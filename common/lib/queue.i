.section "Queue" BANK 0 SLOT "ROM"

.ACCU	16
.INDEX	16

nop

.struct Queue
    start: dw
    head:  dw
    tail:  dw
    end:   dw
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
    pha

    ; Check if the queue is full
    lda queue.tail, X
    cmp queue.start, X
    beq @MaybeFull

    ; Queue isn't empty, so insert.
    @Push:
        pla
        ; Store and Increment the tail pointer
        sta (queue.tail, X)
        inc queue.tail, X 
        inc queue.tail, X

        ; Check if the queue has reached the end of the memory address
        cmp queue.end, X
        beq @Reset
        rts

        ; Reset the queue if it has reached the end of the memory address
        @Reset:
            pha
            lda queue.start, X
            sta queue.tail, X
            pla
            rts

    ; Check if the head and tail are at the start of the memory address
    @MaybeFull:
        lda queue.tail, X
        cmp queue.head, X
        bne @Push
        pla
        rts

; Pulls whatever is at the head into the accumulator
; Expects X to be the start of the memory address
Queue_Pop:
    pha

    ; Check if the queue is empty
    lda queue.head, X
    cmp queue.start, X
    beq @MaybeEmpty

    ; Queue isn't empty, so pop.
    @Pop:
        pla
        lda (queue.head, X)
        inc queue.head, X
        inc queue.head, X

        ; Check if the queue has reached the end of the memory address
        cmp queue.end, X
        beq @Reset
        rts

        ; Reset the queue if it has reached the end of the memory address
        @Reset:
            pha
            lda queue.start, X
            sta queue.head, X
            pla
            rts

    @MaybeEmpty:
        lda queue.head, X
        cmp queue.tail, X
        bne @Pop
        pla
        rts
    rts

.ends