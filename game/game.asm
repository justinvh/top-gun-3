.include "game/sprites.i"
.include "engine/engine.asm"
.include "engine/input.asm"

.section "Game" bank 0 slot "ROM"

nop ; This is here to prevent the compiler from optimizing the label away

.struct Game
    engine instanceof Engine    ; Pointer to the engine struct
    input instanceof Input      ; Pointer to the input struct
    frame_counter dw            ; Frame counter (increments every frame)
.endst

; Intentionally offset at $0000 since we will use the X register to
; point to the game struct when allocated
.enum $0000
    game instanceof Game        ; Pointer to the game struct
.ende

/**
 * Main game loop
 * Arguments:
 * - X: Pointer to Game struct
 */
Game_Frame:
    A16_XY16
    phx                             ; Save X register (this pointer)
    inc game.frame_counter, X       ; Increment frame counter
    call(Engine_Frame, game.engine) ; Equivalent to this->engine.frame()
    call(Input_Frame, game.input)   ; Equivalent to this->input.frame()
    plx                             ; Restore X register (this pointer)
    rts

/**
 * Initialize the game
 * Arguments:
 * - X: Pointer to Game struct
 */
Game_Init:
    A16_XY16
    phx                             ; Save X register (this pointer)
    stz game.frame_counter, X       ; Zero frame counter
    call(Engine_Init, game.engine)  ; Equivalent to this->engine.init()
    call(Input_Init, game.input)    ; Equivalent to this->input.init()
    plx                             ; Restore X register (this pointer)

    A8_XY16

    ; Initialize the VRAM with 128 bytes of sprite data
    @VRAMInit:
        ldx #$00                    ; Loop counter
        @VRAMLoop:                  ; Loop through all X bytes of sprite data
            lda SpriteData.w, X     ; Load bitplane 0/2
            sta VMDATAL             ; Store data to VRAM
            inx                     ; Increment loop counter
            lda SpriteData.w, X     ; Load bitplane 1/3
            sta VMDATAH             ; Store data to VRAM
            inx                     ; Increment loop counter
            cpx #$80                ; Check if we're done
            bcc @VRAMLoop           ; Loop if not

    @CGRAMInit:
        ldx #$00                    ; Loop counter
        lda #$80                    ; Offset pointerfor CGRAM
        sta CGADD                   ; Set CGADD to 0x80
        @CGRAMLoop:                 ; Loop through all X bytes of color data
            lda ColorData.w, X      ; Low byte color data
            sta CGDATA              ; Store data to CGRAM
            inx                     ; Increment loop counter
            lda ColorData.w, X      ; High byte color data
            sta CGDATA              ; Store data to CGRAM
            inx                     ; Increment loop counter
            cpx #$20                ; Check if we're done
            bcc @CGRAMLoop          ; Loop if not

        ; Setup the OAM data for our four sprites
        LoadSprite(-8, -8, #$00, #$00, "Sprite1")
        LoadSprite( 0, -8, #$01, #$00, "Sprite2")
        LoadSprite(-8,  0, #$02, #$00, "Sprite3")
        LoadSprite( 0,  0, #$03, #$00, "Sprite4")

        ; Set main screen designation (---sdcba)
        ; s: sprites, bg4 bg3 bg2 bg1
        lda #$10
        sta TM

    A16_XY16
    rts

/**
 * VBlank handler
 * Arguments:
 * - X: Pointer to Game struct
 */
Game_VBlank:
    phx                              ; Save X register (this pointer)
    call(Input_VBlank, game.input)   ; Equivalent to this->input.vblank()
    call(Engine_VBlank, game.engine) ; Equivalent to this->engine.vblank()
    plx                              ; Restore X register (this pointer)
    rts

.ends