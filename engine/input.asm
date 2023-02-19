.include "engine/drivers/input/interface.asm"

.section "Input" BANK 0 SLOT "ROM"

;Defining and init Queue here does not seem to be pushing/pop
;Defining and init in Main seems to work for push, but it keeps pushing over memory
Queue_Define("INPUT1L_Q", $0090, #$0002, #$0004)
Queue_Define("INPUT1H_Q", $00A0, #$0002, #$0004)

Input_Init:
    A16_XY16
    jsr INPUT1L_Q_Init
    jsr INPUT1H_Q_Init
    A8_XY16
    rts

Input_Frame:
    A16_XY16
    lda JOY1L
    jsr INPUT1L_Q_Push
    jsr INPUT1L_Q_Pop
    lda JOY1H
    jsr INPUT1H_Q_Push
    jsr INPUT1H_Q_Pop
    A8_XY16
    rts

.ends