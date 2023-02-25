.include "engine/drivers/snes/interface.asm"

.section "Engine" BANK 0 SLOT "ROM"

.struct Engine
    frame_counter dw
.endst

.enum $0000
    engine instanceof Engine
.ende

Engine_Init:
    phx
    stz engine.frame_counter, X
    jsr Snes_Init
    plx
    rts

Engine_Frame:
    rts

Engine_VBlank:
    pha

    lda #$10
    sta TM

    pla
    rts

.ends