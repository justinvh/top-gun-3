.define WEAPON_TYPE_MACHINE_GUN 0
.define SPEED_TYPE_NORMAL 1

.struct Plane
    base instanceof Entity
    weapon        db  ; Which weapon the character has
    speed         db  ; Which Speed
    turbo_multi   db  ; Speed multiplier
.endst
.enum $0000
    plane instanceof Plane
.ende

.section "PlaneROM" bank 0 slot "ROM"

nop

.dstruct PlaneBase instanceof Plane values
    base.id:            .db "PLAN"
    base.type:          .dw ENTITY_TYPE_PLANE
    base.health:        .db 100
    base.max_health:    .db 100
    base.w:             .db 64
    base.h:             .db 32
    weapon:             .db WEAPON_TYPE_MACHINE_GUN
    speed:              .db SPEED_TYPE_NORMAL
    turbo_multi:        .db 1
.endst

;
; Y is the plane pointer
;
Plane_Init:
    pha
    phx
    phy

    ; Polymorphism, bitches
    jsr Entity_Init

    ply
    plx
    pla
    rts

Plane_Frame:
    brk
    rts

.ends