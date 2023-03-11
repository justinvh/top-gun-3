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

Engine_InitTestOAM:
    ; Fake OAM Object testing
    ldy #$00 ; OAM address for testing
    call(OAMObject_RandomInit, engine.oam_objects.1) ; Equivalent to this->oam_objects[0].init()
    call(OAMObject_Write, engine.oam_objects.1)      ; Equivalent to this->oam_objects[0].write()

    ldy #$01 ; OAM address for testing
    call(OAMObject_RandomInit, engine.oam_objects.2) ; Equivalent to this->oam_objects[0].init()
    call(OAMObject_Write, engine.oam_objects.2)      ; Equivalent to this->oam_objects[0].write()

    ldy #$02 ; OAM address for testing
    call(OAMObject_RandomInit, engine.oam_objects.3) ; Equivalent to this->oam_objects[0].init()
    call(OAMObject_Write, engine.oam_objects.3)      ; Equivalent to this->oam_objects[0].write()

    ldy #$03 ; OAM address for testing
    call(OAMObject_RandomInit, engine.oam_objects.4) ; Equivalent to this->oam_objects[0].init()
    call(OAMObject_Write, engine.oam_objects.4)      ; Equivalent to this->oam_objects[0].write()

    ldy #$04 ; OAM address for testing
    call(OAMObject_RandomInit, engine.oam_objects.5) ; Equivalent to this->oam_objects[0].init()
    call(OAMObject_Write, engine.oam_objects.5)      ; Equivalent to this->oam_objects[0].write()

    ldy #$05 ; OAM address for testing
    call(OAMObject_RandomInit, engine.oam_objects.6) ; Equivalent to this->oam_objects[0].init()
    call(OAMObject_Write, engine.oam_objects.6)      ; Equivalent to this->oam_objects[0].write()

    ldy #$07 ; OAM address for testing
    call(OAMObject_RandomInit, engine.oam_objects.7) ; Equivalent to this->oam_objects[0].init()
    call(OAMObject_Write, engine.oam_objects.7)      ; Equivalent to this->oam_objects[0].write()
    rts

Engine_Init:
    phy

    stz engine.frame_counter, X
    call(SNES_Init, engine.snes)      ; Equivalent to this->snes.init()
    call(Input_Init, engine.input)    ; Equivalent to this->input.init()

    jsr Engine_InitTestOAM

    ply
    rts

Engine_Frame:
    call(Input_Frame, engine.input)   ; Equivalent to this->input.frame()
    rts

Engine_VBlankTestOAM:
    A8_XY16
    lda engine.oam_objects.1.x, X

    ina
    sta engine.oam_objects.1.x, X
    ina
    ina
    sta engine.oam_objects.2.x, X
    ina
    ina
    ina
    sta engine.oam_objects.3.x, X

    lda engine.oam_objects.1.y, X

    ina
    sta engine.oam_objects.1.y, X
    ina
    ina
    sta engine.oam_objects.2.y, X
    ina
    ina
    ina
    sta engine.oam_objects.3.y, X

    A16_XY16

    call(OAMObject_Write, engine.oam_objects.1)      ; Equivalent to this->oam_objects[0].write()
    call(OAMObject_Write, engine.oam_objects.2)      ; Equivalent to this->oam_objects[0].write()
    call(OAMObject_Write, engine.oam_objects.3)      ; Equivalent to this->oam_objects[0].write()
    call(OAMObject_Write, engine.oam_objects.4)      ; Equivalent to this->oam_objects[0].write()
    call(OAMObject_Write, engine.oam_objects.5)      ; Equivalent to this->oam_objects[0].write()
    call(OAMObject_Write, engine.oam_objects.6)      ; Equivalent to this->oam_objects[0].write()
    call(OAMObject_Write, engine.oam_objects.7)      ; Equivalent to this->oam_objects[0].write()

    rts

Engine_VBlank:
    pha

    call(Input_VBlank, engine.input)   ; Equivalent to this->input.vblank()
    jsr Engine_VBlankTestOAM

    ;        S4321
    lda #%00010001
    sta TM

    pla
    rts

.ends