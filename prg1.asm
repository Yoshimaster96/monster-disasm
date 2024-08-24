	.base $8000
	.org $8000
;BANK NUMBER
	.db $32

;;;;;;;;;;;;;;
;HUD ROUTINES;
;;;;;;;;;;;;;;
	nop
UpdateHUD:
	;Check for ending HUD
	lda EndingHUDFlag
	beq UpdateHUD_NoCutscene
	;Set next HUD position 0
	lda #$00
	sta HUDPositionNext
	jmp DrawHUDRow
UpdateHUD_NoCutscene:
	;Get HUD scroll table index based on Y scroll position and current HUD position
	lda CurScreenY
	and #$01
	sta $10
	lda HUDPositionCur
	asl
	asl
	tay
	;Check to move HUD position up
	lda HUDPositionScrollTable,y
	cmp $10
	beq UpdateHUD_CheckUp2
	bcc UpdateHUD_CheckDown
	cpy #$08
	beq UpdateHUD_CheckDown
	bne UpdateHUD_Up
UpdateHUD_CheckUp2:
	lda HUDPositionScrollTable+1,y
	cmp TempMirror_PPUSCROLL_Y
	bcc UpdateHUD_CheckDown
UpdateHUD_Up:
	;Check to update HUD VRAM pointer
	lda HUDPositionChangeFlag
	bne GetHUDPosition
	;Decrement HUD position (move up)
	ldx HUDPositionCur
	dex
	bpl UpdateHUD_SetPos
	ldx #$02
	bne UpdateHUD_SetPos
UpdateHUD_CheckDown:
	;Check to move HUD position down
	lda $10
	cmp HUDPositionScrollTable+2,y
	beq UpdateHUD_CheckDown2
	bcc NoChangeHUDPosition
	cpy #$08
	beq NoChangeHUDPosition
	bne UpdateHUD_Down
UpdateHUD_CheckDown2:
	lda TempMirror_PPUSCROLL_Y
	cmp HUDPositionScrollTable+3,y
	bcc NoChangeHUDPosition
UpdateHUD_Down:
	;Check to update HUD VRAM pointer
	lda HUDPositionChangeFlag
	bne GetHUDPosition
	;Increment HUD position (move down)
	ldx HUDPositionCur
	inx
	cpx #$03
	bcc UpdateHUD_SetPos
	ldx #$00
UpdateHUD_SetPos:
	;Set next HUD position
	stx HUDPositionNext
	jmp ChangeHUDPosition

GetHUDPosition:
	;Check if using bottom nametable
	ldy TempMirror_PPUSCROLL_Y
	lda CurScreenY
	lsr
	bcs GetHUDPosition_Bottom
	;If current Y scroll position < $58, set HUD position 2
	lda #$02
	cpy #$58
	bcc GetHUDPosition_Set
GetHUDPosition_Pos0:
	;Set HUD position 0
	lda #$00
	beq GetHUDPosition_Set
GetHUDPosition_Bottom:
	;If current Y scroll position < $08, set HUD position 0
	cpy #$08
	bcc GetHUDPosition_Pos0
	;If current Y scroll position < $A8, set HUD position 1
	lda #$01
	cpy #$A8
	bcc GetHUDPosition_Set
	;Set HUD position 0
	lda #$02
GetHUDPosition_Set:
	;If current HUD position = new HUD position, don't update HUD position
	cmp HUDPositionCur
	beq GetHUDPosition_NoChange
	;Update HUD position
	ldx HUDPositionCur
	stx HUDPositionNext
	sta HUDPositionCur
	asl
	tax
	lda HUDVRAMBaseTable,x
	sta HUDVRAMBase
	lda HUDVRAMBaseTable+1,x
	sta HUDVRAMBase+1
GetHUDPosition_NoChange:
	;Draw HUD row
	jmp DrawHUDRow

NoChangeHUDPosition:
	;Don't change HUD position
	lda #$00
	sta HUDPositionChangeFlag
	jmp DrawHUDRow

;HUD SCROLL DATA
HUDVRAMBaseTable:
	.dw $2000
	.dw $2280
	.dw $2980
HUDPositionScrollTable:
	.db $00,$68,$00,$E8
	.db $01,$18,$01,$98
	.db $01,$B8,$00,$48

ChangeHUDPosition:
	;Change HUD position
	lda #$00
	sta HUDRowIndex
	inc HUDPositionChangeFlag

DrawHUDRow:
	;Draw HUD row
	jsr DrawHUDRowSub
	inc UpdateHUDRowFlag
	rts

DrawHUDRowSub:
	;Check for row 0 (border top)
	lda HUDRowIndex
	beq DrawHUDRowSub_BorderTopInit
	and #$03
	beq DrawHUDRowSub_BorderTopNoInit
	;Check for row 1 (score/lives)
	cmp #$01
	beq DrawHUDRowSub_ScoreLives
	;Check for row 2 (HP)
	cmp #$02
	beq DrawHUDRowSub_HP
	;Check for row 3 (border bottom)
	jmp DrawHUDRowSub_BorderBottom
DrawHUDRowSub_BorderTopNoInit:
	;Use current HUD position
	lda HUDPositionCur
	jmp DrawHUDRowSub_BorderTop
DrawHUDRowSub_BorderTopInit:
	;Use next HUD position
	lda HUDPositionNext
DrawHUDRowSub_BorderTop:
	;Get HUD VRAM pointer
	asl
	tay
	lda HUDVRAMBaseTable,y
	sta HUDVRAMPointer
	lda HUDVRAMBaseTable+1,y
	sta HUDVRAMPointer+1
	;Go to next row
	inc HUDRowIndex
	;Get HUD BG data pointers
	jsr GetHUDBGDataPointers
	;Get HUD BG data offset for player 1
	ldx #$00
	lda #$00
	jsr GetHUDBGDataOffset
	;Draw HUD BG for player 1
	jsr DrawHUDBGP1
	;Get HUD BG data offset for player 2
	ldx #$01
	lda #$00
	jsr GetHUDBGDataOffset
	;Draw HUD BG for player 2
	jmp DrawHUDBGP2
DrawHUDRowSub_NextRow:
	;Go to next row
	inc HUDRowIndex
DrawHUDRowSub_IncVRAMPointer:
	;Increment HUD VRAM pointer
	lda HUDVRAMPointer
	clc
	adc #$20
	sta HUDVRAMPointer
	rts
DrawHUDRowSub_ScoreLives:
	;Go to next row
	jsr DrawHUDRowSub_NextRow
	;Get HUD BG data pointers
	jsr GetHUDBGDataPointers
	;Get HUD BG data offset for player 1
	ldx #$00
	lda #$10
	jsr GetHUDBGDataOffset
	;Draw HUD BG for player 1
	jsr DrawHUDBGP1
	;Draw lives for player 1
	lda PlayerLives
	bne DrawHUDRowSub_DrawLivesP1
	lda #$0A
DrawHUDRowSub_DrawLivesP1:
	;Set character to VRAM
	sta HUDVRAMBuffer+$07
	;Draw score for player 1
	ldx #$09
	lda #$00
	jsr DrawHUDScoreSub
	;Get HUD BG data offset for player 2
	ldx #$01
	lda #$10
	jsr GetHUDBGDataOffset
	;Draw HUD BG for player 2
	jsr DrawHUDBGP2
	;If player 2 not active, exit early
	lda PlayerMode+1
	beq DrawHUDRowSub_Exit
	;Draw lives for player 2
	lda PlayerLives+1
	bne DrawHUDRowSub_DrawLivesP2
	lda #$0A
DrawHUDRowSub_DrawLivesP2:
	;Set character to VRAM
	sta HUDVRAMBuffer+$13
	;Draw score for player 2
	ldx #$15
	lda #$01
	jsr DrawHUDScoreSub
DrawHUDRowSub_Exit:
	rts
DrawHUDRowSub_HP:
	;Go to next row
	jsr DrawHUDRowSub_NextRow
	;Get HUD BG data pointers
	jsr GetHUDBGDataPointers
	;Get HUD BG data offset for player 1
	ldx #$00
	lda #$20
	jsr GetHUDBGDataOffset
	;Draw HUD BG for player 1
	jsr DrawHUDBGP1
	;If player 1 active, draw HP for player 1
	lda PlayerMode
	cmp #$02
	bcc DrawHUDRowSub_NoDrawHPP1
	;Draw HP for player 1
	ldy #$00
	ldx #$05
	jsr DrawHUDHPSub
DrawHUDRowSub_NoDrawHPP1:
	;Get HUD BG data offset for player 2
	ldx #$01
	lda #$20
	jsr GetHUDBGDataOffset
	;Draw HUD BG for player 2
	jsr DrawHUDBGP2
	;If player 2 active, draw HP for player 2
	lda PlayerMode+1
	cmp #$02
	bcc DrawHUDRowSub_Exit
	;Draw HP for player 2
	ldy #$01
	ldx #$11
	jmp DrawHUDHPSub
DrawHUDRowSub_ResetRow:
	;If HUD position changed, set HUD row index $00
	lda #$00
	ldy HUDPositionChangeFlag
	bne DrawHUDRowSub_SetRow
	;Set HUD row index $04
	lda #$04
DrawHUDRowSub_SetRow:
	;Set HUD row index
	sta HUDRowIndex
	jmp DrawHUDRowSub_DrawBottom
DrawHUDRowSub_BorderBottom:
	;Check if HUD position changed
	lda HUDRowIndex
	cmp #$05
	bcs DrawHUDRowSub_ResetRow
	;Go to next row
	inc HUDRowIndex
DrawHUDRowSub_DrawBottom:
	;Increment HUD VRAM pointer
	jsr DrawHUDRowSub_IncVRAMPointer
	;Get HUD BG data pointers
	jsr GetHUDBGDataPointers
	;Get HUD BG data offset for player 1
	ldx #$00
	lda #$30
	jsr GetHUDBGDataOffset
	;Draw HUD BG for player 1
	jsr DrawHUDBGP1
	;Get HUD BG data offset for player 2
	ldx #$01
	lda #$30
	jsr GetHUDBGDataOffset
	;Draw HUD BG for player 2
	jmp DrawHUDBGP2

DrawHUDScoreSub:
	;Draw HUD score
	sta $0A
	lda #$00
	sta $09
	lda #$03
	sta $08
DrawHUDScoreSub_Loop:
	;Get score data index
	lda $08
	and #$FE
	ora $0A
	tay
	;Check for high digit
	lda $08
	lsr
	bcs DrawHUDScoreSub_Hi
	;Get low digit
	lda PlayerScoreLo,y
	and #$0F
	jmp DrawHUDScoreSub_Check0
DrawHUDScoreSub_Hi:
	;Get high digit
	lda PlayerScoreLo,y
	lsr
	lsr
	lsr
	lsr
DrawHUDScoreSub_Check0:
	;Check for '0' digit
	beq DrawHUDScoreSub_CheckLeading
	;Set leading zeroes end flag
	inc $09
DrawHUDScoreSub_Set:
	;Set character to VRAM
	sta HUDVRAMBuffer,x
	;Loop for each digit
	inx
	dec $08
	bpl DrawHUDScoreSub_Loop
	rts
DrawHUDScoreSub_CheckLeading:
	;Check for leading '0' digit
	lda $09
	beq DrawHUDScoreSub_CheckLast
DrawHUDScoreSub_Draw0:
	;Draw '0' digit
	lda #$0A
	bne DrawHUDScoreSub_Set
DrawHUDScoreSub_CheckLast:
	;If last digit, draw regardless of if leading '0' digit
	lda $08
	beq DrawHUDScoreSub_Draw0
	;Draw clear tile
	lda #$00
	beq DrawHUDScoreSub_Set

DrawHUDHPSub:
	;Draw HUD HP
	lda PlayerHP,y
	sta $09
	ldy #$05
DrawHUDHPSub_Loop:
	;Check to draw unfilled tiles for HP
	lda $09
	beq DrawHUDHPSub_Clear
	;Set filled HP tiles in VRAM
	lda #$20
	sta HUDVRAMBuffer,x
	inx
	lda #$21
	sta HUDVRAMBuffer,x
	inx
	dec $09
	jmp DrawHUDHPSub_Next
DrawHUDHPSub_Clear:
	;Set unfilled HP tiles in VRAM
	lda #$30
	sta HUDVRAMBuffer,x
	inx
	lda #$31
	sta HUDVRAMBuffer,x
	inx
DrawHUDHPSub_Next:
	;Loop for each tile
	dey
	bne DrawHUDHPSub_Loop
	rts

GetHUDBGDataPointers:
	;Get HUD BG data pointers
	lda PlayerCharacter
	asl
	tay
	lda HUDBGP1DataTable,y
	sta $10
	lda HUDBGP1DataTable+1,y
	sta $11
	lda HUDBGP2DataTable,y
	sta $12
	lda HUDBGP2DataTable+1,y
	sta $13
	rts

GetHUDBGDataOffset:
	;Get HUD BG data offset
	sta $14
	ldy PlayerMode,x
	lda HUDBGDataOffsetTable,y
	clc
	adc $14
	tay
	rts

;HUD DATA
HUDBGDataOffsetTable:
	.db $80,$40,$00,$00,$00,$00,$00

DrawHUDBGP1:
	;Draw HUD BG for player 1
	ldx #$00
DrawHUDBGP1_Loop:
	lda ($10),y
	sta HUDVRAMBuffer,x
	iny
	inx
	cpx #$10
	bcc DrawHUDBGP1_Loop
	rts

DrawHUDBGP2:
	;Draw HUD BG for player 2
	ldx #$10
DrawHUDBGP2_Loop:
	lda ($12),y
	sta HUDVRAMBuffer,x
	iny
	inx
	cpx #$20
	bcc DrawHUDBGP2_Loop
	rts

;HUD DATA
HUDBGP1DataTable:
	.dw HUDBGP1VampireData
	.dw HUDBGP1MonsterData
HUDBGP2DataTable:
	.dw HUDBGP2MonsterData
	.dw HUDBGP2VampireData
HUDBGP1VampireData:
	.db $00,$41,$42,$43,$26,$16,$16,$16,$22,$23,$24,$25,$16,$16,$16,$27
	.db $00,$51,$52,$53,$17,$0B,$0C,$0A,$00,$0A,$0A,$0A,$0A,$0E,$0F,$17
	.db $00,$61,$62,$63,$17,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$17
	.db $00,$71,$72,$73,$36,$32,$33,$32,$33,$32,$33,$32,$33,$32,$33,$37
	.db $00,$49,$4A,$4B,$26,$16,$16,$16,$22,$23,$24,$25,$16,$16,$16,$27
	.db $00,$59,$00,$5B,$17,$0B,$0C,$0A,$00,$0A,$0A,$0A,$0A,$0E,$0F,$17
	.db $00,$69,$00,$6B,$17,$40,$50,$60,$70,$00,$47,$57,$70,$67,$00,$17
	.db $00,$79,$00,$7B,$36,$34,$34,$34,$34,$34,$34,$34,$34,$34,$34,$37
HUDBGP1MonsterData:
	.db $00,$44,$45,$46,$26,$16,$16,$10,$11,$12,$13,$14,$15,$16,$16,$27
	.db $00,$54,$55,$56,$17,$0B,$0C,$0A,$00,$0A,$0A,$0A,$0A,$0E,$0F,$17
	.db $00,$64,$65,$66,$17,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$17
	.db $00,$74,$75,$76,$36,$32,$33,$32,$33,$32,$33,$32,$33,$32,$33,$37
	.db $00,$4C,$4D,$4E,$26,$16,$16,$10,$11,$12,$13,$14,$15,$16,$16,$27
	.db $00,$5C,$00,$5E,$17,$0B,$0C,$0A,$00,$0A,$0A,$0A,$0A,$0E,$0F,$17
	.db $00,$6C,$00,$6E,$17,$40,$50,$60,$70,$00,$47,$57,$70,$67,$00,$17
	.db $00,$7C,$00,$7E,$36,$34,$34,$34,$34,$34,$34,$34,$34,$34,$34,$37
HUDBGP2MonsterData:
	.db $26,$16,$16,$10,$11,$12,$13,$14,$15,$16,$16,$27,$44,$45,$46,$00
	.db $17,$0B,$0C,$0A,$00,$0A,$0A,$0A,$0A,$0E,$0F,$17,$54,$55,$56,$00
	.db $17,$20,$21,$20,$21,$20,$21,$20,$21,$20,$21,$17,$64,$65,$66,$00
	.db $36,$32,$33,$32,$33,$32,$33,$32,$33,$32,$33,$37,$74,$75,$76,$00
	.db $26,$16,$16,$10,$11,$12,$13,$14,$15,$16,$16,$27,$4C,$4D,$4E,$00
	.db $17,$0B,$0C,$0A,$00,$0A,$0A,$0A,$0A,$0E,$0F,$17,$5C,$00,$5E,$00
	.db $17,$40,$50,$60,$70,$00,$47,$57,$70,$67,$00,$17,$6C,$00,$6E,$00
	.db $36,$34,$34,$34,$34,$34,$34,$34,$34,$34,$34,$37,$7C,$00,$7E,$00
	.db $26,$16,$0D,$0D,$48,$58,$68,$78,$0D,$0D,$16,$27,$4C,$4D,$4E,$00
	.db $17,$00,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$00,$17,$5C,$00,$5E,$00
	.db $17,$00,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,$00,$17,$6C,$00,$6E,$00
	.db $36,$34,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F,$34,$37,$7C,$00,$7E,$00
HUDBGP2VampireData:
	.db $26,$16,$16,$16,$22,$23,$24,$25,$16,$16,$16,$27,$41,$42,$43,$00
	.db $17,$0B,$0C,$0A,$00,$0A,$0A,$0A,$0A,$0E,$0F,$17,$51,$52,$53,$00
	.db $17,$20,$21,$20,$21,$20,$21,$20,$21,$20,$21,$17,$61,$62,$63,$00
	.db $36,$32,$33,$32,$33,$32,$33,$32,$33,$32,$33,$37,$71,$72,$73,$00
	.db $26,$16,$16,$16,$22,$23,$24,$25,$16,$16,$16,$27,$49,$4A,$4B,$00
	.db $17,$0B,$0C,$0A,$00,$0A,$0A,$0A,$0A,$0E,$0F,$17,$59,$00,$5B,$00
	.db $17,$40,$50,$60,$70,$00,$47,$57,$70,$67,$00,$17,$69,$00,$6B,$00
	.db $36,$34,$34,$34,$34,$34,$34,$34,$34,$34,$34,$37,$79,$00,$7B,$00
	.db $26,$16,$0D,$0D,$48,$58,$68,$78,$0D,$0D,$16,$27,$49,$4A,$4B,$00
	.db $17,$00,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$00,$17,$59,$00,$5B,$00
	.db $17,$00,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,$00,$17,$69,$00,$6B,$00
	.db $36,$34,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F,$34,$37,$79,$00,$7B,$00

;;;;;;;;;;;;;;
;LEVEL 5 DATA;
;;;;;;;;;;;;;;
Level51BGPointerData:
	.dw Level51BGData+$02B0
	.dw Level51BGData+$0000
	.dw Level51BGData+$0040
	.dw Level51BGData+$0080
	.dw Level51BGData+$00C0
	.dw Level51BGData+$0100
	.dw Level51BGData+$0130
	.dw Level51BGData+$0160
	.dw Level51BGData+$0190
	.dw Level51BGData+$01C0
	.dw Level51BGData+$01F0
	.dw Level51BGData+$0220
	.dw Level51BGData+$0250
	.dw Level51BGData+$0280
Level51BGData:
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$2D
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $1F,$01,$01,$01,$01,$01,$01,$01
	.db $2E,$3C,$39,$39,$3A,$39,$39,$3A
	.db $28,$01,$01,$01,$01,$01,$01,$01
	.db $2C,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$40,$41,$01
	.db $01,$01,$01,$01,$01,$44,$45,$46
	.db $01,$01,$01,$1F,$01,$48,$49,$01
	.db $3A,$39,$3E,$2E,$2F,$4C,$4D,$4E
	.db $01,$01,$01,$28,$01,$50,$51,$52
	.db $01,$01,$01,$2C,$01,$54,$55,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$40,$41,$01,$01,$40,$41,$01
	.db $01,$44,$45,$46,$01,$44,$45,$46
	.db $01,$48,$49,$01,$01,$48,$49,$01
	.db $01,$4C,$4D,$4E,$01,$4C,$4D,$4E
	.db $01,$50,$51,$52,$01,$50,$51,$52
	.db $01,$54,$55,$01,$01,$54,$55,$01
	.db $08,$03,$09,$04,$0B,$09,$05,$04
	.db $09,$0B,$09,$08,$07,$09,$0A,$09
	.db $04,$0B,$08,$09,$07,$04,$05,$09
	.db $09,$0B,$09,$09,$03,$09,$0A,$04
	.db $0C,$0F,$0C,$0D,$0F,$0C,$0E,$0C
	.db $11,$11,$11,$11,$11,$11,$11,$11
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$19,$1A,$1B
	.db $5E,$01,$01,$01,$1C,$1D,$1E,$01
	.db $11,$11,$11,$11,$12,$16,$18,$18
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $20,$21,$22,$01,$01,$01,$01,$01
	.db $01,$25,$26,$27,$01,$01,$01,$01
	.db $18,$18,$17,$10,$11,$11,$11,$15
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $18,$18,$18,$13,$18,$18,$18,$13
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$29
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$29
	.db $18,$18,$18,$14,$11,$11,$11,$11
	.db $23,$01,$32,$01,$01,$01,$32,$01
	.db $2A,$37,$38,$30,$30,$30,$38,$30
	.db $24,$01,$01,$01,$01,$01,$01,$01
	.db $23,$01,$01,$01,$32,$01,$01,$01
	.db $2A,$37,$30,$30,$38,$30,$30,$30
	.db $11,$11,$11,$11,$11,$11,$11,$11
	.db $01,$31,$01,$23,$01,$54,$55,$01
	.db $30,$35,$34,$2A,$2B,$54,$55,$01
	.db $01,$01,$01,$24,$01,$42,$43,$01
	.db $31,$01,$32,$23,$01,$47,$5A,$53
	.db $35,$30,$36,$2A,$4B,$5B,$5B,$4F
	.db $11,$11,$11,$11,$11,$11,$11,$11
	.db $01,$54,$55,$01,$01,$54,$55,$01
	.db $01,$54,$55,$01,$01,$54,$55,$01
	.db $01,$42,$43,$01,$01,$42,$43,$01
	.db $01,$47,$5A,$53,$01,$47,$5A,$53
	.db $5D,$5B,$5B,$4F,$5D,$5B,$5B,$4F
	.db $11,$11,$11,$11,$11,$11,$11,$11
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$58,$3B,$59
	.db $01,$01,$01,$01,$01,$01,$5C,$01
	.db $5E,$01,$5D,$5B,$4F,$56,$3F,$57
	.db $11,$11,$11,$11,$11,$11,$11,$11
	.db $09,$07,$09,$04,$07,$09,$06,$08
	.db $09,$03,$09,$09,$03,$08,$02,$09
	.db $04,$07,$08,$04,$07,$09,$06,$09
	.db $09,$03,$09,$09,$03,$09,$02,$08
	.db $09,$07,$09,$08,$0B,$09,$06,$09
	.db $08,$03,$09,$09,$03,$04,$02,$08
	.db $09,$07,$04,$09,$0B,$08,$06,$09
	.db $09,$03,$09,$09,$03,$09,$02,$09
Level52BGPointerData:
	.dw Level52BGData+$02C0
	.dw Level52BGData+$0000
	.dw Level52BGData+$0040
	.dw Level52BGData+$0080
	.dw Level52BGData+$00B0
	.dw Level52BGData+$00E0
	.dw Level52BGData+$0110
	.dw Level52BGData+$0140
	.dw Level52BGData+$0170
	.dw Level52BGData+$01A0
	.dw Level52BGData+$01D0
	.dw Level52BGData+$0200
	.dw Level52BGData+$0230
	.dw Level52BGData+$0260
	.dw Level52BGData+$0290
Level52BGData:
	.db $35,$35,$35,$35,$35,$35,$35,$35
	.db $35,$35,$35,$35,$35,$35,$35,$35
	.db $35,$35,$35,$35,$35,$35,$35,$35
	.db $35,$35,$35,$35,$35,$35,$35,$35
	.db $35,$35,$35,$35,$35,$35,$35,$35
	.db $35,$35,$35,$35,$35,$35,$35,$35
	.db $35,$35,$35,$35,$35,$35,$35,$35
	.db $20,$1A,$1A,$1A,$20,$1A,$1A,$1A
	.db $35,$35,$35,$35,$35,$6E,$00,$00
	.db $35,$35,$35,$35,$35,$5D,$00,$00
	.db $35,$35,$35,$35,$35,$6E,$00,$00
	.db $35,$35,$35,$35,$35,$5D,$00,$00
	.db $35,$01,$02,$35,$35,$6E,$00,$00
	.db $35,$03,$04,$35,$35,$5D,$00,$00
	.db $35,$05,$06,$35,$35,$6E,$00,$00
	.db $20,$17,$18,$35,$35,$5D,$00,$00
	.db $35,$35,$17,$18,$1B,$1C,$1C,$1C
	.db $35,$35,$17,$18,$1D,$35,$35,$35
	.db $35,$35,$17,$18,$1E,$1F,$1F,$1F
	.db $35,$35,$17,$18,$36,$35,$35,$35
	.db $35,$35,$17,$18,$37,$38,$38,$38
	.db $32,$32,$33,$34,$39,$3A,$3A,$3A
	.db $21,$1C,$1C,$1C,$21,$1C,$1C,$1C
	.db $22,$35,$35,$35,$22,$35,$35,$35
	.db $23,$1F,$1F,$1F,$23,$1F,$1F,$1F
	.db $3B,$35,$35,$35,$3B,$35,$35,$35
	.db $3C,$38,$38,$38,$3C,$38,$38,$38
	.db $3D,$3A,$3A,$3A,$3D,$3A,$3A,$3A
	.db $21,$17,$18,$35,$35,$4F,$00,$76
	.db $22,$17,$18,$35,$35,$50,$00,$76
	.db $23,$17,$18,$35,$35,$4F,$00,$76
	.db $3B,$17,$18,$35,$35,$50,$00,$76
	.db $3C,$17,$18,$35,$35,$4F,$00,$76
	.db $3D,$33,$34,$32,$32,$53,$48,$7D
	.db $46,$47,$7E,$4B,$4C,$76,$46,$47
	.db $46,$47,$7E,$4B,$4C,$76,$46,$47
	.db $46,$47,$7E,$4B,$4C,$76,$46,$47
	.db $46,$47,$7E,$4B,$4C,$76,$46,$47
	.db $46,$47,$7E,$4B,$4C,$76,$46,$47
	.db $49,$4A,$7F,$4D,$4E,$7D,$49,$4A
	.db $7E,$4B,$4C,$76,$46,$47,$7E,$4B
	.db $7E,$4B,$4C,$76,$46,$47,$7E,$4B
	.db $7E,$4B,$4C,$76,$46,$47,$7E,$4B
	.db $7E,$4B,$4C,$76,$46,$47,$7E,$4B
	.db $7E,$4B,$4C,$76,$46,$47,$7E,$4B
	.db $7F,$4D,$4E,$7D,$49,$4A,$7F,$4D
	.db $4C,$76,$46,$47,$7E,$4B,$4C,$00
	.db $4C,$76,$46,$47,$7E,$4B,$4C,$00
	.db $4C,$76,$46,$47,$7E,$4B,$4C,$00
	.db $4C,$76,$46,$47,$7E,$4B,$4C,$00
	.db $4C,$76,$46,$47,$7E,$4B,$4C,$00
	.db $4E,$7D,$49,$4A,$7F,$4D,$4E,$48
	.db $51,$10,$54,$55,$56,$57,$57,$5F
	.db $52,$13,$58,$59,$5A,$5B,$5B,$62
	.db $51,$14,$5C,$55,$5E,$5E,$5E,$5E
	.db $52,$13,$61,$6F,$70,$70,$70,$70
	.db $51,$2C,$64,$72,$74,$79,$79,$79
	.db $6D,$2F,$75,$75,$75,$75,$75,$60
	.db $65,$58,$16,$68,$2A,$08,$09,$08
	.db $63,$58,$15,$6B,$29,$0B,$0C,$0B
	.db $65,$78,$16,$68,$2A,$08,$09,$08
	.db $77,$7C,$15,$6B,$29,$0B,$0C,$0B
	.db $7B,$71,$16,$68,$41,$26,$27,$26
	.db $75,$75,$6C,$69,$44,$28,$28,$28
	.db $09,$08,$09,$08,$09,$0E,$31,$2A
	.db $0C,$0B,$0C,$0B,$0C,$11,$31,$29
	.db $09,$08,$09,$08,$09,$0E,$31,$2A
	.db $0C,$0B,$0C,$0B,$0C,$11,$31,$29
	.db $27,$26,$27,$26,$27,$2B,$31,$41
	.db $28,$28,$28,$28,$28,$28,$28,$28
	.db $08,$09,$08,$09,$08,$09,$08,$09
	.db $0B,$0C,$0B,$0C,$0B,$0C,$0B,$0C
	.db $08,$09,$08,$09,$08,$09,$08,$09
	.db $0B,$0C,$0B,$0C,$0B,$0C,$0B,$0C
	.db $26,$27,$26,$27,$26,$27,$26,$27
	.db $28,$28,$28,$28,$28,$28,$28,$28
	.db $0E,$12,$10,$58,$55,$56,$57,$57
	.db $11,$0F,$13,$58,$59,$5A,$5B,$5B
	.db $0E,$12,$14,$5C,$55,$5E,$5E,$5E
	.db $11,$0F,$13,$58,$6F,$70,$70,$70
	.db $2B,$12,$2C,$71,$72,$79,$79,$74
	.db $28,$2E,$2F,$75,$75,$60,$75,$75
	.db $5F,$65,$58,$67,$3E,$73,$2A,$08
	.db $62,$63,$78,$15,$24,$73,$29,$0B
	.db $5E,$65,$7C,$67,$3E,$73,$2A,$08
	.db $70,$77,$71,$15,$24,$73,$29,$0B
	.db $79,$7B,$58,$16,$3E,$73,$41,$26
	.db $75,$75,$75,$6C,$66,$7A,$44,$28
	.db $35,$35,$35,$35,$35,$35,$35,$35
	.db $35,$35,$35,$35,$35,$35,$35,$35
	.db $35,$35,$35,$35,$35,$35,$35,$35
	.db $35,$35,$35,$35,$35,$35,$35,$35
	.db $35,$35,$01,$02,$35,$35,$35,$35
	.db $35,$35,$03,$04,$35,$35,$35,$35
	.db $35,$35,$05,$06,$35,$35,$35,$35
	.db $35,$35,$17,$18,$19,$1A,$1A,$1A
Level53BGPointerData:
	.dw Level53BGData+$0000
Level53BGData:
	.db $02,$01,$02,$03,$10,$02,$01,$02
	.db $04,$05,$04,$07,$14,$04,$05,$04
	.db $02,$01,$02,$03,$10,$02,$01,$02
	.db $04,$05,$04,$07,$1C,$04,$05,$04
	.db $20,$21,$20,$23,$30,$20,$21,$20
	.db $24,$24,$24,$27,$34,$24,$24,$24
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $2C,$2C,$2C,$2C,$2C,$2C,$2C,$2C
Level51TileData:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $26,$27,$26,$27,$26,$27,$24,$25,$26,$27,$26,$27,$26,$27,$26,$27
	.db $1E,$26,$27,$1E,$1E,$26,$27,$1E,$1E,$26,$27,$1E,$1E,$26,$27,$1E
	.db $28,$29,$2A,$2B,$20,$21,$22,$23,$20,$21,$22,$23,$20,$21,$22,$23
	.db $26,$27,$26,$27,$26,$27,$26,$27,$26,$27,$26,$27,$24,$25,$26,$27
	.db $26,$27,$26,$27,$24,$25,$26,$27,$26,$27,$26,$27,$26,$27,$26,$27
	.db $1E,$26,$27,$1E,$1E,$26,$27,$1E,$1E,$26,$27,$1E,$1E,$24,$25,$1E
	.db $20,$21,$22,$23,$20,$21,$22,$23,$28,$29,$2A,$2B,$20,$21,$22,$23
	.db $20,$21,$22,$23,$20,$21,$22,$23,$20,$21,$22,$23,$20,$21,$22,$23
	.db $26,$27,$26,$27,$26,$27,$26,$27,$26,$27,$26,$27,$26,$27,$24,$25
	.db $1E,$26,$27,$1E,$1E,$24,$25,$1E,$1E,$26,$27,$1E,$1E,$26,$27,$1E
	.db $20,$21,$22,$23,$85,$86,$87,$88,$89,$8A,$8B,$8C,$00,$00,$00,$00
	.db $28,$29,$2A,$2B,$85,$86,$87,$88,$89,$8A,$8B,$8C,$00,$00,$00,$00
	.db $26,$27,$26,$27,$26,$27,$26,$27,$8E,$8F,$8E,$8F,$00,$00,$00,$00
	.db $1E,$26,$27,$1E,$1E,$26,$27,$1E,$8D,$8E,$8F,$8D,$00,$00,$00,$00
	.db $B2,$90,$CF,$91,$0D,$93,$94,$95,$63,$00,$00,$00,$0E,$00,$00,$00
	.db $E0,$90,$E1,$91,$92,$93,$94,$95,$DE,$00,$DE,$00,$00,$00,$00,$00
	.db $C9,$90,$10,$03,$92,$93,$94,$04,$00,$00,$00,$05,$00,$00,$00,$06
	.db $E4,$90,$E1,$0F,$0D,$93,$94,$04,$EE,$00,$DE,$05,$0E,$00,$00,$06
	.db $E4,$90,$E1,$91,$0D,$93,$94,$95,$EE,$00,$DE,$00,$0E,$00,$00,$00
	.db $E0,$90,$E1,$0F,$92,$93,$94,$04,$DE,$00,$DE,$05,$00,$00,$00,$06
	.db $07,$1E,$AF,$B0,$1E,$1E,$AF,$B0,$08,$09,$00,$00,$0A,$0B,$00,$00
	.db $AF,$B0,$1E,$0C,$AF,$B0,$1E,$1E,$00,$00,$08,$09,$00,$00,$0A,$0B
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$08,$09,$08,$09,$0A,$0B,$0A,$0B
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$C3,$1E,$C4,$9D,$C4,$9D,$CB,$53
	.db $C3,$1E,$C5,$9A,$C4,$9D,$9E,$53,$CB,$53,$CC,$53,$53,$A2,$A3,$A4
	.db $D0,$9B,$E3,$E3,$53,$53,$CC,$53,$53,$9F,$A0,$A0,$A5,$A6,$1E,$1E
	.db $1E,$1E,$C1,$96,$1E,$1E,$96,$CA,$C1,$96,$CA,$CC,$97,$98,$99,$99
	.db $CB,$53,$CC,$A2,$53,$AB,$AC,$AD,$AB,$AE,$AF,$B0,$B1,$1E,$AF,$B0
	.db $A9,$AA,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $44,$45,$45,$46,$47,$48,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50,$51
	.db $E3,$E3,$D1,$9C,$53,$CC,$53,$53,$A0,$A0,$A1,$53,$1E,$1E,$A7,$A8
	.db $C8,$B3,$C6,$1E,$53,$B4,$C7,$B5,$CD,$CC,$CD,$B6,$B7,$B8,$CE,$53
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$C7,$B5,$C6,$1E,$53,$B6,$C7,$B5
	.db $52,$53,$53,$54,$52,$53,$53,$54,$52,$53,$53,$54,$52,$53,$53,$54
	.db $52,$53,$53,$54,$52,$59,$5A,$54,$52,$5B,$5C,$54,$52,$5D,$5E,$54
	.db $1E,$1E,$B9,$BA,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $CE,$CC,$CD,$B6,$BB,$BC,$BD,$53,$AF,$B0,$BF,$BD,$AF,$B0,$1E,$1D
	.db $C2,$1E,$1E,$1E,$BE,$C2,$1E,$1E,$CC,$BE,$C2,$1E,$99,$99,$01,$02
	.db $52,$53,$53,$54,$52,$53,$53,$54,$52,$53,$53,$54,$52,$59,$5A,$54
	.db $1E,$1E,$1E,$55,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $D3,$D4,$D4,$56,$52,$53,$53,$54,$52,$53,$53,$54,$52,$53,$53,$54
	.db $67,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $52,$5B,$5C,$54,$52,$5D,$5E,$54,$52,$53,$53,$54,$52,$53,$53,$54
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$55,$1E,$1E,$1E,$1E
	.db $52,$53,$53,$54,$52,$53,$53,$54,$D3,$D4,$D4,$56,$52,$53,$53,$54
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$67,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $D6,$58,$D7,$57,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$F0,$60,$F0,$60,$61,$62,$61,$62
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$F0,$60,$1E,$1E,$61,$62,$1E,$1E
	.db $D5,$D5,$D5,$D5,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $D6,$58,$D5,$D5,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $F1,$64,$F1,$64,$65,$66,$65,$66,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $F1,$64,$D5,$D5,$65,$66,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $D5,$D5,$D5,$57,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $F1,$64,$D7,$57,$65,$66,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$D6,$58,$D7,$57,$1E,$1E,$1E,$1E
	.db $F0,$60,$1E,$1E,$61,$62,$1E,$1E,$F1,$64,$D7,$57,$65,$66,$1E,$1E
	.db $EB,$EB,$EB,$EB,$13,$12,$13,$12,$E6,$14,$E7,$15,$EF,$16,$DF,$17
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$D5,$D5,$D5,$57,$1E,$1E,$1E,$1E
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$D6,$D5,$D5,$D5,$1E,$1E,$1E,$1E
	.db $F0,$60,$1E,$1E,$61,$62,$1E,$1E,$F1,$64,$D5,$D5,$65,$66,$1E,$1E
	.db $E8,$18,$E9,$19,$1A,$1B,$00,$1C,$ED,$ED,$ED,$ED,$6F,$6F,$6F,$6F
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$2E,$1E,$1E,$1E,$32,$1E,$1E,$1E,$35
	.db $2C,$2D,$1E,$1E,$2F,$30,$31,$1E,$33,$33,$34,$1E,$36,$36,$37,$1E
	.db $1E,$1E,$6E,$6F,$1E,$1E,$6E,$6F,$1E,$1E,$6E,$6F,$1E,$1E,$6E,$7D
	.db $6F,$6F,$6F,$72,$6F,$6F,$6F,$72,$6F,$6F,$6F,$72,$7D,$7D,$7D,$72
	.db $1E,$38,$39,$3A,$3F,$40,$41,$41,$D8,$D9,$D9,$D9,$69,$6A,$6A,$6A
	.db $3B,$3B,$3C,$3D,$41,$41,$41,$41,$D9,$D9,$D9,$D9,$6A,$6A,$6A,$6A
	.db $3E,$1E,$1E,$1E,$42,$43,$1E,$1E,$D9,$68,$1E,$1E,$6A,$6B,$1E,$1E
	.db $D8,$D9,$D9,$D9,$6E,$6F,$6F,$6F,$6E,$6F,$6F,$6F,$6E,$7D,$7D,$7D
	.db $1E,$1E,$6C,$6C,$1E,$1E,$6E,$6F,$1E,$1E,$6E,$73,$1E,$1E,$6E,$77
	.db $6C,$6C,$6C,$6D,$70,$71,$6F,$72,$74,$75,$76,$72,$78,$79,$7A,$72
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $67,$1E,$D8,$D9,$1E,$1E,$6E,$6F,$1E,$1E,$6E,$6F,$1E,$1E,$6E,$6F
	.db $1E,$1E,$6E,$6F,$1E,$1E,$6E,$7D,$D8,$D9,$D9,$D9,$69,$6A,$6A,$6A
	.db $7B,$7C,$6F,$72,$7D,$7D,$7D,$72,$D9,$D9,$D9,$D9,$6A,$6A,$6A,$6A
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$D9,$68,$1E,$1E,$6A,$6B,$1E,$1E
	.db $D9,$D9,$D9,$84,$6F,$6F,$6F,$72,$6F,$6F,$6F,$72,$6F,$6F,$6F,$72
	.db $7E,$7F,$7F,$7F,$1E,$81,$82,$82,$1E,$1E,$6C,$6C,$1E,$1E,$6E,$6F
	.db $7F,$7F,$7F,$7F,$82,$82,$82,$82,$6C,$6C,$6C,$6D,$6F,$6F,$6F,$72
	.db $7F,$80,$1E,$1E,$83,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $D9,$84,$1E,$1E,$6F,$72,$1E,$1E,$6F,$72,$1E,$1E,$7D,$72,$1E,$1E
	.db $1E,$1E,$6E,$6F,$1E,$1E,$6E,$6F,$1E,$1E,$6E,$6F,$1E,$1E,$6E,$6F
	.db $6F,$6F,$6F,$72,$6F,$6F,$6F,$72,$6F,$6F,$6F,$72,$6F,$6F,$6F,$72
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$EC,$ED,$1E,$1E,$6E,$6F
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$ED,$84,$1E,$1E,$6F,$72,$1E,$1E
	.db $EA,$EB,$EB,$EB,$11,$12,$13,$12,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $EB,$EB,$EB,$EB,$13,$12,$13,$12,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
	.db $D9,$D9,$D9,$D9,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$7D,$7D,$7D,$7D
	.db $D9,$D9,$D9,$D9,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F
	.db $EF,$16,$DF,$17,$EF,$16,$DF,$17,$EF,$16,$DF,$17,$EF,$16,$DF,$17
	.db $1E,$1E,$D8,$D9,$1E,$1E,$6E,$6F,$1E,$1E,$6E,$6F,$1E,$1E,$6E,$6F
	.db $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$5F,$1E,$1E,$1E,$1F,$1E,$1E,$1E
Level51AttrData:
	.db $00,$AA,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $AA,$AA,$AA,$AA,$AA,$AA,$59,$56,$55,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	.db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$FA
	.db $EE,$FF,$EE,$FF,$FF,$FF,$BB,$FF,$EF,$FF,$AA,$EE,$FE,$FF,$BA,$FF
	.db $EF,$FF,$AB,$BB,$EE,$FF,$EA,$BA,$AA,$AA,$FF,$FF,$AA,$EE,$AA
Level52TileData:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $0E,$0E,$0E,$01,$0E,$0E,$03,$04,$0E,$0E,$07,$08,$0E,$0E,$0A,$0B
	.db $02,$0E,$0E,$0E,$05,$06,$0E,$0E,$00,$09,$0E,$0E,$0C,$0D,$0E,$0E
	.db $F0,$10,$F1,$12,$17,$18,$19,$1A,$1C,$1D,$1E,$1F,$24,$25,$26,$27
	.db $F2,$14,$F3,$16,$18,$18,$18,$1B,$20,$21,$22,$23,$28,$29,$2A,$2B
	.db $17,$18,$19,$1A,$2C,$2D,$2E,$2F,$4B,$4C,$4D,$4E,$52,$53,$26,$54
	.db $18,$18,$18,$1B,$30,$31,$32,$33,$4F,$50,$00,$51,$55,$56,$00,$57
	.db $43,$3B,$3B,$3B,$43,$3B,$3B,$3B,$43,$3B,$3B,$3B,$87,$3F,$3F,$3F
	.db $3B,$3B,$3B,$3C,$3B,$3B,$3B,$3C,$3B,$3B,$3B,$3C,$3F,$3F,$3F,$40
	.db $3D,$3B,$3B,$3B,$3D,$3B,$3B,$3B,$3D,$3B,$3B,$3B,$41,$3F,$3F,$3F
	.db $86,$37,$37,$37,$43,$3B,$3B,$3B,$43,$3B,$3B,$3B,$43,$3B,$3B,$3B
	.db $37,$37,$37,$38,$3B,$3B,$3B,$3C,$3B,$3B,$3B,$3C,$3B,$3B,$3B,$3C
	.db $39,$37,$37,$37,$3D,$3B,$3B,$3B,$3D,$3B,$3B,$3B,$3D,$3B,$3B,$3B
	.db $42,$37,$37,$37,$43,$3B,$3B,$3B,$43,$3B,$3B,$3B,$43,$3B,$3B,$3B
	.db $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3F,$3F,$3F,$49
	.db $34,$48,$AD,$AE,$34,$48,$B1,$B2,$34,$48,$B4,$B5,$34,$48,$B8,$B9
	.db $AF,$B0,$C3,$3B,$B3,$B0,$C3,$3B,$B6,$B7,$C3,$3B,$BA,$BB,$C3,$3B
	.db $37,$37,$37,$4A,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B
	.db $34,$48,$BC,$BD,$34,$48,$C0,$C1,$34,$48,$A7,$A8,$34,$48,$AA,$AB
	.db $BE,$BF,$C3,$3B,$C1,$C2,$C3,$3B,$A8,$A9,$C3,$3B,$AB,$AC,$C3,$3B
	.db $AF,$B0,$C3,$3B,$B3,$B0,$C3,$3B,$B6,$B7,$C3,$D2,$BA,$BB,$C3,$3B
	.db $3B,$D1,$BC,$BD,$3B,$D1,$C0,$C1,$3B,$D1,$A7,$A8,$3B,$D1,$AA,$AB
	.db $C7,$D1,$AD,$AE,$3B,$D1,$B1,$B2,$3B,$D1,$B4,$B5,$3B,$D1,$B8,$B9
	.db $52,$53,$26,$54,$52,$53,$26,$54,$52,$53,$26,$54,$52,$53,$26,$54
	.db $55,$56,$00,$57,$55,$56,$00,$57,$55,$56,$00,$57,$55,$56,$00,$57
	.db $F4,$59,$F5,$5B,$5D,$5E,$5E,$5E,$00,$00,$00,$00,$00,$00,$00,$00
	.db $F6,$F6,$F6,$F6,$5E,$5E,$5E,$5E,$00,$00,$00,$00,$00,$00,$00,$00
	.db $5F,$60,$60,$60,$61,$62,$62,$62,$63,$64,$64,$65,$66,$67,$67,$35
	.db $60,$60,$60,$60,$62,$62,$62,$62,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	.db $66,$67,$67,$35,$66,$67,$67,$35,$66,$67,$67,$35,$68,$69,$6A,$6B
	.db $F9,$F8,$F8,$F8,$6E,$6F,$70,$67,$6E,$71,$72,$67,$73,$74,$75,$76
	.db $F8,$F8,$F8,$F8,$67,$67,$67,$67,$67,$67,$67,$67,$76,$76,$76,$76
	.db $F7,$59,$F5,$5B,$5E,$5E,$5E,$5E,$00,$00,$00,$00,$00,$00,$00,$00
	.db $60,$60,$60,$60,$62,$62,$62,$62,$78,$64,$64,$65,$79,$67,$67,$35
	.db $79,$67,$67,$35,$79,$67,$67,$35,$79,$67,$67,$35,$7A,$69,$6A,$6B
	.db $F8,$F8,$F8,$F8,$67,$6F,$70,$67,$67,$71,$72,$67,$76,$74,$75,$76
	.db $BE,$BF,$00,$00,$C1,$C2,$00,$00,$A8,$A9,$00,$00,$AB,$AC,$00,$00
	.db $43,$3B,$3B,$3B,$43,$3B,$3B,$3B,$43,$3B,$3B,$3B,$44,$45,$45,$45
	.db $3B,$3B,$3B,$3C,$3B,$3B,$3B,$3C,$3B,$3B,$3B,$3C,$45,$45,$45,$46
	.db $3D,$3B,$3B,$3B,$3D,$3B,$3B,$3B,$3D,$3B,$3B,$3B,$47,$45,$45,$45
	.db $7F,$7F,$7F,$7F,$81,$81,$81,$81,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $36,$37,$37,$37,$3A,$3B,$3B,$3B,$3A,$3B,$3B,$3B,$3A,$3B,$3B,$3B
	.db $3A,$3B,$3B,$3B,$3A,$3B,$3B,$3B,$3A,$3B,$3B,$3B,$3E,$3F,$3F,$3F
	.db $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$45,$45,$45,$45
	.db $AF,$B0,$C3,$3B,$B3,$B0,$C3,$3B,$B6,$B7,$C3,$C8,$BA,$BB,$C3,$3B
	.db $7F,$7F,$7F,$82,$81,$81,$81,$83,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $34,$48,$BC,$BD,$84,$85,$C0,$C1,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $BE,$BF,$C3,$3B,$C1,$C2,$5A,$3B,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $37,$37,$37,$37,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B
	.db $34,$48,$34,$35,$34,$48,$34,$35,$34,$48,$34,$35,$34,$48,$34,$35
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $52,$53,$26,$54,$52,$53,$26,$54,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $55,$56,$00,$57,$55,$56,$00,$57,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	.db $63,$64,$64,$65,$66,$67,$67,$35,$66,$67,$67,$35,$66,$67,$67,$35
	.db $66,$67,$67,$35,$68,$69,$6A,$6B,$F9,$F8,$F8,$F8,$6E,$6F,$70,$67
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$F8,$F8,$F8,$F8,$67,$67,$67,$67
	.db $6E,$71,$72,$67,$88,$89,$89,$89,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $67,$67,$67,$67,$89,$89,$89,$89,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $78,$64,$64,$65,$79,$67,$67,$35,$79,$67,$67,$35,$79,$67,$67,$35
	.db $79,$67,$67,$35,$7A,$69,$6A,$6B,$F8,$F8,$F8,$F8,$67,$6F,$70,$67
	.db $67,$71,$72,$67,$89,$89,$89,$89,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $AF,$B0,$00,$00,$B3,$B0,$00,$00,$B6,$B7,$00,$00,$BA,$BB,$00,$00
	.db $39,$37,$37,$37,$3D,$3B,$3B,$3B,$3D,$3B,$3B,$3B,$3D,$3B,$8A,$8B
	.db $37,$37,$37,$38,$3B,$3B,$3B,$3C,$3B,$3B,$3B,$3C,$8C,$8D,$3B,$3C
	.db $3A,$3B,$3B,$3B,$3A,$3B,$3B,$3B,$3A,$3B,$3B,$3B,$96,$45,$45,$45
	.db $3D,$3B,$8E,$00,$3D,$3B,$90,$00,$3D,$3B,$92,$93,$47,$45,$45,$45
	.db $00,$8F,$3B,$3C,$00,$91,$3B,$3C,$94,$95,$3B,$3C,$45,$45,$45,$46
	.db $97,$7F,$7F,$7F,$98,$81,$81,$81,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $34,$48,$34,$35,$84,$85,$80,$6B,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $E0,$9A,$E1,$9C,$E0,$9A,$E1,$9C,$E0,$9A,$E1,$9C,$E0,$9A,$E1,$9C
	.db $E2,$9E,$E3,$A0,$E2,$9E,$E3,$A0,$E2,$9E,$E3,$A0,$E2,$9E,$E3,$A0
	.db $00,$00,$00,$00,$00,$00,$00,$00,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $E0,$9A,$E1,$9C,$E0,$9A,$E1,$9C,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $E2,$9E,$E3,$A0,$E2,$9E,$E3,$A0,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $00,$A1,$A2,$A3,$00,$A1,$A2,$A3,$00,$A1,$A2,$A3,$00,$A1,$A2,$A3
	.db $A4,$A5,$A6,$00,$A4,$A5,$A6,$00,$A4,$A5,$A6,$00,$A4,$A5,$A6,$00
	.db $00,$A1,$A2,$A3,$00,$A1,$A2,$A3,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $A4,$A5,$A6,$00,$A4,$A5,$A6,$00,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $AD,$AE,$AF,$B0,$B1,$B2,$B3,$B0,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB
	.db $BC,$BD,$BE,$BF,$C0,$C1,$C1,$C2,$A7,$A8,$A8,$A9,$AA,$AB,$AB,$AC
	.db $00,$00,$AD,$AE,$00,$00,$B1,$B2,$00,$00,$B4,$B5,$00,$00,$B8,$B9
	.db $00,$00,$BC,$BD,$00,$00,$C0,$C1,$00,$00,$A7,$A8,$00,$00,$AA,$AB
	.db $BC,$BD,$BE,$BF,$C0,$C1,$C1,$C2,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$C7,$3B,$3B,$3B,$3B,$3B,$3B,$C8
	.db $3B,$3B,$3B,$C4,$3B,$3B,$3B,$C4,$3B,$C8,$3B,$C4,$3B,$3B,$3B,$C4
	.db $C5,$C5,$C6,$3B,$C5,$C5,$C6,$3B,$C5,$C5,$C6,$3B,$C5,$C5,$C6,$3B
	.db $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B
	.db $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$C8,$3B,$3B,$C8,$3B,$3B,$3B,$3B
	.db $3B,$3B,$3B,$C4,$3B,$3B,$3B,$C4,$3B,$3B,$CB,$C4,$3B,$3B,$CC,$C4
	.db $C5,$C5,$C6,$3B,$C5,$C5,$C9,$CA,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5
	.db $3B,$3B,$3B,$3B,$CA,$CA,$CA,$CA,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5
	.db $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$9F,$3B,$3B,$3B,$3B,$9D,$3B,$3B
	.db $A7,$A8,$A8,$A9,$AA,$AB,$AB,$AC,$AD,$AE,$AF,$B0,$B1,$B2,$B3,$B0
	.db $CD,$CD,$CD,$CD,$D3,$D3,$D3,$D3,$D3,$D3,$D3,$D3,$D3,$D3,$D3,$D3
	.db $3B,$C4,$C5,$C5,$3B,$C4,$C5,$C5,$3B,$C4,$C5,$C5,$3B,$C4,$C5,$C5
	.db $3B,$3B,$C7,$3B,$3B,$3B,$3B,$3B,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$C8,$3B,$3B,$CB,$3B,$3B,$3B,$CC
	.db $3B,$C4,$C5,$C5,$CA,$CF,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5,$C5
	.db $CE,$3B,$3B,$3B,$CE,$3B,$3B,$D0,$CE,$3B,$3B,$3B,$CE,$3B,$C8,$3B
	.db $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B
	.db $CE,$3B,$3B,$3B,$CE,$3B,$3B,$3B,$CE,$3B,$C7,$3B,$CE,$3B,$3B,$3B
	.db $BE,$BF,$00,$00,$C1,$C2,$00,$00,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $3B,$D1,$AD,$AE,$3B,$D1,$B1,$B2,$3B,$D1,$B4,$B5,$3B,$D1,$B8,$B9
	.db $AF,$B0,$34,$35,$B3,$B0,$34,$35,$B6,$B7,$34,$35,$BA,$BB,$34,$35
	.db $BE,$BF,$34,$35,$C1,$C2,$84,$6B,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $3B,$D1,$BC,$BD,$C8,$D1,$C0,$C1,$3B,$D1,$A7,$A8,$3B,$D1,$AA,$AB
	.db $BE,$BF,$34,$35,$C1,$C2,$34,$35,$A8,$A9,$34,$35,$AB,$AC,$34,$35
	.db $3B,$D1,$BC,$BD,$3B,$D1,$C0,$C1,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $00,$00,$BC,$BD,$00,$00,$C0,$C1,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF,$C0,$C1,$C1,$C2
	.db $3B,$3B,$3B,$C4,$3B,$3B,$3B,$C4,$3B,$3B,$FB,$99,$3B,$3B,$77,$7B
	.db $D3,$D3,$D3,$D3,$9B,$9B,$9B,$9B,$FC,$FC,$FC,$FC,$6D,$6D,$6D,$6D
	.db $3B,$C7,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B
	.db $3B,$3B,$6C,$5C,$3B,$3B,$3B,$3B,$C8,$3B,$3B,$3B,$3B,$3B,$3B,$3B
	.db $00,$00,$34,$35,$00,$00,$34,$35,$00,$00,$34,$35,$00,$00,$34,$35
	.db $5C,$5C,$5C,$5C,$3B,$3B,$3B,$3B,$C7,$3B,$3B,$3B,$3B,$3B,$3B,$3B
	.db $3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $00,$00,$E4,$00,$00,$00,$00,$00,$00,$00,$E4,$00,$00,$00,$00,$00
	.db $CE,$3B,$3B,$3B,$CE,$3B,$3B,$3B,$FD,$58,$CE,$3B,$15,$13,$CE,$3B
	.db $C8,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$D2,$9F,$3B,$3B
	.db $5C,$5C,$5C,$5C,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B
	.db $00,$00,$34,$35,$00,$00,$84,$6B,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $5C,$11,$0F,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$C8,$3B,$C8,$3B
	.db $3B,$3B,$9D,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$3B,$CB,$3B,$3B,$3B,$CC
	.db $00,$00,$E4,$00,$00,$00,$00,$00,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $E4,$00,$00,$00,$00,$00,$00,$00,$E4,$00,$00,$00,$00,$00,$00,$00
	.db $E4,$00,$00,$00,$00,$00,$00,$00,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
Level52AttrData:
	.db $00,$AA,$AA,$AA,$AA,$5A,$5A,$55,$55,$55,$55,$55,$55,$55,$55,$DD
	.db $FF,$55,$DD,$FF,$FF,$FF,$FF,$55,$55,$05,$05,$55,$A5,$55,$55,$55
	.db $05,$55,$55,$55,$33,$55,$55,$55,$F5,$55,$55,$55,$FF,$F5,$FD,$FF
	.db $55,$55,$FA,$F5,$F5,$AA,$55,$55,$5A,$F5,$F5,$55,$55,$F5,$33,$55
	.db $55,$55,$55,$55,$F5,$F5,$55,$FF,$F0,$F5,$FF,$FF,$FF,$FF,$FF,$FF
	.db $FF,$CC,$CC,$FF,$FF,$FF,$66,$55,$FF,$FF,$A6,$A5,$FF,$FF,$FF,$99
	.db $FF,$FF,$A9,$FF,$FF,$FF,$F3,$FF,$77,$F7,$FF,$77,$FF,$FC,$FF,$BF
	.db $FF,$FF,$FF,$44,$FF,$FF,$AA,$EF,$FF,$FF,$F4,$FF,$FF,$F8,$AA,$F2
Level53TileData:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$3F,$40,$41,$3F
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$3F,$3F,$3F,$3F
	.db $0E,$0E,$34,$48,$0E,$0E,$34,$48,$0E,$0E,$34,$48,$3F,$3F,$34,$48
	.db $37,$37,$37,$37,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	.db $37,$38,$39,$37,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E
	.db $37,$37,$37,$37,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	.db $37,$37,$34,$48,$0E,$0E,$34,$48,$0E,$0E,$34,$48,$0E,$0E,$34,$48
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$3F,$3F,$3F,$3F
	.db $0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$3F,$40,$41,$3F
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$3F,$3F,$3F,$3F
	.db $0E,$0E,$34,$48,$0E,$0E,$34,$48,$0E,$0E,$34,$48,$3F,$3F,$34,$48
	.db $37,$37,$37,$37,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	.db $37,$38,$39,$37,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E
	.db $37,$37,$37,$37,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	.db $37,$37,$34,$48,$0E,$0E,$34,$48,$0E,$0E,$34,$48,$0E,$0E,$34,$48
	.db $34,$35,$43,$0E,$34,$35,$43,$0E,$34,$35,$43,$0E,$34,$35,$87,$3F
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$3F,$3F,$3F,$3F
	.db $0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$3F,$40,$41,$3F
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$3F,$3F,$3F,$3F
	.db $34,$35,$86,$37,$34,$35,$43,$0E,$34,$35,$43,$0E,$34,$35,$43,$0E
	.db $37,$37,$37,$37,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	.db $37,$38,$39,$37,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E
	.db $37,$37,$37,$37,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	.db $34,$35,$43,$0E,$34,$35,$43,$0E,$34,$35,$43,$0E,$34,$35,$87,$3F
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$3F,$3F,$3F,$3F
	.db $0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$3F,$40,$41,$3F
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$3F,$3F,$3F,$3F
	.db $34,$35,$42,$37,$34,$35,$43,$0E,$34,$35,$43,$0E,$34,$35,$43,$0E
	.db $37,$37,$37,$37,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	.db $37,$38,$39,$37,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E
	.db $37,$37,$37,$37,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$45,$45,$45,$45
	.db $0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$45,$46,$47,$45
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$45,$45,$45,$45
	.db $0E,$0E,$34,$48,$0E,$0E,$34,$48,$0E,$0E,$34,$48,$45,$45,$34,$48
	.db $7F,$7F,$7F,$7F,$81,$81,$81,$81,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $7F,$7F,$7F,$7F,$81,$81,$81,$81,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $7F,$7F,$7F,$7F,$81,$81,$81,$81,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $7F,$82,$34,$48,$81,$83,$84,$85,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $34,$35,$43,$0E,$34,$35,$43,$0E,$34,$35,$43,$0E,$34,$35,$44,$45
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$45,$45,$45,$45
	.db $0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$0E,$3C,$3D,$0E,$45,$46,$47,$45
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$45,$45,$45,$45
	.db $34,$35,$7F,$7F,$80,$6B,$81,$81,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $7F,$7F,$7F,$7F,$81,$81,$81,$81,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $7F,$7F,$7F,$7F,$81,$81,$81,$81,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $7F,$7F,$7F,$7F,$81,$81,$81,$81,$FA,$7C,$FA,$7C,$7D,$7E,$7D,$7E
	.db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$3F,$3F,$3F,$3F
Level53AttrData:
	.db $FF,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $55,$55,$55,$55,$F5,$F5,$F5,$F5,$FF,$FF,$FF,$FF,$00,$00,$00,$00
	.db $55,$55,$55,$55,$F5,$F5,$F5,$F5,$55

;;;;;;;;;;;;;;
;LEVEL 4 DATA;
;;;;;;;;;;;;;;
Level41BGPointerData:
	.dw Level41BGData+$0000
	.dw Level41BGData+$0040
	.dw Level41BGData+$0080
	.dw Level41BGData+$00C0
	.dw Level41BGData+$0100
	.dw Level41BGData+$0140
	.dw Level41BGData+$0180
	.dw Level41BGData+$01C0
	.dw Level41BGData+$0200
	.dw Level41BGData+$0240
	.dw Level41BGData+$0280
	.dw Level41BGData+$02B0
	.dw Level41BGData+$02E0
	.dw Level41BGData+$0310
	.dw Level41BGData+$0350
	.dw Level41BGData+$0390
Level41BGData:
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$04,$05,$00,$00
	.db $00,$00,$00,$00,$08,$09,$00,$00
	.db $08,$09,$16,$16,$0C,$0D,$16,$16
	.db $0C,$0D,$29,$29,$10,$11,$29,$29
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$08,$09,$00,$00
	.db $08,$09,$16,$16,$0C,$0D,$16,$16
	.db $0C,$0D,$29,$29,$10,$11,$29,$29
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$02,$03,$00,$00,$00
	.db $00,$00,$00,$06,$07,$00,$00,$00
	.db $00,$00,$00,$0A,$0B,$00,$00,$00
	.db $00,$00,$00,$0E,$0F,$00,$00,$00
	.db $12,$13,$16,$16,$16,$16,$16,$16
	.db $08,$09,$29,$29,$29,$29,$29,$29
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$02,$03,$00,$00,$00
	.db $00,$00,$00,$06,$07,$00,$00,$00
	.db $00,$00,$00,$0A,$0B,$00,$00,$00
	.db $00,$00,$00,$0E,$0F,$00,$00,$00
	.db $16,$17,$18,$18,$18,$18,$18,$18
	.db $1A,$1B,$1C,$1C,$1C,$1C,$1C,$1C
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$02,$03,$00,$00,$00
	.db $00,$00,$00,$06,$07,$00,$00,$00
	.db $00,$00,$00,$0A,$0B,$00,$00,$00
	.db $00,$00,$00,$0E,$0F,$00,$00,$00
	.db $18,$18,$18,$18,$18,$18,$18,$18
	.db $1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$02,$03,$00,$00,$00
	.db $00,$00,$00,$06,$07,$00,$00,$00
	.db $00,$00,$00,$0A,$0B,$00,$00,$00
	.db $00,$00,$00,$0E,$0F,$00,$00,$00
	.db $18,$18,$19,$16,$16,$16,$16,$16
	.db $1A,$1B,$1C,$1C,$1C,$1C,$1C,$1C
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $16,$17,$19,$16,$16,$16,$16,$16
	.db $1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $17,$19,$16,$16,$16,$16,$16,$16
	.db $1A,$20,$21,$20,$21,$20,$21,$20
	.db $22,$23,$24,$23,$24,$23,$24,$23
	.db $25,$24,$23,$24,$23,$24,$23,$24
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $16,$16,$16,$16,$16,$16,$16,$16
	.db $21,$20,$21,$20,$21,$20,$21,$20
	.db $24,$23,$24,$23,$24,$23,$24,$23
	.db $23,$24,$23,$24,$23,$24,$23,$24
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $16,$16,$16,$16,$16,$16,$16,$16
	.db $21,$20,$21,$20,$21,$20,$21,$1A
	.db $24,$23,$24,$23,$24,$23,$24,$22
	.db $23,$24,$23,$24,$23,$24,$23,$25
	.db $25,$24,$23,$24,$23,$24,$23,$24
	.db $22,$23,$24,$23,$24,$23,$24,$23
	.db $25,$24,$23,$24,$23,$24,$23,$24
	.db $22,$23,$24,$23,$24,$23,$24,$23
	.db $25,$27,$27,$27,$27,$27,$27,$27
	.db $28,$28,$28,$28,$28,$28,$28,$28
	.db $23,$24,$23,$24,$23,$24,$23,$24
	.db $24,$23,$24,$23,$24,$23,$24,$23
	.db $23,$24,$23,$24,$23,$24,$23,$24
	.db $24,$23,$24,$23,$24,$23,$24,$23
	.db $27,$27,$27,$27,$27,$27,$27,$27
	.db $28,$28,$28,$28,$28,$28,$28,$28
	.db $23,$24,$23,$24,$23,$24,$23,$25
	.db $24,$23,$24,$23,$24,$23,$24,$22
	.db $23,$24,$23,$24,$23,$24,$23,$25
	.db $24,$23,$24,$23,$24,$23,$24,$22
	.db $27,$27,$27,$27,$27,$27,$27,$25
	.db $28,$28,$28,$28,$28,$28,$28,$28
	.db $26,$1E,$1F,$1E,$1F,$1E,$1F,$1E
	.db $1D,$1F,$1E,$1F,$1E,$1F,$1E,$1F
	.db $26,$1E,$1F,$1E,$1F,$1E,$1F,$1E
	.db $1D,$1F,$1E,$1F,$1E,$1F,$1E,$1F
	.db $26,$1E,$1F,$1E,$1F,$1E,$1F,$1E
	.db $1D,$1F,$1E,$1F,$1E,$1F,$1E,$1F
	.db $26,$1E,$1F,$1E,$1F,$1E,$1F,$1E
	.db $1D,$1F,$1E,$1F,$1E,$1F,$1E,$1F
	.db $1F,$1E,$1F,$1E,$1F,$1E,$1F,$1E
	.db $1E,$1F,$1E,$1F,$1E,$1F,$1E,$1F
	.db $1F,$1E,$1F,$1E,$1F,$1E,$1F,$1E
	.db $1E,$1F,$1E,$1F,$1E,$1F,$1E,$1F
	.db $1F,$1E,$1F,$1E,$1F,$1E,$1F,$1E
	.db $1E,$1F,$1E,$1F,$1E,$1F,$1E,$1F
	.db $1F,$1E,$1F,$1E,$1F,$1E,$1F,$1E
	.db $1E,$1F,$1E,$1F,$1E,$1F,$1E,$1F
	.db $1F,$1E,$1F,$1E,$1F,$1E,$1F,$26
	.db $1E,$1F,$1E,$1F,$1E,$1F,$1E,$1D
	.db $1F,$1E,$1F,$1E,$1F,$1E,$1F,$26
	.db $1E,$1F,$1E,$1F,$1E,$1F,$1E,$1D
	.db $1F,$1E,$1F,$1E,$1F,$1E,$1F,$26
	.db $1E,$1F,$1E,$1F,$1E,$1F,$1E,$1D
	.db $1F,$1E,$1F,$1E,$1F,$1E,$1F,$26
	.db $1E,$1F,$1E,$1F,$1E,$1F,$1E,$1D
Level42BGPointerData:
	.dw Level42BGData+$0000
	.dw Level42BGData+$0040
	.dw Level42BGData+$0080
	.dw Level42BGData+$00C0
	.dw Level42BGData+$0100
	.dw Level42BGData+$0130
	.dw Level42BGData+$0160
	.dw Level42BGData+$0190
	.dw Level42BGData+$01C0
	.dw Level42BGData+$0200
	.dw Level42BGData+$0240
	.dw Level42BGData+$0280
	.dw Level42BGData+$02C0
	.dw Level42BGData+$0300
	.dw Level42BGData+$0340
	.dw Level42BGData+$0380
	.dw Level42BGData+$03C0
	.dw Level42BGData+$04C0
	.dw Level42BGData+$0400
	.dw Level42BGData+$0430
	.dw Level42BGData+$0460
	.dw Level42BGData+$0490
Level42BGData:
	.db $04,$05,$7E,$01,$01,$4C,$01,$68
	.db $6A,$6B,$7E,$01,$01,$4C,$01,$68
	.db $0A,$0B,$AF,$AF,$AF,$A2,$AF,$A0
	.db $0A,$0B,$7E,$01,$01,$4C,$01,$68
	.db $6E,$6F,$7E,$01,$01,$4C,$01,$68
	.db $04,$05,$7E,$01,$01,$4C,$01,$68
	.db $04,$05,$7E,$01,$01,$4C,$01,$68
	.db $04,$05,$AF,$AF,$AF,$A2,$AF,$A0
	.db $69,$01,$4D,$01,$01,$7F,$08,$09
	.db $69,$01,$4D,$01,$01,$7F,$08,$09
	.db $A1,$AF,$A3,$AF,$AF,$AF,$08,$09
	.db $69,$01,$4D,$01,$01,$7F,$08,$09
	.db $69,$01,$4D,$01,$01,$7F,$08,$09
	.db $69,$01,$4D,$01,$01,$7F,$08,$09
	.db $69,$01,$4D,$01,$01,$7F,$04,$05
	.db $A1,$AF,$A3,$AF,$AF,$AF,$04,$05
	.db $04,$05,$54,$55,$00,$48,$30,$64
	.db $6A,$6B,$1C,$1D,$30,$46,$01,$68
	.db $0A,$0B,$44,$31,$01,$4C,$01,$68
	.db $0A,$0B,$28,$1A,$01,$4C,$01,$68
	.db $6E,$6F,$2C,$1E,$2D,$42,$01,$68
	.db $04,$05,$62,$52,$66,$4A,$53,$60
	.db $04,$05,$54,$67,$67,$4E,$67,$64
	.db $04,$05,$7E,$01,$01,$4C,$01,$68
	.db $65,$33,$49,$00,$56,$57,$04,$05
	.db $69,$01,$47,$33,$1E,$1F,$6A,$6B
	.db $69,$01,$4D,$01,$32,$45,$0A,$0B
	.db $69,$01,$4D,$01,$19,$2B,$0A,$0B
	.db $69,$01,$43,$2E,$1D,$2F,$6E,$6F
	.db $61,$50,$4B,$66,$51,$63,$04,$05
	.db $65,$67,$4F,$67,$67,$57,$04,$05
	.db $69,$01,$4D,$01,$01,$7F,$04,$05
	.db $08,$09,$7E,$01,$01,$4C,$01,$68
	.db $08,$09,$7E,$01,$01,$4C,$01,$68
	.db $08,$09,$AF,$AF,$AF,$A2,$AF,$A0
	.db $83,$83,$A4,$A5,$01,$4C,$01,$68
	.db $87,$87,$A8,$A9,$01,$4C,$01,$68
	.db $70,$71,$7A,$78,$76,$7C,$77,$74
	.db $69,$01,$4D,$01,$01,$7F,$02,$03
	.db $69,$01,$4D,$01,$01,$7F,$06,$07
	.db $A1,$AF,$A3,$AF,$AF,$AF,$0A,$0B
	.db $69,$01,$4D,$01,$01,$7F,$0A,$0B
	.db $69,$01,$4D,$01,$01,$7F,$0E,$0F
	.db $75,$79,$7D,$78,$76,$7B,$72,$73
	.db $01,$01,$08,$09,$01,$01,$01,$01
	.db $01,$01,$08,$09,$01,$01,$01,$01
	.db $01,$01,$08,$09,$01,$01,$01,$01
	.db $58,$59,$5A,$5A,$5B,$58,$58,$59
	.db $5C,$5D,$5E,$5E,$5F,$5C,$5C,$5D
	.db $01,$01,$08,$09,$01,$01,$01,$01
	.db $01,$08,$09,$01,$01,$08,$09,$01
	.db $01,$08,$09,$01,$01,$08,$09,$01
	.db $01,$08,$09,$01,$01,$08,$09,$01
	.db $01,$08,$09,$01,$01,$08,$09,$01
	.db $01,$08,$09,$01,$01,$08,$09,$01
	.db $AA,$A6,$A7,$AA,$AA,$A6,$A7,$AA
	.db $01,$01,$01,$04,$05,$8C,$01,$01
	.db $01,$01,$01,$04,$05,$1E,$2D,$1A
	.db $01,$01,$01,$6A,$6B,$8E,$33,$1E
	.db $58,$58,$59,$0A,$0B,$5B,$58,$58
	.db $5C,$5C,$5D,$0A,$0B,$5F,$5C,$5C
	.db $01,$01,$01,$6E,$6F,$90,$01,$01
	.db $01,$01,$01,$04,$05,$94,$12,$21
	.db $01,$01,$01,$04,$05,$3D,$16,$25
	.db $01,$01,$8D,$08,$09,$01,$01,$01
	.db $19,$2E,$1D,$08,$09,$01,$01,$01
	.db $1D,$30,$8F,$08,$09,$01,$01,$01
	.db $58,$58,$59,$83,$83,$A4,$58,$58
	.db $5C,$5C,$5D,$87,$87,$A8,$5C,$5C
	.db $01,$01,$8D,$0C,$0D,$01,$01,$01
	.db $19,$2E,$1D,$04,$05,$01,$01,$01
	.db $9C,$9D,$8F,$04,$05,$01,$01,$01
	.db $01,$01,$01,$04,$05,$40,$3A,$3B
	.db $01,$01,$01,$04,$05,$00,$30,$31
	.db $01,$01,$01,$04,$05,$3C,$01,$01
	.db $01,$01,$01,$04,$05,$28,$1A,$01
	.db $01,$01,$01,$04,$05,$2C,$1E,$34
	.db $01,$01,$01,$02,$03,$10,$35,$26
	.db $01,$01,$01,$06,$07,$14,$15,$2A
	.db $01,$01,$01,$0A,$0B,$18,$01,$01
	.db $25,$36,$13,$02,$03,$01,$01,$01
	.db $29,$16,$17,$06,$07,$01,$01,$01
	.db $01,$01,$1B,$0A,$0B,$01,$01,$01
	.db $01,$22,$23,$0A,$0B,$01,$01,$01
	.db $11,$26,$27,$0E,$0F,$01,$01,$01
	.db $38,$39,$41,$04,$05,$01,$01,$01
	.db $32,$33,$00,$04,$05,$01,$01,$01
	.db $01,$01,$3F,$04,$05,$01,$01,$01
	.db $01,$01,$01,$0A,$0B,$90,$01,$01
	.db $01,$01,$01,$6E,$6F,$94,$12,$21
	.db $01,$01,$01,$04,$05,$3D,$9A,$25
	.db $01,$01,$01,$04,$05,$1C,$1D,$98
	.db $01,$01,$01,$04,$05,$44,$31,$01
	.db $01,$01,$01,$04,$05,$8C,$01,$01
	.db $01,$01,$01,$04,$05,$1E,$2D,$1A
	.db $01,$01,$01,$04,$05,$8E,$9E,$9F
	.db $01,$01,$8D,$04,$05,$01,$01,$01
	.db $19,$2E,$1D,$04,$05,$01,$01,$01
	.db $9C,$9D,$8F,$04,$05,$01,$01,$01
	.db $16,$25,$93,$6A,$6B,$01,$01,$01
	.db $01,$29,$97,$0A,$0B,$01,$01,$01
	.db $01,$01,$91,$0A,$0B,$01,$01,$01
	.db $22,$11,$95,$6E,$6F,$01,$01,$01
	.db $26,$15,$3E,$04,$05,$01,$01,$01
	.db $01,$01,$01,$02,$03,$10,$35,$26
	.db $01,$01,$01,$06,$07,$14,$15,$2A
	.db $01,$01,$01,$0A,$0B,$18,$01,$01
	.db $01,$01,$01,$0A,$0B,$20,$21,$01
	.db $01,$01,$01,$0E,$0F,$24,$25,$12
	.db $01,$01,$01,$04,$05,$40,$3A,$3B
	.db $01,$01,$01,$04,$05,$00,$30,$31
	.db $01,$01,$01,$04,$05,$3C,$01,$01
	.db $38,$39,$41,$04,$05,$01,$01,$01
	.db $32,$33,$00,$04,$05,$01,$01,$01
	.db $01,$01,$3F,$04,$05,$01,$01,$01
	.db $01,$19,$2B,$04,$05,$01,$01,$01
	.db $37,$1D,$2F,$04,$05,$01,$01,$01
	.db $25,$36,$13,$02,$03,$01,$01,$01
	.db $29,$16,$17,$06,$07,$01,$01,$01
	.db $01,$01,$1B,$0A,$0B,$01,$01,$01
	.db $01,$01,$01,$04,$05,$8C,$01,$01
	.db $01,$01,$01,$04,$05,$1E,$2D,$1A
	.db $01,$01,$01,$04,$05,$8E,$9E,$9F
	.db $01,$01,$01,$6A,$6B,$92,$26,$15
	.db $01,$01,$01,$0A,$0B,$96,$2A,$01
	.db $01,$01,$01,$0A,$0B,$90,$01,$01
	.db $01,$01,$01,$6E,$6F,$94,$12,$21
	.db $01,$01,$01,$04,$05,$3D,$16,$25
	.db $01,$01,$01,$04,$05,$40,$3A,$3B
	.db $01,$01,$01,$04,$05,$00,$30,$31
	.db $01,$01,$01,$04,$05,$3C,$01,$01
	.db $01,$01,$80,$81,$81,$81,$81,$81
	.db $01,$01,$84,$85,$85,$85,$85,$85
	.db $8B,$8B,$88,$89,$89,$89,$89,$89
	.db $25,$36,$13,$02,$03,$01,$01,$01
	.db $29,$16,$17,$06,$07,$01,$01,$01
	.db $01,$01,$1B,$0A,$0B,$01,$01,$01
	.db $81,$81,$81,$81,$81,$82,$01,$01
	.db $85,$85,$85,$85,$85,$86,$01,$01
	.db $89,$89,$89,$89,$89,$8A,$8B,$8B
	.db $04,$05,$7E,$01,$01,$4C,$01,$68
	.db $6A,$6B,$7E,$01,$01,$4C,$01,$68
	.db $0A,$0B,$AF,$AF,$AF,$A2,$AF,$A0
	.db $0A,$0B,$7E,$01,$01,$4C,$01,$68
	.db $6E,$6F,$7E,$01,$01,$4C,$01,$68
	.db $AC,$AD,$7A,$78,$76,$7C,$77,$74
	.db $69,$01,$4D,$01,$01,$7F,$08,$09
	.db $69,$01,$4D,$01,$01,$7F,$08,$09
	.db $A1,$AF,$A3,$AF,$AF,$AF,$08,$09
	.db $69,$01,$4D,$01,$01,$7F,$08,$09
	.db $69,$01,$4D,$01,$01,$7F,$08,$09
	.db $75,$79,$7D,$78,$76,$7B,$AE,$AB
	.db $01,$01,$91,$0A,$0B,$01,$01,$01
	.db $22,$11,$95,$6E,$6F,$01,$01,$01
	.db $26,$9B,$3E,$04,$05,$01,$01,$01
	.db $99,$1E,$1F,$04,$05,$01,$01,$01
	.db $01,$32,$45,$04,$05,$01,$01,$01
	.db $01,$01,$8D,$04,$05,$01,$01,$01
	.db $19,$2E,$1D,$04,$05,$01,$01,$01
	.db $9C,$9D,$8F,$04,$05,$01,$01,$01
Level43BGPointerData:
	.dw Level43BGData+$0000
	.dw Level43BGData+$0040
Level43BGData:
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$01,$01,$00,$00,$00
	.db $00,$00,$00,$01,$01,$00,$00,$00
	.db $00,$00,$00,$02,$03,$00,$00,$00
	.db $00,$00,$00,$06,$07,$00,$00,$00
	.db $00,$00,$00,$0A,$0B,$00,$00,$00
	.db $00,$00,$00,$0E,$0F,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00
Level41TileData:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $0E,$0F,$10,$11,$00,$16,$17,$00,$1A,$1B,$1C,$1D,$21,$22,$23,$24
	.db $08,$09,$0A,$0B,$12,$04,$13,$00,$18,$13,$00,$14,$1E,$00,$14,$04
	.db $0C,$09,$0A,$0D,$14,$04,$13,$15,$04,$13,$00,$19,$13,$00,$1F,$20
	.db $00,$00,$00,$00,$00,$00,$00,$00,$C4,$C5,$C6,$C6,$C4,$C5,$C6,$C6
	.db $00,$00,$00,$00,$00,$00,$00,$00,$C6,$C6,$C7,$C4,$C6,$C6,$C7,$C4
	.db $25,$14,$04,$13,$12,$04,$13,$00,$27,$13,$00,$14,$00,$29,$2A,$2B
	.db $00,$14,$04,$26,$14,$04,$13,$15,$04,$13,$00,$28,$2C,$2D,$2E,$00
	.db $C4,$C5,$C6,$C6,$C4,$C5,$C6,$C6,$C4,$C5,$C6,$C6,$C4,$D9,$DA,$DA
	.db $C6,$C6,$C7,$C4,$C6,$C6,$C7,$C4,$C6,$C6,$C7,$C4,$DA,$DA,$DB,$C4
	.db $00,$00,$2F,$30,$00,$00,$33,$34,$00,$00,$00,$38,$00,$00,$00,$00
	.db $31,$32,$00,$00,$35,$36,$37,$00,$39,$3A,$3B,$3C,$3D,$3E,$3F,$40
	.db $C4,$C5,$C6,$C6,$C4,$C5,$58,$C6,$C4,$C5,$59,$C6,$C4,$C5,$58,$C6
	.db $C6,$C6,$C7,$C4,$C6,$58,$C7,$C4,$C6,$59,$C7,$C4,$C6,$58,$C7,$C4
	.db $41,$42,$00,$00,$46,$47,$48,$00,$00,$4D,$4E,$4F,$00,$52,$53,$54
	.db $00,$43,$44,$45,$49,$4A,$4B,$4C,$50,$44,$51,$00,$55,$56,$57,$00
	.db $C4,$C5,$59,$C6,$C4,$C5,$58,$C6,$C4,$C5,$59,$C6,$C4,$C5,$58,$C6
	.db $C6,$59,$C7,$C4,$C6,$58,$C7,$C4,$C6,$59,$C7,$C4,$C6,$58,$C7,$C4
	.db $5A,$5A,$5A,$5A,$5B,$5B,$5B,$5B,$C4,$C5,$C6,$C6,$C4,$C5,$C6,$C6
	.db $5A,$5A,$5A,$5A,$5B,$5B,$5B,$5B,$C6,$C6,$C7,$C4,$C6,$C6,$C7,$C4
	.db $C4,$C5,$C6,$C6,$C4,$D9,$DA,$DA,$C4,$C5,$C6,$C6,$C4,$C5,$58,$C6
	.db $C6,$C6,$C7,$C4,$DA,$DA,$DB,$C4,$C6,$C6,$C7,$C4,$C6,$58,$C7,$C4
	.db $5A,$5A,$5A,$5A,$5B,$5B,$5B,$5B,$04,$04,$04,$04,$04,$04,$04,$04
	.db $5A,$5A,$5A,$5A,$5B,$5B,$5B,$5B,$DC,$DC,$DC,$DC,$5D,$5E,$5E,$5E
	.db $5A,$5A,$5A,$5A,$5B,$5B,$5B,$5B,$DC,$DC,$DC,$DC,$5E,$5E,$5E,$5E
	.db $5A,$5A,$5A,$5A,$5B,$5B,$5B,$5B,$DC,$DC,$DC,$DC,$5E,$5E,$5E,$5F
	.db $C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF,$CC,$D1,$D2,$CF,$CC,$D3,$D4,$CF
	.db $C1,$C1,$C1,$C1,$07,$44,$44,$44,$07,$44,$44,$44,$06,$D6,$D6,$D6
	.db $C1,$C1,$C1,$C1,$44,$44,$44,$44,$44,$44,$44,$44,$D6,$D6,$D6,$D6
	.db $CC,$D3,$D4,$CF,$CC,$D3,$D4,$CF,$CC,$D3,$D4,$CF,$CC,$CD,$CE,$CF
	.db $75,$60,$72,$61,$04,$04,$60,$72,$04,$04,$76,$60,$04,$04,$04,$70
	.db $04,$04,$70,$62,$61,$70,$62,$75,$74,$63,$75,$04,$64,$65,$61,$04
	.db $C1,$C1,$C1,$C1,$44,$44,$44,$44,$44,$44,$73,$66,$D6,$D6,$67,$68
	.db $C1,$C1,$C1,$C1,$44,$44,$44,$44,$44,$44,$71,$73,$69,$01,$02,$03
	.db $CC,$D3,$D4,$CF,$CC,$D3,$D4,$CF,$CC,$D3,$D4,$CF,$CC,$D3,$D4,$CF
	.db $04,$04,$76,$60,$04,$04,$04,$70,$04,$04,$70,$62,$61,$70,$62,$75
	.db $74,$63,$75,$04,$64,$65,$61,$04,$75,$60,$72,$61,$04,$04,$60,$72
	.db $CC,$D3,$D4,$CF,$CC,$CD,$CE,$CF,$CC,$D1,$D2,$CF,$CC,$D3,$D4,$CF
	.db $CC,$D1,$D2,$CF,$CC,$D3,$D4,$CF,$CC,$D3,$D4,$CF,$CC,$D3,$D4,$CF
	.db $C0,$C0,$C0,$C0,$44,$44,$44,$44,$44,$44,$44,$44,$D6,$D6,$D6,$D6
	.db $D7,$D8,$D7,$D8,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
	.db $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
	.db $C1,$C1,$C1,$C1,$07,$44,$44,$44,$07,$44,$73,$66,$07,$D6,$67,$68
Level41AttrData:
	.db $55,$AA,$AA,$AA,$F5,$F5,$AA,$AA,$FF,$FF,$AA,$AA,$FF,$FF,$AA,$AA
	.db $FF,$FF,$F5,$F5,$FF,$FF,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $55,$55,$55,$55,$55,$55,$55,$55,$AA,$55,$55
Level42TileData:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	.db $70,$0B,$6B,$6B,$70,$0B,$6B,$6B,$70,$0B,$6B,$6B,$70,$21,$08,$08
	.db $6B,$6B,$76,$70,$6B,$6B,$76,$70,$6B,$6B,$76,$70,$08,$08,$09,$70
	.db $70,$0B,$6B,$6B,$70,$0B,$6B,$6B,$70,$0B,$6B,$6B,$70,$0B,$6B,$6B
	.db $6B,$6B,$76,$70,$6B,$6B,$76,$70,$6B,$6B,$76,$70,$6B,$6B,$76,$70
	.db $70,$0B,$6B,$6B,$70,$0B,$6E,$6B,$70,$0B,$75,$6B,$70,$0B,$6E,$6B
	.db $6B,$6B,$76,$70,$6B,$6E,$76,$70,$6B,$75,$76,$70,$6B,$6E,$76,$70
	.db $48,$49,$03,$03,$48,$49,$03,$03,$48,$49,$03,$03,$48,$49,$03,$03
	.db $03,$03,$4A,$48,$03,$03,$4A,$48,$03,$03,$4A,$48,$03,$03,$4A,$48
	.db $70,$0B,$75,$6B,$70,$0B,$6E,$6B,$70,$0B,$75,$6B,$70,$0B,$6E,$6B
	.db $6B,$75,$76,$70,$6B,$6E,$76,$70,$6B,$75,$76,$70,$6B,$6E,$76,$70
	.db $71,$72,$73,$73,$70,$0B,$01,$01,$70,$0B,$6B,$6B,$70,$0B,$6B,$6B
	.db $73,$73,$74,$71,$01,$01,$76,$70,$6B,$6B,$76,$70,$6B,$6B,$76,$70
	.db $70,$0B,$75,$6B,$70,$21,$08,$08,$70,$0B,$6B,$6B,$70,$0B,$6B,$6B
	.db $6B,$75,$76,$70,$08,$08,$09,$70,$6B,$6B,$76,$70,$6B,$6B,$76,$70
	.db $00,$02,$02,$02,$00,$02,$02,$02,$50,$02,$53,$04,$0A,$04,$5F,$01
	.db $51,$02,$53,$04,$53,$04,$5F,$01,$5F,$01,$5E,$01,$01,$01,$01,$01
	.db $58,$14,$55,$02,$01,$15,$58,$14,$5E,$01,$5E,$15,$01,$01,$01,$01
	.db $02,$02,$02,$00,$02,$02,$02,$00,$58,$14,$55,$00,$01,$15,$58,$2C
	.db $5D,$01,$5E,$01,$0C,$01,$01,$01,$0C,$01,$01,$01,$0C,$01,$01,$0E
	.db $01,$01,$01,$01,$01,$01,$01,$0E,$01,$0E,$10,$11,$10,$11,$02,$02
	.db $01,$01,$01,$01,$24,$01,$01,$01,$25,$23,$24,$01,$02,$02,$25,$23
	.db $5E,$01,$5E,$2D,$01,$01,$01,$2D,$01,$01,$01,$2D,$24,$01,$01,$2D
	.db $0C,$0E,$10,$11,$12,$11,$02,$02,$00,$02,$02,$02,$00,$02,$02,$02
	.db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$1E,$1F,$1E,$1F,$20,$00
	.db $02,$02,$02,$02,$02,$02,$02,$02,$19,$1A,$02,$02,$00,$1B,$19,$1A
	.db $25,$23,$24,$2D,$02,$02,$25,$2E,$02,$02,$02,$00,$02,$02,$02,$00
	.db $00,$02,$1E,$1F,$00,$1F,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$1B,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $19,$1A,$02,$00,$00,$1B,$19,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $5A,$14,$55,$02,$0C,$15,$58,$14,$5D,$01,$5E,$15,$0C,$01,$01,$01
	.db $02,$02,$02,$02,$02,$02,$02,$02,$58,$14,$55,$02,$01,$15,$58,$14
	.db $02,$02,$02,$02,$02,$02,$02,$02,$51,$02,$53,$04,$53,$04,$5F,$01
	.db $51,$02,$53,$34,$53,$04,$5F,$2D,$5F,$01,$5E,$2D,$01,$01,$01,$2D
	.db $0C,$01,$01,$01,$0C,$01,$01,$01,$22,$23,$24,$01,$00,$02,$25,$23
	.db $5E,$01,$5E,$15,$01,$01,$01,$01,$01,$01,$01,$01,$24,$01,$01,$01
	.db $5F,$01,$5E,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$0E
	.db $01,$01,$01,$2D,$01,$01,$01,$2D,$01,$0E,$10,$16,$10,$11,$02,$00
	.db $00,$1A,$02,$02,$00,$1B,$19,$1A,$00,$00,$00,$1B,$00,$00,$00,$00
	.db $25,$23,$24,$01,$02,$02,$25,$23,$02,$02,$02,$02,$02,$02,$02,$02
	.db $01,$0E,$10,$11,$10,$11,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	.db $02,$02,$1E,$00,$1E,$1F,$20,$00,$20,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$1D,$00,$00,$00,$02,$1C,$1D
	.db $19,$1A,$02,$02,$00,$1B,$19,$1A,$00,$00,$00,$1B,$00,$00,$00,$00
	.db $02,$02,$1E,$1F,$1E,$1F,$20,$00,$20,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$28,$00,$28,$29,$02,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$28,$29,$28,$29,$02,$02
	.db $00,$00,$28,$29,$28,$29,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	.db $1C,$1D,$00,$00,$02,$02,$1C,$1D,$02,$02,$02,$02,$02,$02,$02,$02
	.db $00,$00,$00,$00,$00,$00,$00,$00,$1C,$1D,$00,$00,$02,$02,$1C,$1D
	.db $19,$1A,$02,$02,$00,$1B,$19,$1A,$50,$00,$54,$35,$54,$35,$5F,$01
	.db $52,$1D,$54,$35,$53,$04,$5F,$01,$5F,$01,$5E,$01,$01,$01,$01,$01
	.db $59,$2B,$56,$29,$01,$15,$58,$14,$5E,$01,$5E,$15,$01,$01,$01,$01
	.db $02,$02,$1E,$1F,$1E,$1F,$20,$00,$59,$2B,$57,$00,$01,$15,$59,$2B
	.db $01,$01,$01,$01,$01,$01,$01,$0E,$01,$0E,$17,$18,$17,$18,$00,$00
	.db $01,$0E,$10,$11,$17,$18,$19,$1A,$00,$00,$00,$1B,$00,$00,$00,$00
	.db $25,$23,$24,$01,$1E,$1F,$26,$27,$20,$00,$00,$00,$00,$00,$00,$00
	.db $01,$01,$01,$01,$24,$01,$01,$01,$26,$27,$24,$01,$00,$00,$26,$27
	.db $00,$00,$28,$29,$00,$29,$02,$02,$00,$02,$02,$02,$00,$02,$02,$02
	.db $22,$23,$24,$01,$00,$02,$25,$23,$00,$02,$02,$02,$00,$02,$02,$02
	.db $01,$0E,$10,$16,$10,$11,$02,$00,$02,$02,$02,$00,$02,$02,$02,$00
	.db $1C,$1D,$00,$00,$02,$02,$1C,$00,$02,$02,$02,$00,$02,$02,$02,$00
	.db $00,$02,$02,$02,$00,$02,$02,$02,$00,$02,$1E,$1F,$00,$1F,$20,$00
	.db $02,$02,$02,$00,$02,$02,$02,$00,$19,$1A,$02,$00,$00,$1B,$19,$00
	.db $02,$02,$3A,$3B,$02,$02,$3A,$3B,$19,$1A,$3A,$3B,$00,$1B,$3A,$3B
	.db $3A,$3B,$02,$02,$3A,$3B,$02,$02,$3A,$3B,$1E,$1F,$3A,$3B,$20,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$28,$29,$00,$29,$02,$02
	.db $00,$00,$00,$00,$00,$00,$00,$00,$1C,$1D,$00,$00,$02,$02,$1C,$00
	.db $00,$00,$3A,$3B,$28,$29,$3A,$3B,$02,$02,$3A,$3B,$02,$02,$3A,$3B
	.db $3A,$3B,$00,$00,$3A,$3B,$1C,$1D,$3A,$3B,$02,$02,$3A,$3B,$02,$02
	.db $00,$00,$3A,$3B,$00,$00,$3A,$3B,$00,$00,$3A,$3B,$00,$00,$3A,$3B
	.db $3A,$3B,$00,$00,$3A,$3B,$00,$00,$3A,$3B,$00,$00,$3A,$3B,$00,$00
	.db $00,$00,$3A,$3B,$00,$00,$3A,$3B,$07,$07,$3A,$3B,$00,$00,$3A,$3B
	.db $3A,$3B,$00,$00,$3A,$3B,$00,$00,$3A,$3B,$07,$07,$3A,$3B,$00,$00
	.db $02,$02,$3A,$3B,$02,$02,$3A,$3B,$02,$02,$3A,$3B,$02,$02,$3A,$3B
	.db $3A,$3B,$02,$02,$3A,$3B,$02,$02,$3A,$3B,$02,$02,$3A,$3B,$02,$02
	.db $00,$00,$3A,$3B,$00,$00,$3A,$3B,$02,$02,$3A,$3B,$02,$02,$3A,$3B
	.db $3A,$3B,$00,$00,$3A,$3B,$00,$00,$3A,$3B,$02,$02,$3A,$3B,$02,$02
	.db $02,$02,$1E,$1F,$1E,$1F,$20,$00,$07,$07,$07,$07,$00,$00,$00,$00
	.db $00,$00,$28,$29,$28,$29,$02,$02,$07,$07,$07,$07,$00,$00,$00,$00
	.db $1C,$1D,$00,$00,$02,$02,$1C,$1D,$07,$07,$07,$07,$00,$00,$00,$00
	.db $19,$1A,$02,$02,$00,$1B,$19,$1A,$07,$07,$07,$07,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$00,$02,$02,$02
	.db $00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$1E,$1F,$1E,$1F,$20,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$19,$1A,$02,$02,$00,$1B,$19,$1A
	.db $00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$00,$02,$02,$02,$00
	.db $60,$60,$60,$60,$4C,$4C,$4C,$4C,$01,$01,$01,$01,$01,$01,$01,$01
	.db $60,$60,$60,$60,$4C,$4C,$4D,$4C,$01,$01,$4E,$01,$01,$01,$4E,$01
	.db $60,$60,$60,$60,$4C,$4C,$4C,$4C,$0D,$01,$0D,$01,$75,$01,$75,$01
	.db $60,$60,$60,$60,$4D,$4C,$4C,$4C,$4E,$01,$01,$01,$4E,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01,$4F,$4F,$4F,$4F,$60,$60,$60,$60
	.db $01,$01,$4E,$01,$01,$01,$4E,$01,$4F,$4F,$05,$4F,$60,$60,$60,$60
	.db $01,$01,$01,$01,$0D,$01,$0D,$01,$06,$4F,$06,$4F,$60,$60,$60,$60
	.db $4E,$01,$01,$01,$4E,$01,$01,$01,$05,$4F,$4F,$4F,$60,$60,$60,$60
	.db $02,$02,$40,$3D,$02,$02,$41,$3F,$07,$07,$3C,$3D,$00,$00,$3E,$3F
	.db $42,$46,$02,$02,$44,$47,$02,$02,$42,$43,$07,$07,$44,$45,$00,$00
	.db $00,$02,$02,$02,$00,$02,$02,$02,$00,$07,$07,$07,$00,$00,$00,$00
	.db $02,$02,$02,$00,$02,$02,$02,$00,$07,$07,$07,$00,$00,$00,$00,$00
	.db $00,$00,$3C,$3D,$00,$00,$3E,$3F,$02,$02,$40,$3D,$02,$02,$41,$3F
	.db $42,$43,$00,$00,$44,$45,$00,$00,$42,$46,$02,$02,$44,$47,$02,$02
	.db $00,$00,$00,$00,$00,$00,$00,$00,$07,$07,$07,$07,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$02,$02,$02,$02,$02
	.db $02,$02,$40,$3D,$02,$02,$41,$3F,$02,$02,$40,$3D,$02,$02,$41,$3F
	.db $42,$46,$02,$02,$44,$47,$02,$02,$42,$46,$02,$02,$44,$47,$02,$02
	.db $70,$0B,$6B,$6B,$70,$21,$08,$08,$70,$0B,$6B,$6B,$70,$0B,$6E,$6B
	.db $6B,$6B,$76,$70,$08,$08,$09,$70,$6B,$6B,$76,$70,$6B,$6E,$76,$70
	.db $71,$72,$73,$73,$70,$0B,$6E,$6B,$70,$0B,$75,$6B,$70,$0B,$6E,$6B
	.db $73,$73,$74,$71,$6B,$6E,$76,$70,$6B,$75,$76,$70,$6B,$6E,$76,$70
	.db $70,$0B,$75,$6B,$70,$0B,$6E,$6B,$70,$0B,$75,$6B,$70,$21,$08,$08
	.db $6B,$75,$76,$70,$6B,$6E,$76,$70,$6B,$75,$76,$70,$08,$08,$09,$70
	.db $71,$72,$73,$73,$70,$0B,$6B,$6B,$67,$67,$67,$67,$00,$00,$00,$00
	.db $73,$73,$74,$71,$6B,$6B,$76,$70,$67,$67,$67,$36,$00,$00,$38,$01
	.db $70,$0B,$6B,$6B,$70,$0B,$6B,$6B,$66,$66,$66,$66,$01,$01,$01,$01
	.db $6B,$6B,$76,$70,$6B,$6B,$76,$70,$66,$66,$66,$37,$01,$01,$39,$00
	.db $02,$02,$40,$3D,$02,$02,$41,$3F,$66,$66,$66,$37,$01,$01,$39,$00
	.db $42,$46,$02,$02,$44,$47,$02,$02,$67,$67,$67,$67,$00,$00,$00,$00
	.db $02,$02,$02,$02,$02,$02,$02,$02,$67,$67,$67,$67,$00,$00,$00,$00
	.db $02,$02,$02,$02,$02,$02,$02,$02,$66,$66,$66,$66,$01,$01,$01,$01
	.db $02,$02,$02,$02,$02,$02,$02,$02,$66,$66,$66,$37,$01,$01,$39,$00
	.db $02,$02,$02,$02,$02,$02,$02,$02,$67,$67,$67,$36,$00,$00,$38,$01
	.db $00,$02,$02,$02,$00,$02,$02,$02,$66,$66,$66,$66,$01,$01,$01,$01
	.db $02,$02,$02,$00,$02,$02,$02,$00,$67,$67,$67,$36,$00,$00,$38,$01
	.db $02,$02,$3A,$3B,$02,$02,$3A,$3B,$67,$67,$67,$36,$00,$00,$38,$01
	.db $3A,$3B,$02,$02,$3A,$3B,$02,$02,$66,$66,$66,$66,$01,$01,$01,$01
	.db $00,$02,$02,$02,$00,$02,$02,$02,$00,$02,$02,$02,$00,$02,$02,$02
	.db $02,$02,$02,$00,$02,$02,$02,$00,$02,$02,$02,$00,$02,$02,$02,$00
	.db $61,$62,$62,$62,$0F,$03,$03,$03,$0F,$03,$03,$03,$0F,$03,$03,$03
	.db $62,$62,$62,$62,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
	.db $62,$62,$62,$63,$03,$03,$03,$2F,$03,$03,$03,$2F,$03,$03,$03,$2F
	.db $6A,$6A,$6A,$6A,$4C,$4C,$4C,$4C,$6E,$6B,$6E,$6B,$75,$6B,$75,$6B
	.db $0F,$03,$03,$03,$0F,$03,$03,$03,$0F,$03,$03,$03,$0F,$03,$03,$03
	.db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
	.db $03,$03,$03,$2F,$03,$03,$03,$2F,$03,$03,$03,$2F,$03,$03,$03,$2F
	.db $6B,$6B,$6B,$6B,$6E,$6B,$6E,$6B,$6F,$69,$6F,$69,$6A,$6A,$6A,$6A
	.db $0F,$03,$03,$03,$0F,$03,$03,$03,$68,$68,$68,$68,$00,$00,$00,$00
	.db $03,$03,$03,$03,$03,$03,$03,$03,$68,$68,$68,$68,$00,$00,$00,$00
	.db $03,$03,$03,$2F,$03,$03,$03,$2F,$68,$68,$68,$68,$00,$00,$00,$00
	.db $02,$02,$02,$02,$02,$02,$02,$02,$68,$68,$68,$68,$00,$00,$00,$00
	.db $00,$02,$02,$02,$00,$02,$02,$02,$00,$1A,$02,$02,$00,$1B,$19,$1A
	.db $02,$02,$02,$00,$02,$02,$02,$00,$02,$02,$1E,$00,$1E,$1F,$20,$00
	.db $00,$1D,$00,$00,$00,$02,$1C,$1D,$00,$02,$02,$02,$00,$02,$02,$02
	.db $00,$00,$28,$00,$28,$29,$02,$00,$02,$02,$02,$00,$02,$02,$02,$00
	.db $00,$02,$02,$02,$00,$02,$02,$02,$5A,$14,$55,$02,$0C,$15,$58,$14
	.db $02,$02,$02,$00,$02,$02,$02,$00,$51,$02,$53,$34,$53,$04,$5F,$2D
	.db $50,$02,$53,$04,$0A,$04,$5F,$01,$5D,$01,$5E,$01,$0C,$01,$01,$01
	.db $58,$14,$55,$00,$01,$15,$58,$2C,$5E,$01,$5E,$2D,$01,$01,$01,$2D
	.db $5D,$01,$5E,$15,$0C,$01,$01,$01,$0C,$01,$01,$01,$0C,$01,$01,$01
	.db $5F,$01,$5E,$2D,$01,$01,$01,$2D,$01,$01,$01,$2D,$01,$01,$01,$2D
	.db $0C,$01,$01,$01,$0C,$01,$01,$0E,$0C,$0E,$10,$11,$12,$11,$02,$02
	.db $01,$01,$01,$2D,$24,$01,$01,$2D,$25,$23,$24,$2D,$02,$02,$25,$2E
	.db $26,$27,$24,$01,$00,$00,$26,$27,$00,$00,$28,$29,$28,$29,$02,$02
	.db $01,$0E,$17,$18,$17,$18,$00,$00,$1C,$1D,$00,$00,$02,$02,$1C,$1D
	.db $01,$01,$01,$01,$24,$01,$01,$01,$25,$23,$24,$01,$1E,$1F,$26,$27
	.db $01,$01,$01,$01,$01,$01,$01,$0E,$01,$0E,$10,$11,$17,$18,$19,$1A
	.db $59,$2B,$57,$00,$01,$15,$59,$2B,$5E,$01,$5E,$15,$01,$01,$01,$01
	.db $00,$00,$00,$00,$00,$00,$00,$00,$59,$2B,$56,$29,$01,$15,$58,$14
	.db $00,$00,$00,$00,$00,$00,$00,$00,$52,$1D,$54,$35,$53,$04,$5F,$01
	.db $50,$00,$54,$35,$54,$35,$5F,$01,$5F,$01,$5E,$01,$01,$01,$01,$01
	.db $07,$07,$3C,$3D,$00,$00,$3E,$3F,$00,$00,$3C,$3D,$00,$00,$3E,$3F
	.db $42,$43,$07,$07,$44,$45,$00,$00,$42,$43,$00,$00,$44,$45,$00,$00
	.db $07,$07,$3A,$3B,$00,$00,$3A,$3B,$00,$00,$3A,$3B,$00,$00,$3A,$3B
	.db $3A,$3B,$07,$07,$3A,$3B,$00,$00,$3A,$3B,$00,$00,$3A,$3B,$00,$00
	.db $6A,$6A,$6A,$6A,$4D,$4C,$4C,$4C,$6C,$6B,$6B,$6B,$6C,$6B,$6B,$6B
	.db $6A,$6A,$6A,$31,$4C,$4C,$4C,$32,$6B,$6B,$6B,$30,$6B,$6B,$6B,$30
	.db $48,$49,$03,$03,$48,$49,$03,$03,$6A,$6A,$6A,$6A,$4C,$4C,$4C,$4C
	.db $03,$03,$4A,$48,$03,$03,$4A,$48,$6A,$6A,$6A,$6A,$4C,$4C,$4C,$4C
	.db $6C,$6B,$6B,$6B,$6C,$6B,$6B,$6B,$6D,$69,$69,$69,$6A,$6A,$6A,$6A
	.db $6B,$6B,$6B,$30,$6B,$6B,$6B,$30,$69,$69,$69,$33,$6A,$6A,$6A,$31
	.db $02,$02,$02,$02,$02,$02,$02,$02,$6A,$6A,$6A,$6A,$4C,$4C,$4C,$4C
	.db $03,$03,$4A,$48,$03,$03,$4A,$48,$66,$66,$66,$37,$01,$01,$39,$00
	.db $70,$0B,$6B,$6B,$70,$0B,$6B,$6B,$67,$67,$67,$67,$00,$00,$00,$00
	.db $6B,$6B,$76,$70,$6B,$6B,$76,$70,$67,$67,$67,$36,$00,$00,$38,$01
	.db $48,$49,$03,$03,$48,$49,$03,$03,$66,$66,$66,$66,$01,$01,$01,$01
	.db $07,$07,$07,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
Level42AttrData:
	.db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5,$55,$55
	.db $AA,$AA,$AA,$55,$AA,$AA,$AA,$55,$5A,$5A,$5A,$55,$55,$55,$55,$55
	.db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	.db $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$F5,$F5,$F5,$F5,$55

;;;;;;;;;;;;;;;;;;;;
;GAME MODE ROUTINES;
;;;;;;;;;;;;;;;;;;;;
;LEGAL MODE ROUTINES
RunGameMode_Legal:
	;Do jump table
	lda GameSubmode
	jsr DoJumpTable
LegalJumpTable:
	.dw RunGameSubmode_LegalLoadPart1	;$00  Load part 1
	.dw RunGameSubmode_LegalLoadPart2	;$01  Load part 2
	.dw RunGameSubmode_LegalFadeIn		;$02  Fade in
	.dw RunGameSubmode_LegalWait		;$03  Wait
	.dw RunGameSubmode_LegalFadeOut		;$04  Fade out
;$00: Load part 1
RunGameSubmode_LegalLoadPart1:
	;Clear ZP $40-$CF
	jsr ClearZP_40
	;Disable IRQ
	jsr DisableIRQ
	;Clear nametable
	jsr ClearNametableData
	;Clear sound
	jsr ClearSound
	;Clear palette
	jsr ClearPalette
	lda #$00
	sta CurPalette
	sta FadeDirection
	sta FadeInitFlag
	;Clear music
	sta CurMusic
	;Load CHR banks
	lda #$40
	sta FadeTimer
	sta TempCHRBanks
	lda #$7E
	sta TempCHRBanks+1
	;Set black screen timer
	dec BlackScreenTimer
	;Next submode ($01: Load part 2)
	inc GameSubmode
	;Clear scroll position
	lda TempMirror_PPUCTRL
	and #$FC
	sta TempMirror_PPUCTRL
	;Write VRAM strip (legal screen)
	lda #$10
	jmp WriteVRAMStrip
;$01: Load part 2
RunGameSubmode_LegalLoadPart2:
	;Next submode ($02: Fade in)
	inc GameSubmode
	;Write VRAM strip (legal screen)
	lda #$11
	jmp WriteVRAMStrip
;$02: Fade in
RunGameSubmode_LegalFadeIn:
	;Clear black screen timer
	lda #$00
	sta BlackScreenTimer
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_LegalWait_Exit
	;Next submode ($03: Wait)
	inc GameSubmode
	;Set timer
	ldy #$02
	jmp SetModeTimer_Any
;$03: Wait
RunGameSubmode_LegalWait:
	;Check for START press
	lda JoypadDown
	and #JOY_START
	beq RunGameSubmode_LegalWait_Dec
	;Check for A+B+SELECT held
	lda JoypadCur
	and #(JOY_A|JOY_B|JOY_SELECT)
	cmp #(JOY_A|JOY_B|JOY_SELECT)
	beq RunGameSubmode_LegalWait_Next
RunGameSubmode_LegalWait_Dec:
	;Decrement timer, check if 0
	jsr DecrementModeTimer
	bne RunGameSubmode_LegalWait_Exit
RunGameSubmode_LegalWait_Next:
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Next submode ($04: Fade out)
	inc GameSubmode
RunGameSubmode_LegalWait_Exit:
	rts
;$04: Fade out
RunGameSubmode_LegalFadeOut:
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_LegalWait_Exit
	;Check for A+B+RIGHT held
	lda JoypadCur
	and #(JOY_A|JOY_B|JOY_RIGHT)
	cmp #(JOY_A|JOY_B|JOY_RIGHT)
	;Next mode ($0A: Sound test)
	lda #$0A
	bcs RunGameSubmode_LegalFadeOut_SetMode
	;Next mode ($01: Title)
	lda #$01
RunGameSubmode_LegalFadeOut_SetMode:
	;Set game mode
	jmp SetGameMode

;SOUND TEST MODE ROUTINES
SoundTestMusicTable:
	.db MUSIC_TITLE
	.db MUSIC_SELECT
	.db MUSIC_SCENE0
	.db MUSIC_LEVEL1
	.db MUSIC_LEVEL2
	.db MUSIC_LEVEL3
	.db MUSIC_LEVEL4
	.db MUSIC_LEVEL5
	.db MUSIC_LEVEL6
	.db MUSIC_BOSS
	.db MUSIC_BOSSRUSHINT
	.db MUSIC_BOSS2
	.db MUSIC_SCENE1
	.db MUSIC_CREDITS
	.db MUSIC_GAMEOVER
	.db MUSIC_CLEAR
RunGameMode_SoundTest:
	;Check if already inited
	lda GameSubmode
	bne RunGameMode_SoundTest_Main
	;Mark inited
	inc GameSubmode
	;Init palette
	lda #$30
	sta PaletteBuffer+$01
	sta PaletteBuffer+$02
	sta PaletteBuffer+$03
	;Clear nametable
	jsr ClearNametableData
	;Write VRAM strip (sound test screen)
	lda #$3E
	jsr WriteVRAMStrip
	;Write VRAM strip (sound test song 0)
	lda #$2E
	jmp WriteVRAMStrip
RunGameMode_SoundTest_Main:
	;Write palette
	jsr WritePalette
	;Check for B press
	bit JoypadDown
	bvc RunGameMode_SoundTest_NoB
	;Clear sound
	jmp ClearSound
RunGameMode_SoundTest_NoB:
	;Check for A press
	bpl RunGameMode_SoundTest_NoA
	;Clear sound
	jsr ClearSound
	;Play music
	ldy SoundTestMusicIdx
	lda SoundTestMusicTable,y
	jmp LoadSound
RunGameMode_SoundTest_NoA:
	;Check for UP/DOWN press
	lda JoypadDown
	and #(JOY_UP|JOY_DOWN)
	bne RunGameMode_SoundTest_UpDown
RunGameMode_SoundTest_Exit:
	rts
RunGameMode_SoundTest_UpDown:
	;Check for UP press
	cmp #JOY_UP
	;Clear VRAM buffer
	lda #$00
	sta VRAMBufferOffset
	lda SoundTestMusicIdx
	bcs RunGameMode_SoundTest_Up
	;Check if at last song
	cmp #$0F
	beq RunGameMode_SoundTest_Exit
	;Increment current song
	inc SoundTestMusicIdx
RunGameMode_SoundTest_Draw:
	;Clear VRAM strip (sound test song previous)
	adc #$AE
	jsr WriteVRAMStrip
	;Write VRAM strip (sound test song current)
	lda SoundTestMusicIdx
	clc
	adc #$2E
	jmp WriteVRAMStrip
RunGameMode_SoundTest_Up:
	;Check if at first song
	beq RunGameMode_SoundTest_Exit
	;Decrement current song
	dec SoundTestMusicIdx
	clc
	bcc RunGameMode_SoundTest_Draw

;;;;;;;;;;;;;;;;;
;VRAM STRIP DATA;
;;;;;;;;;;;;;;;;;
VRAMStrip2EData:
	.dw $2144
	.db $B7,$90,$8E,$9D,$00,$98,$9E,$9D,$00,$8F,$9B,$98,$96,$00,$B2,$00
	.db $99,$98,$8C,$94,$8E,$9D,$B7
	.db $FF
VRAMStrip2FData:
	.dw $2147
	.db $B7,$9D,$A0,$92,$9C,$9D,$00,$B2,$97,$8D,$00,$9C,$8E,$95,$8E,$8C
	.db $9D,$B7
	.db $FF
VRAMStrip30Data:
	.dw $2149
	.db $B7,$A0,$B2,$9B,$95,$98,$8C,$94,$00,$8E,$A2,$8E,$9C,$B7
	.db $FF
VRAMStrip31Data:
	.dw $2148
	.db $B7,$9D,$91,$8E,$96,$8E,$00,$98,$8F,$00,$96,$96,$B5,$9C,$B7
	.db $FF
VRAMStrip32Data:
	.dw $2145
	.db $B7,$8D,$B2,$97,$8C,$92,$97,$B5,$92,$97,$00,$9D,$91,$8E,$00,$94
	.db $92,$9D,$8C,$91,$8E,$97,$B7
	.db $FF
VRAMStrip33Data:
	.dw $214A
	.db $B7,$8C,$98,$95,$B2,$00,$8F,$95,$98,$B2,$9D,$B7
	.db $FF
VRAMStrip34Data:
	.dw $2149
	.db $B7,$96,$98,$97,$9C,$9D,$8E,$9B,$00,$9B,$B2,$99,$B7
	.db $FF
VRAMStrip35Data:
	.dw $214A
	.db $B7,$B2,$9C,$92,$B2,$00,$8C,$95,$9E,$8B,$B7
	.db $FF
VRAMStrip36Data:
	.dw $214A
	.db $B7,$8E,$B2,$9B,$9D,$91,$9A,$9E,$B2,$94,$8E,$B7
	.db $FF
VRAMStrip37Data:
	.dw $2148
	.db $B7,$9D,$91,$8E,$96,$8E,$00,$98,$8F,$00,$8E,$96,$96,$B5,$9C,$B7
	.db $FF
VRAMStrip38Data:
	.dw $214A
	.db $B7,$8B,$98,$9C,$9C,$00,$A0,$98,$9B,$95,$8D,$B7
	.db $FF
VRAMStrip39Data:
	.dw $2147
	.db $B7,$9D,$91,$8E,$96,$8E,$00,$98,$8F,$00,$A0,$B2,$9B,$95,$98,$8C
	.db $94,$B7
	.db $FF
VRAMStrip3AData:
	.dw $2147
	.db $B7,$96,$98,$97,$9C,$9D,$8E,$9B,$00,$91,$B2,$99,$99,$92,$97,$8E
	.db $9C,$9C,$B7
	.db $FF
VRAMStrip3BData:
	.dw $2148
	.db $B7,$96,$98,$97,$9C,$9D,$8E,$9B,$00,$8B,$98,$98,$90,$92,$8E,$B7
	.db $FF
VRAMStrip3CData:
	.dw $214B
	.db $B7,$92,$B5,$96,$00,$8D,$98,$A0,$97,$B7
	.db $FF
VRAMStrip3DData:
	.dw $2149
	.db $B7,$9C,$9D,$B2,$90,$8E,$00,$8C,$95,$8E,$B2,$9B,$B7
	.db $FF
VRAMStrip3EData:
	.dw $210B
	.db $96,$9E,$9C,$92,$8C,$00,$96,$98,$8D,$8E
	.db $FE
	.dw $228B
	.db $B2,$00,$9C,$98,$9E,$97,$8D,$00,$98,$97
	.db $FE
	.dw $22CB
	.db $8B,$00,$9C,$98,$9E,$97,$8D,$00,$98,$8F,$8F
	.db $FF

;;;;;;;;;;;;;;;;;;;;
;GAME MODE ROUTINES;
;;;;;;;;;;;;;;;;;;;;
;TITLE MODE ROUTINES
RunGameMode_Title:
	;Check for submode $00 (init)
	lda GameSubmode
	beq RunGameMode_Title_JT
	;Check for submode >= $0F (start flash)
	cmp #$0F
	bcs RunGameMode_Title_JT
	;Check for submode >= $0D (main)
	cmp #$0D
	bcs RunGameMode_Title_JT
	;Check for START press
	lda JoypadDown
	and #JOY_START
	beq RunGameMode_Title_JT
	;Init main submode
	jmp TitleMainInit
RunGameMode_Title_JT:
	;Do jump table
	lda GameSubmode
	jsr DoJumpTable
TitleJumpTable:
	.dw RunGameSubmode_TitleInit		;$00  Init
	.dw RunGameSubmode_TitleWait		;$01  Wait
	.dw RunGameSubmode_TitleFadeIn		;$02  Fade in
	.dw RunGameSubmode_TitlePocketBulge	;$03  Pocket bulge
	.dw RunGameSubmode_TitleWait		;$04  Wait
	.dw RunGameSubmode_TitleMonstersOut	;$05  Monsters out
	.dw RunGameSubmode_TitleWait		;$06  Wait
	.dw RunGameSubmode_TitleLogoOut		;$07  Logo out
	.dw RunGameSubmode_TitleWait		;$08  Wait
	.dw RunGameSubmode_TitleScrollDown	;$09  Scroll down
	.dw RunGameSubmode_TitleLogoIn		;$0A  Logo in
	.dw RunGameSubmode_TitleWait		;$0B  Wait
	.dw RunGameSubmode_TitleMonsterPeek	;$0C  Monster peek
	.dw RunGameSubmode_TitleMain		;$0D  Main
	.dw RunGameSubmode_TitleEnd		;$0E  End
	.dw RunGameSubmode_TitleStartFlash	;$0F  Start flash
	.dw RunGameSubmode_TitleMenu		;$10  Menu
	.dw RunGameSubmode_TitleMenuFlash	;$11  Menu flash
	.dw RunGameSubmode_TitleFadeOut		;$12  Fade out

;$00: Init
RunGameSubmode_TitleInit:
	;Next submode ($02: Wait)
	inc GameSubmode
	;Disable IRQ
	jsr DisableIRQ
	;Clear ZP $40-$CF
	jsr ClearZP_40
	;Set vertical mirroring mode
	sta $A000
	;Clear title cursor position
	sta TitleCursorPos
	;Set fade direction
	sta FadeDirection
	sta FadeInitFlag
	;Clear level select index/flag
	sta TitleLevelSelectIndex
	sta TitleLevelSelectFlag
	;Set palette
	lda #$24
	sta CurPalette
	sta FadeTimer
	;Clear sound
	jsr ClearSound
	;Play music
	lda #MUSIC_TITLE
	jsr LoadSound
	;Load CHR banks
	lda #$74
	sta TempCHRBanks
	lda #$76
	sta TempCHRBanks+1
	lda #$74
	sta TempCHRBanks+2
	;Load enemies
	ldx #$02
RunGameSubmode_TitleInit_SpLoop:
	;Load enemy slot
	lda TitlePocketBulgeEnemyX,x
	sta Enemy_X,x
	lda TitlePocketBulgeEnemyY,x
	sta Enemy_Y,x
	lda TitlePocketBulgeEnemyProps,x
	sta Enemy_Props,x
	lda TitlePocketBulgeAnimOffsTable,x
	sta PocketBulgeAnimOffs,x
	lda #$01
	sta PocketBulgeAnimTimer,x
	;Loop for all slots
	dex
	bpl RunGameSubmode_TitleInit_SpLoop
	;Clear palette
	jsr ClearPalette
	;Clear scroll position
	lda TempMirror_PPUCTRL
	and #$FC
	sta TempMirror_PPUCTRL
	;Set timer
	lda #$80
	sta GameModeTimer
	;Write title screen nametable
	ldx #$06
	jmp WriteNametableData

TitlePocketBulgeEnemyX:
	.db $68,$80,$98
TitlePocketBulgeEnemyY:
	.db $8C,$AC,$9C
TitlePocketBulgeAnimTimerTable:
	.db $01,$08,$10
TitlePocketBulgeEnemyProps:
	.db $C0,$00,$40
TitlePocketBulgeAnimOffsTable:
	.db $00,$05,$0A

;$01: Wait
;$04: Wait
;$06: Wait
;$08: Wait
;$0B: Wait
RunGameSubmode_TitleWait:
	;Decrement timer, check if 0
	jsr DecrementModeTimer
	bne RunGameSubmode_TitleWait_Exit
	;Next submode
	inc GameSubmode
RunGameSubmode_TitleWait_Exit:
	rts

;$02: Fade in
RunGameSubmode_TitleFadeIn:
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_TitleWait_Exit
	;Next submode ($03: Pocket bulge)
	inc GameSubmode
	rts

;$03: Pocket bulge
RunGameSubmode_TitlePocketBulge:
	;Do jump table
	lda TitleSubmode
	jsr DoJumpTable
TitlePocketBulgeJumpTable:
	.dw TitlePocketBulgeSub0	;$00  Init
	.dw TitlePocketBulgeSub1	;$01  Wait
	.dw TitlePocketBulgeSub2	;$02  Update
;$00: Init
TitlePocketBulgeSub0:
	;Init loop counter
	lda #$03
	sta TitleCounter
	;Init loop timer
	lda #$20
	sta TitleTimer
	;Set timer
	lda #$80
	sta GameModeTimer
	;Next task ($01: Wait)
	inc TitleSubmode
	rts
;$01: Wait
TitlePocketBulgeSub1:
	;Decrement timer, check if 0
	jsr DecrementModeTimer
	bne TitlePocketBulgeSub1_Exit
	;Next task ($02: Update)
	inc TitleSubmode
TitlePocketBulgeSub1_Exit:
	rts
;$02: Update
TitlePocketBulgeSub2:
	;Decrement timer, check if 0
	dec TitleTimer
	beq TitlePocketBulgeSub2_Next
	;Update enemies
	ldx #$02
TitlePocketBulgeSub2_SpLoop:
	;Decrement animation timer, check if 0
	dec PocketBulgeAnimTimer,x
	bne TitlePocketBulgeSub2_SpNext
	;Decrement animation offset, check if 0
	ldy PocketBulgeAnimOffs,x
	dey
	bpl TitlePocketBulgeSub2_SetOffs
	;Reset animation offset
	ldy #$0C
TitlePocketBulgeSub2_SetOffs:
	;Set animation offset
	sty PocketBulgeAnimOffs,x
	;If animation offset 3, play sound
	cpy #$03
	bne TitlePocketBulgeSub2_NoSound
	;Play sound
	lda #SE_POCKETBULGE
	jsr LoadSound
TitlePocketBulgeSub2_NoSound:
	;Set enemy sprite
	lda TitlePocketBulgeEnemySprite,y
	sta Enemy_Sprite,x
	;Reset animation timer
	lda #$06
	sta PocketBulgeAnimTimer,x
TitlePocketBulgeSub2_SpNext:
	;Loop for all slots
	dex
	bpl TitlePocketBulgeSub2_SpLoop
	rts
TitlePocketBulgeSub2_Next:
	;Decrement counter, check if 0
	dec TitleCounter
	beq TitlePocketBulgeSub2_Next2
	;Set timer
	lda #$40
	sta GameModeTimer
	ldy TitleCounter
	lda TitlePocketBulgeTimerTable,y
	sta TitleTimer
	;Next task ($01: Wait)
	dec TitleSubmode
	rts
TitlePocketBulgeSub2_Next2:
	;Set timer
	lda #$40
	sta GameModeTimer
	;Next task ($00: Init)
	lda #$00
	sta TitleSubmode
	;Reset loop counter
	sta TitleCounter
	;Next submode ($04: Wait)
	inc GameSubmode
	rts

TitlePocketBulgeEnemySprite:
	.db $7F,$80,$81,$80,$00,$00,$00,$00,$00,$00,$00,$00
TitlePocketBulgeTimerTable:
	.db $00,$80,$50

;$05: Monsters out
RunGameSubmode_TitleMonstersOut:
	;Do jump table
	lda TitleSubmode
	jsr DoJumpTable
TitleMonstersOutJumpTable:
	.dw TitleMonstersOutSub0	;$00  Init
	.dw TitleMonstersOutSub1	;$01  Main
;$00: Init
TitleMonstersOutSub0:
	;Init animation offset
	lda #$00
	sta MonstersOutAnimOffs
	lda #$02
	sta MonstersOutAnimOffs+1
	lda #$04
	sta MonstersOutAnimOffs+2
	lda #$06
	sta MonstersOutAnimOffs+3
	;Set timer
	lda #$02
	sta GameModeTimer+1
	;Next task ($01: Main)
	inc TitleSubmode
	;Load palette
	ldx #$10
	lda #$09
	jsr LoadPalette
	jmp WritePalette
;$01: Main
TitleMonstersOutSub1:
	;Decrement timer
	jsr DecrementModeTimer
	;Clear enemies visible flag
	lda #$00
	sta $00
	;Update enemies
	ldx #$03
TitleMonstersOutSub1_SpLoop:
	;If animation offset 0, update enemy
	lda MonstersOutAnimOffs,x
	beq TitleMonstersOutSub1_Update
	;Decrement animation offset
	dec MonstersOutAnimOffs,x
TitleMonstersOutSub1_Exit:
	rts
TitleMonstersOutSub1_Update:
	;If enemy not active yet, load new enemy sprite
	lda Enemy_Sprite+$03,x
	beq TitleMonstersOutSub1_NextSp
	;Apply enemy X velocity
	clc
	lda MonstersOutXVelLo,x
	adc MonstersOutYLo,x
	sta MonstersOutYLo,x
	ldy #$00
	lda MonstersOutXVelHi,x
	bpl TitleMonstersOutSub1_NoXC
	dey
TitleMonstersOutSub1_NoXC:
	adc Enemy_X+$03,x
	sta Enemy_X+$03,x
	;If offscreen horizontally, load new enemy sprite
	tya
	adc #$00
	bne TitleMonstersOutSub1_NextSp
	;Apply enemy Y velocity
	ldy #$00
	lda MonstersOutYVelLo,x
	adc MonstersOutXLo,x
	sta MonstersOutXLo,x
	lda MonstersOutYVelHi,x
	bpl TitleMonstersOutSub1_NoYC
	dey
TitleMonstersOutSub1_NoYC:
	adc Enemy_Y+$03,x
	sta Enemy_Y+$03,x
	;If offscreen vertically, load new enemy sprite
	tya
	adc #$00
	bne TitleMonstersOutSub1_NextSp
	;Accelerate due to gravity
	lda MonstersOutYVelLo,x
	adc #$40
	sta MonstersOutYVelLo,x
	bcc TitleMonstersOutSub1_NoYC2
	inc MonstersOutYVelHi,x
TitleMonstersOutSub1_NoYC2:
	;If enemy Y velocity down, skip this part
	lda MonstersOutYVelHi,x
	bpl TitleMonstersOutSub1_NoFront
	;If enemy Y position >= $40, skip this part
	lda Enemy_Y+$03,x
	cmp #$40
	bcs TitleMonstersOutSub1_NoFront
	;Set enemy priority to be in front of background
	lda Enemy_Props+$03,x
	and #$40
	sta Enemy_Props+$03,x
TitleMonstersOutSub1_NoFront:
	;If enemy active, set enemies visible flag
	lda Enemy_Sprite+$03,x
	ora $00
	sta $00
	;Loop for all slots
	dex
	bpl TitleMonstersOutSub1_SpLoop
	;If timer not 0 or enemies are visible, exit early
	lda GameModeTimer
	ora GameModeTimer+1
	ora $00
	bne TitleMonstersOutSub1_Exit
	;Next task ($00: Init)
	sta TitleSubmode
	;Reset loop counter
	sta TitleCounter
	;Set timer
	lda #$40
	sta GameModeTimer
	;Next submode ($06: Wait)
	inc GameSubmode
	;Load palette
	ldx #$10
	lda #$25
	jsr LoadPalette
	jmp WritePalette
TitleMonstersOutSub1_NextSp:
	;If timer 0, clear enemy sprite
	clc
	lda GameModeTimer
	ora GameModeTimer+1
	beq TitleMonstersOutSub1_SetSprite
	;Increment sprite offset
	lda MonstersOutSpriteOffs,x
	adc #$01
	and #$03
	sta MonstersOutSpriteOffs,x
	txa
	asl
	asl
	ora MonstersOutSpriteOffs,x
	tay
	;If enemy slot 6, don't load CHR bank
	lda TitleMonstersOutEnemyCHRBank,y
	cpx #$03
	beq TitleMonstersOutSub1_NoSetCHRBank
	;Load CHR bank
	sta TempCHRBanks+3,x
TitleMonstersOutSub1_NoSetCHRBank:
	;If enemy slot 4 or 6, don't play sound
	txa
	lsr
	bcs TitleMonstersOutSub1_NoSound
	;Play sound
	lda #SE_MONSTEROUT
	jsr LoadSound
TitleMonstersOutSub1_NoSound:
	;Set enemy position
	lda #$80
	sta Enemy_X+$03,x
	lda #$70
	sta Enemy_Y+$03,x
	;Update PRNG value
	lda PRNGValue
	adc #$D5
	sta PRNGValue
	;Add random offset to enemy velocity
	sta MonstersOutYVelLo,x
	sta MonstersOutXVelLo,x
	and #$03
	clc
	adc #$F7
	sta MonstersOutYVelHi,x
	adc #$07
	sta MonstersOutXVelHi,x
	;Set enemy properties based on if moving left or right
	and #$80
	lsr
	ora #$20
	sta Enemy_Props+$03,x
	;Set enemy sprite
	lda TitleMonstersOutEnemySprite,y
TitleMonstersOutSub1_SetSprite:
	;Set enemy sprite
	sta Enemy_Sprite+$03,x
	bcc TitleMonstersOutSub1_NoFront

TitleMonstersOutEnemyCHRBank:
	.db $25,$2C,$30,$30,$26,$2B,$26,$2B,$27,$27,$27,$27,$27,$27,$27,$27
TitleMonstersOutEnemySprite:
	.db $8B,$8D,$90,$90,$91,$8E,$91,$8E,$8F,$8F,$8F,$8F,$8C,$8C,$8C,$8C

;$07: Logo out
RunGameSubmode_TitleLogoOut:
	;Do jump table
	lda TitleSubmode
	jsr DoJumpTable
TitleLogoOutJumpTable:
	.dw TitleLogoOutSub0	;$00  Init
	.dw TitleLogoOutSub1	;$01  Scroll
	.dw TitleLogoOutSub2	;$02  Shake
;$00: Init
TitleLogoOutSub0:
	;Set Y scroll position
	lda #$A9
	sta TempMirror_PPUCTRL
	lda #$D0
	sta TempMirror_PPUSCROLL_Y
	;Set Y scroll velocity
	lda #$04
	sta LogoScrollYVelHi
	;Next task ($01: Scroll)
	inc TitleSubmode
	;Add IRQ buffer region (title logo)
	lda #$04
	jmp AddIRQBufferRegion
;$01: Scroll
TitleLogoOutSub1:
	;Move logo up
	lda LogoScrollYVelLo
	adc ScrollYPosLo
	sta ScrollYPosLo
	lda LogoScrollYVelHi
	adc TempMirror_PPUSCROLL_Y
	cmp #$F0
	bcc TitleLogoOutSub1_NoYC
	adc #$0F
TitleLogoOutSub1_NoYC:
	sta TempMirror_PPUSCROLL_Y
	;Check if logo is at top
	asl
	bcs TitleLogoOutSub1_Exit
	cmp #$90
	bcc TitleLogoOutSub1_Exit
	;Set timer
	lda #$20
	sta TitleTimer
	;Next task ($02: Shake)
	inc TitleSubmode
TitleLogoOutSub1_Exit:
	rts
;$02: Shake
TitleLogoOutSub2:
	;Set scroll Y position to shake up/down
	lda #$02
	eor TempMirror_PPUSCROLL_Y
	sta TempMirror_PPUSCROLL_Y
	;Decrement counter, check if 0
	dec TitleTimer
	bne TitleLogoOutSub1_Exit
	;Add IRQ buffer region (title pocket)
	lda #$05
	jsr AddIRQBufferRegion
	;Next task ($00: Init)
	lda #$00
	sta TitleSubmode
	;Set timer
	lda #$10
	sta GameModeTimer
	;Next submode ($08: Wait)
	inc GameSubmode
	rts

;$09: Scroll down
RunGameSubmode_TitleScrollDown:
	;Move logo down $04
	clc
	lda TempIRQBufferHeight
	adc #$04
	sta TempIRQBufferHeight
	lda TempIRQBufferHeight+1
	sbc #$03
	sta TempIRQBufferHeight+1
	lda TempMirror_PPUSCROLL_Y
	sbc #$04
	sta TempMirror_PPUSCROLL_Y
	;Check if logo is at bottom
	bne RunGameSubmode_TitleScrollDown_Exit
	;Set timer
	lda #$80
	sta GameModeTimer
	;Next submode ($0A: Logo in)
	inc GameSubmode
RunGameSubmode_TitleScrollDown_Exit:
	rts

;$0A: Logo in
RunGameSubmode_TitleLogoIn:
	;Decrement counter, check if 0
	jsr DecrementModeTimer
	beq RunGameSubmode_TitleLogoIn_Next
	;If timer $70, load fade palette index $00
	ldy #$00
	lda GameModeTimer
	cmp #$70
	beq RunGameSubmode_TitleLogoIn_SetPal
	;If timer $60, load fade palette index $03
	ldy #$03
	cmp #$60
	beq RunGameSubmode_TitleLogoIn_SetPal
	;If timer $50, write VRAM strip and load fade palette index $06
	cmp #$50
	bne RunGameSubmode_TitleScrollDown_Exit
	;Write VRAM strip ("PRESS START" text)
	lda #$13
	jsr WriteVRAMStrip
	ldy #$06
RunGameSubmode_TitleLogoIn_SetPal:
	;Load fade palette data
	lda TitleLogoPaletteData,y
	sta PaletteBuffer+$0D
	lda TitleLogoPaletteData+1,y
	sta PaletteBuffer+$0E
	lda TitleLogoPaletteData+2,y
	sta PaletteBuffer+$0F
	;Write palette
	jmp WritePalette
RunGameSubmode_TitleLogoIn_Next:
	;Set timer
	lda #$20
	sta GameModeTimer
	;Next submode ($0B: Wait)
	inc GameSubmode
	rts

TitleLogoPaletteData:
	.db $06,$07,$00
	.db $16,$17,$10
	.db $16,$27,$10

;$0C: Monster peek
RunGameSubmode_TitleMonsterPeek:
	;Do jump table
	lda TitleSubmode
	jsr DoJumpTable
TitleMonsterPeekJumpTable:
	.dw TitleMonsterPeekSub0	;$00  Init
	.dw TitleMonsterPeekSub1	;$01  Wait
	.dw TitleMonsterPeekSub2	;$02  Left hand
	.dw TitleMonsterPeekSub3	;$03  Right hand
	.dw TitleMonsterPeekSub4	;$04  Eyes
;$00: Init
TitleMonsterPeekSub0:
	;Set timer
	lda #$10
	sta GameModeTimer
	;Next task ($01: Wait)
	inc TitleSubmode
TitleMonsterPeekSub0_Exit:
	rts
;$01: Wait
TitleMonsterPeekSub1:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne TitleMonsterPeekSub0_Exit
	;Next task ($02: Left hand)
	inc TitleSubmode
	;Set timer
	lda #$10
	sta GameModeTimer
	;Init enemy
	lda #$64
	sta Enemy_X+$01
	lda #$A9
	sta Enemy_Y+$01
	lda #$82
	sta Enemy_Sprite+$01
	;Write VRAM strip (left hand shadow)
	lda #$16
	jmp WriteVRAMStrip
;$02: Left hand
TitleMonsterPeekSub2:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne TitleMonsterPeekSub0_Exit
	;Next task ($03: Right hand)
	inc TitleSubmode
	;Set timer
	lda #$10
	sta GameModeTimer
	;Init enemy
	lda #$9C
	sta Enemy_X+$02
	lda #$A9
	sta Enemy_Y+$02
	lda #$40
	sta Enemy_Props+$02
	lda #$82
	sta Enemy_Sprite+$02
	;Write VRAM strip (right hand shadow)
	lda #$17
	jmp WriteVRAMStrip
;$03: Right hand
TitleMonsterPeekSub3:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne TitleMonsterPeekSub0_Exit
	;Init enemy
	lda #$A1
	sta Enemy_Y
	lda #$80
	sta Enemy_X
	lda #$83
	sta Enemy_Sprite
	lda #$00
	sta Enemy_Props
	;Set timer
	lda #$08
	sta GameModeTimer
	;Next task ($04: Eyes)
	inc TitleSubmode
	rts
;$04: Eyes
TitleMonsterPeekSub4:
	;Decrement timer, check if 0
	dec GameModeTimer
	bne TitleMonsterPeekSub0_Exit
	;Increment enemy sprite
	inc Enemy_Sprite
	;Next submode ($0D: Main)
	inc GameSubmode
	;Clear task
	lda #$00
	sta TitleSubmode
	;Set timer
	ldy #$05
	jmp SetModeTimer_Any

;$0D: Main
RunGameSubmode_TitleMain:
	;Check for START press
	lda JoypadDown
	and #JOY_START
	beq RunGameSubmode_TitleMain_NoStart
	;Next submode ($0F: Start flash)
	lda #$0F
	sta GameSubmode
	;Set enemy sprite
	lda #$84
	sta Enemy_Sprite
	;Set timer
	lda #$80
	sta GameModeTimer
	;Play sound
	lda #SE_SELECT
	jmp LoadSound
RunGameSubmode_TitleMain_NoStart:
	;Decrement timer, check if 0
	jsr DecrementModeTimer
	beq RunGameSubmode_TitleMain_End
	;Check for blink mode
	lda GameModeTimer
	ldy MonsterPeekAnimOffs
	bne RunGameSubmode_TitleMain_Blink
	;If bits 0-4 of global timer 0, exit early
	and #$1F
	bne RunGameSubmode_TitleMain_Exit
	;Get new animation offset based on random value
	lda PRNGValue
	and #$07
	;If new animation offset = previous animation offset, increment
	cmp TitleSubmode
	bne RunGameSubmode_TitleMain_New
	adc #$01
RunGameSubmode_TitleMain_New:
	;If animation offset 0, set blink mode
	tay
	bne RunGameSubmode_TitleMain_LookSet
	;Set blink mode
	inc MonsterPeekAnimOffs
RunGameSubmode_TitleMain_LookSet:
	;Set previous animation offset
	sta TitleSubmode
	;Set enemy sprite
	lda TitleMonsterLookEnemySprite,y
	sta Enemy_Sprite
RunGameSubmode_TitleMain_Exit:
	rts
RunGameSubmode_TitleMain_Blink:
	;If bits 0-1 of global timer 0, exit early
	and #$03
	bne RunGameSubmode_TitleMain_Exit
	;Increment animation offset
	inc MonsterPeekAnimOffs
	ldy MonsterPeekAnimOffs
	cpy #$07
	bcc RunGameSubmode_TitleMain_BlinkSet
	;Clear animation offset
	lda #$00
	sta MonsterPeekAnimOffs
	rts
RunGameSubmode_TitleMain_BlinkSet:
	;Set enemy sprite
	lda TitleMonsterBlinkEnemySprite,y
	sta Enemy_Sprite
	rts
RunGameSubmode_TitleMain_End:
	lda #$84
	sta Enemy_Sprite
	;Next submode ($0E: End)
	inc GameSubmode

;$0E: End
RunGameSubmode_TitleEnd:
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_TitleMain_Exit
	;Clear IRQ buffer
	jsr ClearIRQBuffer
	;Clear nametable
	jsr ClearNametableData
	;Next mode ($02: Demo)
	jmp GoToNextGameMode

;$0F: Start flash
RunGameSubmode_TitleStartFlash:
	;Write/clear VRAM strip based on bit 3 of timer
	lda GameModeTimer
	and #$08
	asl
	asl
	asl
	asl
	adc #$13
	jsr WriteVRAMStrip
	;Decrement timer, check if 0
	dec GameModeTimer
	bne RunGameSubmode_TitleMain_Exit
	;Next submode ($10: Menu)
	inc GameSubmode
	;Clear VRAM strip ("PRESS START" text)
	lda #$93
	jsr WriteVRAMStrip
	;Write VRAM strip ("1 PLAYER" text)
	lda #$14
	jsr WriteVRAMStrip
	;Write VRAM strip ("2 PLAYER" text)
	lda #$15
	jmp WriteVRAMStrip

;$10: Menu
RunGameSubmode_TitleMenu:
	;Set enemy position/sprite
	ldx TitleCursorPos
	lda #$50
	sta Enemy_X+$03
	lda #$02
	sta Enemy_Sprite+$03
	lda TitleCursorEnemyY,x
	sta Enemy_Y+$03
	;Check for SELECT press
	lda JoypadDown
	and #JOY_SELECT
	beq RunGameSubmode_TitleMenu_NoSelect
	;Toggle title screen cursor position
	txa
	eor #$01
	sta TitleCursorPos
	;Play sound
	lda #SE_CURSMOVE
	jmp LoadSound
RunGameSubmode_TitleMenu_NoSelect:
	;Skip level select check
	jmp RunGameSubmode_TitleMenu_NoLevelSelect
RunGameSubmode_TitleMenu_CheckLevelSelect:
	;If level select flag already set, skip this part
	lda TitleLevelSelectFlag
	bne RunGameSubmode_TitleMenu_NoLevelSelect
	;If no buttons pressed, exit early
	lda JoypadDown
	beq RunGameSubmode_TitleMenuFlash_Exit
	;Check for correct button press
	ldy TitleLevelSelectIndex
	cmp TitleLevelSelectPasswordData,y
	beq RunGameSubmode_TitleMenu_NextIdx
	;Clear level select index
	ldy #$00
	beq RunGameSubmode_TitleMenu_SetIdx
RunGameSubmode_TitleMenu_NextIdx:
	;Increment level select index
	iny
	;Check if entire password has been entered
	cpy #$06
	bne RunGameSubmode_TitleMenu_SetIdx
	;Set level select flag
	dec TitleLevelSelectFlag
	;Play sound
	lda #SE_STAGECLEAR1UP
	jsr LoadSound
RunGameSubmode_TitleMenu_SetIdx:
	;Set level select index
	sty TitleLevelSelectIndex
RunGameSubmode_TitleMenu_NoLevelSelect:
	;Check for START press
	lda JoypadDown
	and #JOY_START
	beq RunGameSubmode_TitleMenuFlash_Exit
	;Set timer
	lda #$80
	sta GameModeTimer
	;Next submode ($11: Menu flash)
	inc GameSubmode
	;Play sound
	lda #SE_SELECT
	jmp LoadSound

;$11: Menu flash
RunGameSubmode_TitleMenuFlash:
	;Write/clear VRAM strip based on bit 3 of timer
	lda GameModeTimer
	and #$08
	asl
	asl
	asl
	asl
	ora TitleCursorPos
	adc #$14
	jsr WriteVRAMStrip
	;Decrement timer, check if 0
	dec GameModeTimer
	bne RunGameSubmode_TitleMenuFlash_Exit
	;Next submode ($12: Fade out)
	inc GameSubmode
RunGameSubmode_TitleMenuFlash_Exit:
	rts

;$12: Fade out
RunGameSubmode_TitleFadeOut:
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_TitleMenuFlash_Exit
	;Next mode ($03: Select)
	lda #$03
	jmp SetGameMode

TitleMonsterLookEnemySprite:
	.db $84,$84,$85,$86,$87,$88,$89,$8A
TitleMonsterBlinkEnemySprite:
	.db $89,$88,$83,$00,$83,$84,$84
TitleCursorEnemyY:
	.db $83,$93
TitleLevelSelectPasswordData:
	.db $01,$02,$04,$08,$80,$40

TitleMainInit:
	;Clear sound
	jsr ClearSound
	;Clear ZP $70-$CF
	jsr ClearZP_70
	;Clear Y scroll position
	sta TempMirror_PPUSCROLL_Y
	;Set timer
	tax
	ldy #$05
	jsr SetModeTimer_Any
	;Load palette
	lda #$24
	jsr LoadPalette
	lda #$25
	jsr LoadPalette
	lda #$16
	sta PaletteBuffer+$0D
	lda #$27
	sta PaletteBuffer+$0E
	lda #$10
	sta PaletteBuffer+$0F
	jsr WritePalette
	;Init IRQ buffer
	lda #$A9
	sta TempIRQBufferHeight
	lda #$37
	sta TempIRQBufferHeight+1
	ldx #$04
	stx TempIRQBufferSub
	inx
	stx TempIRQBufferSub+1
	lda #$01
	sta TempIRQEnableFlag
	;Next submode ($0D: Main)
	lda #$0D
	sta GameSubmode
	;Load enemies
	lda #$64
	sta Enemy_X+$01
	lda #$9C
	sta Enemy_X+$02
	lda #$A9
	sta Enemy_Y+$01
	sta Enemy_Y+$02
	lda #$82
	sta Enemy_Sprite+$01
	sta Enemy_Sprite+$02
	lda #$40
	sta Enemy_Props+$02
	lda #$A1
	sta Enemy_Y
	lda #$84
	sta Enemy_Sprite
	lda #$80
	sta Enemy_X
	;Set scroll position
	lda #$A9
	sta TempMirror_PPUCTRL
	;Write VRAM strip ("PRESS START" text)
	lda #$13
	jsr WriteVRAMStrip
	;Write VRAM strip (left hand shadow)
	lda #$16
	jsr WriteVRAMStrip
	;Write VRAM strip (right hand shadow)
	lda #$17
	jmp WriteVRAMStrip

;;;;;;;;;;;;;;;
;DEMO ROUTINES;
;;;;;;;;;;;;;;;
UpdateDemoInputSub:
	;If demo data index 0, don't check timer
	ldy DemoIndex
	beq UpdateDemoInputSub_Next
	;Check for joypad down bits
	lda DemoTimer
	bne UpdateDemoInputSub_NoNext
UpdateDemoInputSub_Next:
	;Get next timer value
	lda DemoData+1,y
	sta DemoTimer
	;Check for end of demo
	cmp #$FF
	beq UpdateDemoInputSub_End
	;Increment demo data index
	iny
	iny
	sty DemoIndex
	;Set joypad down bits
	lda DemoData-2,y
	jmp UpdateDemoInputSub_SetDown
UpdateDemoInputSub_NoNext:
	;Clear joypad down bits
	lda #$00
UpdateDemoInputSub_SetDown:
	;Set joypad down bits
	sta JoypadDown
	;Set joypad current bits
	lda DemoData-2,y
	sta JoypadCur
	;Clear player 2 joypad bits
	lda #$00
	sta JoypadCur+1
	sta JoypadDown+1
	;Decrement demo input timer
	dec DemoTimer
	rts
UpdateDemoInputSub_End:
	;Set demo end flag
	inc DemoEndFlag
	rts

;DEMO DATA
DemoData:
	.db $00,$11,$01,$4C,$41,$03,$40,$09,$00,$07,$01,$0F,$00,$01,$40,$0A
	.db $00,$0A,$01,$10,$41,$01,$40,$09,$00,$06,$01,$65,$41,$09,$01,$3B
	.db $41,$0B,$01,$36,$41,$06,$40,$05,$00,$10,$02,$14,$42,$03,$40,$0A
	.db $00,$0A,$01,$12,$41,$01,$40,$0A,$00,$09,$01,$06,$81,$0A,$00,$07
	.db $81,$0D,$01,$05,$00,$0C,$02,$05,$00,$04,$40,$0A,$00,$1B,$80,$08
	.db $00,$07,$80,$0F,$00,$16,$01,$20,$00,$09,$04,$0E,$44,$0A,$04,$04
	.db $00,$0F,$80,$08,$00,$06,$40,$08,$00,$3D,$01,$0E,$00,$0C,$80,$0E
	.db $00,$07,$80,$0A,$00,$07,$40,$0A,$00,$16,$02,$07,$00,$08,$40,$0B
	.db $00,$11,$01,$09,$81,$09,$01,$06,$81,$08,$01,$32,$81,$08,$01,$0B
	.db $81,$0C,$01,$58,$41,$0B,$01,$2F,$41,$0B,$01,$2C,$41,$0A,$01,$B5
	.db $81,$09,$01,$0A,$81,$09,$01,$25,$81,$08,$01,$06,$81,$28,$01,$8E
	.db $00,$09,$02,$0D,$40,$0B,$00,$11,$40,$09,$00,$1A,$40,$0A,$00,$16
	.db $02,$03,$42,$02,$40,$08,$00,$18,$01,$29,$41,$03,$40,$08,$00,$18
	.db $01,$41,$81,$08,$01,$BD,$00,$32,$01,$1C,$41,$02,$40,$0A,$00,$0C
	.db $01,$1D,$41,$09,$01,$0E,$00,$02,$40,$0B,$00,$0F,$02,$07,$00,$02
	.db $40,$0D,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

;;;;;;;;;;;;;;;;
;NAMETABLE DATA;
;;;;;;;;;;;;;;;;
Nametable06Data:
	.dw $2000
	.db $7E,$00,$7E,$00,$7E,$00,$0E,$00,$C3,$C1,$0B,$C3,$82,$CD,$CE,$10
	.db $00,$C3,$C4,$0B,$C6,$82,$CF,$D0,$10,$00,$C3,$C7,$0B,$C9,$82,$D1
	.db $D2,$10,$00,$C3,$CA,$0B,$CC,$82,$D3,$D4,$10,$00,$82,$C4,$D5,$0C
	.db $C6,$82,$DF,$D0,$10,$00,$C3,$C4,$0B,$C6,$82,$CF,$D0,$10,$00,$C3
	.db $C4,$0B,$C6,$82,$CF,$D0,$10,$00,$C3,$C4,$0B,$C6,$82,$DF,$D0,$10
	.db $00,$82,$C4,$D5,$0C,$C6,$82,$DF,$D0,$10,$00,$C3,$C4,$0B,$C6,$82
	.db $CF,$D0,$10,$00,$83,$C4,$D6,$D7,$0A,$C6,$83,$D7,$E0,$D0,$10,$00
	.db $C4,$D8,$81,$DB,$06,$D7,$85,$DB,$DB,$DA,$E1,$E2,$10,$00,$C3,$DC
	.db $81,$D9,$08,$DA,$81,$E1,$C3,$E3,$12,$00,$C3,$DC,$81,$D9,$04,$DA
	.db $81,$E1,$C3,$E3,$16,$00,$C3,$DC,$82,$D9,$E1,$C3,$E3,$1A,$00,$84
	.db $DC,$DD,$E4,$E5,$4E,$00,$1A,$00,$04,$55,$04,$00,$04,$55,$04,$00
	.db $04,$55,$04,$00,$04,$55,$0A,$00,$7E,$00,$0C,$00,$C6,$EC,$C5,$67
	.db $14,$00,$C7,$F2,$C6,$6C,$13,$00,$82,$F9,$FA,$41,$00,$C4,$FB,$C4
	.db $72,$16,$00,$82,$FB,$FF,$C4,$40,$C6,$76,$13,$00,$C7,$44,$C7,$7C
	.db $11,$00,$C8,$4B,$C8,$83,$10,$00,$C6,$53,$85,$00,$59,$8B,$00,$00
	.db $C5,$8C,$11,$00,$C7,$5A,$C7,$91,$13,$00,$C6,$61,$C7,$98,$7E,$00
	.db $7E,$00,$7E,$00,$6F,$00,$0A,$00,$04,$FF,$14,$00,$04,$AA,$1A,$00
	.db $00

;UNUSED SPACE
	;$01 bytes of free space available
	;.db $FF

	.org $C000
