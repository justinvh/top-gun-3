.include "engine/drivers/snes/interface.asm"

.section "Engine" BANK 0 SLOT "ROM"

.struct Engine
    frame_counter dw
.endst

.enum $0000
    engine instanceof Engine
.ende

Engine_Init:
    ldy #$789A
    sty engine.frame_counter, X

    jsr Snes_Init
    ; jsr SPC_Init

    rts

; testing. checks if x key is pressed and changes background color in change_bg
Engine_Frame:
    inc input.frame_counter, X
    rts

Engine_VBlank:
    lda #$10
    sta TM
    rts

.ends