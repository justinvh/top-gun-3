;
; Font management routines for an 8x8 2BPP font
;

.section "Font" bank 0 slot "ROM"

.struct Font
    name    ds 8    ; Name of the font
    bpp     db      ; Bits per pixel
    width   dw      ; Width of each character in pixels
    height  dw      ; Height of each character in pixels
    bin     dw      ; Pointer to the font data
    pal     dw      ; Pointer to the palette to use
    bg      db      ; Which BG VRAM space to use
.endst

.struct FontDrawInfo
    font    dw      ; Pointer to the font object
    data    dw      ; Pointer to the string to draw or collection of indices
    x       db      ; X position to draw at
    y       db      ; Y position to draw at
    time    db      ; Time between character drawing
    mode    db      ; If 0, draw the string, otherwise use the string as indices
    color   db      ; Color to draw with
.endst

.enum $0000
    font instanceof Font
.ende

;
; Load a font given a pointer to the font data
; Expects X to point to the font object
;
Font_Load:
    rts

;
; Draw a character at the given coordinates
; Expects X to point to the font object
; Expects Y to contain the X and Y coordinate
; Expects A to contain the character to draw

.ends