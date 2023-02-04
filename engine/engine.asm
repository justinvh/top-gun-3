.include "engine/drivers/snes/interface.asm"
.include "engine/drivers/spc700/interface.asm"

Engine_Init:
 	jsr Snes_Init
    ; jsr SPC_Init
    rts

Engine_Frame:
	rts

Engine_Render:
	A8_XY8

	; Make the screen red
	; The SNES will automatically do address increment
	; 0bbbbbgg gggrrrrr
	lda	#%00011111
	sta	$2122
	lda	#%00000000
	sta	$2122

    rts