.section "Queue" BANK 0 SLOT "ROM"

.ACCU	16
.INDEX	16

nop

.struct Queue
    start: dw
    head:  dw
    tail:  dw
    end:   dw
    size:  dw
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

    ; Set the end of the memory address
    sty queue.end, X

    ; Set the initial offset for all the pointers
    txa
    adc #(_sizeof_Queue)

    ; Set the start of the queue
    sta queue.start, X
    sta queue.head, X
    sta queue.tail, X

    ply
    plx
    pla
    rts

; Pushes whatever is in the accumulator
; Expects X to be the start of the memory address
Queue_Push:
    sta (queue.tail, X)
    inc queue.tail, X
    inc queue.tail, X
    rts

; Pulls whatever is at the head into the accumulator
; Expects X to be the start of the memory address
Queue_Pop:
    lda (queue.head, X)
    inc queue.head, X
    inc queue.head, X
    rts

; Sets the z flag if the Queue is empty.
; An empty queue is one that queue.head == queue.tail and queue
Queue_Empty:
    rts

; Sets the accumulator to the size of the Queue
Queue_Size:
    lda queue.tail, X
    cmp queue.head, X
    bcs @Positive
    clc
    sbc queue.head, X
    rts
    @Positive:
        clc
        lda queue.head, X
        sbc queue.tail, X
        rts

; Sets the z flag if the Queue is full.
; A full queue is one where queue.head == queue.tail and queue.head > queue.start
Queue_Full:
.ends