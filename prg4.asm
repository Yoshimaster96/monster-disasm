	.base $8000
	.org $8000
;BANK NUMBER
	.db $38

;;;;;;;;;;;;;;;;;;;;;
;ENEMY VRAM ROUTINES;
;;;;;;;;;;;;;;;;;;;;;
WriteElevatorVRAMStrip38:
	;Save X register
	stx $05
	;Check if already inited
	ldy ElevatorInitFlag
	beq WriteElevatorVRAMStrip38_Init
	jmp WriteEnemyVRAMStrip38_NoInit
WriteElevatorVRAMStrip38_Init:
	;Get VRAM strip data pointer
	sta $02
	tay
	lda ElevatorVRAMStripTable38,y
	asl
	tay
	lda EnemyVRAMStripPointerTable38,y
	sta ElevatorVRAMDataPointer
	sta $00
	lda EnemyVRAMStripPointerTable38+1,y
	sta ElevatorVRAMDataPointer+1
	sta $01
	;Get VRAM buffer address
	asl $02
	ldy $02
	lda ElevatorVRAMStripAddrTable38,y
	sta ElevatorVRAMPointer
	lda ElevatorVRAMStripAddrTable38+1,y
	sta ElevatorVRAMPointer+1
	;Mark inited
	inc ElevatorInitFlag
	jmp WriteEnemyVRAMStrip38_Init

WriteEnemyVRAMStrip38:
	;Save X register
	stx $05
	;Check if already inited
	ldy ElevatorInitFlag
	bne WriteEnemyVRAMStrip38_NoInit
	;Get VRAM strip data pointer
	asl
	tay
	lda EnemyVRAMStripPointerTable38+1,y
	sta $01
	lda EnemyVRAMStripPointerTable38,y
	sta $00
	;Get VRAM buffer address
	ldy #$01
	lda ($00),y
	sta ElevatorVRAMPointer+1
	dey
	lda ($00),y
	sta ElevatorVRAMPointer
	;Mark inited
	inc ElevatorInitFlag
	;Increment VRAM strip data pointer
	lda $00
	clc
	adc #$02
	sta ElevatorVRAMDataPointer
	sta $00
	lda $01
	adc #$00
	sta ElevatorVRAMDataPointer+1
	sta $01
	jmp WriteEnemyVRAMStrip38_Init
WriteEnemyVRAMStrip38_Exit:
	rts
WriteEnemyVRAMStrip38_NoInit:
	lda ElevatorVRAMDataPointer
	sta $00
	lda ElevatorVRAMDataPointer+1
	sta $01
WriteEnemyVRAMStrip38_Init:
	;If not enough space in VRAM buffer, exit early
	lda VRAMBufferOffset
	cmp #$18
	bcs WriteEnemyVRAMStrip38_Exit
	;Clear bytes written counter
	lda #$00
	sta $04
	;Init VRAM buffer row
	lda #$01
	jsr WriteVRAMBufferCmd
	lda ElevatorVRAMPointer
	;Set VRAM buffer address
	jsr WriteVRAMBufferCmd_AnyX
	lda ElevatorVRAMPointer+1
	jsr WriteVRAMBufferCmd_AnyX
	jmp WriteEnemyVRAMStrip38_InitNoC
WriteEnemyVRAMStrip38_Loop:
	;Init VRAM buffer row
	lda #$01
	jsr WriteVRAMBufferCmd
	;Set VRAM buffer address
	ldy #$00
	lda ($00),y
	jsr WriteVRAMBufferCmd_AnyX
	sta ElevatorVRAMPointer
	iny
	lda ($00),y
	jsr WriteVRAMBufferCmd_AnyX
	sta ElevatorVRAMPointer+1
	;Increment VRAM strip data pointer
	lda #$02
	clc
	adc $00
	sta $00
	bcc WriteEnemyVRAMStrip38_InitNoC
	inc $01
WriteEnemyVRAMStrip38_InitNoC:
	;Check for end all command
	ldy #$00
	lda ($00),y
	beq WriteEnemyVRAMStrip38_EndAll
	;Check for end strip command
	cmp #$80
	beq WriteEnemyVRAMStrip38_EndStrip
	;Check for RLE mode
	tay
	bpl WriteEnemyVRAMStrip38_RLE
	;Get strip length
	and #$7F
	sta $02
	;Write immediate VRAM strip
	ldy #$01
	;Check for RLE increment mode
	and #$40
	bne WriteEnemyVRAMStrip38_RLEInc
WriteEnemyVRAMStrip38_ImmLoop:
	;Set byte in VRAM
	lda ($00),y
	jsr WriteVRAMBufferCmd_AnyX
	;Loop for each byte
	inc $04
	cpy $02
	beq WriteEnemyVRAMStrip38_ImmEnd
	iny
	bne WriteEnemyVRAMStrip38_ImmLoop
WriteEnemyVRAMStrip38_ImmEnd:
	;Increment VRAM strip data pointer
	lda #$01
	clc
	adc $02
WriteEnemyVRAMStrip38_IncAddr:
	clc
	adc $00
	sta $00
	bcc WriteEnemyVRAMStrip38_NextNoC
	inc $01
WriteEnemyVRAMStrip38_NextNoC:
	lda $02
	clc
	adc ElevatorVRAMPointer
	sta ElevatorVRAMPointer
	lda ElevatorVRAMPointer+1
	adc #$00
	sta ElevatorVRAMPointer+1
	;Check if enough space in VRAM buffer to continue
	lda $04
	cmp #$28
	bcc WriteEnemyVRAMStrip38_NoOver
	;Save VRAM strip data pointer
	lda $00
	sta ElevatorVRAMDataPointer
	lda $01
	sta ElevatorVRAMDataPointer+1
	;End VRAM buffer
	jsr WriteVRAMBufferCmd_End
	;Restore X register
	ldx $05
	rts
WriteEnemyVRAMStrip38_NoOver:
	jmp WriteEnemyVRAMStrip38_InitNoC
WriteEnemyVRAMStrip38_RLE:
	;Write RLE VRAM strip
	ldy #$01
	sta $02
	lda ($00),y
	sta $06
	ldy $02
WriteEnemyVRAMStrip38_RLELoop:
	;Set byte in VRAM
	lda $06
	jsr WriteVRAMBufferCmd_AnyX
	;Loop for each byte
	inc $04
	dey
	bne WriteEnemyVRAMStrip38_RLELoop
WriteEnemyVRAMStrip38_RLEEnd:
	;Increment VRAM strip data pointer
	lda #$02
	bne WriteEnemyVRAMStrip38_IncAddr
WriteEnemyVRAMStrip38_EndStrip:
	;End VRAM buffer
	jsr WriteVRAMBufferCmd_End
	;Increment VRAM strip data pointer
	inc $00
	bne WriteEnemyVRAMStrip38_EndNoC
	inc $01
WriteEnemyVRAMStrip38_EndNoC:
	jmp WriteEnemyVRAMStrip38_Loop
WriteEnemyVRAMStrip38_EndAll:
	;Clear elevator inited flag
	lda #$00
	sta ElevatorInitFlag
	;End VRAM buffer
	jsr WriteVRAMBufferCmd_End
	;Restore X register
	ldx $05
	rts
WriteEnemyVRAMStrip38_RLEInc:
	;Write RLE increment VRAM strip
	lda ($00),y
	sta $03
	lda $02
	and #$3F
	sta $02
	tay
WriteEnemyVRAMStrip38_RLEIncLoop:
	;Set byte in VRAM
	lda $03
	jsr WriteVRAMBufferCmd_AnyX
	;Loop for each byte
	inc $03
	inc $04
	dey
	bne WriteEnemyVRAMStrip38_RLEIncLoop
	;Increment VRAM strip data pointer
	jmp WriteEnemyVRAMStrip38_RLEEnd

EnemyVRAMStripPointerTable38:
	.dw Level4ElevatorVRAMData0	;$00 \Level 4 elevator
	.dw Level4ElevatorVRAMData1	;$01 |
	.dw Level4ElevatorVRAMData2	;$02 /
	.dw Level3BossVRAMData0		;$03 \Level 3 boss
	.dw Level3BossVRAMData1		;$04 |
	.dw Level3BossVRAMData2		;$05 /
	.dw Level4ElevatorVRAMData3	;$06  Level 4 elevator
	.dw Level6ElevatorVRAMData0	;$07 \Level 6 elevator
	.dw Level6ElevatorVRAMData1	;$08 |
	.dw Level6ElevatorVRAMData2	;$09 /
	.dw Nametable0EData		;$0A  Level 3 boss
	.dw Level4BossVRAMData0		;$0B  Level 4 boss
	.dw TVFaceVRAMData		;$0C  TV face
	.dw Level4BossVRAMData1		;$0D  Level 4 boss
	.dw TVStaticVRAMData		;$0E  TV static
	.dw ClearDialogVRAMData38	;$0F  Clear dialog/HUD
	.dw Nametable12Data		;$10  TV top edge
	.dw TVFaceDeathVRAMData		;$11  TV face death
ElevatorVRAMStripAddrTable38:
	.dw $2080,$2300,$2940,$22C0,$2AC0,$22C0,$2AC0,$22C0,$22C0
ElevatorVRAMStripTable38:
	.db $07,$07,$07,$08,$08,$09,$09,$09,$07
ClearDialogVRAMData38:
	.dw $2B00
	.db $40,$00,$40,$00,$40,$00
	.db $80
	.dw $2BF0
	.db $10,$00
	.db $00
Level4ElevatorVRAMData0:
	.dw $2080
	.db $07,$67,$81,$36,$07,$66,$81,$37,$07,$67,$81,$36,$07,$66,$81,$37
	.db $06,$00,$81,$38,$81,$01,$06,$01,$81,$39,$81,$00,$06,$00,$81,$38
	.db $81,$01,$06,$01,$81,$39,$81,$00
	.db $80
	.dw $23C8
	.db $08,$5F
	.db $00
Level4ElevatorVRAMData1:
	.dw $2300
	.db $07,$67,$81,$36,$07,$66,$81,$37,$07,$67,$81,$36,$07,$66,$81,$37
	.db $06,$00,$81,$38,$81,$01,$06,$01,$81,$39,$81,$00,$06,$00,$81,$38
	.db $81,$01,$06,$01,$81,$39,$81,$00
	.db $80
	.dw $23F0
	.db $08,$5F
	.db $00
Level4ElevatorVRAMData2:
	.dw $2940
	.db $07,$67,$81,$36,$07,$66,$81,$37,$07,$67,$81,$36,$07,$66,$81,$37
	.db $06,$00,$81,$38,$81,$01,$06,$01,$81,$39,$81,$00,$06,$00,$81,$38
	.db $81,$01,$06,$01,$81,$39,$81,$00
	.db $80
	.dw $2BD0
	.db $08,$F5
	.db $00
Level3BossVRAMData0:
	.dw $2A50
	.db $C2,$17
	.db $80
	.dw $2A6F
	.db $81,$07,$C4,$1C
	.db $80
	.dw $2A8E
	.db $C2,$09,$C4,$21
	.db $80
	.dw $2AAE
	.db $02,$0C,$C2,$26
	.db $80
	.dw $2ACE
	.db $C2,$0F,$C3,$2B
	.db $00
Level3BossVRAMData1:
	.dw $2A50
	.db $C2,$35,$01,$19
	.db $80
	.dw $2A6F
	.db $C5,$37
	.db $80
	.dw $2A8D
	.db $01,$08,$C6,$3C
	.db $80
	.dw $2AAE
	.db $C4,$42
	.db $80
	.dw $2ACE
	.db $C5,$46
	.db $00
Level3BossVRAMData2:
	.dw $2A51
	.db $C2,$4B
	.db $80
	.dw $2A6E
	.db $85,$4D,$4E,$38,$4F,$50
	.db $80
	.dw $2A8D
	.db $C3,$51
	.db $00
Level4ElevatorVRAMData3:
	.dw $22C0
	.db $07,$67,$81,$36,$07,$66,$81,$37,$07,$67,$81,$36,$07,$66,$81,$37
	.db $06,$00,$81,$38,$81,$01,$06,$01,$81,$39,$81,$00,$06,$00,$81,$38
	.db $81,$01,$06,$01,$81,$39,$81,$00
	.db $80
	.dw $23E8
	.db $08,$F5
	.db $00
Level4BossVRAMData1:
	.dw $2800
	.db $40,$00,$40,$00,$40,$00,$40,$00,$40,$00,$40,$00,$40,$00,$40,$00
	.db $40,$00,$40,$00,$40,$00
Level6ElevatorVRAMData0:
	.db $90,$D0,$D1,$D0,$D1,$D0,$D1,$D0,$D1,$D0,$D1,$D0,$D1,$D0,$D1,$D0
	.db $D1,$90,$D0,$D1,$D0,$D1,$D0,$D1,$D0,$D1,$D0,$D1,$D0,$D1,$D0,$D1
	.db $D0,$D1,$90,$D2,$D3,$D2,$D3,$D2,$D3,$D2,$D3,$D2,$D3,$D2,$D3,$D2
	.db $D3,$D2,$D3,$90,$D2,$D3,$D2,$D3,$D2,$D3,$D2,$D3,$D2,$D3,$D2,$D3
	.db $D2,$D3,$D2,$D3
	.db $00
Level6ElevatorVRAMData1:
	.db $C3,$0F,$09,$11,$09,$11,$09,$11,$C2,$0D,$C2,$16,$09,$11,$09,$11
	.db $0A,$11,$82,$14,$18
	.db $00
Level6ElevatorVRAMData2:
	.db $C2,$0F,$09,$00,$09,$00,$0A,$00,$C2,$0D,$C2,$0F,$09,$00,$09,$00
	.db $0A,$00,$C2,$0D,$00,$2D,$28,$C3,$00,$C3,$14
	.db $80
	.dw $284D
	.db $83,$00,$03,$04,$C5,$17
	.db $80
	.dw $286D
	.db $C3,$05,$C5,$1C
	.db $80
	.dw $288D
	.db $C3,$08,$C5,$21
	.db $80
	.dw $28AD
	.db $C3,$0B,$C5,$26
	.db $80
	.dw $28CD
	.db $C3,$0E,$C5,$2B
	.db $80
	.dw $28ED
	.db $C3,$11,$C5,$30
	.db $00
Level4BossVRAMData0:
	.dw $2000
	.db $40,$00,$40,$00,$40,$00,$40,$00,$40,$00,$40,$00,$40,$00,$40,$00
	.db $40,$00,$40,$00
	.db $80
	.dw $2AC0
	.db $40,$00,$40,$00,$40,$00,$40,$00
	.db $00

;;;;;;;;;;;;;;;;
;ENEMY ROUTINES;
;;;;;;;;;;;;;;;;
;ENEMY HITBOX SIZE DATA
EnemyCollSizeTable:
	.db $F3,$19,$DB,$48
	.db $EF,$21,$E3,$39
	.db $F6,$13,$EC,$26
	.db $F2,$1B,$E1,$3C
	.db $F1,$1D,$D9,$4C
	.db $EA,$2B,$E8,$2E
	.db $F9,$0D,$EF,$20
	.db $EB,$29,$E1,$3C
	.db $E6,$33,$E3,$39
	.db $E2,$3B,$E8,$2E
	.db $E2,$3B,$ED,$24
	.db $EC,$27,$E8,$2E
	.db $E2,$3B,$D7,$50
	.db $EA,$2B,$D7,$50
	.db $E2,$3B,$D8,$4E
	.db $EB,$29,$B8,$8E
	.db $F2,$1B,$E8,$2E
	.db $BC,$87,$E8,$2E
AttackCollSizePointerTable:
	.dw AttackCollSizeTable
	.dw AttackKeyCollSizeTable
AttackCollSizeTable:
	.db $F0,$1E,$E2,$3A
	.db $EA,$28,$E7,$30
	.db $F2,$1A,$F2,$1A
	.db $ED,$24,$E7,$30
	.db $EB,$28,$DF,$40
	.db $EB,$28,$DF,$40
	.db $F4,$16,$F4,$16
	.db $E7,$30,$E7,$30
	.db $E3,$38,$E7,$30
	.db $DF,$40,$EF,$20
	.db $DF,$40,$F4,$16
	.db $E7,$30,$EF,$20
	.db $DF,$40,$DE,$42
	.db $E7,$30,$DE,$42
	.db $D7,$50,$D7,$50
	.db $E8,$2E,$BF,$80
	.db $F0,$1E,$F0,$1E
AttackKeyCollSizeTable:
	.db $F0,$1E,$E4,$36
	.db $EB,$28,$E9,$2C
	.db $F2,$1A,$F4,$16
	.db $ED,$24,$E9,$2C
	.db $EB,$28,$E1,$3C
	.db $EB,$28,$E1,$3C
	.db $F4,$16,$F6,$12
	.db $E7,$30,$E9,$2C
	.db $E3,$38,$E9,$2C
	.db $DF,$40,$F1,$1C
	.db $DF,$40,$F6,$12
	.db $E7,$30,$F1,$1C
	.db $DF,$40,$E9,$2C
	.db $CF,$60,$E0,$3E
	.db $D7,$50,$D9,$4C
	.db $E8,$2E,$C1,$7C
	.db $F0,$1E,$F2,$1A
	.db $B9,$8C,$F1,$1C

AttackDamageTable:
	.db $00,$00,$00,$00,$06,$07,$08
CheckAttackCollision:
	;Get enemy hitbox size data table offset
	lda Enemy_Flags,x
	and #$1F
	asl
	asl
	sta $08
	;Get enemy hitbox position
	lda Enemy_X+$08,x
	lsr
	sta $09
	lda Enemy_Y+$08,x
	sta $0A
	;If enemy invincibility timer not 0, don't check for collision
	lda Enemy_InvinTimer,x
	bne CheckAttackCollision_Invin
	;Check if attack collision is enabled
	lda Enemy_Flags,x
	bmi CheckAttackCollision_Invin
	;Loop for each player
	ldy #$01
CheckAttackCollision_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$03
	bne CheckAttackCollision_PlayerNext
	;Check if player is offscreen vertically
	lda Enemy_YHi,y
	bne CheckAttackCollision_PlayerNext
	;Check for enemy ID $F4-$FF
	lda Enemy_ID,x
	cmp #$F4
	bcs CheckAttackCollision_Enemy
	;If player in death state, don't check for collision
	lda PlayerState,y
	cmp #$0B
	beq CheckAttackCollision_PlayerNext
	;Check for enemy ID $F0-$F3
	lda Enemy_ID,x
	cmp #$F0
	bcs CheckAttackCollision_Enemy
	;Check for key enemy slots
	cpx #$02
	bcc CheckAttackCollision_Enemy
	;If player invincibility timer not 0, don't check for collision
	lda PlayerInvinTimer,y
	bne CheckAttackCollision_PlayerNext
CheckAttackCollision_Enemy:
	;Check for collision
	sty $0B
	jsr CheckEnemyCollision
	ldx CurEnemyIndex
	ldy $0B
CheckAttackCollision_PlayerNext:
	;Loop player
	dey
	bpl CheckAttackCollision_PlayerLoop
CheckAttackCollision_Invin:
	;Check if enemy collision is enabled
	lda Enemy_Flags,x
	asl
	bpl CheckAttackCollision_Attack
	rts
CheckAttackCollision_Attack:
	;Loop for each attack
	ldx #$07
CheckAttackCollision_AttackLoop:
	;Check if enemy offscreen
	lda Enemy_XHi+$02,x
	ora Enemy_YHi+$02,x
	bne CheckAttackCollision_AttackNext
	;Check if player attack is active
	lda PlayerAttackAnimOffs,x
	beq CheckAttackCollision_AttackNext
	bmi CheckAttackCollision_AttackNext
	;Get enemy hitbox size data pointer for normal attack
	ldy #$00
	;Check for key enemy slots
	cpx #$06
	bcc CheckAttackCollision_NoKey
	;Check for key release task
	lda Enemy_Mode-$06,x
	cmp #$03
	bne CheckAttackCollision_AttackNext
	;Get enemy hitbox size data pointer for key attack
	ldy #$02
CheckAttackCollision_NoKey:
	;Get enemy hitbox size data pointer
	lda AttackCollSizePointerTable,y
	sta $0E
	lda AttackCollSizePointerTable+1,y
	sta $0F
	;Check collision X
	ldy $08
	lda Enemy_X+$02,x
	sbc ($0E),y
	ror
	sbc $09
	bmi CheckAttackCollision_AttackNext
	asl
	iny
	cmp ($0E),y
	bcs CheckAttackCollision_AttackNext
	;Check collision Y
	lda Enemy_Y+$02,x
	iny
	sbc ($0E),y
	bcs CheckAttackCollision_AttackNext
	sbc $0A
	bcc CheckAttackCollision_AttackNext
	iny
	cmp ($0E),y
	bcc CheckAttackCollision_Hit
CheckAttackCollision_AttackNext:
	;Loop enemy
	dex
	bpl CheckAttackCollision_AttackLoop
CheckAttackCollision_Exit:
	ldx CurEnemyIndex
	rts
CheckAttackCollision_Hit:
	;Check for boss mode
	ldy CurEnemyIndex
	lda Enemy_HP,y
	bit SpriteBossModeFlag
	bmi CheckAttackCollision_Damage
	;Check for key enemy slots
	cpx #$06
	bcs CheckAttackCollision_KeyHit
CheckAttackCollision_Damage:
	;Do damage to enemy
	sec
	sbc #$01
	sta Enemy_HP,y
	;If enemy HP < 0, kill enemy
	bcs CheckAttackCollision_NoDeath
CheckAttackCollision_KeyHit:
	;Check for key enemy slots
	txa
	cmp #$06
	bcc CheckAttackCollision_NoKeyDeath
	;Set associated player for key attack
	lda Enemy_Temp2-$06,x
	asl
	asl
CheckAttackCollision_NoKeyDeath:
	;Set associated player for normal attack
	cmp #$03
	rol
	and #$01
	sta Enemy_Temp5,y
	;Save killed enemy ID
	lda Enemy_ID,y
	sta Enemy_Temp2,y
	;Check for boss enemy slot
	cpy #$02
	bne CheckAttackCollision_SetExplosion
	;Check for boss mode
	lda SpriteBossModeFlag
	bne CheckAttackCollision_NoExplosion
CheckAttackCollision_SetExplosion:
	;Set enemy ID $01 (Explosion)
	lda #ENEMY_EXPLOSION
	sta Enemy_ID,y
CheckAttackCollision_NoExplosion:
	;Next task ($00: Init)
	lda #$00
	sta Enemy_Mode,y
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|EF_ALLOWOFFSCREEN)
	sta Enemy_Flags,y
	jmp CheckAttackCollision_Exit
CheckAttackCollision_NoDeath:
	;Check for boss enemy slot
	cpy #$02
	bne CheckAttackCollision_NoBossSE
	;Check for boss mode
	lda SpriteBossModeFlag
	beq CheckAttackCollision_NoBossSE
	;Play sound
	lda #SE_BOSSHIT
	bne CheckAttackCollision_SetSE
CheckAttackCollision_NoBossSE:
	;Play sound
	lda #SE_ENEMYHIT
CheckAttackCollision_SetSE:
	jsr LoadSound
	;Set enemy invincibility timer
	lda #$1A
	sta Enemy_InvinTimer,y
	;Loop attack
	jmp CheckAttackCollision_AttackNext

CheckEnemyCollision:
	;Get player position
	lda Enemy_X,y
	sta $0C
	lda Enemy_Y,y
	sta $0D
	;Check collision X
	ldy $08
	clc
	lda $0C
	sbc EnemyCollSizeTable,y
	ror
	sec
	sbc $09
	bmi CheckEnemyCollision_Exit
	asl
	cmp EnemyCollSizeTable+1,y
	bcs CheckEnemyCollision_Exit
	;Check collision Y
	lda $0D
	sbc EnemyCollSizeTable+2,y
	bcs CheckEnemyCollision_Exit
	sec
	sbc $0A
	bcc CheckEnemyCollision_Exit
	;Get player hitbox height based on ducking state
	sta $00
	ldx $0B
	lda PlayerState,x
	sbc #$06
	cmp #$02
	lda $00
	bcs CheckEnemyCollision_NoDuck
	adc #$0A
CheckEnemyCollision_NoDuck:
	cmp EnemyCollSizeTable+3,y
	bcc CheckEnemyCollision_Hit
CheckEnemyCollision_Exit:
	rts
CheckEnemyCollision_Hit:
	;Check for key enemy slots
	ldy CurEnemyIndex
	cpy #$02
	bcs CheckEnemyCollision_NoKey
	;Get key index
	tya
	and #$01
	beq CheckEnemyCollision_Key1
	lda #$40
CheckEnemyCollision_Key1:
	;Set player hit flags for key collision
	ora #$80
	ora PlayerHitFlags,x
	sta PlayerHitFlags,x
	rts
CheckEnemyCollision_NoKey:
	;Check for enemy ID $F0-$FF
	lda Enemy_ID,y
	cmp #$F0
	bcs CheckEnemyCollision_F0
	;Check for level 5 boss fire
	ldy #$01
	cmp #ENEMY_LEVEL5BOSSFIRE
	beq CheckEnemyCollision_Freeze43
	;Check for level 3 boss fire
	cmp #ENEMY_LEVEL2BOSSFIRE
	bne CheckEnemyCollision_NoFreeze
CheckEnemyCollision_Freeze43:
	iny
CheckEnemyCollision_NoFreeze:
	;If player X velocity < $03, skip this part
	lda PlayerXVel,x
	bmi CheckEnemyCollision_SetHitFlags
	cmp #$03
	bcc CheckEnemyCollision_SetHitFlags
	;Check for 45 deg. slope left
	lda PlayerCollTypeBottom,x
	bmi CheckEnemyCollision_SetHitFlags
	cmp #$04
	beq CheckEnemyCollision_PowerHit
CheckEnemyCollision_SetHitFlags:
	;Set player hit flags for freeze collision
	tya
	ora PlayerHitFlags,x
	sta PlayerHitFlags,x
	rts
CheckEnemyCollision_F0:
	;Check for enemy ID $F4-$FF
	cmp #$F4
	bcs CheckEnemyCollision_Platform
	;Set associated player for item
	txa
	sta Enemy_Temp2,y
	;Clear enemy HP
	lda #$FF
	sta Enemy_HP,y
	rts
CheckEnemyCollision_Platform:
	;Set associated player for platform
	inx
	txa
	ora Enemy_Temp2,y
	sta Enemy_Temp2,y
	rts
CheckEnemyCollision_PowerHit:
	;Save killed enemy ID
	ldy CurEnemyIndex
	lda Enemy_ID,y
	sta Enemy_Temp2,y
	;Set associated player for power run attack
	txa
	sta Enemy_Temp3,y
	;Set enemy ID $01 (Explosion)
	lda #ENEMY_EXPLOSION
	sta Enemy_ID,y
	;Next task ($00: Init)
	lda #$00
	sta Enemy_Mode,y
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|EF_ALLOWOFFSCREEN)
	sta Enemy_Flags,y
	rts

;ENEMY ANIMATION DATA
EnemyAnimationTimerTable:
	.db $10,$04,$04,$04,$04,$14,$06,$04,$04,$06,$04,$02,$10,$08,$08,$08
	.db $08,$04,$06,$08,$02,$04,$0E,$04,$18,$08,$04,$04,$12,$02,$06,$06
	.db $04,$0A,$00,$00,$06,$02,$06,$04,$00,$08,$08,$06,$08,$00,$06,$03
	.db $00,$08,$04,$06,$08,$06,$02,$06,$04,$09,$04,$05,$05,$08,$06,$06
	.db $06,$06,$06,$0C,$00,$00,$04,$00,$00,$08,$04,$00,$08,$00,$00,$04
	.db $04,$08,$08,$03,$04,$0C,$02,$02,$08,$00,$00,$00,$00,$00,$00,$00
EnemyAnimationOffsTable:
	.db $02,$05,$03,$02,$02,$02,$03,$04,$02,$02,$08,$02,$02,$02,$04,$02
	.db $02,$04,$02,$02,$02,$02,$02,$03,$02,$03,$02,$02,$02,$02,$04,$02
	.db $04,$02,$00,$00,$02,$02,$02,$02,$00,$02,$02,$03,$02,$00,$02,$0B
	.db $00,$03,$02,$02,$03,$04,$02,$02,$02,$08,$04,$0B,$0B,$04,$05,$02
	.db $02,$02,$02,$03,$00,$00,$04,$00,$00,$02,$07,$00,$02,$00,$00,$04
	.db $02,$02,$02,$04,$02,$04,$03,$03,$04,$00,$00,$00,$00,$00,$00,$00
EnemyAnimationDataOffsetTable:
	;$00
	.db $1B,$02,$07,$10,$0A,$0C,$14,$17,$12,$25,$1D,$0E,$27,$2F,$4F,$2B
	.db $2D,$31,$35,$37,$39,$3B,$3D,$43,$29,$4C,$53,$55,$57,$46,$48,$59
	.db $3F,$8B,$00,$00,$5B,$5D,$5F,$61,$00,$63,$65,$67,$6A,$00,$6C,$6E
	.db $00,$79,$7C,$7E,$88,$80,$84,$86,$8B,$8D,$AF,$95,$A0,$AB,$B3,$B8
	.db $BA,$59,$BC,$BE,$00,$00,$C1,$00,$00,$C7,$C9,$00,$D0,$00,$00,$D2
	;$50
	.db $00,$00,$02,$14,$12,$0E,$08,$0B,$04
EnemyAnimationSprite00Table:
	;$00
	.db $0C,$0D
	;$02
	.db $01,$02,$03,$04,$05
	;$07
	.db $01,$07,$00
	;$0A
	.db $0C,$0D
	;$0C
	.db $1B,$1C
	;$0E
	.db $00,$17
	;$10
	.db $19,$1A
	;$12
	.db $09,$0A
	;$14
	.db $0E,$0F,$10
	;$17
	.db $13,$14,$15,$16
	;$1B
	.db $09,$0B
	;$1D
	.db $0E,$0E,$0E,$11,$12,$12,$12,$12
	;$25
	.db $1F,$20
	;$27
	.db $08,$0E
	;$29
	.db $2C,$2D
	;$2B
	.db $21,$22
	;$2D
	.db $30,$31
	;$2F
	.db $30,$32
	;$31
	.db $55,$56
	;$33
	.db $57,$58
	;$35
	.db $24,$25
	;$37
	.db $28,$29
	;$39
	.db $53,$54
	;$3B
	.db $26,$27
	;$3D
	.db $17,$18
	;$3F
	.db $14,$15,$16,$15
	;$43
	.db $1C,$1D,$1E
	;$46
	.db $43,$44
	;$48
	.db $40,$41,$42,$41
	;$4C
	.db $45,$46,$47
	;$4F
	.db $47,$46,$45,$00
	;$53
	.db $4A,$4B
	;$55
	.db $38,$39
	;$57
	.db $3A,$3B
	;$59
	.db $3D,$3E
	;$5B
	.db $33,$34
	;$5D
	.db $35,$36
	;$5F
	.db $60,$61
	;$61
	.db $5D,$5E
	;$63
	.db $5B,$5C
	;$65
	.db $63,$62
	;$67
	.db $64,$65,$66
	;$6A
	.db $59,$5A
	;$6C
	.db $67,$68
	;$6E
	.db $00,$4C,$4D,$4E,$4F,$50,$4F,$4E,$4D,$4C,$00
	;$79
	.db $6F,$6F,$6E
	;$7C
	.db $6C,$6D
	;$7E
	.db $7B,$7C
	;$80
	.db $75,$76,$77,$76
	;$84
	.db $51,$52
	;$86
	.db $78,$79
	;$88
	.db $78,$7A,$78
	;$8B
	.db $80,$81
	;$8D
	.db $28,$28,$28,$2C,$28,$2C,$28,$2C
	;$95
	.db $28,$28,$28,$28,$28,$28,$29,$2A,$2B,$28,$28
	;$A0
	.db $28,$28,$2F,$2F,$2F,$2F,$2F,$30,$31,$31,$28
	;$AB
	.db $2C,$2D,$2D,$2E,$32,$33,$34,$35
	;$B3
	.db $00,$1F,$20,$21,$22
	;$B8
	.db $36,$37
	;$BA
	.db $38,$39
	;$BC
	.db $3A,$3B
	;$BE
	.db $3E,$3F,$40
	;$C1
	.db $70,$71,$72,$73,$71,$74
	;$C7
	.db $85,$86
	;$C9
	.db $88,$89,$8A,$8B,$8A,$8B,$00
	;$D0
	.db $82,$83
	;$D2
	.db $5E,$5F,$5E,$00
EnemyAnimationSprite50Table:
	;$00
	.db $A4,$A5
	;$02
	.db $8C,$8D
	;$04
	.db $41,$42,$43,$42
	;$08
	.db $45,$46,$47
	;$0B
	.db $48,$49,$4A
	;$0E
	.db $60,$61,$62,$61
	;$12
	.db $69,$68
	;$14
	.db $63,$64,$65,$00

UpdateEnemyAnimation:
	;Update enemy animation based on enemy ID
	ldy Enemy_ID,x
UpdateEnemyAnimation_AnyY:
	;Decrement animation timer, check if < 0
	dec Enemy_AnimTimer,x
	bpl UpdateEnemyAnimation_Exit
	;Set animation timer
	lda EnemyAnimationTimerTable,y
	sta Enemy_AnimTimer,x
	;Check for end of animation
	inc Enemy_AnimOffs,x
	lda Enemy_AnimOffs,x
	cmp EnemyAnimationOffsTable,y
	bcc UpdateEnemyAnimation_NoC
	;Reset enemy animation offset
	lda #$00
	sta Enemy_AnimOffs,x
UpdateEnemyAnimation_NoC:
	;Get animation data index
	clc
	adc EnemyAnimationDataOffsetTable,y
	;Check for enemy ID $50-$FF
	cpy #$50
	tay
	bcs UpdateEnemyAnimation_Anim50
	;Set enemy sprite ($00-$4F)
	lda EnemyAnimationSprite00Table,y
	sta Enemy_Sprite+$08,x
UpdateEnemyAnimation_Exit:
	rts
UpdateEnemyAnimation_Anim50:
	;Set enemy sprite ($50-$FF)
	lda EnemyAnimationSprite50Table,y
	sta Enemy_Sprite+$08,x
	rts

EnemyJumpTableTable:
	.dw Enemy01JumpTable	;$01  Explosion
	.dw Enemy02JumpTable	;$02  Explosion 2
	.dw Enemy03JumpTable	;$03  Witch fire
	.dw Enemy04JumpTable	;$04  Zombie
	.dw Enemy05JumpTable	;$05  Winged panther
	.dw Enemy06JumpTable	;$06  Skeleton
	.dw Enemy07JumpTable	;$07  Skeleton fire
	.dw Enemy08JumpTable	;$08  Beast
	.dw Enemy09JumpTable	;$09  Hunchback
	.dw Enemy0AJumpTable	;$0A  Witch spawner
	.dw Enemy0BJumpTable	;$0B  Witch
	.dw Enemy0CJumpTable	;$0C  Level 1 boss
	.dw Enemy0DJumpTable	;$0D  Level 1 boss fire
	.dw Enemy0EJumpTable	;$0E  Roc fire
	.dw Enemy0FJumpTable	;$0F  Ghost
	.dw Enemy10JumpTable	;$10  Ghoul
	.dw Enemy11JumpTable	;$11  Ghoul fire
	.dw Enemy12JumpTable	;$12  Ogre
	.dw Enemy13JumpTable	;$13  Goblin
	.dw Enemy14JumpTable	;$14  Goblin fire
	.dw Enemy15JumpTable	;$15  Cerberus
	.dw Enemy16JumpTable	;$16  Level 2 boss
	.dw Enemy17JumpTable	;$17  Level 2 boss fire
	.dw Enemy18JumpTable	;$18  Roc
	.dw Enemy19JumpTable	;$19  Haniver
	.dw Enemy1AJumpTable	;$1A  Haniver fire
	.dw Enemy1BJumpTable	;$1B  Golf ball
	.dw Enemy1CJumpTable	;$1C  Catoblepas
	.dw Enemy1DJumpTable	;$1D  Triton
	.dw Enemy1EJumpTable	;$1E  Charon spawner
	.dw Enemy1FJumpTable	;$1F  Charon falling
	.dw Enemy20JumpTable	;$20  Item key
	.dw Enemy21JumpTable	;$21  Item screw
	.dw Enemy22JumpTable	;$22  UNUSED
	.dw Enemy22JumpTable	;$23  UNUSED
	.dw Enemy24JumpTable	;$24  Hydra
	.dw Enemy25JumpTable	;$25  Hydra fire
	.dw Enemy26JumpTable	;$26  Hobgoblin
	.dw Enemy27JumpTable	;$27  Red Cap
	.dw Enemy28JumpTable	;$28  Harpy spawner
	.dw Enemy29JumpTable	;$29  Harpy
	.dw Enemy2AJumpTable	;$2A  Chimera
	.dw Enemy2BJumpTable	;$2B  Chimera fire
	.dw Enemy2CJumpTable	;$2C  Baba Yaga
	.dw Enemy2DJumpTable	;$2D  Warp
	.dw Enemy2EJumpTable	;$2E  Kali
	.dw Enemy2FJumpTable	;$2F  Kali fire
	.dw Enemy30JumpTable	;$30  Harpy spawner 2
	.dw Enemy31JumpTable	;$31  Manticore
	.dw Enemy32JumpTable	;$32  BG cyclops
	.dw Enemy33JumpTable	;$33  Cockatrice
	.dw Enemy34JumpTable	;$34  BG floor scroll
	.dw Enemy35JumpTable	;$35  Karnack
	.dw Enemy36JumpTable	;$36  Stove flame
	.dw Enemy37JumpTable	;$37  Tengu
	.dw Enemy38JumpTable	;$38  Coatlicue
	.dw Enemy39JumpTable	;$39  Level 4 boss
	.dw Enemy3AJumpTable	;$3A  Level 4 boss fire
	.dw Enemy3BJumpTable	;$3B  Level 3 boss
	.dw Enemy3CJumpTable	;$3C  Level 3 boss part
	.dw Enemy3DJumpTable	;$3D  Level 4 elevator
	.dw Enemy3EJumpTable	;$3E  Level 3 boss splash
	.dw Enemy3FJumpTable	;$3F  BG waterfall
	.dw Enemy40JumpTable	;$40  BG water scroll
	.dw Enemy41JumpTable	;$41  Charon
	.dw Enemy42JumpTable	;$42  Level 5 boss
	.dw Enemy43JumpTable	;$43  Level 5 boss fire
	.dw Enemy44JumpTable	;$44  Level 4 boss crane
	.dw Enemy45JumpTable	;$45  Level 3 fall start
	.dw Enemy46JumpTable	;$46  Manticore fire
	.dw Enemy47JumpTable	;$47  Tengu fire
	.dw Enemy48JumpTable	;$48  Cockatrice fire
	.dw Enemy49JumpTable	;$49  T-Rex
	.dw Enemy4AJumpTable	;$4A  T-Rex fire
	.dw Enemy4BJumpTable	;$4B  Level 6 crusher
	.dw Enemy4CJumpTable	;$4C  Behemoth
	.dw Enemy4DJumpTable	;$4D  Level 6 crusher spikes
	.dw Enemy4EJumpTable	;$4E  Water drop spawner
	.dw Enemy4FJumpTable	;$4F  Water drop
	.dw Enemy50JumpTable	;$50  Level 6 elevator
	.dw Enemy51JumpTable	;$51  Minotaur
	.dw Enemy52JumpTable	;$52  Great Beast
	.dw Enemy53JumpTable	;$53  Great Beast fire
	.dw Enemy54JumpTable	;$54  Level 6 elevator 2
	.dw Enemy55JumpTable	;$55  Level 6 fall start
	.dw Enemy56JumpTable	;$56  Level 3 boss fade
	.dw Enemy57JumpTable	;$57  Level 4 boss fade
	.dw Enemy58JumpTable	;$58  Level 6 boss
	.dw Enemy59JumpTable	;$59  Level 6 boss fire
	.dw Enemy5AJumpTable	;$5A  Level 7 boss
	.dw Enemy5BJumpTable	;$5B  Level 4 fence scroll
	.dw Enemy5CJumpTable	;$5C  Level 7 boss fire
	.dw Enemy5DJumpTable	;$5D  Windigo
EnemyF0JumpTableTable:
	.dw EnemyF0JumpTable	;$F0  Item HP
	.dw EnemyF0JumpTable	;$F1  UNUSED
	.dw EnemyF0JumpTable	;$F2  UNUSED
	.dw EnemyF0JumpTable	;$F3  UNUSED
	.dw EnemyF4JumpTable	;$F4  Level 3 platform
	.dw EnemyF5JumpTable	;$F5  Level 4 crane

EnemyCHRBankTable:
	.db $20,$20,$20,$20,$20,$22,$20,$20,$22,$21,$00,$21,$23,$27,$00,$00
	.db $27,$00,$25,$00,$00,$26,$28,$20,$27,$00,$00,$00,$2B,$00,$2C,$00
	.db $00,$00,$00,$00,$2A,$00,$30,$31,$00,$30,$31,$20,$2F,$00,$2F,$00
	.db $00,$36,$36,$34,$00,$35,$00,$35,$34,$00,$00,$00,$00,$00,$00,$00
	.db $00,$2C,$37,$00,$00,$00,$00,$00,$00,$39,$39,$00,$39,$00,$39,$00
	.db $00,$3A,$3A,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
EnemyWallCollisionXOffsTable:
	.db $08,$04,$0C,$18,$18,$08
EnemyWallCollisionYOffsTable:
	.db $08,$00,$00,$F0,$F8,$10
EnemyGroundCollisionXOffsTable:
	.db $04,$04,$02,$04,$02,$00,$00,$04,$00
EnemyGroundCollisionYOffsTable:
	.db $10,$18,$05,$14,$06,$10,$08,$08,$18
EnemyPointsTable:
	.db $00,$00,$00,$00,$10,$05,$05,$00,$05,$05,$05,$05,$05,$00,$05,$10
	.db $10,$00,$10,$10,$00,$10,$15,$00,$10,$15,$00,$00,$15,$20,$05,$05
	.db $00,$00,$00,$00,$25,$00,$15,$10,$15,$15,$10,$00,$15,$00,$15,$00
	.db $15,$15,$20,$20,$00,$15,$00,$20,$15,$10,$00,$20,$00,$00,$00,$00
	.db $00,$05,$10,$00,$00,$00,$00,$00,$00,$25,$00,$00,$25,$00,$00,$00
	.db $00,$20,$25,$00,$00,$00,$00,$10,$50,$00,$50,$00,$00,$15,$00,$00
BossBonusPointsTable:
	.db $01,$02,$03,$04,$05,$08

;$22: UNUSED
Enemy22JumpTable:
	.dw Enemy22_Sub0	;$00  Main
;$00: Main
Enemy22_Sub0:
	rts

FlipEnemyX:
	;Flip enemy X
	lda Enemy_Props+$08,x
	eor #$40
	sta Enemy_Props+$08,x

FlipEnemyXVel:
	;Flip enemy X velocity
	sec
	lda #$00
	sbc Enemy_XVelLo,x
	sta Enemy_XVelLo,x
	lda #$00
	sbc Enemy_XVel,x
	sta Enemy_XVel,x
	rts

FindFreeEnemySlot:
	;Check for free slots
	ldx #$11
	sec
FindFreeEnemySlot_Loop:
	;If free slot available, exit
	lda Enemy_ID,x
	beq FindFreeEnemySlot_Exit
	;Loop for each slot
	dex
	cpx #$0A
	bcs FindFreeEnemySlot_Loop
	;Restore X register
	ldx CurEnemyIndex
FindFreeEnemySlot_Exit:
	rts

SpawnFreeEnemySlot:
	;Save A/X registers
	sta $01
	stx $05
	;Check for free slots
	ldx #$11
SpawnFreeEnemySlot_Loop:
	;If free slot available, spawn enemy
	lda Enemy_ID,x
	beq SpawnEnemy
	;Loop for each slot
	dex
	cpx #$0A
	bcs SpawnFreeEnemySlot_Loop
	;Restore X register
	ldx CurEnemyIndex
	rts

SpawnEnemyOffs:
	;If free slot available, spawn enemy
	txa
	clc
	adc #$08
	tax
	lda Enemy_ID,x
	beq SpawnEnemy
	;Restore X register
	ldx CurEnemyIndex
	rts

SpawnEnemy:
	;Save Y register
	sty $00
	;Offset enemy Y position
	ldy CurEnemyIndex
	lda $01
	clc
	adc Enemy_Y+$08,y
	sta Enemy_Y+$08,x
	lda Enemy_YHi+$08,y
	sta Enemy_YHi+$08,x
	;Copy enemy X position
	lda Enemy_X+$08,y
	sta Enemy_X+$08,x
	lda Enemy_XHi+$08,y
	sta Enemy_XHi+$08,x
	;Target player with 24-angle precision
	ldy $00
	jsr TargetPlayer24
	;Get spawned enemy slot index
	stx $00
	;Restore X register
	ldx CurEnemyIndex
	;Set carry flag
	sec
	rts

TargetPlayerGravity:
	;Target player accounting for gravity
	lda #$02
	jsr GetTargetAngle
	;Set enemy Y velocity
	asl
	tay
	lda TargetPlayerGravityVelTable+2,y
	sta Enemy_YVel,x
	lda TargetPlayerGravityVelTable+3,y
	sta Enemy_YVelLo,x
	;Check if target X < source X
	lda $07
	and #$02
	beq TargetPlayerGravity_PosX
	;Set enemy X velocity (TX >= SX)
	lda #$01
	sbc TargetPlayerGravityVelTable+1,y
	sta Enemy_XVelLo,x
	lda #$00
	sbc TargetPlayerGravityVelTable,y
	sta Enemy_XVel,x
	rts
TargetPlayerGravity_PosX:
	;Set enemy X velocity (TX < SX)
	lda TargetPlayerGravityVelTable,y
	sta Enemy_XVel,x
	lda TargetPlayerGravityVelTable+1,y
	sta Enemy_XVelLo,x
	rts
TargetPlayerGravityVelTable:
	.db $00,$88,$FD,$D0
	.db $01,$24,$FC,$E0
	.db $01,$99,$FC,$40
	.db $01,$C0,$FB,$28
	.db $01,$55,$FA,$88
	.db $02,$50,$F9,$60

TargetPlayerFlying:
	;Target player accounting for flying motion
	lda #$03
	jsr GetTargetAngle
	;Set enemy Y velocity
	asl
	tay
	lda TargetPlayerFlyingVelTable+2,y
	sta Enemy_YVel,x
	lda TargetPlayerFlyingVelTable+3,y
	sta Enemy_YVelLo,x
	;Check if target X < source X
	lda $07
	and #$02
	beq TargetPlayerFlying_PosX
	;Set enemy X velocity (TX >= SX)
	lda #$01
	sbc TargetPlayerFlyingVelTable+1,y
	sta Enemy_XVelLo,x
	lda #$00
	sbc TargetPlayerFlyingVelTable,y
	sta Enemy_XVel,x
	rts
TargetPlayerFlying_PosX:
	;Set enemy X velocity (TX < SX)
	lda TargetPlayerFlyingVelTable,y
	sta Enemy_XVel,x
	lda TargetPlayerFlyingVelTable+1,y
	sta Enemy_XVelLo,x
	rts
TargetPlayerFlyingVelTable:
	.db $00,$80,$06,$00
	.db $01,$00,$06,$00
	.db $02,$00,$03,$40
	.db $02,$00,$07,$00
	.db $03,$00,$03,$80
	.db $03,$00,$04,$80
	.db $03,$00,$05,$80

TargetPlayer12:
	;Target player with 12-angle precision
	lda #$00
	beq TargetPlayer24_AnyA

TargetPlayer24:
	;Target player with 24-angle precision
	lda #$01
TargetPlayer24_AnyA:
	jsr GetTargetAngle

TargetPlayer:
	;Save Y register
	tay
	sty $06
	;Multiply Y velocity
	lda TargetPlayerVelTable,y
	ldy $05
	jsr MultiplyTargetVelocity
	;Check if target Y < source Y
	lda $07
	lsr
	bcc TargetPlayer_PosY
	;Set enemy Y velocity (TY >= SY)
	lda #$00
	sbc $00
	sta Enemy_YVelLo,x
	lda #$00
	sbc $01
	sta Enemy_YVel,x
	jmp TargetPlayer_CheckX
TargetPlayer_PosY:
	;Set enemy Y velocity (TY < SY)
	lda $01
	sta Enemy_YVel,x
	lda $00
	sta Enemy_YVelLo,x
TargetPlayer_CheckX:
	;Restore Y register
	ldy $06
	;Multiply X velocity
	lda TargetPlayerVelTable+1,y
	ldy $05
	jsr MultiplyTargetVelocity
	;Check if target X < source X
	lda $07
	and #$02
	beq TargetPlayer_PosX
	;Set enemy X velocity (TX >= SX)
	sec
	lda #$00
	sbc $00
	sta Enemy_XVelLo,x
	lda #$00
	sbc $01
	sta Enemy_XVel,x
	rts
TargetPlayer_PosX:
	;Set enemy X velocity (TX < SX)
	lda $01
	sta Enemy_XVel,x
	lda $00
	sta Enemy_XVelLo,x
	rts
TargetPlayerVelTable:
	.db $00,$FF	;$00  0  deg.
	.db $42,$F7	;$02  15 deg.
	.db $80,$DD	;$04  30 deg.
	.db $B5,$B5	;$06  45 deg.
	.db $DD,$80	;$08  60 deg.
	.db $F7,$42	;$0A  75 deg.
	.db $FF,$00	;$0C  90 deg.

MultiplyTargetVelocity:
	;Save input value
	sta $00
	lda #$00
	sta $01
	lda $00
	;If Y = $05, multiply by 13/8
	cpy #$05
	beq MultiplyTargetVelocity_X13_8
	bcs MultiplyTargetVelocity_Check
	;If Y = $03, multiply by 5/4
	cpy #$03
	beq MultiplyTargetVelocity_X5_4
	;If Y = $04, multiply by 3/2
	bcs MultiplyTargetVelocity_X3_2
	;If Y = $01, multiply by 3/4
	cpy #$01
	beq MultiplyTargetVelocity_X3_4
	;If Y = $02, multiply by 1
	bcs MultiplyTargetVelocity_X1
	;If Y = $00, multiply by 1/2
	lsr $00
MultiplyTargetVelocity_X1:
	rts
MultiplyTargetVelocity_Check:
	;If Y = $06, multiply by 7/4
	cpy #$07
	bcc MultiplyTargetVelocity_X7_4
	;If Y = $07, multiply by 15/8
	beq MultiplyTargetVelocity_X15_8
	;If Y = $09, multiply by 9/4
	cpy #$09
	beq MultiplyTargetVelocity_X9_4
	;If Y = $08, multiply by 2
	asl $00
	rol $01
	rts
MultiplyTargetVelocity_X3_4:
	;Multiply input by 3/4
	lsr $00
	lda $00
	bpl MultiplyTargetVelocity_X3_2
MultiplyTargetVelocity_X9_4:
	;Multiply input by 9/4
	asl $00
	rol $01
MultiplyTargetVelocity_X5_4:
	;Multiply input by 5/4
	lsr
MultiplyTargetVelocity_X3_2:
	;Multiply input by 3/2
	lsr
	clc
	bcc MultiplyTargetVelocity_Add1
	lsr
MultiplyTargetVelocity_X7_4:
	;Multiply input by 7/4
	lsr
	sta $02
	bpl MultiplyTargetVelocity_Ent7_4
MultiplyTargetVelocity_X13_8:
	;Multiply input by 13/8
	lsr
	sta $02
	lsr
MultiplyTargetVelocity_Ent7_4:
	lsr
	clc
MultiplyTargetVelocity_Ent15_8:
	adc $02
MultiplyTargetVelocity_Add1:
	adc $00
	sta $00
	bcc MultiplyTargetVelocity_NoC
	inc $01
MultiplyTargetVelocity_NoC:
	rts
MultiplyTargetVelocity_X15_8:
	;Multiply input by 15/8
	lda $00
	lsr
	sta $02
	lsr
	sta $03
	lsr
	clc
	adc $03
	bcc MultiplyTargetVelocity_Ent15_8

GetTargetAngle:
	;Set angle data pointer table index
	sta $0F
	;Get target player X position
	lda Enemy_X,y
	sta $0B
	;Get source enemy Y position
	lda Enemy_YHi+$08,x
	beq GetTargetAngle_SetSY
	bpl GetTargetAngle_NoSYC
	lda #$10
	bne GetTargetAngle_SetSY
GetTargetAngle_NoSYC:
	lda #$F0
GetTargetAngle_SetSY:
	clc
	adc Enemy_Y+$08,x
	sta $08
	;Subtract from target player Y position
	lda Enemy_YHi+$08,x
	clc
	adc #$01
	lsr
	ror $08
	lsr
	ror $08
	lda Enemy_YHi,y
	beq GetTargetAngle_NoTYC
	eor #$FF
	jmp GetTargetAngle_SetTY
GetTargetAngle_NoTYC:
	lda Enemy_Y,y
GetTargetAngle_SetTY:
	sec
	ror
	lsr
	ldy #$00
	sec
	sbc $08
	;If target Y < source Y, increment quadrant 1x
	bcs GetTargetAngle_PosY
	eor #$FF
	adc #$01
	iny
GetTargetAngle_PosY:
	;Set max Y distance $38 and mask out bits 0-2
	cmp #$40
	bcc GetTargetAngle_NoYC
	lda #$38
GetTargetAngle_NoYC:
	;Set angle data table index
	and #$38
	lsr
	sta $0A
	;Subtract source enemy X position from target player X position
	lda Enemy_X+$08,x
	sta $09
	lda Enemy_XHi+$08,x
	clc
	adc #$01
	lsr
	ror $09
	lsr
	ror $09
	lda $0B
	sec
	ror
	lsr
	sec
	sbc $09
	;If target X < source X, increment quadrant 2x
	bcs GetTargetAngle_PosX
	eor #$FF
	adc #$01
	iny
	iny
GetTargetAngle_PosX:
	;Set max X distance $38 and mask out bits 0-2
	cmp #$40
	bcc GetTargetAngle_NoXC
	lda #$38
GetTargetAngle_NoXC:
	;Set angle data table index
	lsr
	lsr
	lsr
	sty $07
	lsr
	php
	ora $0A
	sta $0B
	;Get angle data pointer table index
	lda $0F
	asl
	tay
	;If using first 2 tables, don't increment angle data pointer table index
	cpy #$04
	bcc GetTargetAngle_NoIncOffs
	;If target Y < source Y, increment angle data pointer table index
	lda $07
	lsr
	bcc GetTargetAngle_NoIncOffs
	iny
	iny
	iny
	iny
GetTargetAngle_NoIncOffs:
	;Get angle data pointer
	lda AngleDataPointerTable,y
	sta $0A
	lda AngleDataPointerTable+1,y
	ldy $0B
	sta $0B
	;Get angle data bits
	lda ($0A),y
	plp
	bcs GetTargetAngle_MaskLo
	lsr
	lsr
	lsr
	lsr
GetTargetAngle_MaskLo:
	and #$0F
	asl
	rts
AngleDataPointerTable:
	.dw AngleData0	;$00  12-angle precision
	.dw AngleData1	;$01  24-angle precision
	.dw AngleData2	;$02  Affected by gravity, TY >= SY
	.dw AngleData3	;$03  Affected by flying motion, TY >= SY
	.dw AngleData4	;$04  Affected by gravity, TY < SY
	.dw AngleData5	;$05  Affected by flying motion, TY < SY
	.dw AngleData6	;$06  8-angle precision
AngleData0:
	.db $40,$00,$00,$00
	.db $64,$22,$00,$00
	.db $64,$22,$22,$22
	.db $64,$44,$22,$22
	.db $66,$44,$22,$22
	.db $66,$44,$44,$22
	.db $66,$44,$44,$22
	.db $66,$44,$44,$44
AngleData1:
	.db $30,$00,$00,$00
	.db $53,$22,$11,$11
	.db $54,$32,$22,$11
	.db $64,$43,$22,$22
	.db $65,$44,$33,$22
	.db $65,$44,$33,$32
	.db $65,$54,$43,$33
	.db $65,$54,$44,$33
AngleData2:
	.db $01,$23,$45,$55
	.db $01,$23,$45,$55
	.db $00,$12,$34,$55
	.db $00,$12,$34,$55
	.db $00,$01,$23,$45
	.db $00,$01,$23,$45
	.db $00,$00,$12,$34
	.db $00,$00,$12,$34
AngleData3:
	.db $54,$24,$45,$66
	.db $45,$45,$53,$66
	.db $06,$65,$66,$66
	.db $01,$36,$33,$66
	.db $03,$33,$36,$66
	.db $01,$33,$36,$66
	.db $01,$33,$36,$66
	.db $01,$33,$36,$66
AngleData4:
	.db $01,$23,$45,$55
	.db $22,$34,$55,$55
	.db $44,$45,$55,$55
	.db $44,$45,$55,$55
	.db $44,$45,$55,$55
	.db $44,$45,$55,$55
	.db $44,$45,$55,$55
	.db $44,$45,$55,$55
AngleData5:
	.db $00,$01,$22,$44
	.db $00,$01,$22,$44
	.db $00,$01,$22,$45
	.db $00,$11,$22,$45
	.db $00,$12,$24,$45
	.db $00,$12,$24,$56
	.db $00,$12,$44,$56
	.db $00,$12,$45,$66
AngleData6:
	.db $10,$00,$00,$00
	.db $21,$00,$00,$00
	.db $21,$00,$00,$00
	.db $22,$10,$00,$00
	.db $22,$11,$00,$00
	.db $22,$11,$00,$00
	.db $22,$21,$10,$00
	.db $22,$21,$10,$00

CheckPlayerInRangeXVel:
	;Check if player is in range using X velocity
	sta $10
	ldy #$01
CheckPlayerInRangeXVel_Loop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc CheckPlayerInRangeXVel_Next
	;Check if enemy is moving left or right
	sec
	lda Enemy_XVel,x
	bpl CheckPlayerInRangeXVel_Right
	;Get player X distance in front of enemy (left)
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	sta $00
	lda Enemy_XHi+$08,x
	sbc Enemy_XHi,y
	bne CheckPlayerInRangeXVel_Next
	beq CheckPlayerInRangeXVel_CheckX
CheckPlayerInRangeXVel_Right:
	;Get player X distance in front of enemy (right)
	lda Enemy_X,y
	adc #$0D
	sbc Enemy_X+$08,x
	sta $00
	lda Enemy_XHi,y
	sbc Enemy_XHi+$08,x
	bne CheckPlayerInRangeXVel_Next
CheckPlayerInRangeXVel_CheckX:
	;Check if distance >= range value
	sec
	lda $00
	sbc $10
	bcc CheckPlayerInRangeXVel_Next
	;Check if distance < range value + $03
	cmp #$03
	bcs CheckPlayerInRangeXVel_Next
	rts
CheckPlayerInRangeXVel_Next:
	;Loop for each player
	dey
	bpl CheckPlayerInRangeXVel_Loop
	;Set carry flag
	sec
	rts

CheckBossRush:
	;Check for boss rush level
	lda CurLevel
	cmp #$05
	bne CheckBossRush_NoBR
CheckBossRush_SpawnElevator:
	;Spawn level 6 elevator
	lda #ENEMY_LEVEL6ELEVATOR2
	sta Enemy_ID+$09
CheckBossRush_NoElevator:
	;Clear sound
	jsr ClearSound
	;Play music
	lda #MUSIC_BOSSRUSH
	jsr LoadSound
	;Clear auto scroll flags/velocity
	lda #$00
	sta AutoScrollDirFlags
	sta AutoScrollXVel
	sta AutoScrollYVel
	;Clear sprite boss mode flag
	sta SpriteBossModeFlag
CheckBossRush_NoBR:
	;Kill enemy normally
	jmp Enemy01_Sub1_End

;$34: BG floor scroll
Enemy34JumpTable:
	.dw Enemy34_Sub0	;$00  Main
;$00: Main
Enemy34_Sub0_Y0:
	;If not on bottom screen, remove IRQ buffer region
	lda CurScreenY
	beq Enemy34_Sub0_CheckRemIRQ
	;Add IRQ buffer region
	lda #$00
	beq Enemy34_Sub0_CheckAddIRQ
Enemy34_Sub0:
	;If scroll Y position 0, check for bottom screen
	lda TempMirror_PPUSCROLL_Y
	beq Enemy34_Sub0_Y0
	;If scroll Y position < $E4, remove IRQ buffer region
	cmp #$E4
	bcc Enemy34_Sub0_CheckRemIRQ
	;Get IRQ buffer height based on scroll Y position
	lda #$F0
	sec
	sbc TempMirror_PPUSCROLL_Y
Enemy34_Sub0_CheckAddIRQ:
	sta $10
	;Check if BG floor scroll IRQ buffer region is active
	lda TempIRQBufferSub
	cmp #$03
	beq Enemy34_Sub0_NoAddIRQ
	;Add IRQ buffer region (BG floor scroll)
	lda #$03
	jsr AddIRQBufferRegion
Enemy34_Sub0_NoAddIRQ:
	;Set IRQ buffer height for main game
	lda #$AF
	clc
	adc $10
	sta TempIRQBufferHeight
	;Set IRQ buffer height for BG floor scroll
	lda #$0F
	sec
	sbc $10
	sta TempIRQBufferHeight+1
	jmp Enemy34_Sub0_NoRemIRQ
Enemy34_Sub0_CheckRemIRQ:
	;Check if BG floor scroll IRQ buffer region is active
	lda TempIRQBufferSub
	cmp #$03
	bne Enemy34_Sub0_NoRemIRQ
	;Remove IRQ buffer region (BG floor scroll)
	lda #$03
	jsr RemoveIRQBufferRegion
Enemy34_Sub0_NoRemIRQ:
	;If not scrolling horizontally, skip this part
	lda ScrollPlayerXVel
	beq Enemy34_Sub0_Exit
	;Increment BG floor scroll X position
	lda BGFloorScrollXLo
	clc
	adc #$E0
	sta BGFloorScrollXLo
	lda BGFloorScrollX
	adc #$01
	sta BGFloorScrollX
Enemy34_Sub0_Exit:
	rts

;$36: Stove flame
Enemy36JumpTable:
	.dw Enemy36_Sub0	;$00  Init
	.dw Enemy36_Sub1	;$01  Main
;$00: Init
Enemy36_Sub0:
	;Move enemy up $05
	lda Enemy_Y+$08,x
	sec
	sbc #$05
	sta Enemy_Y+$08,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
	rts
;$01: Main
Enemy36_Sub1:
	;Increment animation timer, check if $80
	inc Enemy_Temp1,x
	lda Enemy_Temp1,x
	bpl Enemy36_Sub1_NoSound
	;Toggle stove flame out flag
	lda Enemy_Temp2,x
	eor #$01
	sta Enemy_Temp2,x
	;Set animation timer
	sta Enemy_Temp1,x
	;If stove flame not out, don't play sound
	beq Enemy36_Sub1_NoSound
	;If enemy offscreen horizontally, don't play sound
	lda Enemy_XHi+$08,x
	bne Enemy36_Sub1_NoSound
	;Play sound
	lda #SE_STOVEFLAME
	jsr LoadSound
Enemy36_Sub1_NoSound:
	;Check if stove flame out
	lda Enemy_Temp2,x
	beq Enemy36_Sub1_NoOut
	;Update enemy animation (out)
	ldy #$14
	jmp UpdateEnemyAnimation_AnyY
Enemy36_Sub1_NoOut:
	;Update enemy animation (in)
	jmp UpdateEnemyAnimation

;$4B: Level 6 crusher
Enemy4BJumpTable:
	.dw Enemy4B_Sub0	;$00  Init
	.dw Enemy4B_Sub1	;$01  Down
	.dw Enemy4B_Sub2	;$02  Shake
	.dw Enemy4B_Sub3	;$03  Moving up
	.dw Enemy4B_Sub4	;$04  Up
	.dw Enemy4B_Sub5	;$05  Moving down
	.dw Enemy4B_Sub6	;$06  End wait
;$00: Init
Enemy4B_Sub0:
	;If enemy offscreen horizontally, exit early
	lda Enemy_XHi+$08,x
	bne Enemy4B_Sub0_Exit
	;Play sound
	lda #SE_LEVEL6CRUSHER
	jsr LoadSound
	;Next task ($01: Init wait)
	inc Enemy_Mode,x
	;Set scroll lock settings
	lda #$01
	sta TempScrollLockFlags
	lda #$00
	sta TempScrollLockOther
	;Set auto scroll flags
	lda #$44
	sta AutoScrollDirFlags
	;Set delay timer
	lda #$0A
	sta Enemy_Temp4,x
	;Set animation timer
	lda #$50
	sta Enemy_Temp1,x
	;Add IRQ buffer region (level 6 ceiling crusher)
	lda #$0F
	jsr AddIRQBufferRegion
	;Update level 6 crusher scroll
	jmp Level6CrusherScrollSub
Enemy4B_Sub0_Exit:
	rts
;$01: Down
Enemy4B_Sub1:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy4B_Sub1_NoNext
	;Set delay timer
	lda #$0A
	sta Enemy_Temp4,x
	;Set crusher Y velocity up
	lda #$01
	sta Enemy_Temp3,x
	;Next task ($02: Shake)
	inc Enemy_Mode,x
	;Update level 6 crusher scroll
	jmp Level6CrusherScrollSub
Enemy4B_Sub1_NoNext:
	;If current X screen >= $09, go to next task ($06: End wait)
	lda CurScreenX
	cmp #$09
	bcc Enemy4B_Sub1_NoEnd
	;Next task ($06: End wait)
	lda #$06
	sta Enemy_Mode,x
Enemy4B_Sub1_NoEnd:
	;Update level 6 crusher scroll
	jmp Level6CrusherScrollSub
;$02: Shake
Enemy4B_Sub2:
	;Increment animation timer
	inc Enemy_Temp1,x
	;If bits 0-1 of animation timer not 0, skip this part
	lda Enemy_Temp1,x
	and #$03
	bne Enemy4B_Sub2_NoSetY
	;Decrement delay timer, check if 0
	dec Enemy_Temp4,x
	beq Enemy4B_Sub2_Next
	;Set crusher Y velocity based on bit 0 of delay timer
	lda Enemy_Temp4,x
	and #$01
	tay
	lda Level6CrusherUpShakeYVelocity,y
	sta Enemy_Temp3,x
Enemy4B_Sub2_NoSetY:
	;Update level 6 crusher scroll
	jmp Level6CrusherScrollSub
Enemy4B_Sub2_Next:
	;Play sound
	lda #SE_LEVEL6CRUSHERMOVE
	jsr LoadSound
	;Set crusher Y velocity up
	lda #$01
	sta Enemy_Temp3,x
	;Set animation timer
	lda #$58
	sta Enemy_Temp1,x
	;Next task ($03: Moving up)
	inc Enemy_Mode,x
	;Update level 6 crusher scroll
	bne Level6CrusherScrollSub
Level6CrusherUpShakeYVelocity:
	.db $01,$FF
;$03: Moving up
Enemy4B_Sub3:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Level6CrusherScrollSub
	;Set animation timer
	lda #$08
	sta Enemy_Temp1,x
	;Clear crusher Y velocity
	lda #$00
	sta Enemy_Temp3,x
	;Next task ($04: Up)
	inc Enemy_Mode,x
	;Update level 6 crusher scroll
	bne Level6CrusherScrollSub
;$04: Up
Enemy4B_Sub4:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Level6CrusherScrollSub
	;Set crusher Y velocity down
	lda #$FF
	sta Enemy_Temp3,x
	;Set animation timer
	lda #$58
	sta Enemy_Temp1,x
	;Next task ($05: Moving down)
	inc Enemy_Mode,x
	;Update level 6 crusher scroll
	bne Level6CrusherScrollSub
;$05: Moving down
Enemy4B_Sub5:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Level6CrusherScrollSub
	;Set animation timer
	lda #$30
	sta Enemy_Temp1,x
	;Clear crusher Y velocity
	lda #$00
	sta Enemy_Temp3,x
	;Next task ($01: Down)
	lda #$01
	sta Enemy_Mode,x
	;Update level 6 crusher scroll
	bne Level6CrusherScrollSub
;$06: End wait
Enemy4B_Sub6:
	;If current X screen < $0A, skip this part
	lda CurScreenX
	cmp #$0A
	bcc Level6CrusherScrollSub
	;If crusher Y position not 0, skip this part
	lda TempMirror_PPUSCROLL_Y
	bne Level6CrusherScrollSub
	;Play sound
	lda #SE_LOOPEND
	jsr LoadSound
	;Clear scroll lock flags
	lda #$00
	sta TempScrollLockFlags
	;Clear auto scroll flags/Y velocity
	sta AutoScrollDirFlags
	sta AutoScrollYVel
	;Remove IRQ buffer region (level 6 ceiling crusher)
	lda #$0F
	jsr RemoveIRQBufferRegion
	;Clear enemy
	jmp ClearEnemy
Level6CrusherScrollSub:
	;Set scroll lock settings
	lda Enemy_Temp5,x
	and #$03
	tay
	lda Level6CrusherScrollSubLockFlags,y
	sta TempScrollLockOther
	;Increment shake data index
	inc Enemy_Temp5,x
	;Set auto scroll Y velocity
	lda Level6CrusherShakeYVelocity,y
	clc
	adc Enemy_Temp3,x
	sta AutoScrollYVel
	;Set IRQ buffer height for main game
	lda #$98
	sec
	sbc TempMirror_PPUSCROLL_Y
	sta TempIRQBufferHeight
	;Set IRQ buffer height for level 6 ceiling crusher
	lda #$BF
	sec
	sbc TempIRQBufferHeight
	sta TempIRQBufferHeight+1
	rts
Level6CrusherScrollSubLockFlags:
	.db $01,$02,$01,$00
Level6CrusherShakeYVelocity:
	.db $01,$01,$FF,$FF

;$4D: Level 6 crusher spikes
Enemy4DJumpTable:
	.dw Enemy4D_Sub0	;$00  Init
	.dw Enemy4D_Sub1	;$01  Start wait
	.dw Enemy4D_Sub2	;$02  End wait
	.dw Enemy4D_Sub3	;$03  End
;$01: Start wait
Enemy4D_Sub1:
	;If current X screen $07, go to next task ($02: End wait)
	lda CurScreenX
	cmp #$07
	bne Enemy4D_Sub3
;$00: Init
Enemy4D_Sub0:
	;Next task ($01: Start wait)
	inc Enemy_Mode,x
	bne Enemy4D_Sub3
;$02: End wait
Enemy4D_Sub2:
	;Set enemy X position based on enemy slot index
	lda Level6CrusherSpikesXPosition-$05,x
	sta Enemy_X+$08,x
	;If current X screen $0A, go to next task ($03: End)
	lda CurScreenX
	cmp #$0A
	bne Enemy4D_Sub3
	;Next task ($03: End)
	inc Enemy_Mode,x
;$03: End
Enemy4D_Sub3:
	;Set enemy Y position
	lda #$20
	sta Enemy_Y+$08,x
	rts
Level6CrusherSpikesXPosition:
	.db $40,$C0

;$50: Level 6 elevator
Enemy50JumpTable:
	.dw Enemy50_Sub0	;$00  Init wait part 1
	.dw Enemy50_Sub1	;$01  Init wait part 2
	.dw Enemy50_Sub2	;$02  Init part 1
	.dw Enemy50_Sub3	;$03  Init part 2
	.dw Enemy50_Sub4	;$04  Main
	.dw Enemy50_Sub5	;$05  End
;$00: Init wait part 1
Enemy50_Sub0:
	;If current X screen not $0F, exit early
	lda CurScreenX
	cmp #$0F
	bne Enemy50_Sub0_Exit
	;Clear auto scroll flags/velocity
	lda #$00
	sta AutoScrollDirFlags
	sta AutoScrollYVel
	sta AutoScrollXVel
	;Set elevator position
	lda #$98
	sta ElevatorYPos
	;Next task ($01: Init wait part 2)
	inc Enemy_Mode+$09
Enemy50_Sub0_Exit:
	rts
;$01: Init wait part 2
Enemy50_Sub1:
	;If current X screen not $10, exit early
	lda CurScreenX
	cmp #$10
	bne Enemy50_Sub0_Exit
	;Next task ($02: Init part 1)
	inc Enemy_Mode+$09
	;Write VRAM strip (level 6 elevator)
	lda #$22
	jsr WriteVRAMStrip
	;Write enemy VRAM strip (level 6 elevator)
	lda #$00
	jmp WriteElevatorVRAMStrip38
;$02: Init part 1
Enemy50_Sub2:
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	beq Enemy50_Sub2_Next
	;Write enemy VRAM strip (level 6 elevator)
	jmp WriteEnemyVRAMStrip38
Enemy50_Sub2_Next:
	;Next task ($03: Init part 2)
	inc Enemy_Mode+$09
	;Add IRQ buffer region (level 6 elevator)
	lda #$10
	jsr AddIRQBufferRegion
	;Write level 6 elevator attributes
	ldy #$01
	jsr Level6ElevatorWriteAttr
	;Write enemy VRAM strip (level 6 elevator)
	lda #$04
	jmp WriteElevatorVRAMStrip38
;$03: Init part 2
Enemy50_Sub3:
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	beq Enemy50_Sub3_Next
	;Write enemy VRAM strip (level 6 elevator)
	jmp WriteEnemyVRAMStrip38
Enemy50_Sub3_Next:
	;Set auto scroll flags
	lda #$04
	sta AutoScrollDirFlags
	;Clear auto scroll velocity
	lda #$00
	sta AutoScrollYVel
	sta AutoScrollXVel
	;Next task ($04: Main)
	inc Enemy_Mode+$09
	rts
;$05: End
Enemy50_Sub5:
	;Clear enemy
	jmp ClearEnemy
;$04: Main
Enemy50_Sub4:
	;Check for current Y screen $08
	lda CurScreenY
	cmp #$08
	bne Enemy50_Sub4_NoNext
	;Clear auto scroll flags
	lda #$00
	sta AutoScrollDirFlags
	;Clear elevator position
	sta ElevatorYPos
	;Next task ($05: End)
	inc Enemy_Mode+$09
	;Remove IRQ buffer region (level 6 elevator)
	lda #$10
	jmp RemoveIRQBufferRegion
Enemy50_Sub4_NoNext:
	;Set auto scroll Y velocity based on bit 0 of global timer
	lda GlobalTimer
	and #$01
	sta AutoScrollYVel
Enemy50_Sub4_EntElev2:
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	beq Enemy50_Sub4_NoContinue
	;Write enemy VRAM strip (level 6 elevator)
	jmp WriteEnemyVRAMStrip38
Enemy50_Sub4_NoContinue:
	;Check to decrement elevator section index
	lda Enemy_Temp3+$09
	beq Enemy50_Sub4_NoNextOffs
	;Decrement elevator section index
	dec Enemy_Temp2+$09
	bpl Enemy50_Sub4_NoOffsC
	lda #$02
	sta Enemy_Temp2+$09
Enemy50_Sub4_NoOffsC:
	;Clear next elevator section flag
	lda #$00
	sta Enemy_Temp3+$09
	rts
Enemy50_Sub4_NoNextOffs:
	;Check for elevator section 0
	lda CurScreenY
	ldy Enemy_Temp2+$09
	beq Enemy50_Sub4_Check0
	;Check for elevator section 1
	cpy #$01
	beq Enemy50_Sub4_Check1
	;Check to write next elevator section in VRAM (section 2)
	lsr
	bcc Enemy50_Sub4_Exit
	lda TempMirror_PPUSCROLL_Y
	cmp #$A8
	bcc Enemy50_Sub4_Exit
Enemy50_Sub4_Set:
	;Set next elevator section flag
	inc Enemy_Temp3+$09
	;Write VRAM strip (level 6 elevator)
	ldy Enemy_Temp2+$09
	lda Level6ElevatorVRAMStrip,y
	jsr WriteVRAMStrip
	;Write enemy VRAM strip (level 6 elevator)
	ldy Enemy_Temp2+$09
	lda Level6ElevatorEnemyVRAMStrip,y
	jmp WriteElevatorVRAMStrip38
Enemy50_Sub4_Check0:
	;Check to write next elevator section in VRAM (section 0)
	lsr
	bcc Enemy50_Sub4_Exit
	lda TempMirror_PPUSCROLL_Y
	cmp #$08
	bcs Enemy50_Sub4_Set
Enemy50_Sub4_Exit:
	rts
Enemy50_Sub4_Check1:
	;Check to write next elevator section in VRAM (section 1)
	lsr
	bcs Enemy50_Sub4_Exit
	lda TempMirror_PPUSCROLL_Y
	cmp #$58
	bcc Enemy50_Sub4_Exit
	bcs Enemy50_Sub4_Set
Level6ElevatorEnemyVRAMStrip:
	.db $01,$00,$02
Level6ElevatorVRAMStrip:
	.db $23,$22,$24
Level6ElevatorWriteAttr:
	;Init VRAM buffer attribute row
	lda #$04
	jsr WriteVRAMBufferCmd
	;Set VRAM buffer address
	lda #$E8
	jsr WriteVRAMBufferCmd_AnyX
	lda Level6ElevatorAttrNametableHi,y
	jsr WriteVRAMBufferCmd_AnyX
	;Set left edge attribute in VRAM
	lda #$DD
	jsr WriteVRAMBufferCmd_AnyX
	;Set middle attributes in VRAM
	ldy #$05
	lda #$FF
Level6ElevatorWriteAttr_Loop:
	;Set middle attribute in VRAM
	jsr WriteVRAMBufferCmd_AnyX
	;Loop for each attribute byte
	dey
	bpl Level6ElevatorWriteAttr_Loop
	;Set right edge attribute in VRAM
	lda #$77
	jmp WriteVRAMBufferCmd_AnyX
Level6ElevatorAttrNametableHi:
	.db $23,$2B

;$54: Level 6 elevator 2
Enemy54JumpTable:
	.dw Enemy54_Sub0	;$00  Init wait part 1
	.dw Enemy54_Sub1	;$01  Init wait part 2
	.dw Enemy54_Sub2	;$02  Init part 1
	.dw Enemy54_Sub3	;$03  Init part 2
	.dw Enemy54_Sub4	;$04  Main
	.dw Enemy54_Sub5	;$05  End
;$00: Init wait part 1
Enemy54_Sub0:
	;Set elevator position
	lda #$98
	sta ElevatorYPos
	;If scroll X position 0, exit early
	lda TempMirror_PPUSCROLL_X
	beq Enemy54_Sub0_Exit
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|EF_ALLOWOFFSCREEN)
	sta Enemy_Flags+$09
	;Next task ($01: Init part 2)
	inc Enemy_Mode+$09
Enemy54_Sub0_Exit:
	rts
;$01: Init wait part 2
Enemy54_Sub1:
	;If scroll X position not 0, exit early
	lda TempMirror_PPUSCROLL_X
	bne Enemy54_Sub0_Exit
	;Get initial elevator section data offset
	lda CurScreenY
	and #$01
	sta $10
	tay
	;Next task ($02: Init part 1)
	inc Enemy_Mode+$09
	;Write VRAM strip (level 6 elevator)
	lda Level6Elevator2Init1VRAMStrip,y
	jsr WriteVRAMStrip
	;Set initial elevator section index
	ldy $10
	lda Level6Elevator2Init1Offs,y
	sta Enemy_Temp2+$09
	;Write enemy VRAM strip (level 6 elevator)
	lda Level6Elevator2Init1EnemyVRAMStrip,y
	jmp WriteElevatorVRAMStrip38
Level6Elevator2Init1EnemyVRAMStrip:
	.db $02,$00
Level6Elevator2Init1VRAMStrip:
	.db $24,$22
Level6Elevator2Init1Offs:
	.db $01,$00
;$02: Init part 1
Enemy54_Sub2:
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	beq Enemy54_Sub2_Next
	;Write enemy VRAM strip (level 6 elevator)
	jmp WriteEnemyVRAMStrip38
Enemy54_Sub2_Next:
	;Add IRQ buffer region (level 6 elevator)
	lda #$10
	jsr AddIRQBufferRegion
	;Next task ($03: Init part 2)
	inc Enemy_Mode+$09
	;Write level 6 elevator attributes
	ldy CurScreenY
	lda Level6Elevator2Init2AttrOffs-$01,y
	tay
	jsr Level6ElevatorWriteAttr
	;Write enemy VRAM strip (level 6 elevator)
	ldy CurScreenY
	lda Level6Elevator2Init2EnemyVRAMStrip-$01,y
	jmp WriteElevatorVRAMStrip38
Level6Elevator2Init2AttrOffs:
	.db $01,$00,$01,$00,$01
Level6Elevator2Init2EnemyVRAMStrip:
	.db $04,$03,$06,$05,$06
;$03: Init part 2
Enemy54_Sub3:
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	beq Enemy54_Sub3_Next
	;Write enemy VRAM strip (level 6 elevator)
	jmp WriteEnemyVRAMStrip38
Enemy54_Sub3_Next:
	;Set auto scroll flags
	lda #$04
	sta AutoScrollDirFlags
	;Set end Y screen
	lda CurScreenY
	sta Enemy_Temp4+$09
	inc Enemy_Temp4+$09
	;Next task ($04: Main)
	inc Enemy_Mode+$09
	rts
;$04: Main
Enemy54_Sub4:
	;Check for end of elevator
	lda CurScreenY
	cmp Enemy_Temp4+$09
	bne Enemy54_Sub4_NoNext
	;Clear elevator position
	lda #$00
	sta ElevatorYPos
	;Clear auto scroll Y velocity
	sta AutoScrollYVel
	;Set auto scroll flags
	lda #$01
	sta AutoScrollDirFlags
	;Next task ($05: End)
	inc Enemy_Mode+$09
	;Remove IRQ buffer region (level 6 elevator)
	lda #$10
	jmp RemoveIRQBufferRegion
Enemy54_Sub4_NoNext:
	;Set auto scroll Y velocity based on bit 0 of global timer
	lda GlobalTimer
	and #$01
	sta AutoScrollYVel
	;Update elevator VRAM
	jmp Enemy50_Sub4_EntElev2
;$05: End
Enemy54_Sub5:
	;Clear enemy
	jmp ClearEnemy

;$55: Level 6 fall start
Enemy55JumpTable:
	.dw Enemy55_Sub0	;$00  Main
;$00: Main
Enemy55_Sub0:
	ldy #$01
Enemy55_Sub0_Loop:
	;Check if player is active
	lda PlayerLives,y
	beq Enemy55_Sub0_Next
	;Check if player is grounded
	lda PlayerCollTypeBottom,y
	beq Enemy55_Sub0_Next
	;Clear sound
	jsr ClearSound
	;Play music
	lda #MUSIC_LEVEL6
	jsr LoadSound
	;Clear enemy
	jmp ClearEnemy
Enemy55_Sub0_Next:
	;Loop for each player
	dey
	bpl Enemy55_Sub0_Loop
	rts

;;;;;;;;;;;;;;;;
;NAMETABLE DATA;
;;;;;;;;;;;;;;;;
Nametable0EData:
	.dw $2A00
	.db $17,$00,$17,$00,$82,$01,$02,$C3,$14,$10,$00,$0B,$00,$82,$03,$04
	.db $C5,$17,$18,$00,$C3,$05,$C5,$1C,$18,$00,$C3,$08,$C5,$21,$18,$00
	.db $C3,$0B,$C5,$26,$18,$00,$C3,$0E,$C5,$2B,$18,$00,$C3,$11,$C5,$30
	.db $18,$00,$18,$00,$18,$00,$18,$00,$18,$00,$18,$00,$18,$00,$18,$00
	.db $09,$00,$80,$E0,$2B,$0C,$FF,$81,$AF,$03,$FF,$00

;;;;;;;;;;;;;;;;
;ENEMY ROUTINES;
;;;;;;;;;;;;;;;;
;$0C: Level 1 boss
Enemy0CJumpTable:
	.dw Enemy0C_Sub0	;$00  Init
	.dw Enemy0C_Sub1	;$01  Idle
	.dw Enemy0C_Sub2	;$02  Jump
	.dw Enemy0C_Sub3	;$03  Death init
	.dw Enemy0C_Sub4	;$04  Death wait
	.dw Enemy0C_Sub5	;$05  Death flash
	.dw Enemy0C_Sub6	;$06  Boss rush flash
;$00: Init
Enemy0C_Sub0:
	;Check if enemy HP < 0
	lda Enemy_HP,x
	bpl Enemy0C_Sub0_NoDeath
	;Check if enemy is grounded
	lda Enemy_YVel,x
	beq Enemy0C_Sub0_Death
	;Next task ($02: Jump)
	lda #$02
	sta Enemy_Mode,x
	rts
Enemy0C_Sub0_Death:
	;Load CHR bank
	lda #$23
	sta TempCHRBanks+2
	;Set enemy sprite
	lda #$08
	sta Enemy_Sprite+$08,x
	;Next task ($03: Death init)
	lda #$03
	sta Enemy_Mode,x
	;Set animation timer
	lda #$68
	sta Enemy_Temp1,x
Enemy0C_Sub0_Exit:
	rts
Enemy0C_Sub0_NoDeath:
	;Check for boss rush level
	lda CurLevel
	beq Enemy0C_Sub0_NoBR
	;If scroll Y position not 0, exit early
	lda TempMirror_PPUSCROLL_Y
	bne Enemy0C_Sub0_Exit
	;Next task ($06: Boss rush flash)
	lda #$06
	sta Enemy_Mode,x
	;Disable enemy collision
	lda Enemy_Flags,x
	ora #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags,x
	;Set enemy props
	lda #$40
	sta Enemy_Props+$08,x
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Load CHR bank
	lda #$23
	sta TempCHRBanks+2
	;Set sprite boss mode flag
	dec SpriteBossModeFlag
	rts
Enemy0C_Sub0_NoBR:
	;Set jump counter
	lda #$04
	sta Enemy_Temp2,x
	;Set animation timer
	lda #$60
	sta Enemy_Temp1,x
	;Set sprite boss mode flag
	dec SpriteBossModeFlag
	;Next task ($01: Idle)
	inc Enemy_Mode,x
	rts
;$06: Boss rush flash
Enemy0C_Sub6:
	;Clear/set enemy sprite based on bit 0 of animation timer
	lda Enemy_Temp1,x
	and #$01
	beq Enemy0C_Sub6_SetSp
	lda #$08
Enemy0C_Sub6_SetSp:
	sta Enemy_Sprite+$08,x
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy0C_Sub0_Exit
	;Enable enemy collision
	lda Enemy_Flags,x
	and #(~(EF_NOHITENEMY|EF_NOHITATTACK))&$FF
	sta Enemy_Flags,x
	;Next task ($00: Init)
	lda #$00
	sta Enemy_Mode,x
	;Init enemy state
	jmp Enemy0C_Sub0_NoBR
;$01: Idle
Enemy0C_Sub1:
	;Load CHR bank
	lda #$23
	sta TempCHRBanks+2
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy0C_Sub1_Exit
	;Decrement jump counter, check if 0
	lda #$08
	dec Enemy_Temp2,x
	bne Enemy0C_Sub1_NoJumpC
	;Reset jump counter
	lda #$03
	sta Enemy_Temp2,x
	lda #$60
Enemy0C_Sub1_NoJumpC:
	;Set animation timer
	sta Enemy_Temp1,x
	;Set enemy sprite
	lda #$09
	sta Enemy_Sprite+$08,x
	;Set enemy animation offset/timer
	lda #$01
	sta Enemy_AnimOffs,x
	lda #$14
	sta Enemy_AnimTimer,x
	;Clear jump peak flag
	lda #$00
	sta Enemy_Temp3,x
	;Set enemy velocity randomly
	lda #$FA
	sta Enemy_YVel,x
	lda PRNGValue
	sta Enemy_YVelLo,x
	asl
	and #$80
	sta Enemy_XVelLo,x
	rol
	sta Enemy_XVel,x
	;Find closest player
	jsr FindClosestPlayerX
	;Check if player is to left or right
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	lda #$00
	bcc Enemy0C_Sub1_SetP
	lda #$40
Enemy0C_Sub1_SetP:
	;Set enemy props
	sta Enemy_Props+$08,x
	;If player is to left, flip enemy X velocity
	bcc Enemy0C_Sub1_NoFlipXVel
	;Flip enemy X velocity
	lda #$00
	sbc Enemy_XVelLo,x
	sta Enemy_XVelLo,x
	lda #$00
	sbc Enemy_XVel,x
	sta Enemy_XVel,x
Enemy0C_Sub1_NoFlipXVel:
	;Next task ($02: Jump)
	inc Enemy_Mode,x
Enemy0C_Sub1_Exit:
	rts
;$02: Jump
Enemy0C_Sub2:
	;If enemy animation offset 0, don't attack
	ldy Enemy_AnimOffs,x
	beq Enemy0C_Sub2_NoAttack
	;Decrement animation timer, check if 0
	dec Enemy_AnimTimer,x
	bne Enemy0C_Sub2_NoAttack
	;Decrement animation offset
	dey
	cpy #$01
	bne Enemy0C_Sub2_NoOffsC
	dey
Enemy0C_Sub2_NoOffsC:
	tya
	sta Enemy_AnimOffs,x
	;Load CHR bank
	lda Level1BossJumpAnimCHRBank,y
	sta TempCHRBanks+2
	;Set enemy sprite
	lda Level1BossJumpAnimSprite,y
	sta Enemy_Sprite+$08,x
	;Set animation timer
	lda Level1BossJumpAnimTimer,y
	sta Enemy_AnimTimer,x
	;If animation offset not $03, don't attack
	cpy #$03
	bne Enemy0C_Sub2_NoAttack
	;If enemy Y position < $09, reset animation for peak of jump
	lda Enemy_YHi+$08,x
	bne Enemy0C_Sub2_ResetAnim
	lda Enemy_Y+$08,x
	cmp #$09
	bcs Enemy0C_Sub2_NoResetAnim
Enemy0C_Sub2_ResetAnim:
	;Reset enemy animation offset/timer for peak of jump
	lda #$04
	sta Enemy_AnimOffs,x
	sta Enemy_AnimTimer,x
	bne Enemy0C_Sub2_NoAttack
Enemy0C_Sub2_NoResetAnim:
	;If enemy HP < 0, don't attack
	lda Enemy_HP,x
	bmi Enemy0C_Sub2_NoAttack
	;Spawn projectiles
	jsr Level1BossAttackSub
Enemy0C_Sub2_NoAttack:
	;Accelerate due to gravity
	clc
	lda Enemy_YVelLo,x
	adc #$20
	sta Enemy_YVelLo,x
	lda Enemy_YVel,x
	adc #$00
	sta Enemy_YVel,x
	;Check if at peak of jump
	cmp #$FF
	bne Enemy0C_Sub2_NoPeakAnim
	;If jump peak flag set, skip this part
	lda Enemy_Temp3,x
	bne Enemy0C_Sub2_NoPeakAnim
	;Set enemy animation offset/timer
	lda #$05
	sta Enemy_AnimOffs,x
	lda #$01
	sta Enemy_AnimTimer,x
	;Set jump peak flag
	inc Enemy_Temp3,x
Enemy0C_Sub2_NoPeakAnim:
	;Move enemy
	jsr MoveEnemyXY
	;Check for level bounds
	lda Enemy_X+$08,x
	cmp #$1A
	ldy #$1A
	bcc Enemy0C_Sub2_Bound
	cmp #$E6
	bcc Enemy0C_Sub2_NoBound
	ldy #$E6
Enemy0C_Sub2_Bound:
	;Set enemy X position
	tya
	sta Enemy_X+$08,x
	;Clear enemy X velocity
	lda #$00
	sta Enemy_XVel,x
	sta Enemy_XVelLo,x
Enemy0C_Sub2_NoBound:
	;If moving up, exit early
	lda Enemy_YVel,x
	bmi Enemy0C_Sub2_Exit
	;If no ground collision, exit early
	jsr EnemyGetGroundCollision
	bcc Enemy0C_Sub2_Exit
	;Set enemy grounded
	ldy #$00
	jsr HandleEnemyGroundCollision_NoClearY
	;Set enemy sprite
	lda #$08
	sta Enemy_Sprite+$08,x
	;Check if enemy HP < 0
	lda Enemy_HP,x
	bmi Enemy0C_Sub2_Death
	;Next task ($01: Idle)
	dec Enemy_Mode,x
Enemy0C_Sub2_Exit:
	rts
Enemy0C_Sub2_Death:
	;Set enemy death state
	jmp Enemy0C_Sub0_Death
Level1BossJumpAnimSprite:
	.db $0A,$09,$0D,$0C,$0B
Level1BossJumpAnimCHRBank:
	.db $23,$23,$24,$24,$24
Level1BossJumpAnimTimer:
	.db $08,$08,$08,$08,$10
;$03: Death init
Enemy0C_Sub3:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy0C_Sub3_Next
	;If animation timer < $10, set animation offset $00
	ldy #$00
	lda Enemy_Temp1,x
	cmp #$10
	bcc Enemy0C_Sub3_SetSp
	;If animation timer < $24, set animation offset $01
	iny
	cmp #$24
	bcc Enemy0C_Sub3_SetSp
	;Set animation offset $02
	iny
Enemy0C_Sub3_SetSp:
	;Set enemy sprite
	lda Level1BossDeathAnimSprite,y
	sta Enemy_Sprite+$08,x
	;Load CHR bank
	lda Level1BossDeathAnimCHRBank,y
	sta TempCHRBanks+2
	rts
Level1BossDeathAnimSprite:
	.db $10,$0F,$08
Level1BossDeathAnimCHRBank:
	.db $23,$24,$23
Enemy0C_Sub3_Next:
	;Next task ($04: Death wait)
	inc Enemy_Mode,x
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Clear sound
	jsr ClearSound
	;Set boss death sound flag
	inc BossDeathSoundFlag
	;Play sound
	lda #DMC_BOSSDEATH0
	jmp LoadSound
Enemy0C_Sub4_Exit:
	rts
;$04: Death wait
Enemy0C_Sub4:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy0C_Sub4_Exit
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Next task ($05: Death flash)
	inc Enemy_Mode,x
	rts
;$05: Death flash
Enemy0C_Sub5:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy0C_Sub5_CheckBR
	;Clear/set enemy sprite based on bit 0 of global timer
	lda GlobalTimer
	and #$01
	beq Enemy0C_Sub5_SetSp
	lda #$10
Enemy0C_Sub5_SetSp:
	sta Enemy_Sprite+$08,x
Enemy0C_Sub5_Exit:
	rts
Enemy0C_Sub5_CheckBR:
	;Check for boss rush
	jmp CheckBossRush
Level1BossAttackSub:
	;Find closest player
	jsr FindClosestPlayerX
	;Spawn projectile in free enemy slot
	lda #$F8
	ldx #$03
	jsr SpawnFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy0C_Sub4_Exit
	;Spawn projectile
	ldx $00
	jsr Level1BossAttackSpawn
	;Offset projectile X position based on enemy facing direction
	lda Enemy_Props+$0A
	asl
	asl
	lda #$08
	bcc Level1BossAttackSub_PosX
	ora #$F0
Level1BossAttackSub_PosX:
	adc Enemy_X+$08,x
	sta Enemy_X+$08,x
	;Play sound
	lda #SE_LEVEL1BOSSFIRE
	jsr LoadSound
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy0C_Sub4_Exit
	;Get angle data bits
	lda $06
	lsr
	sta $0E
	tay
	;Get quadrant bits
	lda $07
	sta $0F
	;Rotate target direction clockwise 30 deg.
	dey
	dey
	bpl Level1BossAttackSub_SetQ1
	cpy #$FF
	ldy #$01
	bcs Level1BossAttackSub_NoQC1
	iny
Level1BossAttackSub_NoQC1:
	eor #$01
	sta $07
Level1BossAttackSub_SetQ1:
	tya
	asl
	;Set projectile velocity to target player
	jsr TargetPlayer
	;Spawn projectile
	jsr Level1BossAttackSpawnOffs
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy0C_Sub5_Exit
	;Rotate target direction counterclockwise 30 deg.
	ldy $0E
	lda $0F
	iny
	iny
	cpy #$07
	bcc Level1BossAttackSub_SetQ2
	cpy #$08
	ldy #$05
	bcc Level1BossAttackSub_NoQC2
	dey
Level1BossAttackSub_NoQC2:
	eor #$02
Level1BossAttackSub_SetQ2:
	sta $07
	tya
	asl
	;Set projectile velocity to target player
	jsr TargetPlayer
	;Spawn projectile
	jsr Level1BossAttackSpawnOffs
	;Restore X register
	ldx CurEnemyIndex
	rts
Level1BossAttackSpawnOffs:
	;Offset projectile X position based on enemy facing direction
	ldy CurEnemyIndex
	lda Enemy_Props+$08,y
	asl
	asl
	lda #$08
	bcc Level1BossAttackSpawnOffs_PosX
	ora #$F0
Level1BossAttackSpawnOffs_PosX:
	adc Enemy_X+$08,y
	sta Enemy_X+$08,x
	;Offset projectile Y position
	lda Enemy_Y+$08,y
	sec
	sbc #$08
	sta Enemy_Y+$08,x
	lda Enemy_YHi+$08,y
	sta Enemy_YHi+$08,x
	lda Enemy_XHi+$08,y
	sta Enemy_XHi+$08,x
Level1BossAttackSpawn:
	;Set enemy sprite based on angle bits
	lda $06
	lsr
	tay
	lda Level1BossFireSprite,y
	sta Enemy_Sprite+$08,x
	;Set enemy ID $0D (Level 1 boss fire)
	lda #ENEMY_LEVEL1BOSSFIRE
	sta Enemy_ID,x
	;Set enemy flags/props
	lda #$06
	sta Enemy_Flags,x
	lda Enemy_YVel,x
	asl
	lda Enemy_XVel,x
	ror
	and #$C0
	sta Enemy_Props+$08,x
	rts
Level1BossFireSprite:
	.db $13,$13,$11,$11,$11,$12,$12

;$0D: Level 1 boss fire
Enemy0DJumpTable:
	.dw Enemy0D_Sub0	;$00  Init
	.dw Enemy0D_Sub1	;$01  Main
;$00: Init
Enemy0D_Sub0:
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
Enemy0D_Sub1:
	;Move enemy
	jmp MoveEnemyXY

;$3B: Level 3 boss
Enemy3BJumpTable:
	.dw Enemy3B_Sub0	;$00  Init
	.dw Enemy3B_Sub1	;$01  Wait
	.dw Enemy3B_Sub2	;$02  Splash part 1
	.dw Enemy3B_Sub3	;$03  Splash part 2
	.dw Enemy3B_Sub4	;$04  Moving up
	.dw Enemy3B_Sub5	;$05  Up
	.dw Enemy3B_Sub6	;$06  Moving down
	.dw Enemy3B_Sub7	;$07  Clear parts
	.dw Enemy3B_Sub8	;$08  Death init
	.dw Enemy3B_Sub9	;$09  Death wait
	.dw Enemy3B_SubA	;$0A  Death explode
	.dw Enemy3B_SubB	;$0B  Death flash
	.dw Enemy3B_SubC	;$0C  Death splash
;$00: Init
Enemy3B_Sub0:
	;Check if enemy HP < 0
	lda Enemy_HP+$02
	bpl Enemy3B_Sub0_NoDeath
	;Next task ($08: Death init)
	lda #$08
	sta Enemy_Mode+$02
	;Set animation timer
	lda #$60
	sta Enemy_Temp1+$02
	rts
Enemy3B_Sub0_NoDeath:
	;Load CHR bank
	lda #$3D
	sta TempCHRBanks+2
	;Set enemy X position
	lda #$88
	sta Enemy_X+$0A
	;Check for boss rush level
	lda CurLevel
	cmp #$02
	beq Enemy3B_Sub0_NoBR
	;If scroll Y position not 0, exit early
	lda TempMirror_PPUSCROLL_Y
	bne Enemy3B_Sub1_Exit
	;Set sprite boss mode flag
	dec SpriteBossModeFlag
	;Set animation timer
	lda #$08
	sta Enemy_Temp1+$02
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|$0E)
	sta Enemy_Flags+$02
	;Set enemy ID $56 (Level 3 boss fade)
	lda #ENEMY_LEVEL3BOSSFADE
	sta Enemy_ID+$02
	rts
Enemy3B_Sub0_NoBR:
	;Set sprite boss mode flag
	dec SpriteBossModeFlag
	;Set animation timer
	lda #$50
	sta Enemy_Temp1+$02
	;Next task ($01: Wait)
	inc Enemy_Mode+$02
	;Add IRQ buffer region (level 3 boss layer 1)
	lda #$08
	jsr AddIRQBufferRegion
	;Add IRQ buffer region (level 3 boss layer 2)
	lda #$09
	jmp AddIRQBufferRegion
;$01: Wait
Enemy3B_Sub1:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1+$02
	bne Enemy3B_Sub1_Exit
	;Spawn splash
	clc
	lda Enemy_X+$0A
	adc #$40
	sta Enemy_X+$0C
	lda Enemy_Y+$0A
	sbc #$2F
	sta Enemy_Y+$0C
	lda #ENEMY_LEVEL3BOSSSPLASH
	sta Enemy_ID+$04
	;Set animation timer
	lda #$20
	sta Enemy_Temp1+$02
	;Next task ($02: Splash part 1)
	inc Enemy_Mode+$02
	;Play sound
	lda #SE_SPLASH
	jmp LoadSound
Enemy3B_Sub1_Exit:
	rts
;$02: Splash part 1
Enemy3B_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1+$02
	bne Enemy3B_Sub1_Exit
	;Spawn splash
	sec
	lda Enemy_X+$0A
	sbc #$40
	sta Enemy_X+$13
	lda Enemy_Y+$0A
	sbc #$30
	sta Enemy_Y+$13
	lda #ENEMY_LEVEL3BOSSSPLASH
	sta Enemy_ID+$0B
	;Set animation timer
	lda #$80
	sta Enemy_Temp1+$02
	;Next task ($03: Splash part 2)
	inc Enemy_Mode+$02
	;Play sound
	lda #SE_SPLASH
	jmp LoadSound
;$05: Up
Enemy3B_Sub5:
	;Flash palette
	jsr Level3BossFlashPalette
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	bne Enemy3B_Sub5_NoNext
	;If bits 0-2 of global timer not 0, don't write VRAM strip
	lda GlobalTimer
	and #$07
	bne Enemy3B_SubA
Enemy3B_Sub5_NoNext:
	;Write enemy VRAM strip (level 3 boss)
	lda GlobalTimer
	and #$08
	lsr
	bne Enemy3B_Sub5_SetVRAM
	lda #$03
Enemy3B_Sub5_SetVRAM:
	jsr WriteEnemyVRAMStrip38
;$0A: Death explode
Enemy3B_SubA:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1+$02
	bne Enemy3B_SubA_Exit
	;Next task ($0B: Death flash)
	inc Enemy_Mode+$02
Enemy3B_SubA_Exit:
	rts
;$03: Splash part 2
Enemy3B_Sub3:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1+$02
	bne Enemy3B_Sub1_Exit
	;Next task ($04: Moving up)
	inc Enemy_Mode+$02
	;Play sound
	lda #SE_LEVEL3BOSSAPPEAR
	jmp LoadSound
;$04: Moving up
Enemy3B_Sub4:
	;Flash palette
	jsr Level3BossFlashPalette
	;If bit 0 of global timer 0, exit early
	lda GlobalTimer
	lsr
	bcc Enemy3B_Sub1_Exit
	;Move boss up $01
	dec Enemy_Y+$0A
	dec TempIRQBufferHeight
	inc TempIRQBufferHeight+1
	;Check if boss is all the way up
	ldy CurArea
	lda TempIRQBufferHeight
	cmp Level3BossUpYPosition-1,y
	bne Enemy3B_Sub1_Exit
	;Set animation timer
	lda #$80
	sta Enemy_Temp1+$02
	;Next task ($05: Up)
	inc Enemy_Mode+$02
	rts
Level3BossUpYPosition:
	.db $73,$62
;$06: Moving down
Enemy3B_Sub6:
	;Flash palette
	jsr Level3BossFlashPalette
	;If bit 0 of global timer 0, exit early
	lda GlobalTimer
	lsr
	bcc Enemy3B_Sub6_Exit
	;Move boss down $01
	inc Enemy_Y+$0A
	inc TempIRQBufferHeight
	dec TempIRQBufferHeight+1
	;If boss $02 above ground, play sound
	lda TempIRQBufferHeight+1
	cmp #$08
	bne Enemy3B_Sub6_NoSound
	;Play sound
	lda #SE_LEVEL3BOSSHIDE
	jmp LoadSound
Enemy3B_Sub6_NoSound:
	;Check if boss is all the way down
	cmp #$06
	bne Enemy3B_Sub6_Exit
	;Next task ($07: Clear parts)
	inc Enemy_Mode+$02
Enemy3B_Sub6_Exit:
	rts
;$07: Clear parts
Enemy3B_Sub7:
	;Clear level 3 boss parts
	ldx #$10
Enemy3B_Sub7_Loop:
	;Clear level 3 boss part
	jsr ClearEnemy
	;Loop for each part
	dex
	cpx #$03
	bcs Enemy3B_Sub7_Loop
	;Increment level 3 boss X position table offset
	inc Enemy_Temp2+$02
	;Set enemy X position
	lda Enemy_Temp2+$02
	and #$07
	tay
	lda Level3BossXPosition,y
	sta Enemy_X+$0A
	;Set level 3 boss scroll Y position
	eor #$7F
	adc #$09
	sta Enemy_Temp3+$02
	;Set animation timer
	lda #$80
	sta Enemy_Temp1+$02
	;Next task ($01: Wait)
	lda #$01
	sta Enemy_Mode+$02
	rts
;$08: Death init
Enemy3B_Sub8:
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	beq Enemy3B_Sub8_Next
	;Write enemy VRAM strip (level 3 boss)
	lda GlobalTimer
	and #$08
	lsr
	bne Enemy3B_Sub8_SetVRAM
	lda #$03
Enemy3B_Sub8_SetVRAM:
	jmp WriteEnemyVRAMStrip38
Enemy3B_Sub8_Next:
	;Set level 3 boss parts enemy flags
	ldx #$10
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|EF_ALLOWOFFSCREEN)
Enemy3B_Sub8_Loop:
	;Set enemy flags
	sta Enemy_Flags,x
	;Loop for each part
	dex
	cpx #$02
	bne Enemy3B_Sub8_Loop
	;Next task ($09: Death wait)
	inc Enemy_Mode+$02
	;Clear sound
	jsr ClearSound
	;Set boss death sound flag
	dec BossDeathSoundFlag
	;Play sound
	lda #DMC_BOSSDEATH0
	jmp LoadSound
;$09: Death wait
Enemy3B_Sub9:
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	bne Enemy3B_Sub9_NoNext
	;If bits 0-4 of animation timer not 0, don't write enemy VRAM strip
	lda Enemy_Temp1+$02
	and #$1F
	bne Enemy3B_Sub9_NoSetVRAM
	;Increment enemy VRAM strip index
	inc Enemy_Temp4+$02
Enemy3B_Sub9_NoNext:
	;Write enemy VRAM strip (level 3 boss)
	lda Enemy_Temp4+$02
	and #$01
	clc
	adc #$04
	jsr WriteEnemyVRAMStrip38
Enemy3B_Sub9_NoSetVRAM:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1+$02
	bne Enemy3B_Sub9_Exit
	;Explode level 3 boss parts
	ldx #$10
Enemy3B_Sub9_Loop:
	;Check if part is active
	lda Enemy_ID,x
	beq Enemy3B_Sub9_Next
	;Next task ($02: Death explode)
	inc Enemy_Mode,x
Enemy3B_Sub9_Next:
	;Loop for each part
	dex
	cpx #$02
	bne Enemy3B_Sub9_Loop
	;Set animation timer
	lda #$20
	sta Enemy_Temp1+$02
	;Next task ($0A: explode)
	inc Enemy_Mode+$02
Enemy3B_Sub9_Exit:
	rts
;$0B: Death flash
Enemy3B_SubB:
	;Show/hide level 3 boss based on bit 0 of global timer
	lda GlobalTimer
	lsr
	lda #$08
	bcc Enemy3B_SubB_SetIRQ
	lda #$0C
Enemy3B_SubB_SetIRQ:
	sta TempIRQBufferSub
	;If level 3 boss visible, exit early
	bcc Enemy3B_Sub9_Exit
	;Move boss down $01
	inc TempIRQBufferHeight
	dec TempIRQBufferHeight+1
	;If boss $02 above ground, play sound
	lda TempIRQBufferHeight+1
	cmp #$08
	bne Enemy3B_SubB_NoSound
	;Play sound
	lda #SE_LEVEL3BOSSHIDE
	jmp LoadSound
Enemy3B_SubB_NoSound:
	;Check if boss is all the way down
	cmp #$06
	bne Enemy3B_Sub9_Exit
	;Set timer
	lda #$46
	sta GameModeTimer
	;Next task ($0C: Death splash)
	inc Enemy_Mode,x
	rts
;$0C: Death splash
Enemy3B_SubC:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne Enemy3B_SubC_Exit
	;Remove IRQ buffer region
	lda TempIRQBufferSub
	jsr RemoveIRQBufferRegion
	;Check for boss rush level
	lda CurLevel
	cmp #$05
	beq Enemy3B_SubC_BR
	;Kill enemy normally
	jmp Enemy01_Sub1_End
Enemy3B_SubC_BR:
	;Next task ($04: Fade in init part 1)
	lda #$04
	sta Enemy_Mode+$02
	;Set enemy ID $56 (Level 3 boss fade)
	lda #ENEMY_LEVEL3BOSSFADE
	sta Enemy_ID+$02
Enemy3B_SubC_Exit:
	rts
Level3BossFlashPalette:
	;If enemy invincibility timer 0, exit early
	lda Enemy_InvinTimer+$02
	beq Enemy3B_SubC_Exit
	;If bit 0 of enemy invincibility timer not 0, exit early
	and #$01
	bne Enemy3B_SubC_Exit
	;Clear VRAM buffer
	sta VRAMBufferOffset
	;Set palette color based on bit 1 of enemy invincibility timer
	ldy #$30
	lda Enemy_InvinTimer+2
	and #$02
	beq Level3BossFlashPalette_SetColor
	ldy #$1B
Level3BossFlashPalette_SetColor:
	sty PaletteBuffer+$0D
	;Write palette
	jsr WritePalette
	;Restore X register
	ldx #$02
	rts
Level3BossXPosition:
	.db $80,$60,$90,$A0,$70,$52,$88,$58

;$3C: Level 3 boss part
Enemy3CJumpTable:
	.dw Enemy3C_Sub0	;$00  Init
	.dw Enemy3C_Sub1	;$01  Main
	.dw Enemy3C_Sub2	;$02  Death wait
	.dw Enemy3C_Sub3	;$03  Death explode
;$00: Init
Enemy3C_Sub0:
	;Set base part Y position
	lda Enemy_Y+$0A
	clc
	adc #$20
	sta Enemy_Y+$07,x
	;Set base part X position
	lda Enemy_X+$0A
	sta Enemy_X+$07,x
	;Clear part spawn counter
	ldy #$00
	sty $01
Enemy3C_Sub0_Loop:
	;Set wave animation data offset
	lda Level3BossPartInitOffs,y
	sta Enemy_Temp2,x
	;Offset part Y position
	tay
	clc
	lda Level3BossPartYOffsetTable,y
	sta $00
	adc Enemy_Y+$07,x
	sta Enemy_Y+$08,x
	lda #$00
	bit $00
	bpl Enemy3C_Sub0_NoYC
	lda #$FF
Enemy3C_Sub0_NoYC:
	adc Enemy_YHi+$07,x
	sta Enemy_YHi+$08,x
	;Check if left or right part
	cpx #$0B
	bcs Enemy3C_Sub0_Left
	;Offset part X position (right)
	lda Enemy_X+$07,x
	clc
	adc Level3BossPartXOffsetTable,y
	bne Enemy3C_Sub0_SetX
Enemy3C_Sub0_Left:
	;Flip enemy X
	lda #$40
	sta Enemy_Props+$08,x
	;Offset part X position (left)
	sec
	lda Enemy_X+$07,x
	sbc Level3BossPartXOffsetTable,y
Enemy3C_Sub0_SetX:
	sta Enemy_X+$08,x
	;Set enemy sprite/flags
	lda #$23
	sta Enemy_Sprite+$08,x
	lda #(EF_NOHITATTACK|EF_ALLOWOFFSCREEN|$02)
	sta Enemy_Flags,x
	;Set enemy ID $3C (Level 3 boss part)
	lda #ENEMY_LEVEL3BOSSPART
	sta Enemy_ID,x
	;If part Y offset $05, don't flip enemy X
	lda $00
	cmp #$05
	beq Enemy3C_Sub0_Next
	;If bit 0 of part Y offset not 0, don't flip enemy X
	lsr
	bcc Enemy3C_Sub0_Next
	;Flip enemy X
	lda Enemy_Props+$08,x
	eor #$40
	sta Enemy_Props+$08,x
Enemy3C_Sub0_Next:
	;Next task ($01: Main)
	inc Enemy_Mode,x
	;Loop for each part
	inx
	inc $01
	ldy $01
	cpy #$06
	bcc Enemy3C_Sub0_Loop
	;Set end part enemy sprite
	lda #$27
	sta Enemy_Sprite+$07,x
	;Set end part flag
	lda #$FF
	sta Enemy_YVelLo-$01,x
	;Restore X register
	ldx CurEnemyIndex
	;Set wave offset velocity start
	sta Enemy_Temp4,x
	;Set base part flag
	sta Enemy_Temp5,x
	rts
Level3BossPartInitOffs:
	.db $0C,$12,$18,$18,$18,$18
	.db $0C,$12,$18,$18,$18,$18
Level3BossPartYOffsetTable:
	.db $F0,$F0,$F1,$F1,$F2,$F3
	.db $F5,$F6,$F8,$FA,$FC,$FE
	.db $00,$00,$02,$04,$06,$08
	.db $0A,$0B,$0D,$0E,$0F,$0F
	.db $10
Level3BossPartXOffsetTable:
	.db $00,$02,$04,$06,$08,$0A
	.db $0B,$0D,$0E,$0F,$0F,$10
	.db $10,$10,$0F,$0F,$0E,$0D
	.db $0B,$0A,$08,$06,$04,$02
	.db $00
;$01: Main
Enemy3C_Sub1:
	;If animation timer 0, skip this part
	lda Enemy_Temp1,x
	beq Enemy3C_Sub1_NoSetStart
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy3C_Sub1_NoSetStart
	;Check if wave offset < $0C
	lda Enemy_Temp2,x
	cmp #$0C
	lda #$01
	bcc Enemy3C_Sub1_SetStart
	lda #$FF
Enemy3C_Sub1_SetStart:
	;Set wave offset velocity start
	sta Enemy_Temp4,x
Enemy3C_Sub1_NoSetStart:
	;If wave offset velocity not 0, don't set wave offset velocity
	lda Enemy_Temp3,x
	bne Enemy3C_Sub1_NoSetOffsVel
	;If wave offset velocity start not 0, set wave offset velocity
	lda Enemy_Temp4,x
	bne Enemy3C_Sub1_SetOffsVel
	jmp Enemy3C_Sub1_NoShiftStart
Enemy3C_Sub1_SetOffsVel:
	;Set wave offset velocity
	sta Enemy_Temp3,x
Enemy3C_Sub1_NoSetOffsVel:
	;Check if wave offset velocity > 0
	bpl Enemy3C_Sub1_CheckIncOffs
	;Check for min wave offset
	lda Enemy_Temp2,x
	beq Enemy3C_Sub1_NoSetOffs
	;Check for base part
	ldy Enemy_Temp5,x
	beq Enemy3C_Sub1_DecOffsNoBase
	;If wave offset < $08, don't set wave offset
	cmp #$08
	bcc Enemy3C_Sub1_NoSetOffs
Enemy3C_Sub1_DecOffsNoBase:
	;Decrement wave offset
	sec
	sbc #$01
	sta $00
	;Check for end part
	ldy Enemy_YVelLo,x
	bne Enemy3C_Sub1_SetOffs
	;Get wave offset distance from child part
	sec
	sbc Enemy_Temp2+$01,x
	bcs Enemy3C_Sub1_DecPosD
	eor #$FF
	adc #$01
Enemy3C_Sub1_DecPosD:
	;If wave offset distance < $04, set wave offset
	cmp #$04
	bcc Enemy3C_Sub1_SetOffs
	;If child part wave offset velocity start not $01, set child part wave offset velocity
	lda Enemy_Temp4+$01,x
	cmp #$01
	beq Enemy3C_Sub1_NoSetOffs
	;Set child part wave offset velocity
	lda #$FF
	sta Enemy_Temp3+$01,x
	bne Enemy3C_Sub1_NoSetOffs
Enemy3C_Sub1_CheckIncOffs:
	;Check for max wave offset
	lda Enemy_Temp2,x
	cmp #$18
	beq Enemy3C_Sub1_NoSetOffs
	;Check for base part
	ldy Enemy_Temp5,x
	beq Enemy3C_Sub1_IncOffsNoBase
	;If wave offset >= $10, don't set wave offset
	cmp #$10
	bcs Enemy3C_Sub1_NoSetOffs
Enemy3C_Sub1_IncOffsNoBase:
	;Increment wave offset
	clc
	adc #$01
	sta $00
	;Check for end part
	ldy Enemy_YVelLo,x
	bne Enemy3C_Sub1_SetOffs
	;Get wave offset distance from child part
	sec
	lda Enemy_Temp2+$01,x
	sbc $00
	bcs Enemy3C_Sub1_IncPosD
	eor #$FF
	adc #$01
Enemy3C_Sub1_IncPosD:
	;If wave offset distance < $04, set wave offset
	cmp #$04
	bcc Enemy3C_Sub1_SetOffs
	;If child part wave offset velocity start not $FF, set child part wave offset velocity
	lda Enemy_Temp4+$01,x
	bmi Enemy3C_Sub1_NoSetOffs
	;Set child part wave offset velocity
	lda #$01
	sta Enemy_Temp3+$01,x
	bne Enemy3C_Sub1_NoSetOffs
Enemy3C_Sub1_SetOffs:
	;Clear wave offset velocity
	lda #$00
	sta Enemy_Temp3,x
	;Set wave offset
	lda $00
	sta Enemy_Temp2,x
Enemy3C_Sub1_NoSetOffs:
	;If wave offset velocity start 0, don't shift start index
	lda Enemy_Temp4,x
	beq Enemy3C_Sub1_NoShiftStart
	;Check if wave offset velocity start > 0
	bpl Enemy3C_Sub1_CheckIncShift
	;Check for min wave offset
	lda Enemy_Temp2,x
	beq Enemy3C_Sub1_CheckShiftStart
	;Check for base part
	lda Enemy_Temp2-$01,x
	ldy Enemy_Temp5,x
	beq Enemy3C_Sub1_IncShiftNoBase
	lda #$0C
Enemy3C_Sub1_IncShiftNoBase:
	;Get wave offset distance from parent part
	sbc Enemy_Temp2,x
	;If wave offset distance < 0, don't shift start index
	bcc Enemy3C_Sub1_NoShiftStart
	bcs Enemy3C_Sub1_ShiftPosD
Enemy3C_Sub1_CheckIncShift:
	;Check for max wave offset
	lda Enemy_Temp2,x
	cmp #$18
	beq Enemy3C_Sub1_CheckShiftStart
	;Check for base part
	ldy Enemy_Temp5,x
	beq Enemy3C_Sub1_DecShiftNoBase
	;If wave offset not $10, don't shift start index
	cmp #$10
	bne Enemy3C_Sub1_NoShiftStart
	beq Enemy3C_Sub1_CheckShiftStart
Enemy3C_Sub1_DecShiftNoBase:
	;Get wave offset distance from parent part
	sbc Enemy_Temp2-$01,x
	;If wave offset distance < 0, don't shift start index
	bcc Enemy3C_Sub1_NoShiftStart
Enemy3C_Sub1_ShiftPosD:
	;If wave offset distance < $04, don't shift start index
	cmp #$04
	bcc Enemy3C_Sub1_NoShiftStart
Enemy3C_Sub1_CheckShiftStart:
	;Check for end part
	ldy Enemy_YVelLo,x
	bne Enemy3C_Sub1_ClearStart
	;If child part wave offset velocity start not 0, don't shift start index
	lda Enemy_Temp4+$01,x
	bne Enemy3C_Sub1_NoShiftStart
	;Propagate wave offset velocity start to child part
	lda Enemy_Temp4,x
	sta Enemy_Temp4+$01,x
	;Check for base part
	ldy Enemy_Temp5,x
	beq Enemy3C_Sub1_ClearStart
	;Set animation timer
	lda #$38
	sta Enemy_Temp1,x
Enemy3C_Sub1_ClearStart:
	;Clear wave offset velocity start
	lda #$00
	sta Enemy_Temp4,x
Enemy3C_Sub1_NoShiftStart:
	;Check for base part
	ldy Enemy_Temp5,x
	bne Enemy3C_Sub1_Move
	;Check for end part
	ldy Enemy_YVelLo,x
	beq Enemy3C_Sub1_Exit
	;Set enemy sprite based on wave offset
	ldy Enemy_Temp2,x
	lda Level3BossEndPartSprite,y
	sta Enemy_Sprite+$08,x
	;If wave offset >= $0D, flip enemy Y
	cpy #$0D
	lda Enemy_Props+$08,x
	and #$40
	bcc Enemy3C_Sub1_SetP
	;Flip enemy Y
	ora #$80
Enemy3C_Sub1_SetP:
	;Set enemy props
	sta Enemy_Props+$08,x
Enemy3C_Sub1_Exit:
	rts
Enemy3C_Sub1_Move:
	;Set base part Y position
	clc
	lda Enemy_Y+$0A
	adc #$20
	sta Enemy_Y+$07,x
	;Set base part X position
	lda Enemy_X+$0A
	sta Enemy_X+$07,x
Enemy3C_Sub1_MoveLoop:
	;Offset part Y position
	ldy Enemy_Temp2,x
	clc
	lda Level3BossPartYOffsetTable,y
	sta $00
	adc Enemy_Y+$07,x
	sta Enemy_Y+$08,x
	lda #$00
	bit $00
	bpl Enemy3C_Sub1_MoveNoYC
	lda #$FF
Enemy3C_Sub1_MoveNoYC:
	adc Enemy_YHi+$07,x
	sta Enemy_YHi+$08,x
	;Check if left or right part
	cpx #$0B
	bcs Enemy3C_Sub1_MoveLeft
	;Offset part X position (right)
	lda Enemy_X+$07,x
	clc
	adc Level3BossPartXOffsetTable,y
	bne Enemy3C_Sub1_MoveSetX
Enemy3C_Sub1_MoveLeft:
	;Offset part X position (left)
	sec
	lda Enemy_X+$07,x
	sbc Level3BossPartXOffsetTable,y
Enemy3C_Sub1_MoveSetX:
	sta Enemy_X+$08,x
	;Loop for each part
	inx
	lda Enemy_YVelLo-$01,x
	beq Enemy3C_Sub1_MoveLoop
	;Restore X register
	ldx CurEnemyIndex
	rts
Level3BossEndPartSprite:
	.db $24,$24,$24,$25,$25,$25
	.db $26,$26,$26,$26,$26,$27
	.db $27,$27,$26,$26,$26,$26
	.db $26,$25,$25,$25,$24,$24
	.db $24
;$02: Death wait
Enemy3C_Sub2:
	;Clear enemy animation timer/offset
	lda #$FF
	sta Enemy_AnimTimer,x
	sta Enemy_AnimOffs,x
	;Check for end part
	lda Enemy_YVelLo,x
	beq Enemy3C_Sub2_Exit
	;Next task ($03: Death explode)
	inc Enemy_Mode,x
	;Play sound
	lda #SE_ENEMYDEATH
	jmp LoadSound
Enemy3C_Sub2_Exit:
	rts
;$03: Death explode
Enemy3C_Sub3:
	;Update enemy animation
	ldy #$02
	jsr UpdateEnemyAnimation_AnyY
	;If enemy animation offset < $02, exit early
	lda Enemy_AnimOffs,x
	cmp #$02
	bcc Enemy3C_Sub2_Exit
	;Check for base part
	lda Enemy_Temp5,x
	bne Enemy3C_Sub3_NoSound
	;Next task ($03: Death explode)
	inc Enemy_Mode-$01,x
	;If enemy Y position >= $C0, don't play sound
	lda Enemy_YHi+$08,x
	bne Enemy3C_Sub3_NoSound
	lda Enemy_Y+$08,x
	cmp #$C0
	bcs Enemy3C_Sub3_NoSound
	;Play sound
	lda #SE_ENEMYDEATH
	jsr LoadSound
Enemy3C_Sub3_NoSound:
	;Clear enemy
	jmp ClearEnemy

;$3E: Level 3 boss splash
Enemy3EJumpTable:
	.dw Enemy3E_Sub0	;$00  Init
	.dw Enemy3E_Sub1	;$01  Main
;$00: Init
Enemy3E_Sub0:
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags,x
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
Enemy3E_Sub0_Exit:
	rts
;$01: Main
Enemy3E_Sub1:
	;If animation timer $20, play sound
	lda Enemy_Temp1,x
	cmp #$20
	bne Enemy3E_Sub1_NoSound
	;Play sound
	lda #SE_SPLASH
	jsr LoadSound
Enemy3E_Sub1_NoSound:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy3E_Sub0_Exit
	;Clear enemy
	jsr ClearEnemy
	;Set enemy ID $3C (Level 3 boss part)
	lda #ENEMY_LEVEL3BOSSPART
	sta Enemy_ID,x
	rts

;$39: Level 4 boss
Enemy39JumpTable:
	.dw Enemy39_Sub0	;$00  Init
	.dw Enemy39_Sub1	;$01  Offscreen X
	.dw Enemy39_Sub2	;$02  Offscreen Y
	.dw Enemy39_Sub3	;$03  Attack
	.dw Enemy39_Sub4	;$04  Moving down
	.dw Enemy39_Sub5	;$05  Moving up
	.dw Enemy39_Sub6	;$06  Moving left
	.dw Enemy39_Sub7	;$07  Moving right
	.dw Enemy39_Sub8	;$08  Loop end
	.dw Enemy39_Sub9	;$09  Death fall
	.dw Enemy39_SubA	;$0A  Death flash
;$00: Init
Enemy39_Sub0:
	;Check if enemy HP < 0
	lda Enemy_HP+$02
	bpl Enemy39_Sub0_NoDeath
	;Next task ($09: Death fall)
	lda #$09
	sta Enemy_Mode+$02
	;Clear enemy animation offset/timer
	ldy #$FF
	sty Enemy_AnimOffs+$02
	sty Enemy_AnimTimer+$02
	;Clear auto scroll velocity
	iny
	sty AutoScrollXVel
	sty AutoScrollYVel
	;Set enemy velocity/props/sprite
	lda Enemy_X+$0A
	bmi Enemy39_Sub0_Right
	iny
Enemy39_Sub0_Right:
	sty Enemy_XVel+$02
	tya
	lsr
	and #$40
	eor #$40
	sta Enemy_Props+$0A
	lda #$80
	sta Enemy_XVelLo+$02
	lda #$FD
	sta Enemy_YVel+$02
	lda #$2C
	sta Enemy_Sprite+$0A
	;Set timer
	ldy #$20
	sty GameModeTimer
	;Load CHR bank
	lda #$32
	sta TempCHRBanks+2
Enemy39_Sub0_Exit:
	rts
Enemy39_Sub0_NoDeath:
	;Check for boss rush level
	lda CurLevel
	cmp #$03
	beq Enemy39_Sub0_NoBR
	;Clear level 4 boss crane
	lda #$00
	sta Enemy_ID+$03
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|EF_ALLOWOFFSCREEN|$01)
	sta Enemy_Flags+$02
	;If scroll Y position not 0, exit early
	lda TempMirror_PPUSCROLL_Y
	bne Enemy39_Sub0_Exit
	;Set animation timer
	lda #$08
	sta Enemy_Temp1+$02
	;Set enemy ID $57 (Level 4 boss fade)
	lda #ENEMY_LEVEL4BOSSFADE
	sta Enemy_ID+$02
	rts
Enemy39_Sub0_NoBR:
	;Set sprite boss mode flag
	dec SpriteBossModeFlag
	;Set scroll position
	lda #$20
	sta TempMirror_PPUSCROLL_Y
	lda #$E8
	sta TempMirror_PPUSCROLL_X
	;Disable enemy scroll
	lda #$FF
	sta ScrollEnemyFlag
	;Enable enemy subroutine while invincible
	lda #$80
	sta Enemy_Temp0+$02
	;Set elevator position
	lda #$98
	sta ElevatorYPos
	;Set scroll lock settings
	lda #$01
	sta TempScrollLockFlags
	lda #$DE
	sta TempScrollLockOther
	;Draw level 4 boss ground
	ldx VRAMBufferOffset
	lda #$03
	sta VRAMBuffer,x
	lda #$00
	sta VRAMBuffer+1,x
	lda #$23
	sta VRAMBuffer+2,x
	lda #$20
	sta VRAMBuffer+3,x
	lda #$E0
	sta VRAMBuffer+4,x
	txa
	clc
	adc #$05
	tax
	lda #$03
	sta VRAMBuffer,x
	lda #$20
	sta VRAMBuffer+1,x
	lda #$23
	sta VRAMBuffer+2,x
	lda #$20
	sta VRAMBuffer+3,x
	lda #$CC
	sta VRAMBuffer+4,x
	txa
	clc
	adc #$05
	tax
	lda #$03
	sta VRAMBuffer,x
	lda #$80
	sta VRAMBuffer+1,x
	lda #$2B
	sta VRAMBuffer+2,x
	lda #$40
	sta VRAMBuffer+3,x
	lda #$00
	sta VRAMBuffer+4,x
	txa
	clc
	adc #$05
	tax
	lda #$03
	sta VRAMBuffer,x
	lda #$00
	sta VRAMBuffer+1,x
	lda #$20
	sta VRAMBuffer+2,x
	lda #$80
	sta VRAMBuffer+3,x
	lda #$00
	sta VRAMBuffer+4,x
	txa
	clc
	adc #$05
	sta VRAMBufferOffset
	;Set HUD VRAM pointer
	lda #$22
	sta HUDVRAMPointer+1
	lda #$80
	sta HUDVRAMPointer
	;Set black screen timer
	lda #$02
	sta BlackScreenTimer
	;Restore X register
	tax
	;Add IRQ buffer region (level 4 boss crane)
	lda #$0E
	jsr AddIRQBufferRegion
	;Load CHR bank
	lda #$32
	sta TempCHRBanks+2
	;Set enemy Y position/props
	lda #$FF
	sta Enemy_YHi+$0A
	lda #$A4
	sta Enemy_Y+$0A
	lda #$40
	sta Enemy_Props+$0A
	;Clear auto scroll flags
	lda #$05
	sta AutoScrollDirFlags
	;Get next movement direction
	jmp Enemy39_Sub5_Next
;$01: Offscreen X
Enemy39_Sub1:
	;If scroll X position not $E8, exit early
	lda TempMirror_PPUSCROLL_X
	cmp #$E8
	bne Enemy39_Sub2_Exit
	;Set enemy Y position/props
	lda #$00
	sta Enemy_YHi+$0A
	lda #$84
	sta Enemy_Y+$0A
	;Set scroll lock settings
	lda #$10
	sta TempScrollLockOther
	;Increment path data index
	inc Enemy_Temp2+$02
	;Get next movement direction
	ldy Enemy_Temp2+$02
	lda Level4BossPathData,y
	sta Enemy_Mode+$02
	;Set current X screen
	asl
	and #$03
	sta CurScreenX
	;Set auto scroll X velocity
	cmp #$02
	lda #$02
	bcc Enemy39_Sub1_Right
	lda #$FE
Enemy39_Sub1_Right:
	sta AutoScrollXVel
	;Set enemy X position
	ror
	sta Enemy_XHi+$0A
	;Set scroll Y position
	lda #$20
	sta TempMirror_PPUSCROLL_Y
	;Play sound
	lda #SE_LEVEL4CRANE
	jmp LoadSound
;$02: Offscreen Y
Enemy39_Sub2:
	;Set enemy position
	lda #$00
	sta Enemy_XHi+$0A
	lda #$A4
	sta Enemy_Y+$0A
	;If scroll X position $E8, get next movement direction
	lda TempMirror_PPUSCROLL_X
	cmp #$E8
	beq Enemy39_Sub5_Next
Enemy39_Sub2_Exit:
	rts
;$03: Attack
Enemy39_Sub3:
	;Check if timer < $10
	lda GameModeTimer
	cmp #$10
	bcc Enemy39_Sub3_Anim
	;If timer not $24, don't attack
	cmp #$24
	bne Enemy39_Sub3_NoAttack
	;Spawn projectiles
	jsr Level4BossAttackSub
Enemy39_Sub3_NoAttack:
	;Update enemy animation
	ldy #$3B
	lda Enemy_Temp3+$02
	cmp Enemy_X+$0A
	bcc Enemy39_Sub3_SetAnim
	iny
Enemy39_Sub3_SetAnim:
	jsr UpdateEnemyAnimation_AnyY
	;Load CHR bank based on enemy sprite
	ldy #$32
	lda Enemy_Sprite+$0A
	cmp #$28
	beq Enemy39_Sub3_SetCHR
	iny
Enemy39_Sub3_SetCHR:
	sty TempCHRBanks+2
	jmp Enemy39_Sub3_NoAnim
Enemy39_Sub3_Anim:
	;Update enemy animation
	jsr UpdateEnemyAnimation
Enemy39_Sub3_NoAnim:
	;Decrement timer, check if 0
	dec GameModeTimer
	beq Enemy39_Sub5_Next
	rts
;$04: Moving down
Enemy39_Sub4:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move boss down $02
	lda Enemy_Y+$0A
	clc
	adc #$02
	cmp #$F0
	bcc Enemy39_Sub4_NoYC
	inc Enemy_YHi+$0A
	adc #$10
Enemy39_Sub4_NoYC:
	sta Enemy_Y+$0A
	;Move crane down $02
	dec TempScrollLockOther
	dec TempScrollLockOther
	;If crane is all the way down, get next movement direction
	lda TempScrollLockOther
	cmp #$10
	beq Enemy39_Sub5_Next
Enemy39_Sub4_Exit:
	rts
;$05: Moving up
Enemy39_Sub5:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move boss up $02
	lda Enemy_Y+$0A
	sec
	sbc #$02
	bcs Enemy39_Sub5_NoYC
	dec Enemy_YHi+$0A
	sbc #$10
Enemy39_Sub5_NoYC:
	sta Enemy_Y+$0A
	;Move crane up $02
	lda TempScrollLockOther
	adc #$01
	sta TempScrollLockOther
	;If crane is not all the way up, exit early
	cmp #$DE
	bne Enemy39_Sub4_Exit
Enemy39_Sub5_Next:
	;Check to stop looping sound effect
	lda Enemy_Temp2+$02
	lsr
	lda #SE_LOOPEND
	bcs Enemy39_Sub5_LoadSound
	lda #SE_LEVEL4CRANE
Enemy39_Sub5_LoadSound:
	;Play sound
	jsr LoadSound
	;Load CHR bank
	ldy #$32
	sty TempCHRBanks+2
	;Increment path data index
	inc Enemy_Temp2+$02
	;Clear auto scroll X velocity
	lda #$00
	sta AutoScrollXVel
	;Check for end of path section
	ldy Enemy_Temp2+$02
	tya
	and #$03
	bne Enemy39_Sub5_NoEndPart
	ldy #$14
Enemy39_Sub5_NoEndPart:
	;Get next movement direction
	lda Level4BossPathData,y
	sta Enemy_Mode+$02
	;If end of path data, exit early
	cmp #$08
	beq Enemy39_Sub4_Exit
	;Check for moving X modes
	cmp #$06
	bcs Enemy39_Sub5_MoveX
	;If not attack mode, exit early
	cmp #$03
	bne Enemy39_Sub4_Exit
	;Find closest player
	jsr FindClosestPlayerX
	;Get target player X position
	lda Enemy_X,y
	sta Enemy_Temp3+$02
	;Set timer
	lda #$50
	sta GameModeTimer
	;Clear enemy animation offset/timer
	lda #$FF
	sta Enemy_AnimOffs+$02
	sta Enemy_AnimTimer+$02
	rts
Enemy39_Sub5_MoveX:
	;Set auto scroll X velocity
	lsr
	lda #$FE
	bcs Enemy39_Sub5_Left
	lda #$02
Enemy39_Sub5_Left:
	sta AutoScrollXVel
	;Set scroll lock settings
	lda #$10
	sta TempScrollLockOther
	rts
;$06: Moving left
Enemy39_Sub6:
	;Move boss left $02
	lda Enemy_X+$0A
	sec
	sbc #$02
	sta Enemy_X+$0A
	bcs Enemy39_Sub6_NoXC
	dec Enemy_XHi+$0A
Enemy39_Sub6_NoXC:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If crane is all the way left, get next movement direction
	lda TempMirror_PPUSCROLL_X
	cmp #$E8
	beq Enemy39_Sub5_Next
	rts
;$07: Moving right
Enemy39_Sub7:
	;Move boss right $02
	lda Enemy_X+$0A
	clc
	adc #$02
	sta Enemy_X+$0A
	bcc Enemy39_Sub6_NoXC
	inc Enemy_XHi+$0A
	;Update enemy animation and check crane position
	bcs Enemy39_Sub6_NoXC
;$08: Loop end
Enemy39_Sub8:
	;Set enemy position
	lda #$FF
	sta Enemy_YHi+$0A
	lda #$80
	sta Enemy_X+$0A
	;Set scroll lock settings
	lda #$DE
	sta TempScrollLockOther
	;Set auto scroll X velocity
	lda #$FC
	sta AutoScrollXVel
	;Set scroll X position
	ldy #$E8
	sty TempMirror_PPUSCROLL_X
Enemy39_Sub8_Next:
	;Get next movement direction
	ldy Enemy_Temp2+$02
	lda Level4BossPathData,y
	;Check for end of path data
	ldy #$00
	cmp #$08
	bne Enemy39_Sub8_NoEnd
	;Reset path data index
	sty Enemy_Temp2+$02
	beq Enemy39_Sub8_Next
Enemy39_Sub8_NoEnd:
	;Set next movement direction
	sta Enemy_Mode+$02
	;Set current X screen
	cmp #$01
	beq Enemy39_Sub8_MoveX
	lda #$02
Enemy39_Sub8_MoveX:
	sta CurScreenX
Enemy39_Sub8_Exit:
	rts
;$09: Death fall
Enemy39_Sub9:
	;Clear crane
	ldx #$03
	jsr ClearEnemy
	;Restore X register
	dex
	;If timer 0, don't update enemy animation
	lda GameModeTimer
	beq Enemy39_Sub9_NoAnim
	;Decrement timer
	dec GameModeTimer
	;Update enemy animation
	ldy #$3D
	jsr UpdateEnemyAnimation_AnyY
Enemy39_Sub9_NoAnim:
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate due to gravity
	lda Enemy_YVelLo+$02
	clc
	adc #$18
	sta Enemy_YVelLo+$02
	bcc Enemy39_Sub9_NoYC
	inc Enemy_YVel+$02
Enemy39_Sub9_NoYC:
	;If enemy Y velocity up, exit early
	lda Enemy_YVel+$02
	bmi Enemy39_Sub8_Exit
	;If enemy Y position < $A0, exit early
	lda Enemy_Y+$0A
	cmp #$A0
	bcc Enemy39_Sub8_Exit
	;Set enemy Y position
	lda #$A0
	sta Enemy_Y+$0A
	;Next task ($0A: Death flash)
	inc Enemy_Mode+$02
	;Set timer
	lda #$40
	sta GameModeTimer
	;Clear sound
	jsr ClearSound
	;Set boss death sound flag
	dec BossDeathSoundFlag
	;Play sound
	lda #DMC_BOSSDEATH0
	jmp LoadSound
;$0A: Death flash
Enemy39_SubA:
	;Clear/set enemy sprite based on bit 0 of timer
	lda GameModeTimer
	and #$01
	beq Enemy39_SubA_SetSp
	lda #$2E
Enemy39_SubA_SetSp:
	sta Enemy_Sprite+$0A
	;Decrement timer, check if 0
	dec GameModeTimer
	bne Enemy39_Sub8_Exit
	;Check for boss rush level
	lda CurLevel
	cmp #$05
	beq Enemy39_SubA_BR
	;Kill enemy normally
	jmp Enemy01_Sub1_End
Enemy39_SubA_BR:
	;Clear enemy sprite
	lda #$00
	sta Enemy_Sprite+$0A
	;Set scroll Y position
	lda #$20
	sta TempMirror_PPUSCROLL_Y
	;Set enemy ID $57 (Level 4 boss fade)
	lda #ENEMY_LEVEL4BOSSFADE
	sta Enemy_ID+$02
	;Next task ($04: Fade in init part 1)
	lda #$04
	sta Enemy_Mode+$02
	;Set animation timer
	asl
	sta Enemy_Temp1+$02
	rts
Level4BossAttackSub:
	;Get target player X position
	lda Enemy_Temp3+$02
	sta $09
	;Spawn projectiles
	lda #$03
	sta $08
Level4BossAttackSub_Loop:
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, skip this part
	bcc Level4BossAttackSub_End
	;Set enemy ID $3A (Level 4 boss fire)
	lda #ENEMY_LEVEL4BOSSFIRE
	sta Enemy_ID,x
	;Set enemy velocity data offset
	lda $08
	sta Enemy_Temp2,x
	;Set target player X position
	lda $09
	sta Enemy_Temp3,x
	;Offset projectile Y position
	txa
	tay
	ldx #$02
	lda #$F0
	jsr OffsetEnemyYPos
	;Loop for each projectile
	dec $08
	bpl Level4BossAttackSub_Loop
Level4BossAttackSub_End:
	;Restore X register
	ldx CurEnemyIndex
	;Play sound
	lda #SE_LEVEL4BOSSFIRE
	jmp LoadSound
	rts
	.db $4C
Level4BossPathData:
	.db $02,$04,$03,$05
	.db $01,$07,$03,$07
	.db $01,$06,$03,$06
	.db $02,$04,$03,$07
	.db $01,$07,$03,$05
	.db $08

;$3A: Level 4 boss fire
Enemy3AJumpTable:
	.dw Enemy3A_Sub0	;$00  Init
	.dw Enemy3A_Sub1	;$01  Main
;$00: Init
Enemy3A_Sub0:
	;Check if boss on left or right side of screen
	lda Enemy_Temp2,x
	ldy Enemy_Temp3,x
	bmi Enemy3A_Sub0_Right
	clc
	adc #$04
Enemy3A_Sub0_Right:
	;Set enemy velocity/flags
	tay
	lda Level4BossFireXVelocity,y
	sta Enemy_XVel,x
	lda Level4BossFireXVelocityLo,y
	sta Enemy_XVelLo,x
	lda #$FB
	sta Enemy_YVel,x
	lda #$00
	sta Enemy_YVelLo,x
	lda #(EF_NOHITATTACK|$02)
	sta Enemy_Flags,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
	rts
;$01: Main
Enemy3A_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy3A_Sub1_NoYC
	inc Enemy_YVel,x
Enemy3A_Sub1_NoYC:
	;Move enemy
	jmp MoveEnemyXY
	rts
Level4BossFireXVelocity:
	.db $00,$00,$01,$02
	.db $FF,$FF,$FE,$FD
Level4BossFireXVelocityLo:
	.db $60,$F0,$80,$10
	.db $A0,$10,$80,$F0

;$44: Level 4 boss crane
Enemy44JumpTable:
	.dw Enemy44_Sub0	;$00  Init
	.dw Enemy44_Sub1	;$01  Main
;$00: Init
Enemy44_Sub0:
	;Check for boss mode
	lda SpriteBossModeFlag
	beq Enemy44_Sub0_Exit
	;Set enemy Y position
	lda #$FF
	sta Enemy_YHi+$0B
	;Next task ($01: Main)
	inc Enemy_Mode+$03
Enemy44_Sub0_Exit:
	rts
;$01: Main
Enemy44_Sub1:
	;Offset enemy position
	lda Enemy_X+$0A
	clc
	adc #$18
	sta Enemy_X+$0B
	lda Enemy_XHi+$0A
	adc #$00
	sta Enemy_XHi+$0B
	lda Enemy_Y+$0A
	clc
	adc #$18
	sta Enemy_Y+$0B
	lda Enemy_YHi+$0A
	adc #$00
	sta Enemy_YHi+$0B
	rts

;$16: Level 2 boss
Enemy16JumpTable:
	.dw Enemy16_Sub0	;$00  Init
	.dw Enemy16_Sub1	;$01  Walk
	.dw Enemy16_Sub2	;$02  Hit
	.dw Enemy16_Sub3	;$03  Run
	.dw Enemy16_Sub4	;$04  Attack
	.dw Enemy16_Sub5	;$05  Death fall
	.dw Enemy16_Sub6	;$06  Death wait
	.dw Enemy16_Sub7	;$07  Death flash
	.dw Enemy16_Sub8	;$08  Boss rush flash
;$00: Init
Enemy16_Sub0:
	;Check if enemy HP < 0
	lda Enemy_HP,x
	bmi Enemy16_Sub0_Death
	;Move boss down $08
	lda Enemy_Y+$08,x
	clc
	adc #$08
	sta Enemy_Y+$08,x
	;Check for boss rush level
	lda CurLevel
	cmp #$01
	bne Enemy16_Sub0_BR
Enemy16_Sub0_NoBR:
	;Set sprite boss mode flag
	dec SpriteBossModeFlag
Enemy16_Sub0_Target:
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy X velocity to target player
	lda #$08
	jmp SetEnemyXVel_AnyY
Enemy16_Sub0_Death:
	;Load CHR bank
	lda #$28
	sta TempCHRBanks+2
	;Set enemy sprite
	lda #$17
	sta Enemy_Sprite+$08,x
	;Next task ($05: Death fall)
	lda #$05
	sta Enemy_Mode,x
	;Set animation timer
	lda #$68
	sta Enemy_Temp1,x
	rts
Enemy16_Sub0_BR:
	;Load CHR bank
	lda #$28
	sta TempCHRBanks+2
	;Set palette colors
	lda #$21
	sta PaletteBuffer+$1E
	lda #$3C
	sta PaletteBuffer+$1F
	;If scroll Y position not 0, exit early
	lda TempMirror_PPUSCROLL_Y
	bne Enemy16_Sub1_Exit
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Set enemy props/flags
	sta Enemy_Props+$08,x
	lda #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags,x
	;Next task ($08: Boss rush flash)
	lda #$08
	sta Enemy_Mode,x
	;Set sprite boss mode flag
	dec SpriteBossModeFlag
	rts
;$08: Boss rush flash
Enemy16_Sub8:
	;Clear/set enemy sprite based on bit 0 of animation timer
	lda Enemy_Temp1,x
	and #$01
	beq Enemy16_Sub8_SetSp
	lda #$17
Enemy16_Sub8_SetSp:
	sta Enemy_Sprite+$08,x
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy16_Sub1_Exit
	;Next task ($00: Init)
	lda #$00
	sta Enemy_Mode,x
	;Enable enemy collision
	lda Enemy_Flags,x
	and #(~(EF_NOHITENEMY|EF_NOHITATTACK))&$FF
	sta Enemy_Flags,x
	;Init enemy state
	jmp Enemy16_Sub0_NoBR
;$01: Walk
Enemy16_Sub1:
	;If enemy invincibility timer not 0, go to next task ($02: Hit)
	lda Enemy_InvinTimer,x
	beq Enemy16_Sub1_NoNext
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	;Set enemy sprite
	lda #$19
	sta Enemy_Sprite+$08,x
	;Next task ($02: Hit)
	inc Enemy_Mode,x
Enemy16_Sub1_Exit:
	rts
Enemy16_Sub1_NoNext:
	;Update enemy animation
	jsr UpdateEnemyAnimation
Enemy16_Sub1_EntWindigo:
	;Move enemy X
	jsr MoveEnemyX
	;Check for level bounds
	lda Enemy_X+$08,x
	sbc #$10
	bcc Enemy16_Sub1_Bound
	cmp #$E0
	bcc Enemy16_Sub1_Exit
Enemy16_Sub1_Bound:
	;Check to flip enemy X
	lda Enemy_X+$08,x
	eor Enemy_XVel,x
	bpl Enemy16_Sub1_Exit
	;Set turn around flag
	inc Enemy_Temp2,x
	;Flip enemy X
	jmp FlipEnemyX
;$02: Hit
Enemy16_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy16_Sub1_Exit
	;Clear turn around flag
	lda #$00
	sta Enemy_Temp2,x
	;Clear enemy animation timer
	sta Enemy_AnimTimer,x
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy X velocity to target player
	lda #$0A
	jmp SetEnemyXVel_AnyY
;$03: Run
Enemy16_Sub3:
	;Move enemy X
	jsr MoveEnemyX
	;Update enemy animation
	ldy #$20
	jsr UpdateEnemyAnimation_AnyY
	;Load CHR bank based on enemy animation offset
	ldy #$28
	lda Enemy_AnimOffs,x
	beq Enemy16_Sub3_SetCHR
	iny
Enemy16_Sub3_SetCHR:
	sty TempCHRBanks+2
	;Check if boss has turned around yet
	lda Enemy_Temp2,x
	beq Enemy16_Sub3_NoNext
	;Find closest player
	jsr FindClosestPlayerX
	;Check if player is in range
	lda #$40
	jsr CheckPlayerInRangeXVel
	bcc Enemy16_Sub3_Next
Enemy16_Sub3_NoNext:
	;Check for level bounds
	sec
	lda Enemy_X+$08,x
	sbc #$10
	bcc Enemy16_Sub1_Bound
	cmp #$E0
	bcs Enemy16_Sub1_Bound
	rts
Enemy16_Sub3_Next:
	;Set animation timer
	lda #$10
	sta Enemy_Temp1,x
	;Load CHR bank
	ldy #$28
	sty TempCHRBanks+2
	;Set enemy sprite
	lda #$17
	sta Enemy_Sprite+$08,x
	;Next task ($04: Attack)
	inc Enemy_Mode,x
	rts
;$04: Attack
Enemy16_Sub4:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy16_Sub4_Next
	;If animation timer $08, spawn projectile
	lda Enemy_Temp1,x
	cmp #$08
	bne Enemy16_Sub5_Exit
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;Offset projectile Y position
	txa
	tay
	lda #$00
	ldx CurEnemyIndex
	jsr OffsetEnemyYPos
	;Set enemy X velocity
	lda Enemy_Props+$08,x
	cmp #$40
	lda #$01
	bcc Enemy16_Sub4_Right
	lda #$FE
Enemy16_Sub4_Right:
	sta Enemy_XVel,y
	lda #$80
	sta Enemy_XVelLo,y
	;Set enemy ID $17 (Level 2 boss fire)
	lda #ENEMY_LEVEL2BOSSFIRE
	sta Enemy_ID,y
	;Set enemy flags/sprite
	lda #(EF_NOHITATTACK|$02)
	sta Enemy_Flags,y
	lda #$19
	sta Enemy_Sprite+$08,x
	;Play sound
	lda #SE_LEVEL2BOSSFIRE
	jmp LoadSound
Enemy16_Sub4_Next:
	;Next task ($00: Init)
	lda #$00
	sta Enemy_Mode,x
	;Set enemy X velocity to target player
	jmp Enemy16_Sub0_Target
;$05: Death fall
Enemy16_Sub5:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy16_Sub5_Next
	;If animation timer $30, set animation offset $00
	ldy #$00
	lda Enemy_Temp1,x
	cmp #$30
	beq Enemy16_Sub5_SetSp
	;If animation timer $18, set animation offset $01
	iny
	cmp #$18
	bne Enemy16_Sub5_Exit
	;Load CHR bank
	inc TempCHRBanks+2
Enemy16_Sub5_SetSp:
	;Set enemy sprite
	lda Level2BossDeathAnimSprite,y
	sta Enemy_Sprite+$08,x
Enemy16_Sub5_Exit:
	rts
Level2BossDeathAnimSprite:
	.db $1A,$1B
Enemy16_Sub5_Next:
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Next task ($06: Death wait)
	inc Enemy_Mode,x
	;Clear sound
	jsr ClearSound
	;Set boss death sound flag
	dec BossDeathSoundFlag
	;Play sound
	lda #DMC_BOSSDEATH0
	jmp LoadSound
;$06: Death wait
Enemy16_Sub6:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy16_Sub6_Exit
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Next task ($07: Death flash)
	inc Enemy_Mode,x
Enemy16_Sub6_Exit:
	rts
;$07: Death flash
Enemy16_Sub7:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy16_Sub7_CheckBR
	;Clear/set enemy sprite based on bit 0 of global timer
	lda GlobalTimer
	and #$01
	beq Enemy16_Sub7_SetSp
	lda #$1B
Enemy16_Sub7_SetSp:
	sta Enemy_Sprite+$08,x
	rts
Enemy16_Sub7_CheckBR:
	;Check for boss rush
	jmp CheckBossRush

;$17: Level 2 boss fire
Enemy17JumpTable:
	.dw Enemy17_Sub0	;$00  Init
	.dw Enemy17_Sub1	;$01  Main
;$00: Init
Enemy17_Sub0:
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
Enemy17_Sub1:
	;Move enemy X
	jsr MoveEnemyX
	;Update enemy animation
	jmp UpdateEnemyAnimation

;$42: Level 5 boss
Enemy42JumpTable:
	.dw Enemy42_Sub0	;$00  Init
	.dw Enemy42_Sub1	;$01  In init
	.dw Enemy42_Sub2	;$02  In
	.dw Enemy42_Sub3	;$03  Wait
	.dw Enemy42_Sub4	;$04  Flash
	.dw Enemy42_Sub5	;$05  Attack
	.dw Enemy42_Sub6	;$06  Out
	.dw Enemy42_Sub7	;$07  Death init
	.dw Enemy42_Sub8	;$08  Death fall
	.dw Enemy42_Sub9	;$09  Death wait
	.dw Enemy42_SubA	;$0A  Death flash
;$00: Init
Enemy42_Sub0:
	;Check if enemy HP < 0
	lda Enemy_HP+$02
	bpl Enemy42_Sub0_NoDeath
	jmp Enemy42_Sub7
Enemy42_Sub0_NoDeath:
	;Enable enemy subroutine while invincible
	lda #$80
	sta Enemy_Temp0,x
	;Check for boss rush level
	lda CurLevel
	cmp #$04
	beq Enemy42_Sub0_NoBR
	;If scroll Y position not 0, exit early
	lda TempMirror_PPUSCROLL_Y
	bne Enemy42_Sub0_Exit
	;Set palette colors
	lda #$03
	sta PaletteBuffer+$1D
	lda #$32
	sta PaletteBuffer+$1E
	lda #$14
	sta PaletteBuffer+$1F
Enemy42_Sub0_NoBR:
	;Set animation timer
	lda #$70
	sta Enemy_Temp1+$02
	;Set sprite boss mode flag
	dec SpriteBossModeFlag
	;Next task ($01: In init)
	inc Enemy_Mode+$02
Enemy42_Sub0_Exit:
	rts
;$01: In init
Enemy42_Sub1:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1+$02
	bne Enemy42_Sub0_Exit
	;Spawn fake bosses
	ldy #$03
Enemy42_Sub1_Loop:
	;Set enemy position/velocity/sprite
	lda Level5BossXPositionHi-$03,y
	sta Enemy_XHi+$08,y
	lda Level5BossYPositionHi-$03,y
	sta Enemy_YHi+$08,y
	lda Level5BossXPosition-$03,y
	sta Enemy_X+$08,y
	lda Level5BossYPosition-$03,y
	sta Enemy_Y+$08,y
	lda Level5BossXVelocity-$03,y
	sta Enemy_XVel,y
	lda #$00
	sta Enemy_YVel,y
	lda Level5BossXVelocityLo-$03,y
	sta Enemy_XVelLo,y
	lda Level5BossYVelocityLo-$03,y
	sta Enemy_YVelLo,y
	lda Level5BossSprite-$03,y
	sta Enemy_Sprite+$08,y
	;Check to flip enemy X
	cpy #$06
	bcc Enemy42_Sub1_NoFlip
	;Flip enemy X
	lda #$40
	sta Enemy_Props+$08,y
Enemy42_Sub1_NoFlip:
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|EF_ALLOWOFFSCREEN)
	sta Enemy_Flags,y
	;Set enemy ID $42 (Level 5 boss)
	lda #ENEMY_LEVEL5BOSS
	sta Enemy_ID,y
	;Next task ($02: In)
	lda #$02
	sta Enemy_Mode,y
	;Set animation timer
	lda #$60
	sta Enemy_Temp1,y
	;Loop for each fake boss
	iny
	cpy #$08
	bcc Enemy42_Sub1_Loop
	;Get random fake boss enemy slot index
	lda PRNGValue
	sta $00
	lda #$00
	clc
Enemy42_Sub1_RandLoop:
	rol $00
	rol
	cmp #$05
	bcc Enemy42_Sub1_RandNoC
	sbc #$05
Enemy42_Sub1_RandNoC:
	dey
	bne Enemy42_Sub1_RandLoop
	clc
	adc #$03
	tax
	;Set enemy flags
	lda #EF_ALLOWOFFSCREEN
	sta Enemy_Flags+$02
	;Copy enemy sprite/velocity from random fake boss
	lda Enemy_Sprite+$08,x
	sta Enemy_Sprite+$0A
	lda Enemy_XVel,x
	sta Enemy_XVel+$02
	lda Enemy_XVelLo,x
	sta Enemy_XVelLo+$02
	lda Enemy_YVelLo,x
	sta Enemy_YVelLo+$02
	lda #$00
	sta Enemy_YVel+$02
	;Offset real boss Y position
	ldy #$02
	jsr OffsetEnemyYPos
	;Set animation timer
	lda #$60
	sta Enemy_Temp1+$02
	;Clear enemy
	jsr ClearEnemy
	;Load CHR bank
	lda #$37
	sta TempCHRBanks+2
	;Restore X register
	ldx #$02
	;Next task ($02: In)
	inc Enemy_Mode+$02
	rts
Level5BossXPosition:
	.db $B4,$F6,$80,$4C,$0A
Level5BossXPositionHi:
	.db $FF,$FF,$00,$01,$01
Level5BossYPosition:
	.db $80,$F8,$C2,$80,$F8
Level5BossYPositionHi:
	.db $00,$FF,$FF,$00,$FF
Level5BossXVelocity:
	.db $01,$00,$00,$FF,$FF
Level5BossXVelocityLo:
	.db $00,$AC,$00,$00,$54
Level5BossYVelocityLo:
	.db $10,$BD,$FF,$10,$BD
Level5BossSprite:
	.db $36,$36,$38,$36,$36
;$02: In
Enemy42_Sub2:
	;Update enemy animation based on enemy sprite
	lda Enemy_Sprite+$08,x
	cmp #$38
	ldy #$3F
	bcc Enemy42_Sub2_Anim
	iny
Enemy42_Sub2_Anim:
	jsr UpdateEnemyAnimation_AnyY
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy42_Sub2_Next
	;If enemy invincibility timer >= $10, exit early
	lda Enemy_InvinTimer,x
	cmp #$10
	bcs Enemy42_Sub2_Exit
	;Move enemy
	jmp MoveEnemyXY
Enemy42_Sub2_Next:
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Set enemy sprite
	lda #$3A
	sta Enemy_Sprite+$08,x
	;Load CHR bank
	lda #$38
	sta TempCHRBanks+2
	;Next task ($03: Wait)
	inc Enemy_Mode,x
Enemy42_Sub2_Exit:
	rts
;$03: Wait
Enemy42_Sub3:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy42_Sub2_Exit
	;Next task ($04: Flash)
	inc Enemy_Mode,x
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;If not real boss, exit early
	cpx #$02
	bne Enemy42_Sub2_Exit
	;Find closest player
	jsr FindClosestPlayerX
	;Spawn projectile in free enemy slot
	lda #$F0
	ldx #$09
	jsr SpawnFreeEnemySlot
	;Set animation timer
	ldy $00
	lda #$10
	sta Enemy_Temp1,y
	;Set enemy ID $43 (Level 5 boss fire)
	lda #ENEMY_LEVEL5BOSSFIRE
	sta Enemy_ID,y
	;Set enemy flags
	lda #(EF_NOHITATTACK|$02)
	sta Enemy_Flags,y
	;Get projectile velocity
	lda Enemy_XVel,y
	sta Enemy_Temp2,x
	lda Enemy_XVelLo,y
	sta Enemy_Temp3,x
	lda Enemy_YVel,y
	sta Enemy_Temp4,x
	lda Enemy_YVelLo,y
	sta Enemy_Temp5,x
	;Next task ($05: Attack)
	inc Enemy_Mode,x
	;Play sound
	lda #SE_LEVEL5BOSSFIRE
	jmp LoadSound
;$04: Flash
Enemy42_Sub4:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Get enemy sprite
	lda Enemy_Sprite+$08,x
	beq Enemy42_Sub4_NoSp
	sta Enemy_Temp2,x
Enemy42_Sub4_NoSp:
	;If bit 0 of animation timer = bit 0 of enemy slot index, clear enemy sprite
	lda Enemy_Temp1,x
	eor CurEnemyIndex
	and #$01
	beq Enemy42_Sub4_SetSp
	;Set enemy sprite
	lda Enemy_Temp2,x
Enemy42_Sub4_SetSp:
	sta Enemy_Sprite+$08,x
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy42_Sub2_Exit
	;Clear enemy
	jmp ClearEnemy
;$05: Attack
Enemy42_Sub5:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Decrement animation timer, check if 0
	dec Enemy_Temp1+$02
	beq Enemy42_Sub5_Next
	;If animation timer $2C or $28, spawn projectile
	lda Enemy_Temp1+$02
	cmp #$2C
	beq Enemy42_Sub5_Spawn
	cmp #$28
	bne Enemy42_Sub5_Exit
Enemy42_Sub5_Spawn:
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;Offset projectile Y position
	txa
	tay
	ldx #$02
	lda #$F0
	jsr OffsetEnemyYPos
	;Set projectile velocity
	lda Enemy_Temp2+$02
	sta Enemy_XVel,y
	lda Enemy_Temp3+$02
	sta Enemy_XVelLo,y
	lda Enemy_Temp4+$02
	sta Enemy_YVel,y
	lda Enemy_Temp5+$02
	sta Enemy_YVelLo,y
	;Set enemy ID $43 (Level 5 boss fire)
	lda #ENEMY_LEVEL5BOSSFIRE
	sta Enemy_ID,y
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|$02)
	sta Enemy_Flags,y
	;Set enemy sprite based on animation timer
	lda Enemy_Temp1+$02
	cmp #$2C
	lda #$3F
	bcs Enemy42_Sub5_SetSp
	lda #$3E
Enemy42_Sub5_SetSp:
	sta Enemy_Sprite+$08,y
	;Next task ($02: Main middle)
	lda #$02
	sta Enemy_Mode,y
	rts
Enemy42_Sub5_Next:
	;Find closest player
	jsr FindClosestPlayerX
	;Target player with 24-angle precision
	lda #$08
	sta $05
	jsr TargetPlayer24
	;Set enemy props
	lda Enemy_XVel,x
	lsr
	and #$40
	sta Enemy_Props+$08,x
	;Next task ($06: Out)
	inc Enemy_Mode,x
Enemy42_Sub5_Exit:
	rts
;$06: Out
Enemy42_Sub6:
	;If enemy offscreen, go to next task ($01: In init)
	lda Enemy_XHi+$0A
	bne Enemy42_Sub6_Next
	lda Enemy_Y+$08,x
	cmp #$C0
	bcs Enemy42_Sub6_Next
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If enemy invincibility timer >= $10, exit early
	lda Enemy_InvinTimer,x
	cmp #$10
	bcs Enemy42_Sub5_Exit
	;Move enemy
	jmp MoveEnemyXY
Enemy42_Sub6_Next:
	;Clear enemy sprite
	lda #$00
	sta Enemy_Sprite+$0A
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|EF_ALLOWOFFSCREEN)
	sta Enemy_Flags+$02
	;Set animation timer
	lda #$70
	sta Enemy_Temp1+$02
	;Next task ($01: In init)
	lda #$01
	sta Enemy_Mode+$02
	rts
;$07: Death init
Enemy42_Sub7:
	;Clear fake bosses
	ldx #$07
Enemy42_Sub7_Loop:
	;Check if fake boss is active
	lda Enemy_ID,x
	beq Enemy42_Sub7_Next
	;Clear enemy
	jsr ClearEnemy
Enemy42_Sub7_Next:
	;Loop for each fake boss
	dex
	cpx #$02
	bne Enemy42_Sub7_Loop
	;Load CHR bank
	lda #$37
	sta TempCHRBanks+2
	;Clear enemy animation offset/timer
	lda #$FF
	sta Enemy_AnimOffs,x
	sta Enemy_AnimTimer,x
	;Clear enemy Y velocity
	lda #$00
	sta Enemy_YVel+$02
	sta Enemy_YVelLo+$02
	;Next task ($08: Death fall)
	lda #$08
	sta Enemy_Mode+$02
;$08: Death fall
Enemy42_Sub8:
	;If enemy Y velocity >= $04, don't accelerate
	lda Enemy_YVel+$02
	cmp #$04
	bcs Enemy42_Sub8_NoYC
	;Accelerate due to gravity
	clc
	lda Enemy_YVelLo+$02
	adc #$28
	sta Enemy_YVelLo+$02
	bcc Enemy42_Sub8_NoYC
	inc Enemy_YVel+$02
Enemy42_Sub8_NoYC:
	;Move enemy Y
	jsr MoveEnemyY
	;If enemy Y position >= $A0, go to next task ($09: Death wait)
	lda Enemy_Y+$0A
	cmp #$A0
	bcs Enemy42_Sub8_Next
	;Update enemy animation
	ldy #$3F
	jmp UpdateEnemyAnimation_AnyY
Enemy42_Sub8_Next:
	;Next task ($09: Death wait)
	inc Enemy_Mode+$02
	;Set animation timer
	lda #$40
	sta Enemy_Temp1+$02
	;Set enemy Y position
	lda #$A0
	sta Enemy_Y+$0A
	;Load CHR bank
	lda #$38
	sta TempCHRBanks+2
	;Set enemy sprite
	lda #$3C
	sta Enemy_Sprite+$0A
	;Clear sound
	jsr ClearSound
	;Set boss death sound flag
	dec BossDeathSoundFlag
	;Play sound
	lda #DMC_BOSSDEATH1
	jmp LoadSound
;$09: Death wait
Enemy42_Sub9:
	;If animation timer $20, set enemy sprite
	lda Enemy_Temp1+$02
	cmp #$20
	bne Enemy42_Sub9_NoSetSp
	inc Enemy_Sprite+$0A
Enemy42_Sub9_NoSetSp:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1+$02
	bne Enemy42_Sub9_Exit
	;Set animation timer
	lda #$40
	sta Enemy_Temp1+$02
	;Next task ($0A: Death flash)
	inc Enemy_Mode+$02
Enemy42_Sub9_Exit:
	rts
;$0A: Death flash
Enemy42_SubA:
	;Clear/set enemy sprite based on bit 0 of global timer
	lda GlobalTimer
	lsr
	lda #$00
	bcc Enemy42_SubA_SetSp
	lda #$3D
Enemy42_SubA_SetSp:
	sta Enemy_Sprite+$0A
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy42_Sub9_Exit
	;Check for boss rush level
	lda CurLevel
	cmp #$04
	bne Enemy42_SubA_BR
	;Kill enemy normally
	jmp Enemy01_Sub1_End
Enemy42_SubA_BR:
	;Check for boss rush
	jmp CheckBossRush_NoElevator

;$43: Level 5 boss fire
Enemy43JumpTable:
	.dw Enemy43_Sub0	;$00  Init
	.dw Enemy43_Sub1	;$01  Main end
	.dw Enemy43_Sub2	;$02  Main middle
;$00: Init
Enemy43_Sub0:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy43_Sub0_Exit
	;Clear enemy animation offset/timer
	lda #$FF
	sta Enemy_AnimOffs,x
	sta Enemy_AnimTimer,x
	;Next task ($01: Main end)
	inc Enemy_Mode,x
Enemy43_Sub0_Exit:
	rts
;$01: Main end
Enemy43_Sub1:
	;If enemy sprite not $40, update enemy animation
	lda Enemy_Sprite+$08,x
	cmp #$40
	beq Enemy43_Sub2
	;Update enemy animation
	jsr UpdateEnemyAnimation
;$02: Main middle
Enemy43_Sub2:
	;Set enemy props based on bit 3 of global timer
	lda GlobalTimer
	and #$08
	beq Enemy43_Sub2_SetP
	lda #$03
Enemy43_Sub2_SetP:
	sta Enemy_Props+$08,x
	;Move enemy
	jmp MoveEnemyXY

;$58: Level 6 boss
Enemy58JumpTable:
	.dw Enemy58_Sub0	;$00  Init
	.dw Enemy58_Sub1	;$01  Appear
	.dw Enemy58_Sub2	;$02  Up
	.dw Enemy58_Sub3	;$03  Fly
	.dw Enemy58_Sub4	;$04  Attack init
	.dw Enemy58_Sub5	;$05  Attack part 1
	.dw Enemy58_Sub6	;$06  Attack part 2
	.dw Enemy58_Sub7	;$07  Disappear
	.dw Enemy58_Sub8	;$08  Wait
	.dw Enemy58_Sub9	;$09  Death shock part 1
	.dw Enemy58_SubA	;$0A  Death shock part 2
	.dw Enemy58_SubB	;$0B  Death warp part 1
	.dw Enemy58_SubC	;$0C  Death warp part 2
	.dw Enemy58_SubD	;$0D  Death warp part 3
;$00: Init
Enemy58_Sub0:
	;Check if enemy HP < 0
	lda Enemy_HP+$02
	bpl Enemy58_Sub0_NoDeath
	;Clear lightning
	ldx #$11
Enemy58_Sub0_Loop:
	;Check if lightning is active
	lda Enemy_ID,x
	beq Enemy58_Sub0_Next
	;Clear enemy
	jsr ClearEnemy
Enemy58_Sub0_Next:
	;Loop for each lightning
	dex
	cpx #$02
	bne Enemy58_Sub0_Loop
	;Set palette background color
	lda #$0F
	jsr Level6BossSetBGColor
	;Restore X register
	dex
	;Next task ($09: Death shock part 1)
	lda #$09
	sta Enemy_Mode+$02
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags+$02
	;Load CHR bank
	lda #$3B
	sta TempCHRBanks+2
	;Set enemy sprite
	lda #$45
	sta Enemy_Sprite+$0A
	;Set timer
	lda #$40
	sta GameModeTimer
	;Clear sound
	jsr ClearSound
	;Set boss death sound flag
	dec BossDeathSoundFlag
	;Set pause disable flag
	dec PauseDisableFlag
	;Play sound
	lda #SE_LEVEL6BOSSDEATH
	jmp LoadSound
Enemy58_Sub0_NoDeath:
	;Set palette colors
	lda #$08
	sta PaletteBuffer+$1D
	lda #$17
	sta PaletteBuffer+$1E
	lda #$37
	sta PaletteBuffer+$1F
	;If scroll X position not 0, exit early
	lda TempMirror_PPUSCROLL_X
	bne Enemy58_Sub1_Exit
	;Load CHR bank
	lda #$1F
	sta TempCHRBanks+2
	;Set sprite boss mode flag
	dec SpriteBossModeFlag
	;Set timer
	lda #$40
	sta GameModeTimer
	;Next task ($01: Appear)
	inc Enemy_Mode+$02
	;Play music
	lda #MUSIC_BOSS2
	jmp LoadSound
;$01: Appear
Enemy58_Sub1:
	;Decrement timer, check if 0
	dec GameModeTimer
	beq Enemy58_Sub1_Next
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If bit 3 of animation timer 0, get enemy sprite
	lda Enemy_AnimTimer+$02
	cmp #$08
	bne Enemy58_Sub1_NoSp
	lda Enemy_Sprite+$0A
	sta Enemy_Temp5+$02
Enemy58_Sub1_NoSp:
	;Clear/set enemy sprite based on bit 0 of timer
	lda GameModeTimer
	and #$01
	beq Enemy58_Sub1_SetSp
	lda Enemy_Temp5+$02
Enemy58_Sub1_SetSp:
	sta Enemy_Sprite+$0A
	rts
Enemy58_Sub1_Next:
	;Check if already up
	lda Enemy_Temp4+$02
	beq Enemy58_Sub1_NoUp
	;Next task ($03: Fly)
	inc Enemy_Mode+$02
	;Set timer
	lda #$40
	sta GameModeTimer
	;Set enemy flags
	lda #$04
	sta Enemy_Flags+$02
Enemy58_Sub1_NoUp:
	;Next task ($02: Up)
	inc Enemy_Mode+$02
Enemy58_Sub1_Exit:
	rts
;$02: Up
Enemy58_Sub2:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Check if target Y position above or below
	ldy #$00
	sec
	lda #$58
	sbc Enemy_Y+$0A
	ror
	eor #$80
	bpl Enemy58_Sub2_Down
	dey
Enemy58_Sub2_Down:
	;Adjust enemy Y velocity to target Y position
	clc
	adc Enemy_YVelLo+$02
	sta Enemy_YVelLo+$02
	tya
	adc Enemy_YVel+$02
	sta Enemy_YVel+$02
	;If enemy Y position < $30, go to next task ($03: Fly)
	ldy Enemy_Y+$0A
	cpy #$30
	bcc Enemy58_Sub2_Next
	;Move enemy Y
	jmp MoveEnemyY
Enemy58_Sub2_Next:
	;Set enemy flags
	lda #$04
	sta Enemy_Flags+$02
	;Set timer
	lda #$40
	sta GameModeTimer
	;Set enemy Y velocity
	lda #$FF
	sta Enemy_YVel+$02
	lda #$80
	sta Enemy_YVelLo+$02
	;Next task ($03: Fly)
	inc Enemy_Mode+$02
	rts
;$03: Fly
Enemy58_Sub3:
	;Decrement timer, check if 0
	dec GameModeTimer
	beq Enemy58_Sub3_Next
	;Adjust enemy Y velocity to target Y position
	jsr Level6BossTargetYPos
	;Update enemy animation
	jmp UpdateEnemyAnimation
Enemy58_Sub3_Next:
	;Set timer
	lda #$20
	sta GameModeTimer
	;Set enemy sprite
	lda #$44
	sta Enemy_Sprite+$0A
	;Load CHR bank
	lda #$2D
	sta TempCHRBanks+2
	;Next task ($04: $04: Attack init)
	inc Enemy_Mode+$02
	rts
;$04: Attack init
Enemy58_Sub4:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne Enemy58_Sub1_Exit
	;Load CHR bank
	lda #$2D
	sta TempCHRBanks+2
	;Set enemy ID $59 (Level 6 boss fire)
	lda #ENEMY_LEVEL6BOSSFIRE
	sta Enemy_ID+$03
	;Set timer
	lda #$60
	sta GameModeTimer
	;Next task ($05: Attack part 1)
	inc Enemy_Mode+$02
	;Play sound
	lda #SE_LEVEL6BOSSFIRE
	jmp LoadSound
;$05: Attack part 1
Enemy58_Sub5:
	;Load CHR bank based on bit 1 of timer
	lda GameModeTimer
	and #$02
	lsr
	adc #$2D
	sta TempCHRBanks+2
	;Decrement timer
	dec GameModeTimer
	rts
;$06: Attack part 2
Enemy58_Sub6:
	;Adjust enemy Y velocity to target Y position
	jsr Level6BossTargetYPos
	;Load CHR bank based on bit 1 of timer
	lda GameModeTimer
	and #$02
	lsr
	adc #$2D
	sta TempCHRBanks+2
	;Decrement timer, check if 0
	dec GameModeTimer
	bne Enemy58_Sub6_Exit
	;Next task ($07: Disappear)
	inc Enemy_Mode+$02
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|$10)
	sta Enemy_Flags+$02
	;Set timer
	lda #$30
	sta GameModeTimer
	;Set enemy sprite
	lda #$41
	sta Enemy_Sprite+$0A
	;Load CHR bank
	lda #$1F
	sta TempCHRBanks+2
Enemy58_Sub6_Exit:
	rts
;$07: Disappear
Enemy58_Sub7:
	;Adjust enemy Y velocity to target Y position
	jsr Level6BossTargetYPos
	;Decrement timer, check if 0
	dec GameModeTimer
	beq Enemy58_Sub7_Next
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If bit 3 of animation timer 0, get enemy sprite
	lda Enemy_AnimTimer+$02
	cmp #$08
	bne Enemy58_Sub7_NoSp
	lda Enemy_Sprite+$0A
	sta Enemy_Temp5+$02
Enemy58_Sub7_NoSp:
	;Clear/set enemy sprite based on bit 0 of timer
	lda GameModeTimer
	and #$01
	beq Enemy58_Sub7_SetSp
	lda Enemy_Temp5+$02
Enemy58_Sub7_SetSp:
	sta Enemy_Sprite+$0A
	rts
Enemy58_Sub7_Next:
	;Set timer
	lda #$60
	sta GameModeTimer
	;Clear enemy sprite
	lda #$00
	sta Enemy_Sprite+$0A
	;Next task ($08: Wait)
	inc Enemy_Mode+$02
	rts
;$08: Wait
Enemy58_Sub8:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne Enemy58_Sub6_Exit
	;If bits 5-7 of random value 0, increment timer
	lda PRNGValue
	and #$E0
	bne Enemy58_Sub8_Next
	inc GameModeTimer
	rts
Enemy58_Sub8_Next:
	;Set enemy X position randomly
	sta Enemy_X+$0A
	;Next task ($01: Appear)
	lda #$01
	sta Enemy_Mode+$02
	;Set up flag
	sta Enemy_Temp4+$02
	;Set timer
	lda #$40
	sta GameModeTimer
	rts
;$09: Death shock part 1
Enemy58_Sub9:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne Enemy58_Sub9_NoNext
	;Next task ($0A: Death shock part 2)
	inc Enemy_Mode+$02
	;Set timer
	lda #$60
	sta GameModeTimer
	rts
Enemy58_Sub9_NoNext:
	;Update enemy animation
	ldy #$56
	jmp UpdateEnemyAnimation_AnyY
;$0A: Death shock part 2
Enemy58_SubA:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne Enemy58_SubA_NoNext
	;Set timer
	lda #$04
	sta GameModeTimer
	;Load CHR bank
	lda #$1F
	sta TempCHRBanks+2
	;Set enemy sprite
	lda #$4B
	sta Enemy_Sprite+$0A
	;Next task ($0B: Death warp part 1)
	inc Enemy_Mode+$02
	rts
Enemy58_SubA_NoNext:
	;Update enemy animation
	ldy #$57
	jmp UpdateEnemyAnimation_AnyY
;$0B: Death warp part 1
Enemy58_SubB:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne Enemy58_SubB_Exit
	;Set enemy sprite
	inc Enemy_Sprite+$0A
	;If enemy sprite $4D, go to next task ($0C: Death warp part 2)
	lda Enemy_Sprite+$0A
	cmp #$4D
	beq Enemy58_SubB_Next
	;Set timer
	lda #$04
	sta GameModeTimer
Enemy58_SubB_Exit:
	rts
Enemy58_SubB_Next:
	;Offset enemy Y position
	ldy #$03
	jsr OffsetEnemyYPos
	;Set enemy sprite
	lda #$4D
	sta Enemy_Sprite+$0B
	;Next task ($0C: Death warp part 2)
	inc Enemy_Mode+$02
	;Set timer
	lda #$0C
	sta GameModeTimer
	rts
;$0C: Death warp part 2
Enemy58_SubC:
	;Move enemies apart $02
	dec Enemy_Y+$0A
	inc Enemy_Y+$0B
	;If timer $08 or $04, set enemy sprite
	lda GameModeTimer
	cmp #$08
	beq Enemy58_SubC_SetSp
	cmp #$04
	bne Enemy58_SubC_NoSetSp
Enemy58_SubC_SetSp:
	;Set enemy sprite
	inc Enemy_Sprite+$0A
	inc Enemy_Sprite+$0B
Enemy58_SubC_NoSetSp:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne Enemy58_SubB_Exit
	;Clear other enemy
	inx
	jsr ClearEnemy
	;Restore X register
	dex
	;Clear enemy sprite
	sta Enemy_Sprite+$0A
	;Next task ($0D: Death warp part 3)
	inc Enemy_Mode+$02
	;Set timer
	lda #$60
	sta GameModeTimer
Enemy58_SubC_Exit:
	rts
;$0D: Death warp part 3
Enemy58_SubD:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne Enemy58_SubC_Exit
	;Kill enemy normally
	jmp Enemy01_Sub1_End
Level6BossTargetYPos:
	;Check if target Y position above or below
	ldy #$00
	sec
	lda #$30
	sbc Enemy_Y+$0A
	bcs Level6BossTargetYPos_Down
	dey
Level6BossTargetYPos_Down:
	;Adjust enemy Y velocity to target Y position
	asl
	asl
	asl
	adc Enemy_YVelLo+$02
	sta Enemy_YVelLo+$02
	tya
	adc Enemy_YVel+$02
	sta Enemy_YVel+$02
	;Move enemy Y
	jmp MoveEnemyY

;$59: Level 6 boss fire
Enemy59JumpTable:
	.dw Enemy59_Sub0	;$00  Init
	.dw Enemy59_Sub1	;$01  Main end
	.dw Enemy59_Sub2	;$02  Main middle
	.dw Enemy59_Sub3	;$03  Land init
	.dw Enemy59_Sub4	;$04  Land
;$00: Init
Enemy59_Sub0:
	;Offset enemy up $14
	lda Enemy_Y+$0A
	sec
	sbc #$14
	sta Enemy_Y+$0B
	;Offset enemy left $12
	lda Enemy_X+$0A
	sbc #$12
	sta Enemy_X+$0B
	;Find closest player
	jsr FindClosestPlayerX
	;Get target player position
	lda Enemy_X,y
	sta Enemy_XVel+$03
	lda PlayerXLo,y
	sta Enemy_XVelLo+$03
	lda Enemy_Y,y
	sta Enemy_YVel+$03
	lda PlayerYLo,y
	sta Enemy_YVelLo+$03
	;Set enemy sprite
	lda #$50
	sta Enemy_Sprite+$0B
	;Set animation timer
	lda #$02
	sta Enemy_Temp1+$03
	;Set enemy flags
	lda #(EF_NOHITATTACK|EF_ALLOWOFFSCREEN|$10)
	sta Enemy_Flags+$03
	;Next task ($01: Main end)
	inc Enemy_Mode+$03
	;Set palette background color
	lda #$30
Level6BossSetBGColor:
	;Set palette background color
	sta PaletteBuffer
	sta PaletteBuffer+$04
	sta PaletteBuffer+$08
	sta PaletteBuffer+$0C
	sta PaletteBuffer+$10
	sta PaletteBuffer+$14
	sta PaletteBuffer+$18
	sta PaletteBuffer+$1C
	;Clear VRAM buffer
	lda #$00
	sta VRAMBufferOffset
	;Write palette
	jsr WritePalette
	;Restore X register
	ldx #$03
Level6BossSetBGColor_Exit:
	rts
;$01: Main end
Enemy59_Sub1:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Level6BossSetBGColor_Exit
	;Check if Y position < top part Y position
	lda Enemy_YVel+$03
	sec
	sbc Enemy_Y+$08,x
	bcs Enemy59_Sub1_CheckDir
	jmp Enemy59_Sub1_NoDirChange
Enemy59_Sub1_CheckDir:
	;Check for direction change part
	lda Enemy_Temp2,x
	cmp #$03
	bcc Enemy59_Sub1_CheckAngle
	jmp Enemy59_Sub1_NoDirChange2
Enemy59_Sub1_CheckAngle:
	;Save player position
	lda Enemy_X
	sta $10
	lda Enemy_XHi
	sta $11
	lda Enemy_Y
	sta $12
	lda Enemy_YHi
	sta $13
	;Set target position
	lda Enemy_XVel+$03
	sta Enemy_X
	lda Enemy_XVelLo+$03
	sta PlayerXLo
	lda Enemy_YVel+$03
	sta Enemy_Y
	lda Enemy_YVelLo+$03
	sta PlayerYLo
	;Target player with 8-angle precision
	ldy #$00
	lda #$06
	jsr GetTargetAngle
	lsr
	tay
	;Restore player position
	lda $10
	sta Enemy_X
	lda $11
	sta Enemy_XHi
	lda $12
	sta Enemy_Y
	lda $13
	sta Enemy_YHi
	;Check to flip enemy X
	lda Enemy_Props+$08,x
	cmp #$40
	rol
	rol
	eor $07
	and #$02
	beq Enemy59_Sub1_NoFlip
	;Check for top part
	cpx #$03
	beq Enemy59_Sub1_Flip
	;Check for vertical part
	lda Enemy_Temp2,x
	cmp #$02
	beq Enemy59_Sub1_Flip
	;Set vertical direction value
	ldy #$02
	bne Enemy59_Sub1_NoFlip
Enemy59_Sub1_Flip:
	;Flip enemy X
	lda Enemy_Props+$08,x
	eor #$40
	sta Enemy_Props+$09,x
	;Set vertical direction value
	lda #$02
	ldy #$09
	bne Enemy59_Sub1_SetDir
Enemy59_Sub1_NoFlip:
	;Check for direction change
	tya
	cmp Enemy_Temp2,x
	beq Enemy59_Sub1_NoDirChange
	;Get direction change table index
	asl
	asl
	clc
	adc Enemy_Temp2,x
	tay
	;Set enemy props
	lda Enemy_Props+$08,x
	sta Enemy_Props+$09,x
	;Get direction change value
	lda Level6BossFireDirectionChangeTable,y
	tay
	sbc #$06
	sta Enemy_Temp2+$01,x
	bne Enemy59_Sub1_NoSetDir
Enemy59_Sub1_NoDirChange:
	;Get direction value
	lda Enemy_Temp2,x
Enemy59_Sub1_NoDirChange2:
	tay
	;Set enemy props
	lda Enemy_Props+$08,x
	sta Enemy_Props+$09,x
	;Get direction value
	lda Level6BossFireDirectionTable,y
Enemy59_Sub1_SetDir:
	;Set direction value
	sta Enemy_Temp2+$01,x
Enemy59_Sub1_NoSetDir:
	;Set enemy ID $59 (Level 6 boss fire)
	lda #ENEMY_LEVEL6BOSSFIRE
	sta Enemy_ID+$01,x
	;Set enemy flags
	lda #(EF_NOHITATTACK|EF_ALLOWOFFSCREEN|$10)
	sta Enemy_Flags+$01,x
	;Next task ($01: Main end)
	lda #$01
	;If bottom part, go to next task ($03: Land init)
	cpx #$10
	bcc Enemy59_Sub1_NoLand
	;Next task ($03: Land init)
	lda #$03
Enemy59_Sub1_NoLand:
	sta Enemy_Mode+$01,x
	;Set enemy sprite/Y position
	lda Level6BossFireSprite,y
	sta Enemy_Sprite+$09,x
	lda Level6BossFireYOffset,y
	clc
	adc Enemy_Y+$08,x
	sta Enemy_Y+$09,x
	;If Y position >= $A8, go to next task ($03: Land init)
	cmp #$A8
	bcc Enemy59_Sub1_NoLand2
	;Next task ($03: Land init)
	lda #$03
	sta Enemy_Mode+$01,x
Enemy59_Sub1_NoLand2:
	;Check for top part
	cpx #$03
	bne Enemy59_Sub1_NoTop
	;Set enemy X position
	lda #$00
	tay
	beq Enemy59_Sub1_NoXC
Enemy59_Sub1_NoTop:
	lda Enemy_Props+$09,x
	cmp #$40
	lda Level6BossFireXOffset,y
	bne Enemy59_Sub1_NoX0
	tay
	beq Enemy59_Sub1_NoXC
Enemy59_Sub1_NoX0:
	ldy #$00
	bcc Enemy59_Sub1_NoXC
	eor #$FF
	adc #$00
	dey
Enemy59_Sub1_NoXC:
	adc Enemy_X+$08,x
	sta Enemy_X+$09,x
	tya
	adc Enemy_XHi+$08,x
	sta Enemy_XHi+$09,x
	;Set animation timer
	lda #$01
	sta Enemy_Temp1,x
	sta Enemy_Temp1+$01,x
	;Next task ($02: Main middle)
	inc Enemy_Mode,x
	rts
Level6BossFireDirectionTable:
	.db $00,$01,$02,$01,$00,$02,$00,$02,$01,$02
Level6BossFireDirectionChangeTable:
	.db $00,$0D,$0B,$00
	.db $0F,$00,$0A,$00
	.db $0E,$0C,$00,$00
Level6BossFireYOffset:
	.db $0C,$0D,$10,$0D,$08,$10,$0C,$10,$0A,$10
	.db $10,$10,$0C,$0C,$0C,$0C
Level6BossFireXOffset:
	.db $10,$08,$04,$08,$0C,$00,$0C,$00,$08,$00
	.db $00,$00,$08,$08,$0C,$0C
Level6BossFireSprite:
	.db $53,$52,$51,$52,$53,$51,$53,$51,$52,$51
	.db $54,$55,$56,$57,$58,$59
;$02: Main middle
Enemy59_Sub2:
	;If animation timer 0, exit early
	lda Enemy_Temp1,x
	beq Enemy59_Sub2_Exit
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy59_Sub2_Exit
	;Check for top part
	cpx #$03
	bne Enemy59_Sub2_NoTop
	;Set palette background color
	lda #$0F
	jsr Level6BossSetBGColor
Enemy59_Sub2_NoTop:
	;If enemy sprite $54-$55, set enemy sprite
	lda Enemy_Sprite+$08,x
	cmp #$54
	beq Enemy59_Sub2_SetSp
	cmp #$55
	bne Enemy59_Sub2_Exit
Enemy59_Sub2_SetSp:
	adc #$05
	sta Enemy_Sprite+$08,x
Enemy59_Sub2_Exit:
	rts
;$03: Land init
Enemy59_Sub3:
	;Set animation timer
	lda #$10
	sta Enemy_Temp1,x
	;Next task ($04: Land)
	inc Enemy_Mode,x
	;Next task ($06: Attack part 2)
	inc Enemy_Mode+$02
	rts
;$04: Land
Enemy59_Sub4:
	;If animation timer 0, clear parts
	lda Enemy_Temp1,x
	beq Enemy59_Sub4_Next
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy59_Sub2_Exit
Enemy59_Sub4_Next:
	;Clear lightning
	ldx #$03
Enemy59_Sub4_Loop:
	;Check if lightning is active
	lda Enemy_ID,x
	bne Enemy59_Sub4_Clear
	;Loop for each lightning
	inx
	bne Enemy59_Sub4_Loop
Enemy59_Sub4_Clear:
	;Clear enemy
	jsr ClearEnemy
	;Restore X register
	ldx CurEnemyIndex
	rts

;$5A: Level 7 boss
Enemy5AJumpTable:
	.dw Enemy5A_Sub0	;$00  Init
	.dw Enemy5A_Sub1	;$01  Main
;$00: Init
Enemy5A_Sub0:
	;Check if enemy HP < 0
	lda Enemy_HP+$02
	bpl Enemy5A_Sub0_NoDeath
	;Clear enemies
	ldx #$0F
Enemy5A_Sub0_Loop:
	;Check if enemy is active
	lda Enemy_ID,x
	beq Enemy5A_Sub0_Next
	;Check for Windigo enemy
	cmp #ENEMY_WINDIGO
	;Set enemy sprite
	lda #$00
	sta Enemy_Sprite+$08,x
	;If not Windigo enemy, clear enemy
	bcc Enemy5A_Sub0_SetID
	;Next task ($00: Init)
	sta Enemy_Mode,x
	;Set enemy points value
	dec Enemy_Temp2,x
	;Set enemy ID $01 (Explosion)
	lda #ENEMY_EXPLOSION
Enemy5A_Sub0_SetID:
	sta Enemy_ID,x
Enemy5A_Sub0_Next:
	;Loop for each enemy
	dex
	cpx #$02
	bne Enemy5A_Sub0_Loop
	;Clear sound
	jsr ClearSound
	;Play sound
	lda #DMC_BOSSDEATH2
	jsr LoadSound
	;Kill enemy normally
	jmp Enemy01_Sub1_End
Enemy5A_Sub0_NoDeath:
	;Set enemy HP
	lda #$10
	sta Enemy_HP+$02
	;Next task ($01: Main)
	inc Enemy_Mode+$02
	rts
;$01: Main
Enemy5A_Sub1:
	;If enemy invincibility timer 0, exit early
	lda Enemy_InvinTimer+$02
	beq Enemy5A_Sub1_Exit
	;If bit 0 of enemy invincibility timer not 0, exit early
	and #$01
	bne Enemy5A_Sub1_Exit
	;Clear VRAM buffer
	sta VRAMBufferOffset
	;Set palette color based on bit 1 of enemy invincibility timer
	lda Enemy_InvinTimer+$02
	lsr
	lsr
	ldy #$20
	tya
	bcc Enemy5A_Sub1_SetColor
	ldy #$16
Enemy5A_Sub1_SetColor:
	lda #$27
	sty PaletteBuffer+$09
	sta PaletteBuffer+$0A
	;Write palette
	jsr WritePalette
	;Restore X register
	ldx #$02
Enemy5A_Sub1_Exit:
	rts

;$5C: Level 7 boss fire
Enemy5CJumpTable:
	.dw Enemy5C_Sub0	;$00  Init
	.dw Enemy5C_Sub1	;$01  Flash
	.dw Enemy5C_Sub2	;$02  Wait
	.dw Enemy5C_Sub3	;$03  Attack base
	.dw Enemy5C_Sub4	;$04  Land
	.dw Enemy5C_Sub5	;$05  Attack tail
;$04: Land
Enemy5C_Sub4:
	;Load CHR bank
	lda #$6C
	sta TempCHRBanks+2
	;Update enemy animation
	ldy #$53
	jsr UpdateEnemyAnimation_AnyY
	;If enemy sprite not 0, exit early
	lda Enemy_Sprite+$08,x
	bne Enemy5C_Sub5_Exit
	;Set enemy sprite
	lda #$61
	sta Enemy_Sprite+$08,x
	;Get Windigo enemy slot index
	txa
	clc
	adc #$02
	tay
	;Next task ($00: Init)
	lda #$00
	sta Enemy_Mode,y
	;Offset enemy Y position
	jsr OffsetEnemyYPos
	;Set enemy Y position
	lda #$A0
	sta Enemy_Y+$08,y
	;Set enemy ID $5D (Windigo)
	lda #ENEMY_WINDIGO
	sta Enemy_ID,y
Enemy5C_Sub4_Clear:
	;Clear enemy
	jmp ClearEnemy
;$05: Attack tail
Enemy5C_Sub5:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy5C_Sub5_Exit
	;Move enemy
	jsr MoveEnemyXY
	;Set animation timer
	lda #$02
	sta Enemy_Temp1,x
	;If enemy Y position >= $A8, clear enemy
	lda Enemy_Y+$08,x
	cmp #$A8
	bcs Enemy5C_Sub4_Clear
Enemy5C_Sub5_Exit:
	rts
;$00: Init
Enemy5C_Sub0:
	;If boss HP < 0, clear enemy
	lda Enemy_HP+$02
	bmi Enemy5C_Sub4_Clear
	;Next task ($01: Flash)
	inc Enemy_Mode,x
	;Set eye position
	inc Enemy_Temp5+$02
	;Set enemy flags/position
	lda #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags,x
	lda Level7BossFireXPosition-$03,x
	sta Enemy_X+$08,x
	lda #$4F
	sta Enemy_Y+$08,x
	;Load CHR bank
	lda #$6E
	sta TempCHRBanks+2
	;Clear attack animation offset
	lda #$00
	sta Enemy_Temp2,x
	;Play sound
	lda #SE_LEVEL7BOSSEYEFLASH
	jmp LoadSound
Level7BossFireXPosition:
	.db $76,$8A
;$01: Flash
Enemy5C_Sub1:
	;Update enemy animation
	ldy #$4F
	jsr UpdateEnemyAnimation_AnyY
	;If enemy sprite not 0, exit early
	lda Enemy_Sprite+$08,x
	bne Enemy5C_Sub1_Exit
	;Set enemy X position
	lda Enemy_Temp5+$02
	and #$01
	tay
	lda Level7BossFireXPosition,y
	sta Enemy_X+$08,x
	;Find closest player
	jsr FindClosestPlayerX
	;Target player with 24-angle precision
	lda #$08
	sta $05
	jsr TargetPlayer24
	;Set enemy X position
	lda Level7BossFireXPosition-$03,x
	sta Enemy_X+$08,x
	;Multiply enemy velocity by 4
	asl Enemy_YVelLo,x
	rol Enemy_YVel,x
	asl Enemy_XVelLo,x
	rol Enemy_XVel,x
	asl Enemy_YVelLo,x
	rol Enemy_YVel,x
	asl Enemy_XVelLo,x
	rol Enemy_XVel,x
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	;Next task ($02: Wait)
	inc Enemy_Mode,x
Enemy5C_Sub1_Exit:
	rts
;$02: Wait
Enemy5C_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy5C_Sub1_Exit
	;Set enemy flags
	lda #(EF_NOHITATTACK|$02)
	sta Enemy_Flags,x
	;Set animation timer
	lda #$02
	sta Enemy_Temp1,x
	;Next task ($03: Attack base)
	inc Enemy_Mode,x
	;Set enemy sprite
	lda #$66
	sta Enemy_Sprite+$08,x
Enemy5C_Sub2_Exit:
	rts
;$03: Attack base
Enemy5C_Sub3:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy5C_Sub2_Exit
	;Check for end of animation
	lda Enemy_Temp2,x
	cmp #$03
	bcs Enemy5C_Sub3_NoAnim
	;Get tail part enemy slot index
	cpx #$04
	rol
	tay
	;Set enemy ID $5C (Level 7 boss fire)
	lda #ENEMY_LEVEL7BOSSFIRE
	sta Enemy_ID+$0A,y
	;Set enemy sprite/position/velocity
	lda Enemy_Temp2,x
	adc #$67
	sta Enemy_Sprite+$12,y
	lda Level7BossFireXPosition-$03,x
	sta Enemy_X+$12,y
	lda #$4F
	sta Enemy_Y+$12,y
	lda Enemy_XVel,x
	sta Enemy_XVel+$0A,y
	lda Enemy_XVelLo,x
	sta Enemy_XVelLo+$0A,y
	lda Enemy_YVel,x
	sta Enemy_YVel+$0A,y
	lda Enemy_YVelLo,x
	sta Enemy_YVelLo+$0A,y
	;Next task ($05: Attack tail)
	lda #$05
	sta Enemy_Mode+$0A,y
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags+$0A,y
	;Set animation timer
	lda #$02
	sta Enemy_Temp1+$0A,y
	;Increment attack animation offset
	inc Enemy_Temp2,x
Enemy5C_Sub3_NoAnim:
	;Set animation timer
	lda #$02
	sta Enemy_Temp1,x
	;Move enemy
	jsr MoveEnemyXY
	;If enemy Y position < $A8, exit early
	lda Enemy_Y+$08,x
	cmp #$A8
	bcc Enemy5C_Sub3_Exit
	;Clear enemy X velocity
	lda #$00
	sta Enemy_XVel,x
	sta Enemy_XVelLo,x
	;Set enemy Y position
	lda #$A8
	sta Enemy_Y+$08,x
	;If tail parts still active, exit early
	lda Enemy_ID+$07,x
	ora Enemy_ID+$09,x
	ora Enemy_ID+$0B,x
	bne Enemy5C_Sub3_Exit
	;Set enemy X position
	lda Level7BossFireXOffset-$03,x
	clc
	adc Enemy_X+$08,x
	sta Enemy_X+$08,x
	;Clear enemy animation timer/offset
	lda #$FF
	sta Enemy_AnimTimer,x
	sta Enemy_AnimOffs,x
	;Next task ($04: Land)
	inc Enemy_Mode,x
Enemy5C_Sub3_Exit:
	rts
Level7BossFireXOffset:
	.db $F8,$08

;$5D: Windigo
Enemy5DJumpTable:
	.dw Enemy5D_Sub0	;$00  Init
	.dw Enemy5D_Sub1	;$01  Main
;$00: Init
Enemy5D_Sub0:
	;Set enemy flags/HP
	lda #$07
	sta Enemy_Flags,x
	lda #$02
	sta Enemy_HP,x
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy X velocity to target player
	lda #$04
	jmp SetEnemyXVel_AnyY
;$01: Main
Enemy5D_Sub1:
	;Update enemy animation
	ldy #$55
	jsr UpdateEnemyAnimation_AnyY
	;Check for turn around flag
	lda Enemy_Temp1,x
	beq Enemy5D_Sub1_NoBound
	;Move enemy X accounting for level bounds
	jmp Enemy16_Sub1_EntWindigo
Enemy5D_Sub1_NoBound:
	;Move enemy X
	jmp MoveEnemyX

;$18: Roc
Enemy18JumpTable:
	.dw Enemy18_Sub0	;$00  Init
	.dw Enemy18_Sub1	;$01  Fly
	.dw Enemy18_Sub2	;$02  Drop
;$00: Init
Enemy18_Sub0:
	;Get enemy spawn side
	lda Enemy_Temp2,x
	sta Enemy_Temp5,x
	;Check to spawn enemy on left side of screen
	beq Enemy18_Sub0_Init
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	bmi Enemy18_Sub0_Init
	rts
Enemy18_Sub0_Init:
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, clear enemy
	bcs Enemy18_Sub0_Spawn
	;Clear enemy
	jmp ClearEnemy
Enemy18_Sub0_Spawn:
	;Restore X register
	txa
	ldx CurEnemyIndex
	;Set egg enemy slot index
	sta Enemy_Temp3,x
	;Set enemy ID $0E (Roc fire)
	tay
	lda #ENEMY_ROCFIRE
	sta Enemy_ID,y
	;Set enemy flags/sprite
	lda #$07
	sta Enemy_Flags,y
	lda #$2E
	sta Enemy_Sprite+$08,y
	;Offset enemy position
	lda Enemy_Props+$08,x
	cmp #$40
	lda #$01
	bcs Enemy18_Sub0_Right
	lda #$FE
Enemy18_Sub0_Right:
	adc Enemy_X+$08,x
	sta Enemy_X+$08,y
	lda #$1C
	clc
	adc Enemy_Y+$08,x
	sta Enemy_Y+$08,y
	lda Enemy_XHi+$08,x
	sta Enemy_XHi+$08,y
	lda Enemy_YHi+$08,x
	sta Enemy_YHi+$08,y
	;Set parent enemy slot index
	txa
	sta Enemy_Temp2,y
	;Set enemy X velocity to target player
	lda #$06
	jmp SetEnemyXVel
RocWaveOffsetVelocity:
	.db $03,$FD
;$01: Fly
Enemy18_Sub1:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp5,x
	beq Enemy18_Sub1_NoFlip
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	cmp #$01
	bne Enemy18_Sub1_NoClear
	;Clear enemy
	jmp ClearEnemy
Enemy18_Sub1_NoClear:
	;If scroll Y position not 0, don't flip enemy X
	lda CurScreenY
	ora  TempMirror_PPUSCROLL_Y
	bne Enemy18_Sub1_NoFlip
	;If enemy X screen < $04, don't flip enemy X
	lda Enemy_X+$08,x
	adc TempMirror_PPUSCROLL_X
	lda Enemy_XHi+$08,x
	adc CurScreenX
	cmp #$04
	bcc Enemy18_Sub1_NoFlip
	;Flip enemy X
	jsr FlipEnemyX
Enemy18_Sub1_NoFlip:
	;Apply wave offset velocity based on enemy facing direction
	ldy #$00
	lda Enemy_Props+$08,x
	sta $05
	asl
	bpl Enemy18_Sub1_Right
	iny
Enemy18_Sub1_Right:
	lda Enemy_Temp4,x
	adc RocWaveOffsetVelocity,y
	sta Enemy_Temp4,x
	sta $04
	;Check for Q2/Q4
	bit $04
	bvc Enemy18_Sub1_NoQ1
	;Flip wave offset for Q2/Q4
	eor #$3F
Enemy18_Sub1_NoQ1:
	;Get enemy velocity based on wave offset
	and #$3F
	tay
	lda SineTable,y
	;Multiply velocity by 3/4
	ldy #$01
	jsr MultiplyTargetVelocity
	;Check for Q3/Q4
	lda $04
	asl
	lda #$C0
	bcs Enemy18_Sub1_NoQ2
	;Get enemy velocity (Q1/Q2)
	adc $00
	tay
	rol
	and #$01
	bpl Enemy18_Sub1_CheckFlipVel
Enemy18_Sub1_NoQ2:
	;Get enemy velocity (Q3/Q4)
	sbc $00
	tay
	lda #$00
Enemy18_Sub1_CheckFlipVel:
	;Check to flip enemy X velocity
	bit $05
	bvc Enemy18_Sub1_NoFlipVel
	;Flip enemy X velocity
	sta $00
	sty $01
	sec
	lda #$00
	sbc $01
	tay
	lda #$00
	sbc $00
Enemy18_Sub1_NoFlipVel:
	;Set enemy X velocity
	sta Enemy_XVel,x
	tya
	sta Enemy_XVelLo,x
	;Move enemy X
	jsr MoveEnemyX
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Check for end of enemy animation
	lda Enemy_AnimTimer,x
	bne Enemy18_Sub1_NoSound
	lda Enemy_AnimOffs,x
	bne Enemy18_Sub1_NoSound
	;Play sound
	lda #SE_ROCFLY
	jsr LoadSound
Enemy18_Sub1_NoSound:
	;If no egg enemy, exit early
	lda Enemy_Temp3,x
	beq Enemy18_Sub2_Exit
	;If egg enemy active, drop egg
	tay
	lda Enemy_ID,y
	cmp #ENEMY_ROCFIRE
	beq Enemy18_Sub1_Drop
	;Clear egg enemy slot index
	lda #$00
	sta Enemy_Temp3,x
	rts
Enemy18_Sub1_Drop:
	;Check if player is in range
	ldy #$01
Enemy18_Sub1_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc Enemy18_Sub1_PlayerNext
	;Check if player is in range
	lda Enemy_X,y
	clc
	adc #$2B
	sbc Enemy_X+$08,x
	cmp #$05
	bcs Enemy18_Sub1_PlayerNext
	;Next task ($01: Fall)
	ldy Enemy_Temp3,x
	lda #$01
	sta Enemy_Mode,y
	;Clear egg enemy slot index
	lda #$00
	sta Enemy_Temp3,x
	;Play sound
	lda #SE_ROCDROP
	jmp LoadSound
Enemy18_Sub1_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy18_Sub1_PlayerLoop
	;Offset projectile Y position
	ldy Enemy_Temp3,x
	lda #$1C
	jmp OffsetEnemyYPos
;$02: Drop
Enemy18_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy18_Sub2_Exit
	;Next task ($01: Fly)
	dec Enemy_Mode,x
Enemy18_Sub2_Exit:
	rts

;$0E: Roc fire
Enemy0EJumpTable:
	.dw Enemy0E_Sub0	;$00  Init
	.dw Enemy0E_Sub1	;$01  Fall
	.dw Enemy0E_Sub2	;$02  Land
;$00: Init
Enemy0E_Sub0:
	;If parent enemy not active, go to next task ($01: Main)
	ldy Enemy_Temp2,x
	lda Enemy_ID,y
	cmp #ENEMY_ROC
	beq Enemy0E_Sub0_Exit
	;Next task ($01: Fall)
	inc Enemy_Mode,x
Enemy0E_Sub0_Exit:
	rts
;$01: Fall
Enemy0E_Sub1:
	;If bit 0 of global timer = bit 0 of enemy slot index, skip this part
	txa
	eor GlobalTimer
	and #$01
	beq Enemy0E_Sub1_NoNext
	;Find closest player
	jsr FindClosestPlayerX
	;If enemy Y position < player Y position, skip this part
	lda Enemy_Y+$08,x
	cmp Enemy_Y,y
	bcc Enemy0E_Sub1_NoNext
	;Check for ground collision
	jsr EnemyGetGroundCollision
	bcc Enemy0E_Sub1_NoNext
	;Set enemy sprite/velocity
	lda #$2F
	sta Enemy_Sprite+$08,x
	lda #$FE
	sta Enemy_YVel,x
	lda #$FF
	sta Enemy_XVel,x
	lda #$00
	sta Enemy_XVelLo,x
	sta Enemy_YVelLo,x
	;Next task ($02: Land)
	inc Enemy_Mode,x
Enemy0E_Sub1_NoNext:
	;Accelerate due to gravity
	clc
	lda Enemy_YVelLo,x
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy0E_Sub1_NoYC
	inc Enemy_YVel,x
Enemy0E_Sub1_NoYC:
	;Move enemy Y
	jmp MoveEnemyY
;$02: Land
Enemy0E_Sub2:
	;Accelerate due to gravity
	clc
	lda Enemy_YVelLo,x
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy0E_Sub2_NoYC
	inc Enemy_YVel,x
Enemy0E_Sub2_NoYC:
	;Move enemy
	jmp MoveEnemyXY

;$0F: Ghost
Enemy0FJumpTable:
	.dw Enemy0F_Sub0	;$00  Init
	.dw Enemy0F_Sub1	;$01  Main
;$00: Init
Enemy0F_Sub0:
	;If not scrolling right, clear enemy
	lda LevelScrollFlags
	lsr
	bcs Enemy0F_Sub0_NoClear
	jmp ClearEnemy
Enemy0F_Sub0_NoClear:
	;Find closest player
	lda #$00
	sta $05
	jsr FindClosestPlayerX
	;Target player with 24-angle precision
	jsr TargetPlayer24
	;Convert angle/quadrant bits to full range angle
	lsr $06
	jsr GhostGetFullAngle
	;Set target angle
	lda $06
	sta Enemy_Temp2,x
	;Load CHR bank
	lda #$25
	sta TempCHRBanks+2
	;Set animation timer
	lda #$08
	sta Enemy_Temp1,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
Enemy0F_Sub0_SetP:
	;Set enemy props
	lda Enemy_XVel,x
	asl
	ror
	lsr
	and #$40
	sta Enemy_Props+$08,x
Enemy0F_Sub0_Exit:
	rts
;$01: Main
Enemy0F_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Check for level 2 kitchen counter area
	lda CurArea
	bne Enemy0F_Sub1_Area2
	;If enemy Y screen not 0, move enemy
	lda Enemy_Y+$08,x
	adc TempMirror_PPUSCROLL_Y
	tay
	lda Enemy_YHi+$08,x
	adc CurScreenY
	bne Enemy0F_Sub1_MoveXY
Enemy0F_Sub1_MoveX:
	;Move enemy X
	jsr MoveEnemyX
	jmp Enemy0F_Sub1_CheckT
Enemy0F_Sub1_Area2:
	;If enemy Y velocity up, move enemy
	lda Enemy_YVel,x
	bmi Enemy0F_Sub1_MoveXY
	;If enemy Y position + scroll Y position >= $0100, move enemy X
	lda Enemy_Y+$08,x
	adc TempMirror_PPUSCROLL_Y
	bcs Enemy0F_Sub1_MoveX
	;If enemy Y position in screen >= $80, move enemy X
	bmi Enemy0F_Sub1_MoveX
Enemy0F_Sub1_MoveXY:
	;Move enemy
	jsr MoveEnemyXY
Enemy0F_Sub1_CheckT:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy0F_Sub0_Exit
	;Set animation timer
	lda #$08
	sta Enemy_Temp1,x
	;Find closest player
	lda #$00
	sta $05
	jsr FindClosestPlayerX
	;Target player with 24-angle precision
	lda #$01
	jsr GetTargetAngle
	;Convert angle/quadrant bits to full range angle
	lsr
	sta $06
	jsr GhostGetFullAngle
	;Invert previous target angle
	lda Enemy_Temp2,x
	tay
	clc
	adc #$0C
	cmp #$18
	bcc Enemy0F_Sub1_NoAngleC
	sbc #$18
Enemy0F_Sub1_NoAngleC:
	sta $01
	;If previous angle = new angle, exit early
	tya
	cmp $06
	beq Enemy0F_Sub0_Exit
	;Check if previous angle >= new angle
	bcs Enemy0F_Sub1_CheckDec
	;Check for previous angle Q3/A4
	cmp #$0C
	bcs Enemy0F_Sub1_IncAngle
Enemy0F_Sub1_CheckInc:
	;Check if previous angle inverse >= new angle
	lda $01
	cmp $06
	tya
	bcc Enemy0F_Sub1_DecAngle
Enemy0F_Sub1_IncAngle:
	;Increment target angle
	adc #$00
	cmp #$18
	bcc Enemy0F_Sub1_SetAngle
	lda #$00
	bcs Enemy0F_Sub1_SetAngle
Enemy0F_Sub1_CheckDec:
	;Check for previous angle Q3/A4
	cmp #$0C
	bcs Enemy0F_Sub1_CheckInc
Enemy0F_Sub1_DecAngle:
	;Decrement target angle
	sbc #$00
	bpl Enemy0F_Sub1_SetAngle
	lda #$17
Enemy0F_Sub1_SetAngle:
	;Set target angle
	sta Enemy_Temp2,x
	;Reconstruct angle/quadrant bits from full range angle
	ldy #$00
	sty $05
	;Check for Q1
	cmp #$07
	bcc Enemy0F_Sub1_SetQ
	;Check for Q4
	iny
	cmp #$12
	bcs Enemy0F_Sub1_Q4
	;Check for Q2
	iny
	cmp #$0C
	bcc Enemy0F_Sub1_Q2
	;Handle Q3
	iny
	sbc #$0C
	bpl Enemy0F_Sub1_SetQ
Enemy0F_Sub1_Q4:
	;Handle Q4
	lda #$18
	sbc Enemy_Temp2,x
	bpl Enemy0F_Sub1_SetQ
Enemy0F_Sub1_Q2:
	;Handle Q2
	lda #$0D
	sbc Enemy_Temp2,x
Enemy0F_Sub1_SetQ:
	;Set quadrant bits
	sty $07
	;Set angle data bits
	asl
	;Target player with 24-angle precision
	jsr TargetPlayer
	;Set enemy props
	jmp Enemy0F_Sub0_SetP
GhostGetFullAngle:
	;Check for Q1
	lda $07
	beq GhostGetFullAngle_Exit
	;Check for Q4
	cmp #$02
	beq GhostGetFullAngle_Q4
	;Check for Q2
	bcc GhostGetFullAngle_Q2
	;Handle Q3
	lda $06
	adc #$0B
	bne GhostGetFullAngle_Set
GhostGetFullAngle_Q4:
	;Handle Q4
	lda #$0C
	sbc $06
	bne GhostGetFullAngle_Set
GhostGetFullAngle_Q2:
	;Handle Q2
	lda #$19
	sbc $06
	cmp #$18
	bcc GhostGetFullAngle_Set
	lda #$00
GhostGetFullAngle_Set:
	;Set full range angle
	sta $06
GhostGetFullAngle_Exit:
	rts

;$10: Ghoul
Enemy10JumpTable:
	.dw Enemy10_Sub0	;$00  Init
	.dw Enemy10_Sub1	;$01  Main
	.dw Enemy10_Sub2	;$02  Attack
;$00: Init
Enemy10_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	beq Enemy10_Sub0_Init
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	bpl Enemy10_Sub2_Exit
Enemy10_Sub0_Init:
	;Clear attack timer
	lda #$00
	sta Enemy_Temp2,x
	;Set enemy X velocity to target player
	jmp SetEnemyXVel
;$01: Main
Enemy10_Sub1:
	;Check if enemy X velocity left
	lda Enemy_XVel,x
	bmi Enemy10_Sub1_NoFlip
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	cmp #$01
	bne Enemy10_Sub1_NoClear
	;Clear enemy
	jmp ClearEnemy
Enemy10_Sub1_NoClear:
	;If enemy X screen not $04, don't flip enemy X
	lda Enemy_X+$08,x
	adc TempMirror_PPUSCROLL_X
	lda Enemy_XHi+$08,x
	adc CurScreenX
	cmp #$04
	bne Enemy10_Sub1_NoFlip
	;Flip enemy X
	jsr FlipEnemyX
Enemy10_Sub1_NoFlip:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Check if attack timer 0
	lda Enemy_Temp2,x
	beq Enemy10_Sub1_CheckNext
	;Decrement attack timer, check if 0
	dec Enemy_Temp2,x
	bne Enemy10_Sub1_NoNext
Enemy10_Sub1_CheckNext:
	;Check if player is in range
	lda #$5F
	jsr CheckPlayerInRangeXVel
	bcc Enemy10_Sub1_Next
Enemy10_Sub1_NoNext:
	;Move enemy X
	jmp MoveEnemyX
Enemy10_Sub1_Next:
	;Set animation timer
	lda #$10
	sta Enemy_Temp1,x
	;Set enemy sprite
	lda #$30
	sta Enemy_Sprite+$08,x
	;Next task ($02: Attack)
	inc Enemy_Mode,x
	rts
;$02: Attack
Enemy10_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy10_Sub2_Next
	;If animation timer $08, spawn projectile
	lda Enemy_Temp1,x
	cmp #$08
	bne Enemy10_Sub2_Exit
	jmp Enemy10_Sub2_CheckSpawn
Enemy10_Sub2_Next:
	;Set attack timer
	lda #$08
	sta Enemy_Temp2,x
	;Next task ($01: Main)
	dec Enemy_Mode,x
Enemy10_Sub2_Exit:
	rts
Enemy10_Sub2_CheckSpawn:
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcs Enemy10_Sub2_Spawn
	;Increment animation timer
	inc Enemy_Temp1,x
	rts
Enemy10_Sub2_Spawn:
	;Offset projectile Y position
	txa
	tay
	ldx CurEnemyIndex
	lda #$F8
	jsr OffsetEnemyYPos
	;Set enemy ID $11 (Ghoul fire)
	lda #ENEMY_GHOULFIRE
	sta Enemy_ID,y
	;Set parent enemy slot index
	txa
	sta Enemy_Temp2,y
	;Set enemy sprite
	lda #$32
	sta Enemy_Sprite+$08,x
	rts

;$11: Ghoul fire
Enemy11JumpTable:
	.dw Enemy11_Sub0	;$00  Init
	.dw Enemy11_Sub1	;$01  Main
;$00: Init
Enemy11_Sub0:
	;Set enemy velocity
	ldy Enemy_Temp2,x
	lda #$FB
	sta Enemy_YVel,x
	lda #$C0
	sta Enemy_YVelLo,x
	lda Enemy_XVel,y
	asl
	lda #$01
	bcc Enemy11_Sub0_RightVel
	lda #$FE
Enemy11_Sub0_RightVel:
	sta Enemy_XVel,x
	lda #$80
	sta Enemy_XVelLo,x
	;Offset enemy X position
	lda #$08
	bcc Enemy11_Sub0_RightPos
	lda #$F7
Enemy11_Sub0_RightPos:
	adc Enemy_X+$08,x
	sta Enemy_X+$08,x
	;Set enemy flags
	lda #$02
	sta Enemy_Flags,y
	;Next task ($01: Main)
	inc Enemy_Mode,x
Enemy11_Sub0_Exit:
	rts
;$01: Main
Enemy11_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
Enemy11_Sub1_Accel:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy11_Sub1_NoYC
	inc Enemy_YVel,x
Enemy11_Sub1_NoYC:
	;Move enemy
	jmp MoveEnemyXY

;$12: Ogre
Enemy12JumpTable:
	.dw Enemy12_Sub0	;$00  Init
	.dw Enemy12_Sub1	;$01  Main
;$00: Init
Enemy12_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	beq Enemy12_Sub0_Init
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	bpl Enemy11_Sub0_Exit
Enemy12_Sub0_Init:
	;Check for level 2 kitchen counter area
	lda CurArea
	bne Enemy12_Sub0_Area2
	;If not scrolling right, clear enemy
	lda LevelScrollFlags
	lsr
	bcs Enemy12_Sub0_Area2
Enemy12_Sub0_Clear:
	;Clear enemy
	jmp ClearEnemy
Enemy12_Sub0_Area2:
	;Move enemy down $0C
	lda Enemy_Y+$08,x
	clc
	adc #$0C
	cmp #$F0
	bcc Enemy12_Sub0_NoYC
	inc Enemy_YHi+$08,x
	adc #$0F
Enemy12_Sub0_NoYC:
	sta Enemy_Y+$08,x
	;Set enemy X velocity to target player
	lda #$00
	jmp SetEnemyXVel
;$01: Main
Enemy12_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If bits 0-1 of global timer != bit 0-1 of enemy slot index, don't check for collision
	lda GlobalTimer
	and #$03
	sta $00
	txa
	and #$03
	cmp $00
	bne Enemy12_Sub1_Move
	;If no ground collision, flip enemy X
	ldy #$03
	jsr EnemyGetGroundCollision_AnyY
	bcc Enemy12_Sub1_Flip
	;If wall collision, flip enemy X
	jsr EnemyGetWallCollision
	bcs Enemy12_Sub1_Flip
Enemy12_Sub1_Move:
	;Move enemy X
	jmp MoveEnemyX
Enemy12_Sub1_Flip:
	;Flip enemy X
	jmp FlipEnemyX

;$13: Goblin
Enemy13JumpTable:
	.dw Enemy13_Sub0	;$00  Init
	.dw Enemy13_Sub1	;$01  Idle
	.dw Enemy13_Sub2	;$02  Jump
;$00: Init
Enemy13_Sub0:
	;If scrolling right, clear enemy
	lda LevelScrollFlags
	lsr
	bcs Enemy12_Sub0_Clear
	;Load CHR bank
	lda #$26
	sta TempCHRBanks+2
	;Set enemy sprite
	lda #$28
	sta Enemy_Sprite+$08,x
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Next task ($01: Idle)
	inc Enemy_Mode,x
Enemy13_Sub0_Exit:
	rts
;$01: Idle
Enemy13_Sub1:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy13_Sub0_Exit
	;Set enemy Y velocity
	lda #$FE
	sta Enemy_YVel,x
	lda #$00
	sta Enemy_YVelLo,x
	;Set animation timer
	lda #$08
	sta Enemy_Temp1,x
	;Next task ($02: Jump)
	inc Enemy_Mode,x
	rts
;$02: Jump
Enemy13_Sub2:
	;If enemy Y velocity up, skip this part
	lda Enemy_YVel,x
	bmi Enemy13_Sub2_NoNext
	;If ground collision, go to next task ($01: Idle)
	jsr EnemyGetGroundCollision
	bcc Enemy13_Sub2_NoNext
	;Set animation timer
	lda #$80
	sta Enemy_Temp1,x
	;Set enemy sprite
	lda #$28
	sta Enemy_Sprite+$08,x
	;Next task ($01: Idle)
	dec Enemy_Mode,x
	rts
Enemy13_Sub2_NoNext:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy13_Sub2_NoYC
	inc Enemy_YVel,x
Enemy13_Sub2_NoYC:
	;Move enemy Y
	jsr MoveEnemyY
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy13_Sub0_Exit
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy13_Sub2_Exit
	;Offset projectile Y position
	txa
	tay
	ldx CurEnemyIndex
	lda #$F8
	jsr OffsetEnemyYPos
	;Set enemy ID $14 (Goblin fire)
	lda #ENEMY_GOBLINFIRE
	sta Enemy_ID,y
	;Set enemy sprite
	lda #$29
	sta Enemy_Sprite+$08,x
Enemy13_Sub2_Exit:
	rts

;$14: Goblin fire
Enemy14JumpTable:
	.dw Enemy14_Sub0	;$00  Init
	.dw Enemy14_Sub1	;$01  Fall
	.dw Enemy14_Sub2	;$02  Land
;$00: Init
Enemy14_Sub0:
	;Set enemy flags/sprite
	lda #$02
	sta Enemy_Flags,x
	lda #$2A
	sta Enemy_Sprite+$08,x
	;Next task ($01: Fall)
	inc Enemy_Mode,x
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy velocity to target player
	jmp TargetPlayerGravity
;$01: Fall
Enemy14_Sub1:
	;Accelerate due to gravity
	jsr Enemy11_Sub1_Accel
	;If scrolling right, clear enemy
	lda LevelScrollFlags
	lsr
	bcs Enemy15_Sub0_Clear
	;If bit 0 of global timer != bit 0 of enemy slot index, skip this part
	lda GlobalTimer
	eor CurEnemyIndex
	lsr
	bcs Enemy13_Sub2_Exit
	;If no ground collision, exit early
	ldy #$04
	jsr EnemyGetGroundCollision_AnyY
	cmp #$16
	bcc Enemy13_Sub2_Exit
	;Set animation timer
	lda #$04
	sta Enemy_Temp1,x
	;Set enemy sprite/flags
	lda #$2B
	sta Enemy_Sprite+$08,x
	lda #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags,x
	;Next task ($02: Land)
	inc Enemy_Mode,x
	rts
;$02: Land
Enemy14_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy15_Sub0_Clear
	rts

;$15: Cerberus
Enemy15JumpTable:
	.dw Enemy15_Sub0	;$00  Init
	.dw Enemy15_Sub1	;$01  Run start
	.dw Enemy15_Sub2	;$02  Jump
	.dw Enemy15_Sub3	;$03  Run end
;$00: Init
Enemy15_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	beq Enemy15_Sub0_Init
	;If scrolling right, exit early
	lda LevelScrollFlags
	lsr
	bcs Enemy15_Sub0_Exit
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	cmp #$01
	beq Enemy15_Sub0_NoClear
Enemy15_Sub0_Exit:
	rts
Enemy15_Sub0_Init:
	;If scrolling right, clear enemy
	lda LevelScrollFlags
	lsr
	bcc Enemy15_Sub0_NoClear
Enemy15_Sub0_Clear:
	;Clear enemy
	jmp ClearEnemy
Enemy15_Sub0_NoClear:
	;Set enemy Y velocity
	lda #$FF
	sta Enemy_YVel,x
	;Set enemy X velocity to target player
	lda #$0A
	jmp SetEnemyXVel
;$01: Run start
Enemy15_Sub1:
	;If scrolling right, clear enemy
	lda LevelScrollFlags
	lsr
	bcc Enemy15_Sub1_NoClear
	jmp ClearEnemy
Enemy15_Sub1_NoClear:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy15_Sub1_NoYC
	inc Enemy_YVel,x
Enemy15_Sub1_NoYC:
	;If no ground collision, exit early
	jsr EnemyGetGroundCollision
	cmp #$16
	bcc Enemy15_Sub1_Exit
	;Init enemy jump
	jsr CerberusJumpSub
	;If player behind enemy, go to next task ($03: Run end)
	bpl Enemy15_Sub1_NoJump
	;If player X distance from enemy >= $70, exit early
	lda $00
	cmp #$70
	bcs Enemy15_Sub1_Exit
	;Next task ($02: Jump)
	inc Enemy_Mode,x
	;Set enemy velocity to target player
	jmp TargetPlayerGravity
Enemy15_Sub1_NoJump:
	;Next task ($03: Run end)
	lda #$03
	sta Enemy_Mode,x
Enemy15_Sub1_Exit:
	rts
;$02: Jump
Enemy15_Sub2:
	;If scrolling right, clear enemy
	lda LevelScrollFlags
	lsr
	bcc Enemy15_Sub2_NoClear
	jmp ClearEnemy
Enemy15_Sub2_NoClear:
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy15_Sub2_NoYC
	inc Enemy_YVel,x
Enemy15_Sub2_NoYC:
	;If no ground collision, exit early
	jsr EnemyGetGroundCollision
	cmp #$16
	bcc Enemy15_Sub1_Exit
	;Set enemy grounded
	ldy #$00
	jsr HandleEnemyGroundCollision_NoClearY
	;Set enemy velocity
	tya
	sta Enemy_YVelLo,x
	lda #$FF
	sta Enemy_YVel,x
	lda #$00
	sta Enemy_XVelLo,x
	lda Enemy_Props+$08,x
	cmp #$40
	lda #$02
	bcc Enemy15_Sub2_Right
	lda #$FE
Enemy15_Sub2_Right:
	sta Enemy_XVel,x
	;Next task ($03: Run end)
	inc Enemy_Mode,x
	rts
;$03: Run end
Enemy15_Sub3:
	;If scrolling right, clear enemy
	lda LevelScrollFlags
	lsr
	bcc Enemy15_Sub3_NoClear
	jmp ClearEnemy
Enemy15_Sub3_NoClear:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy15_Sub3_NoYC
	inc Enemy_YVel,x
Enemy15_Sub3_NoYC:
	;If wall collision, flip enemy X
	jsr EnemyGetWallCollision
	bcc Enemy15_Sub3_NoFlip
	jsr FlipEnemyX
Enemy15_Sub3_NoFlip:
	;If no ground collision, exit early
	jsr EnemyGetGroundCollision
	cmp #$16
	bcc Enemy15_Sub1_Exit
	;Init enemy jump
	jsr CerberusJumpSub
	;If player in front of enemy, go to next task ($03: Run start)
	bmi Enemy15_Sub3_Next
	;If player X distance from enemy < $70, exit early
	lda $00
	cmp #$70
	bcc Enemy15_Sub3_Exit
	;Flip enemy X
	jsr FlipEnemyX
Enemy15_Sub3_Next:
	;Next task ($01: Run start)
	lda #$01
	sta Enemy_Mode,x
Enemy15_Sub3_Exit:
	rts
CerberusJumpSub:
	;Set enemy grounded
	ldy #$00
	jsr HandleEnemyGroundCollision_NoClearY
	;Set enemy Y velocity
	tya
	sta Enemy_YVelLo,x
	lda #$FF
	sta Enemy_YVel,x
	;Find closest player
	jsr FindClosestPlayerX
	;Get player X distance from enemy
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	sta $00
	lda Enemy_XHi+$08,x
	sbc #$00
	sta $01
	;Set max X distance $FF
	beq CerberusJumpSub_Left0
	bpl CerberusJumpSub_Left1
	cmp #$FF
	beq CerberusJumpSub_Right
CerberusJumpSub_Left1:
	lda #$01
	sta $00
CerberusJumpSub_Right:
	lda #$00
	sbc $00
	sta $00
CerberusJumpSub_Left0:
	;Check to flip enemy X
	lda $01
	eor Enemy_XVel,x
	rts

;$31: Manticore
Enemy31JumpTable:
	.dw Enemy31_Sub0	;$00  Init
	.dw Enemy31_Sub1	;$01  Run start
	.dw Enemy31_Sub2	;$02  Attack
	.dw Enemy31_Sub3	;$03  Run end
;$00: Init
Enemy31_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	bpl Enemy31_Sub0_Init
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	bmi Enemy31_Sub0_Init
	rts
Enemy31_Sub0_Init:
	;Set palette colors
	lda #$08
	sta PaletteBuffer+$1D
	lda #$18
	sta PaletteBuffer+$1E
	lda #$38
	sta PaletteBuffer+$1F
	;Set enemy Y velocity
	lda #$FE
	sta Enemy_YVel,x
	;Set enemy X velocity to target player
	lda #$0A
	jmp SetEnemyXVel
;$01: Run start
Enemy31_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy31_Sub1_NoYC
	inc Enemy_YVel,x
Enemy31_Sub1_NoYC:
	;Get collision type middle
	lda #$00
	sta $00
	tay
	jsr EnemyGetCollisionType
	sta $16
	;Check for behind BG area collision type
	lda Enemy_Props+$08,x
	and #$DF
	ldy $16
	beq Enemy31_Sub1_NoBehindBG
	;Set enemy priority to be behind background
	ora #$20
Enemy31_Sub1_NoBehindBG:
	;Set enemy props
	sta Enemy_Props+$08,x
	;If enemy Y velocity up, exit early
	lda Enemy_YVel,x
	bmi Enemy31_Sub1_Exit
	;If enemy Y position < $A0, exit early
	lda Enemy_Y+$08,x
	cmp #$A0
	bcc Enemy31_Sub1_Exit
	;Set enemy Y position/velocity
	lda #$A0
	sta Enemy_Y+$08,x
	lda #$00
	sta Enemy_YVelLo,x
	lda #$FE
	sta Enemy_YVel,x
	;Clear enemy animation offset/timer
	sta Enemy_AnimOffs,x
	sta Enemy_AnimTimer,x
	;If not behind BG, exit early
	tya
	beq Enemy31_Sub1_Exit
	;If enemy offscreen horizontally, exit early
	lda Enemy_XHi+$08,x
	bne Enemy31_Sub1_Exit
	;Next task ($02: Attack)
	inc Enemy_Mode,x
	;Set animation timer
	lda #$60
	sta Enemy_Temp1,x
Enemy31_Sub1_Exit:
	rts
;$02: Attack
Enemy31_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy31_Sub2_Next
	;If animation timer $40 or $10, spawn projectile
	lda Enemy_Temp1,x
	cmp #$40
	beq Enemy31_Sub2_CheckSpawn
	cmp #$10
	bne Enemy31_Sub1_Exit
Enemy31_Sub2_CheckSpawn:
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy31_Sub2_NoSpawn
	;Set enemy ID $46 (Manticore fire)
	txa
	tay
	ldx CurEnemyIndex
	lda #ENEMY_MANTICOREFIRE
	sta Enemy_ID,y
	;Offset projectile Y position
	lda #$00
	jmp OffsetEnemyYPos
Enemy31_Sub2_NoSpawn:
	;Increment animation timer
	inc Enemy_Temp1,x
	rts
Enemy31_Sub2_Next:
	;Next task ($03: Run end)
	inc Enemy_Mode,x
	;Flip enemy X
	jmp FlipEnemyX
;$03: Run end
Enemy31_Sub3:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy31_Sub3_NoYC
	inc Enemy_YVel,x
Enemy31_Sub3_NoYC:
	;Get collision type middle
	lda Enemy_XHi+$08,x
	sta $09
	lda Enemy_YHi+$08,x
	sta $0B
	lda Enemy_X+$08,x
	sta $08
	lda Enemy_Y+$08,x
	sta $0A
	jsr GetCollisionType
	sta $16
	;Check for behind BG area collision type
	lda Enemy_Props+$08,x
	and #$DF
	ldy $16
	beq Enemy31_Sub3_NoBehindBG
	;Set enemy priority to be behind background
	ora #$20
Enemy31_Sub3_NoBehindBG:
	;Set enemy props
	sta Enemy_Props+$08,x
	;If enemy Y velocity up, exit early
	lda Enemy_YVel,x
	bmi Enemy31_Sub1_Exit
	;If enemy Y position < $A0, exit early
	lda Enemy_Y+$08,x
	cmp #$A0
	bcc Enemy31_Sub1_Exit
	;Set enemy Y position/velocity
	lda #$A0
	sta Enemy_Y+$08,x
	lda #$00
	sta Enemy_YVelLo,x
	lda #$FE
	sta Enemy_YVel,x
	;Clear enemy animation offset/timer
	sta Enemy_AnimOffs,x
	sta Enemy_AnimTimer,x
	;If enemy not offscreen horizontally, exit early
	lda Enemy_XHi+$08,x
	bne Enemy31_Sub3_Next
	rts
Enemy31_Sub3_Next:
	;Next task ($01: Run start)
	lda #$01
	sta Enemy_Mode,x
	;Flip enemy X
	jmp FlipEnemyX

;$46: Manticore fire
Enemy46JumpTable:
	.dw Enemy46_Sub0	;$00  Init
	.dw Enemy46_Sub1	;$01  Main
;$00: Init
Enemy46_Sub0:
	;Next task ($01: Main)
	inc Enemy_Mode,x
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy velocity to target player
	lda #$00
	jmp TargetPlayerGravity
;$01: Main
Enemy46_Sub1:
	;Check for behind BG area collision type
	jsr EnemyGetWallCollision
	cmp #$02
	lda Enemy_Props+$08,x
	and #$DF
	bcc Enemy46_Sub1_NoBehindBG
	;Set enemy priority to be behind background
	ora #$20
Enemy46_Sub1_NoBehindBG:
	;Set enemy props
	sta Enemy_Props+$08,x
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy46_Sub1_NoYC
	inc Enemy_YVel,x
Enemy46_Sub1_NoYC:
	;Move enemy
	jmp MoveEnemyXY

;$32: BG cyclops
Enemy32JumpTable:
	.dw Enemy32_Sub0	;$00  Init
	.dw Enemy32_Sub1	;$01  Fall
	.dw Enemy32_Sub2	;$02  Land
;$00: Init
Enemy32_Sub0_Exit:
	rts
Enemy32_Sub0:
	;Reset fade timer
	lda #$00
	sta FadeTimer
	;If not enough space in VRAM buffer, exit early
	lda VRAMBufferOffset
	cmp #$10
	bcs Enemy32_Sub0_Exit
	;Check to spawn enemy on left side of screen
	ldy Enemy_Temp2,x
	beq Enemy32_Sub0_Init
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	bne Enemy32_Sub0_Exit
	lda Enemy_X+$08,x
	bmi Enemy32_Sub0_Exit
Enemy32_Sub0_Init:
	;If enemy X position $11-$EF, exit early
	lda Enemy_X+$08,x
	adc #$10
	cmp #$21
	bcc Enemy32_Sub0_Exit
	;Check if player is in range
	lda #$65
	jsr CheckPlayerInRangeSpawnVel
	tya
	bmi Enemy32_Sub0_Exit
	;Get BG cyclops hole graphic VRAM address
	ldy Enemy_Temp2,x
	iny
	lda BGCyclopsVRAMXOffset,y
	adc Enemy_X+$08,x
	adc TempMirror_PPUSCROLL_X
	lsr
	lsr
	lsr
	sec
	sbc #$02
	sta $00
	lda BGCyclopsVRAMYOffset,y
	adc Enemy_Y+$08,x
	sec
	sbc #$10
	asl
	rol $01
	asl
	rol $01
	and #$E0
	ora $00
	sta $00
	lda $01
	and #$03
	ora #$28
	sta $01
	;Draw BG cyclops hole graphic
	ldy #$00
	ldx VRAMBufferOffset
Enemy32_Sub0_VRAMLoop:
	;Init VRAM buffer row
	lda #$01
	sta VRAMBuffer,x
	inx
	;Set VRAM buffer address
	lda $00
	sta VRAMBuffer,x
	inx
	lda $01
	sta VRAMBuffer,x
	inx
Enemy32_Sub0_VRAMLoop2:
	;Set tile in VRAM
	lda BGCyclopsVRAMData,y
	sta VRAMBuffer,x
	;Loop for each tile
	inx
	iny
	tya
	and #$03
	bne Enemy32_Sub0_VRAMLoop2
	;End VRAM buffer
	lda #$FF
	sta VRAMBuffer,x
	inx
	;Increment VRAM buffer address
	lda $00
	clc
	adc #$20
	sta $00
	bcc Enemy32_Sub0_NoVRAMC
	inc $01
Enemy32_Sub0_NoVRAMC:
	;Loop for each row of tiles
	cpy #$10
	bcc Enemy32_Sub0_VRAMLoop
	;Set VRAM buffer offset
	stx VRAMBufferOffset
	;Play sound
	lda #SE_BGCYCLOPS
	jsr LoadSound
	;Restore X register
	ldx CurEnemyIndex
	;Set enemy sprite/Y velocity
	lda #$6B
	sta Enemy_Sprite+$08,x
	lda #$FE
	sta Enemy_YVel,x
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy X velocity to target player
	lda #$04
	jmp SetEnemyXVel_AnyY
BGCyclopsVRAMXOffset:
	.db $08,$F8
BGCyclopsVRAMYOffset:
	.db $F7,$07
;$01: Fall
Enemy32_Sub1:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$20
	sta Enemy_YVelLo,x
	bcc Enemy32_Sub1_NoYC
	inc Enemy_YVel,x
Enemy32_Sub1_NoYC:
	;Move enemy
	jsr MoveEnemyXY
	;If enemy Y position < $A0, exit early
	lda Enemy_Y+$08,x
	cmp #$A0
	bcs Enemy32_Sub1_Next
	rts
Enemy32_Sub1_Next:
	;Set enemy Y position
	lda #$A0
	sta Enemy_Y+$08,x
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy X velocity to target player
	lda #$0A
	jmp SetEnemyXVel_AnyY
;$02: Land
Enemy32_Sub2:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy X
	jmp MoveEnemyX
BGCyclopsVRAMData:
	.db $8A,$8B,$8C,$8D
	.db $8E,$00,$00,$8F
	.db $90,$00,$00,$91
	.db $92,$93,$94,$95

;$35: Karnack
Enemy35JumpTable:
	.dw Enemy35_Sub0	;$00  Init
	.dw Enemy35_Sub1	;$01  Main
;$00: Init
Enemy35_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	bpl Enemy35_Sub0_Init
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	bpl Enemy35_Sub1_Exit
Enemy35_Sub0_Init:
	;Set enemy X velocity to target player
	lda #$02
	jmp SetEnemyXVel
;$01: Main
Enemy35_Sub1:
	;Check if enemy is grounded
	lda Enemy_Temp2,x
	beq Enemy35_Sub1_Grounded
	;Check for wall collision
	jsr EnemyGetWallCollision
	bcs Enemy35_Sub1_InAirNoMoveX
	;Move enemy X
	jsr MoveEnemyX
Enemy35_Sub1_InAirNoMoveX:
	;Move enemy Y
	jsr MoveEnemyY
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy35_Sub1_NoYC
	inc Enemy_YVel,x
Enemy35_Sub1_NoYC:
	;If enemy Y velocity up, exit early
	lda Enemy_YVel,x
	bmi Enemy35_Sub1_Exit
	;If no ground collision, exit early
	jsr EnemyGetGroundCollision
	bcc Enemy35_Sub1_Exit
	;Set enemy grounded
	lda #$00
	sta Enemy_Temp2,x
	tay
	jmp HandleEnemyGroundCollision
Enemy35_Sub1_Exit:
	rts
Enemy35_Sub1_Grounded:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If bits 0-1 of global timer = bit 0-1 of enemy slot index, don't move enemy X
	lda GlobalTimer
	and #$03
	sta $00
	txa
	and #$03
	cmp $00
	beq Enemy35_Sub1_GroundedNoMoveX
	;Move enemy X
	jmp MoveEnemyX
Enemy35_Sub1_GroundedNoMoveX:
	;If enemy X screen < $05, skip this part
	lda TempMirror_PPUSCROLL_X
	adc Enemy_X+$08,x
	lda CurScreenX
	adc Enemy_XHi+$08,x
	cmp #$05
	bcc Enemy35_Sub1_NoCheckFlip
	;Check to flip enemy X
	lda Enemy_XVel,x
	bmi Enemy35_Sub1_NoFlip
	bpl Enemy35_Sub1_Flip
Enemy35_Sub1_NoCheckFlip:
	;Find closest player
	jsr FindClosestPlayerX
	;If enemy not offscreen horizontally, skip this part
	lda Enemy_XHi+$08,x
	beq Enemy35_Sub1_NoCheckFlip2
	;Check to flip enemy X
	eor Enemy_XVel,x
	bpl Enemy35_Sub1_Flip
	bmi Enemy35_Sub1_NoFlip
Enemy35_Sub1_NoCheckFlip2:
	;If scroll X position >= $05, skip this part
	lda TempMirror_PPUSCROLL_X
	cmp #$05
	bcs Enemy35_Sub1_NoFlip
	;Check if player is to left or right
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	sta $00
	ror
	sta $01
	eor Enemy_XVel,x
	bpl Enemy35_Sub1_NoFlip
	;If player X distance from enemy < $40, don't flip enemy X
	asl $01
	lda $00
	bcs Enemy35_Sub1_PosX
	eor #$FF
	adc #$01
Enemy35_Sub1_PosX:
	cmp #$40
	bcc Enemy35_Sub1_NoFlip
Enemy35_Sub1_Flip:
	;Flip enemy X
	jsr FlipEnemyX
Enemy35_Sub1_NoFlip:
	;Check if enemy offscreen vertically
	lda Enemy_YHi+$08,x
	bmi Enemy35_Sub1_CheckFall
	bne Enemy35_Sub1_CheckEnemyY
	;If player Y position > enemy Y position, check to set enemy falling
	lda Enemy_Y+$08,x
	sbc Enemy_Y,y
	sta $00
	bcc Enemy35_Sub1_CheckFall
	;If player distance above enemy < $10, skip this part
	cmp #$10
	bcc Enemy35_Sub1_CheckJump
	;If player not grounded, skip this part
	lda PlayerCollTypeBottom,y
	beq Enemy35_Sub1_CheckJump
	;If player distance above enemy >= $58, check to set enemy jumping
	lda $00
	cmp #$58
	bcs Enemy35_Sub1_CheckEnemyY
	;Get collision type using player Y position
	lda Enemy_Y,y
	adc #$18
	bcs Enemy35_Sub1_NoYC2
	cmp #$F0
	bcc Enemy35_Sub1_SetY2
Enemy35_Sub1_NoYC2:
	adc #$10
	sec
Enemy35_Sub1_SetY2:
	sta $0A
	lda Enemy_YHi,y
	adc #$00
Enemy35_Sub1_SetYHi:
	sta $0B
	ldy #$00
	lda Enemy_XVel,x
	asl
	lda #$20
	bcc Enemy35_Sub1_SetX
	lda #$DF
	dey
Enemy35_Sub1_SetX:
	adc Enemy_X+$08,x
	sta $08
	tya
	adc Enemy_XHi+$08,x
	sta $09
	jsr GetCollisionType
	;If non-slope collision type, set enemy jumping state
	cmp #$13
	bcs Enemy35_Sub1_Jump
Enemy35_Sub1_CheckJump:
	;If wall collision, set enemy jumping state
	jsr EnemyGetWallCollision
	bcs Enemy35_Sub1_Jump
	;If no ground collision, set enemy jumping state
	jsr EnemyGetGroundCollision
	bcc Enemy35_Sub1_Jump
	;Move enemy X
	jmp MoveEnemyX
Enemy35_Sub1_Jump:
	;Set enemy Y velocity
	lda #$FB
	sta Enemy_YVel,x
	;Set in air flag
	inc Enemy_Temp2,x
	;Move enemy
	jmp MoveEnemyXY
Enemy35_Sub1_CheckFall:
	;If wall collision, exit early
	jsr EnemyGetWallCollision
	bcs Enemy35_Sub1_Exit2
	;If no ground collision, set enemy jumping state
	jsr EnemyGetGroundCollision
	bcs Enemy35_Sub1_NoFall
	;Set in air flag
	inc Enemy_Temp2,x
Enemy35_Sub1_NoFall:
	;Move enemy
	jmp MoveEnemyXY
Enemy35_Sub1_Exit2:
	rts
Enemy35_Sub1_CheckEnemyY:
	;Get collision type using enemy Y position
	lda Enemy_Y+$08,x
	sbc #$38
	bcs Enemy35_Sub1_NoYC3
	sbc #$0F
	clc
Enemy35_Sub1_NoYC3:
	sta $0A
	lda Enemy_YHi+$08,x
	sbc #$00
	jmp Enemy35_Sub1_SetYHi

;$37: Tengu
Enemy37JumpTable:
	.dw Enemy37_Sub0	;$00  Init
	.dw Enemy37_Sub1	;$01  Fly start
	.dw Enemy37_Sub2	;$02  Down
	.dw Enemy37_Sub3	;$03  Attack
	.dw Enemy37_Sub4	;$04  Up
	.dw Enemy37_Sub5	;$05  Fly end
;$00: Init
Enemy37_Sub0:
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Set enemy X velocity to target player
	lda #$0E
	jmp SetEnemyXVel
;$01: Fly start
Enemy37_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy X
	jsr MoveEnemyX
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy37_Sub1_Exit
	;If enemy offscreen horizontally, exit early
	lda Enemy_XHi+$08,x
	bne Enemy37_Sub1_IncT
	;Find which player is closest to enemy X
	lda #$FF
	sta $00
	ldy #$01
Enemy37_Sub1_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc Enemy37_Sub1_PlayerNext
	;Get player X distance from enemy
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	ror
	sta $02
	rol
	bcs Enemy37_Sub1_PosX
	eor #$FF
	adc #$01
Enemy37_Sub1_PosX:
	;Check if player X distance from enemy < $20
	cmp #$20
	bcc Enemy37_Sub1_PlayerNext
	;Check if X distance is less than current minimum
	cmp $00
	bcs Enemy37_Sub1_PlayerNext
	;Set closest player distance
	sta $00
	;Set closest player index
	sty $01
	lda $02
	sta $10
Enemy37_Sub1_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy37_Sub1_PlayerLoop
	;If closest player X distance from enemy < $80, exit early
	lda $00
	bpl Enemy37_Sub1_CheckNext
Enemy37_Sub1_IncT:
	;Increment animation timer
	inc Enemy_Temp1,x
Enemy37_Sub1_Exit:
	rts
Enemy37_Sub1_CheckNext:
	;Get target X position
	bit $10
	bpl Enemy37_Sub1_PosX2
	sbc #$20
Enemy37_Sub1_PosX2:
	lsr
	sta $00
	;If player Y position < enemy Y position, exit early
	ldy $01
	lda Enemy_Y,y
	sbc Enemy_Y+$08,x
	bcc Enemy37_Sub1_IncT
	;Divide player Y distance from enemy by player X distance from target position
	sta $01
	lda #$00
	sta $02
	asl $01
	ldy #$08
Enemy37_Sub1_DivLoop:
	rol
	cmp $00
	bcc Enemy37_Sub1_DivNoC
	sbc $00
Enemy37_Sub1_DivNoC:
	rol $01
	dey
	bne Enemy37_Sub1_DivLoop
Enemy37_Sub1_DivLoop2:
	asl
	cmp $00
	bcc Enemy37_Sub1_DivNoC2
	sbc $00
Enemy37_Sub1_DivNoC2:
	rol $02
	dey
	bne Enemy37_Sub1_DivLoop2
	;Multiply player X distance from target position by 1/16
	lsr $00
	ror
	lsr $00
	ror
	lsr $00
	ror
	lsr $00
	ror
	and #$F0
	sta $03
	;If result 1 - result 2 < 0, exit early
	lda $02
	sec
	sbc $03
	tay
	lda $01
	sbc $00
	bcc Enemy37_Sub1_IncT
	;Set max value $06
	cmp #$06
	bcc Enemy37_Sub1_SetY
	lda #$06
Enemy37_Sub1_SetY:
	;Set enemy velocity/props
	sta Enemy_YVel,x
	tya
	sta Enemy_YVelLo,x
	lda #$00
	sta Enemy_XVelLo,x
	lda #$02
	bit $10
	bpl Enemy37_Sub1_SetX
	lda #$FE
Enemy37_Sub1_SetX:
	sta Enemy_XVel,x
	lsr
	and #$40
	sta Enemy_Props+$08,x
	;Next task ($02: Down)
	inc Enemy_Mode,x
	rts
;$02: Down
Enemy37_Sub2:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$20
	sta Enemy_YVelLo,x
	bcc Enemy37_Sub2_NoYC
	inc Enemy_YVel,x
Enemy37_Sub2_NoYC:
	;Move enemy
	jsr MoveEnemyXY
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If no ground collision, exit early
	jsr EnemyGetGroundCollision
	bcc Enemy37_Sub2_Exit
	;Set enemy grounded
	ldy #$00
	jsr HandleEnemyGroundCollision
	;Clear enemy animation timer/offset
	lda #$FF
	sta Enemy_AnimTimer,x
	sta Enemy_AnimOffs,x
	;Set animation timer
	lda #$18
	sta Enemy_Temp1,x
	;Next task ($03: Attack)
	inc Enemy_Mode,x
Enemy37_Sub2_Exit:
	rts
;$03: Attack
Enemy37_Sub3:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy37_Sub3_Next
	;If animation timer $10, spawn attack
	lda Enemy_Temp1,x
	cmp #$10
	bne Enemy37_Sub3_NoAttack
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, skip this part
	bcc Enemy37_Sub3_NoAttack
	;Set enemy ID $47 (Tengu fire)
	lda #ENEMY_TENGUFIRE
	sta Enemy_ID,x
	;Set parent enemy slot index
	txa
	tay
	ldx CurEnemyIndex
	txa
	sta Enemy_Temp2,y
	;Offset attack Y position
	lda #$F8
	jsr OffsetEnemyYPos
	;Offset projectile X position based on enemy facing direction
	lda Enemy_Props+$08,x
	cmp #$40
	lda #$10
	bcc Enemy37_Sub3_Right
	lda #$EF
Enemy37_Sub3_Right:
	adc Enemy_X+$08,y
	sta Enemy_X+$08,y
Enemy37_Sub3_NoAttack:
	;Update enemy animation
	ldy #$34
	jmp UpdateEnemyAnimation_AnyY
Enemy37_Sub3_Next:
	;Set enemy Y velocity
	lda #$FC
	sta Enemy_YVel,x
	;Next task ($04: Up)
	inc Enemy_Mode,x
	rts
;$04: Up
Enemy37_Sub4:
	;If enemy Y position < $28, go to next task ($05: Fly end)
	lda Enemy_Y+$08,x
	cmp #$28
	bcs Enemy37_Sub4_NoNext
	;Set enemy X velocity
	asl Enemy_XVel,x
	lda #$00
	bcc Enemy37_Sub4_Right
	lda #$FF
Enemy37_Sub4_Right:
	sta Enemy_XVel,x
	lda #$80
	sta Enemy_XVelLo,x
	;Set animation timer
	lda #$10
	sta Enemy_Temp1,x
	;Next task ($05: Fly end)
	inc Enemy_Mode,x
	rts
Enemy37_Sub4_NoNext:
	;Accelerate upward
	lda Enemy_YVelLo,x
	sbc #$28
	sta Enemy_YVelLo,x
	bcs Enemy37_Sub4_NoYC
	dec Enemy_YVel,x
Enemy37_Sub4_NoYC:
	;Move enemy
	jsr MoveEnemyXY
	;Update enemy animation
	jmp UpdateEnemyAnimation
;$05: Fly end
Enemy37_Sub5:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy37_Sub5_NoNext
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Next task ($00: Init)
	lda #$00
	sta Enemy_Mode,x
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy X velocity to target player
	lda #$0E
	jmp SetEnemyXVel_AnyY
Enemy37_Sub5_NoNext:
	;Move enemy X
	jsr MoveEnemyX
	;Update enemy animation
	jmp UpdateEnemyAnimation

;$47: Tengu fire
Enemy47JumpTable:
	.dw Enemy47_Sub0	;$00  Init
	.dw Enemy47_Sub1	;$01  Main
;$00: Init
Enemy47_Sub0:
	;Set animation timer
	lda #$08
	sta Enemy_Temp1,x
	;Set enemy flags
	lda #(EF_NOHITATTACK|$10)
	sta Enemy_Flags,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
Enemy47_Sub0_Exit:
	rts
;$01: Main
Enemy47_Sub1:
	;If parent enemy not active, clear enemy
	ldy Enemy_Temp2,x
	lda Enemy_ID,y
	beq Enemy47_Sub1_Clear
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy47_Sub0_Exit
Enemy47_Sub1_Clear:
	;Clear enemy
	jmp ClearEnemy

;$38: Coatlicue
Enemy38JumpTable:
	.dw Enemy38_Sub0	;$00  Init
	.dw Enemy38_Sub1	;$01  Chase
	.dw Enemy38_Sub2	;$02  Flee
;$00: Init
Enemy38_Sub0:
	;Set palette colors
	lda #$08
	sta PaletteBuffer+$1D
	lda #$28
	sta PaletteBuffer+$1E
	lda #$38
	sta PaletteBuffer+$1F
	;If enemy to left of screen bounds, go to next task ($01: Chase)
	lda Enemy_XHi+$08,x
	bpl Enemy38_Sub0_NoNext
	;Set enemy flags/sprite
	lda #$00
	sta Enemy_Flags,x
	lda #$0B
	sta Enemy_Sprite+$08,x
	;Set enemy X velocity to target player
	lda #$10
	jmp SetEnemyXVel
Enemy38_Sub0_NoNext:
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags,x
	rts
;$01: Chase
Enemy38_Sub1:
	;Find closest player
	jsr FindClosestPlayerX
	;If enemy behind player, skip this part
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	lda Enemy_XHi+$08,x
	sbc #$00
	lsr
	eor Enemy_Props,y
	and #$40
	bne Enemy38_Sub1_NoNext
	;Set enemy X velocity to target player
	lda #$08
	jsr SetEnemyXVel_AnyY
	;Flip enemy X
	jmp FlipEnemyX
Enemy38_Sub1_NoNext:
	;Check to flip enemy X
	lda Enemy_XVel,x
	lsr
	eor Enemy_Props,y
	and #$40
	beq Enemy38_Sub1_NoFlip
	;Flip enemy X
	jsr FlipEnemyX
Enemy38_Sub1_NoFlip:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	jmp Enemy38_Sub2_EntChase
;$02: Flee
Enemy38_Sub2:
	;Find closest player
	jsr FindClosestPlayerX
	;If enemy in front of player, skip this part
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	lda Enemy_XHi+$08,x
	sbc #$00
	lsr
	eor Enemy_Props,y
	and #$40
	beq Enemy38_Sub2_NoNext
	;Next task ($01: Chase)
	lda #$01
	sta Enemy_Mode,x
	;Set enemy X velocity to target player
	lda #$10
	jmp SetEnemyXVel_NoNextMode
Enemy38_Sub2_NoNext:
	;Update enemy animation
	ldy #$21
	jsr UpdateEnemyAnimation_AnyY
Enemy38_Sub2_EntChase:
	;If bits 0-1 of global timer != bit 0-1 of enemy slot index, don't check for collision
	txa
	eor GlobalTimer
	lsr
	bcc Enemy38_Sub2_CheckColl
	;If enemy Y velocity 0, don't accelerate
	ldy Enemy_YVel,x
	beq Enemy38_Sub2_NoYC
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy38_Sub2_NoYC
	inc Enemy_YVel,x
	;Move enemy Y
	jsr MoveEnemyY
Enemy38_Sub2_NoYC:
	;If hit wall, exit early
	lda Enemy_Temp2,x
	beq Enemy38_Sub2_MoveX
	rts
Enemy38_Sub2_MoveX:
	;Move enemy X
	jmp MoveEnemyX
Enemy38_Sub2_CheckColl:
	;Check for wall collision
	jsr EnemyGetWallCollision
	bcs Enemy38_Sub2_SetWall
	;Clear hit wall flag
	lda #$00
	sta Enemy_Temp2,x
	;Move enemy X
	jsr MoveEnemyX
	;If enemy Y velocity up, skip this part
	lda Enemy_YVel,x
	bmi Enemy38_Sub2_NoColl
	;Check for ground collision
	jsr EnemyGetGroundCollision
	bcc Enemy38_Sub2_NoColl
	;If enemy Y velocity 0, exit early
	lda Enemy_YVel,x
	bne Enemy38_Sub2_SetGround
	rts
Enemy38_Sub2_SetGround:
	;Set enemy grounded
	ldy #$00
	jmp HandleEnemyGroundCollision
Enemy38_Sub2_SetWall:
	;If hit wall, skip this part
	lda Enemy_Temp2,x
	bne Enemy38_Sub2_NoColl
	;Set hit wall flag
	inc Enemy_Temp2,x
	;Set enemy Y velocity
	lda #$FA
	sta Enemy_YVel,x
Enemy38_Sub2_NoColl:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy38_Sub2_NoYC2
	inc Enemy_YVel,x
Enemy38_Sub2_NoYC2:
	;Move enemy Y
	jmp MoveEnemyY

;$33: Cockatrice
Enemy33JumpTable:
	.dw Enemy33_Sub0	;$00  Init
	.dw Enemy33_Sub1	;$01  Fly
	.dw Enemy33_Sub2	;$02  Turn
;$00: Init
Enemy33_Sub0:
	;Set enemy X velocity to target player
	lda #$02
	jmp SetEnemyXVel
;$01: Fly
Enemy33_Sub1:
	;If enemy offscreen horizontally, skip this part
	lda Enemy_XHi+$08,x
	bne Enemy33_Sub1_NoNext
	;If enemy X position not $40-$BF, go to next task ($02: Turn)
	lda Enemy_X+$08,x
	ldy Enemy_XVel,x
	bpl Enemy33_Sub1_Right
	cmp #$40
	bcs Enemy33_Sub1_NoNext
	bcc Enemy33_Sub1_Next
Enemy33_Sub1_Right:
	cmp #$C0
	bcc Enemy33_Sub1_NoNext
Enemy33_Sub1_Next:
	;Next task ($02: Turn)
	inc Enemy_Mode,x
	;Save enemy X velocity
	tya
	sta Enemy_Temp2,x
Enemy33_Sub1_NoNext:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy X
	jsr MoveEnemyX
	;If attack timer not 0, exit early
	lda Enemy_Temp1,x
	beq Enemy33_Sub1_CheckSpawn
	;Decrement attack timer
	dec Enemy_Temp1,x
	rts
Enemy33_Sub1_CheckSpawn:
	;Check if player is in range
	ldy #$01
Enemy33_Sub1_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc Enemy33_Sub1_PlayerNext
	;If player Y position < enemy Y position, skip this part
	lda Enemy_Y,y
	sbc Enemy_Y+$08,x
	bcc Enemy33_Sub1_PlayerNext
	;Check if enemy is moving left or right
	lsr
	sta $00
	sec
	lda Enemy_Props+$08,x
	and #$40
	beq Enemy33_Sub1_CheckRight
	;Get player X distance in front of enemy (left)
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	bcs Enemy33_Sub1_CheckD
	bcc Enemy33_Sub1_PlayerNext
Enemy33_Sub1_CheckRight:
	;Get player X distance in front of enemy (right)
	lda Enemy_X,y
	sbc Enemy_X+$08,x
	bcc Enemy33_Sub1_PlayerNext
Enemy33_Sub1_CheckD:
	;Check if player is in range
	adc #$0F
	ror
	sec
	sbc $00
	bcc Enemy33_Sub1_PlayerNext
	cmp #$20
	bcc Enemy33_Sub1_Spawn
Enemy33_Sub1_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy33_Sub1_PlayerLoop
Enemy33_Sub1_Exit:
	rts
Enemy33_Sub1_Spawn:
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy33_Sub1_Exit
	;Offset projectile Y position
	txa
	tay
	ldx CurEnemyIndex
	lda #$FC
	jsr OffsetEnemyYPos
	;Set enemy ID $48 (Cockatrice fire)
	lda #ENEMY_COCKATRICEFIRE
	sta Enemy_ID,y
	;Set animation timer
	lda #$02
	sta Enemy_Temp1,y
	;Set enemy sprite/flags/velocity
	lda #$7D
	sta Enemy_Sprite+$08,y
	lda #(EF_NOHITATTACK|$02)
	sta Enemy_Flags,y
	lda Enemy_Props+$08,x
	cmp #$40
	;Offset projectile X position based on enemy facing direction
	lda #$04
	sta Enemy_YVel,y
	bcc Enemy33_Sub1_SpawnRight
	lda #$FC
Enemy33_Sub1_SpawnRight:
	sta Enemy_XVel,y
	asl
	asl
	clc
	adc Enemy_X+$08,y
	sta Enemy_X+$08,y
	;Reset attack timer
	lda #$80
	sta Enemy_Temp1,x
	;Play sound
	lda #SE_COCKATRICEFIRE
	jmp LoadSound
;$02: Turn
Enemy33_Sub2:
	;Check if turning left or right
	lda Enemy_Temp2,x
	bpl Enemy33_Sub2_Left
	;Accelerate right
	lda Enemy_XVelLo,x
	clc
	adc #$04
	sta Enemy_XVelLo,x
	bcc Enemy33_Sub2_NoNext
	inc Enemy_XVel,x
	;If enemy X velocity left, skip this part
	bmi Enemy33_Sub2_NoNext
	;Set enemy props
	lda #$00
	sta Enemy_Props+$08,x
	;If enemy X velocity >= $01, go to next task ($01: Fly)
	lda Enemy_XVel,x
	beq Enemy33_Sub2_NoNext
Enemy33_Sub2_Next:
	;Next task ($01: Fly)
	dec Enemy_Mode,x
Enemy33_Sub2_NoNext:
	jmp Enemy33_Sub1_NoNext
Enemy33_Sub2_Left:
	;Accelerate left
	lda Enemy_XVelLo,x
	sec
	sbc #$04
	sta Enemy_XVelLo,x
	bcs Enemy33_Sub2_NoNext
	dec Enemy_XVel,x
	;If enemy X velocity right, skip this part
	bpl Enemy33_Sub2_NoNext
	;Set enemy props
	lda #$40
	sta Enemy_Props+$08,x
	;If enemy X velocity < $FF, go to next task ($01: Fly)
	lda Enemy_XVel,x
	cmp #$FF
	bcc Enemy33_Sub2_Next
	jmp Enemy33_Sub1_NoNext

;$48: Cockatrice fire
Enemy48JumpTable:
	.dw Enemy48_Sub0	;$00  Init
	.dw MoveEnemyXY		;$01  Main
;$00: Init
Enemy48_Sub0:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy48_Sub0_Exit
	;Set enemy sprite
	inc Enemy_Sprite+$08,x
	;Set animation timer
	lda #$02
	sta Enemy_Temp1,x
	;If enemy sprite not $7F, exit early
	lda Enemy_Sprite+$08,x
	cmp #$7F
	bne Enemy48_Sub0_Exit
	;Next task ($01: Main)
	inc Enemy_Mode,x
Enemy48_Sub0_Exit:
	rts

;$49: T-Rex
Enemy49JumpTable:
	.dw Enemy49_Sub0	;$00  Init
	.dw Enemy49_Sub1	;$01  Main
	.dw Enemy49_Sub2	;$02  Stop
	.dw Enemy49_Sub3	;$03  Attack
;$00: Init
Enemy49_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	beq Enemy49_Sub0_Init
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	bmi Enemy49_Sub0_Init
	rts
Enemy49_Sub0_Init:
	;Move enemy down $08
	lda Enemy_Y+$08,x
	clc
	adc #$08
	sta Enemy_Y+$08,x
	;Set enemy X velocity to target player
	lda #$02
	jmp SetEnemyXVel
;$01: Main
Enemy49_Sub1:
	;Check if animation timer 0
	lda Enemy_Temp1,x
	beq Enemy49_Sub1_CheckNext
	;Decrement animation timer
	dec Enemy_Temp1,x
	jmp Enemy49_Sub1_NoNext
Enemy49_Sub1_CheckNext:
	;Check if player is in range
	ldy #$01
Enemy49_Sub1_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc Enemy49_Sub1_PlayerNext
	;Check if enemy is moving left or right
	lda Enemy_XVel,x
	bmi Enemy49_Sub1_CheckLeft
	;Get player X distance in front of enemy (left)
	lda Enemy_X,y
	sbc Enemy_X+$08,x
	bcs Enemy49_Sub1_CheckD
	bcc Enemy49_Sub1_PlayerNext
Enemy49_Sub1_CheckLeft:
	;Get player X distance in front of enemy (right)
	lda Enemy_X+$08,x
	sbc Enemy_X,y
Enemy49_Sub1_CheckD:
	;If player X distance from enemy < $40, go to next task ($02: Stop)
	cmp #$40
	bcc Enemy49_Sub1_Next
Enemy49_Sub1_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy49_Sub1_PlayerLoop
Enemy49_Sub1_NoNext:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy X
	jsr MoveEnemyX
	;Check for slope top collision type
	ldy #$08
	jsr EnemyGetGroundCollision_AnyY
	cmp #$13
	beq Enemy49_Sub1_SlopeTop
	;Check for ground collision
	bcs Enemy49_Sub1_NoSlope
	;Check for 30 deg. slope collision types
	cmp #$05
	bcs Enemy49_Sub1_Slope
	;Move enemy down $01
	inc Enemy_Y+$08,x
	rts
Enemy49_Sub1_SlopeTop:
	;Check for 30 deg. slope collision types
	ldy #$05
	jsr EnemyGetWallCollision_AnyY
	cmp #$05
	bcc Enemy49_Sub1_NoFlip
	;Move enemy up $02
	dec Enemy_Y+$08,x
	dec Enemy_Y+$08,x
Enemy49_Sub1_Slope:
	;Get collision tile X offset
	tay
	lda Enemy_X+$08,x
	clc
	adc TempMirror_PPUSCROLL_X
	and #$1F
	lsr
	;Check for 30 deg. slope right collision types
	cpy #$07
	bcs Enemy49_Sub1_SlopeRight
	;Set enemy grounded
	eor #$0F
	adc #$01
Enemy49_Sub1_SlopeRight:
	sta $00
	sec
	lda $0A
	and #$F0
	sbc #$18
	clc
	adc $00
	sta Enemy_Y+$08,x
	rts
Enemy49_Sub1_NoSlope:
	;If wall collision, flip enemy X
	jsr EnemyGetWallCollision
	bcc Enemy49_Sub1_NoFlip
	jsr FlipEnemyX
Enemy49_Sub1_NoFlip:
	;If current X screen not $05, skip this part
	lda Enemy_X+$08,x
	adc TempMirror_PPUSCROLL_X
	lda Enemy_XHi+$08,x
	adc CurScreenX
	cmp #$05
	bne Enemy49_Sub1_NoFlip2
	;If enemy X velocity right, flip enemy X
	lda Enemy_XVel,x
	bmi Enemy49_Sub1_NoFlip2
	jsr FlipEnemyX
Enemy49_Sub1_NoFlip2:
	;Set enemy grounded
	ldy #$08
	jmp HandleEnemyGroundCollision_NoClearY
Enemy49_Sub1_Next:
	;Set enemy sprite
	lda #$85
	sta Enemy_Sprite+$08,x
	;Set animation timer
	lda #$18
	sta Enemy_Temp1,x
	;Next task ($02: Stop)
	inc Enemy_Mode,x
Enemy49_Sub1_Exit:
	rts
;$02: Stop
Enemy49_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy49_Sub2_CheckSpawn
	;If animation timer not $10, exit early
	lda Enemy_Temp1,x
	cmp #$10
	bne Enemy49_Sub1_Exit
	;Set enemy sprite
	lda #$87
	sta Enemy_Sprite+$08,x
	rts
Enemy49_Sub2_CheckSpawn:
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcs Enemy49_Sub2_Spawn
	;Increment animation timer
	inc Enemy_Temp1,x
	rts
Enemy49_Sub2_Spawn:
	;Set enemy ID $4A (T-Rex fire)
	lda #ENEMY_TREXFIRE
	sta Enemy_ID,x
	;Offset projectile Y position
	txa
	tay
	ldx CurEnemyIndex
	lda #$F0
	jsr OffsetEnemyYPos
	;Set enemy X velocity
	lda Enemy_XVel,x
	asl
	lda #$2C
	bcc Enemy49_Sub2_RightPos
	lda #$D3
Enemy49_Sub2_RightPos:
	sta $00
	adc Enemy_X+$08,y
	sta Enemy_X+$08,y
	;Offset projectile X position based on enemy facing direction
	lda #$00
	bit $00
	bpl Enemy49_Sub2_RightVel
	lda #$FF
Enemy49_Sub2_RightVel:
	adc Enemy_XHi+$08,x
	sta Enemy_XHi+$08,y
	;Set parent enemy slot index
	txa
	sta Enemy_Temp2,y
	;Set enemy sprite
	lda #$85
	sta Enemy_Sprite+$08,x
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Next task ($03: Attack)
	inc Enemy_Mode,x
	rts
;$03: Attack
Enemy49_Sub3:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy49_Sub3_Exit
	;Next task ($01: Main)
	lda #$01
	sta Enemy_Mode,x
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
Enemy49_Sub3_Exit:
	rts

;$4A: T-Rex fire
Enemy4AJumpTable:
	.dw Enemy4A_Sub0	;$00  Init
	.dw Enemy4A_Sub1	;$01  Main
;$00: Init
Enemy4A_Sub0:
	;Clear enemy animation timer/offset
	lda #$FF
	sta Enemy_AnimTimer,x
	sta Enemy_AnimOffs,x
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|$0A)
	sta Enemy_Flags,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
	;Play sound
	lda #SE_TREXFIRE
	jmp LoadSound
;$01: Main
Enemy4A_Sub1:
	;If parent enemy not active, clear enemy
	ldy Enemy_Temp2,x
	lda Enemy_ID,y
	cmp #ENEMY_TREX
	bne Enemy4A_Sub1_Clear
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If enemy sprite 0, clear enemy
	lda Enemy_Sprite+$08,x
	beq Enemy4A_Sub1_Clear
	;If enemy sprite < $8A, exit early
	cmp #$8A
	bcc Enemy4A_Sub1_Exit
	;Set enemy flags
	lda #(EF_NOHITATTACK|$0A)
	sta Enemy_Flags,x
Enemy4A_Sub1_Exit:
	rts
Enemy4A_Sub1_Clear:
	;Clear enemy
	jmp ClearEnemy

;$4C: Behemoth
Enemy4CJumpTable:
	.dw Enemy4C_Sub0	;$00  Init
	.dw Enemy4C_Sub1	;$01  Wait
	.dw Enemy4C_Sub2	;$02  Jump out
	.dw Enemy4C_Sub3	;$03  Run
	.dw Enemy4C_Sub4	;$04  Jump
;$00: Init
Enemy4C_Sub0:
	;If enemy Y position >= $60, exit early
	lda Enemy_YHi+$08,x
	bne Enemy4A_Sub1_Exit
	lda Enemy_Y+$08,x
	cmp #$60
	bcs Enemy4A_Sub1_Exit
	;Set enemy Y velocity
	lda #$FF
	sta Enemy_YVel,x
	;Clear enemy animation offset/timer
	sta Enemy_AnimOffs,x
	sta Enemy_AnimTimer,x
	;Set enemy sprite
	lda #$82
	sta Enemy_Sprite+$08,x
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy X velocity to target player
	lda #$00
	jmp SetEnemyXVel_AnyY
;$01: Wait
Enemy4C_Sub1:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy4C_Sub1_Exit
	;Disable enemy scroll Y
	lda #$01
	sta Enemy_Temp0,x
	;Next task ($02: Jump out)
	inc Enemy_Mode,x
Enemy4C_Sub1_Exit:
	rts
;$02: Jump out
Enemy4C_Sub2:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy4C_Sub2_NoYC
	inc Enemy_YVel,x
Enemy4C_Sub2_NoYC:
	;Move enemy Y
	jsr MoveEnemyY
	;If enemy Y velocity up, exit early
	lda Enemy_YVel,x
	bmi Enemy4A_Sub1_Exit
	;If enemy Y position < $A0, exit early
	lda Enemy_Y+$08,x
	cmp #$A0
	bcc Enemy4A_Sub1_Exit
	;Set enemy Y position
	lda #$A0
	sta Enemy_Y+$08,x
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy X velocity to target player
	lda #$12
	jmp SetEnemyXVel_AnyY
;$03: Run
Enemy4C_Sub3:
	;Check for level bounds
	lda Enemy_XHi+$08,x
	beq Enemy4C_Sub3_NoBound
	;Check to flip enemy X
	eor Enemy_XVel,x
	bmi Enemy4C_Sub3_NoFlip
	bpl Enemy4C_Sub3_Flip
Enemy4C_Sub3_NoBound:
	lda Enemy_X+$08,x
	eor Enemy_XVel,x
	bpl Enemy4C_Sub3_NoFlip
	lda Enemy_X+$08,x
	adc #$10
	cmp #$20
	bcs Enemy4C_Sub3_NoFlip
Enemy4C_Sub3_Flip:
	;Flip enemy X
	jsr FlipEnemyX
Enemy4C_Sub3_NoFlip:
	;Check if animation timer 0
	lda Enemy_Temp1,x
	beq Enemy4C_Sub3_CheckNext
	;Decrement animation timer
	dec Enemy_Temp1,x
	bne Enemy4C_Sub3_NoNext
Enemy4C_Sub3_CheckNext:
	;Check if player is in range
	ldy #$00
Enemy4C_Sub3_PlayerLoop:
	;Check if enemy is moving left or right
	sec
	lda Enemy_XVel,x
	bmi Enemy4C_Sub3_CheckLeft
	;Get player X distance in front of enemy (right)
	lda Enemy_X,y
	sbc Enemy_X+$08,x
	bcs Enemy4C_Sub3_CheckD
	bcc Enemy4C_Sub3_PlayerNext
Enemy4C_Sub3_CheckLeft:
	;Get player X distance in front of enemy (left)
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	bcc Enemy4C_Sub3_PlayerNext
Enemy4C_Sub3_CheckD:
	;If player X distance from enemy < $40, go to next task ($04: Jump)
	cmp #$40
	bcc Enemy4C_Sub3_Next
Enemy4C_Sub3_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy4C_Sub3_PlayerLoop
Enemy4C_Sub3_NoNext:
	;Move enemy X
	jsr MoveEnemyX
	;Update enemy animation
	jmp UpdateEnemyAnimation
Enemy4C_Sub3_Next:
	;Set enemy sprite/Y velocity
	lda #$84
	sta Enemy_Sprite+$08,x
	lda #$FC
	sta Enemy_YVel,x
	lda #$00
	sta Enemy_YVelLo,x
	;Next task ($04: Jump)
	inc Enemy_Mode,x
	;Move enemy
	jmp MoveEnemyXY
;$04: Jump
Enemy4C_Sub4:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy4C_Sub4_NoYC
	inc Enemy_YVel,x
Enemy4C_Sub4_NoYC:
	;Move enemy
	jsr MoveEnemyXY
	;If enemy Y velocity up, exit early
	lda Enemy_YVel,x
	bmi Enemy4C_Sub4_Exit
	;If enemy Y position < $A0, exit early
	lda Enemy_Y+$08,x
	cmp #$A0
	bcc Enemy4C_Sub4_Exit
	;Set enemy Y position
	lda #$A0
	sta Enemy_Y+$08,x
	;Clear enemy animation timer/offset
	lda #$FF
	sta Enemy_AnimTimer,x
	sta Enemy_AnimOffs,x
	;Set animation timer
	lda #$30
	sta Enemy_Temp1,x
	;Next task ($03: Run)
	dec Enemy_Mode,x
Enemy4C_Sub4_Exit:
	rts

;$4E: Water drop spawner
Enemy4EJumpTable:
	.dw Enemy4E_Sub0	;$00  Init
	.dw Enemy4E_Sub1	;$01  Main
;$00: Init
Enemy4E_Sub0:
	;Set spawn timer
	lda #$10
	sta Enemy_Temp1,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
Enemy4E_Sub1:
	;Decrement spawn timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy4E_Sub1_Exit
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcs Enemy4E_Sub1_CheckSpawn
	;Increment animation timer
	inc Enemy_Temp1,x
Enemy4E_Sub1_Exit:
	rts
Enemy4E_Sub1_CheckSpawn:
	;Get water drop X screen
	ldy CurEnemyIndex
	lda Enemy_Temp2,y
	sta $00
	asl
	lda #$00
	adc #$03
	sta $10
	;Get water drop position data offset
	lda Enemy_Temp3,y
	sta $12
	bit $00
	bpl Enemy4E_Sub1_NoIncOffs
	adc #$05
Enemy4E_Sub1_NoIncOffs:
	tay
	;Check if water drop X position onscreen
	lda WaterDropXPosition,y
	sec
	sbc TempMirror_PPUSCROLL_X
	sta $11
	lda $10
	sbc CurScreenX
	beq Enemy4E_Sub1_Spawn
	;Check if water drop X position offscreen horizontally
	lda $12
	bcs Enemy4E_Sub1_NoSetPos
	cmp #$03
	bne Enemy4E_Sub1_NoSetPos
	;Restore X register
	ldx CurEnemyIndex
	;Clear enemy
	jmp ClearEnemy
Enemy4E_Sub1_Spawn:
	;Set water drop position
	lda $11
	sta Enemy_X+$08,x
	lda WaterDropYPosition,y
	sta Enemy_Y+$08,x
	;Set enemy ID $4F (Water drop)
	lda #ENEMY_WATERDROP
	sta Enemy_ID,x
	;Load CHR bank
	lda #$39
	sta TempCHRBanks+2
Enemy4E_Sub1_NoSetPos:
	;Increment water drop position data offset
	ldx CurEnemyIndex
	lda $12
	clc
	adc #$01
	tay
	bit $00
	bpl Enemy4E_Sub1_NoIncOffs2
	iny
Enemy4E_Sub1_NoIncOffs2:
	cpy #$05
	bcc Enemy4E_Sub1_SetOffs
	lda #$00
Enemy4E_Sub1_SetOffs:
	sta Enemy_Temp3,x
	;Reset spawn timer
	lda #$20
	sta Enemy_Temp1,x
	rts
WaterDropXPosition:
	.db $30,$6C,$4C,$D0,$90
	.db $10,$90,$4C,$D0
WaterDropYPosition:
	.db $3A,$41,$41,$3A,$3A
	.db $3A,$3A,$41,$3A

;$4F: Water drop
Enemy4FJumpTable:
	.dw Enemy4F_Sub0	;$00  Init
	.dw Enemy4F_Sub1	;$01  Wait
	.dw Enemy4F_Sub2	;$02  Fall
	.dw Enemy4F_Sub3	;$03  Land
;$00: Init
Enemy4F_Sub0:
	;Set enemy sprite
	lda #$8E
	sta Enemy_Sprite+$08,x
	;Set animation timer
	lda #$18
	sta Enemy_Temp1,x
	;Set enemy flags
	lda #(EF_NOHITATTACK|$02)
	sta Enemy_Flags,x
	;Next task ($01: Wait)
	inc Enemy_Mode,x
;$01: Wait
Enemy4F_Sub1:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy4F_Sub1_Next
	rts
Enemy4F_Sub1_Next:
	;Next task ($02: Fall)
	inc Enemy_Mode,x
	;Set enemy sprite
	inc Enemy_Sprite+$08,x
;$02: Fall
Enemy4F_Sub2:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy4F_Sub2_NoYC
	inc Enemy_YVel,x
Enemy4F_Sub2_NoYC:
	;Move enemy Y
	jsr MoveEnemyY
	;If enemy Y position < $80, exit early
	lda Enemy_Y+$08,x
	bmi Enemy4F_Sub2_Next
Enemy4F_Sub2_Exit:
	rts
Enemy4F_Sub2_Next:
	;Set enemy Y position
	lda #$80
	sta Enemy_Y+$08,x
	;Set animation timer
	lda #$0A
	sta Enemy_Temp1,x
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags,x
	;Set enemy sprite
	inc Enemy_Sprite+$08,x
	;Next task ($03: Land)
	inc Enemy_Mode,x
	;Play sound
	lda #SE_WATERDROP
	jmp LoadSound
;$03: Land
Enemy4F_Sub3:
	;If animation timer $07, set enemy sprite
	lda Enemy_Temp1,x
	cmp #$07
	bne Enemy4F_Sub3_NoSetSp
	inc Enemy_Sprite+$08,x
Enemy4F_Sub3_NoSetSp:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy4F_Sub2_Exit
	;Clear enemy
	jmp ClearEnemy

;$51: Minotaur
Enemy51JumpTable:
	.dw Enemy51_Sub0	;$00  Init
	.dw Enemy51_Sub1	;$01  Walk
	.dw Enemy51_Sub2	;$02  Stop
	.dw Enemy51_Sub3	;$03  Run
;$00: Init
Enemy51_Sub0:
	;If scroll Y position >= $48, exit early
	lda #$10
	bit AutoScrollXVel
	bmi Enemy51_Sub0_CheckScroll
	lda #$48
Enemy51_Sub0_CheckScroll:
	cmp TempMirror_PPUSCROLL_Y
	bcs Enemy51_Sub0_CheckInit
Enemy51_Sub0_Exit:
	rts
Enemy51_Sub0_CheckInit:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	bpl Enemy51_Sub0_Init
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	bpl Enemy51_Sub0_Exit
Enemy51_Sub0_Init:
	;If level 6 crusher not active, don't set enemy position
	lda AutoScrollDirFlags
	beq Enemy51_Sub0_NoSet
	;If enemy offscreen horizontally, don't set enemy X position
	lda Enemy_XHi+$08,x
	bne Enemy51_Sub0_NoSetX
	;Set enemy position
	sta Enemy_X+$08,x
	lda Enemy_Temp2,x
	clc
	adc #$01
	sta Enemy_XHi+$08,x
Enemy51_Sub0_NoSetX:
	lda #$90
	sec
	sbc TempMirror_PPUSCROLL_Y
	sta Enemy_Y+$08,x
Enemy51_Sub0_NoSet:
	;Set enemy X velocity to target player
	lda #$0C
	jmp SetEnemyXVel
;$03: Run
Enemy51_Sub3:
	;Decrement timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy51_Sub1_EntRun
	;Multiply enemy X velocity by 1/2
	lda Enemy_XVel,x
	asl
	ror Enemy_XVel,x
	ror Enemy_XVelLo,x
	;Next task ($01: Walk)
	lda #$01
	sta Enemy_Mode,x
	rts
;$01: Walk
Enemy51_Sub1:
	;Check if player is in range
	ldy #$00
Enemy51_Sub1_PlayerLoop:
	;Check if enemy is moving left or right
	sec
	lda Enemy_XVel,x
	bmi Enemy51_Sub1_CheckLeft
	;Get player X distance in front of enemy (left)
	lda Enemy_X,y
	sbc Enemy_X+$08,x
	bcs Enemy51_Sub1_CheckD
	bcc Enemy51_Sub1_PlayerNext
Enemy51_Sub1_CheckLeft:
	;Get player X distance in front of enemy (right)
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	bcc Enemy51_Sub1_PlayerNext
Enemy51_Sub1_CheckD:
	;If player X distance from enemy < $40, go to next task ($02: Stop)
	cmp #$40
	bcc Enemy51_Sub1_Next
Enemy51_Sub1_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy51_Sub1_PlayerLoop
Enemy51_Sub1_EntRun:
	;Check if level 6 crusher scroll Y position > $50
	lda TempMirror_PPUSCROLL_Y
	cmp #$50
	bcs Enemy51_Sub1_SetExplosion
	;Update enemy animation
	ldy #$51
	lda Enemy_Mode,x
	cmp #$01
	beq Enemy51_Sub1_NoRun
	dey
Enemy51_Sub1_NoRun:
	jsr UpdateEnemyAnimation_AnyY
	;Move enemy X
	jsr MoveEnemyX
	;Check for slope top collision type
	ldy #$05
	jsr EnemyGetGroundCollision_AnyY
	beq Enemy51_Sub1_SlopeTop
	;Check for ground collision
	bcs Enemy51_Sub1_NoSlope
	;Check for 30 deg. slope collision types
	cmp #$05
	bcs Enemy51_Sub1_Slope
	;Move enemy down $01
	inc Enemy_Y+$08,x
Enemy51_Sub1_Exit:
	rts
Enemy51_Sub1_SlopeTop:
	;Check for 30 deg. slope collision types
	jsr EnemyGetWallCollision
	cmp #$05
	bcc Enemy51_Sub1_NoFlip
	;Move enemy up $02
	dec Enemy_Y+$08,x
	dec Enemy_Y+$08,x
Enemy51_Sub1_Slope:
	;Get collision tile X offset
	tay
	lda Enemy_X+$08,x
	clc
	adc TempMirror_PPUSCROLL_X
	and #$1F
	beq Enemy51_Sub1_Exit
	lsr
	;Check for 30 deg. slope right collision types
	cpy #$07
	bcs Enemy51_Sub1_SlopeRight
	;Set enemy grounded
	eor #$0F
	adc #$01
Enemy51_Sub1_SlopeRight:
	tay
	jmp HandleEnemyGroundCollision_NoClearY
Enemy51_Sub1_NoSlope:
	;If wall collision, flip enemy X
	jsr EnemyGetWallCollision
	bcc Enemy51_Sub1_NoFlip
	jsr FlipEnemyX
Enemy51_Sub1_NoFlip:
	;Set enemy grounded
	ldy #$00
	jmp HandleEnemyGroundCollision_NoClearY
Enemy51_Sub1_Next:
	;Set animation timer
	lda #$10
	sta Enemy_Temp1,x
	;Next task ($02: Stop)
	inc Enemy_Mode,x
	rts
Enemy51_Sub1_SetExplosion:
	;Next task ($00: Init)
	lda #$00
	sta Enemy_Mode,x
	;Clear enemy points value
	lda #ENEMY_MINOTAUR
	sta Enemy_Temp2,x
	lda #$FF
	sta Enemy_Temp5,x
	;Set enemy ID $01 (Explosion)
	lda #ENEMY_EXPLOSION
	sta Enemy_ID,x
	rts
;$02: Stop
Enemy51_Sub2:
	;Decrement timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy51_Sub2_Exit
	;Multiply enemy X velocity by 2
	asl Enemy_XVelLo,x
	rol Enemy_XVel,x
	;Next task ($03: Run)
	inc Enemy_Mode,x
Enemy51_Sub2_Exit:
	rts

;$52: Great Beast
Enemy52JumpTable:
	.dw Enemy52_Sub0	;$00  Init
	.dw Enemy52_Sub1	;$01  Fly
	.dw Enemy52_Sub2	;$02  Turn
;$00: Init
Enemy52_Sub0:
	;Set enemy X velocity to target player
	lda #$04
	jmp SetEnemyXVel
;$01: Fly
Enemy52_Sub1:
	;If enemy offscreen horizontally, skip this part
	lda Enemy_XHi+$08,x
	beq Enemy52_Sub1_CheckNext
	;Check to turn around
	eor Enemy_XVel,x
	bpl Enemy52_Sub1_Next
	bmi Enemy52_Sub1_NoNext
	;If enemy X position not $30-$CF, go to next task ($02: Turn)
Enemy52_Sub1_CheckNext:
	lda Enemy_X+$08,x
	clc
	adc #$30
	cmp #$60
	bcs Enemy52_Sub1_NoNext
	;Check to turn around
	lda Enemy_X+$08,x
	eor Enemy_XVel,x
	bpl Enemy52_Sub1_NoNext
Enemy52_Sub1_Next:
	;Save enemy X velocity
	lda Enemy_XVel,x
	sta Enemy_Temp2,x
	;Next task ($02: Turn)
	inc Enemy_Mode,x
Enemy52_Sub1_NoNext:
	;Check if animation timer 0
	lda Enemy_Temp1,x
	beq Enemy52_Sub1_CheckAttack
	;Decrement animation timer
	dec Enemy_Temp1,x
	jmp Enemy52_Sub1_NoAttack
Enemy52_Sub1_CheckAttack:
	;Check if player is in range
	ldy #$01
Enemy52_Sub1_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc Enemy52_Sub1_PlayerNext
	;If player Y position < enemy Y position, skip this part
	lda Enemy_Y,y
	sbc Enemy_Y+$08,x
	bcc Enemy52_Sub1_PlayerNext
	;If enemy offscreen horizontally, skip this part
	lsr
	lsr
	sta $00
	lda Enemy_XHi+$08,x
	bne Enemy52_Sub1_PlayerNext
	;Check if enemy is moving left or right
	lda Enemy_XVel,x
	asl
	bcs Enemy52_Sub1_CheckLeft
	;Get player X distance in front of enemy (right)
	sec
	lda Enemy_X,y
	sbc Enemy_X+$08,x
	bcc Enemy52_Sub1_PlayerNext
	bcs Enemy52_Sub1_CheckD
Enemy52_Sub1_CheckLeft:
	;Get player X distance in front of enemy (left)
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	bcc Enemy52_Sub1_PlayerNext
Enemy52_Sub1_CheckD:
	;If player X distance from enemy >= $10, skip this part
	adc #$0F
	ror
	sbc $00
	bcc Enemy52_Sub1_PlayerNext
	cmp #$20
	bcs Enemy52_Sub1_PlayerNext
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy52_Sub1_NoAttack
	;Set enemy ID $53 (Great Beast fire)
	lda #ENEMY_GREATBEASTFIRE
	sta Enemy_ID,x
	;Offset projectile Y position
	txa
	tay
	ldx CurEnemyIndex
	lda #$13
	jsr OffsetEnemyYPos
	;Offset projectile X position based on enemy facing direction
	lda Enemy_Props+$08,y
	cmp #$40
	lda #$14
	bcc Enemy52_Sub1_SetX
	lda #$EB
Enemy52_Sub1_SetX:
	sta $00
	adc Enemy_X+$08,y
	sta Enemy_X+$08,y
	lda #$00
	bit $00
	bpl Enemy52_Sub1_SetXHi
	lda #$FF
Enemy52_Sub1_SetXHi:
	adc Enemy_XHi+$08,y
	sta Enemy_XHi+$08,y
	;Set parent enemy slot index
	txa
	sta Enemy_Temp2,y
	;Set animation timer
	lda #$80
	sta Enemy_Temp1,x
	bne Enemy52_Sub1_NoAttack
Enemy52_Sub1_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy52_Sub1_PlayerLoop
Enemy52_Sub1_NoAttack:
	;Get enemy X velocity
	lda Enemy_XVel,x
	sta $12
	lda Enemy_XVelLo,x
	sta $11
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy X
	jsr MoveEnemyX
	;Check for wall collision
	ldy #$03
	jsr EnemyGetWallCollision_AnyY
	bcs Enemy52_Sub1_WallTop
	ldy #$04
	jsr EnemyGetWallCollision_AnyY
	bcc Enemy52_Sub1_NoWallBottom
Enemy52_Sub1_ClearY:
	;Clear enemy Y velocity
	lda #$00
	sta Enemy_YVel,x
	sta Enemy_YVelLo,x
	rts
Enemy52_Sub1_NoWallBottom:
	;If enemy Y position < $30, clear enemy Y velocity
	lda Enemy_Y+$08,x
	cmp #$30
	bcc Enemy52_Sub1_ClearY
	;Set enemy Y velocity up
	lda $12
	bmi Enemy52_Sub1_SetYUp
	cmp #$80
	lda #$00
	sbc $11
	sta $11
	lda #$00
	sbc $12
Enemy52_Sub1_SetYUp:
	sec
	ror
	sta Enemy_YVel,x
	lda $11
	ror
	sta Enemy_YVelLo,x
	;Move enemy Y
	jmp MoveEnemyY
Enemy52_Sub1_WallTop:
	;Set enemy Y velocity down
	lda $12
	bpl Enemy52_Sub1_SetYDown
	sec
	lda #$00
	sbc $11
	sta $11
	lda #$00
	sbc $12
Enemy52_Sub1_SetYDown:
	lsr
	sta Enemy_YVel,x
	lda $11
	ror
	sta Enemy_YVelLo,x
	;Move enemy Y
	jmp MoveEnemyY
;$02: Turn
Enemy52_Sub2:
	;Check if turning left or right
	lda Enemy_Temp2,x
	bpl Enemy52_Sub2_Left
	;Accelerate right
	clc
	lda Enemy_XVelLo,x
	adc #$08
	sta Enemy_XVelLo,x
	bcc Enemy52_Sub2_RightNoXC
	inc Enemy_XVel,x
Enemy52_Sub2_RightNoXC:
	;If enemy X velocity >= $0120, go to next task ($01: Fly)
	ldy Enemy_XVel,x
	cpy #$01
	bne Enemy52_Sub2_NoNext
	cmp #$20
	bcc Enemy52_Sub2_NoNext
	;Next task ($01: Fly)
	dec Enemy_Mode,x
Enemy52_Sub2_NoNext:
	;Set enemy props
	lda Enemy_XVel,x
	lsr
	and #$40
	sta Enemy_Props+$08,x
	jmp Enemy52_Sub1_NoNext
Enemy52_Sub2_Left:
	;Accelerate left
	sec
	lda Enemy_XVelLo,x
	sbc #$08
	sta Enemy_XVelLo,x
	bcs Enemy52_Sub2_LeftNoXC
	dec Enemy_XVel,x
Enemy52_Sub2_LeftNoXC:
	;If enemy X velocity < $FEE8, go to next task ($01: Fly)
	ldy Enemy_XVel,x
	cpy #$FE
	bne Enemy52_Sub2_NoNext
	cmp #$E8
	bcs Enemy52_Sub2_NoNext
	;Next task ($01: Fly)
	dec Enemy_Mode,x
	;Set enemy props
	lda Enemy_XVel,x
	lsr
	and #$40
	sta Enemy_Props+$08,x
	jmp Enemy52_Sub1_NoNext

;$53: Great Beast fire
Enemy53JumpTable:
	.dw Enemy53_Sub0	;$00  Init
	.dw Enemy53_Sub1	;$01  Main
	.dw Enemy53_Sub2	;$02  Land init
	.dw Enemy53_Sub3	;$03  Land
	.dw Enemy53_Sub4	;$04  End
;$00: Init
Enemy53_Sub0:
	;Set animation timer
	lda #$05
	sta Enemy_Temp1,x
	;Set enemy flags/sprite
	lda #(EF_NOHITATTACK|$02)
	sta Enemy_Flags,x
	lda #$92
	sta Enemy_Sprite+$08,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
	;Play sound
	lda #SE_GREATBEASTFIRE
	jmp LoadSound
;$01: Main
Enemy53_Sub1:
	;If bits 0-1 of global timer not 0, don't set enemy sprite
	lda GlobalTimer
	and #$03
	bne Enemy53_Sub1_NoSetSp
	;Set enemy sprite
	lda Enemy_Sprite+$08,x
	eor #$01
	sta Enemy_Sprite+$08,x
Enemy53_Sub1_NoSetSp:
	;If parent enemy not active, skip this part
	ldy Enemy_Temp2,x
	beq Enemy53_Sub1_NoP
	;Copy enemy X velocity from parent
	lda Enemy_XVel,y
	sta Enemy_XVel,x
	;If parent enemy turning around, clear parent enemy slot index
	lsr
	eor Enemy_Props+$08,x
	and #$40
	beq Enemy53_Sub1_NoClearP
	;Clear parent enemy slot index
	lda #$00
	sta Enemy_Temp2,x
Enemy53_Sub1_NoClearP:
	;Copy enemy velocity from parent
	lda Enemy_XVelLo,y
	sta Enemy_XVelLo,x
	lda Enemy_YVel,y
	sta Enemy_YVel,x
	lda Enemy_YVelLo,y
	sta Enemy_YVelLo,x
	;Move enemy
	jsr MoveEnemyXY
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy53_Sub1_Exit
	;If enemy sprite >= $A2, don't set enemy sprite
	lda Enemy_Sprite+$08,x
	clc
	adc #$02
	cmp #$A4
	bcs Enemy53_Sub1_Next
	;Set enemy sprite/position
	sta Enemy_Sprite+$08,x
Enemy53_Sub1_NoP:
	lda Enemy_Props+$08,x
	cmp #$40
	lda #$08
	ldy #$00
	bcc Enemy53_Sub1_Right
	lda #$F7
	dey
Enemy53_Sub1_Right:
	adc Enemy_X+$08,x
	sta Enemy_X+$08,x
	tya
	adc Enemy_XHi+$08,x
	sta Enemy_XHi+$08,x
	clc
	lda Enemy_Y+$08,x
	adc #$0D
	sta Enemy_Y+$08,x
	;If ground collision, go to next task ($02: Land init)
	ldy #$07
	jsr EnemyGetGroundCollision_AnyY
	bcs Enemy53_Sub1_Next
	;Set animation timer
	lda #$03
	sta Enemy_Temp1,x
Enemy53_Sub1_Exit:
	rts
Enemy53_Sub1_Next:
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	;Next task ($02: Land init)
	inc Enemy_Mode,x
	rts
;$02: Land init
Enemy53_Sub2:
	;If parent enemy not active, skip this part
	ldy Enemy_Temp2,x
	beq Enemy53_Sub2_Next
	;Copy enemy X velocity from parent
	lda Enemy_XVel,y
	sta Enemy_XVel,x
	;If parent enemy turning around, clear parent enemy slot index
	lsr
	eor #$40
	beq Enemy53_Sub2_NoClearP
	;Clear parent enemy slot index
	lda #$00
	sta Enemy_Temp2,x
Enemy53_Sub2_NoClearP:
	;Copy enemy velocity from parent
	lda Enemy_XVelLo,y
	sta Enemy_XVelLo,x
	lda Enemy_YVel,y
	sta Enemy_YVel,x
	lda Enemy_YVelLo,y
	sta Enemy_YVelLo,x
	;Move enemy
	jsr MoveEnemyXY
	;If bits 0-1 of global timer not 0, don't set enemy sprite
	lda GlobalTimer
	and #$03
	bne Enemy53_Sub2_NoSetSp
	;Set enemy sprite
	lda Enemy_Sprite+$08,x
	eor #$01
	sta Enemy_Sprite+$08,x
Enemy53_Sub2_NoSetSp:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy53_Sub1_Exit
Enemy53_Sub2_Next:
	;Next task ($03: Land)
	inc Enemy_Mode,x
	;Set animation timer
	lda #$01
	sta Enemy_Temp1,x
	rts
;$03: Land
Enemy53_Sub3:
	;If bits 0-1 of global timer not 0, don't set enemy sprite
	lda GlobalTimer
	and #$03
	bne Enemy53_Sub3_NoSetSp
	;Set enemy sprite
	lda Enemy_Sprite+$08,x
	eor #$01
	sta Enemy_Sprite+$08,x
Enemy53_Sub3_NoSetSp:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy53_Sub1_Exit
	;If enemy sprite < $94, clear enemy
	sec
	lda Enemy_Sprite+$08,x
	sbc #$02
	cmp #$92
	bcc Enemy53_Sub3_Clear
	;Set enemy sprite
	sta Enemy_Sprite+$08,x
	;Set animation timer
	lda #$03
	sta Enemy_Temp1,x
	rts
Enemy53_Sub3_Clear:
	;Clear enemy
	jmp ClearEnemy
;$04: End
Enemy53_Sub4:
	rts

;$56: Level 3 boss fade
Enemy56JumpTable:
	.dw Enemy56_Sub0	;$00  Fade out init part 1
	.dw Enemy56_Sub1	;$01  Fade out init part 2
	.dw Enemy56_Sub2	;$02  Fade out init part 3
	.dw Enemy56_Sub3	;$03  Fade out main
	.dw Enemy56_Sub4	;$04  Fade in init part 1
	.dw Enemy56_Sub5	;$05  Fade in init part 2
	.dw Enemy56_Sub6	;$06  Fade in main
	.dw Enemy56_Sub7	;$07  Fade in end

;$57: Level 4 boss fade
Enemy57JumpTable:
	.dw Enemy56_Sub0	;$00  Fade out init part 1
	.dw Enemy57_Sub1	;$01  Fade out init part 2
	.dw Enemy57_Sub2	;$02  Fade out init part 3
	.dw Enemy57_Sub3	;$03  Fade out main
	.dw Enemy56_Sub0	;$04  Fade in init part 1
	.dw Enemy56_Sub4	;$05  Fade in init part 2
	.dw Enemy57_Sub6	;$06  Fade in init part 3
	.dw Enemy57_Sub7	;$07  Fade in init part 4
	.dw Enemy56_Sub5	;$08  Fade in init part 5
	.dw Enemy56_Sub6	;$09  Fade in main
	.dw Enemy57_SubA	;$0A  Fade in end

;$00: Fade out init part 1
Enemy56_Sub0:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy56_Sub0_Exit
	;Set palette color mask
	lda #$FF
	sta $00
	;Fade out palette buffer data
	ldy #$02
Enemy56_Sub0_Loop:
	lda PaletteBuffer+$09,y
	sec
	sbc #$10
	bcs Enemy56_Sub0_NoSetBlack
	lda #$0F
Enemy56_Sub0_NoSetBlack:
	sta PaletteBuffer+$09,y
	and $00
	sta $00
	dey
	bpl Enemy56_Sub0_Loop
	;Set animation timer
	lda #$08
	sta Enemy_Temp1+$02
	;Check if all colors are completely faded in
	lda $00
	cmp #$0F
	bne Enemy56_Sub0_Exit
	;Next task ($01: Fade out init part 2)
	inc Enemy_Mode+$02
	;Set sprite boss mode flag
	dec SpriteBossModeFlag
Enemy56_Sub0_Exit:
	rts
;$01: Fade out init part 2
Enemy56_Sub1:
	;Init VRAM buffer RLE
	ldy VRAMBufferOffset
	lda #$03
	sta VRAMBuffer,y
	;Set VRAM buffer address
	lda Enemy_Temp2+$02
	sta VRAMBuffer+1,y
	lda #$21
	sta VRAMBuffer+2,y
	;Set clear tiles in VRAM
	lda #$20
	sta VRAMBuffer+3,y
	lda #$00
	sta VRAMBuffer+4,y
	;End VRAM buffer
	tya
	clc
	adc #$05
	sta VRAMBufferOffset
	;Increment VRAM buffer address
	lda Enemy_Temp2+$02
	adc #$20
	sta Enemy_Temp2+$02
	;Check for end of clear tiles
	bcc Enemy56_Sub1_Exit
	;Next task ($02: Fade out init part 3)
	inc Enemy_Mode+$02
Enemy56_Sub1_Exit:
	rts
;$02: Fade out init part 3
Enemy56_Sub2:
	;If not enough space in VRAM buffer, exit early
	lda VRAMBufferOffset
	cmp #$10
	bcs Enemy56_Sub0_Exit
	;Save VRAM buffer offset
	sta $17
	;Clear VRAM strip (level 3 boss)
	lda Enemy_Temp2+$02
	adc #$A5
	jsr WriteVRAMStrip
	;Init VRAM buffer column
	ldy $17
	lda #$02
	sta VRAMBuffer,y
	;Restore X register
	tax
	;Check for end of VRAM strips
	inc Enemy_Temp2+$02
	lda Enemy_Temp2+$02
	cmp #$03
	bcc Enemy56_Sub2_Exit
	;Reset fade timer
	lda #$00
	sta FadeTimer
	;Next task ($03: Fade out main)
	inc Enemy_Mode+$02
Enemy56_Sub2_Exit:
	rts
;$03: Fade out main
Enemy56_Sub3:
	;Reset fade timer
	lda #$00
	sta FadeTimer
	;Write enemy VRAM strip (level 3 boss)
	lda #$0A
	jsr WriteEnemyVRAMStrip38
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	bne Enemy56_Sub2_Exit
	;Set palette colors
	ldy #$02
Enemy56_Sub3_Loop:
	lda Level3BossPalette09Data,y
	sta PaletteBuffer+$09,y
	lda Level3BossPalette0DData,y
	sta PaletteBuffer+$0D,y
	dey
	bpl Enemy56_Sub3_Loop
	;Set enemy ID $3B (Level 3 boss)
	lda #ENEMY_LEVEL3BOSS
	sta Enemy_ID+$02
	;Set enemy flags
	lda #$0E
	sta Enemy_Flags+$02
	;Next task ($01: Wait)
	lda #$01
	sta Enemy_Mode+$02
	;Set animation timer
	lda #$40
	sta Enemy_Temp1+$02
	;Add IRQ buffer region (level 3 boss layer 1, boss rush)
	lda #$11
	jsr AddIRQBufferRegion
	;Add IRQ buffer region (level 3 boss layer 2, boss rush)
	lda #$12
	jmp AddIRQBufferRegion
Level3BossPalette09Data:
	.db $10,$20,$15
Level3BossPalette0DData:
	.db $1B,$10,$20
;$04: Fade in init part 1
Enemy56_Sub4:
	;Set palette colors
	lda #$0F
	sta PaletteBuffer+$09
	sta PaletteBuffer+$0A
	sta PaletteBuffer+$0B
	lda #$01
	sta PaletteBuffer+$0D
	lda #$11
	sta PaletteBuffer+$0E
	lda #$21
	sta PaletteBuffer+$0F
	;Next task ($05: Fade in init part 2)
	inc Enemy_Mode+$02
	;Clear VRAM buffer
	lda #$00
	sta VRAMBufferOffset
	;Clear scroll X position
	sta TempMirror_PPUSCROLL_X
	;Clear VRAM strip offset
	sta Enemy_Temp3+$02
	;Write palette
	jsr WritePalette
	;Load CHR bank
	lda #$64
	sta TempCHRBanks
	;Restore X register
	ldx #$02
Enemy56_Sub4_Exit:
	rts
;$05: Fade in init part 2
Enemy56_Sub5:
	;If not enough space in VRAM buffer, exit early
	lda VRAMBufferOffset
	cmp #$10
	bcs Enemy56_Sub4_Exit
	;Save VRAM buffer offset
	sta $17
	;Write VRAM strip (level 3 boss)
	lda Enemy_Temp3+$02
	adc #$25
	jsr WriteVRAMStrip
	;Set VRAM buffer address
	ldy $17
	lda CurScreenY
	lsr
	bcc Enemy56_Sub5_NoSetVRAM
	lda #$28
	sta VRAMBuffer+2,y
Enemy56_Sub5_NoSetVRAM:
	;Init VRAM buffer column
	lda #$02
	sta VRAMBuffer,y
	;Restore X register
	tax
	;Check for end of VRAM strips
	inc Enemy_Temp3+$02
	lda Enemy_Temp3+$02
	cmp #$03
	bcc Enemy56_Sub4_Exit
	;Set animation timer
	lda #$08
	sta Enemy_Temp1+$02
	;Next task ($06: Fade in main)
	inc Enemy_Mode+$02
	rts
;$06: Fade in main
Enemy56_Sub6:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1+$02
	bne Enemy56_Sub4_Exit
	;Clear collision buffer tiles
	ldy #$00
	sty CollisionBuffer+$47
	sty CollisionBuffer+$48
	sty CollisionBuffer+$49
	;Fade in palette buffer data
Enemy56_Sub6_Loop:
	lda PaletteBuffer+$09,y
	cmp #$0F
	bne Enemy56_Sub6_NoSetBlack
	lda #$F0
Enemy56_Sub6_NoSetBlack:
	clc
	adc #$10
	cmp Level3BossFadeInPalette09Data,y
	bcs Enemy56_Sub6_Next
	sta PaletteBuffer+$09,y
Enemy56_Sub6_Next:
	iny
	cpy #$03
	bcc Enemy56_Sub6_Loop
	;Set animation timer
	ldy #$08
	sty Enemy_Temp1+$02
	;Check if all colors are completely faded in
	cmp #$30
	bcc Enemy56_Sub4_Exit
	;Next task ($07: Fade in end)
	inc Enemy_Mode+$02
	rts
Level3BossFadeInPalette09Data:
	.db $01,$11,$21
;$07: Fade in end
Enemy56_Sub7:
	;Remove IRQ buffer region
	lda TempIRQBufferSub
	jsr RemoveIRQBufferRegion
	;Check for boss rush
	jmp CheckBossRush_SpawnElevator

;$01: Fade out init part 2
Enemy57_Sub1:
	;If not enough space in VRAM buffer, exit early
	lda VRAMBufferOffset
	cmp #$10
	bcs Enemy57_Sub1_Exit
	;Write enemy VRAM strip (level 6 elevator)
	lda #$01
	jsr WriteElevatorVRAMStrip38
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	bne Enemy57_Sub1_Exit
	;Set scroll lock settings
	sta TempScrollLockOther
	lda #$01
	sta TempScrollLockFlags
	;Set scroll Y position
	lda #$20
	sta TempMirror_PPUSCROLL_Y
	;Set fade timer
	lda #$08
	sta FadeTimer
	;Next task ($02: Fade out init part 3)
	inc Enemy_Mode+$02
Enemy57_Sub1_Exit:
	rts
;$02: Fade out init part 3
Enemy57_Sub2:
	;If not enough space in VRAM buffer, exit early
	lda VRAMBufferOffset
	cmp #$10
	bcs Enemy57_Sub1_Exit
	;Set elevator position
	lda #$98
	sta ElevatorYPos
	;Set HUD VRAM pointer
	lda #$22
	sta HUDVRAMPointer+1
	lda #$80
	sta HUDVRAMPointer
	;Write VRAM strip (level 6 elevator)
	lda #$23
	jsr WriteVRAMStrip
	;Next task ($03: Fade out main)
	inc Enemy_Mode+$02
	;Restore X register
	ldx #$02
	;Add IRQ buffer region (level 4 boss crane)
	lda #$0E
	jsr AddIRQBufferRegion
	;Move boss down $01
	inc TempIRQBufferHeight
	dec TempIRQBufferHeight+1
	rts
;$03: Fade out main
Enemy57_Sub3:
	;If not enough space in VRAM buffer, exit early
	lda VRAMBufferOffset
	cmp #$10
	bcs Enemy57_Sub1_Exit
	;Write enemy VRAM strip (level 4 boss)
	lda #$0B
	jsr WriteEnemyVRAMStrip38
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	bne Enemy57_Sub1_Exit
	;Reset path data index
	sta Enemy_Temp2+$02
	;Set scroll X position
	lda #$E8
	sta TempMirror_PPUSCROLL_X
	;Set scroll lock settings
	lda #$DE
	sta TempScrollLockOther
	;Set auto scroll flags/X velocity
	lda #$05
	sta AutoScrollDirFlags
	lda #$FE
	sta AutoScrollXVel
	;Load CHR bank
	lda #$58
	sta TempCHRBanks
	;Disable enemy scroll
	lda #$FF
	sta ScrollEnemyFlag
	;Set enemy Y position
	sta Enemy_YHi+$0A
	;Enable enemy subroutine while invincible
	lda #$80
	sta Enemy_Temp0+$02
	;Set enemy X position/props
	sta Enemy_X+$0A
	lsr
	sta Enemy_Props+$0A
	;Set enemy ID $39 (Level 4 boss)
	lda #ENEMY_LEVEL4BOSS
	sta Enemy_ID+$02
	;Set enemy flags
	lda #(EF_ALLOWOFFSCREEN|$01)
	sta Enemy_Flags+$02
	;Next task ($02: Offscreen Y)
	ldy #$02
	sty Enemy_Mode+$02
	;Set current X screen
	sty CurScreenX
	;Set palette colors
Enemy57_Sub3_Loop:
	lda Level4BossPalette09Data,y
	sta PaletteBuffer+$09,y
	lda Level4BossPalette1DData,y
	sta PaletteBuffer+$1D,y
	dey
	bpl Enemy57_Sub3_Loop
Enemy57_Sub3_Exit:
	rts
Level4BossPalette09Data:
	.db $00,$28,$37
Level4BossPalette1DData:
	.db $0B,$1B,$39
;$06: Fade in init part 3
Enemy57_Sub6:
	;If not enough space in VRAM buffer, exit early
	lda VRAMBufferOffset
	cmp #$10
	bcs Enemy57_Sub3_Exit
	;Write enemy VRAM strip (level 4 boss)
	lda #$0D
	jsr WriteEnemyVRAMStrip38
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	bne Enemy57_Sub3_Exit
	;Set scroll lock settings
	sta TempScrollLockOther
	;Set HUD VRAM pointer
	sta HUDVRAMPointer
	lda #$20
	sta HUDVRAMPointer+1
	;Set scroll Y position
	lsr
	sta TempMirror_PPUSCROLL_Y
	;Set timer
	lda #$03
	sta GameModeTimer
Enemy57_Sub6_Next:
	;Next task ($07: Fade in init part 4)
	inc Enemy_Mode+$02
	rts
;$07: Fade in init part 4
Enemy57_Sub7:
	;Decrement timer, check if 0
	dec GameModeTimer
	beq Enemy57_Sub6_Next
	rts
;$0A: Fade in end
Enemy57_SubA:
	;Set current X screen
	lda #$05
	sta CurScreenX
	;Remove IRQ buffer region
	lda TempIRQBufferSub
	jsr RemoveIRQBufferRegion
	;Enable enemy scroll
	lda #$00
	sta ScrollEnemyFlag
	;Clear elevator position
	sta ElevatorYPos
	;Clear scroll lock flags
	sta TempScrollLockFlags
	;Clear scroll Y position
	sta TempMirror_PPUSCROLL_Y
	;Check for boss rush
	jmp CheckBossRush_SpawnElevator

;;;;;;;;;;;;;;;;;
;VRAM STRIP DATA;
;;;;;;;;;;;;;;;;;
VRAMStrip25Data:
	.dw $2001
	.db $10,$10,$10,$17,$10,$10,$10,$10,$10,$17,$10,$10,$10,$10,$10,$1D
	.db $10,$10,$10,$3C,$40,$44
	.db $FF
VRAMStrip26Data:
	.dw $201E
	.db $0D,$0D,$0D,$14,$0D,$0D,$0D,$0D,$0D,$14,$0D,$0D,$0D,$0D,$0D,$1A
	.db $0D,$0D,$0D,$39,$3D,$41
	.db $FF
VRAMStrip27Data:
	.dw $201F
	.db $13,$0E,$0E,$18,$0E,$0E,$13,$0E,$0E,$15,$0E,$0E,$0E,$0E,$0E,$1B
	.db $37,$37,$37,$3A,$3E,$42
	.db $FF

;UNUSED SPACE
	;$2E bytes of free space available
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

	.org $C000
