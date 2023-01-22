.include "engine/config/rom.asm"

.bank 1
.section "SPC700Driver"

/* SPC700 Assembly */
.define SoundKeyAddr    $F000

Pause:
    mov A,$00F7
    cmp A,!$F000
    bne Pause
    ret

.ends