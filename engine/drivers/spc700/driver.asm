.section "SPC700ROM" bank 10 slot "ROM"
nop
.define SPC700Driver@Bank 10
SPC700Driver@Data:	.incbin "engine/drivers/spc700/spc700.bin" skip 0 read 21904
.ends
