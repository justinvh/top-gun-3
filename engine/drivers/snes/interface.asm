.section "Snes_Interface" bank 0 slot "ROM" semifree

 Snes_Init:
	A8_XY16

	; Set data bank to be the program bank
	phk
	plb

	; Set direct page and transfer accumulators
	lda #$00
	tcd

	; Turn off screen
	lda #$8F
	sta INIDISP

	@ClearBackground:
		ZeroRegisters($210D, $2114, "Background")

	; Initialize VRAM transfer mode to word-access, increment by 1
	; Set the VRAM address to $0000
	@InitVRAM:
		lda #$80
		sta VMAIN
		stz VMADDL
		stz VMADDH
		
	; Clear Mode7
	@ClearMode7:
		ZeroRegisters($211A, $2120, "Mode7")

	; Clear interlacing, main screens, sub screens, color addition
	@ClearScreen:
		ZeroRegisters($2123, $2133, "Screen")

		; Current theory is that it indicates the status of the "MASTER"
		; pin on the S-PPU1 chip, which in the normal SNES is always GND.
		stz STAT77

		; Disable timers, NMI, and auto-joyread
		stz NMITIMEN

		; Programmable I/O write port, initialize to allow reading at in-port
		lda #$FF
		sta WRIO

		; Disable DMA, H-MA, and make slow ROM (2.68MHz)
		stz MDMAEN
		stz HDMAEN
		stz MEMSEL

		; Reset NMI status and readings
		lda RDNMI

	; Manually clear all of VRAM
	@ClearVRAM:
		lda #$80
		sta VMAIN

		; Set DMA mode to fixed source, WORD to $2118/9
		ldx #$1809
		stx DMAP0

		; Set VRAM low address
		ldx #$0000
		stx VMADDL

		; Set DMA source address low byte
		stx $0000
		stx A1T0L

		; Set DMA source address bank
		lda #$00
		sta A1B0

		; Set DMA transfer size
		ldx #$FFFF
		stx $4305

		; Start DMA transfer on channel 0
		lda #$01
		sta $420B

		; Clear VRAM last byte
		stz $2119

	@ClearPalette:
		lda #$80
		sta CGADD
		ZeroRegister(CGDATA, #$0200, "CGDATA")

	@ClearSpriteTable:
		; Clear sprite tables
		stz OAMADDL
		stz OAMADDH
		ZeroRegister(OAMDATA, #$0220, "OAMDATA")

		; Reset OAM addr for future writes
		stz OAMADDL
		stz OAMADDH

	@ClearWRAM:
		stz WMADDL
		stz WMADDM
		stz WMADDH
		ldx #$8008
		stz DMAP0
		ldx #$0000
		stx A1T0L
		lda #$0000
		sta A1B0
		ldx #$0000
		stx $4305
		lda #$01
		sta $420B
		lda #$01
		sta $420B

	; Data Bank = Program Bank
	phk
	plb

	rts

.ends