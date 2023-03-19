.include "game/sprites.i"
.include "game/maps.i"
.include "game/fonts.i"
.include "engine/engine.asm"

.ACCU	16
.INDEX	16

.section "Game" bank 0 slot "ROM"

nop ; This is here to prevent the compiler from optimizing the label away

.struct Game
    frame_counter dw            ; Frame counter (increments every frame)
    map dw                      ; Pointer to the map struct (current map)
    engine instanceof Engine    ; Pointer to the engine struct
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

    ; Map expects to have an Engine pointer in Y, so we need to set it
    txa
    clc
    adc #game.engine
    tay

    ; Initialize the initial map
    lda 1, S                        ; Get the this pointer from the stack
    tax                             ; Store it in X for indirect addressing
    lda #(Map_Demo)                 ; Load the address of the demo map
    sta game.map, X                 ; Set the current map
    call_ptr(Map_Init, game.map)    ; Load the map (call through pointer)

    ; Initialize font data
    phx
    ldx Font_8x8@Header.w
    jsr Font_Load
    plx

    plx
    ply
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