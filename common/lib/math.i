.include "common/lib/point.i"

.section "Math" BANK 0 SLOT "ROM"

.ACCU	16
.INDEX	16

nop

;
; Use the SNES to do 16-bit unsigned math
; X/A -> Y, REMAINDER in X
Math_Div:

    ; Write dividend to WRDIV
    pha
    txa
    sta WRDIVL
    pla

    ; Write divisor
    A8
    sta WRDIVB
    A16

    ; Wait 16 machine cycles
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    ; Load result
    lda RDDIVL
    tay

    ; Put remainder in X
    lda RDMPYL
    tax

    rts

.ends