	.base $C000
	.org $C000

;;;;;;;;;;
;DMC DATA;
;;;;;;;;;;
DMCTomTomData:
	.db $00,$00,$FE,$FF,$FF,$0F,$84,$C1,$1E,$00,$00,$00,$FF,$EF,$D3,$FF
	.db $FF,$3F,$A0,$6F,$BF,$B0,$04,$04,$00,$00,$00,$F8,$FF,$FF,$FF,$FF
	.db $0F,$00,$00,$95,$5B,$84,$04,$00,$54,$EF,$FF,$FF,$FF,$FB,$BB,$00
	.db $00,$00,$10,$62,$BF,$04,$56,$F4,$FF,$7F,$FF,$BA,$73,$09,$02,$00
	.db $00,$42,$B1,$5D,$BB,$55,$FB,$FE,$FF,$DE,$5A,$02,$08,$10,$90,$08
	.db $52,$B5,$BD,$BB,$DB,$97,$B6,$EE,$77,$B7,$08,$00,$80,$00,$44,$69
	.db $FB,$EF,$FB,$75,$AF,$6A,$4A,$AD,$96,$55,$00,$00,$42,$52,$A9,$6D
	.db $7F,$FF,$DF,$56,$B7,$54,$92,$08,$2A,$A9,$08,$10,$48,$ED,$F7,$EE
	.db $77,$FB,$B6,$AB,$B2,$20,$42,$40,$2A,$A5,$54,$89,$90,$FE,$7F,$7F
	.db $DF,$5A,$55,$A9,$10,$24,$89,$20,$A5,$2A,$6A,$B7,$AA,$E4,$FF,$7F
	.db $77,$55,$09,$21,$01,$41,$4A,$15,$69,$B5,$6E,$AB,$76,$BB,$B6,$EF
	.db $5D,$49,$22,$40,$24,$11,$42,$56,$6B,$BB,$77,$57,$DB,$D6,$AA,$DA
	.db $5A,$AB,$00,$04,$44,$AA,$94,$D4,$76,$77,$DB,$7B,$B7,$A6,$4A,$A5
	.db $2A,$55,$4A,$80,$08,$92,$6A,$B7,$DB,$BB,$ED,$DA,$B6,$2D,$A5,$44
	.db $4A,$92,$94,$A4,$88,$48,$D5,$F6,$FE,$AE,$6D,$B7,$55,$55,$52,$89
	.db $90,$44,$54,$55,$49,$2A,$55,$DB,$DF,$F7,$6E,$55,$A5,$52,$49,$4A
	.db $22,$48,$92,$6A,$6A,$AD,$56,$6D,$DB,$7D,$EF,$D6,$14,$21,$92,$24
	.db $89,$A4,$A4,$5A,$B5,$6A,$DB,$B6,$D6,$B6,$DB,$B6,$95,$08,$11,$44
	.db $52,$2A,$A5,$B2,$D6,$B6,$DD,$6D,$AB,$56,$B5,$DA,$2A,$95,$24,$10
	.db $42,$52,$55,$DB,$5A,$6B,$BB,$6D,$DB,$B6,$2A,$A9,$94,$94,$54,$25
	.db $22,$92,$52,$D5,$76,$B7,$6D,$B7,$D6,$5A,$AB,$92,$94,$94,$28,$29
	.db $49,$A9,$54,$5A,$AD,$ED,$DE,$B5,$D5,$5A,$55,$AA,$4A,$24,$49,$52
	.db $29,$55,$A5,$AA,$5A,$6B,$BB,$DB,$D6,$AA,$AA,$4A,$4A,$52,$2A,$25
	.db $55,$2A,$AD,$AA,$AA,$B5,$DA,$D6,$DA,$5A,$55,$55,$52,$4A,$49,$A9
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DMCTomTomDataEnd:
DMCSnareDrumData:
	.db $CE,$C7,$52,$30,$00,$60,$D7,$FB,$F3,$FD,$FF,$7F,$00,$02,$04,$11
	.db $21,$00,$00,$FF,$FF,$DF,$77,$6F,$FF,$FF,$17,$00,$00,$20,$44,$00
	.db $00,$F0,$FF,$F7,$EF,$FD,$FF,$FF,$00,$80,$80,$10,$02,$00,$E0,$FF
	.db $BF,$EF,$FD,$FB,$FF,$23,$00,$40,$20,$02,$00,$08,$98,$FF,$FF,$7F
	.db $3F,$FE,$FF,$5F,$00,$00,$81,$00,$10,$82,$C0,$FE,$FF,$FB,$FD,$FF
	.db $CF,$1F,$06,$00,$00,$04,$21,$00,$E6,$FE,$7F,$DF,$DF,$FB,$CF,$31
	.db $A0,$10,$01,$10,$43,$86,$AC,$73,$E7,$CF,$FB,$3F,$9E,$73,$0C,$11
	.db $10,$31,$18,$63,$0C,$17,$9F,$F3,$EF,$F9,$EE,$1D,$07,$26,$18,$48
	.db $8C,$C4,$30,$C6,$9D,$7F,$FC,$3F,$3D,$9C,$C5,$30,$86,$0C,$11,$26
	.db $F4,$C4,$E3,$E7,$F9,$E7,$39,$67,$C7,$30,$4C,$08,$8C,$23,$1E,$46
	.db $E6,$EC,$79,$E7,$9D,$BB,$39,$06,$27,$43,$60,$90,$31,$8E,$CD,$78
	.db $7E,$7C,$3F,$F7,$38,$0B,$83,$31,$08,$03,$23,$E3,$F4,$3C,$BE,$CF
	.db $DB,$71,$C5,$89,$86,$C1,$18,$8B,$89,$63,$33,$67,$4E,$E7,$3C,$3E
	.db $3C,$E3,$C6,$F0,$70,$98,$90,$71,$58,$38,$CF,$9B,$FB,$B8,$8E,$93
	.db $A9,$C8,$44,$94,$49,$E5,$38,$7D,$3C,$9E,$3B,$75,$38,$C6,$71,$64
	.db $C4,$1C,$C7,$8D,$E3,$58,$D6,$E2,$E1,$74,$3C,$63,$8E,$E3,$CC,$32
	.db $99,$D4,$18,$2D,$CE,$9C,$6E,$C6,$75,$9C,$13,$E7,$18,$C6,$C8,$19
	.db $D3,$B2,$71,$AD,$CE,$B1,$C6,$D1,$D4,$30,$67,$CC,$B8,$71,$9C,$58
	.db $39,$8E,$B3,$E3,$58,$8E,$8D,$39,$39,$E3,$34,$86,$63,$71,$C6,$A6
	.db $95,$6B,$CD,$8C,$C7,$E1,$31,$D3,$14,$53,$C6,$69,$6A,$CC,$65,$C7
	.db $63,$C7,$D4,$C6,$31,$4E,$15,$C7,$38,$66,$6A,$66,$4E,$4E,$67,$65
	.db $CE,$34,$E3,$E8,$70,$C6,$B1,$38,$E6,$E8,$64,$4E,$97,$8E,$D3,$CC
	.db $34,$56,$93,$A9,$34,$96,$66,$4C,$E3,$74,$AE,$D9,$E2,$71,$CC,$38
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DMCSnareDrumDataEnd:
DMCBassDrumData:
	.db $F4,$A7,$71,$D8,$CC,$C1,$83,$71,$04,$0C,$C0,$11,$FE,$D8,$75,$EE
	.db $FC,$FF,$CF,$FF,$DF,$3F,$5B,$56,$89,$01,$07,$00,$00,$10,$20,$A0
	.db $48,$8C,$2A,$2D,$8D,$D3,$AA,$B5,$B3,$B6,$76,$B5,$73,$5D,$77,$B7
	.db $5F,$DF,$5E,$5B,$9D,$AD,$2A,$95,$82,$14,$21,$11,$22,$12,$89,$24
	.db $A9,$54,$2A,$55,$55,$55,$CD,$AA,$D5,$6A,$B5,$5A,$AD,$B5,$6A,$AD
	.db $56,$AB,$56,$B5,$B4,$AA,$AA,$AA,$AA,$AA,$AA,$4A,$55,$55,$55,$AB
	.db $AA,$AA,$5A,$55,$55,$55,$55,$95,$AA,$4A,$55,$A9,$4A,$55,$AA,$4A
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DMCBassDrumDataEnd:
DMCPlayerHurtData:
	.db $66,$66,$66,$9C,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$E7
	.db $E6,$44,$80,$0C,$CC,$F3,$76,$3F,$E7,$99,$0C,$07,$32,$26,$E7,$FF
	.db $8C,$00,$C0,$00,$CF,$7F,$FF,$E7,$79,$44,$0C,$82,$4C,$F6,$FF,$07
	.db $00,$00,$80,$CF,$FF,$FF,$EF,$33,$0C,$30,$80,$FD,$7F,$06,$00,$00
	.db $C0,$FF,$FF,$FF,$F3,$13,$02,$18,$F0,$FF,$0B,$00,$00,$00,$FC,$FF
	.db $FF,$FF,$3F,$20,$00,$F2,$3F,$0F,$00,$00,$00,$FC,$FF,$FF,$FF,$3F
	.db $00,$80,$CF,$FC,$03,$00,$00,$00,$FF,$FF,$FF,$FF,$0F,$00,$8E,$F8
	.db $0F,$00,$00,$00,$F0,$FF,$FF,$FF,$FF,$80,$41,$8E,$77,$00,$00,$00
	.db $E0,$FF,$FF,$FF,$FF,$01,$03,$33,$E6,$01,$00,$00,$E0,$FF,$FF,$FF
	.db $FF,$03,$80,$1D,$F8,$00,$00,$00,$F8,$FF,$FF,$FF,$FF,$00,$60,$06
	.db $7E,$00,$00,$00,$FF,$FF,$FF,$FF,$0F,$00,$30,$E0,$07,$00,$06,$F3
	.db $FF,$FF,$FF,$3B,$00,$00,$80,$7F,$00,$38,$8E,$FF,$FF,$FF,$87,$03
	.db $00,$80,$FC,$00,$E0,$F3,$FC,$FF,$FF,$0F,$0E,$04,$00,$C0,$1F,$00
	.db $FE,$E1,$FF,$DF,$7F,$F8,$70,$00,$00,$38,$00,$F8,$1F,$FF,$FF,$FF
	.db $80,$C7,$01,$60,$80,$0F,$00,$FF,$E1,$FF,$F3,$1F,$38,$3E,$80,$03
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DMCPlayerHurtDataEnd:
DMCBossDeathData:
	.db $F6,$00,$FF,$00,$FF,$00,$FE,$E0,$0F,$F0,$F8,$0F,$30,$E0,$1F,$FE
	.db $01,$80,$FD,$FF,$01,$C0,$FF,$C0,$1F,$1C,$C0,$9F,$7F,$00,$07,$FF
	.db $80,$3F,$7C,$00,$FE,$F3,$00,$F8,$1F,$C0,$1F,$1E,$E0,$0F,$FF,$80
	.db $03,$FE,$80,$3F,$78,$C0,$1F,$F8,$03,$3E,$F0,$0F,$FC,$C1,$07,$FC
	.db $81,$3F,$E0,$81,$7F,$80,$3F,$3C,$C0,$3F,$F8,$03,$1E,$F8,$07,$F8
	.db $E3,$01,$FE,$C1,$1F,$F0,$80,$3F,$E0,$1F,$1E,$E0,$0F,$FC,$81,$07
	.db $FC,$03,$FE,$F0,$00,$FF,$E0,$0F,$38,$E0,$3F,$F0,$87,$07,$F8,$07
	.db $7F,$C0,$01,$FF,$80,$3F,$3C,$C0,$3F,$F8,$03,$0E,$F8,$0F,$FC,$E1
	.db $01,$FE,$81,$3F,$70,$80,$7F,$E0,$1F,$0E,$F0,$0F,$FC,$81,$07,$FC
	.db $03,$FE,$F0,$00,$FF,$C0,$1F,$3C,$E0,$3F,$E0,$87,$03,$F8,$07,$7F
	.db $E0,$01,$FF,$81,$3F,$0C,$E0,$3F,$F8,$03,$07,$F8,$0F,$FC,$31,$00
	.db $FF,$C1,$1F,$38,$E0,$3F,$F0,$87,$01,$FC,$07,$7F,$F0,$00,$FF,$81
	.db $3F,$0C,$C0,$3F,$F8,$07,$07,$F8,$0F,$FC,$61,$00,$FF,$C1,$1F,$1C
	.db $C0,$7F,$E0,$8F,$01,$F8,$0F,$FE,$E0,$00,$FF,$83,$3F,$18,$C0,$7F
	.db $F0,$07,$07,$F8,$0F,$FC,$61,$00,$FF,$C1,$1F,$1C,$C0,$7F,$F0,$07
	.db $03,$F8,$0F,$7F,$F0,$00,$FF,$C0,$1F,$0C,$E0,$3F,$F8,$C3,$03,$FC
	.db $03,$7F,$30,$80,$7F,$F0,$07,$0F,$F0,$1F,$FC,$C1,$00,$FE,$C1,$1F
	.db $1E,$C0,$7F,$F0,$07,$03,$F8,$0F,$FE,$F0,$00,$FF,$C0,$1F,$1C,$E0
	.db $3F,$F0,$83,$07,$F8,$07,$FE,$70,$00,$FF,$C1,$1F,$1C,$E0,$3F,$F0
	.db $87,$03,$F8,$07,$FE,$70,$00,$FF,$81,$3F,$1C,$C0,$7F,$F0,$07,$07
	.db $F8,$0F,$FC,$E1,$00,$FE,$81,$3F,$3C,$C0,$7F,$E0,$0F,$0E,$F0,$1F
	.db $F8,$C1,$01,$FE,$03,$7F,$38,$80,$FF,$C0,$0F,$0F,$E0,$1F,$F8,$C3
	.db $03,$FC,$03,$FE,$70,$80,$FF,$C0,$1F,$1C,$E0,$3F,$F0,$87,$03,$F8
	.db $0F,$FC,$E1,$00,$FE,$81,$3F,$3C,$C0,$7F,$E0,$0F,$07,$F0,$0F,$F8
	.db $C3,$01,$FC,$07,$FE,$70,$00,$FF,$81,$3F,$1C,$E0,$3F,$E0,$0F,$07
	.db $F8,$0F,$F8,$C3,$01,$FE,$03,$FE,$70,$80,$FF,$80,$3F,$1C,$E0,$3F
	.db $E0,$0F,$07,$F8,$0F,$F8,$C3,$01,$FE,$07,$FE,$70,$00,$FF,$81,$3F
	.db $1C,$C0,$7F,$C0,$0F,$0F,$F0,$0F,$F0,$C3,$03,$FC,$07,$FC,$E1,$00
	.db $FF,$01,$7F,$78,$C0,$7F,$80,$1F,$1E,$E0,$3F,$E0,$0F,$07,$F8,$0F
	.db $F8,$C3,$01,$FE,$03,$FC,$F1,$00,$FF,$01,$7F,$38,$C0,$7F,$80,$1F
	.db $1E,$E0,$3F,$E0,$0F,$07,$F8,$1F,$F0,$87,$03,$FC,$07,$F8,$E1,$01
	.db $FE,$03,$FE,$70,$80,$FF,$01,$7F,$38,$C0,$7F,$80,$3F,$1E,$E0,$3F
	.db $C0,$0F,$0F,$F0,$1F,$E0,$87,$07,$F8,$0F,$F0,$C7,$01,$FC,$07,$FC
	.db $F1,$00,$FE,$03,$FE,$70,$80,$FF,$00,$7F,$38,$C0,$7F,$80,$3F,$0E
	.db $E0,$7F,$C0,$1F,$07,$F0,$1F,$E0,$8F,$07,$F8,$0F,$F0,$87,$03,$FC
	.db $07,$F0,$E7,$01,$FC,$07,$F8,$E3,$00,$FE,$03,$FC,$71,$00,$FF,$03
	.db $FE,$38,$80,$FF,$01,$7F,$38,$C0,$7F,$80,$3F,$1C,$E0,$7F,$C0,$3F
	.db $0C,$E0,$3F,$C0,$1F,$07,$F0,$3F,$E0,$8F,$03,$F8,$0F,$F0,$C7,$01
	.db $FC,$0F,$F8,$C3,$01,$FE,$03,$FC,$63,$00,$FF,$03,$FC,$71,$00,$FF
	.db $01,$FE,$31,$80,$FF,$01,$FF,$30,$C0,$FF,$00,$FF,$10,$C0,$FF,$81
	.db $7F,$08,$E0,$7F,$C0,$3F,$06,$F0,$3F,$C0,$3F,$0C,$F0,$1F,$E0,$1F
	.db $03,$F8,$1F,$F0,$0F,$03,$F8,$1F,$F0,$0F,$02,$FC,$1F,$F8,$07,$01
	.db $FE,$0F,$F8,$07,$02,$FE,$07,$FC,$43,$00,$FF,$07,$FC,$C3,$00,$FF
	.db $03,$FE,$81,$80,$FF,$01,$FF,$30,$80,$FF,$01,$FF,$30,$C0,$FF,$80
	.db $7F,$30,$C0,$7F,$80,$7F,$0C,$E0,$7F,$80,$7F,$38,$E0,$3F,$C0,$3F
	.db $30,$F0,$3F,$C0,$3F,$18,$F0,$1F,$E0,$1F,$06,$F8,$1F,$E0,$1F,$06
	.db $F8,$1F,$F0,$0F,$0E,$F8,$0F,$F0,$0F,$0C,$FC,$0F,$F0,$0F,$06,$FC
	.db $07,$F8,$87,$03,$FC,$07,$F8,$87,$03,$FE,$03,$FC,$83,$03,$FE,$03
	.db $FC,$83,$01,$FE,$03,$FE,$83,$03,$FF,$01,$FE,$03,$03,$FF,$01,$FE
	.db $01,$03,$FF,$01,$FE,$C1,$01,$FF,$01,$FE,$C1,$81,$FF,$00,$FF,$E0
	.db $80,$FF,$00,$FF,$C0,$81,$FF,$00,$FF,$60,$80,$FF,$80,$FF,$E0,$80
	.db $7F,$80,$FF,$E0,$80,$7F,$80,$FF,$60,$C0,$7F,$80,$7F,$70,$C0,$7F
	.db $80,$7F,$70,$C0,$7F,$80,$7F,$70,$C0,$7F,$80,$7F,$70,$C0,$7F,$C0
	.db $7F,$60,$E0,$3F,$C0,$3F,$70,$E0,$3F,$C0,$3F,$70,$E0,$3F,$C0,$3F
	.db $70,$E0,$3F,$C0,$3F,$70,$E0,$3F,$C0,$7F,$40,$E0,$3F,$C0,$7F,$70
	.db $E0,$3F,$C0,$3F,$70,$E0,$3F,$C0,$3F,$70,$E0,$3F,$C0,$3F,$70,$E0
	.db $3F,$C0,$3F,$70,$E0,$3F,$E0,$3F,$70,$E0,$1F,$E0,$1F,$38,$E0,$1F
	.db $E0,$3F,$30,$F0,$1F,$E0,$1F,$78,$F0,$1F,$E0,$1F,$38,$F0,$1F,$E0
	.db $1F,$38,$F0,$1F,$E0,$1F,$38,$F0,$0F,$E0,$3F,$60,$F0,$1F,$E0,$3F
	.db $70,$F0,$1F,$E0,$1F,$70,$F0,$1F,$E0,$1F,$70,$F0,$1F,$E0,$3F,$70
	.db $E0,$1F,$E0,$3F,$70,$E0,$1F,$C0,$3F,$F0,$E0,$1F,$C0,$3F,$70,$E0
	.db $3F,$C0,$3F,$F0,$E0,$1F,$C0,$3F,$E0,$E0,$3F,$C0,$3F,$F0,$C0,$3F
	.db $C0,$7F,$E0,$C0,$3F,$80,$7F,$E0,$C1,$3F,$80,$7F,$E0,$C1,$7F,$80
	.db $7F,$C0,$81,$7F,$80,$FF,$C0,$83,$7F,$00,$FF,$C0,$83,$7F,$00,$FF
	.db $C0,$03,$FF,$00,$FF,$81,$03,$FF,$01,$FE,$81,$07,$FF,$01,$FE,$01
	.db $07,$FE,$01,$FE,$01,$07,$FE,$01,$FE,$03,$0F,$FE,$03,$FC,$03,$0E
	.db $FC,$03,$FC,$07,$1E,$FC,$03,$F8,$07,$1C,$FC,$07,$F8,$0F,$1C,$F8
	.db $07,$F0,$0F,$3C,$F8,$0F,$F0,$0F,$38,$F8,$0F,$F0,$0F,$78,$F0,$0F
	.db $E0,$1F,$78,$F0,$1F,$E0,$1F,$70,$E0,$1F,$E0,$1F,$F0,$E0,$1F,$E0
	.db $3F,$F0,$E0,$3F,$C0,$1F,$F0,$C0,$3F,$C0,$3F,$E0,$C0,$3F,$C0,$3F
	.db $F0,$C1,$3F,$C0,$3F,$E0,$C1,$7F,$80,$3F,$E0,$C1,$7F,$80,$7F,$C0
	.db $C1,$7F,$80,$7F,$C0,$83,$7F,$80,$7F,$C0,$83,$7F,$00,$FF,$80,$83
	.db $FF,$00,$FF,$80,$07,$FF,$00,$FF,$80,$07,$FF,$01,$FE,$01,$07,$FF
	.db $01,$FE,$01,$0F,$FE,$01,$FE,$01,$0F,$FE,$03,$FC,$01,$1E,$FC,$03
	.db $FC,$03,$1E,$FC,$03,$FC,$03,$1E,$FC,$07,$F8,$07,$3C,$F8,$07,$F8
	.db $07,$3C,$F8,$07,$F8,$07,$3C,$F8,$0F,$F0,$0F,$78,$F0,$0F,$F0,$0F
	.db $78,$E0,$1F,$E0,$0F,$F8,$E0,$1F,$E0,$1F,$F0,$E0,$3F,$E0,$1F,$F0
	.db $C1,$3F,$C0,$1F,$E0,$C1,$3F,$C0,$3F,$E0,$83,$7F,$80,$3F,$C0,$83
	.db $7F,$80,$7F,$C0,$07,$FF,$00,$FF,$80,$07,$FF,$00,$FF,$80,$0F,$FE
	.db $01,$FE,$00,$1F,$FC,$03,$FE,$01,$1E,$FC,$03,$FC,$03,$3E,$F8,$07
	.db $F8,$03,$7C,$F8,$07,$F8,$07,$7C,$F0,$0F,$F0,$07,$78,$F0,$0F,$F0
	.db $0F,$F8,$E0,$1F,$E0,$0F,$F0,$E1,$1F,$E0,$1F,$F0,$C1,$1F,$E0,$1F
	.db $E0,$C3,$3F,$C0,$1F,$E0,$C3,$3F,$C0,$3F,$C0,$C3,$3F,$C0,$3F,$C0
	.db $C3,$3F,$C0,$3F,$80,$E7,$3F,$80,$3F,$80,$E7,$3F,$80,$7F,$00,$E7
	.db $3F,$80,$7F,$00,$FE,$3F,$00,$7F,$00,$FE,$3F,$00,$FF,$00,$F8,$7F
	.db $00,$FF,$00,$F0,$7F,$00,$FF,$00,$F0,$FF,$00,$FE,$01,$F0,$FF,$00
	.db $FE,$01,$F0,$FF,$00,$FC,$03,$E0,$FF,$01,$FC,$07,$C0,$FF,$03,$F8
	.db $07,$80,$FF,$03,$F8,$0F,$80,$FF,$07,$F0,$0F,$00,$FF,$07,$F0,$1F
	.db $00,$FF,$0F,$F0,$1F,$00,$FE,$0F,$E0,$3F,$00,$FE,$1F,$E0,$3F,$00
	.db $FC,$1F,$C0,$7F,$00,$F8,$3F,$C0,$7F,$00,$F8,$3F,$80,$FF,$00,$F0
	.db $7F,$80,$FF,$00,$F0,$7F,$80,$FF,$00,$F0,$7F,$00,$FF,$01,$E0,$FF
	.db $00,$FF,$03,$C0,$FF,$01,$FE,$03,$C0,$FF,$01,$FC,$07,$80,$FF,$03
	.db $FC,$0F,$00,$FF,$07,$F8,$0F,$00,$FF,$07,$F8,$1F,$00,$FE,$0F,$F0
	.db $1F,$00,$FC,$1F,$E0,$3F,$00,$FC,$1F,$E0,$7F,$00,$F8,$3F,$C0,$7F
	.db $00,$F0,$7F,$80,$FF,$00,$F0,$7F,$80,$FF,$01,$E0,$FF,$00,$FF,$01
	.db $C0,$FF,$01,$FE,$03,$C0,$FF,$01,$FE,$07,$80,$FF,$03,$FC,$07,$80
	.db $FF,$03,$FC,$07,$00,$FF,$07,$F8,$0F,$00,$FF,$07,$F8,$0F,$00,$FE
	.db $07,$F8,$1F,$00,$FE,$0F,$F0,$1F,$00,$FE,$0F,$F0,$3F,$00,$FC,$1F
	.db $E0,$3F,$00,$FC,$1F,$E0,$7F,$00,$F8,$3F,$C0,$7F,$00,$F0,$3F,$C0
	.db $FF,$00,$F0,$7F,$80,$FF,$01,$E0,$FF,$00,$FF,$01,$C0,$FF,$01,$FE
	.db $03,$C0,$FF,$01,$FE,$07,$80,$FF,$03,$FC,$07,$00,$FF,$07,$F8,$0F
	.db $00,$FE,$07,$F8,$1F,$00,$FE,$0F,$F0,$3F,$00,$FC,$1F,$E0,$3F,$00
	.db $F8,$3F,$E0,$7F,$00,$F0,$3F,$C0,$FF,$00,$F0,$7F,$80,$FF,$00,$E0
	.db $FF,$80,$FF,$01,$C0,$FF,$00,$FF,$03,$80,$FF,$01,$FE,$07,$80,$FF
	.db $03,$FC,$0F,$00,$FF,$07,$F8,$1F,$00,$FE,$0F,$F0,$1F,$00,$FC,$1F
	.db $F0,$3F,$00,$F8,$1F,$E0,$7F,$00,$F0,$3F,$C0,$FF,$00,$F0,$7F,$80
	.db $FF,$01,$E0,$FF,$00,$FF,$01,$C0,$FF,$01,$FE,$07,$80,$FF,$03,$FC
	.db $07,$00,$FF,$07,$FC,$0F,$00,$FE,$07,$F8,$1F,$00,$FC,$0F,$F0,$3F
	.db $00,$F8,$3F,$E0,$7F,$00,$F0,$3F,$C0,$FF,$00,$E0,$FF,$80,$FF,$01
	.db $C0,$FF,$01,$FF,$03,$00,$FF,$03,$FE,$07,$00,$FE,$07,$F8,$1F,$00
	.db $FC,$1F,$F0,$3F,$00,$F8,$3F,$E0,$7F,$00,$F0,$7F,$80,$FF,$01,$C0
	.db $FF,$00,$FF,$07,$00,$FF,$03,$FE,$07,$00,$FE,$07,$F8,$3F,$00,$FC
	.db $1F,$F0,$3F,$00,$F0,$3F,$C0,$FF,$00,$E0,$FF,$80,$FF,$01,$80,$FF
	.db $01,$FE,$0F,$00,$FF,$07,$FC,$0F,$00,$FC,$0F,$F0,$7F,$00,$F0,$3F
	.db $C0,$FF,$01,$E0,$FF,$80,$FF,$01,$80,$FF,$01,$FE,$0F,$00,$FE,$07
	.db $F8,$3F,$00,$F8,$1F,$E0,$FF,$00,$E0,$7F,$80,$FF,$03,$80,$FF,$01
	.db $FE,$0F,$00,$FE,$07,$FC,$1F,$00,$F8,$1F,$F0,$7F,$00,$F0,$3F,$C0
	.db $FF,$01,$C0,$FF,$00,$FF,$07,$00,$FF,$03,$FC,$1F,$00,$FC,$0F,$F0
	.db $7F,$00,$F0,$3F,$C0,$FF,$01,$C0,$FF,$00,$FF,$07,$00,$FF,$03,$FC
	.db $1F,$00,$FC,$0F,$F0,$3F,$00,$F0,$3F,$E0,$FF,$01,$C0,$FF,$00,$FF
	.db $07,$00,$FF,$03,$FE,$0F,$00,$FC,$07,$F8,$7F,$00,$F0,$1F,$E0,$FF
	.db $01,$C0,$7F,$80,$FF,$07,$00,$FF,$03,$FE,$0F,$00,$FC,$0F,$F8,$3F
	.db $00,$F0,$3F,$C0,$FF,$01,$C0,$FF,$00,$FF,$07,$00,$FF,$03,$FC,$1F
	.db $00,$FC,$0F,$F0,$FF,$00,$F0,$3F,$80,$FF,$03,$80,$FF,$01,$FE,$07
	.db $00,$FE,$07,$FC,$3F,$00,$F8,$1F,$E0,$FF,$00,$C0,$7F,$80,$FF,$07
	.db $00,$FF,$03,$FC,$1F,$00,$FC,$0F,$F0,$7F,$00,$F0,$3F,$C0,$FF,$03
	.db $80,$FF,$00,$FF,$0F,$00,$FE,$07,$F8,$3F,$00,$F8,$1F,$E0,$FF,$00
	.db $C0,$7F,$80,$FF,$07,$00,$FF,$01,$FE,$1F,$00,$FC,$07,$F8,$7F,$00
	.db $F0,$1F,$E0,$FF,$03,$C0,$7F,$00,$FF,$0F,$00,$FE,$03,$FC,$3F,$00
	.db $F8,$0F,$F0,$FF,$00,$E0,$3F,$80,$FF,$07,$00,$FF,$01,$FE,$1F,$00
	.db $FC,$07,$F8,$FF,$00,$F0,$1F,$C0,$FF,$03,$80,$FF,$00,$FF,$0F,$00
	.db $FE,$03,$F8,$7F,$00,$F8,$1F,$E0,$FF,$01,$C0,$7F,$00,$FF,$0F,$00
	.db $FE,$03,$FC,$3F,$00,$F8,$0F,$E0,$FF,$03,$C0,$7F,$00,$FF,$0F,$00
	.db $FE,$03,$FC,$7F,$00,$F0,$1F,$E0,$FF,$01,$80,$FF,$00,$FF,$0F,$00
	.db $FE,$07,$F8,$7F,$00,$F0,$1F,$C0,$FF,$03,$80,$FF,$00,$FE,$1F,$00
	.db $FC,$0F,$F0,$FF,$00,$E0,$3F,$80,$FF,$07,$00,$FF,$03,$FC,$3F,$00
	.db $F8,$0F,$E0,$FF,$01,$C0,$7F,$00,$FF,$1F,$00,$FE,$03,$F8,$7F,$00
	.db $F0,$3F,$C0,$FF,$03,$80,$FF,$00,$FF,$1F,$00,$FC,$07,$F0,$FF,$00
	.db $E0,$3F,$80,$FF,$07,$00,$FF,$01,$FE,$3F,$00,$F8,$0F,$F0,$FF,$00
	.db $E0,$3F,$80,$FF,$0F,$00,$FF,$01,$FC,$3F,$00,$F8,$0F,$E0,$FF,$01
	.db $C0,$7F,$00,$FF,$1F,$00,$FE,$03,$F8,$FF,$00,$E0,$3F,$80,$FF,$07
	.db $00,$FF,$01,$FC,$7F,$00,$F8,$0F,$E0,$FF,$03,$80,$FF,$00,$FE,$3F
	.db $00,$FC,$07,$E0,$FF,$01,$C0,$7F,$00,$FF,$1F,$00,$FC,$07,$F0,$FF
	.db $01,$E0,$7F,$00,$FF,$0F,$00,$FE,$03,$F8,$FF,$00,$E0,$3F,$00,$FF
	.db $1F,$00,$FE,$03,$F0,$FF,$01,$C0,$FF,$00,$FE,$1F,$00,$FC,$0F,$E0
	.db $FF,$01,$C0,$FF,$00,$FE,$3F,$00,$F8,$0F,$E0,$FF,$03,$80,$FF,$00
	.db $FC,$7F,$00,$F8,$1F,$80,$FF,$07,$00,$FF,$03,$F8,$FF,$00,$E0,$3F
	.db $00,$FF,$0F,$00,$FE,$07,$F0,$FF,$01,$C0,$FF,$00,$FC,$3F,$00,$F8
	.db $3F,$80,$FF,$07,$00,$FF,$03,$F8,$FF,$00,$E0,$7F,$00,$FF,$0F,$00
	.db $FC,$0F,$E0,$FF,$03,$80,$FF,$01,$FC,$3F,$00,$F0,$3F,$80,$FF,$07
	.db $00,$FE,$0F,$E0,$FF,$01,$C0,$FF,$00,$FC,$7F,$00,$F0,$3F,$00,$FF
	.db $1F,$00,$FC,$0F,$E0,$FF,$03,$80,$FF,$01,$F8,$7F,$00,$F0,$7F,$00
	.db $FF,$0F,$00,$FC,$1F,$C0,$FF,$01,$80,$FF,$03,$F8,$7F,$00,$F0,$3F
	.db $80,$FF,$03,$00,$FF,$07,$FC,$3F,$00,$F0,$1F,$F0,$7F,$00,$F0,$0F
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DMCBossDeathDataEnd:

DMCInstrumentTable:
	;DMC high tom-tom
	.db $0C,$7F
	.db (DMCTomTomData>>6)&$FF
	.db (DMCTomTomDataEnd-DMCTomTomData)>>4
	;DMC mid tom-tom
	.db $0D,$7F
	.db (DMCTomTomData>>6)&$FF
	.db (DMCTomTomDataEnd-DMCTomTomData)>>4
	;DMC low tom-tom
	.db $0E,$7F
	.db (DMCTomTomData>>6)&$FF
	.db (DMCTomTomDataEnd-DMCTomTomData)>>4
	;DMC snare drum
	.db $0D,$7F
	.db (DMCSnareDrumData>>6)&$FF
	.db (DMCSnareDrumDataEnd-DMCSnareDrumData)>>4
	;DMC bass drum
	.db $0D,$20
	.db (DMCBassDrumData>>6)&$FF
	.db (DMCBassDrumDataEnd-DMCBassDrumData)>>4
	;DMC vampire hurt
	.db $0D,$20
	.db (DMCPlayerHurtData>>6)&$FF
	.db (DMCPlayerHurtDataEnd-DMCPlayerHurtData)>>4
	;DMC monster hurt
	.db $0B,$20
	.db (DMCPlayerHurtData>>6)&$FF
	.db (DMCPlayerHurtDataEnd-DMCPlayerHurtData)>>4
	;DMC boss death 0
	.db $08,$00
	.db (DMCBossDeathData>>6)&$FF
	.db (DMCBossDeathDataEnd-DMCBossDeathData)>>4
	;DMC boss death 1
	.db $0B,$00
	.db (DMCBossDeathData>>6)&$FF
	.db (DMCBossDeathDataEnd-DMCBossDeathData)>>4
	;DMC boss death 2
	.db $04,$00
	.db (DMCBossDeathData>>6)&$FF
	.db (DMCBossDeathDataEnd-DMCBossDeathData)>>4

;;;;;;;;;;;;;;;;;;;;
;SCROLLING ROUTINES;
;;;;;;;;;;;;;;;;;;;;
LevelLayoutPointerTable:
	.dw Level11LayoutData
	.dw Level12LayoutData
	.dw Level13LayoutData
	.dw Level21LayoutData
	.dw Level22LayoutData
	.dw Level13LayoutData
	.dw Level31LayoutData
	.dw Level32LayoutData
	.dw Level33LayoutData
	.dw Level41LayoutData
	.dw Level42LayoutData
	.dw Level43LayoutData
	.dw Level51LayoutData
	.dw Level52LayoutData
	.dw Level53LayoutData
	.dw Level61LayoutData
	.dw Level62LayoutData
	.dw Level63LayoutData
LevelBGPointerTable:
	.dw Level11BGPointerData
	.dw Level12BGPointerData
	.dw Level13BGPointerData
	.dw Level21BGPointerData
	.dw Level22BGPointerData
	.dw Level23BGPointerData
	.dw Level31BGPointerData
	.dw Level32BGPointerData
	.dw Level33BGPointerData
	.dw Level41BGPointerData
	.dw Level42BGPointerData
	.dw Level43BGPointerData
	.dw Level51BGPointerData
	.dw Level52BGPointerData
	.dw Level53BGPointerData
	.dw Level61BGPointerData
	.dw Level62BGPointerData
	.dw Level63BGPointerData
LevelTilePointerTable:
	.dw Level11TileData
	.dw Level12TileData
	.dw Level13TileData
	.dw Level21TileData
	.dw Level22TileData
	.dw Level23TileData
	.dw Level31TileData
	.dw Level32TileData
	.dw Level32TileData
	.dw Level41TileData
	.dw Level42TileData
	.dw Level41TileData
	.dw Level51TileData
	.dw Level52TileData
	.dw Level53TileData
	.dw Level61TileData
	.dw Level61TileData
	.dw Level63TileData
LevelAttrPointerTable:
	.dw Level11AttrData
	.dw Level12AttrData
	.dw Level13AttrData
	.dw Level21AttrData
	.dw Level22AttrData
	.dw Level23AttrData
	.dw Level31AttrData
	.dw Level32AttrData
	.dw Level32AttrData
	.dw Level41AttrData
	.dw Level42AttrData
	.dw Level41AttrData
	.dw Level51AttrData
	.dw Level52AttrData
	.dw Level53AttrData
	.dw Level61AttrData
	.dw Level61AttrData
	.dw Level63AttrData

GetScrollSeamXPosition:
	;Get scroll seam X position
	lda TempMirror_PPUSCROLL_X
	clc
	adc #$07
	sta $04
	lda CurScreenX
	adc #$00
	tay
	lsr $04
	lsr $04
	lsr $04
	ldx $04
	rts

GetScrollSeamYPosition:
	;Get scroll seam Y position
	ldy CurScreenY
	lda TempMirror_PPUSCROLL_Y
	lsr
	lsr
	lsr
	lsr
	tax
	rts

UpdateLevelScroll:
	;Check for X tile scroll
	lda ScrollXTilePos
	and #$F8
	beq UpdateLevelScroll_NoXTileScroll
	;Set X scroll flag
	inc ScrollXFlag
	;Update X tile scroll position
	ldy #$00
	lda ScrollXTilePos
	bmi UpdateLevelScroll_NoXTileC
	iny
UpdateLevelScroll_NoXTileC:
	sty ScrollXDirection
	and #$07
	sta ScrollXTilePos
UpdateLevelScroll_NoXTileScroll:
	;Check for X collision scroll
	lda ScrollXCollPosLo
	and #$F0
	beq UpdateLevelScroll_NoXCollScroll
	;Set X axis scroll flag
	inc ScrollAxisFlags
	;Update X collision scroll position
	ldy #$00
	lda ScrollXCollPosLo
	bmi UpdateLevelScroll_NoXCollC2
	inc ScrollXCollPosHi
	lda ScrollXCollPosHi
	cmp #$19
	bcc UpdateLevelScroll_NoXCollC1
	lda #$00
	sta ScrollXCollPosHi
UpdateLevelScroll_NoXCollC1:
	iny
	bne UpdateLevelScroll_XCollSet
UpdateLevelScroll_NoXCollC2:
	dec ScrollXCollPosHi
	bpl UpdateLevelScroll_XCollSet
	lda #$18
	sta ScrollXCollPosHi
UpdateLevelScroll_XCollSet:
	sty ScrollXDirection
	lda ScrollXCollPosLo
	and #$0F
	sta ScrollXCollPosLo
UpdateLevelScroll_NoXCollScroll:
	;Check for Y collision scroll
	lda ScrollYCollPosLo
	and #$F0
	beq UpdateLevelScroll_NoYCollScroll
	;Set Y axis scroll flag
	inc ScrollAxisFlags
	inc ScrollAxisFlags
	;Set Y scroll flag
	inc ScrollYFlag
	;Update X collision scroll position
	ldy #$00
	lda ScrollYCollPosLo
	bmi UpdateLevelScroll_NoYCollC2
	inc ScrollYCollPosHi
	lda ScrollYCollPosHi
	cmp #$14
	bcc UpdateLevelScroll_NoYCollC1
	lda #$00
	sta ScrollYCollPosHi
UpdateLevelScroll_NoYCollC1:
	iny
	bne UpdateLevelScroll_YCollSet
UpdateLevelScroll_NoYCollC2:
	dec ScrollYCollPosHi
	bpl UpdateLevelScroll_YCollSet
	lda #$13
	sta ScrollYCollPosHi
UpdateLevelScroll_YCollSet:
	sty ScrollYDirection
	lda ScrollYCollPosLo
	and #$0F
	sta ScrollYCollPosLo
UpdateLevelScroll_NoYCollScroll:
	;Check for horizontal collision scroll
	lsr ScrollAxisFlags
	bcc UpdateLevelScroll_NoHorizColl
	;Update horizontal collision scrolling
	jsr UpdateLevelCollision_Horiz
UpdateLevelScroll_NoHorizColl:
	;Check for vertical collision scroll
	lsr ScrollAxisFlags
	bcc UpdateLevelScroll_NoVertColl
	;Update vertical collision scrolling
	jsr UpdateLevelCollision_Vert
UpdateLevelScroll_NoVertColl:
	;Check if previously updated vertical scroll
	lda ScrollYPrevFlag
	bne UpdateLevelScroll_CheckVert2
	;Check for horizontal scroll
	lda ScrollXFlag
	beq UpdateLevelScroll_CheckVert
UpdateLevelScroll_DoHoriz:
	;Clear X scroll flag
	lda #$00
	sta ScrollXFlag
	;Update horizontal scrolling
	beq UpdateLevelScroll_Horiz
UpdateLevelScroll_CheckVert:
	;Check for vertical scroll
	lda ScrollYFlag
	beq UpdateLevelScroll_Exit
UpdateLevelScroll_DoVert:
	;Set previous Y scroll flag
	inc ScrollYPrevFlag
	;Clear Y scroll flag
	lda #$00
	sta ScrollYFlag
	;Clear Y scroll tile position low bit
	sta ScrollSeamYTileLo
	;Update vertical scrolling
	beq UpdateLevelScroll_DoVert2
UpdateLevelScroll_CheckVert2:
	;Check for vertical scroll
	lda ScrollYFlag
	beq UpdateLevelScroll_DoVert2
	;Check for horizontal scroll
	lda ScrollXFlag
	bne UpdateLevelScroll_DoHoriz
	beq UpdateLevelScroll_DoVert
UpdateLevelScroll_DoVert2:
	;Update vertical scrolling
	jmp UpdateLevelScroll_Vert
UpdateLevelScroll_Exit:
	rts

UpdateLevelScroll_Horiz_BoundR:
	;Clear previous Y scroll flag
	lda #$00
	sta ScrollYPrevFlag
	rts
UpdateLevelScroll_Horiz:
	;Get scroll seam X position
	jsr GetScrollSeamXPosition
	;Check if scrolling left or right
	lda ScrollXDirection
	beq UpdateLevelScroll_Horiz_Left
	;Adjust seam position for right edge of screen
	dex
	bpl UpdateLevelScroll_Horiz_NoXC
	ldx #$1F
	dey
UpdateLevelScroll_Horiz_NoXC:
	;Check for right level bounds
	iny
	cpy LevelAreaWidth
	bcs UpdateLevelScroll_Horiz_BoundR
UpdateLevelScroll_Horiz_Left:
	;Set scroll seam X position
	sty ScrollSeamXScreen
	stx ScrollSeamXTile
	;Get scroll seam Y position
	lda #$0F
	sta $08
	jsr GetScrollSeamYPosition
	dex
	bpl UpdateLevelScroll_Horiz_NoYC
	ldx #$0E
	;Check for top level bounds
	dey
	bpl UpdateLevelScroll_Horiz_NoYC
	dec $08
	ldx #$00
	ldy #$00
UpdateLevelScroll_Horiz_NoYC:
	;Set scroll seam Y position
	stx ScrollSeamYTile
	sty ScrollSeamYScreen
	;Get level BG data pointers
	jsr GetLevelBGPointers
	;Set scroll VRAM pointer
	jsr SetScrollVRAMPointer
	;Init VRAM buffer column
	lda #$02
	jsr WriteVRAMBufferCmd
	;Set VRAM buffer address
	jsr WriteVRAMBufferScrollAddr
	;Get level metatile data offset
	jsr GetLevelMetatileOffset
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	;Get level attribute data pointer
	jsr GetLevelAttrPointer
	;Check to update attribute data buffer
	lda ScrollSeamXTile
	lsr
	bcc UpdateLevelScroll_Horiz_NoAttrBuf
	;Update attribute data buffer
	jsr SetScrollAttrVRAMPointer_Horiz
	jsr UpdateScrollAttrBuffer_Horiz
UpdateLevelScroll_Horiz_NoAttrBuf:
	;Get tile X offset in metatile
	jsr GetTileOffsetX
	;Get tile Y offset in metatile
	lda ScrollSeamYTile
	lsr
	bcc UpdateLevelScroll_Horiz_Loop
	tya
	clc
	adc #$08
	tay
UpdateLevelScroll_Horiz_Loop:
	;Draw column of metatile tiles
	jsr WriteVRAMBufferScrollTile_Horiz
	;Loop for each metatile
	dec $08
	beq UpdateLevelScroll_Horiz_End
	;Go to next row in screen BG data
	inc ScrollSeamYTile
	;Check for nametable overflow
	lda ScrollSeamYTile
	cmp #$0F
	bcc UpdateLevelScroll_Horiz_NoNextNT
	;Setup scroll seam Y position for new nametable
	inc ScrollSeamYScreen
	;Check for bottom level bounds
	lda ScrollSeamYScreen
	cmp LevelAreaHeight
	bcs UpdateLevelScroll_Horiz_End
	lda #$00
	sta ScrollSeamYTile
	;End VRAM buffer
	stx VRAMBufferOffset
	jsr WriteVRAMBufferCmd_End
	;Get level BG screen pointer
	jsr GetLevelBGScreenPointer
	;Get level metatile data offset
	jsr GetLevelMetatileOffset
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	;Get level attribute data pointer
	jsr GetLevelAttrPointer
	;Update attribute data buffer
	jsr UpdateScrollAttrBuffer_Horiz
	;Check for top or bottom nametable
	ldy #$28
	lda ScrollSeamYScreen
	lsr
	bcs UpdateLevelScroll_Horiz_Bottom
	ldy #$20
UpdateLevelScroll_Horiz_Bottom:
	;Set scroll VRAM pointer
	sty ScrollVRAMPointer+1
	lda ScrollVRAMPointer
	and #$1F
	sta ScrollVRAMPointer
	;Init VRAM buffer column
	lda #$02
	jsr WriteVRAMBufferCmd
	;Set VRAM buffer address
	jsr WriteVRAMBufferScrollAddr
	;Get tile X offset in metatile
	jsr GetTileOffsetX
	jmp UpdateLevelScroll_Horiz_Loop
UpdateLevelScroll_Horiz_NoNextNT:
	;Check for last row of metatile
	cpy #$10
	bcc UpdateLevelScroll_Horiz_Loop
	;Get level metatile data offset
	lda $0D
	clc
	adc #$08
	sta $0D
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	;Get level attribute data pointer
	jsr GetLevelAttrPointer
	;Update attribute data buffer
	jsr UpdateScrollAttrBuffer_Horiz
	;Get tile X offset in metatile
	jsr GetTileOffsetX
	jmp UpdateLevelScroll_Horiz_Loop
UpdateLevelScroll_Horiz_End:
	;End VRAM buffer
	stx VRAMBufferOffset
	jsr WriteVRAMBufferCmd_End
	;Check to update attributes
	lda ScrollSeamXTile
	lsr
	bcc UpdateLevelScroll_Horiz_NoAttrSet
	;Draw attributes
	lda #$05
	ldy ScrollAttrBufferOffs
	jsr WriteVRAMBufferScrollAttr
UpdateLevelScroll_Horiz_NoAttrSet:
	;Clear previous Y scroll flag
	lda #$00
	sta ScrollYPrevFlag
	rts

WriteVRAMBufferScrollAddr:
	;Write VRAM buffer scroll address
	lda ScrollVRAMPointer
	sta VRAMBuffer,x
	inx
	lda ScrollVRAMPointer+1
	sta VRAMBuffer,x
	inx
	rts

WriteVRAMBufferScrollTile_Horiz:
	;Write VRAM buffer scroll tile data
	lda #$01
	sta $04
WriteVRAMBufferScrollTile_Horiz_Loop:
	;Set tile in VRAM
	lda ($0E),y
	sta VRAMBuffer,x
	inx
	;Loop for each tile
	tya
	clc
	adc #$04
	tay
	dec $04
	bpl WriteVRAMBufferScrollTile_Horiz_Loop
	rts

GetLevelBGPointers:
	;Get level BG data pointers
	lda LevelAreaNum
	asl
	tax
	lda LevelLayoutPointerTable,x
	sta $0B
	lda LevelLayoutPointerTable+1,x
	sta $0C
	lda LevelBGPointerTable,x
	sta $1E
	lda LevelBGPointerTable+1,x
	sta $1F

GetLevelBGScreenPointer:
	;Get level BG screen data offset
	lda #$00
	sta $09
	ldy ScrollSeamYScreen
	beq GetLevelBGScreenPointer_Y0
GetLevelBGScreenPointer_Loop:
	clc
	adc LevelAreaWidth
	dey
	bne GetLevelBGScreenPointer_Loop
GetLevelBGScreenPointer_Y0:
	clc
	adc ScrollSeamXScreen
	tay
	sta $15
	;Get level BG screen pointer
	lda ($0B),y
	and #$3F
	asl
	tay
	lda ($1E),y
	sta $09
	iny
	lda ($1E),y
	sta $0A
	rts

GetLevelMetatileOffset:
	;Get level metatile data offset
	lda ScrollSeamXTile
	lsr
	lsr
	sta $04
	lda ScrollSeamYTile
	and #$FE
	asl
	asl
	adc $04
	sta $0D
	rts

GetLevelMetatilePointer:
	;Get level metatile data pointer
	lda #$00
	sta $0F
	lda LevelAreaNum
	asl
	sta $04
	ldy $0D
	lda ($09),y
	sta $05
	ldy $04
	asl
	rol $0F
	asl
	rol $0F
	asl
	rol $0F
	asl
	rol $0F
	clc
	adc LevelTilePointerTable,y
	sta $0E
	lda $0F
	adc LevelTilePointerTable+1,y
	sta $0F
	rts

GetLevelAttrPointer:
	;Get level attribute data pointer
	lda LevelAttrPointerTable,y
	sta $06
	lda LevelAttrPointerTable+1,y
	sta $07
	ldy $05
	lda ($06),y
	sta $12
	rts

GetTileOffsetX:
	;Get tile X offset in metatile
	lda ScrollSeamXTile
	and #$03
	tay
	rts

SetScrollVRAMPointer:
	;Set scroll VRAM pointer
	ldy #$28
	lda ScrollSeamYScreen
	lsr
	bcs SetScrollVRAMPointer_Right
	ldy #$20
SetScrollVRAMPointer_Right:
	sty $05
	lda #$00
	sta ScrollVRAMPointer
	lda ScrollSeamYTile
	lsr
	ror ScrollVRAMPointer
	lsr
	ror ScrollVRAMPointer
	adc $05
	sta ScrollVRAMPointer+1
	lda ScrollVRAMPointer
	adc ScrollSeamXTile
	sta ScrollVRAMPointer
	rts

UpdateScrollAttrBuffer_Horiz:
	;Check to update scroll attribute buffer
	lda ScrollSeamXTile
	lsr
	bcc UpdateScrollAttrBuffer_Horiz_Exit
	;Check for near or far side of metatile
	eor ScrollXDirection
	lsr
	bcs UpdateScrollAttrBuffer_Horiz_Near
	;Update scroll attribute buffer
	lda $12
UpdateScrollAttrBuffer_Horiz_Set:
	ldy ScrollAttrBufferOffs
	sta ScrollAttrBuffer-2,y
	;Increment scroll attribute buffer offset
	inc ScrollAttrBufferOffs
UpdateScrollAttrBuffer_Horiz_Exit:
	rts
UpdateScrollAttrBuffer_Horiz_Near:
	;Check if scrolling left or right
	lda #$00
	sta $13
	ldy $15
	lda ScrollXDirection
	bne UpdateScrollAttrBuffer_Horiz_Right
	;Get level attribute data pointer
	iny
	jsr UpdateScrollAttrBuffer_HorizSub
	;Update scroll attribute buffer
	and #$33
	sta $04
	lda $12
	and #$CC
	ora $04
	jmp UpdateScrollAttrBuffer_Horiz_Set
UpdateScrollAttrBuffer_Horiz_Right:
	;Get level attribute data pointer
	dey
	jsr UpdateScrollAttrBuffer_HorizSub
	;Update scroll attribute buffer
	and #$CC
	sta $04
	lda $12
	and #$33
	ora $04
	jmp UpdateScrollAttrBuffer_Horiz_Set

UpdateScrollAttrBuffer_HorizSub:
	;Get level BG screen pointer
	lda ($0B),y
	and #$3F
	asl
	tay
	lda ($1E),y
	sta $13
	iny
	lda ($1E),y
	sta $14
	;Get level attribute data offset
	ldy $0D
	lda ($13),y
	tay
	;Get level attribute data pointer
	lda ($06),y
	rts

UpdateLevelScroll_Vert_Bound:
	;Clear previous Y scroll flag
	lda #$00
	sta ScrollYPrevFlag
	rts
UpdateLevelScroll_Vert_Bottom:
	;Restore scroll seam position
	lda TempScrollSeamXTile
	sta ScrollSeamXTile
	lda TempScrollSeamXScreen
	sta ScrollSeamXScreen
	lda TempScrollSeamYTile
	sta ScrollSeamYTile
	lda TempScrollSeamYScreen
	sta ScrollSeamYScreen
	jmp UpdateLevelScroll_Vert_EntBottom
UpdateLevelScroll_Vert:
	;Check for bottom part of metatile
	lda ScrollSeamYTileLo
	bne UpdateLevelScroll_Vert_Bottom
	;Get scroll seam Y position
	jsr GetScrollSeamYPosition
	;Check if scrolling up or down
	lda ScrollYDirection
	bne UpdateLevelScroll_Vert_Down
	;Adjust seam position for top edge of screen
	dex
	bpl UpdateLevelScroll_Vert_NoYUC
	ldx #$0E
	;Check for top level bounds
	dey
	bmi UpdateLevelScroll_Vert_Bound
	bpl UpdateLevelScroll_Vert_NoYUC
UpdateLevelScroll_Vert_Down:
	;Adjust seam position for bottom edge of screen
	txa
	clc
	adc #$0D
	cmp #$0F
	bcc UpdateLevelScroll_Vert_NoYDC
	adc #$00
	and #$0F
	;Check for bottom level bounds
	iny
	cpy LevelAreaHeight
	bcs UpdateLevelScroll_Vert_Bound
UpdateLevelScroll_Vert_NoYDC:
	tax
UpdateLevelScroll_Vert_NoYUC:
	;Set scroll seam Y position
	stx ScrollSeamYTile
	sty ScrollSeamYScreen
	stx TempScrollSeamYTile
	sty TempScrollSeamYScreen
	;Get scroll seam X position
	jsr GetScrollSeamXPosition
	;Set scroll seam X position
	stx ScrollSeamXTile
	stx TempScrollSeamXTile
	sty ScrollSeamXScreen
	sty TempScrollSeamXScreen
	;Set scroll VRAM pointer
	jsr SetScrollVRAMPointer
	lda ScrollVRAMPointer
	sta $10
UpdateLevelScroll_Vert_EntBottom:
	;Get level BG pointers
	lda #$20
	sta $08
	jsr GetLevelBGPointers
	;Init VRAM buffer row
	lda #$01
	jsr WriteVRAMBufferCmd
	;Set VRAM buffer address
	jsr WriteVRAMBufferScrollAddr
	;Get level metatile data offset
	jsr GetLevelMetatileOffset
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	;Get level attribute data pointer
	jsr GetLevelAttrPointer
	;Update attribute data buffer
	jsr SetScrollAttrVRAMPointer_Vert
	jsr UpdateScrollAttrBuffer_Vert
	;Get tile Y offset in metatile
	jsr GetTileOffsetY
	sty $04
	;Get tile X offset in metatile
	lda ScrollSeamXTile
	and #$03
	clc
	adc $04
	tay
UpdateLevelScroll_Vert_Loop:
	;Set tile in VRAM
	lda ($0E),y
	sta VRAMBuffer,x
	;Loop for each tile
	inx
	dec $08
	beq UpdateLevelScroll_Vert_End
	;Check for nametable overflow
	inc ScrollSeamXTile
	lda ScrollSeamXTile
	cmp #$20
	bcc UpdateLevelScroll_Vert_NoNextNT
	;Setup scroll seam X position for new nametable
	lda #$00
	sta ScrollSeamXTile
	inc ScrollSeamXScreen
	;End VRAM buffer
	stx VRAMBufferOffset
	jsr WriteVRAMBufferCmd_End
	;Get level BG screen pointer
	jsr GetLevelBGScreenPointer
	;Get level metatile data offset
	jsr GetLevelMetatileOffset
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	;Get level attribute data pointer
	jsr GetLevelAttrPointer
	;Update attribute data buffer
	jsr UpdateScrollAttrBuffer_Vert
	;Get tile Y offset in metatile
	jsr GetTileOffsetY
	;Set scroll VRAM pointer
	lda ScrollVRAMPointer
	and #$E0
	sta ScrollVRAMPointer
	;Init VRAM buffer row
	lda #$01
	jsr WriteVRAMBufferCmd
	;Set VRAM buffer address
	jsr WriteVRAMBufferScrollAddr
	jmp UpdateLevelScroll_Vert_Loop
UpdateLevelScroll_Vert_NoNextNT:
	;Check for last column of metatile
	iny
	tya
	and #$03
	bne UpdateLevelScroll_Vert_Loop
	;Get level metatile data offset
	inc $0D
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	;Get level attribute data pointer
	jsr GetLevelAttrPointer
	;Update attribute data buffer
	jsr UpdateScrollAttrBuffer_Vert
	;Get tile Y offset in metatile
	jsr GetTileOffsetY
	jmp UpdateLevelScroll_Vert_Loop
UpdateLevelScroll_Vert_End:
	;End VRAM buffer
	stx VRAMBufferOffset
	jsr WriteVRAMBufferCmd_End
	;Check to update attributes
	lda ScrollSeamYTileLo
	bne UpdateLevelScroll_Vert_AttrSet
	;Set scroll VRAM pointer
	inc ScrollSeamYTileLo
	lda $10
	clc
	adc #$20
	sta ScrollVRAMPointer
	rts
UpdateLevelScroll_Vert_AttrSet:
	;Draw attributes
	lda #$04
	ldy #$0A
	jsr WriteVRAMBufferScrollAttr
	;Clear previous Y scroll flag
	lda #$00
	sta ScrollYPrevFlag
	rts

GetTileOffsetY:
	;Get tile Y offset in metatile
	ldy #$00
	lda ScrollSeamYTile
	lsr
	bcc GetTileOffsetY_NoYC
	ldy #$08
GetTileOffsetY_NoYC:
	lda ScrollSeamYTileLo
	beq GetTileOffsetY_NoYC2
	tya
	clc
	adc #$04
	tay
GetTileOffsetY_NoYC2:
	rts

SetScrollAttrVRAMPointer_Vert:
	;Check to update scroll attribute VRAM pointer
	lda ScrollSeamYTileLo
	eor ScrollYDirection
	beq UpdateScrollAttrBuffer_Vert_Exit
SetScrollAttrVRAMPointer_Horiz:
	;Check for top or bottom nametable
	ldy #$23
	lda ScrollSeamYScreen
	lsr
	bcc SetScrollAttrVRAMPointer_Left
	ldy #$2B
SetScrollAttrVRAMPointer_Left:
	;Set scroll attribute VRAM pointer
	sty ScrollAttrVRAMPointer+1
	lda ScrollSeamYTile
	asl
	asl
	and #$F8
	sta $04
	lda ScrollSeamXTile
	lsr
	lsr
	ora $04
	ora #$C0
	sta ScrollAttrVRAMPointer
	;Init scroll attribute buffer offset
	lda #$02
	sta ScrollAttrBufferOffs
	rts

UpdateScrollAttrBuffer_Vert:
	;Check to update scroll attribute buffer
	lda ScrollSeamYTileLo
	eor ScrollYDirection
	beq UpdateScrollAttrBuffer_Vert_Exit
	;Check for last column of attributes
	lda ScrollAttrBufferOffs
	cmp #$0A
	beq UpdateScrollAttrBuffer_Vert_Last
	;Update scroll attribute buffer
	tay
	lda $12
	sta ScrollAttrBuffer-2,y
	;Increment scroll attribute buffer offset
	inc ScrollAttrBufferOffs
UpdateScrollAttrBuffer_Vert_Exit:
	rts
UpdateScrollAttrBuffer_Vert_Last:
	;If last 2 columns of tiles being drawn, exit early
	lda $08
	cmp #$02
	bcc UpdateScrollAttrBuffer_Vert_Exit
	;Update scroll attribute buffer
	lda $12
	and #$33
	sta $06
	lda ScrollAttrBuffer
	and #$CC
	clc
	adc $06
	sta ScrollAttrBuffer
	rts

WriteVRAMBufferScrollAttr:
	;Init VRAM buffer attribute row/column
	sty $04
	jsr WriteVRAMBufferCmd
	ldy #$00
WriteVRAMBufferScrollAttr_Loop:
	;Set attribute in VRAM
	lda ScrollAttrVRAMPointer,y
	sta VRAMBuffer,x
	;Loop for each attribute byte
	inx
	iny
	cpy $04
	bne WriteVRAMBufferScrollAttr_Loop
	;Save VRAM buffer offset
	stx VRAMBufferOffset
	rts

UpdateFreeMovementScroll:
	;Enable level scrolling in all directions
	lda #$0F
	sta LevelScrollFlags
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
	;Check to init free movement speed
	ldx FreeMovementSpeed
	bne UpdateFreeMovementScroll_NoInitSpeed
	inc FreeMovementSpeed
UpdateFreeMovementScroll_NoInitSpeed:
	;Check for A press
	lda JoypadDown
	and #JOY_A
	beq UpdateFreeMovementScroll_NoIncSpeed
	;Increment free movement speed
	inx
	cpx #$07
	bcc UpdateFreeMovementScroll_SetSpeed
	ldx #$01
UpdateFreeMovementScroll_SetSpeed:
	stx FreeMovementSpeed
UpdateFreeMovementScroll_NoIncSpeed:
	;Clear X scroll velocity
	lda #$00
	sta $0D
	sta $0C
	;Set scroll direction flags
	lda JoypadCur
	and #$0F
	sta ScrollDirectionFlags
	;Check for RIGHT held
	lsr
	bcc UpdateFreeMovementScroll_NoRight
	;Set X scroll velocity right
	lda FreeMovementSpeed
	sta $0D
	jmp UpdateFreeMovementScroll_NoLeft
UpdateFreeMovementScroll_NoRight:
	;Check for LEFT held
	lsr
	bcc UpdateFreeMovementScroll_NoLeft
	;Set X scroll velocity left
	lda #$00
	sec
	sbc FreeMovementSpeed
	sta $0D
UpdateFreeMovementScroll_NoLeft:
	;Update player X scroll
	jsr UpdatePlayerScrollXSub
	;Clear Y scroll velocity
	lda #$00
	sta $0C
	sta $0D
	;Check for DOWN held
	lda JoypadCur
	lsr
	lsr
	lsr
	bcc UpdateFreeMovementScroll_NoDown
	;Set Y scroll velocity down
	lda FreeMovementSpeed
	sta $0D
	jmp UpdateFreeMovementScroll_NoUp
UpdateFreeMovementScroll_NoDown:
	;Check for UP held
	lsr
	bcc UpdateFreeMovementScroll_NoUp
	;Set Y scroll velocity up
	lda #$00
	sec
	sbc FreeMovementSpeed
	sta $0D
UpdateFreeMovementScroll_NoUp:
	;Update player Y scroll
	jmp UpdatePlayerScrollYSub
	rts

;;;;;;;;;;;;;;;;;;
;PALETTE ROUTINES;
;;;;;;;;;;;;;;;;;;
;PALETTE DATA
PaletteData:
	.db $0F,$16,$2A,$20,$0F,$08,$17,$27,$0F,$0B,$1A,$29,$0F,$02,$11,$2C	;$00 \Level 1-1
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$07,$24,$33	;$01 /
	.db $1A,$16,$0F,$20,$1A,$08,$18,$27,$1A,$0F,$0A,$29,$1A,$0F,$08,$18	;$02 \Level 1-2
	.db $1A,$16,$27,$20,$1A,$08,$16,$3C,$1A,$08,$12,$31,$1A,$08,$17,$28	;$03 /
	.db $1A,$16,$0F,$20,$1A,$07,$18,$28,$1A,$0F,$02,$11,$1A,$0F,$08,$18	;$04 \Level 1-3
	.db $1A,$16,$27,$20,$1A,$08,$16,$3C,$1A,$08,$12,$31,$1A,$08,$1C,$32	;$05 /
	.db $0F,$16,$2A,$20,$0F,$17,$28,$37,$0F,$16,$27,$37,$0F,$27,$38,$20	;$06 \Level 2-1
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$08,$19,$29	;$07 /
	.db $0F,$16,$2A,$20,$0F,$22,$31,$20,$0F,$00,$10,$20,$0F,$18,$28,$20	;$08 \Level 2-2
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$08,$19,$29	;$09 /
	.db $0F,$16,$2A,$20,$0F,$22,$31,$20,$0F,$1A,$28,$20,$0F,$18,$28,$20	;$0A \Level 2-3
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$08,$21,$3C	;$0B /
	.db $0F,$16,$2A,$20,$0F,$10,$31,$20,$0F,$17,$28,$20,$0F,$05,$16,$20	;$0C \Level 3-1
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$04,$13,$23	;$0D /
	.db $0F,$16,$2A,$20,$0F,$0C,$1B,$10,$0F,$08,$13,$22,$0F,$08,$18,$28	;$0E \Level 3-2
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$02,$11,$31	;$0F /
	.db $0F,$16,$2A,$20,$0F,$0C,$1B,$10,$0F,$10,$20,$15,$0F,$1B,$10,$20	;$10 \Level 3-3
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$0F,$1B,$20	;$11 /
	.db $0F,$16,$2A,$20,$0F,$1A,$13,$38,$0F,$00,$28,$37,$0F,$06,$16,$10	;$12 \Level 4-1
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$0B,$1A,$3A	;$13 /
	.db $0F,$16,$2A,$20,$0F,$06,$16,$22,$0F,$00,$10,$20,$0F,$00,$28,$37	;$14 \Level 4-2
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$08,$18,$39	;$15 /
	.db $0F,$16,$2A,$20,$0F,$06,$16,$26,$0F,$00,$28,$37,$0F,$06,$16,$10	;$16 \Level 4-3
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$0B,$1B,$39	;$17 /
	.db $0F,$16,$2A,$20,$0F,$19,$2A,$31,$0F,$06,$17,$31,$0F,$00,$10,$31	;$18 \Level 5-1
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$0B,$1B,$28	;$19 /
	.db $0F,$16,$2A,$20,$0F,$16,$27,$30,$0F,$01,$21,$31,$0F,$07,$17,$38	;$1A \Level 5-2
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$0B,$1B,$28	;$1B /
	.db $0F,$16,$2A,$20,$0F,$16,$27,$30,$0F,$01,$21,$31,$0F,$07,$17,$38	;$1C \Level 5-3
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$03,$32,$14	;$1D /
	.db $0F,$16,$2A,$20,$0F,$00,$10,$20,$0F,$07,$17,$27,$0F,$01,$11,$21	;$1E \Level 6-1
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$07,$1A,$31	;$1F /
	.db $0F,$16,$2A,$20,$0F,$00,$10,$20,$0F,$00,$10,$20,$0F,$01,$11,$21	;$20 \Level 6-2
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$08,$1C,$32	;$21 /
	.db $0F,$16,$2A,$20,$0F,$00,$10,$36,$0F,$16,$27,$36,$0F,$17,$27,$37	;$22 \Level 6-3
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$0F,$00,$10	;$23 /
	.db $0F,$16,$28,$03,$0F,$01,$11,$21,$0F,$20,$20,$20,$0F,$0F,$0F,$0F	;$24 \Title screen
	.db $0F,$01,$11,$21,$0F,$06,$15,$28,$0F,$17,$27,$20,$0F,$20,$20,$20	;$25 /
	.db $0F,$03,$11,$21,$0F,$0C,$1B,$2B,$0F,$20,$20,$20,$0F,$0F,$0F,$20	;$26 \Player select/stage clear (Both players)
	.db $0F,$0F,$21,$20,$0F,$1B,$2B,$20,$0F,$17,$27,$20,$0F,$20,$20,$20	;$27 /
	.db $0F,$03,$11,$21,$0F,$0F,$00,$10,$0F,$20,$20,$20,$0F,$0F,$0F,$20	;$28 \Player select/stage clear (Vampire only)
	.db $0F,$0F,$21,$20,$0F,$0F,$00,$10,$0F,$17,$27,$20,$0F,$20,$20,$20	;$29 /
	.db $0F,$0F,$00,$10,$0F,$0C,$1B,$2B,$0F,$20,$20,$20,$0F,$0F,$0F,$20	;$2A \Player select/stage clear (Monster only)
	.db $0F,$0F,$00,$10,$0F,$1B,$2B,$20,$0F,$17,$27,$20,$0F,$20,$20,$20	;$2B /
	.db $0F,$25,$05,$15,$0F,$0C,$1B,$2B,$0F,$20,$20,$20,$0F,$0F,$0F,$20	;$2C \UNUSED
	.db $0F,$0F,$00,$10,$0F,$1B,$2B,$20,$0F,$17,$27,$20,$0F,$20,$20,$20	;$2D /
	.db $0F,$16,$2A,$20,$0F,$08,$17,$27,$0F,$0B,$1A,$29,$0F,$02,$11,$2C	;$2E \Game over
	.db $0F,$01,$11,$21,$0F,$06,$15,$28,$0F,$17,$27,$20,$0F,$20,$20,$20	;$2F /

FadePalette_IncT:
	;Increment fade timer
	inc FadeTimer
FadePalette_SetFadeDone:
	;Set fade done flag
	lda #$11
	sta FadeDoneFlag
	rts
FadePalette:
	;Increment fade timer
	inc FadeTimer
	;Check for fade timer < $08
	lda FadeTimer
	cmp #$08
	bcc FadePalette_IncT
	;If not enough space in VRAM buffer, exit early
	lda VRAMBufferOffset
	cmp #$10
	bcs FadePalette_SetFadeDone
	;Reset fade timer
	lda #$00
	sta FadeTimer
	;Clear fade done flag
	sta FadeDoneFlag
	;Check for fade direction $01 (no fade)
	ldy FadeDirection
	cpy #$01
	beq FadePalette_NoFade
	;Get palette data pointer
	jsr GetPaletteDataPointer
	;Check for fade direction $02 (fade out)
	tya
	bne FadePalette_FadeOut
	;If fade not inited, copy max darkened palette data to buffer
	lda FadeInitFlag
	bne FadePalette_FadeIn
	;Copy max darkened palette data to buffer
	ldy #$1F
FadePalette_CopyLoop:
	lda ($10),y
	and #$0F
	sta PaletteBuffer,y
	dey
	bpl FadePalette_CopyLoop
	;Set fade inited flag
	inc FadeInitFlag
	;Set fade done flag
	inc FadeDoneFlag
FadePalette_NoFade:
	;Write palette data to VRAM
	jmp WritePalette
FadePalette_FadeIn:
	;Copy fade in palette data to buffer
	ldy #$1F
FadePalette_FadeInLoop:
	lda PaletteBuffer,y
	cmp ($10),y
	beq FadePalette_FadeInNext
	clc
	adc #$10
	sta PaletteBuffer,y
	inc FadeDoneFlag
FadePalette_FadeInNext:
	dey
	bpl FadePalette_FadeInLoop
	;Check if all colors are completely faded in
	lda FadeDoneFlag
	bne FadePalette_NoNext
	;Next fade direction ($01: No fade)
	inc FadeDirection
FadePalette_NoNext:
	;Write palette data to VRAM
	jmp WritePalette
FadePalette_FadeOut:
	;Copy fade out palette data to buffer
	ldy #$1F
FadePalette_FadeOutLoop:
	lda PaletteBuffer,y
	cmp #$0F
	beq FadePalette_FadeOutNext
	bcs FadePalette_NoSetBlack
	lda #$0F
	bne FadePalette_FadeOutSet
FadePalette_NoSetBlack:
	sbc #$10
FadePalette_FadeOutSet:
	sta PaletteBuffer,y
	inc FadeDoneFlag
FadePalette_FadeOutNext:
	dey
	bpl FadePalette_FadeOutLoop
	;Write palette data to VRAM
	jmp WritePalette

GetPaletteDataPointer:
	;Get palette data pointer
	lda #$00
	sta $12
	lda CurPalette
GetPaletteDataPointer_AnyA:
	asl
	rol $12
	asl
	rol $12
	asl
	rol $12
	asl
	rol $12
	adc PaletteDataPointer
	sta $10
	lda $12
	and #$0F
	adc PaletteDataPointer+1
	sta $11
	rts

PaletteDataPointer:
	.dw PaletteData

LoadPalette:
	;Get palette data pointer
	ldy #$00
	sta $12
	jsr GetPaletteDataPointer_AnyA
LoadPalette_Loop:
	;Copy palette data to buffer
	lda ($10),y
	sta PaletteBuffer,x
	iny
	inx
	cpy #$10
	bne LoadPalette_Loop
	rts

;;;;;;;;;;;;;;
;IRQ ROUTINES;
;;;;;;;;;;;;;;
AddIRQBufferRegion:
	;Save requested IRQ buffer ID
	sta $1B
	;Get requested IRQ buffer height
	tay
	lda IRQHeightTable-1,y
	sta $18
	;Find location in buffer to insert entry
	ldy #$00
	sty $19
AddIRQBufferRegion_SearchLoop:
	;Check for end of IRQ buffer
	lda TempIRQBufferSub,y
	beq AddIRQBufferRegion_InsEnd
	;Check to insert entry here
	lda TempIRQBufferHeight,y
	clc
	adc $19
	sta $1A
	sec
	sbc $18
	bcs AddIRQBufferRegion_Insert
	;Loop for each entry
	lda $1A
	sta $19
	iny
	cpy #$05
	bne AddIRQBufferRegion_SearchLoop
	rts
AddIRQBufferRegion_Insert:
	;Set next IRQ buffer entry height
	sty $1C
	sta TempIRQBufferHeight,y
	inc $1C
	;Shift entries after insertion point
	ldy #$04
AddIRQBufferRegion_InsLoop:
	;Shift entry
	lda TempIRQBufferSub-1,y
	sta TempIRQBufferSub,y
	lda TempIRQBufferHeight-1,y
	sta TempIRQBufferHeight,y
	;Loop for each entry
	dey
	cpy $1C
	bcs AddIRQBufferRegion_InsLoop
AddIRQBufferRegion_InsEnd:
	;Insert entry here
	lda $1B
	sta TempIRQBufferSub,y
	lda $18
	sec
	sbc $19
	sta TempIRQBufferHeight,y
AddIRQBufferRegion_IRQEnable:
	;Enable IRQ
	lda #$01
AddIRQBufferRegion_IRQSet:
	sta TempIRQEnableFlag
	rts

RemoveIRQBufferRegion:
	;Save requested IRQ buffer ID
	sta $18
	;Find location in buffer to remove entry
	ldy #$00
RemoveIRQBufferRegion_SearchLoop:
	;Check for end of IRQ buffer
	lda TempIRQBufferSub,y
	beq RemoveIRQBufferRegion_Exit
	;Check to remove entry here
	cmp $18
	beq RemoveIRQBufferRegion_Remove
	;Loop for each entry
	iny
	cpy #$05
	bne RemoveIRQBufferRegion_SearchLoop
RemoveIRQBufferRegion_Exit:
	rts
RemoveIRQBufferRegion_Remove:
	;Check for last entry
	cpy #$04
	beq RemoveIRQBufferRegion_RemLast
	;Set next IRQ buffer entry ID
	lda TempIRQBufferSub+1,y
	sta TempIRQBufferSub,y
	;Check for end of IRQ buffer
	beq RemoveIRQBufferRegion_RemEnd
	;Set next IRQ buffer entry height
	lda TempIRQBufferHeight+1,y
	clc
	adc TempIRQBufferHeight,y
	sta TempIRQBufferHeight,y
	;Shift entries after removal point
RemoveIRQBufferRegion_RemLoop:
	;Loop for each entry
	iny
	cpy #$04
	bcs RemoveIRQBufferRegion_RemLast
	;Shift entry
	lda TempIRQBufferHeight+1,y
	sta TempIRQBufferHeight,y
	lda TempIRQBufferSub+1,y
	sta TempIRQBufferSub,y
	;Check for end of IRQ buffer
	bne RemoveIRQBufferRegion_RemLoop
	rts
RemoveIRQBufferRegion_RemEnd:
	;Check for first entry
	cpy #$00
	bne AddIRQBufferRegion_IRQEnable
	;Disable IRQ
	lda #$00
	beq AddIRQBufferRegion_IRQSet
RemoveIRQBufferRegion_RemLast:
	;Remove last entry
	lda #$00
	sta TempIRQBufferSub,y
	rts

IRQ:
	;Disable IRQ
	sei
	;Save A/X/Y registers
	pha
	tya
	pha
	txa
	pha
	;Enable IRQ
	sta $E000
	sta $E001
	;Set IRQ scanline timer to next IRQ height
	lda IRQNextHeight
	sta $C000
	;Check for last IRQ
	lda IRQLastFlag
	beq IRQ_DoJump
	;Disable IRQ
	sta $E000
IRQ_DoJump:
	;Enable IRQ
	cli
	;Do jump
	jmp (IRQSubPointer)

DisableIRQ:
	;Disable IRQ
	lda #$00
	sta IRQEnableFlag
	sta $E000
	rts

DecodeIRQBuffer:
	;Decode IRQ buffer entries
	ldy #$04
DecodeIRQBuffer_Loop:
	;Decode scroll ID value
	lda TempIRQBufferSub,y
	sta IRQBufferSub,y
	lda TempIRQBufferHeight,y
	;Decode scroll height value
	sta IRQBufferHeight,y
	;Loop for each entry
	dey
	bpl DecodeIRQBuffer_Loop
	;Decode IRQ enable flag
	lda TempIRQEnableFlag
	sta IRQEnableFlag
DecodeIRQBuffer_Lag:
	;Enable/disable IRQ based on IRQ enable flag
	ldy IRQEnableFlag
	sta $E000,y
	;If IRQ disabled, exit early
	beq DecodeIRQBuffer_Exit
	;Latch PPU status line
	lda PPU_STATUS
	;Clear PPU scroll
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL
	;Latch PPU status line
	lda PPU_STATUS
	;Set IRQ scanline timer $FF
	lda #$FF
	sta $C000
	sta $C001
	;Trigger 2 additional IRQ scanline timer ticks
	lda #$00
	sta PPU_ADDR
	sta PPU_ADDR
	lda #$10
	sta PPU_ADDR
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	sta PPU_ADDR
	lda #$10
	sta PPU_ADDR
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	sta PPU_ADDR
	;Set IRQ scanline timer to IRQ buffer scroll height
	lda IRQBufferHeight
	sta $C000
	sta $C001
	;Clear IRQ continue flag
	lda #$00
	sta IRQContinueFlag
	;Setup next IRQ buffer entry
	jsr SetNextIRQBuffer
	;Enable IRQ
	cli
DecodeIRQBuffer_Exit:
	rts

InitMMC3:
	;Clear bank switch value
	lda #$00
	sta $8000
	;Disable IRQ
	sta $E000
	;Latch PPU status line
	lda PPU_STATUS
	;Trigger 8 additional IRQ scanline timer ticks
	lda #$10
	tax
InitMMC3_IRQLoop:
	sta PPU_ADDR
	sta PPU_ADDR
	eor #$10
	dex
	bne InitMMC3_IRQLoop
	rts

SetNextIRQBuffer:
	;Get next IRQ buffer height
	ldx IRQContinueFlag
	lda IRQBufferHeight+1,x
	sec
	sbc #$01
	sta IRQNextHeight
	;Set IRQ continue flag
	inc IRQContinueFlag
	;Check for last entry
	cpx #$04
	beq SetNextIRQBuffer_Last
	lda IRQBufferSub+1,x
	bne SetNextIRQBuffer_ClearLast
SetNextIRQBuffer_Last:
	;Set last IRQ flag
	lda #$01
	bne SetNextIRQBuffer_SetLast
SetNextIRQBuffer_ClearLast:
	;Clear last IRQ flag
	lda #$00
SetNextIRQBuffer_SetLast:
	sta IRQLastFlag
	;Get IRQ jump address
	lda IRQBufferSub,x
	asl
	tax
	lda IRQJumpTable-2,x
	sta IRQSubPointer
	lda IRQJumpTable-2+1,x
	sta IRQSubPointer+1
	rts

;$0C: Nothing
IRQSub0C:
	;Setup next IRQ buffer entry
	jsr SetNextIRQBuffer
IRQSub0C_NoNext:
	;Restore last bank switch value
	ldx SoundMutex
	lda TempLastBankSwitch,x
	sta $8000
	;Restore A/X/Y registers
	pla
	tax
	pla
	tay
	pla
	rti

IRQHeightTable:
	.db $BF,$DC,$AF,$61,$E0,$B0,$B0,$9A,$A0,$8F,$10,$9A,$80,$B0,$A0,$B0
	.db $AB,$B1,$0A,$BF
IRQJumpTable:
	.dw IRQSub01	;$01  Main game
	.dw IRQSub02	;$02  HUD
	.dw IRQSub03	;$03  BG floor scroll
	.dw IRQSub04	;$04  Title logo
	.dw IRQSub05	;$05  Title pocket
	.dw IRQSub06	;$06  Level 3 water BG layer 2
	.dw IRQSub07	;$07  Level 4 elevator layer 2
	.dw IRQSub08	;$08  Level 3 boss layer 1
	.dw IRQSub09	;$09  Level 3 boss layer 2
	.dw IRQSub0A	;$0A  Level 3 water BG layer 1
	.dw IRQSub0B	;$0B  Level 4 elevator layer 1
	.dw IRQSub0C	;$0C  Nothing
	.dw IRQSub0D	;$0D  Level 4 crane
	.dw IRQSub0E	;$0E  Level 4 boss crane
	.dw IRQSub0F	;$0F  Level 6 ceiling crusher
	.dw IRQSub10	;$10  Level 6 elevator
	.dw IRQSub08	;$11  Level 3 boss layer 1 (boss rush)
	.dw IRQSub12	;$12  Level 3 boss layer 2 (boss rush)
	.dw IRQSub13	;$13  TV face wave
	.dw IRQSub14	;$14  TV normal

;$01: Main game
IRQSub01:
	;Wait for HBlank
	ldx #$08
IRQSub01_WaitHBlank:
	dex
	bpl IRQSub01_WaitHBlank
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	lda HUDVRAMBase+1
	sta PPU_ADDR
	lda HUDVRAMBase
	sta PPU_ADDR
	;Clear PPU scroll
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL
	;Load CHR banks
	ldx #$00
	stx $8000
	lda HUDCHRBank
	sta $8001
	inx
	stx $8000
	lda #$3E
	sta $8001
	inx
	stx $8000
	sta $8001
	inx
	stx $8000
	sta $8001
	inx
	stx $8000
	sta $8001
	inx
	stx $8000
	sta $8001
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$02: HUD
IRQSub02:
	;Wait for HBlank
	ldx #$07
IRQSub02_WaitHBlank1:
	dex
	bne IRQSub02_WaitHBlank1
	nop
	;Load CHR bank
	stx $8000
	lda #$3E
	sta $8001
	;Check to update HUD row
	lda UpdateHUDRowFlag
	beq IRQSub02_NoUpdateHUD
	;Wait for HBlank
	ldx #$04
IRQSub02_WaitHBlank2:
	dex
	bne IRQSub02_WaitHBlank2
	;Hide sprites/background
	stx PPU_MASK
	;Write HUD to VRAM
	jsr WriteHUD
IRQSub02_NoUpdateHUD:
	;Setup next IRQ buffer entry
	jmp IRQSub0C

WriteHUD:
	;Check for row 1
	lda HUDRowIndex
	tay
	and #$03
	cmp #$01
	bne WriteHUD_NoAttr
	;Check if HUD position changed
	cpy #$04
	;Use current HUD position
	lda HUDPositionCur
	bcs WriteHUD_NoInit
	;Use next HUD position
	lda HUDPositionNext
WriteHUD_NoInit:
	;Set PPU address based on HUD position index
	asl
	tay
	lda HUDVRAMAttrAddrTable+1,y
	sta PPU_ADDR
	lda HUDVRAMAttrAddrTable,y
	sta PPU_ADDR
	;Set attributes in VRAM
	ldx #$08
	lda #$00
WriteHUD_AttrLoop:
	;Set attribute in VRAM
	sta PPU_DATA
	;Loop for each attribute byte
	dex
	bne WriteHUD_AttrLoop
WriteHUD_NoAttr:
	;Set PPU address based on HUD VRAM address
	lda HUDVRAMPointer+1
	sta PPU_ADDR
	lda HUDVRAMPointer
	sta PPU_ADDR
	;Set tiles in VRAM
	ldx #$00
WriteHUD_TileLoop:
	;Set tile in VRAM
	lda HUDVRAMBuffer,x
	sta PPU_DATA
	;Loop for each tile byte
	inx
	cpx #$20
	bcc WriteHUD_TileLoop
	rts

HUDVRAMAttrAddrTable:
	.dw $23C0
	.dw $23E8
	.dw $2BD8

;$03: BG floor scroll
IRQSub03:
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU scroll
	lda BGFloorScrollX
	sta PPU_SCROLL
	lda TempMirror_PPUSCROLL_Y
	sta PPU_SCROLL
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$04: Title logo
IRQSub04:
	;Wait for HBlank
	ldx #$08
IRQSub04_WaitHBlank:
	dex
	bne IRQSub04_WaitHBlank
	;Clear PPU scroll
	lda #$A8
	sta PPU_CTRL
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	lda #$21
	sta PPU_ADDR
	lda #$80
	sta PPU_ADDR
	;Clear PPU scroll
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$05: Title pocket
IRQSub05:
	;Wait for HBlank
	ldx #$08
IRQSub05_WaitHBlank:
	dex
	bne IRQSub05_WaitHBlank
	;Load CHR bank
	lda #$01
	sta $8000
	lda #$7E
	sta $8001
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$06: Level 3 water BG layer 2
IRQSub06:
	;Wait for HBlank
	ldx #$08
IRQSub06_WaitHBlank:
	dex
	bne IRQSub06_WaitHBlank
	;Load CHR banks
	ldx #$02
	stx $8000
	lda #$7F
	sta $8001
	inx
	stx $8000
	sta $8001
	inx
	stx $8000
	sta $8001
	inx
	stx $8000
	sta $8001
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$07: Level 4 elevator layer 2
IRQSub07:
	;Wait for HBlank
	ldx #$1E
IRQSub07_WaitHBlank:
	dex
	bne IRQSub07_WaitHBlank
	;Get elevator position index
	lda Enemy_Temp2+$0A
	asl
	tay
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address based on elevator position index
	lda Level4ElevatorVRAMAddrTable+1,y
	sta PPU_ADDR
	lda Level4ElevatorVRAMAddrTable,y
	sta PPU_ADDR
	;Set PPU scroll
	lda TempMirror_PPUSCROLL_X
	sta PPU_SCROLL
	lda #$00
	sta PPU_SCROLL
	;Setup next IRQ buffer entry
	jmp IRQSub0C

Level4ElevatorVRAMAddrTable:
	.dw $2080
	.dw $2300
	.dw $2940

;$08: Level 3 boss layer 1
;$11: Level 3 boss layer 1 (boss rush)
IRQSub08:
	;Wait for HBlank
	ldx #$09
IRQSub08_WaitHBlank:
	dex
	bne IRQSub08_WaitHBlank
	;Get boss scroll Y position
	ldy Enemy_Temp3+$02
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	lda #$2A
	sta PPU_ADDR
	stx PPU_ADDR
	;Set PPU scroll
	sty PPU_SCROLL
	stx PPU_SCROLL
	;Load CHR bank
	stx $8000
	lda #$3C
	sta $8001
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$09: Level 3 boss layer 2
IRQSub09:
	;Wait for HBlank
	ldx #$09
IRQSub09_WaitHBlank:
	dex
	bne IRQSub09_WaitHBlank
	;Set PPU address
	ldy #$80
	;Latch PPU status line
	lda PPU_STATUS
	lda #$22
	sta PPU_ADDR
	sty PPU_ADDR
	;Clear PPU scroll
	stx PPU_SCROLL
	stx PPU_SCROLL
	;Load CHR banks
	stx $8000
	lda TempCHRBanks
	sta $8001
	inx
	inx
	stx $8000
	lda #$7F
	sta $8001
	inx
	stx $8000
	sta $8001
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$12: Level 3 boss layer 2 (boss rush)
IRQSub12:
	;Load CHR banks
	ldx #$02
	lda #$7F
	stx $8000
	sta $8001
	inx
	stx $8000
	sta $8001
	;Wait for HBlank
	ldx #$07
IRQSub12_WaitHBlank:
	dex
	bne IRQSub12_WaitHBlank
	;Set PPU address
	ldy #$C0
	;Latch PPU status line
	lda PPU_STATUS
	lda #$22
	sta PPU_ADDR
	sty PPU_ADDR
	;Clear PPU scroll
	stx PPU_SCROLL
	stx PPU_SCROLL
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$0A: Level 3 water BG layer 1
IRQSub0A:
	;Wait for HBlank
	ldx #$01
IRQSub0A_WaitHBlank:
	dex
	bne IRQSub0A_WaitHBlank
	;Check for end of sections
	dec Enemy_Temp2+$0C
	beq IRQSub0A_Next
	;Bugged attempt to latch PPU status line?
	lda PPU_MASK
	;Set PPU scroll based on wave scroll offset data
	ldy Enemy_Temp3+$0C
	lda TempMirror_PPUSCROLL_X
	clc
	adc Level3WaterBGWaveTable,y
	sta PPU_SCROLL
	lda TempMirror_PPUSCROLL_Y
	sta PPU_SCROLL
	;Check for last section
	lda Enemy_Temp2+$0C
	cmp #$01
	bne IRQSub0A_SetHeight1
	;If layer 2 not active, set height of next section $21
	ldy #$21
	lda IRQBufferSub+3
	beq IRQSub0A_SetHeight
	;Set height of next section $12
	ldy #$12
IRQSub0A_SetHeight:
	sty IRQNextHeight
	;Increment wave scroll offset data index
	inc Enemy_Temp3+$0C
	lda Enemy_Temp3+$0C
	and #$0F
	sta Enemy_Temp3+$0C
	;Continue current IRQ buffer entry
	jmp IRQSub0C_NoNext
IRQSub0A_SetHeight1:
	;Set height of next section $01
	lda #$01
	sta IRQNextHeight
	;Increment wave scroll offset data index
	inc Enemy_Temp3+$0C
	lda Enemy_Temp3+$0C
	and #$0F
	sta Enemy_Temp3+$0C
	;Continue current IRQ buffer entry
	jmp IRQSub0C_NoNext
IRQSub0A_Next:
	;Reset section counter
	lda #$08
	sta Enemy_Temp2+$0C
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU scroll
	lda TempMirror_PPUSCROLL_X
	sta PPU_SCROLL
	lda TempMirror_PPUSCROLL_Y
	sta PPU_SCROLL
	;If paused, skip this part
	lda PausedFlag
	bne IRQSub0A_NoIncT
	;If bits 0-3 of global timer not 0, skip this part
	lda GlobalTimer
	and #$07
	bne IRQSub0A_NoIncT
	;Increment start wave scroll offset data index
	inc Enemy_Temp4+$0C
IRQSub0A_NoIncT:
	;Save start wave scroll offset data index
	lda Enemy_Temp4+$0C
	and #$0F
	sta Enemy_Temp3+$0C
	;Setup next IRQ buffer entry
	jmp IRQSub0C

Level3WaterBGWaveTable:
	.db $00,$02,$05,$06,$07,$07,$06,$05,$02
	.db $00,$FE,$FB,$FA,$F9,$F9,$FA,$FB,$FE

;$0B: Level 4 elevator layer 1
IRQSub0B:
	;Wait for HBlank
	ldx #$02
IRQSub0B_WaitHBlank:
	dex
	bne IRQSub0B_WaitHBlank
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	lda #$28
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	;Set PPU scroll
	lda ElevatorScrollX
	sta PPU_SCROLL
	lda #$00
	sta PPU_SCROLL
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$0D: Level 4 crane
IRQSub0D:
	;Wait for HBlank
	ldx #$07
IRQSub0D_WaitHBlank:
	dex
	bne IRQSub0D_WaitHBlank
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU scroll
	lda TempMirror_PPUSCROLL_X
	sta PPU_SCROLL
	lda TempMirror_PPUSCROLL_Y
	sta PPU_SCROLL
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$0E: Level 4 boss crane
IRQSub0E:
	;Wait for HBlank
	ldx #$0B
IRQSub0E_WaitHBlank:
	dex
	bne IRQSub0E_WaitHBlank
	;Set PPU address
	ldy #$23
	;Latch PPU status line
	lda PPU_STATUS
	sty PPU_ADDR
	stx PPU_ADDR
	;Clear PPU scroll
	stx PPU_SCROLL
	stx PPU_SCROLL
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$0F: Level 6 ceiling crusher
IRQSub0F:
	;Wait for HBlank
	ldx #$20
IRQSub0F_WaitHBlank:
	dex
	bne IRQSub0F_WaitHBlank
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	ldx #$60
	lda #$2A
	sta PPU_ADDR
	stx PPU_ADDR
	;Set PPU scroll
	lda TempMirror_PPUSCROLL_X
	sta PPU_SCROLL
	lda TempMirror_PPUSCROLL_Y
	sta PPU_SCROLL
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$10: Level 6 elevator
IRQSub10:
	;Wait for HBlank
	ldx #$1E
IRQSub10_WaitHBlank:
	dex
	bne IRQSub10_WaitHBlank
	;Get elevator position index
	lda Enemy_Temp2+$09
	asl
	tay
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address based on elevator position index
	lda Level6ElevatorVRAMAddrTable+1,y
	sta PPU_ADDR
	lda Level6ElevatorVRAMAddrTable,y
	sta PPU_ADDR
	;Set PPU scroll
	lda TempMirror_PPUSCROLL_X
	sta PPU_SCROLL
	lda #$00
	sta PPU_SCROLL
	;Setup next IRQ buffer entry
	jmp IRQSub0C

Level6ElevatorVRAMAddrTable:
	.dw $2080
	.dw $2940
	.dw $2300

;$13: TV face wave
IRQSub13:
	;Wait for HBlank
	ldx #$02
IRQSub13_WaitHBlank1:
	dex
	bne IRQSub13_WaitHBlank1
	;Check for first section
	lda TVFaceWaveCounter
	cmp #$32
	bne IRQSub13_NoFirst
	nop
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	ldx #$A0
	lda #$21
	sta PPU_ADDR
	stx PPU_ADDR
	;Clear PPU scroll
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL
	;Check for end of sections
	dec TVFaceWaveCounter
	bne IRQSub13_SetHeight1
IRQSub13_NoFirst:
	;Check for end of sections
	dec TVFaceWaveCounter
	beq IRQSub13_Next
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU scroll based on wave scroll offset data
	ldy TVFaceWaveOffset
	lda TempMirror_PPUSCROLL_X
	clc
	adc TVFaceWaveXBuffer,y
	sta PPU_SCROLL
	lda TempMirror_PPUSCROLL_Y
	sta PPU_SCROLL
	;Check for last section
	lda TVFaceWaveCounter
	cmp #$01
	bne IRQSub13_SetHeight1
	;Set height of next section $3E
	lda #$3E
	bne IRQSub13_SetHeight
IRQSub13_SetHeight1:
	;Set height of next section $01
	lda #$01
IRQSub13_SetHeight:
	sta IRQNextHeight
	;Increment wave scroll offset data index
	inc TVFaceWaveOffset
	lda TVFaceWaveOffset
	cmp #$18
	bcc IRQSub13_NoC
	lda #$00
	sta TVFaceWaveOffset
IRQSub13_NoC:
	;Continue current IRQ buffer entry
	jmp IRQSub0C_NoNext
IRQSub13_Next:
	ldx #$19
IRQSub13_WaitHBlank2:
	dex
	bpl IRQSub13_WaitHBlank2
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	ldx #$00
	lda #$2A
	sta PPU_ADDR
	stx PPU_ADDR
	;Clear PPU scroll
	stx PPU_SCROLL
	stx PPU_SCROLL
	lda #$A8
	sta PPU_CTRL
	;Reset section counter
	lda #$32
	sta TVFaceWaveCounter
	;Save start wave scroll offset data index
	lda TempTVFaceWaveOffset
	sta TVFaceWaveOffset
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;$14: TV normal
IRQSub14:
	;Wait for HBlank
	ldx #$01
IRQSub14_WaitHBlank:
	dex
	bne IRQSub14_WaitHBlank
	;Load CHR bank
	ldx #$01
	stx $8000
	lda #$7E
	sta $8001
	;Setup next IRQ buffer entry
	jmp IRQSub0C

;;;;;;;;;;;;;;;;;;;;
;SCROLLING ROUTINES;
;;;;;;;;;;;;;;;;;;;;
UpdateLevelCollision_Horiz_Clear:
	;Clear collision buffer column
	jmp ClearCollisionBufferCol
UpdateLevelCollision_Horiz:
	;Get scroll seam Y collision position
	lda #$13
	sta $00
	lda ScrollYCollPosHi
	sec
	sbc #$03
	bcs UpdateLevelCollision_Horiz_NoYCollC
	adc #$14
UpdateLevelCollision_Horiz_NoYCollC:
	sta $02
	;Check if scrolling left or right
	lda ScrollXDirection
	bne UpdateLevelCollision_Horiz_Right
	;Get scroll seam X collision position for left edge of screen
	lda ScrollXCollPosHi
	sec
	sbc #$04
	bcs UpdateLevelCollision_Horiz_LeftNoXC
	adc #$19
UpdateLevelCollision_Horiz_LeftNoXC:
	sta $01
	;Get scroll seam X tile position for left edge of screen
	lda TempMirror_PPUSCROLL_X
	sec
	sbc #$40
	sta ScrollSeamXTile
	lda CurScreenX
	sbc #$00
	;Check for left level bounds
	bmi UpdateLevelCollision_Horiz_Clear
	sta ScrollSeamXScreen
	bpl UpdateLevelCollision_Horiz_XC
UpdateLevelCollision_Horiz_Right:
	;Get scroll seam X collision position for right edge of screen
	lda ScrollXCollPosHi
	sec
	sbc #$05
	bcs UpdateLevelCollision_Horiz_RightNoXC
	adc #$19
UpdateLevelCollision_Horiz_RightNoXC:
	sta $01
	;Get scroll seam X tile position for right edge of screen
	lda TempMirror_PPUSCROLL_X
	clc
	adc #$40
	sta ScrollSeamXTile
	lda CurScreenX
	adc #$01
	;Check for right level bounds
	cmp LevelAreaWidth
	bcs UpdateLevelCollision_Horiz_Clear
	sta ScrollSeamXScreen
UpdateLevelCollision_Horiz_XC:
	;Get level tile collision range data pointer
	lda LevelAreaNum
	asl
	tay
	lda LevelTileCollRangePointerTable,y
	sta $18
	lda LevelTileCollRangePointerTable+1,y
	sta $19
	;Get scroll seam Y tile position
	lda TempMirror_PPUSCROLL_Y
	sec
	sbc #$30
	bcs UpdateLevelCollision_Horiz_NoYTileC
	sbc #$0F
	clc
UpdateLevelCollision_Horiz_NoYTileC:
	sta ScrollSeamYTile
	lda CurScreenY
	sbc #$00
	sta ScrollSeamYScreen
	lsr ScrollSeamXTile
	lsr ScrollSeamXTile
	lsr ScrollSeamXTile
	lsr ScrollSeamYTile
	lsr ScrollSeamYTile
	lsr ScrollSeamYTile
	lsr ScrollSeamYTile
	;Get collision buffer pointer
	jsr GetCollisionBufferPointer
	;Get collision tile mask
	jsr GetCollisionTileMask
	;Check for top level bounds
	lda #$00
	sta $1A
	ldy ScrollSeamYScreen
	bpl UpdateLevelCollision_Horiz_NoBoundT
UpdateLevelCollision_Horiz_SetBound:
	;Set level bounds flag
	inc $1A
	;Clear collision tile
	lda #$00
	beq UpdateLevelCollision_Horiz_SetTile
UpdateLevelCollision_Horiz_NoBoundT:
	;Get level BG data pointers
	jsr GetLevelBGPointers
	;Check for out-of-bounds screen
	ldy $15
	lda ($0B),y
	cmp #$80
	beq UpdateLevelCollision_Horiz_SetBound
	;Check for bottom screen
	and #$40
	sta $1B
	;Get level metatile data offset
	jsr GetLevelMetatileOffset
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	;Get upper-left 8x8 tile of 16x16 block
	lda ScrollSeamXTile
	and #$02
	tay
	lda ScrollSeamYTile
	lsr
	bcc UpdateLevelCollision_Horiz_TopTile
	tya
	ora #$08
	tay
UpdateLevelCollision_Horiz_TopTile:
	sty $14
UpdateLevelCollision_Horiz_GetTile:
	;Get collision type
	ldy $14
	lda ($0E),y
	jsr TileToCollisionType
UpdateLevelCollision_Horiz_SetTile:
	;Draw collision tile
	jsr DrawCollisionTile
	;Loop for each collision tile
	dec $00
	bmi UpdateLevelCollision_Horiz_Exit
	;Go to next row
	inc $02
	;Check for collision buffer overflow
	lda $02
	cmp #$14
	bcc UpdateLevelCollision_Horiz_NoYCollC2
	lda #$00
	sta $02
UpdateLevelCollision_Horiz_NoYCollC2:
	;Get collision buffer pointer
	jsr GetCollisionBufferPointer
	;Get collision tile mask
	jsr GetCollisionTileMask
	;Go to next row in screen BG data
	inc ScrollSeamYTile
	lda ScrollSeamYTile
	;Check for level bounds
	ldy $1A
	bne UpdateLevelCollision_Horiz_NoBottom
	;Check for bottom screen
	ldy $1B
	beq UpdateLevelCollision_Horiz_NoBottom
	;Check for nametable overflow
	cmp #$0C
	bcs ClearCollisionBufferCol
	bcc UpdateLevelCollision_Horiz_NoScreenC
UpdateLevelCollision_Horiz_NoBottom:
	cmp #$0F
	bcc UpdateLevelCollision_Horiz_NoScreenC
	;Setup scroll seam Y position for new nametable
	lda #$00
	sta ScrollSeamYTile
	inc ScrollSeamYScreen
	jmp UpdateLevelCollision_Horiz_ScreenC
UpdateLevelCollision_Horiz_Exit:
	rts
UpdateLevelCollision_Horiz_NoScreenC:
	;Check for level bounds
	lda $1A
	beq UpdateLevelCollision_Horiz_NoBoundScreen
	;Clear collision tile
	lda #$00
	beq UpdateLevelCollision_Horiz_SetTile
UpdateLevelCollision_Horiz_NoBoundScreen:
	;Go to next row
	lda $14
	cmp #$08
	bcs UpdateLevelCollision_Horiz_TopTile2
	ora #$08
	sta $14
	bne UpdateLevelCollision_Horiz_GetTile
UpdateLevelCollision_Horiz_TopTile2:
	and #$06
	sta $14
	lda $0D
	clc
	adc #$08
	sta $0D
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	jmp UpdateLevelCollision_Horiz_GetTile
UpdateLevelCollision_Horiz_ScreenC:
	;Clear level bounds flag
	lda #$00
	sta $1A
	;Get level BG data pointers
	jsr GetLevelBGPointers
	;Check for out-of-bounds screen
	ldy $15
	lda ($0B),y
	cmp #$80
	beq UpdateLevelCollision_Horiz_SetBound2
	;Check for bottom screen
	and #$40
	sta $1B
	;Get level metatile data offset
	jsr GetLevelMetatileOffset
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	;Get upper-left 8x8 tile of 16x16 block
	lda ScrollSeamXTile
	and #$02
	tay
	jmp UpdateLevelCollision_Horiz_TopTile
UpdateLevelCollision_Horiz_SetBound2:
	;Check for nametable overflow
	lda $01
	cmp #$0F
	bcc ClearCollisionBufferCol
	;Set level bounds flag
	inc $1A
	;Clear collision tile
	lda #$00
	jmp UpdateLevelCollision_Horiz_SetTile

ClearCollisionBufferCol:
	;Get collision buffer pointer
	jsr GetCollisionBufferPointer
	;Get collision tile mask
	lda #$0F
	ldx $03
	beq ClearCollisionBufferCol_MaskLo
	lda #$F0
ClearCollisionBufferCol_MaskLo:
	;Clear collision buffer bits
	and CollisionBuffer,y
	sta CollisionBuffer,y
	;Loop for each collision tile
	dec $00
	bmi ClearCollisionBufferCol_Exit
	;Increment collision tile Y position
	inc $02
	lda $02
	cmp #$14
	bcc ClearCollisionBufferCol
	lda #$00
	sta $02
	beq ClearCollisionBufferCol
ClearCollisionBufferCol_Exit:
	rts

TileToCollisionType:
	;Set collision type based on tile range
	ldy #$00
TileToCollisionType_Loop:
	;Check for tile range
	cmp ($18),y
	bcc TileToCollisionType_Set
	;Loop for each range
	iny
	bne TileToCollisionType_Loop
TileToCollisionType_Set:
	;Set collision type
	lda CollTypeTable,y
	rts

DrawCollisionTile:
	;Draw collision tile
	and $11
	sta $13
	ldy $10
	lda CollisionBuffer,y
	and $12
	ora $13
	sta CollisionBuffer,y
	rts

GetCollisionTileMask:
	;Get collision tile mask
	ldy $03
	lda CollMaskTable,y
	sta $11
	eor #$FF
	sta $12
	rts

CollMaskTable:
	.db $F0,$0F

GetCollisionBufferPointer:
	;Get collision tile offset and mask
	lda #$00
	sta $03
	lda $01
	lsr
	bcc GetCollisionBufferPointer_NoXC
	inc $03
GetCollisionBufferPointer_NoXC:
	sta $04
	lda $02
	lsr
	bcc GetCollisionBufferPointer_NoYC
	lda $03
	beq GetCollisionBufferPointer_NoC
	inc $04
GetCollisionBufferPointer_NoC:
	eor #$01
	sta $03
GetCollisionBufferPointer_NoYC:
	ldy $02
	lda $04
	clc
	adc CollBufferRowOffset,y
	sta $10
	tay
	rts

CollBufferRowOffset:
	.db $00,$0C,$19,$25,$32,$3E,$4B,$57,$64,$70,$7D,$89,$96,$A2,$AF,$BB
	.db $C8,$D4,$E1,$ED
LevelTileCollRangePointerTable:
	.dw Level11TileCollRangeData
	.dw Level12TileCollRangeData
	.dw Level12TileCollRangeData
	.dw Level21TileCollRangeData
	.dw Level22TileCollRangeData
	.dw Level21TileCollRangeData
	.dw Level31TileCollRangeData
	.dw Level32TileCollRangeData
	.dw Level32TileCollRangeData
	.dw Level41TileCollRangeData
	.dw Level42TileCollRangeData
	.dw Level43TileCollRangeData
	.dw Level51TileCollRangeData
	.dw Level52TileCollRangeData
	.dw Level52TileCollRangeData
	.dw Level61TileCollRangeData
	.dw Level61TileCollRangeData
	.dw Level63TileCollRangeData
CollTypeTable:
	.db $00,$11,$22,$33,$44,$55,$66,$77,$88,$99,$AA,$BB,$CC,$DD,$EE,$FF

UpdateLevelCollision_Vert_Clear:
	;Clear collision buffer row
	jmp ClearCollisionBufferRow
UpdateLevelCollision_Vert:
	;Get scroll seam X collision position
	lda #$18
	sta $00
	lda ScrollXCollPosHi
	sec
	sbc #$04
	bcs UpdateLevelCollision_Vert_NoXCollC
	adc #$19
UpdateLevelCollision_Vert_NoXCollC:
	sta $01
	;Check if scrolling up or down
	lda ScrollYDirection
	bne UpdateLevelCollision_Vert_Down
	;Get scroll seam Y collision position for top edge of screen
	lda ScrollYCollPosHi
	sec
	sbc #$03
	bcs UpdateLevelCollision_Vert_UpNoYCollC
	adc #$14
UpdateLevelCollision_Vert_UpNoYCollC:
	sta $02
	;Get scroll seam Y tile position for top edge of screen
	lda TempMirror_PPUSCROLL_Y
	sec
	sbc #$30
	bcs UpdateLevelCollision_Vert_UpNoYTileC
	sbc #$0F
	clc
UpdateLevelCollision_Vert_UpNoYTileC:
	sta ScrollSeamYTile
	lda CurScreenY
	sbc #$00
	;Check for top level bounds
	bmi UpdateLevelCollision_Vert_Clear
	sta ScrollSeamYScreen
	bpl UpdateLevelCollision_Vert_YC
UpdateLevelCollision_Vert_Down:
	;Get scroll seam Y collision position for bottom edge of screen
	lda ScrollYCollPosHi
	sec
	sbc #$04
	bcs UpdateLevelCollision_Vert_DownNoYCollC
	adc #$14
UpdateLevelCollision_Vert_DownNoYCollC:
	sta $02
	;Get scroll seam Y tile position for bottom edge of screen
	lda TempMirror_PPUSCROLL_Y
	clc
	adc #$10
	bcs UpdateLevelCollision_Vert_DownNoYTileC
	cmp #$F0
	bcc UpdateLevelCollision_Vert_DownSetYTile
UpdateLevelCollision_Vert_DownNoYTileC:
	adc #$0F
	sec
UpdateLevelCollision_Vert_DownSetYTile:
	sta ScrollSeamYTile
	lda CurScreenY
	adc #$01
	;Check for bottom level bounds
	cmp LevelAreaHeight
	bcs UpdateLevelCollision_Vert_Clear
	sta ScrollSeamYScreen
UpdateLevelCollision_Vert_YC:
	;Get level tile collision range data pointer
	lda LevelAreaNum
	asl
	tay
	lda LevelTileCollRangePointerTable,y
	sta $18
	lda LevelTileCollRangePointerTable+1,y
	sta $19
	;Get scroll seam X tile position
	lda TempMirror_PPUSCROLL_X
	sec
	sbc #$40
	sta ScrollSeamXTile
	lda CurScreenX
	sbc #$00
	sta ScrollSeamXScreen
	lsr ScrollSeamXTile
	lsr ScrollSeamXTile
	lsr ScrollSeamXTile
	lda ScrollSeamXTile
	and #$FE
	sta ScrollSeamXTile
	lsr ScrollSeamYTile
	lsr ScrollSeamYTile
	lsr ScrollSeamYTile
	lsr ScrollSeamYTile
	;Get collision buffer pointer
	jsr GetCollisionBufferPointer
	;Get collision tile mask
	jsr GetCollisionTileMask
	;Check for left level bounds
	lda #$00
	sta $1A
	ldy ScrollSeamXScreen
	bpl UpdateLevelCollision_Vert_NoBoundL
UpdateLevelCollision_Vert_SetBound:
	;Set level bounds flag
	inc $1A
	;Clear collision tile
	lda #$00
	beq UpdateLevelCollision_Vert_SetTile
UpdateLevelCollision_Vert_NoBoundL:
	;Get level BG data pointers
	jsr GetLevelBGPointers
	;Check for out-of-bounds screen
	ldy $15
	lda ($0B),y
	cmp #$80
	beq UpdateLevelCollision_Vert_SetBound
	;Check for bottom screen
	and #$40
	beq UpdateLevelCollision_Vert_NoBottom
	;Check for out-of-bounds part of bottom screen
	lda ScrollSeamYTile
	cmp #$0C
	bcs UpdateLevelCollision_Vert_SetBound
UpdateLevelCollision_Vert_NoBottom:
	;Get level metatile data offset
	jsr GetLevelMetatileOffset
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	;Get upper-left 8x8 tile of 16x16 block
	lda ScrollSeamXTile
	and #$02
	tay
UpdateLevelCollision_Vert_CheckTopTile:
	lda ScrollSeamYTile
	lsr
	bcc UpdateLevelCollision_Vert_TopTile
	tya
	ora #$08
	tay
UpdateLevelCollision_Vert_TopTile:
	sty $14
UpdateLevelCollision_Vert_GetTile:
	;Get collision type
	ldy $14
	lda ($0E),y
	jsr TileToCollisionType
UpdateLevelCollision_Vert_SetTile:
	;Draw collision tile
	jsr DrawCollisionTile
	;Loop for each collision tile
	dec $00
	bmi UpdateLevelCollision_Vert_Exit
	;Go to next column
	inc $01
	;Check for collision buffer overflow
	lda $01
	cmp #$19
	bcs UpdateLevelCollision_Vert_NoXCollC2
	;Toggle collision tile mask
	lda $03
	eor #$01
	sta $03
	bne UpdateLevelCollision_Vert_GetMask
	inc $10
	bne UpdateLevelCollision_Vert_GetMask
UpdateLevelCollision_Vert_NoXCollC2:
	lda #$00
	sta $01
	;Get collision buffer pointer
	jsr GetCollisionBufferPointer
UpdateLevelCollision_Vert_GetMask:
	;Get collision tile mask
	jsr GetCollisionTileMask
	;Go to next column in screen BG data
	inc ScrollSeamXTile
	inc ScrollSeamXTile
	;Check for nametable overflow
	lda ScrollSeamXTile
	cmp #$20
	bcc UpdateLevelCollision_Vert_NoScreenC
	lda #$00
	sta ScrollSeamXTile
	inc ScrollSeamXScreen
	;Check for right screen
	lda ScrollSeamXScreen
	cmp LevelAreaWidth
	bcs ClearCollisionBufferRow
	bcc UpdateLevelCollision_Vert_NoRight
UpdateLevelCollision_Vert_NoScreenC:
	;Check for level bounds
	lda $1A
	bne UpdateLevelCollision_Vert_SetBound3
	;Go to next column
	lda $14
	and #$02
	bne UpdateLevelCollision_Vert_RightTile
	lda $14
	ora #$02
	sta $14
	bne UpdateLevelCollision_Vert_GetTile
UpdateLevelCollision_Vert_RightTile:
	inc $0D
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	lda $14
	and #$F8
	sta $14
	jmp UpdateLevelCollision_Vert_GetTile
UpdateLevelCollision_Vert_NoRight:
	;Clear level bounds flag
	lda #$00
	sta $1A
	;Get level BG data pointers
	jsr GetLevelBGPointers
	;Check for out-of-bounds screen
	ldy $15
	lda ($0B),y
	cmp #$80
	beq UpdateLevelCollision_Vert_SetBound2
	;Check for bottom screen
	and #$40
	beq UpdateLevelCollision_Vert_NoBottom2
	;Check for out-of-bounds part of bottom screen
	lda ScrollSeamYTile
	cmp #$0C
	bcs UpdateLevelCollision_Vert_SetBound2
UpdateLevelCollision_Vert_NoBottom2:
	;Get level metatile data offset
	jsr GetLevelMetatileOffset
	;Get level metatile data pointer
	jsr GetLevelMetatilePointer
	;Get upper-left 8x8 tile of 16x16 block
	ldy #$00
	jmp UpdateLevelCollision_Vert_CheckTopTile
UpdateLevelCollision_Vert_Exit:
	rts
UpdateLevelCollision_Vert_SetBound2:
	;Check for nametable overflow
	lda $00
	cmp #$10
	bcc ClearCollisionBufferRow
UpdateLevelCollision_Vert_SetBound3:
	;Set level bounds flag
	inc $1A
	;Clear collision tile
	lda #$00
	jmp UpdateLevelCollision_Vert_SetTile

ClearCollisionBufferRow:
	;Get collision buffer pointer
	jsr GetCollisionBufferPointer
	;Get collision tile mask
	ldx #$0F
	lda $03
	beq ClearCollisionBufferRow_MaskLo
	ldx #$F0
ClearCollisionBufferRow_MaskLo:
	stx $17
ClearCollisionBufferRow_Loop:
	;Clear collision buffer bits
	lda CollisionBuffer,y
	and $17
	sta CollisionBuffer,y
	;Loop for each collision tile
	dec $00
	bmi ClearCollisionBufferRow_Exit
	;Increment collision tile X position
	inc $01
	lda $01
	cmp #$19
	bcs ClearCollisionBufferRow_NoXC
	;Toggle collision tile mask
	lda $17
	eor #$FF
	sta $17
	lda $03
	eor #$01
	sta $03
	bne ClearCollisionBufferRow_Loop
	iny
	bne ClearCollisionBufferRow_Loop
ClearCollisionBufferRow_NoXC:
	lda #$00
	sta $01
	beq ClearCollisionBufferRow
ClearCollisionBufferRow_Exit:
	rts

GetCollisionType:
	;Get collision buffer offset based on X scroll position
	lda TempMirror_PPUSCROLL_X
	and #$0F
	clc
	adc $08
	ror
	lsr
	lsr
	lsr
	;Check for X offset >= 0
	ldy $09
	beq GetCollisionType_Right
	;Check for X offset < 0
	cpy #$FF
	beq GetCollisionType_Left
	;Handle large X offset
	adc #$10
	bne GetCollisionType_Right
GetCollisionType_Left:
	;Handle X offset < 0
	and #$0F
	bne GetCollisionType_NoXC
	lda ScrollXCollPosHi
	jmp GetCollisionType_SetX
GetCollisionType_NoXC:
	ora #$F0
	clc
	adc ScrollXCollPosHi
	bpl GetCollisionType_SetX
	adc #$19
	bcs GetCollisionType_SetX
GetCollisionType_Right:
	;Handle X offset >= 0
	clc
	adc ScrollXCollPosHi
	cmp #$19
	bcc GetCollisionType_SetX
	sbc #$19
GetCollisionType_SetX:
	sta $01
	;Get collision buffer offset based on Y scroll position
	lda TempMirror_PPUSCROLL_Y
	and #$0F
	clc
	adc $0A
	lsr
	lsr
	lsr
	lsr
	;Check for Y offset >= 0
	ldy $0B
	beq GetCollisionType_Down
	;Check for Y offset < 0
	cpy #$FF
	beq GetCollisionType_Up
	;Handle large Y offset
	adc #$0F
	bne GetCollisionType_Down
GetCollisionType_Up:
	;Handle Y offset < 0
	sbc #$0F
	clc
	adc ScrollYCollPosHi
	bpl GetCollisionType_SetY
	adc #$14
	bcs GetCollisionType_SetY
GetCollisionType_Down:
	;Handle Y offset >= 0
	clc
	adc ScrollYCollPosHi
	cmp #$14
	bcc GetCollisionType_SetY
	sbc #$14
GetCollisionType_SetY:
	sta $02
	;Get collision buffer pointer
	jsr GetCollisionBufferPointer
	;Get collision buffer bits
	lda CollisionBuffer,y
	ldy $03
	bne GetCollisionType_MaskLo
	lsr
	lsr
	lsr
	lsr
GetCollisionType_MaskLo:
	and #$0F
	;Get collision type based on current level area
	ldy LevelAreaNum
	ora LevelSlopeShapeSetOffset,y
	tay
	lda SlopeShapeSetData,y
	rts

LevelSlopeShapeSetOffset:
	.db $00,$00,$00
	.db $00,$00,$00
	.db $10,$00,$00
	.db $20,$00,$00
	.db $20,$20,$20
	.db $20,$20,$00
SlopeShapeSetData:
	.db $00,$02,$03,$04,$05,$06,$07,$08,$13,$14,$16,$16,$16,$16,$16,$16
	.db $00,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$13,$14,$16,$16,$16,$16,$16
	.db $00,$02,$03,$04,$05,$06,$07,$08,$11,$13,$14,$16,$1B,$1B,$1B,$1B
	.db $00,$03,$04,$05,$06,$07,$08,$08,$08,$13,$14,$16,$16,$16,$16,$16
Level11TileCollRangeData:
	.db $CC,$CC,$CD,$CE,$CF,$D0,$D1,$D2,$D6,$FF,$FF,$FF,$FF,$FF,$FF,$FF
Level12TileCollRangeData:
	.db $AE,$BA,$BA,$BC,$BC,$BC,$BE,$C0,$C5,$D6,$FF,$FF,$FF,$FF,$FF,$FF
Level21TileCollRangeData:
	.db $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0,$F0,$FF,$FF,$FF,$FF,$FF,$FF
Level22TileCollRangeData:
	.db $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$FF,$FF,$FF,$FF,$FF,$FF,$FF
Level31TileCollRangeData:
	.db $C0,$C1,$C5,$C9,$D1,$D6,$DB,$E1,$E6,$F4,$FF,$FF,$FF,$FF,$FF,$FF
Level32TileCollRangeData:
	.db $BE,$BE,$BE,$BE,$BE,$BE,$BE,$BE,$BE,$BE,$FF,$FF,$FF,$FF,$FF,$FF
Level41TileCollRangeData:
	.db $70,$70,$72,$74,$74,$74,$74,$74,$75,$77,$C4,$DC,$FF,$FF,$FF,$FF
Level42TileCollRangeData:
	.db $50,$50,$50,$50,$53,$55,$58,$5C,$60,$66,$FF,$FF,$FF,$FF,$FF,$FF
Level43TileCollRangeData:
	.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
Level51TileCollRangeData:
	.db $C0,$C0,$C2,$C3,$C4,$C6,$C7,$C9,$C9,$D2,$DB,$F0,$FF,$FF,$FF,$FF
Level52TileCollRangeData:
	.db $E0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$FF,$FF,$FF,$FF,$FF,$FF
Level61TileCollRangeData:
	.db $96,$96,$96,$96,$97,$98,$99,$9B,$9B,$A0,$A0,$FF,$FF,$FF,$FF,$FF
Level63TileCollRangeData:
	.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

;;;;;;;;;;;;;;;;;;;;
;GAME MODE ROUTINES;
;;;;;;;;;;;;;;;;;;;;
RunGameMode:
	;Increment global timer
	inc GlobalTimer
	;Load PRG bank based on game mode
	ldx GameMode
	lda GameModeBankTable,x
	beq RunGameMode_NoBank
	jsr LoadPRGBank
RunGameMode_NoBank:
	;Do jump table
	txa
	jsr DoJumpTable
GameModeJumpTable:
	.dw RunGameMode_Legal		;$00  Legal
	.dw RunGameMode_Title		;$01  Title
	.dw RunGameMode_Demo		;$02  Demo
	.dw RunGameMode_Select		;$03  Select
	.dw RunGameMode_Intro		;$04  Intro
	.dw RunGameMode_LevelStart	;$05  Level start
	.dw RunGameMode_MainGame	;$06  Main game
	.dw RunGameMode_StageClear	;$07  Stage clear
	.dw RunGameMode_GameOver	;$08  Game over
	.dw RunGameMode_Ending		;$09  Ending
	.dw RunGameMode_SoundTest	;$0A  Sound test
GameModeBankTable:
	.db $32,$32,$32,$3A,$34,$36,$00,$3A,$32,$34,$32

;DEMO MODE ROUTINES
RunGameMode_Demo:
	;Check if already inited
	lda GameSubmode
	bne RunGameMode_Demo_Main
	;Mark inited
	inc GameSubmode
	;Clear ZP $40-$CF and set demo flag
	jsr ClearZP_Demo
	;Set timer
	lda #$00
	ldy #$05
	jmp SetModeTimer_Any
RunGameMode_Demo_Main:
	;Check for SELECT/START press
	lda JoypadDown
	and #(JOY_SELECT|JOY_START)
	bne RunGameMode_Demo_End
	;Check for end of demo
	lda DemoEndFlag
	bne RunGameMode_Demo_EndDemo
	jsr DecrementModeTimer
	beq RunGameMode_Demo_EndDemo
	;Update demo input
	jmp UpdateDemoInput
RunGameMode_Demo_EndDemo:
	;Disable IRQ
	inc GameSubmode
	lda #$00
	sta TempIRQEnableFlag
RunGameMode_Demo_End:
	;Disable IRQ
	lda #$00
	sta TempIRQEnableFlag
	;Clear sound
	jsr ClearSound
	;Clear nametable
	jsr ClearNametableData
	;Next mode ($01: Title)
	lda #$01
	jmp SetGameMode
RunGameMode_Demo_Exit:
	rts

;GAME OVER MODE ROUTINES
RunGameMode_GameOver:
	;Do jump table
	lda GameSubmode
	jsr DoJumpTable
GameOverJumpTable:
	.dw RunGameSubmode_GameOverFadeOut	;$00  Fade out
	.dw RunGameSubmode_GameOverInit		;$01  Init
	.dw RunGameSubmode_GameOverMenuIn	;$02  Menu fade in
	.dw RunGameSubmode_GameOverMenu		;$03  Menu
	.dw RunGameSubmode_GameOverWait		;$04  Wait
	.dw RunGameSubmode_GameOverMenuOut	;$05  Menu fade out
	.dw RunGameSubmode_GameOverNoContinues	;$06  No continues

ClearScreen:
	;Clear scroll position
	sta TempMirror_PPUSCROLL_X
	sta TempMirror_PPUSCROLL_Y
	lda TempMirror_PPUCTRL
	and #$FC
	sta TempMirror_PPUCTRL
	;Clear screen enemies
	jsr ClearEnemies_Screen
	;Next submode
	inc GameSubmode
	;Set fade direction
	lda #$00
	sta FadeInitFlag
	sta FadeDirection
	;Clear nametable
	jsr ClearNametableData
	;Clear enemy sprites
	ldx #$20
	lda #$00
ClearScreen_Loop:
	sta Enemy_Sprite,x
	dex
	bpl ClearScreen_Loop
	;Clear sound
	jmp ClearSound

;$00: Fade out
RunGameSubmode_GameOverFadeOut:
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_GameOverFadeOut_Exit
	;Clear scroll flags
	lda #$00
	sta AutoScrollDirFlags
	sta TempScrollLockFlags
	;Next submode ($01: Init)
	inc GameSubmode
	;Clear IRQ buffer
	jmp ClearIRQBuffer
RunGameSubmode_GameOverFadeOut_Exit:
	rts

;$01: Init
RunGameSubmode_GameOverInit:
	;Load PRG bank $36 (clear player bank)
	lda #$36
	jsr LoadPRGBank
	;Clear both players
	ldx #$00
	jsr ClearPlayer
	ldx #$01
	jsr ClearPlayer
	;Clear screen
	jsr ClearScreen
	;Write game over nametable
	ldx #$14
	jsr WriteNametableData
	;Set palette
	lda #$2E
	sta CurPalette
	;Play music
	lda #MUSIC_GAMEOVER
	jsr LoadSound
	;Draw top score
	lda #$21
	sta $0B
	lda TopScoreLo
	sta $0C
	lda TopScoreMid
	sta $0D
	lda TopScoreHi
	sta $0E
	lda #$D0
	sta $0F
	lda #$72
	jsr DrawDecimalValue
	;Set timer
	lda #$40
	sta GameModeTimer2
	;Load CHR bankds
	lda #$7C
	sta TempCHRBanks
	lda #$7A
	sta TempCHRBanks+1
	lda #$74
	sta TempCHRBanks+2
	;Write VRAM strip ("HI SCORE" text)
	lda #$0B
	jmp WriteVRAMStrip

;$02: Menu fade in
RunGameSubmode_GameOverMenuIn:
	;Fade palette
	jsr FadePalette
	;Increment timer, check if 0
	inc GameModeTimer2
	bne RunGameSubmode_GameOverMenuIn_Exit
	;Check for no continues left
	lda NumContinues
	bne RunGameSubmode_GameOverMenuIn_Continue
	;Next submode ($06: No continues)
	lda #$06
	sta GameSubmode
	;Set timer
	lda #$E8
	sta GameModeTimer
	rts
RunGameSubmode_GameOverMenuIn_Continue:
	;Next submode ($03: Menu)
	inc GameSubmode
	;Draw continues
	jsr DrawGameOverContinues
	;Write VRAM strip ("CONTINUE" text)
	lda #$0C
	jsr WriteVRAMStrip
	;Write VRAM strip ("END" text)
	lda #$0D
	jmp WriteVRAMStrip
RunGameSubmode_GameOverMenuIn_Exit:
	rts

DrawGameOverContinues:
	;Get continues digit tile
	lda NumContinues
	ora #$D0
	sta $10
DrawGameOverContinues_Clear:
	;Init VRAM buffer row
	lda #$01
	jsr WriteVRAMBufferCmd
	;Set VRAM buffer address
	lda #$16
	jsr WriteVRAMBufferCmd_AnyX
	lda #$22
	jsr WriteVRAMBufferCmd_AnyX
	;Set continues digit tile in VRAM
	lda $10
	jsr WriteVRAMBufferCmd_AnyX
	;End VRAM buffer
	jmp WriteVRAMBufferCmd_End

;$03: Menu
RunGameSubmode_GameOverMenu:
	;Check for SELECT press
	lda JoypadDown
	and #JOY_SELECT
	beq RunGameSubmode_GameOverMenu_NoSelect
	;Play sound
	lda #SE_CURSMOVE
	jsr LoadSound
	;Toggle cursor position
	lda GameModeTimer2
	eor #$01
	sta GameModeTimer2
RunGameSubmode_GameOverMenu_NoSelect:
	;Set enemy position based on cursor position
	ldy GameModeTimer2
	lda #$48
	sta Enemy_X
	lda GameOverCursorY,y
	sta Enemy_Y
	;Set enemy sprite
	lda #$02
	sta Enemy_Sprite
	;Check for START press
	lda JoypadDown
	and #JOY_START
	beq RunGameSubmode_GameOverMenu_Exit
	;Check for continue option
	lda GameModeTimer2
	bne RunGameSubmode_GameOverMenu_NoContinue
	;Decrement number of continues
	dec NumContinues
	;Draw continues
	jsr DrawGameOverContinues
RunGameSubmode_GameOverMenu_NoContinue:
	;Play sound
	lda #SE_SELECT
	jsr LoadSound
	;Set timer
	lda #$40
	sta GameModeTimer
	;Next submode ($04: Wait)
	inc GameSubmode
RunGameSubmode_GameOverMenu_Exit:
	rts

GameOverCursorY:
	.db $83,$9B

;$04: Wait
RunGameSubmode_GameOverWait:
	;Flash continues
	jsr FlashGameOverContinues
	;Decrement timer, check if 0
	dec GameModeTimer
	bne RunGameSubmode_GameOverWait_Exit
	;Next submode ($05: Menu fade out)
	inc GameSubmode
RunGameSubmode_GameOverWait_Exit:
	rts

;$05: Menu fade out
RunGameSubmode_GameOverMenuOut:
	;Flash continues
	jsr FlashGameOverContinues
	;Decrement timer
	dec GameModeTimer
RunGameSubmode_GameOverMenuOut_EntNoContinues:
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Fade palette
	jsr FadePalette
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_GameOverMenuOut_Exit
	;Check for continue option
	lda GameModeTimer2
	beq RunGameSubmode_GameOverMenuOut_Continue
	;Next mode ($01: Title)
	lda #$01
	sta GameMode
	;Next submode ($00: Init)
	jmp GoToNextGameMode_ClearSub
RunGameSubmode_GameOverMenuOut_Continue:
	;Next mode ($05: Level start)
	lda #$05
	sta GameMode
	;Next submode ($00: Init)
	jsr GoToNextGameMode_ClearSub
	sta MainGameSubmode
	;Clear current area
	sta CurArea
RunGameSubmode_GameOverMenuOut_Exit:
	rts

;$06: No continues
RunGameSubmode_GameOverNoContinues:
	;Set cursor position
	lda #$01
	sta GameModeTimer2
	;Check if timer 0
	lda GameModeTimer
	beq RunGameSubmode_GameOverMenuOut_EntNoContinues
	;Decrement timer
	dec GameModeTimer
RunGameSubmode_GameOverNoContinues_Exit:
	rts

FlashGameOverContinues:
	;If bits 0-2 of timer not 0, exit early
	lda GameModeTimer
	and #$07
	bne RunGameSubmode_GameOverNoContinues_Exit
	;Write/clear VRAM strip based on bit 3 of timer
	lda GameModeTimer
	and #$08
	asl
	asl
	asl
	asl
	adc GameModeTimer2
	adc #$0C
	jsr WriteVRAMStrip
	;Check for continue option
	lda GameModeTimer2
	bne RunGameSubmode_GameOverNoContinues_Exit
	;Write/clear continues based on bit 3 of timer
	lda #$00
	sta $10
	lda GameModeTimer
	and #$08
	bne FlashGameOverContinues_Clear
	jmp DrawGameOverContinues
FlashGameOverContinues_Clear:
	jmp DrawGameOverContinues_Clear

;;;;;;;;;;;;;;;
;MISC ROUTINES;
;;;;;;;;;;;;;;;
;DRAW DECIMAL VALUE ROUTINE
DrawDecimalValue:
	;Init VRAM buffer row
	sta $0A
	lda #$01
	jsr WriteVRAMBufferCmd
	;Set VRAM buffer address
	lda $0A
	jsr WriteVRAMBufferCmd_AnyX
	lda $0B
	jsr WriteVRAMBufferCmd_AnyX
	;Clear leading zero flag
	lda #$00
	sta $09
	;Draw decimal value
	lda #$03
	sta $08
DrawDecimalValue_Loop:
	;Check for high or low digit
	lda $08
	lsr
	tay
	bcs DrawDecimalValue_Hi
	;Get low digit
	lda $0C,y
	and #$0F
	jmp DrawDecimalValue_Check0
DrawDecimalValue_Hi:
	;Get high digit
	lda $0C,y
	lsr
	lsr
	lsr
	lsr
DrawDecimalValue_Check0:
	;Check for '0' digit
	beq DrawDecimalValue_CheckLead0
	;Set leading zero flag
	inc $09
DrawDecimalValue_SetTileDigit:
	;Set digit tile in VRAM
	ora $0F
DrawDecimalValue_SetTile:
	;Set tile in VRAM
	jsr WriteVRAMBufferCmd_AnyX
	;Loop for each digit
	dec $08
	bpl DrawDecimalValue_Loop
	;Set "PTS." text tiles in VRAM
	lda #$F4
	ora $0F
	jsr WriteVRAMBufferCmd_AnyX
	lda #$F5
	ora $0F
	jsr WriteVRAMBufferCmd_AnyX
	;End VRAM buffer
	jmp WriteVRAMBufferCmd_End
DrawDecimalValue_CheckLead0:
	;Check for leading zero flag
	lda $09
	beq DrawDecimalValue_CheckLast0
DrawDecimalValue_SetLead0:
	;Set leading '0' digit in VRAM
	lda #$00
	beq DrawDecimalValue_SetTileDigit
DrawDecimalValue_CheckLast0:
	;Check for last digit
	lda $08
	beq DrawDecimalValue_SetLead0
	;Set blank tile in VRAM
	lda #$00
	beq DrawDecimalValue_SetTile

;MISC GAME MODE ROUTINES
GoToNextGameMode:
	;Next mode
	inc GameMode
GoToNextGameMode_ClearSub:
	;Next submode
	lda #$00
	sta GameSubmode
	rts

SetGameMode:
	;Next mode
	sta GameMode
	jmp GoToNextGameMode_ClearSub

DecrementModeTimer:
	;Decrement timer, check if 0
	lda GameModeTimer
	ora GameModeTimer+1
	beq DecrementModeTimer_Exit
	lda GameModeTimer
	bne DecrementModeTimer_NoC
	dec GameModeTimer+1
DecrementModeTimer_NoC:
	dec GameModeTimer
	lda #$01
DecrementModeTimer_Exit:
	rts

SetModeTimer:
	;Set timer
	lda #$00
	ldy #$01
SetModeTimer_Any:
	sta GameModeTimer
	sty GameModeTimer+1
	rts

;CLEAR RAM ROUTINES
ClearZP_Demo:
	;Clear ZP $40-$CF
	jsr ClearZP_40
	;Set demo flag
	lda #$01
	sta DemoFlag
	rts

ClearEnemies_Screen:
	;Clear screen enemies
	ldy #$07
	bne ClearEnemies_AnyY
ClearEnemies_Attack:
	;Clear attack enemies
	ldy #$05
ClearEnemies_AnyY:
	;Clear enemy
	lda #$00
ClearEnemies_Loop:
	sta Enemy_Sprite+$02,y
	sta PlayerAttackAnimOffs,y
	;Loop for each enemy
	dey
	bpl ClearEnemies_Loop
	rts

ClearZP_40:
	;Clear ZP $40-$CF
	ldx #$40
	bne ClearZP_AnyX
ClearZP_70:
	;Clear ZP $70-$CF
	ldx #$70
ClearZP_AnyX:
	;Clear ZP
	lda #$00
ClearZP_Loop:
	sta $00,x
	inx
	cpx #$D0
	bne ClearZP_Loop
	;Clear sprite boss mode flag
	sta SpriteBossModeFlag

ClearWRAM:
	;Clear WRAM
	lda #$00
	ldx #$00
ClearWRAM_Loop:
	sta $0400,x
	sta $0500,x
	sta $0600,x
	cpx #$F0
	bcs ClearWRAM_Next
	sta $0700,x
ClearWRAM_Next:
	inx
	bne ClearWRAM_Loop
	;Clear HUD VRAM buffer
	ldx #$80
ClearWRAM_VRAMBuffer:
	sta VRAMBuffer,x
	inx
	bne ClearWRAM_VRAMBuffer
	rts

;DO JUMP TABLE ROUTINE
DoJumpTable:
	;Get jump table offset
	asl
	;Get jump address
	sty $03
	tay
	iny
	pla
	sta $00
	pla
	sta $01
	lda ($00),y
	sta $02
	iny
	lda ($00),y
	ldy $03
	sta $03
	;Jump to address
	jmp ($02)

;DRAW NAMETABLE INCREMENT/DECREMENT ADDRESS ROUTINES
DrawNametableIncAddr:
	;Increment address
	clc
	adc $00,x
	sta $00,x
	bcc DrawNametableIncAddr_NoC
	inc $01,x
DrawNametableIncAddr_NoC:
	rts

DrawNametableDecAddr:
	;Decrement address
	sec
	eor #$FF
	adc $00,x
	sta $00,x
	bcs DrawNametableDecAddr_NoC
	dec $01,x
DrawNametableDecAddr_NoC:
	rts

;SIN/COS DATA
SineTable:
	.db $00,$06,$0C,$12,$19,$1F,$25,$2B,$31,$38,$3E,$44,$4A,$50,$56,$5C
	.db $61,$67,$6D,$73,$78,$7E,$83,$88,$8E,$93,$98,$9D,$A2,$A7,$AB,$B0
	.db $B5,$B9,$BD,$C1,$C5,$C9,$CD,$D1,$D4,$D8,$DB,$DE,$E1,$E4,$E7,$EA
	.db $EC,$EE,$F1,$F3,$F4,$F6,$F8,$F9,$FB,$FC,$FD,$FE,$FE,$FF,$FF,$FF
	.db $FF

;SCORE ROUTINES
GivePoints:
	;Add points to score
	jsr AddScore
	;Check for lives bonus
	lda PlayerScoreMid,x
	cmp PlayerLivesBonus,x
	bcc GivePoints_NoCL
	;Increment lives bonus threshold by 2000 points
	lda #$1F
	adc PlayerLivesBonus,x
	sta PlayerLivesBonus,x
	;Check for 9 lives (max allowed)
	lda PlayerLives,x
	cmp #$09
	bcs GivePoints_NoCL
	;Increment lives count
	inc PlayerLives,x
	;Check for stage clear mode
	lda GameMode
	cmp #$07
	;Play sound
	lda #SE_1UP
	bcc GivePoints_NoStageClear
	lda #SE_STAGECLEAR1UP
GivePoints_NoStageClear:
	jsr LoadSound
GivePoints_NoCL:
	;Compare top score 1000's+100's place
	lda TopScoreMid
	cmp PlayerScoreMid,x
	;If less, exit
	bcc GivePoints_SetTop
	;If equal, check 10's+1's place as well
	bne GivePoints_Exit
	;Compare top score 10's+1's place
	lda TopScoreLo
	cmp PlayerScoreLo,x
	;If greater, set top score
	bcc GivePoints_SetTop
GivePoints_Exit:
	rts
GivePoints_SetTop:
	;Set top score to current score
	lda PlayerScoreMid,x
	sta TopScoreMid
	lda PlayerScoreLo,x
	sta TopScoreLo
	rts

AddScore:
	;Add points to score (10's+1's place)
	clc
	lda PlayerScoreLo,x
	ldy #$00
	jsr AddScoreSub
	sta PlayerScoreLo,x
	;Add points to score (1000's+100's place)
	lda PlayerScoreMid,x
	iny
	jsr AddScoreSub
	;Check for max score (9999 points)
	bcc AddScore_NoC
	;Set max score
	lda #$99
	sta PlayerScoreLo,x
AddScore_NoC:
	sta PlayerScoreMid,x
	rts

SubScore:
	;Subtract points from score (10's+1's place)
	sec
	lda PlayerScoreLo,x
	ldy #$00
	jsr SubScoreSub
	sta PlayerScoreLo,x
	;Subtract points from score (1000's+100's place)
	lda PlayerScoreMid,x
	iny
	jsr SubScoreSub
	;Check for min score (0 points)
	bcs SubScore_NoC
	;Set min score
	lda #$00
	sta PlayerScoreLo,x
SubScore_NoC:
	sta PlayerScoreMid,x
	rts

AddScoreSub:
	;Get low/high digits
	sta $04
	and #$F0
	sta $03
	eor $04
	sta $04
	;Add low digits
	lda $00,y
	and #$0F
	adc $04
	;Check for BCD carry
	cmp #$0A
	bcc AddScoreSub_NoC
	;Adjust sum for BCD carry
	adc #$05
AddScoreSub_NoC:
	adc $03
	sta $03
	;Add high digits
	lda $00,y
	and #$F0
	adc $03
	;Check for BCD carry
	bcs AddScoreSub_NoC2
	cmp #$A0
	bcc AddScoreSub_Exit
AddScoreSub_NoC2:
	;Adjust sum for BCD carry
	sbc #$A0
	sec
AddScoreSub_Exit:
	rts

SubScoreSub:
	;Get low digit
	sta $05
	lda $00,y
	and #$0F
	sta $03
	;Subtract low digits
	lda $05
	and #$0F
	sbc $03
	;Check for BCD carry
	bcs SubScoreSub_NoC
	;Adjust difference for BCD carry
	adc #$0A
	clc
SubScoreSub_NoC:
	sta $04
	;Get high digit
	lda $00,y
	and #$F0
	bcs SubScoreSub_NoC2
	adc #$10
SubScoreSub_NoC2:
	sec
	sta $03
	;Subtract high digits
	lda $05
	and #$F0
	ora $04
	sbc $03
	;Check for BCD carry
	bcs SubScoreSub_Exit
	;Adjust difference for BCD carry
	adc #$A0
	clc
SubScoreSub_Exit:
	rts

;;;;;;;;;;;;;;;
;VRAM ROUTINES;
;;;;;;;;;;;;;;;
ClearPalette:
	;Clear palette buffer
	ldx #$1F
	lda #$0F
ClearPalette_Loop:
	sta PaletteBuffer,x
	dex
	bpl ClearPalette_Loop

WritePalette:
	;Init VRAM buffer row
	ldy #$00
	ldx VRAMBufferOffset
	lda #$01
	sta VRAMBuffer,x
	inx
	;Set VRAM buffer address
	lda #$00
	sta VRAMBuffer,x
	inx
	lda #$3F
	sta VRAMBuffer,x
	inx
WritePalette_Loop:
	;Get palette buffer color
	lda PaletteBuffer,y
	;Check for boss palette color index
	cpy #$1D
	bne WritePalette_Set
	;Check for boss palette flash flag
	bit BossPaletteFlashFlag
	bpl WritePalette_Set
	;Check for black color
	cmp #$0F
	bne WritePalette_NoBlack
	;Set white color
	lda #$00
WritePalette_NoBlack:
	;Set max lightness color
	ora #$30
WritePalette_Set:
	;Set color in VRAM
	sta VRAMBuffer,x
	;Loop for each color
	inx
	iny
	cpy #$20
	bcc WritePalette_Loop
	;End VRAM buffer
	lda #$FF
	sta VRAMBuffer,x
	inx
	stx VRAMBufferOffset
	;Write VRAM strip (load partial palette data)
	lda #$04
	jmp WriteVRAMStrip

DrawOldTitleScreen:
	;Clear sound
	jsr ClearSound
	;Clear nametable
	jsr ClearNametableData
	;Clear scroll position
	lda TempMirror_PPUCTRL
	and #$FC
	sta TempMirror_PPUCTRL
	;Write VRAM strip (old title screen palette)
	lda #$05
	jsr WriteVRAMStrip
	;Write VRAM strip (old title screen)
	lda #$03
	sta $08
DrawOldTitleScreen_Loop:
	lda $08
	jsr WriteVRAMStrip
	dec $08
	bpl DrawOldTitleScreen_Loop
	rts

ClearNametableData:
	;Write nametable $00 (empty nametable)
	ldx #$00

WriteNametableData:
	;Get nametable data pointer
	lda NametableDataPointerTable,x
	sta $00
	lda NametableDataPointerTable+1,x
	sta $01
	;Disable video out
	jsr DisableVideoOut
	;Clear scroll position
	lda #$00
	sta TempMirror_PPUSCROLL_X
	sta TempMirror_PPUSCROLL_Y
WriteNametableData_Loop:
	;Latch PPU status line
	lda PPU_STATUS
	;Set VRAM buffer address
	ldy #$01
	lda ($00),y
	sta PPU_ADDR
	dey
	lda ($00),y
	sta PPU_ADDR
	;Increment nametable data pointer
	ldx #$00
	lda #$02
	jsr DrawNametableIncAddr
WriteNametableData_Loop2:
	;Check for end all command
	ldy #$00
	lda ($00),y
	beq WriteNametableData_EndAll
	;Check for end strip command
	cmp #$80
	beq WriteNametableData_EndStrip
	;Check for RLE mode
	tay
	bpl WriteNametableData_RLE
	;Get strip length
	and #$7F
	sta $02
	;Write immediate VRAM strip
	ldy #$01
	;Check for RLE increment mode
	and #$40
	bne WriteNametableData_RLEInc
WriteNametableData_ImmLoop:
	;Set byte in VRAM
	lda ($00),y
	sta PPU_DATA
	;Loop for each byte
	cpy $02
	beq WriteNametableData_ImmEnd
	iny
	bne WriteNametableData_ImmLoop
WriteNametableData_ImmEnd:
	;Increment nametable data pointer
	lda #$01
	clc
	adc $02
WriteNametableData_IncAddr:
	jsr DrawNametableIncAddr
	jmp WriteNametableData_Loop2
WriteNametableData_RLE:
	;Write RLE VRAM strip
	ldy #$01
	sta $02
	lda ($00),y
	ldy $02
WriteNametableData_RLELoop:
	;Set byte in VRAM
	sta PPU_DATA
	;Loop for each byte
	dey
	bne WriteNametableData_RLELoop
WriteNametableData_RLEEnd:
	;Increment nametable data pointer
	lda #$02
	bne WriteNametableData_IncAddr
WriteNametableData_EndStrip:
	;Increment nametable data pointer
	lda #$01
	jsr DrawNametableIncAddr
	;Loop for each strip
	jmp WriteNametableData_Loop
WriteNametableData_EndAll:
	;Enable video out
	jmp SetScroll_SetCtrl
WriteNametableData_RLEInc:
	;Write RLE increment VRAM strip
	lda ($00),y
	sta $03
	lda $02
	and #$3F
	tay
WriteNametableData_RLEIncLoop:
	;Set byte in VRAM
	lda $03
	sta PPU_DATA
	;Loop for each byte
	inc $03
	dey
	bne WriteNametableData_RLEIncLoop
	;Increment nametable data pointer
	jmp WriteNametableData_RLEEnd

;;;;;;;;;;;;;;;;
;NAMETABLE DATA;
;;;;;;;;;;;;;;;;
NametableDataPointerTable:
	.dw Nametable00Data	;$00  Empty
	.dw Nametable00Data	;$02  UNUSED
	.dw Nametable00Data	;$04  UNUSED
	.dw Nametable06Data	;$06  Title screen
	.dw Nametable08Data	;$08  Player select/stage clear (Vampire)
	.dw Nametable0AData	;$0A  Stage clear (Monster)
	.dw Nametable00Data	;$0C  UNUSED
	.dw Nametable0EData	;$0E  Level 3 boss
	.dw Nametable10Data	;$10  Clear dialog/HUD
	.dw Nametable12Data	;$12  TV top edge
	.dw Nametable14Data	;$14  Game over
	.dw Nametable16Data	;$16  Level start
Nametable00Data:
	.dw $2400
	.db $78,$00,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00
	.db $40,$00
	.db $80
	.dw $2800
	.db $78,$00,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00,$78,$00
	.db $40,$00
	.db $00
Nametable10Data:
	.dw $2B00
	.db $40,$00,$40,$00,$40,$00
	.db $80
	.dw $2BF0
	.db $10,$00
	.db $00

;;;;;;;;;;;;;;;
;VRAM ROUTINES;
;;;;;;;;;;;;;;;
WriteVRAMStrip:
	;Get VRAM strip pointer
	asl
	tay
	lda VRAMStripPointerTable,y
	sta $00
	lda VRAMStripPointerTable+1,y
	sta $01
	;Check for clear VRAM strip command
	lda #$FF
	adc #$00
	sta $02
	;Write VRAM strip
	ldy #$00
WriteVRAMStrip_Loop:
	;Init VRAM buffer row
	lda #$01
	jsr WriteVRAMBufferCmd
	;Set VRAM buffer address
	lda ($00),y
	jsr WriteVRAMBufferCmd_AnyX
	iny
	lda ($00),y
	jsr WriteVRAMBufferCmd_AnyX
	iny
WriteVRAMStrip_Loop2:
	;Check for end command
	lda ($00),y
	iny
	cmp #$FE
	bcs WriteVRAMStrip_End
	;Set byte in VRAM
	and $02
	jsr WriteVRAMBufferCmd_AnyX
	jmp WriteVRAMStrip_Loop2
WriteVRAMStrip_End:
	;Check for end all command
	bne WriteVRAMBufferCmd_End
	;Check for end strip command
	jsr WriteVRAMBufferCmd_End
	jmp WriteVRAMStrip_Loop

WriteVRAMBufferCmd_End:
	;Write VRAM command to end current strip
	lda #$FF

WriteVRAMBufferCmd:
	;Write VRAM command
	ldx VRAMBufferOffset
WriteVRAMBufferCmd_AnyX:
	sta VRAMBuffer,x
	inx
	stx VRAMBufferOffset
	rts

;;;;;;;;;;;;;;;;;
;VRAM STRIP DATA;
;;;;;;;;;;;;;;;;;
VRAMStripPointerTable:
	.dw VRAMStrip00Data	;$00 \Old title screen
	.dw VRAMStrip01Data	;$01 |
	.dw VRAMStrip02Data	;$02 |
	.dw VRAMStrip03Data	;$03 /
	.dw VRAMStrip04Data	;$04  Load partial palette data
	.dw VRAMStrip05Data	;$05  Old title screen palette
	.dw VRAMStrip06Data	;$06  UNUSED
	.dw VRAMStrip07Data	;$07  UNUSED
	.dw VRAMStrip08Data	;$08  UNUSED
	.dw VRAMStrip09Data	;$09 \Level select screen
	.dw VRAMStrip0AData	;$0A /
	.dw VRAMStrip0BData	;$0B  "HI SCORE" text
	.dw VRAMStrip0CData	;$0C  "CONTINUE" text
	.dw VRAMStrip0DData	;$0D  "END" text
	.dw VRAMStrip0EData	;$0E  "PLAYER SELECT" text
	.dw VRAMStrip0FData	;$0F  UNUSED
	.dw VRAMStrip10Data	;$10 \Legal screen
	.dw VRAMStrip11Data	;$11 /
	.dw VRAMStrip12Data	;$12 \"PRESS START" text
	.dw VRAMStrip12Data	;$13 /
	.dw VRAMStrip14Data	;$14  "1 PLAYER" text
	.dw VRAMStrip15Data	;$15  "2 PLAYER" text
	.dw VRAMStrip16Data	;$16  Left hand shadow
	.dw VRAMStrip17Data	;$17  Right hand shadow
	.dw VRAMStrip18Data	;$18  "STAGE   CLEAR" text
	.dw VRAMStrip19Data	;$19  "1 PLAYER VAMPIRE" text
	.dw VRAMStrip1AData	;$1A  "2 PLAYER THE MONSTER" text
	.dw VRAMStrip1BData	;$1B  "1 PLAYER THE MONSTER" text (stage clear)
	.dw VRAMStrip1CData	;$1C  "2 PLAYER VAMPIRE" text (stage clear)
	.dw VRAMStrip1DData	;$1D  "HI SCORE" text
	.dw VRAMStrip1EData	;$1E  "SCORE" text
	.dw VRAMStrip1FData	;$1F  "BONUS" text
	.dw VRAMStrip20Data	;$20  "1 PLAYER THE MONSTER" text (player select)
	.dw VRAMStrip21Data	;$21  "2 PLAYER VAMPIRE" text (player select)
	.dw VRAMStrip22Data	;$22 \Level 6 elevator
	.dw VRAMStrip23Data	;$23 |
	.dw VRAMStrip24Data	;$24 /
	.dw VRAMStrip25Data	;$25 \Level 3 boss
	.dw VRAMStrip26Data	;$26 |
	.dw VRAMStrip27Data	;$27 /
	.dw VRAMStrip28Data	;$28 \TV blink animation
	.dw VRAMStrip29Data	;$29 |
	.dw VRAMStrip2AData	;$2A /
	.dw VRAMStrip2BData	;$2B  Project Murata logo
	.dw VRAMStrip2CData	;$2C  TV mouth clear
	.dw VRAMStrip2DData	;$2D  Konami logo
	.dw VRAMStrip2EData	;$2E  Music $A5 (GET OUT FROM A POCKET)
	.dw VRAMStrip2FData	;$2F  Music $A9 (TWIST AND SELECT)
	.dw VRAMStrip30Data	;$30  Music $A1 (WARLOCK EYES)
	.dw VRAMStrip31Data	;$31  Music $7D (THEME OF MM'S)
	.dw VRAMStrip32Data	;$32  Music $81 (DANCIN' IN THE KITCHEN)
	.dw VRAMStrip33Data	;$33  Music $85 (COLA FLOAT)
	.dw VRAMStrip34Data	;$34  Music $89 (MONSTER RAP)
	.dw VRAMStrip35Data	;$35  Music $8D (ASIA CLUB)
	.dw VRAMStrip36Data	;$36  Music $91 (EARTHQUAKE)
	.dw VRAMStrip37Data	;$37  Music $95 (THEME OF EMM'S)
	.dw VRAMStrip38Data	;$38  Music $9D (BOSS WORLD)
	.dw VRAMStrip39Data	;$39  Music $B0 (THEME OF WARLOCK)
	.dw VRAMStrip3AData	;$3A  Music $AD (MONSTER HAPPINESS)
	.dw VRAMStrip3BData	;$3B  Music $B4 (MONSTER BOOGIE)
	.dw VRAMStrip3CData	;$3C  Music $BC (I'M DOWN)
	.dw VRAMStrip3DData	;$3D  Music $B8 (STAGE CLEAR)
	.dw VRAMStrip3EData	;$3E  Sound test screen
	.dw VRAMStrip3FData	;$3F  "STAGE 1" text
	.dw VRAMStrip40Data	;$40  "STAGE 2" text
	.dw VRAMStrip41Data	;$41  "STAGE 3" text
	.dw VRAMStrip42Data	;$42  "STAGE 4" text
	.dw VRAMStrip43Data	;$43  "STAGE 5" text
	.dw VRAMStrip44Data	;$44  "STAGE 6" text
	.dw VRAMStrip45Data	;$45  Stage 1 (MONSTERS IN MY HOUSE)
	.dw VRAMStrip46Data	;$46  Stage 2 (BIG TROUBLE IN THE KITCHEN)
	.dw VRAMStrip47Data	;$47  Stage 3 (CRISIS FROM UNDERGROUND)
	.dw VRAMStrip48Data	;$48  Stage 4 (TOWERING CATASTROPHE)
	.dw VRAMStrip49Data	;$49  Stage 5 (ORIENTAL ILLUSION)
	.dw VRAMStrip4AData	;$4A  Stage 6 (LAST BATTLE AT MONSTER MOUNTAIN)
VRAMStrip02Data:
	.dw $210C
	.db $80,$81,$82,$83,$84,$85,$86,$87
	.db $FE
	.dw $212C
	.db $90,$91,$92,$93,$94,$95,$96,$97
	.db $FF
VRAMStrip03Data:
	.dw $214C
	.db $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7
	.db $FE
	.dw $216C
	.db $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7
	.db $FF
VRAMStrip00Data:
	.dw $22CD
	.db $BB,$BF,$9F,$9B,$88,$B8,$8C,$A9
	.db $FF
VRAMStrip01Data:
	.dw $230D
	.db $BC,$BF,$9F,$9B,$88,$B8,$8C,$A9,$AA
	.db $FF
VRAMStrip05Data:
	.dw $3F00
	.db $0F,$16,$2A,$20,$0F,$17,$27,$37,$0F,$1B,$2B,$20,$0F,$2C,$3C,$20
	.db $0F,$16,$27,$20,$0F,$08,$16,$3C,$0F,$08,$12,$31,$0F,$07,$24,$33
	.db $FE
VRAMStrip04Data:
	.dw $3F00
	.db $FE
	.dw $0000
	.db $FF
VRAMStrip06Data:
	.dw $3F00
	.db $0F,$15,$29,$20,$0F,$18,$28,$38,$0F,$09,$00,$37,$0F,$07,$17,$27
	.db $0F,$09,$26,$31,$0F,$0C,$2C,$30,$0F,$12,$26,$30,$0F,$06,$30,$30
	.db $FE
	.dw $3F00
	.db $FE
	.dw $0000
	.db $FF
VRAMStrip07Data:
	.dw $3F00
	.db $0F,$15,$29,$20,$0F,$18,$27,$37,$0F,$00,$28,$38,$0F,$00,$10,$20
	.db $0F,$09,$26,$31,$0F,$0C,$2C,$30,$0F,$12,$26,$30,$0F,$06,$30,$30
	.db $FE
	.dw $3F00
	.db $FE
	.dw $0000
	.db $FF
VRAMStrip08Data:
	.dw $3F00
	.db $0F,$15,$29,$20,$0F,$18,$28,$38,$0F,$09,$00,$37,$0F,$07,$17,$27
	.db $0F,$08,$26,$31,$0F,$0C,$2C,$30,$0F,$12,$26,$30,$0F,$06,$30,$30
	.db $FE
	.dw $3F00
	.db $FE
	.dw $0000
	.db $FF
VRAMStrip09Data:
	.dw $20CA
	.db $9C,$9D,$B2,$90,$8E,$00,$9C,$8E,$95,$8E,$8C,$9D
	.db $FE
	.dw $210E
	.db $82
	.db $FF
VRAMStrip0AData:
	.dw $2110
	.db $B0,$00,$82
	.db $FF
VRAMStrip0BData:
	.dw $2168
	.db $E1,$E2,$00,$EC,$DC,$E8,$EB,$DE
	.db $FF
VRAMStrip0CData:
	.dw $220D
	.db $DC,$E8,$E7,$ED,$E2,$E7,$EE,$DE
	.db $FF
VRAMStrip0DData:
	.dw $226D
	.db $DE,$E7,$DD
	.db $FF
VRAMStrip0EData:
	.dw $2349
	.db $E9,$E5,$DA,$F2,$DE,$EB,$00,$EC,$DE,$E5,$DE,$DC,$ED
	.db $FF
VRAMStrip0FData:
	.dw $210A
	.db $8C,$98,$96,$92,$97,$90,$00,$9C,$98,$98,$97
	.db $FE
	.dw $2207
	.db $9C,$8E,$8E,$00,$A2,$98,$9E,$00,$97,$8E,$A1,$9D,$00,$A0,$92,$97
	.db $9D,$8E,$9B
	.db $FF
VRAMStrip10Data:
	.dw $2064
	.db $96,$98,$97,$9C,$9D,$8E,$9B,$00,$92,$97,$00,$00,$96,$A2,$00,$00
	.db $99,$98,$8C,$94,$8E,$9D,$A4,$A5
	.db $FE
	.dw $20A4
	.db $95,$98,$90,$98,$00,$00,$B2,$97,$8D,$00,$00,$B2,$95,$95,$00,$8C
	.db $91,$B2,$9B,$B2,$8C,$9D,$8E,$9B
	.db $FE
	.dw $20E4
	.db $8D,$8E,$9C,$92,$90,$97,$9C,$00,$B2,$9B,$8E,$00,$98,$A0,$97,$8E
	.db $8D,$00,$8B,$A2,$00,$B2,$97,$8D
	.db $FF
VRAMStrip11Data:
	.dw $2124
	.db $9E,$9C,$8E,$8D,$00,$9E,$97,$8D,$8E,$9B,$00,$95,$92,$8C,$8E,$97
	.db $9C,$8E,$00,$00,$8F,$9B,$98,$96
	.db $FE
	.dw $2164
	.db $96,$98,$9B,$9B,$92,$9C,$98,$97,$00,$8E,$97,$9D,$8E,$9B,$9D,$B2
	.db $92,$97,$96,$8E,$97,$9D
	.db $FE
	.dw $21A4
	.db $90,$9B,$98,$9E,$99,$A6,$92,$97,$8C,$A7
	.db $FE
	.dw $21E4
	.db $B1,$00,$82,$8A,$8A,$82,$00,$00,$96,$98,$9B,$9B,$92,$9C,$98,$97
	.db $FE
	.dw $2224
	.db $8E,$97,$9D,$8E,$9B,$9D,$B2,$92,$97,$96,$8E,$97,$9D,$00,$90,$9B
	.db $98,$9E,$99,$A6,$92,$97,$8C,$A7
	.db $FE
	.dw $2264
	.db $B2,$95,$95,$00,$9B,$92,$90,$91,$9D,$9C,$00,$9B,$8E,$9C,$8E,$9B
	.db $9F,$8E,$8D,$A7
	.db $FE
	.dw $22C2
	.db $9D,$96,$00,$B2,$97,$8D,$00,$B1,$82,$8A,$8A,$82,$00,$94,$98,$97
	.db $B2,$96,$92,$00,$8C,$98,$A7,$A6,$95,$9D,$8D,$A7
	.db $FE
	.dw $230B
	.db $95,$92,$8C,$8E,$97,$9C,$8E,$8D,$00,$8B,$A2
	.db $FE
	.dw $2344
	.db $97,$92,$97,$9D,$8E,$97,$8D,$98,$00,$98,$8F,$00,$B2,$96,$8E,$9B
	.db $92,$8C,$B2,$00,$92,$97,$8C,$A7
	.db $FF
VRAMStrip12Data:
	.dw $262A
	.db $A0,$A1,$A2,$A3,$A3,$00,$00,$A3,$A4,$A5,$A1,$A4
	.db $FF
VRAMStrip14Data:
	.dw $260C
	.db $A6,$00,$A0,$A8,$A5,$A9,$A2,$A1
	.db $FF
VRAMStrip15Data:
	.dw $264C
	.db $A7,$00,$A0,$A8,$A5,$A9,$A2,$A1,$A3
	.db $FF
VRAMStrip16Data:
	.dw $218B
	.db $E6,$E7,$E8
	.db $FF
VRAMStrip17Data:
	.dw $2192
	.db $E9,$EA,$EB
	.db $FF
VRAMStrip18Data:
	.dw $234A
	.db $EC,$ED,$DA,$E0,$DE,$00,$00,$00,$DC,$E5,$DE,$DA,$EB
	.db $FF
VRAMStrip19Data:
	.dw $20C8
	.db $D1,$00,$E9,$E5,$DA,$F2,$DE,$EB
	.db $FE
	.dw $2108
	.db $EF,$DA,$E6,$E9,$E2,$EB,$DE
	.db $FF
VRAMStrip1AData:
	.dw $2290
	.db $D2,$00,$E9,$E5,$DA,$F2,$DE,$EB
	.db $FE
	.dw $22D0
	.db $ED,$E1,$DE
	.db $FE
	.dw $22F0
	.db $E6,$E8,$E7,$EC,$ED,$DE,$EB
	.db $FF
VRAMStrip1BData:
	.dw $20C8
	.db $D1,$00,$E9,$E5,$DA,$F2,$DE,$EB
	.db $FE
	.dw $2108
	.db $ED,$E1,$DE
	.db $FE
	.dw $2128
	.db $E6,$E8,$E7,$EC,$ED,$DE,$EB
	.db $FF
VRAMStrip1CData:
	.dw $2290
	.db $D2,$00,$E9,$E5,$DA,$F2,$DE,$EB
	.db $FE
	.dw $22D0
	.db $EF,$DA,$E6,$E9,$E2,$EB,$DE
	.db $FF
VRAMStrip1DData:
	.dw $204C
	.db $E1,$E2,$00,$EC,$DC,$E8,$EB,$DE
	.db $FF
VRAMStrip1EData:
	.dw $216A
	.db $EC,$DC,$E8,$EB,$DE
	.db $FF
VRAMStrip1FData:
	.dw $220A
	.db $DB,$E8,$E7,$EE,$EC
	.db $FF
VRAMStrip20Data:
	.dw $20D0
	.db $D1,$00,$E9,$E5,$DA,$F2,$DE,$EB
	.db $FE
	.dw $2110
	.db $ED,$E1,$DE
	.db $FE
	.dw $2130
	.db $E6,$E8,$E7,$EC,$ED,$DE,$EB
	.db $FF
VRAMStrip21Data:
	.dw $2288
	.db $D2,$00,$E9,$E5,$DA,$F2,$DE,$EB
	.db $FE
	.dw $22C8
	.db $EF,$DA,$E6,$E9,$E2,$EB,$DE
	.db $FF
VRAMStrip22Data:
	.dw $23C8
	.db $F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5
	.db $FF
VRAMStrip23Data:
	.dw $23F0
	.db $F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5
	.db $FF
VRAMStrip24Data:
	.dw $2BD0
	.db $5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F
	.db $FF
VRAMStrip28Data:
	.dw $292D
	.db $D1,$DA,$DB,$DC,$DD,$D6
	.db $FE
	.dw $294E
	.db $D9,$E3,$E4,$88
	.db $FF
VRAMStrip29Data:
	.dw $292D
	.db $E9,$EA,$EB,$EC,$ED,$EE
	.db $FE
	.dw $294E
	.db $FA,$FB,$FC,$FD
	.db $FF
VRAMStrip2AData:
	.dw $292D
	.db $D1,$D2,$D3,$D4,$D5,$D6
	.db $FE
	.dw $294E
	.db $E2,$E3,$E4,$E5
	.db $FF
VRAMStrip2BData:
	.dw $29AC
	.db $28,$29,$2A,$2B,$2C,$2D,$2E,$2F
	.db $FE
	.dw $29CC
	.db $38,$39,$3A,$3B,$3C,$3D,$3E,$3F
	.db $FF
VRAMStrip2CData:
	.dw $2BCA
	.db $00,$00,$00,$00
	.db $FE
	.dw $2BD2
	.db $00,$00,$00,$00
	.db $FE
	.dw $2BDA
	.db $00,$00,$00,$00
	.db $FF
VRAMStrip2DData:
	.dw $28CF
	.db $04,$05,$06
	.db $FE
	.dw $28EF
	.db $14,$15,$16
	.db $FE
	.dw $290D
	.db $07,$08,$09,$0A,$0B,$0C
	.db $FE
	.dw $292C
	.db $00,$17,$18,$19,$1A,$1B,$1C
	.db $FE
	.dw $294E
	.db $0D,$0E,$0F
	.db $FE
	.dw $296E
	.db $1D,$1E,$1F
	.db $FE
	.dw $298D
	.db $02,$03,$10,$11,$12,$13
	.db $FF

;;;;;;;;;;;;;;;
;VRAM ROUTINES;
;;;;;;;;;;;;;;;
WriteVRAMBufferPPU_CTRLTable:
	.db $00,$04,$00,$00,$00

WriteVRAMBuffer:
	ldy #$00
WriteVRAMBuffer_Loop:
	;Check for end of VRAM buffer
	ldx VRAMBuffer,y
	beq WriteVRAMBuffer_Exit
	;Set VRAM strip direction
	lda TempMirror_PPUCTRL
	and #$18
	ora WriteVRAMBufferPPU_CTRLTable-1,x
	sta PPU_CTRL
	iny
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	lda VRAMBuffer+1,y
	sta PPU_ADDR
	lda VRAMBuffer,y
	sta PPU_ADDR
	iny
	iny
	;Check for RLE mode
	cpx #$03
	beq WriteVRAMBuffer_RLE
	;Check for attribute row mode
	cpx #$04
	beq WriteVRAMBuffer_AttrRow
	;Check for attribute column mode
	cpx #$05
	beq WriteVRAMBuffer_AttrCol
	bne WriteVRAMBuffer_GetByte
WriteVRAMBuffer_Exit:
	;Clear VRAM buffer
	lda #$00
	sta VRAMBuffer
	sta VRAMBufferOffset
	rts
WriteVRAMBuffer_ImmFF:
	;Set immediate $FF value in VRAM
	lda #$FF
WriteVRAMBuffer_SetData:
	;Set value in VRAM
	sta PPU_DATA
WriteVRAMBuffer_GetByte:
	;Get data byte
	lda VRAMBuffer,y
	iny
	;Check for $FF
	cmp #$FF
	bne WriteVRAMBuffer_SetData
	;Check for immediate $FF value command
	lda VRAMBuffer,y
	cmp #$06
	bcs WriteVRAMBuffer_ImmFF
	;Check for VRAM strip direction
	bcc WriteVRAMBuffer_Loop
WriteVRAMBuffer_RLE:
	;Write RLE VRAM buffer data
	ldx VRAMBuffer,y
	iny
	lda VRAMBuffer,y
	iny
WriteVRAMBuffer_RLELoop:
	;Set value in VRAM
	sta PPU_DATA
	;Loop for each byte
	dex
	bne WriteVRAMBuffer_RLELoop
	beq WriteVRAMBuffer_Loop
WriteVRAMBuffer_AttrRow:
	;Get PPU address
	lda VRAMBuffer-1,y
	sta $10
	lda VRAMBuffer-2,y
	sta $11
	;Write attribute row data
	ldx #$08
WriteVRAMBuffer_AttrRowLoop:
	;Set attribute in VRAM
	lda VRAMBuffer,y
	iny
	sta PPU_DATA
	;Loop for each byte
	dex
	beq WriteVRAMBuffer_Loop
	;Increment PPU address
	lda $11
	and #$07
	cmp #$07
	beq WriteVRAMBuffer_NoAttrRowC
	inc $11
	bne WriteVRAMBuffer_AttrRowLoop
WriteVRAMBuffer_NoAttrRowC:
	lda $11
	and #$F8
	sta $11
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	lda $10
	sta PPU_ADDR
	lda $11
	sta PPU_ADDR
	bne WriteVRAMBuffer_AttrRowLoop
WriteVRAMBuffer_AttrCol:
	;Get PPU address
	ldx ScrollAttrBufferOffs
	dex
	dex
	lda VRAMBuffer-1,y
	sta $10
	lda VRAMBuffer-2,y
	sta $11
WriteVRAMBuffer_AttrColLoop:
	;Set attribute in VRAM
	lda VRAMBuffer,y
	iny
	sta PPU_DATA
	;Loop for each byte
	dex
	beq WriteVRAMBuffer_AttrColEnd
	;Increment PPU address
	lda $11
	clc
	adc #$08
	bcc WriteVRAMBuffer_NoAttrColC
	lda $10
	eor #$08
	sta $10
	lda $11
	and #$C7
WriteVRAMBuffer_NoAttrColC:
	sta $11
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	lda $10
	sta PPU_ADDR
	lda $11
	sta PPU_ADDR
	bne WriteVRAMBuffer_AttrColLoop
WriteVRAMBuffer_AttrColEnd:
	jmp WriteVRAMBuffer_Loop

;;;;;;;;;;;;;;;;;;;;
;GAME MODE ROUTINES;
;;;;;;;;;;;;;;;;;;;;
;DEMO MODE ROUTINES
UpdateDemoInput:
	;Update demo input
	jsr UpdateDemoInputSub
	;Check for end of demo
	lda DemoEndFlag
	beq RunGameMode_MainGame
	;Next mode ($00: Legal)
	lda #$00
	sta GameMode
	sta GameSubmode
	rts

;MAIN GAME MODE ROUTINES
RunGameMode_MainGame:
	;Do jump table
	lda MainGameSubmode
	jsr DoJumpTable
MainGameJumpTable:
	.dw RunGameSubmode_MainGameInitFirst	;$00: Init first
	.dw RunGameSubmode_MainGameInit		;$01: Init
	.dw RunGameSubmode_MainGameLoad		;$02: Load level
	.dw RunGameSubmode_MainGamePlay		;$03: Main gameplay
	.dw RunGameSubmode_MainGameVictory	;$04: Victory
	.dw RunGameSubmode_MainGameFadeOut	;$05: Fade out

LevelAreaCHRBank0Table:
	.db $40,$44,$44
	.db $48,$4C,$48
	.db $50,$54,$54
	.db $58,$5A,$58
	.db $5C,$60,$60
	.db $64,$64,$7E
LevelAreaCHRBank1Table:
	.db $42,$46,$46
	.db $4A,$4E,$4A
	.db $52,$56,$56
	.db $56,$5A,$5A
	.db $5E,$62,$62
	.db $66,$66,$6A
LevelAreaCHRBank3Table:
	.db $00,$00,$00
	.db $00,$00,$00
	.db $00,$00,$00
	.db $00,$00,$00
	.db $01,$01,$01
	.db $00,$00,$00
LevelAreaStartTable:
	.db $00,$03,$06,$09,$0C,$0F

;$00: Init first
RunGameSubmode_MainGameInitFirst:
	;Clear enemy sprites
	ldx #$20
	lda #$00
RunGameSubmode_MainGameInitFirst_SpLoop:
	sta Enemy_Sprite,x
	dex
	bpl RunGameSubmode_MainGameInitFirst_SpLoop
	;Clear music
	sta CurMusic
	;Load PRG bank $36 (clear player bank)
	lda #$36
	jsr LoadPRGBank
	;Clear players
	ldx #$01
RunGameSubmode_MainGameInitFirst_PlayerLoop:
	;Clear player
	jsr ClearPlayer
	;Loop for each player
	dex
	bpl RunGameSubmode_MainGameInitFirst_PlayerLoop
	;Init player lives bonus
	lda #$05
	sta PlayerLivesBonus
	sta PlayerLivesBonus+1
	;Init player character
	lda SelectCursorPos
	sta PlayerCharacter
	eor #$01
	sta PlayerCharacter+1
	;Init player lives
	lda #$03
	sta PlayerLives
	;Set respawn start flag
	inc PlayerRespawnStartFlag
	;Check for 2 player mode
	lda TitleCursorPos
	beq RunGameSubmode_MainGameInitFirst_No2P
	;Init player lives
	lda #$03
	sta PlayerLives+1
	;Set respawn start flag
	inc PlayerRespawnStartFlag+1
RunGameSubmode_MainGameInitFirst_No2P:
	;Next submode ($01: Init)
	inc MainGameSubmode
	rts

ClearIRQBuffer:
	;Clear IRQ buffer
	ldy #$03
	lda #$00
ClearIRQBuffer_Loop:
	sta TempIRQBufferHeight,y
	sta TempIRQBufferSub,y
	dey
	bpl ClearIRQBuffer_Loop
	sta TempIRQEnableFlag
	rts

;$01: Init
RunGameSubmode_MainGameInit:
	;Clear ZP $70-$CF
	ldx #$60
	lda #$00
RunGameSubmode_MainGameInit_ZPLoop:
	sta $70,x
	dex
	bpl RunGameSubmode_MainGameInit_ZPLoop
	;Clear sprite boss mode flag
	sta SpriteBossModeFlag
	;Clear ending HUD flag
	sta EndingHUDFlag
	;Load PRG bank $36 (clear player bank)
	lda #$36
	jsr LoadPRGBank
	;Clear players
	ldx #$01
RunGameSubmode_MainGameInit_PlayerLoop:
	;Clear player
	jsr ClearPlayer_NoFirst
	;Loop for each player
	dex
	bpl RunGameSubmode_MainGameInit_PlayerLoop
	;Load PRG bank
	lda #$34
	jsr LoadPRGBank
	;Clear IRQ buffer
	jsr ClearIRQBuffer
	;Clear attack enemies
	jsr ClearEnemies_Attack
	;Next submode ($02: Load level)
	inc MainGameSubmode
	;Clear palette
	jmp ClearPalette

;$02: Load level
RunGameSubmode_MainGameLoad:
	;Init level scroll
	jsr InitLevelScroll
	;Update enemy BG movement
	jsr UpdateEnemyBGMovement
	;Clear autoscroll/fixed camera flags
	lda #$00
	sta AutoScrollDirFlags
	sta TempScrollLockFlags
	;Clear elevator Y position
	sta ElevatorYPos
	;If demo active, don't load music
	ldy LevelAreaNum
	lda DemoFlag
	bne RunGameSubmode_MainGameLoad_NoSetMusic
	;If current area not X-2, load music
	lda CurArea
	cmp #$01
	bne RunGameSubmode_MainGameLoad_SetMusic
	;If new music same as current music, don't load music
	lda LevelMusicTable,y
	cmp CurMusic
	beq RunGameSubmode_MainGameLoad_NoSetMusic
RunGameSubmode_MainGameLoad_SetMusic:
	;Clear sound
	jsr ClearSound
	;Clear fadeout state
	lda #$00
	sta SoundFadeoutCounter
	sta SoundFadeoutTimer
	sta SoundFadeout
	;Play music
	lda LevelMusicTable,y
	sta CurMusic
	jsr LoadSound
RunGameSubmode_MainGameLoad_NoSetMusic:
	;Next submode ($03: Main gameplay)
	inc MainGameSubmode
	;Add IRQ buffer region (Main game)
	lda #$01
	jsr AddIRQBufferRegion
	;Add IRQ buffer region (HUD)
	lda #$02
	jmp AddIRQBufferRegion

LevelHUDCHRBankTable:
	.db $70,$72,$72
	.db $70,$70,$70
	.db $70,$70,$70
	.db $70,$70,$70
	.db $70,$70,$70
	.db $70,$70,$70
LevelBankTable:
	.db $30,$30,$34,$32,$32,$34
LevelMusicTable:
	;$00
	.db MUSIC_LEVEL1
	.db MUSIC_LEVEL1
	.db MUSIC_BOSS
	;$03
	.db MUSIC_LEVEL2
	.db MUSIC_LEVEL2
	.db MUSIC_BOSS
	;$06
	.db MUSIC_LEVEL3
	.db SE_FALLSTART
	.db MUSIC_BOSS
	;$09
	.db MUSIC_LEVEL4
	.db MUSIC_LEVEL4
	.db MUSIC_BOSS
	;$0C
	.db MUSIC_LEVEL5
	.db MUSIC_LEVEL5
	.db MUSIC_BOSS
	;$0F
	.db SE_FALLSTART
	.db MUSIC_BOSSRUSHINT
	.db MUSIC_BOSS

InitLevelScroll:
	;Clear pause disable flag
	lda #$00
	sta PauseDisableFlag
	;Set horizontal mirroring
	lda #$01
	sta $A000
	;Set level area number
	ldy CurLevel
	lda LevelAreaStartTable,y
	clc
	adc CurArea
	sta LevelAreaNum
	;Load CHR banks
	tay
	lda LevelAreaCHRBank0Table,y
	sta TempCHRBanks
	lda LevelAreaCHRBank1Table,y
	sta TempCHRBanks+1
	;Set level area size
	lda LevelAreaWidthTable,y
	sta LevelAreaWidth
	lda LevelAreaHeightTable,y
	sta LevelAreaHeight
	;Setup player entrance
	lda LevelAreaStartScreenYTable,y
	sec
	sbc #$02
	sta CurScreenY
	lda LevelAreaStartScreenXTable,y
	sta CurScreenX
	;Clear scroll position
	lda #$00
	sta TempMirror_PPUSCROLL_X
	sta TempMirror_PPUSCROLL_Y
	;Clear item collected bits
	sta ItemCollectedBits
	sta ItemCollectedBits+1
	;Load CHR banks
	lda LevelAreaCHRBank3Table,y
	sta TempCHRBanks+3
	lda #$02
	sta TempCHRBanks+4
	;Init tile/collision scroll position
	lda #$07
	sta ScrollXTilePos
	lda #$04
	sta ScrollYCollPosHi
	sta ScrollXCollPosHi
	;Init HUD row
	lda #$04
	sta HUDRowIndex
	;Load PRG bank $32 (get HUD position bank)
	lda #$32
	jsr LoadPRGBank
	jsr GetHUDPosition
InitLevelScroll_Loop:
	;Go to next screen
	inc ScrollYCollPosLo
	inc TempMirror_PPUSCROLL_Y
	lda TempMirror_PPUSCROLL_Y
	cmp #$F0
	bcc InitLevelScroll_NoYC
	lda #$00
	sta TempMirror_PPUSCROLL_Y
	inc CurScreenY
	inc ScrollInitScreenCounter
InitLevelScroll_NoYC:
	;Load level PRG bank
	ldy CurLevel
	lda LevelBankTable,y
	jsr LoadPRGBank
	;Draw screen of tiles
	jsr UpdateLevelScroll
	;Load PRG bank $32 (update HUD bank)
	lda #$32
	jsr LoadPRGBank
	;Update HUD
	jsr UpdateHUD
	;End VRAM buffer
	lda #$00
	jsr WriteVRAMBufferCmd
	;Disable video out
	jsr DisableVideoOut
	;Write HUD to VRAM
	jsr WriteHUD
	;Write VRAM buffer
	jsr WriteVRAMBuffer
	;Set PPU control register
	jsr SetScroll_SetCtrl
	;Loop for each screen
	lda ScrollInitScreenCounter
	cmp #$02
	bne InitLevelScroll_Loop
	;Set nametable
	lda TempMirror_PPUCTRL
	and #$FC
	sta TempMirror_PPUCTRL
	lda CurScreenY
	lsr
	bcc InitLevelScroll_NoYC2
	lda TempMirror_PPUCTRL
	ora #$02
	sta TempMirror_PPUCTRL
InitLevelScroll_NoYC2:
	;Load PRG bank
	lda #$30
	jsr LoadPRGBank
	;Set fade timer
	lda #$06
	sta FadeTimer
	;Set palette
	lda LevelAreaNum
	asl
	sta CurPalette
	;Fade palette
	jsr FadePalette
	;End VRAM buffer
	lda #$00
	jsr WriteVRAMBufferCmd
	;Disable video out
	jsr DisableVideoOut
	;Write VRAM buffer
	jsr WriteVRAMBuffer
	;Set PPU control register
	jsr SetScroll_SetCtrl
	;Set HUD CHR bank
	ldy LevelAreaNum
	lda LevelHUDCHRBankTable,y
	sta HUDCHRBank
	;Set player respawn position
	lda #$80
	sta PlayerRespawnXHi
	sta PlayerRespawnXHi+1
	;Clear black screen timer
	lda #$00
	sta BlackScreenTimer
	rts

;$03: Main gameplay
RunGameSubmode_MainGamePlay:
	;Check to pause game
	jsr CheckPause
	;If gameplay paused, exit early
	lda PausedFlag
	beq RunGameSubmode_MainGamePlay_CheckVictory
	rts
RunGameSubmode_MainGamePlay_Victory:
	;Next submode ($04: Victory)
	inc MainGameSubmode
	;Set timer
	lda #$00
	sta GameModeTimer2
	;Play music
	lda #MUSIC_CLEAR
	jsr LoadSound
RunGameSubmode_MainGamePlay_NoWarp:
	;Load PRG bank $36 (control player bank)
	lda #$36
	jsr LoadPRGBank
	;Control player
	jsr ControlPlayer
	;Load level PRG bank
	ldy CurLevel
	lda LevelBankTable,y
	jsr LoadPRGBank
	;Update level scroll
	jsr UpdateLevelScroll
	;Fade palette
	jsr FadePalette
	;Load PRG bank $32 (update HUD bank)
	lda #$32
	jsr LoadPRGBank
	;Update HUD
	jsr UpdateHUD
	;Set PPU mask register
	lda Mirror_PPUMASK
	and #$FC
	sta PPU_MASK
	;Update enemy BG movement
	jmp UpdateEnemyBGMovement
RunGameSubmode_MainGamePlay_CheckVictory:
	;Check for victory
	lda VictoryFlag
	bne RunGameSubmode_MainGamePlay_Victory
	;Check for warp
	lda WarpFlag
	beq RunGameSubmode_MainGamePlay_NoWarp
RunGameSubmode_MainGamePlay_Warp:
	;Next submode ($05: Fade out)
	lda #$05
	sta MainGameSubmode
	;Fade palette
	jsr FadePalette
	;Load PRG bank $32 (update HUD bank)
	lda #$32
	jsr LoadPRGBank
	;Update HUD
	jsr UpdateHUD
	;Set fade timer
	lda #$07
	sta FadeTimer
	rts

InitPlayerState:
	;Load PRG bank $36 (player routines bank)
	lda #$36
	jsr LoadPRGBank
	;Clear player inactive counter
	lda #$00
	sta $10
	;Do tasks for both players
	ldx #$01
InitPlayerState_Loop:
	;Check for death mode
	lda PlayerMode,x
	cmp #$04
	beq InitPlayerState_Death
	;Check for main mode
	cmp #$03
	beq InitPlayerState_Main
	;Check for respawn mode
	cmp #$02
	beq InitPlayerState_Respawn
InitPlayerState_CheckInit:
	;Check for init mode
	lda PlayerMode,x
	cmp #$01
	bcs InitPlayerState_NoInit
	;Increment player inactive counter
	inc $10
InitPlayerState_NoInit:
	;Clear player
	jsr ClearPlayer_NoFirst
	;Clear key animation flag
	lda PlayerKeyFlags,x
	and #$FD
	sta PlayerKeyFlags,x
	;Loop for each player
	dex
	bpl InitPlayerState_Loop
	rts
InitPlayerState_Main:
	;Check for hit state
	lda PlayerState,x
	cmp #$0A
	bne InitPlayerState_CheckState
	;If player HP not 0, skip this part
	lda PlayerHP,x
	bne InitPlayerState_Respawn
InitPlayerState_Death:
	;Respawn player
	jsr SetPlayerRespawn
	;Handle player death
	jsr HandlePlayerDeath
	jmp InitPlayerState_CheckInit
InitPlayerState_CheckState:
	;Check for death state
	cmp #$0B
	bne InitPlayerState_Respawn
	beq InitPlayerState_Death
InitPlayerState_Respawn:
	;Next mode ($02: Death)
	lda #$02
	sta PlayerMode,x
	;Set respawn start flag
	sta PlayerRespawnStartFlag,x
	bne InitPlayerState_CheckInit

;$04: Victory
RunGameSubmode_MainGameVictory:
	;Decrement timer, check if 0
	dec GameModeTimer2
	beq RunGameSubmode_MainGamePlay_Warp
	jmp RunGameSubmode_MainGamePlay_NoWarp

;$05: Fade out
RunGameSubmode_MainGameFadeOut:
	;Set fade direction
	lda #$02
	sta FadeDirection
	;Fade palette
	jsr FadePalette
	;Load PRG bank $32 (update HUD bank)
	lda #$32
	jsr LoadPRGBank
	;Update HUD
	jsr UpdateHUD
	;Check if finished fading
	lda FadeDoneFlag
	bne RunGameSubmode_MainGameFadeOut_Exit
	;Clear autoscroll/fixed camera flags
	lda #$00
	sta AutoScrollDirFlags
	sta TempScrollLockFlags
	;Clear elevator Y position
	sta ElevatorYPos
	;Init player state
	jsr InitPlayerState
	;If both players inactive, go to next mode ($08: Game over)
	lda $10
	cmp #$02
	beq RunGameSubmode_MainGameFadeOut_GameOver
	;Check for last area in level
	lda LevelAreaNum
	cmp #$10
	beq RunGameSubmode_MainGameFadeOut_StageClear
	lda CurArea
	cmp #$02
	bcc RunGameSubmode_MainGameFadeOut_NextArea
RunGameSubmode_MainGameFadeOut_StageClear:
	;Increment current level
	inc CurLevel
	;Clear key flags
	lda #$00
	sta PlayerKeyFlags
	sta PlayerKeyFlags+1
	;Clear current area
	sta CurArea
	;Clear save key enemies flag
	sta SaveKeyEnemiesFlag
	;Do tasks for both players
	ldx #$01
RunGameSubmode_MainGameFadeOut_Loop:
	;Check for respawn mode
	lda PlayerMode,x
	cmp #$02
	bne RunGameSubmode_MainGameFadeOut_Next
	;Reset player HP
	lda #$05
	sta PlayerHP,x
RunGameSubmode_MainGameFadeOut_Next:
	;Loop for each player
	dex
	bpl RunGameSubmode_MainGameFadeOut_Loop
	;Next mode ($07: Stage clear)
	jmp GoToNextGameMode
RunGameSubmode_MainGameFadeOut_GameOver:
	;Clear sound
	jsr ClearSound
	;Next mode ($08: Game over)
	inc GameMode
	jmp GoToNextGameMode
RunGameSubmode_MainGameFadeOut_NextArea:
	;Increment current area
	inc CurArea
	;Set save key enemies flag
	lda #$01
	sta SaveKeyEnemiesFlag
	;Check if key is active for player 1
	lda PlayerKeyFlags
	beq RunGameSubmode_MainGameFadeOut_NoKeyP1
	;Set key animation flag for player 1
	lda PlayerKeyFlags
	ora #$02
	sta PlayerKeyFlags
RunGameSubmode_MainGameFadeOut_NoKeyP1:
	;Check if key is active for player 2
	lda PlayerKeyFlags+1
	beq RunGameSubmode_MainGameFadeOut_NoKeyP2
	;Set key animation flag for player 2
	lda PlayerKeyFlags+1
	ora #$02
	sta PlayerKeyFlags+1
RunGameSubmode_MainGameFadeOut_NoKeyP2:
	;Next submode ($01: Init)
	lda #$01
	sta MainGameSubmode
RunGameSubmode_MainGameFadeOut_Exit:
	rts

CheckPause:
	;Check if pausing is enabled
	lda DemoFlag
	ora PauseDisableFlag
	ora BlackScreenTimer
	bne CheckPause_Exit
	;Check if paused
	lda TempJoypadDown
	ora TempJoypadDown+1
	ldy PausedFlag
	bne CheckPause_Unpause
	;Check for START press
	and #JOY_START
	beq CheckPause_Exit
	;Set paused flag
	lda #$01
	sta PausedFlag
	;Play sound
	lda #SE_PAUSE
	jmp LoadSound
CheckPause_Unpause:
	;Check for START press
	and #JOY_START
	beq CheckPause_Exit
	;Clear paused flag
	lda #$00
	sta PausedFlag
CheckPause_Exit:
	rts

LevelAreaWidthTable:
	.db $0B,$0F,$03
	.db $06,$0B,$03
	.db $0A,$0B,$03
	.db $0E,$08,$04
	.db $0F,$10,$03
	.db $14,$0A,$03
LevelAreaHeightTable:
	.db $02,$08,$01
	.db $02,$02,$01
	.db $03,$05,$01
	.db $03,$0A,$03
	.db $02,$02,$01
	.db $09,$07,$02
LevelAreaStartScreenXTable:
	.db $01,$01,$01
	.db $01,$01,$01
	.db $01,$01,$01
	.db $0C,$01,$02
	.db $01,$01,$01
	.db $01,$01,$01
LevelAreaStartScreenYTable:
	.db $01,$01,$00
	.db $01,$00,$00
	.db $00,$00,$00
	.db $02,$09,$01
	.db $01,$01,$00
	.db $01,$01,$01
Level11LayoutData:
	.db $80,$80,$00,$01,$02,$03,$04,$05,$06,$80,$80
	.db $C7,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$CF
Level12LayoutData:
	.db $80,$80,$00,$01,$02,$03,$04,$80,$80,$80,$80,$80,$80,$80,$80
	.db $C5,$45,$46,$47,$08,$09,$0A,$0B,$80,$80,$80,$80,$80,$80,$80
	.db $80,$80,$80,$80,$0C,$0D,$0E,$0F,$10,$80,$80,$80,$80,$80,$80
	.db $80,$80,$80,$80,$51,$12,$13,$14,$15,$20,$80,$80,$80,$80,$80
	.db $80,$80,$80,$80,$80,$56,$17,$18,$19,$21,$22,$80,$80,$80,$80
	.db $80,$80,$80,$80,$80,$80,$5A,$1B,$1C,$23,$24,$25,$80,$80,$80
	.db $80,$80,$80,$80,$80,$80,$80,$5D,$1E,$26,$27,$28,$29,$2A,$AA
	.db $80,$80,$80,$80,$80,$80,$80,$80,$5F,$6B,$6C,$6D,$6E,$6F,$EF
Level13LayoutData:
	.db $C0,$40,$C0
Level21LayoutData:
	.db $80,$00,$01,$02,$03,$80
	.db $C4,$44,$45,$46,$47,$C7
Level22LayoutData:
	.db $C0,$40,$41,$42,$43,$04,$05,$06,$07,$08,$C8
	.db $80,$80,$80,$80,$80,$49,$4A,$4B,$4C,$4D,$8D
Level31LayoutData:
	.db $80,$00,$08,$80,$80,$80,$80,$80,$80,$80
	.db $C9,$09,$01,$02,$03,$04,$05,$06,$07,$87
	.db $80,$4A,$4A,$4B,$4C,$4D,$4E,$4F,$50,$D0
Level32LayoutData:
	.db $80,$00,$80,$80,$80,$80,$80,$80,$80,$80,$80
	.db $80,$01,$80,$80,$80,$80,$80,$80,$80,$80,$80
	.db $80,$02,$80,$80,$80,$80,$80,$80,$80,$80,$80
	.db $80,$03,$80,$80,$80,$80,$80,$80,$80,$80,$80
	.db $C4,$44,$45,$46,$47,$48,$48,$49,$49,$4A,$8A
Level33LayoutData:
	.db $80,$40,$80
Level41LayoutData:
	.db $80,$40,$41,$42,$43,$44,$43,$44,$45,$46,$07,$08,$09,$80
	.db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$0D,$0E,$0F,$80
	.db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$4A,$4B,$4C,$80
Level42LayoutData:
	.db $80,$80,$80,$80,$54,$55,$47,$D7
	.db $80,$80,$80,$80,$80,$80,$80,$80
	.db $80,$80,$80,$80,$00,$01,$80,$80
	.db $80,$8B,$80,$80,$02,$03,$80,$80
	.db $80,$08,$09,$46,$44,$45,$80,$80
	.db $80,$0A,$0B,$80,$80,$80,$80,$80
	.db $80,$0C,$0D,$80,$80,$80,$80,$80
	.db $80,$0E,$0F,$80,$80,$80,$80,$80
	.db $80,$10,$11,$80,$80,$80,$80,$80
	.db $D2,$52,$53,$D3,$80,$80,$80,$80
Level43LayoutData:
	.db $00,$00,$00,$00
	.db $00,$00,$01,$00
	.db $00,$00,$00,$00
Level51LayoutData:
	.db $80,$80,$80,$80,$80,$80,$81,$01,$02,$03,$04,$00,$00,$80,$80
	.db $C5,$45,$45,$45,$46,$47,$48,$49,$4A,$4B,$4C,$45,$45,$4D,$CD
Level52LayoutData:
	.db $80,$00,$01,$01,$01,$02,$82,$80,$80,$80,$80,$80,$80,$80,$80,$80
	.db $C3,$43,$44,$44,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$CE
Level53LayoutData:
	.db $80,$40,$80
Level61LayoutData:
	.db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	.db $80,$00,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	.db $80,$10,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	.db $80,$41,$42,$43,$44,$45,$06,$07,$07,$07,$07,$48,$49,$4A,$4B,$4C,$0D,$80,$80,$80
	.db $80,$80,$80,$80,$80,$80,$51,$51,$51,$51,$51,$80,$80,$80,$80,$80,$12,$80,$80,$80
	.db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$12,$80,$80,$80
	.db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$12,$80,$80,$80
	.db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$12,$80,$80,$80
	.db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$4E,$4F,$53,$80
Level62LayoutData:
	.db $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	.db $C0,$40,$01,$80,$80,$80,$09,$09,$09,$09
	.db $80,$80,$45,$01,$80,$80,$09,$09,$0A,$09
	.db $80,$80,$80,$45,$02,$80,$09,$09,$09,$00
	.db $09,$09,$09,$09,$46,$07,$80,$80,$80,$80
	.db $09,$09,$0A,$09,$80,$46,$08,$80,$80,$80
	.db $09,$09,$09,$09,$80,$80,$45,$43,$44,$80
Level63LayoutData:
	.db $80,$80,$80
	.db $80,$40,$80
LevelScrollPointerTable:
	.dw Level11ScrollData
	.dw Level12ScrollData
	.dw Level13ScrollData
	.dw Level21ScrollData
	.dw Level22ScrollData
	.dw Level13ScrollData
	.dw Level31ScrollData
	.dw Level32ScrollData
	.dw Level33ScrollData
	.dw Level41ScrollData
	.dw Level42ScrollData
	.dw Level43ScrollData
	.dw Level51ScrollData
	.dw Level52ScrollData
	.dw Level13ScrollData
	.dw Level61ScrollData
	.dw Level62ScrollData
	.dw Level63ScrollData
Level11ScrollData:
	.db $00,$DD,$DD,$DD,$D0,$00
	.db $0D,$DD,$DD,$DD,$DD,$00
Level12ScrollData:
	.db $0D,$DD,$55,$55,$55,$55,$55,$50
	.db $0D,$DD,$D5,$55,$55,$55,$55,$50
	.db $0D,$DD,$DD,$55,$55,$55,$55,$50
	.db $0D,$DD,$DD,$D5,$55,$55,$55,$50
	.db $0D,$DD,$DD,$DD,$55,$55,$55,$50
	.db $0D,$DD,$DD,$DD,$D5,$55,$55,$50
	.db $0D,$DD,$DD,$DD,$DD,$55,$55,$50
	.db $0D,$DD,$DD,$DD,$DD,$DD,$DD,$D0
Level13ScrollData:
	.db $00,$00
Level21ScrollData:
	.db $0E,$EE,$E0
	.db $0D,$DD,$D0
Level22ScrollData:
	.db $0D,$DD,$DD,$DD,$DD,$00
	.db $00,$00,$0D,$DD,$DD,$00
Level31ScrollData:
	.db $04,$00,$00,$00,$00
	.db $05,$55,$55,$55,$50
	.db $05,$55,$55,$55,$50
Level32ScrollData:
	.db $F4,$FF,$FF,$FF,$FF,$FF
	.db $F4,$FF,$FF,$FF,$FF,$FF
	.db $F4,$FF,$FF,$FF,$FF,$FF
	.db $F4,$FF,$FF,$FF,$FF,$FF
	.db $F5,$11,$11,$11,$11,$11
Level33ScrollData:
	.db $00,$00
Level41ScrollData:
	.db $0E,$EE,$EE,$EE,$EE,$AA,$A0
	.db $00,$00,$00,$00,$00,$BB,$B0
	.db $00,$00,$00,$00,$00,$BB,$B0
Level42ScrollData:
	.db $00,$00,$33,$D0
	.db $00,$00,$00,$00
	.db $00,$00,$33,$00
	.db $00,$00,$33,$00
	.db $0D,$DD,$33,$00
	.db $0F,$F0,$00,$00
	.db $0F,$F0,$00,$00
	.db $0F,$F0,$00,$00
	.db $0F,$F0,$00,$00
	.db $0F,$F0,$00,$00
Level43ScrollData:
	.db $00,$00
	.db $33,$33
	.db $00,$00
Level51ScrollData:
	.db $00,$00,$00,$0D,$DD,$DD,$D0,$00
	.db $01,$11,$11,$1D,$DD,$DD,$DD,$00
Level52ScrollData:
	.db $0D,$DD,$DD,$D0,$00,$00,$00,$00
	.db $0D,$DD,$DD,$D1,$11,$11,$11,$10
Level61ScrollData:
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $04,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $04,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $05,$11,$11,$11,$11,$11,$11,$11,$10,$00
	.db $00,$00,$00,$11,$11,$10,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$11,$10
Level62ScrollData:
	.db $00,$00,$00,$00,$00
	.db $01,$10,$00,$00,$00
	.db $00,$11,$00,$00,$00
	.db $00,$01,$10,$00,$00
	.db $33,$33,$11,$00,$00
	.db $33,$33,$01,$10,$00
	.db $33,$33,$00,$11,$10
Level63ScrollData:
	.db $00,$00
	.db $00,$00

;;;;;;;;;;;;;;;;
;ENEMY ROUTINES;
;;;;;;;;;;;;;;;;
EnemyPRGBankTable:
	.db $3B,$39,$37,$37,$39,$39

UpdateEnemyBGMovement:
	;Load PRG bank $36 (level enemy bank)
	lda #$36
	jsr LoadPRGBank
	;Check for load level submode
	lda MainGameSubmode
	cmp #$02
	bne UpdateEnemyBGMovement_NoLoad
	;Clear enemies
	ldx #$11
UpdateEnemyBGMovement_ClearLoop:
	;Check to save key enemies
	lda SaveKeyEnemiesFlag
	beq UpdateEnemyBGMovement_Clear
	;Check for key enemy slots
	cpx #$02
	bcs UpdateEnemyBGMovement_Clear
	;Check for key held task
	lda Enemy_Mode,x
	cmp #$02
	beq UpdateEnemyBGMovement_ClearNext
UpdateEnemyBGMovement_Clear:
	;Clear enemy
	jsr ClearEnemy
UpdateEnemyBGMovement_ClearNext:
	;Loop for each enemy
	dex
	bpl UpdateEnemyBGMovement_ClearLoop
	;Get enemy PRG bank
	ldy CurLevel
	lda EnemyPRGBankTable,y
	sta EnemyPRGBank
	;Offset scroll X position for first column
	lda TempMirror_PPUSCROLL_X
	sta $18
	clc
	adc #$70
	sta TempMirror_PPUSCROLL_X
	lda CurScreenX
	sta $19
	adc #$01
	sta CurScreenX
	;Check for right level bounds
	cmp LevelAreaWidth
	bcc UpdateEnemyBGMovement_NoBoundR
	;Set scroll X position for right level bounds
	lda #$30
	sta TempMirror_PPUSCROLL_X
UpdateEnemyBGMovement_NoBoundR:
	;Set X scroll direction left
	lda #$02
	sta ScrollDirectionFlags
UpdateEnemyBGMovement_LoadLoop:
	;Offset scroll X position for next column
	lda TempMirror_PPUSCROLL_X
	sta SaveScrollX
	sec
	sbc #$10
	sta TempMirror_PPUSCROLL_X
	bcs UpdateEnemyBGMovement_NoLoadC
	dec CurScreenX
UpdateEnemyBGMovement_NoLoadC:
	;Update enemy BG movement
	jsr MoveEnemies
	;Check to load level enemies
	jsr CheckLevelEnemies
	;Loop for each column
	lda TempMirror_PPUSCROLL_X
	cmp $18
	bne UpdateEnemyBGMovement_LoadLoop
	lda CurScreenX
	cmp $19
	bne UpdateEnemyBGMovement_LoadLoop
	;Check for level 3 boss area
	lda LevelAreaNum
	cmp #$08
	bne UpdateEnemyBGMovement_Exit
	;Load PRG bank $38 (level 3 boss nametable data bank)
	lda #$38
	jsr LoadPRGBank
	;Write level 3 boss nametable
	ldx #$0E
	jmp WriteNametableData
UpdateEnemyBGMovement_Exit:
	rts
UpdateEnemyBGMovement_NoLoad:
	;Update enemy BG movement
	jsr MoveEnemies
	;Check to load level enemies
	jsr CheckLevelEnemies
	;Clear player hit flags
	lda #$00
	sta PlayerHitFlags
	sta PlayerHitFlags+1
	;Load enemy PRG bank
	jsr LoadEnemyPRGBank
	;Loop for enemy
	ldx #$11
UpdateEnemyBGMovement_RunLoop:
	;Check if enemy is active
	lda Enemy_ID,x
	beq UpdateEnemyBGMovement_RunNext
	;Check to run enemy subroutine while invincible
	stx CurEnemyIndex
	lda Enemy_Temp0,x
	bmi UpdateEnemyBGMovement_Run
	;If enemy invincibility timer >= $10, don't run enemy subroutine
	lda Enemy_InvinTimer,x
	cmp #$10
	bcs UpdateEnemyBGMovement_NoRun
UpdateEnemyBGMovement_Run:
	;Run enemy subroutine
	jsr RunEnemy
	;Check for enemy ID $F4-$FF
	ldx CurEnemyIndex
	lda Enemy_ID,x
	cmp #$F4
	bcs UpdateEnemyBGMovement_CheckHitAttack
	;Check for enemy ID $F0-$F3
	cmp #$F0
	bcs UpdateEnemyBGMovement_NoInvin
	;If enemy invincibility timer not 0, decrement and check for flash
	lda Enemy_InvinTimer,x
	beq UpdateEnemyBGMovement_NoInvin
UpdateEnemyBGMovement_NoRun:
	;Check for boss mode
	ldy SpriteBossModeFlag
	beq UpdateEnemyBGMovement_NoFlash
	;Check for ending area
	ldy LevelAreaNum
	cpy #$11
	beq UpdateEnemyBGMovement_NoFlash
	;Check for boss enemy slot
	cpx #$02
	bne UpdateEnemyBGMovement_NoFlash
	;Set boss palette flash flag based on bit 1 of invincibility timer
	and #$02
	beq UpdateEnemyBGMovement_SetFlash
	lda #$FF
UpdateEnemyBGMovement_SetFlash:
	sta BossPaletteFlashFlag
UpdateEnemyBGMovement_NoFlash:
	;Decrement enemy invincibility timer
	dec Enemy_InvinTimer,x
	bpl UpdateEnemyBGMovement_NoHitAttack
UpdateEnemyBGMovement_NoInvin:
	;Check for key enemy slots
	cpx #$02
	bcc UpdateEnemyBGMovement_CheckHitAttack
	;If bit 0 of global timer = bit 0 of enemy slot index, don't check for collision
	lda GlobalTimer
	eor CurEnemyIndex
	lsr
	bcc UpdateEnemyBGMovement_RunNext
UpdateEnemyBGMovement_CheckHitAttack:
	;If enemy offscreen, don't check for collision
	lda Enemy_XHi+$08,x
	ora Enemy_YHi+$08,x
	bne UpdateEnemyBGMovement_NoHitAttack
	;If enemy mode 0, don't check for collision
	lda Enemy_Mode,x
	beq UpdateEnemyBGMovement_NoHitAttack
	;Check for collision
	jsr CheckAttackCollision
UpdateEnemyBGMovement_NoHitAttack:
	;Check if enemy offscreen
	jsr CheckOffscreen
	ldx CurEnemyIndex
UpdateEnemyBGMovement_RunNext:
	;Loop enemy
	dex
	bpl UpdateEnemyBGMovement_RunLoop
	rts

RunEnemy:
	;Check for enemy ID $F0-$FF
	lda Enemy_ID,x
	cmp #$F0
	bcs RunEnemy_EnemyF0
	;Check for enemy ID $80-$EF
	asl
	tay
	bcs RunEnemy_Enemy80
	;Handle enemy ID $00-$7F
	lda EnemyJumpTableTable-2,y
	sta $00
	lda EnemyJumpTableTable-2+1,y
	jmp RunEnemy_DoJump
RunEnemy_Enemy80:
	;Handle enemy ID $80-$EF
	lda EnemyJumpTableTable+$100-2,y
	sta $00
	lda EnemyJumpTableTable+$100-2+1,y
	jmp RunEnemy_DoJump
RunEnemy_EnemyF0:
	;Handle enemy ID $F0-$FF
	sbc #$F0
	asl
	tay
	lda EnemyF0JumpTableTable,y
	sta $00
	lda EnemyF0JumpTableTable+1,y
RunEnemy_DoJump:
	sta $01
	;Get jump table offset
	lda Enemy_Mode,x
	asl
	tay
	;Get jump address
	lda ($00),y
	sta $02
	iny
	lda ($00),y
	sta $03
	;Jump to address
	jmp ($02)

;$01: Explosion
Enemy01JumpTable:
	.dw Enemy01_Sub0	;$00  Init
	.dw Enemy01_Sub1	;$01  Main
;$00: Init
Enemy01_Sub0:
	;Clear enemy animation offset/timer
	lda #$FF
	sta Enemy_AnimOffs,x
	lda #$00
	sta Enemy_AnimTimer,x
	;Set delay timer
	lda #$14
	sta Enemy_Temp1,x
	;If enemy points 0, don't play sound
	ldy Enemy_Temp2,x
	lda EnemyPointsTable,y
	beq Enemy01_Sub0_NextID
	;Check for looping SFX
	lda #SE_ENEMYDEATH
	bit ExplosionSoundLoopingID
	bpl Enemy01_Sub0_NoLoop
	lda #SE_ENEMYDEATHLOOP
Enemy01_Sub0_NoLoop:
	;Play sound
	jsr LoadSound
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
Enemy01_Sub1:
	;Decrement delay timer, check if 0
	dec Enemy_Temp1,x
	beq Enemy01_Sub1_End
	;Update enemy animation
	jmp UpdateEnemyAnimation
Enemy01_Sub1_End:
	;Get enemy points value
	ldy Enemy_Temp2,x
	lda EnemyPointsTable,y
	sta $00
	lda #$00
	sta $01
	;If no player associated, don't give points
	lda Enemy_Temp5,x
	bmi Enemy01_Sub1_NoPoints
	;Give player points
	tax
	sta $10
	jsr GivePoints
Enemy01_Sub1_NoPoints:
	;Check for boss mode
	ldx CurEnemyIndex
	bit SpriteBossModeFlag
	bpl Enemy01_Sub1_Clear
	;Check for boss enemy slot
	cpx #$02
	bne Enemy01_Sub1_Clear
	;Set victory flag
	inc VictoryFlag
	;Set bonus points value based on current level
	ldy CurLevel
	lda BossBonusPointsTable,y
	ldy $10
	sta PlayerBonusMid,y
Enemy01_Sub1_Clear:
	;Clear enemy
	jmp ClearEnemy

;$02: Explosion 2
Enemy02JumpTable:
	.dw Enemy02_Sub0	;$00  Main
Enemy01_Sub0_NextID:
	;Set enemy ID $02 (explosion 2)
	inc Enemy_ID,x
;$00: Main
Enemy02_Sub0:
	;Update enemy animation
	jsr UpdateEnemyAnimation
	;Check for end of animation
	lda Enemy_Sprite+$08,x
	beq Enemy01_Sub1_Clear
	rts

CheckOffscreen:
	;If enemy allowed offscreen, exit early
	lda Enemy_Flags,x
	and #EF_ALLOWOFFSCREEN
	bne CheckOffscreen_Exit
	;If enemy offscreen horizontally, clear enemy
	lda Enemy_XHi+$08,x
	beq CheckOffscreen_CheckY
	asl
	lda Enemy_X+$08,x
	bcs CheckOffscreen_Left
	cmp #$40
	bcc CheckOffscreen_CheckY
	bcs ClearEnemy
CheckOffscreen_Left:
	cmp #$C0
	bcc ClearEnemy
CheckOffscreen_CheckY:
	;If enemy offscreen vertically, clear enemy
	lda Enemy_YHi+$08,x
	beq CheckOffscreen_Exit
	bpl ClearEnemy
	lda Enemy_Y+$08,x
	cmp #$B0
	bcc ClearEnemy
CheckOffscreen_Exit:
	rts

ClearEnemy:
	;Check for ending area
	lda LevelAreaNum
	cmp #$11
	beq ClearEnemy_Ending
	;Clear player state
	lda #$00
	sta Enemy_Temp3,x
	sta Enemy_Temp4,x
ClearEnemy_Ending:
	lda #$00
	sta Enemy_Flags,x
	sta Enemy_ID,x
	sta Enemy_Mode,x
	sta Enemy_XHi+$08,x
	sta Enemy_X+$08,x
	sta Enemy_XLo,x
	sta Enemy_YHi+$08,x
	sta Enemy_Y+$08,x
	sta Enemy_YLo,x
	sta Enemy_XVelLo,x
	sta Enemy_XVel,x
	sta Enemy_YVelLo,x
	sta Enemy_YVel,x
	sta Enemy_HP,x
	sta Enemy_Temp0,x
	sta Enemy_Temp1,x
	sta Enemy_AnimOffs,x
	sta Enemy_AnimTimer,x
	sta Enemy_InvinTimer,x
	sta Enemy_Temp2,x
	sta Enemy_Temp5,x
	sta Enemy_Sprite+$08,x
	sta Enemy_Props+$08,x
	rts

MoveEnemyX:
	;Apply enemy X velocity
	lda Enemy_XLo,x
	clc
	adc Enemy_XVelLo,x
	sta Enemy_XLo,x
	ldy #$00
	lda Enemy_XVel,x
	bpl MoveEnemyX_NoXC
	dey
MoveEnemyX_NoXC:
	adc Enemy_X+$08,x
	sta Enemy_X+$08,x
	tya
	adc Enemy_XHi+$08,x
	sta Enemy_XHi+$08,x
	rts

MoveEnemyXY:
	;Apply enemy X velocity
	lda Enemy_XLo,x
	clc
	adc Enemy_XVelLo,x
	sta Enemy_XLo,x
	ldy #$00
	lda Enemy_XVel,x
	bpl MoveEnemyXY_NoXC
	dey
MoveEnemyXY_NoXC:
	adc Enemy_X+$08,x
	sta Enemy_X+$08,x
	tya
	adc Enemy_XHi+$08,x
	sta Enemy_XHi+$08,x

MoveEnemyY:
	;Check if moving up or down
	ldy Enemy_YVel,x
	bpl MoveEnemyY_Down
	;Apply enemy Y velocity (up)
	sec
	lda #$00
	sbc Enemy_YVelLo,x
	sta $00
	lda #$00
	sbc Enemy_YVel,x
	sta $01
	sec
	lda Enemy_YLo,x
	sbc $00
	sta Enemy_YLo,x
	lda Enemy_Y+$08,x
	sbc $01
	bcs MoveEnemyY_UpNoYC
	sbc #$0F
	dec Enemy_YHi+$08,x
MoveEnemyY_UpNoYC:
	sta Enemy_Y+$08,x
	rts
MoveEnemyY_Down:
	;Apply enemy Y velocity (down)
	clc
	lda Enemy_YVelLo,x
	adc Enemy_YLo,x
	sta Enemy_YLo,x
	tya
	adc Enemy_Y+$08,x
	bcs MoveEnemyY_DownNoYC
	cmp #$F0
	bcc MoveEnemyY_DownSetY
MoveEnemyY_DownNoYC:
	adc #$0F
	inc Enemy_YHi+$08,x
MoveEnemyY_DownSetY:
	sta Enemy_Y+$08,x
	rts

EnemyXVelTable:
	.db $FF,$01
	.db $FF,$00
	.db $FE,$01
	.db $FF,$00
	.db $FF,$00
	.db $FE,$02
	.db $FE,$01
	.db $FF,$00
	.db $FE,$01
	.db $FF,$00
EnemyXVelLoTable:
	.db $00,$20
	.db $60,$A0
	.db $E0,$20
	.db $FF,$00
	.db $80,$80
	.db $00,$00
	.db $C0,$40
	.db $C0,$40
	.db $40,$C0
	.db $00,$FF
SetEnemyXVel:
	;Compare against player 1 X position
	ldy #$00
SetEnemyXVel_AnyY:
	;Next task
	inc Enemy_Mode,x
SetEnemyXVel_NoNextMode:
	;Set enemy velocity data table offset
	sta $00
	;Check if player is to left or right
	lda Enemy_X+$08,x
	sec
	sbc Enemy_X,y
	ldy Enemy_XHi+$08,x
	bcs SetEnemyXVel_NoXC
	dey
SetEnemyXVel_NoXC:
	;Get enemy velocity data table offset
	tya
	asl
	rol
	and #$01
	ora $00
	tay
	;Set enemy X velocity
	lda EnemyXVelLoTable,y
	sta Enemy_XVelLo,x
	lda EnemyXVelTable,y
	sta Enemy_XVel,x
	;Flip enemy X according to player relative X position
	lsr
	and #$40
	sta Enemy_Props+$08,x
	;Check to load CHR bank
	ldy Enemy_ID,x
	lda EnemyCHRBankTable,y
	beq SetEnemyXVel_Exit
	sta TempCHRBanks+2
SetEnemyXVel_Exit:
	rts

FindClosestPlayerX:
	;Check if player 1 is active
	ldy #$00
	lda PlayerMode
	cmp #$02
	bcc FindClosestPlayerX_NoP1
	;Check if player 2 is active
	lda PlayerMode+1
	cmp #$02
	bcc FindClosestPlayerX_Exit
	;Find which player is closest to enemy X
	lda #$FF
	sta $00
	iny
FindClosestPlayerX_Loop:
	;Subtract enemy X position from player X position
	sec
	lda Enemy_XHi+$08,x
	beq FindClosestPlayerX_NoXC
	eor #$FF
	jmp FindClosestPlayerX_SetX
FindClosestPlayerX_NoXC:
	lda Enemy_X+$08,x
FindClosestPlayerX_SetX:
	sbc Enemy_X,y
	bcs FindClosestPlayerX_NoXC2
	eor #$FF
FindClosestPlayerX_NoXC2:
	adc #$01
	;Check if X distance is less than current minimum
	cmp $00
	bcs FindClosestPlayerX_Next
	;Set closest player distance
	sta $00
	;Set closest player index
	sty $01
FindClosestPlayerX_Next:
	;Loop for each player
	dey
	bpl FindClosestPlayerX_Loop
	;Get closest player index
	ldy $01
FindClosestPlayerX_Exit:
	rts
FindClosestPlayerX_NoP1:
	;Check if player 2 is active
	lda PlayerMode+1
	cmp #$02
	bcc FindClosestPlayerX_SetP1Pos
	;Set closest player index for player 2
	iny
FindClosestPlayerX_SetP1Pos:
	;Set player 1 position
	lda #$80
	sta Enemy_X
	sta Enemy_Y
	rts

EnemyGetCollisionType:
	;Get collision check X point
	lda $00
	clc
	adc Enemy_X+$08,x
	sta $08
	lda #$00
	bit $00
	bpl EnemyGetCollisionType_NoXC
	lda #$FF
EnemyGetCollisionType_NoXC:
	adc Enemy_XHi+$08,x
	sta $09
	;Check for Y offset >= 0
	clc
	tya
	bpl EnemyGetCollisionType_Down
	;Handle Y offset < 0
	eor #$FF
	adc #$01
	sta $00
	sec
	lda Enemy_Y+$08,x
	sbc $00
	bcs EnemyGetCollisionType_UpNoYC
	sbc #$0F
	clc
EnemyGetCollisionType_UpNoYC:
	sta $0A
	lda Enemy_YHi+$08,x
	sbc #$00
	jmp EnemyGetCollisionType_SetYHi
EnemyGetCollisionType_Down:
	;Handle Y offset >= 0
	adc Enemy_Y+$08,x
	bcs EnemyGetCollisionType_DownNoYC
	cmp #$F0
	bcc EnemyGetCollisionType_SetY
EnemyGetCollisionType_DownNoYC:
	adc #$0F
	sec
EnemyGetCollisionType_SetY:
	sta $0A
	lda Enemy_YHi+$08,x
	adc #$00
EnemyGetCollisionType_SetYHi:
	sta $0B
	;Get collision type
	jmp GetCollisionType

EnemyGetWallCollision:
	ldy #$00
EnemyGetWallCollision_AnyY:
	;Get wall collision X offset
	sty $17
	lda EnemyWallCollisionXOffsTable,y
	;Check if moving left or right
	ldy Enemy_XVel,x
	bpl EnemyGetWallCollision_PosX
	eor #$FF
	clc
	adc #$01
EnemyGetWallCollision_PosX:
	sta $00
	;Get wall collision Y offset
	ldy $17
	lda EnemyWallCollisionYOffsTable,y
	tay
	;Get wall collision type
	jsr EnemyGetCollisionType
	;Check for solid collision type
	cmp #$16
	rts

EnemyGetGroundCollision:
	ldy #$00
EnemyGetGroundCollision_AnyY:
	;Get ground collision X offset
	sty $17
	lda EnemyGroundCollisionXOffsTable,y
	;Check if moving left or right
	ldy Enemy_XVel,x
	bpl EnemyGetGroundCollision_PosX
	eor #$FF
	clc
	adc #$01
EnemyGetGroundCollision_PosX:
	sta $00
	;Get wall collision Y offset
	ldy $17
	lda EnemyGroundCollisionYOffsTable,y
	tay
	;Get wall collision type
	jsr EnemyGetCollisionType
	;Check for non-slope collision types
	cmp #$13
	rts

CheckPlayerInRangeSpawnVel:
	;If enemy offscreen horizontally, exit early
	sta $00
	lda Enemy_XHi+$08,x
	bne CheckPlayerInRangeSpawnVel_NoPlayers
	;Check if player is in range using spawn X velocity
	ldy #$01
CheckPlayerInRangeSpawnVel_Loop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$02
	bcc CheckPlayerInRangeSpawnVel_Next
	;Check to spawn enemy on left side of screen
	lda Enemy_Temp2,x
	bne CheckPlayerInRangeSpawnVel_Left
	;Get player X distance in front of enemy (right)
	lda Enemy_X+$08,x
	sbc Enemy_X,y
	bcc CheckPlayerInRangeSpawnVel_Next
	;Check if distance >= range value
	sbc $00
	bcc CheckPlayerInRangeSpawnVel_Next
	;Check if distance < range value + $07
	cmp #$07
	bcs CheckPlayerInRangeSpawnVel_Next
	bcc CheckPlayerInRangeSpawnVel_Exit
CheckPlayerInRangeSpawnVel_Left:
	;If enemy X position >= $80, exit early
	lda Enemy_X+$08,x
	bmi CheckPlayerInRangeSpawnVel_NoPlayers
	;Get player X distance in front of enemy (left)
	sbc Enemy_X,y
	bcs CheckPlayerInRangeSpawnVel_Next
	;Check if distance >= range value
	adc $00
	bcs CheckPlayerInRangeSpawnVel_Next
	;Check if distance < range value + $07
	cmp #$F9
	bcs CheckPlayerInRangeSpawnVel_Exit
CheckPlayerInRangeSpawnVel_Next:
	;Loop for each player
	dey
	bpl CheckPlayerInRangeSpawnVel_Loop
CheckPlayerInRangeSpawnVel_NoPlayers:
	;Set player index for no valid players
	ldy #$FF
CheckPlayerInRangeSpawnVel_Exit:
	rts

OffsetEnemyYPos:
	;Offset enemy Y position
	sta $00
	clc
	adc Enemy_Y+$08,x
	sta Enemy_Y+$08,y
	lda #$00
	bit $00
	bpl OffsetEnemyYPos_PosY
	lda #$FF
OffsetEnemyYPos_PosY:
	adc Enemy_YHi+$08,x
	sta Enemy_YHi+$08,y
	;Copy enemy X position
	lda Enemy_X+$08,x
	sta Enemy_X+$08,y
	lda Enemy_XHi+$08,x
	sta Enemy_XHi+$08,y
	;Copy enemy props
	lda Enemy_Props+$08,x
	sta Enemy_Props+$08,y
	rts

InitEnemyTargetYPos:
	;Set enemy Y velocity
	lda #$00
InitEnemyTargetYPos_AnyA:
	sta Enemy_YVelLo,x
	lda #$FF
	sta Enemy_YVel,x
	;Set enemy target Y position
	lda Enemy_Y+$08,x
	ldy Enemy_YHi+$08,x
	beq InitEnemyTargetYPos_Set
	clc
	bpl InitEnemyTargetYPos_Down
	adc #$10
InitEnemyTargetYPos_Down:
	jmp InitEnemyTargetYPos_Set
	adc #$F0
InitEnemyTargetYPos_Set:
	sta Enemy_Temp2,x
	rts

UpdateEnemyTargetYPos:
	;Check if scrolling up or down
	lda Enemy_Temp2,x
	ldy ScrollDirectionFlags
	cpy #$04
	bcc UpdateEnemyTargetYPos_ScrollSet
	cpy #$08
	bcs UpdateEnemyTargetYPos_ScrollUp
	;Apply scroll Y velocity to enemy target Y position (down)
	sec
	sbc ScrollEnemyYVel
	jmp UpdateEnemyTargetYPos_ScrollSet
UpdateEnemyTargetYPos_ScrollUp:
	;Apply scroll Y velocity to enemy target Y position (up)
	clc
	adc ScrollEnemyYVel
UpdateEnemyTargetYPos_ScrollSet:
	sta Enemy_Temp2,x
UpdateEnemyTargetYPos_NoScroll:
	;Get enemy target Y position
	ldy Enemy_YHi+$08,x
	beq UpdateEnemyTargetYPos_Set
	clc
	bmi UpdateEnemyTargetYPos_Up
	adc #$10
	jmp UpdateEnemyTargetYPos_Set
UpdateEnemyTargetYPos_Up:
	adc #$F0
UpdateEnemyTargetYPos_Set:
	;Check if target Y position above or below
	ldy #$00
	sec
	sbc Enemy_Y+$08,x
	bpl UpdateEnemyTargetYPos_NoYC
	dey
UpdateEnemyTargetYPos_NoYC:
	;Adjust enemy Y velocity to target Y position
	clc
	adc Enemy_YVelLo,x
	sta Enemy_YVelLo,x
	tya
	adc Enemy_YVel,x
	sta Enemy_YVel,x
	rts

HandleEnemySlopeCollision:
	;Get collision tile X offset
	lda Enemy_X+$08,x
	clc
	adc TempMirror_PPUSCROLL_X
	and #$0F
	tay

HandleEnemyGroundCollision:
	;Clear enemy Y velocity
	lda #$00
	sta Enemy_YVel,x
	sta Enemy_YVelLo,x
HandleEnemyGroundCollision_NoClearY:
	;Get collision tile Y offset
	lda TempMirror_PPUSCROLL_Y
	clc
	adc Enemy_Y+$08,x
	and #$0F
	sta $00
	;Adjust enemy Y position for collision
	tya
	clc
	adc Enemy_Y+$08,x
	sec
	sbc $00
	bcs HandleEnemyGroundCollision_NoC
	sbc #$0F
	dec Enemy_YHi+$08,x
HandleEnemyGroundCollision_NoC:
	sta Enemy_Y+$08,x
	rts

;$21: Item screw
Enemy21JumpTable:
	.dw Enemy21_Sub0	;$00  Init
	.dw Enemy20_Sub1	;$01  Main
	.dw Enemy21_Sub2	;$02  Held
	.dw Enemy20_Sub3	;$03  Release
;$00: Init
Enemy21_Sub0:
	;Load PRG bank
	lda #$01
	sta TempCHRBanks+3
	;Set enemy sprite
	lda #$01
	bne Enemy20_Sub0_EntScrew
;$02: Held
Enemy21_Sub2:
	;Set enemy sprite
	lda #$01
	bne Enemy20_Sub2_EntScrew
	jmp Enemy20_Sub3

;$20: Item key
Enemy20JumpTable:
	.dw Enemy20_Sub0	;$00  Init
	.dw Enemy20_Sub1	;$01  Main
	.dw Enemy20_Sub2	;$02  Held
	.dw Enemy20_Sub3	;$03  Release
;$00: Init
Enemy20_Sub0:
	;Load CHR bank
	lda #$00
	sta TempCHRBanks+3
	;Set enemy sprite
	lda #$03
Enemy20_Sub0_EntScrew:
	sta Enemy_Sprite+$08,x
	;Move enemy down $07
	lda Enemy_Y+$08,x
	clc
	adc #$07
	bcs Enemy20_Sub0_NoYC
	cmp #$F0
	bcc Enemy20_Sub0_SetY
Enemy20_Sub0_NoYC:
	adc #$10
	inc Enemy_YHi+$08,x
Enemy20_Sub0_SetY:
	sta Enemy_Y+$08,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
Enemy20_Sub1:
	rts
;$02: Held
Enemy20_Sub2:
	;Set enemy sprite
	lda #$03
Enemy20_Sub2_EntScrew:
	sta Enemy_Sprite+$08,x
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|EF_ALLOWOFFSCREEN|$09)
	sta Enemy_Flags,x
Enemy20_Sub2_Exit:
	rts
;$03: Release
Enemy20_Sub3:
	;Set enemy flags
	lda #(EF_NOHITENEMY|EF_NOHITATTACK|$09)
	sta Enemy_Flags,x
	;Move enemy
	jsr MoveEnemyXY
	;Check for boss mode
	bit SpriteBossModeFlag
	bpl Enemy20_Sub3_NoBound
	;Check if enemy offscreen horizontally
	lda Enemy_XHi+$08,x
	beq Enemy20_Sub3_NoBound
	;Set enemy X position for level bounds
	eor #$FF
	sta Enemy_X+$08,x
	lda #$00
	sta Enemy_XHi+$08,x
Enemy20_Sub3_NoBound:
	;If enemy Y velocity >= $05, don't accelerate
	lda Enemy_YVel,x
	bmi Enemy20_Sub3_Accel
	cmp #$05
	bcs Enemy20_Sub3_NoAccel
Enemy20_Sub3_Accel:
	;Accelerate due to gravity
	lda Enemy_YVelLo,x
	clc
	adc #$28
	sta Enemy_YVelLo,x
	bcc Enemy20_Sub3_NoAccel
	inc Enemy_YVel,x
Enemy20_Sub3_NoAccel:
	;If wall collision, flip enemy X
	ldy #$02
	jsr EnemyGetWallCollision_AnyY
	bcs Enemy20_Sub3_Flip
	;Check for behind BG area collision type
	tay
	lda Enemy_Props+$08,x
	and #$DF
	cpy #$02
	bne Enemy20_Sub3_NoBehindBG
	;Set enemy priority to be behind background
	ora #$20
Enemy20_Sub3_NoBehindBG:
	sta Enemy_Props+$08,x
	jmp Enemy20_Sub3_CheckGround
Enemy20_Sub3_Flip:
	;Flip enemy X
	jsr FlipEnemyX
Enemy20_Sub3_CheckGround:
	;If enemy Y velocity up, exit early
	lda Enemy_YVel,x
	bmi Enemy20_Sub2_Exit
	;If no ground collision below enemy, exit early
	ldy #$06
	jsr EnemyGetGroundCollision_AnyY
	bcc Enemy20_Sub2_Exit
	;Get collision type top
	lda $0A
	sbc #$10
	bcs Enemy20_Sub3_NoYC
	dec $0B
	sbc #$0F
Enemy20_Sub3_NoYC:
	sta $0A
	jsr GetCollisionType
	;Check for non-slope collision types
	cmp #$14
	bcc Enemy20_Sub3_NoTop
	;If enemy Y position < player Y position, exit early
	ldy Enemy_Temp2,x
	lda Enemy_Y+$08,x
	cmp Enemy_Y,y
	bcc Enemy20_Sub2_Exit
Enemy20_Sub3_NoTop:
	;If no ground collision below enemy, exit early
	ldy #$05
	jsr EnemyGetGroundCollision_AnyY
	bcc Enemy20_Sub2_Exit
	;Multiply enemy X velocity by 1/2
	lda Enemy_XVel,x
	cmp #$80
	ror Enemy_XVel,x
	ror Enemy_XVelLo,x
	;If enemy X velocity left, multiply enemy X velocity by 1/4
	cmp #$80
	bcc Enemy20_Sub3_Right
	ror Enemy_XVel,x
	ror Enemy_XVelLo,x
Enemy20_Sub3_Right:
	;Multiply enemy Y velocity by -1/2
	lda #$00
	sbc Enemy_YVelLo,x
	sta Enemy_YVelLo,x
	lda #$00
	sbc Enemy_YVel,x
	sec
	ror
	sta Enemy_YVel,x
	ror Enemy_YVelLo,x
	;If enemy Y velocity >= $FF80, go to next task ($01: Main)
	cmp #$FF
	bne Enemy20_Sub3_NoNext
	lda Enemy_YVelLo,x
	cmp #$80
	bcc Enemy20_Sub3_NoNext
	;Next task ($01: Main)
	lda #$01
	sta Enemy_Mode,x
	;Set enemy flags
	lda #(EF_NOHITATTACK|$09)
	sta Enemy_Flags,x
	;Set enemy grounded
	ldy #$08
	jmp HandleEnemyGroundCollision
Enemy20_Sub3_NoNext:
	;Check for item screw
	lda Enemy_ID,x
	cmp #ENEMY_ITEMSCREW
	;Play sound based on enemy ID
	lda #SE_ITEMKEYLAND
	bcc Enemy20_Sub3_LoadSound
	lda #SE_ITEMSCREWLAND
Enemy20_Sub3_LoadSound:
	jsr LoadSound
	;Set enemy grounded
	ldy #$08
	jmp HandleEnemyGroundCollision_NoClearY

;$F0: Item HP
EnemyF0JumpTable:
	.dw EnemyF0_Sub0	;$00  Init
	.dw EnemyF0_Sub1	;$01  Main
;$00: Init
EnemyF0_Sub0:
	;Check if item is already collected
	ldy #$00
	cpx #$08
	bcc EnemyF0_Sub0_Bit0
	iny
EnemyF0_Sub0_Bit0:
	txa
	and #$07
	tax
	lda ItemBitTable,x
	and ItemCollectedBits,y
	beq EnemyF0_Sub0_NoClear
	;Restore X register
	ldx CurEnemyIndex
	;Clear enemy
	jmp ClearEnemy
EnemyF0_Sub0_NoClear:
	;Restore X register
	ldx CurEnemyIndex
	;Move enemy down $07
	lda Enemy_Y+$08,x
	clc
	adc #$07
	bcs EnemyF0_Sub0_NoYC
	cmp #$F0
	bcc EnemyF0_Sub0_SetY
EnemyF0_Sub0_NoYC:
	inc Enemy_YHi+$08,x
	adc #$0F
EnemyF0_Sub0_SetY:
	sta Enemy_Y+$08,x
	;Set enemy sprite
	lda #$06
	sta Enemy_Sprite+$08,x
	;Next task ($01: Main)
	inc Enemy_Mode,x
;$01: Main
EnemyF0_Sub1:
	;Check if collected
	lda Enemy_HP,x
	beq EnemyF0_Sub1_Exit
	;Mark item as collected
	ldy #$00
	cpx #$08
	bcc EnemyF0_Sub1_Bit0
	iny
EnemyF0_Sub1_Bit0:
	txa
	and #$07
	tax
	lda ItemBitTable,x
	ora ItemCollectedBits,y
	sta ItemCollectedBits,y
	;Play sound
	lda #SE_ITEMHP
	jsr LoadSound
	;Restore X register
	ldx CurEnemyIndex
	;Check if player HP $05 (max allowed)
	ldy Enemy_Temp2,x
	lda PlayerHP,y
	cmp #$05
	bcs EnemyF0_Sub1_NoIncHP
	;Increment player HP
	adc #$01
	sta PlayerHP,y
EnemyF0_Sub1_NoIncHP:
	;Clear enemy
	jmp ClearEnemy
EnemyF0_Sub1_Exit:
	rts
ItemBitTable:
	.db $01,$02,$04,$08,$10,$20,$40,$80

;$2D: Warp
Enemy2DJumpTable:
	.dw Enemy2D_Sub0	;$00  Main
;$00: Main
Enemy2D_Sub0:
	;If scroll X position not 0, exit early
	lda TempMirror_PPUSCROLL_X
	bne Enemy2D_Sub0_Exit
	;Get warp direction bits
	lda LevelAreaNum
	lsr
	tay
	lda WarpDirectionTable,y
	bcs Enemy2D_Sub0_MaskLo
	lsr
	lsr
	lsr
	lsr
Enemy2D_Sub0_MaskLo:
	and #$0F
	sta $10
	;Check for player collision
	ldy #$01
Enemy2D_Sub0_Loop:
	;Check if player is active
	lda PlayerMode,y
	cmp #$03
	bne Enemy2D_Sub0_Next
	;Check if player is to left or right
	lda Enemy_X+$08,x
	cmp Enemy_X,y
	bcc Enemy2D_Sub0_Right
	;If player is to left and warp is on left, set warp flag
	lda $10
	bne Enemy2D_Sub0_Next
	beq Enemy2D_Sub0_Warp
Enemy2D_Sub0_Right:
	;If player is to right and warp is on right, set warp flag
	lda $10
	bne Enemy2D_Sub0_Warp
Enemy2D_Sub0_Next:
	;Loop for each player
	dey
	bpl Enemy2D_Sub0_Loop
Enemy2D_Sub0_Exit:
	rts
Enemy2D_Sub0_Warp:
	;Set warp flag
	inc WarpFlag
	rts
WarpDirectionTable:
	.db $11,$10,$11,$11,$10,$11,$11,$11,$11,$11,$11,$11,$11,$11

;;;;;;;;;;;;;;;;;
;SYSTEM ROUTINES;
;;;;;;;;;;;;;;;;;
Reset:
	;Setup CPU
	sei
	cld
	ldx #$FF
	txs
	;Setup PPU
	lda #$00
	sta PPU_CTRL
	sta PPU_MASK
	ldx #$02
Reset_WaitVBlank1:
	bit PPU_STATUS
	bpl Reset_WaitVBlank1
Reset_WaitVBlank2:
	bit PPU_STATUS
	bmi Reset_WaitVBlank2
	dex
	bne Reset_WaitVBlank1
	;Disable IRQ
	sta $E000
	;Init APU registers
	jsr InitAPU
	;Clear RAM
	txa
	sta $00
	sta $01
	ldy #$00
	ldx #$04
Reset_ClearRAM:
	sta ($00),y
	iny
	bne Reset_ClearRAM
	inc $01
	cpx $01
	bne Reset_ClearRAM
	jsr ClearWRAM
	;Clear sound
	jsr ClearSound
	;Enable write protection
	lda #$40
	sta $A001
	;Init APU registers
	lda #$00
	sta DMC_FREQ
	lda #$40
	sta JOY2
	;Init MMC3 mapper
	jsr InitMMC3
	;Load PRG bank
	lda #$30
	jsr LoadPRGBank
	;Check for soft reset
	ldx #$03
Reset_SoftCheckLoop:
	;If soft reset data buffer value not equal, setup hard reset
	lda SoftResetDataBuffer,x
	cmp SoftResetDataTable,x
	bne Reset_HardSet
	;Loop for each byte
	dex
	bpl Reset_SoftCheckLoop
	;If soft reset data buffer equal, skip this part
	bmi Reset_SoftSet
Reset_HardSet:
	;Setup soft reset data buffer
	ldx #$03
Reset_HardSetLoop:
	lda SoftResetDataTable,x
	sta SoftResetDataBuffer,x
	dex
	bpl Reset_HardSetLoop
	;Reset top score
	lda #$03
	sta TopScoreMid
	lda #$00
	sta TopScoreLo
Reset_SoftSet:
	;Enable video out
	jsr EnableVideoOut
	;Init sound PRG bank
	lda #$3D
	sta SoundPRGBank
	;Enable IRQ
	cli
Reset_PRNGLoop:
	;Update PRNG value
	inc PRNGValue
	clc
	lda PRNGValue
	adc GlobalTimer
	sta PRNGValue
	;Loop infinitely
	jmp Reset_PRNGLoop

SoftResetDataTable:
	.db $12,$34,$56,$78

NMI_Lag:
	;Decode IRQ buffer
	jsr DecodeIRQBuffer_Lag
	;Set CHR banks
	ldx #$00
	stx $8000
	lda TempCHRBanks
	sta $8001
	inx
	stx $8000
	lda TempCHRBanks+1
	sta $8001
	inx
	stx $8000
	lda CHRBanks
	sta $8001
	inx
	stx $8000
	lda CHRBanks+1
	sta $8001
	inx
	stx $8000
	lda CHRBanks+2
	sta $8001
	inx
	stx $8000
	lda CHRBanks+3
	sta $8001
	;Set PPU mask register
	lda Mirror_PPUMASK
	sta PPU_MASK
	;Process game logic tasks
	jsr SetScroll
	;Check sound mutex
	ldx SoundMutex
	bne NMI_NoLagSound
	;Process game logic tasks
	jsr UpdateSound
NMI_NoLagSound:
	;Restore last bank switch value
	ldx SoundMutex
	lda TempLastBankSwitch,x
	sta $8000
	jmp NMI_Exit
NMI:
	;Save A/X/Y registers
	pha
	txa
	pha
	tya
	pha
	;Latch PPU status line
	lda PPU_STATUS
	;Check for lag frame
	ldy NMIMutex
	bne NMI_Lag
	;Set NMI mutex
	inc NMIMutex
	;Write OAM buffer data
	lda #$00
	sta OAM_ADDR
	ldy #>OAMBuffer
	sty OAM_DMA
	;Disable video output
	jsr DisableVideoOut
	;Write VRAM buffer data
	jsr WriteVRAMBuffer
	;If black screen timer not 0, hide sprites/background
	lda Mirror_PPUMASK
	ldx BlackScreenTimer
	beq NMI_NoBlack
	;Decrement black screen timer
	dec BlackScreenTimer
	beq NMI_NoBlack
	;Hide sprites/background
	and #$E7
NMI_NoBlack:
	sta PPU_MASK
	;Decode IRQ buffer
	jsr DecodeIRQBuffer
	;Clear HUD update row flag
	lda #$00
	sta UpdateHUDRowFlag
	;Set scroll lock settings
	lda TempScrollLockFlags
	sta ScrollLockFlags
	lda TempScrollLockOther
	sta ScrollLockOther
	;Set CHR banks
	ldx #$00
	stx $8000
	lda TempCHRBanks
	sta $8001
	inx
	stx $8000
	lda TempCHRBanks+1
	sta $8001
	inx
	stx $8000
	lda TempCHRBanks+2
	sta CHRBanks
	sta $8001
	inx
	stx $8000
	lda TempCHRBanks+3
	sta CHRBanks+1
	sta $8001
	inx
	stx $8000
	lda TempCHRBanks+4
	sta CHRBanks+2
	sta $8001
	inx
	stx $8000
	lda TempCHRBanks+5
	sta CHRBanks+3
	sta $8001
	;Process game logic tasks
	jsr SetScroll
	jsr UpdateSound
	jsr ReadInput
	jsr RunGameMode
	lda #$3A
	jsr LoadPRGBank
	jsr DrawEnemySprites
	;End VRAM buffer
	lda #$00
	jsr WriteVRAMBufferCmd
	;Clear NMI mutex
	sta NMIMutex
NMI_Exit:
	;Restore A/X/Y registers
	pla
	tay
	pla
	tax
	pla
	rti

SetScroll:
	;Check for X scroll lock
	lda ScrollLockFlags
	lsr
	bcs SetScroll_SetX
	;Check for Y scroll lock
	lsr
	bcs SetScroll_SetY
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	lda #$20
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	;Latch PPU status line
	lda PPU_STATUS
	;Set X scroll
	lda TempMirror_PPUSCROLL_X
	sta PPU_SCROLL
	;Set Y scroll
	lda TempMirror_PPUSCROLL_Y
	sta PPU_SCROLL
SetScroll_SetCtrl:
	;Set PPU control register
	lda TempMirror_PPUCTRL
	sta PPU_CTRL
	rts
SetScroll_SetX:
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	lda #$20
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	;Latch PPU status line
	lda PPU_STATUS
	;Set X scroll
	lda TempMirror_PPUSCROLL_X
	sta PPU_SCROLL
	sta ElevatorScrollX
	;Set Y scroll
	lda ScrollLockOther
	sta PPU_SCROLL
	;Set PPU control register
	lda TempMirror_PPUCTRL
	sta PPU_CTRL
	rts
SetScroll_SetY:
	;Latch PPU status line
	lda PPU_STATUS
	;Set PPU address
	lda #$20
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	;Latch PPU status line
	lda PPU_STATUS
	;Set X scroll
	lda ScrollLockOther
	sta PPU_SCROLL
	;Set Y scroll
	lda TempMirror_PPUSCROLL_Y
	sta PPU_SCROLL
	;Set PPU control register
	lda TempMirror_PPUCTRL
	sta PPU_CTRL
	rts

InitAPU:
	;Init APU registers
	lda #$0F
	sta SND_CHN
	lda #$C0
	sta JOY2
	rts

EnableVideoOut:
	;Enable video output
	lda #$A8
	sta TempMirror_PPUCTRL
	sta PPU_CTRL
	lda #$18
	sta Mirror_PPUMASK
	lda #$05
	sta BlackScreenTimer
	rts

DisableVideoOut:
	;Disable video output
	lda TempMirror_PPUCTRL
	and #$7F
	sta PPU_CTRL
	lda #$00
	sta PPU_ADDR
	sta PPU_ADDR
	lda Mirror_PPUMASK
	and #$E7
	sta PPU_MASK
	rts

ReadInput:
	;Read input
	ldx #$00
	jsr ReadInputSub
	;Read input again
	ldx #$02
	jsr ReadInputSub
	;If input mismatch, branch to exit
	lda $00
	cmp $02
	bne ReadInput_Diff
	lda $01
	cmp $03
	bne ReadInput_Diff
	;Get buttons pressed this frame
	ldx #$00
	lda $00
	jsr ReadInput_Set
	inx
	lda $01
ReadInput_Set:
	eor TempJoypadCur,x
	and $00,x
	sta JoypadDown,x
	sta TempJoypadDown,x
	lda $00,x
	sta JoypadCur,x
	sta TempJoypadCur,x
	rts
ReadInput_Diff:
	;Input mismatch (DMC hardware bug workaround)
	lda #$00
	sta JoypadDown
	sta TempJoypadDown
	sta JoypadDown+1
	sta TempJoypadDown+1
	rts

ReadInputSub:
	;Strobe input register
	ldy #$01
	sty JOY1
	dey
	sty JOY1
	ldy #$08
ReadInputSub_BitLoop:
	;Get input bits and shift into result
	lda JOY1
	sta $04
	lsr
	ora $04
	lsr
	rol $00,x
	lda JOY2
	sta $05
	lsr
	ora $05
	lsr
	rol $01,x
	;Loop for all 8 bits
	dey
	bne ReadInputSub_BitLoop
	rts

LoadPRGBank:
	;Set PRG bank
	ldy #$06
	sty TempLastBankSwitch
	sty $8000
	sta $8001
	iny
	clc
	adc #$01
	sty TempLastBankSwitch
	sty $8000
	sta $8001
	rts

LoadEnemyPRGBank:
	;Set enemy PRG bank
	lda #$38
	ldy #$06
	sty TempLastBankSwitch
	sty $8000
	sta $8001
	iny
	lda EnemyPRGBank
	sty TempLastBankSwitch
	sty $8000
	sta $8001
	rts

LoadSoundPRGBank:
	;Set sound PRG bank
	lda #$3C
	ldy #$06
	sty TempLastBankSwitch+1
	sty $8000
	sta $8001
	lda SoundPRGBank
	iny
	sty TempLastBankSwitch+1
	sty $8000
	sta $8001
	rts

RestoreSoundPRGBank:
	;Set PRG bank
	ldy #$06
	sty TempLastBankSwitch+1
	sty $8000
	sta $8001
	;Check for enemy PRG bank
	cmp #$38
	bne RestoreSoundPRGBank_NoEnemy
	;Restore enemy PRG bank
	lda EnemyPRGBank
	bne RestoreSoundPRGBank_SetEnemy
RestoreSoundPRGBank_NoEnemy:
	;Restore other PRG bank
	clc
	adc #$01
RestoreSoundPRGBank_SetEnemy:
	;Set PRG bank
	iny
	sty TempLastBankSwitch+1
	sty $8000
	sta $8001
	rts

LoadSound:
	;Set sound mutex
	inc SoundMutex
	;Save A/X/Y registers
	sta SoundSubSaveA
	stx SoundSubSaveX
	sty SoundSubSaveY
	;If sound effect or DMC command, don't update sound PRG bank
	cmp #$7D
	bcc LoadSound_SE
	;If music ID < $A5, set sound PRG bank $3D
	cmp #$A5
	lda #$3D
	bcc LoadSound_SetBank
	;Set sound PRG bank $31
	lda #$31
LoadSound_SetBank:
	sta SoundPRGBank
LoadSound_SE:
	;Save PRG bank
	lda $8000
	sta SoundSubSaveBank
	;Load sound PRG bank
	jsr LoadSoundPRGBank
	;Load sound
	lda SoundSubSaveA
	jsr LoadSoundSub
	;Restore PRG bank
	lda SoundSubSaveBank
	jsr RestoreSoundPRGBank
	;Restore X/Y registers
	ldx SoundSubSaveX
	ldy SoundSubSaveY
	;Clear sound mutex
	dec SoundMutex
	rts

ClearSound:
	;Set sound mutex
	inc SoundMutex
	;Save X/Y registers
	stx SoundSubSaveX
	sty SoundSubSaveY
	;Save PRG bank
	lda $8000
	sta SoundSubSaveBank
	;Load sound PRG bank
	jsr LoadSoundPRGBank
	;Clear sound
	jsr ClearSoundSub
	;Restore PRG bank
	lda SoundSubSaveBank
	jsr RestoreSoundPRGBank
	;Restore X/Y registers
	ldx SoundSubSaveX
	ldy SoundSubSaveY
	;Clear sound mutex
	dec SoundMutex
	rts

UpdateSound:
	;Set sound mutex
	inc SoundMutex
	;Save PRG bank
	lda $8000
	sta SoundSubSaveBank
	;Load sound PRG bank
	jsr LoadSoundPRGBank
	;Update sound
	jsr UpdateSoundSub
	;Restore PRG bank
	lda SoundSubSaveBank
	jsr RestoreSoundPRGBank
	;Clear sound mutex
	dec SoundMutex
	rts

;;;;;;;;;;;;;;;;;;;;
;LONG MODE ROUTINES;
;;;;;;;;;;;;;;;;;;;;
UpdatePlayerAnimation_L:
	;Load PRG bank $36 (update player animation bank)
	lda #$36
	jsr LoadPRGBank
	;Update player animation
	jsr UpdatePlayerAnimation
	;Restore PRG bank
	lda #$34
	jmp LoadPRGBank

InitLevelScroll_L:
	;Init level scroll
	jsr InitLevelScroll
	;Load PRG bank $34 (write enemy VRAM strip bank)
	lda #$34
	jmp LoadPRGBank

DrawHUDRow_L:
	;Load PRG bank $32 (draw HUD row bank)
	lda #$32
	jsr LoadPRGBank
	;Draw HUD row
	jsr DrawHUDRow
	;Restore PRG bank
	lda #$34
	jmp LoadPRGBank

;UNUSED SPACE
	;$4F bytes of free space available
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	;.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

;;;;;;;;
;HEADER;
;;;;;;;;
	.org $FFF0
	;    0123456789
	.db "MAST911001"	;Build date
;IVT data
	.dw NMI
	.dw Reset
	.dw IRQ
