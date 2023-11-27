.struct SNES
    init db
.endst

.ramsection "SNESRAM" appendto "RAM"
    snes instanceof SNES
.ends

.section "SNES_Interface" bank 0 slot "ROM" semifree

nop
SNES_Init:
    pha
    phx
    phy

    A8

    ; Disable timers, NMI, and auto-joyread
    stz NMITIMEN

    ; Turn off screen
    lda #$8F
    sta INIDISP

    @ClearBackground:
        ZeroRegisters($2105, $2114, "Background")

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
        stz VMADDL

        ; Set DMA source address to be a byte on the stack
        A16
        lda #0      ; Store 0 into the current stack pointer
        pha
        pla
        tsc         ; Copy stack pointer to accumulator
        sta A1T0L   ; Tell the DMA engine to read from the stack
        A8

        ; Set DMA source address bank from stack
        phb         ; Save bank
        pla         ; Pull bank into accumulator
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

    A16

    ply
    plx

    lda #1
    sta snes.init.w

    pla
    rts

.ends
