;
; Module for implementing the SNES Multitap Interface
;
; Responsible for identifying which port the Multitap is plugged into
; and then providing a way to sample the inputs.
;
; Supports Multitap being plugged into both ports.
;
.struct MultitapPort
    id      db
    enabled db
    sigh    db
    sigl    db
.endst

.struct Multitap
    port instanceof MultitapPort 2
    enabled db
.endst

.ramsection "Multi5RAM" appendto "RAM"
    multi5 instanceof Multitap
.ends

.section "Multi5ROM" bank 0 slot "ROM" semifree

Multitap_Init:
    A8

    lda #1
    sta multi5.port.1.id
    stz multi5.port.1.sigh
    stz multi5.port.1.sigl
    stz multi5.port.1.enabled

    lda #2
    sta multi5.port.2.id
    stz multi5.port.2.sigh
    stz multi5.port.2.sigl
    stz multi5.port.2.enabled

    A16
    rts

;
; V-Blank Routine for the Multitap Driver
;
Multitap_VBlank:
    jsr Multitap_IdentifyPort
    rts

;
; The peripheral device signature is contained in bits 13 ~ 16
; of the OUT 0 latch pulse (<4016H> D0 WR) when read serially from
; <4016H> D0 (<4017H> D0)
;
; Check 4-9-5 of the manual to see the timing diagrams.
;
; This code will not do anything to confirm that the Multitap is
; plugged into Port #2, only that it is either plugged into Port #1,
; Port #2, or both.
;
Multitap_IdentifyPort:
    php
    A8_XY8
    sep #$30

    stz multi5.enabled
    stz multi5.port.1.enabled
    stz multi5.port.2.enabled

    @WaitForAutoJoyRead:
        lda HVBJOY
        and #$01
        bne @WaitForAutoJoyRead
    
    ; Clear the latch state, so we can sample the ports
    stz JOYOUT
    
    ; This reads both port.1 and port.2 registers 8x times
    ; and sets the initial signature check for each of them.
    @ReadSignaturePass1:
        ; When bit is set, we enable the latch state
        lda #1
        sta JOYOUT

        ; Read each port.1 and port.2 8x
        ldx #8
        @@Loop:
            ; Read the controller port 1 state
            lda JOYSER0
            lsr A
            lsr A
            rol multi5.port.1.sigh

            ; Read the controller port 2 state
            lda JOYSER1
            lsr A
            lsr A
            rol multi5.port.2.sigh

            ; Read 8x times
            dex
            bne @@Loop

    ; This reads port.1 and port.2 registers 8x times, again.
    ; The goal is to verify the signature is now not $FF.
    @ReadSignaturePass2:
        ; Clear the latch state and then read the ports again
        stz JOYSER0

        ; Read each port.1 and port.2 8x
        ldx #$08
        @@Loop:
            ; Read the controller port 1 state
            lda JOYSER0
            lsr A
            lsr A
            rol multi5.port.1.sigl

            ; Read the controller port 2 state
            lda JOYSER1
            lsr A
            lsr A
            rol multi5.port.2.sigl

            ; Read 8x times
            dex
            bne @@Loop

    ; We then check the state of port.1 signature bits and
    ; check if they are set to $FF and then not $FF. If true,
    ; then a multitap is plugged into port 1
    @CheckPort1Enabled:
        ; if (port.1_sigh != 0xFF) CheckPort2Enabled()
        lda multi5.port.1.sigh
        cmp #$FF
        bne @CheckPort2Enabled

        ; if (port.1_sigh == 0xFF) CheckPort2Enabled()
        lda multi5.port.1.sigl
        cmp #$FF
        beq @CheckPort2Enabled

        ; A Multitap is plugged into port.1
        lda #1
        sta multi5.port.1.enabled
        sta multi5.enabled

    ; We then check the state of port.2 signature bits and
    ; check if they are set to $FF and then not $FF. If true,
    ; then a multitap is plugged into port 2
    @CheckPort2Enabled:
        ; if (port.1_sigh != 0xFF) Done()
        lda multi5.port.2.sigh
        cmp #$FF
        bne @Done

        ; if (port.1_sigh == 0xFF) Done()
        lda multi5.port.2.sigl
        cmp #$FF
        beq @Done

        ; A Multitap is plugged into port.2
        lda #1
        sta multi5.port.2.enabled
        sta multi5.enabled

    @Done:
        plp
        A16_XY16
        rts

.ends
