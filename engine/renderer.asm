.struct BGScreen
    h_offset dw
    v_offset dw
.endst

.struct Renderer
    bg_screen instanceof BGScreen 4
.endst

.ramsection "RendererRAM" appendto "RAM"
    renderer instanceof Renderer
.ends

.enum $0000
    bg_screen instanceof BGScreen
.ende

.section "Renderer" bank 0 slot "ROM"

;
; Initialize the renderer.
;
Renderer_Init:
    pha
    phx
    phy

    A8
    lda #255
    sta BG1VOFS
    lda #128
    sta BG1VOFS
    A16

    ; Memset should take care of these initializations, but we do it here
    ; anyways if we ever need to re-initialize the renderer.
    ldx #renderer.bg_screen.w
    ldy #0
    @BGScreen_Init:
        stz bg_screen.h_offset, X
        stz bg_screen.v_offset, X
        clc
        txa
        adc #_sizeof_BGScreen
        tax
        iny
        cpy #4
        bne @BGScreen_Init

    ply
    plx
    pla
    rts

Renderer_Frame:
    rts

Renderer_VBlank:
    pha

    inc renderer.bg_screen.1.h_offset.w
    inc renderer.bg_screen.1.h_offset.w
    inc renderer.bg_screen.1.h_offset.w
    inc renderer.bg_screen.1.v_offset.w

    inc renderer.bg_screen.2.h_offset.w


    @UpdateBGOffsets:
        .16bit
        A8
        lda renderer.bg_screen.1.h_offset.w
        sta BG1HOFS
        lda renderer.bg_screen.1.h_offset.w + 1
        sta BG1HOFS

        lda renderer.bg_screen.2.h_offset.w
        sta BG2HOFS
        lda renderer.bg_screen.2.h_offset.w + 1
        sta BG2HOFS

        A16
        .8bit

    pla
    rts

.ends