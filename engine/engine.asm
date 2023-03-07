.include "engine/drivers/snes/interface.asm"
.include "engine/input.asm"
.include "engine/map.asm"

.section "Engine" BANK 0 SLOT "ROM"

.struct Engine
    frame_counter dw
    input instanceof Input      ; Pointer to the input struct
.endst

.enum $0000
    engine instanceof Engine
.ende

Engine_Init:
    phx
    stz engine.frame_counter, X
    jsr Snes_Init
    call(Input_Init, engine.input)    ; Equivalent to this->input.init()
    plx
    rts

Engine_Frame:
    call(Input_Frame, engine.input)   ; Equivalent to this->input.frame()
    rts

Engine_VBlank:
    pha

    call(Input_VBlank, engine.input)   ; Equivalent to this->input.vblank()

    ;lda #$10
    ;sta TM
    lda #%00000001
    sta TM

    pla
    rts

.ends