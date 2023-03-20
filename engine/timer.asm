;
; Creates a series of timers that can be used to time the execution of code.
;
.section "Timer" bank 0 slot "ROM"

.define MAX_TIMERS 8
.define TICK_MS 17

.struct Timer
    allocated    dw
    enabled      dw
    triggered    dw
    timer_ms     dw
    remaining_ms dw
.endst

.struct TimerManager
    timers instanceof Timer MAX_TIMERS
.endst

.enum $0000
    tm instanceof TimerManager
.ende
.enum $0000
    timer instanceof Timer
.ende

;
; Initialize the timer manager and all timers.
;
TimerManager_Init:
    pha
    phx
    phy

    ldy #MAX_TIMERS
    @Loop:
        stz timer.allocated, X
        stz timer.enabled, X
        stz timer.triggered, X
        stz timer.timer_ms, X
        stz timer.remaining_ms, X

        ; Next timer
        txa
        clc
        adc #_sizeof_Timer
        tax

        ; Check if we're done
        dey
        cpy #0
        bne @Done

    @Done:
        ply
        plx
        pla
        rts

;
; Request a timer from the timer manager. The timer will be disabled by default.
; Y register will be a pointer to the timer.
;
TimerManager_Request:
    pha
    phx

    ldy #MAX_TIMERS
    @Loop:
        lda timer.allocated, X
        cmp #0
        beq @Found

        ; Next timer
        txa
        clc
        adc #_sizeof_Timer
        tax

        ; Check if we're done
        dey
        cpy #0
        bne @Loop

    ; No timers available
    ldy #0
    bra @Done

    ; Found a timer
    @Found:
        lda #1
        sta timer.allocated, X
        stz timer.enabled, X
        stz timer.triggered, X
        stz timer.timer_ms, X
        stz timer.remaining_ms, X
        txy

    @Done:
        plx
        pla
        rts

;
; Tick the clock by 17ms milliseconds.
; A register is the number of milliseconds to tick the clock.
;
TimerManager_Tick:
    pha
    phx
    phy

    ldy #MAX_TIMERS
    @Loop:
        ; Timers not enabled aren't tracked
        lda timer.enabled, X
        cmp #0
        beq @Skip

        ; Timers not allocated aren't tracked
        lda timer.allocated, X
        cmp #0
        beq @Skip

        ; Triggered timers have to be reset
        lda timer.triggered, X
        cmp #1
        beq @Skip

        ; Decrement the remaining time
        lda timer.remaining_ms, X
        sec
        sbc #TICK_MS
        sta timer.remaining_ms, X
        bpl @Skip

        ; Timer has expired, set the triggered flag
        lda timer.timer_ms, X
        sta timer.remaining_ms, X
        lda #1
        sta timer.triggered, X

        ; Next timer
        @Skip:
            txa
            clc
            adc #_sizeof_Timer
            tax
            dey
            cpy #0
            bne @Loop

    ply
    plx
    pla
    rts

;
; Initialize a timer to be triggered after a certain number of milliseconds.
; X register is a pointer to the timer.
; Y register is the number of milliseconds to trigger the timer.
;
Timer_Init:
    pha
    phy

    stz timer.triggered, X

    tya
    sta timer.timer_ms, X
    sta timer.remaining_ms, X

    lda #1
    sta timer.enabled, X
    sta timer.allocated, X

    ply
    pla
    rts

;
; Restarts a timer.
; X register is a pointer to the timer.
;
Timer_Restart:
    pha
    stz timer.triggered, X

    lda timer.timer_ms, X
    sta timer.remaining_ms, X

    lda #1
    sta timer.enabled, X
    sta timer.allocated, X
    pla
    rts

;
; Disables a timer.
; Expects X register to be a pointer to the timer.
;
Timer_Disable:
    stz timer.enabled, X
    rts

;
; Enables a timer.
; Expects X register to be a pointer to the timer.
;
Timer_Enable:
    pha
    lda #1
    sta timer.enabled, X
    pla
    rts

;
; Sets the triggered state of the timer to Y and clears the triggered flag.
; Expects X register to be a pointer to the timer.
;
Timer_Triggered:
    pha
    lda timer.triggered, X
    tay
    stz timer.triggered, X
    pla
    rts

.ends