.ACCU	16
.INDEX 16

.include "common/memorymap.i"
.include "common/alias.i"
.include "common/macros.i"
.include "common/lib/malloc.i"
.include "common/lib/math.i"
.include "common/lib/queue.i"
.include "common/lib/stack.i"

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
nop

; Special pointer to the global game object for nmi
.define GAME_GLOBAL $0000

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

    ldx #7
    lda #3
    jsr Math_Divide

    ; Setup allocators (default to offset 0x0004)
    jsr Malloc_Init

    ; Allocate memory for a game
    ; X will have start address
    lda #(_sizeof_Game) ; Load the size of the Game object
    jsr Malloc_Bytes    ; Expects A to be the malloc size

    jsr Game_Init       ; Expects X to be the "this" pointer

    ; Store the X pointer to the game object in the global variable
    stx GAME_GLOBAL     ; Put Game pointer into the first address as global variable

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
    ; read NMI status, acknowledge NMI
    A8_XY16
    lda RDNMI

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
    ldx ($0000)     ; Get the global game object pointer
    jsr Game_VBlank ; Expects X to be the "this" pointer

    ; Restore CPU registers
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