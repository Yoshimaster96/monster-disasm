	.base $8000
	.org $8000
;BANK NUMBER
	.db $36

;;;;;;;;;;;;;;;;;;;;;;;;;
;PLAYER CONTROL ROUTINES;
;;;;;;;;;;;;;;;;;;;;;;;;;
HandlePlayerCollisionX:
	;Check if moving left or right
	ldy #$00
	lda PlayerXVel,x
	bpl HandlePlayerCollisionX_PosX
	iny
HandlePlayerCollisionX_PosX:
	;Get collision type top side
	sty $16
	lda PlayerCollisionXOffsLoTable,y
	clc
	adc Enemy_X,x
	sta $08
	lda #$00
	adc PlayerCollisionXOffsHiTable,y
	sta $09
	lda Enemy_Y,x
	sec
	sbc #$0D
	sta $0A
	lda Enemy_YHi,x
	sbc #$00
	sta $0B
	jsr GetCollisionType
	;Check for solid collision type
	cmp #$16
	bcs HandlePlayerCollisionX_Solid
	;Get collision type middle side
	lda Enemy_Y,x
	clc
	adc #$04
	sta $0A
	lda Enemy_YHi,x
	adc #$00
	sta $0B
	jsr GetCollisionType
	;Check for solid collision type
	cmp #$16
	bcs HandlePlayerCollisionX_Solid
	;Check for behind BG area
	jsr CheckBehindBGArea
	;Get collision type bottom side
	lda Enemy_Y,x
	clc
	adc #$15
	sta $0A
	lda Enemy_YHi,x
	adc #$00
	sta $0B
	jsr GetCollisionType
	;Check for solid collision type
	cmp #$16
	bcc HandlePlayerCollisionX_NoClearX
HandlePlayerCollisionX_Solid:
	;If solid collision type, clear player X velocity
	lda #$00
	sta PlayerXVel,x
	sta PlayerXVelLo,x
	rts
HandlePlayerCollisionX_NoClearX:
	;Set X movement direction
	inc $16
	lda $16
	sta $11,x
	;Check if on left or right side of screen
	ldy Enemy_X,x
	cpy #$80
	bcc HandlePlayerCollisionX_Left
	;Check if moving left while on left side of screen
	cmp #$01
	beq HandlePlayerCollisionX_SetScroll
	bne HandlePlayerCollisionX_Exit
HandlePlayerCollisionX_Left:
	;Check if moving right while on right side of screen
	cmp #$02
	bne HandlePlayerCollisionX_Exit
HandlePlayerCollisionX_SetScroll:
	;Set X scroll direction
	sta $13,x
HandlePlayerCollisionX_Exit:
	rts

HandleAutoScrollX:
	;Enable scrolling left/right
	lda LevelScrollFlags
	ora #$03
	sta LevelScrollFlags
	;Set X scroll velocity
	lda #$00
	sta $0C
	lda AutoScrollXVel
	sta $0D
	;Update player X scroll
	jsr UpdatePlayerScrollXSub
	;Handle player X collision/movement
	ldx #$01
HandleAutoScrollX_Loop:
	;If player not active, don't handle collision
	lda PlayerMode,x
	cmp #$03
	bne HandleAutoScrollX_Next
	;If player X velocity 0, don't handle collision
	lda PlayerXVel,x
	ora PlayerYVelLo,x
	beq HandleAutoScrollX_NoColl
	;Handle player X collision
	jsr HandlePlayerCollisionX
	;Move player
	jsr MovePlayerXVel
HandleAutoScrollX_NoColl:
	;Check for fixed camera
	lda AutoScrollDirFlags
	and #$30
	beq HandleAutoScrollX_Next
	;Move player
	jsr MoveOtherPlayerXScroll
HandleAutoScrollX_Next:
	;Loop for each player
	dex
	bpl HandleAutoScrollX_Loop
	;Handle player Y movement
	jmp HandlePlayerMovementY

PlayerCollisionXOffsLoTable:
	.db $0A,$F5
PlayerCollisionXOffsHiTable:
	.db $00,$FF

CheckBehindBGArea:
	;Check for behind BG area collision type
	cmp #$02
	bne CheckBehindBGArea_Front
	;Set player priority to be behind background
	lda Enemy_Props,x
	ora #$20
	sta Enemy_Props,x
	rts
CheckBehindBGArea_Front:
	;Set player priority to be in front of background
	lda Enemy_Props,x
	and #$DF
	sta Enemy_Props,x
	rts

HandlePlayerMovementX:
	;Save scroll position
	lda TempMirror_PPUSCROLL_X
	sta SaveScrollX
	lda TempMirror_PPUSCROLL_Y
	sta SaveScrollY
	;Clear player scroll velocity
	lda #$00
	sta ScrollPlayerXVel
	sta ScrollPlayerYVel
	;Clear scroll direction flags
	sta ScrollDirectionFlags
	;Clear movement/scroll direction
	sta $11
	sta $12
	sta $13
	sta $14
	;Get level scroll flags
	jsr GetLevelScrollFlags
	;Check for X autoscroll
	lda AutoScrollDirFlags
	and #$03
	bne HandleAutoScrollX
	;Handle player X collision/movement
	ldx #$01
HandlePlayerMovementX_CollLoop:
	;If player not active, skip this part
	lda PlayerMode,x
	cmp #$03
	bne HandlePlayerMovementX_NoColl
	;If player X velocity 0, skip this part
	lda PlayerXVel,x
	ora PlayerXVelLo,x
	beq HandlePlayerMovementX_NoColl
	;Handle player X collision/movement
	jsr HandlePlayerCollisionX
HandlePlayerMovementX_NoColl:
	;Loop for each player
	dex
	bpl HandlePlayerMovementX_CollLoop
	;Check if no players are scrolling
	lda $13
	ora $14
	beq HandlePlayerMovementX_NoDir
	;Check if players are scrolling in opposite directions
	cmp #$03
	beq HandlePlayerMovementX_NoDir
	;Check if players are scrolling in same direction
	lda $13
	eor $14
	beq HandlePlayerMovementX_SameDir
	;Find which player is scrolling
	sta $16
	ldx #$01
	lda $14
	beq HandlePlayerMovementX_P1Scroll
	dex
HandlePlayerMovementX_P1Scroll:
	;Check if non-scrolling player is active
	lda PlayerMode,x
	cmp #$03
	bne HandlePlayerMovementX_1P
	;Move non-scrolling player
	jsr MovePlayerXVel_CheckDir
	;Check which direction player is scrolling
	ldy Enemy_X,x
	lda $16
	and #$01
	bne HandlePlayerMovementX_CheckOtherLeft
	;Check if player scrolling left while other player on right side of screen
	cpy #$F0
	bcs HandlePlayerMovementX_OtherEdge
	bcc HandlePlayerMovementX_OtherMid
HandlePlayerMovementX_CheckOtherLeft:
	;Check if player scrolling right while other player on left side of screen
	cpy #$10
	bcc HandlePlayerMovementX_OtherEdge
HandlePlayerMovementX_OtherMid:
	;Move scrolling player
	txa
	eor #$01
	tax
	jsr UpdatePlayerScrollX
	;Move non-scrolling player
	txa
	eor #$01
	tax
	jsr MoveOtherPlayerXScroll
	;Handle player Y movement
	jmp HandlePlayerMovementY
HandlePlayerMovementX_1P:
	;Move player
	txa
	eor #$01
	tax
	jsr UpdatePlayerScrollX
	;Handle player Y movement
	jmp HandlePlayerMovementY
HandlePlayerMovementX_OtherEdge:
	;Move scrolling player
	txa
	eor #$01
	tax
	jsr MovePlayerXVel_CheckDir
	;Handle player Y movement
	jmp HandlePlayerMovementY
HandlePlayerMovementX_NoDir:
	;Move both players
	ldx #$01
HandlePlayerMovementX_NoDirLoop:
	jsr MovePlayerXVel_CheckDir
	dex
	bpl HandlePlayerMovementX_NoDirLoop
	;Handle player Y movement
	jmp HandlePlayerMovementY
HandlePlayerMovementX_CheckSameVel:
	;Check if players have same X velocity
	ldy PlayerXVelLo
	cpy PlayerXVelLo+1
	beq HandlePlayerMovementX_SameVel
	;Check which player is faster
	bcc HandlePlayerMovementX_DiffVelRight
	bcs HandlePlayerMovementX_DiffVelLeft
HandlePlayerMovementX_SameDir:
	;Check if players have same X velocity
	lda $13
	ldy PlayerXVel
	cpy PlayerXVel+1
	beq HandlePlayerMovementX_CheckSameVel
	;Check which player is faster
	bcc HandlePlayerMovementX_DiffVelRight
HandlePlayerMovementX_DiffVelLeft:
	;Check which player is faster (left)
	and #$01
	jmp HandlePlayerMovementX_DiffVel
HandlePlayerMovementX_DiffVelRight:
	;Check which player is faster (right)
	and #$02
	lsr
HandlePlayerMovementX_DiffVel:
	;Move faster player
	tax
	jsr MovePlayerXVel_CheckDir
	;Move both players
	jmp HandlePlayerMovementX_OtherMid
HandlePlayerMovementX_SameVel:
	;Move both players
	ldx #$00
	jsr UpdatePlayerScrollX
	ldx #$01
	jsr MovePlayerXScroll
	;Handle player Y movement
	jmp HandlePlayerMovementY

MoveOtherPlayerXScroll:
	;Move other player X based on scroll velocity
	lda Enemy_X,x
	sec
	sbc ScrollPlayerXVel
	sta Enemy_X,x
	rts

MovePlayerXVel_CheckDir:
	;If not moving left or right, exit early
	lda $11,x
	beq MovePlayerXVel_Exit

MovePlayerXVel:
	;Check if moving left or right
	lda Enemy_X,x
	ldy PlayerXVel,x
	bpl MovePlayerXVel_PosX
	;If moving left while on left side of screen, exit early
	cmp #$10
	bcc MovePlayerXVel_Exit
	bcs MovePlayerXVel_AddPos
MovePlayerXVel_PosX:
	;If moving right while on right side of screen, exit early
	cmp #$F0
	bcs MovePlayerXVel_Exit
MovePlayerXVel_AddPos:
	;Apply player X velocity
	lda PlayerXLo,x
	clc
	adc PlayerXVelLo,x
	sta PlayerXLo,x
	lda Enemy_X,x
	adc PlayerXVel,x
	sta Enemy_X,x
MovePlayerXVel_Exit:
	rts

MovePlayerXScroll:
	;Check if moving left or right
	lda Enemy_X,x
	ldy $0D
	bpl MovePlayerXScroll_PosX
	;If moving left while on left side of screen, exit early
	cmp #$10
	bcc MovePlayerXScroll_Exit
	bcs MovePlayerXScroll_AddPos
MovePlayerXScroll_PosX:
	;If moving right while on right side of screen, exit early
	cmp #$F0
	bcs MovePlayerXScroll_Exit
MovePlayerXScroll_AddPos:
	;Apply scroll X velocity
	lda PlayerXLo,x
	clc
	adc $0C
	sta PlayerXLo,x
	lda Enemy_X,x
	adc $0D
	sta Enemy_X,x
MovePlayerXScroll_Exit:
	rts

UpdatePlayerScrollX:
	;Get player velocity
	lda PlayerXVelLo,x
	sta $0C
	lda PlayerXVel,x
	sta $0D
	;Update player X scroll
	jsr UpdatePlayerScrollXSub
	;Check for level bounds
	lda $00
	beq MovePlayerXScroll_Exit
	;Move player
	jmp MovePlayerXScroll

UpdatePlayerScrollXSub_Bound:
	;Set level bounds flag
	inc $00
	rts
UpdatePlayerScrollXSub:
	;Clear level bounds flag
	lda #$00
	sta $0E
	sta $00
	;Check if moving left or right
	lda LevelScrollFlags
	ldy $0D
	bpl UpdatePlayerScrollXSub_PosX
	;Check if left scrolling is enabled
	and #$02
	beq UpdatePlayerScrollXSub_Bound
	dec $0E
	jmp UpdatePlayerScrollXSub_AddPos
UpdatePlayerScrollXSub_PosX:
	;Check if right scrolling is enabled
	and #$01
	beq UpdatePlayerScrollXSub_Bound
UpdatePlayerScrollXSub_AddPos:
	;Apply scroll X velocity
	lda ScrollXPosLo
	clc
	adc $0C
	sta ScrollXPosLo
	lda TempMirror_PPUSCROLL_X
	adc $0D
	sta TempMirror_PPUSCROLL_X
	lda CurScreenX
	adc $0E
	sta CurScreenX
	;Check for left level bounds
	bmi UpdatePlayerScrollXSub_BoundL
	;Check if moving left or right
	lda $0D
	bmi UpdatePlayerScrollXSub_Left
	;Check for right level bounds
	lda #$FF
	clc
	adc TempMirror_PPUSCROLL_X
	lda #$00
	adc CurScreenX
	sta $1B
	cmp LevelAreaWidth
	bcs UpdatePlayerScrollXSub_BoundR
	;Get level layout flags for right screen
	lda CurScreenY
	sta $1A
	jsr GetLevelLayoutFlags
	;Check for right level bounds
	bmi UpdatePlayerScrollXSub_BoundR
	;Check for bottom screen
	and #$40
	beq UpdatePlayerScrollXSub_NoBound
	;Check for top of bottom screen
	lda TempMirror_PPUSCROLL_Y
	beq UpdatePlayerScrollXSub_NoBound
	bne UpdatePlayerScrollXSub_BoundR
UpdatePlayerScrollXSub_Left:
	;Get level layout flags for left screen
	jsr GetCurrentScreen
	;Check for left level bounds
	bmi UpdatePlayerScrollXSub_BoundL
	;Check for bottom screen
	and #$40
	beq UpdatePlayerScrollXSub_NoBound
	;Check for top of bottom screen
	lda TempMirror_PPUSCROLL_Y
	beq UpdatePlayerScrollXSub_NoBound
UpdatePlayerScrollXSub_BoundL:
	;Adjust X scroll position for left level bounds
	inc CurScreenX
UpdatePlayerScrollXSub_BoundR:
	;Adjust X scroll position for right level bounds
	lda ScrollXPosLo
	sta $0C
	lda TempMirror_PPUSCROLL_X
	sta $0D
	inc $00
	;Set level bounds flag
	lda #$00
	sta TempMirror_PPUSCROLL_X
	sta ScrollXPosLo
	beq UpdatePlayerScrollXSub_CheckDir
UpdatePlayerScrollXSub_NoBound:
	;Clear X scroll adjustment
	lda #$00
	sta $0C
	sta $0D
UpdatePlayerScrollXSub_CheckDir:
	;Set X scroll velocity
	ldy #$01
	lda TempMirror_PPUSCROLL_X
	sec
	sbc SaveScrollX
	sta ScrollPlayerXVel
	;If scroll X velocity 0, exit early
	beq UpdatePlayerScrollXSub_Exit
	;Check if scrolling left or right
	bpl UpdatePlayerScrollXSub_SetDir
	ldy #$02
UpdatePlayerScrollXSub_SetDir:
	;Set X scroll direction
	sty ScrollDirectionFlags
	sta ScrollPlayerXVel
	;Update X tile scroll position
	lda ScrollPlayerXVel
	clc
	adc ScrollXTilePos
	sta ScrollXTilePos
	;Update X collision scroll position
	lda ScrollPlayerXVel
	clc
	adc ScrollXCollPosLo
	sta ScrollXCollPosLo
UpdatePlayerScrollXSub_Exit:
	rts

GetCurrentScreen:
	;Get current screen
	lda CurScreenY
	sta $1A
	lda CurScreenX
	sta $1B

GetLevelLayoutFlags:
	;Get level layout flags pointer
	lda LevelAreaNum
	asl
	tay
	lda LevelLayoutPointerTable,y
	sta $18
	lda LevelLayoutPointerTable+1,y
	sta $19
	lda #$00
	ldy $1A
	clc
	beq GetLevelLayoutFlags_Y0
GetLevelLayoutFlags_Loop:
	adc LevelAreaWidth
	dey
	bne GetLevelLayoutFlags_Loop
GetLevelLayoutFlags_Y0:
	adc $1B
	tay
	;Get level layout flags bits
	lda ($18),y
	rts

GetLevelScrollFlags:
	;Get level scroll flags pointer
	lda LevelAreaNum
	asl
	tay
	lda LevelScrollPointerTable,y
	sta $1C
	lda LevelScrollPointerTable+1,y
	sta $1D
	lda LevelAreaWidth
	lsr
	sta $1E
	bcc GetLevelScrollFlags_NoXC
	inc $1E
GetLevelScrollFlags_NoXC:
	lda TempMirror_PPUSCROLL_X
	adc #$80
	lda CurScreenX
	adc #$00
	sta $07
	lsr
	sta $1F
	lda TempMirror_PPUSCROLL_Y
	adc #$B0
	lda CurScreenY
	adc #$00
	clc
	tay
	beq GetLevelScrollFlags_Y0
	lda #$00
GetLevelScrollFlags_Loop:
	adc $1E
	dey
	bne GetLevelScrollFlags_Loop
GetLevelScrollFlags_Y0:
	adc $1F
	tay
	;Get level scroll flags mask
	lda ($1C),y
	lsr $07
	bcs GetLevelScrollFlags_MaskLo
	lsr
	lsr
	lsr
	lsr
GetLevelScrollFlags_MaskLo:
	;Get level scroll flags bits
	and #$0F
	sta LevelScrollFlags
	rts

ControlPlayer:
	;Do tasks for both players
	ldx #$01
ControlPlayer_Loop:
	;Handle player mode
	jsr HandlePlayerMode
	;Loop for each player
	dex
	bpl ControlPlayer_Loop
	;Do tasks
	jsr HandlePlayerMovementX
	jsr HandlePlayerAttack
	;Do tasks for both players
	ldx #$01
ControlPlayer_Loop2:
	;If player grounded, clear player Y velocity
	lda PlayerCollTypeBottom,x
	cmp #$03
	bcc ControlPlayer_NoLand
	;Clear player Y velocity
	lda #$00
	sta PlayerYVel,x
	sta PlayerYVelLo,x
ControlPlayer_NoLand:
	;If player active, update key
	lda PlayerMode,x
	cmp #$03
	bcc ControlPlayer_NoKey
	;Update key
	jsr UpdateKey
ControlPlayer_NoKey:
	;Update player respawn
	jsr UpdatePlayerRespawn
	;Loop for each player
	dex
	bpl ControlPlayer_Loop2
	rts

UpdateKey:
	;If key not active, exit early
	lda PlayerKeyFlags,x
	and #$05
	beq UpdateKey_Exit
	;Get key index
	and #$01
	tay
	sty $10
	;Set enemy props
	lda Enemy_Props,x
	and #$E0
	sta Enemy_Props+$08,y
	;Check if player is ducking
	lda #$F4
	ldy PlayerState,x
	cpy #$06
	beq UpdateKey_Duck
	cpy #$07
	beq UpdateKey_Duck
	lda #$E8
UpdateKey_Duck:
	;Set enemy position
	ldy $10
	clc
	adc Enemy_Y,x
	sta Enemy_Y+$08,y
	lda Enemy_YHi,x
	adc #$FF
	sta Enemy_YHi+$08,y
	lda Enemy_X,x
	sta Enemy_X+$08,y
	lda Enemy_XHi,x
	sta Enemy_XHi+$08,y
UpdateKey_Exit:
	rts

UpdatePlayerRespawn:
	;Check if player on platform
	lda PlayerPlatformFlag,x
	bne UpdatePlayerRespawn_Plat
	;Check if scrolling left or right
	lda #$00
	ldy ScrollPlayerXVel
	bpl UpdatePlayerRespawn_PosX
	lda #$FF
UpdatePlayerRespawn_PosX:
	sta $10
	;Set player respawn X position
	lda PlayerRespawnX,x
	sec
	sbc ScrollPlayerXVel
	sta PlayerRespawnX,x
	lda PlayerRespawnXHi,x
	sbc $10
	sta PlayerRespawnXHi,x
	;Check if scrolling up or down
	lda ScrollPlayerYVel
	bpl UpdatePlayerRespawn_Down
	;Set player respawn Y position (up)
	lda PlayerRespawnY,x
	sec
	sbc ScrollPlayerYVel
	cmp #$F0
	bcc UpdatePlayerRespawn_UpNoYC
	adc #$0F
	inc PlayerRespawnYHi,x
UpdatePlayerRespawn_UpNoYC:
	sta PlayerRespawnY,x
	rts
UpdatePlayerRespawn_Plat:
	;If platform active, exit early
	ldy PlayerPlatformIndex,x
	lda Enemy_ID,y
	bmi UpdatePlayerRespawn_Exit
	;Set player respawn position
	lda #$80
	sta PlayerRespawnXHi,x
	;Clear on platform flag
	lda #$00
	sta PlayerPlatformFlag,x
UpdatePlayerRespawn_Exit:
	rts
UpdatePlayerRespawn_Down:
	;Set player respawn Y position (down)
	lda PlayerRespawnY,x
	sec
	sbc ScrollPlayerYVel
	bcs UpdatePlayerRespawn_DownNoYC
	sbc #$0F
	dec PlayerRespawnYHi,x
UpdatePlayerRespawn_DownNoYC:
	sta PlayerRespawnY,x
	rts

PlayerAttackSpriteTable:
	.db $42,$7A
	.db $43,$7B
	.db $44,$7C
	.db $45,$7D
	.db $46,$7E
UpdatePlayerAttackAnimation:
	;Clear animation timer
	lda #$00
	sta PlayerAttackAnimTimer,x
	;Set player attack sprite based on animation offset
	lda PlayerAttackAnimOffs,x
	asl
	sta $10
	ldy $11
	lda PlayerCharacter,y
	ora $10
	tay
	lda PlayerAttackSpriteTable-2,y
	sta Enemy_Sprite+$02,x
	rts

HandlePlayerAttack:
	;Handle player attacks
	ldx #$05
HandlePlayerAttack_Loop:
	;Check if player attack is active
	lda PlayerAttackAnimOffs,x
	bne HandlePlayerAttack_NoNext
	jmp HandlePlayerAttack_Next
HandlePlayerAttack_NoNext:
	;Get player index for attack
	ldy #$00
	cpx #$03
	bcc HandlePlayerAttack_P1
	iny
HandlePlayerAttack_P1:
	sty $11
	;Check if animation frame >= $04
	and #$0F
	cmp #$04
	bcc HandlePlayerAttack_NoFrame4
	jmp HandlePlayerAttack_Frame4
HandlePlayerAttack_NoFrame4:
	;Check if player is frozen
	lda PlayerFreezeTimer,y
	beq HandlePlayerAttack_NoFreeze
	;Set player attack frozen flag
	lda PlayerAttackAnimOffs,x
	ora #$80
	sta PlayerAttackAnimOffs,x
	;Set player attack props
	lda Enemy_Props+$02,x
	ora #$03
	sta Enemy_Props+$02,x
	jmp HandlePlayerAttack_Next
HandlePlayerAttack_NoFreeze:
	;Set player attack props
	lda Enemy_Props+$02,x
	and #$F0
	sta Enemy_Props+$02,x
	;Increment animation timer, check if >= $04
	inc PlayerAttackAnimTimer,x
	lda PlayerAttackAnimTimer,x
	cmp #$04
	bcc HandlePlayerAttack_NoAnim
	;Update player attack animation
	jsr UpdatePlayerAttackAnimation
	;Check if player is ducking
	lda PlayerAttackDuckFlag,x
	beq HandlePlayerAttack_NoDuck
	lda #$08
HandlePlayerAttack_NoDuck:
	;Set player attack Y offset
	sta PlayerAttackYOffs,x
	;Check if player is facing left or right
	ldy $11
	lda #$00
	sta $10
	lda Enemy_Props,y
	and #$40
	beq HandlePlayerAttack_Left
	;Set player attack props (right)
	ora Enemy_Props+$02,x
	sta Enemy_Props+$02,x
	inc $10
	bne HandlePlayerAttack_SetPos
HandlePlayerAttack_Left:
	;Set player attack props (left)
	lda Enemy_Props+$02,x
	and #$BF
	sta Enemy_Props+$02,x
HandlePlayerAttack_SetPos:
	;Set player attack X offset
	lda PlayerAttackDuckFlag,x
	asl
	ora $10
	tay
	lda PlayerAttackXOffsTable,y
	sta PlayerAttackXOffs,x
	lda PlayerAttackXOffsHiTable,y
	sta PlayerAttackXOffsHi,x
	;Increment animation offset
	inc PlayerAttackAnimOffs,x
HandlePlayerAttack_NoAnim:
	;Set player attack position
	ldy $11
	lda Enemy_Y,y
	clc
	adc PlayerAttackYOffs,x
	sta Enemy_Y+$02,x
	lda Enemy_YHi,y
	adc #$00
	sta Enemy_YHi+$02,x
	lda Enemy_X,y
	clc
	adc PlayerAttackXOffs,x
	sta Enemy_X+$02,x
	lda Enemy_XHi,y
	adc PlayerAttackXOffsHi,x
	sta Enemy_XHi+$02,x
	jmp HandlePlayerAttack_Next
HandlePlayerAttack_Frame4:
	;Increment animation timer, check if >= $06
	inc PlayerAttackAnimTimer,x
	lda PlayerAttackAnimTimer,x
	cmp #$06
	bcc HandlePlayerAttack_NoFrame4Anim
	;Check for end of animation
	lda PlayerAttackAnimOffs,x
	and #$0F
	cmp #$06
	bcc HandlePlayerAttack_NoAnimEnd
	;Clear player attack animation
	lda #$00
	sta PlayerAttackAnimOffs,x
	sta PlayerAttackDuckFlag,x
	sta Enemy_Sprite+$02,x
	beq HandlePlayerAttack_Next
HandlePlayerAttack_NoAnimEnd:
	;Update player attack animation
	jsr UpdatePlayerAttackAnimation
	;Increment animation offset
	inc PlayerAttackAnimOffs,x
HandlePlayerAttack_NoFrame4Anim:
	;Check if enemy scroll is enabled
	lda ScrollEnemyFlag
	beq HandlePlayerAttack_Scroll
	jmp HandlePlayerAttack_Next
HandlePlayerAttack_Scroll:
	;Check if scrolling left or right
	lda #$00
	sta $10
	lda ScrollPlayerXVel
	bpl HandlePlayerAttack_Frame4SetPos
	dec $10
HandlePlayerAttack_Frame4SetPos:
	;Set player attack X position
	lda Enemy_X+$02,x
	sec
	sbc ScrollPlayerXVel
	sta Enemy_X+$02,x
	lda Enemy_XHi+$02,x
	sbc $10
	sta Enemy_XHi+$02,x
	;Check if scrolling up or down
	lda ScrollPlayerYVel
	bmi HandlePlayerAttack_Up
	;Set player attack Y position (down)
	lda Enemy_Y+$02,x
	sec
	sbc ScrollPlayerYVel
	bcs HandlePlayerAttack_DownNoYC
	sbc #$0F
	dec Enemy_YHi+$02,x
HandlePlayerAttack_DownNoYC:
	sta Enemy_Y+$02,x
	jmp HandlePlayerAttack_Next
HandlePlayerAttack_Up:
	;Set player attack Y position (up)
	lda Enemy_Y+$02,x
	sec
	sbc ScrollPlayerYVel
	bcs HandlePlayerAttack_UpNoYC
	cmp #$F0
	bcc HandlePlayerAttack_SetY
HandlePlayerAttack_UpNoYC:
	adc #$0F
	inc Enemy_YHi+$02,x
HandlePlayerAttack_SetY:
	sta Enemy_Y+$02,x
HandlePlayerAttack_Next:
	;Loop for each player attack
	dex
	bmi HandlePlayerAttack_Exit
	jmp HandlePlayerAttack_Loop
HandlePlayerAttack_Exit:
	rts
PlayerAttackXOffsTable:
	.db $18,$E8
	.db $10,$F0
PlayerAttackXOffsHiTable:
	.db $00,$FF
	.db $00,$FF

HandlePlayerMode:
	;Do jump table
	lda PlayerMode,x
	jsr DoJumpTable
PlayerModeJumpTable:
	.dw PlayerModeSub0	;$00  Init
	.dw PlayerModeSub1	;$01  Continue
	.dw PlayerModeSub2	;$02  Respawn
	.dw PlayerModeSub3	;$03  Main
	.dw PlayerModeSub4	;$04  Death

;$04: Death
PlayerModeSub4:
	;Decrement respawn timer, check if 0
	dec PlayerStateTimer,x
	bne HandlePlayerDeath_Exit

HandlePlayerDeath:
	;Clear player state
	jsr ClearPlayer_Death
	;Check if player HP 0
	lda PlayerHP,x
	bne HandlePlayerDeath_NoDecL
	;Decrement player lives, check if 0
	dec PlayerLives,x
	beq HandlePlayerDeath_Continue
	;Reset player HP
	lda #$05
	sta PlayerHP,x
HandlePlayerDeath_NoDecL:
	;Next mode ($02: Respawn)
	lda #$02
	sta PlayerMode,x
HandlePlayerDeath_Exit:
	rts
HandlePlayerDeath_Continue:
	;Next mode ($01: Continue)
	lda #$01
	sta PlayerMode,x
	rts

ClearPlayer:
	;Clear player state
	lda #$00
	sta Enemy_Props,x
	sta PlayerMode,x
	sta PlayerKeyFlags,x
	sta PlayerScoreLo,x
	sta PlayerScoreMid,x
ClearPlayer_Death:
	lda #$00
	sta PlayerRespawnStartFlag,x
ClearPlayer_NoFirst:
	lda #$00
	sta PlayerStateMode,x
	sta Enemy_XHi,x
	sta Enemy_YHi,x
	sta PlayerState,x
	sta PlayerAnimTimer,x
	sta PlayerAnimOffs,x
	sta PlayerPowLo,x
	sta PlayerPowHi,x
	sta PlayerCollTypeBottom,x
	sta PlayerSprite,x
	sta Enemy_Sprite,x
	sta PlayerJumpDownTimer,x
	sta PlayerAnimation,x
	sta PlayerXVel,x
	sta PlayerXVelLo,x
	sta PlayerYVel,x
	sta PlayerYVelLo,x
	sta PlayerFreezeTimer,x
	sta PlayerHitFlags,x
	sta PlayerJumpFallFlag,x
	sta PlayerJumpYPos,x
	rts

;$03: Main
PlayerModeSub3:
	;Handle player state
	jsr HandePlayerState
	;If player frozen, exit early
	lda PlayerFreezeTimer,x
	beq PlayerModeSub3_NoFreeze
	rts
PlayerModeSub3_NoFreeze:
	;Update player animation
	jsr UpdatePlayerAnimation
	;If invincibility timer not 0, decrement and check for visibility
	lda PlayerInvinTimer,x
	beq PlayerModeSub3_NoInvin
	;Decrement invincibility timer
	dec PlayerInvinTimer,x
	;If bit 0 of invincibility timer 0, clear player sprite
	and #$01
	bne PlayerModeSub3_NoInvin
	sta Enemy_Sprite,x
	beq PlayerModeSub3_NoSetSprite
PlayerModeSub3_NoInvin:
	;Set player sprite
	lda PlayerSprite,x
	sta Enemy_Sprite,x
PlayerModeSub3_NoSetSprite:
	;If player Y velocity $03, skip this part
	lda PlayerYVel,x
	cmp #$03
	beq PlayerModeSub3_NoGravity
	;If player grounded, skip this part
	lda PlayerCollTypeBottom,x
	cmp #$03
	bcs PlayerModeSub3_NoGravity
	;Accelerate due to gravity
	lda PlayerYVelLo,x
	clc
	adc #$40
	sta PlayerYVelLo,x
	bcc PlayerModeSub3_NoGravity
	inc PlayerYVel,x
PlayerModeSub3_NoGravity:
	;Handle player Y collision
	jmp HandlePlayerCollisionY

DropKey:
	;Check if key is active
	lda PlayerKeyFlags,x
	and #$05
	beq DropKey_NoKey
	;Get key enemy slot index
	and #$01
	tay
	;Next task ($03: Release)
	lda #$03
	sta Enemy_Mode,y
	;Set key Y velocity
	lda #$FE
	sta Enemy_YVel,x
	lda #$80
	sta PlayerKeyPower,y
	lda #$00
	sta Enemy_YVelLo,x
	;Check if player is facing left or right
	sty $10
	ldy #$00
	lda Enemy_Props,x
	and #$40
	beq DropKey_Right
	iny
	iny
DropKey_Right:
	;Set key X velocity
	lda DropKeyXVelTable,y
	sta $11
	lda DropKeyXVelTable+1,y
	ldy $10
	sta Enemy_XVelLo,y
	lda $11
	sta Enemy_XVel,y
	;Clear enemy offscreen flag
	lda Enemy_Flags,y
	and #~EF_ALLOWOFFSCREEN
	sta Enemy_Flags,y
DropKey_NoKey:
	;Clear key flags
	lda #$00
	sta PlayerKeyFlags,x
	rts
DropKeyXVelTable:
	.db $FE,$80
	.db $01,$80

HandePlayerState_Freeze:
	;If player freeze timer >= $60, don't play sound
	lda PlayerFreezeTimer,x
	cmp #$60
	bcs HandePlayerState_NoFreezeSound
	;Check for level 5 boss
	lda Enemy_ID+$02
	cmp #ENEMY_LEVEL5BOSS
	beq HandePlayerState_Load59
	;Play sound
	lda #SE_PLAYERFREEZE
	bne HandePlayerState_SetFreezeSound
HandePlayerState_Load59:
	;Play sound
	lda #SE_PLAYERFREEZE2
HandePlayerState_SetFreezeSound:
	jsr LoadSound
HandePlayerState_NoFreezeSound:
	;Set player freeze timer
	lda #$FE
	sta PlayerFreezeTimer,x
	;Set player props
	lda Enemy_Props,x
	ora #$03
	sta Enemy_Props,x
	;Clear player velocity
	lda #$00
	sta PlayerXVel,x
	sta PlayerXVelLo,x
	sta PlayerYVel,x
	sta PlayerYVelLo,x
	rts
PlayerHurtSndEffTable:
	.db DMC_VAMPIREHURT
	.db DMC_MONSTERHURT

HandePlayerState:
	;Check for death state
	lda PlayerState,x
	cmp #$0B
	bne HandePlayerState_NoDeath
	jmp HandePlayerState_JT
HandePlayerState_NoDeath:
	;If player Y position < $D0, skip this part
	lda Enemy_YHi,x
	bmi HandePlayerState_NoFall
	lda Enemy_Y,x
	cmp #$D0
	bcc HandePlayerState_NoFall
	;Play sound based on player character
	ldy PlayerCharacter,x
	lda PlayerHurtSndEffTable,y
	jsr LoadSound
	;Drop key
	jsr DropKey
	;Check for bottom screen
	lda TempMirror_PPUSCROLL_Y
	bne HandePlayerState_NoBottom
	jsr GetCurrentScreen
	and #$40
	beq HandePlayerState_NoBottom
	;Clear player HP
	lda #$00
	sta PlayerHP,x
	;Respawn player
	jmp SetPlayerRespawn
HandePlayerState_NoBottom:
	;If player HP 0, respawn player
	lda PlayerHP,x
	beq HandePlayerState_Respawn
	;Decrement player HP
	dec PlayerHP,x
HandePlayerState_Respawn:
	;Respawn player
	jmp SetPlayerRespawn
HandePlayerState_NoFall:
	;If invincibility timer not 0, skip this part
	lda PlayerInvinTimer,x
	bne HandePlayerState_Invin
	;Check for hurt collision type
	lda PlayerCollTypeBottom,x
	cmp #$1B
	beq HandePlayerState_Hurt
	;Check for enemy collision
	lda PlayerHitFlags,x
	and #$0F
	beq HandePlayerState_Invin
	;Check to freeze player
	cmp #$02
	bne HandePlayerState_Hurt
	jmp HandePlayerState_Freeze
HandePlayerState_Hurt:
	;If boss death sound playing, don't play sound
	lda BossDeathSoundFlag
	bne HandePlayerState_NoHurtSound
	;Play sound based on player character
	ldy PlayerCharacter,x
	lda PlayerHurtSndEffTable,y
	jsr LoadSound
HandePlayerState_NoHurtSound:
	;Decrement player HP
	dec PlayerHP,x
	;Set invincibility timer
	lda #$90
	sta PlayerInvinTimer,x
	;Drop key
	jsr DropKey
	;Next mode ($0A: Hurt)
	lda #$0A
	jsr SetPlayerState
	;Clear player freeze timer
	sta PlayerFreezeTimer,x
	beq HandePlayerState_Flash
HandePlayerState_Invin:
	;If player not frozen, skip this part
	lda PlayerFreezeTimer,x
	beq HandePlayerState_JT
	;Decrement player freeze timer, check if 0
	dec PlayerFreezeTimer,x
	bne HandePlayerState_NoFlash
HandePlayerState_Flash:
	;Set player props
	lda Enemy_Props,x
	and #$FC
	sta Enemy_Props,x
	rts
HandePlayerState_NoFlash:
	;If player freeze timer >= $50, exit early
	cmp #$50
	bcs HandePlayerState_Exit
	;Set player props based on bit 1 of player freeze timer
	and #$02
	bne HandePlayerState_Flash
	lda Enemy_Props,x
	ora #$03
	sta Enemy_Props,x
HandePlayerState_Exit:
	rts
HandePlayerState_JT:
	;Do jump table
	lda PlayerState,x
	jsr DoJumpTable
PlayerStateJumpTable:
	.dw PlayerStateSub0	;$00  Idle
	.dw PlayerStateSub1	;$01  Running
	.dw PlayerStateSub2	;$02  Stopping
	.dw PlayerStateSub3	;$03  Attacking
	.dw PlayerStateSub4	;$04  Jumping
	.dw PlayerStateSub5	;$05  Falling
	.dw PlayerStateSub6	;$06  Ducking
	.dw PlayerStateSub7	;$07  Duck attacking
	.dw PlayerStateSub8	;$08  Double jump
	.dw PlayerStateSub9	;$09  Jump attacking
	.dw PlayerStateSubA	;$0A  Hit
	.dw PlayerStateSubB	;$0B  Death

;$00: Idle
PlayerStateSub0:
	;If animation timer >= $40, skip this part
	lda PlayerAnimTimer,x
	cmp #$40
	bcs PlayerStateSub0_CheckFall
	;If bit 0 of global timer 0, skip this part
	lda GlobalTimer
	and #$01
	beq PlayerStateSub0_CheckFall
	;Increment animation timer
	inc PlayerAnimTimer,x
PlayerStateSub0_CheckFall:
	;If player Y velocity not 0, set player falling state
	lda PlayerYVel,x
	beq PlayerStateSub0_CheckJump
PlayerStateSub0_SetFall:
	;Clear player fall timer
	lda #$00
	sta PlayerFallTimer,x
	;Next state ($05: Falling)
	lda #$05
	jmp SetPlayerState
PlayerStateSub0_CheckJump:
	;Check for A press
	lda JoypadDown,x
	and #JOY_A
	beq PlayerStateSub0_NoJump
PlayerStateSub0_SetJump:
	;Set player jumping state
	jmp SetPlayerJumping
PlayerStateSub0_NoJump:
	;Check for B press
	lda JoypadDown,x
	and #JOY_B
	beq PlayerStateSub0_NoAttack
PlayerStateSub0_SetAttack:
	;If key not active, play sound
	lda PlayerKeyFlags,x
	and #$05
	bne PlayerStateSub0_AttackKey
	;Play sound based on player character
	lda PlayerAttackSndEffTable,x
	jsr LoadSound
PlayerStateSub0_AttackKey:
	;Next state ($03: Attacking)
	lda #$03
	jmp SetPlayerState
PlayerAttackSndEffTable:
	.db SE_VAMPIREATTACK
	.db SE_MONSTERATTACK
PlayerStateSub0_NoAttack:
	;Check for DOWN held
	lda JoypadCur,x
	and #JOY_DOWN
	beq PlayerStateSub0_NoDuck
PlayerStateSub0_SetDuck:
	;Next state ($06: Ducking)
	lda #$06
	jsr SetPlayerState
	;Set animation offset
	lda #$04
	sta PlayerAnimOffs,x
	rts
PlayerStateSub0_NoDuck:
	;Handle player running
	jsr HandlePlayerRunning
	;If LEFT/RIGHT held, set player running state
	lda $11
	beq PlayerStateSub0_NoRun
	;Next state ($01: Running)
	lda #$01
	jsr SetPlayerState
	;Set animation offset
	lda #$09
	sta PlayerAnimOffs,x
	rts
PlayerStateSub0_NoRun:
	;If player X velocity not 0, set player stopping state
	lda PlayerXVel,x
	ora PlayerXVelLo,x
	beq PlayerStateSub0_Exit
	;Next state ($02: Stopping)
	lda #$02
	jmp SetPlayerState
PlayerStateSub0_Exit:
	rts

;$01: Running
PlayerStateSub1:
	;If player Y velocity not 0, set player falling state
	lda PlayerYVel,x
	bne PlayerStateSub0_SetFall
	;If DOWN held, set player ducking state
	lda JoypadCur,x
	and #JOY_DOWN
	bne PlayerStateSub0_SetDuck
	;If A press, set player jumping state
	lda JoypadDown,x
	and #JOY_A
	bne PlayerStateSub0_SetJump
	;If B press, set player attacking state
	lda JoypadDown,x
	and #JOY_B
	bne PlayerStateSub0_SetAttack
	;Handle player running
	jsr HandlePlayerRunning
	;If LEFT/RIGHT held, exit early
	lda $11
	bne PlayerStateSub0_Exit
	;Check if moving left or right
	lda PlayerXVel,x
	bmi PlayerStateSub1_Left
	;If player X velocity < $01, set stopping state
	beq PlayerStateSub1_Stop
	;Don't flip player X
	lda Enemy_Props,x
	and #$BF
	sta Enemy_Props,x
	rts
PlayerStateSub1_Left:
	;If player X velocity > $FF, set stopping state
	cmp #$FF
	bcc PlayerStateSub1_LeftP
	lda PlayerXVelLo,x
	beq PlayerStateSub1_LeftP
PlayerStateSub1_Stop:
	;Next state ($02: Stopping)
	lda #$02
	jsr SetPlayerState
	;Set animation offset
	lda #$02
	sta PlayerAnimOffs,x
	rts
PlayerStateSub1_LeftP:
	;Flip player X
	lda Enemy_Props,x
	ora #$40
	sta Enemy_Props,x
	rts

HandlePlayerRunning_NoSlopeArea:
	;Set player X velocity based on slope type
	tay
	lda PlayerSlopeXVelTable+1,y
	sta PlayerXVelLo,x
	lda PlayerSlopeXVelTable,y
	sta PlayerXVel,x
	jmp HandlePlayerRunning_CheckP

ClearPlayerRunning:
	;Clear player running
	lda #$00
	beq HandlePlayerRunning_EntClear

HandlePlayerRunning:
	;Check for LEFT/RIGHT held
	lda JoypadCur,x
	and #(JOY_LEFT|JOY_RIGHT)
HandlePlayerRunning_EntClear:
	sta $11
	;Get slope data offset
	ldy PlayerCollTypeBottom,x
	lda PlayerSlopeDataOffsetTable,y
	sta $10
	;Check for LEFT+RIGHT held
	lda $11
	cmp #(JOY_LEFT|JOY_RIGHT)
	bne HandlePlayerRunning_NoLR
	lda #$00
HandlePlayerRunning_NoLR:
	asl
	adc $10
	sta $10
	;Check for level 1 big slope area
	ldy LevelAreaNum
	cpy #$01
	bne HandlePlayerRunning_NoSlopeArea
	;Check for 45 deg. slope
	cmp #$06
	bcc HandlePlayerRunning_No45
	cmp #$12
	bcs HandlePlayerRunning_No45
	adc #$18
	tay
	;Set player slope power
	lda PlayerSlopePowerTable-$18-$06+1,y
	clc
	adc PlayerPowLo,x
	sta PlayerPowLo,x
	lda PlayerSlopePowerTable-$18-$06,y
	adc PlayerPowHi,x
	sta PlayerPowHi,x
	;Check if accelerating left or right
	bmi HandlePlayerRunning_LeftPower
	;If player power >= $02, set player power $02
	cmp #$02
	bcc HandlePlayerRunning_SetVel
	;Set player power $02
	lda #$02
	bne HandlePlayerRunning_SetPower
HandlePlayerRunning_LeftPower:
	;If player power < $FE, set player power $FE
	cmp #$FE
	bcs HandlePlayerRunning_SetVel
	;Set player power $FE
	lda #$FE
HandlePlayerRunning_SetPower:
	;Set player power
	sta PlayerPowHi,x
	lda #$00
	sta PlayerPowLo,x
	beq HandlePlayerRunning_SetVel
HandlePlayerRunning_No45:
	;If player power 0, skip this part
	lda PlayerPowLo,x
	and #$FC
	sta PlayerPowLo,x
	ora PlayerPowHi,x
	beq HandlePlayerRunning_NoPower
	;Increment/decrement player power $01
	ldy #$01
	;Check if accelerating left or right
	lda PlayerPowHi,x
	bpl HandlePlayerRunning_No45Right
	;Check for LEFT held
	lda $11
	and #JOY_LEFT
	bne HandlePlayerRunning_No45LeftPower
	;Increment player power $04
	ldy #$04
HandlePlayerRunning_No45LeftPower:
	;Increment player power
	tya
	clc
	adc PlayerPowLo,x
	sta PlayerPowLo,x
	bcc HandlePlayerRunning_NoPower
	inc PlayerPowHi,x
	jmp HandlePlayerRunning_NoPower
HandlePlayerRunning_No45Right:
	;Check for RIGHT held
	lda $11
	and #JOY_RIGHT
	bne HandlePlayerRunning_No45RightPower
	;Decrement player power $04
	ldy #$04
HandlePlayerRunning_No45RightPower:
	;Decrement player power
	sty $12
	lda PlayerPowLo,x
	sec
	sbc $12
	sta PlayerPowLo,x
	bcs HandlePlayerRunning_NoPower
	dec PlayerPowHi,x
HandlePlayerRunning_NoPower:
	ldy $10
HandlePlayerRunning_SetVel:
	;Set player props
	lda Enemy_Props,x
	and #$FC
	sta Enemy_Props,x
	;Set player X velocity
	lda PlayerSlopeXVelTable+1,y
	clc
	adc PlayerPowLo,x
	sta PlayerXVelLo,x
	lda PlayerSlopeXVelTable,y
	adc PlayerPowHi,x
	sta PlayerXVel,x
	;Check if moving left or right
	bmi HandlePlayerRunning_LeftVel
	;If player X velocity >= $02, update player run animation
	cmp #$02
	bcc HandlePlayerRunning_CheckP
	;Update player run animation
	jsr UpdatePlayerRunAnimation
	;If player X velocity >= $03, check to flash player for run animation
	cmp #$03
	bcc HandlePlayerRunning_CheckP
	bcs HandlePlayerRunning_CheckRunFlash
HandlePlayerRunning_LeftVel:
	;If player X velocity <= $FE, update player run animation
	cmp #$FF
	bcs HandlePlayerRunning_CheckP
	lda PlayerXVelLo,x
	bne HandlePlayerRunning_CheckP
	;Update player run animation
	jsr UpdatePlayerRunAnimation
	;If player X velocity <= $FD, check to flash player for run animation
	cmp #$FE
	bcs HandlePlayerRunning_CheckP
HandlePlayerRunning_CheckRunFlash:
	;If player not on 45 deg. slope right, skip this part
	lda PlayerCollTypeBottom,x
	cmp #$04
	bne HandlePlayerRunning_CheckP
	;Clear invincibility timer
	lda #$00
	sta PlayerInvinTimer,x
	;If bit 1 of global timer != player character, skip this part
	lda GlobalTimer
	and #$03
	lsr
	cmp PlayerCharacter,x
	beq HandlePlayerRunning_CheckP
	;Set player props
	lda Enemy_Props,x
	ora #$03
	sta Enemy_Props,x
HandlePlayerRunning_CheckP:
	;If LEFT/RIGHT not held, exit early
	lda $11
	beq HandlePlayerRunning_Exit
	;Check for RIGHT held
	lsr
	bcc HandlePlayerRunning_LeftP
	;Don't flip player X
	lda Enemy_Props,x
	and #$BF
	sta Enemy_Props,x
	rts
HandlePlayerRunning_LeftP:
	;Flip player X
	lda Enemy_Props,x
	ora #$40
	sta Enemy_Props,x
HandlePlayerRunning_Exit:
	rts

UpdatePlayerRunAnimation:
	;Check for running state
	ldy PlayerState,x
	cpy #$01
	bne UpdatePlayerRunAnimation_Exit
	;If animation timer not 0, decrement
	ldy PlayerAnimTimer,x
	beq UpdatePlayerRunAnimation_Exit
	;Decrement animation timer
	dec PlayerAnimTimer,x
UpdatePlayerRunAnimation_Exit:
	rts

;PLAYER SLOPE ACCELERATION DATA
PlayerSlopeDataOffsetTable:
	.db $00,$00,$00,$06,$0C,$12,$12,$18,$18,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PlayerSlopeXVelTable:
	.db $00,$00,$01,$40,$FE,$C0	;$00  Flat
	.db $00,$00,$01,$00,$FE,$80	;$06  45 deg. slope left
	.db $00,$00,$01,$80,$FF,$00	;$0C  45 deg. slope right
	.db $00,$00,$01,$00,$FE,$80	;$12  30 deg. slope left
	.db $00,$00,$01,$80,$FF,$00	;$18  30 deg. slope right
	.db $FF,$00,$FF,$00,$FF,$00	;$1E  45 deg. slope left  (slope area)
	.db $01,$00,$01,$00,$01,$00	;$24  45 deg. slope right (slope area)
PlayerSlopePowerTable:
	.db $FF,$FE,$00,$02,$FF,$FC	;$00  45 deg. slope left  (slope area)
	.db $00,$02,$00,$04,$FF,$FE	;$06  45 deg. slope right (slope area)

SetPlayerJumping:
	;Play sound
	lda #SE_PLAYERJUMP
	jsr LoadSound
	;Next state ($04: Jumping)
	lda #$04
	jsr SetPlayerState
	;Set animation offset
	lda #$03
	sta PlayerAnimOffs,x
	rts

;$02: Stopping
PlayerStateSub2:
	;Check for DOWN held
	lda JoypadCur,x
	and #JOY_DOWN
	beq PlayerStateSub2_NoDuck
	;Next state ($06: Ducking)
	lda #$06
	jsr SetPlayerState
	;Set animation offset
	lda #$04
	sta PlayerAnimOffs,x
	rts
PlayerStateSub2_NoDuck:
	;If player Y velocity not 0, set player falling state
	lda PlayerYVel,x
	beq PlayerStateSub2_NoFall
	;Clear player fall timer
	lda #$00
	sta PlayerFallTimer,x
	;Next state ($05: Falling)
	lda #$05
	jmp SetPlayerState
PlayerStateSub2_NoFall:
	;Check for A press
	lda JoypadDown,x
	and #JOY_A
	beq PlayerStateSub2_NoJump
	;Set player jumping state
	jmp SetPlayerJumping
PlayerStateSub2_NoJump:
	;Check for B press
	lda JoypadDown,x
	and #JOY_B
	beq PlayerStateSub2_NoAttack
	;If key not active, play sound
	lda PlayerKeyFlags,x
	and #$05
	bne PlayerStateSub2_AttackKey
	;Play sound based on player character
	lda PlayerAttackSndEffTable,x
	jsr LoadSound
PlayerStateSub2_AttackKey:
	;Next state ($03: Attacking)
	lda #$03
	jmp SetPlayerState
PlayerStateSub2_NoAttack:
	;Handle player running
	jsr HandlePlayerRunning
	;If LEFT/RIGHT held, set player running state
	lda $11
	beq PlayerStateSub2_NoRun
PlayerStateSub2_SetRun:
	;Next state ($01: Running)
	lda #$01
	jsr SetPlayerState
	;Set animation offset
	lda #$09
	sta PlayerAnimOffs,x
	rts
PlayerStateSub2_NoRun:
	;If player X velocity 0, set player idle state
	lda PlayerXVel,x
	ora PlayerXVelLo,x
	beq PlayerStateSub2_SetIdle
	;Check if moving left or right
	lda PlayerXVel,x
	bmi PlayerStateSub2_Left
	;If player X velocity >= $01, set player running state
	beq PlayerStateSub2_Exit
	;Don't flip player X
	lda Enemy_Props,x
	and #$BF
	sta Enemy_Props,x
	;Set player running state
	jmp PlayerStateSub2_SetRun
PlayerStateSub2_Left:
	;If player X velocity <= $FF, set player running state
	cmp #$FF
	bcc PlayerStateSub2_LeftP
	lda PlayerXVelLo,x
	bne PlayerStateSub2_Exit
PlayerStateSub2_LeftP:
	;Flip player X
	lda Enemy_Props,x
	ora #$40
	sta Enemy_Props,x
	;Set player running state
	bne PlayerStateSub2_SetRun
PlayerStateSub2_Exit:
	rts
PlayerStateSub2_SetIdle:
	;If animation offset not 0, exit early
	lda PlayerAnimOffs,x
	bne PlayerStateSub2_Exit
	;Next state ($00: Idle)
	lda #$00
	jmp SetPlayerState

;$03: Attacking
PlayerStateSub3:
	;If animation offset 0, set player stopping state
	ldy PlayerAnimOffs,x
	beq PlayerStateSub3_SetStop
	;Check for animation offset >= $03
	cpy #$03
	bcs PlayerStateSub3_NoStop
	;Clear player running
	jsr ClearPlayerRunning
	;If facing direction != moving direction, set player stopping state
	lda Enemy_Props,x
	and #$40
	sta $12
	jsr CheckPlayerFlipX
	lda Enemy_Props,x
	and #$40
	cmp $12
	beq PlayerStateSub3_Exit
PlayerStateSub3_SetStop:
	;Clear key flags
	lda #$00
	sta PlayerKeyFlags,x
	;Next state ($02: Stopping)
	lda #$02
	jmp SetPlayerState
PlayerStateSub3_NoStop:
	;Clear player running
	jsr ClearPlayerRunning
PlayerStateSub3_CheckKey:
	;If animation offset not $04, exit early
	lda PlayerAnimTimer,x
	bpl PlayerStateSub3_Exit
	ldy PlayerAnimOffs,x
	cpy #$04
	bne PlayerStateSub3_Exit
	;If key active, throw key
	lda PlayerKeyFlags,x
	and #$05
	bne PlayerStateSub3_ThrowKey
	;Spawn player attack
	jmp SpawnPlayerAttack
PlayerStateSub3_ThrowKey:
	;Get key enemy slot index
	and #$01
	tay
	;Next task ($03: Release)
	lda #$03
	sta Enemy_Mode,y
	sta PlayerKeyPower,y
	;Set key Y velocity
	lda #$FE
	sta Enemy_YVel,y
	lda #$80
	sta Enemy_YVelLo,y
	;Check if player is facing left or right
	sty $10
	ldy #$00
	lda Enemy_Props,x
	and #$40
	beq PlayerStateSub3_Right
	iny
	iny
PlayerStateSub3_Right:
	;Set key X velocity
	lda ThrowKeyXVelTable,y
	sta $11
	lda ThrowKeyXVelTable+1,y
	ldy $10
	sta Enemy_XVelLo,y
	lda $11
	sta Enemy_XVel,y
	;Clear enemy offscreen flag
	lda Enemy_Flags,y
	and #~EF_ALLOWOFFSCREEN
	sta Enemy_Flags,y
	;Set player index
	txa
	sta Enemy_Temp2,y
	;Clear key held flag
	lda #$02
	sta PlayerKeyFlags,x
PlayerStateSub3_Exit:
	rts
ThrowKeyXVelTable:
	.db $02,$80
	.db $FD,$80

;$09: Jump attacking
PlayerStateSub9:
	;If player grounded, handle normal attacking state
	lda PlayerCollTypeBottom,x
	cmp #$03
	bcc PlayerStateSub9_NoLand
	jmp PlayerStateSub3
PlayerStateSub9_NoLand:
	;If animation offset 0, set player falling state
	ldy PlayerAnimOffs,x
	beq PlayerStateSub9_SetFall
	;Check for animation offset >= $03
	cpy #$03
	bcs PlayerStateSub9_CheckKey
	;If facing direction != moving direction, set player falling state
	lda Enemy_Props,x
	and #$40
	sta $12
	jsr HandlePlayerRunning
	lda Enemy_Props,x
	and #$40
	cmp $12
	bne PlayerStateSub9_SetFall
	rts
PlayerStateSub9_CheckKey:
	;Handle normal attacking state
	jmp PlayerStateSub3_CheckKey
PlayerStateSub9_SetFall:
	;Clear key flags
	lda #$00
	sta PlayerKeyFlags,x
	;If player Y velocity up, set player double jump state
	lda PlayerYVel,x
	bmi PlayerStateSub9_SetDJ
	;Clear player fall timer
	lda #$00
	sta PlayerFallTimer,x
	;Next state ($05: Falling)
	lda #$05
	jmp SetPlayerState
PlayerStateSub9_SetDJ:
	;Next state ($08: Double jump)
	lda #$08
	jmp SetPlayerState

;$04: Jumping
PlayerStateSub4:
	;Check if already inited
	lda PlayerStateMode,x
	bne PlayerStateSub4_CheckAttack
	;If animation offset not $01, skip this part
	lda PlayerAnimTimer,x
	bpl PlayerStateSub4_NoInit
	lda PlayerAnimOffs,x
	cmp #$01
	bne PlayerStateSub4_NoInit
	;Save player Y position
	lda Enemy_Y,x
	sta PlayerJumpYPos,x
	;Set player Y velocity
	lda #$FC
	sta PlayerYVel,x
	lda #$20
	sta PlayerYVelLo,x
	;Play sound
	lda #SE_PLAYERJUMP
	jsr LoadSound
	;Set jump timer
	lda #$07
	sta PlayerStateTimer,x
	;Mark inited
	inc PlayerStateMode,x
PlayerStateSub4_NoInit:
	;Handle player running
	jmp HandlePlayerRunning
PlayerStateSub4_CheckAttack:
	;Check for B press
	lda JoypadDown,x
	and #JOY_B
	beq PlayerStateSub4_NoAttack
PlayerStateSub4_SetAttack:
	;If key not active, play sound
	lda PlayerKeyFlags,x
	and #$05
	bne PlayerStateSub4_AttackKey
	;Play sound based on player character
	ldy PlayerCharacter,x
	lda PlayerAttackSndEffTable,y
	jsr LoadSound
PlayerStateSub4_AttackKey:
	;Next state ($09: Jump attacking)
	lda #$09
	jmp SetPlayerState
PlayerStateSub4_NoAttack:
	;If player Y velocity down, set player falling state
	lda PlayerYVel,x
	bpl PlayerStateSub4_SetFall
	;If jump timer < 0, skip this part
	lda PlayerStateTimer,x
	bmi PlayerStateSub4_CheckDJ
	;If A not held, skip this part
	lda JoypadCur,x
	and #JOY_A
	beq PlayerStateSub4_CheckDJ
	;Decrement jump timer
	dec PlayerStateTimer,x
	;Accelerate player Y velocity against gravity
	lda PlayerYVelLo,x
	sec
	sbc #$40
	sta PlayerYVelLo,x
	bcs PlayerStateSub4_CheckDJ
	dec PlayerYVel,x
PlayerStateSub4_CheckDJ:
	;Check player double jump
	jmp CheckPlayerDoubleJump
PlayerStateSub4_SetFall:
	;Set player falling state
	jsr SetPlayerFalling
	;Set jump fall flag
	inc PlayerJumpFallFlag,x
	;Set fall timer
	lda #$0D
	sta PlayerStateTimer,x
	rts

;$08: Double jump
PlayerStateSub8:
	;If B press, set player attacking state
	lda JoypadDown,x
	and #JOY_B
	bne PlayerStateSub4_SetAttack
	;If player Y velocity down, set player falling state
	lda PlayerYVel,x
	bmi PlayerStateSub8_NoFall
	;Set player falling state
	jmp SetPlayerFalling
PlayerStateSub8_NoFall:
	;Handle player running
	jmp HandlePlayerRunning

SetPlayerFalling:
	;Check for jumping state
	lda #$05
	ldy PlayerAnimation,x
	cpy #$04
	beq SetPlayerFalling_Jump
	;Check for double jump state
	cpy #$08
	beq SetPlayerFalling_Jump
	lda #$0D
SetPlayerFalling_Jump:
	sta $10
	;Clear player fall timer
	lda #$00
	sta PlayerFallTimer,x
	;Next state ($05: Falling)
	lda #$05
	jsr SetPlayerState
	;Set player animation based on previous state
	lda $10
	sta PlayerAnimation,x
	;Set animation offset
	lda #$03
	sta PlayerAnimOffs,x
SetPlayerFalling_Exit:
	rts

;$05: Falling
PlayerStateSub5:
	;If bits 0 and 4 of global timer 0, increment player fall timer
	lda GlobalTimer
	and #$11
	bne PlayerStateSub5_NoIncT
	;Increment player fall timer
	inc PlayerFallTimer,x
PlayerStateSub5_NoIncT:
	;If B press, set player attacking state
	lda JoypadDown,x
	and #JOY_B
	beq PlayerStateSub5_NoAttack
	jmp PlayerStateSub4_SetAttack
PlayerStateSub5_NoAttack:
	;Check if already inited
	lda PlayerStateMode,x
	bne PlayerStateSub5_Main
	;Check if player is grounded
	lda PlayerCollTypeBottom,x
	cmp #$03
	bcc PlayerStateSub5_CheckDJ
	;Check for other states
	jsr PlayerStateSub0_CheckJump
	;If player not in falling state, exit early
	lda PlayerState,x
	cmp #$05
	bne SetPlayerFalling_Exit
	;Set player animation
	lda #$0C
	jsr SetPlayerState_AnimOnly
	;If fall timer >= $0D, play sound
	lda PlayerFallTimer,x
	cmp #$0D
	bcc PlayerStateSub5_NoSound
	;Play sound
	lda #SE_FALLLAND
	jsr LoadSound
PlayerStateSub5_NoSound:
	;Mark inited
	inc PlayerStateMode,x
	;Handle player running
	jmp HandlePlayerRunning
PlayerStateSub5_CheckDJ:
	;If jump fall flag not set, skip this part
	lda PlayerJumpFallFlag,x
	cmp #$01
	bne CheckPlayerDoubleJump_NoDJ
	;Decrement fall timer, check if < 0
	dec PlayerStateTimer,x
	bmi CheckPlayerDoubleJump_NoDJ

CheckPlayerDoubleJump:
	;If A not held, skip this part
	lda JoypadDown,x
	and #JOY_A
	beq CheckPlayerDoubleJump_NoDJ
	;If player Y velocity not 0, skip this part
	lda Enemy_YHi,x
	bne CheckPlayerDoubleJump_NoDJ
	;If player Y position >= jump start Y position, skip this part
	lda PlayerJumpYPos,x
	cmp Enemy_Y,x
	bcc CheckPlayerDoubleJump_NoDJ
	;Play sound
	lda #SE_PLAYERDOUBLEJUMP
	jsr LoadSound
	;Set player Y velocity
	lda #$FB
	sta PlayerYVel,x
	lda #$00
	sta PlayerYVelLo,x
	;Next state ($08: Double jump)
	lda #$08
	jmp SetPlayerState
CheckPlayerDoubleJump_NoDJ:
	;Handle player running
	jmp HandlePlayerRunning

PlayerStateSub5_Main:
	;Check to flip player X
	jsr CheckPlayerFlipX
	;Clear player running
	jsr ClearPlayerRunning
	;Check for other states
	jsr PlayerStateSub0_CheckFall
	;If player not in falling state, exit early
	lda PlayerState,x
	cmp #$05
	bne PlayerStateSub5_Exit
	;If no longer inited, exit early
	lda PlayerStateMode,x
	beq PlayerStateSub5_Exit
	;If animation not finished, exit early
	lda PlayerAnimTimer,x
	cmp #$FF
	bne PlayerStateSub5_Exit
	;Next state ($02: Stopping)
	lda #$02
	jmp SetPlayerState
PlayerStateSub5_Exit:
	rts

;$06: Ducking
PlayerStateSub6:
	;Check to flip player X
	jsr CheckPlayerFlipX
	;If player Y velocity not 0, set player falling state
	lda PlayerYVel,x
	beq PlayerStateSub6_NoFall
	;Clear player fall timer
	lda #$00
	sta PlayerFallTimer,x
	;Next state ($05: Falling)
	lda #$05
	jmp SetPlayerState
PlayerStateSub6_NoFall:
	;If solid collision type, skip this part
	ldy PlayerCollTypeBottom,x
	cpy #$16
	bcs PlayerStateSub6_NoJumpDown
	;Check for A press
	lda JoypadDown,x
	and #JOY_A
	beq PlayerStateSub6_NoJumpDown
	;If no ground below, skip this part
	jsr CheckPlayerJumpDown
	bcs PlayerStateSub6_NoJumpDown
	;Check for slope collision types
	lda #$80
	ldy PlayerCollTypeBottom,x
	cpy #$14
	bcc PlayerStateSub6_SetJumpDown
	lda #$0A
PlayerStateSub6_SetJumpDown:
	;Set player jump down timer
	sta PlayerJumpDownTimer,x
PlayerStateSub6_NoJumpDown:
	;Check for B press
	lda JoypadDown,x
	and #JOY_B
	beq PlayerStateSub6_NoAttack
	;If key active, skip this part
	lda PlayerKeyFlags,x
	and #$05
	bne PlayerStateSub6_AttackKey
	;Check for key collision
	lda PlayerHitFlags,x
	and #$F0
	bne PlayerStateSub6_GrabKey
PlayerStateSub6_SetAttackSound:
	;Play sound based on player character
	ldy PlayerCharacter,x
	lda PlayerAttackSndEffTable,y
	jsr LoadSound
PlayerStateSub6_AttackKey:
	;Next state ($07: Duck attacking)
	lda #$07
	jmp SetPlayerState
PlayerStateSub6_NoAttack:
	;Check for DOWN held
	lda JoypadCur,x
	and #JOY_DOWN
	bne PlayerStateSub6_Duck
	;Next state ($02: Stopping)
	lda #$02
	jsr SetPlayerState
	;Set player animation
	lda #$0D
	sta PlayerAnimation,x
	rts
PlayerStateSub6_Duck:
	;Clear player running
	jmp ClearPlayerRunning
PlayerStateSub6_GrabKey:
	;Get key index
	ldy #$00
	lda PlayerHitFlags,x
	and #$40
	beq PlayerStateSub6_Key1
	ldy #$01
PlayerStateSub6_Key1:
	;If key not inited, handle normal attacking state
	lda Enemy_Mode,y
	cmp #$01
	bne PlayerStateSub6_SetAttackSound
	;Set key flags based on key index
	tya
	ora #$06
	sta PlayerKeyFlags,x
	;Next task ($02: Held)
	lda #$02
	sta Enemy_Mode,y
	;Set enemy offscreen flag
	lda Enemy_Flags,y
	ora #EF_ALLOWOFFSCREEN
	sta Enemy_Flags,y
	;Set player key X offset
	lda Enemy_X+$08,y
	sec
	sbc Enemy_X,x
	sta PlayerKeyXOffs,y
	;Next state ($06: Ducking)
	lda #$06
	jmp SetPlayerState

;$07: Duck attacking
PlayerStateSub7:
	;If animation offset 0, set player ducking state
	ldy PlayerAnimOffs,x
	beq PlayerStateSub7_SetDuck
	;If animation offset >= $03, skip this part
	cpy #$03
	bcs PlayerStateSub7_NoDuck
	;Clear player running
	jsr ClearPlayerRunning
	;If facing direction != moving direction, set player ducking state
	lda Enemy_Props,x
	and #$40
	sta $12
	jsr CheckPlayerFlipX
	lda Enemy_Props,x
	and #$40
	cmp $12
	beq PlayerStateSub7_Exit
PlayerStateSub7_SetDuck:
	;Clear key flags
	lda #$00
	sta PlayerKeyFlags,x
	;Next state ($06: Ducking)
	lda #$06
	jmp SetPlayerState
PlayerStateSub7_NoDuck:
	;Clear player running
	jsr ClearPlayerRunning
	;If animation offset not $04, exit early
	lda PlayerAnimTimer,x
	bpl PlayerStateSub7_Exit
	ldy PlayerAnimOffs,x
	cpy #$04
	bne PlayerStateSub7_Exit
	;If key active, throw key
	lda PlayerKeyFlags,x
	and #$05
	bne PlayerStateSub7_ThrowKey
	;Spawn player attack
	jmp SpawnPlayerAttack
PlayerStateSub7_ThrowKey:
	;Throw key
	jmp PlayerStateSub3_ThrowKey
PlayerStateSub7_Exit:
	rts

;$0A: Hit
PlayerStateSubA:
	;Check if already inited
	ldy PlayerStateMode,x
	bne PlayerStateSubA_Main
	;Set player Y velocity
	lda #$FE
	sta PlayerYVel,x
	lda #$20
	sta PlayerYVelLo,x
	;Check if player is facing left or right
	ldy #$FF
	lda Enemy_Props,x
	and #$40
	beq PlayerStateSubA_Right
	ldy #$01
PlayerStateSubA_Right:
	;Set player X velocity
	tya
	sta PlayerXVel,x
	lda #$00
	sta PlayerXVelLo,x
	;Mark inited
	inc PlayerStateMode,x
	rts
PlayerStateSubA_Main:
	;If player Y velocity up, exit early
	lda PlayerYVel,x
	bmi PlayerStateSubA_Exit
	;If player not grounded, exit early
	lda PlayerCollTypeBottom,x
	cmp #$03
	bcc PlayerStateSubA_Exit
	;If player HP 0, set player death state
	lda PlayerHP,x
	beq PlayerStateSubA_Death
	;Next state ($02: Stopping)
	lda #$02
	jsr SetPlayerState
	;Set player animation
	lda #$0D
	sta PlayerAnimation,x
	rts
PlayerStateSubA_Death:
	;Clear invincibility timer
	lda #$00
	sta PlayerInvinTimer,x
	;Play sound
	lda #SE_PLAYERDEATH
	jsr LoadSound
	;Next state ($0B: Death)
	lda #$0B
	jsr SetPlayerState
	;Set animation offset
	lda #$05
	sta PlayerAnimOffs,x
PlayerStateSubA_Exit:
	rts

;$0B: Death
PlayerStateSubB:
	;Clear player running ClearPlayerRunning
	jsr ClearPlayerRunning
	;If animation not finished, exit early
	lda PlayerAnimTimer,x
	bpl PlayerStateSubB_Exit
	lda PlayerAnimOffs,x
	bne PlayerStateSubB_Exit
	;Check if we've reached the next animation
	ldy PlayerStateMode,x
	lda PlayerStateTimer,x
	cmp PlayerRespawnTimerTable,y
	bcs PlayerStateSubB_Respawn
	;Increment respawn timer
	inc PlayerStateTimer,x
PlayerStateSubB_Exit:
	rts
PlayerStateSubB_Respawn:
	;Check for end of animation
	lda PlayerRespawnAnimationTable,y
	bmi SetPlayerRespawn
	;Set player animation
	sta PlayerAnimation,x
	;Clear animation timer/offset
	lda #$00
	sta PlayerAnimTimer,x
	sta PlayerAnimOffs,x
	;Increment respawn animation data index
	inc PlayerStateMode,x
	rts
PlayerRespawnTimerTable:
	.db $03,$02,$00
PlayerRespawnAnimationTable:
	.db $0E,$0F,$FF

SetPlayerRespawn:
	;Set respawn timer
	lda #$60
	sta PlayerStateTimer,x
	;Clear player sprite
	lda #$00
	sta PlayerSprite,x
	sta Enemy_Sprite,x
	;Clear respawn start flag
	sta PlayerRespawnStartFlag,x
	;Clear animation timer
	lda #$FF
	sta PlayerAnimTimer,x
	;Next mode ($04: Death)
	inc PlayerMode,x
	rts

SpawnPlayerAttack:
	;Check for player 2
	stx $10
	ldy #$00
	txa
	beq SpawnPlayerAttack_P1
	ldy #$03
SpawnPlayerAttack_P1:
	;Find free slot for player attack
	ldx #$02
SpawnPlayerAttack_Loop:
	;If free slot available, spawn player attack
	lda PlayerAttackAnimOffs,y
	beq SpawnPlayerAttack_Spawn
	;Loop for each slot
	iny
	dex
	bpl SpawnPlayerAttack_Loop
SpawnPlayerAttack_Spawn:
	;Set animation offset
	lda #$01
	sta PlayerAttackAnimOffs,y
	;Check if player is ducking
	ldx $10
	lda PlayerState,x
	cmp #$07
	bne SpawnPlayerAttack_NoDuck
	lda #$01
	sta PlayerAttackDuckFlag,y
SpawnPlayerAttack_NoDuck:
	;Set player attack props
	lda Enemy_Props,x
	and #$60
	sta Enemy_Props+$02,y
	;Set animation timer
	lda #$F0
	sta PlayerAttackAnimTimer,y
	rts

CheckPlayerFlipX:
	;If LEFT/RIGHT not held, exit early
	lda JoypadCur,x
	and #(JOY_LEFT|JOY_RIGHT)
	beq CheckPlayerFlipX_Exit
	;Check for RIGHT held
	ldy #$00
	lsr
	bcs CheckPlayerFlipX_RightP
	;Flip player X
	iny
	lda Enemy_Props,x
	ora #$40
	bne CheckPlayerFlipX_SetP
CheckPlayerFlipX_RightP:
	;Don't flip player X
	lda Enemy_Props,x
	and #$BF
CheckPlayerFlipX_SetP:
	sta Enemy_Props,x
CheckPlayerFlipX_Exit:
	rts

SetPlayerState:
	;Set player state
	sta PlayerState,x
SetPlayerState_AnimOnly:
	;Set player animation
	sta PlayerAnimation,x
	;Clear player state
	lda #$00
	sta PlayerStateTimer,x
	sta PlayerStateMode,x
	sta PlayerJumpFallFlag,x
	sta PlayerAnimTimer,x
	sta PlayerAnimOffs,x
	rts

UpdatePlayerAnimation:
	;If animation timer $7F, exit early
	lda PlayerAnimTimer,x
	and #$7F
	cmp #$7F
	beq UpdatePlayerAnimation_Exit
	sta PlayerAnimTimer,x
	;Decrement animation timer, check if < 0
	dec PlayerAnimTimer,x
	bpl UpdatePlayerAnimation_Exit
	;Get animation data offset based on player character and key animation flag
	lda PlayerKeyFlags,x
	and #$02
	sta $10
	lda PlayerAnimation,x
	asl
	asl
	ora PlayerCharacter,x
	ora $10
	tay
	;Check for end of animation
	dec PlayerAnimOffs,x
	bpl UpdatePlayerAnimation_NoFC
	;Reset enemy animation frame
	lda PlayerAnimationOffsTable,y
	sta PlayerAnimOffs,x
UpdatePlayerAnimation_NoFC:
	;Get animation data index
	lda PlayerAnimOffs,x
	adc PlayerAnimationDataOffsetTable,y
	tay
	;Set player sprite
	lda PlayerAnimationSpriteTable,y
	sta PlayerSprite,x
	;Set animation timer
	lda PlayerAnimationTimerTable,y
	ora #$80
	sta PlayerAnimTimer,x
	;Load CHR bank
	lda PlayerAnimationCHRBankTable,y
	beq UpdatePlayerAnimation_Exit
	ldy PlayerCharacter,x
	sta TempCHRBanks+4,y
UpdatePlayerAnimation_Exit:
	rts

;PLAYER ANIMATION DATA
PlayerAnimationDataOffsetTable:
	.db $00,$03,$06,$09	;$00  Idle
	.db $0C,$15,$1E,$27	;$01  Walking
	.db $30,$32,$34,$36	;$02  Stopping
	.db $38,$3D,$42,$47	;$03  Attacking
	.db $4C,$4F,$52,$55	;$04  Jumping
	.db $58,$5B,$5E,$61	;$05  Falling
	.db $64,$68,$6C,$70	;$06  Ducking
	.db $74,$79,$7E,$83	;$07  Duck attacking
	.db $88,$8A,$8C,$8E	;$08  Double jump
	.db $38,$3D,$42,$47	;$09  Jump attacking
	.db $90,$91,$92,$93	;$0A  Hit
	.db $94,$99,$9E,$9F	;$0B  Death
	.db $A0,$A2,$A4,$A6	;$0C  Landing
	.db $A8,$AA,$AC,$AE	;$0D  Unducking
	.db $B0,$B2,$9E,$9F	;$0E \Respawn
	.db $B4,$BD,$9E,$9F	;$0F /
PlayerAnimationSpriteTable:
	;$00
	.db $10,$0F,$0E
	.db $47,$47,$47
	.db $31,$30,$2F
	.db $64,$64,$64
	;$0C
	.db $0B,$0A,$09,$08,$07,$06,$05,$04,$0C
	.db $5C,$5B,$5A,$59,$58,$57,$56,$55,$5D
	.db $2C,$2B,$2A,$29,$28,$27,$26,$25,$2D
	.db $73,$72,$71,$70,$6F,$6E,$6D,$6C,$74
	;$30
	.db $0E,$0D
	.db $47,$5E
	.db $2F,$2E
	.db $64,$75
	;$38
	.db $0D,$0D,$21,$21,$20
	.db $5E,$5E,$60,$60,$5F
	.db $0D,$0D,$3B,$3B,$3A
	.db $5E,$5E,$77,$77,$76
	;$4C
	.db $15,$14,$13
	.db $51,$50,$48
	.db $36,$35,$34
	.db $68,$67,$65
	;$58
	.db $18,$17,$16
	.db $54,$53,$52
	.db $39,$38,$37
	.db $6B,$6A,$69
	;$64
	.db $12,$12,$11,$13
	.db $49,$49,$49,$48
	.db $33,$33,$32,$34
	.db $66,$66,$66,$65
	;$74
	.db $24,$24,$23,$23,$22
	.db $63,$63,$62,$62,$61
	.db $24,$24,$23,$3D,$3C
	.db $63,$63,$62,$79,$78
	;$88
	.db $15,$14
	.db $51,$50
	.db $36,$35
	.db $68,$67
	;$90
	.db $19
	.db $4A
	;$92
	.db $19
	.db $19
	;$94
	.db $1B,$1C,$1B,$1A,$19
	.db $4B,$4C,$4B,$4B,$4A
	;$9E
	.db $4A
	.db $4A
	;$A0
	.db $13,$13
	.db $48,$48
	.db $34,$34
	.db $65,$65
	;$A8
	.db $0E,$13
	.db $47,$48
	.db $2F,$34
	.db $64,$65
	;$B0
	.db $1B,$1D
	.db $4B,$4D
	;$B4
	.db $00,$1F,$1E,$1B,$1E,$1B,$1E,$1B,$1E
	.db $00,$4F,$4E,$4B,$4E,$4B,$4E,$4B,$4E
PlayerAnimationCHRBankTable:
	;$00
	.db $05,$05,$05
	.db $17,$17,$17
	.db $0D,$0D,$0D
	.db $18,$18,$18
	;$0C
	.db $04,$04,$03,$03,$03,$02,$02,$02,$05
	.db $19,$18,$1A,$1C,$16,$12,$1A,$1C,$1D
	.db $0F,$0F,$10,$11,$10,$11,$10,$0F,$11
	.db $19,$18,$1A,$1C,$16,$1E,$1A,$1C,$1D
	;$30
	.db $05,$05
	.db $17,$14
	.db $0D,$0E
	.db $18,$14
	;$38
	.db $05,$05,$09,$09,$09
	.db $14,$14,$1B,$1B,$1B
	.db $05,$05,$0E,$0E,$08
	.db $14,$14,$13,$13,$1D
	;$4C
	.db $06,$06,$06
	.db $12,$12,$17
	.db $0D,$0D,$0A
	.db $12,$12,$14
	;$58
	.db $07,$07,$06
	.db $19,$19,$13
	.db $07,$07,$0E
	.db $17,$17,$13
	;$64
	.db $04,$04,$04,$06
	.db $18,$18,$18,$17
	.db $0C,$0C,$0C,$0A
	.db $17,$17,$17,$14
	;$74
	.db $0A,$0A,$0A,$0A,$0A
	.db $1A,$1A,$1B,$1B,$1B
	.db $0A,$0A,$0A,$0C,$0B
	.db $1A,$1A,$1B,$13,$1D
	;$88
	.db $06,$06
	.db $12,$12
	.db $0D,$0D
	.db $12,$12
	;$90
	.db $09
	.db $15
	;$92
	.db $09
	.db $09
	;$94
	.db $0B,$08,$0B,$0B,$09
	.db $14,$16,$14,$14,$15
	;$9E
	.db $15
	.db $15
	;$A0
	.db $06,$06
	.db $17,$17
	.db $0A,$0A
	.db $14,$14
	;$A8
	.db $05,$06
	.db $17,$17
	.db $0D,$0A
	.db $18,$14
	;$B0
	.db $0B,$0B
	.db $14,$16
	;$B4
	.db $00,$08,$0C,$0B,$0C,$0B,$0C,$0B,$0C
	.db $00,$15,$15,$14,$15,$14,$15,$14,$15
PlayerAnimationOffsTable:
	.db $02,$02,$02,$02	;$00  Idle
	.db $07,$07,$07,$07	;$01  Walking
	.db $00,$00,$00,$00	;$02  Stopping
	.db $04,$04,$04,$04	;$03  Attacking
	.db $01,$01,$01,$01	;$04  Jumping
	.db $01,$01,$01,$01	;$05  Falling
	.db $02,$02,$02,$02	;$06  Ducking
	.db $04,$04,$04,$04	;$07  Duck attacking
	.db $01,$01,$01,$01	;$08  Double jump
	.db $04,$04,$04,$04	;$09  Jump attacking
	.db $00,$00,$00,$00	;$0A  Hit
	.db $01,$01,$00,$00	;$0B  Death
	.db $01,$01,$01,$01	;$0C  Landing
	.db $01,$01,$01,$01	;$0D  Unducking
	.db $01,$01,$00,$00	;$0E \Respawn
	.db $08,$08,$00,$00	;$0F /
PlayerAnimationTimerTable:
	;$00
	.db $7C,$07,$07
	.db $7C,$07,$07
	.db $7C,$07,$07
	.db $7C,$07,$07
	;$0C
	.db $04,$04,$04,$04,$04,$04,$04,$04,$03
	.db $04,$04,$04,$04,$04,$04,$04,$04,$03
	.db $04,$04,$04,$04,$04,$04,$04,$04,$03
	.db $04,$04,$04,$04,$04,$04,$04,$04,$03
	;$30
	.db $7F,$03
	.db $7F,$03
	.db $7F,$03
	.db $7F,$03
	;$38
	.db $7F,$05,$02,$04,$04
	.db $7F,$05,$02,$04,$04
	.db $7F,$05,$02,$04,$04
	.db $7F,$05,$02,$04,$04
	;$4C
	.db $05,$05,$05
	.db $05,$05,$05
	.db $05,$05,$05
	.db $05,$05,$05
	;$58
	.db $07,$07,$09
	.db $07,$07,$09
	.db $07,$07,$09
	.db $07,$07,$09
	;$64
	.db $7F,$03,$03,$03
	.db $7F,$03,$03,$03
	.db $7F,$03,$03,$03
	.db $7F,$03,$03,$03
	;$74
	.db $7F,$05,$02,$04,$04
	.db $7F,$05,$02,$04,$04
	.db $7F,$05,$02,$04,$04
	.db $7F,$05,$02,$04,$04
	;$88
	.db $05,$05
	.db $05,$05
	.db $05,$05
	.db $05,$05
	;$90
	.db $7F
	.db $7F
	;$92
	.db $7F
	.db $7F
	;$94
	.db $03,$03,$04,$04,$04
	.db $03,$03,$04,$04,$04
	;$9E
	.db $7F
	.db $7F
	;$A0
	.db $7F,$03
	.db $7F,$03
	.db $7F,$03
	.db $7F,$03
	;$A8
	.db $7F,$03
	.db $7F,$03
	.db $7F,$03
	.db $7F,$03
	;$B0
	.db $02,$02
	.db $02,$02
	;$B4
	.db $04,$04,$04,$02,$02,$02,$02,$02,$02
	.db $04,$04,$04,$02,$02,$02,$02,$02,$02

CheckPlayerJumpDown:
	;Get collision X position
	lda Enemy_X,x
	sta $08
	lda Enemy_XHi,x
	sta $09
	;Check for slope collision types
	lda #$28
	ldy PlayerCollTypeBottom,x
	cpy #$11
	bcs CheckPlayerJumpDown_NoSlope
	lda #$3D
CheckPlayerJumpDown_NoSlope:
	;Get collision Y position
	clc
	adc Enemy_Y,x
	sta $0A
	lda Enemy_YHi,x
	adc #$00
	sta $0B
	;If below screen bounds, set carry flag and exit
	bne CheckPlayerJumpDown_SetC
	lda $0A
	cmp #$C1
	bcs CheckPlayerJumpDown_Exit
CheckPlayerJumpDown_Loop:
	;Get collision type bottom
	jsr GetCollisionType
	;If ground, clear carry flag and exit
	cmp #$03
	bcs CheckPlayerJumpDown_ClearC
	;If below screen bounds, set carry flag and exit
	lda $0A
	cmp #$B1
	bcs CheckPlayerJumpDown_Exit
	;Go to next row
	adc #$10
	sta $0A
	bne CheckPlayerJumpDown_Loop
CheckPlayerJumpDown_ClearC:
	;Clear carry flag
	clc
CheckPlayerJumpDown_Exit:
	rts
CheckPlayerJumpDown_SetC:
	;Set carry flag
	sec
	rts

FindRespawnPosition:
	;Clear collision check point high bytes
	ldy #$00
	sty $09
	sty $0B
	;Clear ground check counter/position
	sty $12
	sty $13
	sty $14
FindRespawnPosition_Loop:
	;Get collision check Y point
	lda #$00
	sta $11
	sec
	sbc TempMirror_PPUSCROLL_Y
	and #$0F
	ora #$20
	sta $0A
	;Get collision check X point
	lda #$00
	sec
	sbc TempMirror_PPUSCROLL_X
	and #$0F
	ora FindRespawnXOffsTable,y
	sta $08
FindRespawnPosition_Loop2:
	;If ground check counter >= $02, check for ground collision types
	lda $11
	cmp #$02
	bcs FindRespawnPosition_CheckGround
	;Check for non-solid collision types
	jsr GetCollisionType
	;If ground collision type, reset ground check counter
	cmp #$03
	bcs FindRespawnPosition_Reset
	;Increment ground check counter
	inc $11
	bne FindRespawnPosition_Next2
FindRespawnPosition_Reset:
	;Reset ground check counter
	lda #$00
	sta $11
	beq FindRespawnPosition_Next2
FindRespawnPosition_CheckGround:
	;Set ground check position
	lda $14
	bne FindRespawnPosition_NoSetGroundPos
	lda $08
	sta $13
	lda $0A
	sta $14
FindRespawnPosition_NoSetGroundPos:
	;Check for ground collision types
	jsr GetCollisionType
	;If ground collision type, set player respawn position
	cmp #$03
	bcs FindRespawnPosition_SetPos
FindRespawnPosition_Next2:
	;Loop for each row
	lda $0A
	cmp #$B0
	bcs FindRespawnPosition_Next
	adc #$10
	sta $0A
	bne FindRespawnPosition_Loop2
FindRespawnPosition_Next:
	;Loop for each column
	inc $12
	ldy $12
	cpy #$0E
	bcc FindRespawnPosition_Loop
	;Clear carry flag
	clc
	rts
FindRespawnPosition_SetPos:
	;Set player respawn position
	lda $0A
	sec
	sbc #$18
	sta Enemy_Y,x
	lda $08
	sta Enemy_X,x
	;Set carry flag
	sec
	rts
FindRespawnXOffsTable:
	.db $88,$98,$78,$A8,$68,$B8,$58,$C8,$48,$D8,$38,$E8,$28,$18

;$00: Init
PlayerModeSub0_Start:
	;Set player lives
	lda #$03
	sta PlayerLives,x
	bne PlayerModeSub1_Reset
PlayerModeSub0:
	;Set player respawn X position
	lda #$80
	sta PlayerRespawnXHi,x
	;Check to respawn at start of area
	lda PlayerRespawnStartFlag,x
	bne PlayerModeSub0_Start
	;Get other player index
	txa
	eor #$01
	tay
	;If other player lives < $02, don't allow lives borrowing
	lda PlayerLives,y
	cmp #$02
	bcc PlayerModeSub0_Exit
	;Check for A press
	lda JoypadDown,x
	and #JOY_A
	bne PlayerModeSub1_BorrowLife
PlayerModeSub0_Exit:
	rts

;$01: Continue
PlayerModeSub1:
	;Get other player index
	txa
	eor #$01
	tay
	;If other player lives < $02, don't allow lives borrowing
	lda PlayerLives,y
	cmp #$02
	bcc PlayerModeSub1_NoRespawn
	;Check for A press
	lda JoypadDown,x
	and #JOY_A
	beq PlayerModeSub1_NoRespawn
PlayerModeSub1_BorrowLife:
	;Set player lives
	lda #$01
	sta PlayerLives,x
	;Decrement other player lives
	lda PlayerLives,y
	sec
	sbc #$01
	sta PlayerLives,y
PlayerModeSub1_Reset:
	;Clear player score
	lda #$00
	sta PlayerScoreLo,x
	sta PlayerScoreMid,x
	;Reset player HP
	lda #$05
	sta PlayerHP,x
	;Reset player lives bonus
	sta PlayerLivesBonus,x
	;Next mode ($02: Respawn)
	lda #$02
	sta PlayerMode,x
PlayerModeSub1_Exit:
	rts
PlayerModeSub1_NoRespawn:
	;If player 2, exit early
	txa
	bne PlayerModeSub1_Exit
	;If other player lives >= $02, exit early
	lda PlayerMode+1
	cmp #$02
	bcs PlayerModeSub1_Exit
	;Increment respawn game over timer
	inc RespawnGameOverTimer
	;If timer >= $80, go to next mode ($08: Game over)
	lda RespawnGameOverTimer
	cmp #$80
	bcc PlayerModeSub1_Exit
	;Clear sound
	jsr ClearSound
	;Next mode ($08: Game over)
	lda #$08
	sta GameMode
	;Next submode ($00: Fade out)
	lda #$00
	sta GameSubmode
	rts

;$02: Respawn
PlayerModeSub2_Start:
	;Get other player index
	txa
	eor #$01
	tay
	;Check if other player is active
	lda PlayerMode,y
	cmp #$03
	beq PlayerModeSub2_Start2P
	;Set player X position offset for 1 player mode
	ldy LevelAreaNum
	lda #$00
	beq PlayerModeSub2_StartSetPos
PlayerModeSub2_Start2P:
	;Set player X position offset for 2 player mode (player 2)
	ldy LevelAreaNum
	lda #$E0
	;Check for player 2
	cpx #$00
	bne PlayerModeSub2_StartSetPos
	;Set player X position offset for 2 player mode (player 1)
	lda #$20
PlayerModeSub2_StartSetPos:
	;Set player position
	adc LevelAreaStartXTable,y
	sta Enemy_X,x
	lda LevelAreaStartYTable,y
	sta Enemy_Y,x
	;Clear player props
	lda #$00
	sta Enemy_Props,x
	;Next mode ($03: Main)
	inc PlayerMode,x
	rts
LevelAreaStartXTable:
	.db $80,$80,$40
	.db $80,$80,$80
	.db $80,$80,$80
	.db $80,$80,$80
	.db $80,$80,$80
	.db $80,$38,$80
LevelAreaStartYTable:
	.db $80,$80,$80
	.db $80,$68,$80
	.db $48,$80,$80
	.db $80,$98,$80
	.db $80,$68,$80
	.db $80,$98,$80
PlayerModeSub2_Plat:
	;Get other player index
	txa
	eor #$01
	tay
	;Check if other player is active
	lda PlayerMode,y
	cmp #$03
	bne PlayerModeSub2_Plat1P
	jmp PlayerModeSub2_Plat2P
PlayerModeSub2_Plat1P:
	;Get platform enemy slot index
	ldy PlayerPlatformIndex,x
	;Set player position for 1 player mode
	lda Enemy_Y+$08,y
	sec
	sbc #$24
	sta Enemy_Y,x
	lda Enemy_YHi+$08,y
	sbc #$00
	bne PlayerModeSub2_PlatExit
	sta Enemy_YHi,x
	lda Enemy_XHi+$08,y
	bne PlayerModeSub2_PlatExit
	sta Enemy_XHi,x
	lda Enemy_X+$08,y
	sta Enemy_X,x
	;Next mode ($03: Main)
	inc PlayerMode,x
PlayerModeSub2_PlatExit:
	rts
PlayerModeSub2:
	;Clear respawn game over timer
	lda #$00
	sta RespawnGameOverTimer
	;Check to respawn at start of area
	lda PlayerRespawnStartFlag,x
	beq PlayerModeSub2_NoStart
	jmp PlayerModeSub2_Start
PlayerModeSub2_NoStart:
	;Set invincibility timer
	lda #$30
	sta PlayerInvinTimer,x
	;Check if player on platform
	lda PlayerPlatformFlag,x
	bne PlayerModeSub2_Plat
	;Check if respawn position is offscreen
	lda PlayerRespawnXHi,x
	ora PlayerRespawnYHi,x
	beq PlayerModeSub2_Normal
	jmp PlayerModeSub2_Offscreen
PlayerModeSub2_Normal:
	;Check if respawn Y position is offscreen
	lda PlayerRespawnY,x
	cmp #$08
	bcc PlayerModeSub2_Offscreen
	cmp #$B8
	bcs PlayerModeSub2_Offscreen
	;Check if respawn X position is offscreen
	lda PlayerRespawnX,x
	cmp #$0C
	bcc PlayerModeSub2_Offscreen
	cmp #$F4
	bcs PlayerModeSub2_Offscreen
	;Check for ground collision types bottom right
	lda #$00
	sta $11
	lda PlayerRespawnY,x
	clc
	adc #$1A
	sta $0A
	lda PlayerRespawnYHi,x
	sta $0B
	lda PlayerRespawnXHi,x
	sta $09
	lda PlayerRespawnX,x
	clc
	adc #$07
	sta $08
	bcs PlayerModeSub2_Offscreen
	jsr GetCollisionType
	cmp #$03
	bcc PlayerModeSub2_NoGroundRight
	inc $11
PlayerModeSub2_NoGroundRight:
	;Check for ground collision types bottom left
	lda PlayerRespawnX,x
	sec
	sbc #$08
	sta $08
	bcc PlayerModeSub2_Offscreen
	jsr GetCollisionType
	cmp #$03
	bcc PlayerModeSub2_NoGroundLeft
	inc $11
	inc $11
PlayerModeSub2_NoGroundLeft:
	;Check for no ground bottom left or bottom right
	ldy $11
	beq PlayerModeSub2_Offscreen
	;Check for ground bottom left and bottom right
	cpy #$03
	beq PlayerModeSub2_SetPos
	;Set player X position offset for ground bottom right only
	lda #$05
	;Check for ground bottom left only
	cpy #$02
	bne PlayerModeSub2_NoSetLeft
	;Set player X position offset for ground bottom left only
	lda #$FA
PlayerModeSub2_NoSetLeft:
	;Apply player X position offset
	clc
	adc PlayerRespawnX,x
	sta PlayerRespawnX,x
PlayerModeSub2_SetPos:
	;Set player position
	lda PlayerRespawnX,x
	sta Enemy_X,x
	lda PlayerRespawnY,x
	sta Enemy_Y,x
	;Check if elevator is active
	lda ElevatorYPos
	beq PlayerModeSub2_NormalNext
	;Set player Y position above elevator
	lda #$80
	sta Enemy_Y,x
PlayerModeSub2_NormalNext:
	;Next mode ($03: Main)
	inc PlayerMode,x
	rts
PlayerModeSub2_Offscreen:
	;Get other player index
	txa
	eor #$01
	tay
	;Check if other player is active
	lda PlayerMode,y
	cmp #$03
	bcc PlayerModeSub2_FindPos
PlayerModeSub2_Plat2P:
	;If other player not grounded, exit early
	lda PlayerCollTypeBottom,y
	beq PlayerModeSub2_Exit
	;Check if other player is offscreen
	lda Enemy_YHi,y
	bne PlayerModeSub2_FindPos
	lda Enemy_Y,y
	cmp #$C0
	bcs PlayerModeSub2_FindPos
	;Set player position to other player position
	lda Enemy_X,y
	sta Enemy_X,x
	lda Enemy_Y,y
	sta Enemy_Y,x
	;Next mode ($03: Main)
	inc PlayerMode,x
PlayerModeSub2_Exit:
	rts
PlayerModeSub2_FindPos:
	;Find position to respawn player
	jsr FindRespawnPosition
	bcs PlayerModeSub2_OffscreenNext
	;Check if valid position found
	lda $14
	beq PlayerModeSub2_Fail
	;Set player position to found position
	sta Enemy_Y,x
	lda $13
	sta Enemy_X,x
	;Check if elevator is active
	lda ElevatorYPos
	beq PlayerModeSub2_OffscreenNext
	;Set player Y position above elevator
	lda #$80
	sta Enemy_Y,x
PlayerModeSub2_OffscreenNext:
	;Next mode ($03: Main)
	inc PlayerMode,x
	rts
PlayerModeSub2_Fail:
	;Set player position default
	lda #$80
	sta Enemy_X,x
	sta Enemy_Y,x
	;Next mode ($03: Main)
	inc PlayerMode,x
	rts

HandleAutoScrollY:
	;Enable scrolling up/down
	lda LevelScrollFlags
	ora #$0C
	sta LevelScrollFlags
	;Set Y scroll velocity
	lda #$00
	sta $0C
	lda AutoScrollYVel
	sta $0D
	;Update player Y scroll
	jsr UpdatePlayerScrollYSub
	;Handle player Y collision/movement
	ldx #$01
HandleAutoScrollY_Loop:
	;If player not active, don't handle collision
	lda PlayerMode,x
	cmp #$03
	bne HandleAutoScrollY_Next
	;Move player
	jsr MovePlayerYVel
	;Check for fixed camera
	lda AutoScrollDirFlags
	and #$C0
	beq HandleAutoScrollY_NoColl
	;Move player
	jsr MoveOtherPlayerYScroll
	jmp HandleAutoScrollY_Next
HandleAutoScrollY_NoColl:
	;If player grounded, move player
	lda PlayerCollTypeBottom,x
	cmp #$03
	bcc HandleAutoScrollY_Next
	;Move player
	jsr MoveOtherPlayerYScroll
HandleAutoScrollY_Next:
	;Loop for each player
	dex
	bpl HandleAutoScrollY_Loop
	rts

LevelYScrollFocusTable:
	.db $60,$78,$60
	.db $60,$60,$60
	.db $80,$60,$60
	.db $60,$60,$60
	.db $60,$60,$60
	.db $60,$60,$60
	.db $60,$60,$60
HandlePlayerMovementY:
	;Check for Y autoscroll
	lda AutoScrollDirFlags
	and #$0C
	bne HandleAutoScrollY
	;Get Y scroll focus position
	ldy LevelAreaNum
	lda LevelYScrollFocusTable,y
	sta $0C
	;Clear movement/scroll direction
	lda #$00
	sta $11
	sta $12
	sta $13
	sta $14
	;Handle player Y movement
	ldx #$01
HandlePlayerMovementY_CollLoop:
	;If player not active, skip this part
	lda PlayerMode,x
	cmp #$03
	bne HandlePlayerMovementY_CollNext
	;If player Y velocity 0, skip this part
	lda PlayerYVel,x
	ora PlayerYVelLo,x
	beq HandlePlayerMovementY_CollNext
	;Set Y movement direction
	ldy #$01
	lda PlayerYVel,x
	bpl HandlePlayerMovementY_PosY
	iny
HandlePlayerMovementY_PosY:
	tya
	sta $11,x
	;Check if on top or bottom side of screen
	lda Enemy_YHi,x
	bmi HandlePlayerMovementY_Up
	lda Enemy_Y,x
	cmp $0C
	bcc HandlePlayerMovementY_Up
	;Check if moving up while on top side of screen
	cpy #$01
	beq HandlePlayerMovementY_SetScroll
	bne HandlePlayerMovementY_CollNext
HandlePlayerMovementY_Up:
	;Check if moving down while on bottom side of screen
	cpy #$02
	bne HandlePlayerMovementY_CollNext
HandlePlayerMovementY_SetScroll:
	;Set Y scroll direction
	tya
	sta $13,x
HandlePlayerMovementY_CollNext:
	;Loop for each player
	dex
	bpl HandlePlayerMovementY_CollLoop
	;Check if no players are scrolling
	lda $13
	ora $14
	beq HandlePlayerMovementY_NoDir
	;Check if players are scrolling in opposite directions
	cmp #$03
	beq HandlePlayerMovementY_NoDir
	;Check if players are scrolling in same direction
	lda $13
	eor $14
	beq HandlePlayerMovementY_SameDir
	;Find which player is scrolling
	sta $16
	ldx #$01
	lda $13,x
	beq HandlePlayerMovementY_P1Scroll
	dex
HandlePlayerMovementY_P1Scroll:
	;Check if non-scrolling player is active
	lda PlayerMode,x
	cmp #$03
	bne HandlePlayerMovementY_1P
	;Move non-scrolling player
	jsr MovePlayerYVel_CheckDir
	;Check which direction player is scrolling
	ldy Enemy_Y,x
	lda $16
	and #$01
	bne HandlePlayerMovementY_OtherUp
	;Check if player scrolling up while other player on bottom side of screen
	cpy #$A0
	bcc HandlePlayerMovementY_OtherMid
	ldy Enemy_YHi,x
	beq HandlePlayerMovementY_OtherEdge
	bne HandlePlayerMovementY_OtherMid
HandlePlayerMovementY_OtherUp:
	;Check if player scrolling down while other player on top side of screen
	cpy #$30
	bcc HandlePlayerMovementY_OtherEdge
	ldy Enemy_YHi,x
	bne HandlePlayerMovementY_OtherEdge
HandlePlayerMovementY_OtherMid:
	;Move scrolling player
	txa
	eor #$01
	tax
	jsr UpdatePlayerScrollY
	;Move non-scrolling player
	txa
	eor #$01
	tax
	jmp MoveOtherPlayerYScroll
HandlePlayerMovementY_1P:
	;Move player
	txa
	eor #$01
	tax
	jmp UpdatePlayerScrollY
HandlePlayerMovementY_OtherEdge:
	;Move scrolling player
	txa
	eor #$01
	tax
	jmp MovePlayerYVel_CheckDir
HandlePlayerMovementY_NoDir:
	;Move both players
	ldx #$01
HandlePlayerMovementY_NoDirLoop:
	jsr MovePlayerYVel_CheckDir
	dex
	bpl HandlePlayerMovementY_NoDirLoop
	rts
HandlePlayerMovementY_CheckSameVel:
	;Check if players have same Y velocity
	ldy PlayerYVelLo
	cpy PlayerYVelLo+1
	beq HandlePlayerMovementY_SameVel
	;Check which player is faster
	bcc HandlePlayerMovementY_DiffVelDown
	bcs HandlePlayerMovementY_DiffVelUp
HandlePlayerMovementY_SameDir:
	;Check if players have same Y velocity
	lda $13
	ldy PlayerYVel
	cpy PlayerYVel+1
	beq HandlePlayerMovementY_CheckSameVel
	;Check which player is faster
	bcc HandlePlayerMovementY_DiffVelDown
HandlePlayerMovementY_DiffVelUp:
	;Check which player is faster (up)
	and #$01
	jmp HandlePlayerMovementY_DiffVel
HandlePlayerMovementY_DiffVelDown:
	;Check which player is faster (down)
	and #$02
	lsr
HandlePlayerMovementY_DiffVel:
	;Move faster player
	tax
	jsr MovePlayerYVel_CheckDir
	;Move both players
	jmp HandlePlayerMovementY_OtherMid
HandlePlayerMovementY_SameVel:
	;Move both players
	ldx #$00
	jsr UpdatePlayerScrollY
	lda $0C
	ora $0D
	beq MoveOtherPlayerYScroll_Exit
	ldx #$01
	jmp MovePlayerYScroll

MoveOtherPlayerYScroll:
	;Check if moving up or down
	lda ScrollPlayerYVel
	bmi MoveOtherPlayerYScroll_PosY
	;Apply scroll Y velocity (down)
	lda Enemy_Y,x
	sec
	sbc ScrollPlayerYVel
	bcs MoveOtherPlayerYScroll_NegSet
	sbc #$0F
	dec Enemy_YHi,x
MoveOtherPlayerYScroll_NegSet:
	sta Enemy_Y,x
	rts
MoveOtherPlayerYScroll_PosY:
	;Apply scroll Y velocity (up)
	lda Enemy_Y,x
	sec
	sbc ScrollPlayerYVel
	bcs MoveOtherPlayerYScroll_PosC
	cmp #$F0
	bcc MoveOtherPlayerYScroll_PosSet
MoveOtherPlayerYScroll_PosC:
	adc #$0F
	inc Enemy_YHi,x
MoveOtherPlayerYScroll_PosSet:
	sta Enemy_Y,x
MoveOtherPlayerYScroll_Exit:
	rts

MovePlayerYVel_CheckDir:
	;If not moving up or down, exit early
	lda $11,x
	beq MovePlayerYVel_Exit

MovePlayerYVel:
	;Check if moving up or down
	lda PlayerYVel,x
	bpl MovePlayerYVel_PosY
	;Apply player Y velocity (down)
	lda PlayerYLo,x
	clc
	adc PlayerYVelLo,x
	sta PlayerYLo,x
	lda Enemy_Y,x
	adc PlayerYVel,x
	bcs MovePlayerYVel_NegSet
	sbc #$0F
	dec Enemy_YHi,x
MovePlayerYVel_NegSet:
	sta Enemy_Y,x
MovePlayerYVel_Exit:
	rts
MovePlayerYVel_PosY:
	;Apply player Y velocity (down)
	lda PlayerYLo,x
	clc
	adc PlayerYVelLo,x
	sta PlayerYLo,x
	lda Enemy_Y,x
	adc PlayerYVel,x
	cmp #$F0
	bcc MovePlayerYVel_PosSet
	adc #$0F
	inc Enemy_YHi,x
MovePlayerYVel_PosSet:
	sta Enemy_Y,x
	rts

MovePlayerYScroll:
	;Check if moving up or down
	lda $0D
	bpl MovePlayerYScroll_PosY
	;Apply scroll Y velocity (down)
	lda PlayerYLo,x
	clc
	adc $0C
	sta PlayerYLo,x
	lda Enemy_Y,x
	adc $0D
	bcs MovePlayerYScroll_NegSet
	sbc #$0F
	dec Enemy_YHi,x
MovePlayerYScroll_NegSet:
	sta Enemy_Y,x
	rts
MovePlayerYScroll_PosY:
	;Apply scroll Y velocity (down)
	lda PlayerYLo,x
	clc
	adc $0C
	sta PlayerYLo,x
	lda Enemy_Y,x
	adc $0D
	cmp #$F0
	bcc MovePlayerYScroll_PosSet
	adc #$0F
	inc Enemy_YHi,x
MovePlayerYScroll_PosSet:
	sta Enemy_Y,x
MovePlayerYScroll_Exit:
	rts

UpdatePlayerScrollY:
	;Get player velocity
	lda PlayerYVelLo,x
	sta $0C
	lda PlayerYVel,x
	sta $0D
	;Update player Y scroll
	jsr UpdatePlayerScrollYSub
	;If scroll Y velocity 0, exit early
	lda $0C
	ora $0D
	beq MovePlayerYScroll_Exit
	;Move player
	jmp MovePlayerYScroll

UpdatePlayerScrollYSub:
	;Check if moving up or down
	lda $0D
	bmi UpdatePlayerScrollYSub_NegY
	;Get level layout flags for left screen
	jsr GetCurrentScreen
	;Check for bottom screen
	and #$40
	beq UpdatePlayerScrollYSub_PosYCheckRight
	bne UpdatePlayerScrollYSub_Exit
UpdatePlayerScrollYSub_PosYCheckRight:
	;Get level layout flags for right screen
	lda #$FF
	clc
	adc TempMirror_PPUSCROLL_X
	lda #$00
	adc CurScreenX
	sta $1B
	jsr GetLevelLayoutFlags
	;Check for bottom screen
	and #$40
	beq UpdatePlayerScrollYSub_PosY
UpdatePlayerScrollYSub_Exit:
	rts
UpdatePlayerScrollYSub_PosY:
	;Check if down scrolling is enabled
	lda LevelScrollFlags
	and #$04
	beq UpdatePlayerScrollYSub_Exit
	;Apply scroll Y velocity
	lda ScrollYPosLo
	clc
	adc $0C
	sta ScrollYPosLo
	lda TempMirror_PPUSCROLL_Y
	adc $0D
	bcs UpdatePlayerScrollYSub_PosYNoC
	cmp #$F0
	bcc UpdatePlayerScrollYSub_PosYSet
UpdatePlayerScrollYSub_PosYNoC:
	adc #$0F
	sec
UpdatePlayerScrollYSub_PosYSet:
	sta TempMirror_PPUSCROLL_Y
	bcc UpdatePlayerScrollYSub_PosYNoC2
	inc CurScreenY
UpdatePlayerScrollYSub_PosYNoC2:
	;Get level layout flags for left screen
	jsr GetCurrentScreen
	;Check for bottom screen
	and #$40
	bne UpdatePlayerScrollYSub_BoundB
	;Get level layout flags for right screen
	lda #$FF
	clc
	adc TempMirror_PPUSCROLL_X
	lda #$00
	adc CurScreenX
	sta $1B
	jsr GetLevelLayoutFlags
	;Check for bottom screen
	and #$40
	bne UpdatePlayerScrollYSub_BoundB
	beq UpdatePlayerScrollYSub_NoBound
UpdatePlayerScrollYSub_NegY:
	;Check if up scrolling is enabled
	lda LevelScrollFlags
	and #$08
	beq UpdatePlayerScrollYSub_Exit
	;Apply scroll Y velocity
	lda ScrollYPosLo
	clc
	adc $0C
	sta ScrollYPosLo
	lda TempMirror_PPUSCROLL_Y
	adc $0D
	bcs UpdatePlayerScrollYSub_NegYSet
	sbc #$0F
	clc
UpdatePlayerScrollYSub_NegYSet:
	sta TempMirror_PPUSCROLL_Y
	lda CurScreenY
	sbc #$00
	sta CurScreenY
	;Check for top level bounds
	bmi UpdatePlayerScrollYSub_BoundT
	;Get level layout flags for left screen
	jsr GetCurrentScreen
	;Check for top level bounds
	bmi UpdatePlayerScrollYSub_BoundT
	;Get level layout flags for right screen
	lda #$FF
	clc
	adc TempMirror_PPUSCROLL_X
	lda #$00
	adc CurScreenX
	sta $1B
	jsr GetLevelLayoutFlags
	;Check for top level bounds
	bmi UpdatePlayerScrollYSub_BoundT
UpdatePlayerScrollYSub_NoBound:
	;Clear Y scroll adjustment
	lda #$00
	sta $0C
	sta $0D
	beq UpdatePlayerScrollYSub_NoBoundSet
UpdatePlayerScrollYSub_BoundT:
	;Adjust Y scroll position for top level bounds
	inc CurScreenY
	lda TempMirror_PPUSCROLL_Y
	clc
	adc #$10
	sta $0D
	jmp UpdatePlayerScrollYSub_BoundSet
UpdatePlayerScrollYSub_BoundB:
	;Adjust Y scroll position for bottom level bounds
	lda TempMirror_PPUSCROLL_Y
	sta $0D
UpdatePlayerScrollYSub_BoundSet:
	lda ScrollYPosLo
	sta $0C
	lda #$00
	sta TempMirror_PPUSCROLL_Y
	sta ScrollYPosLo
UpdatePlayerScrollYSub_NoBoundSet:
	lda TempMirror_PPUSCROLL_Y
	sec
	sbc SaveScrollY
	beq UpdatePlayerScrollYSub_SetCtrl
	bmi UpdatePlayerScrollYSub_CheckUp
	;Set Y scroll velocity
	ldy #$04
	cmp #$10
	bcc UpdatePlayerScrollYSub_SetDir
	sbc #$10
UpdatePlayerScrollYSub_SetDir:
	sta ScrollPlayerYVel
	;Set Y scroll direction
	tya
	ora ScrollDirectionFlags
	sta ScrollDirectionFlags
	;Update Y collision scroll position
	lda ScrollPlayerYVel
	clc
	adc ScrollYCollPosLo
	sta ScrollYCollPosLo
UpdatePlayerScrollYSub_SetCtrl:
	;Set Y scroll position
	lda TempMirror_PPUCTRL
	and #$FD
	sta TempMirror_PPUCTRL
	lda CurScreenY
	and #$01
	asl
	ora TempMirror_PPUCTRL
	sta TempMirror_PPUCTRL
	rts
UpdatePlayerScrollYSub_CheckUp:
	;Set Y scroll velocity
	ldy #$08
	cmp #$F1
	bcs UpdatePlayerScrollYSub_SetDir
	adc #$10
	jmp UpdatePlayerScrollYSub_SetDir

HandlePlayerCollisionY:
	;Check if moving up or down
	lda PlayerYVel,x
	bpl HandlePlayerCollisionY_PosY
	;Clear collision type bottom
	lda #$00
	sta PlayerCollTypeBottom,x
	;Get collision type top left
	lda Enemy_Y,x
	sec
	sbc #$11
	bcs HandlePlayerCollisionY_NegYNoC
	sbc #$0F
	clc
HandlePlayerCollisionY_NegYNoC:
	sta $0A
	lda Enemy_YHi,x
	sbc #$00
	sta $0B
	bpl HandlePlayerCollisionY_NegYNoC2
	lda $0A
	cmp #$C0
	bcc HandlePlayerCollisionY_Exit
HandlePlayerCollisionY_NegYNoC2:
	lda Enemy_X,x
	sec
	sbc #$05
	sta $08
	lda Enemy_XHi,x
	sbc #$00
	sta $09
	jsr GetCollisionType
	;Check for solid collision type
	cmp #$16
	bcs HandlePlayerCollisionY_NegYSolid
	;Get collision type top right
	lda Enemy_X,x
	clc
	adc #$04
	sta $08
	lda Enemy_XHi,x
	adc #$00
	sta $09
	jsr GetCollisionType
	;Check for solid collision type
	cmp #$16
	bcc HandlePlayerCollisionY_Exit
HandlePlayerCollisionY_NegYSolid:
	;If solid collision type, clear player Y velocity/position
	lda #$00
	sta PlayerYVel,x
	sta PlayerYLo,x
	lda #$20
	sta PlayerYVelLo,x
	;Adjust player Y position for collision
	lda TempMirror_PPUSCROLL_Y
	clc
	adc Enemy_Y,x
	ora #$F8
	sta $00
	lda Enemy_Y,x
	sec
	sbc $00
	sta Enemy_Y,x
	lda Enemy_YHi,x
	sbc #$FF
	sta Enemy_YHi,x
HandlePlayerCollisionY_Exit:
	rts
HandlePlayerCollisionY_PosY:
	;Clear slope top collision tile Y offset
	lda #$00
	sta $16
	;Check for non-solid collision types
	ldy PlayerCollTypeBottom,x
	cpy #$03
	bcc HandlePlayerCollisionY_NoSlope
	;Check for non-slope collision types
	cpy #$14
	bcs HandlePlayerCollisionY_NoSlope
	;Check for 30 deg. slope
	cpy #$05
	bcs HandlePlayerCollisionY_Slope30
	;Offset collision check Y position $03
	lda PlayerYVel,x
	adc #$03
	sta PlayerYVel,x
	jmp HandlePlayerCollisionY_NoSlope
HandlePlayerCollisionY_Slope30:
	;Offset collision check Y position $01
	lda PlayerYVel,x
	adc #$01
	sta PlayerYVel,x
HandlePlayerCollisionY_NoSlope:
	;Apply player Y velocity and offset to collision check Y base position
	lda PlayerYLo,x
	clc
	adc PlayerYVelLo,x
	sta $13
	lda Enemy_Y,x
	adc PlayerYVel,x
	bcs HandlePlayerCollisionY_PosYNoC
	cmp #$F0
	bcc HandlePlayerCollisionY_PosYSet
HandlePlayerCollisionY_PosYNoC:
	adc #$0F
	sec
HandlePlayerCollisionY_PosYSet:
	sta $14
	lda Enemy_YHi,x
	adc #$00
	sta $15
	;Check if elevator is active
	lda ElevatorYPos
	beq HandlePlayerCollisionY_NoElev
	;If moving up, skip this part
	lda $15
	bne HandlePlayerCollisionY_NoElev
	;Check if player is below elevator
	lda $14
	sec
	sbc ElevatorYPos
	bcc HandlePlayerCollisionY_ElevCheck1
HandlePlayerCollisionY_ElevSet:
	;Set player grounded
	sta $11
	lda #$16
	sta PlayerCollTypeBottom,x
	jmp SetPlayerGrounded
HandlePlayerCollisionY_ElevCheck1:
	;Check if player Y position is $01 less than elevator Y position
	cmp #$FF
	beq HandlePlayerCollisionY_ElevSet
HandlePlayerCollisionY_NoElev:
	;Check for platform collision type
	lda PlayerCollTypeBottom,x
	cmp #$1E
	bcc HandlePlayerCollisionY_NoPlat
	jmp HandlePlayerCollisionY_JT
HandlePlayerCollisionY_NoPlat:
	;Get collision type bottom left
	lda $14
	clc
	adc #$18
	bcs HandlePlayerCollisionY_PosYNoC2
	cmp #$F0
	bcc HandlePlayerCollisionY_PosYSet2
HandlePlayerCollisionY_PosYNoC2:
	adc #$0F
	sec
HandlePlayerCollisionY_PosYSet2:
	sta $0A
	lda $15
	adc #$00
	sta $0B
	lda Enemy_X,x
	sec
	sbc #$05
	sta $08
	lda Enemy_XHi,x
	sbc #$00
	sta $09
	jsr GetCollisionType
	;Check for non-solid collision types
	cmp #$03
	bcc HandlePlayerCollisionY_PosYCheckRight
	;Check for slope collision types
	cmp #$14
	bcc HandlePlayerCollisionY_PosYCheckMid
HandlePlayerCollisionY_PosYCheckRight:
	sta $11
	;Get collision type bottom right
	lda Enemy_X,x
	clc
	adc #$04
	sta $08
	lda Enemy_XHi,x
	adc #$00
	sta $09
	jsr GetCollisionType
	;Check for non-solid collision types
	cmp #$03
	bcc HandlePlayerCollisionY_PosYCheckPrio
	;Check for slope collision types
	cmp #$14
	bcc HandlePlayerCollisionY_PosYCheckMid
HandlePlayerCollisionY_PosYCheckPrio:
	;Prioritize solid ground over semisolid ground
	cmp $11
	bcs HandlePlayerCollisionY_PosYRightPrio
	lda $11
HandlePlayerCollisionY_PosYRightPrio:
	;Check to set collision type bottom
	tay
	beq PlayerCollSub00
	bne HandlePlayerGroundCollision_SetType
HandlePlayerCollisionY_PosYCheckMid:
	;Get collision type bottom middle
	lda Enemy_X,x
	sta $08
	lda Enemy_XHi,x
	sta $09
	jsr GetCollisionType
HandlePlayerGroundCollision_SetType:
	;Set collision type bottom
	sta PlayerCollTypeBottom,x
HandlePlayerCollisionY_JT:
	;Do jump table
	jsr DoJumpTable
PlayerCollJumpTable:
	.dw PlayerCollSub00	;$00  Nothing
	.dw PlayerCollSub00	;$01  UNUSED
	.dw PlayerCollSub00	;$02  Behind BG area
	.dw PlayerCollSub03	;$03  45 deg. slope left
	.dw PlayerCollSub04	;$04  45 deg. slope right
	.dw PlayerCollSub05	;$05 \30 deg. slope left
	.dw PlayerCollSub06	;$06 /
	.dw PlayerCollSub07	;$07 \30 deg. slope right
	.dw PlayerCollSub08	;$08 /
	.dw PlayerCollSub09	;$09 \7.5 deg. slope right
	.dw PlayerCollSub0A	;$0A |
	.dw PlayerCollSub0B	;$0B |
	.dw PlayerCollSub0C	;$0C |
	.dw PlayerCollSub0D	;$0D |
	.dw PlayerCollSub0E	;$0E |
	.dw PlayerCollSub0F	;$0F |
	.dw PlayerCollSub10	;$10 /
	.dw PlayerCollSub11	;$11  Cross slope
	.dw PlayerCollSub00	;$12  UNUSED
	.dw PlayerCollSub13	;$13  Slope top
	.dw PlayerCollSub14	;$14  Semisolid ground
	.dw PlayerCollSub00	;$15  UNUSED
	.dw PlayerCollSub16	;$16  Solid ground
	.dw PlayerCollSub00	;$17  UNUSED
	.dw PlayerCollSub00	;$18  UNUSED
	.dw PlayerCollSub00	;$19  UNUSED
	.dw PlayerCollSub00	;$1A  UNUSED
	.dw PlayerCollSub14	;$1B  Hurts
	.dw PlayerCollSub00	;$1C  UNUSED
	.dw PlayerCollSub00	;$1D  UNUSED
	.dw PlayerCollSub1E	;$1E  Platform
	.dw PlayerCollSub1E	;$1F  UNUSED

;$00: Nothing
;$02: Behind BG area
PlayerCollSub00:
	;Clear jump down timer
	jsr ClearJumpDownTimer
PlayerCollSub00_InAir:
	;Set player in air
	lda #$00
	sta PlayerCollTypeBottom,x
	rts

;$14: Semisolid ground
;$1B: Hurts
PlayerCollSub14:
	;If player Y position offscreen, set player in air
	lda TempMirror_PPUSCROLL_Y
	and #$0F
	clc
	adc $14
	sta $0F
	lda $15
	adc #$00
	bne PlayerCollSub00
	lda $0F
	cmp #$08
	bcc PlayerCollSub00
	lda $15
	bne PlayerCollSub00
	;If jump down timer 0, set player grounded
	lda PlayerJumpDownTimer,x
	and #$0F
	beq PlayerCollSub14_Grounded
	;Decrement jump down timer, check if 0
	dec PlayerJumpDownTimer,x
	bne PlayerCollSub00_InAir
PlayerCollSub14_Grounded:
	;Get collision tile Y offset, check if 0
	jsr GetPlayerTileOffsetY
	beq SetPlayerGrounded_NoSetY
	;If collision tile Y offset >= $08, set player in air
	cmp #$08
	bcs PlayerCollSub00
	bcc SetPlayerGrounded

;$16: Solid ground
PlayerCollSub16:
	;If player Y position offscreen, set player in air
	lda TempMirror_PPUSCROLL_Y
	and #$0F
	clc
	adc $14
	sta $0F
	lda $15
	adc #$00
	beq PlayerCollSub16_Grounded
	lda $0F
	cmp #$C8
	bcc PlayerCollSub00
PlayerCollSub16_Grounded:
	;Clear player jump down timer
	jsr ClearJumpDownTimer
	;Get collision tile Y offset, check if 0
	jsr GetPlayerTileOffsetY
	beq SetPlayerGrounded_NoSetY

SetPlayerGrounded:
	;Adjust player Y velocity for collision
	lda PlayerYVel,x
	sec
	sbc $11
	sta PlayerYVel,x
SetPlayerGrounded_NoSetY:
	;Set player respawn position
	lda $14
	sta PlayerRespawnY,x
	lda $15
	sta PlayerRespawnYHi,x
	lda Enemy_X,x
	sta PlayerRespawnX,x
	lda Enemy_XHi,x
	sta PlayerRespawnXHi,x
	;Clear on platform flag
	lda #$00
	sta PlayerPlatformFlag,x
	rts

;$13: Slope top
PlayerCollSub13_InAir:
	;Set player in air
	lda #$00
	sta PlayerCollTypeBottom,x
	rts
PlayerCollSub13:
	;If player Y position offscreen, set player in air
	lda TempMirror_PPUSCROLL_Y
	and #$0F
	clc
	adc $14
	sta $0F
	lda $15
	adc #$00
	beq PlayerCollSub13_Onscreen
	lda $0F
	cmp #$B8
	bcc PlayerCollSub13_Nothing2
PlayerCollSub13_Onscreen:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Check for level 1 big slope area
	ldy LevelAreaNum
	cpy #$01
	beq PlayerCollSub13_SlopeArea
	;If collision tile Y offset >= $04, set player in air
	cmp #$04
	bcs PlayerCollSub13_Nothing2
PlayerCollSub13_SlopeArea:
	;If jump down timer slope flag set, set player in air
	lda PlayerJumpDownTimer,x
	and #$F0
	bne PlayerCollSub13_InAir
	;Adjust player Y position for collision
	lda $14
	clc
	sbc $11
	sta $14
	lda $15
	sbc #$00
	sta $15
	;Get collision type bottom middle
	lda $14
	clc
	adc #$18
	bcs PlayerCollSub13_NoYC
	cmp #$F0
	bcc PlayerCollSub13_SetY
PlayerCollSub13_NoYC:
	adc #$0F
	sec
PlayerCollSub13_SetY:
	sta $0A
	lda $15
	adc #$00
	sta $0B
	jsr GetCollisionType
	;Check for non-solid collision types
	cmp #$03
	bcc SetPlayerGrounded
	;Check for non-slope collision types
	cmp #$13
	bcs SetPlayerGrounded
	;Set slope top collision tile Y offset
	ldy $11
	sty $16
	jmp HandlePlayerGroundCollision_SetType
PlayerCollSub13_Nothing2:
	;Clear player jump down timer
	jsr ClearJumpDownTimer
PlayerCollSub13_InAir2:
	;Set player in air
	lda #$00
	sta PlayerCollTypeBottom,x
	rts

;$03: 45 deg. slope left
PlayerCollSub03:
	;If player Y position offscreen, set player in air
	lda TempMirror_PPUSCROLL_Y
	and #$0F
	clc
	adc $14
	sta $0F
	lda $15
	adc #$00
	beq PlayerCollSub03_Onscreen
	;Check if moving left or right
	lda PlayerXVel,x
	bmi PlayerCollSub03_Left
	;Clear player X velocity
	lda #$00
	sta PlayerXVel,x
	sta PlayerXVel,x
PlayerCollSub03_Left:
	lda $0F
	cmp #$C8
	bcc PlayerCollSub13_Nothing2
PlayerCollSub03_Onscreen:
	;Set cross collision type
	lda #$00
	sta PlayerCrossCollType,x
	;If jump down timer slope flag set, set player in air
	lda PlayerJumpDownTimer,x
	and #$F0
	bne PlayerCollSub13_InAir2
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Check for slope top
	lda $16
	beq PlayerCollSub03_NoTop
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	;If collision tile X offset >= $04, set player in air
	cmp #$04
	bcs PlayerCollSub03_InAir
PlayerCollSub03_EntCheckTop:
	;Adjust player Y position for collision
	eor #$0F
	sta $12
	;Check if above or below slope
	lda $11
	sec
	sbc $12
	bmi PlayerCollSub03_InAir
	bne PlayerCollSub03_Below
	;Set player grounded
	lda $16
	sta $11
	jmp SetPlayerGrounded
PlayerCollSub03_Below:
	;Set player grounded
	clc
	adc $16
	sta $11
	jmp SetPlayerGrounded
PlayerCollSub03_NoTop:
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
PlayerCollSub03_EntCheckNoTop:
	;Adjust player Y position for collision
	eor #$0F
	sta $12
	;Check if above or below slope
	lda $11
	sec
	sbc $12
	bmi PlayerCollSub03_InAir
	;If player distance below slope >= $06, set player in air
	cmp #$06
	bcs PlayerCollSub03_InAir
	;Set player grounded
	sta $11
	jmp SetPlayerGrounded
PlayerCollSub03_InAir:
	;Clear jump down timer
	jsr ClearJumpDownTimer
	;Set player in air
	lda #$00
	sta PlayerCollTypeBottom,x
	rts

CheckSlopeLeftOffsetY:
	;Check for slope top
	ldy $16
	bne PlayerCollSub03_EntCheckTop
	beq PlayerCollSub03_EntCheckNoTop

;$04: 45 deg. slope right
PlayerCollSub04:
	;If player Y position offscreen, set player in air
	lda TempMirror_PPUSCROLL_Y
	and #$0F
	clc
	adc $14
	sta $0F
	lda $15
	adc #$00
	beq PlayerCollSub04_Onscreen
	;Check if moving left or right
	lda PlayerXVel,x
	bpl PlayerCollSub04_Right
	;Clear player X velocity
	lda #$00
	sta PlayerXVel,x
	sta PlayerXVel,x
PlayerCollSub04_Right:
	lda $0F
	cmp #$C8
	bcc PlayerCollSub03_InAir
PlayerCollSub04_Onscreen:
	;Set cross collision type
	lda #$01
	sta PlayerCrossCollType,x
	;Check for level 1 big slope area
	lda LevelAreaNum
	cmp #$01
	bne PlayerCollSub04_NoSound
	;If player not in running state, skip this part
	lda PlayerState,x
	cmp #$01
	bne PlayerCollSub04_NoSound
	;If moving up, skip this part
	lda PlayerYVel,x
	bmi PlayerCollSub04_NoSound
	;If player Y velocity < $02, skip this part
	cmp #$02
	bcc PlayerCollSub04_NoSound
	;If bits 0-1 of animation offset not 0, skip this part
	lda PlayerAnimTimer,x
	bpl PlayerCollSub04_NoSound
	lda PlayerAnimOffs,x
	and #$03
	bne PlayerCollSub04_NoSound
	;Play sound
	lda #SE_SLOPEPOWERRUN
	jsr LoadSound
PlayerCollSub04_NoSound:
	;If jump down timer slope flag set, set player in air
	lda PlayerJumpDownTimer,x
	and #$F0
	bne PlayerCollSub05_InAir
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Check for slope top
	lda $16
	beq PlayerCollSub04_NoTop
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	;If collision tile X offset < $0B, set player in air
	cmp #$0B
	bcc PlayerCollSub03_InAir
PlayerCollSub04_EntCheckTop:
	;Adjust player Y position for collision
	sta $12
	;Check if above or below slope
	lda $11
	sec
	sbc $12
	bmi PlayerCollSub03_InAir
	beq PlayerCollSub04_Same
	jmp PlayerCollSub03_Below
PlayerCollSub04_Same:
	;Set player grounded
	lda $16
	sta $11
	jmp SetPlayerGrounded
PlayerCollSub04_InAir:
	;Clear jump down timer
	jsr ClearJumpDownTimer
	;Set player in air
	lda #$00
	sta PlayerCollTypeBottom,x
	rts
PlayerCollSub04_NoTop:
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
PlayerCollSub04_EntCheckNoTop:
	;Adjust player Y position for collision
	sta $12
	;Check if above or below slope
	lda $11
	sec
	sbc $12
	bmi PlayerCollSub04_InAir
	;Check for level 1 big slope area
	ldy LevelAreaNum
	cpy #$01
	beq PlayerCollSub04_SlopeArea
	;If player distance below slope >= $06, set player in air
	cmp #$06
	bcs PlayerCollSub04_InAir
PlayerCollSub04_SlopeArea:
	;Set player grounded
	sta $11
	jmp SetPlayerGrounded

CheckSlopeRightOffsetY:
	;Check for slope top
	ldy $16
	bne PlayerCollSub04_EntCheckTop
	beq PlayerCollSub04_EntCheckNoTop

;$05: 30 deg. slope left (bottom)
PlayerCollSub05_InAir:
	;Set player in air
	lda #$00
	sta PlayerCollTypeBottom,x
	rts
PlayerCollSub05:
	;If player Y position offscreen, set player in air
	lda TempMirror_PPUSCROLL_Y
	and #$0F
	clc
	adc $14
	sta $0F
	lda $15
	adc #$00
	beq PlayerCollSub05_Onscreen
	;Check if moving left or right
	lda PlayerXVel,x
	bmi PlayerCollSub05_Left
	;Clear player X velocity
	lda #$00
	sta PlayerXVel,x
	sta PlayerXVel,x
PlayerCollSub05_Left:
	lda $0F
	cmp #$C8
	bcs PlayerCollSub05_Onscreen
	;Clear jump down timer
	jsr ClearJumpDownTimer
	;Set player in air
	lda #$00
	sta PlayerCollTypeBottom,x
	rts
PlayerCollSub05_Onscreen:
	;If jump down timer slope flag set, set player in air
	lda PlayerJumpDownTimer,x
	and #$F0
	bne PlayerCollSub05_InAir
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	;Check if above or below slope
	jmp CheckSlopeLeftOffsetY

;$06: 30 deg. slope left (top)
PlayerCollSub06:
	;If player Y position offscreen, set player in air
	lda TempMirror_PPUSCROLL_Y
	and #$0F
	clc
	adc $14
	sta $0F
	lda $15
	adc #$00
	beq PlayerCollSub06_Onscreen
	;Check if moving left or right
	lda PlayerXVel,x
	bmi PlayerCollSub06_Left
	;Clear player X velocity
	lda #$00
	sta PlayerXVel,x
	sta PlayerXVel,x
PlayerCollSub06_Left:
	lda $0F
	cmp #$C8
	bcs PlayerCollSub06_Onscreen
	;Clear jump down timer
	jsr ClearJumpDownTimer
	;Set player in air
	lda #$00
	sta PlayerCollTypeBottom,x
	rts
PlayerCollSub06_Onscreen:
	;If jump down timer slope flag set, set player in air
	lda PlayerJumpDownTimer,x
	and #$F0
	bne PlayerCollSub07_InAir
	;Check for slope top
	lda $16
	beq PlayerCollSub06_NoTop
	jmp PlayerCollSub00
PlayerCollSub06_NoTop:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	ora #$08
	;Check if above or below slope
	jmp PlayerCollSub03_EntCheckNoTop

;$07: 30 deg. slope right (bottom)
PlayerCollSub07:
	;If player Y position offscreen, set player in air
	lda TempMirror_PPUSCROLL_Y
	and #$0F
	clc
	adc $14
	sta $0F
	lda $15
	adc #$00
	beq PlayerCollSub07_Onscreen
	;Check if moving left or right
	lda PlayerXVel,x
	bmi PlayerCollSub07_Left
	;Clear player X velocity
	lda #$00
	sta PlayerXVel,x
	sta PlayerXVel,x
PlayerCollSub07_Left:
	lda $0F
	cmp #$C8
	bcs PlayerCollSub07_Onscreen
	;Clear jump down timer
	jsr ClearJumpDownTimer
PlayerCollSub07_InAir:
	;Set player in air
	lda #$00
	sta PlayerCollTypeBottom,x
	rts
PlayerCollSub07_Onscreen:
	;If jump down timer slope flag set, set player in air
	lda PlayerJumpDownTimer,x
	and #$F0
	bne PlayerCollSub07_InAir
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	ora #$08
	;Check if above or below slope
	jmp CheckSlopeRightOffsetY

;$08: 30 deg. slope right (top)
PlayerCollSub08:
	;If player Y position offscreen, set player in air
	lda TempMirror_PPUSCROLL_Y
	and #$0F
	clc
	adc $14
	sta $0F
	lda $15
	adc #$00
	beq PlayerCollSub08_Onscreen
	;Check if moving left or right
	lda PlayerXVel,x
	bmi PlayerCollSub08_Left
	;Clear player X velocity
	lda #$00
	sta PlayerXVel,x
	sta PlayerXVel,x
PlayerCollSub08_Left:
	lda $0F
	cmp #$C8
	bcs PlayerCollSub08_Onscreen
	;Clear jump down timer
	jsr ClearJumpDownTimer
	;Set player in air
	lda #$00
	sta PlayerCollTypeBottom,x
	rts
PlayerCollSub08_Onscreen:
	;If jump down timer slope flag set, set player in air
	lda PlayerJumpDownTimer,x
	and #$F0
	bne PlayerCollSub07_InAir
	;Check for slope top
	lda $16
	beq PlayerCollSub08_NoTop
	jmp PlayerCollSub00
PlayerCollSub08_NoTop:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	;Check if above or below slope
	jmp PlayerCollSub04_EntCheckNoTop

;$09: 7.5 deg. slope right (8/8 top)
PlayerCollSub09:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	lsr
	lsr
	;Check if above or below slope
	jmp CheckSlopeRightOffsetY

;$0A: 7.5 deg. slope right (7/8)
PlayerCollSub0A:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	lsr
	lsr
	clc
	adc #$02
	;Check if above or below slope
	jmp CheckSlopeRightOffsetY

;$0B: 7.5 deg. slope right (6/8)
PlayerCollSub0B:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	lsr
	lsr
	clc
	adc #$04
	;Check if above or below slope
	jmp CheckSlopeRightOffsetY

;$0C: 7.5 deg. slope right (5/8)
PlayerCollSub0C:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	lsr
	lsr
	clc
	adc #$06
	;Check if above or below slope
	jmp CheckSlopeRightOffsetY

;$0D: 7.5 deg. slope right (4/8)
PlayerCollSub0D:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	lsr
	lsr
	clc
	adc #$08
	;Check if above or below slope
	jmp CheckSlopeRightOffsetY

;$0E: 7.5 deg. slope right (3/8)
PlayerCollSub0E:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	lsr
	lsr
	clc
	adc #$0A
	;Check if above or below slope
	jmp CheckSlopeRightOffsetY

;$0F: 7.5 deg. slope right (2/8)
PlayerCollSub0F:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	lsr
	lsr
	clc
	adc #$0C
	;Check if above or below slope
	jmp CheckSlopeRightOffsetY

;$10: 7.5 deg. slope right (1/8 bottom)
PlayerCollSub10:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;Get slope Y offset based on collision tile X offset
	jsr GetPlayerTileOffsetX
	lsr
	lsr
	lsr
	clc
	adc #$0E
	;Check if above or below slope
	jmp CheckSlopeRightOffsetY

;$11: Cross slope
PlayerCollSub11:
	;Get collision tile Y offset
	jsr GetPlayerTileOffsetY
	;If collision tile Y offset $08-$09, check to change cross collision type
	cmp #$08
	bcc PlayerCollSub11_CheckCross
	cmp #$0A
	bcs PlayerCollSub11_CheckCross
	;Check for UP/DOWN held
	ldy #$00
	lda JoypadCur,x
	and #(JOY_UP|JOY_DOWN)
	beq PlayerCollSub11_CheckCross
	;Check for UP held
	and #JOY_UP
	bne PlayerCollSub11_Up
	;Check for LEFT/RIGHT held
	lda JoypadCur,x
	and #(JOY_LEFT|JOY_RIGHT)
	beq PlayerCollSub11_CheckCross
	;Check for LEFT held
	lda JoypadCur,x
	and #JOY_LEFT
	bne PlayerCollSub11_SetCross
	iny
	bne PlayerCollSub11_SetCross
PlayerCollSub11_Up:
	;Check for LEFT/RIGHT held
	lda JoypadCur,x
	and #(JOY_LEFT|JOY_RIGHT)
	beq PlayerCollSub11_CheckCross
	;Check for RIGHT held
	and #JOY_RIGHT
	bne PlayerCollSub11_SetCross
	iny
PlayerCollSub11_SetCross:
	;Set cross collision type
	tya
	sta PlayerCrossCollType,x
PlayerCollSub11_CheckCross:
	;Check for cross collision type left
	lda PlayerCrossCollType,x
	beq PlayerCollSub11_CrossLeft
	;Handle 45 deg. slope right
	lda #$04
	sta PlayerCollTypeBottom,x
	jmp PlayerCollSub04
PlayerCollSub11_CrossLeft:
	;Handle 45 deg. slope left
	lda #$03
	sta PlayerCollTypeBottom,x
	jmp PlayerCollSub03

;$1E: Platform
PlayerCollSub1E:
	;Get platform Y position
	ldy PlayerPlatformIndex,x
	lda Enemy_Y+$08,y
	sec
	sbc #$28
	sta $11
	lda Enemy_YLo,y
	clc
	adc Enemy_YVelLo,y
	lda $11
	adc Enemy_YVel,y
	sta $11
	;Adjust player Y position for collision
	lda $14
	sec
	sbc $11
	sta $11
	;Apply platform X velocity to player X velocity
	lda PlayerXVelLo,x
	clc
	adc Enemy_XVelLo,y
	sta PlayerXVelLo,x
	lda PlayerXVel,x
	adc Enemy_XVel,y
	sta PlayerXVel,x
	;Set player grounded
	jsr SetPlayerGrounded
	;Set on platform flag
	inc PlayerPlatformFlag,x
	rts

GetPlayerTileOffsetY:
	;Get collision tile Y offset
	lda $14
	eor #$08
	clc
	adc TempMirror_PPUSCROLL_Y
	and #$0F
	sta $11
	rts

GetPlayerTileOffsetX:
	;Get collision tile X offset
	lda TempMirror_PPUSCROLL_X
	clc
	adc Enemy_X,x
	and #$0F
	rts

ClearJumpDownTimer:
	;Clear player jump down timer
	lda #$00
	sta PlayerJumpDownTimer,x
	rts

;;;;;;;;;;;;;;;;
;ENEMY ROUTINES;
;;;;;;;;;;;;;;;;
MoveEnemies_Exit:
	rts
MoveEnemies:
	;If enemy scroll not enabled, exit early
	lda ScrollEnemyFlag
	bne MoveEnemies_Exit
	;Set enemy scroll X velocity
	ldy #$00
	lda SaveScrollX
	sec
	sbc TempMirror_PPUSCROLL_X
	bpl MoveEnemies_NoScrollXC
	dey
MoveEnemies_NoScrollXC:
	sta ScrollEnemyXVel
	sty $01
	;Check for Y scroll
	ldy #$00
	lda ScrollDirectionFlags
	and #$0C
	beq MoveEnemies_SetScrollY
	;Check if scrolling up or down
	cmp #$08
	bcs MoveEnemies_UpScroll
	;Set enemy scroll Y velocity
	dey
	sec
	lda TempMirror_PPUSCROLL_Y
	sbc SaveScrollY
	bcs MoveEnemies_SetScrollY
	sbc #$0F
	bcs MoveEnemies_SetScrollY
MoveEnemies_UpScroll:
	lda SaveScrollY
	sbc TempMirror_PPUSCROLL_Y
	bcs MoveEnemies_SetScrollY
	sbc #$0F
MoveEnemies_SetScrollY:
	sta ScrollEnemyYVel
	sty $03
	;Update enemies BG movement
	ldx #$11
MoveEnemies_Loop:
	;If enemy is active, update enemy BG movement
	ldy Enemy_ID,x
	beq MoveEnemies_Next
	;Check for key enemy slots
	cpx #$02
	bcs MoveEnemies_NoKey
	;Check for key held task
	lda Enemy_Mode,x
	cmp #$02
	beq MoveEnemies_Next
MoveEnemies_NoKey:
	;Apply enemy scroll X velocity
	lda ScrollEnemyXVel
	beq MoveEnemies_NoSetX
	clc
	adc Enemy_X+$08,x
	sta Enemy_X+$08,x
	lda Enemy_XHi+$08,x
	adc $01
	sta Enemy_XHi+$08,x
MoveEnemies_NoSetX:
	;Check if enemy scroll Y is enabled
	lda Enemy_Temp0,x
	lsr
	bcs MoveEnemies_Next
	;Apply enemy scroll Y velocity
	lda ScrollEnemyYVel
	beq MoveEnemies_Next
	;Check if scrolling up or down
	ldy $03
	bmi MoveEnemies_Up
	clc
	adc Enemy_Y+$08,x
	bcs MoveEnemies_DownNoYC
	cmp #$F0
	bcc MoveEnemies_SetY
MoveEnemies_DownNoYC:
	adc #$0F
	inc Enemy_YHi+$08,x
	jmp MoveEnemies_SetY
MoveEnemies_Up:
	lda Enemy_Y+$08,x
	sec
	sbc ScrollEnemyYVel
	bcs MoveEnemies_SetY
	sbc #$0F
	dec Enemy_YHi+$08,x
MoveEnemies_SetY:
	sta Enemy_Y+$08,x
MoveEnemies_Next:
	;Loop for each enemy
	dex
	bpl MoveEnemies_Loop
	rts

LevelEnemyLayoutDataPointerTable:
	.dw Level11EnemyLayoutData
	.dw Level12EnemyLayoutData
	.dw Level13EnemyLayoutData
	.dw Level21EnemyLayoutData
	.dw Level22EnemyLayoutData
	.dw Level23EnemyLayoutData
	.dw Level31EnemyLayoutData
	.dw Level32EnemyLayoutData
	.dw Level33EnemyLayoutData
	.dw Level41EnemyLayoutData
	.dw Level42EnemyLayoutData
	.dw Level43EnemyLayoutData
	.dw Level51EnemyLayoutData
	.dw Level52EnemyLayoutData
	.dw Level53EnemyLayoutData
	.dw Level61EnemyLayoutData
	.dw Level62EnemyLayoutData
	.dw Level63EnemyLayoutData
LevelEnemyDataPointerTable:
	.dw Level11EnemyData
	.dw Level12EnemyData
	.dw Level13EnemyData
	.dw Level21EnemyData
	.dw Level22EnemyData
	.dw Level23EnemyData
	.dw Level31EnemyData
	.dw Level32EnemyData
	.dw Level33EnemyData
	.dw Level41EnemyData
	.dw Level42EnemyData
	.dw Level43EnemyData
	.dw Level51EnemyData
	.dw Level52EnemyData
	.dw Level53EnemyData
	.dw Level61EnemyData
	.dw Level62EnemyData
	.dw Level63EnemyLayoutData

CheckLevelEnemies_Exit:
	rts
CheckLevelEnemies:
	;If not scrolling, exit early
	lda ScrollDirectionFlags
	and #$0F
	beq CheckLevelEnemies_Exit
	;Get enemy data pointer
	lda LevelAreaNum
	asl
	tay
	lda LevelEnemyLayoutDataPointerTable,y
	sta $08
	lda LevelEnemyLayoutDataPointerTable+1,y
	sta $09
	lda LevelEnemyDataPointerTable,y
	sta $0A
	lda LevelEnemyDataPointerTable+1,y
	sta $0B
	;Clear enemy spawn position high bytes
	lda #$00
	sta $02
	sta $03
	;Clear check left/top edge position flags
	sta $0C
	sta $0E
	;Set screen left edge X position for spawning level enemies
	ldx CurScreenX
	lda TempMirror_PPUSCROLL_X
	sec
	sbc #$30
	bcs CheckLevelEnemies_SetLeft
	dec $02
	dex
	bpl CheckLevelEnemies_SetLeft
	lda #$00
	sta $02
	tax
	inc $0C
CheckLevelEnemies_SetLeft:
	sta $10
	stx $11
	;Set screen right edge X position for spawning level enemies
	ldx CurScreenX
	lda TempMirror_PPUSCROLL_X
	clc
	adc #$31
	bcc CheckLevelEnemies_RightNoC
	inx
CheckLevelEnemies_RightNoC:
	inx
	cpx LevelAreaWidth
	bcc CheckLevelEnemies_SetRight
	lda #$FF
	dex
CheckLevelEnemies_SetRight:
	sta $12
	stx $13
	;Set screen top edge Y position for spawning level enemies
	ldx CurScreenY
	lda TempMirror_PPUSCROLL_Y
	sec
	sbc #$20
	bcs CheckLevelEnemies_SetTop
	dec $03
	sbc #$10
	dex
	bpl CheckLevelEnemies_SetTop
	lda #$00
	sta $03
	tax
	inc $0E
CheckLevelEnemies_SetTop:
	sta $14
	stx $15
	;Set screen bottom edge Y position for spawning level enemies
	ldx CurScreenY
	lda TempMirror_PPUSCROLL_Y
	clc
	adc #$E1
	bcs CheckLevelEnemies_BottomNoC
	cmp #$F0
	bcc CheckLevelEnemies_BottomNoC2
CheckLevelEnemies_BottomNoC:
	adc #$0F
	inx
CheckLevelEnemies_BottomNoC2:
	cpx LevelAreaHeight
	bcc CheckLevelEnemies_SetBottom
	lda #$FF
	dex
CheckLevelEnemies_SetBottom:
	sta $16
	stx $17
	;Check to scroll horizontally
	lda SaveScrollX
	and #$F0
	sta $00
	lda TempMirror_PPUSCROLL_X
	and #$F0
	cmp $00
	bne CheckLevelEnemies_Horiz
	jmp CheckLevelEnemies_Vert
CheckLevelEnemies_Horiz:
	;Get check bottom edge flag
	sec
	lda $17
	sbc $15
	sta $0F
	;Get base screen position
	lda #$00
	ldx $15
	clc
CheckLevelEnemies_HorizScreenLoop:
	dex
	bmi CheckLevelEnemies_HorizScreenEnd
	adc LevelAreaWidth
	bne CheckLevelEnemies_HorizScreenLoop
CheckLevelEnemies_HorizScreenEnd:
	sta $00
	;Set X position for spawning level enemies based on scroll direction
	lda ScrollDirectionFlags
	lsr
	lda $10
	bcc CheckLevelEnemies_HorizLeft
	lda $12
CheckLevelEnemies_HorizLeft:
	and #$F0
	sta $04
	lda $00
	bcc CheckLevelEnemies_HorizLeft2
	clc
	adc $13
	bne CheckLevelEnemies_HorizSetScreen
CheckLevelEnemies_HorizLeft2:
	adc $11
CheckLevelEnemies_HorizSetScreen:
	sta $05
CheckLevelEnemies_HorizLoop:
	;Offset enemy data for enemy spawn check
	tay
	lda ($08),y
	tay
CheckLevelEnemies_HorizLoop2:
	;Check for end of level screen enemy data
	lda ($0A),y
	bne CheckLevelEnemies_HorizNoNext
	jmp CheckLevelEnemies_HorizNext
CheckLevelEnemies_HorizNoNext:
	;Get level enemy X position
	sta $00
	and #$F0
	sta $01
	;Check if level enemy X position in range
	cmp $04
	beq CheckLevelEnemies_HorizInRangeX
CheckLevelEnemies_HorizNoInRange:
	iny
	lda ($0A),y
	asl
	iny
	bne CheckLevelEnemies_HorizNext2
CheckLevelEnemies_HorizInRangeX:
	;Get level enemy Y position
	lda $00
	asl
	asl
	asl
	asl
	sta $00
	;Check if level enemy Y position in range
	ldx $0E
	bne CheckLevelEnemies_HorizCheckBottom
	cmp $14
	bcc CheckLevelEnemies_HorizNoInRange
	bcs CheckLevelEnemies_HorizInRangeY
CheckLevelEnemies_HorizCheckBottom:
	ldx $0F
	bne CheckLevelEnemies_HorizInRangeY
	cmp $16
	bcs CheckLevelEnemies_HorizNoInRange
CheckLevelEnemies_HorizInRangeY:
	;Get level enemy slot index
	iny
	lda ($0A),y
	sta $06
	cmp #$80
	iny
	and #$1F
	tax
	;If enemy slot not free, go to next level enemy
	lda Enemy_ID,x
	bne CheckLevelEnemies_HorizNext2
	;Get level enemy ID
	lda ($0A),y
	sta $07
	;Set level enemy X position
	lda $01
	sec
	sbc TempMirror_PPUSCROLL_X
	sta Enemy_X+$08,x
	lda ScrollDirectionFlags
	lsr
	lda #$01
	bcs CheckLevelEnemies_HorizNoXC
	lda #$FF
CheckLevelEnemies_HorizNoXC:
	sta Enemy_XHi+$08,x
	;Set level enemy Y position
	lda $00
	sty $00
	ldy $03
	sec
	sbc TempMirror_PPUSCROLL_Y
	bcs CheckLevelEnemies_HorizNoYC
	sbc #$0F
	dey
CheckLevelEnemies_HorizNoYC:
	sta Enemy_Y+$08,x
	tya
	sta Enemy_YHi+$08,x
	;Init level enemy
	jsr SpawnLevelEnemy
CheckLevelEnemies_HorizNext2:
	;Loop for each enemy
	iny
	bcs CheckLevelEnemies_HorizNext
	jmp CheckLevelEnemies_HorizLoop2
CheckLevelEnemies_HorizNext:
	;Loop for each screen
	inc $03
	inc $0E
	dec $0F
	bmi CheckLevelEnemies_Vert
	clc
	lda $05
	adc LevelAreaWidth
	sta $05
	jmp CheckLevelEnemies_HorizLoop
CheckLevelEnemies_Vert:
	;Check to scroll vertically
	lda ScrollDirectionFlags
	and #$0C
	bne CheckLevelEnemies_VertCheck
CheckLevelEnemies_VertExit:
	rts
CheckLevelEnemies_VertCheck:
	lda SaveScrollY
	and #$F0
	sta $00
	lda TempMirror_PPUSCROLL_Y
	and #$F0
	cmp $00
	beq CheckLevelEnemies_VertExit
	;Get check right edge flag
	sec
	lda $13
	sbc $11
	sta $0F
	;Set Y position for spawning level enemies based on scroll direction
	lda ScrollDirectionFlags
	cmp #$08
	lda #$00
	ldy $14
	ldx $15
	bcs CheckLevelEnemies_VertUp
	ldy $16
	ldx $17
CheckLevelEnemies_VertUp:
	clc
	beq CheckLevelEnemies_VertY0
CheckLevelEnemies_VertScreenLoop:
	adc LevelAreaWidth
	dex
	bne CheckLevelEnemies_VertScreenLoop
CheckLevelEnemies_VertY0:
	adc $11
	sta $05
	sty $04
CheckLevelEnemies_VertLoop:
	;Offset enemy data for enemy spawn check
	tay
	lda ($08),y
	tay
CheckLevelEnemies_VertLoop2:
	;Check for end of level screen enemy data
	lda ($0A),y
	bne CheckLevelEnemies_VertNoNext
	jmp CheckLevelEnemies_VertNext
CheckLevelEnemies_VertNoNext:
	;Get level enemy Y position
	sta $00
	asl
	asl
	asl
	asl
	sta $01
	;Check if level enemy Y position in range
	lda $04
	and #$F0
	cmp $01
	beq CheckLevelEnemies_VertInRangeY
CheckLevelEnemies_VertNoInRange:
	iny
	lda ($0A),y
	asl
	iny
	bne CheckLevelEnemies_VertNext2
CheckLevelEnemies_VertInRangeY:
	;Get level enemy X position
	lda $00
	and #$F0
	sta $00
	;Check if level enemy X position in range
	ldx $0C
	bne CheckLevelEnemies_VertCheckRight
	cmp $10
	bcc CheckLevelEnemies_VertNoInRange
	bcs CheckLevelEnemies_VertInRangeX
CheckLevelEnemies_VertCheckRight:
	ldx $0F
	bne CheckLevelEnemies_VertInRangeX
	cmp $12
	bcs CheckLevelEnemies_VertNoInRange
CheckLevelEnemies_VertInRangeX:
	;Get level enemy slot index
	iny
	lda ($0A),y
	sta $06
	cmp #$80
	iny
	and #$1F
	tax
	;If enemy slot not free, go to next level enemy
	lda Enemy_ID,x
	bne CheckLevelEnemies_VertNext2
	;Get level enemy ID
	lda ($0A),y
	sta $07
	;Set level enemy Y position
	lda $01
	sec
	sbc TempMirror_PPUSCROLL_Y
	bcs CheckLevelEnemies_VertNoYC
	sbc #$0F
CheckLevelEnemies_VertNoYC:
	sta Enemy_Y+$08,x
	lda ScrollDirectionFlags
	cmp #$08
	lda #$FF
	bcs CheckLevelEnemies_VertNoYC2
	lda #$00
CheckLevelEnemies_VertNoYC2:
	sta Enemy_YHi+$08,x
	;Set level enemy X position
	lda $00
	sty $00
	ldy $02
	sec
	sbc TempMirror_PPUSCROLL_X
	bcs CheckLevelEnemies_VertNoXC
	dey
CheckLevelEnemies_VertNoXC:
	sta Enemy_X+$08,x
	tya
	sta Enemy_XHi+$08,x
	;Init level enemy
	jsr SpawnLevelEnemy
CheckLevelEnemies_VertNext2:
	;Loop for each enemy
	iny
	bcs CheckLevelEnemies_VertNext
	jmp CheckLevelEnemies_VertLoop2
CheckLevelEnemies_VertNext:
	;Loop for each screen
	inc $02
	inc $0C
	dec $0F
	bmi SpawnLevelEnemy_Exit
	clc
	inc $05
	lda $05
	jmp CheckLevelEnemies_VertLoop

SpawnLevelEnemy:
	;Init level enemy ID
	lda $07
	sta Enemy_ID,x
	;Check for enemy ID $F0-$FF
	cmp #$F0
	bcs SpawnLevelEnemy_F0
	;Check to spawn enemy on left side of screen
	tay
	lda EnemyInitialFlags,y
	bit $06
	bvc SpawnLevelEnemy_Right
	;Set screen left side spawn flag
	dec Enemy_Temp2,x
SpawnLevelEnemy_Right:
	;Init level enemy flags
	sta Enemy_Flags,x
	;Init level enemy HP
	lda EnemyInitialHP,y
	sta Enemy_HP,x
	asl $06
	ldy $00
SpawnLevelEnemy_Exit:
	rts
SpawnLevelEnemy_F0:
	;Check for enemy ID $F4-$FF
	cmp #$F4
	bcs SpawnLevelEnemy_Platform
	;Init level enemy flags
	lda #(EF_NOHITATTACK|$02)
	sta Enemy_Flags,x
	asl $06
	ldy $00
	rts
SpawnLevelEnemy_Platform:
	;Init level enemy flags
	tay
	lda EnemyPlatformInitialFlags-$F4,y
	sta Enemy_Flags,x
	asl $06
	ldy $00
	rts

;ENEMY INITIAL STATE DATA
EnemyInitialFlags:
	.db $00,$00,$00,$00,$00,$01,$01,$00,$04,$01,$C0,$00,$00,$07,$00,$01
	.db $01,$00,$00,$01,$00,$07,$00,$00,$07,$81,$00,$47,$01,$C0,$C0,$00
	.db $49,$49,$49,$49,$03,$00,$01,$01,$C0,$01,$07,$02,$01,$C0,$01,$00
	.db $E0,$0B,$01,$07,$E0,$01,$45,$03,$00,$21,$00,$0E,$00,$E0,$00,$C0
	.db $E0,$01,$E0,$00,$47,$E0,$00,$00,$00,$04,$00,$E0,$01,$51,$E0,$E0
	.db $E0,$00,$00,$00,$E0,$E0,$00,$00,$C0,$00,$00,$E0
EnemyInitialHP:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$10,$00,$00,$01,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$02,$00
	.db $02,$01,$00,$00,$00,$01,$00,$00,$01,$18,$00,$20,$00,$00,$00,$00
	.db $00,$01,$0C,$00,$00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00
	.db $00,$00,$02,$00,$00,$00,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00
EnemyPlatformInitialFlags:
	.db $4C,$4D,$00,$00,$00,$00,$00

;;;;;;;;;;;;
;ENEMY DATA;
;;;;;;;;;;;;
;LEVEL 1 ENEMY DATA
Level11EnemyLayoutData:
	.db $00,$00,$04,$16,$31,$46,$49,$00,$00,$00,$00
	.db $00,$01,$07,$1C,$3A,$00,$4F,$5E,$64,$73,$00
Level11EnemyData:
	;$00
	.db $00
	;$01
	.db $88,$8C,ENEMY_BGFLOORSCROLL
	;$04
	.db $9C,$C6,ENEMY_ZOMBIE
	;$07
	.db $2A,$42,ENEMY_ZOMBIE
	.db $4A,$03,ENEMY_ZOMBIE
	.db $6A,$04,ENEMY_ZOMBIE
	.db $8A,$05,ENEMY_ZOMBIE
	.db $EA,$87,ENEMY_ZOMBIE
	;$16
	.db $7C,$08,ENEMY_SKELETON
	.db $8C,$84,ENEMY_ZOMBIE
	;$1C
	.db $1A,$09,ENEMY_SKELETON
	.db $24,$03,ENEMY_SKELETON
	.db $42,$00,ENEMY_ITEMKEY
	.db $6A,$05,ENEMY_ZOMBIE
	.db $8A,$07,ENEMY_ZOMBIE
	.db $6A,$4A,ENEMY_ZOMBIE
	.db $EA,$8B,ENEMY_ZOMBIE
	;$31
	.db $AC,$06,ENEMY_ZOMBIE
	.db $CC,$07,ENEMY_SKELETON
	.db $FC,$82,ENEMY_ZOMBIE
	;$3A
	.db $2A,$03,ENEMY_ZOMBIE
	.db $6A,$04,ENEMY_SKELETON
	.db $AA,$05,ENEMY_ZOMBIE
	.db $EA,$89,ENEMY_ZOMBIE
	;$46
	.db $2C,$8B,ENEMY_ITEMHP
	;$49
	.db $26,$03,ENEMY_WITCHSPAWNER
	.db $A6,$84,ENEMY_WITCHSPAWNER
	;$4F
	.db $2A,$05,ENEMY_HUNCHBACK
	.db $82,$06,ENEMY_HUNCHBACK
	.db $AA,$07,ENEMY_HUNCHBACK
	.db $D2,$08,ENEMY_WITCHSPAWNER
	.db $E8,$89,ENEMY_WITCHSPAWNER
	;$5E
	.db $8A,$42,ENEMY_ZOMBIE
	.db $CA,$C3,ENEMY_ZOMBIE
	;$64
	.db $8A,$04,ENEMY_ZOMBIE
	.db $AA,$05,ENEMY_ZOMBIE
	.db $BA,$06,ENEMY_ZOMBIE
	.db $4A,$47,ENEMY_ZOMBIE
	.db $AA,$88,ENEMY_SKELETON
	;$73
	.db $0A,$0A,ENEMY_ZOMBIE
	.db $2A,$02,ENEMY_ZOMBIE
	.db $6A,$04,ENEMY_ZOMBIE
	.db $C8,$09,ENEMY_WARP
	.db $AA,$85,ENEMY_ZOMBIE
Level12EnemyLayoutData:
	.db $00,$00,$00,$00,$16,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$01,$10,$25,$34,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$3A,$49,$58,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$43,$52,$5B,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$61,$73,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$64,$76,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$79,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$82,$8B,$97,$A9,$00
Level12EnemyData:
	;$00
	.db $00
	;$01
	.db $48,$02,ENEMY_ZOMBIE
	.db $68,$03,ENEMY_ZOMBIE
	.db $88,$0A,ENEMY_SKELETON
	.db $C8,$04,ENEMY_ZOMBIE
	.db $D8,$85,ENEMY_ZOMBIE
	;$10
	.db $42,$02,ENEMY_ITEMHP
	.db $48,$CB,ENEMY_BEAST
	;$16
	.db $05,$4C,ENEMY_BEAST
	.db $25,$06,ENEMY_BEAST
	.db $65,$07,ENEMY_BEAST
	.db $A5,$08,ENEMY_BEAST
	.db $E2,$8D,ENEMY_WINGEDPANTHER
	;$25
	.db $28,$09,ENEMY_BEAST
	.db $68,$03,ENEMY_BEAST
	.db $68,$4E,ENEMY_BEAST
	.db $92,$0F,ENEMY_WINGEDPANTHER
	.db $C8,$D0,ENEMY_BEAST
	;$34
	.db $78,$0A,ENEMY_WINGEDPANTHER
	.db $89,$8D,ENEMY_WINGEDPANTHER
	;$3A
	.db $51,$03,ENEMY_BEAST
	.db $59,$51,ENEMY_BEAST
	.db $D9,$85,ENEMY_BEAST
	;$43
	.db $C2,$4B,ENEMY_BEAST
	.db $E2,$CC,ENEMY_BEAST
	;$49
	.db $80,$06,ENEMY_BEAST
	.db $33,$0E,ENEMY_WINGEDPANTHER
	.db $AC,$8F,ENEMY_WINGEDPANTHER
	;$52
	.db $52,$06,ENEMY_BEAST
	.db $DA,$87,ENEMY_BEAST
	;$58
	.db $08,$82,ENEMY_BEAST
	;$5B
	.db $81,$03,ENEMY_BEAST
	.db $46,$90,ENEMY_WINGEDPANTHER
	;$61
	.db $83,$84,ENEMY_ZOMBIE
	;$64
	.db $54,$08,ENEMY_ZOMBIE
	.db $54,$11,ENEMY_SKELETON
	.db $BC,$09,ENEMY_ZOMBIE
	.db $CC,$0A,ENEMY_SKELETON
	.db $DC,$82,ENEMY_ZOMBIE
	;$73
	.db $0B,$85,ENEMY_ZOMBIE
	;$76
	.db $84,$86,ENEMY_ZOMBIE
	;$79
	.db $35,$0B,ENEMY_SKELETON
	.db $55,$0C,ENEMY_SKELETON
	.db $AD,$83,ENEMY_ZOMBIE
	;$82
	.db $16,$4D,ENEMY_BEAST
	.db $46,$4E,ENEMY_BEAST
	.db $C6,$CF,ENEMY_BEAST
	;$8B
	.db $16,$04,ENEMY_BEAST
	.db $36,$05,ENEMY_BEAST
	.db $66,$50,ENEMY_BEAST
	.db $86,$89,ENEMY_ITEMHP
	;$97
	.db $16,$06,ENEMY_BEAST
	.db $20,$11,ENEMY_WINGEDPANTHER
	.db $66,$07,ENEMY_BEAST
	.db $96,$08,ENEMY_BEAST
	.db $A6,$4C,ENEMY_BEAST
	.db $C0,$8B,ENEMY_WINGEDPANTHER
	;$A9
	.db $16,$0A,ENEMY_BEAST
	.db $36,$02,ENEMY_BEAST
	.db $76,$03,ENEMY_BEAST
	.db $80,$07,ENEMY_WINGEDPANTHER
	.db $BA,$09,ENEMY_WARP
	.db $E6,$84,ENEMY_BEAST
Level13EnemyLayoutData:
	.db $00,$00,$00
Level13EnemyData:
	;$00
	.db $C9,$82,ENEMY_LEVEL1BOSS

;LEVEL 2 ENEMY DATA
Level21EnemyLayoutData:
	.db $00,$61,$55,$46,$43,$00
	.db $00,$01,$07,$1F,$34,$00
Level21EnemyData:
	;$00
	.db $00
	;$01
	.db $88,$09,ENEMY_BGFLOORSCROLL
	.db $29,$CA,ENEMY_OGRE
	;$07
	.db $19,$02,ENEMY_OGRE
	.db $39,$03,ENEMY_OGRE
	.db $62,$0B,ENEMY_GHOST
	.db $69,$4C,ENEMY_OGRE
	.db $99,$4D,ENEMY_OGRE
	.db $A1,$01,ENEMY_ITEMKEY
	.db $D0,$05,ENEMY_OGRE
	.db $F9,$86,ENEMY_OGRE
	;$1F
	.db $14,$0E,ENEMY_GHOST
	.db $59,$4F,ENEMY_OGRE
	.db $95,$07,ENEMY_OGRE
	.db $B9,$02,ENEMY_OGRE
	.db $CA,$03,ENEMY_ITEMHP
	.db $E2,$10,ENEMY_GHOST
	.db $F9,$D1,ENEMY_OGRE
	;$34
	.db $19,$04,ENEMY_OGRE
	.db $B5,$0A,ENEMY_OGRE
	.db $B9,$07,ENEMY_OGRE
	.db $D0,$08,ENEMY_OGRE
	.db $D9,$8B,ENEMY_OGRE
	;$43
	.db $C7,$06,ENEMY_ITEMHP
	;$46
	.db $D6,$4A,ENEMY_CERBERUS
	.db $A6,$0B,ENEMY_GOBLIN
	.db $53,$02,ENEMY_GOBLIN
	.db $59,$03,ENEMY_CERBERUS
	.db $19,$C4,ENEMY_CERBERUS
	;$55
	.db $D6,$06,ENEMY_GOBLIN
	.db $C9,$07,ENEMY_CERBERUS
	.db $49,$09,ENEMY_CERBERUS
	.db $36,$8A,ENEMY_GOBLIN
	;$61
	.db $42,$0B,ENEMY_WARP
	.db $D9,$8C,ENEMY_CERBERUS
Level22EnemyLayoutData:
	.db $00,$01,$07,$10,$28,$3A,$49,$52,$6D,$7C,$00
	.db $00,$00,$00,$00,$00,$7C,$7C,$7C,$7D,$8C,$00
Level22EnemyData:
	;$00
	.db $00
	;$01
	.db $E7,$42,ENEMY_GHOUL
	.db $F6,$8A,ENEMY_OGRE
	;$07
	.db $56,$0B,ENEMY_OGRE
	.db $76,$0C,ENEMY_OGRE
	.db $D2,$C5,ENEMY_ROC
	;$10
	.db $17,$47,ENEMY_GHOUL
	.db $27,$06,ENEMY_GHOUL
	.db $57,$08,ENEMY_GHOUL
	.db $67,$49,ENEMY_GHOUL
	.db $77,$0B,ENEMY_GHOUL
	.db $97,$0A,ENEMY_ITEMHP
	.db $A1,$04,ENEMY_ROC
	.db $E2,$85,ENEMY_ROC
	;$28
	.db $13,$06,ENEMY_ROC
	.db $77,$08,ENEMY_GHOUL
	.db $96,$4B,ENEMY_OGRE
	.db $C6,$42,ENEMY_OGRE
	.db $D7,$03,ENEMY_GHOUL
	.db $F6,$C4,ENEMY_OGRE
	;$3A
	.db $66,$46,ENEMY_OGRE
	.db $86,$07,ENEMY_OGRE
	.db $A2,$08,ENEMY_GHOST
	.db $D6,$09,ENEMY_OGRE
	.db $E5,$8A,ENEMY_GHOST
	;$49
	.db $06,$11,ENEMY_OGRE
	.db $21,$02,ENEMY_GHOST
	.db $43,$83,ENEMY_GHOST
	;$52
	.db $07,$0C,ENEMY_STOVEFLAME
	.db $67,$05,ENEMY_ITEMHP
	.db $56,$0B,ENEMY_OGRE
	.db $66,$4D,ENEMY_OGRE
	.db $86,$0E,ENEMY_OGRE
	.db $A2,$0F,ENEMY_GHOST
	.db $C7,$90,ENEMY_STOVEFLAME
	;
	.db $D6,$11,ENEMY_OGRE
	.db $E5,$82,ENEMY_GHOST
	;$6D
	.db $0D,$07,ENEMY_ITEMHP
	.db $47,$08,ENEMY_STOVEFLAME
	.db $56,$03,ENEMY_OGRE
	.db $66,$05,ENEMY_OGRE
	.db $77,$89,ENEMY_ITEMHP
	;$7C
	.db $00
	;$7D
	.db $1A,$04,ENEMY_ITEMHP
	.db $3A,$02,ENEMY_ITEMHP
	.db $6A,$49,ENEMY_GHOUL
	.db $96,$4A,ENEMY_ROC
	.db $AA,$80,ENEMY_ITEMKEY
	;$8C
	.db $9A,$04,ENEMY_GHOUL
	.db $A7,$05,ENEMY_ROC
	.db $DC,$06,ENEMY_WARP
	.db $EA,$07,ENEMY_GHOUL
	.db $F5,$88,ENEMY_ROC
Level23EnemyLayoutData:
	.db $00,$00,$00
Level23EnemyData:
	;$00
	.db $E8,$82,ENEMY_LEVEL2BOSS

;LEVEL 3 ENEMY DATA
Level31EnemyLayoutData:
	.db $00,$00,$04,$00,$00,$00,$00,$00,$00,$00
	.db $0A,$01,$0D,$1C,$2E,$37,$3D,$4F,$00,$00
	.db $00,$00,$0D,$00,$00,$00,$49,$55,$64,$00
Level31EnemyData:
	;$00
	.db $00
	;$01
	.db $C4,$8B,ENEMY_ITEMHP
	;$04
	.db $24,$06,ENEMY_CATOBLEPAS
	.db $1E,$89,ENEMY_CATOBLEPAS
	;
	.db $F1,$8C,ENEMY_CATOBLEPAS
	;$0D
	.db $09,$02,ENEMY_HANIVER
	.db $67,$47,ENEMY_CATOBLEPAS
	.db $83,$08,ENEMY_CATOBLEPAS
	.db $8A,$03,ENEMY_HANIVER
	.db $C5,$89,ENEMY_CATOBLEPAS
	;$1C
	.db $0B,$04,ENEMY_HANIVER
	.db $67,$0B,ENEMY_CATOBLEPAS
	.db $87,$0C,ENEMY_CATOBLEPAS
	.db $A7,$0D,ENEMY_CATOBLEPAS
	.db $CB,$06,ENEMY_ITEMHP
	.db $EB,$85,ENEMY_ITEMHP
	;$2E
	.db $09,$02,ENEMY_GOLFBALL
	.db $4B,$03,ENEMY_GOLFBALL
	.db $CC,$84,ENEMY_GOLFBALL
	;$37
	.db $84,$4C,ENEMY_HYDRA
	.db $84,$C6,ENEMY_HYDRA
	;$3D
	.db $4A,$08,ENEMY_HYDRA
	.db $6C,$09,ENEMY_HYDRA
	.db $8B,$0A,ENEMY_HYDRA
	.db $CD,$82,ENEMY_HYDRA
	;$49
	.db $40,$07,ENEMY_GOLFBALL
	.db $A1,$8B,ENEMY_GOLFBALL
	;$4F
	.db $8D,$09,ENEMY_HYDRA
	.db $CE,$8B,ENEMY_HYDRA
	;$55
	.db $02,$03,ENEMY_GOLFBALL
	.db $10,$06,ENEMY_HYDRA
	.db $63,$48,ENEMY_HYDRA
	.db $A0,$0A,ENEMY_HYDRA
	.db $E2,$82,ENEMY_HYDRA
	;$64
	.db $65,$04,ENEMY_ITEMHP
	.db $41,$4C,ENEMY_HYDRA
	.db $82,$07,ENEMY_HYDRA
	.db $E8,$85,ENEMY_WARP
Level32EnemyLayoutData:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$01,$04,$0D,$16,$22,$31,$3A,$46,$52,$00
Level32EnemyData:
	;$00
	.db $00
	;$01
	.db $11,$8E,ENEMY_LEVEL3FALLSTART
	;$04
	.db $C6,$09,ENEMY_BGWATERFALL
	.db $C2,$02,ENEMY_CHARONSPAWNER
	.db $C9,$C5,ENEMY_CHARON
	;$0D
	.db $79,$06,ENEMY_CHARON
	.db $86,$0A,ENEMY_BGWATERFALL
	.db $82,$83,ENEMY_CHARONSPAWNER
	;$16
	.db $46,$0B,ENEMY_BGWATERFALL
	.db $C9,$09,ENEMY_ITEMHP
	.db $39,$07,ENEMY_CHARON
	.db $42,$84,ENEMY_CHARONSPAWNER
	;$22
	.db $81,$0C,ENEMY_BGWATERSCROLL
	.db $89,$08,ENEMY_TRITON
	.db $A9,$06,ENEMY_TRITON
	.db $C9,$47,ENEMY_TRITON
	.db $E9,$89,ENEMY_TRITON
	;$31
	.db $49,$0A,ENEMY_TRITON
	.db $89,$0B,ENEMY_TRITON
	.db $C9,$8C,ENEMY_TRITON
	;$3A
	.db $2B,$03,ENEMY_LEVEL3PLATFORM
	.db $49,$4D,ENEMY_TRITON
	.db $89,$4E,ENEMY_TRITON
	.db $C9,$CF,ENEMY_TRITON
	;$46
	.db $09,$10,ENEMY_TRITON
	.db $49,$11,ENEMY_TRITON
	.db $69,$44,ENEMY_TRITON
	.db $A9,$85,ENEMY_TRITON
	;$52
	.db $19,$06,ENEMY_TRITON
	.db $B9,$08,ENEMY_ITEMHP
	.db $69,$07,ENEMY_TRITON
	.db $E9,$82,ENEMY_WARP
Level33EnemyLayoutData:
	.db $00,$00,$00
	.db $00,$00,$00
Level33EnemyData:
	;$00
	.db $8C,$82,ENEMY_LEVEL3BOSS

;LEVEL 4 ENEMY DATA
Level41EnemyLayoutData:
	.db $00,$91,$88,$7C,$6D,$61,$55,$00,$4C,$46,$3D,$2E,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$28,$1F,$16,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$01,$00,$00
Level41EnemyData:
	;$00
	.db $00
	;$01
	.db $D9,$02,ENEMY_HOBGOBLIN
	.db $C1,$03,ENEMY_HARPYSPAWNER
	.db $99,$04,ENEMY_HOBGOBLIN
	.db $21,$05,ENEMY_HARPYSPAWNER
	.db $19,$86,ENEMY_HOBGOBLIN
	;$10
	.db $39,$0A,ENEMY_ITEMHP
	.db $89,$87,ENEMY_HOBGOBLIN
	;$16
	.db $2C,$07,ENEMY_HARPYSPAWNER
	.db $A6,$03,ENEMY_HARPYSPAWNER
	.db $20,$82,ENEMY_HARPYSPAWNER
	;$1F
	.db $8C,$08,ENEMY_HARPYSPAWNER
	.db $82,$04,ENEMY_HARPYSPAWNER
	.db $04,$86,ENEMY_HARPYSPAWNER
	;$28
	.db $60,$02,ENEMY_HARPYSPAWNER
	.db $6E,$83,ENEMY_HARPYSPAWNER
	;$2E
	.db $01,$09,ENEMY_LEVEL4FENCESCROLL
	.db $F1,$09,ENEMY_LEVEL4FENCESCROLL
	.db $C9,$45,ENEMY_HOBGOBLIN
	.db $B9,$07,ENEMY_HOBGOBLIN
	.db $89,$CA,ENEMY_HOBGOBLIN
	;$3D
	.db $E9,$03,ENEMY_HOBGOBLIN
	.db $C9,$08,ENEMY_HOBGOBLIN
	.db $49,$C4,ENEMY_HOBGOBLIN
	;$46
	.db $A9,$0B,ENEMY_ITEMHP
	.db $79,$8C,ENEMY_HOBGOBLIN
	;$4C
	.db $F9,$0D,ENEMY_HOBGOBLIN
	.db $A9,$0F,ENEMY_HOBGOBLIN
	.db $88,$87,ENEMY_LEVEL4CRANE
	;$55
	.db $82,$11,ENEMY_BABAYAGA
	.db $19,$0C,ENEMY_ITEMHP
	.db $44,$02,ENEMY_BABAYAGA
	.db $28,$83,ENEMY_BABAYAGA
	;$61
	.db $C3,$04,ENEMY_BABAYAGA
	.db $85,$05,ENEMY_BABAYAGA
	.db $44,$06,ENEMY_BABAYAGA
	.db $06,$88,ENEMY_BABAYAGA
	;$6D
	.db $E2,$09,ENEMY_BABAYAGA
	.db $A6,$0A,ENEMY_BABAYAGA
	.db $65,$0B,ENEMY_BABAYAGA
	.db $41,$0C,ENEMY_BABAYAGA
	.db $07,$8D,ENEMY_BABAYAGA
	;$7C
	.db $C4,$0E,ENEMY_BABAYAGA
	.db $86,$0F,ENEMY_BABAYAGA
	.db $42,$10,ENEMY_BABAYAGA
	.db $18,$91,ENEMY_KALI
	;$88
	.db $95,$02,ENEMY_KALI
	.db $37,$09,ENEMY_ITEMHP
	.db $17,$83,ENEMY_KALI
	;$91
	.db $94,$04,ENEMY_KALI
	.db $17,$05,ENEMY_KALI
	.db $18,$87,ENEMY_WARP
Level42EnemyLayoutData:
	.db $00,$00,$00,$00,$00,$00,$67,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$3A,$46,$52,$5B,$61,$00,$00
	.db $00,$00,$2E,$00,$00,$00,$00,$00
	.db $00,$25,$19,$00,$00,$00,$00,$00
	.db $00,$10,$00,$00,$00,$00,$00,$00
	.db $00,$07,$0A,$00,$00,$00,$00,$00
	.db $00,$00,$01,$00,$00,$00,$00,$00
Level42EnemyData:
	;$00
	.db $00
	;$01
	.db $2A,$0B,ENEMY_CHIMERA
	.db $6A,$8C,ENEMY_CHIMERA
	;$07
	.db $BB,$82,ENEMY_REDCAP
	;$0A
	.db $22,$03,ENEMY_REDCAP
	.db $41,$85,ENEMY_REDCAP
	;$10
	.db $E7,$04,ENEMY_REDCAP
	.db $D7,$06,ENEMY_REDCAP
	.db $C6,$88,ENEMY_REDCAP
	;$19
	.db $0D,$07,ENEMY_REDCAP
	.db $2C,$09,ENEMY_REDCAP
	.db $4B,$0B,ENEMY_REDCAP
	.db $03,$8A,ENEMY_REDCAP
	;$25
	.db $E2,$0C,ENEMY_REDCAP
	.db $D2,$0E,ENEMY_REDCAP
	.db $C1,$90,ENEMY_REDCAP
	;$2E
	.db $27,$0D,ENEMY_REDCAP
	.db $37,$0F,ENEMY_REDCAP
	.db $46,$11,ENEMY_REDCAP
	.db $56,$83,ENEMY_REDCAP
	;$3A
	.db $FD,$04,ENEMY_REDCAP
	.db $EC,$06,ENEMY_REDCAP
	.db $CB,$08,ENEMY_REDCAP
	.db $BB,$8A,ENEMY_REDCAP
	;$46
	.db $0D,$02,ENEMY_REDCAP
	.db $05,$0B,ENEMY_ITEMHP
	.db $65,$07,ENEMY_CHIMERA
	.db $C5,$89,ENEMY_CHIMERA
	;$52
	.db $25,$03,ENEMY_CHIMERA
	.db $65,$04,ENEMY_CHIMERA
	.db $A5,$86,ENEMY_CHIMERA
	;$5B
	.db $65,$07,ENEMY_ITEMHP
	.db $F1,$88,ENEMY_HARPYSPAWNER2
	;$61
	.db $01,$09,ENEMY_HARPYSPAWNER2
	.db $A8,$8A,ENEMY_LEVEL4ELEVATOR
	;$67
	.db $4A,$02,ENEMY_ITEMHP
	.db $8A,$04,ENEMY_ITEMHP
	.db $C8,$83,ENEMY_WARP
Level43EnemyLayoutData:
	.db $00,$00,$00,$00
	.db $00,$00,$00,$00
	.db $00,$00,$00,$00
Level43EnemyData:
	;$00
	.db $88,$02,ENEMY_LEVEL4BOSS
	.db $80,$83,ENEMY_LEVEL4BOSSCRANE

;LEVEL 5 ENEMY DATA
Level51EnemyLayoutData:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$52,$5B,$67,$00,$00,$00,$00
	.db $00,$01,$07,$1C,$31,$3D,$49,$00,$00,$5E,$73,$7C,$85,$94,$00
Level51EnemyData:
	;$00
	.db $00
	;$01
	.db $29,$42,ENEMY_KARNACK
	.db $A9,$C3,ENEMY_KARNACK
	;$07
	.db $09,$44,ENEMY_KARNACK
	.db $39,$05,ENEMY_KARNACK
	.db $89,$07,ENEMY_KARNACK
	.db $A2,$08,ENEMY_TENGU
	.db $B9,$49,ENEMY_KARNACK
	.db $C1,$0A,ENEMY_TENGU
	.db $D3,$CB,ENEMY_TENGU
	;$1C
	.db $19,$0C,ENEMY_KARNACK
	.db $22,$0D,ENEMY_TENGU
	.db $79,$0F,ENEMY_KARNACK
	.db $91,$50,ENEMY_TENGU
	.db $A2,$11,ENEMY_TENGU
	.db $C9,$05,ENEMY_KARNACK
	.db $C2,$87,ENEMY_TENGU
	;$31
	.db $11,$08,ENEMY_TENGU
	.db $53,$0A,ENEMY_TENGU
	.db $81,$42,ENEMY_TENGU
	.db $A2,$83,ENEMY_TENGU
	;$3D
	.db $01,$04,ENEMY_TENGU
	.db $62,$06,ENEMY_TENGU
	.db $C1,$0C,ENEMY_TENGU
	.db $79,$8D,ENEMY_KARNACK
	;$49
	.db $F9,$08,ENEMY_ITEMHP
	.db $02,$0F,ENEMY_TENGU
	.db $C3,$91,ENEMY_TENGU
	;$52
	.db $D8,$10,ENEMY_COCKATRICE
	.db $BA,$01,ENEMY_ITEMSCREW
	.db $FE,$91,ENEMY_COATLICUE
	;$5B
	.db $C6,$C4,ENEMY_COCKATRICE
	;$5E
	.db $23,$05,ENEMY_COCKATRICE
	.db $A9,$47,ENEMY_COATLICUE
	.db $E9,$C8,ENEMY_COATLICUE
	;$67
	.db $56,$02,ENEMY_ITEMHP
	.db $D6,$07,ENEMY_ITEMHP
	.db $06,$05,ENEMY_COCKATRICE
	.db $E6,$87,ENEMY_COCKATRICE
	;$73
	.db $19,$49,ENEMY_COATLICUE
	.db $59,$0A,ENEMY_COATLICUE
	.db $E9,$CD,ENEMY_COATLICUE
	;$7C
	.db $04,$03,ENEMY_COCKATRICE
	.db $49,$44,ENEMY_COATLICUE
	.db $A3,$86,ENEMY_COCKATRICE
	;$85
	.db $19,$08,ENEMY_COATLICUE
	.db $23,$09,ENEMY_COCKATRICE
	.db $49,$4A,ENEMY_COATLICUE
	.db $69,$0B,ENEMY_COATLICUE
	.db $C4,$8C,ENEMY_COCKATRICE
	;$94
	.db $59,$04,ENEMY_COATLICUE
	.db $84,$03,ENEMY_COCKATRICE
	.db $C8,$82,ENEMY_WARP
Level52EnemyLayoutData:
	.db $00,$00,$07,$16,$31,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$01,$0D,$28,$3A,$00,$46,$4C,$52,$55,$5B,$67,$76,$88,$8B,$00
Level52EnemyData:
	;$00
	.db $00
	;$01
	.db $80,$09,ENEMY_BGFLOORSCROLL
	.db $E3,$8F,ENEMY_ITEMHP
	;$07
	.db $6C,$42,ENEMY_KARNACK
	.db $A8,$84,ENEMY_TENGU
	;$0D
	.db $67,$05,ENEMY_KARNACK
	.db $E3,$00,ENEMY_ITEMSCREW
	.db $67,$CA,ENEMY_KARNACK
	;$16
	.db $09,$0B,ENEMY_TENGU
	.db $1C,$4C,ENEMY_KARNACK
	.db $2C,$0D,ENEMY_KARNACK
	.db $8C,$0F,ENEMY_KARNACK
	.db $A9,$50,ENEMY_TENGU
	.db $E8,$84,ENEMY_TENGU
	;$28
	.db $67,$50,ENEMY_KARNACK
	.db $B7,$11,ENEMY_KARNACK
	.db $E2,$85,ENEMY_KARNACK
	;$31
	.db $2C,$06,ENEMY_KARNACK
	.db $89,$08,ENEMY_TENGU
	.db $EC,$89,ENEMY_KARNACK
	;$3A
	.db $07,$0A,ENEMY_KARNACK
	.db $43,$0C,ENEMY_ITEMHP
	.db $82,$0E,ENEMY_KARNACK
	.db $C8,$8F,ENEMY_ITEMHP
	;$46
	.db $29,$42,ENEMY_MANTICORE
	.db $C9,$C3,ENEMY_MANTICORE
	;$4C
	.db $29,$04,ENEMY_MANTICORE
	.db $E9,$86,ENEMY_MANTICORE
	;$52
	.db $89,$87,ENEMY_MANTICORE
	;$55
	.db $D6,$04,ENEMY_ITEMHP
	.db $49,$88,ENEMY_MANTICORE
	;$5B
	.db $A4,$0A,ENEMY_BGCYCLOPS
	.db $A8,$4B,ENEMY_BGCYCLOPS
	.db $E4,$4C,ENEMY_BGCYCLOPS
	.db $F7,$8D,ENEMY_BGCYCLOPS
	;$67
	.db $37,$0E,ENEMY_BGCYCLOPS
	.db $55,$4F,ENEMY_BGCYCLOPS
	.db $77,$10,ENEMY_BGCYCLOPS
	.db $A4,$51,ENEMY_BGCYCLOPS
	.db $B7,$83,ENEMY_BGCYCLOPS
	;$76
	.db $44,$04,ENEMY_BGCYCLOPS
	.db $47,$05,ENEMY_BGCYCLOPS
	.db $75,$46,ENEMY_BGCYCLOPS
	.db $97,$07,ENEMY_BGCYCLOPS
	.db $C8,$48,ENEMY_BGCYCLOPS
	.db $D3,$8A,ENEMY_BGCYCLOPS
	;$88
	.db $89,$8D,ENEMY_MANTICORE
	;$8B
	.db $09,$0E,ENEMY_MANTICORE
	.db $69,$10,ENEMY_MANTICORE
	.db $A8,$82,ENEMY_WARP
Level53EnemyLayoutData:
	.db $00,$00,$00
Level53EnemyData:
	;$00
	.db $E9,$82,ENEMY_LEVEL5BOSS

;LEVEL 6 ENEMY DATA
Level61EnemyLayoutData:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$01,$07,$0A,$13,$19,$1A,$20,$35,$47,$56,$62,$68,$6E,$74,$7A,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$86,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$8F,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$98,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$A1,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$AA,$B0,$00
Level61EnemyData:
	;$00
	.db $00
	;$01
	.db $88,$02,ENEMY_LEVEL6FALLSTART
	.db $E9,$83,ENEMY_TREX
	;$07
	.db $E6,$84,ENEMY_TREX
	;$0A
	.db $52,$05,ENEMY_WATERDROPSPAWNER
	.db $86,$48,ENEMY_TREX
	.db $E6,$87,ENEMY_TREX
	;$13
	.db $52,$46,ENEMY_WATERDROPSPAWNER
	.db $E6,$89,ENEMY_TREX
	;$19
	.db $00
	;$1A
	.db $89,$0A,ENEMY_MINOTAUR
	.db $A9,$82,ENEMY_MINOTAUR
	;$20
	.db $42,$05,ENEMY_L6CRUSHERSPIKES
	.db $29,$43,ENEMY_MINOTAUR
	.db $49,$04,ENEMY_MINOTAUR
	.db $89,$08,ENEMY_MINOTAUR
	.db $A9,$49,ENEMY_MINOTAUR
	.db $C2,$06,ENEMY_L6CRUSHERSPIKES
	.db $E9,$C7,ENEMY_MINOTAUR
	;$35
	.db $08,$0B,ENEMY_LEVEL6CRUSHER
	.db $09,$0C,ENEMY_MINOTAUR
	.db $69,$0D,ENEMY_MINOTAUR
	.db $89,$4E,ENEMY_MINOTAUR
	.db $A9,$0F,ENEMY_MINOTAUR
	.db $E9,$90,ENEMY_MINOTAUR
	;$47
	.db $09,$4D,ENEMY_MINOTAUR
	.db $49,$4E,ENEMY_MINOTAUR
	.db $69,$0F,ENEMY_MINOTAUR
	.db $A9,$10,ENEMY_MINOTAUR
	.db $E9,$D1,ENEMY_MINOTAUR
	;$56
	.db $09,$02,ENEMY_MINOTAUR
	.db $49,$03,ENEMY_MINOTAUR
	.db $69,$04,ENEMY_MINOTAUR
	.db $A9,$85,ENEMY_MINOTAUR
	;$62
	.db $89,$06,ENEMY_MINOTAUR
	.db $E4,$87,ENEMY_GREATBEAST
	;$68
	.db $07,$08,ENEMY_MINOTAUR
	.db $89,$CA,ENEMY_MINOTAUR
	;$6E
	.db $A6,$02,ENEMY_GREATBEAST
	.db $C9,$86,ENEMY_MINOTAUR
	;$74
	.db $46,$03,ENEMY_GREATBEAST
	.db $A6,$84,ENEMY_GREATBEAST
	;$7A
	.db $4A,$05,ENEMY_ITEMHP
	.db $8A,$0A,ENEMY_ITEMHP
	.db $46,$08,ENEMY_GREATBEAST
	.db $C8,$89,ENEMY_LEVEL6ELEVATOR
	;$86
	.db $46,$02,ENEMY_BEHEMOTH
	.db $86,$03,ENEMY_BEHEMOTH
	.db $C6,$84,ENEMY_BEHEMOTH
	;$8F
	.db $46,$05,ENEMY_BEHEMOTH
	.db $86,$06,ENEMY_BEHEMOTH
	.db $C6,$87,ENEMY_BEHEMOTH
	;$98
	.db $46,$08,ENEMY_BEHEMOTH
	.db $86,$0A,ENEMY_BEHEMOTH
	.db $C6,$8B,ENEMY_BEHEMOTH
	;$A1
	.db $46,$0C,ENEMY_BEHEMOTH
	.db $86,$0D,ENEMY_BEHEMOTH
	.db $C6,$8E,ENEMY_BEHEMOTH
	;$AA
	.db $89,$02,ENEMY_TREX
	.db $C9,$C3,ENEMY_TREX
	;$B0
	.db $89,$04,ENEMY_TREX
	.db $DB,$8F,ENEMY_WARP
Level62EnemyLayoutData:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$01,$07,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$0A,$07,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$0D,$07,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$10,$07,$00,$00,$00,$00
	.db $00,$00,$13,$00,$00,$13,$07,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$19,$1C,$22,$00
Level62EnemyData:
	;$00
	.db $00
	;$01
	.db $7A,$05,ENEMY_ITEMHP
	.db $BA,$86,ENEMY_ITEMHP
	;$07
	.db $08,$89,ENEMY_LEVEL6ELEVATOR2
	;$0A
	.db $CA,$82,ENEMY_LEVEL1BOSS
	;$0D
	.db $C9,$82,ENEMY_LEVEL2BOSS
	;$10
	.db $8D,$82,ENEMY_LEVEL3BOSS
	;$13
	.db $88,$02,ENEMY_LEVEL4BOSS
	.db $80,$83,ENEMY_LEVEL4BOSSCRANE
	;$19
	.db $8C,$82,ENEMY_LEVEL5BOSS
	;$1C
	.db $8A,$07,ENEMY_ITEMHP
	.db $CA,$88,ENEMY_ITEMHP
	;$22
	.db $88,$82,ENEMY_LEVEL6BOSS
Level63EnemyLayoutData:
	.db $00

;;;;;;;;;;;;;;;;
;ENEMY ROUTINES;
;;;;;;;;;;;;;;;;
;$1D: Triton
Enemy1DJumpTable:
	.dw Enemy1D_Sub0	;$00  Init
	.dw Enemy1D_Sub1	;$01  Out
	.dw Enemy1D_Sub2	;$02  Main
	.dw Enemy1D_Sub3	;$03  In
	.dw Enemy1D_Sub4	;$04  Wait
;$00: Init
Enemy1D_Sub0:
	;Check if player is in range
	lda #$5F
	ldy Enemy_Temp2,x
	bpl Enemy1D_Sub0_Right
	lda #$1F
Enemy1D_Sub0_Right:
	jsr CheckPlayerInRangeSpawnVel
	tya
	bmi Enemy1D_Sub0_Exit
Enemy1D_Sub0_Next:
	;Set enemy Y position
	lda #$90
	sta Enemy_Y+$08,x
	;Load CHR bank
	lda #$2C
	sta TempCHRBanks+2
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	;Next task ($01: Out)
	inc Enemy_Mode,x
Enemy1D_Sub0_Exit:
	rts
;$01: Out
Enemy1D_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy1D_Sub0_Exit
	;Set enemy velocity/props/flags
	lda #$FB
	sta Enemy_YVel,x
	lda #$00
	sta Enemy_YVelLo,x
	lda Enemy_Temp2,x
	eor #$FF
	bmi Enemy1D_Sub1_Left
	lda #$01
Enemy1D_Sub1_Left:
	sta Enemy_XVel,x
	lsr
	and #$40
	sta Enemy_Props+$08,x
	lda Enemy_Flags,x
	and #(~(EF_NOHITENEMY|EF_NOHITATTACK))&$FF
	sta Enemy_Flags,x
	;Next task ($02: Main)
	inc Enemy_Mode,x
	;Play sound
	lda #SE_SPLASH
	jmp LoadSound
;$02: Main
Enemy1D_Sub2:
	;Update enemy animation
	ldy #$1E
	jsr UpdateEnemyAnimation_AnyY
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy1D_Sub2_NoYC
	inc Enemy_YVel,x
Enemy1D_Sub2_NoYC:
	;If enemy Y velocity up, exit early
	lda Enemy_YVel,x
	bmi Enemy1D_Sub0_Exit
	;If enemy Y position < $A0, exit early
	lda Enemy_Y+$08,x
	cmp #$98
	bcc Enemy1D_Sub0_Exit
	;Set enemy Y position/flags
	lda #$94
	sta Enemy_Y+$08,x
	lda Enemy_Flags,x
	ora #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags,x
	;Set animation timer
	lda #$10
	sta Enemy_Temp1,x
	;Set enemy sprite
	lda #$43
	sta Enemy_Sprite+$08,x
	;Next task ($03: In)
	inc Enemy_Mode,x
	;Play sound
	lda #SE_SPLASH
	jmp LoadSound
;$03: In
Enemy1D_Sub3:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy1D_Sub3_Next
	;If animation timer $08, set enemy sprite
	lda Enemy_Temp1,x
	cmp #$08
	bne Enemy1D_Sub3_Exit
	;Set enemy sprite
	lda #$44
	sta Enemy_Sprite+$08,x
	rts
Enemy1D_Sub3_Next:
	;Set enemy Y position
	lda #$90
	sta Enemy_Y+$08,x
	;Clear enemy sprite
	lda #$00
	sta Enemy_Sprite+$08,x
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Next task ($04: Wait)
	inc Enemy_Mode,x
Enemy1D_Sub3_Exit:
	rts
;$04: Wait
Enemy1D_Sub4:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy1D_Sub4_Exit
	;If enemy offscreen horizontally, exit early
	lda Enemy_XHi+$08,x
	beq Enemy1D_Sub4_Next
	;Set animation timer
	lda #$10
	sta Enemy_Temp1,x
Enemy1D_Sub4_Exit:
	rts
Enemy1D_Sub4_Next:
	;Find closest player
	jsr FindClosestPlayerX
	;Check if player is to left or right
	lda Enemy_X,y
	sbc Enemy_X+$08,x
	rol
	and #$01
	beq Enemy1D_Sub4_Right
	lda #$FF
Enemy1D_Sub4_Right:
	sta Enemy_Temp2,x
	;Clear enemy animation offset/timer
	lda #$00
	sta Enemy_AnimOffs,x
	sta Enemy_AnimTimer,x
	;Next task ($01: Out)
	sta Enemy_Mode,x
	jmp Enemy1D_Sub0_Next

;$19: Haniver
Enemy19JumpTable:
	.dw Enemy19_Sub0	;$00  Init
	.dw Enemy19_Sub1	;$01  Up
	.dw Enemy19_Sub2	;$02  Attack
	.dw Enemy19_Sub3	;$03  Wait
	.dw Enemy19_Sub4	;$04  Down
;$00: Init
Enemy19_Sub0:
	;Check if player is in range
	ldy #$01
Enemy19_Sub0_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc Enemy19_Sub0_PlayerNext
	;Get player X distance from enemy
	lda Enemy_XHi+$08,x
	beq Enemy19_Sub0_X0
	eor #$FF
	jmp Enemy19_Sub0_NoX0
Enemy19_Sub0_X0:
	lda Enemy_X+$08,x
Enemy19_Sub0_NoX0:
	sbc Enemy_X,y
	ror
	sta $01
	rol
	sta $00
	bcs Enemy19_Sub0_CheckD
	eor #$FF
	adc #$01
Enemy19_Sub0_CheckD:
	;If player X distance from enemy < $60, go to next task ($01: Up)
	cmp #$60
	bcc Enemy19_Sub0_Next
Enemy19_Sub0_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy19_Sub0_PlayerLoop
	rts
Enemy19_Sub0_Next:
	;Set enemy props
	lda $01
	lsr
	and #$40
	sta Enemy_Props+$08,x
	;Set attack counter
	lda #$03
	sta Enemy_Temp3,x
	;Load CHR bank
	lda #$2B
	sta TempCHRBanks+2
	;Next task ($01: Up)
	bne Enemy19_Sub1_ClearAnim
;$01: Up
Enemy19_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If enemy animation offset 0, set enemy flags
	lda Enemy_AnimOffs,x
	bne Enemy19_Sub1_CheckNext
	lda Enemy_Flags,x
	and #(~(EF_NOHITENEMY|EF_NOHITATTACK))&$FF
	sta Enemy_Flags,x
Enemy19_Sub1_Exit:
	rts
Enemy19_Sub1_CheckNext:
	;If enemy animation offset < $02, exit early
	cmp #$02
	bcc Enemy19_Sub1_Exit
	;Set animation timer
	lda #$30
	sta Enemy_Temp1,x
Enemy19_Sub1_ClearAnim:
	;Clear enemy animation offset/timer
	lda #$FF
	sta Enemy_AnimOffs,x
	sta Enemy_AnimTimer,x
Enemy19_Sub1_Next:
	;Next task ($02: Attack)
	inc Enemy_Mode,x
	rts
;$02: Attack
Enemy19_Sub2:
	;Set enemy sprite
	lda Enemy_Temp1,x
	ldy #$47
	cmp #$31
	bcs Enemy19_Sub2_IncSp
	cmp #$10
	bcs Enemy19_Sub2_SetSp
Enemy19_Sub2_IncSp:
	iny
Enemy19_Sub2_SetSp:
	tya
	sta Enemy_Sprite+$08,x
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy19_Sub1_Exit
	;Spawn projectile
	jsr HaniverAttackSub
	;Decrement attack counter, check if 0
	dec Enemy_Temp3,x
	beq Enemy19_Sub1_Next
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	rts
;$03: Wait
Enemy19_Sub3:
	;Update enemy animation
	ldy #$0E
	jsr UpdateEnemyAnimation_AnyY
	;If enemy animation offset 0, set enemy flags
	lda Enemy_AnimOffs,x
	bne Enemy19_Sub3_CheckNext
	lda Enemy_Flags,x
	ora #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags,x
	rts
Enemy19_Sub3_CheckNext:
	;If enemy animation offset < $03, exit early
	cmp #$03
	bcc Enemy19_Sub1_Exit
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Next task ($04: Down)
	inc Enemy_Mode,x
	rts
;$04: Down
Enemy19_Sub4:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy19_Sub1_Exit
	;If enemy offscreen horizontally, exit early
	lda Enemy_XHi+$08,x
	beq Enemy19_Sub4_Next
	;Set animation timer
	lda #$10
	sta Enemy_Temp1,x
	rts
Enemy19_Sub4_Next:
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy props
	lda Enemy_X+$08,x
	cmp Enemy_X,y
	lda #$00
	ror
	lsr
	sta Enemy_Props+$08,x
	;Next task ($04: Up)
	lda #$01
	sta Enemy_Mode,x
	;Set attack counter
	lda #$03
	sta Enemy_Temp3,x
	;Clear enemy animation offset/timer
	lda #$FF
	sta Enemy_AnimOffs,x
	sta Enemy_AnimTimer,x
Enemy19_Sub4_Exit:
	rts
HaniverAttackSub:
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy19_Sub4_Exit
	;Offset projectile Y position
	txa
	tay
	ldx CurEnemyIndex
	lda #$00
	jsr OffsetEnemyYPos
	;Set projectile velocity
	lda Enemy_Props+$08,y
	tax
	beq HaniverAttackSub_Right
	ldx #$01
HaniverAttackSub_Right:
	lda HaniverFireXVelocity,x
	sta Enemy_XVel,y
	lda #$00
	sta Enemy_XVelLo,y
	lda HaniverFireYVelocity,x
	sta Enemy_YVel,y
	lda HaniverFireYVelocityLo,x
	sta Enemy_YVelLo,y
	;Set enemy ID $1A (Haniver fire)
	lda #ENEMY_HANIVERFIRE
	sta Enemy_ID,y
	;Set enemy flags
	lda #$02
	sta Enemy_Flags,y
	;Set animation timer
	lda #$01
	sta Enemy_Temp1,y
	;Set enemy sprite
	lda #$49
	sta Enemy_Sprite+$08,y
	;Restore X register
	ldx CurEnemyIndex
	;Play sound
	lda #SE_HANIVERFIRE
	jmp LoadSound
HaniverFireXVelocity:
	.db $02,$FE
HaniverFireYVelocity:
	.db $00,$FF
HaniverFireYVelocityLo:
	.db $40,$C0

;$1A: Haniver fire
Enemy1AJumpTable:
	.dw Enemy1A_Sub0	;$00  Init
	.dw Enemy1A_Sub1	;$01  Main
;$00: Init
Enemy1A_Sub0:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy1A_Sub1_NoClear
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
Enemy1A_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If enemy X screen >= $04, clear enemy
	lda Enemy_X+$08,x
	adc TempMirror_PPUSCROLL_X
	lda Enemy_XHi+$08,x
	adc CurScreenX
	cmp #$04
	bcc Enemy1A_Sub1_NoClear
	jmp ClearEnemy
Enemy1A_Sub1_NoClear:
	;Move enemy
	jmp MoveEnemyXY

;$1B: Golf ball
Enemy1BJumpTable:
	.dw Enemy1B_Sub0	;$00  Init
	.dw Enemy1B_Sub1	;$01  Main
;$00: Init
Enemy1B_Sub0:
	;If enemy to right of screen bounds, exit early
	lda Enemy_XHi+$08,x
	bpl Enemy1B_Sub1_Exit
	;Load CHR bank
	lda #$2A
	sta TempCHRBanks+2
	;Set enemy X velocity to target player
	lda #$0A
	jmp SetEnemyXVel
;$01: Main
Enemy1B_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy1B_Sub1_NoYC
	inc Enemy_YVel,x
Enemy1B_Sub1_NoYC:
	;If enemy Y velocity up, exit early
	lda Enemy_YVel,x
	bmi Enemy1B_Sub1_Exit
Enemy1B_Sub1_CheckSlope:
	;If no ground collision, exit early
	ldy #$05
	jsr EnemyGetGroundCollision_AnyY
	sec
	sbc #$09
	bcc Enemy1B_Sub1_Exit
	;Check for slope top collision type
	cmp #$0A
	beq Enemy1B_Sub1_SlopeTop
	;Check for 7.5 deg. slope right collision types
	bcc Enemy1B_Sub1_SlopeRight
	clc
Enemy1B_Sub1_Exit:
	rts
Enemy1B_Sub1_SlopeTop:
	;Set enemy grounded
	clc
	lda $0A
	adc TempMirror_PPUSCROLL_Y
	and #$0F
	sta $00
	lda Enemy_Y+$08,x
	clc
	sbc $00
	bcs Enemy1B_Sub1_SlopeTopNoYC
	dec Enemy_YHi+$08,x
	sbc #$0F
Enemy1B_Sub1_SlopeTopNoYC:
	sta Enemy_Y+$08,x
	jmp Enemy1B_Sub1_CheckSlope
Enemy1B_Sub1_SlopeRight:
	;Get collision tile X offset
	tay
	lda TempMirror_PPUSCROLL_X
	adc $08
	and #$08
	cmp #$08
	tya
	rol
	sta $00
	lda TempMirror_PPUSCROLL_Y
	adc $0A
	and #$0F
	sec
	sbc $00
	;Check if above or below slope
	bcc Enemy1B_Sub1_Exit
	beq Enemy1B_Sub1_SlopeNoSetY
	;Set enemy grounded
	sta $00
	lda Enemy_Y+$08,x
	sbc $00
	bcs Enemy1B_Sub1_SlopeRightNoYC
	dec Enemy_YHi+$08,x
	sbc #$0F
Enemy1B_Sub1_SlopeRightNoYC:
	sta Enemy_Y+$08,x
Enemy1B_Sub1_SlopeNoSetY:
	;If enemy not active, don't play sound
	lda Enemy_ID,x
	cmp #ENEMY_GOLFBALL
	bne Enemy1B_Sub1_NoSound
	;Play sound
	lda #SE_GOLFBALL
	jsr LoadSound
Enemy1B_Sub1_NoSound:
	;Set enemy Y velocity
	lda #$FE
	sta Enemy_YVel,x
	lda #$00
	sta Enemy_YVelLo,x
	sec
Enemy1C_Sub0_Exit:
	rts

;$1C: Catoblepas
Enemy1CJumpTable:
	.dw Enemy1C_Sub0	;$00  Init
	.dw Enemy1C_Sub1	;$01  Fly
	.dw Enemy1C_Sub2	;$02  Dive
;$00: Init
Enemy1C_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	bmi Enemy1C_Sub0_Exit
	;If player offscreen vertically, exit early
	lda Enemy_YHi,x
	bne Enemy1C_Sub0_Exit
	;Check if enemy offscreen
	lda Enemy_XHi+$08,x
	beq Enemy1C_Sub0_Next
	lda Enemy_YHi+$08,x
	bmi Enemy1C_Sub0_Next
	bne Enemy1C_Sub0_Exit
	;Find closest player
	jsr FindClosestPlayerX
	;If player Y position <= enemy Y position, exit early
	lda Enemy_Y+$08,x
	cmp Enemy_Y,y
	bcs Enemy1C_Sub0_Exit
Enemy1C_Sub0_Next:
	;Set enemy target Y position
	jsr InitEnemyTargetYPos
	;Set animation timer
	lda #$04
	sta Enemy_Temp1,x
	;Set enemy X velocity to target player
	lda #$02
	jmp SetEnemyXVel
;$01: Fly
Enemy1C_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Adjust enemy Y velocity to target Y position
	jsr UpdateEnemyTargetYPos
	;If enemy offscreen horizontally, skip this part
	lda Enemy_XHi+$08,x
	bne Enemy1C_Sub1_NoFlip
	;Find closest player
	jsr FindClosestPlayerX
	sty CatoblepasPlayerIndex
	;If player X distance from enemy < $40, don't flip enemy X
	lda Enemy_X,y
	sbc Enemy_X+$08,x
	sta $00
	lda #$00
	sbc Enemy_XHi+$08,x
	bne Enemy1C_Sub1_NoCheckFlip
	lda $00
	adc #$40
	cmp #$80
	bcc Enemy1C_Sub1_NoFlip
Enemy1C_Sub1_NoCheckFlip:
	;If player behind enemy, flip enemy X
	lda Enemy_XHi+$08,x
	beq Enemy1C_Sub1_X0
	eor #$80
	asl
	bne Enemy1C_Sub1_NoX0
Enemy1C_Sub1_X0:
	lda Enemy_X+$08,x
	cmp Enemy_X,y
Enemy1C_Sub1_NoX0:
	ror
	lsr
	eor Enemy_Props+$08,x
	and #$40
	beq Enemy1C_Sub1_NoFlip
	;Flip enemy X
	jsr FlipEnemyX
Enemy1C_Sub1_NoFlip:
	;Move enemy
	jsr MoveEnemyXY
	;If enemy offscreen, exit early
	lda Enemy_YHi+$08,x
	ora Enemy_XHi+$08,x
	bne Enemy1C_Sub1_Exit
	;If bits 0-3 of global timer != enemy slot index, exit early
	lda GlobalTimer
	and #$0F
	cmp CurEnemyIndex
	bne Enemy1C_Sub1_Exit
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy1C_Sub1_Exit
	;If player offscreen vertically or enemy is offscreen, exit early
	ldy CatoblepasPlayerIndex
	lda Enemy_YHi,y
	ora Enemy_YHi+$08,x
	ora Enemy_XHi+$08,x
	beq Enemy1C_Sub1_Dive
	;Increment animation timer
	inc Enemy_Temp1,x
Enemy1C_Sub1_Exit:
	rts
Enemy1C_Sub1_Dive:
	;Get player X distance from enemy
	sta $03
	lda Enemy_X,y
	sbc Enemy_X+$08,x
	bcs Enemy1C_Sub1_NoXC
	dec $03
	eor #$FF
	adc #$01
	cmp #$20
	bcc Enemy1C_Sub1_SetX
	sbc #$10
	bne Enemy1C_Sub1_SetX
Enemy1C_Sub1_NoXC:
	adc #$1F
Enemy1C_Sub1_SetX:
	sta $01
	;Get player Y distance from enemy
	lda Enemy_Y,y
	sbc Enemy_Y+$08,x
	bcs Enemy1C_Sub1_NoYC
	lda #$10
Enemy1C_Sub1_NoYC:
	lsr
	lsr
	lsr
	lsr
	;Set enemy Y velocity based on player Y distance from enemy
	tay
	lda CatoblepasYVelocity,y
	sta Enemy_YVel,x
	lsr
	sta $02
	lda CatoblepasYVelocityLo,y
	sta Enemy_YVelLo,x
	;Divide player X distance from enemy by player Y distance from target position
	ldy #$08
	lda #$00
	asl $01
Enemy1C_Sub1_DivLoop:
	rol
	cmp $02
	bcc Enemy1C_Sub1_DivNoC
	sbc $02
Enemy1C_Sub1_DivNoC:
	rol $01
	dey
	bne Enemy1C_Sub1_DivLoop
	;Set max value $50
	lda $01
	cmp #$50
	bcc Enemy1C_Sub1_DivNoC2
	lda #$50
	sta $01
Enemy1C_Sub1_DivNoC2:
	;Multiply result by 1/16
	lsr $01
	ror
	lsr $01
	ror
	lsr $01
	ror
	lsr $01
	ror
	and #$F0
	;Set enemy X velocity/props
	bit $03
	bpl Enemy1C_Sub1_DivNoXC
	eor #$FF
	clc
	adc #$01
Enemy1C_Sub1_DivNoXC:
	sta Enemy_XVelLo,x
	lda $01
	bit $03
	bpl Enemy1C_Sub1_DivNoXC2
	eor #$FF
	adc #$00
Enemy1C_Sub1_DivNoXC2:
	sta Enemy_XVel,x
	lsr
	and #$40
	sta Enemy_Props+$08,x
	;Next task ($02: Dive)
	inc Enemy_Mode,x
	rts
;$02: Dive
Enemy1C_Sub2:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate upward
	sec
	lda Enemy_YVelLo,x
	sbc #$20
	sta Enemy_YVelLo,x
	bcs Enemy1C_Sub2_NoYC
	dec Enemy_YVel,x
Enemy1C_Sub2_NoYC:
	;If enemy Y velocity down, exit early
	lda Enemy_YVel,x
	bpl Enemy1C_Sub2_Exit
	;If enemy Y position >= $20, exit early
	lda Enemy_YHi+$08,x
	bmi Enemy1C_Sub2_CheckX
	bne Enemy1C_Sub2_Exit
	lda Enemy_Y+$08,x
	cmp #$20
	bcs Enemy1C_Sub2_Exit
Enemy1C_Sub2_CheckX:
	;If current X screen >= $03, clear enemy
	lda CurScreenX
	cmp #$03
	bcs Enemy1C_Sub2_Clear
	;If enemy X screen < $04, go to next task ($00: Init)
	lda Enemy_X+$08,x
	adc TempMirror_PPUSCROLL_X
	tya
	adc CurScreenX
	cmp #$04
	bcc Enemy1C_Sub2_Next
	;If enemy offscreen horizontally, clear enemy
	ldy Enemy_XHi+$08,x
	beq Enemy1C_Sub2_Exit
Enemy1C_Sub2_Clear:
	;Clear enemy
	jmp ClearEnemy
Enemy1C_Sub2_Next:
	;Next task ($00: Init)
	lda #$00
	sta Enemy_Mode,x
Enemy1C_Sub2_Exit:
	rts
CatoblepasYVelocity:
	.db $02,$02,$02,$03,$04,$04,$04,$05,$05,$06,$06,$06,$06,$07,$07
CatoblepasYVelocityLo:
	.db $00,$00,$D0,$74,$00,$78,$E4,$4A,$A6,$00,$52,$A2,$EC,$36,$7A
	.db $BE,$BE

;$1E: Charon spawner
Enemy1EJumpTable:
	.dw Enemy1E_Sub0	;$00  Init
	.dw Enemy1E_Sub1	;$01  Main
;$00: Init
Enemy1E_Sub0:
	;If enemy offscreen horizontally, exit early
	lda Enemy_XHi+$08,x
	bne Enemy1E_Sub0_Exit
	;Next task ($01: Main)
	inc Enemy_Mode,x
Enemy1E_Sub0_Exit:
	rts
;$01: Main
Enemy1E_Sub1:
	;If spawner not active, exit early
	lda Enemy_Temp3,x
	beq Enemy1E_Sub1_Exit
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcs Enemy1E_Sub1_Spawn
	;Set animation timer
	lda #$08
	sta Enemy_Temp1,x
Enemy1E_Sub1_Exit:
	rts
Enemy1E_Sub1_Spawn:
	;Set enemy ID $1F (Charon falling)
	lda #ENEMY_CHARONFALLING
	sta Enemy_ID,x
	;Set enemy position
	txa
	tay
	ldx CurEnemyIndex
	lda Enemy_X+$08,x
	sta Enemy_X+$08,y
	lda Enemy_Y+$08,x
	sta Enemy_Y+$08,y
	lda Enemy_XHi+$08,x
	sta Enemy_XHi+$08,y
	;Clear spawner active flag
	lda #$00
	sta Enemy_Temp3,x
	rts

;$1F: Charon falling
Enemy1FJumpTable:
	.dw Enemy1F_Sub0	;$00  Init
	.dw Enemy1F_Sub1	;$01  Fall
	.dw Enemy1F_Sub2	;$02  Main
;$00: Init
Enemy1F_Sub0:
	;Set enemy flags/HP
	lda #$01
	sta Enemy_Flags,x
	sta Enemy_HP,x
	;Load CHR bank
	lda #$2C
	sta TempCHRBanks+2
	;Set enemy sprite
	lda #$3C
	sta Enemy_Sprite+$08,x
	;Set enemy X velocity to target player
	lda #$00
	jmp SetEnemyXVel
;$01: Fall
Enemy1F_Sub1:
	;Move enemy Y
	jsr MoveEnemyY
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	adc #$28
	bcc Enemy1F_Sub1_NoYC
	inc Enemy_YVel,x
Enemy1F_Sub1_NoYC:
	sta Enemy_YVelLo,x
	;If no ground collision, exit early
	jsr EnemyGetGroundCollision
	bcc Enemy1E_Sub1_Exit
	;Next task ($02: Main)
	inc Enemy_Mode,x
	;Set enemy grounded
	ldy #$00
	jmp HandleEnemyGroundCollision
;$02: Main
Enemy1F_Sub2:
	;If enemy invincibility timer not 0, exit early
	lda Enemy_InvinTimer,x
	bne Enemy1E_Sub1_Exit
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy X
	jsr MoveEnemyX
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy1E_Sub1_Exit
	;Flip enemy X
	jmp FlipEnemyX

;$41: Charon
Enemy41JumpTable:
	.dw Enemy41_Sub0	;$00  Init
	.dw Enemy1F_Sub2	;$01  Main
;$00: Init
Enemy41_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	bpl Enemy41_Sub0_Init
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	bmi Enemy41_Sub0_Init
	rts
Enemy41_Sub0_Init:
	;Set enemy X velocity to target player
	lda #$00
	jmp SetEnemyXVel

;$24: Hydra
Enemy24JumpTable:
	.dw Enemy24_Sub0	;$00  Init
	.dw Enemy24_Sub1	;$01  Fly
	.dw Enemy24_Sub2	;$02  Dive
	.dw Enemy24_Sub3	;$03  Down
	.dw Enemy24_Sub4	;$04  Attack
	.dw Enemy24_Sub5	;$05  Up
	.dw Enemy24_Sub6	;$06  Out
;$00: Init
Enemy24_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	beq Enemy24_Sub0_Init
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	bmi Enemy24_Sub0_Init
	rts
Enemy24_Sub0_Init:
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
Enemy24_Sub0_SetVel:
	;Set enemy target Y position
	jsr InitEnemyTargetYPos
	;Set enemy X velocity to target player
	lda #$08
	jmp SetEnemyXVel
;$01: Fly
Enemy24_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Adjust enemy Y velocity to target Y position
	jsr UpdateEnemyTargetYPos
	;Move enemy
	jsr MoveEnemyXY
	;If enemy offscreen, exit early
	lda Enemy_XHi+$08,x
	ora Enemy_YHi+$08,x
	bne Enemy24_Sub1_Exit
	;Check if animation timer 0
	lda Enemy_Temp1,x
	beq Enemy24_Sub1_CheckNext
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy24_Sub1_CheckNext
Enemy24_Sub1_Exit:
	rts
Enemy24_Sub1_CheckNext:
	;Check if player is in range
	ldy #$01
Enemy24_Sub1_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$03
	bcc Enemy24_Sub1_ClearD
	;Get player X distance from enemy
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	bcs Enemy24_Sub1_NoXC
	eor #$FF
Enemy24_Sub1_NoXC:
	adc #$01
	bmi Enemy24_Sub1_ClearD
	;Set min X distance $40
	cmp #$40
	bcs Enemy24_Sub1_PlayerNext
Enemy24_Sub1_ClearD:
	lda #$00
Enemy24_Sub1_PlayerNext:
	sta $00,y
	;Loop for each player
	dey
	bpl Enemy24_Sub1_PlayerLoop
	;If no players are in range, exit early
	ora $01
	beq Enemy24_Sub1_Exit
	;If player 2 not in range, set player 1 as target player
	ldy #$00
	lda $01
	beq Enemy24_Sub1_SetPlayer
	;If player 1 not in range, set player 2 as target player
	iny
	lda $00
	beq Enemy24_Sub1_SetPlayer
	;Set closest player index
	cmp $01
	bcs Enemy24_Sub1_SetPlayer
	dey
Enemy24_Sub1_SetPlayer:
	;Set target player index
	tya
	sta Enemy_Temp3,x
	;Init dive state
	lda #$00
	jmp Enemy1C_Sub1_Dive
;$02: Dive
Enemy24_Sub2:
	;Get player X distance from enemy
	ldy Enemy_Temp3,x
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	bcs Enemy24_Sub2_PosX
	eor #$FF
	adc #$01
Enemy24_Sub2_PosX:
	;If player X distance from enemy < $28, go to next task ($03: Down)
	cmp #$28
	bcs Enemy24_Sub2_NoNext
	;Clear enemy velocity
	lda #$00
	sta Enemy_XVel,x
	sta Enemy_XVelLo,x
	sta Enemy_YVel,x
	sta Enemy_YVelLo,x
	;Next task ($03: Down)
	inc Enemy_Mode,x
Enemy24_Sub2_NoNext:
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate upward
	lda Enemy_YVelLo,x
	sec
	sbc #$20
	sta Enemy_YVelLo,x
	bcs Enemy24_Sub2_NoYC
	dec Enemy_YVel,x
Enemy24_Sub2_NoYC:
	;Update enemy animation
	jmp UpdateEnemyAnimation
;$03: Down
Enemy24_Sub3:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy Y
	jsr MoveEnemyY
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy24_Sub3_NoYC
	inc Enemy_YVel,x
Enemy24_Sub3_NoYC:
	;If no ground collision, exit early
	jsr Enemy1B_Sub1_CheckSlope
	bcc Enemy24_Sub4_Exit
	;Next task ($04: Attack)
	inc Enemy_Mode,x
	;Set animation timer
	lda #$10
	sta Enemy_Temp1,x
	rts
;$04: Attack
Enemy24_Sub4:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy24_Sub4_Next
	;If animation timer not $08, exit early
	lda Enemy_Temp1,x
	cmp #$08
	bne Enemy24_Sub4_Exit
	;Set enemy sprite
	lda #$34
	sta Enemy_Sprite+$08,x
	;Spawn projectile in free enemy slot
	ldy Enemy_Temp3,x
	lda #$00
	ldx #$04
	jsr SpawnFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy24_Sub4_Exit
	;Set enemy ID $25 (Hydra fire)
	ldy $00
	lda #ENEMY_HYDRAFIRE
	sta Enemy_ID,y
	;Set enemy props
	lda Enemy_Props+$08,x
	sta Enemy_Props+$08,y
	;Play sound
	lda #SE_HYDRAFIRE
	jmp LoadSound
Enemy24_Sub4_Next:
	;Next task ($05: Up)
	inc Enemy_Mode,x
	;Set enemy Y velocity
	lda #$FD
	sta Enemy_YVel,x
	lda #$00
	sta Enemy_YVelLo,x
Enemy24_Sub4_Exit:
	rts
;$05: Up
Enemy24_Sub5:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$20
	sta Enemy_YVelLo,x
	bcc Enemy24_Sub5_NoYC
	inc Enemy_YVel,x
	;If Y velocity 0, go to next task ($06: Out)
	bne Enemy24_Sub5_NoYC
	;Next task ($06: Out)
	inc Enemy_Mode,x
	;Set enemy X velocity
	lda Enemy_Props+$08,x
	cmp #$40
	lda #$05
	bcc Enemy24_Sub5_Right
	lda #$FC
Enemy24_Sub5_Right:
	sta Enemy_XVel,x
	rts
Enemy24_Sub5_NoYC:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy Y
	jmp MoveEnemyY
;$06: Out
Enemy24_Sub6:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate upward
	lda Enemy_YVelLo,x
	sec
	sbc #$20
	sta Enemy_YVelLo,x
	bcs Enemy24_Sub6_NoYC
	dec Enemy_YVel,x
Enemy24_Sub6_NoYC:
	;If enemy Y position >= $10, exit early
	lda Enemy_Y+$08,x
	cmp #$10
	bcs Enemy24_Sub4_Exit
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Next task ($01: Fly)
	lda #$00
	sta Enemy_Mode,x
	;Set enemy velocity
	jmp Enemy24_Sub0_SetVel

;$25: Hydra fire
Enemy25JumpTable:
	.dw Enemy25_Sub0	;$00  Init
	.dw Enemy25_Sub1	;$01  Main
	.dw Enemy25_Sub2	;$02  End
;$00: Init
Enemy25_Sub0:
	;Set enemy flags
	lda #(EF_NOHITATTACK|$02)
	sta Enemy_Flags,x
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
Enemy25_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy25_Sub1_NoNext
	;Set animation timer
	lda #$08
	sta Enemy_Temp1,x
	;Set enemy sprite
	lda #$37
	sta Enemy_Sprite+$08,x
	;Next task ($02: End)
	inc Enemy_Mode,x
Enemy25_Sub1_NoNext:
	;Move enemy
	jmp MoveEnemyXY
;$02: End
Enemy25_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy25_Sub2_Exit
	;Clear enemy
	jmp ClearEnemy
Enemy25_Sub2_Exit:
	rts

;$26: Hobgoblin
Enemy26JumpTable:
	.dw Enemy26_Sub0	;$00  Init
	.dw Enemy26_Sub1	;$01  Main
;$00: Init
Enemy26_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	beq Enemy26_Sub0_Init
	;Check if enemy is on left side of screen
	ldy Enemy_XHi+$08,x
	cpy #$01
	beq Enemy26_Sub0_ClearF
	rts
Enemy26_Sub0_ClearF:
	;Set enemy flags
	lda Enemy_Flags,x
	and #(~(EF_NOHITENEMY|EF_NOHITATTACK))&$FF
	sta Enemy_Flags,x
Enemy26_Sub0_Init:
	;Set enemy X velocity to target player
	lda #$00
	jmp SetEnemyXVel
;$01: Main
Enemy26_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If no ground collision, flip enemy X
	ldy #$01
	jsr EnemyGetGroundCollision_AnyY
	bcc Enemy26_Sub1_Flip
	;If wall collision, flip enemy X
	jsr EnemyGetWallCollision
	bcs Enemy26_Sub1_Flip
	;Move enemy X
	jmp MoveEnemyX
Enemy26_Sub1_Flip:
	;Flip enemy X
	jmp FlipEnemyX

;$27: Red Cap
Enemy27JumpTable:
	.dw Enemy27_Sub0	;$00  Init
	.dw Enemy27_Sub1	;$01  Idle
	.dw Enemy27_Sub2	;$02  Jump init
	.dw Enemy27_Sub3	;$03  Jump
	.dw Enemy27_Sub4	;$04  Slide
	.dw Enemy27_Sub5	;$05  Fall
;$00: Init
Enemy27_Sub0:
	;If enemy Y position >= $D0, clear enemy
	lda Enemy_YHi+$08,x
	bne Enemy27_Sub0_NoClear
	lda Enemy_Y+$08,x
	cmp #$D0
	bcc Enemy27_Sub0_NoClear
	;Clear enemy
	jmp ClearEnemy
Enemy27_Sub0_NoClear:
	;Set enemy grounded
	lda Enemy_X+$08,x
	clc
	adc TempMirror_PPUSCROLL_X
	and #$10
	beq Enemy27_Sub0_NoSetY
	lda Enemy_Y+$08,x
	sec
	sbc #$08
	bcs Enemy27_Sub0_NoYC
	sbc #$0F
	dec Enemy_YHi+$08,x
Enemy27_Sub0_NoYC:
	sta Enemy_Y+$08,x
Enemy27_Sub0_NoSetY:
	;Load CHR bank
	lda #$31
	sta TempCHRBanks+2
	;Set enemy props/sprite
	txa
	lsr
	bcc Enemy27_Sub0_NoSetP
	lda #$40
	sta Enemy_Props+$08,x
Enemy27_Sub0_NoSetP:
	lda #$5D
	sta Enemy_Sprite+$08,x
	;Next task ($01: Idle)
	inc Enemy_Mode,x
Enemy27_Sub0_Exit:
	rts
;$01: Idle
Enemy27_Sub1:
	;If enemy offscreen vertically, exit early
	ldy Enemy_YHi+$08,x
	bne Enemy27_Sub0_Exit
	;Find which player is closest to enemy Y
	dey
	sty $00
	sty $01
	;Check if player is in range
	iny
	iny
Enemy27_Sub1_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc Enemy27_Sub1_PlayerNext
	;If player Y position < enemy Y position, skip this part
	lda Enemy_Y,y
	sbc Enemy_Y+$08,x
	bcc Enemy27_Sub1_PlayerNext
	;Check if Y distance is less than current minimum
	cmp $00
	bcs Enemy27_Sub1_PlayerNext
	;Set closest player distance
	sta $00
	;Set closest player index
	sty $01
Enemy27_Sub1_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy27_Sub1_PlayerLoop
	;If no closest player, exit early
	ldy $01
	bmi Enemy27_Sub0_Exit
	;If player not grounded, exit early
	lda PlayerCollTypeBottom,y
	beq Enemy27_Sub2_Exit
	;If player Y distance from enemy >= $30, exit early
	lda $00
	cmp #$30
	bcs Enemy27_Sub2_Exit
	;Get player X distance from enemy
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	ldy Enemy_XHi+$08,x
	bcs Enemy27_Sub1_NoXC
	dey
Enemy27_Sub1_NoXC:
	beq Enemy27_Sub1_CheckD
	eor #$FF
	clc
	adc #$01
Enemy27_Sub1_CheckD:
	;If player X distance from enemy < $60, go to next task ($02: Jump init)
	cmp #$60
	bcs Enemy27_Sub2_Exit
	;Next task ($02: Jump init)
	inc Enemy_Mode,x
;$02: Jump init
Enemy27_Sub2:
	;Next task ($03: Jump)
	inc Enemy_Mode,x
	;Set enemy sprite/velocity
	lda #$5D
	sta Enemy_Sprite+$08,x
	lda Enemy_Props+$08,x
	cmp #$40
	lda #$FF
	bcs Enemy27_Sub2_Left
	lda #$01
Enemy27_Sub2_Left:
	sta Enemy_XVel,x
	lda #$FE
	sta Enemy_YVel,x
Enemy27_Sub2_Exit:
	rts
;$03: Jump
Enemy27_Sub3:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy27_Sub3_NoYC
	inc Enemy_YVel,x
Enemy27_Sub3_NoYC:
	;Move enemy
	jsr MoveEnemyXY
	;If enemy Y velocity up, exit early
	lda Enemy_YVel,x
	bmi Enemy27_Sub2_Exit
	;Set enemy sprite
	lda #$5F
	sta Enemy_Sprite+$08,x
	;Check for 30 deg. slope collision types
	ldy #$05
	jsr EnemyGetGroundCollision_AnyY
	cmp #$05
	bcc Enemy27_Sub2_Exit
	;Get collision tile X offset
	sta $02
	clc
	lda TempMirror_PPUSCROLL_X
	adc Enemy_X+$08,x
	and #$1F
	lsr
	ldy Enemy_Props+$08,x
	cpy #$40
	bcc Enemy27_Sub3_RightPos
	eor #$0F
Enemy27_Sub3_RightPos:
	sta $00
	clc
	lda Enemy_Y+$08,x
	adc TempMirror_PPUSCROLL_Y
	and #$0F
	ldy $02
	cpy #$13
	bcc Enemy27_Sub3_NoSlopeTop
	adc #$0F
Enemy27_Sub3_NoSlopeTop:
	;Check if above or below slope
	cmp $00
	beq Enemy27_Sub3_SlopeNoSetY
	bcc Enemy27_Sub2_Exit
	;Set enemy grounded
	sbc $00
	sta $01
	lda Enemy_Y+$08,x
	sbc $01
	bcs Enemy27_Sub3_SlopeNoYC
	sbc #$0F
	dec Enemy_YHi+$08,x
Enemy27_Sub3_SlopeNoYC:
	sta Enemy_Y+$08,x
Enemy27_Sub3_SlopeNoSetY:
	;Set enemy velocity
	asl Enemy_XVel,x
	lda #$02
	bcc Enemy27_Sub3_RightVel
	lda #$FE
Enemy27_Sub3_RightVel:
	sta Enemy_XVel,x
	lda #$01
	sta Enemy_YVel,x
	lda #$00
	sta Enemy_YVelLo,x
	sta Enemy_XVelLo,x
	;Next task ($04: Slide)
	inc Enemy_Mode,x
Enemy27_Sub3_Exit:
	rts
;$04: Slide
Enemy27_Sub4:
	;If bit 0 of global timer 0, skip this part
	tya
	eor GlobalTimer
	lsr
	bcc Enemy27_Sub4_NoNext
	;Check for 30 deg. slope collision types
	ldy #$05
	jsr EnemyGetGroundCollision_AnyY
	cmp #$05
	bcc Enemy27_Sub4_Next
	;Check for non-slope collision types
	cmp #$14
	bcc Enemy27_Sub4_NoNext
Enemy27_Sub4_Next:
	;Next task ($05: Fall)
	inc Enemy_Mode,x
Enemy27_Sub4_NoNext:
	;If enemy invincibility timer not 0, exit early
	lda Enemy_InvinTimer,x
	bne Enemy27_Sub3_Exit
	;Move enemy
	jmp MoveEnemyXY
;$05: Fall
Enemy27_Sub5:
	;If enemy Y velocity >= $06, don't accelerate
	lda Enemy_YVel,x
	cmp #$06
	bcs Enemy27_Sub5_NoYC
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy27_Sub5_NoYC
	inc Enemy_YVel,x
Enemy27_Sub5_NoYC:
	;Move enemy Y
	jmp MoveEnemyY

;$30: Harpy spawner 2
Enemy30JumpTable:
	.dw Enemy30_Sub0	;$00  Init
	.dw Enemy30_Sub1	;$01  Main
	.dw Enemy30_Sub2	;$02  Wait
;$00: Init
Enemy30_Sub0:
	;If auto scroll disabled, exit early
	lda AutoScrollDirFlags
	beq Enemy30_Sub1_Exit
	;Next task ($01: Main)
	inc Enemy_Mode,x
	;If bit 0 of enemy slot index 0, exit early
	txa
	and #$01
	beq Enemy30_Sub1_Exit
	;Set animation timer
	lda #$80
	sta Enemy_Temp1,x
	;Next task ($02: Wait)
	inc Enemy_Mode,x
	rts
;$01: Main
Enemy30_Sub1:
	;If current Y screen and scroll Y position 0, clear enemy
	lda CurScreenY
	ora TempMirror_PPUSCROLL_Y
	bne Enemy30_Sub1_NoClear
	jmp ClearEnemy
Enemy30_Sub1_NoClear:
	;If auto scroll and scroll lock disabled, exit early
	lda AutoScrollDirFlags
	ora TempScrollLockFlags
	beq Enemy30_Sub1_Exit
	;If enemy offscreen horizontally, exit early
	lda Enemy_XHi+$08,x
	bne Enemy30_Sub1_Exit
	;Check for free slots
	ldy #$07
Enemy30_Sub1_Loop:
	;Check if free slot available
	lda Enemy_ID,y
	beq Enemy30_Sub0_Spawn
	;Loop for each slot
	dey
	cpy #$02
	bcs Enemy30_Sub1_Loop
Enemy30_Sub1_Exit:
	rts
Enemy30_Sub0_Spawn:
	;Set enemy ID $28 (Harpy spawner)
	lda #ENEMY_HARPYSPAWNER
	sta Enemy_ID,y
	;Set enemy flags/position
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|EF_ALLOWOFFSCREEN)
	sta Enemy_Flags,y
	lda Enemy_Temp2,x
	and #$01
	bne Enemy30_Sub0_SetXHi
	lda #$FF
Enemy30_Sub0_SetXHi:
	sta Enemy_XHi+$08,y
	asl
	lda #$20
	bcc Enemy30_Sub0_SetX
	lda #$E0
Enemy30_Sub0_SetX:
	sta Enemy_X+$08,y
	lda #$18
	sta Enemy_Y+$08,y
	;Move spawner to other side of screen
	inc Enemy_Temp2,x
	;Next task ($02: Wait)
	inc Enemy_Mode,x
	rts
;$02: Wait
Enemy30_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy30_Sub2_Exit
	;Next task ($02: Wait)
	dec Enemy_Mode,x
Enemy30_Sub2_Exit:
	rts

;$28: Harpy spawner
Enemy28JumpTable:
	.dw Enemy28_Sub0	;$00  Main
	.dw Enemy28_Sub1	;$01  Wait
;$00: Main
Enemy28_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	beq Enemy28_Sub0_Init
	;Check if enemy is on left side of screen
	lda Enemy_XHi+$08,x
	bmi Enemy28_Sub0_CheckSpawn
Enemy28_Sub0_Exit:
	rts
Enemy28_Sub0_Init:
	lda Enemy_XHi+$08,x
	beq Enemy28_Sub0_Clear
Enemy28_Sub0_CheckSpawn:
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy28_Sub0_Exit
	;Disable enemy scroll Y
	inc Enemy_Temp0,x
	;Offset enemy Y position
	txa
	tay
	ldx CurEnemyIndex
	jsr OffsetEnemyYPos
	lda #$00
	sta Enemy_YHi+$08,y
	;Set enemy HP
	sta Enemy_HP,y
	lda Enemy_Y+$08,x
	sta Enemy_Y+$08,y
	;Set enemy ID $29 (Harpy)
	lda #ENEMY_HARPY
	sta Enemy_ID,y
	;Set enemy flags
	lda #$07
	sta Enemy_Flags,y
	;Load CHR bank
	lda #$30
	sta TempCHRBanks+2
	;If all enemies have spawned, clear enemy
	lda Enemy_Temp3,x
	cmp #$02
	bcs Enemy28_Sub0_Clear
	;Set animation timer
	lda #$10
	sta Enemy_Temp1,x
	;Increment spawn counter
	inc Enemy_Temp3,x
	;Next task ($01: Wait)
	inc Enemy_Mode,x
	rts
Enemy28_Sub0_Clear:
	;Clear enemy
	jmp ClearEnemy
;$01: Wait
Enemy28_Sub1:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy28_Sub1_Exit
	;Next task ($01: Main)
	dec Enemy_Mode,x
Enemy28_Sub1_Exit:
	rts

;$29: Harpy
Enemy29JumpTable:
	.dw Enemy29_Sub0	;$00  Init
	.dw Enemy29_Sub1	;$01  Fly start
	.dw Enemy29_Sub2	;$02  Dive
	.dw Enemy29_Sub3	;$03  Fly end
;$00: Init
Enemy29_Sub0:
	;Set enemy target Y position
	jsr InitEnemyTargetYPos
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Set enemy X velocity to target player
	lda #$0C
	jmp SetEnemyXVel
;$01: Fly start
Enemy29_Sub1:
	;If animation timer 0, go to next task ($02: Dive)
	lda Enemy_Temp1,x
	beq Enemy29_Sub1_Next
	;Decrement animation timer
	dec Enemy_Temp1,x
	bne Enemy29_Sub3
Enemy29_Sub1_Next:
	;If enemy offscreen, skip this part
	lda Enemy_XHi+$08,x
	ora Enemy_YHi+$08,x
	bne Enemy29_Sub3
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy velocity to target player
	jsr TargetPlayerFlying
	;Set enemy props
	lda Enemy_XVel,x
	lsr
	and #$40
	sta Enemy_Props+$08,x
	;Next task ($02: Dive)
	inc Enemy_Mode,x
;$03: Fly end
Enemy29_Sub3:
	;Adjust enemy Y velocity to target Y position
	lda Enemy_Temp2,x
	jsr UpdateEnemyTargetYPos_NoScroll
	;Move enemy
	jsr MoveEnemyXY
	;Update enemy animation
	jmp UpdateEnemyAnimation
;$02: Dive
Enemy29_Sub2:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate upward
	lda Enemy_YVelLo,x
	sec
	sbc #$28
	sta Enemy_YVelLo,x
	bcs Enemy29_Sub2_NoYC
	dec Enemy_YVel,x
Enemy29_Sub2_NoYC:
	;If enemy Y velocity down, exit early
	lda Enemy_YVel,x
	bpl Enemy29_Sub2_Exit
	;If enemy Y position >= $20, exit early
	lda Enemy_YHi+$08,x
	bmi Enemy29_Sub2_Next
	bne Enemy29_Sub2_Exit
	lda Enemy_Y+$08,x
	cmp #$20
	bcs Enemy29_Sub2_Exit
Enemy29_Sub2_Next:
	;Set enemy target Y position
	jsr InitEnemyTargetYPos
	;Set enemy X velocity to target player
	ldy #$0C
	lda Enemy_XVel,x
	asl
	bcs Enemy29_Sub2_NoXC
	iny
Enemy29_Sub2_NoXC:
	lda EnemyXVelTable,y
	sta Enemy_XVel,x
	lda EnemyXVelLoTable,y
	sta Enemy_XVelLo,x
	;Next task ($03: Fly end)
	inc Enemy_Mode,x
Enemy29_Sub2_Exit:
	rts

;$2A: Chimera
Enemy2AJumpTable:
	.dw Enemy2A_Sub0	;$00  Init
	.dw Enemy2A_Sub1	;$01  Wait
	.dw Enemy2A_Sub2	;$02  Attack init
	.dw Enemy2A_Sub3	;$03  Attack
;$00: Init
Enemy2A_Sub0:
	;Set enemy sprite/props/X velocity
	lda #$62
	sta Enemy_Sprite+$08,x
	lda #$40
	sta Enemy_Props+$08,x
	lda #$FE
	sta Enemy_XVel,x
	;Load CHR bank
	lda #$31
	sta TempCHRBanks+2
	;Next task ($01: Wait)
	inc Enemy_Mode,x
	rts
;$01: Wait
Enemy2A_Sub1:
	;If enemy offscreen, exit early
	lda Enemy_XHi+$08,x
	ora Enemy_YHi+$08,x
	bne Enemy2A_Sub1_Exit
	;Check if player is in range
	ldy #$01
Enemy2A_Sub1_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc Enemy2A_Sub1_PlayerNext
	;If player X position < enemy X position, go to next task ($02: Attack init)
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	bcc Enemy2A_Sub1_Next
	;If player X distance from enemy >= $90, skip this part
	cmp #$90
	bcs Enemy2A_Sub1_PlayerNext
	;If player Y distance from enemy < $10, go to next task ($02: Attack init)
	lda Enemy_Y+$08,x
	sbc Enemy_Y,y
	adc #$10
	cmp #$20
	bcc Enemy2A_Sub1_Next
Enemy2A_Sub1_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy2A_Sub1_PlayerLoop
	rts
Enemy2A_Sub1_Next:
	;Next task ($02: Attack init)
	inc Enemy_Mode,x
Enemy2A_Sub1_Exit:
	rts
;$02: Attack init
Enemy2A_Sub2:
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy2A_Sub1_Exit
	;Set enemy ID $2B (Chimera fire)
	txa
	tay
	ldx CurEnemyIndex
	lda #ENEMY_CHIMERAFIRE
	sta Enemy_ID,y
	;Set enemy sprite
	lda #$64
	sta Enemy_Sprite+$08,y
	;Offset projectile Y position
	lda #$00
	jsr OffsetEnemyYPos
	;Set projectile X velocity
	asl
	asl
	lda #$01
	bcc Enemy2A_Sub2_RightVel
	lda #$FE
Enemy2A_Sub2_RightVel:
	sta Enemy_XVel,y
	;Offset projectile X position
	lda #$18
	bcc Enemy2A_Sub2_RightPos
	lda #$E8
Enemy2A_Sub2_RightPos:
	sta $00
	adc Enemy_X+$08,x
	sta Enemy_X+$08,y
	lda #$00
	bit $00
	bpl Enemy2A_Sub2_RightPosHi
	lda #$FF
Enemy2A_Sub2_RightPosHi:
	adc Enemy_XHi+$08,x
	sta Enemy_XHi+$08,y
	;Set projectile Y velocity
	lda #$80
	sta Enemy_YVelLo,y
	;Set enemy flags
	lda #(EF_NOHITATTACK|$02)
	sta Enemy_Flags,y
	;Clear enemy animation timer/offset
	lda #$FF
	sta Enemy_AnimTimer,y
	sta Enemy_AnimOffs,y
	;Play sound
	lda #SE_CHIMERAFIRE
	jsr LoadSound
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Next task ($03: Attack)
	inc Enemy_Mode,x
	;Init jump state
	jmp Enemy2A_Sub2_Jump
;$03: Attack
Enemy2A_Sub3:
	;Check if animation timer 0
	lda Enemy_Temp1,x
	beq Enemy2A_Sub3_Run
	;Decrement animation timer
	dec Enemy_Temp1,x
	rts
Enemy2A_Sub3_Run:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jsr MoveEnemyXY
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy2A_Sub3_NoYC
	inc Enemy_YVel,x
Enemy2A_Sub3_NoYC:
	;If enemy Y velocity up, exit early
	lda Enemy_YVel,x
	bmi Enemy2A_Sub3_Exit
	;If no ground collision, exit early
	jsr EnemyGetGroundCollision
	bcc Enemy2A_Sub3_Exit
	;Set enemy grounded
	ldy #$00
	jsr HandleEnemyGroundCollision
Enemy2A_Sub2_Jump:
	;Set enemy Y velocity
	lda #$FE
	sta Enemy_YVel,x
	;Clear enemy animation timer/offset
	sta Enemy_AnimTimer,x
	sta Enemy_AnimOffs,x
	lda #$80
	sta Enemy_YVelLo,x
Enemy2A_Sub3_Exit:
	rts

;$2B: Chimera fire
Enemy2BJumpTable:
	.dw Enemy2B_Sub0	;$00  Init
	.dw Enemy2B_Sub1	;$01  Main
;$00: Init
Enemy2B_Sub0:
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
Enemy2B_Sub1:
	;If enemy sprite $66, don't updat enemy animation
	lda Enemy_Sprite+$08,x
	cmp #$66
	beq Enemy2B_Sub1_NoAnim
	;Update enemy animation
	jsr UpdateEnemyAnimation
Enemy2B_Sub1_NoAnim:
	;If bits 0-1 of global timer 0, set enemy props
	lda GlobalTimer
	and #$03
	bne Enemy2B_Sub1_NoSetP
	;Set enemy props
	lda Enemy_Props+$08,x
	eor #$80
	sta Enemy_Props+$08,x
Enemy2B_Sub1_NoSetP:
	;Move enemy X
	jmp MoveEnemyX

;$2C: Baba Yaga
Enemy2CJumpTable:
	.dw Enemy2C_Sub0	;$00  Init
	.dw Enemy2C_Sub1	;$01  Fly
	.dw Enemy2C_Sub2	;$02  Turn
;$00: Init
Enemy2C_Sub0:
	;Set enemy X velocity to target player
	lda #$0A
	jmp SetEnemyXVel
;$01: Fly
Enemy2C_Sub1:
	;Move enemy X
	jsr MoveEnemyX
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If enemy offscreen horizontally, exit early
	lda Enemy_XHi+$08,x
	bne Enemy2C_Sub1_Exit
	;Check to turn around
	lda Enemy_X+$08,x
	tay
	eor Enemy_XVel,x
	bpl Enemy2C_Sub1_Exit
	;If enemy X position not $20-$DF, go to next task ($02: Turn)
	tya
	clc
	adc #$20
	bcs Enemy2C_Sub1_Next
	cmp #$40
	bcc Enemy2C_Sub1_Next
Enemy2C_Sub1_Exit:
	rts
Enemy2C_Sub1_Next:
	;Next task ($02: Turn)
	inc Enemy_Mode,x
	;Init wave offset
	lda #$00
	sta Enemy_Temp2,x
	;Save enemy X velocity
	lda Enemy_XVel,x
	sta Enemy_Temp3,x
	;Find which player is closest to enemy Y
	ldy #$FF
	sty $00
	sty $01
	iny
	iny
Enemy2C_Sub1_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc Enemy2C_Sub1_PlayerNext
	;Get player Y distance from enemy
	lda Enemy_Y+$08,x
	sbc Enemy_Y,y
	php
	bcs Enemy2C_Sub1_PosY
	eor #$FF
	adc #$01
Enemy2C_Sub1_PosY:
	;Check if X distance is less than current minimum
	cmp $00
	bcs Enemy2C_Sub1_NoSet
	;Set closest player distance
	sta $00
	;Set closest player index
	sty $01
	;Set closest player direction
	plp
	ror
	sta $02
	jmp Enemy2C_Sub1_PlayerNext
Enemy2C_Sub1_NoSet:
	plp
Enemy2C_Sub1_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy2C_Sub1_PlayerLoop
	;Set direction
	asl $01
	lda $02
	bcc Enemy2C_Sub1_SetDir
	lda Enemy_Y+$08,x
Enemy2C_Sub1_SetDir:
	sta Enemy_Temp4,x
	rts
;$02: Turn
Enemy2C_Sub2:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Increment wave offset
	inc Enemy_Temp2,x
	inc Enemy_Temp2,x
	;Check for Q2
	ldy Enemy_Temp2,x
	cpy #$41
	bcc Enemy2C_Sub2_NoQ2
	lda #$80
	sbc Enemy_Temp2,x
	tay
Enemy2C_Sub2_NoQ2:
	;Set enemy Y velocity based on wave offset
	lda Enemy_Temp4,x
	asl
	lda SineTable,y
	ldy #$00
	bcc Enemy2C_Sub2_PosY
	eor #$FF
	adc #$00
	dey
Enemy2C_Sub2_PosY:
	sta Enemy_YVelLo,x
	tya
	sta Enemy_YVel,x
	;Adjust wave offset for X velocity
	sec
	lda Enemy_Temp3,x
	bpl Enemy2C_Sub2_Left
	lda Enemy_Temp2,x
	sbc #$40
	jmp Enemy2C_Sub2_CheckQ4
Enemy2C_Sub2_Left:
	lda #$40
	sbc Enemy_Temp2,x
Enemy2C_Sub2_CheckQ4:
	;Check for Q4
	bcs Enemy2C_Sub2_NoQ4
	eor #$FF
	adc #$01
Enemy2C_Sub2_NoQ4:
	;Set enemy X velocity based on wave offset
	tay
	lda SineTable,y
	ldy #$00
	bcs Enemy2C_Sub2_PosX
	eor #$FF
	adc #$01
	dey
Enemy2C_Sub2_PosX:
	sta Enemy_XVelLo,x
	tya
	sta Enemy_XVel,x
	;Set enemy props
	lsr
	and #$40
	sta Enemy_Props+$08,x
	;Check if finished turning
	lda Enemy_Temp2,x
	bpl Enemy2C_Sub2_NoNext
	;Multiply enemy X velocity by 2
	asl Enemy_XVelLo,x
	rol Enemy_XVel,x
	;Next task ($01: Fly)
	dec Enemy_Mode,x
Enemy2C_Sub2_NoNext:
	;Move enemy
	jmp MoveEnemyXY

;$2E: Kali
Enemy2EJumpTable:
	.dw Enemy2E_Sub0	;$00  Init
	.dw Enemy2E_Sub1	;$01  Idle
	.dw Enemy2E_Sub2	;$02  Attack
;$00: Init
Enemy2E_Sub0:
	;Load CHR bank
	lda #$2F
	sta TempCHRBanks+2
	;Set animation timer
	inc Enemy_Temp1,x
	;Next task ($01: Idle)
	inc Enemy_Mode,x
	rts
;$01: Idle
Enemy2E_Sub1:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy2E_Sub1_CheckSpawn
	;If animation timer < $10, set enemy sprite
	lda Enemy_Temp1,x
	cmp #$10
	bcc Enemy2E_Sub1_SetSp
	;Update enemy animation
	jmp UpdateEnemyAnimation
Enemy2E_Sub1_SetSp:
	;Set enemy sprite
	lda #$69
	sta Enemy_Sprite+$08,x
	rts
Enemy2E_Sub1_Exit:
	;Increment animation timer
	inc Enemy_Temp1,x
	rts
Enemy2E_Sub1_CheckSpawn:
	;Find free enemy slot
	jsr FindFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy2E_Sub1_Exit
	;Set parent enemy slot index
	txa
	tay
	ldx CurEnemyIndex
	sta Enemy_Temp3,x
	;Set enemy ID $2F (Kali fire)
	lda #ENEMY_KALIFIRE
	sta Enemy_ID,y
	;Set projectile enemy slot index
	txa
	sta Enemy_Temp2,y
	;Offset projectile Y position
	lda Enemy_Y+$08,x
	sbc #$04
	sta Enemy_Y+$08,y
	;Set enemy props
	lda Enemy_Props+$08,x
	sta Enemy_Props+$08,y
	;Offset projectile X position
	lda #$28
	adc Enemy_X+$08,x
	sta Enemy_X+$08,y
	lda #$00
	adc Enemy_XHi+$08,x
	sta Enemy_XHi+$08,y
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|$0A)
	sta Enemy_Flags,y
	;Next task ($02: Attack)
	inc Enemy_Mode,x
	;Set enemy sprite
	lda #$6A
	sta Enemy_Sprite+$08,x
	;Play sound
	lda #SE_KALIFIRE
	jmp LoadSound
;$02: Attack
Enemy2E_Sub2:
	;If projectile enemy active, exit early
	ldy Enemy_Temp3,x
	lda Enemy_ID,y
	bne Enemy2E_Sub2_Exit
	;Set animation timer
	lda #$50
	sta Enemy_Temp1,x
	;Next task ($01: Idle)
	dec Enemy_Mode,x
Enemy2E_Sub2_Exit:
	rts

;$2F: Kali fire
Enemy2FJumpTable:
	.dw Enemy2F_Sub0	;$00  Init
	.dw Enemy2F_Sub1	;$01  Main
;$00: Init
Enemy2F_Sub0:
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
Enemy2F_Sub1:
	;If parent enemy not active, clear enemy
	ldy Enemy_Temp2,x
	lda Enemy_ID,y
	beq Enemy2F_Sub1_Clear
	cmp #ENEMY_KALI
	bne Enemy2F_Sub1_Clear
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|$0A)
	ldy Enemy_AnimOffs,x
	cpy #$02
	bcc Enemy2F_Sub1_SetF
	cpy #$08
	bcs Enemy2F_Sub1_SetF
	lda #(EF_NOHITATTACK|$0A)
Enemy2F_Sub1_SetF:
	sta Enemy_Flags,x
	;Check for end of animation
	cpy #$0A
	bcc Enemy2E_Sub2_Exit
Enemy2F_Sub1_Clear:
	;Clear enemy
	jmp ClearEnemy

;$5B: Level 4 fence scroll
Enemy5BJumpTable:
	.dw Enemy5B_Sub0	;$00  Init
	.dw Enemy5B_Sub1	;$01  Main
;$00: Init
Enemy5B_Sub0:
	;If scroll Y position 0, clear enemy
	lda TempMirror_PPUSCROLL_Y
	beq Enemy5B_Sub1_Clear
	;If scroll Y position >= $2B, exit early
	cmp #$2B
	bcs Enemy5B_Sub0_Exit
	;Set auto scroll flags/Y velocity
	lda #$04
	sta AutoScrollDirFlags
	lda #$FF
	sta AutoScrollYVel
	;Next task ($01: Main)
	inc Enemy_Mode,x
Enemy5B_Sub0_Exit:
	rts
;$01: Main
Enemy5B_Sub1:
	;If scroll Y position not 0, exit early
	lda TempMirror_PPUSCROLL_Y
	bne Enemy5B_Sub0_Exit
Enemy5B_Sub1_Clear:
	;Clear auto scroll flags/Y velocity
	lda #$00
	sta AutoScrollDirFlags
	sta AutoScrollYVel
	;Clear enemy
	jmp ClearEnemy

;$45: Level 3 fall start
Enemy45JumpTable:
	.dw Enemy45_Sub0	;$00  Main
;$00: Main
Enemy45_Sub0:
	ldy #$01
Enemy45_Sub0_Loop:
	;Check if player is active
	lda PlayerLives,y
	beq Enemy45_Sub0_Next
	;Check if player is grounded
	lda PlayerCollTypeBottom,y
	beq Enemy45_Sub0_Next
	;Clear sound
	jsr ClearSound
	;Play music
	lda #MUSIC_LEVEL3
	jsr LoadSound
	;Clear enemy
	jmp ClearEnemy
Enemy45_Sub0_Next:
	;Loop for each player
	dey
	bpl Enemy45_Sub0_Loop
	rts

;$F5: Level 4 crane
EnemyF5JumpTable:
	.dw EnemyF5_Sub0	;$00  Init
	.dw EnemyF5_Sub1	;$01  Wait
	.dw EnemyF5_Sub2	;$02  Main
	.dw EnemyF5_Sub3	;$03  End
;$01: Wait
EnemyF5_Sub1:
	;If bits 1-7 of scroll X position not 0, skip this part
	lda TempMirror_PPUSCROLL_X
	and #$FE
	bne EnemyF5_Sub0_EntWait
	;Set scroll lock settings
	sta TempScrollLockOther
	;Add IRQ buffer region (level 4 crane)
	lda #$0D
	jsr AddIRQBufferRegion
	;Set auto scroll flags
	lda #$01
	sta AutoScrollDirFlags
	;Set scroll lock flags
	lda #$02
	sta TempScrollLockFlags
;$00: Init
EnemyF5_Sub0:
	;Next task ($01: Wait)
	inc Enemy_Mode,x
EnemyF5_Sub0_EntWait:
	;Check for platform collision
	jmp EnemyF4_Sub1_EntL4Plat
;$02: Main
EnemyF5_Sub2:
	;If current X screen not $02, skip this part
	lda CurScreenX
	cmp #$02
	bne EnemyF5_Sub2_NoNext
	;Remove IRQ buffer region (level 4 crane)
	lda #$0D
	jsr RemoveIRQBufferRegion
	;Clear auto scroll flags
	lda #$00
	sta AutoScrollDirFlags
	;Clear scroll lock flags
	sta TempScrollLockFlags
	;If looping SFX, play sound
	lda ExplosionSoundLoopingID
	beq EnemyF5_Sub2_NextNoSound
	;Play sound
	lda #SE_LOOPEND
	jsr LoadSound
EnemyF5_Sub2_NextNoSound:
	;Clear looping SFX flag
	lda #$00
	sta ExplosionSoundLoopingID
	;Next task ($03: End)
	inc Enemy_Mode,x
	;Check for platform collision
	jmp EnemyF4_Sub1_EntL4Plat
EnemyF5_Sub2_NoNext:
	;Set enemy position
	lda #$80
	sta Enemy_Y+$08,x
	sta Enemy_X+$08,x
	;Check if no players are active
	lda PlayerHP
	ora PlayerHP+1
	beq EnemyF5_Sub2_CheckX
	;Check if player 1 is active
	lda PlayerLives
	beq EnemyF5_Sub2_NoP1
	;Check if player 1 is on platform
	lda PlayerCollTypeBottom
	bne EnemyF5_Sub2_SetP1Plat
	ldy Enemy_Temp4,x
	cpy #$1E
	bne EnemyF5_Sub2_CheckX
	;If player 1 Y position < $70, set player 1 on platform
	ldy Enemy_YHi
	bmi EnemyF5_Sub2_NoP1
	bne EnemyF5_Sub2_CheckX
	ldy Enemy_Y
	cpy #$70
	bcs EnemyF5_Sub2_CheckX
	bcc EnemyF5_Sub2_NoP1
EnemyF5_Sub2_SetP1Plat:
	sta Enemy_Temp4,x
	cmp #$1E
	bne EnemyF5_Sub2_CheckX
EnemyF5_Sub2_NoP1:
	;Check if player 2 is active
	lda PlayerLives+1
	beq EnemyF5_Sub2_NoP2
	;Check if player 2 is on platform
	lda PlayerCollTypeBottom+1
	bne EnemyF5_Sub2_SetP2Plat
	ldy Enemy_Temp5,x
	cpy #$1E
	bne EnemyF5_Sub2_CheckX
	;If player 2 Y position < $70, set player 2 on platform
	ldy Enemy_YHi+$01
	bmi EnemyF5_Sub2_NoP2
	bne EnemyF5_Sub2_CheckX
	ldy Enemy_Y+$01
	cpy #$70
	bcs EnemyF5_Sub2_CheckX
	bcc EnemyF5_Sub2_NoP2
EnemyF5_Sub2_SetP2Plat:
	sta Enemy_Temp5,x
	cmp #$1E
	beq EnemyF5_Sub2_NoP2
EnemyF5_Sub2_CheckX:
	;If platform acceleration not 0, play sound
	lda Enemy_AnimTimer,x
	beq EnemyF5_Sub2_NoSoundEnd
	lda #SE_LOOPEND
	jsr LoadSound
EnemyF5_Sub2_NoSoundEnd:
	;Clear platform acceleration
	lda #$00
	tay
	beq EnemyF5_Sub2_SetX
EnemyF5_Sub2_NoP2:
	;If platform acceleration 0, play sound
	lda Enemy_AnimTimer,x
	bne EnemyF5_Sub2_NoSound
	lda #SE_LEVEL4CRANE
	jsr LoadSound
EnemyF5_Sub2_NoSound:
	;Set platform acceleration
	ldy #$00
	lda #$D0
EnemyF5_Sub2_SetX:
	;Set looping SFX flag
	sta ExplosionSoundLoopingID
	;Set platform acceleration
	sta Enemy_AnimTimer,x
	;Apply platform acceleration
	clc
	adc Enemy_Temp3,x
	sta Enemy_Temp3,x
	bcc EnemyF5_Sub2_NoXC
	dey
EnemyF5_Sub2_NoXC:
	;Set auto scroll X velocity
	sty AutoScrollXVel
;$03: End
EnemyF5_Sub3:
	;Check for platform collision
	jmp EnemyF4_Sub1_EntL4Plat

;$40: BG water scroll
Enemy40JumpTable:
	.dw Enemy40_Sub0	;$00  Init part 1
	.dw Enemy40_Sub1	;$01  Init part 2
	.dw Enemy40_Sub2	;$02  Main
;$00: Init part 1
Enemy40_Sub0:
	;If bit 0 of scroll X position not 0, exit early
	lda TempMirror_PPUSCROLL_X
	lsr
	bne Enemy40_Sub0_Exit
	;Next task ($01: Init part 2)
	inc Enemy_Mode+$0C
Enemy40_Sub0_Exit:
	rts
;$01: Init part 2
Enemy40_Sub1:
	;Add IRQ buffer region (level 3 water layer 1)
	lda #$0A
	jsr AddIRQBufferRegion
	;Set IRQ buffer height for level 3 water layer 1
	lda #$02
	sta TempIRQBufferHeight+1
	;Reset section counter
	lda #$08
	sta Enemy_Temp2+$0C
	;Next task ($02: Main)
	inc Enemy_Mode+$0C
;$02: Main
Enemy40_Sub2:
	rts

;$3F: BG waterfall
Enemy3FJumpTable:
	.dw Enemy3F_Sub0	;$00  Init
	.dw Enemy3F_Sub1	;$01  Set init
	.dw Enemy3F_Sub2	;$02  Set
	.dw Enemy3F_Sub3	;$03  Clear wait
	.dw Enemy3F_Sub4	;$04  Clear init
	.dw Enemy3F_Sub5	;$05  Clear
	.dw Enemy3F_Sub6	;$06  Set wait
	.dw Enemy3F_Sub7	;$07  End
;$00: Init
Enemy3F_Sub0:
	;If enemy X position >= $F0, exit early
	lda Enemy_XHi+$08,x
	bne Enemy3F_Sub0_Exit
	lda Enemy_X+$08,x
	cmp #$F0
	bcs Enemy3F_Sub0_Exit
	;Get BG waterfall VRAM address data index
	lda BGWaterfallVRAMIndex-$09,x
	sta Enemy_Temp5,x
	;Set Charon spawner active flag
	ldy BGWaterfallSpawnerEnemyIndex-$09,x
	lda #$01
	sta Enemy_Temp3,y
	;Next task ($01: Set init)
	inc Enemy_Mode,x
Enemy3F_Sub0_Exit:
	rts
BGWaterfallVRAMIndex:
	.db $00,$01,$02
BGWaterfallVRAMAddress:
	.dw $20B6,$20AE,$20A6
;$01: Set init
Enemy3F_Sub1:
	;Play sound
	lda #SE_BGWATERFALL
	jsr LoadSound
;$04: Clear init
Enemy3F_Sub4:
	;Get BG waterfall VRAM address
	lda Enemy_Temp5,x
	asl
	tay
	lda BGWaterfallVRAMAddress,y
	sta Enemy_Temp2,x
	lda BGWaterfallVRAMAddress+1,y
	sta Enemy_Temp3,x
	;Next task ($02: Set)
	inc Enemy_Mode,x
	rts
;$02: Set
Enemy3F_Sub2_NoNext:
	;If current BG waterfall row < $08, exit early
	lda Enemy_Temp4,x
	cmp #$08
	bcc Enemy3F_Sub2_Exit
	;Set enemy flags
	lda #(EF_NOHITATTACK|$0F)
	sta Enemy_Flags,x
Enemy3F_Sub2_Exit:
	rts
Enemy3F_Sub2:
	;Update BG waterfall VRAM data
	jsr BGWaterfallVRAMSub
	;Check for end of BG waterfall
	bcc Enemy3F_Sub2_NoNext
	;Set animation timer
	lda #$08
	sta Enemy_Temp1,x
Enemy3F_Sub2_Next:
	;Next task ($03: Clear wait)
	inc Enemy_Mode,x
	rts
;$03: Clear wait
Enemy3F_Sub3:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy3F_Sub2_Next
	rts
;$05: Clear
Enemy3F_Sub5_NoNext:
	;If current BG waterfall row >= $08, exit early
	lda Enemy_Temp4,x
	cmp #$08
	bcs Enemy3F_Sub5_Exit
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK)
	sta Enemy_Flags,x
Enemy3F_Sub5_Exit:
	rts
Enemy3F_Sub5:
	;Update BG waterfall VRAM data
	jsr BGWaterfallVRAMSub
	;Check for end of BG waterfall
	bcc Enemy3F_Sub5_NoNext
	;Set animation timer
	inc Enemy_AnimTimer,x
	lda Enemy_AnimTimer,x
	and #$01
	tay
	lda BGWaterfallAnimationTimer,y
	sta Enemy_Temp1,x
	;If enemy X position < $50, go to next task ($07: End)
	lda Enemy_XHi+$08,x
	bne Enemy3F_Sub6_End
	lda Enemy_X+$08,x
	cmp #$50
	bcc Enemy3F_Sub6_End
	;Next task ($06: Set wait)
	inc Enemy_Mode,x
	rts
;$06: Set wait
Enemy3F_Sub6:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy3F_Sub6_Exit
	;If enemy X position < $50, go to next task ($07: End)
	lda Enemy_XHi+$08,x
	bne Enemy3F_Sub6_End
	lda Enemy_X+$08,x
	cmp #$50
	bcc Enemy3F_Sub6_End
	;Next task ($01: Set init)
	lda #$01
	sta Enemy_Mode,x
	;Set Charon spawner active flag
	ldy BGWaterfallSpawnerEnemyIndex-$09,x
	lda #$01
	sta Enemy_Temp3,y
Enemy3F_Sub6_Exit:
	rts
Enemy3F_Sub6_End:
	;Next task ($07: End)
	lda #$07
	sta Enemy_Mode,x
;$07: End
Enemy3F_Sub7:
	rts
BGWaterfallAnimationTimer:
	.db $60,$10
BGWaterfallSpawnerEnemyIndex:
	.db $02,$03,$04
BGWaterfallVRAMSub:
	;If not enough space in VRAM buffer, exit early
	lda VRAMBufferOffset
	cmp #$28
	bcs BGWaterfallVRAMSub_NoNext
	;Save X register
	stx $10
	;Get BG waterfall VRAM address
	lda Enemy_Temp2,x
	sta $11
	lda Enemy_Temp3,x
	sta $12
	;Get BG waterfall VRAM data offset
	lda Enemy_Temp4,x
	asl
	asl
	tay
	;Get BG waterfall mode
	lda Enemy_Mode,x
	sta $13
	;Init VRAM buffer row
	lda #$01
	jsr WriteVRAMBufferCmd
	;Set VRAM buffer address
	lda $11
	jsr WriteVRAMBufferCmd
	lda $12
	jsr WriteVRAMBufferCmd
	;Set tiles in VRAM
	lda #$04
	sta $11
	;Check for BG waterfall set mode
	lda $13
	cmp #$03
	bcc BGWaterfallVRAMSub_SetLoop
BGWaterfallVRAMSub_ClearLoop:
	;Set tile in VRAM
	lda BGWaterfallClearVRAMData,y
	jsr WriteVRAMBufferCmd
	;Loop for each tile
	iny
	dec $11
	bne BGWaterfallVRAMSub_ClearLoop
	beq BGWaterfallVRAMSub_End
BGWaterfallVRAMSub_SetLoop:
	;Set tile in VRAM
	lda BGWaterfallSetVRAMData,y
	jsr WriteVRAMBufferCmd
	;Loop for each tile
	iny
	dec $11
	bne BGWaterfallVRAMSub_SetLoop
BGWaterfallVRAMSub_End:
	;End VRAM buffer
	jsr WriteVRAMBufferCmd_End
	;Restore X register
	ldx $10
	;Increment current BG waterfall row
	inc Enemy_Temp4,x
	;Check for end of BG waterfall
	lda Enemy_Temp4,x
	cmp #$0F
	bcs BGWaterfallVRAMSub_Next
	;Increment BG waterfall VRAM address
	lda Enemy_Temp2,x
	clc
	adc #$20
	sta Enemy_Temp2,x
	lda Enemy_Temp3,x
	adc #$00
	sta Enemy_Temp3,x
BGWaterfallVRAMSub_NoNext:
	;Clear carry flag
	clc
	rts
BGWaterfallVRAMSub_Next:
	;Clear current BG waterfall row
	lda #$00
	sta Enemy_Temp4,x
	;Set carry flag
	sec
	rts
BGWaterfallSetVRAMData:
	.db $B9,$34,$34,$35
	.db $BC,$BD,$BC,$BD
	.db $00,$00,$00,$00
	.db $BA,$BB,$BA,$BB
	.db $BC,$BD,$BC,$BD
	.db $00,$00,$00,$00
	.db $00,$00,$00,$00
	.db $BA,$BB,$BA,$BB
	.db $BC,$BD,$BC,$BD
	.db $00,$00,$00,$00
	.db $00,$00,$00,$00
	.db $BA,$BB,$BA,$BB
	.db $BC,$BD,$BC,$BD
	.db $00,$00,$00,$00
	.db $00,$00,$00,$00
BGWaterfallClearVRAMData:
	.db $5D,$00,$00,$5E
	.db $66,$67,$68,$69
	.db $70,$71,$72,$73
	.db $79,$7A,$7B,$7C
	.db $08,$08,$06,$06
	.db $0B,$0C,$0C,$0B
	.db $10,$11,$0F,$10
	.db $03,$04,$21,$01
	.db $08,$09,$05,$06
	.db $0B,$0D,$0A,$0B
	.db $11,$12,$0E,$0F
	.db $02,$03,$01,$02
	.db $07,$08,$06,$07
	.db $0C,$0B,$0B,$0C
	.db $10,$11,$0F,$10

;$F4: Level 3 platform
EnemyF4JumpTable:
	.dw EnemyF4_Sub0	;$00  Init
	.dw EnemyF4_Sub1	;$01  Main
;$00: Init
EnemyF4_Sub0:
	;Load CHR bank
	lda #$2C
	sta TempCHRBanks+2
	;Set IRQ buffer height for level 3 water layer 1
	lda #$30
	sta TempIRQBufferHeight+1
	;Add IRQ buffer region (level 3 water layer 2)
	lda #$06
	jsr AddIRQBufferRegion
	;Set IRQ buffer height for level 3 water layer 1
	lda #$02
	sta TempIRQBufferHeight+1
	;Set enemy Y velocity
	lda #$40
	sta Enemy_YVelLo,x
	;Set animation timer
	lda #$01
	sta Enemy_Temp5,x
	;Set enemy sprite
	lda #$3F
	sta Enemy_Sprite+$08,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
	rts
;$01: Main
EnemyF4_Sub1:
	;Move enemy
	jsr MoveEnemyXY
	;Check if no players are active
	lda PlayerLives
	ora PlayerLives+1
	beq EnemyF4_Sub1_CheckX
	;Check if player 1 is active
	lda #$00
	ldy PlayerLives
	beq EnemyF4_Sub1_NoP1
	;Check if player 1 is on platform
	ldy PlayerCollTypeBottom
	cpy #$1E
	bne EnemyF4_Sub1_CheckX
EnemyF4_Sub1_NoP1:
	;Check if player 2 is active
	ldy PlayerLives+1
	beq EnemyF4_Sub1_CheckPos
	;Check if player 2 is on platform
	ldy PlayerCollTypeBottom+1
	cpy #$1E
	beq EnemyF4_Sub1_CheckPos
EnemyF4_Sub1_CheckX:
	;If enemy X position >= $40, don't move
	ldy Enemy_XHi+$08,x
	bmi EnemyF4_Sub1_CheckPos
	bne EnemyF4_Sub1_SetX
	ldy Enemy_X+$08,x
	cpy #$40
	bcs EnemyF4_Sub1_SetX
EnemyF4_Sub1_CheckPos:
	;If platform position >= $0410, don't move
	ldy Enemy_AnimOffs,x
	cpy #$04
	bcc EnemyF4_Sub1_Move
	ldy Enemy_AnimTimer,x
	cpy #$10
	bcs EnemyF4_Sub1_SetX
EnemyF4_Sub1_Move:
	;Increment platform position
	lda #$90
	inc Enemy_AnimTimer,x
	bne EnemyF4_Sub1_SetX
	inc Enemy_AnimOffs,x
EnemyF4_Sub1_SetX:
	;Set enemy X velocity
	sta Enemy_XVelLo,x
	;Update platform animation
	jsr Level3PlatformAnimSub
	jmp EnemyF4_Sub1_EntL4Plat
EnemyF4_Sub1_EntL4Plat:
	;Check if no players are on platform
	ldy Enemy_Temp2,x
	beq ClearPlayerOnPlatform
	;If enemy offscreen, exit early
	lda Enemy_YHi+$08,x
	ora Enemy_XHi+$08,x
	bne SetPlayerOnPlatform_Exit
	;Check if both players are on platform
	cpy #$03
	beq SetPlayerOnPlatform
	;Handle 1 player on platform
	dey
	jsr SetPlayerOnPlatformSub
	tya
	eor #$01
	tay
	jsr ClearPlayerOnPlatformSub
	jmp SetPlayerOnPlatform_Exit
SetPlayerOnPlatformSub:
	;If player distance above enemy < $1C, exit early
	lda Enemy_Y,y
	clc
	adc #$1C
	cmp Enemy_Y+$08,x
	bcs SetPlayerOnPlatformSub_Exit
	;Set player on platform
	lda #$1E
	sta PlayerCollTypeBottom,y
	txa
	sta PlayerPlatformIndex,y
SetPlayerOnPlatformSub_Exit:
	rts
SetPlayerOnPlatform:
	;Set player 1 on platform
	ldy #$00
	jsr SetPlayerOnPlatformSub
	;Set player 2 on platform
	ldy #$01
	jsr SetPlayerOnPlatformSub
SetPlayerOnPlatform_Exit:
	;Clear player platform collision flags
	lda #$00
	sta Enemy_Temp2,x
	rts
ClearPlayerOnPlatform:
	;Clear players on platform
	ldy #$01
ClearPlayerOnPlatform_Loop:
	;Clear player on platform
	jsr ClearPlayerOnPlatformSub
	;Loop for each player
	dey
	bpl ClearPlayerOnPlatform_Loop
	bmi SetPlayerOnPlatform_Exit
ClearPlayerOnPlatformSub:
	;If player not on platform, exit early
	lda PlayerCollTypeBottom,y
	cmp #$1E
	bne ClearPlayerOnPlatformSub_Exit
	txa
	cmp PlayerPlatformIndex,y
	bne ClearPlayerOnPlatformSub_Exit
	;Clear player on platform
	lda #$00
	sta PlayerCollTypeBottom,y
ClearPlayerOnPlatformSub_Exit:
	rts
Level3PlatformAnimSub:
	;Decrement animation timer, check if 0
	dec Enemy_Temp5,x
	bne Level3PlatformAnimSub_NoSound
	;Set animation timer
	lda #$20
	sta Enemy_Temp5,x
	;Set enemy Y velocity data offset
	lda Enemy_Temp4,x
	eor #$02
	sta Enemy_Temp4,x
	beq Level3PlatformAnimSub_NoSound
	;If platform position 0, play sound
	lda Enemy_AnimTimer,x
	ora Enemy_AnimOffs,x
	beq Level3PlatformAnimSub_NoSound
	;Play sound
	lda #SE_BGWATERSCROLL
	jsr LoadSound
Level3PlatformAnimSub_NoSound:
	;Set enemy Y velocity
	ldy Enemy_Temp4,x
	lda Enemy_YVelLo,x
	clc
	adc Level3PlatformYVelocity+1,y
	sta Enemy_YVelLo,x
	lda Enemy_YVel,x
	adc Level3PlatformYVelocity,y
	sta Enemy_YVel,x
	rts
Level3PlatformYVelocity:
	.db $00,$04
	.db $FF,$FC

;$3D: Level 4 elevator
Enemy3DJumpTable:
	.dw Enemy3D_Sub0	;$00  Init
	.dw Enemy3D_Sub1	;$01  Up init
	.dw Enemy3D_Sub2	;$02  Up part 1
	.dw Enemy3D_Sub3	;$03  Accelerate
	.dw Enemy3D_Sub4	;$04  Up part 2
	.dw Enemy3D_Sub5	;$05  Decelerate
	.dw Enemy3D_Sub6	;$06  Up part 3
	.dw Enemy3D_Sub7	;$07  Slow down
	.dw Enemy3D_Sub8	;$08  Stop
;$00: Init
Enemy3D_Sub0:
	;If enemy offscreen horizontally, exit early
	lda Enemy_XHi+$12
	bne Enemy3D_Sub0_Exit
	;If scroll X position < $C0, exit early
	lda TempMirror_PPUSCROLL_X
	cmp #$C0
	bcc Enemy3D_Sub0_Exit
	;Next task ($01: Up init)
	inc Enemy_Mode+$0A
Enemy3D_Sub0_Exit:
	rts
;$01: Up init
Enemy3D_Sub1:
	;Update elevator VRAM
	jsr Level4ElevatorVRAMSub
	;Check for end of VRAM strip
	lda Enemy_Temp2+$0A
	cmp #$02
	bne Enemy3D_Sub0_Exit
	;Add IRQ buffer region (level 4 elevator layer 2)
	lda #$07
	jsr AddIRQBufferRegion
	;Set elevator position
	lda #$98
	sta ElevatorYPos
	;Set auto scroll flags
	lda #$08
	sta AutoScrollDirFlags
	;Disable enemy scroll
	sta ScrollEnemyFlag
	;Set auto scroll Y velocity
	lda #$FF
	sta AutoScrollYVel
	;Play sound
	lda #SE_LEVEL4ELEV
	jsr LoadSound
	;Set looping SFX flag
	dec ExplosionSoundLoopingID
	;Next task ($02: Up part 1)
	inc Enemy_Mode+$0A
	rts
;$02: Up part 1
Enemy3D_Sub2:
	;If scroll Y position not 0, skip this part
	lda TempMirror_PPUSCROLL_Y
	bne Enemy3D_Sub2_NoNext
	;Clear auto scroll flags
	lda #$00
	sta AutoScrollDirFlags
	;Set scroll lock flags
	lda #$01
	sta TempScrollLockFlags
	;Set elevator Y velocity
	lda #$02
	sta Enemy_Temp4+$0A
	;Next task ($03: Accelerate)
	inc Enemy_Mode+$0A
	;Update elevator scroll
	jmp Level4ElevatorScrollSub
Enemy3D_Sub2_NoNext:
	;If scroll Y position $80, set auto scroll Y velocity
	cmp #$80
	bne Enemy3D_Sub2_NoSetY
	;Set auto scroll Y velocity
	lda #$FE
	sta AutoScrollYVel
Enemy3D_Sub2_NoSetY:
	;Update elevator VRAM
	jmp Level4ElevatorVRAMSub
;$03: Accelerate
Enemy3D_Sub3:
	;Accelerate elevator Y velocity
	lda Enemy_Temp5+$0A
	clc
	adc #$04
	sta Enemy_Temp5+$0A
	bcc Enemy3D_Sub3_NoYC
	inc Enemy_Temp4+$0A
Enemy3D_Sub3_NoYC:
	;Update elevator scroll
	jsr Level4ElevatorScrollSub
	;If elevator Y velocity $08, go to next task ($04: Up part 2)
	lda Enemy_Temp5+$0A
	bne Enemy3D_Sub3_Exit
	lda Enemy_Temp4+$0A
	cmp #$08
	bne Enemy3D_Sub3_Exit
	;Set screen counter
	lda #$15
	sta Enemy_AnimTimer+$0A
	;Next task ($04: Up part 2)
	inc Enemy_Mode+$0A
Enemy3D_Sub3_Exit:
	rts
;$04: Up part 2
Enemy3D_Sub4:
	;Update elevator scroll
	jsr Level4ElevatorScrollSub
	;If no screen wrap, exit early
	lda $11
	beq Enemy3D_Sub4_Exit
	;Decrement screen counter, check if 0
	dec Enemy_AnimTimer+$0A
	bne Enemy3D_Sub4_Exit
	;Next task ($05: Decelerate)
	inc Enemy_Mode+$0A
Enemy3D_Sub4_Exit:
	rts
;$05: Decelerate
Enemy3D_Sub5:
	;Decelerate elevator Y velocity
	lda Enemy_Temp5+$0A
	sec
	sbc #$08
	sta Enemy_Temp5+$0A
	bcs Enemy3D_Sub5_NoYC
	dec Enemy_Temp4+$0A
Enemy3D_Sub5_NoYC:
	;Update elevator scroll
	jsr Level4ElevatorScrollSub
	;If elevator Y velocity $02, go to next task ($06: Up part 3)
	lda Enemy_Temp5+$0A
	bne Enemy3D_Sub5_Exit
	lda Enemy_Temp4+$0A
	cmp #$02
	bne Enemy3D_Sub5_Exit
	;Next task ($06: Up part 3)
	inc Enemy_Mode+$0A
Enemy3D_Sub5_Exit:
	rts
;$06: Up part 3
Enemy3D_Sub6:
	;If elevator Y position not 0, skip this part
	lda TempScrollLockOther
	bne Level4ElevatorScrollSub
	;Set auto scroll flags
	lda #$08
	sta AutoScrollDirFlags
	;Clear scroll lock flags
	lda #$00
	sta TempScrollLockFlags
	;Next task ($07: Slow down)
	inc Enemy_Mode+$0A
	;Play sound
	lda #SE_LEVEL4ELEVSLOW
	jmp LoadSound
;$07: Slow down
Enemy3D_Sub7:
	;If scroll Y position not 0, skip this part
	lda TempMirror_PPUSCROLL_Y
	bne Enemy3D_Sub7_NoNext
	;Clear auto scroll flags/Y velocity
	lda #$00
	sta AutoScrollDirFlags
	sta AutoScrollYVel
	;Set current Y screen
	sta CurScreenY
	;Enable enemy scroll
	sta ScrollEnemyFlag
	;Next task ($08: Stop)
	inc Enemy_Mode+$0A
	;Write enemy VRAM strip (level 4 elevator)
	lda #$06
	jsr WriteEnemyVRAMStrip38
	;Play sound
	lda #SE_LEVEL4ELEVSTOP
	jmp LoadSound
Enemy3D_Sub7_NoNext:
	;Update elevator VRAM
	jmp Level4ElevatorVRAMSub
;$08: Stop
Enemy3D_Sub8:
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	beq Enemy3D_Sub8_End
	;Write enemy VRAM strip (level 4 elevator)
	jmp WriteEnemyVRAMStrip38
Enemy3D_Sub8_End:
	;Remove IRQ buffer region (level 4 elevator layer 2)
	lda #$07
	jmp RemoveIRQBufferRegion
Level4ElevatorScrollSub:
	;Clear screen wrap flag
	lda #$00
	sta $11
	;Apply elevator Y velocity
	lda TempScrollLockOther
	sec
	sbc Enemy_Temp4+$0A
	bcs Level4ElevatorScrollSub_NoYC
	adc #$C0
Level4ElevatorScrollSub_NoYC:
	sta TempScrollLockOther
	;If elevator Y position < $02, check to add IRQ buffer region
	ldy TempIRQBufferSub
	lda #$C0
	sec
	sbc TempScrollLockOther
	cmp #$02
	bcc Level4ElevatorScrollSub_NoYC2
	;If elevator Y position >= $AF, check to remove IRQ buffer region
	cmp #$AF
	bcs Level4ElevatorScrollSub_CheckRemL1
Level4ElevatorScrollSub_CheckAddL1:
	;Check if level 4 elevator layer 1 IRQ buffer region is active
	sta $10
	cpy #$0B
	beq Level4ElevatorScrollSub_NoAddL1
	;Add IRQ buffer region (level 4 elevator layer 1)
	lda #$0B
	jsr AddIRQBufferRegion
Level4ElevatorScrollSub_NoAddL1:
	;Set IRQ buffer height for level 4 elevator
	lda #$B0
	sec
	sbc $10
	sta TempIRQBufferHeight+1
	;Set IRQ buffer height for main game
	lda $10
	sta TempIRQBufferHeight
	rts
Level4ElevatorScrollSub_NoYC2:
	;Set elevator Y position
	lda #$BE
	sta TempScrollLockOther
	;Check to add IRQ buffer region
	lda #$02
	bne Level4ElevatorScrollSub_CheckAddL1
Level4ElevatorScrollSub_CheckRemL1:
	;Check if level 4 elevator layer 1 IRQ buffer region is active
	cpy #$0B
	bne Level4ElevatorScrollSub_Exit
	;Set screen wrap flag
	inc $11
	;Remove IRQ buffer region (level 4 elevator layer 1)
	lda #$0B
	jsr RemoveIRQBufferRegion
	;Set IRQ buffer height for main game
	lda #$B0
	sta TempIRQBufferHeight
	;Set IRQ buffer height for level 4 elevator layer 2
	lda #$0F
	sta TempIRQBufferHeight+1
Level4ElevatorScrollSub_Exit:
	rts
Level4ElevatorVRAMSub:
	;Check for end of VRAM strip
	lda ElevatorInitFlag
	beq Level4ElevatorVRAMSub_CheckNext
	;Write enemy VRAM strip (level 4 elevator)
	jmp WriteEnemyVRAMStrip38
Level4ElevatorVRAMSub_CheckNext:
	;Check to write next enemy VRAM strip
	lda Enemy_Temp3+$0A
	beq Level4ElevatorVRAMSub_CheckPos
	;Decrement elevator position index
	dec Enemy_Temp2+$0A
	bpl Level4ElevatorVRAMSub_NoC
	lda #$02
	sta Enemy_Temp2+$0A
Level4ElevatorVRAMSub_NoC:
	;Clear elevator position index decrement flag
	lda #$00
	sta Enemy_Temp3+$0A
	rts
Level4ElevatorVRAMSub_CheckPos:
	;Check for elevator position index 0
	lda CurScreenY
	ldy Enemy_Temp2+$0A
	beq Level4ElevatorVRAMSub_Check0
	;Check for elevator position index 2
	cpy #$02
	beq Level4ElevatorVRAMSub_Check2
	;If current Y scroll position < $18, write next enemy VRAM strip
	lda TempMirror_PPUSCROLL_Y
	cmp #$18
	bcc Level4ElevatorVRAMSub_Next
	rts
Level4ElevatorVRAMSub_Check2:
	;Check if using bottom nametable
	lsr
	bcc Level4ElevatorVRAMSub_Exit
	;If current Y scroll position < $A8, write next enemy VRAM strip
	lda TempMirror_PPUSCROLL_Y
	cmp #$A8
	bcs Level4ElevatorVRAMSub_Exit
Level4ElevatorVRAMSub_Next:
	;Set elevator position index decrement flag
	inc Enemy_Temp3+$0A
	;Write enemy VRAM strip (level 4 elevator)
	ldy Enemy_Temp2+$0A
	lda Level4ElevatorEnemyVRAMStrip,y
	jmp WriteEnemyVRAMStrip38
Level4ElevatorVRAMSub_Exit:
	rts
Level4ElevatorVRAMSub_Check0:
	;Check if using bottom nametable
	lsr
	bcs Level4ElevatorVRAMSub_Exit
	;If current Y scroll position < $58, write next enemy VRAM strip
	lda TempMirror_PPUSCROLL_Y
	cmp #$58
	bcs Level4ElevatorVRAMSub_Exit
	bcc Level4ElevatorVRAMSub_Next
Level4ElevatorEnemyVRAMStrip:
	.db $02,$00,$01

;;;;;;;;;;;;;;;;
;NAMETABLE DATA;
;;;;;;;;;;;;;;;;
Nametable14Data:
	.dw $20C8
	.db $C8,$42,$81,$42,$C3,$4B,$84,$48,$49,$4E,$4F,$10,$00,$C8,$52,$81
	.db $52,$C3,$5B,$84,$58,$59,$5E,$5F,$80,$CD,$22,$C6,$01,$19,$00,$C8
	.db $10,$18,$00,$C8,$20,$18,$00,$C8,$30,$00
	.db $FF

;;;;;;;;;;;;;;;;;;;;
;GAME MODE ROUTINES;
;;;;;;;;;;;;;;;;;;;;
;LEVEL START MODE ROUTINES
RunGameMode_LevelStart:
	;Do jump table
	lda GameSubmode
	jsr DoJumpTable
LevelStartJumpTable:
	.dw RunGameSubmode_LevelStartLoadPart1	;$00  Load part 1
	.dw RunGameSubmode_LevelStartLoadPart2	;$01  Load part 2
	.dw RunGameSubmode_LevelStartWait	;$02  Wait
	.dw RunGameSubmode_LevelStartFadeOut	;$03  Fade out

;$00: Load part 1
RunGameSubmode_LevelStartLoadPart1:
	;Clear screen
	jsr ClearScreen
	;Clear palette
	lda #$00
	sta CurPalette
	;Write level start nametable
	ldx #$16
	jsr WriteNametableData
	;Load CHR banks
	lda #$7C
	sta TempCHRBanks
	lda #$7A
	sta TempCHRBanks+1
	;Write VRAM strip (level number)
	ldy CurLevel
	lda LevelStartVRAMStrip0Table,y
	jsr WriteVRAMStrip
	;Set timer
	lda #$C0
	sta GameModeTimer2
	rts

;$01: Load part 2
RunGameSubmode_LevelStartLoadPart2:
	;Next submode ($02: Wait)
	inc GameSubmode
	;Write VRAM strip (level name)
	ldy CurLevel
	lda LevelStartVRAMStrip1Table,y
	jmp WriteVRAMStrip

;$02: Wait
RunGameSubmode_LevelStartWait:
	;Fade palette
	jsr FadePalette
	;Decrement timer, check if 0
	dec GameModeTimer2
	bne RunGameSubmode_LevelStartWait_Exit
	;Next submode ($03: Fade out)
	inc GameSubmode
RunGameSubmode_LevelStartWait_Exit:
	rts

;$03: Fade out
RunGameSubmode_LevelStartFadeOut:
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_LevelStartWait_Exit
	;Next mode ($06: Main game)
	jmp GoToNextGameMode

LevelStartVRAMStrip0Table:
	.db $3F,$40,$41,$42,$43,$44
LevelStartVRAMStrip1Table:
	.db $45,$46,$47,$48,$49,$4A

;;;;;;;;;;;;;;;;;
;VRAM STRIP DATA;
;;;;;;;;;;;;;;;;;
VRAMStrip3FData:
	.dw $2115
	.db $64,$65
	.db $FE
	.dw $2135
	.db $74,$75
	.db $FF
VRAMStrip40Data:
	.dw $2115
	.db $66,$67
	.db $FE
	.dw $2135
	.db $76,$77
	.db $FF
VRAMStrip41Data:
	.dw $2115
	.db $68,$69
	.db $FE
	.dw $2135
	.db $78,$79
	.db $FF
VRAMStrip42Data:
	.dw $2115
	.db $6A,$6B
	.db $FE
	.dw $2135
	.db $7A,$7B
	.db $FF
VRAMStrip43Data:
	.dw $2115
	.db $6C,$6D
	.db $FE
	.dw $2135
	.db $7C,$7D
	.db $FF
VRAMStrip44Data:
	.dw $2115
	.db $6E,$6F
	.db $FE
	.dw $2135
	.db $7E,$7F
	.db $FF
VRAMStrip45Data:
	.dw $21C5
	.db $F6,$E6,$E8,$E7,$EC,$ED,$DE,$EB,$EC,$00,$E2,$E7,$00,$E6,$F2,$00
	.db $E1,$E8,$EE,$EC,$DE,$F6
	.db $FF
VRAMStrip46Data:
	.dw $21C2
	.db $F6,$DB,$E2,$E0,$00,$ED,$EB,$E8,$EE,$DB,$E5,$DE,$00,$E2,$E7,$00
	.db $ED,$E1,$DE,$00,$E4,$E2,$ED,$DC,$E1,$DE,$E7,$F6
	.db $FF
VRAMStrip47Data:
	.dw $21C3
	.db $F6,$DC,$EB,$E2,$EC,$E2,$EC,$00,$DF,$EB,$E8,$E6,$00,$EE,$E7,$DD
	.db $DE,$EB,$E0,$EB,$E8,$EE,$E7,$DD,$F6
	.db $FF
VRAMStrip48Data:
	.dw $21C5
	.db $F6,$ED,$E8,$F0,$DE,$EB,$E2,$E7,$E0,$00,$DC,$DA,$ED,$DA,$EC,$ED
	.db $EB,$E8,$E9,$E1,$DE,$F6
	.db $FF
VRAMStrip49Data:
	.dw $21C7
	.db $F6,$E8,$EB,$E2,$DE,$E7,$ED,$DA,$E5,$00,$E2,$E5,$E5,$EE,$EC,$E2
	.db $E8,$E7,$F6
	.db $FF
VRAMStrip4AData:
	.dw $21C3
	.db $F6,$E5,$DA,$EC,$ED,$00,$DB,$DA,$ED,$ED,$E5,$DE,$00
	.db $FE
	.dw $2209
	.db $DA,$ED,$00,$E6,$E8,$E7,$EC,$ED,$DE,$EB,$00,$E6,$E8,$EE,$E7,$ED
	.db $DA,$E2,$E7,$F6
	.db $FF

;;;;;;;;;;;;;;;;
;NAMETABLE DATA;
;;;;;;;;;;;;;;;;
Nametable16Data:
	.dw $2109
	.db $C4,$60,$86,$44,$45,$42,$43,$48,$49,$16,$00,$C4,$70,$86,$54,$55
	.db $52,$53,$58,$59,$80,$8D,$22,$C6,$01,$19,$00,$C8,$10,$18,$00,$C8
	.db $20,$18,$00,$C8,$30,$00

;UNUSED SPACE
	;$324 bytes of free space available
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF

	.org $C000
