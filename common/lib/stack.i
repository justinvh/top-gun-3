.macro Stack_Define ARGS NAME, ADDRESS, SIZE
    .enum ADDRESS
        {NAME}@start: dw
        {NAME}@next:  dw
        {NAME}@end:   dw
    .ende

    {NAME}_Init:
        A16_XY16
        lda #(ADDRESS + 6)
        sta {NAME}@start
        lda #(ADDRESS + 6)
        sta {NAME}@next
        lda #(ADDRESS + SIZE + 6)
        sta {NAME}@end
        rts

    {NAME}_Push:
        A16_XY16
        sta ({NAME}@next)
        inc {NAME}@next
        inc {NAME}@next
        rts

    {NAME}_Pop:
        A16_XY16
        dec {NAME}@next
        dec {NAME}@next
        lda ({NAME}@next)
        rts

    {NAME}_Empty:
        A16_XY16
        lda {NAME}@next
        cmp {NAME}@start

    {NAME}_Full:
        A16_XY16
        lda {NAME}@next
        cmp {NAME}@end
.endm