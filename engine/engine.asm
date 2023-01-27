.include "engine/drivers/snes/interface.asm"
.include "engine/drivers/spc700/interface.asm"

Engine_Init:
 	jsr Snes_Init
    jsr SPC_Init
    rts

Engine_Frame:
	sep     #$20 		;i like colors
	lda     #%10000000  	; Force VBlank by turning off the screen.
	sta     $2100
	lda     #%11100000  		; Load the low byte of the green color.
	sta     $2122
	lda     #%00000000  	; Load the high byte of the green color.
	sta     $2122
	lda     #%00001111  		; End VBlank, setting brightness to 15 (100%).
	sta     $2100
    rts