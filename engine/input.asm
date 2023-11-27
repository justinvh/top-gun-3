.include "engine/drivers/input/interface.asm"
.include "engine/drivers/input/multitap.asm"
.include "engine/drivers/input/pad.asm"

.section "InputManagerROM" bank 0 slot "ROM" semifree
nop

InputManager_Init:
    jsr Multitap_Init
    jsr PadManager_Init 
    rts

InputManager_Frame:
    rts

InputManager_VBlank:
    jsr Multitap_VBlank 
    jsr PadManager_VBlank
    rts

InputManager_Request:
    jsr PadManager_Request
    rts

.ends
