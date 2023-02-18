.include "engine/drivers/input/interface.asm"

.section "Input" BANK 0 SLOT "ROM"

.ENUM $80
    Joy1A db    ;B, Y, Select, Start, Up, Down, Left, Right
    Joy1B db    ;A, X, L, R, iiii-ID
.ENDE

;Defining and init Queue here does not seem to be pushing/pop
;Defining and init in Main seems to work for push, but it keeps pushing over memory
Queue_Define("INPUT1_Q", $0090, #$0002)
Queue_Define("INPUT2_Q", $00A0, #$0002)

Input_Init:
    A16_XY16
    jsr INPUT1_Q_Init
    jsr INPUT2_Q_Init
    A8_XY16
    rts

Input_Frame:
    A16_XY16
    ; lda JOY1L
    lda #$FFFF
    jsr INPUT1_Q_Push
    ; lda JOY1H
    jsr INPUT1_Q_Push
    ; lda #$AAAA
    jsr INPUT1_Q_Pop
    jsr INPUT1_Q_Pop
    ; sta $86
    ; sta Joy1A
    ; lda JOY1H
    ; sta Joy1B

    A8_XY16
    rts

.ends