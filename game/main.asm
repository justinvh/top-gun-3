.ACCU	16
.INDEX 16

.include "common/memorymap.i"
.include "common/alias.i"
.include "common/macros.i"
.include "common/lib/malloc.i"

.ramsection "RAM" bank 0 slot "WRAM" offset 0
    malloc instanceof Malloc
.ends

.include "common/lib/math.i"
.include "common/lib/queue.i"
.include "common/lib/stack.i"
.include "game/game.asm"

.ramsection "MallocInitializeRAM" appendto "RAM"
    malloc_initialize db
.ends

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
nop

;
; Entry point for everything.
;
Main:
    ; Disable interrupts
    sei

    ; Enter 65816, default to A8XY16
    Enable65816
    EnableBinaryMode

    A16_XY16
    
    ; Initial write just to say we haven't set game pointer
    stz $0000

    ; Set stack pointer
    ldx #$1FFF
    txs

    ; Setup allocators (default to offset 0x0004)
    jsr Malloc_Init

    ; Allocate memory for a game
    ; X will have start address
    lda #(malloc_initialize) ; Load the size of the Game object
    jsr Malloc_Bytes    ; Expects A to be the malloc size

    jsr Game_Init       ; Expects X to be the "this" pointer

    A8

    lda #$0F
    sta INIDISP
    
    ; Enable interrupts and joypad polling
    lda #$81
    sta NMITIMEN
    cli

    A16

    ; Main game loop
    @Main_Loop:
        wai             ; Wait for interrupt
        jsr Game_Frame  ; Expects X to be the "this" pointer
        jmp @Main_Loop  ; Loop forever

;
; The VBlank interrupt is an NMI that is activated when the vertical
; blanking period begins (and the interrupt is enabled)
;
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

    ; read NMI status, acknowledge NMI, and turn off screen
    A8
    lda RDNMI
    lda #$8F
    sta INIDISP

    ; Ideally, we only do these when the Main_Loop says it's done
    ; handling a game frame, then we can do the rendering and input
    ; and otherwise skip this ISR.
    A16
    jsr Game_VBlank ; Expects X to be the "this" pointer

    ; Re-enable the screen
    A8
    lda #$0F
    sta INIDISP

    ; Restore CPU registers
    A16
    pld
    plb
    ply
    plx
    pla

    ; Return from NMI
    rti

EmptyHandler:
    rti

.ends