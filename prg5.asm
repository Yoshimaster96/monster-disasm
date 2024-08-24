	.base $8000
	.org $8000
;BANK NUMBER
	.db $3A

;;;;;;;;;;;;;;;;;;;;;;;;;
;SPRITE DRAWING ROUTINES;
;;;;;;;;;;;;;;;;;;;;;;;;;
	nop
	nop
	nop
DrawEnemySprites:
	;Update OAM buffer start offset
	lda OAMBufferOffset
	clc
	adc #$4C
	sta OAMBufferOffset
	sta $06
	;Get OAM buffer end offset
	sec
	sbc #$C4
	tay
	sty $07
	lda #$00
	sta OAMBuffer+1,y
	;Update enemy start index
	lda EnemyOAMStartIndex
	clc
	adc #$0D
	and #$1F
	sta EnemyOAMStartIndex
	tax
DrawEnemySprites_Loop:
	;If no sprite, go to next enemy
	lda Enemy_Sprite,x
	beq DrawEnemySprites_Next
	;Save X register
	stx $17
	;Draw sprite
	ldy Enemy_X,x
	sty $10
	ldy Enemy_Y,x
	sty $11
	ldy Enemy_Props,x
	sty $12
	ldy Enemy_XHi,x
	sty $13
	ldy Enemy_YHi,x
	sty $14
	jsr DrawSprite
	;Restore X register
	ldx $17
DrawEnemySprites_Next:
	;Loop for each enemy
	dex
	bpl DrawEnemySprites_NoC
	ldx #$1F
DrawEnemySprites_NoC:
	cpx EnemyOAMStartIndex
	bne DrawEnemySprites_Loop
	;Check for OAM buffer overflow
	ldy $07
	lda OAMBuffer+1,y
	bne DrawEnemySprites_Exit
	;Fill rest of OAM buffer $F4
	ldx $06
DrawEnemySprites_EndLoop:
	lda #$F4
	sta OAMBuffer,x
	txa
	clc
	adc #$C4
	tax
	cpx OAMBufferOffset
	bne DrawEnemySprites_EndLoop
DrawEnemySprites_Exit:
	rts

DrawSprite:
	;Check for player object
	cpx #$0A
	bcc DrawSprite_Player
	;Check for boss mode
	asl
	tay
	bit SpriteBossModeFlag
	bmi DrawSprite_Boss
	;Check for enemy sprites $80-$FF
	bcs DrawSprite_Enemy80
	;Handle enemy sprites $00-$7F
	lda SpriteDataEnemyPointerTable-2,y
	sta $08
	lda SpriteDataEnemyPointerTable-2+1,y
	jmp DrawSprite_Draw
DrawSprite_Enemy80:
	;Handle enemy sprites $80-$FF
	lda SpriteDataEnemyPointerTable+$100-2,y
	sta $08
	lda SpriteDataEnemyPointerTable+$100-2+1,y
	jmp DrawSprite_Draw
DrawSprite_Boss:
	;Handle boss sprites
	lda SpriteDataBossPointerTable-2,y
	sta $08
	lda SpriteDataBossPointerTable-2+1,y
	jmp DrawSprite_Draw
DrawSprite_Player:
	;Check for player sprites $00-$7F
	asl
	tay
	bcc DrawSprite_Player00
	;Handle player sprites $80-$FF
	lda SpriteDataPlayerPointerTable+$100-2,y
	sta $08
	lda SpriteDataPlayerPointerTable+$100-2+1,y
	jmp DrawSprite_Draw
DrawSprite_Player00:
	;Handle player sprites $00-$7F
	lda SpriteDataPlayerPointerTable-2,y
	sta $08
	lda SpriteDataPlayerPointerTable-2+1,y
DrawSprite_Draw:
	sta $09
	;Get number of OAM entries used
	ldy #$00
	lda ($08),y
	beq DrawEnemySprites_Exit
	asl
	asl
	tay
	ldx $06
DrawSprite_Loop:
	;Get OAM X position
	lda ($08),y
	sta $00
	dey
	;Set OAM attribute
	lda ($08),y
	sta $01
	dey
	and #$03
	ora $12
	sta $02
	lda $01
	and #$C0
	eor $02
	sta OAMBuffer+2,x
	;Check to flip OAM sprite X
	lda $00
	bit $12
	bvc DrawSprite_NoFlipX
	eor #$FF
	clc
	adc #$F9
DrawSprite_NoFlipX:
	sta $00
	;Set OAM X position
	clc
	adc $10
	sta OAMBuffer+3,x
	;Check if OAM X position is offscreen
	lda #$00
	bit $00
	bpl DrawSprite_NoXC
	lda #$FF
DrawSprite_NoXC:
	adc $13
	beq DrawSprite_CheckY
	dey
DrawSprite_OffScreen:
	;Set OAM Y position offscreen
	lda #$00
	sta OAMBuffer,x
	dey
	bne DrawSprite_Loop
DrawSprite_End:
	;Save OAM buffer offset and exit
	stx $06
	rts
DrawSprite_CheckY:
	;Set OAM tile
	lda ($08),y
	sta OAMBuffer+1,x
	dey
	;Get OAM Y position
	lda ($08),y
	;Check to flip OAM sprite Y
	bit $12
	bpl DrawSprite_NoFlipY
	eor #$FF
	clc
	adc #$F1
DrawSprite_NoFlipY:
	;Check for OAM Y position $80-$FF
	asl
	bcs DrawSprite_Y80
	;Set OAM Y position ($00-$7F)
	ror
	adc $11
	bcs DrawSprite_NoY00C
	cmp #$F0
	bcc DrawSprite_NoY00C2
DrawSprite_NoY00C:
	adc #$0F
	sec
DrawSprite_NoY00C2:
	sta OAMBuffer,x
	;Check if OAM Y position is offscreen ($00-$7F)
	lda #$00
	adc $14
	bne DrawSprite_OffScreen
	;Check if OAM Y position is offscreen
	beq DrawSprite_Next
DrawSprite_Y80:
	;Set OAM Y position ($80-$FF)
	ror
	eor #$FF
	adc #$01
	sta $01
	lda $11
	sec
	sbc $01
	bcs DrawSprite_NoY80C
	sbc #$0F
	clc
DrawSprite_NoY80C:
	sta OAMBuffer,x
	;Check if OAM Y position is offscreen ($80-$FF)
	lda $14
	sbc #$00
	bne DrawSprite_OffScreen
DrawSprite_Next:
	;Check if OAM Y position is offscreen
	lda OAMBuffer,x
	cmp #$CC
	bcs DrawSprite_OffScreen
	;Loop for each entry
	txa
	adc #$C4
	;Check for OAM buffer overflow
	cmp OAMBufferOffset
	beq DrawSprite_Over
	tax
	dey
	beq DrawSprite_End
	jmp DrawSprite_Loop
DrawSprite_Over:
	ldx EnemyOAMStartIndex
	inx
	stx $17
	rts

;;;;;;;;;;;;;
;SPRITE DATA;
;;;;;;;;;;;;;
SpriteDataPlayerPointerTable:
	.dw SpritePlayer01Data	;$01  Item screw
	.dw SpritePlayer02Data	;$02  Title screen cursor
	.dw SpritePlayer03Data	;$03  Item key
	.dw SpritePlayer04Data	;$04 \Vampire walking
	.dw SpritePlayer05Data	;$05 |
	.dw SpritePlayer06Data	;$06 |
	.dw SpritePlayer07Data	;$07 |
	.dw SpritePlayer08Data	;$08 |
	.dw SpritePlayer09Data	;$09 |
	.dw SpritePlayer0AData	;$0A |
	.dw SpritePlayer0BData	;$0B |
	.dw SpritePlayer0CData	;$0C /
	.dw SpritePlayer0DData	;$0D \Vampire stopping
	.dw SpritePlayer0EData	;$0E |
	.dw SpritePlayer0FData	;$0F /
	.dw SpritePlayer10Data	;$10  Vampire idle
	.dw SpritePlayer11Data	;$11 \Vampire ducking
	.dw SpritePlayer12Data	;$12 |
	.dw SpritePlayer13Data	;$13 /
	.dw SpritePlayer14Data	;$14 \Vampire jumping
	.dw SpritePlayer15Data	;$15 |
	.dw SpritePlayer16Data	;$16 |
	.dw SpritePlayer17Data	;$17 |
	.dw SpritePlayer18Data	;$18 /
	.dw SpritePlayer19Data	;$19  Vampire hit
	.dw SpritePlayer1AData	;$1A \Vampire death
	.dw SpritePlayer1BData	;$1B |
	.dw SpritePlayer1CData	;$1C |
	.dw SpritePlayer1DData	;$1D |
	.dw SpritePlayer1EData	;$1E |
	.dw SpritePlayer1FData	;$1F /
	.dw SpritePlayer20Data	;$20 \Vampire attacking
	.dw SpritePlayer21Data	;$21 /
	.dw SpritePlayer22Data	;$22 \Vampire duck attacking
	.dw SpritePlayer23Data	;$23 |
	.dw SpritePlayer24Data	;$24 /
	.dw SpritePlayer25Data	;$25 \Vampire walking with key
	.dw SpritePlayer26Data	;$26 |
	.dw SpritePlayer27Data	;$27 |
	.dw SpritePlayer28Data	;$28 |
	.dw SpritePlayer29Data	;$29 |
	.dw SpritePlayer2AData	;$2A |
	.dw SpritePlayer2BData	;$2B |
	.dw SpritePlayer2CData	;$2C |
	.dw SpritePlayer2DData	;$2D /
	.dw SpritePlayer2EData	;$2E \Vampire stopping with key
	.dw SpritePlayer2FData	;$2F |
	.dw SpritePlayer30Data	;$30 /
	.dw SpritePlayer31Data	;$31  Vampire idle with key
	.dw SpritePlayer32Data	;$32 \Vampire ducking with key
	.dw SpritePlayer33Data	;$33 |
	.dw SpritePlayer34Data	;$34 /
	.dw SpritePlayer35Data	;$35 \Vampire jumping with key
	.dw SpritePlayer36Data	;$36 |
	.dw SpritePlayer37Data	;$37 |
	.dw SpritePlayer38Data	;$38 |
	.dw SpritePlayer39Data	;$39 /
	.dw SpritePlayer3AData	;$3A \Vampire throwing key
	.dw SpritePlayer3BData	;$3B /
	.dw SpritePlayer3CData	;$3C \Vampire duck throwing key
	.dw SpritePlayer3DData	;$3D /
	.dw SpritePlayer3EData	;$3E  UNUSED
	.dw SpritePlayer3FData	;$3F  UNUSED
	.dw SpritePlayer40Data	;$40  UNUSED
	.dw SpritePlayer41Data	;$41  UNUSED
	.dw SpritePlayer42Data	;$42 \Vampire fire
	.dw SpritePlayer43Data	;$43 |
	.dw SpritePlayer44Data	;$44 |
	.dw SpritePlayer45Data	;$45 |
	.dw SpritePlayer46Data	;$46 /
	.dw SpritePlayer47Data	;$47  Monster idle
	.dw SpritePlayer48Data	;$48 \Monster ducking
	.dw SpritePlayer49Data	;$49 /
	.dw SpritePlayer4AData	;$4A  Monster hit
	.dw SpritePlayer4BData	;$4B \Monster death
	.dw SpritePlayer4CData	;$4C |
	.dw SpritePlayer4DData	;$4D |
	.dw SpritePlayer4EData	;$4E |
	.dw SpritePlayer4FData	;$4F /
	.dw SpritePlayer50Data	;$50 \Monster jumping
	.dw SpritePlayer51Data	;$51 |
	.dw SpritePlayer52Data	;$52 |
	.dw SpritePlayer53Data	;$53 |
	.dw SpritePlayer54Data	;$54 /
	.dw SpritePlayer55Data	;$55 \Monster walking
	.dw SpritePlayer56Data	;$56 |
	.dw SpritePlayer57Data	;$57 |
	.dw SpritePlayer58Data	;$58 |
	.dw SpritePlayer59Data	;$59 |
	.dw SpritePlayer5AData	;$5A |
	.dw SpritePlayer5BData	;$5B |
	.dw SpritePlayer5CData	;$5C |
	.dw SpritePlayer5DData	;$5D /
	.dw SpritePlayer5EData	;$5E \Monster attacking
	.dw SpritePlayer5FData	;$5F |
	.dw SpritePlayer60Data	;$60 /
	.dw SpritePlayer61Data	;$61 \Monster duck attacking
	.dw SpritePlayer62Data	;$62 |
	.dw SpritePlayer63Data	;$63 /
	.dw SpritePlayer64Data	;$64  Monster idle with key
	.dw SpritePlayer65Data	;$65 \Monster ducking with key
	.dw SpritePlayer66Data	;$66 /
	.dw SpritePlayer67Data	;$67 \Monster jumping with key
	.dw SpritePlayer68Data	;$68 |
	.dw SpritePlayer69Data	;$69 |
	.dw SpritePlayer6AData	;$6A |
	.dw SpritePlayer6BData	;$6B /
	.dw SpritePlayer6CData	;$6C \Monster walking with key
	.dw SpritePlayer6DData	;$6D |
	.dw SpritePlayer6EData	;$6E |
	.dw SpritePlayer6FData	;$6F |
	.dw SpritePlayer70Data	;$70 |
	.dw SpritePlayer71Data	;$71 |
	.dw SpritePlayer72Data	;$72 |
	.dw SpritePlayer73Data	;$73 |
	.dw SpritePlayer74Data	;$74 /
	.dw SpritePlayer75Data	;$75  Monster stopping with key
	.dw SpritePlayer76Data	;$76 \Monster throwing key
	.dw SpritePlayer77Data	;$77 /
	.dw SpritePlayer78Data	;$78 \Monster duck throwing key
	.dw SpritePlayer79Data	;$79 /
	.dw SpritePlayer7AData	;$7A \Monster fire
	.dw SpritePlayer7BData	;$7B |
	.dw SpritePlayer7CData	;$7C |
	.dw SpritePlayer7DData	;$7D |
	.dw SpritePlayer7EData	;$7E /
	.dw SpritePlayer7FData	;$7F \Title screen pocket bulge
	.dw SpritePlayer80Data	;$80 |
	.dw SpritePlayer81Data	;$81 /
	.dw SpritePlayer82Data	;$82  Title screen pocket monster hands
	.dw SpritePlayer83Data	;$83 \Title screen pocket monster eyes
	.dw SpritePlayer84Data	;$84 |
	.dw SpritePlayer85Data	;$85 |
	.dw SpritePlayer86Data	;$86 |
	.dw SpritePlayer87Data	;$87 |
	.dw SpritePlayer88Data	;$88 |
	.dw SpritePlayer89Data	;$89 |
	.dw SpritePlayer8AData	;$8A /
	.dw SpritePlayer8BData	;$8B \Title screen pocket enemies
	.dw SpritePlayer8CData	;$8C |
	.dw SpritePlayer8DData	;$8D |
	.dw SpritePlayer8EData	;$8E |
	.dw SpritePlayer8FData	;$8F |
	.dw SpritePlayer90Data	;$90 |
	.dw SpritePlayer91Data	;$91 /
	.dw SpritePlayer92Data	;$92 \Player select vampire eye
	.dw SpritePlayer93Data	;$93 |
	.dw SpritePlayer94Data	;$94 |
	.dw SpritePlayer95Data	;$95 /
	.dw SpritePlayer96Data	;$96 \Player select monster eye
	.dw SpritePlayer97Data	;$97 |
	.dw SpritePlayer98Data	;$98 /
	.dw SpritePlayer99Data	;$99  Player select vampire fang
	.dw SpritePlayer9AData	;$9A  Intro/ending vampire sitting
	.dw SpritePlayer9BData	;$9B \Intro/ending vampire standing
	.dw SpritePlayer9CData	;$9C |
	.dw SpritePlayer9DData	;$9D /
	.dw SpritePlayer9EData	;$9E  Intro/ending monster sitting
	.dw SpritePlayer9FData	;$9F  Intro/ending monster standing

;Unreferenced sprite data???
	.db $00
	.db $02
	.db $F8,$05,$00,$F8
	.db $F8,$07,$00,$00
;Title screen cursor
SpritePlayer02Data:
	.db $02
	.db $F8,$2B,$02,$F8
	.db $F8,$2D,$02,$00
;Item key
SpritePlayer03Data:
	.db $05
	.db $F8,$71,$02,$F4
	.db $F8,$6F,$02,$EC
	.db $F4,$73,$02,$FC
	.db $F4,$75,$02,$04
	.db $F4,$77,$02,$0C
;Item screw
SpritePlayer01Data:
	.db $05
	.db $F5,$77,$02,$0C
	.db $F8,$6F,$02,$EC
	.db $F6,$71,$02,$F4
	.db $F5,$73,$02,$FC
	.db $F5,$75,$02,$04
;Vampire walking
SpritePlayer04Data:
	.db $0B
	.db $08,$95,$01,$0A
	.db $E8,$83,$01,$F8
	.db $E8,$85,$01,$00
	.db $E8,$87,$01,$08
	.db $F8,$89,$01,$F8
	.db $F8,$8B,$01,$00
	.db $F8,$8D,$01,$08
	.db $F0,$81,$01,$F0
	.db $08,$8F,$01,$F2
	.db $08,$91,$01,$FA
	.db $08,$93,$01,$02
SpritePlayer05Data:
	.db $09
	.db $08,$A5,$01,$01
	.db $EB,$97,$01,$F1
	.db $E8,$99,$01,$F7
	.db $E8,$9B,$01,$FF
	.db $F8,$9D,$01,$F9
	.db $F8,$9F,$01,$01
	.db $E8,$87,$01,$07
	.db $08,$A1,$01,$F1
	.db $08,$A3,$01,$F9
SpritePlayer06Data:
	.db $0A
	.db $09,$B7,$01,$FF
	.db $EB,$A7,$01,$EF
	.db $E9,$A9,$01,$F7
	.db $E9,$AB,$01,$FF
	.db $E9,$87,$01,$07
	.db $FB,$AD,$01,$EF
	.db $F9,$AF,$01,$F7
	.db $F9,$B1,$01,$FF
	.db $F9,$B3,$01,$07
	.db $09,$B5,$01,$F7
SpritePlayer07Data:
	.db $0A
	.db $09,$93,$01,$02
	.db $F1,$81,$01,$EE
	.db $E9,$83,$01,$F6
	.db $E9,$85,$01,$FE
	.db $E9,$87,$01,$06
	.db $F9,$89,$01,$F6
	.db $F9,$8B,$01,$FE
	.db $F9,$8D,$01,$06
	.db $09,$8F,$01,$F2
	.db $09,$91,$01,$FA
SpritePlayer08Data:
	.db $0B
	.db $09,$A7,$01,$0A
	.db $E9,$95,$01,$EF
	.db $E9,$97,$01,$F7
	.db $E9,$99,$01,$FF
	.db $E9,$87,$01,$07
	.db $F9,$9B,$01,$F4
	.db $F9,$9D,$01,$FC
	.db $F9,$9F,$01,$04
	.db $09,$A1,$01,$F2
	.db $09,$A3,$01,$FA
	.db $09,$A5,$01,$02
SpritePlayer09Data:
	.db $09
	.db $08,$B7,$01,$01
	.db $F0,$A9,$01,$F1
	.db $E8,$AB,$01,$F7
	.db $E8,$AD,$01,$FF
	.db $E8,$87,$01,$07
	.db $F8,$AF,$01,$F9
	.db $F8,$B1,$01,$01
	.db $07,$B3,$01,$F1
	.db $08,$B5,$01,$F9
SpritePlayer0AData:
	.db $0A
	.db $FB,$89,$01,$F0
	.db $E8,$85,$01,$00
	.db $E8,$87,$01,$08
	.db $EB,$81,$01,$F0
	.db $E8,$83,$01,$F8
	.db $F8,$8B,$01,$F8
	.db $F8,$8D,$01,$00
	.db $F8,$8F,$01,$08
	.db $08,$91,$01,$F8
	.db $08,$93,$01,$00
SpritePlayer0BData:
	.db $0A
	.db $08,$A5,$01,$04
	.db $F0,$95,$01,$F1
	.db $E8,$97,$01,$F9
	.db $E8,$99,$01,$01
	.db $E8,$87,$01,$09
	.db $F8,$9B,$01,$F9
	.db $F8,$9D,$01,$01
	.db $F8,$9F,$01,$09
	.db $08,$A1,$01,$F4
	.db $08,$A3,$01,$FC
SpritePlayer0CData:
	.db $08
	.db $E8,$83,$01,$03
	.db $F8,$85,$01,$F4
	.db $F8,$87,$01,$FC
	.db $F8,$89,$01,$04
	.db $08,$8F,$01,$06
	.db $E8,$81,$01,$FB
	.db $08,$8B,$01,$F6
	.db $08,$8D,$01,$FE
;Vampire stopping
SpritePlayer0DData:
	.db $07
	.db $09,$9D,$01,$01
	.db $E9,$91,$01,$FA
	.db $E9,$93,$01,$02
	.db $FB,$95,$01,$F1
	.db $F9,$97,$01,$F9
	.db $F9,$99,$01,$01
	.db $09,$9B,$01,$F9
SpritePlayer0EData:
	.db $07
	.db $08,$AB,$01,$02
	.db $E8,$9F,$01,$FA
	.db $E8,$A1,$01,$02
	.db $F8,$A3,$01,$FA
	.db $F8,$A5,$01,$02
	.db $00,$A7,$01,$F2
	.db $08,$A9,$01,$FA
SpritePlayer0FData:
	.db $07
	.db $08,$AB,$01,$02
	.db $E8,$9F,$01,$FA
	.db $E8,$A1,$01,$02
	.db $F8,$AD,$01,$FA
	.db $F8,$A5,$01,$02
	.db $00,$AF,$01,$F2
	.db $08,$B1,$01,$FA
;Vampire idle
SpritePlayer10Data:
	.db $06
	.db $08,$AB,$01,$02
	.db $E8,$9F,$01,$FA
	.db $E8,$A1,$01,$02
	.db $F8,$B3,$01,$FA
	.db $F8,$A5,$01,$02
	.db $08,$B5,$01,$FA
;Vampire ducking
SpritePlayer11Data:
	.db $06
	.db $08,$B1,$01,$01
	.db $F8,$A7,$01,$F2
	.db $F8,$A9,$01,$FA
	.db $F8,$AB,$01,$02
	.db $08,$AD,$01,$F1
	.db $08,$AF,$01,$F9
SpritePlayer12Data:
	.db $06
	.db $08,$B1,$01,$01
	.db $F8,$B3,$01,$F2
	.db $F8,$B5,$01,$FA
	.db $F8,$AB,$01,$02
	.db $08,$B7,$01,$F1
	.db $08,$B9,$01,$F9
SpritePlayer13Data:
	.db $07
	.db $08,$8D,$01,$01
	.db $E8,$81,$01,$FC
	.db $E8,$83,$01,$04
	.db $FC,$85,$01,$F1
	.db $F8,$87,$01,$F9
	.db $F8,$89,$01,$01
	.db $08,$8B,$01,$F9
;Vampire jumping
SpritePlayer14Data:
	.db $09
	.db $08,$9F,$01,$05
	.db $E8,$8F,$01,$FC
	.db $E8,$91,$01,$04
	.db $F0,$93,$01,$F4
	.db $F8,$95,$01,$FC
	.db $F8,$97,$01,$04
	.db $F8,$99,$01,$0C
	.db $08,$9B,$01,$F5
	.db $08,$9D,$01,$FD
SpritePlayer15Data:
	.db $09
	.db $08,$9F,$01,$05
	.db $E8,$A1,$01,$FC
	.db $E8,$91,$01,$04
	.db $F1,$A3,$01,$F4
	.db $F8,$A5,$01,$FC
	.db $F8,$A7,$01,$04
	.db $F8,$99,$01,$0C
	.db $08,$9B,$01,$F5
	.db $08,$9D,$01,$FD
SpritePlayer16Data:
	.db $09
	.db $FB,$B5,$01,$08
	.db $E8,$A9,$01,$F4
	.db $E8,$AB,$01,$FC
	.db $EB,$AD,$01,$04
	.db $F8,$B1,$01,$F8
	.db $F8,$B3,$01,$00
	.db $EB,$AF,$01,$0C
	.db $08,$B7,$01,$F8
	.db $08,$B9,$01,$00
SpritePlayer17Data:
	.db $09
	.db $08,$91,$01,$05
	.db $E8,$81,$01,$F4
	.db $E8,$83,$01,$FC
	.db $E8,$85,$01,$04
	.db $E8,$87,$01,$0C
	.db $F8,$89,$01,$FB
	.db $F8,$8B,$01,$03
	.db $F8,$8D,$01,$0B
	.db $08,$8F,$01,$FD
SpritePlayer18Data:
	.db $09
	.db $08,$91,$01,$05
	.db $E7,$93,$01,$F4
	.db $E8,$95,$01,$FC
	.db $E8,$85,$01,$04
	.db $E8,$87,$01,$0C
	.db $F8,$97,$01,$FB
	.db $F8,$99,$01,$03
	.db $F8,$8D,$01,$0B
	.db $08,$8F,$01,$FD
;Unreferenced sprite data???
	.db $07
	.db $F8,$89,$01,$05
	.db $E8,$81,$01,$FA
	.db $E8,$83,$01,$02
	.db $F8,$85,$01,$F5
	.db $F8,$87,$01,$FD
	.db $08,$8B,$01,$F8
	.db $08,$8D,$01,$00
	.db $07
	.db $F8,$89,$01,$05
	.db $E8,$81,$01,$FA
	.db $E8,$83,$01,$02
	.db $F8,$8F,$01,$F5
	.db $F8,$91,$01,$FD
	.db $08,$93,$01,$F8
	.db $08,$8D,$01,$00
	.db $09
	.db $08,$AB,$01,$04
	.db $E8,$9B,$01,$F4
	.db $E8,$9D,$01,$FC
	.db $F8,$A1,$01,$F0
	.db $F8,$A3,$01,$F8
	.db $F8,$A5,$01,$00
	.db $F8,$A7,$01,$08
	.db $E8,$9F,$01,$04
	.db $08,$A9,$01,$FC
	.db $09
	.db $08,$AB,$01,$04
	.db $E8,$AD,$01,$F4
	.db $E8,$AF,$01,$FC
	.db $E8,$9F,$01,$04
	.db $F8,$B3,$01,$F8
	.db $F8,$A5,$01,$00
	.db $F8,$A7,$01,$08
	.db $F3,$B1,$01,$F0
	.db $08,$A9,$01,$FC
;Vampire hit
SpritePlayer19Data:
	.db $09
	.db $10,$B9,$01,$F9
	.db $F0,$AB,$01,$F8
	.db $F0,$AD,$01,$00
	.db $F0,$AF,$01,$08
	.db $00,$B1,$01,$F8
	.db $00,$B3,$01,$00
	.db $00,$B5,$01,$08
	.db $F0,$A9,$01,$F0
	.db $0E,$B7,$01,$F1
;Vampire death
SpritePlayer1AData:
	.db $07
	.db $08,$8D,$01,$07
	.db $F8,$83,$01,$00
	.db $F8,$85,$01,$08
	.db $F8,$81,$01,$F8
	.db $FF,$87,$01,$F0
	.db $08,$89,$01,$F7
	.db $08,$8B,$01,$FF
SpritePlayer1BData:
	.db $08
	.db $08,$8D,$01,$07
	.db $F8,$8F,$01,$F0
	.db $F8,$83,$01,$00
	.db $F8,$85,$01,$08
	.db $F8,$91,$01,$F8
	.db $08,$93,$01,$EF
	.db $08,$95,$01,$F7
	.db $08,$8B,$01,$FF
SpritePlayer1CData:
	.db $09
	.db $E8,$95,$01,$08
	.db $F8,$97,$01,$F0
	.db $F8,$99,$01,$F8
	.db $F8,$9B,$01,$00
	.db $F8,$9D,$01,$08
	.db $08,$9F,$01,$F0
	.db $08,$A1,$01,$F8
	.db $08,$A3,$01,$00
	.db $08,$A5,$01,$08
SpritePlayer1DData:
	.db $0C
	.db $E8,$97,$01,$F0
	.db $E8,$99,$01,$F8
	.db $E8,$9B,$01,$00
	.db $E8,$9D,$01,$08
	.db $F8,$9F,$01,$F0
	.db $F8,$A1,$01,$F8
	.db $F8,$A3,$01,$00
	.db $F8,$A5,$01,$08
	.db $08,$A7,$01,$F0
	.db $08,$A9,$01,$F8
	.db $08,$AB,$01,$00
	.db $08,$AD,$01,$08
SpritePlayer1EData:
	.db $0C
	.db $E8,$A3,$01,$F0
	.db $E8,$A5,$01,$F8
	.db $E8,$A7,$01,$00
	.db $E8,$A9,$01,$08
	.db $F8,$AB,$01,$F0
	.db $F8,$AD,$01,$F8
	.db $F8,$AF,$01,$00
	.db $F8,$B1,$01,$08
	.db $08,$B3,$01,$F0
	.db $08,$B5,$01,$F8
	.db $08,$B7,$01,$00
	.db $08,$B9,$01,$08
SpritePlayer1FData:
	.db $09
	.db $08,$B7,$01,$04
	.db $E8,$A7,$01,$F4
	.db $E8,$A9,$01,$FC
	.db $E8,$AB,$01,$04
	.db $F8,$AD,$01,$F4
	.db $F8,$AF,$01,$FC
	.db $F8,$B1,$01,$04
	.db $08,$B3,$01,$F4
	.db $08,$B5,$01,$FC
;Vampire attacking
SpritePlayer20Data:
	.db $09
	.db $08,$91,$01,$06
	.db $E8,$81,$01,$F4
	.db $E8,$83,$01,$FC
	.db $08,$8D,$01,$F6
	.db $F8,$8B,$01,$05
	.db $E8,$85,$01,$04
	.db $F8,$87,$01,$F5
	.db $08,$8F,$01,$FE
	.db $F8,$89,$01,$FD
SpritePlayer21Data:
	.db $0B
	.db $E8,$93,$01,$00
	.db $E8,$95,$01,$08
	.db $E8,$97,$01,$10
	.db $F0,$99,$01,$F8
	.db $F8,$9B,$01,$00
	.db $F8,$9D,$01,$08
	.db $F8,$9F,$01,$10
	.db $08,$A1,$01,$F8
	.db $08,$A3,$01,$00
	.db $08,$A5,$01,$08
	.db $08,$A7,$01,$10
;Vampire duck attacking
SpritePlayer22Data:
	.db $07
	.db $F8,$85,$01,$03
	.db $F8,$81,$01,$F3
	.db $F8,$83,$01,$FB
	.db $08,$87,$01,$F0
	.db $08,$89,$01,$F8
	.db $08,$8B,$01,$00
	.db $08,$8D,$01,$08
SpritePlayer23Data:
	.db $07
	.db $08,$9B,$01,$06
	.db $F8,$91,$01,$F8
	.db $F8,$93,$01,$00
	.db $F8,$95,$01,$08
	.db $F8,$8F,$01,$F0
	.db $08,$97,$01,$F6
	.db $08,$99,$01,$FE
SpritePlayer24Data:
	.db $07
	.db $02,$A3,$01,$F0
	.db $F8,$9F,$01,$00
	.db $F8,$A1,$01,$08
	.db $F8,$9D,$01,$F8
	.db $08,$A5,$01,$F8
	.db $08,$A7,$01,$00
	.db $08,$A9,$01,$08
;Vampire walking with key
SpritePlayer25Data:
	.db $0B
	.db $0C,$95,$01,$0A
	.db $EC,$81,$01,$F0
	.db $EC,$83,$01,$F8
	.db $EC,$85,$01,$00
	.db $EC,$87,$01,$08
	.db $FC,$89,$01,$F4
	.db $FC,$8B,$01,$FC
	.db $FC,$8D,$01,$04
	.db $0C,$8F,$01,$F2
	.db $0C,$91,$01,$FA
	.db $0C,$93,$01,$02
SpritePlayer26Data:
	.db $09
	.db $0C,$91,$01,$01
	.db $EC,$81,$01,$EF
	.db $EC,$83,$01,$F7
	.db $EC,$85,$01,$FF
	.db $EC,$87,$01,$07
	.db $FC,$89,$01,$F9
	.db $FC,$8B,$01,$01
	.db $04,$8D,$01,$F1
	.db $0C,$8F,$01,$F9
SpritePlayer27Data:
	.db $09
	.db $0C,$91,$01,$00
	.db $EC,$81,$01,$EF
	.db $EC,$83,$01,$F7
	.db $EC,$85,$01,$FF
	.db $EC,$87,$01,$07
	.db $FC,$89,$01,$F1
	.db $FC,$8B,$01,$F9
	.db $FC,$8D,$01,$01
	.db $0C,$8F,$01,$F8
SpritePlayer28Data:
	.db $0A
	.db $0C,$A5,$01,$00
	.db $EC,$93,$01,$EE
	.db $EC,$95,$01,$F6
	.db $EC,$97,$01,$FE
	.db $EC,$99,$01,$06
	.db $FC,$9B,$01,$F3
	.db $FC,$9D,$01,$FB
	.db $FC,$9F,$01,$03
	.db $0C,$A1,$01,$F0
	.db $0C,$A3,$01,$F8
SpritePlayer29Data:
	.db $0B
	.db $0C,$A5,$01,$0A
	.db $EC,$93,$01,$EF
	.db $EC,$95,$01,$F7
	.db $EC,$97,$01,$FF
	.db $EC,$87,$01,$07
	.db $FC,$99,$01,$F4
	.db $FC,$9B,$01,$FC
	.db $FC,$9D,$01,$04
	.db $0C,$9F,$01,$F2
	.db $0C,$A1,$01,$FA
	.db $0C,$A3,$01,$02
SpritePlayer2AData:
	.db $0A
	.db $0C,$B7,$01,$01
	.db $EC,$A7,$01,$EF
	.db $EC,$A9,$01,$F7
	.db $EC,$AB,$01,$FF
	.db $EC,$87,$01,$07
	.db $FC,$AD,$01,$F1
	.db $FC,$AF,$01,$F9
	.db $FC,$B1,$01,$01
	.db $0C,$B3,$01,$F1
	.db $0C,$B5,$01,$F9
SpritePlayer2BData:
	.db $09
	.db $0C,$A3,$01,$00
	.db $EC,$97,$01,$F0
	.db $EC,$99,$01,$F8
	.db $EC,$85,$01,$00
	.db $EC,$87,$01,$08
	.db $FC,$9B,$01,$F2
	.db $FC,$9D,$01,$FA
	.db $FC,$9F,$01,$02
	.db $0C,$A1,$01,$F8
SpritePlayer2CData:
	.db $0A
	.db $0C,$B7,$01,$00
	.db $EC,$A5,$01,$F8
	.db $EC,$A7,$01,$00
	.db $EC,$A9,$01,$08
	.db $F4,$AB,$01,$F0
	.db $FC,$AD,$01,$F4
	.db $FC,$AF,$01,$FC
	.db $FC,$B1,$01,$04
	.db $0C,$B3,$01,$F0
	.db $0C,$B5,$01,$F8
SpritePlayer2DData:
	.db $0A
	.db $0C,$B9,$01,$06
	.db $EC,$A7,$01,$F6
	.db $EC,$A9,$01,$FE
	.db $EC,$AB,$01,$06
	.db $F4,$AD,$01,$EE
	.db $FC,$AF,$01,$F6
	.db $FC,$B1,$01,$FE
	.db $FC,$B3,$01,$06
	.db $0C,$B5,$01,$F3
	.db $0C,$B7,$01,$FB
;Vampire stopping with key
SpritePlayer2EData:
	.db $08
	.db $0B,$8F,$01,$02
	.db $0B,$8D,$01,$FA
	.db $EB,$83,$01,$FE
	.db $EB,$85,$01,$06
	.db $FB,$87,$01,$F2
	.db $FB,$89,$01,$FA
	.db $FB,$8B,$01,$02
	.db $EB,$81,$01,$F6
SpritePlayer2FData:
	.db $09
	.db $0A,$91,$01,$04
	.db $EA,$81,$01,$F4
	.db $EA,$83,$01,$FC
	.db $EA,$85,$01,$04
	.db $FA,$87,$01,$F4
	.db $FA,$89,$01,$FC
	.db $FA,$8B,$01,$04
	.db $0A,$8D,$01,$F4
	.db $0A,$8F,$01,$FC
SpritePlayer30Data:
	.db $09
	.db $0A,$91,$01,$04
	.db $EA,$81,$01,$F4
	.db $EA,$83,$01,$FC
	.db $EA,$85,$01,$04
	.db $FA,$93,$01,$F4
	.db $FA,$89,$01,$FC
	.db $FA,$8B,$01,$04
	.db $0A,$95,$01,$F4
	.db $0A,$97,$01,$FC
;Vampire idle with key
SpritePlayer31Data:
	.db $09
	.db $0A,$91,$01,$04
	.db $EA,$81,$01,$F4
	.db $EA,$83,$01,$FC
	.db $EA,$85,$01,$04
	.db $FA,$99,$01,$F4
	.db $FA,$89,$01,$FC
	.db $FA,$8B,$01,$04
	.db $0A,$9B,$01,$F4
	.db $0A,$9D,$01,$FC
;Vampire ducking with key
SpritePlayer32Data:
	.db $06
	.db $04,$87,$01,$F1
	.db $F8,$85,$01,$08
	.db $F8,$81,$01,$F8
	.db $F8,$83,$01,$00
	.db $08,$89,$01,$F9
	.db $08,$8B,$01,$01
SpritePlayer33Data:
	.db $06
	.db $08,$8B,$01,$01
	.db $F8,$83,$01,$00
	.db $F8,$85,$01,$08
	.db $F8,$8D,$01,$F8
	.db $08,$8F,$01,$F1
	.db $08,$91,$01,$F9
SpritePlayer34Data:
	.db $08
	.db $0E,$B9,$01,$01
	.db $EE,$AB,$01,$F8
	.db $EE,$AD,$01,$00
	.db $EE,$AF,$01,$08
	.db $FE,$B1,$01,$F2
	.db $FE,$B3,$01,$FA
	.db $FE,$B5,$01,$02
	.db $0E,$B7,$01,$F9
;Vampire jumping with key
SpritePlayer35Data:
	.db $0A
	.db $08,$B1,$01,$04
	.db $E8,$A3,$01,$00
	.db $E8,$A5,$01,$08
	.db $F8,$A7,$01,$F8
	.db $F8,$A9,$01,$00
	.db $F8,$AB,$01,$08
	.db $EE,$9F,$01,$F0
	.db $E8,$A1,$01,$F8
	.db $08,$AD,$01,$F4
	.db $08,$AF,$01,$FC
SpritePlayer36Data:
	.db $0A
	.db $08,$B1,$01,$04
	.db $E8,$B5,$01,$F8
	.db $E8,$A3,$01,$00
	.db $E8,$A5,$01,$08
	.db $F8,$B7,$01,$F8
	.db $F8,$B9,$01,$00
	.db $F8,$AB,$01,$08
	.db $F0,$B3,$01,$F0
	.db $08,$AD,$01,$F4
	.db $08,$AF,$01,$FC
SpritePlayer37Data:
	.db $09
	.db $EC,$91,$01,$F0
	.db $E8,$93,$01,$F8
	.db $E8,$95,$01,$00
	.db $E8,$97,$01,$08
	.db $F8,$99,$01,$F8
	.db $F8,$9B,$01,$00
	.db $F8,$9D,$01,$08
	.db $08,$9F,$01,$F8
	.db $08,$A1,$01,$00
SpritePlayer38Data:
	.db $09
	.db $08,$AB,$01,$04
	.db $E8,$9D,$01,$F8
	.db $E8,$9F,$01,$00
	.db $E8,$A1,$01,$08
	.db $F8,$A3,$01,$F8
	.db $F8,$A5,$01,$00
	.db $F8,$A7,$01,$08
	.db $E8,$9B,$01,$F0
	.db $08,$A9,$01,$FC
SpritePlayer39Data:
	.db $09
	.db $08,$AB,$01,$04
	.db $E8,$AF,$01,$F8
	.db $E8,$B1,$01,$00
	.db $E8,$A1,$01,$08
	.db $F8,$B3,$01,$F8
	.db $F8,$A5,$01,$00
	.db $F8,$A7,$01,$08
	.db $E8,$AD,$01,$F0
	.db $08,$A9,$01,$FC
;Vampire throwing key
SpritePlayer3AData:
	.db $09
	.db $0A,$91,$01,$02
	.db $EA,$81,$01,$F0
	.db $EA,$83,$01,$F8
	.db $EA,$85,$01,$00
	.db $FA,$87,$01,$F0
	.db $FA,$89,$01,$F8
	.db $FA,$8B,$01,$00
	.db $0A,$8D,$01,$F2
	.db $0A,$8F,$01,$FA
SpritePlayer3BData:
	.db $0B
	.db $10,$B7,$01,$04
	.db $F0,$A5,$01,$F8
	.db $F0,$A7,$01,$00
	.db $F0,$A9,$01,$08
	.db $F0,$A3,$01,$F0
	.db $00,$AD,$01,$F8
	.db $00,$AF,$01,$00
	.db $00,$B1,$01,$08
	.db $F3,$AB,$01,$10
	.db $10,$B3,$01,$F4
	.db $10,$B5,$01,$FC
;Vampire duck throwing key
SpritePlayer3CData:
	.db $06
	.db $08,$B9,$01,$02
	.db $F8,$B1,$01,$F8
	.db $F8,$B3,$01,$00
	.db $F8,$AF,$01,$F0
	.db $08,$B5,$01,$F2
	.db $08,$B7,$01,$FA
SpritePlayer3DData:
	.db $08
	.db $00,$A1,$01,$10
	.db $F8,$95,$01,$F8
	.db $F8,$97,$01,$00
	.db $F8,$99,$01,$08
	.db $08,$9B,$01,$F8
	.db $08,$9D,$01,$00
	.db $08,$9F,$01,$08
	.db $FE,$93,$01,$F0
;UNUSED
SpritePlayer3EData:
	.db $08
	.db $08,$8F,$01,$FF
	.db $E8,$83,$01,$00
	.db $E8,$85,$01,$08
	.db $E8,$81,$01,$F8
	.db $F8,$87,$01,$F7
	.db $F8,$89,$01,$FF
	.db $F8,$8B,$01,$07
	.db $08,$8D,$01,$F7
SpritePlayer3FData:
	.db $08
	.db $08,$8F,$01,$FF
	.db $E8,$83,$01,$00
	.db $E8,$85,$01,$08
	.db $E8,$91,$01,$F8
	.db $F8,$93,$01,$F7
	.db $F8,$95,$01,$FF
	.db $F8,$8B,$01,$07
	.db $08,$97,$01,$F7
SpritePlayer40Data:
	.db $09
	.db $08,$A9,$01,$01
	.db $E8,$9B,$01,$F8
	.db $E8,$9D,$01,$00
	.db $E8,$9F,$01,$08
	.db $E8,$99,$01,$F0
	.db $F8,$A1,$01,$F2
	.db $F8,$A3,$01,$FA
	.db $F8,$A5,$01,$02
	.db $08,$A7,$01,$F9
SpritePlayer41Data:
	.db $09
	.db $08,$A9,$01,$01
	.db $E8,$AD,$01,$F8
	.db $E8,$9D,$01,$00
	.db $E8,$9F,$01,$08
	.db $E8,$AB,$01,$F0
	.db $F8,$AF,$01,$F2
	.db $F8,$B1,$01,$FA
	.db $F8,$A5,$01,$02
	.db $08,$A7,$01,$F9
;Vampire fire
SpritePlayer42Data:
	.db $04
	.db $00,$47,$00,$FE
	.db $F0,$43,$00,$F7
	.db $F0,$45,$00,$FF
	.db $F0,$41,$00,$EF
SpritePlayer43Data:
	.db $04
	.db $00,$4B,$80,$04
	.db $F0,$49,$00,$FC
	.db $F0,$4B,$00,$04
	.db $00,$49,$80,$FC
SpritePlayer44Data:
	.db $04
	.db $00,$4F,$80,$05
	.db $F0,$4D,$00,$FD
	.db $F0,$4F,$00,$05
	.db $00,$4D,$80,$FD
SpritePlayer45Data:
	.db $04
	.db $00,$53,$80,$05
	.db $ED,$51,$00,$FD
	.db $F0,$53,$00,$05
	.db $03,$51,$80,$FD
SpritePlayer46Data:
	.db $04
	.db $E8,$59,$00,$00
	.db $F0,$5B,$00,$08
	.db $08,$59,$80,$00
	.db $00,$5B,$80,$08
;Monster idle
SpritePlayer47Data:
	.db $06
	.db $08,$CB,$02,$FF
	.db $E8,$C1,$02,$F8
	.db $E8,$C3,$02,$00
	.db $F8,$C5,$02,$F8
	.db $F8,$C7,$02,$00
	.db $08,$C9,$02,$F7
;Monster ducking
SpritePlayer48Data:
	.db $06
	.db $08,$D7,$02,$FF
	.db $E8,$CD,$02,$F8
	.db $F8,$D1,$02,$F4
	.db $F8,$D3,$02,$FC
	.db $E8,$CF,$02,$00
	.db $08,$D5,$02,$F7
SpritePlayer49Data:
	.db $05
	.db $08,$C9,$02,$FF
	.db $F8,$C1,$02,$F7
	.db $F8,$C3,$02,$FF
	.db $04,$C5,$02,$EF
	.db $08,$C7,$02,$F7
;Monster hit
SpritePlayer4AData:
	.db $0A
	.db $E8,$C1,$02,$F4
	.db $E8,$C3,$02,$FC
	.db $F8,$C5,$02,$F4
	.db $F8,$C7,$02,$FC
	.db $08,$C9,$02,$F4
	.db $08,$CB,$02,$FC
	.db $F0,$CD,$02,$04
	.db $F0,$CF,$02,$0C
	.db $00,$D1,$02,$04
	.db $00,$D3,$02,$0C
;Monster death
SpritePlayer4BData:
	.db $06
	.db $F8,$C5,$02,$05
	.db $F8,$C1,$02,$F5
	.db $F8,$C3,$02,$FD
	.db $08,$C7,$02,$F4
	.db $08,$C9,$02,$FC
	.db $08,$CB,$02,$04
SpritePlayer4CData:
	.db $06
	.db $F8,$C5,$02,$05
	.db $F8,$C1,$02,$F5
	.db $F8,$C3,$02,$FD
	.db $08,$C7,$02,$F4
	.db $08,$C9,$02,$FC
	.db $08,$CB,$02,$04
SpritePlayer4DData:
	.db $07
	.db $F8,$D3,$02,$05
	.db $E8,$CD,$02,$F5
	.db $F8,$CF,$02,$F5
	.db $F8,$D1,$02,$FD
	.db $08,$D5,$02,$F4
	.db $08,$D7,$02,$FC
	.db $08,$D9,$02,$04
SpritePlayer4EData:
	.db $09
	.db $E8,$D5,$02,$F4
	.db $E8,$D7,$02,$FC
	.db $E8,$D9,$02,$04
	.db $F8,$DB,$02,$F4
	.db $F8,$DD,$02,$FC
	.db $F8,$DF,$02,$04
	.db $08,$E1,$02,$F4
	.db $08,$E3,$02,$FC
	.db $08,$E5,$02,$04
SpritePlayer4FData:
	.db $09
	.db $E8,$E7,$02,$F4
	.db $E8,$E9,$02,$FC
	.db $E8,$EB,$02,$04
	.db $F8,$ED,$02,$F4
	.db $F8,$EF,$02,$FC
	.db $F8,$F1,$02,$04
	.db $08,$F3,$02,$F4
	.db $08,$F5,$02,$FC
	.db $08,$F7,$02,$04
;Monster jumping
SpritePlayer50Data:
	.db $08
	.db $05,$CF,$02,$00
	.db $E5,$C1,$02,$FA
	.db $E5,$C3,$02,$02
	.db $F5,$C5,$02,$F7
	.db $F5,$C7,$02,$FF
	.db $F5,$C9,$02,$07
	.db $05,$CB,$02,$F0
	.db $05,$CD,$02,$F8
SpritePlayer51Data:
	.db $08
	.db $05,$CF,$02,$00
	.db $E5,$C1,$02,$FA
	.db $E5,$C3,$02,$02
	.db $F5,$D1,$02,$F7
	.db $F5,$D3,$02,$FF
	.db $F5,$C9,$02,$07
	.db $05,$CB,$02,$F0
	.db $05,$CD,$02,$F8
SpritePlayer52Data:
	.db $09
	.db $06,$CF,$02,$FF
	.db $E6,$D1,$02,$F8
	.db $E6,$D3,$02,$00
	.db $E6,$D5,$02,$08
	.db $F6,$D7,$02,$F5
	.db $F6,$D9,$02,$FD
	.db $F6,$DB,$02,$05
	.db $06,$CB,$02,$EF
	.db $06,$CD,$02,$F7
SpritePlayer53Data:
	.db $08
	.db $08,$CF,$02,$FB
	.db $E8,$C1,$02,$F2
	.db $E8,$C3,$02,$FA
	.db $E8,$C5,$02,$02
	.db $E8,$C7,$02,$0A
	.db $F8,$C9,$02,$F3
	.db $F8,$CB,$02,$FB
	.db $08,$CD,$02,$F3
SpritePlayer54Data:
	.db $08
	.db $08,$CF,$02,$FB
	.db $E8,$D1,$02,$F2
	.db $E8,$D3,$02,$FA
	.db $E8,$C5,$02,$02
	.db $E8,$C7,$02,$0A
	.db $F8,$D5,$02,$F3
	.db $F8,$D7,$02,$FB
	.db $08,$CD,$02,$F3
;Monster walking
SpritePlayer55Data:
	.db $09
	.db $0C,$D1,$02,$FF
	.db $FC,$D9,$02,$F4
	.db $FC,$DB,$02,$FC
	.db $FC,$DD,$02,$04
	.db $EC,$D7,$02,$01
	.db $0C,$CD,$02,$EF
	.db $0C,$CF,$02,$F7
	.db $EC,$D5,$02,$F9
	.db $0C,$D3,$02,$07
SpritePlayer56Data:
	.db $08
	.db $0C,$D1,$02,$FD
	.db $EC,$D3,$02,$F8
	.db $EC,$D5,$02,$00
	.db $FC,$D7,$02,$F4
	.db $FC,$C7,$02,$EC
	.db $FC,$D9,$02,$FC
	.db $FC,$DB,$02,$04
	.db $0C,$CF,$02,$F5
SpritePlayer57Data:
	.db $08
	.db $0C,$F1,$02,$FC
	.db $EC,$E3,$02,$F4
	.db $EC,$E5,$02,$FC
	.db $EC,$E7,$02,$04
	.db $FC,$E9,$02,$F0
	.db $FC,$EB,$02,$F8
	.db $FC,$ED,$02,$00
	.db $0C,$EF,$02,$F4
SpritePlayer58Data:
	.db $09
	.db $0C,$EB,$02,$00
	.db $EC,$DB,$02,$F4
	.db $EC,$DD,$02,$FC
	.db $EC,$DF,$02,$04
	.db $FC,$E1,$02,$F4
	.db $FC,$E3,$02,$FC
	.db $FC,$E5,$02,$04
	.db $0C,$E7,$02,$F0
	.db $0C,$E9,$02,$F8
SpritePlayer59Data:
	.db $09
	.db $0C,$D3,$02,$07
	.db $EC,$F1,$02,$00
	.db $EC,$EF,$02,$F8
	.db $FC,$F3,$02,$F4
	.db $FC,$F5,$02,$FC
	.db $FC,$F7,$02,$04
	.db $0C,$EB,$02,$EF
	.db $0C,$ED,$02,$F7
	.db $0C,$D1,$02,$FF
SpritePlayer5AData:
	.db $07
	.db $0C,$E5,$02,$FD
	.db $EC,$E7,$02,$F8
	.db $EC,$D5,$02,$00
	.db $FC,$E9,$02,$F6
	.db $FC,$EB,$02,$FE
	.db $FC,$DD,$02,$EE
	.db $0C,$E3,$02,$F5
SpritePlayer5BData:
	.db $09
	.db $0C,$E9,$02,$FC
	.db $EC,$EB,$02,$F4
	.db $EC,$ED,$02,$FC
	.db $EC,$EF,$02,$04
	.db $FC,$F1,$02,$EC
	.db $FC,$F3,$02,$F4
	.db $FC,$F5,$02,$FC
	.db $FC,$F7,$02,$04
	.db $0C,$E7,$02,$F4
SpritePlayer5CData:
	.db $0A
	.db $0C,$E9,$02,$01
	.db $EC,$EB,$02,$F4
	.db $EC,$ED,$02,$FC
	.db $EC,$EF,$02,$04
	.db $FC,$F1,$02,$F4
	.db $FC,$F3,$02,$FC
	.db $FC,$F5,$02,$04
	.db $F4,$F7,$02,$0C
	.db $0C,$E5,$02,$F1
	.db $0C,$E7,$02,$F9
SpritePlayer5DData:
	.db $09
	.db $0C,$D1,$02,$02
	.db $EC,$D7,$02,$00
	.db $EC,$D5,$02,$F8
	.db $DC,$D3,$02,$00
	.db $FC,$D9,$02,$F4
	.db $FC,$DB,$02,$FC
	.db $FC,$DD,$02,$04
	.db $0C,$CD,$02,$F2
	.db $0C,$CF,$02,$FA
;Monster attacking
SpritePlayer5EData:
	.db $07
	.db $0B,$F7,$02,$02
	.db $EB,$EB,$02,$F6
	.db $EB,$ED,$02,$FE
	.db $FB,$EF,$02,$F5
	.db $FB,$F1,$02,$FD
	.db $0B,$F3,$02,$F2
	.db $0B,$F5,$02,$FA
SpritePlayer5FData:
	.db $08
	.db $E8,$C1,$02,$F2
	.db $E8,$C3,$02,$FA
	.db $E8,$C5,$02,$02
	.db $F8,$C7,$02,$F2
	.db $F8,$C9,$02,$FA
	.db $F8,$CB,$02,$02
	.db $08,$CD,$02,$F6
	.db $08,$CF,$02,$FE
SpritePlayer60Data:
	.db $09
	.db $08,$EB,$02,$0E
	.db $F8,$DB,$02,$00
	.db $E8,$DD,$02,$08
	.db $F2,$DF,$02,$10
	.db $F2,$E1,$02,$18
	.db $F8,$E3,$02,$08
	.db $08,$E5,$02,$F6
	.db $08,$E7,$02,$FE
	.db $08,$E9,$02,$06
;Monster duck attacking
SpritePlayer61Data:
	.db $06
	.db $08,$D9,$02,$00
	.db $F8,$C1,$02,$EE
	.db $F8,$D1,$02,$F6
	.db $F8,$D3,$02,$FE
	.db $08,$D5,$02,$F0
	.db $08,$D7,$02,$F8
SpritePlayer62Data:
	.db $07
	.db $FB,$E1,$02,$0C
	.db $F8,$F1,$02,$04
	.db $08,$F3,$02,$F4
	.db $08,$F5,$02,$FC
	.db $08,$F7,$02,$04
	.db $F8,$ED,$02,$F4
	.db $F8,$EF,$02,$FC
SpritePlayer63Data:
	.db $06
	.db $08,$F7,$02,$00
	.db $F8,$ED,$02,$F0
	.db $F8,$EF,$02,$F8
	.db $F8,$F1,$02,$00
	.db $08,$F3,$02,$F0
	.db $08,$F5,$02,$F8
;Monster idle with key
SpritePlayer64Data:
	.db $08
	.db $0A,$D9,$02,$05
	.db $EA,$CB,$02,$F5
	.db $EA,$CD,$02,$FD
	.db $EA,$CF,$02,$05
	.db $FA,$D1,$02,$F9
	.db $FA,$D3,$02,$01
	.db $0A,$D5,$02,$F5
	.db $0A,$D7,$02,$FD
;Monster ducking with key
SpritePlayer65Data:
	.db $07
	.db $0E,$D9,$02,$FE
	.db $EE,$CD,$02,$F4
	.db $EE,$CF,$02,$FC
	.db $EE,$D1,$02,$04
	.db $FE,$D3,$02,$F6
	.db $FE,$D5,$02,$FE
	.db $0E,$D7,$02,$F6
SpritePlayer66Data:
	.db $06
	.db $F8,$D9,$02,$F4
	.db $F8,$DB,$02,$FC
	.db $F8,$DD,$02,$04
	.db $08,$DF,$02,$F4
	.db $08,$E1,$02,$FC
	.db $08,$E3,$02,$04
;Monster jumping with key
SpritePlayer67Data:
	.db $08
	.db $08,$CF,$02,$00
	.db $E8,$D7,$02,$04
	.db $F8,$D9,$02,$F4
	.db $F8,$DB,$02,$FC
	.db $F8,$DD,$02,$04
	.db $E8,$D5,$02,$FC
	.db $08,$CB,$02,$F0
	.db $08,$CD,$02,$F8
SpritePlayer68Data:
	.db $08
	.db $08,$CF,$02,$00
	.db $E8,$D7,$02,$04
	.db $F8,$DF,$02,$F4
	.db $F8,$E1,$02,$FC
	.db $F8,$DD,$02,$04
	.db $E8,$D5,$02,$FC
	.db $08,$CB,$02,$F0
	.db $08,$CD,$02,$F8
SpritePlayer69Data:
	.db $08
	.db $08,$CF,$02,$00
	.db $E8,$C3,$02,$FC
	.db $E8,$C5,$02,$04
	.db $E8,$C1,$02,$F4
	.db $F8,$C7,$02,$F5
	.db $F8,$C9,$02,$FD
	.db $08,$CB,$02,$F0
	.db $08,$CD,$02,$F8
SpritePlayer6AData:
	.db $07
	.db $08,$F1,$02,$FD
	.db $E8,$E7,$02,$FC
	.db $E8,$E9,$02,$04
	.db $E8,$E5,$02,$F4
	.db $F8,$EB,$02,$F6
	.db $F8,$ED,$02,$FE
	.db $08,$EF,$02,$F5
SpritePlayer6BData:
	.db $07
	.db $08,$F1,$02,$FD
	.db $E8,$E7,$02,$FC
	.db $E8,$E9,$02,$04
	.db $E8,$E5,$02,$F4
	.db $F8,$F5,$02,$F6
	.db $F8,$F7,$02,$FE
	.db $08,$EF,$02,$F5
;Monster walking with key
SpritePlayer6CData:
	.db $0A
	.db $0C,$D3,$02,$07
	.db $EC,$C3,$02,$FC
	.db $EC,$C5,$02,$04
	.db $FC,$C7,$02,$F4
	.db $FC,$C9,$02,$FC
	.db $FC,$CB,$02,$04
	.db $EC,$C1,$02,$F4
	.db $0C,$CD,$02,$EF
	.db $0C,$CF,$02,$F7
	.db $0C,$D1,$02,$FF
SpritePlayer6DData:
	.db $09
	.db $0C,$D1,$02,$FD
	.db $EC,$C1,$02,$F4
	.db $EC,$C3,$02,$FC
	.db $EC,$C5,$02,$04
	.db $FC,$C7,$02,$EC
	.db $FC,$C9,$02,$F4
	.db $FC,$CB,$02,$FC
	.db $FC,$CD,$02,$04
	.db $0C,$CF,$02,$F5
SpritePlayer6EData:
	.db $08
	.db $0C,$CF,$02,$FC
	.db $EC,$C1,$02,$F4
	.db $EC,$C3,$02,$FC
	.db $EC,$C5,$02,$04
	.db $FC,$C7,$02,$F0
	.db $FC,$C9,$02,$F8
	.db $FC,$CB,$02,$00
	.db $0C,$CD,$02,$F4
SpritePlayer6FData:
	.db $09
	.db $0C,$EB,$02,$00
	.db $EC,$ED,$02,$F4
	.db $EC,$EF,$02,$FC
	.db $EC,$F1,$02,$04
	.db $FC,$F3,$02,$F4
	.db $FC,$F5,$02,$FC
	.db $FC,$F7,$02,$04
	.db $0C,$E7,$02,$F0
	.db $0C,$E9,$02,$F8
SpritePlayer70Data:
	.db $0A
	.db $0C,$D3,$02,$07
	.db $EC,$DF,$02,$F4
	.db $EC,$E1,$02,$FC
	.db $EC,$E3,$02,$04
	.db $FC,$E5,$02,$F4
	.db $FC,$E7,$02,$FC
	.db $FC,$E9,$02,$04
	.db $0C,$EB,$02,$EF
	.db $0C,$ED,$02,$F7
	.db $0C,$D1,$02,$FF
SpritePlayer71Data:
	.db $08
	.db $0C,$E5,$02,$FD
	.db $EC,$C1,$02,$F4
	.db $EC,$C3,$02,$FC
	.db $EC,$C5,$02,$04
	.db $FC,$DD,$02,$EE
	.db $FC,$DF,$02,$F6
	.db $FC,$E1,$02,$FE
	.db $0C,$E3,$02,$F5
SpritePlayer72Data:
	.db $08
	.db $0C,$E9,$02,$FC
	.db $EC,$DB,$02,$F4
	.db $EC,$DD,$02,$FC
	.db $EC,$DF,$02,$04
	.db $FC,$E1,$02,$F0
	.db $FC,$E3,$02,$F8
	.db $FC,$E5,$02,$00
	.db $0C,$E7,$02,$F4
SpritePlayer73Data:
	.db $09
	.db $0C,$E9,$02,$01
	.db $EC,$D9,$02,$F4
	.db $EC,$DB,$02,$FC
	.db $EC,$DD,$02,$04
	.db $FC,$DF,$02,$F4
	.db $FC,$E1,$02,$FC
	.db $FC,$E3,$02,$04
	.db $0C,$E5,$02,$F1
	.db $0C,$E7,$02,$F9
SpritePlayer74Data:
	.db $09
	.db $0C,$D1,$02,$02
	.db $EC,$C1,$02,$F4
	.db $EC,$C3,$02,$FC
	.db $EC,$C5,$02,$04
	.db $FC,$C7,$02,$F4
	.db $FC,$C9,$02,$FC
	.db $FC,$CB,$02,$04
	.db $0C,$CD,$02,$F2
	.db $0C,$CF,$02,$FA
;Monster stopping with key
SpritePlayer75Data:
	.db $08
	.db $0C,$E9,$02,$04
	.db $EC,$DB,$02,$F4
	.db $EC,$DD,$02,$FC
	.db $EC,$DF,$02,$04
	.db $FC,$E1,$02,$F4
	.db $FC,$E3,$02,$FC
	.db $0C,$E5,$02,$F4
	.db $0C,$E7,$02,$FC
;Monster throwing key
SpritePlayer76Data:
	.db $08
	.db $0A,$ED,$02,$02
	.db $EA,$DF,$02,$EE
	.db $EA,$E1,$02,$F6
	.db $EA,$E3,$02,$FE
	.db $FA,$E5,$02,$F3
	.db $FA,$E7,$02,$FB
	.db $0A,$E9,$02,$F2
	.db $0A,$EB,$02,$FA
SpritePlayer77Data:
	.db $0A
	.db $10,$EF,$02,$07
	.db $08,$DD,$02,$EF
	.db $F8,$DF,$02,$F7
	.db $F0,$E1,$02,$FF
	.db $F0,$E3,$02,$07
	.db $F8,$E5,$02,$0F
	.db $08,$E7,$02,$F7
	.db $00,$E9,$02,$FF
	.db $00,$EB,$02,$07
	.db $10,$ED,$02,$FF
;Monster duck throwing key
SpritePlayer78Data:
	.db $06
	.db $08,$F7,$02,$FE
	.db $F8,$DF,$02,$EE
	.db $F8,$EF,$02,$F6
	.db $F8,$F1,$02,$FE
	.db $08,$F3,$02,$EE
	.db $08,$F5,$02,$F6
SpritePlayer79Data:
	.db $07
	.db $03,$E5,$02,$0E
	.db $FB,$F1,$02,$F6
	.db $FB,$E1,$02,$FE
	.db $FB,$E3,$02,$06
	.db $0B,$F3,$02,$F6
	.db $0B,$F5,$02,$FE
	.db $0B,$F7,$02,$06
;Monster fire
SpritePlayer7AData:
	.db $03
	.db $F6,$79,$00,$FE
	.db $F6,$55,$00,$EE
	.db $F6,$57,$00,$F6
SpritePlayer7BData:
	.db $04
	.db $FE,$4B,$80,$04
	.db $EE,$49,$00,$FC
	.db $EE,$4B,$00,$04
	.db $FE,$49,$80,$FC
SpritePlayer7CData:
	.db $04
	.db $FE,$4F,$80,$04
	.db $EE,$4D,$00,$FC
	.db $EE,$4F,$00,$04
	.db $FE,$4D,$80,$FC
SpritePlayer7DData:
	.db $04
	.db $FE,$53,$80,$05
	.db $EB,$51,$00,$FD
	.db $EE,$53,$00,$05
	.db $03,$51,$80,$FD
SpritePlayer7EData:
	.db $04
	.db $E6,$59,$00,$00
	.db $EE,$5B,$00,$08
	.db $06,$59,$80,$00
	.db $FE,$5B,$80,$08
;Title screen pocket bulge
SpritePlayer7FData:
	.db $04
	.db $F0,$2F,$00,$F6
	.db $F0,$03,$00,$FE
	.db $00,$05,$00,$F6
	.db $00,$07,$00,$FE
SpritePlayer80Data:
	.db $05
	.db $F0,$09,$00,$F0
	.db $F0,$0B,$00,$F8
	.db $F0,$0D,$00,$00
	.db $00,$0F,$00,$F8
	.db $00,$11,$00,$00
SpritePlayer81Data:
	.db $06
	.db $F0,$13,$00,$F0
	.db $F0,$15,$00,$F8
	.db $F0,$17,$00,$00
	.db $00,$19,$00,$F8
	.db $00,$1B,$00,$00
	.db $F8,$1D,$00,$08
;Title screen pocket monster hands
SpritePlayer82Data:
	.db $03
	.db $F8,$1F,$01,$F4
	.db $F8,$21,$01,$FC
	.db $F8,$23,$01,$04
;Title screen pocket monster eyes
SpritePlayer83Data:
	.db $02
	.db $F8,$27,$02,$F6
	.db $F8,$27,$42,$02
SpritePlayer84Data:
	.db $02
	.db $F8,$25,$02,$F6
	.db $F8,$25,$42,$02
SpritePlayer85Data:
	.db $02
	.db $F8,$25,$02,$F6
	.db $F8,$25,$02,$02
SpritePlayer86Data:
	.db $02
	.db $F8,$25,$42,$F6
	.db $F8,$25,$42,$02
SpritePlayer87Data:
	.db $02
	.db $F8,$29,$02,$F6
	.db $F8,$29,$02,$02
SpritePlayer88Data:
	.db $02
	.db $F8,$29,$82,$F6
	.db $F8,$29,$82,$02
SpritePlayer89Data:
	.db $02
	.db $F8,$29,$42,$F6
	.db $F8,$29,$42,$02
SpritePlayer8AData:
	.db $02
	.db $F8,$29,$C2,$F6
	.db $F8,$29,$C2,$02
;Title screen pocket enemies
SpritePlayer8BData:
	.db $06
	.db $F0,$5F,$02,$F9
	.db $F0,$61,$02,$01
	.db $F0,$63,$02,$09
	.db $00,$65,$02,$F4
	.db $00,$67,$02,$FC
	.db $00,$69,$02,$04
SpritePlayer8CData:
	.db $06
	.db $01,$CB,$01,$07
	.db $F1,$C3,$01,$FF
	.db $F1,$C5,$01,$07
	.db $01,$C7,$01,$F7
	.db $01,$C9,$01,$FF
	.db $F1,$C1,$01,$F7
SpritePlayer8DData:
	.db $06
	.db $00,$4B,$01,$04
	.db $F0,$41,$01,$F4
	.db $F0,$43,$01,$FC
	.db $F0,$45,$01,$04
	.db $00,$47,$01,$F4
	.db $00,$49,$01,$FC
SpritePlayer8EData:
	.db $08
	.db $00,$A5,$02,$F0
	.db $F0,$A1,$42,$08
	.db $00,$A5,$42,$08
	.db $F0,$A1,$02,$F0
	.db $F0,$A3,$02,$F8
	.db $00,$A7,$02,$F8
	.db $F0,$A3,$42,$00
	.db $00,$A7,$42,$00
SpritePlayer8FData:
	.db $06
	.db $F0,$E5,$03,$F8
	.db $F0,$E7,$03,$00
	.db $00,$EB,$03,$F8
	.db $00,$ED,$03,$00
	.db $FB,$E3,$03,$F0
	.db $FC,$E9,$03,$08
SpritePlayer90Data:
	.db $07
	.db $01,$4D,$01,$08
	.db $F1,$41,$01,$F8
	.db $F1,$43,$01,$00
	.db $00,$47,$01,$F0
	.db $F1,$45,$01,$08
	.db $01,$49,$01,$F8
	.db $01,$4B,$01,$00
SpritePlayer91Data:
	.db $07
	.db $F0,$8B,$02,$F5
	.db $F0,$8D,$02,$FD
	.db $F0,$8F,$02,$05
	.db $F0,$91,$02,$0D
	.db $00,$93,$02,$F5
	.db $00,$95,$02,$FD
	.db $00,$97,$02,$05
;Player select vampire eye
SpritePlayer92Data:
	.db $03
	.db $F8,$31,$00,$F4
	.db $F8,$33,$00,$FC
	.db $F8,$35,$00,$04
SpritePlayer93Data:
	.db $03
	.db $F8,$37,$00,$F4
	.db $F8,$39,$00,$FC
	.db $F8,$3B,$00,$04
SpritePlayer94Data:
	.db $03
	.db $F8,$3D,$00,$F4
	.db $F8,$3F,$00,$FC
	.db $F8,$AB,$00,$04
SpritePlayer95Data:
	.db $03
	.db $F8,$AD,$00,$F4
	.db $F8,$AF,$00,$FC
	.db $F8,$B1,$00,$04
;Player select monster eye
SpritePlayer96Data:
	.db $02
	.db $F8,$B5,$01,$F6
	.db $F8,$B7,$01,$FE
SpritePlayer97Data:
	.db $02
	.db $F8,$B9,$01,$F6
	.db $F8,$BB,$01,$FE
SpritePlayer98Data:
	.db $02
	.db $F8,$BD,$01,$F6
	.db $F8,$BF,$01,$FE
;Player select vampire fang
SpritePlayer99Data:
	.db $01
	.db $F8,$B3,$00,$FC
;Intro/ending vampire sitting
SpritePlayer9AData:
	.db $07
	.db $0D,$87,$41,$0A
	.db $FD,$99,$01,$F6
	.db $FD,$83,$01,$FE
	.db $FD,$85,$01,$06
	.db $0D,$87,$01,$F2
	.db $0D,$89,$01,$FA
	.db $0D,$8B,$01,$02
;Intro/ending vampire standing
SpritePlayer9BData:
	.db $08
	.db $F8,$95,$01,$09
	.db $08,$97,$01,$F5
	.db $08,$A1,$01,$FD
	.db $08,$A3,$01,$05
	.db $F8,$91,$01,$F9
	.db $F8,$93,$01,$01
	.db $E8,$8D,$01,$FA
	.db $E8,$8F,$01,$02
SpritePlayer9CData:
	.db $08
	.db $F8,$95,$01,$09
	.db $08,$A9,$01,$F5
	.db $08,$AB,$01,$FD
	.db $08,$A3,$01,$05
	.db $F8,$A7,$01,$01
	.db $E8,$8D,$01,$FA
	.db $E8,$8F,$01,$02
	.db $F8,$A5,$01,$F9
SpritePlayer9DData:
	.db $09
	.db $08,$B7,$01,$05
	.db $E8,$8F,$01,$02
	.db $E8,$8D,$01,$FA
	.db $F8,$AD,$01,$F1
	.db $F8,$AF,$01,$F9
	.db $F8,$B1,$01,$01
	.db $F8,$95,$01,$09
	.db $08,$B3,$01,$F5
	.db $08,$B5,$01,$FD
;Intro/ending monster sitting
SpritePlayer9EData:
	.db $07
	.db $FA,$C5,$02,$00
	.db $0A,$C7,$02,$EC
	.db $0A,$C9,$02,$F4
	.db $0A,$CB,$02,$FC
	.db $0A,$CD,$02,$04
	.db $FA,$C1,$02,$F0
	.db $FA,$C3,$02,$F8
;Intro/ending monster standing
SpritePlayer9FData:
	.db $09
	.db $08,$DF,$02,$00
	.db $E8,$CF,$02,$F0
	.db $E8,$D1,$02,$F8
	.db $E8,$D3,$02,$00
	.db $F8,$D5,$02,$F0
	.db $F8,$D7,$02,$F8
	.db $F8,$D9,$02,$00
	.db $08,$DB,$02,$F0
	.db $08,$DD,$02,$F8

SpriteDataEnemyPointerTable:
	.dw SpriteEnemy01Data	;$01 \Explosion
	.dw SpriteEnemy02Data	;$02 |
	.dw SpriteEnemy03Data	;$03 |
	.dw SpriteEnemy04Data	;$04 |
	.dw SpriteEnemy05Data	;$05 /
	.dw SpriteEnemy06Data	;$06  Item HP
	.dw SpriteEnemy07Data	;$07  Explosion
	.dw SpriteEnemy08Data	;$08  Nothing
	.dw SpriteEnemy09Data	;$09 \Beast walking
	.dw SpriteEnemy0AData	;$0A |
	.dw SpriteEnemy0BData	;$0B /
	.dw SpriteEnemy0CData	;$0C \Zombie walking
	.dw SpriteEnemy0DData	;$0D /
	.dw SpriteEnemy0EData	;$0E \Skeleton walking
	.dw SpriteEnemy0FData	;$0F |
	.dw SpriteEnemy10Data	;$10 /
	.dw SpriteEnemy11Data	;$11 \Skeleton throwing skull
	.dw SpriteEnemy12Data	;$12 /
	.dw SpriteEnemy13Data	;$13 \Skeleton fire
	.dw SpriteEnemy14Data	;$14 |
	.dw SpriteEnemy15Data	;$15 |
	.dw SpriteEnemy16Data	;$16 /
	.dw SpriteEnemy17Data	;$17  Witch idle
	.dw SpriteEnemy18Data	;$18  Witch attacking
	.dw SpriteEnemy19Data	;$19 \Witch fire
	.dw SpriteEnemy1AData	;$1A /
	.dw SpriteEnemy1BData	;$1B \Winged panther flying
	.dw SpriteEnemy1CData	;$1C /
	.dw SpriteEnemy1DData	;$1D  Hunchback standing
	.dw SpriteEnemy1EData	;$1E  Hunchback jumping
	.dw SpriteEnemy1FData	;$1F \Hunchback punching
	.dw SpriteEnemy20Data	;$20 /
	.dw SpriteEnemy21Data	;$21 \Ghost flying
	.dw SpriteEnemy22Data	;$22 /
	.dw SpriteEnemy07Data	;$23  Explosion
	.dw SpriteEnemy24Data	;$24 \Ogre walking
	.dw SpriteEnemy25Data	;$25 /
	.dw SpriteEnemy26Data	;$26 \Cerberus walking
	.dw SpriteEnemy27Data	;$27 /
	.dw SpriteEnemy28Data	;$28  Goblin idle
	.dw SpriteEnemy29Data	;$29  Goblin throwing
	.dw SpriteEnemy2AData	;$2A \Goblin fire
	.dw SpriteEnemy2BData	;$2B /
	.dw SpriteEnemy2CData	;$2C \Roc flying
	.dw SpriteEnemy2DData	;$2D /
	.dw SpriteEnemy2EData	;$2E \Roc fire
	.dw SpriteEnemy2FData	;$2F /
	.dw SpriteEnemy30Data	;$30 \Ghoul walking
	.dw SpriteEnemy31Data	;$31 /
	.dw SpriteEnemy32Data	;$32  Ghoul throwing
	.dw SpriteEnemy33Data	;$33 \Hydra flying
	.dw SpriteEnemy34Data	;$34 /
	.dw SpriteEnemy35Data	;$35 \Hydra fire
	.dw SpriteEnemy36Data	;$36 |
	.dw SpriteEnemy37Data	;$37 /
	.dw SpriteEnemy38Data	;$38 \Golf ball
	.dw SpriteEnemy39Data	;$39 /
	.dw SpriteEnemy3AData	;$3A \Catoblepas flying
	.dw SpriteEnemy3BData	;$3B /
	.dw SpriteEnemy3CData	;$3C  Charon falling
	.dw SpriteEnemy3DData	;$3D \Charon walking
	.dw SpriteEnemy3EData	;$3E /
	.dw SpriteEnemy3FData	;$3F  Level 3 platform
	.dw SpriteEnemy40Data	;$40 \Triton flying
	.dw SpriteEnemy41Data	;$41 |
	.dw SpriteEnemy42Data	;$42 /
	.dw SpriteEnemy43Data	;$43 \Triton splash
	.dw SpriteEnemy44Data	;$44 /
	.dw SpriteEnemy45Data	;$45 \Haniver appearing
	.dw SpriteEnemy46Data	;$46 /
	.dw SpriteEnemy47Data	;$47 \Haniver attacking
	.dw SpriteEnemy48Data	;$48 /
	.dw SpriteEnemy49Data	;$49 \Haniver fire
	.dw SpriteEnemy4AData	;$4A |
	.dw SpriteEnemy4BData	;$4B /
	.dw SpriteEnemy4CData	;$4C \Kali fire
	.dw SpriteEnemy4DData	;$4D |
	.dw SpriteEnemy4EData	;$4E |
	.dw SpriteEnemy4FData	;$4F |
	.dw SpriteEnemy50Data	;$50 /
	.dw SpriteEnemy51Data	;$51 \Stove flame
	.dw SpriteEnemy52Data	;$52 |
	.dw SpriteEnemy53Data	;$53 |
	.dw SpriteEnemy54Data	;$54 /
	.dw SpriteEnemy55Data	;$55 \Ghoul fire
	.dw SpriteEnemy56Data	;$56 |
	.dw SpriteEnemy57Data	;$57 |
	.dw SpriteEnemy58Data	;$58 /
	.dw SpriteEnemy59Data	;$59 \Baba Yaga flying
	.dw SpriteEnemy5AData	;$5A /
	.dw SpriteEnemy5BData	;$5B \Harpy flying
	.dw SpriteEnemy5CData	;$5C /
	.dw SpriteEnemy5DData	;$5D  Red Cap idle
	.dw SpriteEnemy5EData	;$5E  Red Cap walking
	.dw SpriteEnemy5FData	;$5F  Red Cap attacking
	.dw SpriteEnemy60Data	;$60 \Hobgoblin walking
	.dw SpriteEnemy61Data	;$61 /
	.dw SpriteEnemy62Data	;$62 \Chimera walking
	.dw SpriteEnemy63Data	;$63 /
	.dw SpriteEnemy64Data	;$64 \Chimera fire
	.dw SpriteEnemy65Data	;$65 |
	.dw SpriteEnemy66Data	;$66 /
	.dw SpriteEnemy67Data	;$67 \Kali idle
	.dw SpriteEnemy68Data	;$68 /
	.dw SpriteEnemy69Data	;$69 \Kali attacking
	.dw SpriteEnemy6AData	;$6A /
	.dw SpriteEnemy6BData	;$6B  Cyclops falling
	.dw SpriteEnemy6CData	;$6C \Cyclops walking
	.dw SpriteEnemy6DData	;$6D /
	.dw SpriteEnemy6EData	;$6E \Manticore walking
	.dw SpriteEnemy6FData	;$6F /
	.dw SpriteEnemy70Data	;$70 \Manticore fire
	.dw SpriteEnemy71Data	;$71 |
	.dw SpriteEnemy72Data	;$72 |
	.dw SpriteEnemy73Data	;$73 |
	.dw SpriteEnemy74Data	;$74 /
	.dw SpriteEnemy75Data	;$75 \Karnack walking
	.dw SpriteEnemy76Data	;$76 |
	.dw SpriteEnemy77Data	;$77 /
	.dw SpriteEnemy78Data	;$78 \Tengu flying
	.dw SpriteEnemy79Data	;$79 /
	.dw SpriteEnemy7AData	;$7A  Tengu punching
	.dw SpriteEnemy7BData	;$7B \Cockatrice flying
	.dw SpriteEnemy7CData	;$7C /
	.dw SpriteEnemy7DData	;$7D \Cockatrice fire
	.dw SpriteEnemy7EData	;$7E |
	.dw SpriteEnemy7FData	;$7F /
	.dw SpriteEnemy80Data	;$80 \Coatlicue walking
	.dw SpriteEnemy81Data	;$81 /
	.dw SpriteEnemy82Data	;$82  Behemoth falling
	.dw SpriteEnemy83Data	;$83 \Behemoth walking
	.dw SpriteEnemy84Data	;$84 /
	.dw SpriteEnemy85Data	;$85 \T-Rex walking
	.dw SpriteEnemy86Data	;$86 |
	.dw SpriteEnemy85Data	;$87 /
	.dw SpriteEnemy88Data	;$88 \T-Rex fire
	.dw SpriteEnemy89Data	;$89 |
	.dw SpriteEnemy8AData	;$8A |
	.dw SpriteEnemy8BData	;$8B /
	.dw SpriteEnemy8CData	;$8C \Great Beast flying
	.dw SpriteEnemy8DData	;$8D /
	.dw SpriteEnemy8EData	;$8E \Water drop
	.dw SpriteEnemy8FData	;$8F |
	.dw SpriteEnemy90Data	;$90 |
	.dw SpriteEnemy91Data	;$91 /
	.dw SpriteEnemy92Data	;$92 \Great Beast fire
	.dw SpriteEnemy93Data	;$93 |
	.dw SpriteEnemy94Data	;$94 |
	.dw SpriteEnemy95Data	;$95 |
	.dw SpriteEnemy96Data	;$96 |
	.dw SpriteEnemy97Data	;$97 |
	.dw SpriteEnemy98Data	;$98 |
	.dw SpriteEnemy99Data	;$99 |
	.dw SpriteEnemy9AData	;$9A |
	.dw SpriteEnemy9BData	;$9B |
	.dw SpriteEnemy9CData	;$9C |
	.dw SpriteEnemy9DData	;$9D |
	.dw SpriteEnemy9EData	;$9E |
	.dw SpriteEnemy9FData	;$9F |
	.dw SpriteEnemyA0Data	;$A0 |
	.dw SpriteEnemyA1Data	;$A1 |
	.dw SpriteEnemyA2Data	;$A2 |
	.dw SpriteEnemyA3Data	;$A3 /
	.dw SpriteEnemyA4Data	;$A4 \Minotaur walking
	.dw SpriteEnemyA5Data	;$A5 /

;Nothing
SpriteEnemy08Data:
	.db $00
;Beast walking
SpriteEnemy09Data:
	.db $06
	.db $00,$0B,$01,$02
	.db $F0,$03,$01,$FA
	.db $F0,$05,$01,$02
	.db $00,$07,$01,$F2
	.db $00,$09,$01,$FA
	.db $F0,$01,$01,$F2
SpriteEnemy0AData:
	.db $08
	.db $01,$1B,$01,$06
	.db $F1,$0D,$01,$EE
	.db $F1,$0F,$01,$F6
	.db $F1,$11,$01,$FE
	.db $F1,$13,$01,$06
	.db $01,$15,$01,$EE
	.db $01,$17,$01,$F6
	.db $01,$19,$01,$FE
SpriteEnemy0BData:
	.db $07
	.db $01,$29,$01,$01
	.db $F1,$1F,$01,$FD
	.db $F1,$21,$01,$05
	.db $F1,$23,$01,$0D
	.db $F1,$1D,$01,$F5
	.db $01,$25,$01,$F1
	.db $01,$27,$01,$F9
;Zombie walking
SpriteEnemy0CData:
	.db $08
	.db $11,$35,$02,$FC
	.db $F3,$2D,$02,$08
	.db $11,$33,$02,$F4
	.db $11,$37,$02,$04
	.db $01,$2F,$02,$F8
	.db $F1,$29,$02,$F8
	.db $F1,$2B,$02,$00
	.db $01,$31,$02,$00
SpriteEnemy0DData:
	.db $07
	.db $F2,$2D,$02,$08
	.db $F0,$29,$02,$F8
	.db $00,$39,$02,$F8
	.db $00,$3B,$02,$00
	.db $10,$3D,$02,$F8
	.db $10,$3F,$02,$00
	.db $F0,$2B,$02,$00
;Skeleton walking
SpriteEnemy0EData:
	.db $06
	.db $F0,$01,$01,$F5
	.db $F0,$03,$01,$FD
	.db $F0,$05,$01,$05
	.db $00,$07,$01,$F5
	.db $00,$09,$01,$FD
	.db $00,$0B,$01,$05
SpriteEnemy0FData:
	.db $06
	.db $01,$15,$01,$06
	.db $F1,$0D,$01,$F6
	.db $F1,$0F,$01,$FE
	.db $F1,$05,$01,$06
	.db $01,$11,$01,$F6
	.db $01,$13,$01,$FE
SpriteEnemy10Data:
	.db $05
	.db $01,$19,$01,$FF
	.db $F1,$01,$01,$F5
	.db $F1,$03,$01,$FD
	.db $F1,$05,$01,$05
	.db $01,$17,$01,$F7
;Skeleton throwing skull
SpriteEnemy11Data:
	.db $05
	.db $02,$1F,$01,$FF
	.db $F2,$1B,$01,$F6
	.db $F2,$0F,$01,$FE
	.db $F2,$05,$01,$06
	.db $02,$1D,$01,$F7
SpriteEnemy12Data:
	.db $06
	.db $00,$23,$01,$06
	.db $F0,$01,$01,$F6
	.db $F0,$03,$01,$FE
	.db $F0,$05,$01,$06
	.db $00,$07,$01,$F6
	.db $00,$21,$01,$FE
;Skeleton fire
SpriteEnemy13Data:
	.db $02
	.db $F8,$25,$01,$F9
	.db $F8,$27,$01,$01
SpriteEnemy14Data:
	.db $02
	.db $F8,$25,$41,$00
	.db $F8,$27,$41,$F8
SpriteEnemy15Data:
	.db $02
	.db $F9,$25,$C1,$00
	.db $F9,$27,$C1,$F8
SpriteEnemy16Data:
	.db $02
	.db $F9,$27,$81,$01
	.db $F9,$25,$81,$F9
;Witch idle
SpriteEnemy17Data:
	.db $07
	.db $F0,$01,$02,$F9
	.db $F0,$03,$02,$01
	.db $F0,$05,$02,$09
	.db $00,$07,$02,$F1
	.db $00,$09,$02,$F9
	.db $00,$0B,$02,$01
	.db $00,$0D,$02,$09
;Witch attacking
SpriteEnemy18Data:
	.db $08
	.db $F0,$0F,$02,$F9
	.db $F0,$11,$02,$01
	.db $F0,$13,$02,$09
	.db $F0,$15,$02,$11
	.db $00,$17,$02,$F1
	.db $00,$19,$02,$F9
	.db $00,$1B,$02,$01
	.db $00,$1D,$02,$09
;Witch fire
SpriteEnemy19Data:
	.db $02
	.db $F8,$1F,$00,$F9
	.db $F8,$1F,$40,$01
SpriteEnemy1AData:
	.db $02
	.db $F8,$21,$02,$F9
	.db $F8,$21,$42,$01
;Winged panther flying
SpriteEnemy1BData:
	.db $06
	.db $F0,$2D,$03,$03
	.db $F0,$2B,$03,$FB
	.db $00,$2F,$03,$EF
	.db $00,$31,$03,$F7
	.db $00,$33,$03,$FF
	.db $00,$35,$03,$07
SpriteEnemy1CData:
	.db $05
	.db $FD,$39,$03,$FF
	.db $FE,$2F,$03,$EF
	.db $FE,$37,$03,$F7
	.db $F8,$3B,$03,$07
	.db $08,$3D,$03,$07
;Hunchback standing
SpriteEnemy1DData:
	.db $05
	.db $00,$2B,$01,$00
	.db $F0,$25,$01,$FF
	.db $F0,$27,$01,$07
	.db $F0,$23,$01,$F7
	.db $00,$29,$01,$F8
;Hunchback jumping
SpriteEnemy1EData:
	.db $06
	.db $00,$31,$01,$06
	.db $F0,$23,$01,$F6
	.db $F0,$25,$01,$FE
	.db $F0,$27,$01,$06
	.db $00,$2D,$01,$F6
	.db $00,$2F,$01,$FE
;Hunchback punching
SpriteEnemy1FData:
	.db $07
	.db $00,$3F,$01,$01
	.db $F0,$35,$01,$FD
	.db $F0,$37,$01,$05
	.db $F0,$39,$01,$0D
	.db $F0,$33,$01,$F5
	.db $00,$3B,$01,$F1
	.db $00,$3D,$01,$F9
SpriteEnemy20Data:
	.db $05
	.db $00,$2B,$01,$F6
	.db $F0,$25,$01,$F5
	.db $F0,$27,$01,$FD
	.db $F0,$23,$01,$ED
	.db $00,$29,$01,$EE
;Ghost flying
SpriteEnemy21Data:
	.db $06
	.db $F0,$1F,$02,$F9
	.db $F0,$21,$02,$01
	.db $F0,$23,$02,$09
	.db $00,$25,$02,$F4
	.db $00,$27,$02,$FC
	.db $00,$29,$02,$04
SpriteEnemy22Data:
	.db $06
	.db $F0,$2F,$02,$08
	.db $F0,$2B,$02,$F8
	.db $F0,$2D,$02,$00
	.db $00,$31,$02,$F4
	.db $00,$33,$02,$FC
	.db $00,$35,$02,$04
;Ogre walking
SpriteEnemy24Data:
	.db $0A
	.db $E4,$01,$01,$F5
	.db $E4,$03,$01,$FD
	.db $E4,$05,$01,$05
	.db $F4,$09,$01,$F5
	.db $F4,$0B,$01,$FD
	.db $F4,$0D,$01,$05
	.db $04,$0F,$01,$F5
	.db $04,$11,$01,$FD
	.db $04,$13,$01,$05
	.db $F0,$07,$01,$0D
SpriteEnemy25Data:
	.db $0A
	.db $03,$1D,$01,$09
	.db $E3,$01,$01,$F5
	.db $E3,$03,$01,$FD
	.db $E3,$05,$01,$05
	.db $F3,$37,$01,$F5
	.db $F3,$39,$01,$FD
	.db $F3,$15,$01,$05
	.db $03,$19,$01,$F9
	.db $03,$1B,$01,$01
	.db $F3,$17,$01,$0D
;Cerberus walking
SpriteEnemy26Data:
	.db $08
	.db $F0,$23,$03,$F0
	.db $F0,$25,$03,$F8
	.db $F0,$27,$03,$00
	.db $F0,$29,$03,$08
	.db $00,$2B,$03,$F0
	.db $00,$2D,$03,$F8
	.db $00,$2F,$03,$00
	.db $00,$31,$03,$08
SpriteEnemy27Data:
	.db $07
	.db $00,$3F,$03,$05
	.db $F0,$35,$03,$F8
	.db $F0,$37,$03,$00
	.db $F0,$39,$03,$08
	.db $F0,$33,$03,$F0
	.db $00,$3B,$03,$F5
	.db $00,$3D,$03,$FD
;Goblin idle
SpriteEnemy28Data:
	.db $05
	.db $F0,$03,$02,$02
	.db $F0,$01,$02,$FA
	.db $00,$05,$02,$F5
	.db $00,$07,$02,$FD
	.db $00,$09,$02,$05
;Goblin throwing
SpriteEnemy29Data:
	.db $07
	.db $F0,$0B,$02,$F5
	.db $F0,$0D,$02,$FD
	.db $F0,$0F,$02,$05
	.db $F0,$11,$02,$0D
	.db $00,$13,$02,$F5
	.db $00,$15,$02,$FD
	.db $00,$17,$02,$05
;Goblin fire
SpriteEnemy2AData:
	.db $02
	.db $F8,$19,$02,$F8
	.db $F8,$1B,$02,$00
SpriteEnemy2BData:
	.db $03
	.db $F5,$21,$02,$04
	.db $F2,$1D,$02,$F4
	.db $F4,$1F,$02,$FC
;Roc flying
SpriteEnemy2CData:
	.db $06
	.db $F0,$25,$03,$F8
	.db $F0,$27,$03,$00
	.db $00,$2B,$03,$F8
	.db $00,$2D,$03,$00
	.db $FB,$23,$03,$F0
	.db $FC,$29,$03,$08
SpriteEnemy2DData:
	.db $06
	.db $FA,$23,$03,$F0
	.db $F0,$31,$03,$00
	.db $EF,$2F,$03,$F8
	.db $FF,$2B,$03,$F8
	.db $00,$35,$03,$00
	.db $FC,$33,$03,$08
;Roc fire
SpriteEnemy2EData:
	.db $08
	.db $00,$37,$01,$F0
	.db $00,$3B,$01,$00
	.db $00,$3D,$01,$08
	.db $F0,$37,$81,$F0
	.db $F0,$39,$81,$F8
	.db $F0,$3B,$81,$00
	.db $F0,$3D,$81,$08
	.db $00,$39,$01,$F8
SpriteEnemy2FData:
	.db $08
	.db $F0,$37,$81,$F0
	.db $F0,$39,$81,$F8
	.db $F0,$3B,$81,$00
	.db $F0,$3D,$81,$08
	.db $00,$3D,$01,$08
	.db $00,$3B,$01,$00
	.db $00,$3F,$01,$F8
	.db $00,$37,$01,$F0
;Ghoul walking
SpriteEnemy30Data:
	.db $06
	.db $01,$0B,$01,$07
	.db $F1,$03,$01,$FF
	.db $F1,$05,$01,$07
	.db $01,$07,$01,$F7
	.db $01,$09,$01,$FF
	.db $F1,$01,$01,$F7
SpriteEnemy31Data:
	.db $05
	.db $F0,$01,$01,$F7
	.db $F0,$03,$01,$FF
	.db $00,$0D,$01,$FB
	.db $F0,$05,$01,$07
	.db $00,$0F,$01,$03
;Ghoul throwing
SpriteEnemy32Data:
	.db $07
	.db $F8,$17,$01,$10
	.db $F0,$13,$01,$00
	.db $F0,$15,$01,$08
	.db $00,$19,$01,$F5
	.db $F0,$11,$01,$F8
	.db $00,$1B,$01,$FD
	.db $00,$1D,$01,$05
;Unreferenced sprite data???
	.db $02
	.db $F8,$1F,$01,$F8
	.db $F8,$21,$01,$00
;Hydra flying
SpriteEnemy33Data:
	.db $08
	.db $02,$09,$03,$F1
	.db $F0,$15,$03,$01
	.db $F0,$17,$03,$09
	.db $F2,$01,$03,$F1
	.db $F0,$03,$03,$F9
	.db $00,$0B,$03,$F9
	.db $00,$19,$03,$01
	.db $00,$1B,$03,$09
SpriteEnemy34Data:
	.db $07
	.db $F6,$07,$03,$09
	.db $F0,$11,$03,$F9
	.db $F1,$0F,$03,$F1
	.db $EF,$05,$03,$01
	.db $00,$13,$03,$F9
	.db $01,$09,$03,$F1
	.db $FF,$0D,$03,$01
;Hydra fire
SpriteEnemy35Data:
	.db $02
	.db $F8,$1D,$02,$F8
	.db $F8,$1F,$02,$00
SpriteEnemy36Data:
	.db $02
	.db $F8,$3D,$02,$F7
	.db $F8,$1F,$02,$FF
SpriteEnemy37Data:
	.db $02
	.db $F8,$3F,$02,$F8
	.db $F8,$3F,$42,$00
;Golf ball
SpriteEnemy38Data:
	.db $08
	.db $F0,$21,$02,$F0
	.db $F0,$23,$02,$F8
	.db $F0,$25,$02,$00
	.db $F0,$27,$02,$08
	.db $00,$29,$02,$F0
	.db $00,$2B,$02,$F8
	.db $00,$2D,$02,$00
	.db $00,$2F,$02,$08
SpriteEnemy39Data:
	.db $08
	.db $F0,$21,$02,$F0
	.db $F0,$23,$02,$F8
	.db $F0,$31,$02,$00
	.db $F0,$33,$02,$08
	.db $00,$35,$02,$F0
	.db $00,$37,$02,$F8
	.db $00,$39,$02,$00
	.db $00,$3B,$02,$08
;Catoblepas flying
SpriteEnemy3AData:
	.db $07
	.db $FE,$0D,$01,$09
	.db $F0,$03,$01,$F9
	.db $F0,$05,$01,$01
	.db $00,$07,$01,$F1
	.db $00,$09,$01,$F9
	.db $00,$0B,$01,$01
	.db $F0,$01,$01,$F1
SpriteEnemy3BData:
	.db $07
	.db $FD,$0D,$01,$09
	.db $F0,$11,$01,$F9
	.db $F0,$13,$01,$01
	.db $00,$15,$01,$F1
	.db $00,$17,$01,$F9
	.db $00,$1D,$01,$01
	.db $F0,$0F,$01,$F1
;Charon falling
SpriteEnemy3CData:
	.db $06
	.db $00,$0B,$01,$04
	.db $F0,$01,$01,$F4
	.db $F0,$03,$01,$FC
	.db $F0,$05,$01,$04
	.db $00,$07,$01,$F4
	.db $00,$09,$01,$FC
;Charon walking
SpriteEnemy3DData:
	.db $06
	.db $01,$17,$01,$04
	.db $F1,$0D,$01,$F4
	.db $F1,$0F,$01,$FC
	.db $F1,$11,$01,$04
	.db $01,$13,$01,$F4
	.db $01,$15,$01,$FC
SpriteEnemy3EData:
	.db $06
	.db $F0,$0D,$01,$F4
	.db $F0,$0F,$01,$FC
	.db $F0,$11,$01,$04
	.db $00,$19,$01,$F4
	.db $00,$1B,$01,$FC
	.db $00,$1D,$01,$04
;Level 3 platform
SpriteEnemy3FData:
	.db $0C
	.db $F1,$39,$01,$E8
	.db $F1,$3B,$01,$F0
	.db $F1,$3D,$01,$F8
	.db $F1,$39,$41,$10
	.db $F1,$3B,$41,$08
	.db $F1,$35,$01,$00
	.db $01,$39,$81,$E8
	.db $01,$3B,$81,$F0
	.db $01,$3D,$81,$F8
	.db $01,$39,$C1,$10
	.db $01,$3B,$C1,$08
	.db $01,$35,$81,$00
;Triton flying
SpriteEnemy40Data:
	.db $06
	.db $EE,$21,$03,$F1
	.db $F0,$23,$03,$F9
	.db $F0,$25,$03,$01
	.db $00,$27,$03,$F1
	.db $00,$29,$03,$F9
	.db $00,$2B,$03,$01
SpriteEnemy41Data:
	.db $06
	.db $EE,$21,$03,$F1
	.db $F0,$23,$03,$F9
	.db $F0,$2D,$03,$01
	.db $00,$2F,$03,$F1
	.db $00,$31,$03,$F9
	.db $00,$2B,$03,$01
SpriteEnemy42Data:
	.db $06
	.db $F0,$21,$03,$F1
	.db $F0,$33,$03,$F9
	.db $F0,$2D,$03,$01
	.db $00,$27,$03,$F1
	.db $00,$29,$03,$F9
	.db $00,$2B,$03,$01
;Triton splash
SpriteEnemy43Data:
	.db $04
	.db $F5,$1F,$41,$08
	.db $F9,$3F,$01,$F8
	.db $F9,$1F,$01,$F0
	.db $FD,$3F,$41,$00
SpriteEnemy44Data:
	.db $04
	.db $F0,$37,$01,$00
	.db $F1,$37,$01,$F0
	.db $EC,$37,$01,$F8
	.db $F1,$37,$41,$08
;Haniver appearing
SpriteEnemy45Data:
	.db $04
	.db $00,$21,$42,$08
	.db $00,$23,$42,$00
	.db $00,$21,$02,$F0
	.db $00,$23,$02,$F8
SpriteEnemy46Data:
	.db $08
	.db $00,$25,$02,$F0
	.db $F0,$21,$42,$08
	.db $00,$25,$42,$08
	.db $F0,$21,$02,$F0
	.db $F0,$23,$02,$F8
	.db $00,$27,$02,$F8
	.db $F0,$23,$42,$00
	.db $00,$27,$42,$00
;Haniver attacking
SpriteEnemy47Data:
	.db $07
	.db $F0,$29,$02,$F8
	.db $F0,$2B,$02,$00
	.db $F0,$2D,$02,$08
	.db $00,$2F,$02,$F0
	.db $00,$31,$02,$F8
	.db $00,$33,$02,$00
	.db $00,$35,$02,$08
SpriteEnemy48Data:
	.db $07
	.db $00,$31,$02,$F8
	.db $F0,$29,$02,$F8
	.db $00,$2F,$02,$F0
	.db $F0,$37,$02,$00
	.db $F0,$39,$02,$08
	.db $00,$3B,$02,$00
	.db $00,$3D,$02,$08
;Haniver fire
SpriteEnemy49Data:
	.db $02
	.db $F8,$3F,$00,$F8
	.db $F8,$3F,$40,$00
SpriteEnemy4AData:
	.db $02
	.db $F8,$19,$00,$F8
	.db $F8,$19,$40,$00
SpriteEnemy4BData:
	.db $02
	.db $F8,$1B,$00,$F8
	.db $F8,$1B,$40,$00
;Stove flame
SpriteEnemy51Data:
	.db $04
	.db $F8,$3B,$00,$F0
	.db $F8,$3B,$00,$F8
	.db $F8,$3B,$00,$00
	.db $F8,$3B,$00,$08
SpriteEnemy52Data:
	.db $04
	.db $F8,$3B,$40,$F0
	.db $F8,$3B,$40,$F8
	.db $F8,$3B,$40,$00
	.db $F8,$3B,$40,$08
SpriteEnemy53Data:
	.db $04
	.db $F8,$3D,$00,$F0
	.db $F8,$3D,$00,$F8
	.db $F8,$3D,$00,$00
	.db $F8,$3D,$00,$08
SpriteEnemy54Data:
	.db $04
	.db $F8,$3D,$40,$F0
	.db $F8,$3D,$40,$F8
	.db $F8,$3D,$40,$00
	.db $F8,$3D,$40,$08
;Ghoul fire
SpriteEnemy55Data:
	.db $02
	.db $F8,$1F,$01,$F8
	.db $F8,$21,$01,$00
SpriteEnemy56Data:
	.db $02
	.db $F8,$1F,$81,$F8
	.db $F8,$21,$81,$00
SpriteEnemy57Data:
	.db $02
	.db $F8,$1F,$C1,$00
	.db $F8,$21,$C1,$F8
SpriteEnemy58Data:
	.db $02
	.db $F8,$1F,$41,$00
	.db $F8,$21,$41,$F8
;Baba Yaga flying
SpriteEnemy59Data:
	.db $07
	.db $00,$0D,$01,$06
	.db $F0,$05,$01,$03
	.db $F0,$07,$01,$0B
	.db $F0,$01,$01,$F3
	.db $00,$09,$01,$F6
	.db $00,$0B,$01,$FE
	.db $F0,$03,$01,$FB
SpriteEnemy5AData:
	.db $07
	.db $FF,$1B,$01,$0B
	.db $EF,$0F,$01,$F5
	.db $EF,$11,$01,$FD
	.db $FF,$19,$01,$03
	.db $FF,$15,$01,$F3
	.db $FF,$17,$01,$FB
	.db $EF,$13,$01,$05
;Harpy flying
SpriteEnemy5BData:
	.db $08
	.db $F0,$23,$03,$F8
	.db $F0,$25,$03,$00
	.db $F0,$27,$03,$08
	.db $00,$29,$03,$F0
	.db $F0,$21,$03,$F0
	.db $00,$2B,$03,$F8
	.db $00,$2D,$03,$00
	.db $00,$2F,$03,$08
SpriteEnemy5CData:
	.db $08
	.db $F0,$33,$03,$F8
	.db $F0,$35,$03,$00
	.db $F0,$37,$03,$08
	.db $00,$39,$03,$F0
	.db $00,$3B,$03,$F8
	.db $F0,$31,$03,$F0
	.db $00,$3D,$03,$00
	.db $00,$3F,$03,$08
;Red Cap idle
SpriteEnemy5DData:
	.db $06
	.db $01,$31,$01,$06
	.db $F1,$21,$01,$F6
	.db $F1,$23,$01,$FE
	.db $F1,$25,$01,$06
	.db $01,$2D,$01,$F6
	.db $01,$2F,$01,$FE
;Red Cap walking
SpriteEnemy5EData:
	.db $06
	.db $F0,$21,$01,$F6
	.db $F0,$23,$01,$FE
	.db $F0,$25,$01,$06
	.db $00,$27,$01,$F6
	.db $00,$29,$01,$FE
	.db $00,$2B,$01,$06
;Red Cap attacking
SpriteEnemy5FData:
	.db $07
	.db $F8,$33,$01,$F6
	.db $F8,$35,$01,$FE
	.db $F8,$37,$01,$06
	.db $08,$39,$01,$F6
	.db $08,$3B,$01,$FE
	.db $08,$3D,$01,$06
	.db $08,$3F,$01,$0E
;Hobgoblin walking
SpriteEnemy60Data:
	.db $07
	.db $01,$0D,$01,$08
	.db $F1,$01,$01,$F8
	.db $F1,$03,$01,$00
	.db $00,$07,$01,$F0
	.db $F1,$05,$01,$08
	.db $01,$09,$01,$F8
	.db $01,$0B,$01,$00
SpriteEnemy61Data:
	.db $06
	.db $F0,$0F,$01,$F8
	.db $F0,$11,$01,$00
	.db $F0,$13,$01,$08
	.db $00,$15,$01,$F8
	.db $00,$17,$01,$00
	.db $00,$19,$01,$08
;Chimera walking
SpriteEnemy62Data:
	.db $08
	.db $05,$1B,$03,$08
	.db $F0,$0F,$03,$F0
	.db $F0,$11,$03,$F8
	.db $F0,$13,$03,$00
	.db $00,$15,$03,$F0
	.db $00,$17,$03,$F8
	.db $00,$19,$03,$00
	.db $F5,$07,$03,$08
SpriteEnemy63Data:
	.db $07
	.db $F4,$07,$03,$09
	.db $F0,$03,$03,$F9
	.db $F0,$05,$03,$01
	.db $00,$09,$03,$F1
	.db $00,$0B,$03,$F9
	.db $00,$0D,$03,$01
	.db $F0,$01,$03,$F1
;Chimera fire
SpriteEnemy64Data:
	.db $02
	.db $F8,$1D,$00,$F0
	.db $F8,$1F,$00,$F8
SpriteEnemy65Data:
	.db $03
	.db $F8,$1D,$00,$F0
	.db $F8,$1F,$00,$F8
	.db $F8,$1F,$00,$00
SpriteEnemy66Data:
	.db $04
	.db $F8,$1D,$00,$F0
	.db $F8,$1F,$00,$F8
	.db $F8,$1F,$00,$00
	.db $F8,$1F,$00,$08
;Kali idle
SpriteEnemy67Data:
	.db $07
	.db $F0,$21,$02,$F4
	.db $F0,$23,$02,$FC
	.db $F0,$25,$02,$04
	.db $F0,$27,$02,$0C
	.db $00,$29,$02,$F4
	.db $00,$2B,$02,$FC
	.db $00,$2D,$02,$04
SpriteEnemy68Data:
	.db $07
	.db $F0,$21,$02,$F4
	.db $F0,$23,$02,$FC
	.db $F0,$27,$02,$0C
	.db $00,$29,$02,$F4
	.db $00,$2B,$02,$FC
	.db $00,$2D,$02,$04
	.db $F0,$2F,$02,$04
;Kali attacking
SpriteEnemy69Data:
	.db $07
	.db $F0,$23,$02,$FC
	.db $F0,$37,$02,$04
	.db $F0,$21,$02,$F4
	.db $00,$29,$02,$F4
	.db $00,$2B,$02,$FC
	.db $EF,$39,$02,$0C
	.db $00,$2D,$02,$04
SpriteEnemy6AData:
	.db $07
	.db $F3,$31,$02,$0D
	.db $01,$3D,$02,$FD
	.db $01,$3F,$02,$05
	.db $01,$3B,$02,$F5
	.db $F1,$21,$02,$F5
	.db $F1,$23,$02,$FD
	.db $F1,$25,$02,$05
;Kali fire
SpriteEnemy4CData:
	.db $02
	.db $F8,$33,$01,$E8
	.db $F8,$35,$02,$F0
SpriteEnemy4DData:
	.db $03
	.db $F8,$33,$01,$E8
	.db $F8,$33,$01,$F0
	.db $F8,$35,$02,$F8
SpriteEnemy4EData:
	.db $04
	.db $F8,$33,$01,$E8
	.db $F8,$33,$01,$F0
	.db $F8,$33,$01,$F8
	.db $F8,$35,$02,$00
SpriteEnemy4FData:
	.db $05
	.db $F8,$33,$01,$E8
	.db $F8,$33,$01,$F0
	.db $F8,$33,$01,$F8
	.db $F8,$33,$01,$00
	.db $F8,$35,$02,$08
SpriteEnemy50Data:
	.db $06
	.db $F8,$33,$01,$E8
	.db $F8,$33,$01,$F0
	.db $F8,$33,$01,$F8
	.db $F8,$33,$01,$00
	.db $F8,$33,$01,$08
	.db $F8,$35,$02,$10
;Cyclops falling
SpriteEnemy6BData:
	.db $06
	.db $F0,$01,$01,$F4
	.db $F0,$03,$01,$FC
	.db $F0,$05,$01,$04
	.db $00,$07,$01,$F4
	.db $00,$09,$01,$FC
	.db $00,$0B,$01,$04
;Cyclops walking
SpriteEnemy6CData:
	.db $05
	.db $00,$1B,$01,$FF
	.db $F0,$11,$01,$04
	.db $F0,$0D,$01,$F4
	.db $F0,$0F,$01,$FC
	.db $00,$19,$01,$F7
SpriteEnemy6DData:
	.db $06
	.db $01,$17,$01,$04
	.db $F1,$0D,$01,$F4
	.db $F1,$0F,$01,$FC
	.db $F1,$11,$01,$04
	.db $01,$13,$01,$F4
	.db $01,$15,$01,$FC
;Manticore walking
SpriteEnemy6EData:
	.db $09
	.db $08,$31,$03,$08
	.db $EE,$23,$03,$F8
	.db $EE,$25,$03,$00
	.db $F2,$21,$03,$F0
	.db $02,$29,$03,$E8
	.db $FE,$2D,$03,$F8
	.db $FE,$2F,$03,$00
	.db $02,$2B,$03,$F0
	.db $F8,$27,$03,$08
SpriteEnemy6FData:
	.db $07
	.db $F4,$27,$03,$07
	.db $F0,$33,$03,$EF
	.db $ED,$35,$03,$F7
	.db $EE,$37,$03,$FF
	.db $00,$39,$03,$EF
	.db $FD,$3B,$03,$F7
	.db $FE,$3D,$03,$FF
;Manticore fire
SpriteEnemy70Data:
	.db $02
	.db $F8,$1D,$02,$F8
	.db $F8,$1F,$02,$00
SpriteEnemy71Data:
	.db $02
	.db $F8,$3F,$02,$F8
	.db $F8,$3F,$42,$00
SpriteEnemy72Data:
	.db $02
	.db $F8,$1D,$82,$F8
	.db $F8,$1F,$82,$00
SpriteEnemy73Data:
	.db $02
	.db $F8,$1D,$C2,$00
	.db $F8,$1F,$C2,$F8
SpriteEnemy74Data:
	.db $02
	.db $F8,$1D,$42,$00
	.db $F8,$1F,$42,$F8
;Karnack walking
SpriteEnemy75Data:
	.db $08
	.db $01,$0F,$01,$06
	.db $E1,$01,$01,$FD
	.db $E1,$03,$01,$05
	.db $F1,$05,$01,$F5
	.db $F1,$07,$01,$FD
	.db $F1,$09,$01,$05
	.db $01,$0B,$01,$F6
	.db $01,$0D,$01,$FE
SpriteEnemy76Data:
	.db $07
	.db $00,$19,$01,$03
	.db $E0,$03,$01,$05
	.db $F0,$11,$01,$F5
	.db $F0,$13,$01,$FD
	.db $F0,$15,$01,$05
	.db $E0,$01,$01,$FD
	.db $00,$17,$01,$FB
SpriteEnemy77Data:
	.db $08
	.db $01,$0F,$01,$06
	.db $E1,$01,$01,$FD
	.db $E1,$03,$01,$05
	.db $F1,$1B,$01,$F5
	.db $F1,$1D,$01,$FD
	.db $F1,$1F,$01,$05
	.db $01,$0B,$01,$F6
	.db $01,$0D,$01,$FE
;Tengu flying
SpriteEnemy78Data:
	.db $08
	.db $F0,$3F,$02,$01
	.db $01,$2B,$03,$F8
	.db $F0,$33,$03,$08
	.db $00,$29,$03,$F0
	.db $F1,$31,$03,$F8
	.db $F0,$25,$03,$00
	.db $00,$2D,$03,$00
	.db $F0,$2F,$03,$F0
SpriteEnemy79Data:
	.db $08
	.db $EF,$3F,$02,$01
	.db $EF,$21,$03,$F0
	.db $F0,$23,$03,$F8
	.db $EF,$25,$03,$00
	.db $EF,$27,$03,$08
	.db $00,$2B,$03,$F8
	.db $FF,$29,$03,$F0
	.db $FF,$2D,$03,$00
;Tengu punching
SpriteEnemy7AData:
	.db $09
	.db $F1,$3F,$02,$03
	.db $F0,$35,$03,$F0
	.db $F0,$39,$03,$00
	.db $F0,$3B,$03,$08
	.db $F0,$3D,$03,$10
	.db $00,$29,$03,$F0
	.db $F1,$37,$03,$F8
	.db $00,$2D,$03,$00
	.db $01,$2B,$03,$F8
;Cockatrice flying
SpriteEnemy7BData:
	.db $0A
	.db $F0,$1F,$00,$01
	.db $F0,$01,$01,$F0
	.db $F0,$03,$01,$F8
	.db $ED,$05,$01,$00
	.db $E8,$07,$01,$08
	.db $00,$09,$01,$F0
	.db $00,$0B,$01,$F8
	.db $F8,$0F,$01,$08
	.db $FD,$0D,$01,$00
	.db $10,$11,$01,$F3
SpriteEnemy7CData:
	.db $08
	.db $EF,$1F,$00,$01
	.db $F6,$13,$01,$F0
	.db $F6,$15,$01,$F8
	.db $EC,$05,$01,$00
	.db $F2,$17,$01,$08
	.db $06,$19,$01,$F0
	.db $06,$1B,$01,$F8
	.db $FC,$1D,$01,$00
;Cockatrice fire
SpriteEnemy7DData:
	.db $01
	.db $F4,$3F,$00,$F4
SpriteEnemy7EData:
	.db $02
	.db $F4,$3F,$00,$F4
	.db $FC,$3F,$00,$FC
SpriteEnemy7FData:
	.db $03
	.db $F4,$3F,$00,$F4
	.db $FC,$3F,$00,$FC
	.db $04,$3F,$00,$04
;Coatlicue walking
SpriteEnemy80Data:
	.db $09
	.db $08,$2F,$03,$F8
	.db $E8,$23,$03,$F6
	.db $E8,$25,$03,$FE
	.db $E8,$27,$03,$06
	.db $E8,$21,$03,$EE
	.db $F8,$29,$03,$F2
	.db $F8,$2B,$03,$FA
	.db $F8,$2D,$03,$02
	.db $08,$31,$03,$00
SpriteEnemy81Data:
	.db $0A
	.db $09,$3B,$03,$FA
	.db $E9,$21,$03,$EE
	.db $E9,$23,$03,$F6
	.db $E9,$25,$03,$FE
	.db $E9,$27,$03,$06
	.db $F9,$33,$03,$F2
	.db $F9,$35,$03,$FA
	.db $F9,$37,$03,$02
	.db $09,$39,$03,$F2
	.db $09,$3D,$03,$02
;Behemoth falling
SpriteEnemy82Data:
	.db $06
	.db $00,$0B,$01,$04
	.db $F0,$01,$01,$F4
	.db $F0,$03,$01,$FC
	.db $F0,$05,$01,$04
	.db $00,$07,$01,$F4
	.db $00,$09,$01,$FC
;Behemoth walking
SpriteEnemy83Data:
	.db $06
	.db $01,$11,$01,$04
	.db $F1,$01,$01,$F4
	.db $F1,$03,$01,$FC
	.db $F1,$05,$01,$04
	.db $01,$0D,$01,$F4
	.db $01,$0F,$01,$FC
SpriteEnemy84Data:
	.db $07
	.db $0B,$19,$01,$08
	.db $FB,$01,$01,$F8
	.db $FB,$03,$01,$00
	.db $FB,$05,$01,$08
	.db $03,$13,$01,$F0
	.db $0B,$15,$01,$F8
	.db $0B,$17,$01,$00
;T-Rex walking
SpriteEnemy85Data:
	.db $0A
	.db $08,$2D,$03,$04
	.db $E8,$1D,$03,$08
	.db $E8,$1F,$03,$10
	.db $F8,$21,$03,$F8
	.db $F8,$23,$03,$00
	.db $F8,$25,$03,$08
	.db $E8,$1B,$03,$00
	.db $08,$27,$03,$EC
	.db $08,$29,$03,$F4
	.db $08,$2B,$03,$FC
SpriteEnemy86Data:
	.db $0A
	.db $09,$33,$03,$05
	.db $E9,$1B,$03,$01
	.db $E9,$1D,$03,$09
	.db $E9,$1F,$03,$11
	.db $F9,$21,$03,$F9
	.db $F9,$23,$03,$01
	.db $F9,$25,$03,$09
	.db $08,$27,$03,$ED
	.db $09,$2F,$03,$F5
	.db $09,$31,$03,$FD
;T-Rex fire
SpriteEnemy88Data:
	.db $02
	.db $F8,$35,$00,$EC
	.db $F8,$39,$00,$F4
SpriteEnemy89Data:
	.db $03
	.db $F8,$37,$00,$F4
	.db $F8,$35,$00,$EC
	.db $F8,$39,$00,$FC
SpriteEnemy8AData:
	.db $04
	.db $F8,$39,$00,$04
	.db $F8,$35,$00,$EC
	.db $F8,$37,$00,$F4
	.db $F8,$37,$00,$FC
SpriteEnemy8BData:
	.db $05
	.db $F8,$39,$00,$0C
	.db $F8,$35,$00,$EC
	.db $F8,$37,$00,$F4
	.db $F8,$37,$00,$FC
	.db $F8,$37,$00,$04
;Minotaur walking
SpriteEnemyA4Data:
	.db $0A
	.db $E0,$05,$02,$05
	.db $E0,$01,$02,$F5
	.db $E0,$03,$02,$FD
	.db $F0,$07,$02,$F0
	.db $F0,$09,$02,$F8
	.db $F0,$0B,$02,$00
	.db $F0,$0D,$02,$08
	.db $00,$0F,$02,$F0
	.db $00,$11,$02,$F8
	.db $00,$13,$02,$00
SpriteEnemyA5Data:
	.db $0A
	.db $F1,$0D,$02,$08
	.db $E1,$01,$02,$F5
	.db $E1,$03,$02,$FD
	.db $F1,$07,$02,$F0
	.db $F1,$09,$02,$F8
	.db $01,$19,$02,$00
	.db $E1,$05,$02,$05
	.db $F1,$0B,$02,$00
	.db $01,$15,$02,$F0
	.db $01,$17,$02,$F8
;Great Beast flying
SpriteEnemy8CData:
	.db $0C
	.db $10,$31,$03,$FA
	.db $F0,$1B,$03,$EC
	.db $F0,$1D,$03,$F4
	.db $F0,$1F,$03,$FC
	.db $F0,$21,$03,$04
	.db $F0,$23,$03,$0C
	.db $00,$25,$03,$EC
	.db $00,$27,$03,$F4
	.db $00,$29,$03,$FC
	.db $00,$2B,$03,$04
	.db $00,$2D,$03,$0C
	.db $10,$2F,$03,$F2
SpriteEnemy8DData:
	.db $0C
	.db $FF,$2D,$03,$0C
	.db $EF,$33,$03,$EC
	.db $EF,$35,$03,$F4
	.db $EF,$37,$03,$FC
	.db $EF,$21,$03,$04
	.db $EF,$23,$03,$0C
	.db $FF,$39,$03,$EC
	.db $FF,$3B,$03,$F4
	.db $FF,$29,$03,$FC
	.db $FF,$2B,$03,$04
	.db $0F,$2F,$03,$F2
	.db $0F,$31,$03,$FA
;Water drop
SpriteEnemy8EData:
	.db $02
	.db $F4,$3B,$42,$00
	.db $F4,$3B,$02,$F8
SpriteEnemy8FData:
	.db $02
	.db $F8,$3D,$02,$F8
	.db $F8,$3D,$42,$00
SpriteEnemy90Data:
	.db $04
	.db $F6,$3F,$42,$08
	.db $F0,$3F,$42,$00
	.db $F0,$3F,$02,$F8
	.db $F6,$3F,$02,$F0
SpriteEnemy91Data:
	.db $04
	.db $EE,$3F,$42,$0E
	.db $EE,$3F,$02,$EA
	.db $E7,$3F,$42,$02
	.db $E7,$3F,$02,$F6
;Great Beast fire
SpriteEnemy92Data:
	.db $01
	.db $F8,$3D,$00,$FC
SpriteEnemy93Data:
	.db $01
	.db $F8,$3F,$00,$FC
SpriteEnemy94Data:
	.db $02
	.db $F8,$3D,$00,$FC
	.db $EB,$3D,$00,$F4
SpriteEnemy95Data:
	.db $02
	.db $F8,$3F,$00,$FC
	.db $EB,$3F,$00,$F4
SpriteEnemy96Data:
	.db $03
	.db $F8,$3D,$00,$FC
	.db $DE,$3D,$00,$EC
	.db $EB,$3D,$00,$F4
SpriteEnemy97Data:
	.db $03
	.db $F8,$3F,$00,$FC
	.db $DE,$3F,$00,$EC
	.db $EB,$3F,$00,$F4
SpriteEnemy98Data:
	.db $04
	.db $F8,$3D,$00,$FC
	.db $D1,$3D,$00,$E4
	.db $DE,$3D,$00,$EC
	.db $EB,$3D,$00,$F4
SpriteEnemy99Data:
	.db $04
	.db $F8,$3F,$00,$FC
	.db $D1,$3F,$00,$E4
	.db $DE,$3F,$00,$EC
	.db $EB,$3F,$00,$F4
SpriteEnemy9AData:
	.db $05
	.db $F8,$3D,$00,$FC
	.db $C4,$3D,$00,$DC
	.db $D1,$3D,$00,$E4
	.db $DE,$3D,$00,$EC
	.db $EB,$3D,$00,$F4
SpriteEnemy9BData:
	.db $05
	.db $F8,$3F,$00,$FC
	.db $C4,$3F,$00,$DC
	.db $D1,$3F,$00,$E4
	.db $DE,$3F,$00,$EC
	.db $EB,$3F,$00,$F4
SpriteEnemy9CData:
	.db $06
	.db $F8,$3D,$00,$FC
	.db $B7,$3D,$00,$D4
	.db $C4,$3D,$00,$DC
	.db $D1,$3D,$00,$E4
	.db $DE,$3D,$00,$EC
	.db $EB,$3D,$00,$F4
SpriteEnemy9DData:
	.db $06
	.db $F8,$3F,$00,$FC
	.db $B7,$3F,$00,$D4
	.db $C4,$3F,$00,$DC
	.db $D1,$3F,$00,$E4
	.db $DE,$3F,$00,$EC
	.db $EB,$3F,$00,$F4
SpriteEnemy9EData:
	.db $07
	.db $F8,$3D,$00,$FC
	.db $AA,$3D,$00,$CC
	.db $B7,$3D,$00,$D4
	.db $C4,$3D,$00,$DC
	.db $D1,$3D,$00,$E4
	.db $DE,$3D,$00,$EC
	.db $EB,$3D,$00,$F4
SpriteEnemy9FData:
	.db $07
	.db $F8,$3F,$00,$FC
	.db $AA,$3F,$00,$CC
	.db $B7,$3F,$00,$D4
	.db $C4,$3F,$00,$DC
	.db $D1,$3F,$00,$E4
	.db $DE,$3F,$00,$EC
	.db $EB,$3F,$00,$F4
SpriteEnemyA0Data:
	.db $08
	.db $F8,$3D,$00,$FC
	.db $9D,$3D,$00,$C4
	.db $AA,$3D,$00,$CC
	.db $B7,$3D,$00,$D4
	.db $C4,$3D,$00,$DC
	.db $D1,$3D,$00,$E4
	.db $DE,$3D,$00,$EC
	.db $EB,$3D,$00,$F4
SpriteEnemyA1Data:
	.db $08
	.db $F8,$3F,$00,$FC
	.db $9D,$3F,$00,$C4
	.db $AA,$3F,$00,$CC
	.db $B7,$3F,$00,$D4
	.db $C4,$3F,$00,$DC
	.db $D1,$3F,$00,$E4
	.db $DE,$3F,$00,$EC
	.db $EB,$3F,$00,$F4
SpriteEnemyA2Data:
	.db $09
	.db $EB,$3D,$00,$F4
	.db $90,$3D,$00,$BC
	.db $9D,$3D,$00,$C4
	.db $AA,$3D,$00,$CC
	.db $B7,$3D,$00,$D4
	.db $C4,$3D,$00,$DC
	.db $D1,$3D,$00,$E4
	.db $DE,$3D,$00,$EC
	.db $F8,$3D,$00,$FC
SpriteEnemyA3Data:
	.db $09
	.db $F8,$3F,$00,$FC
	.db $90,$3F,$00,$BC
	.db $9D,$3F,$00,$C4
	.db $AA,$3F,$00,$CC
	.db $B7,$3F,$00,$D4
	.db $C4,$3F,$00,$DC
	.db $D1,$3F,$00,$E4
	.db $DE,$3F,$00,$EC
	.db $EB,$3F,$00,$F4

SpriteDataBossPointerTable:
	.dw SpriteEnemy01Data	;$01 \Explosion
	.dw SpriteEnemy02Data	;$02 |
	.dw SpriteEnemy03Data	;$03 |
	.dw SpriteEnemy04Data	;$04 |
	.dw SpriteEnemy05Data	;$05 /
	.dw SpriteEnemy06Data	;$06  Item HP
	.dw SpriteEnemy07Data	;$07  Explosion
	.dw SpriteBoss08Data	;$08  Level 1 boss idle
	.dw SpriteBoss09Data	;$09 \Level 1 boss jumping
	.dw SpriteBoss0AData	;$0A |
	.dw SpriteBoss0BData	;$0B |
	.dw SpriteBoss0CData	;$0C |
	.dw SpriteBoss0DData	;$0D /
	.dw SpriteBoss0EData	;$0E  Level 1 boss idle
	.dw SpriteBoss0FData	;$0F \Level 1 boss death
	.dw SpriteBoss10Data	;$10 /
	.dw SpriteBoss11Data	;$11 \Level 1 boss fire
	.dw SpriteBoss12Data	;$12 |
	.dw SpriteBoss13Data	;$13 /
	.dw SpriteBoss14Data	;$14 \Level 2 boss running
	.dw SpriteBoss15Data	;$15 |
	.dw SpriteBoss16Data	;$16 /
	.dw SpriteBoss17Data	;$17 \Level 2 boss walking
	.dw SpriteBoss18Data	;$18 /
	.dw SpriteBoss19Data	;$19  Level 2 boss hit
	.dw SpriteBoss1AData	;$1A \Level 2 boss death
	.dw SpriteBoss1BData	;$1B /
	.dw SpriteBoss1CData	;$1C \Level 2 boss fire
	.dw SpriteBoss1DData	;$1D |
	.dw SpriteBoss1EData	;$1E /
	.dw SpriteBoss1FData	;$1F \Level 3 boss splash
	.dw SpriteBoss20Data	;$20 |
	.dw SpriteBoss21Data	;$21 |
	.dw SpriteBoss22Data	;$22 /
	.dw SpriteBoss23Data	;$23  Level 3 boss part
	.dw SpriteBoss24Data	;$24 \Level 3 boss part spike
	.dw SpriteBoss25Data	;$25 |
	.dw SpriteBoss26Data	;$26 |
	.dw SpriteBoss27Data	;$27 /
	.dw SpriteBoss28Data	;$28 \Level 4 boss standing
	.dw SpriteBoss29Data	;$29 |
	.dw SpriteBoss2AData	;$2A |
	.dw SpriteBoss2BData	;$2B /
	.dw SpriteBoss2CData	;$2C  Level 4 boss jumping
	.dw SpriteBoss2DData	;$2D \Level 4 boss death
	.dw SpriteBoss2EData	;$2E /
	.dw SpriteBoss2FData	;$2F \Level 4 boss throwing
	.dw SpriteBoss30Data	;$30 |
	.dw SpriteBoss31Data	;$31 /
	.dw SpriteBoss32Data	;$32 \Level 4 boss fire
	.dw SpriteBoss33Data	;$33 |
	.dw SpriteBoss34Data	;$34 |
	.dw SpriteBoss35Data	;$35 /
	.dw SpriteBoss36Data	;$36 \Level 5 boss flying
	.dw SpriteBoss37Data	;$37 |
	.dw SpriteBoss38Data	;$38 |
	.dw SpriteBoss39Data	;$39 |
	.dw SpriteBoss3AData	;$3A |
	.dw SpriteBoss3BData	;$3B /
	.dw SpriteBoss3CData	;$3C \Level 5 boss death
	.dw SpriteBoss3DData	;$3D /
	.dw SpriteBoss3EData	;$3E \Level 5 boss fire
	.dw SpriteBoss3FData	;$3F |
	.dw SpriteBoss40Data	;$40 /
	.dw SpriteBoss41Data	;$41 \Level 6 boss idle
	.dw SpriteBoss42Data	;$42 |
	.dw SpriteBoss43Data	;$43 /
	.dw SpriteBoss44Data	;$44  Level 6 boss attacking
	.dw SpriteBoss45Data	;$45 \Level 6 boss death
	.dw SpriteBoss46Data	;$46 |
	.dw SpriteBoss47Data	;$47 |
	.dw SpriteBoss48Data	;$48 |
	.dw SpriteBoss49Data	;$49 |
	.dw SpriteBoss4AData	;$4A |
	.dw SpriteBoss4BData	;$4B |
	.dw SpriteBoss4CData	;$4C |
	.dw SpriteBoss4DData	;$4D |
	.dw SpriteBoss4EData	;$4E |
	.dw SpriteBoss4FData	;$4F /
	.dw SpriteBoss50Data	;$50 \Level 6 boss fire
	.dw SpriteBoss51Data	;$51 |
	.dw SpriteBoss52Data	;$52 |
	.dw SpriteBoss53Data	;$53 |
	.dw SpriteBoss54Data	;$54 |
	.dw SpriteBoss55Data	;$55 |
	.dw SpriteBoss56Data	;$56 |
	.dw SpriteBoss57Data	;$57 |
	.dw SpriteBoss58Data	;$58 |
	.dw SpriteBoss59Data	;$59 |
	.dw SpriteBoss5AData	;$5A |
	.dw SpriteBoss5BData	;$5B /
	.dw SpriteBoss5CData	;$5C  TV left edge
	.dw SpriteBoss5DData	;$5D  TV right edge
	.dw SpriteBoss5EData	;$5E \Level 7 boss eye flash
	.dw SpriteBoss5FData	;$5F /
	.dw SpriteBoss60Data	;$60 \Windigo walking
	.dw SpriteBoss61Data	;$61 |
	.dw SpriteBoss62Data	;$62 /
	.dw SpriteBoss63Data	;$63 \Level 7 boss fire land
	.dw SpriteBoss64Data	;$64 |
	.dw SpriteBoss65Data	;$65 /
	.dw SpriteBoss66Data	;$66 \Level 7 boss fire attack
	.dw SpriteBoss67Data	;$67 |
	.dw SpriteBoss68Data	;$68 |
	.dw SpriteBoss69Data	;$69 /

;Level 1 boss idle
SpriteBoss08Data:
	.db $07
	.db $F3,$35,$00,$04
	.db $F2,$01,$03,$F4
	.db $F2,$03,$03,$FC
	.db $F2,$05,$03,$04
	.db $02,$07,$03,$F4
	.db $02,$09,$03,$FC
	.db $02,$0B,$03,$04
;Level 1 boss jumping
SpriteBoss09Data:
	.db $08
	.db $E9,$35,$00,$05
	.db $F0,$0D,$03,$F0
	.db $EA,$0F,$03,$F8
	.db $EA,$11,$03,$00
	.db $EA,$13,$03,$08
	.db $00,$15,$03,$F0
	.db $FA,$17,$03,$F8
	.db $FA,$19,$03,$00
SpriteBoss0AData:
	.db $07
	.db $E8,$1D,$03,$F4
	.db $F8,$23,$03,$FC
	.db $F8,$21,$03,$F4
	.db $F8,$25,$03,$04
	.db $E8,$35,$00,$04
	.db $E8,$1F,$03,$FC
	.db $E8,$2D,$03,$04
SpriteBoss0BData:
	.db $08
	.db $07,$2D,$03,$F6
	.db $E7,$01,$03,$F5
	.db $E7,$07,$03,$FD
	.db $E7,$09,$03,$05
	.db $F7,$0B,$03,$F5
	.db $F7,$17,$03,$FD
	.db $F7,$19,$03,$05
	.db $E8,$35,$00,$05
;Level 1 boss fire
SpriteBoss11Data:
	.db $02
	.db $F8,$2F,$02,$F8
	.db $F8,$31,$02,$00
SpriteBoss12Data:
	.db $01
	.db $F8,$33,$02,$FC
;Level 1 boss jumping
SpriteBoss0CData:
	.db $07
	.db $E4,$29,$03,$FF
	.db $E4,$2B,$03,$07
	.db $F4,$37,$03,$F6
	.db $F4,$39,$03,$FE
	.db $F4,$3B,$03,$06
	.db $E4,$27,$03,$F7
	.db $E6,$35,$00,$05
SpriteBoss0DData:
	.db $08
	.db $E5,$03,$03,$F7
	.db $05,$15,$03,$FD
	.db $F5,$13,$03,$FF
	.db $E4,$35,$00,$05
	.db $F5,$11,$03,$F7
	.db $E5,$0D,$03,$07
	.db $E9,$0F,$03,$0F
	.db $E5,$05,$03,$FF
;Level 1 boss idle
SpriteBoss0EData:
	.db $07
	.db $F3,$35,$40,$00
	.db $F2,$29,$03,$FC
	.db $F2,$2B,$03,$04
	.db $02,$07,$03,$F4
	.db $02,$09,$03,$FC
	.db $02,$0B,$03,$04
	.db $F2,$01,$03,$F4
;Level 1 boss death
SpriteBoss0FData:
	.db $07
	.db $F7,$35,$00,$0C
	.db $00,$21,$03,$F6
	.db $F4,$1B,$03,$FE
	.db $F4,$1D,$03,$06
	.db $F8,$1F,$03,$0E
	.db $04,$23,$03,$FE
	.db $04,$25,$03,$06
SpriteBoss10Data:
	.db $05
	.db $04,$35,$00,$0E
	.db $00,$39,$03,$FE
	.db $00,$3B,$03,$06
	.db $00,$37,$03,$F6
	.db $00,$1B,$03,$0E
;Level 1 boss fire
SpriteBoss13Data:
	.db $02
	.db $F8,$3D,$02,$F8
	.db $F8,$3F,$02,$00
;Level 2 boss running
SpriteBoss14Data:
	.db $09
	.db $05,$11,$03,$09
	.db $E9,$03,$03,$01
	.db $F1,$05,$03,$09
	.db $F9,$07,$03,$F9
	.db $08,$0B,$03,$F1
	.db $F9,$09,$03,$01
	.db $09,$0D,$03,$F9
	.db $09,$0F,$03,$01
	.db $E9,$01,$03,$F9
SpriteBoss15Data:
	.db $07
	.db $09,$0D,$03,$FF
	.db $E9,$01,$03,$F9
	.db $F0,$05,$03,$09
	.db $E9,$03,$03,$01
	.db $F9,$07,$03,$F9
	.db $F9,$09,$03,$01
	.db $09,$0B,$03,$F7
SpriteBoss16Data:
	.db $0A
	.db $09,$35,$03,$02
	.db $E9,$23,$03,$F9
	.db $E9,$25,$03,$01
	.db $E9,$27,$03,$09
	.db $F9,$2B,$03,$F9
	.db $F9,$2D,$03,$01
	.db $F9,$2F,$03,$09
	.db $F4,$29,$03,$F1
	.db $09,$31,$03,$F2
	.db $09,$33,$03,$FA
;Level 2 boss walking
SpriteBoss17Data:
	.db $09
	.db $09,$1B,$03,$09
	.db $E9,$03,$03,$01
	.db $F9,$07,$03,$F9
	.db $E9,$01,$03,$F9
	.db $F9,$13,$03,$01
	.db $F1,$05,$03,$09
	.db $09,$15,$03,$F1
	.db $09,$17,$03,$F9
	.db $09,$19,$03,$01
SpriteBoss18Data:
	.db $07
	.db $E8,$01,$03,$F9
	.db $E8,$03,$03,$01
	.db $F0,$05,$03,$09
	.db $F8,$07,$03,$F9
	.db $F8,$13,$03,$01
	.db $08,$1D,$03,$F9
	.db $08,$1F,$03,$01
;Level 2 boss hit
SpriteBoss19Data:
	.db $0B
	.db $F0,$31,$03,$14
	.db $E9,$2B,$03,$FC
	.db $E9,$2D,$03,$04
	.db $E9,$2F,$03,$0C
	.db $F9,$33,$03,$FC
	.db $F9,$35,$03,$04
	.db $F9,$37,$03,$0C
	.db $09,$15,$03,$F6
	.db $09,$17,$03,$FE
	.db $09,$19,$03,$06
	.db $09,$1B,$03,$0E
;Level 2 boss death
SpriteBoss1AData:
	.db $06
	.db $08,$29,$03,$09
	.db $08,$25,$03,$F9
	.db $F8,$21,$03,$F9
	.db $F8,$23,$03,$01
	.db $08,$27,$03,$01
	.db $F9,$05,$03,$09
SpriteBoss1BData:
	.db $06
	.db $08,$17,$03,$09
	.db $F8,$11,$03,$09
	.db $FD,$21,$03,$F9
	.db $F8,$0F,$03,$01
	.db $0D,$13,$03,$F9
	.db $08,$15,$03,$01
;Level 2 boss fire
SpriteBoss1CData:
	.db $04
	.db $00,$39,$02,$FC
	.db $F8,$39,$02,$04
	.db $F0,$39,$02,$FC
	.db $F8,$39,$42,$F4
SpriteBoss1DData:
	.db $04
	.db $F8,$3B,$42,$F4
	.db $F0,$3B,$02,$FC
	.db $00,$3B,$02,$FC
	.db $F8,$3B,$02,$04
SpriteBoss1EData:
	.db $04
	.db $F0,$3D,$02,$FC
	.db $00,$3D,$02,$FC
	.db $00,$3D,$82,$04
	.db $F0,$3F,$02,$04
;Level 3 boss splash
SpriteBoss1FData:
	.db $04
	.db $00,$2F,$02,$F0
	.db $00,$31,$02,$F8
	.db $00,$31,$42,$00
	.db $00,$2F,$42,$08
SpriteBoss20Data:
	.db $04
	.db $00,$33,$02,$F0
	.db $00,$35,$02,$F8
	.db $00,$37,$02,$00
	.db $00,$33,$42,$08
SpriteBoss21Data:
	.db $04
	.db $FD,$39,$02,$F0
	.db $F7,$3B,$02,$F8
	.db $FE,$3B,$02,$00
	.db $FA,$39,$42,$08
SpriteBoss22Data:
	.db $04
	.db $F3,$3D,$02,$F0
	.db $F0,$3F,$02,$F8
	.db $F1,$39,$02,$00
	.db $F4,$3D,$42,$08
;Level 3 boss part
SpriteBoss23Data:
	.db $02
	.db $F8,$1B,$03,$F8
	.db $F8,$1D,$03,$00
;Level 3 boss part spike
SpriteBoss24Data:
	.db $02
	.db $F8,$1F,$03,$F8
	.db $F8,$21,$03,$00
SpriteBoss25Data:
	.db $02
	.db $F8,$23,$03,$F8
	.db $F8,$25,$03,$00
SpriteBoss26Data:
	.db $02
	.db $F8,$27,$03,$F8
	.db $F8,$29,$03,$00
SpriteBoss27Data:
	.db $02
	.db $F8,$2B,$03,$F8
	.db $F8,$2D,$02,$00
;Level 4 boss standing
SpriteBoss28Data:
	.db $0A
	.db $F1,$3F,$00,$01
	.db $F0,$01,$03,$EE
	.db $F0,$03,$03,$F6
	.db $F0,$05,$03,$FE
	.db $00,$09,$03,$F0
	.db $00,$0B,$03,$F8
	.db $00,$0D,$03,$00
	.db $00,$0F,$03,$08
	.db $F0,$07,$03,$06
	.db $F1,$3D,$00,$F9
SpriteBoss29Data:
	.db $09
	.db $F1,$3F,$00,$FF
	.db $F0,$2B,$03,$EC
	.db $F0,$2D,$03,$F4
	.db $F0,$05,$03,$FC
	.db $F0,$2F,$03,$04
	.db $00,$31,$03,$F4
	.db $00,$33,$03,$FC
	.db $00,$35,$03,$04
	.db $F1,$3D,$00,$F7
SpriteBoss2AData:
	.db $09
	.db $F1,$3F,$00,$00
	.db $F0,$01,$03,$EE
	.db $F0,$17,$03,$F6
	.db $F0,$19,$03,$FE
	.db $F0,$1B,$03,$06
	.db $00,$1D,$03,$F5
	.db $00,$1F,$03,$FD
	.db $00,$23,$03,$05
	.db $F1,$3D,$00,$F8
SpriteBoss2BData:
	.db $0B
	.db $F2,$3F,$00,$03
	.db $F0,$0D,$03,$F8
	.db $F0,$21,$03,$F0
	.db $F0,$0F,$03,$08
	.db $00,$03,$03,$F0
	.db $00,$07,$03,$F8
	.db $F1,$05,$03,$00
	.db $00,$0B,$03,$08
	.db $01,$09,$03,$00
	.db $F2,$3D,$00,$FB
	.db $F8,$11,$03,$10
;Level 4 boss jumping
SpriteBoss2CData:
	.db $09
	.db $EF,$3F,$00,$01
	.db $ED,$13,$03,$F0
	.db $ED,$15,$03,$F8
	.db $ED,$17,$03,$00
	.db $ED,$11,$03,$08
	.db $FD,$19,$03,$F5
	.db $FD,$1B,$03,$FD
	.db $FD,$37,$03,$05
	.db $EF,$3D,$00,$F9
;Level 4 boss death
SpriteBoss2DData:
	.db $08
	.db $F4,$3D,$00,$F9
	.db $F8,$2F,$03,$F1
	.db $F0,$2B,$03,$F9
	.db $F0,$2D,$03,$01
	.db $00,$31,$03,$F9
	.db $00,$33,$03,$01
	.db $F9,$29,$03,$09
	.db $F0,$39,$00,$01
SpriteBoss2EData:
	.db $07
	.db $F0,$21,$03,$07
	.db $00,$25,$03,$F8
	.db $00,$27,$03,$00
	.db $00,$35,$03,$08
	.db $00,$23,$03,$F0
	.db $F0,$1D,$03,$F5
	.db $F0,$1F,$03,$FF
;Level 4 boss throwing
SpriteBoss2FData:
	.db $08
	.db $F0,$37,$43,$04
	.db $F1,$3D,$40,$01
	.db $F0,$05,$43,$FC
	.db $F0,$2F,$43,$F4
	.db $00,$39,$43,$04
	.db $00,$35,$43,$F4
	.db $F1,$3F,$40,$F9
	.db $00,$33,$43,$FC
SpriteBoss30Data:
	.db $0A
	.db $F1,$3F,$40,$F8
	.db $F0,$1B,$43,$F2
	.db $F0,$19,$43,$FA
	.db $F0,$27,$43,$02
	.db $F0,$25,$43,$0A
	.db $00,$29,$43,$0B
	.db $00,$1D,$43,$03
	.db $00,$1F,$43,$FB
	.db $00,$23,$43,$F3
	.db $F1,$3D,$40,$00
SpriteBoss31Data:
	.db $0B
	.db $F2,$3D,$40,$FD
	.db $F0,$0F,$43,$F0
	.db $F0,$15,$43,$00
	.db $F0,$13,$43,$08
	.db $00,$03,$43,$08
	.db $00,$07,$43,$00
	.db $F1,$05,$43,$F8
	.db $00,$0B,$43,$F0
	.db $F8,$11,$43,$E8
	.db $01,$09,$43,$F8
	.db $F2,$3F,$40,$F5
;Level 4 boss fire
SpriteBoss32Data:
	.db $01
	.db $F8,$3B,$02,$FC
SpriteBoss33Data:
	.db $01
	.db $F8,$3B,$82,$FC
SpriteBoss34Data:
	.db $01
	.db $F8,$3B,$C2,$FC
SpriteBoss35Data:
	.db $01
	.db $F8,$3B,$42,$FC
;Level 5 boss flying
SpriteBoss36Data:
	.db $0A
	.db $EE,$3F,$02,$01
	.db $F8,$07,$03,$F8
	.db $E8,$03,$03,$04
	.db $08,$0D,$03,$F2
	.db $08,$0F,$03,$FA
	.db $08,$11,$03,$02
	.db $E8,$01,$03,$FC
	.db $F8,$0B,$03,$08
	.db $F8,$05,$03,$F0
	.db $F8,$09,$03,$00
SpriteBoss37Data:
	.db $0A
	.db $EE,$3F,$02,$01
	.db $E8,$15,$03,$04
	.db $F8,$1D,$03,$F0
	.db $F8,$07,$03,$F8
	.db $F8,$09,$03,$00
	.db $F8,$1F,$03,$08
	.db $E8,$13,$03,$FC
	.db $08,$17,$03,$F2
	.db $08,$19,$03,$FA
	.db $08,$1B,$03,$02
SpriteBoss38Data:
	.db $0A
	.db $EE,$3D,$02,$FC
	.db $F8,$25,$03,$F0
	.db $E8,$21,$03,$F8
	.db $F8,$29,$03,$00
	.db $F8,$2B,$03,$08
	.db $E8,$23,$03,$00
	.db $08,$0D,$03,$F5
	.db $08,$0F,$03,$FD
	.db $08,$11,$03,$05
	.db $F8,$27,$03,$F8
SpriteBoss39Data:
	.db $0A
	.db $EE,$3D,$02,$FC
	.db $F8,$31,$03,$F0
	.db $E8,$2D,$03,$F8
	.db $F8,$27,$03,$F8
	.db $F8,$29,$03,$00
	.db $F8,$33,$03,$08
	.db $E8,$2F,$03,$00
	.db $08,$17,$03,$F4
	.db $08,$19,$03,$FC
	.db $08,$1B,$03,$04
SpriteBoss3AData:
	.db $0B
	.db $EE,$3F,$02,$02
	.db $F8,$07,$03,$F0
	.db $E8,$03,$03,$FF
	.db $F8,$09,$03,$F8
	.db $F8,$0B,$03,$00
	.db $F8,$13,$03,$08
	.db $E8,$05,$03,$07
	.db $08,$0D,$03,$F2
	.db $08,$0F,$03,$FA
	.db $08,$11,$03,$02
	.db $E8,$01,$03,$F7
SpriteBoss3BData:
	.db $0B
	.db $EE,$3F,$02,$02
	.db $E8,$15,$03,$FF
	.db $F8,$1F,$03,$F0
	.db $E8,$1D,$03,$07
	.db $F8,$09,$03,$F8
	.db $F8,$0B,$03,$00
	.db $F8,$21,$03,$08
	.db $E8,$01,$03,$F7
	.db $08,$17,$03,$F2
	.db $08,$19,$03,$FA
	.db $08,$1B,$03,$02
;Level 5 boss death
SpriteBoss3CData:
	.db $07
	.db $F4,$3D,$02,$FF
	.db $00,$29,$03,$F8
	.db $00,$27,$03,$F0
	.db $00,$2D,$03,$08
	.db $00,$2B,$03,$00
	.db $F0,$23,$03,$FB
	.db $F0,$25,$03,$03
SpriteBoss3DData:
	.db $04
	.db $00,$27,$03,$F0
	.db $00,$2F,$03,$F8
	.db $00,$31,$03,$00
	.db $00,$33,$03,$08
;Level 5 boss fire
SpriteBoss3EData:
	.db $02
	.db $F8,$3B,$40,$00
	.db $F8,$3B,$00,$F8
SpriteBoss3FData:
	.db $02
	.db $F8,$39,$00,$F8
	.db $F8,$39,$40,$00
SpriteBoss40Data:
	.db $02
	.db $F8,$37,$40,$00
	.db $F8,$37,$00,$F8
;Level 6 boss idle
SpriteBoss41Data:
	.db $0B
	.db $00,$11,$03,$05
	.db $E0,$03,$03,$00
	.db $E0,$01,$03,$F8
	.db $F0,$07,$03,$F0
	.db $F0,$09,$03,$F8
	.db $F0,$0B,$03,$00
	.db $E8,$05,$03,$EC
	.db $00,$0D,$03,$F5
	.db $00,$0F,$03,$FD
	.db $10,$13,$03,$F8
	.db $10,$15,$03,$00
SpriteBoss42Data:
	.db $0B
	.db $00,$0F,$03,$FD
	.db $E0,$03,$03,$00
	.db $E0,$01,$03,$F8
	.db $F0,$07,$03,$F0
	.db $F0,$09,$03,$F8
	.db $00,$19,$03,$05
	.db $00,$0D,$03,$F5
	.db $F0,$17,$03,$00
	.db $E8,$05,$03,$EC
	.db $10,$13,$03,$F8
	.db $10,$15,$03,$00
SpriteBoss43Data:
	.db $0B
	.db $00,$1D,$03,$05
	.db $E0,$03,$03,$00
	.db $E0,$01,$03,$F8
	.db $F0,$07,$03,$F0
	.db $F0,$09,$03,$F8
	.db $F0,$1B,$03,$00
	.db $E8,$05,$03,$EC
	.db $00,$0D,$03,$F5
	.db $00,$0F,$03,$FD
	.db $10,$13,$03,$F8
	.db $10,$15,$03,$00
;Level 6 boss attacking
SpriteBoss44Data:
	.db $12
	.db $E7,$09,$03,$FA
	.db $D7,$01,$03,$00
	.db $E7,$0D,$03,$0A
	.db $F7,$11,$03,$FC
	.db $E7,$07,$03,$F2
	.db $D7,$03,$03,$08
	.db $E7,$0B,$03,$02
	.db $E7,$05,$03,$EA
	.db $17,$1B,$43,$0B
	.db $F7,$0F,$03,$F4
	.db $F7,$13,$03,$04
	.db $07,$15,$03,$F0
	.db $07,$17,$03,$F8
	.db $07,$19,$03,$00
	.db $07,$15,$43,$07
	.db $17,$1B,$03,$EC
	.db $17,$1D,$03,$F4
	.db $17,$1D,$43,$03
;Level 6 boss death
SpriteBoss45Data:
	.db $16
	.db $10,$2D,$42,$0B
	.db $E8,$07,$03,$08
	.db $F0,$09,$03,$F8
	.db $F0,$0B,$03,$00
	.db $00,$0D,$03,$F0
	.db $00,$0F,$03,$F8
	.db $00,$11,$03,$00
	.db $00,$13,$03,$08
	.db $E8,$01,$03,$F0
	.db $10,$15,$03,$ED
	.db $10,$17,$03,$F5
	.db $E0,$03,$03,$F8
	.db $10,$17,$43,$02
	.db $10,$15,$43,$0A
	.db $E0,$27,$02,$F3
	.db $E0,$27,$42,$04
	.db $E0,$05,$03,$00
	.db $F0,$29,$02,$F1
	.db $F0,$29,$42,$06
	.db $00,$2B,$02,$EE
	.db $00,$2B,$42,$09
	.db $10,$2D,$02,$E9
SpriteBoss46Data:
	.db $16
	.db $00,$35,$42,$08
	.db $E0,$05,$03,$00
	.db $E8,$07,$03,$08
	.db $F0,$09,$03,$F8
	.db $F0,$0B,$03,$00
	.db $00,$0D,$03,$F0
	.db $00,$0F,$03,$F8
	.db $00,$11,$03,$00
	.db $00,$13,$03,$08
	.db $E8,$01,$03,$F0
	.db $10,$15,$03,$ED
	.db $10,$17,$03,$F5
	.db $10,$17,$43,$02
	.db $10,$15,$43,$0A
	.db $E0,$2F,$02,$F1
	.db $F0,$31,$02,$F0
	.db $F0,$33,$02,$F8
	.db $E0,$2F,$42,$06
	.db $F0,$33,$42,$00
	.db $F0,$31,$42,$08
	.db $E0,$03,$03,$F8
	.db $00,$35,$02,$EF
SpriteBoss47Data:
	.db $18
	.db $E0,$05,$03,$00
	.db $E8,$07,$03,$08
	.db $F0,$09,$03,$F8
	.db $F0,$0B,$03,$00
	.db $00,$0D,$03,$F0
	.db $00,$0F,$03,$F8
	.db $00,$11,$03,$00
	.db $00,$13,$03,$08
	.db $E8,$01,$03,$F0
	.db $10,$15,$03,$ED
	.db $10,$17,$03,$F5
	.db $10,$17,$43,$02
	.db $10,$15,$43,$0A
	.db $E0,$03,$03,$F8
	.db $E0,$37,$02,$F5
	.db $F0,$39,$02,$F0
	.db $E0,$37,$42,$02
	.db $F0,$39,$42,$07
	.db $00,$3B,$02,$F1
	.db $00,$3B,$42,$06
	.db $10,$3D,$02,$EC
	.db $10,$3F,$02,$F4
	.db $10,$3D,$42,$0B
	.db $10,$3F,$42,$03
SpriteBoss48Data:
	.db $17
	.db $10,$2D,$02,$EC
	.db $E0,$1D,$03,$04
	.db $E0,$19,$03,$F4
	.db $F0,$1F,$03,$F4
	.db $F0,$21,$03,$FC
	.db $F0,$23,$03,$04
	.db $00,$0D,$03,$F0
	.db $00,$0F,$03,$F8
	.db $00,$11,$03,$00
	.db $00,$13,$03,$08
	.db $E0,$25,$03,$FC
	.db $10,$15,$03,$ED
	.db $10,$17,$03,$F5
	.db $10,$17,$43,$02
	.db $E0,$1B,$03,$FC
	.db $10,$15,$43,$0A
	.db $E0,$27,$02,$F3
	.db $E0,$27,$42,$04
	.db $F0,$29,$02,$F1
	.db $00,$2B,$02,$EE
	.db $F0,$29,$42,$06
	.db $00,$2B,$42,$09
	.db $10,$2D,$42,$0B
SpriteBoss49Data:
	.db $17
	.db $00,$35,$02,$EF
	.db $E0,$19,$03,$F4
	.db $E0,$1B,$03,$FC
	.db $E0,$1D,$03,$04
	.db $F0,$1F,$03,$F4
	.db $F0,$21,$03,$FC
	.db $F0,$23,$03,$04
	.db $00,$0D,$03,$F0
	.db $00,$0F,$03,$F8
	.db $00,$11,$03,$00
	.db $00,$13,$03,$08
	.db $E0,$25,$03,$FC
	.db $10,$15,$03,$ED
	.db $10,$17,$03,$F5
	.db $10,$17,$43,$02
	.db $10,$15,$43,$0A
	.db $E0,$2F,$02,$F1
	.db $F0,$31,$02,$F0
	.db $E0,$2F,$42,$06
	.db $F0,$33,$42,$00
	.db $F0,$31,$42,$08
	.db $F0,$33,$02,$F8
	.db $00,$35,$42,$08
SpriteBoss4AData:
	.db $19
	.db $10,$3D,$42,$0B
	.db $E0,$1B,$03,$FC
	.db $E0,$1D,$03,$04
	.db $F0,$1F,$03,$F4
	.db $F0,$21,$03,$FC
	.db $F0,$23,$03,$04
	.db $00,$0D,$03,$F0
	.db $00,$0F,$03,$F8
	.db $00,$11,$03,$00
	.db $00,$13,$03,$08
	.db $E0,$25,$03,$FC
	.db $10,$15,$03,$ED
	.db $10,$17,$03,$F5
	.db $10,$17,$43,$02
	.db $10,$15,$43,$0A
	.db $E0,$19,$03,$F4
	.db $E0,$37,$02,$F5
	.db $F0,$39,$02,$F0
	.db $E0,$37,$42,$02
	.db $F0,$39,$42,$07
	.db $00,$3B,$02,$F1
	.db $00,$3B,$42,$06
	.db $10,$3D,$02,$EC
	.db $10,$3F,$02,$F4
	.db $10,$3F,$42,$03
SpriteBoss4BData:
	.db $08
	.db $E0,$1F,$03,$F8
	.db $F0,$21,$03,$F8
	.db $00,$23,$03,$F8
	.db $10,$25,$03,$F8
	.db $E0,$1F,$43,$00
	.db $F0,$21,$43,$00
	.db $00,$23,$43,$00
	.db $10,$25,$43,$00
SpriteBoss4CData:
	.db $0A
	.db $D8,$27,$03,$F8
	.db $E8,$29,$03,$F8
	.db $F8,$2B,$03,$F8
	.db $08,$2D,$03,$F8
	.db $18,$2F,$03,$F8
	.db $D8,$27,$43,$00
	.db $E8,$29,$43,$00
	.db $F8,$2B,$43,$00
	.db $08,$2D,$43,$00
	.db $18,$2F,$43,$00
SpriteBoss4DData:
	.db $06
	.db $D0,$31,$03,$FC
	.db $E0,$31,$03,$FC
	.db $F0,$31,$03,$FC
	.db $00,$31,$03,$FC
	.db $10,$31,$03,$FC
	.db $20,$31,$03,$FC
SpriteBoss4EData:
	.db $08
	.db $B0,$33,$03,$FC
	.db $C0,$33,$03,$FC
	.db $D0,$33,$03,$FC
	.db $E0,$33,$03,$FC
	.db $F0,$33,$03,$FC
	.db $00,$33,$03,$FC
	.db $10,$33,$03,$FC
	.db $20,$33,$03,$FC
SpriteBoss4FData:
	.db $08
	.db $B0,$35,$03,$FC
	.db $C0,$35,$03,$FC
	.db $D0,$35,$03,$FC
	.db $E0,$35,$03,$FC
	.db $F0,$35,$03,$FC
	.db $00,$35,$03,$FC
	.db $10,$35,$03,$FC
	.db $20,$35,$03,$FC
;Level 6 boss fire
SpriteBoss50Data:
	.db $02
	.db $F8,$1F,$02,$F8
	.db $F8,$21,$02,$00
SpriteBoss51Data:
	.db $01
	.db $F8,$23,$02,$FC
SpriteBoss52Data:
	.db $01
	.db $F8,$25,$02,$FC
SpriteBoss53Data:
	.db $02
	.db $F8,$27,$02,$F8
	.db $F8,$29,$02,$00
SpriteBoss54Data:
	.db $01
	.db $F8,$2B,$02,$FC
SpriteBoss55Data:
	.db $01
	.db $F8,$2D,$02,$FC
SpriteBoss56Data:
	.db $01
	.db $F8,$2F,$02,$FC
SpriteBoss57Data:
	.db $01
	.db $F8,$31,$02,$FC
SpriteBoss58Data:
	.db $01
	.db $F8,$33,$02,$FC
SpriteBoss59Data:
	.db $01
	.db $F8,$35,$02,$FC
SpriteBoss5AData:
	.db $02
	.db $F8,$37,$02,$FC
	.db $00,$39,$02,$F4
SpriteBoss5BData:
	.db $02
	.db $F8,$3B,$02,$FC
	.db $00,$3D,$02,$F4
;TV left edge
SpriteBoss5CData:
	.db $0E
	.db $F8,$31,$03,$F8
	.db $F8,$33,$03,$00
	.db $08,$39,$03,$F8
	.db $08,$3B,$03,$00
	.db $18,$39,$03,$F8
	.db $18,$3B,$03,$00
	.db $28,$39,$03,$F8
	.db $28,$3B,$03,$00
	.db $38,$39,$03,$F8
	.db $38,$3B,$03,$00
	.db $48,$39,$03,$F8
	.db $48,$3B,$03,$00
	.db $58,$39,$03,$F8
	.db $58,$3B,$03,$00
;TV right edge
SpriteBoss5DData:
	.db $0E
	.db $F8,$35,$03,$F8
	.db $F8,$37,$03,$00
	.db $08,$3D,$03,$F8
	.db $08,$3F,$03,$00
	.db $18,$3D,$03,$F8
	.db $18,$3F,$03,$00
	.db $28,$3D,$03,$F8
	.db $28,$3F,$03,$00
	.db $38,$3D,$03,$F8
	.db $38,$3F,$03,$00
	.db $48,$3D,$03,$F8
	.db $48,$3F,$03,$00
	.db $58,$3D,$03,$F8
	.db $58,$3F,$03,$00
;Windigo walking
SpriteBoss60Data:
	.db $08
	.db $F1,$03,$01,$F0
	.db $F1,$05,$01,$F8
	.db $F1,$09,$01,$08
	.db $F1,$07,$01,$00
	.db $01,$0B,$01,$F0
	.db $01,$0D,$01,$F8
	.db $01,$0F,$01,$00
	.db $01,$11,$01,$08
SpriteBoss61Data:
	.db $08
	.db $F0,$03,$01,$F0
	.db $F0,$05,$01,$F8
	.db $F0,$07,$01,$00
	.db $F0,$09,$01,$08
	.db $00,$13,$01,$F0
	.db $00,$15,$01,$F8
	.db $00,$17,$01,$00
	.db $00,$19,$01,$08
SpriteBoss62Data:
	.db $08
	.db $F1,$03,$01,$F1
	.db $F1,$05,$01,$F9
	.db $F1,$07,$01,$01
	.db $F1,$09,$01,$09
	.db $01,$19,$01,$09
	.db $01,$1B,$01,$F1
	.db $01,$1D,$01,$F9
	.db $01,$1F,$01,$01
;Level 7 boss fire land
SpriteBoss63Data:
	.db $04
	.db $FC,$25,$40,$08
	.db $FC,$25,$00,$F0
	.db $FC,$27,$00,$F8
	.db $FC,$27,$40,$00
SpriteBoss64Data:
	.db $04
	.db $FA,$29,$40,$08
	.db $F8,$2B,$00,$F8
	.db $F8,$2B,$40,$00
	.db $FA,$29,$00,$F0
SpriteBoss65Data:
	.db $04
	.db $F8,$2D,$00,$F0
	.db $F8,$2F,$00,$F8
	.db $F8,$2F,$40,$00
	.db $F8,$2D,$40,$08
;Level 7 boss eye flash
SpriteBoss5EData:
	.db $01
	.db $F8,$21,$00,$FC
SpriteBoss5FData:
	.db $02
	.db $F8,$23,$00,$F8
	.db $F8,$25,$00,$00
;Level 7 boss fire attack
SpriteBoss69Data:
	.db $01
	.db $F8,$27,$00,$FC
SpriteBoss68Data:
	.db $01
	.db $F8,$29,$00,$FC
SpriteBoss67Data:
	.db $02
	.db $F8,$2B,$00,$F8
	.db $F8,$2B,$40,$00
SpriteBoss66Data:
	.db $02
	.db $F8,$2D,$00,$F8
	.db $F8,$2D,$40,$00
;Explosion
SpriteEnemy01Data:
	.db $02
	.db $F8,$5D,$00,$F8
	.db $F8,$5D,$40,$00
SpriteEnemy02Data:
	.db $06
	.db $F8,$5F,$00,$F0
	.db $F0,$61,$00,$F8
	.db $F0,$61,$40,$00
	.db $00,$61,$80,$F8
	.db $00,$61,$C0,$00
	.db $F8,$5F,$40,$08
SpriteEnemy03Data:
	.db $08
	.db $F0,$63,$00,$F0
	.db $F0,$65,$00,$F8
	.db $F0,$65,$40,$00
	.db $F0,$63,$40,$08
	.db $00,$63,$80,$F0
	.db $00,$65,$80,$F8
	.db $00,$65,$C0,$00
	.db $00,$63,$C0,$08
SpriteEnemy04Data:
	.db $08
	.db $F0,$67,$00,$F0
	.db $F0,$69,$00,$F8
	.db $F0,$67,$40,$08
	.db $F0,$69,$40,$00
	.db $00,$67,$80,$F0
	.db $00,$69,$80,$F8
	.db $00,$69,$C0,$00
	.db $00,$67,$C0,$08
SpriteEnemy05Data:
	.db $08
	.db $F0,$6B,$00,$F0
	.db $F0,$6D,$00,$F8
	.db $F0,$6D,$40,$00
	.db $F0,$6B,$40,$08
	.db $00,$6B,$80,$F0
	.db $00,$6D,$80,$F8
	.db $00,$6D,$C0,$00
	.db $00,$6B,$C0,$08
SpriteEnemy07Data:
	.db $02
	.db $F8,$7B,$00,$F8
	.db $F8,$7B,$40,$00
;Item HP
SpriteEnemy06Data:
	.db $02
	.db $F8,$BD,$01,$F8
	.db $F8,$BF,$01,$00

;;;;;;;;;;;;;;;;;;;;
;GAME MODE ROUTINES;
;;;;;;;;;;;;;;;;;;;;
;SELECT MODE ROUTINES
RunGameMode_Select:
	;Do jump table
	lda GameSubmode
	jsr DoJumpTable
SelectJumpTable:
	.dw RunGameSubmode_SelectInit		;$00  Init
	.dw RunGameSubmode_SelectLevel		;$01  Level select
	.dw RunGameSubmode_SelectLevelOut	;$02  Level select fade out
	.dw RunGameSubmode_SelectPlayerIn	;$03  Player select fade in
	.dw RunGameSubmode_SelectPlayer		;$04  Player select
	.dw RunGameSubmode_SelectPlayerOut	;$05  Player select fade out
	.dw RunGameSubmode_SelectEnd		;$06  End

;$06: End
RunGameSubmode_SelectEnd:
	;Check for ending area
	lda CurLevel
	cmp #$05
	bne RunGameSubmode_SelectEnd_NoEnding
	lda CurArea
	cmp #$02
	bne RunGameSubmode_SelectEnd_NoEnding
	;Next mode ($09: Ending)
	ldy #$09
	bne RunGameSubmode_SelectEnd_Next
RunGameSubmode_SelectEnd_NoEnding:
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_SelectEnd_Exit
	;Clear IRQ buffer
	jsr ClearIRQBuffer
	;Next mode ($05: Level start)
	ldy #$05
	;Check for first area
	lda CurLevel
	bne RunGameSubmode_SelectEnd_Next
	lda CurArea
	bne RunGameSubmode_SelectEnd_Next
	;Next mode ($04: Intro)
	dey
RunGameSubmode_SelectEnd_Next:
	sty GameMode
	lda #$00
	sta GameSubmode
	;Clear sound
	jmp ClearSound
RunGameSubmode_SelectEnd_Exit:
	rts

;$00: Init
RunGameSubmode_SelectInit:
	;Clear ZP $40-$CF
	jsr ClearZP_40
	;Clear demo flag
	sta DemoFlag
	;Next submode ($00: Init first)
	sta MainGameSubmode
	;Clear nametable
	jsr ClearNametableData
	;Clear scroll position
	lda TempMirror_PPUCTRL
	and #$FC
	sta TempMirror_PPUCTRL
	;Load CHR banks
	lda #$60
	sta TempCHRBanks
	lda #$7E
	sta TempCHRBanks+1
	;Next submode ($02: Level select)
	inc GameSubmode
	;Play music
	lda #MUSIC_SELECT
	jsr LoadSound
	;Clear palette
	lda #$00
	sta CurPalette
	sta FadeInitFlag
	sta FadeDirection
	;Set player continues
	lda #$03
	sta NumContinues
	;Check for level select flag
	lda TitleLevelSelectFlag
	beq RunGameSubmode_SelectInit_Next
	;Write VRAM strip (level select screen)
	lda #$09
	jsr WriteVRAMStrip
	lda #$0A
	jmp WriteVRAMStrip
RunGameSubmode_SelectInit_EntLevel:
	;Check for ending area
	lda CurLevel
	cmp #$05
	bcc RunGameSubmode_SelectInit_Next
	lda CurArea
	cmp #$02
	bne RunGameSubmode_SelectInit_Next
	;Set current area
	lda #$01
	sta CurArea
RunGameSubmode_SelectInit_Next:
	;Next submode ($03: Level select fade out)
	inc GameSubmode
	rts

;$01: Level select
RunGameSubmode_SelectLevel:
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDirection
	beq RunGameSubmode_SelectLevel_Exit
	;Check for START press
	lda JoypadDown
	and #JOY_START
	bne RunGameSubmode_SelectInit_EntLevel
	;Check for A press
	lda JoypadDown
	and #JOY_A
	beq RunGameSubmode_SelectLevel_NoA
	;Increment current area
	ldx CurArea
	cpx #$02
	bcc RunGameSubmode_SelectLevel_NoAC
	ldx #$FF
RunGameSubmode_SelectLevel_NoAC:
	inx
	stx CurArea
	;Write VRAM strip (level select screen)
	lda #$0A
	jsr WriteVRAMStrip
	lda CurArea
	clc
	adc #$82
	sta VRAMBuffer-2,x
RunGameSubmode_SelectLevel_NoA:
	;Check for B press
	lda JoypadDown
	and #JOY_B
	beq RunGameSubmode_SelectLevel_Exit
	;Increment current level
	ldx CurLevel
	cpx #$05
	bcc RunGameSubmode_SelectLevel_NoLC
	ldx #$FF
RunGameSubmode_SelectLevel_NoLC:
	inx
	stx CurLevel
	;Write VRAM strip (level select screen)
	lda #$09
	jsr WriteVRAMStrip
	lda CurLevel
	clc
	adc #$82
	sta VRAMBuffer-2,x
RunGameSubmode_SelectLevel_Exit:
	rts

;$02: Level select fade out
RunGameSubmode_SelectLevelOut:
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_SelectLevelOut_Exit
	;Write player select nametable
	ldx #$08
	jsr WriteNametableData
	;Load enemies
	ldx #$02
RunGameSubmode_SelectLevelOut_SpLoop:
	;Load enemy slot
	lda PlayerSelectEnemyY,x
	sta Enemy_Y,x
	lda PlayerSelectEnemyX,x
	sta Enemy_X,x
	lda PlayerSelectEnemySprite,x
	sta Enemy_Sprite,x
	lda PlayerSelectEyeOpen,x
	sta SelectEyeOpen,x
	;Loop for all slots
	dex
	bpl RunGameSubmode_SelectLevelOut_SpLoop
	;Next task ($02: Open)
	lda #$02
	sta SelectEyeMode
	;Write VRAM strip ("PLAYER SELECT" text)
	lda #$0E
	jsr WriteVRAMStrip
	;Write VRAM strip ("1 PLAYER VAMPIRE" text)
	lda #$19
	jsr WriteVRAMStrip
	;Set palette
	ldy #$28
	;Check for 2 player mode
	lda TitleCursorPos
	beq RunGameSubmode_SelectLevelOut_No2P
	;Set player 2 eye enemy sprite
	lda #$98
	sta Enemy_Sprite+$01
	lda #$03
	sta SelectEyeOpen,x
	;Next task ($02: Open)
	lda #$02
	sta SelectEyeMode+1
	;Write VRAM strip ("2 PLAYER THE MONSTER" text)
	lda #$1A
	jsr WriteVRAMStrip
	;Set palette
	ldy #$26
RunGameSubmode_SelectLevelOut_No2P:
	;Set palette
	sty CurPalette
	;Load CHR banks
	lda #$78
	sta TempCHRBanks
	lda #$7A
	sta TempCHRBanks+1
	ldx #$74
	stx TempCHRBanks+2
	inx
	stx TempCHRBanks+3
	inx
	stx TempCHRBanks+4
	inx
	stx TempCHRBanks+5
	;Set fade direction
	lda #$00
	sta FadeInitFlag
	sta FadeDirection
	;Next submode ($03: Player select fade in)
	inc GameSubmode
RunGameSubmode_SelectLevelOut_Exit:
	rts

;SELECT ENEMY/SPRITE DATA
PlayerSelectEnemyY:
	.db $70,$68,$A0
PlayerSelectEnemyX:
	.db $1C,$E7,$14
PlayerSelectEnemySprite:
	.db $95,$00,$99
PlayerSelectEyeOpen:
	.db $03,$00,$00

;$03: Player select fade in
RunGameSubmode_SelectPlayerIn:
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDirection
	beq RunGameSubmode_SelectPlayerIn_Exit
	;Next submode ($04: Player select)
	inc GameSubmode
RunGameSubmode_SelectPlayerIn_Exit:
	rts

;$04: Player select
RunGameSubmode_SelectPlayer:
	;Handle player select
	jsr SelectPlayerSub
	;Check for START press
	lda JoypadDown
	and #JOY_START
	beq RunGameSubmode_SelectPlayer_Exit
	;Clear sound
	jsr ClearSound
	;Play sound
	lda #SE_SELECT
	jsr LoadSound
	;Set timer
	lda #$28
	sta GameModeTimer2
	;Next submode ($05: Player select fade out)
	inc GameSubmode
RunGameSubmode_SelectPlayer_Exit:
	rts

;$05: Player select fade out
RunGameSubmode_SelectPlayerOut:
	;Process enemies
	jsr MoveSelectEnemies
	;Check if timer 0
	lda GameModeTimer2
	bne RunGameSubmode_SelectPlayerOut_Continue
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_SelectPlayer_Exit
	;Next submode ($06: End)
	inc GameSubmode
	rts
RunGameSubmode_SelectPlayerOut_Continue:
	;Decrement timer
	dec GameModeTimer
	;If bit 0 of timer not 0, exit early
	lda GameModeTimer
	and #$01
	bne RunGameSubmode_SelectPlayerOut_Exit
	;Write select VRAM strip for player 1
	ldy #$00
	jsr WriteSelectVRAMStrip
	;Check for player 1 monster
	lda SelectEyeVRAMStrip
	cmp #$1A
	bne RunGameSubmode_SelectPlayerOut_NoSet1P
	lda $10
	bmi RunGameSubmode_SelectPlayerOut_NoSet1P
	;Set digit tile '1' in VRAM
	lda #$D1
	sta VRAMBuffer-$1B,x
RunGameSubmode_SelectPlayerOut_NoSet1P:
	;Write select VRAM strip for player 2
	ldy #$01
	jsr WriteSelectVRAMStrip
	;Decrement timer
	dec GameModeTimer2
	rts
RunGameSubmode_SelectPlayerOut_Exit:
	;Write palette
	jmp WritePalette

WriteSelectVRAMStrip:
	;Check for player active
	lda SelectEyeVRAMStrip,y
	beq WriteSelectVRAMStrip_Exit
	;Write/clear VRAM strip based on bit 3 of timer
	lda GameModeTimer
	and #$08
	asl
	asl
	asl
	asl
	adc SelectEyeVRAMStrip,y
	sta $10
	jmp WriteVRAMStrip
WriteSelectVRAMStrip_Exit:
	rts

MoveSelectEnemies:
	;Process enemies
	ldx #$01
MoveSelectEnemies_Loop:
	;Process enemy
	jsr MoveSelectEyeSub
	;Loop for all moving enemies
	dex
	bpl MoveSelectEnemies_Loop
	rts

MoveSelectEyeSub:
	;Increment animation timer
	inc SelectEyeTimer,x
	;Do jump table
	lda SelectEyeMode,x
	jsr DoJumpTable
SelectEyeJumpTable:
	.dw SelectEyeSub0	;$00  Closed
	.dw SelectEyeSub1	;$01  Opening
	.dw SelectEyeSub2	;$02  Open
	.dw SelectEyeSub3	;$03  Closing

;$01: Opening
SelectEyeSub1:
	;If bits 0-1 of timer not 0, exit early
	lda SelectEyeTimer,x
	and #$03
	bne SelectEyeSub0
	;Increment open amount, check if 3
	ldy SelectEyeOpen,x
	bmi SelectEyeSub1_NoC
	cpy #$03
	bcs SelectEyeSub1_Next
SelectEyeSub1_NoC:
	inc SelectEyeOpen,x
SelectEyeSub1_SetSprite:
	;Set enemy sprite based on select eye open amount
	txa
	asl
	asl
	adc SelectEyeOpen,x
	tay
	lda PlayerSelectEyeOpenSprite,y
	sta Enemy_Sprite,x

;$00: Closed
SelectEyeSub0:
	;Do nothing
	rts

SelectEyeSub1_Next:
	;Clear animation timer
	lda #$00
	sta SelectEyeTimer,x
	;Next task ($02: Open)
	inc SelectEyeMode,x
	rts

;$03: Closing
SelectEyeSub3:
	;If bits 0-1 of timer not 0, exit early
	lda SelectEyeTimer,x
	and #$03
	bne SelectEyeSub0
	;Decrement open amount, check if < 0
	lda SelectEyeOpen,x
	bmi SelectEyeSub3_Close
	dec SelectEyeOpen,x
	bpl SelectEyeSub1_SetSprite
SelectEyeSub3_Close:
	lda #$00
	sta PlayerAnimOffs,x
	rts

;$02: Open
SelectEyeSub2:
	;Check for player 2
	ldy #$00
	cpx #$00
	beq SelectEyeSub2_No2P
	ldy #$07
SelectEyeSub2_No2P:
	tya
	clc
	adc #$07
	sta $10
	;Set enemy sprite based on timer value
	lda PlayerAnimTimer,x
SelectEyeSub2_Loop:
	cmp PlayerSelectEyeBlinkTimer,y
	beq SelectEyeSub2_Set
	iny
	cpy $10
	bcc SelectEyeSub2_Loop
	rts
SelectEyeSub2_Set:
	;Set enemy sprite
	lda PlayerSelectEyeBlinkSprite,y
	sta Enemy_Sprite,x
	;Set select eye open amount
	lda PlayerSelectEyeBlinkOpen,y
	sta SelectEyeOpen,x
	rts

;SELECT ENEMY/SPRITE DATA
PlayerSelectEyeBlinkTimer:
	.db $10,$12,$14,$16,$18,$1A,$1C
	.db $30,$32,$34,$36,$38,$3A,$3C
PlayerSelectEyeBlinkSprite:
	.db $95,$94,$93,$92,$93,$94,$95
	.db $98,$97,$96,$00,$96,$97,$98
PlayerSelectEyeBlinkOpen:
	.db $03,$02,$01,$00,$01,$02,$03
	.db $03,$02,$01,$00,$01,$02,$03
PlayerSelectEyeOpenSprite:
	.db $92,$93,$94,$95
	.db $00,$96,$97,$98

SelectPlayerSub_NoSelect:
	;If bit 0 of global timer not 0, update VRAM strips
	lda GlobalTimer
	and #$01
	beq SelectPlayerSub_DoVRAM
	;Write palette
	jsr WritePalette
	;Process enemies
	jmp MoveSelectEnemies
SelectPlayerSub_DoVRAM:
	;Check for player 1
	lda SelectEyeVRAMStrip
	beq SelectPlayerSub_NoSet1P
	;Write VRAM strip
	jsr WriteVRAMStrip
	;Check for player 1 monster
	lda SelectEyeVRAMStrip
	cmp #$1A
	bne SelectPlayerSub_NoSet1P
	;Set digit tile '1' in VRAM
	lda #$D1
	sta VRAMBuffer-$1B,x
SelectPlayerSub_NoSet1P:
	;Check for player 2
	lda SelectEyeVRAMStrip+1
	beq SelectPlayerSub_NoSet2P
	;Write VRAM strip
	jsr WriteVRAMStrip
SelectPlayerSub_NoSet2P:
	;Process enemies
	jmp MoveSelectEnemies
SelectPlayerSub:
	;Check for SELECT press
	lda JoypadDown
	and #JOY_SELECT
	beq SelectPlayerSub_NoSelect
	;Play sound
	lda #SE_CURSMOVE
	jsr LoadSound
	;Toggle player select cursor position
	lda SelectCursorPos
	eor #$01
	sta SelectCursorPos
	;Check for 2 player mode
	lda TitleCursorPos
	bne SelectPlayerSub_2P
	;Check for player 1 vampire
	lda SelectCursorPos
	beq SelectPlayerSub_Vampire1P
	;Clear VRAM strip ("1 PLAYER VAMPIRE" text)
	lda #$99
	jsr WriteVRAMStrip
	;Set VRAM strips
	lda #$1A
	sta SelectEyeVRAMStrip
	lda #$00
	sta SelectEyeVRAMStrip+1
	;Next task ($03: Closing)
	lda #$03
	sta SelectEyeMode
	;Next task ($01: Opening)
	lda #$01
	sta SelectEyeMode+1
	;Load palette
	lda #$2A
	ldx #$00
	jsr LoadPalette
	lda #$2B
	bne SelectPlayerSub_SetSpPalette
SelectPlayerSub_Vampire1P:
	;Set VRAM strips
	lda #$19
	sta SelectEyeVRAMStrip
	lda #$00
	sta SelectEyeVRAMStrip+1
	;Clear VRAM strip ("2 PLAYER THE MONSTER" text)
	lda #$9A
	jsr WriteVRAMStrip
	;Next task ($01: Opening)
	lda #$01
	sta SelectEyeMode
	;Next task ($03: Closing)
	lda #$03
	sta SelectEyeMode+1
	;Load palette
	lda #$28
	ldx #$00
	jsr LoadPalette
	lda #$29
SelectPlayerSub_SetSpPalette:
	ldx #$10
	jsr LoadPalette
	;Process enemies
	jmp MoveSelectEnemies
SelectPlayerSub_2P:
	;Check for player 1 vampire
	lda SelectCursorPos
	beq SelectPlayerSub_Vampire2P
	;Clear VRAM strips
	lda #$99
	jsr WriteVRAMStrip
	lda #$9A
	jsr WriteVRAMStrip
	;Set VRAM strips
	lda #$20
	sta SelectEyeVRAMStrip
	lda #$21
	sta SelectEyeVRAMStrip+1
	;Process enemies
	jmp MoveSelectEnemies
SelectPlayerSub_Vampire2P:
	;Set VRAM strips
	lda #$19
	sta SelectEyeVRAMStrip
	lda #$1A
	sta SelectEyeVRAMStrip+1
	;Clear VRAM strips
	lda #$A0
	jsr WriteVRAMStrip
	lda #$A1
	jsr WriteVRAMStrip
	;Process enemies
	jmp MoveSelectEnemies

;;;;;;;;;;;;;;;;
;NAMETABLE DATA;
;;;;;;;;;;;;;;;;
Nametable08Data:
	.dw $2000
	.db $7E,$00,$3C,$00,$C5,$7F,$82,$00,$00,$C3,$23,$15,$00,$C6,$89,$82
	.db $00,$00,$C4,$2E,$14,$00,$C6,$96,$81,$00,$C6,$00,$13,$00,$C7,$62
	.db $86,$00,$06,$02,$02,$07,$08,$13,$00,$C7,$69,$88,$00,$09,$02,$02
	.db $0A,$0B,$00,$0C,$12,$00,$87,$70,$71,$02,$72,$73,$00,$00,$C7,$0D
	.db $12,$00,$C5,$74,$82,$00,$00,$C7,$14,$11,$00,$C6,$79,$81,$00,$C8
	.db $1B,$11,$00,$C3,$84,$84,$00,$87,$88,$00,$C8,$26,$11,$00,$C7,$8F
	.db $C8,$32,$11,$00,$C7,$9C,$C7,$3A,$12,$00,$C7,$A3,$C7,$41,$12,$00
	.db $C6,$AA,$82,$00,$00,$C6,$48,$13,$00,$C5,$B0,$82,$00,$00,$C5,$4E
	.db $14,$00,$C5,$B5,$81,$00,$C6,$53,$13,$00,$C7,$BA,$81,$00,$C4,$59
	.db $14,$00,$C6,$C1,$82,$00,$00,$C3,$5D,$17,$00,$C4,$C7,$84,$00,$00
	.db $60,$61,$18,$00,$C4,$CB,$7E,$00,$43,$00,$08,$FF,$92,$0F,$CF,$0F
	.db $0F,$5F,$5F,$55,$55,$00,$0C,$F0,$F0,$F5,$F5,$55,$55,$00,$00,$04
	.db $FF,$84,$55,$55,$00,$00,$04,$FF,$8A,$55,$55,$00,$FC,$00,$00,$55
	.db $55,$75,$55,$08,$FF,$08,$00,$00
Nametable0AData:
	.dw $2000
	.db $7E,$00,$24,$00,$C5,$7F,$1A,$00,$C6,$89,$12,$00,$C3,$23,$05,$00
	.db $C6,$96,$12,$00,$C4,$2E,$04,$00,$C7,$62,$11,$00,$C5,$01,$03,$00
	.db $C7,$69,$11,$00,$85,$06,$02,$02,$07,$08,$04,$00,$85,$70,$71,$02
	.db $72,$73,$12,$00,$89,$09,$02,$02,$0A,$0B,$00,$0C,$00,$00,$C5,$74
	.db $12,$00,$C7,$0D,$81,$00,$C6,$79,$12,$00,$C7,$14,$81,$00,$C3,$84
	.db $83,$00,$87,$88,$11,$00,$C8,$1B,$81,$00,$C7,$8F,$10,$00,$C8,$26
	.db $81,$00,$C7,$9C,$10,$00,$C8,$32,$81,$00,$C7,$A3,$10,$00,$C7,$3A
	.db $82,$00,$00,$C6,$AA,$11,$00,$C7,$41,$03,$00,$C5,$B0,$12,$00,$C6
	.db $48,$03,$00,$C5,$B5,$12,$00,$C5,$4E,$03,$00,$C7,$BA,$10,$00,$C6
	.db $53,$03,$00,$C6,$C1,$12,$00,$C4,$59,$06,$00,$C4,$C7,$12,$00,$C3
	.db $5D,$07,$00,$C4,$CB,$12,$00,$82,$60,$61,$7E,$00,$47,$00,$08,$FF
	.db $92,$55,$55,$5F,$5F,$FF,$FF,$00,$00,$55,$55,$F5,$F5,$FF,$FF,$00
	.db $00,$55,$55,$04,$FF,$84,$00,$00,$55,$55,$04,$FF,$86,$00,$00,$55
	.db $55,$FF,$FF,$04,$00,$10,$FF,$00

;;;;;;;;;;;;;;;;;;;;
;GAME MODE ROUTINES;
;;;;;;;;;;;;;;;;;;;;
;STAGE CLEAR MODE ROUTINES
RunGameMode_StageClear:
	;Do jump table
	lda GameSubmode
	jsr DoJumpTable
StageClearJumpTable:
	.dw RunGameSubmode_StageClearFadeOut	;$00  Fade out
	.dw RunGameSubmode_StageClearInit	;$01  Init
	.dw RunGameSubmode_StageClearInitP1	;$02  Init player 1
	.dw RunGameSubmode_StageClearInitP2	;$03  Init player 2
	.dw RunGameSubmode_StageClearWait	;$04  Wait
	.dw RunGameSubmode_StageClearScoreUp	;$05  Score up
	.dw RunGameSubmode_StageClearWaitEnd	;$06  Wait end

;$00: Fade out
RunGameSubmode_StageClearFadeOut_Exit:
	rts
RunGameSubmode_StageClearFadeOut:
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_StageClearFadeOut_Exit
	;Next submode ($01: Init)
	inc GameSubmode
	;Clear IRQ buffer
	jmp ClearIRQBuffer

;$01: Init
RunGameSubmode_StageClearInit:
	;Clear screen
	jsr ClearScreen
	;Clear palette
	lda #$00
	sta CurPalette
	;Load CHR banks
	lda #$78
	sta TempCHRBanks
	lda #$7A
	sta TempCHRBanks+1
	ldx #$74
	stx TempCHRBanks+2
	inx
	stx TempCHRBanks+3
	inx
	stx TempCHRBanks+4
	inx
	stx TempCHRBanks+5
	;Check for 2 player mode
	ldy #$00
	ldx #$08
	lda SelectCursorPos
	beq RunGameSubmode_StageClearInit_No2P
	ldy #$03
	ldx #$0A
RunGameSubmode_StageClearInit_No2P:
	;Load enemies
	lda StageClearEnemyX,y
	sta Enemy_X
	lda StageClearEnemyX+1,y
	sta Enemy_X+$01
	lda StageClearEnemyX+2,y
	sta Enemy_X+$02
	;Write stage clear nametable
	jsr WriteNametableData
	;Load enemies
	ldx #$02
RunGameSubmode_StageClearInit_SpLoop:
	;Load enemy slot
	lda StageClearEnemySprite,x
	sta Enemy_Sprite,x
	lda StageClearEnemyY,x
	sta Enemy_Y,x
	lda #$00
	sta Enemy_Props,x
	;Loop for all slots
	dex
	bpl RunGameSubmode_StageClearInit_SpLoop
	;If player 1 not active, skip this part
	ldy #$00
	lda PlayerMode
	cmp #$02
	bne RunGameSubmode_StageClearInit_NoSetP1
	;Next task ($02: Open)
	ldx PlayerCharacter
	sta SelectEyeMode,x
	;Set enemy sprite
	lda StageClearEyeOpenSprite,x
	sta Enemy_Sprite,x
	;Increment palette table index
	iny
RunGameSubmode_StageClearInit_NoSetP1:
	;If player 2 not active, skip this part
	lda PlayerMode+1
	cmp #$02
	bne RunGameSubmode_StageClearInit_NoSetP2
	;Next task ($02: Open)
	ldx PlayerCharacter+1
	sta SelectEyeMode,x
	;Set enemy sprite
	lda StageClearEyeOpenSprite,x
	sta Enemy_Sprite,x
	;Increment palette table index
	iny
	iny
RunGameSubmode_StageClearInit_NoSetP2:
	;Check for 2 player palette index
	dey
	cpy #$02
	beq RunGameSubmode_StageClearInit_NoPal2P
	;Adjust palette index based on player character
	tya
	eor SelectCursorPos
	tay
RunGameSubmode_StageClearInit_NoPal2P:
	;Set palette
	lda StageClearPaletteTable,y
	sta CurPalette
	;Draw top score
	jsr DrawStageClearTopScore
	;Write VRAM strip ("STAGE   CLEAR" text)
	lda #$18
	jsr WriteVRAMStrip
	;Set level number digit tile in VRAM
	lda CurLevel
	clc
	adc #$D0
	sta VRAMBuffer-8,x
	rts

;STAGE CLEAR ENEMY/SPRITE DATA
StageClearEyeOpenSprite:
	.db $95,$98
StageClearEnemySprite:
	.db $92,$00,$99
StageClearEnemyY:
	.db $70,$68,$A0
StageClearEnemyX:
	.db $1C,$E7,$14
	.db $DC,$28,$D5
StageClearPaletteTable:
	.db $28,$2A,$26

DrawStageClearTopScore:
	;Write VRAM strip ("HI SCORE" text)
	lda #$1D
	jsr WriteVRAMStrip
	;Draw top score
	lda TopScoreLo
	sta $0C
	lda TopScoreMid
	sta $0D
	lda TopScoreHi
	sta $0E
	lda #$D0
	sta $0F
	lda #$20
	sta $0B
	lda #$8D
	jmp DrawDecimalValue

;$02: Init player 1
RunGameSubmode_StageClearInitP1:
	;If player 1 not active, go to next submode ($03: Init player 2)
	lda PlayerMode
	cmp #$02
	bne RunGameSubmode_StageClearInitP1_Next
	;Write VRAM strip ("1 PLAYER VAMPIRE" text)
	lda #$19
	;Check for player 1 vampire
	ldx SelectCursorPos
	beq RunGameSubmode_StageClearInitP1_Vampire
	;Write VRAM strip ("1 PLAYER THE MONSTER" text)
	lda #$1B
RunGameSubmode_StageClearInitP1_Vampire:
	jsr WriteVRAMStrip
	;Write VRAM strip ("SCORE" text)
	lda #$1E
	jsr WriteVRAMStrip
	;Draw player 1 score
	jsr DrawStageClearScoreP1
	;Write VRAM strip ("BONUS" text)
	lda #$1F
	jsr WriteVRAMStrip
	;Draw player 1 bonus
	jsr DrawStageClearBonusP1
RunGameSubmode_StageClearInitP1_Next:
	;Next submode ($03: Init player 2)
	inc GameSubmode
	rts

DrawStageClearScoreP1:
	;Draw player 1 score
	lda PlayerScoreLo
	sta $0C
	lda PlayerScoreMid
	sta $0D
	lda #$D0
	sta $0F
	lda #$21
	sta $0B
	lda #$A9
	jmp DrawDecimalValue

DrawStageClearBonusP1:
	;Draw player 1 bonus
	lda PlayerBonusLo
	sta $0C
	lda PlayerBonusMid
	sta $0D
	lda PlayerBonusHi
	sta $0E
	lda #$D0
	sta $0F
	lda #$22
	sta $0B
	lda #$49
	jmp DrawDecimalValue

;$03: Init player 2:
RunGameSubmode_StageClearInitP2:
	;Set timer
	lda #$10
	sta GameModeTimer2
	;If player 2 not active, go to next submode ($04: Wait)
	lda PlayerMode+1
	cmp #$02
	bne RunGameSubmode_StageClearInitP1_Next
	;Next submode ($04: Wait)
	inc GameSubmode
	;Write VRAM strip ("2 PLAYER THE MONSTER" text)
	lda #$1A
	;Check for player 1 vampire
	ldx SelectCursorPos
	beq RunGameSubmode_StageClearInitP2_Vampire
	;Write VRAM strip ("2 PLAYER VAMPIRE" text)
	lda #$1C
RunGameSubmode_StageClearInitP2_Vampire:
	jsr WriteVRAMStrip
	;Write VRAM strip ("SCORE" text)
	lda #$1E
	jsr WriteVRAMStrip
	;Set modified VRAM address for player 2 in VRAM
	lda #$72
	sta VRAMBuffer-8,x
	;Draw player 2 score
	jsr DrawStageClearScoreP2
	;Write VRAM strip ("BONUS" text)
	lda #$1F
	jsr WriteVRAMStrip
	;Set modified VRAM address for player 2 in VRAM
	lda #$12
	sta VRAMBuffer-8,x
	;Draw player 1 bonus
	jmp DrawStageClearBonusP2

DrawStageClearScoreP2:
	;Draw player 2 score
	lda PlayerScoreLo+1
	sta $0C
	lda PlayerScoreMid+1
	sta $0D
	lda #$D0
	sta $0F
	lda #$21
	sta $0B
	lda #$B1
	jmp DrawDecimalValue

DrawStageClearBonusP2:
	;Draw player 2 bonus
	lda PlayerBonusLo+1
	sta $0C
	lda PlayerBonusMid+1
	sta $0D
	lda PlayerBonusHi+1
	sta $0E
	lda #$D0
	sta $0F
	lda #$22
	sta $0B
	lda #$51
	jmp DrawDecimalValue

;$04: Wait
RunGameSubmode_StageClearWait:
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDirection
	beq RunGameSubmode_StageClearWait_Exit
	;Process enemies
	jsr MoveSelectEnemies
	;Decrement timer, check if 0
	dec GameModeTimer2
	bne RunGameSubmode_StageClearWait_Exit
RunGameSubmode_StageClearWait_Next:
	;Next submode ($05: Score up)
	inc GameSubmode
RunGameSubmode_StageClearWait_Exit:
	rts

;$05: Score up
RunGameSubmode_StageClearScoreUp:
	;Process enemies
	jsr MoveSelectEnemies
	;Set timer
	lda #$80
	sta GameModeTimer2
	;Clear score up flag
	lda #$00
	sta $18
	;If player 1 active, handle score up for player 1
	lda PlayerMode
	cmp #$02
	bne RunGameSubmode_StageClearScoreUp_NoP1
	;Handle score up for player 1
	ldx #$00
	jsr ScoreUpSub
RunGameSubmode_StageClearScoreUp_NoP1:
	;If player 2 active, handle score up for player 2
	lda PlayerMode+1
	cmp #$02
	bne RunGameSubmode_StageClearScoreUp_NoP2
	;Handle score up for player 2
	ldx #$01
	jsr ScoreUpSub
RunGameSubmode_StageClearScoreUp_NoP2:
	;If score up flag not set, go to next submode ($06: Wait end)
	lda $18
	beq RunGameSubmode_StageClearWait_Next
	;If bit 0 of global timer 0, play sound
	lda GlobalTimer
	and #$01
	bne RunGameSubmode_StageClearScoreUp_NoSound
	;Play sound
	lda #SE_SCOREUP
	jsr LoadSound
RunGameSubmode_StageClearScoreUp_NoSound:
	;Draw top score
	jmp DrawStageClearTopScore

;$06: Wait end
RunGameSubmode_StageClearWaitEnd:
	;Process enemies
	jsr MoveSelectEnemies
	;If timer not 0, exit early
	lda GameModeTimer2
	bne RunGameSubmode_StageClearWaitEnd_Continue
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_StageClearWaitEnd_Exit
	;Clear player bonus
	lda #$00
	sta PlayerBonusMid
	sta PlayerBonusMid+1
	lda #$01
	sta MainGameSubmode
	;Next mode ($05: Level start)
	ldy #$05
	;Check for ending area
	lda CurLevel
	cmp #$06
	bne RunGameSubmode_StageClearWaitEnd_NoEnding
	;Next mode ($09: Ending)
	ldy #$09
RunGameSubmode_StageClearWaitEnd_NoEnding:
	sty GameMode
	jmp GoToNextGameMode_ClearSub
RunGameSubmode_StageClearWaitEnd_Continue:
	;Decrement timer
	dec GameModeTimer2
RunGameSubmode_StageClearWaitEnd_Exit:
	rts

ScoreUpSub:
	;If player bonus 0, exit early
	lda PlayerBonusLo,x
	ora PlayerBonusMid,x
	ora PlayerBonusHi,x
	beq RunGameSubmode_StageClearWaitEnd_Exit
	;Set score up flag
	inc $18
	;Subtract 2 points from bonus
	lda #$02
	sta $00
	lda #$00
	sta $01
	sta $02
	sec
	lda PlayerBonusLo,x
	ldy #$00
	jsr SubScoreSub
	sta PlayerBonusLo,x
	lda PlayerBonusMid,x
	iny
	jsr SubScoreSub
	sta PlayerBonusMid,x
	lda PlayerBonusHi,x
	iny
	jsr SubScoreSub
	sta PlayerBonusHi,x
	;Give player 2 points
	lda #$02
	sta $00
	lda #$00
	sta $01
	sta $02
	jsr GivePoints
	;Check for player 2
	txa
	bne ScoreUpSub_P2
	;Draw player 1 score
	jsr DrawStageClearScoreP1
	;Draw player 1 bonus
	jmp DrawStageClearBonusP1
ScoreUpSub_P2:
	;Draw player 2 score
	jsr DrawStageClearScoreP2
	;Draw player 2 bonus
	jmp DrawStageClearBonusP2

;;;;;;;;;;;;;;;;
;ENEMY ROUTINES;
;;;;;;;;;;;;;;;;
;$04: Zombie
Enemy04JumpTable:
	.dw Enemy04_Sub0	;$00  Init
	.dw Enemy04_Sub1	;$01  Main
;$00: Init
Enemy04_Sub0:
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	beq Enemy04_Sub0_Init
	;Check if enemy is on left side of screen
	ldy Enemy_XHi+$08,x
	bmi Enemy04_Sub0_Init
	rts
Enemy04_Sub0_Init:
	;Set enemy grounded
	sec
	lda Enemy_Y+$08,x
	sbc #$08
	bcs Enemy04_Sub0_NoYC
	sbc #$0F
	dec Enemy_YHi+$08,x
Enemy04_Sub0_NoYC:
	sta Enemy_Y+$08,x
	;Set enemy X velocity to target player
	lda #$00
	jmp SetEnemyXVel
;$01: Main
Enemy04_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Check if on slope
	lda Enemy_Temp3,x
	bne Enemy04_Sub1_Slope
	;If bit 0 of global timer = bit 0 of enemy slot index, skip this part
	txa
	eor GlobalTimer
	lsr
	bcc Enemy04_Sub1_Move
	;Check to turn around
	jsr CheckEnemyTurnArea
	bcs Enemy04_Sub1_Flip
	;Check for ground collision
	ldy #$01
	jsr EnemyGetGroundCollision_AnyY
	bcc Enemy04_Sub1_Flip
	;Check for 45 deg. slope right collision type
	cmp #$04
	beq Enemy04_Sub1_SlopeRight
	;Check for slope top collision type
	cmp #$13
	beq Enemy04_Sub1_SlopeTop
	;If wall collision, flip enemy X
	jsr EnemyGetWallCollision
	bcs Enemy04_Sub1_Flip
	;Check for behind BG area collision type
	ldy #$00
	cmp #$02
	bne Enemy04_Sub1_NoBehindBG
	;Set enemy priority to be behind background
	ldy #$20
Enemy04_Sub1_NoBehindBG:
	sty $00
	;Set enemy props
	lda Enemy_Props+$08,x
	and #$DF
	ora $00
	sta Enemy_Props+$08,x
Enemy04_Sub1_Slope:
	;Check if on slope
	lda Enemy_Temp3,x
	beq Enemy04_Sub1_Move
	;Move enemy up $01
	lda Enemy_Y+$08,x
	sec
	sbc #$01
	bcs Enemy04_Sub1_GroundedNoYC
	dec Enemy_YHi+$08,x
	sbc #$0F
Enemy04_Sub1_GroundedNoYC:
	sta Enemy_Y+$08,x
Enemy04_Sub1_Move:
	;Move enemy X
	jmp MoveEnemyX
Enemy04_Sub1_Flip:
	;Flip enemy X
	jmp FlipEnemyX
Enemy04_Sub1_SlopeTop:
	;Move enemy up $01
	dec Enemy_Y+$08,x
Enemy04_Sub1_SlopeRight:
	;Move enemy X
	jsr MoveEnemyX
	;Set enemy grounded
	jsr HandleEnemySlopeCollision
	sec
	sbc #$08
	bcs Enemy04_Sub1_SlopeNoYC
	dec Enemy_YHi+$08,x
	sbc #$0F
Enemy04_Sub1_SlopeNoYC:
	sta Enemy_Y+$08,x
	;Set on slope flag
	inc Enemy_Temp3,x
	rts

;$05: Winged panther
Enemy05JumpTable:
	.dw Enemy05_Sub0	;$00  Init
	.dw Enemy05_Sub1	;$01  Fly
	.dw Enemy05_Sub2	;$02  Dive
;$00: Init
Enemy05_Sub0:
	;Set enemy target Y position
	jsr InitEnemyTargetYPos
	;Set animation timer
	lda #$40
	sta Enemy_Temp1,x
	;Set enemy X velocity to target player
	lda #$08
	jmp SetEnemyXVel
;$01: Fly
Enemy05_Sub1:
	;Check for behind BG area collision type
	jsr EnemyGetWallCollision
	ldy #$00
	cmp #$02
	bne Enemy05_Sub1_NoBehindBG
	;Set enemy priority to be behind background
	ldy #$20
Enemy05_Sub1_NoBehindBG:
	sty $00
	;Set enemy props
	lda Enemy_Props+$08,x
	and #$DF
	ora $00
	sta Enemy_Props+$08,x
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If enemy offscreen, don't play sound
	lda Enemy_XHi+$08,x
	ora Enemy_YHi+$08,x
	bne Enemy05_Sub1_NoSound
	;Check for end of animation
	lda Enemy_AnimTimer,x
	bne Enemy05_Sub1_NoSound
	lda Enemy_AnimOffs,x
	bne Enemy05_Sub1_NoSound
	;Play sound
	lda #SE_ROCFLY
	jsr LoadSound
Enemy05_Sub1_NoSound:
	;Adjust enemy Y velocity to target Y position
	jsr UpdateEnemyTargetYPos
	;If enemy offscreen horizontally, don't set enemy X velocity
	lda Enemy_XHi+$08,x
	bne Enemy05_Sub1_NoSetX
	;Find closest player
	jsr FindClosestPlayerX
	;If player X distance from enemy >= $20, don't set enemy X velocity
	lda Enemy_X,y
	sbc Enemy_X+$08,x
	adc #$20
	cmp #$40
	bcs Enemy05_Sub1_NoSetX
	;Set enemy props/X velocity
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	ror
	lsr
	and #$40
	sta Enemy_Props+$08,x
	beq Enemy05_Sub1_Right
	lda #$FF
Enemy05_Sub1_Right:
	sta Enemy_XVel,x
	;Move enemy Y
	jsr MoveEnemyY
	jmp Enemy05_Sub1_NoFlip
Enemy05_Sub1_NoSetX:
	;Move enemy
	jsr MoveEnemyXY
	;If enemy X screen not $07, don't flip enemy X
	lda Enemy_X+$08,x
	adc TempMirror_PPUSCROLL_X
	lda Enemy_XHi+$08,x
	adc CurScreenX
	cmp #$07
	bne Enemy05_Sub1_NoFlip
	;If enemy X velocity left, don't flip enemy X
	lda Enemy_XVel,x
	bmi Enemy05_Sub1_NoFlip
	;Flip enemy X
	jsr FlipEnemyX
Enemy05_Sub1_NoFlip:
	;If enemy offscreen, exit early
	lda Enemy_YHi+$08,x
	ora Enemy_XHi+$08,x
	bne Enemy05_Sub2_Exit
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy05_Sub2_Exit
	;Next task ($02: Dive)
	inc Enemy_Mode,x
	;Find closest player
	jsr FindClosestPlayerX
	;Set enemy velocity to target player
	jsr TargetPlayerFlying
	;Set enemy props
	lda Enemy_XVel,x
	lsr
	and #$40
	sta Enemy_Props+$08,x
	rts
;$02: Dive
Enemy05_Sub2:
	;Check for behind BG area collision type
	jsr EnemyGetWallCollision
	ldy #$00
	cmp #$02
	bne Enemy05_Sub2_NoBehindBG
	;Set enemy priority to be behind background
	ldy #$20
Enemy05_Sub2_NoBehindBG:
	sty $00
	;Set enemy props
	lda Enemy_Props+$08,x
	and #$DF
	ora $00
	sta Enemy_Props+$08,x
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jsr MoveEnemyXY
	;If enemy X screen $07, clear enemy X velocity
	lda Enemy_X+$08,x
	adc TempMirror_PPUSCROLL_X
	lda Enemy_XHi+$08,x
	adc CurScreenX
	cmp #$07
	bne Enemy05_Sub2_NoClearX
	;Clear enemy X velocity
	lda #$00
	sta Enemy_XVel,x
	sta Enemy_XVelLo,x
Enemy05_Sub2_NoClearX:
	;Accelerate upward
	sec
	lda Enemy_YVelLo,x
	sbc #$28
	sta Enemy_YVelLo,x
	bcs Enemy05_Sub2_NoYC
	dec Enemy_YVel,x
Enemy05_Sub2_NoYC:
	;If enemy Y velocity down, exit early
	lda Enemy_YVel,x
	bpl Enemy05_Sub2_Exit
	;If enemy Y position >= $20, exit early
	lda Enemy_YHi+$08,x
	bmi Enemy05_Sub2_Next
	bne Enemy05_Sub2_Exit
	lda Enemy_Y+$08,x
	cmp #$20
	bcs Enemy05_Sub2_Exit
Enemy05_Sub2_Next:
	;Next task ($00: Init)
	lda #$00
	sta Enemy_Mode,x
Enemy05_Sub2_Exit:
	rts

;$06: Skeleton
Enemy06JumpTable:
	.dw Enemy06_Sub0	;$00  Init
	.dw Enemy06_Sub1	;$01  Main
	.dw Enemy06_Sub2	;$02  Throw
;$00: Init
Enemy06_Sub0:
	;Set animation timer randomly
	lda PRNGValue
	and #$3F
	clc
	adc #$40
	sta Enemy_Temp1,x
	;Set enemy X velocity to target player
	lda #$02
	jmp SetEnemyXVel
;$01: Main
Enemy06_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Check to turn around
	jsr CheckEnemyTurnArea
	bcs Enemy06_Sub1_Flip
	;Move enemy X
	jsr MoveEnemyX
	;Set enemy props
	sec
	lda Enemy_X+$08,x
	sbc Enemy_X
	ror
	lsr
	and #$40
	sta Enemy_Props+$08,x
	;If no ground collision, reset animation timer
	jsr EnemyGetGroundCollision
	bcc Enemy06_Sub1_SetT
	;If wall collision, reset animation timer
	ldy #$03
	jsr EnemyGetWallCollision_AnyY
	bcs Enemy06_Sub1_SetT
	;Check for behind BG area collision type
	ldy #$00
	cmp #$02
	bne Enemy06_Sub1_NoBehindBG
	;Set enemy priority to be behind background
	ldy #$20
Enemy06_Sub1_NoBehindBG:
	sty $00
	;Set enemy props
	lda Enemy_Props+$08,x
	and #$DF
	ora $00
	sta Enemy_Props+$08,x
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy06_Sub1_Exit
	;If enemy offscreen, reset animation timer
	lda Enemy_YHi+$08,x
	ora Enemy_XHi+$08,x
	bne Enemy06_Sub1_SetT
	;Check if player is in range vertically
	ldy #$01
Enemy06_Sub1_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc Enemy06_Sub1_PlayerNext
	;If player Y distance from enemy < $10, go to next task ($02: Throw)
	lda Enemy_Y+$08,x
	sec
	sbc Enemy_Y,y
	clc
	adc #$10
	cmp #$20
	bcc Enemy06_Sub1_Next
Enemy06_Sub1_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy06_Sub1_PlayerLoop
Enemy06_Sub1_SetT:
	;Reset animation timer randomly
	lda PRNGValue
	and #$3F
	ora #$40
	sta Enemy_Temp1,x
Enemy06_Sub1_Flip:
	;Flip enemy X
	jmp FlipEnemyXVel
Enemy06_Sub1_Next:
	;Set enemy sprite
	lda #$0E
	sta Enemy_Sprite+$08,x
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	;Next task ($02: Throw)
	inc Enemy_Mode,x
Enemy06_Sub1_Exit:
	rts
;$02: Throw
Enemy06_Sub2:
	;Update enemy animation
	ldy #$0A
	jsr UpdateEnemyAnimation_AnyY
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy06_Sub2_Next
	;If animation timer not $10, exit early
	lda Enemy_Temp1,x
	cmp #$10
	bne Enemy06_Sub1_Exit
	;Check for free slots
	ldy #$0F
Enemy06_Sub2_Loop:
	;If free slot available, spawn projectile
	lda Enemy_ID,y
	beq Enemy06_Sub2_Shoot
	;Loop for each slot
	dey
	cpy #$08
	bcs Enemy06_Sub2_Loop
	rts
Enemy06_Sub2_Shoot:
	;Set enemy ID $07 (Skeleton fire)
	lda #ENEMY_SKELETONFIRE
	sta Enemy_ID,y
	;Set enemy flags
	lda #$02
	sta Enemy_Flags,y
	;Offset projectile Y position
	lda #$08
	jsr OffsetEnemyYPos
	;Set projectile X velocity
	tax
	beq Enemy06_Sub2_Right
	ldx #$01
Enemy06_Sub2_Right:
	lda SkeletonFireXVelocity,x
	sta Enemy_XVel,y
	lda SkeletonFireXVelocityLo,x
	sta Enemy_XVelLo,y
	;Restore X register
	ldx CurEnemyIndex
	;Set enemy sprite
	lda #$12
	sta Enemy_Sprite+$08,x
	rts
Enemy06_Sub2_Next:
	;Next task ($01: Main)
	dec Enemy_Mode,x
	;Reset animation timer randomly
	jmp Enemy06_Sub1_SetT
SkeletonFireXVelocity:
	.db $01,$FE
SkeletonFireXVelocityLo:
	.db $20,$E0

;$07: Skeleton fire
Enemy07JumpTable:
	.dw Enemy07_Sub0	;$00  Init
	.dw Enemy07_Sub1	;$01  Main
	.dw Enemy07_Sub2	;$02  Hit wall
;$00: Init
Enemy07_Sub0:
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
Enemy07_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;If in turn around area, go to next task ($02: Hit wall)
	jsr CheckEnemyTurnArea
	bcs Enemy07_Sub1_Next
	;Move enemy
	jsr MoveEnemyXY
	;If wall collision, go to next task ($02: Hit wall)
	ldy #$01
	jsr EnemyGetWallCollision_AnyY
	bcs Enemy07_Sub1_Next
	;Check for behind BG area collision type
	ldy #$00
	cmp #$02
	bne Enemy07_Sub1_NoBehindBG
	;Set enemy priority to be behind background
	ldy #$20
Enemy07_Sub1_NoBehindBG:
	sty $00
	;Set enemy props
	lda Enemy_Props+$08,x
	and #$DF
	ora $00
	sta Enemy_Props+$08,x
	;Check for ground collision
	ldy #$02
	jsr EnemyGetGroundCollision_AnyY
	bcc Enemy07_Sub1_NoGround
	;Set enemy grounded
	ldy #$0B
	jmp HandleEnemyGroundCollision
Enemy07_Sub1_NoGround:
	;If enemy Y velocity >= $05, don't accelerate
	lda Enemy_YVel,x
	cmp #$05
	bcs Enemy07_Sub1_Exit
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$80
	sta Enemy_YVelLo,x
	bcc Enemy07_Sub1_Exit
	inc Enemy_YVel,x
	rts
Enemy07_Sub1_Next:
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	;Next task ($02: Hit wall)
	inc Enemy_Mode,x
Enemy07_Sub1_Exit:
	rts
;$02: Hit wall
Enemy07_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy07_Sub1_Exit
Enemy07_Sub2_Clear:
	;Clear enemy
	jmp ClearEnemy

;$08: Beast
Enemy08JumpTable:
	.dw Enemy08_Sub0	;$00  Init
	.dw Enemy08_Sub1	;$01  Main
	.dw Enemy08_Sub2	;$02  Attack
;$00: Init
Enemy08_Sub0:
	;If enemy offscreen vertically, exit early
	lda Enemy_YHi+$08,x
	bne Enemy07_Sub1_Exit
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	beq Enemy08_Sub0_Init
	;Check if enemy is on left side of screen
	ldy Enemy_XHi+$08,x
	bpl Enemy07_Sub1_Exit
Enemy08_Sub0_Init:
	;If enemy not offscreen horizontally, clear enemy
	lda Enemy_XHi+$08,x
	beq Enemy07_Sub2_Clear
	;Set enemy X velocity to target player
	lda #$04
	jmp SetEnemyXVel
;$01: Main
Enemy08_Sub1:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jsr MoveEnemyXY
	;If enemy offscreen, skip this part
	lda Enemy_XHi+$08,x
	ora Enemy_YHi+$08,x
	bne Enemy08_Sub1_NoAttack
	;Check if player is in range
	ldy #$01
Enemy08_Sub1_PlayerLoop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc Enemy08_Sub1_PlayerNext
	;If player invincibility timer not 0, don't check for range
	lda PlayerInvinTimer,y
	bne Enemy08_Sub1_PlayerNext
	;Check if player X distance from enemy < $18
	sec
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	clc
	adc #$18
	cmp #$30
	bcs Enemy08_Sub1_PlayerNext
	;If player Y distance from enemy < $09, go to next task ($02: Attack)
	lda Enemy_Y+$08,x
	sbc Enemy_Y,y
	clc
	adc #$09
	cmp #$10
	bcc Enemy08_Sub1_Next
Enemy08_Sub1_PlayerNext:
	;Loop for each player
	dey
	bpl Enemy08_Sub1_PlayerLoop
Enemy08_Sub1_NoAttack:
	;If wall collision, flip enemy X
	jsr EnemyGetWallCollision
	sta $00
	bcc Enemy08_Sub1_NoFlip
	jsr FlipEnemyX
Enemy08_Sub1_NoFlip:
	;Check for behind BG area collision type
	ldy #$00
	lda $00
	cmp #$02
	bne Enemy08_Sub1_NoBehindBG
	;Set enemy priority to be behind background
	ldy #$20
Enemy08_Sub1_NoBehindBG:
	sty $00
	;Set enemy props
	lda Enemy_Props+$08,x
	and #$DF
	ora $00
	sta Enemy_Props+$08,x
	;Check for non-solid collision types
	jsr EnemyGetGroundCollision
	cmp #$03
	bcc Enemy08_Sub1_NoSlope
	;Check for 45 deg. slope right collision type
	cmp #$04
	beq Enemy08_Sub1_SlopeRight
	;Check for slope top collision type
	cmp #$13
	beq Enemy08_Sub1_SlopeTop
	;Set enemy grounded
	ldy #$00
	jmp HandleEnemyGroundCollision
Enemy08_Sub1_SlopeTop:
	;Move enemy up $01
	dec Enemy_Y+$08,x
	rts
Enemy08_Sub1_SlopeRight:
	;Set enemy grounded
	jmp HandleEnemySlopeCollision
Enemy08_Sub1_NoSlope:
	;If enemy X screen $07, flip enemy X
	lda Enemy_X+$08,x
	adc TempMirror_PPUSCROLL_X
	lda Enemy_XHi+$08,x
	adc CurScreenX
	cmp #$07
	beq Enemy08_Sub1_Flip
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	adc #$40
	sta Enemy_YVelLo,x
	bcc Enemy08_Sub1_Exit
	inc Enemy_YVel,x
Enemy08_Sub1_Exit:
	rts
Enemy08_Sub1_Flip:
	;Flip enemy X
	jmp FlipEnemyX
Enemy08_Sub1_Next:
	;Next task ($02: Attack)
	inc Enemy_Mode,x
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	rts
;$02: Attack
Enemy08_Sub2:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy08_Sub2_Next
	;Update enemy animation
	ldy #$00
	jsr UpdateEnemyAnimation_AnyY
	;If animation timer < $10, set enemy flags
	lda Enemy_Temp1,x
	cmp #$10
	bcs Enemy08_Sub2_NoSetF
	;Set enemy flags
	lda #$05
	sta Enemy_Flags,x
Enemy08_Sub2_NoSetF:
	;Move enemy Y
	jsr MoveEnemyY
	;Process enemy movement
	jmp Enemy08_Sub1_NoFlip
Enemy08_Sub2_Next:
	;Set enemy flags
	lda #$04
	sta Enemy_Flags,x
	;Next task ($01: Main)
	dec Enemy_Mode,x
	rts

;$09: Hunchback
Enemy09JumpTable:
	.dw Enemy09_Sub0	;$00  Init
	.dw Enemy09_Sub1	;$01  Jump init
	.dw Enemy09_Sub2	;$02  Jump
	.dw Enemy09_Sub3	;$03  Land
	.dw Enemy09_Sub4	;$04  Attack
;$00: Init
Enemy09_Sub0:
	;If enemy offscreen horizontally, exit early
	lda Enemy_XHi+$08,x
	bne Enemy09_Sub0_Exit
	;Load CHR bank
	lda #$21
	sta TempCHRBanks+2
	;Next task ($01: Jump init)
	inc Enemy_Mode,x
Enemy09_Sub0_Exit:
	rts
HunchbackVelocityTable:
	.db $00,$40,$FC,$00
	.db $00,$40,$FC,$00
	.db $00,$80,$FB,$00
	.db $01,$00,$FD,$C0
	.db $01,$00,$FB,$00
	.db $01,$80,$FC,$40
	.db $01,$80,$FB,$00
	.db $01,$80,$FB,$C0
	.db $02,$00,$FB,$00
;$01: Jump init
Enemy09_Sub1:
	;Set enemy sprite/props
	lda #$1E
	sta Enemy_Sprite+$08,x
	lda #$00
	sta Enemy_Props+$08,x
	;Check if enemy offscreen horizontally
	lda Enemy_XHi+$08,x
	beq Enemy09_Sub1_CheckPlayer
	eor #$FF
	tay
	bne Enemy09_Sub1_SetVel
Enemy09_Sub1_CheckPlayer:
	;Find closest player
	jsr FindClosestPlayerX
	;Get player X distance from enemy
	lda Enemy_X,y
	ldy #$00
	sbc Enemy_X+$08,x
	bcs Enemy09_Sub1_SetVel
	dey
	eor #$FF
	adc #$01
Enemy09_Sub1_SetVel:
	sty $00
	;Set max distance $80 and mask out bits 0-3
	bpl Enemy09_Sub1_NoXC
	lda #$80
Enemy09_Sub1_NoXC:
	and #$F0
	;Set enemy velocity based on player X distance
	lsr
	lsr
	tay
	lda HunchbackVelocityTable,y
	sta Enemy_XVel,x
	lda HunchbackVelocityTable+1,y
	sta Enemy_XVelLo,x
	lda HunchbackVelocityTable+2,y
	sta Enemy_YVel,x
	lda HunchbackVelocityTable+3,y
	sta Enemy_YVelLo,x
	;If player is to left, flip enemy X
	bit $00
	bpl Enemy09_Sub1_Next
	jsr FlipEnemyX
Enemy09_Sub1_Next:
	;Next task ($02: Jump)
	inc Enemy_Mode,x
;$02: Jump
Enemy09_Sub2:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy09_Sub2_NoYC
	inc Enemy_YVel,x
Enemy09_Sub2_NoYC:
	;Check to turn around
	jsr CheckEnemyTurnArea
	bcs Enemy09_Sub2_NoFlip
	;Flip enemy X
	jsr FlipEnemyX
Enemy09_Sub2_NoFlip:
	;Move enemy
	jsr MoveEnemyXY
	;If wall collision, clear enemy X velocity
	jsr EnemyGetWallCollision
	bcc Enemy09_Sub2_NoWall
	;Clear enemy X velocity
	lda #$00
	sta Enemy_XVel,x
	sta Enemy_XVelLo,x
	;Adjust enemy X position for collision
	ldy #$08
	lda TempMirror_PPUSCROLL_X
	clc
	adc Enemy_X,x
	and #$0F
	sta $00
	tya
	clc
	adc Enemy_X+$08,x
	sec
	sbc $00
	sta Enemy_X+$08,x
Enemy09_Sub2_NoWall:
	;If enemy Y velocity up, exit early
	lda Enemy_YVel,x
	bmi Enemy09_Sub2_Exit
	;If enemy above screen bounds, exit early
	lda Enemy_YHi+$08,x
	bmi Enemy09_Sub2_Exit
	;If enemy below screen bounds, skip this part
	bne Enemy09_Sub2_CheckGround
	;Find closest player
	jsr FindClosestPlayerX
	;If player distance below enemy >= $20, exit early
	lda Enemy_Y,y
	sbc Enemy_Y+$08,x
	bcc Enemy09_Sub2_CheckGround
	cmp #$20
	bcs Enemy09_Sub2_Exit
Enemy09_Sub2_CheckGround:
	;If no ground collision, exit early
	jsr EnemyGetGroundCollision
	bcc Enemy09_Sub2_Exit
	;Set enemy grounded
	ldy #$00
	jsr HandleEnemyGroundCollision
	;Set enemy sprite
	lda #$1D
	sta Enemy_Sprite+$08,x
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	;Next task ($03: Land)
	inc Enemy_Mode,x
Enemy09_Sub2_Exit:
	rts
;$03: Land
Enemy09_Sub3:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy09_Sub3_Exit
	;If enemy offscreen horizontally, go to next task ($01: Jump init)
	lda Enemy_XHi+$08,x
	bne Enemy09_Sub4_NoAttack
	;Find closest player
	jsr FindClosestPlayerX
	;If player Y distance from enemy >= $20, go to next task ($01: Jump init)
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	adc #$20
	cmp #$40
	bcs Enemy09_Sub4_NoAttack
	;Move enemy forward $07
	lda Enemy_Props+$08,x
	cmp #$40
	lda #$F8
	bcs Enemy09_Sub3_Left
	lda #$07
Enemy09_Sub3_Left:
	adc Enemy_X+$08,x
	sta Enemy_X+$08,x
	;Set enemy sprite
	lda #$1F
	sta Enemy_Sprite+$08,x
	;Set animation timer
	lda #$18
	sta Enemy_Temp1,x
	;Set enemy flags
	lda #$08
	sta Enemy_Flags,x
	;Next task ($04: Attack)
	inc Enemy_Mode,x
Enemy09_Sub3_Exit:
	rts
;$04: Attack
Enemy09_Sub4:
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy09_Sub4_Next
	;Update enemy animation
	jmp UpdateEnemyAnimation
Enemy09_Sub4_Next:
	;Move enemy backward $07
	lda Enemy_Props+$08,x
	cmp #$40
	lda #$06
	bcs Enemy09_Sub4_Right
	lda #$F9
Enemy09_Sub4_Right:
	adc Enemy_X+$08,x
	sta Enemy_X+$08,x
Enemy09_Sub4_NoAttack:
	;Set enemy flags
	lda #$01
	sta Enemy_Flags,x
	;Next task ($01: Jump init)
	sta Enemy_Mode,x
	rts

;$0A: Witch spawner
Enemy0AJumpTable:
	.dw Enemy0A_Sub0	;$00  Init
	.dw Enemy0A_Sub1	;$01  Main
;$00: Init
Enemy0A_Sub0:
	;Set spawn timer
	lda #$60
	sta Enemy_Temp1,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
	rts
;$01: Main
Enemy0A_Sub1:
	;If enemy offscreen horizontally, exit early
	lda Enemy_XHi+$08,x
	bne Enemy0A_Sub1_Exit
	;If Witch already active, exit early
	lda Enemy_Temp2,x
	bne Enemy0A_Sub1_Exit
	;Decrement spawn timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy0A_Sub1_GetRange
Enemy0A_Sub1_Exit:
	rts
Enemy0A_Sub1_GetRange:
	;Set player X distance range randomly
	lda PRNGValue
	cmp #$C0
	bcc Enemy0A_Sub1_SetRange
	eor #$80
Enemy0A_Sub1_SetRange:
	adc #$20
	sta $00
	;Check if player 2 is active
	ldy #$00
	lda PlayerMode+1
	cmp #$03
	bcc Enemy0A_Sub1_NoP2
	iny
	iny
Enemy0A_Sub1_NoP2:
	;Check if player 1 is active
	lda PlayerMode
	cmp #$03
	bcc Enemy0A_Sub1_NoP1
	iny
Enemy0A_Sub1_NoP1:
	;Check if both players are active
	cpy #$03
	bne Enemy0A_Sub1_No2P
	;If X distance between players >= $20 away from range value, don't spawn Witch
	ldy #$01
	lda Enemy_X
	adc $00
	sbc Enemy_X+1
	adc #$20
	cmp #$40
	bcc Enemy0A_Sub1_NoSpawn
	;Get random target player index
	lda PRNGValue
	lsr
	bcc Enemy0A_Sub1_CheckSpawn
	dey
	bcs Enemy0A_Sub1_CheckSpawn
Enemy0A_Sub1_No2P:
	;If no players are active, don't spawn Witch
	tya
	beq Enemy0A_Sub1_NoSpawn
	;Get active player index
	lsr
	tay
Enemy0A_Sub1_CheckSpawn:
	;Check for free slots
	ldx #$11
Enemy0A_Sub1_Loop:
	;If free slot available, spawn Witch
	lda Enemy_ID,x
	beq Enemy0A_Sub1_Spawn
	;Loop for each slot
	dex
	cpx #$0A
	bcs Enemy0A_Sub1_Loop
	;Restore X register
	ldx CurEnemyIndex
Enemy0A_Sub1_NoSpawn:
	;Increment spawn timer
	lda #$08
	adc Enemy_Temp1,x
	sta Enemy_Temp1,x
	rts
Enemy0A_Sub1_Spawn:
	;Set enemy position/props
	lda Enemy_X,y
	adc $00
	sta Enemy_X+$08,x
	sbc Enemy_X,y
	lda #$00
	ror
	lsr
	sta Enemy_Props+$08,x
	lda Enemy_Y,y
	sta Enemy_Y+$08,x
	;Set enemy ID $0B (Witch)
	lda #ENEMY_WITCH
	sta Enemy_ID,x
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_ALLOWOFFSCREEN|$03)
	sta Enemy_Flags,x
	;Set parent enemy slot index
	lda CurEnemyIndex
	sta Enemy_Temp3,x
	;Set target player index
	tya
	sta Enemy_Temp4,x
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	;Set enemy target Y position
	lda #$C0
	jsr InitEnemyTargetYPos_AnyA
	;Load CHR bank
	lda #$21
	sta TempCHRBanks+2
	;Restore X register
	txa
	ldx CurEnemyIndex
	;Set Witch enemy slot index
	sta Enemy_Temp2,x
	;Reset spawn timer
	lda #$60
	sta Enemy_Temp1,x
	;Play sound
	lda #SE_WITCHAPPEAR
	jmp LoadSound

;$0B: Witch
Enemy0BJumpTable:
	.dw Enemy0B_Sub0	;$00  Flash in
	.dw Enemy0B_Sub1	;$01  Shoot
	.dw Enemy0B_Sub2	;$02  Flash out
;$00: Flash in
Enemy0B_Sub0:
	;Adjust enemy Y velocity to target Y position
	jsr UpdateEnemyTargetYPos
	;Move enemy Y
	jsr MoveEnemyY
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy0B_Sub0_Exit
	;Next task ($01: Shoot)
	inc Enemy_Mode,x
	;Set animation timer
	lda #$30
	sta Enemy_Temp1,x
	;Set enemy flags
	lda #(EF_ALLOWOFFSCREEN|$03)
	sta Enemy_Flags,x
Enemy0B_Sub0_Exit:
	rts
;$01: Shoot
Enemy0B_Sub1:
	;Adjust enemy Y velocity to target Y position
	jsr UpdateEnemyTargetYPos
	;Move enemy Y
	jsr MoveEnemyY
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy0B_Sub1_Next
	;If animation timer not $20, exit early
	lda Enemy_Temp1,x
	cmp #$20
	bne Enemy0B_Sub0_Exit
	;Set enemy sprite
	lda #$18
	sta Enemy_Sprite+$08,x
	;Spawn projectile in free enemy slot
	ldy Enemy_Temp4,x
	ldx #$03
	lda #$FE
	jsr SpawnFreeEnemySlot
	;If no free slot available, exit early
	bcc Enemy0B_Sub1_Exit
	;Set enemy ID $03 (Witch fire)
	ldy $00
	lda #ENEMY_WITCHFIRE
	sta Enemy_ID,y
	;Set enemy flags
	lda #$02
	sta Enemy_Flags,y
Enemy0B_Sub1_Exit:
	rts
Enemy0B_Sub1_Next:
	;Next task ($02: Flash out)
	inc Enemy_Mode,x
	;Set animation timer
	lda #$20
	sta Enemy_Temp1,x
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_ALLOWOFFSCREEN|$03)
	sta Enemy_Flags,x
	rts
;$02: Flash out
Enemy0B_Sub2:
	;Adjust enemy Y velocity to target Y position
	jsr UpdateEnemyTargetYPos
	;Move enemy Y
	jsr MoveEnemyY
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Decrement animation timer, check if 0
	dec Enemy_Temp1,x
	bne Enemy0B_Sub0_Exit
	;Clear parent enemy slot index
	ldy Enemy_Temp3,x
	lda #$00
	sta Enemy_Temp2,y
	;Clear enemy
	jmp ClearEnemy

;$03: Witch fire
Enemy03JumpTable:
	.dw Enemy03_Sub0	;$00  Init
	.dw Enemy03_Sub1	;$01  Main
;$00: Init
Enemy03_Sub0:
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
Enemy03_Sub1:
	;If in turn around area, clear enemy
	jsr CheckEnemyTurnArea
	bcs Enemy03_Sub1_NoClear
	;Clear enemy
	jmp ClearEnemy
Enemy03_Sub1_NoClear:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Move enemy
	jmp MoveEnemyXY

CheckEnemyTurnArea:
	;If enemy Y screen >= $07, set carry flag
	lda Enemy_Y+$08,x
	adc TempMirror_PPUSCROLL_Y
	lda Enemy_YHi+$08,x
	adc CurScreenY
	cmp #$07
	bcs CheckEnemyTurnArea_Exit
	;Check if enemy X screen >= $04
	lda TempMirror_PPUSCROLL_X
	adc Enemy_X+$08,x
	tay
	lda CurScreenX
	adc Enemy_XHi+$08,x
	cmp #$04
	bcs CheckEnemyTurnArea_CheckXLo
	;If enemy X screen < $03, clear carry flag
	cmp #$03
	bcc CheckEnemyTurnArea_Exit
	;Check for level 1 big slope area
	lda CurArea
	bne CheckEnemyTurnArea_CheckXVel
CheckEnemyTurnArea_NoTurn:
	;Clear carry flag
	clc
	rts
CheckEnemyTurnArea_CheckXLo:
	;Check if enemy X screen $04
	bne CheckEnemyTurnArea_CheckXHi
	;If enemy X position in screen < $F0, clear carry flag
	cpy #$F0
	bcc CheckEnemyTurnArea_Exit
CheckEnemyTurnArea_CheckXVel:
	;If enemy X velocity left, clear carry flag
	lda Enemy_XVel,x
	bmi CheckEnemyTurnArea_NoTurn
CheckEnemyTurnArea_Exit:
	rts
CheckEnemyTurnArea_CheckXHi:
	;If enemy X screen < $07, set carry flag
	cmp #$07
	bcc CheckEnemyTurnArea_Turn
	;If enemy X screen not $07, clear carry flag
	bne CheckEnemyTurnArea_NoTurn
	;If enemy X position in screen >= $80, clear carry flag
	tya
	bmi CheckEnemyTurnArea_NoTurn
	;If enemy X velocity right, clear carry flag
	lda Enemy_XVel,x
	bpl CheckEnemyTurnArea_NoTurn
CheckEnemyTurnArea_Turn:
	;Set carry flag
	sec
	rts

;UNUSED SPACE
	;$7F bytes of free space available
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

	.org $C000
