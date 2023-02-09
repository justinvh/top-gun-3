.include "engine/drivers/snes/interface.asm"
.include "engine/drivers/spc700/interface.asm"

Engine_Init:
 	jsr Snes_Init
    ; jsr SPC_Init
    rts

; testing. checks if x key is pressed and changes background color in change_bg
Engine_Frame:
	A8_XY8
	lda Joy1A
	cmp #$2F
	BEQ Change_BG
	lda	#%00001111
	sta	$2122

	rts

Change_BG:
	lda	#%00011110
	sta	$2122

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