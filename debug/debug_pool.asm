; Initially, no debug hooks are enabled
; You do not have to modify these except when adding more hooks
.define DEBUG_PoolTest 0

; If debug.asm doesn't define DEBUG_HOOKS as 1 then none of the debug hooks
; will be compiled below.
.ifeq DEBUG_HOOKS 1

.print "debug_pool.asm: Enabling debug hooks\n"

; Required hooks to debug the Pool manager
.ifeq DEBUG_POOL_ALLOCATOR 1
    .print "debug_pool.asm: Enabling vram manager debug hooks\n"
    .redefine DEBUG_PoolTest 1
.endif

.struct DebugPool
    empty db

    .ifeq DEBUG_PoolTest 1
    pool instanceof Pool
    .endif
.endst

.ramsection "DebugPoolRAM" appendto "RAM"
    dbg_pool instanceof DebugPool
.ends

.section "DebugPoolROM" bank 0 slot "ROM"

nop

.ifeq DEBUG_PoolTest 1
Main@PoolTest:
    pha
    phx

    brk

    ldx #dbg_pool.pool
    pea $0000
    pea $8000
    jsr Pool_AllocateBlock
    pla
    pla

    ; Intentionally mark the block free, so that we can
    ; attempt to split it below
    ldx #dbg_pool.pool.chunks.1
    lda #1
    sta pool_chunk.free, X

    ; Attempt to allocate an entire block
    @AllocateBlock:
        ldx #dbg_pool.pool

        pea $2000
        pea $27FF
        jsr Pool_AllocateBlock
        pla
        pla

        cpy #0
        beq @FailedAllocateBlock

        ; Confirm the pool was correctly allocated
        ldx #dbg_pool.pool.chunks.1

        lda pool_chunk.free, X
        cmp #$0
        bne @FailedAllocateBlock

        lda pool_chunk.allocated, X
        cmp #$1
        bne @FailedAllocateBlock

        lda pool_chunk.start, X
        cmp #$2000
        bne @FailedAllocateBlock

        lda pool_chunk.end, X
        cmp #$27FF
        bne @FailedAllocateBlock

        ; Look at the "prev" block and confirm it was correctly allocated
        ldx #dbg_pool.pool.chunks.2

        lda pool_chunk.start, X
        cmp #$0
        bne @FailedAllocateBlock

        lda pool_chunk.end, X
        cmp #$1FFF

        lda pool_chunk.free, X
        cmp #$1
        bne @FailedAllocateBlock

        lda pool_chunk.allocated, X
        cmp #$1
        bne @FailedAllocateBlock

        ; Look at the "next" block and confirm it was correctly allocated
        ldx #dbg_pool.pool.chunks.3

        lda pool_chunk.start, X
        cmp #$2800
        bne @FailedAllocateBlock

        lda pool_chunk.end, X
        cmp #$8000

        lda pool_chunk.free, X
        cmp #$1
        bne @FailedAllocateBlock

        lda pool_chunk.allocated, X
        cmp #$1
        bne @FailedAllocateBlock

        bra @AllocateWithinBlock1

    @FailedAllocateBlock:
        brk
        jmp @FailedTests

    ; Attempt to allocate within a block
    @AllocateWithinBlock1:
        ldx #dbg_pool.pool
        pea $100
        pea $2800
        pea $4000
        jsr Pool_AllocateWithinBlock
        pla
        pla
        pla

        tyx

        lda pool_chunk.free, X
        cmp #$0
        bne @FailedAllocateWithinBlock1

        lda pool_chunk.allocated, X
        cmp #$1
        bne @FailedAllocateWithinBlock1

        lda pool_chunk.start, X
        cmp #$2800
        bne @FailedAllocateWithinBlock1

        lda pool_chunk.end, X
        cmp #$28FF
        bne @FailedAllocateWithinBlock1

    bra @AllocateWithinBlock2

    @FailedAllocateWithinBlock1:
        brk
        jmp @FailedTests

    ; Attempt to allocate within a block
    @AllocateWithinBlock2:
        ldx #dbg_pool.pool
        pea $100
        pea $2800
        pea $4000
        jsr Pool_AllocateWithinBlock
        pla
        pla
        pla

        tyx

        lda pool_chunk.free, X
        cmp #$0
        bne @FailedAllocateWithinBlock2

        lda pool_chunk.allocated, X
        cmp #$1
        bne @FailedAllocateWithinBlock2

        lda pool_chunk.start, X
        cmp #$2900
        bne @FailedAllocateWithinBlock2

        lda pool_chunk.end, X
        cmp #$29FF
        bne @FailedAllocateWithinBlock2

    bra @FreePool

    @FailedAllocateWithinBlock2:
        brk
        jmp @FailedTests    

    @FreePool:
        ldx #dbg_pool.pool
        pea $2000 ; Start
        pea $8000 ; End
        jsr Pool_Free
        pla
        pla

        ldx dbg_pool.pool.head.w

        lda pool_chunk.free, X
        cmp #1
        bne @FailedFreePool

        lda pool_chunk.allocated, X
        cmp #1
        bne @FailedFreePool

        lda pool_chunk.start, X
        cmp #$0
        bne @FailedFreePool

        lda pool_chunk.end, X
        cmp #$1FFF
        bne @FailedFreePool

        lda pool_chunk.next, X
        cmp #$0
        bne @FailedFreePool

    bra @FreeAllPool
    @FailedFreePool:
        brk
        jmp @FailedTests

    @FreeAllPool:
        brk
        ldx #dbg_pool.pool
        pea $0 ; Start
        pea $8000 ; End
        jsr Pool_Free
        pla
        pla

        lda dbg_pool.pool.head.w
        cmp #$0
        bne @FailedFreeAllPool

    bra @Done
    @FailedFreeAllPool:
        brk
        jmp @FailedTests

    @FailedTests:
        brk
    
    @Done:
        plx
        pla
        rts
.endif ; DEBUG_POOL_ALLOCATOR

.ends

.endif ; DEBUG_HOOKS