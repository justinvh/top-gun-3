.include "engine/drivers/snes/interface.asm"
.include "engine/input.asm"
.include "engine/map.asm"

.section "Engine" BANK 0 SLOT "ROM"

.struct Engine
    frame_counter dw
    snes instanceof SNES
    input instanceof Input                  ; Pointer to the input struct
    oam_objects instanceof OAMObject 128    ; Represents OAM space
.endst

.enum $0000
    engine instanceof Engine
.ende

Engine_Init:
    pha
    phx
    phy

    stz engine.frame_counter, X
    call(SNES_Init, engine.snes)      ; Equivalent to this->snes.init()
    call(Input_Init, engine.input)    ; Equivalent to this->input.init()

    ; Fake OAM Object testing
    ldy #$00 ; OAM address for testing
    call(OAMObject_RandomInit, engine.oam_objects.1) ; Equivalent to this->oam_objects[0].init()
    call(OAMObject_Write, engine.oam_objects.1)      ; Equivalent to this->oam_objects[0].write()

    ply
    plx
    pla
    rts

Engine_Frame:
    pha
    phx
    phy

    call(Input_Frame, engine.input)   ; Equivalent to this->input.frame()

    ply
    plx
    pla
    rts

Engine_VBlank:
    pha
    phx
    phy

    call(Input_VBlank, engine.input)   ; Equivalent to this->input.vblank()

    ;lda #$10
    ;sta TM
    lda #%00000001
    sta TM

    ply
    plx
    pla
    rts

.ends