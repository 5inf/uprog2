;******************************************************************************
;*        automatic generated file                                            *
;******************************************************************************

		.section .text,"ax"
		.globl _get_fbyte


;------------------------------------------------------------------------------
; get port level
; par1: PORT Nr.
;------------------------------------------------------------------------------
_get_fbyte:		push	bc
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

