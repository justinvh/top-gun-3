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
    lda #(MALLOC_START + 4)
    sta malloc.next
    rts

;  @example
;      lda $#50 ; 50 bytes
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
    ina             ; Advance by 1
    sta malloc.next ; Advance the pointer
    tay             ; Put the end address into the Y register

    ; Debugging: Memset the allocated memory
    phx             ; Save the start address of the memory
    phy             ; Save the end address of the memory
    lda 5, S        ; Put the malloc size into the accumulator
    tay             ; Make the Y register the counter
    lda #$FFFF      ; Make the accumulator the magic value to write
    @Malloc_Memset:
        sta (3, S), Y
        dey
        dey
        bpl @Malloc_Memset
    ply
    plx

    pla
    rts

.ends