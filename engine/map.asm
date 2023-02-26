.ACCU	16
.INDEX	16

.section "Map" bank 0 slot "ROM"

nop

.struct Tile
    id          db ; ID of the tile
    x           dw ; X position of the tile
    y           dw ; Y position of the tile
.endst

;
; Expects a packed tileset in the following format:
;
.struct SpriteSheet
    magic       db 3  ; "4BPP"
    bpp         db ; Bits per pixel
    width       db ; Width in pixels per tile
    height      db ; Height in pixels per tile
    num_rows    db ; Number of rows in the tileset
    num_cols    db ; Number of columns in the tileset
    data        db ; Where the tile data starts
.endst

;
; Palette data is stored in the following format:
;
.struct Palette
    magic       db 3  ; "PAL"
    num_colors  db ; Number of colors in the palette
    data        db ; Where the palette data starts
.endst

;
; Map data is stored in the following format:
;
.struct Map
    magic          db 3  ; "TMX"
    version        db    ; Version of the map format
    name           db 16 ; Name of the map
    num_tiles      dw    ; Number of tiles in the map
    num_objects    dw    ; Number of objects in the map
    tile_width     db ; Width of a tile in pixels
    tile_height    db ; Height of a tile in pixels
    height         db ; Height in tiles of tile_height
    width          db ; Width in tiles of tile_width
    ; These are all relative to the start of the map struct
    tile_offset    dw ; Where all the tile data starts
    sprite_offset  dw ; Where all the map data starts
    palette_offset dw ; Where all the palette data starts
    object_offset  dw ; Where all the objects in the map go
.endst

; Intentionally offset at $0000 since we will use the X register to
; point to the map struct when allocated
.enum $0000
    map instanceof Map
.ende

.enum $0000
    palette instanceof Palette
.ende

.enum $0000
    tileset instanceof Tileset
.ende

;
; Load map data at the X register offset
;
Map_Load:
    rts

Palette_Load:
    rts

Tileset_Load:
    rts

.ends