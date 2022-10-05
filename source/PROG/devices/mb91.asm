;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;#										#
;# copyright (c) 2012-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
;#										#
;#										#
;# This program is free software; you can redistribute it and/or		#
;# modify it under the terms of the GNU General Public License			#
;# as published by the Free Software Foundation; either version 2		#
;# of the License, or (at your option) any later version.			#
;#										#
;# This program is distributed in the hope that it will be useful,		#
;# but WITHOUT ANY WARRANTY; without even the implied warranty of		#
;# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the GNU		#
;# General Public License for more details.					#
;#										#
;# You should have received a copy of the GNU General Public			#
;# License along with this library; if not, write to the			#
;# Free Software Foundation, Inc., 59 Temple Place - Suite 330,			#
;# Boston, MA 02111-1307, USA.							#
;#										#
;################################################################################

.equ		MB91_RESET	= SIG1
.equ		MB91_TX		= SIG2
.equ		MB91_RX		= SIG3

.macro MB91_BLSEND
		call	send2_9600
.endm

.macro MB91_BLSENDS
		call	send2_9600s
.endm

.macro MB91_BLRECV
		call	recv3_9600
.endm

.macro MB91_BLSEND19
		call	send2_19200
.endm

.macro MB91_BLSEND19S
		call	send2_19200s
.endm

.macro MB91_BLRECV19
		call	recv3_19200
.endm

.macro MB91_BLSEND38
		call	send2_38400
.endm

.macro MB91_BLSEND38S
		call	send2_38400s
.endm

.macro MB91_BLRECV38
		call	recv3_38400
.endm

.macro MB91_B2SEND
		call	send2_500k
.endm

.macro MB91_B2RECV
		call	recv3_500k
.endm

.macro MB91_B2RECV_LT
		call	recv3_500k_lt
.endm


;-------------------------------------------------------------------------------
; init
; PAR1:		0 = 9600
;		1 = 19200
;		2 = 38400
;		+16 = no reset
;		
; PAR3:		Request byte
; PAR4:		Response byte
;-------------------------------------------------------------------------------
mb91_init:		mov	r24,r16
			sbrc	r16,4
			rjmp	mb91_init_2			;no reset...
			out	CTRLPORT,const_0		;all input
			sbi	CTRLDDR,MB91_TX			;TX output
			sbi	CTRLDDR,MB91_RESET		;RST output
			call	api_vcc_on			;power on
			sbi	CTRLPORT,MB91_TX		;tx high
			ldi	ZL,250
			ldi	ZH,0
			call	api_wait_ms
			sbi	CTRLPORT,MB91_RESET		;release reset
			ldi	ZL,1
			ldi	ZH,0
			call	api_wait_ms
			cbi	CTRLDDR,MB91_RESET		;RST output

			ldi	ZL,150
			clr	ZH
			call	api_wait_ms
			mov	r16,r24

mb91_init_2:		mov	XL,r18
			andi	r16,7
			brne	mb91_init_3
			MB91_BLSENDS	
			MB91_BLRECV
			cp	XL,r19
			brne	mb91_init_err
			jmp	main_loop_ok

mb91_init_3:		cpi	r16,1
			brne	mb91_init_4
			MB91_BLSEND19S	
			MB91_BLRECV19
			cp	XL,r19
			brne	mb91_init_err
			jmp	main_loop_ok

mb91_init_4:		cpi	r16,2
			brne	mb91_init_err
			MB91_BLSEND38S	
			MB91_BLRECV38
			cp	XL,r19
			brne	mb91_init_err
			jmp	main_loop_ok
			
mb91_init_err:		sts	0x100,XL
			ldi	r16,0x50
			jmp	main_loop
			
						
;-------------------------------------------------------------------------------
; exit
;-------------------------------------------------------------------------------
mb91_exit:		out	CTRLPORT,const_0
			ldi	ZL,50
			clr	ZH
			call	api_wait_ms
			call	api_vcc_off
			out	CTRLDDR,const_0
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; send BL head
; PAR1 = loader select
; PAR3 = LEN low
; PAR4 = LEN high
;-------------------------------------------------------------------------------
mb91_head:		andi	r16,7
			brne	mb91_head_2
			
			ldi	XL,0x00
			MB91_BLSEND	
			ldi	XL,0x00
			MB91_BLSEND	
			ldi	XL,0x01
			MB91_BLSEND	
			ldi	XL,0x00
			MB91_BLSEND	
			ldi	XL,0x00
			MB91_BLSEND	
			
			ldi	XL,0x00
			MB91_BLSEND	
			ldi	XL,0x00
			MB91_BLSEND	
			mov	XL,r19
			MB91_BLSEND	
			mov	XL,r18
			MB91_BLSEND	
			
			ldi	XL,1
			add	XL,r19
			add	XL,r18
			MB91_BLSENDS	
			
			MB91_BLRECV
			cpi	XL,0x11
			brne	mb91_head1_err
			jmp	main_loop_ok
			
mb91_head1_err:		sts	0x100,XL
			ldi	r16,0x51
			jmp	main_loop

mb91_head_2:		cpi	r16,1
			brne	mb91_head_3
			
			ldi	XL,0x00
			MB91_BLSEND19	
			ldi	XL,0x00
			MB91_BLSEND19	
			ldi	XL,0x01
			MB91_BLSEND19	
			ldi	XL,0x00
			MB91_BLSEND19	
			ldi	XL,0x00
			MB91_BLSEND19	
			
			ldi	XL,0x00
			MB91_BLSEND19	
			ldi	XL,0x00
			MB91_BLSEND19	
			mov	XL,r19
			MB91_BLSEND19	
			mov	XL,r18
			MB91_BLSEND19	
			
			ldi	XL,1
			add	XL,r19
			add	XL,r18
			MB91_BLSEND19S	
			
			MB91_BLRECV19
			cpi	XL,0x11
			brne	mb91_head2_err
			jmp	main_loop_ok
			
mb91_head2_err:		sts	0x100,XL
			ldi	r16,0x51
			jmp	main_loop


mb91_head_3:		ldi	XL,0x00
			MB91_BLSEND38	
			ldi	XL,0x00
			MB91_BLSEND38	
			ldi	XL,0x01
			MB91_BLSEND38	
			ldi	XL,0x00
			MB91_BLSEND38	
			ldi	XL,0x00
			MB91_BLSEND38	
			
			ldi	XL,0x00
			MB91_BLSEND38	
			ldi	XL,0x00
			MB91_BLSEND38	
			mov	XL,r19
			MB91_BLSEND38	
			mov	XL,r18
			MB91_BLSEND38	
			
			ldi	XL,1
			add	XL,r19
			add	XL,r18
			MB91_BLSEND38S	
			
			MB91_BLRECV38
			cpi	XL,0x11
			brne	mb91_head3_err
			jmp	main_loop_ok
			
mb91_head3_err:		sts	0x100,XL
			ldi	r16,0x51
			jmp	main_loop

;-------------------------------------------------------------------------------
; send BL data
; PAR1 = loader select
; PAR3 = LEN low
; PAR4 = LEN high
;-------------------------------------------------------------------------------
mb91_sdata:		call	api_resetptr
			movw	r24,r18			;get num of bytes
			andi	r16,7
			brne	mb91_sdata_2
	
mb91_sdata_1l:		call	api_buf_bread
			MB91_BLSEND
			sbiw	r24,1
			brne	mb91_sdata_1l
			jmp	main_loop_ok

mb91_sdata_2:		cpi	r16,1
			brne	mb91_sdata_3
	
mb91_sdata_2l:		call	api_buf_bread
			MB91_BLSEND19
			sbiw	r24,1
			brne	mb91_sdata_2l
			jmp	main_loop_ok

mb91_sdata_3:
mb91_sdata_3l:		call	api_buf_bread
			MB91_BLSEND38
			sbiw	r24,1
			brne	mb91_sdata_3l
			jmp	main_loop_ok
			
;-------------------------------------------------------------------------------
; send BL data sum
; PAR1 = loader select
; PAR3 = LEN low
; PAR4 = LEN high
;-------------------------------------------------------------------------------
mb91_ssum:		mov	XL,r19			;get sum
			andi	r16,7
			brne	mb91_ssum_2
	
mb91_ssum_1l:		MB91_BLSENDS
			MB91_BLRECV
			cpi	XL,0x11
			brne	mb91_ssum_err
			jmp	main_loop_ok

mb91_ssum_2:		cpi	r16,1
			brne	mb91_ssum_3

			MB91_BLSEND19S
			MB91_BLRECV19
			cpi	XL,0x11
			brne	mb91_ssum_err
			jmp	main_loop_ok

mb91_ssum_3:
			MB91_BLSEND38S
			MB91_BLRECV
			cpi	XL,0x11
			brne	mb91_ssum_err
			jmp	main_loop_ok


mb91_ssum_err:		ldi	r16,0x52
			jmp	main_loop			

;-------------------------------------------------------------------------------
; send BL exec
; PAR1 = loader select
; PAR3 = LEN low
; PAR4 = LEN high
;-------------------------------------------------------------------------------
mb91_exec:		andi	r16,7
			brne	mb91_exec_2
			
			ldi	XL,0xC0
			MB91_BLSEND	
			ldi	XL,0x00
			MB91_BLSEND	
			ldi	XL,0x00
			MB91_BLSEND	
			ldi	XL,0x00
			MB91_BLSEND	
			ldi	XL,0x00
			MB91_BLSEND	
			
			ldi	XL,0x00
			MB91_BLSEND	
			ldi	XL,0x00
			MB91_BLSEND	
			ldi	XL,0x00
			MB91_BLSEND	
			ldi	XL,0x00
			MB91_BLSEND	
			ldi	XL,0xC0
			MB91_BLSEND	
			jmp	main_loop_ok
			
mb91_exec_2:		cpi	r16,1
			brne	mb91_exec_3
			
			ldi	XL,0xC0
			MB91_BLSEND19	
			ldi	XL,0x00
			MB91_BLSEND19	
			ldi	XL,0x00
			MB91_BLSEND19	
			ldi	XL,0x00
			MB91_BLSEND19	
			ldi	XL,0x00
			MB91_BLSEND19	

			ldi	XL,0x00
			MB91_BLSEND19	
			ldi	XL,0x00
			MB91_BLSEND19	
			ldi	XL,0x00
			MB91_BLSEND19	
			ldi	XL,0x00
			MB91_BLSEND19	
			ldi	XL,0xC0
			MB91_BLSEND19	
			jmp	main_loop_ok
			

mb91_exec_3:		ldi	XL,0xC0
			MB91_BLSEND38	
			ldi	XL,0x00
			MB91_BLSEND38	
			ldi	XL,0x00
			MB91_BLSEND38	
			ldi	XL,0x00
			MB91_BLSEND38	
			ldi	XL,0x00
			MB91_BLSEND38	

			ldi	XL,0x00
			MB91_BLSEND38	
			ldi	XL,0x00
			MB91_BLSEND38	
			ldi	XL,0x00
			MB91_BLSEND38	
			ldi	XL,0x00
			MB91_BLSEND38	
			ldi	XL,0xC0
			MB91_BLSEND38	
			jmp	main_loop_ok
			

