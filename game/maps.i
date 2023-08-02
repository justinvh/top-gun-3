.macro incmap ARGS _bank, _name
.define Map_{_name}@Bank _bank
Map_{_name}@Data: .incbin resources/maps/{_name}.bin
.endm

.section "SkyscraperMap" bank 2 slot "ROM"
incmap(2, "Skyscraper")
.ends

.section "SynthscraperMap" bank 5 slot "ROM"
incmap(5, "Synthscraper")
.ends