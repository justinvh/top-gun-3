; Initially, no debug hooks are enabled
; You do not have to modify these except when adding more hooks
.define DEBUG_EntityManager 0

; If debug.asm doesn't define DEBUG_HOOKS as 1 then none of the debug hooks
; will be compiled below.
.ifeq DEBUG_HOOKS 1

.print "debug_entity.asm: Enabling debug hooks\n"

; Required hooks to debug the VRAM manager
.ifeq DEBUG_ENTITY_MANAGER 1
    .print "debug_entity.asm: Enabling entity manager debug hooks\n"
    .redefine DEBUG_EntityManager 1
.endif

.section "DebugEntityROM" bank 0 slot "ROM"

nop

.ifeq DEBUG_EntityManager 1

Main@EntityManagerTest:
    brk

    ; Attempt to spawn in a boss
    lda #ENTITY_TYPE_PLANE
    jsr EntityManager_Spawn

    ; Enable it and force the entity manager to run a frame
    lda #1
    sta entity.enabled, Y
    jsr EntityManager_Frame

    /*
    ; Release it back
    jsr EntityManager_Release

    ; Verify that it's gone
    A8

    lda entity.enabled, Y
    cmp #0
    bne @Failed

    lda entity.allocated, Y
    cmp #0
    bne @Failed

    lda entity.dirty, Y
    cmp #0
    bne @Failed

    bra @Done

    @Failed:
        brk
    */

    @Done:
        A16
        rts

.endif

.ends

.endif ; DEBUG_HOOKS