.include "engine/drivers/snes/interface.asm"

.section "Engine" BANK 0 SLOT "ROM"

Engine_Init:
 	jsr Snes_Init
    ; jsr SPC_Init
    rts

; testing. checks if x key is pressed and changes background color in change_bg
Engine_Frame:
	lda Joy1A
	cmp #$02
	beq @ChangeBG
	rts

	; Reset the CGRAM address register and write a stupid color to it
	@ChangeBG:
		stz CGADD
		lda #$FF
		sta CGDATA
		lda #$FF
		sta CGDATA
	rts

Engine_Render:
	lda #$10
	sta TM
    rts

.ends