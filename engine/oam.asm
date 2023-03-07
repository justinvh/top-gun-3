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

;
; Reinitialize all objects in the OAM
;
OAM_Init:
    stz OAMADDL         ; Set the OAMADDR to 0
    stz OAMADDH         ; Set the OAMADDR to 0

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

    stz OAMADDL         ; Set the OAMADDR to 0
    stz OAMADDH         ; Set the OAMADDR to 0

    rts


;
; Get or Set the 3-bit value of the palette an object is using.
;
; X index register should be the object's id (0..127)
; Y index register is set, then the palette is set from the accumulator.
;
OAM_Color:
    rts

;
; Get or Set the Name (000H - 1FFH) of the object
; X index register should be the object's id (0..127)
; Y index register is set, then the VRAM address is set from the accumulator.
;
OAM_Name:
    rts

;
; Get or Set the Object's size (big or small)
; X index register should be the object's id (0..127)
; Y index register is set, then the object size is set from the accumulator.
; Otherwise, accumulator will have Object's size state.
;
OAM_Size:
    rts

;
; Get or Set the object is flipped horizontally
; X index register should be the object's id (0..127)
; Y index register is set, then the object flip is set from the accumulator.
; Otherwise, accumulator will have Object's horizontal state.
;
OAM_FlipHorizontal:
    rts

;
; Get or Set the object is flipped vertically 
; X index register should be the object's id (0..127)
; Y index register is set, then the object flip is set from the accumulator.
; Otherwise, accumulator will have Object's vertical state.
;
OAM_FlipVertical:
    rts

;
; Get or Set the object priority.
; X index register should be the object's id (0..127)
; Y index register is set, then the object priority is set from the accumulator.
; Otherwise, accumulator will have Object's priority.
;
OAM_Priority:
    rts

;
; Get or Set the object position.
; X index register should be the object's id (0..127)
; Y index register is set, then the object pos is set from the accumulator.
; Otherwise, accumulator will have Object's X position.
;
OAM_X:
    rts

;
; Get or Set the object position.
; X index register should be the object's id (0..127)
; Y index register is set, then the object pos is set from the accumulator.
; Otherwise, accumulator will have Object's Y position.
;
OAM_Y:
    rts

.ends