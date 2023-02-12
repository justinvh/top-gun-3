.include "common/memorymap.i"
.include "common/alias.i"
.include "common/macros.i"
.include "common/lib/queue.i"
.include "common/lib/stack.i"

.include "engine/engine.asm"
.include "engine/input.asm"

.include "game/game.asm"

.SNESNATIVEVECTOR
  COP EmptyHandler
  BRK EmptyHandler
  ABORT EmptyHandler
  NMI Main_VBlank
  IRQ EmptyHandler
.ENDNATIVEVECTOR

.SNESEMUVECTOR
  COP EmptyHandler
  ABORT EmptyHandler
  NMI EmptyHandler
  RESET Main
  IRQBRK EmptyHandler
.ENDEMUVECTOR

.section "MainCode" bank 0 slot "ROM"
; Define a queue that starts at $0000 and has size 2
Stack_Define("S1", $0000, #$0002)
Queue_Define("Q1", $0010, #$0002)

Stack_Init:
    A16_XY16

    jsr S1_Init

    lda #$1234
    jsr S1_Push

    lda #$4567
    jsr S1_Push

    lda #$FFFF

    ; $4567
    jsr S1_Pop

    ; $1234
    jsr S1_Pop

    A8_XY16

    rts

Queue_Init:
    A16_XY16

    jsr Q1_Init

    lda #$1234
    jsr Q1_Push

    lda #$4567
    jsr Q1_Push

    lda #$FFFF

    ; $1234
    jsr Q1_Pop

    ; $5678
    jsr Q1_Pop

    A8_XY16

    rts

/**
 * Entry point for everything.
 */
Main:
    ; Disable interrupts
    sei

    ; Enter 65816, default to A8XY16
    Enable65816
    EnableBinaryMode
    
    ; Set stack pointer
    ldx #$1FFF
    txs

    ; Setup our engine, game, and other drivers
    jsr Stack_Init
    jsr Queue_Init
    jsr Engine_Init
    jsr Game_Init
    jsr Input_Init

    ; Turn on the screen, we're ready to play (a000bbbb)
    lda #$0F
    sta INIDISP
    
    ; Enable interrupts and joypad polling
    lda #$81
    sta NMITIMEN
    cli

    ; Main game loop
    @Main_Loop:
        wai
        jsr Engine_Frame
        jsr Game_Frame
        jmp @Main_Loop

/**
 * The VBlank interrupt is an NMI that is activated when the vertical
 * blanking period begins (and the interrupt is enabled)
 */
Main_VBlank:
    ; read NMI status, acknowledge NMI
    A8_XY16
    lda    RDNMI

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
    A8_XY16
    jsr Input_Frame
    jsr Engine_Render
    
    ; Restore CPU registers
    A16_XY16
    pld
    plb
    ply
    plx
    pla

    ; Return from the interrupt
    rti

EmptyHandler:
    rti

.ends