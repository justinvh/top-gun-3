.ACCU   16
.INDEX  16

.include "engine/font.asm"
.section "Fonts" bank 1 slot "ROM"

nop

; resources/fonts/8x8-font.bin -- A 2BPP 128x64 font with 8x8 characters
incfont(1, "8x8", 128, 128)

.ends