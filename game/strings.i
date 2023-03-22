.macro definetext args _bank, _short, _text
    .asciitable
        map " " to "~" = 1
    .enda
    .define Text_{_short}@Bank _bank
    Text_{_short}@Data: .ascstr _text, $0
    .asciitable
        map " " to "~" = 32
    .enda
.endm

.section "Strings" bank 1 slot "ROM"

definetext(1, "TopGun3", "Top Gun 3")

.ends