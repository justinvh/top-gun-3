/* SPC700 Assembly 
.define SoundKeyAddr    $F000

Pause:
    mov A,$00F7
    cmp A,!$F000
    bne Pause
    ret