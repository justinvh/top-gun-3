.include "engine/drivers/input/interface.asm"

Input_Init:
    jsr INPUT_Init
    rts

Input_Frame:
    rts