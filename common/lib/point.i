.section "Point" BANK 0 SLOT "ROM"

.struct Point2d
    x   dw ; x coordinate
    y   dw ; y coordinate
.endst

.enum $0000
    point2d instanceof Point2d
.ende

.ends