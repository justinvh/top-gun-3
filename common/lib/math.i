.include "common/lib/point.i"

.section "Math" BANK 0 SLOT "ROM"

.ACCU	16
.INDEX	16

nop

;
; Use the SNES to do 16-bit unsigned math
; X/A -> Y, REMAINDER in X
SNES_Math_Divide:

    ; Write dividend to WRDIV
    pha
    txa
    sta WRDIVL
    xba
    sta WRDIVH
    pla

    ; Write divisor
    sta WRDIVB

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
    xba
    lda RDDIVH
    xba
    tay

    ; Put remainder in X
    lda RDMPYL
    xba
    lda RDMPYH
    xba
    tax

    rts

;
; 16-bit divide: X/A -> Y, REMAINDER in X
; This is equivalent to N/D -> Q
; Native mode: all registers set to 16-bit modes
; No special handling for divide by zero
;
Math_Divide:
    clc
    pha    ; Save divisor
    ldy #1 ; Initialize shift counter to 1

    ; Create quotient temporary variable
    ; and initialize it to zero.
    pha
    lda #0
    sta 1, S

    ; Restore divisor into the accumulator
    lda 3, S

    ; Shift divisor all the way to the left and then start subtracting
    @AlignSignificantBit:
        asl                      ; Shift divisor: test leftmost bit
        bcs @PrepareSubtract     ; Branch when we get the leftmost bit
        iny                      ; else increment shift count
        cpy #17                  ; and test again (all zeroes in divisor)
        bne @AlignSignificantBit ; until we get to the leftmost bit
    
    ; We add the bit back in so it is aligned (since we shifted it out)
    @PrepareSubtract:
        ror       ; Put shifted-out bit back

    ; Subtract divisor from dividend until divisor is zero
    @Subtract:
        pha       ; Save divisor
        txa       ; Copy dividend to accumulator
        sec       ; Set carry for subtract
        sbc 1, S  ; Subtract divisor from dividend
        bcc @ShiftDivisorRight ; Branch if we can't subtract; dividend still in X
        tax       ; Save new dividend in X; carry=1 for quotient

    ; Shift divisor right and decrement shift count
    @ShiftDivisorRight:
        lda 3, S  ; Get quotient
        rol       ; Shift carry -> qutient (1 for divide, 0 for not) 
        sta 3, S  ; Save new quotient
        pla       ; Restore divisor
        lsr       ; Shift divisor right
        dey       ; Decrement shift count
        bne @Subtract ; Loop until divisor is zero

    ; Dividend will be in X
    ; Restore quotient to Y
    lda 1, S
    tay

    pla     ; Toss temporary quotient variable
    pla     ; Toss temporary divisor variable

    rts

.ends