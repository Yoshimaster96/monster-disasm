	.base $8000
	.org $8000
;BANK NUMBER
	.db $3C

;;;;;;;;;;;;;;;;
;SOUND ROUTINES;
;;;;;;;;;;;;;;;;
UpdateSoundPause:
	;Do jump table
	clc
	lda PausedFlag
	adc SoundPausedFlag
	adc #$19
	jmp UpdateSoundChannel_CommandJump

UpdateSoundPause_Pause:
	;Set paused sound flag
	lda #$02
	sta SoundPausedFlag
	;Clear other sound registers
	jmp ClearSoundSub_ClearRegs

UpdateSoundPause_Unpause:
	;Clear paused sound flag
	lda #$00
	sta SoundPausedFlag
	;Check for triangle channel
	ldx #$02
	lda SoundID,x
	beq UpdateSoundPause_NoTri
	;Check for envelope sustain end
	jsr CheckEnvSEnd
	bcc UpdateSoundPause_NoTri
	beq UpdateSoundPause_NoTri
	;Check for rest
	lda SoundControlFlags1,x
	and #SF1_REST
	bne UpdateSoundPause_NoTri
	;Set triangle linear timer
	lda #$90
	sta TRI_LINEAR
	lda SoundFreqHi,x
	ora #$08
	sta TRI_HI
UpdateSoundPause_NoTri:
	;Check for SFX square channel
	lda SoundID+4
	beq UpdateSoundPause_NoSESq
	;Check for pause sound effect
	cmp #SE_PAUSE
	beq UpdateSoundPause_NoChange
UpdateSoundPause_NoSESq:
	;Check for looping SFX
	lda SoundLoopingID
	beq UpdateSoundPause_Sq1
	;Check for level 4 crane sound effect
	cmp #SE_LEVEL4CRANE
	bne UpdateSoundPause_NoLoad16
	;Reload sound effect
	lda #SE_LEVEL4CRANELOOP
UpdateSoundPause_Load:
	;Load sound
	jmp LoadSoundSub
UpdateSoundPause_NoLoad16:
	;Check for level 4 elevator sound effects
	cmp #SE_LEVEL4ELEV
	beq UpdateSoundPause_Load18
	cmp #SE_LEVEL4ELEVSLOW
	beq UpdateSoundPause_Load19
	;Check for level 6 crusher sound effect
	lda #SE_LEVEL6CRUSHER
	bne UpdateSoundPause_Load
UpdateSoundPause_Load18:
	;Reload sound effect
	lda #SE_LEVEL4ELEVLOOP
	bne UpdateSoundPause_Load
UpdateSoundPause_Load19:
	;Reload sound effect
	lda #SE_LEVEL4ELEVSLOWLOOP
	bne UpdateSoundPause_Load
UpdateSoundPause_Sq1:
	;Check for square 1 channel
	ldx #$00
	lda SoundID,x
	beq UpdateSoundPause_NoChange
	;Check for sound effect
	lda SoundControlFlags1,x
	and #SF1_SNDEFF
	bne UpdateSoundPause_SE
	;Set square 1 sound registers
	lda SoundOutFreqHi,x
	ora #$08
	sta SQ1_HI
	lda SoundSq1OutFreqLo
	sta SQ1_LO
	;Output sound volume
	jmp OutputSoundVolume
UpdateSoundPause_NoChange:
	rts
UpdateSoundPause_SE:
	;Set square 1 sound registers
	lda SoundFreqHi,x
	ora #$08
	sta SQ1_HI
	lda SoundFreqLo,x
	sta SQ1_LO
	lda SoundOutVol,x
	ora SoundDuty,x
	sta SQ1_VOL
	rts

UpdateSoundSub:
	;Update sound pause
	jsr UpdateSoundPause
	;Update sound fadeout
	ldx #$00
	stx SoundCurChannel
	ldy #$00
	jsr UpdateSoundFadeout
	;Decrement DMC sample timer
	lda SoundDMCTimer
	beq UpdateSoundSub_NoC
	dec SoundDMCTimer
UpdateSoundSub_NoC:
	;Clear sound tick flag
	lda #$00
	sta SoundTickFlag
	;If tempo timer 0, set sound tick flag
	lda SoundTempoTimer
	beq UpdateSoundSub_Loop
	;Decrement tempo timer, check if 0
	dec SoundTempoTimer
	bne UpdateSoundSub_Loop
	;Set sound tick flag
	inc SoundTickFlag
	;Reset tempo timer
	lda SoundTempoReload
	sta SoundTempoTimer
	inc SoundTempoTimer
UpdateSoundSub_Loop:
	;Check if channel is active
	lda SoundID,x
	beq UpdateSoundSub_Next
	;Check for pause sound effect
	cmp #SE_PAUSE
	beq UpdateSoundSub_Pause
	lda SoundPausedFlag
	beq UpdateSoundSub_Pause
	bne UpdateSoundSub_Next
UpdateSoundSub_Pause:
	;Get sound register index
	lda SoundOutIndexTable,x
	sta SoundOutIndex
	;Update sound channel
	jsr UpdateSoundChannel
UpdateSoundSub_Next:
	;Go to next channel
	inx
	stx SoundCurChannel
	cpx #$06
	bcc UpdateSoundSub_Loop
	rts

UpdateSoundChannel:
	;Check for sound tick flag
	lda SoundTickFlag
	beq UpdateSoundChannel_NextTick
	;Check for sound effect
	lda SoundControlFlags1,x
	and #SF1_SNDEFF
	beq UpdateSoundSub_Next
UpdateSoundChannel_NextTick:
	;Decrement sound timer
	dec SoundTimer,x
	;If timer expired, get next command byte
	beq UpdateSoundChannel_NextCmd
	jmp UpdateSoundChannel_Continue
UpdateSoundChannel_NextCmd:
	;Increment sound timer
	inc SoundTimer,x
	;Get sound data pointer
	ldy #$00
	lda SoundPointerLo,x
	sta TempSoundDataPointer
	lda SoundPointerHi,x
	sta TempSoundDataPointer+1
	dey
UpdateSoundChannel_NextByte:
	iny
UpdateSoundChannel_GetByte:
	;Check for sound effect
	lda SoundControlFlags1,x
	and #SF1_SNDEFF
	beq UpdateSoundChannel_NoSE
	jmp UpdateSoundChannel_SE
UpdateSoundChannel_NoSE:
	;Check for command byte $D0-$FF
	lda (TempSoundDataPointer),y
	cmp #$D0
	bcs UpdateSoundChannel_Command
	;Check for command byte $00-$0F (rest command)
	lda (TempSoundDataPointer),y
	and #$F0
	beq UpdateSoundChannel_Command
	;Check for noise channel
	cpx #$03
	bne UpdateSoundChannel_NoNoise
	jmp SoundCommandNote_Noise
UpdateSoundChannel_NoNoise:
	jmp SoundCommandNote_NoNoise

SoundOutIndexTable:
	.db $00,$04,$08,$0C,$00,$0C

UpdateSoundFadeout:
	;If fadeout timer 0, exit
	lda SoundFadeoutCounter
	beq UpdateSoundFadeout_Exit
	;If fadeout timer $0100, clear square channels
	cmp #$01
	bne UpdateSoundFadeout_NoFadeSq
	lda #$00
	sta SoundID
	sta SoundID+1
	lda #$30
	sta SQ2_VOL
	lda SoundID+4
	bne UpdateSoundFadeout_Ch0Exit
	lda #$30
	sta SQ1_VOL
UpdateSoundFadeout_Ch0Exit:
	rts
UpdateSoundFadeout_NoFadeSq:
	;If fadeout timer $0400, clear triangle channel
	cmp #$04
	bne UpdateSoundFadeout_NoFadeTri
	jsr SoundCommandFF_Tri
	lda #$00
	sta SoundID+2
	beq UpdateSoundFadeout_NoFadeNoise
UpdateSoundFadeout_NoFadeTri:
	;If fadeout timer $0500, clear noise channel
	cmp #$05
	bne UpdateSoundFadeout_NoFadeNoise
	lda #$00
	sta SoundID+3
UpdateSoundFadeout_NoFadeNoise:
	;Increment fadeout timer and compare
	inc SoundFadeoutTimer
	lda #$20
	cmp SoundFadeoutTimer
	bne UpdateSoundFadeout_Exit
	lda #$00
	sta SoundFadeoutTimer
	lda SoundFadeoutCounter
	cmp #$09
	bcs UpdateSoundFadeout_NoC
	inc SoundFadeout
UpdateSoundFadeout_NoC:
	dec SoundFadeoutCounter
UpdateSoundFadeout_Exit:
	rts

UpdateSoundChannel_Command:
	;Get jump table offset
	and #$30
	lsr
	lsr
	lsr
	lsr
UpdateSoundChannel_CommandJump:
	;Get jump address
	asl
	tax
	lda SoundCommandJumpTable,x
	sta $E2
	lda SoundCommandJumpTable+1,x
	sta $E3
	ldx SoundCurChannel
	;Jump to address
	jmp ($E2)

UpdateSoundChannel_Continue:
	;Check for rest or sound effect flags
	lda SoundControlFlags1,x
	and #(SF1_REST|SF1_SNDEFF)
	bne UpdateSoundChannel_Exit
	;Check for noise channel
	cpx #$03
	beq UpdateSoundChannel_Exit
	;Check for instrument pitch flag
	lda SoundInstrumentFlags,x
	and #SFI_INST2
	beq UpdateSoundChannel_NoInst2
	;Check for echo outputted flag
	lda SoundEchoFlags,x
	and #SFE_OUTPUT
	bne UpdateSoundChannel_NoInst2
	;Update instrument pitch
	lda SoundInst2TimerStart,x
	beq UpdateSoundChannel_Inst2Cont
	dec SoundInst2TimerStart,x
	bne UpdateSoundChannel_NoInst2
	beq UpdateSoundChannel_Inst2Init
UpdateSoundChannel_Inst2Cont:
	dec SoundInst2Timer,x
	bne UpdateSoundChannel_NoInst2
	inc SoundInst2Pointer,x
UpdateSoundChannel_Inst2Init:
	jsr UpdateInstrumentPitch
	;Check for end of instrument data
	lda ($E4),y
	cmp #$FF
	beq UpdateSoundChannel_Inst2End
	;Output sound pitch
	jsr OutputSoundPitch
UpdateSoundChannel_Inst2End:
	;Restore X/Y registers
	ldx SoundCurChannel
	ldy $E2
UpdateSoundChannel_NoInst2:
	;Check for envelope sustain end
	jsr CheckEnvSEnd
	beq UpdateSoundChannel_EnvSEnd
	bcs UpdateSoundChannel_NoEnvSEnd
UpdateSoundChannel_EnvSEnd:
	;Update envelope release
	jmp UpdateSoundEnvR
UpdateSoundChannel_NoEnvSEnd:
	;Check for triangle channel
	cpx #$02
	beq UpdateSoundChannel_Exit
	;Check for echo enabled flag
	lda SoundEchoFlags,x
	and #SFE_ENABLE
	beq UpdateSoundChannel_NoEcho
	;If echo amount >= $07, don't update echo
	lda SoundEchoAmount,x
	cmp #$07
	bcs UpdateSoundChannel_NoEcho
	;Update echo buffer
	jsr UpdateEchoBuffer
UpdateSoundChannel_NoEcho:
	;Do jump table
	lda SoundEnvMode,x
	clc
	adc #$14
	jmp UpdateSoundChannel_CommandJump
UpdateSoundChannel_Exit:
	rts

UpdateSoundEnvHD:
	;Decrement envelope hold timer, check if < 0
	dec SoundEnvHTimer,x
	bmi UpdateSoundEnvHD_ResetH
	beq UpdateSoundEnvHD_Decay
	bpl UpdateSoundChannel_Exit
UpdateSoundEnvHD_ResetH:
	;Reset envelope hold timer
	lda SoundEnvHDData,x
	lsr
	lsr
	lsr
	lsr
	sec
	sbc #$07
	sta SoundEnvHTimer,x
	bne UpdateSoundEnvHD
UpdateSoundEnvHD_Decay:
	;Check for envelope decay end
	lda SoundEnvDTimer,x
	beq UpdateSoundEnvS
	;Decrement sound volume
	lda SoundEnvDMultiplier,x
	bne UpdateSoundEnvHD_EnvDC
	lda #$01
UpdateSoundEnvHD_EnvDC:
	sta $E2
	lda SoundOutVol,x
	jsr DecSoundVolume
	;Decrement envelope decay timer, check if < 0
	dec SoundEnvDTimer,x
	bmi UpdateSoundEnvS
	;Output sound volume
	jmp OutputChannel0Volume

UpdateSoundEnvInst:
	;Decrement instrument volume timer, check if 0
	dec SoundInst1Timer,x
	bne UpdateSoundChannel_Exit
	;Output sound volume
	jsr UpdateInstrumentVolume_EntInst
	;If instrument volume 0, exit
	lda $E3
	beq UpdateSoundEnvS_Exit

OutputChannel0Volume:
	;Check if SFX square channel is playing over square 1 channel
	jsr CheckForChannel0
	bcc UpdateSoundChannel_Exit
	;Output sound volume
	jmp OutputSoundVolume

UpdateSoundEnvS:
	;Set mode ($03: Sustain mode)
	lda #$03
	sta SoundEnvMode,x
UpdateSoundEnvS_Exit:
	rts

CheckEnvSEnd:
	;Check for envelope sustain end
	lda SoundTimer,x
	cmp SoundEnvSTimer,x
	rts

UpdateSoundEnvR_Tri:
	;If envelope sustain timer 0, exit
	lda SoundEnvSTimer,x
	beq UpdateSoundEnvS_Exit
	;Clear envelope sustain timer
	lda #$00
	sta SoundEnvSTimer,x
	sta TRI_LINEAR
	beq UpdateSoundEnvS_Exit
UpdateSoundEnvR:
	;Check for triangle channel
	cpx #$02
	beq UpdateSoundEnvR_Tri
	;Set mode ($04: Release mode)
	lda #$04
	sta SoundEnvMode,x
	lda #$02
	sta $E2
	;Check for echo enabled flag
	lda SoundEchoFlags,x
	and #SFE_ENABLE
	beq UpdateSoundEnvR_NoEcho
	;If echo amount >= $07, don't update echo
	lda SoundEchoAmount,x
	cmp #$07
	bcc UpdateSoundEnvR_Echo
	;Check for echo updated flag
	lda SoundEchoFlags,x
	and #SFE_UPDATE
	beq UpdateSoundEnvR_NoEcho
	;Output echo buffer
	jsr OutputEchoBuffer
	;Clear echo updated flag
	lda SoundEchoFlags,x
	and #~SFE_UPDATE
	sta SoundEchoFlags,x
	jmp UpdateSoundEnvR_NoEcho
UpdateSoundEnvR_Echo:
	;Update echo buffer and output
	jsr UpdateEchoBuffer
	jsr OutputEchoBufferOffs
UpdateSoundEnvR_NoEcho:
	;Get note duty
	jsr GetNoteDuty
	;Check if echo duty is different
	lda SoundEchoDuty,x
	and #$0C
	lsr
	lsr
	beq UpdateSoundEnvR_NoEchoDuty
	sta SoundOutVol,x
	;Output sound volume
	jmp OutputChannel0Volume
UpdateSoundEnvR_NoEchoDuty:
	;Decrement envelope release timer, check if 0
	dec SoundEnvRTimer,x
	bne ResetEnvRTimer_Exit
	;Decrement sound volume
	lda SoundEnvRMultiplier,x
	bne UpdateSoundEnvR_EnvRC
	lda #$01
UpdateSoundEnvR_EnvRC:
	sta $E2
	lda SoundOutVol,x
	jsr DecSoundVolume
	;Reset envelope release timer
	jsr ResetEnvRTimer
	;If underflow, increment volume
	lda SoundOutVol,x
	bpl UpdateSoundEnvR_VolC
	beq UpdateSoundEnvR_VolC
	inc SoundOutVol,x
	rts
UpdateSoundEnvR_VolC:
	;Output sound volume
	jmp OutputChannel0Volume

ResetEnvRTimer:
	;Reset envelope release timer
	lda SoundEnvSRData,x
	lsr
	lsr
	lsr
	lsr
	sta SoundEnvRTimer,x
ResetEnvRTimer_Exit:
	rts

OutputEchoBufferOffs:
	;Check for echo updated flag
	lda SoundEchoFlags,x
	and #SFE_UPDATE
	beq ResetEnvRTimer_Exit
	;Check for echo outputted flag
	lda SoundEchoFlags,x
	ora #SFE_OUTPUT
	sta SoundEchoFlags,x
	;Output echo buffer
	jsr OutputEchoBufferOffsSub
	;Clear echo updated flag
	ldx SoundCurChannel
	lda SoundEchoFlags,x
	and #~SFE_UPDATE
	sta SoundEchoFlags,x
	rts

OutputEchoBufferOffsSub:
	;Get echo buffer offset
	sec
	lda SoundEchoOffset,x
	sbc SoundEchoAmount,x
	sta $E2
	bcs OutputEchoBufferOffsSub_NoC
	clc
	lda #$04
	adc $E2
	sta $E2
OutputEchoBufferOffsSub_NoC:
	;Check for square 2 channel
	lda $E2
OutputEchoBufferOffsSub_EntNoOffs:
	cpx #$01
	bne OutputEchoBufferOffsSub_NoSq2
	clc
	adc #$04
OutputEchoBufferOffsSub_NoSq2:
	tax

OutputEchoBuffer:
	;Check if echo buffer is empty
	lda SoundEchoBufferHi,x
	cmp #$FF
	beq OutputEchoBuffer_NoEcho
	;Get frequency from echo buffer
	sta $EE
	lda SoundEchoBufferLo,x
	sta $ED
	;Output sound pitch
	ldx SoundCurChannel
	jsr OutputSoundPitch
	rts
OutputEchoBuffer_NoEcho:
	;Check for square 2 channel
	lda #$00
	ldx SoundCurChannel
	jmp OutputEchoBufferOffsSub_EntNoOffs

DecSoundVolume:
	;Decrement sound volume
	sec
	sbc $E2
	bcs DecSoundVolume_NoC
	lda #$00
DecSoundVolume_NoC:
	sta SoundOutVol,x
	rts

UpdateSoundChannel_SE_Next:
	iny
UpdateSoundChannel_SE:
	;Check for command byte $00 (rest)
	lda (TempSoundDataPointer),y
	bne UpdateSoundChannel_SE_NoRest
	;Set SFX channel rest output
	lda #$00
	sta SoundOutVol,x
	lda SoundBaseLength,x
	sta SoundTimer,x
	jmp UpdateSoundChannel_SE_EntRest
UpdateSoundChannel_SE_NoRest:
	;Check for command byte $01-$0F (set base length)
	cmp #$10
	bcc UpdateSoundChannel_SE_SetBaseLen
	;Check for command byte $10-$E7 (note command)
	cmp #$E8
	bcc UpdateSoundChannel_SE_Note
	;Check for command byte $FB-$FF
	cmp #$FB
	bcc UpdateSoundChannel_SE_Cmd
	jmp SoundCommandFx
UpdateSoundChannel_SE_Cmd:
	;Check for command byte $E8-$EF
	cmp #$F0
	bcs UpdateSoundChannel_SE_Note
	;Check for SFX noise channel
	cpx #$05
	beq UpdateSoundChannel_SE_Note
	;Do jump table
	sec
	sbc #$C1
	jmp UpdateSoundChannel_CommandJump
UpdateSoundChannel_SE_SetBaseLen:
	;Set base length
	sta SoundBaseLength,x
	;Check for SFX noise channel
	cpx #$05
	beq UpdateSoundChannel_SE_Next
	;Output sound sweep
	iny
	lda (TempSoundDataPointer),y
	sta SoundDuty,x
	jsr OutputSoundSweep
	jmp UpdateSoundChannel_SE_Next
UpdateSoundChannel_SE_Note:
	;Set timer
	lda SoundBaseLength,x
	sta SoundTimer,x
	;Check for SFX noise channel
	cpx #$05
	bne UpdateSoundChannel_SE_Sq
	jmp UpdateSoundChannel_SE_Noise
UpdateSoundChannel_SE_Sq:
	;Set sound volume
	lda (TempSoundDataPointer),y
	lsr
	lsr
	lsr
	lsr
	sta SoundVol,x
	;Check for SFX noise channel
	cpx #$05
	beq UpdateSoundChannel_SE_NoiseFreq
	;If volume 0, don't repeat frequency
	lda SoundVol,x
	beq UpdateSoundChannel_SE_NoRepeat
	;Check for repeat flag
	lda SoundControlFlags2,x
	and #SF2_REPEAT
	bne UpdateSoundChannel_SE_NoRepeat
	;Set frequency
	lda (TempSoundDataPointer),y
	and #$0F
	ora #$08
	sta SoundFreqHi,x
	sta $EE
	iny
	lda (TempSoundDataPointer),y
	sta SoundFreqLo,x
	sta $ED
UpdateSoundChannel_SE_NoRepeat:
	;Get note volume
	lda SoundVol,x
	beq UpdateSoundChannel_SE_NoVol
	jsr GetNoteVolume
UpdateSoundChannel_SE_EntRest:
	;Save Y register
	sty $E3
	;Output sound volume
	ldy SoundOutIndex
	lda SoundOutVol,x
UpdateSoundChannel_SE_NoVol:
	ora SoundDuty,x
	sta SQ1_VOL,y
	;Check for repeat flag
	lda SoundControlFlags2,x
	and #SF2_REPEAT
	beq UpdateSoundChannel_SE_NoRepeat2
	;Get sound frequency
	lda SoundFreqLo,x
	sta $ED
	lda SoundFreqHi,x
	sta $EE
	lda (TempSoundDataPointer),y
	and #$0F
	beq UpdateSoundChannel_SE_NoPitchSet
UpdateSoundChannel_SE_NoRepeat2:
	;Update sound pitch
	jsr UpdateSoundPitch
	;Output sound pitch
	lda $ED
	sta SQ1_LO,y
	lda $EE
	and #$07
	cmp SoundOutFreqHi,x
	bne UpdateSoundChannel_SE_NoPitchRepeat
	;Check for sweep flag
	lda SoundControlFlags1,x
	and #SF1_SWEEP
	beq UpdateSoundChannel_SE_NoPitchSet
	lda $EE
UpdateSoundChannel_SE_NoPitchRepeat:
	ora #$08
	sta SQ1_HI,y
	and #$07
	sta SoundOutFreqHi,x
UpdateSoundChannel_SE_NoPitchSet:
	;Restore Y register
	ldy $E3
	jmp IncSoundPointer
UpdateSoundChannel_SE_Noise:
	;Set sound volume
	lda (TempSoundDataPointer),y
	lsr
	lsr
	lsr
	lsr
	sta SoundOutVol,x
UpdateSoundChannel_SE_NoiseFreq:
	;Set frequency
	lda (TempSoundDataPointer),y
	and #$0F
	sta SoundFreqLo,x
	sta $ED
	lda #$08
	sta $EE
	lda #$30
	sta SoundDuty,x
	bne UpdateSoundChannel_SE_EntRest

;$EC: Set repeat flag
SoundCommandEC_SE:
	;Set repeat flag
	lda SoundControlFlags2,x
	ora #SF2_REPEAT
	sta SoundControlFlags2,x
	jmp UpdateSoundChannel_NextByte

;$ED: Set fade amount
SoundCommandED_SE:
	;Set fade amount
	iny
	lda (TempSoundDataPointer),y
	sta SoundFade,x
	jmp UpdateSoundChannel_NextByte

;$EA: Set sweep
SoundCommandEA_SE:
	;Set sweep
	jsr OutputSoundSweep
	jmp UpdateSoundChannel_NextByte

OutputSoundSweep:
	;Set sweep flag
	lda SoundControlFlags1,x
	ora #SF1_SWEEP
	sta SoundControlFlags1,x
	;Check if sweep value $88 (sweep disabled)
	iny
	lda (TempSoundDataPointer),y
	cmp #$88
	bne OutputSoundSweep_Sweep
	;Clear sweep flag
	lda SoundControlFlags1,x
	and #(~SF1_SWEEP)&$FF
	sta SoundControlFlags1,x
	;Disable sweep
	lda #$7F
OutputSoundSweep_Sweep:
	;Set sweep register
	ldx SoundOutIndex
	sta SQ1_SWEEP,x
	ldx SoundCurChannel
	rts
	rts

SoundCommandNote_NoNoise:
	;Clear rest flag
	lda SoundControlFlags1,x
	and #~SF1_REST
	sta SoundControlFlags1,x
	;Get note length
	jsr GetNoteLength
	;Get note frequency
	jsr GetNoteFrequency
	lda $E2
	sta SoundFreqLo,x
	sta $ED
	lda $E3
	sta SoundFreqHi,x
	sta $EE
	;Init echo buffer
	jsr InitEchoBuffer
	;Init instrument pitch
	jsr InitInstrumentPitch
	;Update sound pitch
	jsr UpdateSoundPitch
SoundCommandNote_EntRest:
	;Check for rest flag
	jsr IncSoundPointer
	dey
	lda SoundControlFlags1,x
	and #SF1_REST
	bne SoundCommandNote_Rest
	;Output sound pitch
	jsr OutputSoundPitch
	;Check for triangle channel
	cpx #$02
	beq SoundCommandNote_Tri
	;Update instrument volume
	jsr UpdateInstrumentVolume
	;Get note duty
	lda #$01
	sta $E2
	jsr GetNoteDuty
SoundCommandNote_Rest:
	;Output sound volume
	jsr CheckForChannel0
	bcc SoundCommandNote_Exit
	jmp OutputSoundVolume
SoundCommandNote_Tri:
	;Set triangle sound registers
	lda SoundOutFreqHi,x
	sta TRI_HI
	lda #$90
	sta TRI_LINEAR
	lda SoundEnvSMultiplier,x
	cmp #$10
	bcc SoundCommandNote_Exit
	sec
	sbc #$10
	sta TRI_LINEAR
SoundCommandNote_Exit:
	rts

UpdateSoundPitch:
	;If pitch bend 0, exit
	lda SoundPitch,x
	beq UpdateSoundPitch_Exit
	;Check for shifting pitch down
	and #$0F
	sta $E2
	lda SoundPitch,x
	cmp #$80
	bcs UpdateSoundPitch_Down
	;Shift pitch up
	sec
	lda $ED
	sbc $E2
	sta $ED
	lda $EE
	sbc #$00
	sta $EE
UpdateSoundPitch_Exit:
	rts
UpdateSoundPitch_Down:
	;Shift pitch down
	clc
	lda $ED
	adc $E2
	sta $ED
	lda $EE
	adc #$00
	sta $EE
	rts

InitInstrumentPitch:
	;Check for instrument pitch flag
	lda SoundInstrumentFlags,x
	and #SFI_INST2
	beq UpdateSoundPitch_Exit
	lda SoundInstrumentFlags,x
	and #SFI_INST2
	beq InitInstrumentPitch_Exit
	;Set instrument pitch frequency
	lda SoundFreqLo,x
	sta SoundInst2FreqLo,x
	lda SoundFreqHi,x
	sta SoundInst2FreqHi,x
	;Check for triangle channel
	cpx #$02
	beq InitInstrumentPitch_Tri
	;Check for echo outputted flag
	lda SoundEchoFlags,x
	and #SFE_OUTPUT
	bne InitInstrumentPitch_Exit
InitInstrumentPitch_Tri:
	;Clear instrument pointers/counters
	lda #$00
	sta SoundInst2RepeatCounter,x
	sta SoundInst2Pointer,x
	;Multiply instrument pitch timer start value by SoundBaseLength
	lda SoundInst2Multiplier,x
	lsr
	lsr
	lsr
	lsr
	sta $E2
	beq InitInstrumentPitch_Clear
	lda #$00
InitInstrumentPitch_Loop:
	clc
	adc SoundBaseLength,x
	dec $E2
	bne InitInstrumentPitch_Loop
	beq InitInstrumentPitch_Set
InitInstrumentPitch_Exit:
	rts
InitInstrumentPitch_Clear:
	;Clear instrument pitch timer start
	lda #$00
InitInstrumentPitch_Set:
	;Set instrument pitch timer start
	sty $E2
	sta SoundInst2TimerStart,x
	;Update instrument pitch
	lda SoundInst2TimerStart,x
	beq UpdateInstrumentPitch
	bne InitInstrumentPitch_Exit

UpdateInstrumentPitch:
	;Get instrument pitch pointer
	lda SoundInst2,x
	tax
	lda InstrumentPitchPointerTable,x
	sta $E4
	lda InstrumentPitchPointerTable+1,x
	sta $E5
	ldx SoundCurChannel

UpdateSoundInstrument:
	;Save Y register
	sty $E2
UpdateSoundInstrument_NextByte:
	;Check for command byte $FB-$FF
	ldy SoundInst2Pointer,x
	lda ($E4),y
	cmp #$FB
	bcc UpdateSoundInstrument_NoCmd
	;Check for command byte $FB (loop begin)
	beq UpdateSoundInstrument_FB
	;Check for command byte $FE (loop end)
	cmp #$FE
	bcc UpdateSoundInstrument_NoCmd
	beq UpdateSoundInstrument_FE
	;Handle command byte $FF (return)
	lda #$00
	sta $E3
	sta SoundInst2Pointer,x
	rts
UpdateSoundInstrument_NoCmd:
	;Set instrument timer
	lsr
	lsr
	lsr
	lsr
	sta SoundInst2Timer,x
	;Set instrument value
	lda ($E4),y
	and #$0F
	sta $E3
	;Check for instrument pitch
	cpx #$03
	bcc UpdateSoundInstrument_Pitch
	rts
UpdateSoundInstrument_Pitch:
	;Check for shifting pitch down
	lda $E3
	cmp #$08
	bcc UpdateSoundInstrument_NoDown
	;Shift pitch down
	lda #$10
	sbc $E3
	sta $E3
UpdateSoundInstrument_NoDown:
	;Multiply instrument pitch
	jsr MultiplyInstrumentPitch
	;Apply instrument pitch
	lda ($E4),y
	and #$08
	beq ApplyInstrumentPitch
	jmp ApplyInstrumentPitch_Down
UpdateSoundInstrument_FB:
	;Handle command byte $FB (loop begin)
	iny
	tya
	sta SoundInst2RepeatPointer,x
	sta SoundInst2Pointer,x
	jmp UpdateSoundInstrument_NextByte
UpdateSoundInstrument_FE:
	;Handle command byte $FE (loop end)
	lda SoundInst2RepeatCounter,x
	beq UpdateSoundInstrument_Init
	cmp #$FF
	bne UpdateSoundInstrument_CheckLoop
UpdateSoundInstrument_Init:
	iny
	lda ($E4),y
	sta SoundInst2RepeatCounter,x
	lda SoundInst2RepeatPointer,x
	sta SoundInst2Pointer,x
	dec SoundInst2RepeatCounter,x
	lda SoundInst2RepeatCounter,x
	beq UpdateSoundInstrument_NoLoop
	cmp #$FE
	beq UpdateSoundInstrument_Infin
UpdateSoundInstrument_Next:
	ldy SoundInst2Pointer,x
	jmp UpdateSoundInstrument
UpdateSoundInstrument_Infin:
	inc SoundInst2RepeatCounter,x
	bne UpdateSoundInstrument_Next
UpdateSoundInstrument_CheckLoop:
	dec SoundInst2RepeatCounter,x
	beq UpdateSoundInstrument_NoLoop
	lda SoundInst2RepeatPointer,x
	sta SoundInst2Pointer,x
	ldy SoundInst2Pointer,x
	jmp UpdateSoundInstrument
UpdateSoundInstrument_NoLoop:
	iny
	iny
	tya
	sta SoundInst2Pointer,x
	ldy SoundInst2Pointer,x
	lda #$00
	sta SoundInst2RepeatCounter,x
	jmp UpdateSoundInstrument

MultiplyInstrumentPitch:
	;Set instrument pitch
	lda SoundInst2Multiplier,x
	and #$0F
	sta $E6
	lda #$00
MultiplyInstrumentPitch_Loop:
	clc
	adc $E3
	sta SoundInst2Pitch,x
	dec $E6
	bne MultiplyInstrumentPitch_Loop
	lda SoundInst2Multiplier,x
	and #$0F
	sta $E6
	rts

ApplyInstrumentPitch:
	;Shift pitch up
	sec
	lda SoundInst2FreqLo,x
	sbc SoundInst2Pitch,x
	sta $ED
	lda SoundInst2FreqHi,x
	sbc #$00
	sta $EE
	jmp ApplyInstrumentPitch_RestY
ApplyInstrumentPitch_Down:
	;Shift pitch down
	lda SoundInst2FreqLo,x
	adc SoundInst2Pitch,x
	sta $ED
	lda SoundInst2FreqHi,x
	adc #$00
	sta $EE
ApplyInstrumentPitch_RestY:
	;Restore Y register
	ldy $E2
ApplyInstrumentPitch_Exit:
	rts

InitEchoBuffer:
	;Check for triangle channel
	cpx #$02
	beq ApplyInstrumentPitch_Exit
	;Check for echo enabled flag
	lda SoundEchoFlags,x
	and #SFE_ENABLE
	beq InitEchoBuffer_Exit
	;Clear echo updated/outputted flags
	lda SoundEchoFlags,x
	and #~SFE_OUTPUT
	ora #SFE_UPDATE
	sta SoundEchoFlags,x
	lda SoundEchoAmount,x
	lda SoundEchoFlags,x
	and #~(SFE_OUTPUT|SFE_UPDATE)
	sta SoundEchoFlags,x
	;Init echo timer
	lda #$01
	sta SoundEchoTimer,x
	;Update echo buffer
	jsr UpdateEchoBuffer
InitEchoBuffer_Exit:
	rts

UpdateEchoBuffer:
	;Decrement echo timer, check if 0
	dec SoundEchoTimer,x
	bne UpdateEchoBuffer_Exit
	;Reset echo timer
	lda SoundBaseLength,x
	sta SoundEchoTimer,x
	;Set echo updated flag
	lda SoundEchoFlags,x
	lda SoundEchoFlags,x
	ora #SFE_UPDATE
	sta SoundEchoFlags,x
	;Increment echo buffer offset
	lda SoundEchoOffset,x
	cmp #$03
	bne UpdateEchoBuffer_NoC
	lda #$FF
	sta SoundEchoOffset,x
UpdateEchoBuffer_NoC:
	inc SoundEchoOffset,x
	;Check for square 2 channel
	lda SoundEchoOffset,x
	cpx #$01
	bne UpdateEchoBuffer_NoSq2
	clc
	adc #$04
UpdateEchoBuffer_NoSq2:
	;Set frequency to echo buffer
	sta $E6
	lda SoundFreqLo,x
	ldx $E6
	sta SoundEchoBufferLo,x
	ldx SoundCurChannel
	lda SoundFreqHi,x
	ldx $E6
	sta SoundEchoBufferHi,x
	ldx SoundCurChannel
UpdateEchoBuffer_Exit:
	rts

OutputSoundPitch:
	;Check for square 1 channel
	ldy SoundOutIndex
	cpx #$00
	bne OutputSoundPitch_NoSq1
	;Output sound pitch
	lda $ED
	sta SoundSq1OutFreqLo
OutputSoundPitch_NoSq1:
	lda $EE
	cmp SoundOutFreqHi,x
	beq OutputSoundPitch_PitchRepeat
	ldx SoundCurChannel
	sta SoundOutFreqHi,x
	sta $E2
	;Check if SFX square channel is playing over square 1 channel
	jsr CheckForChannel0
	bcc UpdateEchoBuffer_Exit
	;Set square sound registers
	lda #$7F
	sta SQ1_SWEEP,y
	lda $E2
	ora #$08
	sta SQ1_HI,y
OutputSoundPitch_PitchRepeat:
	;Check if SFX square channel is playing over square 1 channel
	jsr CheckForChannel0
	bcc UpdateEchoBuffer_Exit
	;Set square sound registers
	lda $ED
	sta SQ1_LO,y
	rts

CheckForChannel0:
	;Check for square 1 channel
	cpx #$00
	bne CheckForChannel0_Exit
	;Check for SFX square channel sound ID
	lda SoundID+4
	beq CheckForChannel0_Exit
	;Clear carry flag
	clc
CheckForChannel0_Exit:
	rts

OutputSoundVolume:
	;Save Y register
	sty $E6
	;Check for rest flag
	lda SoundControlFlags1,x
	and #SF1_REST
	beq OutputSoundVolume_NoRest
	;Set volume to 0
	lda #$00
	beq OutputSoundVolume_NoEcho
OutputSoundVolume_NoRest:
	;Subtract fade volume
	lda SoundOutVol,x
	beq OutputSoundVolume_VolZ
	sec
	sbc SoundFade,x
	beq OutputSoundVolume_VolC
	bcs OutputSoundVolume_VolZ
OutputSoundVolume_VolC:
	;If underflow, set volume to 1
	lda #$01
OutputSoundVolume_VolZ:
	cmp SoundEchoVol,x
	bcs OutputSoundVolume_NoEcho
	lda SoundEchoVol,x
OutputSoundVolume_NoEcho:
	;Subtract fade volume
	sec
	sbc SoundFadeout
	bcs OutputSoundVolume_Set
	;If underflow, set volume to 0
	lda #$00
OutputSoundVolume_Set:
	;Set square sound registers
	ora SoundOutDuty,x
	ldy SoundOutIndex
	ora #$30
	sta SQ1_VOL,y
	;Get note duty
	jsr GetNoteDuty_SetDuty
	;Restore Y register
	ldy $E6
	rts

GetNoteLength:
	;Get note length
	lda (TempSoundDataPointer),y
	and #$0F
	sta $E2
	bne GetNoteLength_NoLen10
	lda #$10
	sta $E2
GetNoteLength_NoLen10:
	lda #$00
GetNoteLength_Loop:
	clc
	adc SoundBaseLength,x
	dec $E2
	bne GetNoteLength_Loop
	sta SoundTimer,x
	;Check for triangle channel
	cpx #$02
	beq GetNoteLength_Tri
	;Check for noise channel
	bcs GetNoteVolume_Exit
	;Clear envelope hold timer
	lda #$00
	sta SoundEnvHTimer,x
	;Apply tie length to note length
	jsr ApplyTieLength
	;Check for rest flag
	lda SoundControlFlags1,x
	and #SF1_REST
	bne GetNoteVolume_Exit
	;Set envelope mode
	lda SoundInstrumentFlags,x
	and #$03
	sta SoundEnvMode,x
	;Init envelope decay timer
	lda SoundEnvHDData,x
	and #$0F
	sta SoundEnvDTimer,x
GetNoteLength_Tri:
	;Get envelope sustain length
	jsr GetNoteEnvSLength
	sta SoundEnvSTimer,x
	;Check for triangle channel
	cpx #$02
	bne GetNoteVolume
	rts

GetNoteVolume:
	;Get note volume
	lda SoundFade,x
	sta $E2
	cpx #$04
	bcs GetNoteVolume_SetVol
	lda SoundInstrumentFlags,x
	and #SFI_INST1
	beq GetNoteVolume_SetVol
	bne GetNoteVolume_Exit
GetNoteVolume_SetVol:
	lda SoundVol,x
	sta SoundOutVol,x
GetNoteVolume_Exit:
	rts

GetNoteEnvSLength:
	;Get note envelope sustain length
	lda SoundEnvSMultiplier,x
	beq GetNoteEnvSLength_Exit
	sta $E4
	lda #$00
	sta $E2
	sta $E3
GetNoteEnvSLength_Loop:
	dec $E4
	bmi GetNoteEnvSLength_End
	clc
	lda $E2
	adc SoundTimer,x
	sta $E2
	bcc GetNoteEnvSLength_NoC
	inc $E3
GetNoteEnvSLength_NoC:
	jmp GetNoteEnvSLength_Loop
GetNoteEnvSLength_End:
	lsr
	lsr
	lsr
	lsr
	sta $E2
	lda $E3
	asl
	asl
	asl
	asl
	ora $E2
GetNoteEnvSLength_Exit:
	ldx SoundCurChannel
	rts

GetNoteFrequency:
	;Convert note number to frequency table index
	lda (TempSoundDataPointer),y
	and #$F0
	sec
	sbc #$10
	sta $E3
	lda #$00
	sta $E2
	lda SoundOctave,x
	sta $E4
GetNoteFrequency_OctLoop:
	lda $E4
	beq GetNoteFrequency_OctEnd
	clc
	lda $E2
	adc #$0C
	sta $E2
	dec $E4
	jmp GetNoteFrequency_OctLoop
GetNoteFrequency_OctEnd:
	;Check for pitch shift
	lda SoundPitchShift,x
	and #$0F
	sta $E4
	beq GetNoteFrequency_NoPS
	;Check for shifting pitch down
	lda SoundPitchShift,x
	cmp #$80
	bcs GetNoteFrequency_Down
	;Shift pitch up
	clc
	lda $E2
	adc $E4
	bne GetNoteFrequency_SetPS
GetNoteFrequency_Down:
	;Shift pitch down
	sec
	lda $E2
	sbc $E4
GetNoteFrequency_SetPS:
	sta $E2
GetNoteFrequency_NoPS:
	;Get frequency table index
	lda $E3
	lsr
	lsr
	lsr
	lsr
	clc
	adc $E2
	asl
	tax
	;Get note frequency
	lda FrequencyTable,x
	sta $E2
	lda FrequencyTable+1,x
	sta $E3
	ldx SoundCurChannel
GetNoteFrequency_Exit:
	rts

GetNoteDuty:
	;Get note duty
	lda SoundEchoDuty,x
	and $E2
	beq GetNoteDuty_SetDuty
	lda SoundEchoDuty,x
	and #$F0
	bne GetNoteDuty_SetDutyA
GetNoteDuty_SetDuty:
	lda SoundDuty,x
GetNoteDuty_SetDutyA:
	sta SoundOutDuty,x
	rts

;$0x: Rest
SoundCommand0x:
	;Set rest flag
	lda SoundControlFlags1,x
	ora #SF1_REST
	sta SoundControlFlags1,x
	;Get note length
	jsr GetNoteLength
	;Check for triangle/noise channels
	cpx #$02
	bcs SoundCommand0x_NoSq
	jmp SoundCommandNote_EntRest
SoundCommand0x_NoSq:
	jsr IncSoundPointer
	;Check for triangle channel
	cpx #$02
	bne SoundCommand0x_Exit
	;Clear triangle sound registers
	jmp SoundCommandFF_Tri
SoundCommand0x_Exit:
	rts

UpdateInstrumentVolume:
	;Check for envelope instrument volume mode
	lda SoundEnvMode,x
	cmp #$01
	bne GetNoteFrequency_Exit
	;Clear instrument pointers/counters
	lda #$FF
	sta SoundInst1Pointer,x
UpdateInstrumentVolume_EntInst:
	;Get instrument volume pointer
	lda SoundInst1,x
	tax
	lda InstrumentVolumePointerTable,x
	sta $E4
	lda InstrumentVolumePointerTable+1,x
	sta $E5
	;Update sound instrument
	sec
	ldx SoundCurChannel
	inc SoundInst1Pointer,x
	inx
	inx
	inx
	jsr UpdateSoundInstrument
	;Restore X/Y registers
	ldy $E2
	ldx SoundCurChannel
	;Set volume
	lda $E3
	beq UpdateInstrumentVolume_Exit
	sta SoundOutVol,x
	beq UpdateInstrumentVolume_Exit
UpdateInstrumentVolume_Exit:
	rts

;$Dx: Set fade amount
SoundCommandDx:
	;Set fade amount
	lda (TempSoundDataPointer),y
	and #$0F
	sta SoundFade,x
	jmp UpdateSoundChannel_NextByte

;$E4: Set instrument volume
SoundCommandE4:
	;Set mode ($00: Hold/decay mode)
	lda #$00
	sta SoundEnvMode,x
	;Check for instrument volume or envelope
	iny
	lda (TempSoundDataPointer),y
	cmp #$80
	bcs SoundCommandE4_EnvSR
	;Set instrument volume
	jsr SetInstrumentVolumeSub
	jmp UpdateSoundChannel_NextByte
SoundCommandE4_EnvSR:
	;Set envelope hold/decay settings
	sta SoundEnvHDData,x
	and #$0F
	sta SoundEnvDTimer,x
	lda SoundInstrumentFlags,x
	and #$FC
	sta SoundInstrumentFlags,x
	jmp UpdateSoundChannel_NextByte

GetSoundByte:
	;Get sound data byte
	iny
	lda (TempSoundDataPointer),y
	rts

SoundCommandEx:
	;Check for command byte $EF (set tempo)
	lda (TempSoundDataPointer),y
	and #$0F
	cmp #$0F
	bne SoundCommandEx_NoEF
	;Handle command byte $EF (set tempo)
	jmp SoundCommandEF
SoundCommandEx_NoEF:
	;Do jump table
	clc
	adc #$04
	jmp UpdateSoundChannel_CommandJump

SetInstrumentVolumeSub:
	;Set instrument volume
	lda (TempSoundDataPointer),y
	asl
	sta SoundInst1,x
	lda SoundInstrumentFlags,x
	ora #SFI_INST1
	sta SoundInstrumentFlags,x
	rts

;$E0: Set instrument
SoundCommandE0:
	;Set octave
	iny
	lda (TempSoundDataPointer),y
	lsr
	lsr
	lsr
	lsr
	beq SoundCommandE0_NoO
	sta SoundOctave,x
SoundCommandE0_NoO:
	;Set base length
	lda (TempSoundDataPointer),y
	and #$0F
	sta SoundBaseLength,x
	;Do jump table
	clc
	txa
	adc #$1D
	jmp UpdateSoundChannel_CommandJump

;$E1: Set base length
SoundCommandE1:
	;Set base length
	iny
	lda (TempSoundDataPointer),y
	sta SoundBaseLength,x
	jmp UpdateSoundChannel_NextByte

;$E2: Set duty
SoundCommandE2:
	;Check to set echo or normal duty
	iny
	lda (TempSoundDataPointer),y
	beq SoundCommandE2_Echo
	and #$0F
	beq SoundCommandE2_NoEcho
	lda (TempSoundDataPointer),y
SoundCommandE2_Echo:
	;Set echo duty
	sta SoundEchoDuty,x
	jmp UpdateSoundChannel_NextByte
SoundCommandE2_NoEcho:
	;Set normal duty
	lda (TempSoundDataPointer),y
	sta SoundDuty,x
	jmp UpdateSoundChannel_NextByte

;$E3: Set volume
SoundCommandE3:
	;Check for triangle channel
	cpx #$02
	beq SoundCommandE3_Tri
	;Set echo volume
	iny
	lda (TempSoundDataPointer),y
	lsr
	lsr
	lsr
	lsr
	sta SoundEchoVol,x
	;Set normal volume
	lda (TempSoundDataPointer),y
	and #$0F
	sta SoundVol,x
	jmp UpdateSoundChannel_NextByte
SoundCommandE3_Tri:
	;Set envelope sustain note length multiplier
	jmp SoundCommandInstrument_Tri

;$E7: Set instrument pitch
SoundCommandE7:
	;Set instrument pitch flag
	lda SoundInstrumentFlags,x
	ora #SFI_INST2
	sta SoundInstrumentFlags,x
	;Set instrument pitch
	lda #$00
	sta SoundInst2Timer,x
	sec
	iny
	lda (TempSoundDataPointer),y
	beq SoundCommandE7_NoInst2
	sbc #$50
	asl
	sta SoundInst2,x
	iny
	lda (TempSoundDataPointer),y
	sta SoundInst2Multiplier,x
	beq SoundCommandE7_NoInst2
	jmp UpdateSoundChannel_NextByte
SoundCommandE7_NoInst2:
	;Clear instrument pitch
	lda #$00
	sta SoundInst2Pointer,x
	sta SoundInst2,x
	sta SoundInst2Timer,x
	;Clear instrument pitch flag
	lda SoundInstrumentFlags,x
	and #~SFI_INST2
	sta SoundInstrumentFlags,x
	jmp UpdateSoundChannel_NextByte

;$EA: Set echo settings
SoundCommandEA:
	;Clear echo buffer
	jsr ClearEchoBuffer
	;Set echo enabled flag
	lda SoundEchoFlags,x
	ora #SFE_ENABLE
	sta SoundEchoFlags,x
	;Init echo offset
	lda #$FF
	sta SoundEchoOffset,x
	;Set echo amount
	iny
	lda (TempSoundDataPointer),y
	sta SoundEchoAmount,x
	;If echo amount 0, clear echo enabled flag
	bne SoundCommandEA_Echo
	lda #$00
	sta SoundEchoFlags,x
SoundCommandEA_Echo:
	jmp UpdateSoundChannel_NextByte

;$E8: Set pitch shift
SoundCommandE8:
	;Set pitch shift
	iny
	lda (TempSoundDataPointer),y
	sta SoundPitchShift,x
	jmp UpdateSoundChannel_NextByte

;$E9: Set pitch bend
SoundCommandE9:
	;Set pitch bend
	iny
	lda (TempSoundDataPointer),y
	sta SoundPitch,x
	jmp UpdateSoundChannel_NextByte

;$EF: Set tempo
SoundCommandEF:
	;Set tempo
	iny
	lda (TempSoundDataPointer),y
	sta SoundTempoReload
	sta SoundTempoTimer
	jmp UpdateSoundChannel_NextByte

SoundCommandInstrument_Sq_Inst:
	;Set fade amount
	dey
	lda (TempSoundDataPointer),y
	and #$0F
	sta SoundFade,x
	;Set mode ($01: Instrument volume mode)
	lda #$01
	sta SoundEnvMode,x
	;Set instrument volume
	iny
	lda (TempSoundDataPointer),y
	jsr SetInstrumentVolumeSub
	;Set envelope sustain/release settings
	jmp SoundCommandE5
SoundCommandInstrument_Sq:
	;Set duty
	iny
	lda (TempSoundDataPointer),y
	and #$F0
	sta SoundDuty,x
	;Check for envelope or instrument volume
	iny
	lda (TempSoundDataPointer),y
	and #$80
	beq SoundCommandInstrument_Sq_Inst
	;Set envelope
	dey
	lda (TempSoundDataPointer),y
	and #$0F
	sta SoundVol,x
	;Set envelope hold/decay settings
	iny
	lda (TempSoundDataPointer),y
	sta SoundEnvHDData,x
	and #$0F
	sta SoundEnvDTimer,x
	;Set mode ($00: Hold/decay mode)
	lda #$00
	sta SoundEnvMode,x
	;Clear instrument volume flag
	lda SoundInstrumentFlags,x
	and #~SFI_INST1
	sta SoundInstrumentFlags,x

;$E5: Set envelope S/R settings
SoundCommandE5:
	;Set envelope sustain/release settings
	iny
	lda (TempSoundDataPointer),y
	sta SoundEnvSRData,x
	lsr
	lsr
	lsr
	lsr
	sta SoundEnvRTimer,x
	lda (TempSoundDataPointer),y
	and #$0F
	sta SoundEnvSMultiplier,x
	jmp UpdateSoundChannel_NextByte

SoundCommandInstrument_Tri:
	;Set envelope sustain note length multiplier
	lda #$00
	sta SoundEnvSMultiplier,x
	iny
	lda (TempSoundDataPointer),y
	beq SoundCommandInstrument_Noise
	sta SoundEnvSMultiplier,x

SoundCommandInstrument_Noise:
	;Do nothing
	jmp UpdateSoundChannel_NextByte

SoundCommandNote_Noise:
	;Get note length
	jsr GetNoteLength
	;Clear rest flag
	lda SoundControlFlags1+3
	and #~SF1_REST
	sta SoundControlFlags1+3
	;Check for DMC patch
	lda (TempSoundDataPointer),y
	lsr
	lsr
	lsr
	lsr
	sec
	sbc #$01
	pha
	jsr IncSoundPointer
	pla
	tax
	lda NoiseSoundIDTable,x
	cmp #$73
	bcs SoundCommandNote_DMC
	;Load sound
	ldx SoundCurChannel
	jmp LoadSoundSub
NoiseSoundIDTable:
	.db SE_CLOSEDHHAT
	.db SE_CLOSEDHHAT
	.db SE_OPENHHAT
	.db SE_MIDCRASHNOISE
	.db SE_SNARENOISE
	.db SE_HICRASHNOISE
	.db DMC_HITOM
	.db DMC_MIDTOM
	.db DMC_LOTOM
	.db SE_LOCRASHNOISE
	.db DMC_SNARE
	.db DMC_BASS

SoundCommandNote_DMC:
	sta $E2
	;Check for boss death sound effect
	cmp #DMC_BOSSDEATH0
	bcs SoundCommandNote_DMCBossDeath
	;Check for player hurt sound effect
	cmp #DMC_VAMPIREHURT
	beq SoundCommandNote_DMCPlayerHurt
	cmp #DMC_MONSTERHURT
	beq SoundCommandNote_DMCPlayerHurt
	;If DMC sample timer not 0, exit
	lda SoundDMCTimer
	beq SoundCommandNote_DMCBossDeath
	bne SoundCommandNote_DMCExit
SoundCommandNote_DMCPlayerHurt:
	;Init DMC sample timer
	lda #$20
	sta SoundDMCTimer
SoundCommandNote_DMCBossDeath:
	;Get DMC instrument table offset
	lda $E2
	sec
	sbc #$73
	asl
	asl
	sty $E2
	tay
	;Disable DMC output
	lda #$0F
	sta SND_CHN
	;Init DMC sound registers state
	lda DMCInstrumentTable,y
	sta DMC_FREQ
	lda DMCInstrumentTable+1,y
	sta DMC_RAW
	lda DMCInstrumentTable+2,y
	sta DMC_START
	lda DMCInstrumentTable+3,y
	sta DMC_LEN
	;Enable DMC output
	lda #$1F
	sta SND_CHN
	ldy $E2
SoundCommandNote_DMCExit:
	rts

;$F6: Tie
SoundCommandF6:
	;Increment tie length
	lda SoundBaseLength,x
	asl
	asl
	asl
	asl
	sta $E2
	clc
	adc SoundTieTimer,x
	sta SoundTieTimer,x
	jmp UpdateSoundChannel_NextByte

ApplyTieLength:
	;Check for triangle/noise channels
	cpx #$02
	bcs ApplyTieLength_Exit
	;Check for tie
	lda SoundTieTimer,x
	beq ApplyTieLength_Exit
	;Apply tie length to note length and clear
	clc
	adc SoundTimer,x
	sta SoundTimer,x
	lda #$00
	sta SoundTieTimer,x
ApplyTieLength_Exit:
	rts

;$Fx: Set octave
SoundCommandFx:
	;Check for command byte $F6 (tie)
	lda (TempSoundDataPointer),y
	and #$0F
	cmp #$06
	beq SoundCommandF6
	;Check for command byte $F0-$F5 (set octave)
	bcc SoundCommandFx_SetO
	;Do jump table
	iny
	clc
	adc #$04
	jmp UpdateSoundChannel_CommandJump
SoundCommandFx_SetO:
	;Set octave
	sta SoundOctave,x
	jmp UpdateSoundChannel_NextByte

;$FB: Loop begin
SoundCommandFB:
	;Set loop flag
	lda SoundControlFlags2,x
	ora #SF2_LOOP
	sta SoundControlFlags2,x
	;Setup sound data pointers
	tya
	clc
	adc TempSoundDataPointer
	sta SoundRepeatPtrLo,x
	lda #$00
	adc TempSoundDataPointer+1
	sta SoundRepeatPtrHi,x
	jmp UpdateSoundChannel_GetByte

;$FE: Loop end
SoundCommandFE_DoInfin:
	;Setup sound data pointers
	iny
	lda (TempSoundDataPointer),y
	sta SoundRepeatPtrLo,x
	iny
	lda (TempSoundDataPointer),y
	sta SoundRepeatPtrHi,x
SoundCommandFE_DoLoop:
	;Setup sound data pointers
	lda SoundRepeatPtrLo,x
	sta TempSoundDataPointer
	lda SoundRepeatPtrHi,x
	sta TempSoundDataPointer+1
	ldy #$00
	jmp UpdateSoundChannel_GetByte
SoundCommandFE:
	;Check for infinite loop
	lda (TempSoundDataPointer),y
	cmp #$FF
	beq SoundCommandFE_DoInfin
	;Check for end of loop
	inc SoundRepeatCounter,x
	cmp SoundRepeatCounter,x
	bne SoundCommandFE_DoLoop
	;Clear loop flag
	lda SoundControlFlags2,x
	and #~SF2_LOOP
	sta SoundControlFlags2,x
	;Clear loop counter
	lda #$00
	sta SoundRepeatCounter,x
	jmp UpdateSoundChannel_NextByte

;$FD: Call
SoundCommandFD:
	;Setup sound data pointers
	lda (TempSoundDataPointer),y
	pha
	iny
	lda (TempSoundDataPointer),y
	pha
	jsr IncSoundPointer
	lda SoundPointerLo,x
	sta SoundReturnPtrLo,x
	lda SoundPointerHi,x
	sta SoundReturnPtrHi,x
	pla
	sta SoundPointerHi,x
	pla
	sta SoundPointerLo,x
	;Set in subroutine flag
	lda SoundControlFlags2,x
	ora #SF2_INSUB
	sta SoundControlFlags2,x
	ldy #$00
	jmp UpdateSoundChannel_NextCmd

;$FC: Return
SoundCommandFC:
	;Clear in subroutine flag
	lda SoundControlFlags2,x
	and #~SF2_INSUB
	sta SoundControlFlags2,x
	;Setup sound data pointers
	lda SoundReturnPtrLo,x
	sta SoundPointerLo,x
	lda SoundReturnPtrHi,x
	sta SoundPointerHi,x
	jmp UpdateSoundChannel_NextCmd

;$FF: Return/end
SoundCommandFF:
	;Check for in subroutine flag
	lda SoundControlFlags2,x
	and #SF2_INSUB
	bne SoundCommandFC
	;Clear sound ID
	lda #$00
	sta SoundID,x
	;Do jump table
	txa
	clc
	adc #$21
	jmp UpdateSoundChannel_CommandJump

SoundCommandFF_Sq:
	;Check if SFX square channel is playing over square 1 channel
	jsr CheckForChannel0
	bcc SoundCommandFF_Noise
	;Save Y register
	sty $E2
	;Clear square sound registers
	lda #$30
	ldy SoundOutIndex
	sta SQ1_VOL,y
	lda #$7F
	sta SQ1_SWEEP,y
	;Restore X/Y registers
	ldx SoundCurChannel
	ldy $E2
	rts

SoundCommandFF_Tri:
	;Clear triangle sound registers
	lda #$00
	sta TRI_LINEAR
	;Check for rest flag
	lda SoundControlFlags1,x
	and #SF1_REST
	bne SoundCommandFF_Noise
	;Clear triangle sound registers
	lda #$0B
	sta SND_CHN
	lda #$0F
	sta SND_CHN
	rts

SoundCommandFF_Noise:
	;Do nothing
	rts

SoundCommandFF_SESq:
	;Clear square sound registers
	jsr SoundCommandFF_Sq
	;If sound paused, exit
	lda SoundPausedFlag
	bne SoundCommandFF_SESq_Exit
	;Check for looping SFX
	lda SoundLoopingID
	beq SoundCommandFF_SESq_NoLoad
	;Check for level 4 elevator sound effects
	lda SoundLoopingID
	cmp #SE_LEVEL4ELEV
	beq SoundCommandFF_SESq_Load18
	cmp #SE_LEVEL4ELEVSLOW
	beq SoundCommandFF_SESq_Load19
	;Check for level 6 crusher sound effect
	cmp #SE_LEVEL6CRUSHERMOVE
	beq SoundCommandFF_SESq_Load5B
	;Check for level 4 crane sound effect
	cmp #SE_LEVEL4CRANE
	beq SoundCommandFF_SESq_Load16
SoundCommandFF_SESq_Load5B:
	;Reload sound effect
	lda #SE_LEVEL6CRUSHER
	bne SoundCommandFF_SESq_Load
SoundCommandFF_SESq_Load16:
	;Reload sound effect
	lda #SE_LEVEL4CRANELOOP
	bne SoundCommandFF_SESq_Load
SoundCommandFF_SESq_Load18:
	;Reload sound effect
	lda #SE_LEVEL4ELEVLOOP
	bne SoundCommandFF_SESq_Load
SoundCommandFF_SESq_Load19:
	;Reload sound effect
	lda #SE_LEVEL4ELEVSLOWLOOP
SoundCommandFF_SESq_Load:
	;Load sound
	jmp LoadSoundSub
SoundCommandFF_SESq_NoLoad:
	;Output sound
	jsr UpdateSoundPause_Sq1
	ldx #$04
SoundCommandFF_SESq_Exit:
	rts

SoundCommandFF_SENoise:
	;Clear noise sound registers
	lda #$30
	sta NOISE_VOL
	rts

IncSoundPointer:
	;Increment sound data pointer
	lda TempSoundDataPointer+1
	iny
	tya
	clc
	adc TempSoundDataPointer
	sta SoundPointerLo,x
	lda TempSoundDataPointer+1
	adc #$00
	sta SoundPointerHi,x
	rts

SoundCommandJumpTable:
	;$00
	.dw SoundCommand0x	;$0x  Rest
	.dw SoundCommandDx	;$Dx  Set fade amount
	.dw SoundCommandEx
	.dw SoundCommandFx
SoundCommandExJumpTable:
	;$04
	.dw SoundCommandE0	;$E0  Set instrument
	.dw SoundCommandE1	;$E1  Set base length
	.dw SoundCommandE2	;$E2  Set duty
	.dw SoundCommandE3	;$E3  Set volume
	.dw SoundCommandE4	;$E4  Set instrument volume
	.dw SoundCommandE5	;$E5  Set envelope S/R settings
	.dw SoundCommandE0	;$E6
	.dw SoundCommandE7	;$E7  Set instrument pitch
	.dw SoundCommandE8	;$E8  Set pitch shift
	.dw SoundCommandE9	;$E9  Set pitch bend
	.dw SoundCommandEA	;$EA  Set echo settings
SoundCommandFxJumpTable:
	;$0F
	.dw SoundCommandFB	;$FB  Loop begin
	.dw SoundCommandFC	;$FC  Return
	.dw SoundCommandFD	;$FD  Call
	.dw SoundCommandFE	;$FE  Loop end
	.dw SoundCommandFF	;$FF  Return/end
SoundEnvelopeJumpTable:
	;$14
	.dw UpdateSoundEnvHD	;$00  Hold/decay mode
	.dw UpdateSoundEnvInst	;$01  Instrument volume mode
	.dw SoundCommandE4	;$02  ??? (pointer not used)
	.dw UpdateSoundEnvS	;$03  Sustain mode
	.dw UpdateSoundEnvR	;$04  Release mode
SoundPauseJumpTable:
	;$19
	.dw UpdateSoundPause_NoChange	;Unpaused -> Unpaused
	.dw UpdateSoundPause_Pause	;Unpaused -> Paused
	.dw UpdateSoundPause_Unpause	;Paused   -> Unpaused
	.dw UpdateSoundPause_NoChange	;Paused   -> Paused
SoundCommandInstrumentJumpTable:
	;$1D
	.dw SoundCommandInstrument_Sq
	.dw SoundCommandInstrument_Sq
	.dw SoundCommandInstrument_Tri
	.dw SoundCommandInstrument_Noise
SoundCommandFFJumpTable:
	;$21
	.dw SoundCommandFF_Sq
	.dw SoundCommandFF_Sq
	.dw SoundCommandFF_Tri
	.dw SoundCommandFF_Noise
	.dw SoundCommandFF_SESq
	.dw SoundCommandFF_SENoise
SoundCommandExSEJumpTable:
	;$27
	.dw SoundCommandE1	;$E8  Set base length
	.dw SoundCommandE2	;$E9  Set duty
	.dw SoundCommandEA_SE	;$EA  Set sweep
	.dw SoundCommandE9	;$EB  Set pitch bend
	.dw SoundCommandEC_SE	;$EC  Set repeat flag
	.dw SoundCommandED_SE	;$ED  Set fade amount
	.dw SoundCommandEF	;$EE  Set tempo
FrequencyTable:
	.dw $06AE,$064E,$05F4,$059E,$054E,$0501,$04B9,$0476,$0436,$03F9,$03C0,$038A
	.dw $0357,$0327,$02FA,$02CF,$02A7,$0281,$025D,$023B,$021B,$01FD,$01E0,$01C5
	.dw $01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$00FE,$00F0,$00E2
	.dw $00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097,$008F,$0087,$007F,$0077,$0071
	.dw $006B,$0065,$005F,$0059,$0055,$0050,$004B,$0047,$0043,$0040,$003B,$0039
	.dw $0035,$0032,$0030,$002C,$002A,$0028,$0025,$0024,$0021,$0020,$001D,$001B
SoundHeaderTablePointer:
	.dw SoundHeaderTable-3

LoadSoundSub:
	;Check for sound effect
	sta SoundLoadID
	cmp #$73
	bcc LoadSoundSub_SE
	;Check for DMC
	cmp #$7D
	bcs LoadSoundSub_Music
	jmp SoundCommandNote_DMC
LoadSoundSub_SE:
	;Check for level 4 elevator sound effects
	lda SoundLoadID
	cmp #SE_LEVEL4ELEV
	beq LoadSoundSub_SetLoopSE
	cmp #SE_LEVEL4ELEVSLOW
	beq LoadSoundSub_SetLoopSE
	;Check for level 4 crane sound effect
	cmp #SE_LEVEL4CRANE
	beq LoadSoundSub_SetLoopSE
	;Check for level 6 crusher sound effects
	cmp #SE_LEVEL6CRUSHERMOVE
	beq LoadSoundSub_SetLoopSE
	cmp #SE_LEVEL6CRUSHER
	beq LoadSoundSub_SetLoopSE
	;Check for loop end sound effect
	cmp #SE_LOOPEND
	beq LoadSoundSub_ClearLoopSE
	;Check for level 4 elevator stop sound effect
	cmp #SE_LEVEL4ELEVSTOP
	beq LoadSoundSub_ClearLoopSE
	bne LoadSoundSub_Music
LoadSoundSub_ClearLoopSE:
	;Clear looping sound effect ID
	lda #$00
	beq LoadSoundSub_SetSESq
LoadSoundSub_SetLoopSE:
	;Set looping sound effect ID
	lda SoundLoadID
LoadSoundSub_SetSESq:
	sta SoundLoopingID
LoadSoundSub_Music:
	;Get sound header pointer
	lda SoundHeaderTablePointer
	sta $EA
	lda SoundHeaderTablePointer+1
	sta $EB
	lda #$03
	sta $EC
LoadSoundSub_MultLoop:
	lda SoundLoadID
	clc
	adc $EA
	sta $EA
	lda #$00
	adc $EB
	sta $EB
	dec $EC
	bne LoadSoundSub_MultLoop
	;Get number of channels
	ldy #$00
	lda ($EA),y
	lsr
	lsr
	lsr
	lsr
	sta $EC
LoadSoundSub_Loop:
	;Get current channel
	lda ($EA),y
	and #$0F
	tax
	;If not level music, skip priority check
	lda SoundLoadID
	cmp #$A5
	bcs LoadSoundSub_NoPri
	;If select sound effect, skip priority check
	cmp #SE_SELECT
	beq LoadSoundSub_NoPri
	;Check if playing equal priority sound
	cmp SoundID,x
	beq LoadSoundSub_PriZ
	;If playing higher priority sound, continue
	bcs LoadSoundSub_NoPri
	;If playing lower priority sound, exit
	bcc LoadSoundSub_PriC
LoadSoundSub_PriZ:
	;If not water drop sound effect, skip priority check
	cmp #SE_WATERDROP
	bne LoadSoundSub_NoPri
LoadSoundSub_PriC:
	iny
	iny
	jmp LoadSoundSub_Exit
LoadSoundSub_NoPri:
	;Get sound pointers
	iny
	lda ($EA),y
	sta SoundPointerLo,x
	sta $E8
	iny
	lda ($EA),y
	sta SoundPointerHi,x
	sta $E9
	;Init common state variables
	lda #$0F
	sta SoundOutFreqHi,x
	lda #$00
	sta SoundRepeatCounter,x
	sta SoundControlFlags2,x
	lda #$01
	sta SoundTimer,x
	;Check for noise channel
	cpx #$03
	beq LoadSoundSub_Noise
	;Check for SFX channel
	bcs LoadSoundSub_Tri
	;Init square/tri-only state variables
	lda #$00
	sta SoundInst2RepeatCounter,x
	sta SoundInst2Timer,x
	sta SoundInstrumentFlags,x
	sta SoundPitchShift,x
	;Check for triangle channel
	cpx #$02
	beq LoadSoundSub_Tri
	;Init square-only state variables
	sta SoundTieTimer,x
	sta SoundPitch,x
	sta SoundFade,x
	sta SoundEnvMode,x
	sta SoundTempoReload
	sta SoundTempoTimer
	sta SoundEchoDuty,x
	sta SoundEchoFlags,x
	;Clear echo buffer
	stx $E3
	jsr ClearEchoBuffer
	ldx $E3
LoadSoundSub_Tri:
	;Init square/tri-only state variables
	lda #$F8
	sta SoundFreqHi,x
LoadSoundSub_Noise:
	;Save Y register
	sty $E2
	;Set sound effect flag
	ldy #$00
	lda ($E8),y
	ldy #SF1_SNDEFF
	;Check for command byte $00-$0F (SFX rest/set base length)
	cmp #$10
	bcc LoadSoundSub_SE2
	;Check for SFX square channel
	cpx #$04
	beq LoadSoundSub_SE2
	;Clear fadeout state
	lda #$00
	sta SoundFadeoutCounter
	sta SoundFadeout
	sta SoundFadeoutTimer
	;Clear sound effect flag
	ldy #$00
LoadSoundSub_SE2:
	tya
	sta SoundControlFlags1,x
	;Restore Y register
	ldy $E2
	;Set ID
	lda SoundLoadID
	sta SoundID,x
	;Go to next channel
	dec $EC
	bmi LoadSoundSub_Exit
	iny
	jmp LoadSoundSub_Loop
LoadSoundSub_Exit:
	rts

ClearSoundSub:
	;Clear sound state
	ldx #$00
	lda #$00
	sta BossDeathSoundFlag
	sta SoundLoopingID
	sta SoundFadeoutCounter
	sta SoundFadeoutTimer
	sta SoundFadeout
ClearSoundSub_ClearIDLoop:
	sta SoundID,x
	inx
	cpx #$06
	bne ClearSoundSub_ClearIDLoop
ClearSoundSub_ClearRegs:
	;Clear sound registers
	lda #$30
	sta SQ1_VOL
	sta SQ2_VOL
	sta NOISE_VOL
	lda #$00
	sta TRI_LINEAR
	rts

ClearEchoBuffer:
	;Check for square 2 channel
	lda #$04
	cpx #$01
	bne ClearEchoBuffer_NoSq2End
	clc
	adc #$04
ClearEchoBuffer_NoSq2End:
	sta $E2
	;Check for square 2 channel
	lda #$00
	cpx #$01
	bne ClearEchoBuffer_NoSq2Start
	clc
	adc #$04
ClearEchoBuffer_NoSq2Start:
	tax
ClearEchoBuffer_Loop:
	;Clear echo buffer
	lda #$FF
	sta SoundEchoBufferLo,x
	sta SoundEchoBufferHi,x
	inx
	cpx $E2
	bne ClearEchoBuffer_Loop
	ldx SoundCurChannel
	rts

;;;;;;;;;;;;
;SOUND DATA;
;;;;;;;;;;;;
;HEADER DATA
SoundHeaderTable:
	;SOUND EFFECTS
	.db $05				;$01  Noise patch (open hi-hat)
	.dw SndEff01Ch5Data		;
	.db $05				;$02  Noise patch (closed hi-hat)
	.dw SndEff02Ch5Data		;
	.db $05				;$03  Noise patch (snare noise)
	.dw SndEff03Ch5Data		;
	.db $05				;$04  Noise patch (mid crash noise)
	.dw SndEff04Ch5Data		;
	.db $05				;$05  Noise patch (high crash noise)
	.dw SndEff05Ch5Data		;
	.db $05				;$06  Noise patch (low crash noise)
	.dw SndEff06Ch5Data		;
	.db $05				;$07  Typing
	.dw SndEff07Ch5Data		;
	.db $14				;$08 \Pocket bulge
	.dw SndEff08Ch4Data		;    |
	.db $05				;$09 /
	.dw SndEff08Ch5Data		;
	.db $14				;$0A \Monster out
	.dw SndEff0ACh4Data		;    |
	.db $05				;$0B /
	.dw SndEff0ACh5Data		;
	.db $04				;$0C  Cursor move
	.dw SndEff0CCh4Data		;
	.db $11				;$0D \Select
	.dw SndEff0DCh1Data		;    |
	.db $04				;$0E /
	.dw SndEff0DCh4Data		;
	.db $14				;$0F \Slope power run
	.dw SndEff0FCh4Data		;    |
	.db $05				;$10 /
	.dw SndEff0FCh5Data		;
	.db $05				;$11  TV static
	.dw SndEff11Ch5Data		;
	.db $10				;$12 \Score up
	.dw SndEff12Ch0Data		;    |
	.db $01				;$13 /
	.dw SndEff12Ch1Data		;
	.db $10				;$14 \Stage clear 1-UP
	.dw SndEff14Ch0Data		;    |
	.db $01				;$15 /
	.dw SndEff14Ch1Data		;
	.db $14				;$16 \Level 4 crane (looping SFX active)
	.dw SndEff16Ch4Data		;    |
	.db $05				;$17 /
	.dw SndEff16Ch5Data		;
	.db $04				;$18  Level 4 elevator (looping SFX active)
	.dw SndEff18Ch4Data		;
	.db $04				;$19  Level 4 elevator slow (looping SFX active)
	.dw SndEff19Ch4Data		;
	.db $05				;$1A  Player jump
	.dw SndEff1ACh5Data		;
	.db $05				;$1B  Player double jump
	.dw SndEff1BCh5Data		;
	.db $05				;$1C  Vampire attack
	.dw SndEff1CCh5Data		;
	.db $05				;$1D  Monster attack
	.dw SndEff1DCh5Data		;
	.db $04				;$1E  BG water scroll
	.dw SndEff1ECh4Data		;
	.db $10				;$1F \Fall start
	.dw SndEff1FCh0Data		;    |
	.db $01				;$20 /
	.dw SndEff1FCh1Data		;
	.db $14				;$21 \Fall land
	.dw SndEff21Ch4Data		;    |
	.db $05				;$22 /
	.dw SndEff21Ch5Data		;
	.db $14				;$23 \Level 1 boss fire
	.dw SndEff23Ch4Data		;    |
	.db $05				;$24 /
	.dw SndEff23Ch5Data		;
	.db $14				;$25 \Enemy death (looping SFX active)
	.dw SndEff25Ch4Data		;    |
	.db $05				;$26 /
	.dw SndEff25Ch5Data		;
	.db $04				;$27  Witch appear
	.dw SndEff27Ch4Data		;
	.db $05				;$28  Roc fly
	.dw SndEff28Ch5Data		;
	.db $04				;$29  Roc drop
	.dw SndEff29Ch4Data		;
	.db $04				;$2A  Level 2 boss fire
	.dw SndEff2ACh4Data		;
	.db $14				;$2B \Player freeze
	.dw SndEff2BCh4Data		;    |
	.db $05				;$2C /
	.dw SndEff2BCh5Data		;
	.db $14				;$2D \Golf ball
	.dw SndEff2DCh4Data		;    |
	.db $05				;$2E /
	.dw SndEff2DCh5Data		;
	.db $14				;$2F \Haniver fire
	.dw SndEff2FCh4Data		;    |
	.db $05				;$30 /
	.dw SndEff2FCh5Data		;
	.db $14				;$31 \Kali fire
	.dw SndEff31Ch4Data		;    |
	.db $05				;$32 /
	.dw SndEff31Ch5Data		;
	.db $04				;$33  Level 4 boss fire
	.dw SndEff33Ch4Data		;
	.db $05				;$34  Chimera fire
	.dw SndEff34Ch5Data		;
	.db $14				;$35 \Cockatrice fire
	.dw SndEff35Ch4Data		;    |
	.db $05				;$36 /
	.dw SndEff35Ch5Data		;
	.db $05				;$37  T-Rex fire
	.dw SndEff37Ch5Data		;
	.db $14				;$38 \Great Beast fire
	.dw SndEff38Ch4Data		;    |
	.db $05				;$39 /
	.dw SndEff38Ch5Data		;
	.db $14				;$3A \Stove flame
	.dw SndEff3ACh4Data		;    |
	.db $05				;$3B /
	.dw SndEff3ACh5Data		;
	.db $14				;$3C \BG cyclops
	.dw SndEff3CCh4Data		;    |
	.db $05				;$3D /
	.dw SndEff3CCh5Data		;
	.db $04				;$3E  Hydra fire
	.dw SndEff3ECh4Data		;
	.db $05				;$3F  Splash
	.dw SndEff3FCh5Data		;
	.db $14				;$40 \Enemy hit
	.dw SndEff40Ch4Data		;    |
	.db $05				;$41 /
	.dw SndEff40Ch5Data		;
	.db $14				;$42 \BG waterfall
	.dw SndEff42Ch4Data		;    |
	.db $05				;$43 /
	.dw SndEff42Ch5Data		;
	.db $04				;$44  Water drop
	.dw SndEff44Ch4Data		;
	.db $14				;$45 \Enemy death
	.dw SndEff45Ch4Data		;    |
	.db $05				;$46 /
	.dw SndEff45Ch5Data		;
	.db $14				;$47 \Item key land
	.dw SndEff47Ch4Data		;    |
	.db $05				;$48 /
	.dw SndEff47Ch5Data		;
	.db $14				;$49 \Item screw land
	.dw SndEff49Ch4Data		;    |
	.db $05				;$4A /
	.dw SndEff49Ch5Data		;
	.db $14				;$4B \Level 3 boss appear
	.dw SndEff4BCh4Data		;    |
	.db $05				;$4C /
	.dw SndEff4BCh5Data		;
	.db $14				;$4D \Level 3 boss hide
	.dw SndEff4DCh4Data		;    |
	.db $05				;$4E /
	.dw SndEff4DCh5Data		;
	.db $14				;$4F \Level 4 crane
	.dw SndEff16Ch4Data		;    |
	.db $05				;$50 /
	.dw SndEff16Ch5Data		;
	.db $14				;$51 \Level 4 crane stop
	.dw SndEff51Ch4Data		;    |
	.db $05				;$52 /
	.dw SndEff51Ch4Data		;
	.db $04				;$53  Level 4 elevator
	.dw SndEff18Ch4Data		;
	.db $04				;$54  Level 4 elevator slow
	.dw SndEff19Ch4Data		;
	.db $14				;$55 \Level 4 elevator stop
	.dw SndEff55Ch4Data		;    |
	.db $05				;$56 /
	.dw SndEff55Ch5Data		;
	.db $14				;$57 \Level 5 boss fire
	.dw SndEff57Ch4Data		;    |
	.db $05				;$58 /
	.dw SndEff57Ch5Data		;
	.db $14				;$59 \Player freeze 2
	.dw SndEff59Ch4Data		;    |
	.db $05				;$5A /
	.dw SndEff59Ch5Data		;
	.db $14				;$5B \Level 6 crusher
	.dw SndEff5BCh4Data		;    |
	.db $05				;$5C /
	.dw SndEff5BCh5Data		;
	.db $14				;$5D \Level 6 crusher move
	.dw SndEff5DCh4Data		;    |
	.db $05				;$5E /
	.dw SndEff5DCh5Data		;
	.db $04				;$5F  Item HP
	.dw SndEff5FCh4Data		;
	.db $20				;$60 \TV static 2
	.dw SndEff60Ch0Data		;    |
	.db $01				;$61 |
	.dw SndEff60Ch1Data		;    |
	.db $05				;$62 /
	.dw SndEff60Ch5Data		;
	.db $14				;$63 \Boss hit
	.dw SndEff63Ch4Data		;    |
	.db $05				;$64 /
	.dw SndEff63Ch5Data		;
	.db $14				;$65 \Level 6 boss fire
	.dw SndEff65Ch4Data		;    |
	.db $05				;$66 /
	.dw SndEff65Ch5Data		;
	.db $04				;$67  Level 7 boss fire
	.dw SndEff67Ch4Data		;
	.db $14				;$68 \Level 7 boss eye flash
	.dw SndEff68Ch4Data		;    |
	.db $05				;$69 /
	.dw SndEff68Ch5Data		;
	.db $20				;$6A \Level 6 boss death
	.dw SndEff6ACh0Data		;    |
	.db $01				;$6B |
	.dw SndEff6ACh1Data		;    |
	.db $05				;$6C /
	.dw SndEff6ACh5Data		;
	.db $20				;$6D \TV static 3
	.dw SndEff6DCh0Data		;    |
	.db $01				;$6E |
	.dw SndEff6DCh1Data		;    |
	.db $05				;$6F /
	.dw SndEff6DCh5Data		;
	.db $04				;$70  1-UP
	.dw SndEff70Ch4Data		;
	.db $04				;$71  Player death
	.dw SndEff71Ch4Data		;
	.db $04				;$72  Pause
	.dw SndEff72Ch4Data		;
	;DMC
	.db $06				;$73  DMC high tom-tom
	.dw DMCInstrumentTable+$00	;
	.db $06				;$74  DMC mid tom-tom
	.dw DMCInstrumentTable+$04	;
	.db $06				;$75  DMC low tom-tom
	.dw DMCInstrumentTable+$08	;
	.db $06				;$76  DMC snare drum
	.dw DMCInstrumentTable+$0C	;
	.db $06				;$77  DMC bass drum
	.dw DMCInstrumentTable+$10	;
	.db $06				;$78  DMC vampire hurt
	.dw DMCInstrumentTable+$14	;
	.db $06				;$79  DMC monster hurt
	.dw DMCInstrumentTable+$18	;
	.db $06				;$7A  DMC boss death 0
	.dw DMCInstrumentTable+$1C	;
	.db $06				;$7B  DMC boss death 1
	.dw DMCInstrumentTable+$20	;
	.db $06				;$7C  DMC boss death 2
	.dw DMCInstrumentTable+$24	;
	;MUSIC
	.db $30				;$7D \Level 1
	.dw Music7DCh0Data		;    |
	.db $01				;$7E |
	.dw Music7DCh1Data		;    |
	.db $02				;$7F |
	.dw Music7DCh2Data		;    |
	.db $03				;$80 /
	.dw Music7DCh3Data		;
	.db $30				;$81 \Level 2
	.dw Music81Ch0Data		;    |
	.db $01				;$82 |
	.dw Music81Ch1Data		;    |
	.db $02				;$83 |
	.dw Music81Ch2Data		;    |
	.db $03				;$84 /
	.dw Music81Ch3Data		;
	.db $30				;$85 \Level 3
	.dw Music85Ch0Data		;    |
	.db $01				;$86 |
	.dw Music85Ch1Data		;    |
	.db $02				;$87 |
	.dw Music85Ch2Data		;    |
	.db $03				;$88 /
	.dw Music85Ch3Data		;
	.db $30				;$89 \Level 4
	.dw Music89Ch0Data		;    |
	.db $01				;$8A |
	.dw Music89Ch1Data		;    |
	.db $02				;$8B |
	.dw Music89Ch2Data		;    |
	.db $03				;$8C /
	.dw Music89Ch3Data		;
	.db $30				;$8D \Level 5
	.dw Music8DCh0Data		;    |
	.db $01				;$8E |
	.dw Music8DCh1Data		;    |
	.db $02				;$8F |
	.dw Music8DCh2Data		;    |
	.db $03				;$90 /
	.dw Music8DCh3Data		;
	.db $30				;$91 \Level 6
	.dw Music91Ch0Data		;    |
	.db $01				;$92 |
	.dw Music91Ch1Data		;    |
	.db $02				;$93 |
	.dw Music91Ch2Data		;    |
	.db $03				;$94 /
	.dw Music91Ch3Data		;
	.db $30				;$95 \Boss
	.dw Music95Ch0Data		;    |
	.db $01				;$96 |
	.dw Music95Ch1Data		;    |
	.db $02				;$97 |
	.dw Music95Ch2Data		;    |
	.db $03				;$98 /
	.dw Music95Ch3Data		;
	.db $30				;$99 \Boss rush (no intro)
	.dw Music99Ch0Data		;    |
	.db $01				;$9A |
	.dw Music99Ch1Data		;    |
	.db $02				;$9B |
	.dw Music99Ch2Data		;    |
	.db $03				;$9C /
	.dw Music99Ch3Data		;
	.db $30				;$9D \Boss rush (with intro)
	.dw Music9DCh0Data		;    |
	.db $01				;$9E |
	.dw Music9DCh1Data		;    |
	.db $02				;$9F |
	.dw Music9DCh2Data		;    |
	.db $03				;$A0 /
	.dw Music9DCh3Data		;
	.db $30				;$A1 \Scene 0
	.dw MusicA1Ch0Data		;    |
	.db $01				;$A2 |
	.dw MusicA1Ch1Data		;    |
	.db $02				;$A3 |
	.dw MusicA1Ch2Data		;    |
	.db $03				;$A4 /
	.dw MusicA1Ch3Data		;
	.db $30				;$A5 \Title
	.dw MusicA5Ch0Data		;    |
	.db $01				;$A6 |
	.dw MusicA5Ch1Data		;    |
	.db $02				;$A7 |
	.dw MusicA5Ch2Data		;    |
	.db $03				;$A8 /
	.dw MusicA5Ch3Data		;
	.db $30				;$A9 \Select
	.dw MusicA9Ch0Data		;    |
	.db $01				;$AA |
	.dw MusicA9Ch1Data		;    |
	.db $02				;$AB |
	.dw MusicA9Ch2Data		;    |
	.db $03				;$AC /
	.dw MusicA9Ch3Data		;
	.db $20				;$AD \Scene 1
	.dw MusicADCh0Data		;    |
	.db $01				;$AE |
	.dw MusicADCh1Data		;    |
	.db $02				;$AF /
	.dw MusicADCh2Data		;
	.db $30				;$B0 \Boss 2
	.dw MusicB0Ch0Data		;    |
	.db $01				;$B1 |
	.dw MusicB0Ch1Data		;    |
	.db $02				;$B2 |
	.dw MusicB0Ch2Data		;    |
	.db $03				;$B3 /
	.dw MusicB0Ch3Data		;
	.db $30				;$B4 \Credits
	.dw MusicB4Ch0Data		;    |
	.db $01				;$B5 |
	.dw MusicB4Ch1Data		;    |
	.db $02				;$B6 |
	.dw MusicB4Ch2Data		;    |
	.db $03				;$B7 /
	.dw MusicB4Ch3Data		;
	.db $30				;$B8 \Clear
	.dw MusicB8Ch0Data		;    |
	.db $01				;$B9 |
	.dw MusicB8Ch1Data		;    |
	.db $02				;$BA |
	.dw MusicB8Ch2Data		;    |
	.db $03				;$BB /
	.dw MusicB8Ch3Data		;
	.db $30				;$BC \Game over
	.dw MusicBCCh0Data		;    |
	.db $01				;$BD |
	.dw MusicBCCh1Data		;    |
	.db $02				;$BE |
	.dw MusicBCCh2Data		;    |
	.db $03				;$BF /
	.dw MusicBCCh3Data		;

;SOUND EFFECT DATA
SndEff02Ch5Data:
	.db $01,$A2,$41,$11
	.db $FF
SndEff01Ch5Data:
	.db $01,$B2,$05,$91,$51,$41,$31,$21
	.db $FF
SndEff03Ch5Data:
	.db $01,$7F,$5D,$38,$26,$16
	.db $FF
SndEff04Ch5Data:
	.db $05,$6B,$5B,$4B,$3B,$2B,$2B,$1B,$1B
	.db $FF
SndEff05Ch5Data:
	.db $05,$89,$79,$69,$59,$49,$39,$29,$19
	.db $FF
SndEff06Ch5Data:
	.db $0A,$CE,$BE,$9E,$8E,$7E,$6E,$5E,$4E
	.db $FF
SndEff07Ch5Data:
	.db $01,$78,$32,$21,$11
	.db $FF
SndEff08Ch4Data:
	.db $05,$B0,$81,$C3,$87,$B2,$34,$A3,$06,$A3,$28,$53,$C8
	.db $FF
SndEff08Ch5Data:
	.db $02,$16,$26,$48,$85,$00,$46,$24
	.db $FF
SndEff0ACh4Data:
	.db $03,$30,$99,$00,$50,$95,$70,$9C,$90,$A8,$B0,$B5,$90,$C0,$70,$C4
	.db $40,$C8,$30,$CC,$20,$CC,$20,$D0,$10,$D4
	.db $FF
SndEff0ACh5Data:
	.db $01,$00,$83,$98,$00,$83,$98,$64,$73,$84,$03,$95,$A6,$C7,$75,$64
	.db $55,$04,$44,$32,$24,$13
	.db $FF
SndEff0CCh4Data:
	.db $02,$B0,$88,$90,$5A,$60,$71,$20,$5A,$10,$71,$00,$30,$5A,$20,$71
	.db $10,$5A,$00,$20,$71,$10,$5A,$10,$71
	.db $FF
SndEff0DCh1Data:
	.db $04,$70,$88,$00
SndEff0DCh4Data:
	.db $04,$70,$88,$80,$7F,$80,$5F,$80,$55,$80,$40,$30,$7F,$30,$5F,$30
	.db $55,$30,$40,$10,$7F,$10,$5F,$10,$55,$10,$40
	.db $FF
SndEff12Ch0Data:
	.db $01,$B0,$88,$50,$97,$20,$97
	.db $FF
SndEff12Ch1Data:
	.db $01,$B0,$88,$50,$7F,$20,$7F
	.db $FF
SndEff14Ch1Data:
	.db $05,$B0,$88,$00
SndEff14Ch0Data:
	.db $05,$B0,$88,$90,$6B,$90,$50,$90,$40,$90,$35,$20,$35,$10,$35
	.db $FF
SndEff1ACh5Data:
	.db $01,$8A,$02,$00,$8A,$03,$77,$64,$53,$04,$43,$31,$23,$11
	.db $FF
SndEff1BCh5Data:
	.db $03,$77,$64,$53,$42,$31,$22,$11
	.db $FF
SndEff1CCh5Data:
	.db $02,$58,$00,$58,$86,$DA,$04,$7C,$67,$39,$3A,$2B,$1A,$1B
	.db $FF
SndEff1DCh5Data:
	.db $01,$B7,$00,$B7,$CA,$DC,$03,$CD,$BB,$02,$68,$37,$28,$17,$16
	.db $FF
SndEff40Ch4Data:
	.db $02,$30,$8A,$E2,$4E,$EA,$8B,$00,$C0,$62,$90,$72,$50,$62,$30,$72
	.db $20,$72,$10,$72
	.db $FF
SndEff40Ch5Data:
	.db $01,$DD,$00,$C7,$00,$02,$A7,$88,$89,$00,$39,$2A,$1B,$1B
	.db $FF
SndEff1FCh1Data:
	.db $07,$B0,$88,$EB,$01
SndEff1FCh0Data:
	.db $07,$B0,$88,$10,$60,$20,$61,$30,$62,$40,$63,$50,$64,$60,$65,$70
	.db $66,$70,$67,$70,$68,$70,$69,$70,$6A,$70,$6B,$70,$6C,$70,$6D,$70
	.db $6E,$70,$6F,$70,$70,$70,$71,$70,$72,$70,$73,$70,$74,$70,$75,$70
	.db $76,$70,$77,$70,$78,$70,$79,$70,$7A,$70,$7B,$70,$7C,$70,$7D,$70
	.db $7E,$70,$7F,$70,$80,$70,$81,$70,$82,$70,$83,$70,$84,$60,$85,$60
	.db $86,$50,$87,$50,$88,$40,$89,$40,$8A,$30,$8B,$30,$8C,$20,$8D,$20
	.db $8E,$10,$8F,$10,$90
	.db $FF
SndEff23Ch4Data:
	.db $01,$30,$88,$E0,$30,$00,$EA,$85,$E0,$30,$00,$C0,$21,$B0,$16,$90
	.db $15,$60,$15,$30,$14,$20,$14,$10,$14
	.db $FF
SndEff23Ch5Data:
	.db $01,$EA,$B9,$00,$02,$B7,$94,$83,$73,$62,$42,$32,$21,$11
	.db $FF
SndEff21Ch4Data:
	.db $01,$70,$81,$A3,$40,$00,$00,$23,$40
	.db $FF
SndEff21Ch5Data:
	.db $01,$D5,$00,$00,$85,$25
	.db $FF
SndEff45Ch4Data:
	.db $03,$B0,$83,$E2,$00,$00,$D1,$90,$B1,$80,$A1,$70,$91,$80,$71,$90
	.db $51,$A0,$41,$B0,$31,$C0,$21,$D0,$11,$D8
	.db $FF
SndEff45Ch5Data:
	.db $01,$9D,$9C,$00,$8C,$00,$03,$9A,$89,$7A,$04,$5B,$4C,$3D,$2E,$1E
	.db $FF
SndEff25Ch4Data:
	.db $03,$B0,$83,$E2,$00,$00,$D1,$90,$B1,$80,$A1,$70,$91,$80,$71,$90
	.db $51,$A0
	.db $FF
SndEff25Ch5Data:
	.db $01,$9D,$9C,$00,$8C,$00,$03,$9A,$89,$7A,$04,$5B,$4C,$02,$3D
	.db $FF
SndEff27Ch4Data:
	.db $07,$B0,$92,$40,$96,$50,$93,$60,$90,$70,$8D,$80,$8A,$90,$87,$A0
	.db $85,$90,$82,$30,$83,$10,$81
	.db $FF
SndEff28Ch5Data:
	.db $02,$58,$77,$96,$02,$73,$64,$45,$26,$15,$16,$15,$26,$15
	.db $FF
SndEff0FCh4Data:
	.db $01,$70,$83,$C3,$00
	.db $FF
SndEff0FCh5Data:
	.db $01,$BC,$43
	.db $FF
SndEff11Ch5Data:
	.db $05,$A6,$00,$0A,$00,$00,$04,$A6,$00,$00,$00,$FB,$A6,$FE,$40
	.db $FF
SndEff29Ch4Data:
	.db $02,$B0,$85,$B0,$CA,$00,$D0,$8A,$B0,$8A,$80,$8A,$00,$70,$8A,$60
	.db $8A,$00,$40,$8A,$30,$8A,$00,$20,$8A,$10,$8A
	.db $FF
SndEff47Ch4Data:
	.db $02,$70,$88,$D0,$2A,$00,$B0,$2A,$E9,$30,$A0,$2A,$00,$80,$27,$70
	.db $27,$60,$27,$50,$27,$40,$27,$30,$27,$E8,$01,$00,$20,$27,$20,$27
	.db $20,$27,$00,$E8,$02,$10,$27,$10,$27
	.db $FF
SndEff47Ch5Data:
	.db $01,$AA,$00,$93,$03,$73,$45,$34,$32,$23,$23,$12,$01,$00,$12
	.db $FF
SndEff49Ch4Data:
	.db $01,$30,$88,$C0,$52,$A0,$B7,$00,$A0,$52,$A0,$B7,$00,$80,$52,$80
	.db $B7,$70,$52,$70,$B7,$60,$52,$60,$B7,$50,$52,$50,$B7,$40,$52,$40
	.db $B7,$30,$52,$30,$B7,$20,$52,$20,$B7,$10,$52,$10,$B7,$10,$52,$10
	.db $B7,$10,$52,$00,$10,$52
	.db $FF
SndEff49Ch5Data:
	.db $01,$EC,$00,$CB,$D8,$C6,$B4,$A8,$03,$74,$43,$32,$33,$22,$21,$12
	.db $FF
SndEff2ACh4Data:
	.db $02,$70,$88,$FB,$C0,$12,$D0,$08,$E0,$14,$E0,$0A,$E0,$13,$E0,$0F
	.db $E0,$14,$E0,$0C,$E0,$12,$FE,$02,$C0,$12,$A0,$08,$70,$14,$50,$0A
	.db $40,$13,$30,$0F,$20,$14,$10,$0C,$10,$12
	.db $FF
SndEff2BCh4Data:
	.db $02,$F0,$88,$D0,$18,$F0,$16,$00,$F0,$15,$E0,$0E,$02,$B0,$88,$00
	.db $F0,$11,$00,$A0,$0F,$00,$80,$11,$50,$0F,$30,$0F,$10,$0F
	.db $FF
SndEff2BCh5Data:
	.db $01,$EC,$00,$EC,$AA,$64,$00,$03,$51,$43,$32,$04,$23,$12,$11
	.db $FF
SndEff2DCh4Data:
	.db $01,$B0,$88,$E1,$79,$00,$B1,$79,$00,$31,$79,$21,$79,$11,$79,$00
	.db $21,$79,$11,$79,$00,$11,$79
	.db $FF
SndEff2DCh5Data:
	.db $01,$BB,$00,$5B,$19,$00,$2C,$1B,$00,$1C,$1B,$00,$1B
	.db $FF
SndEff2FCh4Data:
	.db $04,$70,$8A,$C2,$C6,$00,$52,$E1,$32,$67,$12,$52
	.db $FF
SndEff2FCh5Data:
	.db $05,$8B,$59,$4B,$3C,$2D,$1C
	.db $FF
SndEff3ECh4Data:
	.db $05,$70,$92,$C0,$90,$60,$90,$40,$90,$20,$90,$10,$90
	.db $FF
SndEff3FCh5Data:
	.db $01,$A7,$03,$B5,$00,$03,$A5,$74,$73,$06,$52,$41,$22,$11
	.db $FF
SndEff4BCh4Data:
	.db $02,$B0,$8B,$C2,$00,$00,$E8,$05,$B2,$00,$C2,$00,$D1,$4D,$B1,$36
	.db $A1,$00,$72,$00,$61,$4D,$51,$36,$41,$00,$32,$00,$21,$4D,$11,$36
	.db $11,$00
	.db $FF
SndEff4BCh5Data:
	.db $02,$E1,$00,$EA,$CB,$00,$EA,$CB,$E9,$E8,$E7,$00,$06,$E6,$D5,$C6
	.db $B5,$A6,$85,$07,$66,$55,$36,$25,$16
	.db $FF
SndEff4DCh4Data:
	.db $04,$B0,$8B,$B1,$60,$B1,$80,$81,$C0,$82,$00,$61,$60,$61,$80,$41
	.db $C0,$42,$00,$21,$60,$21,$80,$11,$C0,$12,$00
	.db $FF
SndEff4DCh5Data:
	.db $02,$CA,$05,$83,$B8,$A9,$98,$89,$78,$69,$58,$49,$38,$29,$18,$19
	.db $FF
SndEff42Ch4Data:
	.db $04,$B0,$8B,$C4,$33,$D3,$73,$E1,$70,$A1,$50,$61,$20,$11,$00,$41
	.db $20,$11,$00,$21,$20,$11,$00
	.db $FF
SndEff42Ch5Data:
	.db $03,$E8,$00,$E8,$D7,$00,$E8,$D7,$C6,$B5,$A4,$93,$72,$61,$52,$11
	.db $61,$51,$31,$21,$11
	.db $FF
SndEff1ECh4Data:
	.db $04,$B0,$8B,$31,$50,$71,$20,$51,$00,$31,$20,$E8,$06,$11,$62,$11
	.db $5E
	.db $FF
SndEff16Ch4Data:
	.db $01,$30,$88,$92,$36,$E9,$70,$53,$36,$E9,$30,$91,$DE,$E9,$70,$51
	.db $DE,$E9,$30,$91,$E4,$E9,$70,$51,$E4
	.db $FF
SndEff16Ch5Data:
	.db $02,$4A,$42,$4C
	.db $FF
SndEff51Ch4Data:
	.db $FF
SndEff18Ch4Data:
	.db $02,$30,$88,$62,$E5,$E9,$70,$62,$FA
	.db $FF
SndEff19Ch4Data:
	.db $02,$30,$88,$63,$05,$E9,$70,$63,$1A
	.db $FF
SndEff55Ch4Data:
	.db $02,$70,$82,$FB,$E3,$60,$00,$FE,$03,$E3,$60,$05,$70,$83,$E1,$60
	.db $D1,$60,$B1,$60,$81,$60,$51,$60,$31,$60,$11,$60
	.db $FF
SndEff55Ch5Data:
	.db $03,$FB,$EA,$00,$FE,$03,$06,$B4,$94,$84,$74,$64,$54,$44,$33,$24
	.db $13
	.db $FF
SndEff31Ch4Data:
	.db $02,$30,$89,$00,$00,$80,$60,$91,$90,$A0,$60,$81,$90,$70,$60,$61
	.db $90,$50,$60,$41,$90,$60,$68,$71,$98,$60,$70,$51,$A0,$40,$78,$31
	.db $A8,$20,$80,$11,$B0,$11,$C0
	.db $FF
SndEff31Ch5Data:
	.db $01,$19,$39,$48,$5C,$69,$02,$68,$95,$89,$73,$62,$53,$42,$00,$43
	.db $52,$63,$46,$38,$39,$2A,$28,$1A,$18,$1A
	.db $FF
SndEff33Ch4Data:
	.db $04,$30,$84,$A0,$80,$80,$B0,$60,$E0,$41,$10,$21,$40,$00,$11,$70
	.db $FF
SndEff34Ch5Data:
	.db $03,$56,$07,$CE,$BE,$AE,$9E,$8E,$7E,$6E,$2E,$1E
	.db $FF
SndEff35Ch4Data:
	.db $02,$30,$82,$B0,$3A,$20,$3A,$E8,$03,$A0,$3A,$01,$30,$92,$D0,$16
	.db $D0,$1A,$C0,$16,$C0,$1A,$A0,$16,$A0,$1A,$50,$16,$50,$1A,$30,$16
	.db $30,$1A,$20,$16,$20,$1A,$00,$00,$20,$16,$20,$1A,$10,$16,$10,$1A
	.db $10,$16,$10,$1A
	.db $FF
SndEff35Ch5Data:
	.db $01,$BD,$00,$02,$76,$33,$22,$11,$FB,$22,$23,$FE,$03
	.db $FF
SndEff37Ch5Data:
	.db $02,$55,$66,$00,$01,$7D,$8D,$AB,$CB,$EB,$FA,$EA,$CB,$BB,$AC,$9C
	.db $8D,$07,$8D,$7E,$6E,$5F,$3F,$2F,$1F
	.db $FF
SndEff38Ch4Data:
	.db $01,$30,$9A,$D0,$28,$D0,$28,$FB,$C0,$9E,$C0,$9E,$C0,$4A,$C0,$4A
	.db $FE,$09,$70,$9E,$70,$9E,$50,$4A,$50,$4A,$20,$9E,$20,$9E,$10,$4A
	.db $10,$4A,$10,$9E,$10,$9E,$10,$4A,$10,$4A,$10,$4A,$10,$4A
	.db $FF
SndEff38Ch5Data:
	.db $02,$FB,$6C,$67,$FE,$09,$5C,$47,$3C,$27,$1C,$1B,$1C
	.db $FF
SndEff3ACh4Data:
	.db $03,$F0,$83,$00,$00,$00,$00,$C1,$78,$00,$E8,$07,$C1,$78,$A1,$78
	.db $81,$78,$E8,$08,$62,$10,$42,$10,$22,$40,$12,$10
	.db $FF
SndEff3ACh5Data:
	.db $02,$83,$B3,$D3,$03,$00,$68,$04,$9E,$AD,$9C,$06,$8E,$7E,$6E,$5E
	.db $4E,$3E,$2E,$1E
	.db $FF
SndEff3CCh4Data:
	.db $01,$30,$88,$B3,$10,$00,$83,$10,$42,$20,$22,$20,$12,$20
	.db $FF
SndEff3CCh5Data:
	.db $01,$EE,$00,$02,$E5,$D3,$00,$02,$D1,$C2,$B1,$A1,$72,$51,$31,$21
	.db $11
	.db $FF
SndEff57Ch4Data:
	.db $04,$B0,$8C,$B0,$60,$B0,$70,$B0,$60,$B0,$70,$B0,$50,$50,$60,$50
	.db $70,$50,$50,$30,$60,$30,$70,$30,$50,$10,$60,$10,$70,$10,$50
	.db $FF
SndEff57Ch5Data:
	.db $02,$64,$66,$65,$64,$0A,$53,$34,$15
	.db $FF
SndEff59Ch4Data:
	.db $02,$30,$89,$C3,$20,$00,$33,$20,$00,$00,$00,$43,$20,$00,$13,$20
	.db $FF
SndEff59Ch5Data:
	.db $02,$EA,$00,$E9,$00,$C2,$11,$96,$11,$85,$11,$64,$11,$53,$11,$42
	.db $11,$00,$11,$22,$11
	.db $FF
SndEff44Ch4Data:
	.db $02,$B0,$8B,$70,$4E,$03,$B0,$8A,$00,$60,$C8,$E8,$07,$30,$A9,$10
	.db $85,$10,$50
	.db $FF
SndEff5BCh4Data:
	.db $03,$70,$83,$41,$E0,$41,$20
	.db $FF
SndEff5BCh5Data:
	.db $03,$8E,$8B
	.db $FF
SndEff5DCh4Data:
	.db $04,$70,$83,$FB,$C2,$20,$C1,$20,$FE,$0A
	.db $FF
SndEff5DCh5Data:
	.db $04,$FB,$ED,$EB,$FE,$0A
	.db $FF
SndEff5FCh4Data:
	.db $01,$70,$88,$60,$AA,$80,$AA,$A0,$AA,$E8,$02,$C0,$AA,$D0,$97,$E0
	.db $8F,$D0,$7F,$C0,$71,$B0,$65,$A0,$5F,$80,$AC,$70,$99,$70,$91,$60
	.db $81,$60,$73,$50,$67,$50,$61,$40,$AE,$40,$9B,$30,$95,$30,$83,$20
	.db $75,$20,$69,$10,$63
	.db $FF
SndEff60Ch0Data:
	.db $01,$30,$8A,$40,$A0,$80,$F0,$00,$FB,$C5,$00,$C5,$20,$FE,$03,$00
	.db $00,$FB,$C5,$00,$C5,$20,$FE,$30,$08,$30,$9B,$00,$00,$31,$28,$41
	.db $26,$51,$24,$61,$22,$71,$20,$81,$1E,$91,$1C,$A1,$1A,$81,$18,$61
	.db $16,$41,$14,$21,$12,$11,$10,$11,$10
	.db $FF
SndEff60Ch1Data:
	.db $08,$30,$9B,$FB,$00,$FE,$0D,$31,$20,$41,$20,$51,$20,$61,$20,$71
	.db $20,$81,$1E,$91,$1C,$E8,$07,$A1,$1A,$B1,$18,$C1,$16,$EA,$8C,$D1
	.db $14,$C1,$12,$D1,$10,$C1,$0E,$C1,$0C,$C1,$0A,$A1,$08,$81,$06,$61
	.db $04,$41,$02,$21,$00,$20,$FE,$10,$FC,$10,$FA
	.db $FF
SndEff60Ch5Data:
	.db $01,$32,$62,$00,$08,$FB,$94,$FE,$14,$84,$74,$64,$54,$44,$34,$24
	.db $14
	.db $FF
SndEff65Ch4Data:
	.db $01,$30,$8A,$F0,$38,$F0,$38,$F0,$24,$F0,$24,$F0,$40,$F0,$40,$F0
	.db $24,$F0,$24,$F0,$50,$F0,$50,$F0,$24,$F0,$24,$F0,$70,$F0,$70,$F0
	.db $24,$F0,$24,$F0,$60,$F0,$60,$F0,$24,$F0,$24,$80,$60,$80,$60,$50
	.db $24,$50,$24,$80,$80,$80,$80,$50,$24,$50,$24,$80,$70,$80,$70,$50
	.db $24,$50,$24,$50,$68,$50,$68,$20,$24,$20,$24,$40,$88,$40,$88,$20
	.db $24,$20,$24,$20,$78,$20,$78,$20,$24,$20,$24,$20,$70,$20,$70,$20
	.db $24,$20,$24,$10,$90,$10,$90,$10,$24,$10,$24,$10,$80,$10,$80
	.db $FF
SndEff65Ch5Data:
	.db $01,$EC,$00,$EC,$33,$EE,$00,$07,$EC,$DA,$AD,$7B,$09,$5A,$3C,$2A
	.db $1C
	.db $FF
SndEff67Ch4Data:
	.db $0A,$30,$9C,$31,$20,$41,$20,$51,$20,$61,$20,$71,$20,$81,$1E,$91
	.db $1C,$A1,$1A,$B1,$18,$C1,$16,$D1,$14,$C1,$12,$D1,$10,$C1,$0E,$C1
	.db $0C,$C1,$0A,$A1,$08,$81,$06,$61,$04,$41,$02,$21,$00,$20,$FE,$10
	.db $FC,$10,$FA
	.db $FF
SndEff68Ch4Data:
	.db $01,$B0,$88,$B0,$14,$00,$E8,$03,$B0,$20,$70,$14,$60,$14,$50,$14
	.db $40,$14,$30,$14,$20,$14,$10,$14,$04,$30,$82,$30,$30,$40,$31,$50
	.db $32,$60,$33,$70,$34,$80,$35,$90,$36,$A0,$37,$B0,$38,$C0,$39,$30
	.db $3A,$20,$3B,$10,$3C
	.db $FF
SndEff68Ch5Data:
	.db $01,$C9,$00,$04,$85,$75,$65,$55,$45,$35,$25,$39,$49,$59,$69,$79
	.db $89,$99,$A9,$B9,$C9,$39,$29,$19
	.db $FF
SndEff6ACh1Data:
	.db $01,$70,$81,$00,$EB,$02
SndEff6ACh0Data:
	.db $01,$70,$81,$70,$44,$80,$45,$00,$00,$FB,$70,$44,$80,$45,$B0,$44
	.db $C0,$45,$10,$43,$FE,$1E,$20,$44,$20,$45,$10,$44,$10,$45,$0B,$30
	.db $9A,$F0,$80,$C0,$80,$80,$80,$50,$80,$20,$80,$10,$80
	.db $FF
SndEff6ACh5Data:
	.db $01,$FB,$39,$3A,$39,$3A,$00,$FE,$1E,$28,$2A,$19,$1A,$04,$00,$02
	.db $C8,$88,$08,$57,$44,$33,$22,$12,$12
	.db $FF
SndEff6DCh0Data:
	.db $0F,$70,$88,$FB,$00,$FE,$07,$01,$30,$8A,$FB,$65,$00,$65,$20,$FE
	.db $03,$00,$00,$FB,$65,$00,$65,$20,$FE,$30
	.db $FF
SndEff6DCh1Data:
	.db $08,$30,$8B,$31,$20,$41,$20,$51,$20,$61,$20,$71,$20,$81,$1E,$91
	.db $1C,$E8,$07,$A1,$1A,$B1,$18,$C1,$16,$D1,$14,$C1,$12,$D1,$10,$C1
	.db $0E,$C1,$0C,$C1,$0A,$A1,$08,$81,$06,$61,$04,$41,$02,$21,$00,$20
	.db $FE,$10,$FC,$10,$FA
	.db $FF
SndEff6DCh5Data:
	.db $0F,$FB,$00,$FE,$07,$FB,$99,$FE,$40
	.db $FF
SndEff63Ch4Data:
	.db $02,$30,$8A,$E2,$4E,$00,$E2,$4E,$EA,$8A,$00,$C0,$92,$90,$92,$50
	.db $92,$E8,$01,$30,$90,$20,$8E,$10,$8C,$10,$8C
	.db $FF
SndEff63Ch5Data:
	.db $01,$ED,$00,$D7,$00,$02,$C7,$A8,$99,$00,$59,$3A,$01,$00,$02,$2B
	.db $1B,$1B
	.db $FF
SndEff70Ch4Data:
	.db $01,$B0,$88,$D0,$6B,$A0,$6B,$50,$6B,$30,$6B,$10,$6B,$D0,$50,$A0
	.db $50,$50,$6B,$30,$6B,$10,$6B,$D0,$40,$A0,$40,$50,$50,$30,$50,$10
	.db $50,$D0,$35,$A0,$35,$50,$35,$50,$35,$40,$35,$30,$35,$20,$40,$10
	.db $35,$00,$00,$E8,$05,$20,$6B,$20,$50,$10,$40,$10,$35
	.db $FF
SndEff71Ch4Data:
	.db $04,$70,$93,$70,$6B,$80,$78,$90,$8F,$A0,$A0,$B0,$B4,$C0,$D6,$D0
	.db $69,$D0,$76,$D0,$8D,$D0,$9E,$D0,$B2,$D0,$D4,$90,$67,$90,$74,$90
	.db $8B,$90,$9C,$90,$B0,$90,$D2,$50,$67,$50,$74,$50,$8B,$50,$9C,$50
	.db $B0,$50,$D0,$30,$65,$30,$72,$30,$89,$30,$9A,$30,$AE,$30,$D0,$10
	.db $63,$10,$70,$10,$88,$10,$98,$10,$AC,$10,$CE
	.db $FF
SndEff72Ch4Data:
	.db $05,$82,$88,$10,$D5,$10,$8E,$10,$A9,$02,$B0,$88,$E0,$6A,$D0,$6A
	.db $B0,$6A,$A0,$6A,$90,$6A,$70,$6A,$50,$6A,$40,$6A
	.db $FF

;INSTRUMENT DATA
InstrumentVolumePointerTable:
	.dw InstrumentVol00Data
	.dw InstrumentVol01Data
	.dw InstrumentVol02Data
	.dw InstrumentVol03Data
	.dw InstrumentVol04Data
	.dw InstrumentVol05Data
	.dw InstrumentVol06Data
	.dw InstrumentVol07Data
	.dw InstrumentVol08Data
	.dw InstrumentVol09Data
	.dw InstrumentVol0AData
	.dw InstrumentVol0BData
	.dw InstrumentVol0CData
	.dw InstrumentVol0DData
	.dw InstrumentVol0EData
	.dw InstrumentVol0FData
	.dw InstrumentVol10Data
	.dw InstrumentVol11Data
	.dw InstrumentVol12Data
	.dw InstrumentVol13Data
	.dw InstrumentVol14Data
	.dw InstrumentVol15Data
	.dw InstrumentVol16Data
	.dw InstrumentVol17Data
	.dw InstrumentVol18Data
	.dw InstrumentVol19Data
	.dw InstrumentVol1AData
	.dw InstrumentVol1BData
	.dw InstrumentVol1CData
	.dw InstrumentVol1DData
	.dw InstrumentVol1EData
	.dw InstrumentVol1FData
	.dw InstrumentVol20Data
	.dw InstrumentVol21Data
	.dw InstrumentVol22Data
	.dw InstrumentVol23Data
	.dw InstrumentVol24Data
	.dw InstrumentVol25Data
InstrumentPitchPointerTable:
	.dw InstrumentPitch00Data
	.dw InstrumentPitch01Data
	.dw InstrumentPitch02Data
	.dw InstrumentPitch03Data
	.dw InstrumentPitch04Data
	.dw InstrumentPitch05Data
	.dw InstrumentPitch06Data
	.dw InstrumentPitch07Data
	.dw InstrumentPitch08Data
	.dw InstrumentPitch09Data
	.dw InstrumentPitch0AData
	.dw InstrumentPitch0BData
	.dw InstrumentPitch0CData
	.dw InstrumentPitch0DData
	.dw InstrumentPitch0EData
	.dw InstrumentPitch0FData
	.dw InstrumentPitch10Data
	.dw InstrumentPitch11Data
	.dw InstrumentPitch12Data
	.dw InstrumentPitch13Data
	.dw InstrumentPitch14Data
	.dw InstrumentPitch15Data
	.dw InstrumentPitch16Data
	.dw InstrumentPitch17Data
	.dw InstrumentPitch18Data
	.dw InstrumentPitch19Data
	.dw InstrumentPitch1AData
	.dw InstrumentPitch1BData
	.dw InstrumentPitch1CData
	.dw InstrumentPitch1DData
	.dw InstrumentPitch1EData
	.dw InstrumentPitch1FData
	.dw InstrumentPitch20Data
	.dw InstrumentPitch21Data
	.dw InstrumentPitch22Data
	.dw InstrumentPitch23Data

InstrumentVol00Data:
	.db $FF
InstrumentVol01Data:
	.db $23,$14,$15,$16,$17,$FF
InstrumentVol02Data:
	.db $FF
InstrumentVol03Data:
	.db $1C,$1B,$1A,$19,$17,$15,$12,$11,$FF
InstrumentVol04Data:
	.db $FF
InstrumentVol05Data:
	.db $FF
InstrumentVol06Data:
	.db $11,$12,$13,$24,$75,$76,$77,$78,$FF
InstrumentVol07Data:
	.db $1A,$18,$17,$13,$12,$11,$FF
InstrumentVol08Data:
	.db $FF
InstrumentVol09Data:
	.db $FF
InstrumentVol0AData:
	.db $FF
InstrumentVol0BData:
	.db $FF
InstrumentVol0CData:
	.db $FF
InstrumentVol0DData:
	.db $FF
InstrumentVol0EData:
	.db $FF
InstrumentVol0FData:
	.db $FF
InstrumentVol10Data:
	.db $FF
InstrumentVol11Data:
	.db $FF
InstrumentVol12Data:
	.db $FF
InstrumentVol13Data:
	.db $FF
InstrumentVol14Data:
	.db $FF
InstrumentVol15Data:
	.db $FF
InstrumentVol16Data:
	.db $FF
InstrumentVol17Data:
	.db $FF
InstrumentVol18Data:
	.db $FF
InstrumentVol19Data:
	.db $FF
InstrumentVol1AData:
	.db $FF
InstrumentVol1BData:
	.db $FF
InstrumentVol1CData:
	.db $FF
InstrumentVol1DData:
	.db $FF
InstrumentVol1EData:
	.db $FF
InstrumentVol1FData:
	.db $FF
InstrumentVol20Data:
	.db $FF
InstrumentVol21Data:
	.db $FF
InstrumentVol22Data:
	.db $FF
InstrumentVol23Data:
	.db $FF
InstrumentVol24Data:
	.db $FF
InstrumentVol25Data:
	.db $FF
InstrumentPitch00Data:
	.db $FF
InstrumentPitch01Data:
	.db $1D,$1E,$1F,$10,$FE,$FF
InstrumentPitch02Data:
	.db $FB,$1F,$1E,$1D,$1C,$1B,$FE,$FF
InstrumentPitch03Data:
	.db $FF
InstrumentPitch04Data:
	.db $FF
InstrumentPitch05Data:
	.db $FB,$11,$21,$11,$10,$1F,$1E,$1F,$10,$FE,$FF
InstrumentPitch06Data:
	.db $1C,$1D,$1E,$1F,$10,$FF
InstrumentPitch07Data:
	.db $FB,$4F,$30,$31,$10,$FE,$FF
InstrumentPitch08Data:
	.db $FB,$51,$10,$2F,$20,$FE,$FF
InstrumentPitch09Data:
	.db $FF
InstrumentPitch0AData:
	.db $FF
InstrumentPitch0BData:
	.db $FF
InstrumentPitch0CData:
	.db $FF
InstrumentPitch0DData:
	.db $FF
InstrumentPitch0EData:
	.db $FF
InstrumentPitch0FData:
	.db $FF
InstrumentPitch10Data:
	.db $FB,$11,$12,$11,$10,$1F,$1E,$1F,$1E,$1F,$10,$FE,$FF
InstrumentPitch11Data:
	.db $1A,$1B,$1C,$1D,$1E,$1F,$10,$FF
InstrumentPitch12Data:
	.db $1A,$1B,$1C,$1D,$1E,$1F,$10,$FB,$11,$12,$11,$10,$1F,$1E,$1F,$1E
	.db $1F,$10,$FE,$FF
InstrumentPitch13Data:
	.db $FF
InstrumentPitch14Data:
	.db $FF
InstrumentPitch15Data:
	.db $FF
InstrumentPitch16Data:
	.db $FF
InstrumentPitch17Data:
	.db $FF
InstrumentPitch18Data:
	.db $FF
InstrumentPitch19Data:
	.db $FF
InstrumentPitch1AData:
	.db $FF
InstrumentPitch1BData:
	.db $FF
InstrumentPitch1CData:
	.db $FF
InstrumentPitch1DData:
	.db $FF
InstrumentPitch1EData:
	.db $FF
InstrumentPitch1FData:
	.db $FF
InstrumentPitch20Data:
	.db $FF
InstrumentPitch21Data:
	.db $FF
InstrumentPitch22Data:
	.db $FF
InstrumentPitch23Data:
	.db $FF

;MUSIC DATA
Music7DCh0Data:
	.db $E0,$05,$33,$80,$00,$E8,$01,$E7,$60,$01,$F2,$02
	.db $FD
	.dw Music7DSection0
	.db $E0,$05,$74,$82,$A7,$F3,$84,$82,$74,$72,$44,$E0,$25,$B3,$81,$16
	.db $FB,$31,$41,$51,$61,$71,$61,$51,$41,$FE,$03,$31,$21,$11,$F1,$C1
	.db $B1,$A1,$B1,$A1,$FB,$F2,$31,$41,$51,$61,$71,$61,$51,$41,$FE,$02
	.db $E0,$15,$35,$81,$A7,$E2,$B7,$82,$D1,$82,$F2,$12,$D0,$F1,$A4,$D1
	.db $82,$92,$A2,$E2,$00,$D0
Music7DCh0Data_Loop:
	.db $FD
	.dw Music7DSection2
	.db $E4,$82,$82,$D1,$E2,$70,$F1,$A4,$52,$C4,$C2,$F2,$34,$32,$12,$E1
	.db $03,$31,$11,$E1,$04,$31,$E1,$05,$14,$E4,$83,$52,$72,$82
	.db $FD
	.dw Music7DSection2
	.db $82,$F1,$54,$52,$F0,$C4,$C2,$F1,$14,$F2,$11,$F1,$C1,$F2,$11,$31
	.db $51,$31,$51,$61,$81,$A1,$C1,$F3,$11,$31,$51,$61,$71,$E0,$15,$76
	.db $84,$A7,$E2,$B7,$52,$F2,$52,$F1,$52,$F2,$62,$F1,$62,$62,$F2,$72
	.db $F1,$72,$E2,$00,$E5,$15,$F2,$A2,$F1,$A2,$52,$F2,$A4,$A2,$52,$32
	.db $E2,$B7,$F1,$72,$F2,$72,$F1,$72,$F2,$82,$F1,$82,$82,$F2,$92,$F1
	.db $92,$E2,$00,$E2,$70,$D2,$E4,$81,$02,$F3,$11,$11,$F2,$A2,$F3,$31
	.db $31,$F2,$A2,$F3,$51,$51,$F2,$A2,$F3,$81,$81,$E4,$84,$D0,$E2,$70
	.db $E2,$B7,$F1,$92,$F2,$92,$F1,$92,$F2,$A2,$F1,$A2,$A2,$F2,$B2,$F1
	.db $B2,$E2,$00,$E5,$15,$F2,$A2,$52,$A2,$A4,$A2,$52,$32,$E5,$A6,$82
	.db $72,$52,$74,$52,$34,$C6,$E1,$03,$61,$81,$E1,$04,$A1,$E1,$05,$C8
	.db $E0,$15,$37,$84,$1A,$FB,$D0,$42,$D1,$52,$52,$52,$D0,$42,$D1,$52
	.db $52,$52,$D0,$42,$D1,$52,$52,$54,$D0,$32,$42,$52,$FE,$02
	.db $FE,$FF
	.dw Music7DCh0Data_Loop
Music7DCh1Data:
	.db $E0,$05,$38,$85,$16,$E8,$01,$F2
	.db $FD
	.dw Music7DSection0
	.db $21,$11,$E7,$60,$01,$E4,$82,$E5,$A6,$F3,$12,$42,$72,$14,$A2,$F4
	.db $14,$E0,$25,$38,$83,$17,$FB,$61,$71,$81,$91,$A1,$91,$81,$71,$FE
	.db $03,$61,$51,$41,$31,$21,$31,$21,$11,$FB,$61,$71,$81,$91,$A1,$91
	.db $81,$71,$FE,$02,$E0,$05,$39,$84,$A7,$E2,$B7,$12,$D0,$32,$82,$E5
	.db $A3,$D0,$74,$D1,$E5,$A7,$32,$52,$E2,$00,$E1,$03,$F1,$A1,$F2,$11
	.db $E1,$04,$21,$D0
Music7DCh1Data_Loop:
	.db $FD
	.dw Music7DSection1
	.db $E7,$61,$03,$E4,$84,$E5,$A7,$D0,$E2,$00,$C4,$E7,$60,$44,$A2,$74
	.db $E5,$28,$D0,$82,$D1,$72,$52,$E5,$28,$72,$82,$E1,$03,$71,$81,$E1
	.db $04,$71,$E1,$05,$52,$72,$F1,$A2,$C2,$F2,$12,$D0
	.db $FD
	.dw Music7DSection1
	.db $E2,$00,$E4,$84,$E5,$A7,$F1,$E7,$61,$05,$A4,$A2,$C4,$C2,$E7,$60
	.db $44,$F2,$14,$E4,$87,$E5,$17,$F1,$A1,$81,$A1,$C1,$F2,$11,$F1,$C1
	.db $F2,$11,$31,$51,$61,$81,$A1,$C1,$F3,$11,$31,$41,$E0,$35,$78,$83
	.db $A8,$E2,$31,$E7,$60,$22,$56,$46,$34,$E7,$60,$03,$14,$F2,$E7,$60
	.db $22,$E2,$77,$A2,$F3,$12,$32,$12,$F2,$C2,$A2,$F3,$E2,$00,$E2,$31
	.db $56,$46,$34,$E2,$00,$E5,$28,$11,$11,$F2,$A2,$F3,$31,$31,$F2,$A2
	.db $F3,$51,$51,$F2,$A2,$F3,$81,$81,$F2,$A2,$E0,$05,$79,$83,$28,$F3
	.db $52,$D1,$52,$52,$D0,$42,$D1,$42,$42,$D0,$32,$32,$D1,$E5,$A8,$14
	.db $F2,$E2,$77,$A2,$F3,$12,$32,$12,$F2,$C2,$A2,$E2,$00,$E7,$60,$11
	.db $F3,$52,$32,$12,$34,$12,$F2,$C4,$56,$E1,$03,$C1,$F3,$11,$E1,$04
	.db $31,$E1,$05,$58,$FB,$E0,$15,$37,$85,$16,$D0,$92,$D1,$A2,$A2,$A2
	.db $D0,$92,$D1,$A2,$A2,$A2,$D0,$92,$D1,$A2,$A2,$A4,$D0,$82,$92,$A2
	.db $92,$D1,$A2,$A2,$A2,$D0,$92,$D1,$A2,$A2,$A2,$92,$A2,$A2,$A4,$82
	.db $92,$E0,$05,$39,$84,$E6,$E1,$03,$A1,$F2,$11,$E1,$04,$21
	.db $FE,$FF
	.dw Music7DCh1Data_Loop
Music7DCh2Data:
	.db $E0,$35,$00,$E8,$01
	.db $FD
	.dw Music7DSection0
	.db $21,$11,$F2,$E0,$05,$04,$E7,$60,$04,$12,$42,$72,$14,$A2,$F3,$14
	.db $E7,$00,$E0,$15,$08,$FB,$92,$A2,$A2,$A2,$FE,$02,$92,$A2,$A2,$A4
	.db $82,$92,$A2,$FB,$92,$A2,$A2,$A2,$FE,$02,$A2,$A2,$A2,$C4,$C2,$F2
	.db $12,$12
Music7DCh2Data_Loop:
	.db $FD
	.dw Music7DSection3
	.db $E0,$15,$07,$92,$A2,$A2,$A4,$A2,$A2,$A2,$92,$A2,$A2,$A2,$92,$A2
	.db $A2,$A2,$92,$A2,$A2,$A4,$A2,$B2,$C2
	.db $FD
	.dw Music7DSection3
	.db $E0,$15,$07,$92,$A2,$A2,$A4,$A2,$A2,$A2,$92,$A2,$A2,$A2,$92,$A2
	.db $A2,$A2,$A1,$A1,$A1,$A1,$C1,$C1,$C1,$C1,$F2,$11,$11,$11,$11,$31
	.db $31,$31,$31,$E0,$25,$06,$52,$52,$52,$42,$42,$42,$12,$12,$F1,$E7
	.db $61,$0A,$E0,$05,$06,$A4,$E7,$00,$A2,$C4,$C2,$F2,$12,$12,$52,$52
	.db $52,$42,$42,$42,$12,$12,$A1,$A1,$A2,$C1,$C1,$C2,$F3,$11,$11,$12
	.db $31,$31,$32,$F2,$52,$52,$52,$42,$42,$42,$12,$12,$E7,$61,$06,$A4
	.db $E7,$00,$A2,$C4,$C2,$F3,$12,$12,$F2,$12,$12,$12,$34,$32,$54,$56
	.db $E1,$03,$C1,$F3,$11,$E1,$04,$31,$E0,$05,$03,$54,$E1,$01,$11,$21
	.db $31,$41,$51,$61,$51,$41,$31,$21,$11,$F2,$C1,$B1,$A1,$91,$81,$71
	.db $61,$51,$41
	.db $FD
	.dw Music7DSection6
	.db $FD
	.dw Music7DSection6
	.db $FE,$FF
	.dw Music7DCh2Data_Loop
Music7DCh3Data:
	.db $E0,$05,$00,$81,$81,$72,$72,$C2,$12,$C2,$B2,$12
	.db $FD
	.db $25,$A1
	.db $C2,$12,$B2,$12,$B2,$12,$B2,$12,$91,$91,$82,$82,$72,$C2,$B2,$C2
	.db $C2
	.db $FD
	.db $25,$A1
	.db $FD
	.db $25,$A1
	.db $C2,$12,$B2,$12,$C2,$11,$11,$B2,$11,$11,$B2,$12,$12,$B2,$12,$C2
	.db $B2,$C2,$FB,$C2,$12,$B2,$12,$FE,$03,$91,$91,$92,$81,$81,$72
	.db $FD
	.db $36,$A1
	.db $FD
	.db $36,$A1
	.db $C2,$12,$B2,$12,$C2,$11,$11,$B2,$11,$11,$B2,$12,$12,$B2,$12,$12
	.db $B2,$12,$FB,$C2,$11,$11,$B2,$11,$11,$FE,$02,$91,$91,$91,$91,$81
	.db $81,$81,$81,$71,$71,$71,$71,$B2,$B1,$B1,$B2,$C2,$C2,$B2,$C2,$C2
	.db $B2,$C2,$FB,$12,$C2,$B2,$12,$FE,$02,$B2,$C2,$C2,$B2,$C2,$C2,$B2
	.db $C2,$C2,$C1,$C1,$B2,$11,$11,$C2,$C1,$C1,$81,$81,$72,$B2,$12,$12
	.db $B2,$C2,$C2,$FB,$B2,$12,$FE,$05,$92,$82,$72,$92,$92,$92,$82,$72
	.db $C2,$11,$11,$B2,$11,$11,$B4,$91,$81,$71,$71
	.db $FD
	.db $36,$A1
	.db $FB,$C2,$12,$B2,$12,$FE,$02,$C2,$12,$92,$82,$C2,$92,$82,$72
	.db $FE,$FF
	.db $7C,$9F
Music7DSection0:
	.db $61,$71,$81,$91,$A1,$91,$81,$71,$61,$51,$41,$31,$21,$31
	.db $FF
Music7DSection1:
	.db $E0,$15,$3A,$84,$A8,$E8,$01,$E7,$60,$44,$F2,$38,$E7,$61,$07,$D1
	.db $34,$E7,$60,$44,$F1,$A4,$F2,$12,$F1,$A2,$F2,$12,$D1,$34,$E4,$88
	.db $D0,$F1,$A2,$D1,$F2,$12,$E4,$84,$F1,$A2,$F2,$D0,$E7,$61,$07,$42
	.db $02,$D1,$44,$D0,$32,$D1,$02,$34,$E7,$60,$44,$D2,$12,$F1,$A2,$F2
	.db $12,$D1,$36,$12,$F1,$C2,$A0,$D0,$E0,$25,$39,$85,$B7,$E2,$7A,$E7
	.db $61,$06,$12,$E7,$00,$D1,$F1,$A2,$D0,$F2,$82,$74,$E7,$00,$E5,$1B
	.db $12,$32,$52
	.db $FF
Music7DSection2:
	.db $E0,$15,$36,$84,$18,$E2,$04,$E8,$01,$92,$A2,$A2,$32,$92,$A2,$32
	.db $32,$A2,$32,$92,$A4,$F2,$32,$A2,$32,$D4,$A2,$D0,$E4,$83,$E5,$23
	.db $A2,$92,$D4,$A2,$D0,$82,$D4,$A2,$D0,$64,$86,$66,$F1,$82,$82,$E2
	.db $00,$E0,$25,$76,$85,$19,$E2,$76,$A1,$A1,$11,$D4,$F1,$A1,$F2,$D0
	.db $12,$F1,$A1,$A1,$F2,$11,$D4,$F1,$A1,$D0,$F2,$11,$01,$F1,$A1,$A1
	.db $F2,$11,$D4,$F1,$A1,$D0,$E2,$00,$E0,$15,$36,$83,$A8,$A2,$D1,$52
	.db $D0,$F2,$12,$34,$E7,$00,$E4,$84,$52,$72
	.db $FF
Music7DSection3:
	.db $E0,$25,$07,$FB,$22,$32,$32,$32,$22,$32,$32,$32,$22,$32,$32,$34
	.db $12,$22,$32,$FE,$02,$F1,$92,$A2,$A2,$A2,$92,$A2,$A2,$A2
	.db $FF
Music7DSection4:
	.db $C2,$12,$B2,$12,$C2,$12,$B2,$12,$C2,$12,$B2,$C2,$12,$12,$B2,$12
	.db $FF
Music7DSection5:
	.db $C2,$12,$B2,$12,$C2,$12,$B2,$12,$C2,$12,$B2,$C2,$12,$C2,$B2,$12
	.db $FF
Music7DSection6:
	.db $E0,$15,$07,$FB,$92,$A2,$A2,$A2,$FE,$02,$92,$A2,$A2,$A4,$82,$92
	.db $A2
	.db $FF
Music81Ch0Data:
	.db $E0,$25,$36,$83,$16,$FB,$E2,$B7,$E7,$00,$F2,$81,$81,$01,$81,$72
	.db $82,$08,$E7,$62,$01,$F3,$82,$02,$8C,$FE,$02,$E0,$35,$36,$82,$16
	.db $E7,$00,$11,$11,$01,$11,$F2,$C2,$F3,$12,$08,$E7,$62,$02,$12,$02
	.db $1C,$E0,$25,$37,$83,$16,$E7,$00,$81,$81,$01,$81,$72,$E7,$62,$01
	.db $82,$08,$82,$02,$86,$E5,$1A,$D2,$22,$32,$42,$D0,$E0,$25,$B5,$83
	.db $A6,$E7,$58,$45,$26,$1A,$F1,$B6,$F2,$1A,$04,$72,$72,$82,$82,$E9
	.db $81,$F1,$32,$42,$E2,$30,$F2,$22,$04,$2A,$E9,$00,$E0,$35,$35,$83
	.db $9A,$E2,$00,$B2,$02,$A2,$B2,$E2,$70,$F2,$04,$24,$42,$22,$32,$44
	.db $22,$92,$42,$14,$12,$F1,$B2,$F2,$12,$F1,$44,$72,$E2,$30,$F2,$E5
	.db $18,$41,$41,$72,$82,$42,$81,$81,$42,$22,$12,$E0,$35,$35,$83,$9A
	.db $42,$02,$22,$42,$F2,$04,$24,$02,$E2,$70,$E5,$38,$F2,$42,$D3,$44
	.db $D0,$22,$D3,$22,$D0,$12,$22,$D3,$12,$D0,$42,$24,$E5,$16,$D1,$E1
	.db $07,$61,$41,$E1,$06,$11,$E1,$07,$F1,$B1,$71,$E1,$06,$B1,$E1,$05
	.db $E5,$00,$D2,$B8,$D0,$E5,$16,$21,$41,$71,$91,$B1,$F2,$21,$42,$E0
	.db $25,$77,$85,$66,$D2,$E7,$58,$41,$E2,$31,$52,$62,$62,$F1,$62,$F2
	.db $62,$62,$04,$E2,$00,$F3,$62,$02,$E4,$84,$6A,$02,$E5,$17,$F1,$D0
	.db $B2,$D2,$42,$42,$F2,$D0,$12,$F1,$D2,$42,$42,$F2,$D0,$22,$F1,$D2
	.db $42,$42,$F2,$D0,$12,$F1,$D2,$42,$42,$D0,$B2,$D2,$42,$F2,$D0,$12
	.db $D2,$42,$E2,$31,$E0,$25,$77,$85,$66,$52,$62,$62,$F1,$62,$F2,$62
	.db $62,$04,$E2,$00,$F3,$62,$02,$E4,$84,$6C,$E0,$25,$F6,$84,$A6,$B2
	.db $D1,$B2,$B2,$94,$D0,$42,$D1,$42,$22,$D0,$42,$D1,$42,$42,$D0,$44
	.db $D1,$22,$F1,$D0,$B2,$D1,$92,$D0,$B2,$D1,$92,$B2,$D0,$F2,$22,$D1
	.db $F1,$B2,$D0,$F2,$22,$42,$52,$62,$04,$E5,$C8,$E7,$58,$03,$BA
	.db $FE,$FF
	.dw Music81Ch0Data
Music81Ch1Data:
	.db $FB,$E0,$35,$77,$82,$16,$E2,$B7,$41,$41,$01,$41,$22,$42,$D4,$21
	.db $21,$42,$22,$42,$D0,$E7,$62,$01,$42,$02,$E5,$A6,$E2,$00,$45,$E7
	.db $00,$E2,$B7,$D2,$11,$21,$41,$72,$61,$41,$D0,$FE,$02,$E5,$16,$F3
	.db $91,$91,$01,$91,$82,$92,$D4,$41,$41,$22,$42,$22,$D0,$E7,$62,$01
	.db $92,$02,$E2,$00,$E5,$A6,$94,$E7,$00,$E2,$B7,$D2,$31,$41,$72,$92
	.db $72,$D0,$41,$41,$01,$41,$22,$42,$D4,$21,$21,$42,$22,$42,$D0,$E7
	.db $62,$01,$42,$02,$E2,$00,$46,$E7,$00,$E0,$25,$38,$86,$37,$82,$92
	.db $A2,$E0,$25,$38,$84,$A8,$E7,$58,$22,$E4,$86,$E5,$27,$B2,$A2,$B2
	.db $E5,$A8,$E4,$84,$E7,$62,$02,$94,$E7,$60,$21,$E5,$27,$E4,$87,$72
	.db $42,$E4,$84,$12,$72,$82,$72,$82,$E4,$84,$72,$42,$12,$E7,$58,$01
	.db $E5,$A6,$F6,$42,$F2,$B2,$04,$BA,$E7,$00,$E0,$35,$38,$84,$D7,$E2
	.db $B7,$22,$02,$12,$22,$02,$E2,$00,$F2,$B2,$42,$72,$E1,$01,$E4,$80
	.db $D2,$81,$D1,$91,$D0,$E4,$84,$E1,$0E,$A2,$E1,$05,$E7,$58,$12,$E1
	.db $05,$94,$72,$E4,$86,$42,$22,$E4,$84,$44,$E4,$86,$42,$22,$E4,$84
	.db $42,$14,$F1,$F6,$B2,$F2,$E2,$B7,$92,$02,$72,$92,$E2,$00,$02,$42
	.db $72,$42,$E7,$61,$04,$96,$E7,$60,$12,$76,$E4,$87,$42,$72,$92,$72
	.db $E5,$00,$D3,$E4,$80,$E1,$02,$91,$A1,$B1,$B1,$A1,$91,$81,$71,$61
	.db $51,$D0,$E4,$85,$E5,$18,$E1,$07,$91,$71,$E1,$06,$41,$E1,$07,$21
	.db $F1,$B1,$E1,$06,$F2,$21,$E1,$05,$E5,$00,$48,$E5,$1F,$F1,$41,$71
	.db $91,$B1,$F2,$21,$41,$71,$91,$E0,$25,$38,$84,$E5,$E7,$58,$02,$B0
	.db $F3,$E7,$58,$41,$B2,$02,$E5,$A3,$B8,$F2,$42,$72,$E5,$D7,$E7,$61
	.db $05,$96,$76,$B6,$76,$44,$74,$E5,$E5,$E7,$58,$02,$B0,$E7,$60,$41
	.db $F3,$B2,$02,$B8,$F2,$B2,$F3,$22,$E0,$35,$3A,$85,$A5,$E7,$58,$11
	.db $42,$D2,$42,$42,$D0,$24,$E7,$00,$F2,$A2,$D2,$92,$72,$D0,$92,$D2
	.db $A2,$A2,$E7,$62,$01,$D0,$94,$E7,$58,$11,$72,$D2,$42,$22,$D0,$42
	.db $D2,$22,$42,$D0,$72,$D2,$42,$72,$D0,$92,$E7,$00,$A2,$B2,$04,$E7
	.db $60,$03,$F3,$2A,$E7,$00
	.db $FE,$FF
	.dw Music81Ch1Data
Music81Ch2Data:
	.db $E0,$25,$04
	.db $FD
	.dw Music81Section0
	.db $FD
	.dw Music81Section0
	.db $92,$92,$72,$92,$C2,$92,$72,$94,$92,$72,$92,$C2,$92,$74
	.db $FD
	.dw Music81Section0
	.db $F1,$B2,$04,$B4,$F2,$B2,$92,$62,$F1,$92,$04,$94,$F2,$92,$72,$42
	.db $42,$04,$44,$22,$32,$42,$F3,$22,$04,$2A,$E0,$25,$06,$FB,$46,$74
	.db $B2,$92,$72,$FE,$04,$FB,$F1,$96,$C4,$F2,$42,$22,$F1,$C2,$FE,$02
	.db $E0,$15,$04,$94,$C4,$94,$B4,$F2,$48,$F1,$41,$71,$91,$B1,$F2,$21
	.db $41,$71,$B1,$FB,$F1,$B6,$F2,$64,$B2,$92,$62,$FE,$02,$FB,$F1,$96
	.db $F2,$44,$92,$72,$42,$FE,$02,$FB,$F1,$B6,$F2,$64,$B2,$92,$62,$FE
	.db $02,$F2,$32,$42,$42,$44,$F1,$B4,$94,$92,$74,$92,$72,$52,$32,$F2
	.db $42,$42,$72,$72,$92,$92,$A2,$A2,$B2,$04,$E7,$60,$02,$BA,$E7,$00
	.db $FE,$FF
	.dw Music81Ch2Data
Music81Ch3Data:
	.db $E0,$05
	.db $FD
	.dw Music81Section1
	.db $FD
	.dw Music81Section1
	.db $FD
	.dw Music81Section1
	.db $FD
	.dw Music81Section2
	.db $FD
	.dw Music81Section1
	.db $FD
	.dw Music81Section1
	.db $FD
	.dw Music81Section1
	.db $C2,$12,$B2,$12,$11,$91,$82,$91,$81,$72,$FB,$B2,$C2,$C2,$B2,$C2
	.db $92,$82,$72,$FE,$02
	.db $FD
	.dw Music81Section1
	.db $B2,$22,$22,$B2,$92,$82,$81,$81,$72
	.db $FD
	.dw Music81Section1
	.db $FD
	.dw Music81Section1
	.db $FD
	.dw Music81Section1
	.db $FD
	.dw Music81Section2
	.db $FD
	.dw Music81Section1
	.db $FD
	.dw Music81Section1
	.db $FD
	.dw Music81Section1
	.db $B2,$12,$B2,$12,$91,$91,$91,$91,$81,$81,$81,$81
	.db $FD
	.dw Music81Section1
	.db $FD
	.dw Music81Section1
	.db $FB,$B2,$22,$22,$FE,$04,$B2,$22,$B2,$22,$FB,$C2,$12,$B2,$12,$11
	.db $C1,$C2,$B2,$12,$FE,$02,$FB,$72,$C2,$C2,$72,$C2,$C2,$B2,$22,$B2
	.db $22,$22,$92,$82,$82,$72,$72,$FB,$B2,$C2,$C2,$FE,$02,$B2,$C2,$B2
	.db $91,$81,$72,$36,$E1,$02,$B1,$E1,$03,$B1,$E1,$05,$B1,$B1,$B1
	.db $FE,$FF
	.dw Music81Ch3Data
Music81Section0:
	.db $42,$42,$22,$42,$82,$42,$22,$44,$42,$22,$42,$82,$42,$24
	.db $FF
Music81Section1:
	.db $C2,$12,$B2,$12,$11,$C1,$C2,$B2,$12
	.db $FF
Music81Section2:
	.db $C2,$12,$B2,$12,$11,$C1,$C2,$91,$91,$81,$71
	.db $FF
Music85Ch1Data:
	.db $E0,$24,$78,$83,$B6,$E7,$60,$51,$E8,$81,$E2,$B7,$42,$72,$92,$E1
	.db $06,$F3,$43,$F2,$E2,$00,$A0,$E2,$B7,$94,$71,$43,$21,$E1,$04,$42
	.db $72,$92,$E1,$06,$F3,$43,$F2,$E2,$00,$A9,$F3,$74,$03,$71,$03,$75
	.db $E0,$26,$78,$84,$A7,$E2,$B1,$43,$21,$43,$74,$41,$73,$91,$E5,$83
	.db $AA,$91,$71,$43,$21,$E2,$00,$43,$E5,$2F,$41,$E5,$A7,$D5,$43,$41
	.db $D6,$43,$D0,$E0,$16,$77,$82,$42,$71,$B3,$94,$71,$93,$B5,$73,$41
	.db $E0,$26,$78,$84,$A7,$E2,$B1,$43,$21,$43,$74,$41,$73,$91,$A4,$93
	.db $A1,$93,$71,$43,$21,$43,$E5,$2F,$41,$E5,$A6,$D5,$43,$41,$D7,$43
	.db $D0,$E0,$36,$38,$82,$17,$E2,$BA,$41,$01,$D5,$42,$D0,$F2,$A3,$E1
	.db $04,$91,$A1,$91,$E1,$06,$73,$41,$73,$41,$03,$E2,$00,$E0,$26,$78
	.db $82,$B7,$E4,$01,$E7,$60,$52,$E2,$00,$90,$E4,$82,$B1,$73,$E2,$76
	.db $41,$03,$41,$03,$41,$E2,$00,$E4,$83,$E7,$61,$03,$73,$E7,$00,$41
	.db $E7,$61,$04,$94,$E7,$00,$73,$91,$73,$91,$B3,$71,$93,$71,$03,$E2
	.db $76,$41,$01,$D6,$42,$D0,$21,$F3,$41,$D6,$21,$41,$D0,$41,$E2,$00
	.db $E0,$34,$79,$86,$96,$12,$D1,$22,$42,$E1,$06,$E4,$84,$73,$41,$73
	.db $61,$43,$21,$13,$F2,$91,$03,$91,$F3,$13,$24,$31,$E4,$84,$D0,$E1
	.db $04,$42,$72,$42,$92,$42,$A2,$E1,$06,$E2,$00,$93,$41,$73,$91,$E7
	.db $00,$43,$F2,$71,$B3,$94,$71,$E2,$76,$F3,$41,$02,$41,$E2,$00,$E0
	.db $26,$78,$83,$C6,$E4,$01,$E7,$60,$83,$D0,$40,$E4,$83,$E1,$04,$E5
	.db $48,$EA,$03,$E2,$74,$D3,$22,$42,$22,$D2,$42,$22,$D1,$42,$E5,$C9
	.db $72,$92,$72,$92,$EA,$00,$E2,$00,$D0,$72,$92,$E1,$06,$E5,$D6,$E7
	.db $60,$42,$E4,$01,$E1,$0F,$F3,$49,$E5,$28,$E4,$83,$E1,$03,$01,$E1
	.db $06,$D0,$F2,$E7,$00,$E2,$30,$B1,$E1,$04,$A2,$92,$72,$E5,$A6,$E1
	.db $06,$E7,$60,$01,$44
	.db $FE,$FF
	.dw Music85Ch1Data
Music85Ch0Data:
	.db $E0,$04,$38,$83,$87,$E8,$81,$F0,$42,$D3,$F2,$22,$42,$E1,$06,$F2
	.db $23,$21,$13,$D6,$11,$E2,$70,$E7,$60,$55,$E5,$00,$D4,$AB,$E7,$00
	.db $E5,$87,$D3,$E2,$30,$44,$21,$F1,$B3,$91,$E1,$04,$D0,$F0,$42,$D3
	.db $F2,$22,$42,$E1,$06,$43,$21,$13,$D6,$11,$E2,$70,$E5,$00,$D4,$A4
	.db $D3,$24,$03,$21,$03,$25,$D0,$E0,$26,$B7,$86,$A8,$73,$F0,$71,$93
	.db $F2,$14,$25,$17,$14,$25,$E4,$85,$73,$E5,$2F,$71,$E5,$68,$D5,$73
	.db $71,$D7,$73,$D0,$E0,$16,$F3,$81,$44,$11,$63,$44,$21,$43,$65,$23
	.db $F0,$B1,$E0,$26,$B7,$86,$A8,$73,$F0,$71,$93,$F2,$14,$25,$17,$14
	.db $25,$E4,$85,$73,$E5,$2F,$71,$E5,$68,$D4,$73,$71,$D7,$73,$D0,$E5
	.db $A8,$E2,$30,$E2,$B7,$B1,$D6,$B3,$D0,$E4,$84,$54,$41,$23,$F1,$B1
	.db $F2,$23,$F1,$B1,$03,$E2,$00,$E0,$06,$79,$83,$47,$E2,$00,$01,$F0
	.db $43,$E3,$07,$E2,$76,$EA,$03,$D1,$F2,$11,$43,$74,$61,$43,$11,$EA
	.db $00,$F1,$B3,$E2,$76,$71,$03,$71,$03,$71,$E2,$00,$93,$B1,$D0,$E3
	.db $09,$F0,$73,$E3,$07,$F1,$D3,$EA,$03,$71,$B3,$F2,$24,$11,$F1,$B3
	.db $EA,$00,$71,$E2,$76,$42,$01,$71,$93,$A2,$02,$91,$F3,$E2,$00,$B1
	.db $02,$B1,$E0,$04,$BF,$84,$96,$E2,$B6,$F0,$42,$E3,$08,$D2,$F2,$42
	.db $42,$E1,$06,$92,$D7,$41,$D2,$91,$73,$71,$63,$61,$43,$F1,$91,$03
	.db $D3,$41,$F2,$93,$A4,$D2,$F1,$A1,$E2,$76,$E1,$04,$F2,$42,$72,$42
	.db $92,$42,$A2,$E2,$00,$E1,$06,$93,$41,$73,$91,$B3,$21,$63,$44,$21
	.db $B1,$02,$B1,$D0,$E0,$16,$79,$86,$A6,$E2,$31,$E7,$00,$D1,$93,$A1
	.db $B3,$B1,$E2,$00,$E2,$70,$D6,$F2,$48,$D0,$E5,$84,$E2,$31,$F1,$78
	.db $28,$E5,$A6,$93,$A1,$B3,$B1,$E2,$70,$F3,$D6,$4F,$D0,$E2,$30,$B1
	.db $E1,$04,$A2,$92,$72,$E5,$A6,$E1,$06,$44
	.db $FE,$FF
	.dw Music85Ch0Data
Music85Ch2Data:
	.db $E0,$26,$04,$E8,$81,$44,$73,$41,$74,$93,$71,$94,$C3,$91,$C3,$E0
	.db $36,$00,$23,$E1,$02,$21,$11,$F2,$B1,$A1,$71,$61,$E0,$06,$04,$44
	.db $73,$41,$74,$93,$71,$F1,$B4,$03,$B1,$03,$B5,$FB,$E0,$26,$03,$43
	.db $71,$93,$A1,$03,$A1,$93,$71,$42,$05,$11,$23,$41,$03,$11,$43,$41
	.db $14,$24,$44,$74,$14,$24,$44,$FE,$02,$E0,$26,$04,$44,$24,$14,$F1
	.db $B4,$E0,$26,$08,$44,$64,$74,$84,$E0,$06,$07,$F1,$74,$94,$B4,$74
	.db $73,$44,$91,$03,$91,$B1,$02,$B1,$E0,$26,$04,$E7,$60,$01,$47,$44
	.db $11,$23,$41,$27,$24,$21,$43,$71,$97,$94,$41,$73,$91,$42,$01,$42
	.db $03,$21,$02,$21,$F3,$41,$02,$41,$E7,$00,$E0,$26,$04,$23,$31,$43
	.db $41,$08,$F1,$98,$78,$F2,$23,$31,$43,$41,$08,$07,$61,$E1,$04,$42
	.db $22,$12,$E1,$06,$F1,$B4
	.db $FE,$FF
	.dw Music85Ch2Data
Music85Ch3Data:
	.db $E0,$06,$C4,$13,$11,$FB,$34,$13,$11,$FE,$02,$34,$54,$34,$13,$11
	.db $FB,$34,$13,$11,$54,$13,$51,$34,$53,$C1,$C4,$13,$11,$FB,$34,$13
	.db $11,$FE,$03,$C4,$13,$11,$FB,$34,$13,$11,$FE,$02,$34,$E1,$08,$51
	.db $C1,$C1,$E0,$06,$C4,$13,$11,$FB,$34,$13,$11,$FE,$03,$C4,$13,$11
	.db $FB,$34,$13,$11,$FE,$02,$34,$E1,$08,$51,$51,$51,$E0,$06,$54,$13
	.db $11,$FB,$34,$13,$11,$FE,$03,$C4,$13,$11,$FB,$34,$13,$11,$FE,$02
	.db $34,$53,$51,$FB,$34,$13,$11,$FE,$04,$C4,$13,$11,$FB,$34,$13,$11
	.db $FE,$02,$34,$53,$51,$C4,$13,$11,$FB,$34,$13,$11,$FE,$03,$C4,$13
	.db $11,$FB,$34,$13,$11,$FE,$02,$E1,$08,$91,$81,$71,$73
	.db $FE,$FF
	.dw Music85Ch3Data
Music89Ch0Data:
	.db $E0,$07,$37,$87,$1F,$E8,$03,$F0,$11,$11,$02,$11,$11,$02,$11,$01
	.db $11,$01,$11,$11,$02,$00,$E5,$00,$D6,$FB
	.db $FD
	.dw Music89Section1
	.db $FE,$05,$E1,$07,$01
	.db $FD
	.dw Music89Section2
	.db $FD
	.dw Music89Section1
	.db $FD
	.dw Music89Section1
	.db $FD
	.dw Music89Section2
	.db $E1,$07,$04,$D0
Music89Ch0Data_Loop:
	.db $E2,$00,$FB,$E7,$51,$01,$E2,$36,$EA,$03,$E0,$07,$3A,$85,$18,$E8
	.db $89,$F0,$B1,$E8,$03,$E3,$07,$F1,$11,$62,$62,$61,$12,$B1,$F2,$12
	.db $F1,$12,$11,$61,$F0,$B1,$F1,$11,$62,$42,$42,$62,$F0,$B1,$B1,$B1
	.db $F1,$41,$F0,$B1,$B1,$E7,$00,$E2,$30,$D0,$E8,$89,$E3,$09,$B1,$E3
	.db $07,$E8,$03,$F1,$11,$62,$62,$62,$62,$41,$41,$41,$61,$41,$01,$F0
	.db $D1,$41,$41,$42,$42,$52,$EA,$00,$62,$02,$E0,$37,$34,$82,$88,$E2
	.db $00,$E7,$60,$01,$14,$E7,$00,$D0,$FE,$02,$E0,$07,$73,$91,$00,$01
	.db $E8,$03,$E9,$81
	.db $FD
	.dw Music89Section0
	.db $E8,$05
	.db $FD
	.dw Music89Section0
	.db $E8,$03
	.db $FD
	.dw Music89Section0
	.db $F1,$B1,$F2,$11,$61,$11,$F3,$12,$F1,$B1,$E0,$27,$34,$83,$17,$31
	.db $31,$31,$31,$04,$E8,$03,$E0,$17,$79,$88,$28,$EA,$03,$E2,$77,$E8
	.db $03,$B2,$F2,$12,$42,$12,$11,$12,$01,$D2,$F1,$12,$11,$D0,$B2,$B1
	.db $F2,$12,$42,$11,$09,$F1,$B2,$F2,$12,$42,$12,$11,$12,$01,$D2,$F0
	.db $12,$11,$D0,$F1,$B2,$B1,$F2,$12,$42,$11,$09
	.db $FE,$FF
	.dw Music89Ch0Data_Loop
Music89Ch1Data:
	.db $E0,$27,$38,$87,$19,$E8,$03,$E7,$52,$01,$11,$11,$02,$11,$11,$02
	.db $11,$01,$11,$01,$11,$11,$02,$00,$FB
	.db $FD
	.dw Music89Section1
	.db $FE,$05,$E1,$07,$01
	.db $FD
	.dw Music89Section2
	.db $FD
	.dw Music89Section1
	.db $FD
	.dw Music89Section1
	.db $FD
	.dw Music89Section2
	.db $E1,$07,$04
Music89Ch1Data_Loop:
	.db $D0,$FB,$E2,$76,$E0,$27,$79,$86,$27,$E7,$00,$B2,$D3,$F1,$12,$D0
	.db $F2,$A2,$D3,$F1,$12,$D0,$F2,$82,$D3,$F1,$12,$D0,$F2,$11,$01,$11
	.db $E5,$2A,$EA,$03,$B2,$B1,$B2,$A2,$A2,$82,$EA,$00,$E2,$30,$D1,$E4
	.db $87,$F1,$41,$41,$41,$61,$41,$43,$E2,$70,$E4,$85,$D0,$F2,$B2,$A2
	.db $D4,$F1,$12,$D0,$F2,$82,$D3,$F1,$12,$D0,$E0,$27,$7A,$88,$19,$E5
	.db $2A,$EA,$03,$12,$11,$F1,$B2,$B1,$B2,$B2,$C2,$EA,$00,$E2,$00,$E5
	.db $1F,$F2,$11,$03,$E0,$37,$3B,$89,$47,$13,$01,$FE,$02,$E0,$07,$7A
	.db $87,$13,$E9,$00
	.db $FD
	.dw Music89Section0
	.db $E8,$05
	.db $FD
	.dw Music89Section0
	.db $E8,$03
	.db $FD
	.dw Music89Section0
	.db $F1,$B1,$F2,$11,$61,$11,$F3,$12,$F1,$B1,$F2,$11,$E0,$27,$32,$03
	.db $00,$81,$81,$81,$81,$04,$FB,$E0,$57,$76,$95,$1A,$E7,$00,$D3,$11
	.db $01,$11,$01,$D4,$11,$01,$D5,$11,$01,$D1,$11,$01,$11,$81,$E4,$85
	.db $D5,$11,$01,$11,$81,$E5,$1F,$D5,$E5,$1F,$11,$81,$11,$11,$E5,$18
	.db $D4,$11,$81,$11,$11,$E4,$82,$D3,$11,$81,$11,$11,$E4,$85,$11,$F4
	.db $B1,$81,$81,$FE,$02,$D0
	.db $FE,$FF
	.dw Music89Ch1Data_Loop
Music89Ch2Data:
	.db $E0,$07,$06,$E8,$03,$F2,$11,$11,$02,$11,$11,$02,$11,$01,$11,$01
	.db $11,$11,$02,$E0,$07,$0B,$E7,$52,$06,$F5,$FB,$21,$FE,$08,$08,$00
	.db $E7,$00
Music89Ch2Data_Loop:
	.db $E0,$07,$05,$FB,$F1,$B2,$F2,$11,$01,$42,$11,$01,$11,$11,$02,$11
	.db $01,$11,$F1,$B2,$B1,$F2,$11,$01,$42,$12,$02,$F1,$41,$41,$41,$61
	.db $41,$41,$E0,$07,$00,$B2,$E0,$07,$06,$F2,$11,$01,$42,$11,$01,$11
	.db $11,$02,$11,$01,$11,$F1,$B1,$01,$B1,$B1,$01,$B1,$01,$C2,$F2,$12
	.db $02,$F3,$12,$02,$FE,$02,$E0,$07,$06,$FB,$F1,$91,$91,$92,$91,$F2
	.db $81,$91,$F1,$91,$91,$F2,$91,$81,$91,$61,$81,$41,$61,$FE,$02,$FB
	.db $F1,$B1,$B1,$B2,$B1,$F2,$91,$B1,$F1,$B1,$B1,$F2,$B1,$91,$B1,$81
	.db $91,$61,$91,$FE,$02,$FB,$F1,$91,$91,$92,$91,$F2,$81,$91,$F1,$91
	.db $91,$F2,$91,$81,$91,$61,$81,$41,$61,$FE,$02,$F1,$B1,$B1,$B2,$B1
	.db $F2,$91,$B1,$F1,$B1,$F2,$11,$11,$11,$11,$04,$F1,$B2,$F2,$11,$01
	.db $42,$11,$01,$11,$11,$02,$11,$01,$11,$F1,$B2,$B1,$F2,$11,$01,$42
	.db $12,$01,$11,$F1,$C1,$B1,$91,$81,$61,$41,$E0,$07,$00,$B2,$E0,$07
	.db $06,$F2,$11,$01,$42,$11,$01,$11,$11,$02,$11,$01,$11,$F1,$B1,$01
	.db $B1,$F2,$11,$01,$42,$12,$08
	.db $FE,$FF
	.dw Music89Ch2Data_Loop
Music89Ch3Data:
	.db $E0,$07,$C1,$C1,$02,$C1,$C1,$02,$C2,$C2,$C1,$C3,$FB,$C1,$FE,$08
	.db $FB,$B1,$FE,$08,$C1,$C1,$C1,$C1,$B2,$C1,$C1,$C1,$C1,$B2,$B1,$B1
	.db $B1,$B1
Music89Ch3Data_Loop:
	.db $E0,$07,$FB,$C1,$11,$11,$11,$B2,$11,$11,$C1,$11,$11,$11,$B4,$FE
	.db $08,$E0,$07,$FB,$C1,$11,$12,$B2,$11,$11,$C1,$11,$11,$11,$B4,$FE
	.db $03,$C1,$11,$12,$B2,$11,$11,$11,$91,$81,$11,$81,$81,$71,$71,$FB
	.db $C1,$11,$12,$B2,$11,$11,$C1,$11,$11,$11,$B4,$FE,$02,$C1,$11,$11
	.db $11,$B1,$B1,$11,$11,$B1,$B1,$B1,$B1,$11,$B1,$C2,$E0,$07,$C1,$11
	.db $11,$11,$B2,$11,$11,$C1,$11,$11,$11,$B4,$C1,$11,$11,$11,$B2,$11
	.db $11,$B1,$91,$82,$71,$71,$C1,$C1,$B1,$11,$11,$11,$B2,$11,$11,$C1
	.db $11,$11,$C1,$B1,$B1,$B1,$B5,$11,$32,$11,$91,$82,$91,$81,$71,$72
	.db $FE,$FF
	.dw Music89Ch3Data_Loop
Music89Section0:
	.db $FB,$F1,$91,$B1,$F2,$41,$F1,$B1,$F2,$B2,$F1,$91,$B2,$91,$B1,$91
	.db $F2,$B1,$F1,$91,$B1,$F2,$41,$FE,$02
	.db $FF
Music89Section1:
	.db $D0,$F2,$E1,$01,$81,$91,$A1,$B4
	.db $FF
Music89Section2:
	.db $F2,$E1,$02,$11,$D3,$F1,$B1,$A1,$91,$81,$71,$61
	.db $FF
Music8DCh0Data:
	.db $E0,$16,$75,$83,$5C,$E7,$60,$14,$A2,$A1,$C1,$F2,$12,$32,$F1,$92
	.db $A2,$92,$62,$E5,$2C,$C2,$A2,$72,$A2,$E5,$D6,$E7,$60,$04,$C8
Music8DCh0Data_Loop:
	.db $E0,$26,$73,$80,$00,$E8,$00,$E7,$60,$02,$01
	.db $FD
	.dw Music8DSection0
	.db $F1,$C2,$F2,$31,$E0,$16,$75,$83,$A8,$E7,$00,$C1,$C1,$F2,$52,$61
	.db $51,$11,$F1,$C1,$E5,$1B,$E2,$76,$A1,$A1,$91,$61,$91,$61,$51,$31
	.db $E2,$00,$E0,$06,$73,$80,$00,$E7,$60,$01,$01
	.db $FD
	.dw Music8DSection1
	.db $E0,$26,$75,$82,$16,$31,$51,$61,$81,$61,$51,$31,$E7,$00,$E5,$67
	.db $21,$F1,$B1,$A2,$F3,$21,$F2,$B1,$A2,$E2,$30,$F1,$B2,$F2,$32,$51
	.db $61,$51,$31,$52,$31,$F1,$B1,$84,$A2,$B1,$81,$B1,$A1,$81,$81,$A4
	.db $E7,$60,$05,$F2,$B4,$E7,$00,$FB,$E0,$16,$77,$85,$B6,$51,$31,$E5
	.db $12,$53,$E5,$B6,$A1,$F2,$31,$51,$FE,$02,$E1,$08,$F0,$31,$F1,$81
	.db $B1,$B1,$81,$81,$B1,$81,$81,$E1,$06,$E7,$60,$04,$84,$E7,$00,$E4
	.db $84,$51,$62,$82,$61,$82,$A2,$81,$A1,$B2,$A1,$B1,$E0,$26,$77,$86
	.db $1F,$51,$51,$51,$01,$E0,$36,$73,$81,$00,$51,$FB,$F2,$31,$51,$F3
	.db $31,$51,$FE,$02,$F2,$31,$F3,$51,$31,$E0,$26,$77,$85,$27,$51,$52
	.db $51,$51,$42,$41,$32,$31,$22,$11,$F1,$C1,$B1
	.db $FE,$FF
	.dw Music8DCh0Data_Loop
Music8DCh1Data:
	.db $E0,$36,$79,$88,$2C,$E2,$72,$E7,$60,$11,$12,$11,$F2,$C1,$A2,$62
	.db $52,$62,$52,$32,$E5,$1C,$52,$32,$F1,$C2,$F2,$32,$E7,$60,$04,$E4
	.db $85,$E5,$A6,$58,$E2,$00
Music8DCh1Data_Loop:
	.db $E0,$26,$7A,$85,$37,$E8,$00,$E7,$00
	.db $FD
	.dw Music8DSection0
	.db $F1,$C2,$F2,$32,$E0,$26,$79,$85,$26,$E7,$00,$51,$51,$A2,$C1,$A1
	.db $61,$31,$E5,$17,$E2,$76,$51,$61,$51,$31,$51,$F1,$C1,$F2,$11,$F1
	.db $A1,$E2,$00,$E0,$06,$78,$83,$36
	.db $FD
	.dw Music8DSection1
	.db $F2,$A1,$B1,$F3,$21,$31,$51,$31,$21,$F2,$B1,$FB,$A1,$81,$52,$FE
	.db $02,$E5,$A6,$E8,$0C,$A6,$E7,$60,$12,$91,$A1,$92,$61,$91,$62,$51
	.db $31,$21,$51,$61,$31,$51,$31,$F1,$B1,$F2,$31,$54,$F3,$E7,$60,$01
	.db $54,$E7,$00,$E8,$0C,$EA,$03,$FB,$E0,$16,$79,$85,$35,$D1,$A1,$81
	.db $E5,$12,$A2,$D0,$E5,$25,$A1,$F2,$31,$51,$A1,$FE,$02,$EA,$00,$E1
	.db $08,$F1,$61,$B1,$F2,$31,$51,$31,$F1,$B1,$61,$B1,$F2,$51,$E1,$06
	.db $E7,$60,$01,$E5,$43,$A4,$E7,$00,$F1,$A1,$B2,$F2,$12,$F1,$B1,$F2
	.db $12,$32,$11,$31,$52,$31,$51,$E0,$26,$78,$86,$1F,$E8,$00,$A1,$A1
	.db $A1,$E4,$83,$E5,$17,$F3,$51,$FB,$F2,$31,$51,$F3,$31,$51,$FE,$02
	.db $E2,$76,$F2,$31,$F3,$51,$31,$F2,$B1,$E5,$17,$A1,$A2,$A1,$A1,$92
	.db $91,$82,$81,$72,$61,$51,$41,$E2,$00
	.db $FE,$FF
	.dw Music8DCh1Data_Loop
Music8DCh2Data:
	.db $E0,$21,$00,$61,$71,$81,$81,$A2,$E0,$06,$06,$A1,$A1,$A1,$C2,$C2
	.db $F3,$12,$12,$32,$32,$E0,$36,$08,$52,$32,$F2,$C2,$F3,$32,$E0,$36
	.db $05,$58,$E7,$00
Music8DCh2Data_Loop:
	.db $E0,$16,$04,$FB,$F1,$A1,$A1,$F2,$51,$A1,$FE,$04,$FB,$F1,$B1,$B1
	.db $F2,$61,$B1,$FE,$04,$FB,$F1,$C1,$C1,$F2,$71,$C1,$FE,$04,$F2,$61
	.db $61,$A2,$61,$A1,$61,$51,$11,$11,$11,$F1,$A1,$C4,$FB,$E0,$16,$07
	.db $B1,$B1,$F2,$51,$B1,$FE,$04,$F1,$51,$81,$A1,$B1,$F2,$21,$F1,$B1
	.db $A1,$81,$FB,$F2,$51,$31,$F1,$B2,$FE,$02,$FB,$F1,$B2,$F2,$B1,$B1
	.db $FE,$02,$F1,$B2,$F2,$A1,$A1,$F1,$A2,$81,$81,$B2,$B1,$B1,$F2,$52
	.db $51,$81,$A4,$A4,$E0,$26,$06,$FB,$A1,$81,$A2,$A1,$A1,$A1,$A1,$FE
	.db $02,$FB,$E1,$08,$31,$61,$B1,$B1,$61,$61,$FE,$02,$E1,$06,$F2,$51
	.db $52,$51,$31,$32,$31,$11,$12,$11,$F1,$B1,$B2,$B1,$E0,$16,$07,$FB
	.db $A1,$FE,$05,$F2,$51,$A1,$F1,$A1,$A1,$A1,$F2,$A1,$F1,$A1,$A1,$F2
	.db $51,$A1,$F1,$A1,$A1,$A2,$A1,$C1,$C2,$C1,$F2,$11,$12,$32,$31,$51
	.db $61
	.db $FE,$FF
	.dw Music8DCh2Data_Loop
Music8DCh3Data:
	.db $E0,$06,$00,$0A,$C1,$C1,$B4
Music8DCh3Data_Loop:
	.db $FB,$C2,$11,$11,$B2,$11,$11,$FE,$06,$91,$91,$82,$81,$91,$81,$71
	.db $71,$71,$71,$71,$B1,$C1,$C1,$C1,$C2,$11,$11,$B2,$11,$11,$C1,$11
	.db $12,$B2,$11,$11,$C2,$11,$11,$B2,$11,$11,$91,$91,$81,$11,$81,$81
	.db $71,$11,$FB,$C2,$11,$11,$B2,$11,$11,$FE,$02,$B1,$11,$11,$81,$B1
	.db $C1,$11,$C1,$B2,$11,$11,$B2,$11,$11,$FB,$81,$81,$72,$B1,$B1,$B1
	.db $B1,$FE,$02,$E0,$08,$91,$81,$71,$81,$71,$71,$C1,$C1,$C1,$E0,$06
	.db $B4,$91,$92,$91,$81,$82,$81,$72,$71,$72,$C1,$C1,$C1,$B2,$11,$11
	.db $B2,$11,$11,$C2,$11,$11,$B2,$91,$81,$91,$92,$91,$81,$82,$81,$72
	.db $71,$72,$B1,$B1,$B1
	.db $FE,$FF
	.dw Music8DCh3Data_Loop
Music8DSection0:
	.db $52,$51,$31,$F1,$C2,$F2,$32,$52,$32,$A2,$62,$51,$51,$62,$52,$32
	.db $52,$32,$F1,$B2,$82,$C1,$C1,$F2,$32,$F1,$C1,$C1,$F2,$32,$52,$32
	.db $FF
Music8DSection1:
	.db $FB,$F3,$51,$31,$F2,$B2,$F2,$51,$31,$F1,$B2,$FE,$02
	.db $FF
Music91Ch0Data:
	.db $E8,$02,$FB,$E0,$26,$72,$80,$53,$E7,$60,$02,$03,$11,$61,$B1,$F3
	.db $12,$F2,$B2,$61,$12,$64,$E0,$06,$38,$85,$38,$E2,$36,$11,$11,$01
	.db $12,$12,$11,$12,$E2,$00,$E5,$B6,$16,$E0,$26,$72,$80,$53,$03,$11
	.db $61,$B1,$F3,$12,$F2,$B2,$E1,$04,$61,$81,$41,$E1,$06,$61,$F1,$B3
	.db $E0,$26,$38,$84,$28,$E2,$36,$D0,$11,$11,$01,$12,$12,$11,$11,$11
	.db $F1,$81,$E2,$00,$E5,$00,$62,$72,$FE,$02,$FB,$E0,$16,$35,$84,$23
	.db $E7,$60,$02,$12,$F0,$12,$F1,$B1,$42,$E4,$80,$E5,$76,$E2,$70,$D2
	.db $F2,$13,$11,$F1,$42,$B1,$42,$E0,$06,$35,$84,$23,$D0,$F0,$C1,$F1
	.db $31,$F0,$C2,$F1,$31,$F0,$C2,$F1,$E4,$80,$E5,$76,$E2,$70,$D2,$C3
	.db $C1,$32,$81,$32,$D0,$FE,$03,$E4,$84,$E5,$46,$12,$12,$41,$12,$E4
	.db $83,$B2,$F2,$11,$11,$F1,$B1,$72,$61,$31,$D1,$FB,$61,$81,$FE,$04
	.db $D0,$FB,$61,$81,$FE,$04,$E7,$00,$E0,$26,$77,$84,$B6,$E7,$60,$11
	.db $14,$F2,$61,$51,$12,$F0,$52,$F2,$81,$61,$81,$E2,$30,$E5,$18,$61
	.db $51,$11,$E5,$A6,$14,$24,$F1,$B4,$94,$E2,$70,$F2,$14,$F2,$61,$51
	.db $12,$F0,$52,$F1,$81,$81,$81,$F2,$E2,$30,$E5,$1F,$61,$41,$11,$E0
	.db $06,$77,$84,$17,$E2,$31,$FB,$F0,$61,$F1,$91,$FE,$02,$F2,$11,$F3
	.db $11,$F2,$11,$F3,$11,$FB,$F2,$81,$F1,$81,$FE,$02,$F2,$81,$91,$81
	.db $91,$E2,$00,$E0,$36,$73,$81,$A6,$E7,$60,$01,$01,$E8,$83,$11,$21
	.db $F2,$B1,$F3,$11,$F2,$91,$B1,$81,$91,$61,$81,$51,$61,$21,$41,$11
	.db $21,$E8,$02,$F1,$92,$81,$71,$C2,$B1,$91,$F2,$11,$F1,$C1,$F2,$11
	.db $31,$44,$11,$41,$31,$61,$41,$81,$61,$91,$81,$B1,$91,$F3,$11,$F2
	.db $C1,$F3,$31,$11,$E5,$1F,$E3,$06,$F2,$FB,$31,$FE,$05,$D2,$01,$B1
	.db $91,$81,$71,$81,$71,$81,$E4,$81,$E5,$73,$E2,$00,$73,$E7,$00,$D0
	.db $FE,$FF
	.dw Music91Ch0Data
Music91Ch1Data:
	.db $E8,$02,$E7,$00,$FB,$E0,$06,$79,$83,$37,$F0,$11,$F2,$11,$61,$B1
	.db $F3,$12,$F2,$B2,$61,$12,$61,$D4,$12,$61,$11,$D0,$E0,$06,$38,$86
	.db $17,$E2,$76,$01,$61,$61,$01,$62,$42,$61,$82,$E2,$00,$E5,$00,$46
	.db $E0,$06,$79,$83,$37,$11,$61,$B1,$F3,$12,$F2,$B2,$E1,$04,$61,$81
	.db $41,$E1,$06,$61,$F1,$B1,$D4,$F2,$E1,$04,$81,$41,$E1,$06,$61,$E1
	.db $04,$01,$E1,$06,$F1,$B1,$D0,$E0,$26,$39,$86,$17,$E2,$76,$01,$61
	.db $61,$01,$62,$42,$61,$81,$41,$11,$F1,$E2,$00,$E4,$96,$E5,$A7,$B2
	.db $C2,$FE,$02
	.db $FD
	.dw Music91Section0
	.db $41,$E0,$26,$37,$85,$18,$E7,$60,$11,$11,$11,$F1,$42,$B1,$42,$41
	.db $E0,$26,$79,$85,$23,$82,$B2,$71,$62,$41,$E0,$16,$37,$84,$17,$C1
	.db $C1,$32,$81,$32,$31
	.db $FD
	.dw Music91Section0
	.db $62,$71,$61,$41,$12,$F1,$B1,$81,$E5,$18,$E2,$77,$D1,$FB,$F1,$B1
	.db $F2,$11,$FE,$04,$D0,$FB,$F1,$B1,$F2,$11,$FE,$04,$E2,$00,$E0,$06
	.db $39,$85,$84,$E2,$73,$E7,$60,$13,$F2,$61,$91,$B1,$E4,$84,$F3,$13
	.db $E4,$86,$F2,$51,$81,$B1,$E4,$84,$F3,$13,$E4,$86,$F2,$E5,$18,$E2
	.db $76,$B1,$91,$81,$61,$E2,$30,$61,$91,$E2,$00,$F3,$11,$21,$11,$F2
	.db $B1,$91,$81,$E4,$84,$E5,$A4,$62,$51,$61,$52,$21,$11,$61,$91,$B1
	.db $F3,$13,$F2,$51,$81,$B1,$F3,$13,$F2,$E5,$18,$E2,$76,$B1,$91,$81
	.db $61,$E2,$00,$E0,$36,$39,$84,$18,$EA,$02,$E2,$77,$11,$21,$F2,$B1
	.db $F3,$11,$F2,$91,$B1,$81,$91,$61,$81,$51,$61,$21,$41,$11,$21,$E0
	.db $36,$79,$84,$3A,$E7,$60,$01,$E2,$76,$E8,$83,$11,$21,$F2,$B1,$F3
	.db $11,$F2,$91,$B1,$81,$91,$61,$81,$51,$61,$21,$41,$11,$21,$E8,$02
	.db $F1,$E2,$00,$EA,$00,$E4,$82,$E7,$60,$04,$92,$E5,$18,$E2,$76,$81
	.db $71,$E2,$00,$E5,$3A,$C2,$E7,$00,$E2,$76,$B1,$91,$F2,$11,$F1,$C1
	.db $F2,$11,$31,$E2,$00,$E7,$60,$03,$E4,$83,$E5,$86,$44,$E2,$76,$E4
	.db $87,$E5,$17,$E7,$00,$11,$41,$31,$61,$41,$81,$61,$91,$81,$B1,$91
	.db $F3,$11,$F2,$C1,$F3,$31,$11,$41,$F2,$FB,$C1,$FE,$05,$E2,$70,$B1
	.db $91,$81,$71,$81,$71,$81,$E4,$83,$E5,$96,$E7,$60,$02,$E2,$00,$74
	.db $E7,$00,$D0
	.db $FE,$FF
	.dw Music91Ch1Data
Music91Section0:
	.db $E0,$06,$79,$85,$A6,$F0,$12,$F2,$12,$41,$12,$41,$E0,$26,$37,$85
	.db $18,$11,$11,$F1,$42,$B1,$42,$41,$E0,$26,$79,$85,$A6,$74,$63,$41
	.db $E0,$16,$37,$85,$18,$C1,$C1,$32,$81,$32,$31,$E0,$06,$79,$85,$45
	.db $F0,$12,$F2,$12,$41,$12
	.db $FF
Music91Ch2Data:
	.db $E8,$02,$E0,$06,$05,$FB,$F2,$14,$84,$12,$11,$41,$01,$83,$F1,$C4
	.db $F2,$94,$82,$F1,$81,$F2,$81,$01,$93,$14,$84,$12,$11,$41,$01,$83
	.db $F1,$F1,$C4,$F2,$94,$61,$81,$41,$11,$F1,$B2,$C2,$FE,$02,$FB,$F2
	.db $14,$84,$12,$11,$41,$01,$83,$F1,$C4,$F2,$94,$F1,$C2,$C1,$F2,$41
	.db $01,$93,$FE,$03,$14,$84,$12,$11,$41,$01,$83,$E0,$06,$06,$FB,$F1
	.db $11,$F2,$11,$FE,$08,$E0,$26,$03,$FB,$64,$F3,$14,$F2,$54,$F3,$14
	.db $F2,$62,$61,$F3,$12,$F2,$63,$54,$24,$FE,$02,$E0,$26,$05,$14,$84
	.db $12,$11,$42,$83,$F1,$C4,$F2,$94,$F1,$C2,$C1,$F2,$42,$93,$14,$84
	.db $12,$11,$42,$83,$F1,$FB,$81,$FE,$05,$F2,$31,$F1,$81,$81,$81,$F2
	.db $31,$F1,$81,$81,$82,$C2
	.db $FE,$FF
	.dw Music91Ch2Data
Music91Ch3Data:
	.db $E0,$06,$FB,$C1,$12,$11,$B2,$11,$11,$C1,$11,$C1,$B2,$11,$11,$11
	.db $C1,$C1,$12,$B2,$11,$11,$C1,$C1,$11,$B2,$31,$11,$11,$C1,$12,$11
	.db $B2,$11,$11,$C1,$11,$C1,$B2,$11,$11,$11,$C1,$12,$11,$B2,$11,$11
	.db $C1,$B1,$C2,$C2,$B1,$11,$FE,$02,$E0,$06
	.db $FD
	.dw Music91Section1
	.db $C2,$12,$B2,$11,$11,$C1,$11,$12,$91,$91,$82
	.db $FD
	.dw Music91Section1
	.db $C2,$11,$11,$B2,$11,$11,$C1,$C1,$C1,$C1,$B1,$B1,$B1,$B1
	.db $FD
	.dw Music91Section2
	.db $C2,$11,$11,$B1,$12,$11,$11,$B1,$C2,$B2,$C1,$C1
	.db $FD,$00,$B6
	.db $FB,$B1,$FE,$04,$91,$91,$81,$81,$C1,$11,$C1,$11,$B2,$C1,$C1
	.db $FE,$FF
	.dw Music91Ch3Data
Music91Section1:
	.db $FB,$C2,$12,$B2,$11,$11,$C1,$11,$12,$B2,$11,$11,$FE,$03
	.db $FF
Music91Section2:
	.db $FB,$C2,$11,$11,$B2,$11,$11,$C1,$11,$C2,$B2,$11,$11,$FE,$03
	.db $FF
Music95Ch0Data:
	.db $E0,$04,$37,$83,$59,$E7,$60,$01,$0C,$F2,$C5,$F3,$14,$E5,$A6,$33
Music95Ch0Data_Loop:
	.db $E0,$04,$37,$83,$15,$EA,$03,$E2,$77,$E7,$00
	.db $FD
	.dw Music95Section0
	.db $F2,$12,$F1,$A1,$F2,$32,$F1,$83,$81,$92,$A1
	.db $FD
	.dw Music95Section0
	.db $A2,$F2,$81,$72,$31,$52,$F1,$A1,$F2,$12,$31,$EA,$00
	.db $FD
	.dw Music95Section0
	.db $F2,$12,$F1,$A1,$F2,$32,$F1,$83,$81,$92,$A1
	.db $FD
	.dw Music95Section0
	.db $F1,$E4,$85,$A2,$F2,$51,$42,$31,$12,$F1,$A1,$82,$91,$E0,$04,$72
	.db $80,$00,$E7,$60,$22,$03,$E2,$00,$E8,$00
	.db $FD
	.dw Music95Section1
	.db $39
	.db $FD
	.dw Music95Section2
	.db $F3,$11,$F2,$B2,$91,$E0,$04,$B2,$80,$00,$03,$D0,$E8,$03,$E7,$60
	.db $22
	.db $FD
	.dw Music95Section1
	.db $39,$D1
	.db $FD
	.dw Music95Section2
	.db $F2,$A1,$82,$61,$E0,$34,$72,$80,$00,$03,$E2,$00,$E7,$62,$01,$E8
	.db $00,$8C,$76,$66,$E5,$23,$E7,$60,$01,$53,$43,$33,$23,$12,$11,$F2
	.db $C3,$B3,$F3,$E5,$17,$E2,$31,$FB,$32,$02,$FE,$03,$FB,$52,$02,$FE
	.db $03,$E2,$00,$E0,$04,$74,$83,$18,$F2,$51,$31,$51,$81,$51,$81,$A1
	.db $81,$A1,$F3,$11,$F2,$A1,$F3,$31,$E1,$01,$54,$41,$31,$21,$11,$F2
	.db $C1,$B1,$A1,$91,$D3,$F3,$54,$41,$31,$21,$11,$F2,$C1,$B1,$A1,$91
	.db $E1,$04,$06,$D0,$E2,$00
	.db $FE,$FF
	.dw Music95Ch0Data_Loop
Music95Ch1Data:
	.db $E0,$04,$38,$84,$7A,$0C,$E7,$60,$01,$F3,$55,$64,$F3,$E7,$00,$E5
	.db $A6,$83,$E2,$00
Music95Ch1Data_Loop:
	.db $E0,$04,$38,$84,$36,$E7,$00,$E8,$0C
	.db $FD
	.dw Music95Section0
	.db $F2,$12,$F1,$A1,$F2,$32,$E5,$23,$F1,$83,$E5,$36,$81,$92,$A1
	.db $FD
	.dw Music95Section0
	.db $A2,$F2,$81,$72,$31,$52,$F1,$A1,$F2,$12,$31
	.db $FD
	.dw Music95Section0
	.db $F2,$12,$F1,$A1,$F2,$32,$E5,$23,$F1,$83,$E5,$36,$81,$92,$A1
	.db $FD
	.dw Music95Section0
	.db $E4,$87,$F1,$A2,$F2,$51,$42,$31,$12,$F1,$A1,$82,$91,$E0,$04,$79
	.db $83,$25,$E7,$60,$41,$E2,$00,$E8,$00
	.db $FD
	.dw Music95Section3
	.db $8C,$F3,$3C
	.db $FD
	.dw Music95Section4
	.db $F3,$81,$62,$41,$E2,$00,$E0,$04,$B9,$83,$25,$E2,$37,$E8,$03
	.db $FD
	.dw Music95Section3
	.db $E2,$00,$8C,$F3,$3C,$E4,$84
	.db $FD
	.dw Music95Section4
	.db $F3,$51,$32,$11,$E2,$00,$E8,$00,$E0,$34,$79,$83,$65,$E2,$00,$E7
	.db $61,$01,$E8,$00,$8C,$76,$66,$E7,$60,$01,$E4,$84,$53,$43,$33,$23
	.db $12,$11,$F2,$C3,$B3,$E7,$00,$A3,$F3,$E2,$31,$E5,$17,$FB,$82,$02
	.db $FE,$03,$FB,$A2,$02,$FE,$03,$E2,$76,$F2,$A1,$81,$A1,$F3,$11,$F2
	.db $A1,$F3,$11,$31,$11,$31,$51,$31,$81,$E1,$01,$E2,$00,$A4,$91,$81
	.db $71,$61,$51,$41,$31,$21,$E1,$01,$D5,$A4,$91,$81,$71,$61,$51,$41
	.db $31,$21,$D7,$A4,$91,$81,$71,$61,$51,$41,$31,$21,$E1,$04,$03,$D0
	.db $E2,$00
	.db $FE,$FF
	.dw Music95Ch1Data_Loop
Music95Ch2Data:
	.db $E0,$04,$04,$0C,$E7,$60,$01,$F3,$55,$64,$83,$E7,$00
Music95Ch2Data_Loop:
	.db $E0,$04,$05
	.db $FD
	.dw Music95Section0
	.db $F2,$12,$F1,$A1,$F2,$32,$F1,$83,$81,$92,$A1
	.db $FD
	.dw Music95Section0
	.db $A2,$F2,$81,$72,$31,$52,$F1,$A1,$F2,$12,$31
	.db $FD
	.dw Music95Section0
	.db $F2,$12,$F1,$A1,$F2,$32,$F1,$83,$81,$92,$A1
	.db $FD
	.dw Music95Section0
	.db $A2,$F2,$51,$42,$31,$12,$F1,$A1,$82,$91
	.db $FD
	.dw Music95Section0
	.db $F2,$12,$F1,$A1,$F2,$32,$F1,$83,$81,$92,$A1
	.db $FD
	.dw Music95Section0
	.db $A2,$F2,$81,$72,$31,$52,$F1,$A1,$F2,$12,$31,$F1,$A2,$01,$A3,$C2
	.db $01,$C3,$F2,$12,$01,$12,$F1,$83,$81,$82,$81,$A2,$01,$A3,$C2,$01
	.db $C3,$F2,$12,$01,$12,$F1,$83,$B1,$B2,$B1,$E8,$03
	.db $FD
	.dw Music95Section0
	.db $F2,$12,$F1,$A1,$F2,$32,$F1,$83,$81,$92,$A1
	.db $FD
	.dw Music95Section0
	.db $A2,$F2,$81,$72,$31,$52,$F1,$A1,$F2,$12,$31,$FB,$F1,$A1,$02,$A3
	.db $C1,$02,$C3,$F2,$11,$02,$13,$F1,$81,$02,$83,$FE,$02,$E8,$00,$E8
	.db $00,$F1,$AC,$B6,$C6,$F2,$13,$23,$33,$43,$52,$51,$63,$73,$83,$FB
	.db $82,$02,$FE,$03,$FB,$A2,$02,$FE,$03,$E0,$04,$08,$A1,$81,$A1,$F3
	.db $11,$F2,$A1,$F3,$11,$31,$11,$31,$51,$31,$81,$A3,$09
	.db $FE,$FF
	.dw Music95Ch2Data_Loop
Music95Ch3Data:
	.db $E0,$04,$FB,$91,$81,$71,$FE,$02,$C1,$C1,$C1,$B3,$B3,$C2,$B3,$C1
	.db $B3
Music95Ch3Data_Loop:
	.db $E0,$04
	.db $FD
	.dw Music95Section5
	.db $FD
	.dw Music95Section5
	.db $FD
	.dw Music95Section5
	.db $FB,$C2,$21,$B2,$21,$C2,$21,$B2,$21,$C2,$21,$B2,$C3,$C1,$B2,$21
	.db $FE,$02
	.db $FD
	.dw Music95Section5
	.db $FB,$C2,$21,$B2,$21,$C2,$21,$B2,$21,$C2,$21,$B2,$C2,$21,$C1,$B2
	.db $21,$FE,$02
	.db $FD
	.dw Music95Section5
	.db $FB,$B2,$22,$FE,$06,$91,$91,$91,$81,$81,$81,$71,$71,$71,$C1,$C1
	.db $C1,$B6,$81,$81,$81,$73
	.db $FE,$FF
	.dw Music95Ch3Data_Loop
Music95Section0:
	.db $F1,$A2,$A1,$F2,$52,$F1,$A1,$F2,$42,$F1,$A1,$F2,$32,$F1,$A1
	.db $FF
Music95Section1:
	.db $F3,$52,$41,$32,$A1,$32,$21,$12,$81,$12,$F2,$A1,$F3,$42,$31,$12
	.db $F2,$A1,$F3,$32,$F2,$A1,$8C,$F3
	.db $FF
Music95Section2:
	.db $E0,$24,$36,$84,$27,$E2,$77,$FB,$51,$02,$53,$71,$02,$73,$E7,$61
	.db $05,$85,$E7,$00,$31,$02,$31,$42,$51,$51,$02,$53,$71,$02,$73,$81
	.db $02,$82,$31,$02
	.db $FF
Music95Section3:
	.db $F3,$52,$41,$32,$A1,$32,$21,$12,$81,$12,$F2,$A1,$F3,$42,$31,$12
	.db $F2,$A1,$F3,$32,$F2,$A1,$E5,$A6
	.db $FF
Music95Section4:
	.db $E0,$24,$39,$85,$27,$E2,$B7,$A1,$D7,$A2,$D0,$A3,$C1,$D7,$C2,$D0
	.db $C3,$E7,$61,$05,$F3,$15,$E7,$00,$F2,$81,$D7,$82,$D0,$81,$92,$A1
	.db $F2,$A1,$D7,$A2,$D0,$A3,$C1,$D7,$C2,$D0,$C3,$F3,$E7,$61,$08,$12
	.db $01,$E7,$00,$12,$F2,$82,$01
	.db $FF
Music95Section5:
	.db $C2,$21,$B2,$21,$C2,$21,$B2,$21,$C2,$21,$B2,$C3,$C1,$B2,$21,$C2
	.db $21,$B2,$21,$C2,$21,$B2,$21,$C2,$B1,$C3,$B2,$21,$B2,$21
	.db $FF
Music9DCh0Data:
	.db $E0,$02,$37,$84,$B7,$E8,$81
	.db $FD
	.dw Music9DSection0
Music99Ch0Data:
	.db $E8,$00,$E0,$04,$37,$83,$1A,$E2,$B1,$E7,$56,$04,$FB,$F0,$A2,$F2
	.db $A2,$A2,$B2,$F3,$12,$F2,$B2,$A2,$F0,$A2,$F2,$A2,$F3,$22,$F2,$A2
	.db $A2,$B2,$F0,$A2,$F2,$B2,$A2,$F0,$A2,$F2,$A2,$22,$F3,$A2,$F0,$A2
	.db $F2,$A2,$A2,$B2,$02,$F2,$B2,$A2,$02,$A2,$F3,$22,$F2,$A2,$A2,$B2
	.db $02,$B2,$A2,$02,$A2,$F3,$A2,$F2,$22,$FE,$02
Music99Ch0Data_Loop:
	.db $E0,$24,$B4,$81,$A5,$E2,$00,$E7,$00,$B6,$54,$52,$A2,$92,$E7,$56
	.db $21,$88,$E0,$24,$77,$84,$18,$E2,$7A,$EA,$03,$72,$82,$92,$82,$92
	.db $A2,$92,$A2,$E7,$00,$E0,$24,$B4,$81,$A5,$E2,$00,$EA,$00,$B4,$B2
	.db $84,$72,$62,$52,$46,$E0,$24,$77,$84,$18,$E7,$56,$06,$EA,$03,$E2
	.db $7A,$42,$52,$62,$52,$62,$72,$62,$72,$82,$E0,$24,$B4,$81,$A5,$E7
	.db $00,$E2,$00,$EA,$00,$B6,$54,$52,$A2,$92,$88,$E0,$24,$77,$84,$18
	.db $EA,$03,$E2,$7A,$E7,$56,$07,$72,$82,$92,$82,$92,$A2,$92,$A2,$E2
	.db $00,$E0,$24,$30,$07,$67,$EA,$03,$D2,$E7,$00,$12,$FB,$F1,$D3,$12
	.db $D4,$82,$F2,$12,$FE,$02,$E2,$70,$F1,$12,$F3,$12,$FB,$D3,$F2,$12
	.db $82,$F3,$12,$FE,$02,$F2,$12,$EA,$00,$D0,$E0,$14,$F8,$85,$A6,$E9
	.db $01,$E8,$0C,$E2,$31,$E7,$55,$02,$88,$E2,$FA,$EA,$03,$F0,$82,$D1
	.db $F1,$42,$12,$F0,$82,$82,$82,$D0,$F1,$E2,$00,$98,$E2,$FA,$F0,$92
	.db $F1,$D1,$52,$22,$F0,$92,$92,$92,$D0,$F1,$E7,$00,$E2,$00,$A8,$E2
	.db $FA,$F0,$A2,$F1,$E7,$55,$02,$D1,$32,$32,$F0,$92,$92,$92,$E2,$B0
	.db $E2,$00,$EA,$00,$FB,$D0,$F2,$B2,$D1,$F1,$B2,$B2,$FE,$02,$D0,$F2
	.db $B2,$A2,$F1,$A2,$B2,$E0,$14,$F8,$85,$A6,$E8,$0C,$88,$F0,$EA,$02
	.db $E5,$19,$E2,$FA,$82,$F2,$D1,$42,$12,$F1,$82,$82,$82,$D0,$E5,$A6
	.db $E2,$00,$98,$E2,$FA,$E5,$19,$F0,$92,$D1,$F2,$52,$22,$F1,$E2,$00
	.db $EA,$00,$92,$92,$92,$D0,$E0,$04,$36,$84,$27,$E2,$B0,$B2,$B2,$B2
	.db $F2,$12,$12,$12,$22,$22,$32,$32,$F2,$E5,$00,$E7,$55,$02,$E4,$06
	.db $E2,$70,$D4,$F6,$84,$D0,$E2,$00,$E8,$00
	.db $FE,$FF
	.dw Music99Ch0Data_Loop
Music9DCh1Data:
	.db $E0,$02,$37,$84,$B7
	.db $FD
	.dw Music9DSection0
Music99Ch1Data:
	.db $E0,$24,$30,$06,$B7,$E7,$55,$64,$FB,$F6,$54,$F6,$44,$F6,$84,$F6
	.db $74,$FE,$02
Music99Ch1Data_Loop:
	.db $E0,$24,$39,$84,$26,$E2,$00,$E7,$55,$14,$D1,$82,$72,$82,$E5,$A6
	.db $D0,$B4,$E5,$1F,$B2,$D0,$82,$72,$E4,$06,$E7,$55,$55,$E5,$77,$F6
	.db $58,$E7,$55,$14,$E4,$85,$E5,$1F,$D1,$82,$72,$82,$E5,$A6,$D0,$B4
	.db $E5,$1F,$B2,$D1,$82,$F3,$22,$E5,$87,$F2,$E7,$55,$C5,$E4,$06,$E7
	.db $55,$55,$F6,$B8,$E7,$55,$15,$E4,$85,$E5,$1F,$F2,$82,$72,$82,$E5
	.db $A6,$B4,$E5,$1F,$B2,$82,$72,$E5,$77,$E4,$06,$E7,$55,$55,$F6,$58
	.db $E7,$00,$E0,$24,$30,$07,$76,$EA,$03,$82,$FB,$D0,$F1,$82,$D2,$F2
	.db $12,$82,$FE,$02,$E2,$70,$F1,$82,$F3,$82,$FB,$D0,$F2,$82,$D1,$F3
	.db $12,$82,$FE,$02,$F2,$82,$D0,$EA,$00,$E0,$24,$79,$85,$00,$E8,$0C
	.db $E2,$31,$12,$D6,$F1,$82,$F2,$D0,$12,$02,$E5,$17,$72,$D1,$82,$72
	.db $D0,$72,$D1,$52,$12,$E5,$00,$D0,$22,$D6,$F1,$92,$D0,$F2,$22,$02
	.db $E5,$17,$82,$D1,$92,$82,$D0,$82,$52,$D1,$22,$E5,$00,$D0,$32,$D6
	.db $F1,$A2,$D0,$F2,$32,$02,$E5,$17,$A2,$D1,$62,$92,$D0,$32,$D1,$62
	.db $92,$E2,$B0,$FB,$F2,$D0,$42,$F1,$D1,$42,$42,$FE,$02,$D0,$F2,$42
	.db $32,$F1,$32,$42,$E0,$24,$7A,$87,$00,$E2,$37,$E8,$0C,$12,$D9,$F1
	.db $84,$D0,$F2,$12,$E5,$19,$72,$D1,$82,$72,$D0,$72,$D1,$52,$12,$E5
	.db $00,$D0,$22,$D9,$F1,$94,$D0,$F2,$22,$E5,$19,$82,$D1,$92,$82,$D0
	.db $82,$D1,$52,$22,$D0,$E2,$70,$E2,$31,$42,$B2,$B2,$62,$C2,$C2,$62
	.db $F3,$22,$F2,$82,$F3,$32,$E7,$00,$E2,$70,$E4,$84,$E5,$A4,$E7,$55
	.db $41,$F2,$F6,$84,$E2,$00,$E3,$00,$E8,$00
	.db $FE,$FF
	.dw Music99Ch1Data_Loop
Music9DCh2Data:
	.db $E0,$02,$06,$F0,$91,$A1,$B1,$C1,$F1,$11,$21,$31,$41,$51,$61,$71
	.db $81,$91,$A1,$B1,$C1,$F2,$11,$21,$31,$41,$51,$61,$71,$81,$91,$A1
	.db $B1,$C1,$F3,$11,$21,$31,$41
Music99Ch2Data:
	.db $E0,$14,$05,$FB,$A2,$F3,$71,$01,$F1,$F1,$A2,$F0,$A2,$A2,$F1,$A2
	.db $F0,$A2,$A2,$F1,$A2,$A2,$82,$92,$A2,$F1,$A2,$A2,$F2,$A2,$F1,$A2
	.db $A2,$F2,$22,$F1,$A2,$FE,$04
Music99Ch2Data_Loop:
	.db $E0,$24,$04,$FB,$F2,$12,$12,$12,$F1,$12,$12,$F2,$12,$F1,$12,$F2
	.db $12,$12,$F1,$12,$B2,$C2,$F2,$12,$F1,$12,$12,$F2,$12,$F1,$12,$F2
	.db $12,$12,$F1,$12,$FE,$02,$12,$F1,$12,$F2,$12,$F1,$12,$12,$F2,$12
	.db $F1,$12,$F2,$12,$12,$F1,$12,$F2,$12,$12,$F1,$B2,$C2,$F2,$12,$F1
	.db $B2,$F2,$62,$F1,$B2,$C2,$F1,$12,$E0,$14,$06,$C2,$F2,$FB,$12,$FE
	.db $07,$C2,$F3,$FB,$12,$FE,$07,$F2,$12,$F1,$12,$F2,$12,$02,$12,$82
	.db $F3,$12,$F2,$12,$12,$12,$F2,$22,$F1,$22,$F2,$22,$02,$22,$92,$F3
	.db $22,$F2,$22,$22,$22,$32,$F1,$32,$F2,$32,$02,$32,$32,$F3,$32,$F2
	.db $32,$32,$32,$FB,$42,$32,$32,$FE,$02,$42,$32,$12,$32,$F2,$12,$F3
	.db $12,$F2,$12,$12,$12,$62,$12,$12,$12,$12,$22,$F3,$22,$F2,$22,$22
	.db $22,$62,$22,$22,$22,$22,$F1,$42,$F2,$42,$42,$F1,$52,$F2,$52,$52
	.db $F1,$62,$F2,$62,$F1,$72,$F2,$82,$82,$F1,$82,$82,$F2,$82,$82,$72
	.db $62,$52,$12,$F1,$B2
	.db $FE,$FF
	.dw Music99Ch2Data_Loop
Music9DCh3Data:
	.db $E0,$01,$C1,$17,$98,$88,$C1,$17,$84,$84,$78,$B8,$B8
Music99Ch3Data:
	.db $E0,$04,$FB,$C2,$12,$B2,$12,$12,$B2,$12,$B2,$B2,$C2,$C2,$12,$B2
	.db $12,$12,$B2,$12,$B2,$B2,$12,$FE,$03,$C2,$12,$B2,$12,$12,$B2,$12
	.db $B2,$B2,$C2,$B2,$12,$12,$92,$82,$82,$92,$82,$82,$72
Music99Ch3Data_Loop:
	.db $FB,$C2,$12,$B2,$12,$12,$B2,$12,$B2,$B2,$12,$C2,$C2,$B2,$12,$12
	.db $B2,$12,$B2,$B2,$12,$FE,$03,$FB,$B2,$C2,$C2,$FE,$02,$B2,$C2,$FB
	.db $B2,$C2,$C2,$B2,$82,$82,$72,$72,$FB,$C2,$12,$B2,$12,$12,$C2,$12
	.db $B2,$12,$12,$FE,$03,$91,$91,$82,$72,$82,$72,$72,$82,$72,$C2,$C2
	.db $FB,$C2,$12,$C2,$B2,$C2,$C2,$C2,$82,$82,$72,$FE,$02,$91,$91,$82
	.db $72,$92,$82,$72,$82,$72,$C2,$C2,$B2,$C2,$C2,$B2,$C2,$C2,$B2,$C2
	.db $B2,$B2
	.db $FE,$FF
	.dw Music99Ch3Data_Loop
	.db $FF
Music9DSection0:
	.db $D4,$F0,$91,$A1,$B1,$C1,$D3,$F1,$11,$21,$31,$41,$D2,$51,$61,$71
	.db $81,$D1,$91,$A1,$B1,$C1,$D0,$F2,$11,$21,$31,$41,$51,$61,$71,$81
	.db $91,$A1,$B1,$C1,$F3,$11,$21,$31,$41
	.db $FF
MusicA1Ch0Data:
	.db $E0,$13,$39,$84,$A7,$E7,$60,$11,$E8,$06
	.db $FD
	.dw MusicA1Section1
	.db $E1,$06,$F3,$E7,$60,$02,$10,$E8,$00,$D0,$E0,$06,$38,$82,$88,$E9
	.db $83,$E7,$60,$01
MusicA1Ch0Data_Loop:
	.db $F1,$18,$28
	.db $FE,$FF
	.dw MusicA1Ch0Data_Loop
MusicA1Ch1Data:
	.db $E0,$13,$39,$84,$A7,$E7,$60,$01
	.db $FD
	.dw MusicA1Section1
	.db $E1,$06,$F4,$10,$E8,$00,$D0,$E0,$03,$39,$81,$88,$E7,$60,$01
MusicA1Ch1Data_Loop:
	.db $F0,$10
	.db $FE,$FF
	.dw MusicA1Ch1Data_Loop
MusicA1Ch2Data:
	.db $E0,$13,$04,$E8,$09,$12,$42,$72,$A2,$42,$72,$A2,$72,$A2,$E1
	.db $06,$F2,$10,$E8,$00,$E0,$06,$00,$00,$00,$E7,$60,$01
MusicA1Ch2Data_Loop:
	.db $FD
	.dw MusicA1Section0
	.db $F2,$C0
	.db $FD
	.dw MusicA1Section0
	.db $C0
	.db $FE,$FF
	.dw MusicA1Ch2Data_Loop
MusicA1Section0:
	.db $F3,$14,$24,$14,$24,$54,$24,$14,$24,$14,$24,$14,$24
	.db $FF
MusicA1Ch3Data:
	.db $E0,$06,$B1,$91,$81,$81,$B1,$91,$81,$71,$A1,$A0,$00,$00
MusicA1Ch3Data_Loop:
	.db $FB,$48,$68,$FE,$03,$A0
	.db $FE,$FF
	.dw MusicA1Ch3Data_Loop
MusicA1Section1:
	.db $12,$D1,$42,$72,$A2,$D0,$42,$D1,$72,$A2,$72,$A2
	.db $FF

;UNUSED SPACE
	;$75 bytes of free space available
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF

	.org $C000
