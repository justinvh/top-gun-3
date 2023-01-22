.include "engine/drivers/spc700/interface.asm"

/**
 * @private
 * 
 * Utility for clamping a byte from 0-100 -> 0-127
 * @param val Value to clamp from 0-100 and map to 0-127
 * @return 0-127
 */
 .function S_NormByte(val) lobyte(((clamp(val, 0, 100) / 100) * 127))

 /**
  * @private
  *
  * Converts a channel and a register to a given offset
  * @param ch Channel index from 1-7
  * @param reg Register offset
  * @return Offset from $0C
 */
 .function S_ChRegister(ch, reg) ($C0 + (clamp(ch, 1, 7) - 1) * $0F) + reg

/**
 * @privaengine/te
 *
 * Utility to quickly print a register and associated value
 * @param register  HEX     value
 * @param value     HEX     value
 */
.macro S_DebugPrint
    .ifdef DEBUG
        .print "[S]: register=$", HEX \1, " value=$", HEX \2, "\n"
    .endif
.endm

/**
 * @private
 *
 * Wrapper around preparing local registers and sending to the SPC
 * @param register  HEX     value
 * @param value     HEX     value
 */
.macro S_SendCmd ARGS register value
    S_DebugPrint(register, value)
    lda.b   register
    ldx.b   value
    jsr     SPC_SendCmd
.endm


/**
 * Set the left and right volume for a channel
 *
 * @param channel   Channel         1-7
 * @param left      Left Volume     0-100
 * @param right     Right Volume    0-100
 *
 * @code
 * ; Set channel 1 left and right channels to 100%
 * S_ChVol 1 100 100
 * @endcode
 */
.macro S_ChVol ARGS channel left right
    S_SendCmd(S_ChRegister(channel, CH_VOL_L) S_NormByte(left))
    S_SendCmd(S_ChRegister(channel, CH_VOL_R) S_NormByte(right))
.endm

S_ChPitch:
    rts

S_ChSource:
    rts

S_ChADSR:
    rts

S_ChGain:
    rts

S_ChOn:
    rts

S_ChOff:
    rts

S_MainVol:
    rts

S_EchoVol:
    rts

S_Init:
    rts