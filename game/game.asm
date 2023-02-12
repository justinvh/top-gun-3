.ACCU	8
.INDEX	16

.include "game/sprites.i"

.section "Game" bank 0 slot "ROM"

.macro LoadSprite ARGS X, Y, NAME, FLIP, DEBUG_NAME
@LoadSprite{DEBUG_NAME}:
	; horizontal position of second sprite
	lda #(256/2 + X)
	sta OAMDATA

	; vertical position of second sprite
	lda #(224/2 + Y)
	sta OAMDATA

	; name of second sprite
	lda #(NAME)
	sta OAMDATA

	; no flip, prio 0, palette 0
	lda #(FLIP)
	sta OAMDATA
.endm

Game_Frame:
	rts

Game_Init:
	@VRAMInit:
		ldx #$00
		@VRAMLoop:
			lda SpriteData.w, X	; get bitplane 0/2 byte from the sprite data
			sta VMDATAL         ; write the byte in A to VRAM
			inx                 ; increment counter/offset
			lda SpriteData.w, X ; get bitplane 1/3 byte from the sprite data
			sta VMDATAH         ; write the byte in A to VRAM
			inx                 ; increment counter/offset
			cpx #$80            ; check whether we have written $04 * $20 = $80 bytes to VRAM (four sprites)
			bcc @VRAMLoop  		; if X is smaller than $80, continue the loop

	@CGRAMInit:
		ldx #$00
		lda #$80
		sta CGADD
		@CGRAMLoop:
			lda ColorData.w, X	; get the color low byte
			sta CGDATA          ; store it in CGRAM
			inx                 ; increase counter/offset
			lda ColorData.w, X  ; get the color high byte
			sta CGDATA          ; store it in CGRAM
			inx                 ; increase counter/offset
			cpx #$20            ; check whether 32/$20 bytes were transfered
			bcc @CGRAMLoop		; if not, continue loop

		LoadSprite(-8, -8, #$00, #$00, "Sprite1")
		LoadSprite( 0, -8, #$01, #$00, "Sprite2")
		LoadSprite(-8,  0, #$02, #$00, "Sprite3")
		LoadSprite( 0,  0, #$03, #$00, "Sprite4")

		lda #$10
		sta TM
	rts

.ends