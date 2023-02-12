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
 *     1.1. Clear the carry (clc)
 *     1.2. Set E=0 (xce)
 */
.macro Enable65816
    clc
    xce
    A8_XY16
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
    rep     #%00110000
    .ACCU   16
    .INDEX  16
.endm

/**
 * Set 8-bit Accumulator and 16-bit XY registers
 * ---X----
 */
.macro A8_XY16
    rep    #%00010000
    sep    #%00100000
    .ACCU  8
    .INDEX 16
.endm

/**
 * Set 16-bit Accumulator and 8-bit XY registers
 * --M-----
 */
.macro A16_XY8
    rep    #%00100000
    sep    #%00010000
    .ACCU  16
    .INDEX 8
.endm

/**
 * Set 8-bit Accumulator and 8-bit XY registers
 * --MX----
 */
.macro A8_XY8
    sep    #%00110000
    .ACCU  8
    .INDEX 8
.endm

/**
 * Zero a range of registers
 */
.macro ZeroRegisters ARGS START, END, NAME
    A8_XY16
    ldx #(END - START)
    @ZeroRegister_{NAME}:
        stz END, X
        dex
        bpl @ZeroRegister_{NAME}
.endm

.macro ZeroRegister ARGS REGISTER, COUNT, NAME
    A8_XY16
    ldx #(COUNT)
    @ZeroRegister_{NAME}:
        stz REGISTER
        dex
        bpl @ZeroRegister_{NAME}
.endm

.macro LoadSprite ARGS X, Y, NAME, FLIP, DEBUG_NAME
@LoadSprite{DEBUG_NAME}:
    ; horizontal position of second sprite
    lda #(256/2 + X)
    sta OAMDATA

    ; vertical position of second sprite
    lda #(224/2 + Y)
    sta OAMDATA

    ; name of second sprite
    lda #(NAME)
    sta OAMDATA

    ; no flip, prio 0, palette 0
    lda #(FLIP)
    sta OAMDATA
.endm