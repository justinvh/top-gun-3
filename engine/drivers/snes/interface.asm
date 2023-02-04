.include "engine/config/rom.asm"


/*
Processor flags for 65816 native mode
=========================
Bits: 7   6   5   4   3   2   1   0

                                 |e├─── Emulation: 0 = Native Mode
     |n| |v| |m| |x| |d| |i| |z| |c|
     └┼───┼───┼───┼───┼───┼───┼───┼┘
      │   │   │   │   │   │   │   └──────── Carry: 1 = Carry set
      │   │   │   │   │   │   └───────────── Zero: 1 = Result is zero
      │   │   │   │   │   └────────── IRQ Disable: 1 = Disabled
      │   │   │   │   └───────────── Decimal Mode: 1 = Decimal, 0 = Hexadecimal
      │   │   │   └──────── Index Register Select: 1 = 8-bit, 0 = 16-bit
      │   │   └─────────────── Accumulator Select: 1 = 8-bit, 0 = 16-bit
      │   └───────────────────────────── Overflow: 1 = Overflow set
      └───────────────────────────────── Negative: 1 = Negative set
*/

/**
 * Enable 65816 mode and put into 16-bit addressing
 * 1. Put the CPU into 65816 mode (native 16-bit)
 * 	1.1. Clear the carry (clc)
 * 	1.2. Set E=0 (xce)
 */
.macro Enable65816
	clc
	xce
	rep 	#%00110000
	.ACCU	16
	.INDEX	16
.endm

/**
 * Set Binary Mode
 * ----D---
 */
 .macro EnableBinaryMode
	rep #%00001000
.endm

/**
 * Set 16-bit Accumulator and XY Index Registers
 * --MX----
 *
 * This is done by resetting the processor state for the
 * accumulator and index register select flags. When the
 * flags are set to 1, then we are resetting the value back
 * to 0, which puts the state into 16-bit for Accumulator and XY
 */
.macro A16_XY16
	rep 	#%00110000
	.ACCU	16
	.INDEX	16
.endm

/**
 * Set 8-bit Accumulator and 16-bit XY registers
 * ---X----
 */
.macro A8_XY16
	rep 	#%00010000
	sep		#%00100000
	.ACCU	8
	.INDEX	16
.endm

/**
 * Set 16-bit Accumulator and 8-bit XY registers
 * --M-----
 */
.macro A16_XY8
	rep 	#%00100000
	sep		#%00010000
	.ACCU	16
	.INDEX	8
.endm

/**
 * Set 8-bit Accumulator and 8-bit XY registers
 * --MX----
 */
.macro A8_XY8
	sep		#%00110000
	.ACCU	8
	.INDEX	8
.endm

.bank 0 slot 0
.org 1
 .section "Snes_Init" SEMIFREE

 Snes_Init:
	; Sanity Checks / Learning
	jsr		A16_XY16_Test

	; Sanity Checks / Learning
	jsr		A8_XY8_Test

	; 8-bit addressing and index registers for initialization
	A8_XY8
 	lda 	#$8F	; Screen off, full brightness
 	sta 	$2100   ; brightness + screen enable register 
 	stz 	$2101   ; Sprite register (size + address in VRAM) 
 	stz 	$2102   ; Sprite registers (address of sprite memory [OAM])
 	stz 	$2103   ;    ""                       ""
 	stz 	$2105   ; Mode 0, = Graphic mode register
 	stz 	$2106   ; noplanes, no mosaic, = Mosaic register
 	stz 	$2107   ; Plane 0 map VRAM location
 	stz 	$2108   ; Plane 1 map VRAM location
 	stz 	$2109   ; Plane 2 map VRAM location
 	stz 	$210A   ; Plane 3 map VRAM location
 	stz 	$210B   ; Plane 0+1 Tile data location
 	stz 	$210C   ; Plane 2+3 Tile data location
 	stz 	$210D   ; Plane 0 scroll x (first 8 bits)
 	stz 	$210D   ; Plane 0 scroll x (last 3 bits) #$0 - #$07ff
 	lda 	#$FF    ; The top pixel drawn on the screen isn't the top one in the tilemap, it's the one above that.
 	sta 	$210E   ; Plane 0 scroll y (first 8 bits)
 	sta 	$2110   ; Plane 1 scroll y (first 8 bits)
 	sta 	$2112   ; Plane 2 scroll y (first 8 bits)
 	sta 	$2114   ; Plane 3 scroll y (first 8 bits)
 	lda 	#$07    ; Since this could get quite annoying, it's better to edit the scrolling registers to fix this.
 	sta 	$210E   ; Plane 0 scroll y (last 3 bits) #$0 - #$07ff
 	sta 	$2110   ; Plane 1 scroll y (last 3 bits) #$0 - #$07ff
 	sta 	$2112   ; Plane 2 scroll y (last 3 bits) #$0 - #$07ff
 	sta 	$2114   ; Plane 3 scroll y (last 3 bits) #$0 - #$07ff
 	stz 	$210F   ; Plane 1 scroll x (first 8 bits)
 	stz 	$210F   ; Plane 1 scroll x (last 3 bits) #$0 - #$07ff
 	stz 	$2111   ; Plane 2 scroll x (first 8 bits)
 	stz 	$2111   ; Plane 2 scroll x (last 3 bits) #$0 - #$07ff
 	stz 	$2113   ; Plane 3 scroll x (first 8 bits)
 	stz 	$2113   ; Plane 3 scroll x (last 3 bits) #$0 - #$07ff
 	lda 	#$80    ; increase VRAM address after writing to $2119
 	sta 	$2115   ; VRAM address increment register
 	stz 	$2116   ; VRAM address low
 	stz 	$2117   ; VRAM address high
 	stz 	$211A   ; Initial Mode 7 setting register
 	stz 	$211B   ; Mode 7 matrix parameter A register (low)
 	lda 	#$01
 	sta 	$211B   ; Mode 7 matrix parameter A register (high)
 	stz 	$211C   ; Mode 7 matrix parameter B register (low)
 	stz 	$211C   ; Mode 7 matrix parameter B register (high)
 	stz 	$211D   ; Mode 7 matrix parameter C register (low)
 	stz 	$211D   ; Mode 7 matrix parameter C register (high)
 	stz 	$211E   ; Mode 7 matrix parameter D register (low)
 	sta 	$211E   ; Mode 7 matrix parameter D register (high)
 	stz 	$211F   ; Mode 7 center position X register (low)
 	stz 	$211F   ; Mode 7 center position X register (high)
 	stz 	$2120   ; Mode 7 center position Y register (low)
 	stz 	$2120   ; Mode 7 center position Y register (high)
 	stz 	$2121   ; Color number register ($0-ff)
 	stz 	$2123   ; BG1 & BG2 Window mask setting register
 	stz 	$2124   ; BG3 & BG4 Window mask setting register
 	stz 	$2125   ; OBJ & Color Window mask setting register
 	stz 	$2126   ; Window 1 left position register
 	stz 	$2127   ; Window 2 left position register
 	stz 	$2128   ; Window 3 left position register
 	stz 	$2129   ; Window 4 left position register
 	stz 	$212A   ; BG1, BG2, BG3, BG4 Window Logic register
 	stz 	$212B   ; OBJ, Color Window Logic Register (or,and,xor,xnor)
 	sta 	$212C   ; Main Screen designation (planes, sprites enable)
 	stz 	$212D   ; Sub Screen designation
 	stz 	$212E   ; Window mask for Main Screen
 	stz 	$212F   ; Window mask for Sub Screen
 	lda 	#$30
 	sta 	$2130   ; Color addition & screen addition init setting
 	stz 	$2131   ; Add/Sub sub designation for screen, sprite, color
 	lda 	#$E0
 	sta 	$2132   ; color data for addition/subtraction
 	stz 	$2133   ; Screen setting (interlace x,y/enable SFX data)
 	stz 	$4200   ; Enable V-blank, interrupt, Joypad register
 	lda 	#$FF
 	sta 	$4201   ; Programmable I/O port
 	stz 	$4202   ; Multiplicand A
 	stz 	$4203   ; Multiplier B
 	stz 	$4204   ; Multiplier C
 	stz 	$4205   ; Multiplicand C
 	stz 	$4206   ; Divisor B
 	stz 	$4207   ; Horizontal Count Timer
 	stz 	$4208   ; Horizontal Count Timer MSB (most significant bit)
 	stz 	$4209   ; Vertical Count Timer
 	stz 	$420A   ; Vertical Count Timer MSB
 	stz 	$420B   ; General DMA enable (bits 0-7)
 	stz 	$420C   ; Horizontal DMA (HDMA) enable (bits 0-7)
	stz 	$420D	; Accss cycle designation (slow/fast rom)
 	rts

/**
 * Quick 16-bit Sanity Checks
 */
 A16_XY16_Test:
	A16_XY16
	.ACCU	16
	.INDEX	16

	lda		#$BBAA
	ldx		#$1111
	ldy		#$2222

	phx
	phy
	pha

	lda		#$0000
	ldx		#$0000
	ldy		#$0000

	pla
	ply
	plx

	rts

/**
 * Quick 8-bit Sanity Checks
 */
A8_XY8_Test:
	A8_XY8
	.ACCU	8
	.INDEX	8

	lda		#$AA
	ldx		#$11
	ldy		#$22

	phx
	phy
	pha

	lda		#$00
	ldx		#$00
	ldy		#$00

	pla
	ply
	plx

	rts
 .ends