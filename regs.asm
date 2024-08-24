;;;;;;;;;;;;;;;;;;;
;NES CPU REGISTERS;
;;;;;;;;;;;;;;;;;;;
SQ1_VOL		.equ $4000
SQ1_SWEEP	.equ $4001
SQ1_LO		.equ $4002
SQ1_HI		.equ $4003
SQ2_VOL		.equ $4004
SQ2_SWEEP	.equ $4005
SQ2_LO		.equ $4006
SQ2_HI		.equ $4007
TRI_LINEAR	.equ $4008
;
TRI_LO		.equ $400A
TRI_HI		.equ $400B
NOISE_VOL	.equ $400C
;
NOISE_LO	.equ $400E
NOISE_HI	.equ $400F
DMC_FREQ	.equ $4010
DMC_RAW		.equ $4011
DMC_START	.equ $4012
DMC_LEN		.equ $4013
OAM_DMA		.equ $4014
SND_CHN		.equ $4015
JOY1		.equ $4016
JOY2		.equ $4017

;;;;;;;;;;;;;;;;;;;
;NES PPU REGISTERS;
;;;;;;;;;;;;;;;;;;;
PPU_CTRL	.equ $2000
PPU_MASK	.equ $2001
PPU_STATUS	.equ $2002
OAM_ADDR	.equ $2003
OAM_DATA	.equ $2004
PPU_SCROLL	.equ $2005
PPU_ADDR	.equ $2006
PPU_DATA	.equ $2007

;;;;;;;;;;;;;;;;;;;;
;NES JOYPAD DEFINES;
;;;;;;;;;;;;;;;;;;;;
JOY_A		.equ $80
JOY_B		.equ $40
JOY_SELECT	.equ $20
JOY_START	.equ $10
JOY_UP		.equ $08
JOY_DOWN	.equ $04
JOY_LEFT	.equ $02
JOY_RIGHT	.equ $01
