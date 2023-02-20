.ACCU     16
.INDEX    16

.include "game/sprites.i"
.include "engine/engine.asm"
.include "engine/input.asm"

.section "Game" bank 0 slot "ROM"

nop

.struct Game
    engine instanceof Engine
    input instanceof Input
    frame_counter dw
.endst

.enum $0000
    game instanceof Game
.ende

Game_Frame:
    A16_XY16
    phx

    inc game.frame_counter, X

    ; Create engine pointer and call frame
    txa
    adc #(game.engine)
    tax
    jsr Engine_Frame

    plx
    phx

    txa
    adc #(game.input)
    tax
    jsr Input_Frame

    plx

    rts

Game_Init:
    A16_XY16

    ; Save X pointer for other objects
    phx

    ; Set frame counter to 0
    ldy #$0000
    sty game.frame_counter, X

    ; Create engine pointer and call its init
    ; expects X to be the this pointer
    txa
    adc #(game.engine)
    tax
    jsr Engine_Init

    ; Restore X pointer
    plx
    phx

    ; Create input pointer
    ; expects X to be the this pointer
    txa
    adc #(game.input)
    tax
    jsr Input_Init

    ; No longer need X pointer
    plx

    A8_XY16

    @VRAMInit:
        ldx #$00
        @VRAMLoop:
            ; Bitplane 0/2
            lda SpriteData.w, X
            sta VMDATAL
            inx
            ; Bitplane 1/3
            lda SpriteData.w, X
            sta VMDATAH
            inx
            ; Keep loading data
            cpx #$80
            bcc @VRAMLoop

    @CGRAMInit:
        ldx #$00
        lda #$80
        sta CGADD
        @CGRAMLoop:
            ; Low byte color data
            lda ColorData.w, X
            sta CGDATA
            inx
            ; High byte color data
            lda ColorData.w, X
            sta CGDATA
            inx
            ; Keep loading data
            cpx #$20
            bcc @CGRAMLoop

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

; Expects X to be this pointer
Game_VBlank:
    ; Save this pointer
    phx

    ; Create input pointer and call frame
    txa
    adc #(game.input)
    tax
    jsr Input_VBlank

    ; Restore this pointer
    plx
    phx 

    ; Create engine pointer and call render
    txa
    adc #(game.engine)
    tax
    jsr Engine_VBlank

    ; Toss this pointer
    plx

    rts

.ends