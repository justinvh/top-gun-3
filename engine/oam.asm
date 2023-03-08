; What is an object?
; ==================
; Objects are the primitive that associate sprites. Any small graphic that
; can move independent of the background is an object. They can use the
; palettes from 8-15 and are 4BPP that can be 8x8, 16x16, 32x32, 64x64.
;
; Overview
; ========
; The maximum number of objects that can be displayed on the screen is 128.
; A frame can have two sizes of objects and each object can be one of the two
; sizes. Each frame can have 8 color palettes and an object can use one of the
; palettes. Each palette is 16 colors out of 32,768 colors.
;
; During Initial Settings
; =======================
; - Set register <2101H> to set the object size, name select, and base address.
; - Set D1 of register <2133H> to set the object V select.
; - Set D4 of register <212CH> for "Through Main Obj" settings.
;
; During Forced Blank
; ===================
; - Set register <2115H> to set V-RAM address sequence mode. H/L increments.
; - Set register <2116H> ~ <2119H> to set the V-RAM address and data.
; - Transfer all the object character data to VRAM through the DMA registers.
; - Set register <2121H>, <2122H> to set color palette address and data.
;
; During V-BLANK
; ==============
; - Set register <2102H> ~ <2104H> to set OAM address, priority, and data.
; - Transfer object data to OAM via DMA.
;
; OAM Addressing
; ===============
;                              OBJECT 0
;     | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
;     |----|----|----|----|----|----|---|---|---|---|---|---|---|---|---|---|
; 000 | ~~~~~Object V-Position~~~~~~~~~~~~~ | ~~~~~Object H-Position~~~~~~~ |
;     | 7  | 6  | 5  | 4  | 3  | 2  | 1 | 0 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
; 001 | ~FLIP~  | ~PRIOR~ | ~COLOR~ | ~~~~~~~~~~~~~~~~~~~NAME~~~~~~~~~~~~~~ |
;     | V  | H  | 1  | 0  | 2  | 1  | 0 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
;  .    ^         ^         ^             ^
;       |         |         |              \ Character code number
;       |         |         \ Designate palette for the character
;       |          \Determine the display priority when objects overlap
;        \ X-direction and Y-direction flip. (0 is normal, 1 is flip)
;
; Repeats for 128 objects and then addresses 256 - 271 are for extra bits.
;
;  .                          OBJECT 7...0
; 256 | 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
;     |   OBJ7  |  OBJ6   |   OBJ5  |  OBJ4 | OBJ3  | OBJ2  | OBJ1  | OBJ0  |
;     | S  | Z  | S  | Z  | S  | Z  | S | Z | S | Z | S | Z | S | Z | S | Z |
;       ^    ^
;       |    \ Base position of the Object on the H-direction
;       \ Size large/small (0 is small)
;
.section "OAM" bank 0 slot "ROM"
nop
OAM_Test:
    ldx #0
    jsr OAM_GetColor
    ldx #1
    jsr OAM_GetColor
    ldx #2
    jsr OAM_GetColor
;
; Reinitialize all objects in the OAM
;
OAM_Init:
    stz OAMADDH         ; Set the OAMADDR to 0
    stz OAMADDL         ; Set the OAMADDR to 0
    stz OBSEL           ; Reinitialize object select
    jsr OAM_Test
    ; Clear out the standard 4 bytes for each object
    ; This will clear OAM address data 000 - 255 for D15 - D0
    ldx #128            ; 128 objects
    @LoopRegion1:
        stz OAMDATA     ; Clear X
        stz OAMDATA     ; Clear Y
        stz OAMDATA     ; Clear tile name
        stz OAMDATA     ; Clear last bit of name, color, obj, flip
        dex
        bne @LoopRegion1
    ; Clear out the size and extra X bit for each object
    ; This will clear OAM address data 256 - 271 for D15 - D0
    ldx #(128 / 8)       ; 128 objects for the SX bits (8 objects per word)
    @LoopRegion2:
        stz OAMDATA     ; Clear SZ bits for OBJ 0 ... 7
        stz OAMDATA
        dex
        bne @LoopRegion2
    stz OAMADDH         ; Set the OAMADDR to 0
    stz OAMADDL         ; Set the OAMADDR to 0
    rts
;
; Get the index of the OAM address for the object.
; X index register should be the object's id (0..127)
; Y index register should be word offset (0 or 1)
; Accumulator is set to the OAM address.
;
OAM_Index:
    ; Take the object id and multiply by 2 to get the OAM word address
    phy
    phx
    txa         ; Object offset (not word offset)
    adc 1, S    ; Multiply 2 (now word offset for the base object address)
    clc
    adc 3, S    ; Add the extra word offset
    stz OAMADDH     ; Keep the most significant bit at 0
    sta OAMADDL     ; Set the OAMADDR to the object's word address
    plx
    ply
    rts
;
; Get the 3-bit value of the palette an object is using.
;
; X index register should be the object's id (0..127)
; Accumulator will have the palette value
;
OAM_GetColor:
    phy
    ldy #1          ; Get the word offset for the color palette data
    jsr OAM_Index
    lda OAMDATAREAD ; Ignore the first byte of the word
    lda OAMDATAREAD ; This has the byte we care about
    ror             ; Shift the palette bits to the right
    ror             ; Shift the palette bits to the right
    and #$3         ; Mask the palette bits
    ply
    rts
;
; Get the Name (000H - 1FFH) of the object
; X index register should be the object's id (0..127)
; Accumulator will have the palette value
;
OAM_GetName:
    phy
    ldy #1          ; Get the word offset for the name data
    jsr OAM_Index
    lda OAMDATAREAD ; The first two bytes have the data we care about
    xba             ; Flip the byte and re-read the next byte and swap back
    lda OAMDATAREAD ; Read second byte
    xba             ; Flip the byte back
    and #$2         ; Mask off the all the fields we don't care about
    ply
    rts
;
; Get the Object's size (big or small)
; X index register should be the object's id (0..127)
; Accumulator will have Object's size state.
;
OAM_GetSize:
    rts
;
; Get the object is flipped horizontally
; X index register should be the object's id (0..127)
; Accumulator will have Object's horizontal state.
;
OAM_GetFlipHorizontal:
    phy
    ldy #1          ; Get the word offset for the horizontal
    jsr OAM_Index
    lda OAMDATAREAD ; Ignore the first byte of the word
    lda OAMDATAREAD ; This has the byte we care about
    bit #$40        ; Test the horizontal bit
    beq @NoFlip     ; If it's not set, then we're not flipped
    lda #$1
    ply
    rts
    @NoFlip:
        lda #$0
        ply
        rts
    rts
;
; Get the object is flipped vertically
; X index register should be the object's id (0..127)
; Accumulator will have Object's vertical state.
;
OAM_GetFlipVertical:
    phy
    ldy #1          ; Get the word offset for the vertical
    jsr OAM_Index
    lda OAMDATAREAD ; Ignore the first byte of the word
    lda OAMDATAREAD ; This has the byte we care about
    bit #$80        ; Test the vertical bit
    beq @NoFlip     ; If it's not set, then we're not flipped
    lda #$1
    ply
    rts
    @NoFlip:
        lda #$0
        ply
        rts
;
; Get the object priority.
; X index register should be the object's id (0..127)
; Accumulator will have Object's priority.
;
OAM_GetPriority:
    phy
    ldy #1          ; Get the word offset for the priority
    jsr OAM_Index
    lda OAMDATAREAD ; Ignore the first byte of the word
    lda OAMDATAREAD ; This has the byte we care about
    and #$30        ; Mask off non-priority bits
    lsr             ; Shift priority into the right place
    lsr
    lsr
    ply
    rts
;
; Get the object position.
; X index register should be the object's id (0..127)
; Accumulator will have Object's X position.
;
OAM_GetX:
    phy
    ldy #0          ; Horizontal position is in word 0
    jsr OAM_Index
    lda OAMDATAREAD ; This has the byte we care about
    ; TODO: Add the extra X bit in lower memory
    ply
    rts
;
; Get the object position.
; X index register should be the object's id (0..127)
; Accumulator will have Object's Y position.
;
OAM_GetY:
    phy
    ldy #0          ; vertical position is in word 0
    jsr OAM_Index
    lda OAMDATAREAD ; Ignore horizontal position
    lda OAMDATAREAD ; This has the byte we care about
    ply
    rts
.ends