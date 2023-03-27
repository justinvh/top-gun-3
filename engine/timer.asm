;
; Creates a series of timers that can be used to time the execution of code.
;
.define MAX_TIMERS 8
.define VBLANK_MS 16
.define VBLANK_US 666

.struct Timer
    allocated    dw
    enabled      dw
    triggered    dw
    timer_ms     dw
    remaining_ms dw
.endst

.struct Clock
    us  dw
    ms  dw
    s   db
    m   db
    h   db
    d   db
.endst

.struct TimerManager
    elapsed_hblanks dw
    elapsed_vblanks dw
    elapsed_us dw
    elapsed_ms dw
    clock instanceof Clock
    timers instanceof Timer MAX_TIMERS
.endst

.enum $0000
    timer instanceof Timer
.ende

.ramsection "TimerManagerRAM" appendto "RAM"
    timer_manager instanceof TimerManager
.ends

.section "Timer" bank 0 slot "ROM"
;
; Initialize the timer manager and all timers.
;
TimerManager_Init:
    pha
    phx
    phy

    A8
    stz timer_manager.clock.s.w
    stz timer_manager.clock.m.w
    stz timer_manager.clock.h.w
    stz timer_manager.clock.d.w

    A16
    stz timer_manager.clock.us.w
    stz timer_manager.clock.ms.w
    stz timer_manager.elapsed_us.w
    stz timer_manager.elapsed_ms.w
    stz timer_manager.elapsed_hblanks.w
    stz timer_manager.elapsed_vblanks.w

    ldx #timer_manager.timers

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
        bne @Loop

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
    ldx #timer_manager.timers
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

TimerManager_Tick:
    pha
    phx

    clc
    ldx timer_manager.elapsed_vblanks.w

    @Loop:
        @Elapsed:
            lda timer_manager.elapsed_ms.w  ; V-Blank is 60Hz to 50Hz
            adc #VBLANK_MS                  ; Add 16ms to the elapsed time
            sta timer_manager.elapsed_ms.w  ; Store the new elapsed time

            lda timer_manager.elapsed_us.w  ; V-Blank is 60Hz to 50Hz
            adc #VBLANK_US                  ; Add 666us to the elapsed time
            sta timer_manager.elapsed_us.w  ; Store the new elapsed time
            cmp #1000                       ; Check if we've reached 1ms
            bcc @Microseconds               ; If not, skip to updating the clock

            lda #1000                       ; Subtract 1ms from the elapsed time (us)
            sec                             ; Prepare carry flag
            sbc timer_manager.elapsed_us.w  ; Calculate remainder
            sta timer_manager.elapsed_us.w  ; Store the remainder
            inc timer_manager.elapsed_ms.w  ; Increment the elapsed time (ms)

        @Microseconds:
            clc
            lda timer_manager.clock.us.w
            adc #VBLANK_US
            sta timer_manager.clock.us.w
            cmp #1000
            bcc @Milliseconds; if (us_elapsed <= 1000)
            sec                             ; Prepare carry flag
            sbc #1000                       ; Calculate remainder
            sta timer_manager.clock.us.w    ; Store the remainder
            inc timer_manager.clock.ms.w    ; Increment the clock (ms)

        @Milliseconds:
            clc                             ; Add 16ms to the clock (ms)
            lda timer_manager.clock.ms.w    ;
            adc #VBLANK_MS                  ;
            sta timer_manager.clock.ms.w    ; Store the new clock (ms)
            cmp #1000                       ; Check if we've reached 1s
            bcc @Done                       ; If not, we're done.
            sec                             ; Prepare carry flag
            sbc #1000                       ; Subtract 1ms from the clock (ms)
            sta timer_manager.clock.ms.w    ; Store the remainder

        A8

        @Seconds:
            inc timer_manager.clock.s.w     ; Increment the clock (s)
            lda timer_manager.clock.s.w     ; Check if we've reached 60s
            cmp #60                         ;
            bcc @Done                       ; If not, we're done.

        @Minutes:
            stz timer_manager.clock.s.w     ; Reset the clock (s)
            inc timer_manager.clock.m.w     ; Increment the clock (m)
            lda timer_manager.clock.m.w     ; Check if we've reached 60m
            cmp #60                         ;
            bcc @Done                       ; If not, we're done.

        @Hours:
            stz timer_manager.clock.m.w     ; Reset the clock (m)
            inc timer_manager.clock.h.w     ; Increment the clock (h)
            lda timer_manager.clock.h.w
            cmp #24
            bcc @Done

        @Days:
            stz timer_manager.clock.h.w
            inc timer_manager.clock.d.w
            lda timer_manager.clock.d.w

        @Done:
            A16
            dex
            cpx #0
            beq @Exit
            jmp @Loop

    @Exit:
    stz timer_manager.elapsed_vblanks.w
    A16
    plx
    pla
    rts

TimerManager_Frame:
    pha
    phx
    phy

    lda timer_manager.elapsed_vblanks.w
    cmp #0
    beq @Done

    jsr TimerManager_Tick

    ldy #MAX_TIMERS
    ldx #timer_manager.timers
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
        sbc timer_manager.elapsed_ms.w
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

    ; Reset the elapsed ms time, since we are checking it now.
    stz timer_manager.elapsed_ms.w

    @Done:
    ply
    plx
    pla
    rts

;
; Increment the elapsed vblanks counter.
;
TimerManager_VBlank:
    inc timer_manager.elapsed_vblanks.w
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