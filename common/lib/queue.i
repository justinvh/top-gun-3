.macro Queue_Define ARGS NAME, ADDRESS, SIZE
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

        lda #(ADDRESS + SIZE + (2 * 4))
        sta {NAME}@end
        rts

    {NAME}_Push:
        A16_XY16
        sta ({NAME}@tail)
        inc {NAME}@tail
        inc {NAME}@tail
        rts

    {NAME}_Pop:
        A16_XY16
        lda ({NAME}@head)
        inc {NAME}@head
        inc {NAME}@head
        rts

    {NAME}_Empty:
        rts

    {NAME}_Full:
        rts
.endm