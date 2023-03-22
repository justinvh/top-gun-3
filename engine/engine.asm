.include "engine/drivers/snes/interface.asm"
.include "engine/input.asm"
.include "engine/map.asm"
.include "engine/oam_manager.asm"
.include "engine/timer.asm"

.section "Engine" BANK 0 SLOT "ROM"

.struct Engine
    frame_counter dw
    snes            instanceof SNES
    input           instanceof Input
    oam_manager     instanceof OAMManager
    bg_manager      instanceof BGManager
    font_manager    instanceof FontManager
    timer_manager   instanceof TimerManager
    map_manager     instanceof MapManager
    test_object_ptr dw ; Pointer to the requested OAM object
.endst

.enum $0000
    engine instanceof Engine
.ende

Engine_Init:
    phy

    stz engine.frame_counter, X
    call(SNES_Init, engine.snes)
    call(OAMManager_Init, engine.oam_manager)
    call(BGManager_Init, engine.bg_manager)
    call(Input_Init, engine.input)

    ; Prepare Font and Map Manager and initialize it
    txa
    adc #engine.bg_manager

    ; Background managers for both map and font
    sta engine.map_manager.bg_manager_ptr, X
    sta engine.font_manager.bg_manager_ptr, X

    call(MapManager_Init, engine.map_manager)

    ; Request a timer for the font manager to use
    call(TimerManager_Request, game.engine.timer_manager)
    tya
    sta engine.font_manager.timer_ptr, X

    call(FontManager_Init, engine.font_manager)

    ; Test functions
    jsr Engine_InitTestObject

    ;        S4321
    lda #%00010111
    sta TM

    ply
    rts

Engine_Frame:
    call(Input_Frame, engine.input)
    rts

Engine_VBlank:
    pha

    ; Increase the timer by 17ms for every vblank
    call(TimerManager_Tick, engine.timer_manager)

    jsr Engine_MoveTestObject
    call(Input_VBlank, engine.input)
    call(OAMManager_VBlank, engine.oam_manager)
    call(FontManager_VBlank, engine.font_manager)

    pla
    rts

Engine_InitTestObject:
    pha
    phy

    call(OAMManager_Request, engine.oam_manager) ; Request 1 OAM object

    ; VRAM address 0 is a transparent tile. 1 is a grass tile in the test.
    A8
    lda #1
    sta oam_object.vram, Y
    A16

    ; Save the pointer for testing later
    tya
    sta engine.test_object_ptr, X

    ply
    pla
    rts

Engine_MoveTestObject:
    pha
    phx

    ; Load pointer to OAM object
    lda engine.test_object_ptr, X
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