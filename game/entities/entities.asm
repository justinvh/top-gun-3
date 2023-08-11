.include "game/entities/entity.asm"
.include "game/entities/plane.asm"
.include "game/entities/roboss.asm"

.section "EntityTable" bank 0 slot "ROM"

nop

.define ENTITY_TYPE_NONE                2 * 0
.define ENTITY_TYPE_PLANE               2 * 1
.define ENTITY_TYPE_BOSS                2 * 2

EntitySpriteBank:
    .dw 0                   ; ENTITY_TYPE_NONE
    .dw Sprite_Plane@Bank   ; ENTITY_TYPE_PLANE
    .dw 0                   ; ENTITY_TYPE_BOSS

EntitySpriteData:
    .dw 0                   ; ENTITY_TYPE_NONE
    .dw Sprite_Plane@Data   ; ENTITY_TYPE_PLANE
    .dw 0                   ; ENTITY_TYPE_BOSS

EntityInitObject:
    .dw EntityBase    ; ENTITY_TYPE_NONE
    .dw PlaneBase     ; ENTITY_TYPE_PLANE
    .dw RobossBase    ; ENTITY_TYPE_BOSS

EntityVTable@Init:
    .dw Entity_Init ; ENTITY_TYPE_NONE
    .dw Plane_Init  ; ENTITY_TYPE_PLANE
    .dw Entity_Init ; ENTITY_TYPE_BOSS

EntityVTable@Frame:
    .dw Entity_Frame    ; ENTITY_TYPE_NONE
    .dw Plane_Frame     ; ENTITY_TYPE_PLANE
    .dw Roboss_Frame    ; ENTITY_TYPE_BOSS

EntityVTable@MarkDirty:
    .dw Entity_MarkDirty ; ENTITY_TYPE_NONE
    .dw Entity_MarkDirty ; ENTITY_TYPE_PLANE
    .dw Entity_MarkDirty ; ENTITY_TYPE_BOSS

EntityVTable@VBlank
    .dw Entity_VBlank   ; ENTITY_TYPE_NONE
    .dw Entity_VBlank   ; ENTITY_TYPE_PLANE
    .dw Entity_VBlank   ; ENTITY_TYPE_BOSS

EntityVTable@AABB:
    .dw Entity_AABB   ; ENTITY_TYPE_NONE
    .dw Entity_AABB   ; ENTITY_TYPE_BOSS
    .dw Entity_AABB   ; ENTITY_TYPE_PLANE

EntityVTable@GiveDamage:
    .dw Entity_GiveDamage   ; ENTITY_TYPE_NONE
    .dw Entity_GiveDamage   ; ENTITY_TYPE_BOSS
    .dw Entity_GiveDamage   ; ENTITY_TYPE_PLANE

EntityVTable@TakeDamage:
    .dw Entity_TakeDamage   ; ENTITY_TYPE_NONE
    .dw Entity_TakeDamage   ; ENTITY_TYPE_BOSS
    .dw Entity_TakeDamage   ; ENTITY_TYPE_PLANE

.ends