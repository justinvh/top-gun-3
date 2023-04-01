.section "String" BANK 0 SLOT "ROM"

nop

;
; Calculate the length of a string.
;
; Registers:
;  - X: pointer to start of string
;  - Y: maximum length of string
;
String_Length:
    pha
    phx
    phy

    @Loop:
        lda $0, X
        bne @Continue
        bra @Done

    @Continue:
        inx
        dey
        bne @Loop

    @Done:
        txy
        pla
        plx
        ply
        rts

;
; Reverses a string in place.
; Expects the string to be null-terminated.
;
; Cycles: 32 + 17 * (length of string)
; Registers:
;  - X: pointer to start of string
;  - Y: pointer to the end of the string
;
String_Reverse:
    pha
    phx
    phy

    ; Temporary space
    pha

    @Loop:
        ; x >= y?
        @@CheckPointers:
            tya         ; Load Y into A and store it into temporary space
            sta 1, S    ;
            txa         ; Compare X to the temporary space
            cmp 1, S    ;
            bcs @Done   ; X >= Y, we're done

        ; Swap characters
        @@Swap:
            A8
            lda $0, X   ; Store the character at x into the temporary space
            sta 1, S    ;
            lda $0, Y   ; Load the character at Y
            sta $0, X   ; Store it at X
            lda 1, S    ; Load the character from the temporary space
            sta $0, Y   ; Store it at Y
            A16

        ; x++, y--
        @@AdvancePointers:
            inx
            dey
            bra @Loop

    @Done:
        pla
        ply
        plx
        pla
        rts

;
; Converts a 16-bit unsigned integer
; Registers:
;  - A: integer to convert
;  - X: pointer to string buffer
String_FromInt:
    pha
    phy
    phx

    ; Temporary space, initial value of X
    phx

    @Loop:
        ; n / 10
        tax             ; X = n
        lda #10         ; A = 10
        jsr Math_Div    ; Result is in Y, remainder is in X

        ; Result is in Y, remainder is in X
        txa

        ; n += '0'
        clc
        adc #'0'

        ; *s = n
        plx
        sta $0, X
        inx
        phx

        ; n /= 10
        tya
        bne @Loop

    ; X = pointer to beginning of string
    ; Y = pointer to end of string
    dex
    txy
    lda 3, S
    tax
    jsr String_Reverse

    ; Store a null character
    iny
    lda #0
    sta $0, Y

    plx ; Temporary space
    plx
    ply
    pla
    rts

.ends