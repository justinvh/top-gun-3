.ACCU   16
.INDEX  16

.define MAX_INPUTS 2

.struct PadState
    index  db
    allocated db
    rbtn   db
    lbtn   db
    xbtn   db
    abtn   db
    rhtbtn db
    lftbtn db   
    dnbtn  db
    upbtn  db
    start  db
    select db
    ybtn   db
    bbtn   db
.endst

.enum $00
    padstate instanceof PadState
.ende

.struct PadManager
    pad_objects instanceof PadState MAX_INPUTS

    pad_queue instanceof Queue
    pad_queue_memory  ds (2 * MAX_INPUTS)
.endst

.ramsection "PadRAM" appendto "RAM"
    pad_manager instanceof PadManager
.ends

.section "PadROM" BANK 0 SLOT "ROM"

nop

Pad_Init:
    A8
    stz padstate.bbtn, X
    stz padstate.ybtn, X
    stz padstate.select, X
    stz padstate.start, X
    stz padstate.upbtn, X
    stz padstate.dnbtn, X
    stz padstate.lftbtn, X
    stz padstate.rhtbtn, X
    stz padstate.abtn, X
    stz padstate.xbtn, X
    stz padstate.lbtn, X
    stz padstate.rbtn, X
    stz padstate.index, X
    A16
    rts

Pad_Frame:
    rts

PadManager_VBlank:
    pha

    ; Wait until the HVBJOY shows that the controllers are ready to be read
    @WaitForJoyReady:
        lda HVBJOY
        and #1
        bne @WaitForJoyReady

    ; Advance the pointer to the first joypad input object in the struct
    clc
    lda #pad_manager.pad_objects
    tax
    pha
    lda #JOY1L
    pha
    ldy #0
        @Loop:
            pla
            jsr Pad_Buttons
            adc #2
            pha
            lda 3, s
            clc
            adc #_sizeof_PadState 
            sta 3, s
            tax 
            iny                     
            cpy #MAX_INPUTS    
            bne @Loop
    pla
    pla
    pla
    rts

Pad_Buttons:
    pha
    phy

    phx
    tax
    lda $00, x
    plx

    ; Skip controller id
    lsr A
    lsr A
    lsr A
    lsr A

    ldy #12
    pha
    txa
    adc #padstate
    tax
    pla
    clc
    inx
    inx
    @Loop:
        stz padstate, X ; 5 cycles
        lsr A                   ; 2 cycles
        rol padstate, X ; 7 cycles
        inx
        dey
        bne @Loop

    bra @Done

    @Done:
        A16
        ply
        pla
        rts

PadManager_Init:
    pha
    phy
    phx

    ; Initialize the queue
    lda #pad_manager.pad_queue_memory       ; Set the base address of the queue 
    sta pad_manager.pad_queue.start_addr.w 

    ; Calculate the end address of the queue
    clc
    adc #(MAX_INPUTS * 2)
    sta pad_manager.pad_queue.end_addr.w 

    ; Set the element size to 1 bytes
    lda #1
    sta pad_manager.pad_queue.element_size.w 

    ; Initialize the queue
    ldx #pad_manager.pad_queue               ; Set the Queue "this" pointer
    jsr Queue_Init

    ; Advance the pointer to the first Pad object in the struct
    clc
    lda #pad_manager.pad_objects
    tax

    ; This will be the counter for number of objects
    ldy #0

    @Loop:
        jsr Pad_Init 
        sty padstate.index, X
        clc
        adc #_sizeof_PadState 
        tax 
        iny                     
        cpy #MAX_INPUTS    
        bne @Loop 

    plx
    ply
    pla
    rts

PadManager_Request:
    pha
    phx

    ; Advance the pointer to the first OAM object in the struct
    clc
    lda #pad_manager.pad_objects
    sec
    sbc #_sizeof_PadState       ; Intentionally start at -1
    tax

    ldy #0

    @Next:
        clc
        txa
        adc #_sizeof_PadState   ; Advance the pointer
        tax

        ; Did we reach the end of the INPUT object space?
        iny
        cpy #(MAX_INPUTS + 1)
        beq @Error

        ; Otherwise check if the object is allocated
        lda padstate.allocated, X
        and #$00FF

        bne @Next

    ; If we got here, then we found a free object. Mark it allocated
    lda #1
    sta padstate.allocated, X

    ; Return the address of the INPUT object
    txy
    bra @Done

    ; If we got here, then we did not find a free object
    @Error:
        ldy #0

    ; Common exit point. We do not restore Y because we want to return it.
    @Done:
        plx
        pla

    rts
.ends
