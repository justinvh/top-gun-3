.ACCU   16
.INDEX  16

.include "engine/font.asm"
.section "Fonts" bank 0 slot "ROM"

Font_8x8:
    @bin: .incbin "resources/fonts/8x8-font.bin"
    @pal: .incbin "resources/fonts/8x8-font.pal"

    .dstruct @Header instanceof Font values
        name:   .db "8x8"           ; Name
        bpp:    .db 2               ; 2 bits per pixel for BG3
        width:  .db 128             ; 128 pixels wide
        height: .db 128             ; 128 pixels high
        bin:    .dw Font_8x8@bin    ; Pointer to binary data
        pal:    .dw Font_8x8@pal    ; Pointer to palette data
        bg:     .db 3               ; Which background VRAM space to use
    .endst

.ends