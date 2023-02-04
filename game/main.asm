.include "engine/engine.asm"
.include "engine/input.asm"
.include "game/game.asm"

.SECTION "EmptyVectors" SEMIFREE
	EmptyHandler:
		rti
.ENDS

.SNESHEADER
  ID "SNES"                     ; 1-4 letter string, just leave it as "SNES"
  NAME "Top Gun 3: Bottom Gun"
  SLOWROM
  LOROM
  CARTRIDGETYPE $00             ; $00 = ROM only, see WLA documentation for others
  ROMSIZE $08                   ; $08 = 2 Mbits,  see WLA doc for more..
  SRAMSIZE $00                  ; No SRAM         see WLA doc for more..
  COUNTRY $01                   ; $01 = U.S.  $00 = Japan  $02 = Australia, Europe, Oceania and Asia  $03 = Sweden  $04 = Finland  $05 = Denmark  $06 = France  $07 = Holland  $08 = Spain  $09 = Germany, Austria and Switzerland  $0A = Italy  $0B = Hong Kong and China  $0C = Indonesia  $0D = Korea
  LICENSEECODE $00              ; Just use $00
  VERSION $00                   ; $00 = 1.00, $01 = 1.01, etc.
.ENDSNES

.SNESNATIVEVECTOR               ; Define Native Mode interrupt vector table
  COP EmptyHandler
  BRK EmptyHandler
  ABORT EmptyHandler
  NMI Main_VBlank
  IRQ EmptyHandler
.ENDNATIVEVECTOR

.SNESEMUVECTOR                  ; Define Emulation Mode interrupt vector table
  COP EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  RESET Main
  IRQBRK EmptyHandler
.ENDEMUVECTOR

.bank 0

.section "MainCode"

/**
 * Entry point for everything.
 */
Main:
	; Disable interrupts until we're ready
	sei

	; Jump into native mode
	Enable65816
	EnableBinaryMode

	; Set stack
	A16_XY16
	ldx #$1FFF
	txs

	; Setup our engine, game, and other drivers
	jsr Engine_Init
	jsr Game_Init
	jsr Input_Init

	; Turn on the screen, we're ready to play (a000bbbb)
	A8_XY8
	lda	%10001111
	sta $2100

	; Enable interrupts
 	cli

	/**
	* This is main loop that will run the engine and then handle
	* the game logic.
	*/
	@Main_Loop:
		jsr Engine_Frame
		jsr Game_Frame
		jmp @Main_Loop

/**
 * The VBlank interrupt is an NMI that is activated when the vertical
 * blanking period begins (and the interrupt is enabled)
 */
Main_VBlank:
	; Push CPU registers to stack
	A16_XY16
	pha
	phx
	phy
	phb
	phd

	; Reset DB/DP registers
	phk
	plb
	lda #0
	tcd

	; Ideally, we only do these when the Main_Loop says it's done
	; handling a game frame, then we can do the rendering and input
	; and otherwise skip this ISR.
	jsr Engine_Render
	jsr Input_Frame

	; Restore CPU registers
	A16_XY16
	pld
	plb
	ply
	plx
	pla

	; Return from the interrupt
	rti

.ends
