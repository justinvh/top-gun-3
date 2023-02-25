.section "Queue" BANK 0 SLOT "ROM"

.ACCU	16
.INDEX	16

nop

.struct Queue
    base_addr: dw ; Data buffer start address
    buf_len:   dw ; Data buffer length
    head_idx:  dw ; Head index counter
    tail_idx:  dw ; Tail index counter
.endst

.enum $00
    queue instanceof Queue
.ende

; Expects X to be the start of the memory address
; Expects Y to be the end of the memory address
Queue_Init:
    pha
    phx
    phy

    ; Set the initial offset for all the pointers
    txa
    adc #(_sizeof_Queue)
    sta queue.base_addr, X

    ; Compute the size (number of bytes)
    tya
    phx
    sec
    sbc 1, S
    sbc #(_sizeof_Queue)
    clc
    plx
    tay

    ; Set the buffer length and head/tail indexes
    sty queue.buf_len, X
    stz queue.head_idx, X
    stz queue.tail_idx, X

    ply
    plx
    pla
    rts

; Pushes whatever is in the accumulator
; Expects X to be the start of the memory address
Queue_Push:
    pha
    phx
    phy

    ; Save the accumulator
    pha

    ; Get the tail index
    ldy queue.tail_idx, X

    ; Compute pointer offset
    lda queue.base_addr, X
    phy
    adc 1, S
    ply
    tay

    ; Store accumulator at pointer offset
    ; Restore accumulator and save value
    pla
    sta $0, Y

    ; Increment the tail index
    inc queue.tail_idx, X
    inc queue.tail_idx, X

    ; Check if the tail index is past the buffer length
    lda queue.buf_len, X
    sec
    sbc queue.tail_idx, X
    bne @Done

    ; Reset tail index
    stz queue.tail_idx, X

    @Done:
    ply
    plx
    pla
    rts


; Pulls whatever is at the head into the accumulator
; Expects X to be the start of the memory address
Queue_Pop:
    phx
    phy

    ; Get the head index
    ldy queue.head_idx, X

    ; Compute pointer offset
    lda queue.base_addr, X
    phy
    adc 1, S
    ply
    tay

    ; Store accumulator at pointer offset
    lda $0, Y
    pha

    ; Increment the head index
    inc queue.head_idx, X
    inc queue.head_idx, X

    ; Check if the tail index is past the buffer length
    lda queue.buf_len, X
    sec
    sbc queue.head_idx, X
    bne @Done

    ; Reset tail index
    stz queue.head_idx, X

    @Done:

    pla
    ply
    plx
    rts

.ends