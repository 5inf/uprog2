;******************************************************************************
;*        automatic generated file                                            *
;******************************************************************************

		.section .text,"ax"
		.globl _get_dfbyte


;------------------------------------------------------------------------------
; get port level
; par1: PORT Nr.
;------------------------------------------------------------------------------
_get_dfbyte:		push	bc
			push	hl
			movw 	ax,[sp+8]
			movw	hl,ax
			mov	ES,#14
			mov	a,ES:[hl]
			mov	ES,#0
			mov	0xFFEF0,a

			pop	hl				;restore registers
			pop	bc
			ret

