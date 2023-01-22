.include "engine/engine.asm"
.include "game/game.asm"

.SNESNATIVEVECTOR               ; Define Native Mode interrupt vector table
  COP EmptyHandler
  BRK EmptyHandler
  ABORT EmptyHandler
  NMI VBlank
  IRQ EmptyHandler
.ENDNATIVEVECTOR

.SNESEMUVECTOR                  ; Define Emulation Mode interrupt vector table
  COP EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  RESET Main
  IRQBRK EmptyHandler
.ENDEMUVECTOR

VBlank:	    			; Needed to satisfy interrupt definition in "header.inc"
	RTI

.bank 0

.section "MainCode"

Main:
	nop
	sei 	 	; Disabled interrupts
 	clc 	 	; clear carry to switch to native mode
 	xce 	 	; Xchange carry & emulation bit. native mode
 	rep 	#$18 	; Binary mode (decimal mode off), X/Y 16 bit
    ldx 	#$1FFF  ; set stack to $1FFF
    txs
	jsr Engine_Init
	jsr Game_Init
 	cli
	@Main_Loop:
		jsr Engine_Frame
		jsr Game_Frame
		jmp @Main_Loop

.ends
