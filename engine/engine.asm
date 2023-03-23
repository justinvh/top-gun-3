.ACCU  16
.INDEX 16

.include "engine/drivers/snes/interface.asm"
.include "engine/bg.asm"
.include "engine/input.asm"
.include "engine/map.asm"
.include "engine/oam.asm"
.include "engine/timer.asm"

.struct Engine
    frame_counter dw
    test_object_ptr dw ; Pointer to the requested OAM object
.endst

.ramsection "EngineRAM" appendto "RAM"
    engine instanceof Engine
.ends

.section "Engine" BANK 0 SLOT "ROM"

Engine_Init:
    phy
    phx

    stz engine.frame_counter.w

    jsr SNES_Init
    jsr OAMManager_Init
    jsr BGManager_Init
    jsr TimerManager_Init
    jsr MapManager_Init
    jsr FontManager_Init

    ; Test functions
    jsr Engine_InitTestObject

    ;        S4321
    lda #%00010111
    sta TM

    plx
    ply
    rts

Engine_Frame:
    rts

Engine_VBlank:
    pha

    ; Increase the timer by 17ms for every vblank
    jsr TimerManager_Tick

    jsr Engine_MoveTestObject

    jsr OAMManager_VBlank

    jsr FontManager_VBlank

    pla
    rts

Engine_InitTestObject:
    pha
    phy

    jsr OAMManager_Request

    ; VRAM address 0 is a transparent tile. 1 is a grass tile in the test.
    A8
    lda #1
    sta oam_object.vram, Y
    A16

    ; Save the pointer for testing later
    tya
    sta engine.test_object_ptr.w

    ply
    pla
    rts

;
; Move the test object
;
Engine_MoveTestObject:
    pha
    phx

    ; Load pointer to OAM object
    lda engine.test_object_ptr.w
    tax

    A8_XY16

    ; Load OAM object and add 1 to x position and y position
    inc oam_object.x, X
    inc oam_object.y, X
    stz oam_object.clean, X

    A16_XY16

    plx
    pla
    rts

.ends