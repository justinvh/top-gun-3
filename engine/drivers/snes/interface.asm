.include "engine/oam.asm"

.section "Snes_Interface" bank 0 slot "ROM" semifree

nop

 Snes_Init:
    pha
    phx
    phy

    A8_XY16

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
        ldx #$0000
        stx VMADDL

        ; Set DMA source address low byte
        stx $0000
        stx A1T0L

        ; Set DMA source address bank
        ; This does erase byte 0 of the bank. So, caution.
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

    A16_XY16

    jsr OAM_Init

    ply
    plx
    pla
    rts

.ends