;
; HEY! This is part of Bank 1, so it is next to the map data
;
.ACCU   16
.INDEX  16
.16bit

.section "Map" bank 1 slot "ROM"

nop

.struct Tile
    id          db ; ID of the tile
    version     db ;
    index       dw ; 8x8 32-width index
.endst

;
; Expects a packed tileset in the following format:
;
.struct SpriteSheet
    magic       ds 3  ; "SPR"
    bpp         db ; Bits per pixel
    size        dw ; Total number of bytes in this sheet
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
    size        dw ; Total number of bytes in this palette
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
.enum $0000
    tile instanceof Tile
.ende

;
; Load map data at the X register offset
; Expects that X register points to the map struct
; Expects this subroutine to be called as long jump
;
Map_Init:
    .16bit

    phd
    phb
    phy
    phx
    A8

    ; HACK: This is a hack to get the right X and Y register values
    ; Manipulate the data bank register to point to 1 (since this is bank 1)
    DB1

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
        A16
        clc
        lda map.sprite_offset, X
        adc 1, S
        tay
        A8

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
        A16
        clc
        lda map.palette_offset, X
        adc 1, S
        tay
        A8

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
        A16
        lda 3, S
        tay
        jsr Map_Load

    @Error_BadMagic:
        nop

    A16
    plx
    ply
    plb
    pld
    rtl

;
; This routine is called after the magic number has been checked
; Arguments:
;  X = Pointer to the map struct
;  Y = Pointer to the engine object
;
; It will load:
; (1) The tile data from the map into vram
; (2) The palette data into cgram
;
Map_Load:
    A16
    phy
    phx

    ; Prepare the X register to point to the sprite data
    clc
    lda map.sprite_offset, X
    adc 1, S
    tax
    jsr Map_LoadSprites

    ; Bounce the stack X register for getting objects again
    lda 1, S
    tax

    ; Prepare the X register to point to the palette data
    ; Keep the Y register as the engine pointer
    clc
    lda map.palette_offset, X
    adc 1, S
    tax
    jsr Map_LoadPalettes

    ; Bounce the stack X register for getting objects again
    lda 1, S
    tax

    ; There is far more setup for loading tiles, so pass
    ; the Map object to it
    jsr Map_LoadTiles

    ; Restore the stack
    plx
    ply
    rts

;
; Loads the sprites from the map into vram
; Expects that X register points to the sprite sheet object
; Expects that Y register points to the engine object
; Does not need to preserve any register.
;
Map_LoadSprites
    ; This will manipulate the X register, so we need to save it
    phy
    phx

    ; Transfer the size of the sprite sheet into the X register
    ; as a counter for reading data
    lda sprite_sheet.size, X
    tay

    ; Start loading the sprite sheet data into VRAM
    ; Expects Y register to be the number of words to allocate
    lda 3, S
    tax
    long_call(BGManager_BG1Next, engine.bg_manager)

    ; Restore X register
    lda 1, S
    tax

    A8

    @VRAMLoop:                      ; Loop through all X bytes of sprite data
        lda sprite_sheet.data.w, X    ; Load bitplane 0/2
        sta VMDATAL                 ; Store data to VRAM
        inx                         ; Increment X register for the data
        dey                         ; Decrement loop counter
        lda sprite_sheet.data.w, X    ; Load bitplane 1/3
        sta VMDATAH                 ; Store data to VRAM
        inx                         ; Increment X register for the data
        dey                         ; Decrement loop counter
        bne @VRAMLoop               ; Loop if we haven't reached 0

    ; Set the background registers
    A16
    ply
    plx
    rts

;
; Read all the palette data from the map into cgram
; Expects that X register points to the palette object
; Expects that Y register points to the engine object
; Does not need to preserve any register.
;
Map_LoadPalettes:
    A16
    phx

    ; Transfer the size of the palette into the X register
    ; as a counter for reading data
    ;lda palette.size, X
    lda #$20
    tay

    A8
    lda #$00
    sta CGADD                   ; Set CGADD to 0x80
    @BGCGRAMLoop:               ; Loop through all X bytes of color data
        lda palette.data, X     ; Low byte color data
        sta CGDATA              ; Store data to CGRAM
        inx                     ; Increment data offset
        dey                     ; Decrement counter
        lda palette.data, X     ; High byte color data
        sta CGDATA              ; Store data to CGRAM
        inx                     ; Increment data offset
        dey                     ; Decrement counter
        bne @BGCGRAMLoop        ; Loop if not

    A16
    plx
    phx

    A8
    lda #$20
    tay
    lda #$80
    sta CGADD                   ; Set CGADD to 0x80
    @ObjCGRAMLoop:              ; Loop through all X bytes of color data
        lda palette.data.w, X   ; Low byte color data
        sta CGDATA              ; Store data to CGRAM
        inx                     ; Increment data offset
        dey                     ; Decrement counter
        lda palette.data.w, X   ; High byte color data
        sta CGDATA              ; Store data to CGRAM
        inx                     ; Increment data offset
        dey                     ; Decrement counter
        bne @ObjCGRAMLoop       ; Loop if not

    A16
    plx

    rts

;
; Read all the tiles data from the map into bgmap
; Expects that X register points to the palette object
; Expects that Y register points to the engine object
; Does not need to preserve any register.
;
Map_LoadTiles:
    phy
    phx

    ; 8-bit background mode for all modes
    A8
    lda #$80
    sta VMAIN

    A16
    ; Put the number of tiles on the stack
    lda map.num_tiles, X
    tay

    ; First get the bgtile offset (which is end of sprite)
    clc
    lda map.sprite_offset, X
    adc 1, S
    tax

    ; This is the number of bytes into vram we should expect
    lda sprite_sheet.size, X

    ; Put the sprite sheet on the stack
    pha

    ; Put the map pointer back into the X register (+2 bytes)
    lda 3, S
    tax

    ; Now, we need to load the tilemap data into VRAM
    clc
    lda map.tile_offset, X
    adc 3, S
    tax

    @LoadTile:
        ; Set the tilemap address
        clc
        lda tile.index, X
        adc #BG1_TILEMAP_VRAM   ; This is hacky.
        sta VMADDL

        ; Save tile reference
        lda tile.id, X
        dea
        sta VMDATAL
        stz VMDATAH

        ; Advance the pointer
        txa
        adc #(_sizeof_Tile)
        tax

        ; Decrement the counter and update stack value
        dey
        bne @LoadTile

    ; Restore the stack
    pla
    plx
    ply

    rts

.8bit
.ends