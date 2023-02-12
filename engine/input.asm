.include "engine/drivers/input/interface.asm"

.section "Input" BANK 0 SLOT "ROM"

.ENUM $80
	Joy1A	db	;B, Y, Select, Start, Up, Down, Left, Right
	Joy1B	db	;A, X, L, R, iiii-ID
.ENDE

Input_Init:
    rts

Input_Frame:
	lda JOY1L
	sta Joy1A
	lda JOY1H
	sta Joy1B
    rts

.ends