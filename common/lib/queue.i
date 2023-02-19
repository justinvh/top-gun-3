.macro Queue_Define ARGS NAME, ADDRESS, SIZE, COUNT
    .enum ADDRESS
        {NAME}@start: dw
        {NAME}@head:  dw
        {NAME}@tail:  dw
        {NAME}@end:   dw
    .ende

    {NAME}_Init:
        A16_XY16
        lda #(ADDRESS + (2 * 4))
        sta {NAME}@start

        lda #(ADDRESS + (2 * 4))
        sta {NAME}@head

        lda #(ADDRESS + (2 * 4))
        sta {NAME}@tail

        lda #(ADDRESS + (SIZE * COUNT) + (2 * 4))
        sta {NAME}@end
        rts

    {NAME}_Push:
        A16_XY16
        ldx {NAME}@tail
        cpx {NAME}@end
        beq {NAME}_Full       
        sta ({NAME}@tail)
        inc {NAME}@tail
        inc {NAME}@tail
        rts

    {NAME}_Pop:
        A16_XY16
        ldx {NAME}@head
        cpx {NAME}@end
        beq {NAME}_Empty
        lda ({NAME}@head)
        inc {NAME}@head
        inc {NAME}@head
        rts

    {NAME}_Empty:
        lda {NAME}@start
        sta {NAME}@head
        rts

    {NAME}_Full:
        lda {NAME}@start
        sta {NAME}@tail
        rts
.endm