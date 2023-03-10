.section "Malloc" BANK 0 SLOT "ROM"

.ACCU	16
.INDEX	16

.define MALLOC_START $0002

.struct Malloc
    size dw ; Size of the current malloc
    next dw ; Pointer to the next free memory
.endst

.enum MALLOC_START
    malloc instanceof Malloc
.ende

;
;  @example
;      jsr Malloc_Init
;
Malloc_Init:
    lda #(MALLOC_START + _sizeof_Malloc)
    sta malloc.next
    stz malloc.size
    rts

;  @example
;      lda #50 ; 50 bytes
;      jsr Malloc_Bytes
;      ; X now holds your pointer
;
Malloc_Bytes:
    ; Push return value
    ldx malloc.next

    pha             ; Store the desired malloc size to malloc.size as a placeholder

    ; Advance the next pointer
    lda malloc.next ; Put the start address into the accumulator
    clc             ; Clear carry flag
    adc 1, S        ; Add the malloc size to the accumulator to advance the pointer
    tay             ; Put the end address into the Y register
    ina             ; Advance the accumulator pointer
    sta malloc.next ; Store the new pointer

    ; Zero memory
    lda #$0000
    jsr Memset

    pla
    rts

;
; Memset an address range with a value
; Arguments:
;  X: Start address
;  Y: End address
;  A: Value to write
;
Memset:
    phx             ; Save the start address of the memory
    phy             ; Save the end address of the memory
    pha             ; Save the value to write

    ; Calculate the size of the memory
    tya             ; Get the end address
    sbc 5, S        ; Subtract the start address from the end address

    ; Setup counter
    tay             ; Make the Y register the counter

    ; Loop and fill
    lda 1, S        ; Load value to write
    @Loop:
        sta (5, S), Y
        dey
        dey
        bpl @Loop

    pla
    ply
    plx
    rts

.ends