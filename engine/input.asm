.include "engine/drivers/input/interface.asm"

.section "Input" BANK 0 SLOT "ROM"

nop

.struct Input
    frame_counter dw
    input1l_q instanceof Queue
    input1h_q instanceof Queue
.endst

.enum $00
    input instanceof Input
.ende

;Defining and init Queue here does not seem to be pushing/pop
;Defining and init in Main seems to work for push, but it keeps pushing over memory
;Queue_Define("INPUT1L_Q", $0090, #$0002, #$0004)
;Queue_Define("INPUT1H_Q", $00A0, #$0002, #$0004)

Input_Init:
    pha
    phy
    phx

    ; Allocate Queue + 4 bytes for the queue
    lda #(_sizeof_Queue)
    adc 4
    jsr Malloc_Bytes

    ; X has the start address
    ; Y has the end address
    jsr Queue_Init

    txy         ; Y is now the start address
    lda 1, S    ; Grab the this pointer again
    tax         ; X is now the proper offset
    tya         ; Put the start address back into the accumulator
    sta input.input1l_q, X ; Store the start address into the input struct


    lda #$0000
    sta input.frame_counter, X

    plx
    ply
    pla
    rts

Input_Frame:
    rts

; X is "this" pointer
Input_VBlank:
    pha
    phx

    inc input.frame_counter, X

    lda JOY1L
    call_ptr(Queue_Push, input.input1l_q)
    call_ptr(Queue_Pop, input.input1l_q)

    ;lda JOY1H
    ;jsr INPUT1H_Q_Push
    ;jsr INPUT1H_Q_Pop

    plx
    pla
    rts

.ends