.ACCU    8
.INDEX    16

.include "game/sprites.i"

.section "Game" bank 0 slot "ROM"

Game_Frame:
    rts

Game_Init:
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
    rts

.ends