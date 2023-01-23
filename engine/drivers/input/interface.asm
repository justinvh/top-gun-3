.define NMITIMEN $4200          ; vblank flag

INPUT_Init:
	lda #%10000001	; Enable NMI and Auto Joypad read
	sta NMITIMEN   	; Interrupt Enable Flags
    rts