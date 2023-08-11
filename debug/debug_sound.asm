; Initially, no debug hooks are enabled
; You do not have to modify these except when adding more hooks
.define DEBUG_SoundPlaySongOfJosiah 0

; If debug.asm doesn't define DEBUG_HOOKS as 1 then none of the debug hooks
; will be compiled below.
.ifeq DEBUG_HOOKS 1

.print "debug_sound.asm: Enabling debug hooks\n"

; Required hooks to debug the Pool manager
.ifeq DEBUG_SOUND_SONG_OF_JOSIAH 1
    .print "debug_sound.asm: Playing the song of Josiah\n"
    .redefine DEBUG_SoundPlaySongOfJosiah 1
.endif

.section "DebugSoundROM" bank 0 slot "ROM"

nop

.ifeq DEBUG_SoundPlaySongOfJosiah 1
Main@DebugPlaySoundOfJosiah:
    pha
    phx

    lda #SongOfJosiah@Data
    ldx #SongOfJosiah@Bank
    jsr SoundManager_PlayMusic

    ; Song of Josiah is best played in Stereo
    lda #1
    jsr SoundManager_Stereo

    ; Song of Josiah wants maximum volume
    lda #255
    ldx #127
    jsr SoundManager_GlobalVolume

    plx
    pla
    rts
.endif

.ends

.endif