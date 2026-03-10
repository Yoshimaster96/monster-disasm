;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Monster In My Pocket Disassembly;
;        By Yoshimaster96        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;VER_USA = 1	;Default
;VER_EUR = 1

;;;;;;;;;;;;;
;INES HEADER;
;;;;;;;;;;;;;
	.incbin "header.bin"

;;;;;;;;;
;PRG ROM;
;;;;;;;;;
	.include "regs.asm"
	.include "vars.asm"

	.fillvalue $FF
	.include "prg0.asm"
	.include "prg1.asm"
	.include "prg2.asm"
	.include "prg3.asm"
	.include "prg4.asm"
	.include "prg5.asm"
	.include "prg6.asm"
	.include "prg7.asm"

;;;;;;;;;
;CHR ROM;
;;;;;;;;;
.ifdef VER_EUR
	.incbin "chr_e.bin"
.else ;VER_USA
	.incbin "chr.bin"
.endif
