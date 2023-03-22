.include "game/sprites.i"
.include "game/maps.i"
.include "game/fonts.i"
.include "game/strings.i"
.include "engine/engine.asm"

.ACCU	16
.INDEX	16

.section "Game" bank 0 slot "ROM"

nop ; This is here to prevent the compiler from optimizing the label away

.struct Game
    frame_counter dw            ; Frame counter (increments every frame)
    engine instanceof Engine    ; Pointer to the engine struct
    test_timer_ptr dw           ; Pointer to the requested test timer
    test_ui_ptr dw              ; Pointer to the requested test UI component
.endst

; Intentionally offset at $0000 since we will use the X register to
; point to the game struct when allocated
.enum $0000
    game instanceof Game        ; Pointer to the game struct
.ende

;
; Main game loop
; Arguments:
; - X: Pointer to Game struct
;
Game_Frame:
    pha
    phx

    inc game.frame_counter, X       ; Increment frame counter
    call(Engine_Frame, game.engine) ; Equivalent to this->engine.frame()

    ; Check if triggered and reset if so
    call_ptr(Timer_Triggered, game.test_timer_ptr)
    cpy #1
    beq @TimerTriggered
    bra @TimerNotTriggered

    @TimerTriggered:
        nop
        ;brk

    @TimerNotTriggered:
        nop

    plx
    pla
    rts

;
; Initialize the game
; Arguments:
; - X: Pointer to Game struct
;
Game_Init:
    pha                             ; Save A register
    phy                             ; Save Y register
    phx                             ; Save X register (this pointer)

    stz game.frame_counter, X       ; Zero frame counter
    call(Engine_Init, game.engine)  ; Equivalent to this->engine.init()

    ; Load a demo map
    lda #Map_Demo_Bank
    ldy #Map_Demo
    call(MapManager_Load, game.engine.map_manager)

    ; Initialize all font data
    jsr Game_FontInit

    plx
    ply
    pla
    rts

;
; Initialize all font data
;
Game_FontInit:
    pha
    phx
    phy

    ; Setup pointer for font manager
    txa
    adc #game.engine.font_manager
    tax

    ; Load Font 8x8 into Slot 0
    lda #Font_8x8@Header.w   ; Argument 1 (pointer to font data)
    jsr FontManager_Load
    txa
    adc #font_manager.font_vram_info.1
    sta font_manager.font_draw_info.font_vram_info_ptr, X

    ; Provide pointer
    lda #Text_TopGun3
    sta font_manager.font_draw_info.data_ptr, X

    ; Test drawing
    jsr FontManager_Draw

    ply
    plx
    pla

    rts

;
; VBlank handler
; Arguments:
; - X: Pointer to Game struct
;
Game_VBlank:
    call(Engine_VBlank, game.engine) ; Equivalent to this->engine.vblank()
    rts

.ends