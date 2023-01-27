.include "engine/drivers/input/interface.asm"
.define CNTRL1L $4218
.define CNTRL1H $4219

.ENUM $80
	Joy1A	db	;B, Y, Select, Start, Up, Down, Left, Right
	Joy1B	db	;A, X, L, R, iiii-ID
.ENDE

Input_Init:
    jsr INPUT_Init
    rts

Input_Frame:
	lda CNTRL1L     ; $4218
	sta Joy1A
	lda CNTRL1H     ; $4219
	sta Joy1B
    nop
    rts