.include "engine/drivers/snes/interface.asm"

.section "Engine" BANK 0 SLOT "ROM"

Engine_Init:
     jsr Snes_Init
    ; jsr SPC_Init
    rts

; testing. checks if x key is pressed and changes background color in change_bg
Engine_Frame:
    rts

Engine_Render:
    lda #$10
    sta TM
    rts

.ends