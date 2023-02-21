.section "Malloc" BANK 0 SLOT "ROM"

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
    A16_XY16
    lda #(MALLOC_START + 4)
    sta malloc.next
    rts

;  @example
;      lda $#50 ; 50 bytes
;      jsr Malloc_Bytes
;      ; X now holds your pointer
;
Malloc_Bytes:
    A16_XY16

    ; Push return value
    ldx malloc.next

    ; Store the start address 
    sta malloc.size ; Store the desired malloc size to malloc.size as a placeholder

    ; Advance the next pointer
    lda malloc.next ; Put the start address into the accumulator
    clc             ; Clear carry flag
    adc malloc.size ; Add the malloc size to the accumulator to advance the pointer
    sta malloc.next ; Advance the pointer

    rts

.ends