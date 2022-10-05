;******************************************************************************
;*        automatic generated file                                            *
;******************************************************************************

		.section .text,"ax"
		.globl _get_fbyte0
		.globl _get_fbyte1
		.globl _get_fbyte2
		.globl _get_fbyte3


;------------------------------------------------------------------------------
; get flash byte
;------------------------------------------------------------------------------
_get_fbyte0:		push	bc
			push	hl
			movw 	ax,[sp+8]
			movw	hl,ax
			mov	ES,#0
			mov	a,ES:[hl]			;get addr of PIO
			mov	ES,#0
			mov	0xFFEF0,a

			pop	hl				;restore registers
			pop	bc
			ret

_get_fbyte1:		push	bc
			push	hl
			movw 	ax,[sp+8]
			movw	hl,ax
			mov	ES,#1
			mov	a,ES:[hl]			;get addr of PIO
			mov	ES,#0
			mov	0xFFEF0,a

			pop	hl				;restore registers
			pop	bc
			ret


_get_fbyte2:		push	bc
			push	hl
			movw 	ax,[sp+8]
			movw	hl,ax
			mov	ES,#2
			mov	a,ES:[hl]			;get addr of PIO
			mov	ES,#0
			mov	0xFFEF0,a

			pop	hl				;restore registers
			pop	bc
			ret


_get_fbyte3:		push	bc
			push	hl
			movw 	ax,[sp+8]
			movw	hl,ax
			mov	ES,#3
			mov	a,ES:[hl]			;get addr of PIO
			mov	ES,#0
			mov	0xFFEF0,a

			pop	hl				;restore registers
			pop	bc
			ret

