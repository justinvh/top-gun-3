;
; Font management routines for an 8x8 2BPP font
;

.section "Font" bank 0 slot "ROM"

.define MAX_FONTS 2

.macro incfont args _name, _width, _height
    Font_{_name}:
        @bin: .incbin resources/fonts/{_name}-font.bin
        @pal: .incbin resources/fonts/{_name}-font.pal
        .dstruct @Header instanceof Font values
            name:    .db _name
            bpp:     .db 2
            width:   .db _width
            height:  .db _height
            bin_ptr: .dw @bin
            pal_ptr: .dw @pal
            words:   .dw (((_width * _height) / 2) >> 2)
        .endst
.endm

.struct Font
    name    ds 8    ; Name of the font
    bpp     db      ; Bits per pixel
    width   dw      ; Width of each character in pixels
    height  dw      ; Height of each character in pixels
    bin_ptr dw      ; Pointer to the font data
    pal_ptr dw      ; Pointer to the palette to use
    words   dw      ; Number of words to load to VRAM
.endst

.struct FontVRAMInfo
    font_ptr        dw ; Pointer to the font
    bg_vram         dw ; VRAM bg mode
    char_vram_addr  dw ; VRAM address to load the font to
.endst

.struct FontDrawInfo
    font_vram_info_ptr dw ; Pointer to the font VRAM info
    x               db   ; X position to draw at
    y               db   ; Y position to draw at
    time            db   ; Time between character drawing
    mode            db   ; If 0, draw the string, if 1 use as indices
    color           db   ; Color to draw with
    data_ptr        dw   ; Pointer to the string or indices
.endst

.struct FontManager
    font_vram_info instanceof FontVRAMInfo MAX_FONTS
    font_draw_info instanceof FontDrawInfo
    bg_manager_ptr dw   ; Pointer to the BG manager to use
    
.endst

.enum $0000
    font instanceof Font
.ende
.enum $0000
    font_manager instanceof FontManager
.ende
.enum $0000
    font_vram_info instanceof FontVRAMInfo
.ende

FontManager_Init:
    rts
;
; Load a font in FontManager.font
; Expects A to point to the font to load
; Expects X to point to the font manager object
;
FontManager_Load:
    pha
    phx
    phy

    sta font_manager.font_vram_info.1.font_ptr, X

    ; Store in Y the number of words to load
    phx
    tax
    ldy font.words, X
    plx

    ; Use the 2BPP plane 3rd background for the font
    lda #3
    sta font_manager.font_vram_info.1.bg_vram, X

    ; Get the background manager pointer and get the next VRAM address
    ; and store it in the current font VRAM info
    phx
    lda font_manager.bg_manager_ptr, X
    tax
    lda bg_manager.bg_info.3.next_char_vram, X

    ; Prepare BGManager to advance the VRAM address for BG3 
    ; X points to the BGManager object currently
    ; Y currently points to the number of words to load
    jsr BGManager_BG3Next

    ; Pop the stack. Store the VRAM address in the font VRAM info
    plx
    sta font_manager.font_vram_info.1.char_vram_addr, X

    ; Font is now ready to write to VRAM
    lda font_manager.font_vram_info.1.font_ptr, X
    tax

    ; X now points to the font object
    ; VRAM is ready to be written to
    ; Y will be our counter for decrementing
    lda font.words, X
    tay

    ; Make X point to the bin object for the font
    lda font.bin_ptr, X
    tax

    A8
    @VRAMLoop:
        lda $0, X           ; Load bitplane 0
        sta VMDATAL         ; Store data to VRAM
        inx                 ; Increment X register for the data
        lda $0, X           ; Load bitplane 1
        sta VMDATAH         ; Store data to VRAM
        inx                 ; Increment X register for the data
        dey                 ; Decrement Y register for the counter
        bne @VRAMLoop       ; If Y is not 0, loop

    A16
    ply
    plx
    pla
    rts

;
; Dumb drawing code for now
; Expects A to point to the string to render. Should be terminated with 0.
;
FontManager_Draw:
    pha
    phx
    phy

    tax
    ldy #0
    @Loop:
        clc

        A16
        tya
        adc #BG3_TILEMAP_VRAM ; This is hacky
        sta VMADDL

        A8
        lda $0, X
        cmp #0
        beq @Done

        dea ; Strings are offset by 1
        
        sta VMDATAL
        stz VMDATAH

        iny
        inx
        bra @Loop

    @Done:

    A16
    ply
    plx
    pla
    rts

.ends