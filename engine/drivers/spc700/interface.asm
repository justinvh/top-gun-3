/**
 *                       SPC Sound Registers
 * |=========================================================================|
 * | [c]hannel registers (1-7)                                               |
 * |=========================================================================|
 * |    | Name  | Description                    | Bits        | Meaning     |
 * |----|-------|--------------------------------|-------------|-------------|
 * | c0 | VOL   | Left Volume                    | -VVV VVVV   | Volume      |
 * | c1 | VOL   | Right Volume                   | -VVV VVVV   | Volume      |
 * | c2 | P     | Pitch Low                      | PPPP PPPP   | Pitch       |
 * | c3 | P     | Pitch High                     | --PP PPPP   | Pitch       |
 * | c4 | SRCN  | Source number                  | SSSS SSSS   | Source      |
 * | c5 | ADSR  | Use ADSR, else GAIN            | E DDD AAAA  | En, Dr, Ar  |
 * | c6 | ADSR  | ADSR envelope                  | LLL RRRRRR  | sL, sR      |
 * | c7 | GAIN  | Envelope bits                  | GGGG GGGG   | Bits        |
 * | c8 | -ENVX | Read envelope value            | 0VVV VVVV   | Value       |
 * | c9 | -OUTX | Read waveform value            | S VVV VVVV  | Signed      |
 * |=========================================================================|
 * | Master registers (1-7)                                                  |
 * |=========================================================================|
 * | 0C | MVOL  | Main volume left               | -VVV VVVV   | Volume      |
 * | 1C | MVOL  | Main volume right              | -VVV VVVV   | Volume      |
 * | 2C | EVOL  | Echo volume left               | -VVV VVVV   | Volume      |
 * | 3C | EVOL  | Echo volume right              | -VVV VVVV   | Volume      |
 * | 4C | KON   | Key On                         | CCCC CCCC   | Channel     |
 * | 5C | KOFF  | Key Off                        | CCCC CCCC   | Channel     |
 * | 6C | FLG   | Reset, mute, echo, noise       | R M E NNNNN | Echo Off=1  |
 * | 7C | -ENDX | Read to see if channel is done | CCCC CCCC   | Channel     |
 * | 0D | EFB   | Echo feedback                  | S FFF FFFF  | Signed      |
 * | 2D | PMON  | Pitch modulation               | CCCC CCC-   | Channel 1-7 |
 * | 3D | NON   | Noise enable                   | CCCC CCCC   | Channel     |
 * | 4D | EON   | Echo enable                    | CCCC CCCC   | Channel     |
 * | 5D | DIR   | directory=DIR*100h             | OOOO OOOO   | $OO00       |
 * | 6D | ESA   | buffer start=ESA*100h          | OOOO OOOO   | $OO00       |
 * | 7D | EDL   | Echo delay, 4-bits             | ---- EEEE   | Echo delay  |
 * |=========================================================================|
 * | FIR [f]ilter Coefficient registers                                        |
 * |=========================================================================|
 * | fF | COEF  | 8-tap FIR filter coef          | S CCC CCCC  | Coefficient |
 * |=========================================================================|
 */

.function SPC_65816(register) ($2140 + (register - $00F4))

.define CH_VOL_L    $00
.define CH_VOL_R    $01

/* SNES Side Ports */
.define SNES_P1     $2140
.define SNES_P2     $2141
.define SNES_P3     $2142
.define SNES_P4     $2143

/* SPC Side Ports (as SNES ports) */
.define SPC_P1      SPC_65816($00F4)
.define SPC_P2      SPC_65816($00F5)
.define SPC_P3      SPC_65816($00F6)
.define SPC_P4      SPC_65816($00F7)

/**
 * Send a register and value to the SPC
 *
 * @register A SPC register
 * @register X Value to set
 *
 * ==================================================
 * SNES SIDE                             SPC SIDE
 * ==================================================
 * (write)                               (write)
 * -----> $2140 ------------,    .-------- P1 <-----
 * -----> $2141 ----------, |    | .------ P2 <-----
 * -----> $2142 --------, | |    | | .---- P3 <-----
 * -----> $2143 ------, | | |    | | | .-- P4 <-----
 *                    | | | |    | | | |
 * <----- $2140 <-----|-|-|-|----' | | |
 * <----- $2141 <-----|-|-|-|------' | |
 * <----- $2142 <-----|-|-|-|--------' |
 * <----- $2143 <-----|-|-|-|----------'
 * (read)             | | | |            (read)
 *                    | | | `------------> P1 ------>
 *                    | | `--------------> P2 ------>
 *                    | `----------------> P3 ------>
 *                    `------------------> P4 ------>
 */
SPC_SendCmd:
    /* Put A and X into Port 1 and Port 2 */
    sta SNES_P1
    stx SNES_P2
    ;lda #03

    /* Define the command write the value in 00F7/2143 */
    sta SPC_P3
    lda SPC_P4
    sta SPC_P4

    /* Wait until the value changes, which means the SPC processed */
    _SPC_SendCmdWait:
        cmp $2143
        beq _SPC_SendCmdWait

    rts


/**
 * Initialization routine for preparing for data transfer.
 * The read and write ports are separate.
 */
SPC_Init:
    lda SPC_P1
    cmp $AA
    bne SPC_Init
    lda SPC_P2
    cmp $BB
    bne SPC_Init
	rts