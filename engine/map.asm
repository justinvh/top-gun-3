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
    magic       ds 3  ; "SPR"
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
    magic       ds 3  ; "PAL"
    num_colors  db ; Number of colors in the palette
    data        db ; Where the palette data starts
.endst

;
; Map data is stored in the following format:
;
.struct Map
    magic          ds 3  ; "TMX"
    version        db    ; Version of the map format
    name           ds 16 ; Name of the map
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
    sprite_sheet instanceof SpriteSheet
.ende
.enum $0000
    palette instanceof Palette
.ende

;
; Load map data at the X register offset
;
Map_Init:
    phx
    A8_XY16

    @CheckMapMagicNumber:
        txy
        lda map.magic, Y
        cmp #ASC('T')
        bcc @Error_BadMagic
        iny

        lda map.magic, Y
        cmp #ASC('M')
        bcc @Error_BadMagic
        iny

        lda map.magic, Y
        cmp #ASC('X')
        bcc @Error_BadMagic
        iny

    @CheckSpriteMagicNumber:
        A16_XY16
        clc
        lda map.sprite_offset, X
        adc 1, S
        tay
        A8_XY16

        lda sprite_sheet.magic, Y
        cmp #ASC('S')
        bcc @Error_BadMagic
        iny

        lda sprite_sheet.magic, Y
        cmp #ASC('P')
        bcc @Error_BadMagic
        iny

        lda sprite_sheet.magic, Y
        cmp #ASC('R')
        bcc @Error_BadMagic
        iny

    @CheckPaletteMagicNumber:
        A16_XY16
        clc
        lda map.palette_offset, X
        adc 1, S
        tay
        A8_XY16

        lda palette.magic, Y
        cmp #ASC('P')
        bcc @Error_BadMagic
        iny

        lda palette.magic, Y
        cmp #ASC('A')
        bcc @Error_BadMagic
        iny

        lda palette.magic, Y
        cmp #ASC('L')
        bcc @Error_BadMagic
        iny

    @MagicSuccess:
        jsr Map_Load

    @Error_BadMagic:
        nop

    A16_XY16
    plx
    rts

;
; This routine is called after the magic number has been checked
; Arguments:
;  X = Pointer to the map struct
;
; It will load:
; (1) The tile data from the map into vram
; (2) The palette data into cgram
;
Map_Load:
    rts

.ends