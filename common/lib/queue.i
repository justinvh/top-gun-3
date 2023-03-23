.section "Queue" BANK 0 SLOT "ROM"

.ACCU	16
.INDEX	16

nop

.define QUEUE_ERROR_NONE 0
.define QUEUE_ERROR_FULL 1
.define QUEUE_ERROR_EMPTY 2

.struct Queue
    start_addr:     dw ; Start address of the queue
    end_addr:       dw ; End address of the queue
    element_size:   dw ; Number of bytes of each object in the buffer
    error           dw ; Error state

    ; Private members
    m_is_full:        dw ; Flag to indicate if the queue is at capacity
    m_is_empty:       dw ; Flag to indicate if the queue is empty
    m_head_ptr:       dw ; Head pointer
    m_tail_ptr:       dw ; Tail pointer
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

    lda #1
    sta queue.m_is_empty, X
    stz queue.error, X
    stz queue.m_is_full, X

    lda queue.start_addr, X  ; Get the base address
    sta queue.m_head_ptr, X  ; Set the head pointer
    sta queue.m_tail_ptr, X  ; Set the tail pointer

    ply
    plx
    pla
    rts

;
; Expects X to be the Queue instance
; Updates Y to be the address of the caller to use.
;
Queue_Pop:
    pha
    phx

    ; if (queue.m_is_empty)
    ;   Set the error state to empty and exit
    @CheckCapacity:
        lda queue.m_is_empty, X  ; Check if the queue is empty
        cmp #1                   ; Compare the accumulator to 1 (is full)
        bne @HasCapacity         ; If the queue is not full, then we have capacity
        lda #QUEUE_ERROR_EMPTY   ; Set the error state
        stz queue.m_is_full, X   ; Clear the full flag
        sta queue.error, X       ; Set the error state
        plx
        pla
        rts
    ; else
    @HasCapacity:
        stz queue.m_is_full, X   ; Clear the full flag
        stz queue.error, X       ; Clear the error state

    ; Set the return value to the tail pointer
    lda queue.m_head_ptr, X
    tay
    
    ; queue.m_head_ptr += queue.element_size
    ; queue.m_head_idx += 1
    @AdvanceHead:
        clc
        adc queue.element_size, X   ; Add the element size to the tail pointer
        sta queue.m_head_ptr, X     ; Store the new head pointer

    ; if (head_ptr >= end_addr)
    ;   head_idx = 0
    ;   head_ptr = start_addr
    @CheckHeadOverflow:
        cmp queue.end_addr, X       ; Compare the head index to the number of elements
        bne @CheckHeadCatchesTail   ; Condition not met, exit
        lda queue.start_addr, X     ; Get the start address
        sta queue.m_head_ptr, X     ; Set the head pointer

    ; if (head_ptr == tail_ptr)
    ;  queue.m_is_empty = 1
    @CheckHeadCatchesTail:
        cmp queue.m_tail_ptr, X
        bne @Done
        lda #1
        sta queue.m_is_empty, X

    @Done:
        plx
        pla
        rts

;
; Expects X to be the Queue instance
; Updates the Y register to be the address of the caller to use.
;
Queue_Push:
    pha
    phx

    ; if (queue.m_is_full)
    ;   Set the error state to full and exit
    @CheckCapacity:
        lda queue.m_is_full, X   ; Check if the queue is full
        cmp #1                   ; Compare the accumulator to 1 (is full)
        bne @HasCapacity         ; If the queue is not full, then we have capacity
        stz queue.m_is_empty, X  ; Clear the empty flag
        lda #QUEUE_ERROR_FULL    ; Set the error state
        sta queue.error, X       ; Set the error state
        plx
        pla
        rts
    ; else
    @HasCapacity:
        stz queue.m_is_empty, X ; Clear the empty flag
        stz queue.error, X      ; Clear the error state

    ; Set the return value to the tail pointer
    lda queue.m_tail_ptr, X
    tay
    
    ; queue.m_tail_ptr += queue.element_size
    ; queue.m_tail_idx += 1
    @AdvanceTail:
        clc
        adc queue.element_size, X   ; Add the element size to the tail pointer
        sta queue.m_tail_ptr, X     ; Store the new tail pointer

    ; if (tail_index >= num_elements)
    ;   tail_index = 0
    ;   tail_ptr = base_addr
    @CheckTailOverflow:
        cmp queue.end_addr, X       ; Compare the tail index to the number of elements
        bne @CheckTailCatchesHead   ; Condition not met, exit
        lda queue.start_addr, X     ; Get the base address
        sta queue.m_tail_ptr, X     ; Set the tail pointer

    ; if (head_ptr == tail_ptr)
    ;  queue.m_is_full = 1
    @CheckTailCatchesHead:
        lda queue.m_head_ptr, X
        cmp queue.m_tail_ptr, X
        bne @Done
        lda #1
        sta queue.m_is_full, X

    @Done:
        plx
        pla
        rts

.ends