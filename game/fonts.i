.ACCU   16
.INDEX  16

.include "engine/font.asm"
.section "Fonts" bank 0 slot "ROM"

; resources/fonts/8x8-font.bin -- A 2BPP 128x64 font with 8x8 characters
incfont("8x8", 128, 64)

.ends