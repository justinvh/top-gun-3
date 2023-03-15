.macro Stack_Define ARGS NAME, ADDRESS, SIZE
    .enum ADDRESS
        {NAME}@start: dw
        {NAME}@next:  dw
        {NAME}@end:   dw
    .ende

    {NAME}_Init:
        lda #(ADDRESS + 6)
        sta {NAME}@start
        lda #(ADDRESS + 6)
        sta {NAME}@next
        lda #(ADDRESS + SIZE + 6)
        sta {NAME}@end
        rts

    {NAME}_Push:
        sta ({NAME}@next)
        inc {NAME}@next
        inc {NAME}@next
        rts

    {NAME}_Pop:
        dec {NAME}@next
        dec {NAME}@next
        lda ({NAME}@next)
        rts

    {NAME}_Empty:
        lda {NAME}@next
        cmp {NAME}@start

    {NAME}_Full:
        lda {NAME}@next
        cmp {NAME}@end
.endm