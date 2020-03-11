;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;#										#
;# copyright (c) 2012-2017 Joerg Wolfram (joerg@jcwolfram.de)			#
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

.equ			CCXX_RST	= SIG1
.equ			CCXX_DC		= SIG2
.equ			CCXX_DD		= SIG3

.equ			CCXX_WR_CONFIG	= 0x19
.equ			CCXX_RD_CONFIG	= 0x24
.equ			CCXX_RD_STATUS	= 0x30

.equ			CCXX_INST1	= 0x55
.equ			CCXX_INST2	= 0x56
.equ			CCXX_INST3	= 0x57


;-------------------------------------------------------------------------------
; init
;-------------------------------------------------------------------------------
ccxx_init:		out		CTRLPORT,const_0
			sbi		CTRLDDR,CCXX_RST
			sbi		CTRLDDR,CCXX_DC
			sbi		CTRLDDR,CCXX_DD
			call		api_vcc_on		;power on
			ldi		ZL,150
			clr		ZH
			call		api_wait_ms
			sbi		CTRLPORT,CCXX_RST	;release reset
			ldi		ZL,1
			clr		ZH
			call		api_wait_ms
			cbi		CTRLPORT,CCXX_RST	;set reset
			rcall		ccxx_w1			;wait
			ldi		r23,2

ccxx_init_1:		sbi		CTRLPORT,CCXX_DC	;pulse
			rcall		ccxx_w0_1
			cbi		CTRLPORT,CCXX_DC	;pulse
			rcall		ccxx_w0_1
			dec		r23
			brne		ccxx_init_1
			rcall		ccxx_w0			;wait
			sbi		CTRLPORT,CCXX_RST	;release reset

			;now get chip id
			ldi		XL,0x68			;read chip id
			rcall		ccxx_send
			rcall		ccxx_read_status
			sts		0x100,XL		;chip ID
			rcall		ccxx_recv
			sts		0x101,XL		;chip rev
			jmp		main_loop_ok

;-------------------------------------------------------------------------------
; chip erase
;-------------------------------------------------------------------------------
ccxx_cerase:		ldi		XL,0x10			;chip erase
			rcall		ccxx_send
			rcall		ccxx_read_status		;wait for OK

			ldi		r24,0
			ldi		r25,0

ccxx_erase_1:		rcall		ccxx_w1			;wait 1ms
			ldi		XL,CCXX_RD_STATUS	;get status
			rcall		ccxx_send
			rcall		ccxx_read_status	;wait for OK
			sbrs		XL,7
			rjmp		ccxx_erase_2
			sbiw		r24,1
			brne		ccxx_erase_1
ccxx_cerase_err:	ldi		r16,0x41		;timeout
			jmp		main_loop

ccxx_erase_2:		jmp		main_loop_ok

;-------------------------------------------------------------------------------
; program 2K
; r16-r18 = flash address
;-------------------------------------------------------------------------------
ccxx_prog:		call		api_resetptr

			lds		r25,txlen_h		;high length
			lsr		r25
			lsr		r25

			;enable DMA
cxxx_prog_0:		push		r25
			ldi		XL,0x18			;WR_CONFIG
			rcall		ccxx_send
			ldi		XL,0x22			;enable DMA transfers
			rcall		ccxx_send
			rcall		ccxx_read_status	;read status byte

			;DMA config data
			ldi		ZL,LOW(ccxx_dma_data_0*2)
			ldi		ZH,HIGH(ccxx_dma_data_0*2)
			ldi		r24,0
			ldi		r25,4
			rcall		ccxx_xdata_wblock8	;write DMA config 1
			ldi		r24,8
			rcall		ccxx_xdata_wblock8	;write DMA config 2

			;set DMA config pointer
			ldi		r25,0x70
			ldi		r24,0xd2

			ldi		XH,0x08			;DMA1 config LOW
			rcall		ccxx_xdata_write
			ldi		XH,0x04			;DMA1 config HIGH
			rcall		ccxx_xdata_write1
			ldi		XH,0x00			;DMA0 config LOW
			rcall		ccxx_xdata_write1
			ldi		XH,0x04			;DMA0 config HIGH
			rcall		ccxx_xdata_write1

			;set flash address
			lsr		r18			;addr >> 2
			ror		r17
			ror		r16
			lsr		r18
			ror		r17
			ror		r16

			rcall		ccxx_w1

			ldi		r25,0x62
			ldi		r24,0x71		;Flash addr LO
			mov		XH,r16			;value LO
			rcall		ccxx_xdata_write
			mov		XH,r17			;value HI
			rcall		ccxx_xdata_write1

			;transfer data to buffer
			ldi		r25,0x70		;DMA arm
			ldi		r24,0xd6
			ldi		XH,0x01			;channel 0
			rcall		ccxx_xdata_write

			ldi		XL,0x84			;burst write + HI
			rcall		ccxx_send
			ldi		XL,0x00			;LO
			rcall		ccxx_send

			ldi		r25,4			;num bytes
			ldi		r24,0

ccxx_prog_1:		call		api_buf_bread
;			ldi		XL,0x11
			rcall		ccxx_send
			sbiw		r24,1
			brne		ccxx_prog_1

			rcall		ccxx_w0
			rcall		ccxx_read_status

			;start programming
			ldi		r25,0x70		;DAM arm
			ldi		r24,0xd6
			ldi		XH,0x02			;channel 1
			rcall		ccxx_xdata_write

			ldi		r25,0x62		;FCTL
			ldi		r24,0x70
			ldi		XH,0x06			;start
			rcall		ccxx_xdata_write

			;wait until done
ccxx_prog_3:		ldi		r25,0x62		;FCTL
			ldi		r24,0x70
			rcall		ccxx_xdata_read

			sbrc		XH,7			;check busy flag
			rjmp		ccxx_prog_3

			pop		r25
			dec		r25
			breq		ccxx_prog_4
			rjmp		cxxx_prog_0

ccxx_prog_4:		jmp		main_loop_ok

sccxx_prog_err:		ldi		r16,0x41		;timeout
			jmp		main_loop

;DMA data for 1K block size
ccxx_dma_data_0:	.db	0x62,0x60,0x00,0x00,0x04,0x00,0x1f,0x11
ccxx_dma_data_1:	.db	0x00,0x00,0x62,0x73,0x04,0x00,0x12,0x42
		;	.db	0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff

;-------------------------------------------------------------------------------
; read flash
; r16/r17 = address
; r18     = bank
;-------------------------------------------------------------------------------
ccxx_read:		call		api_resetptr

			;select bank
			ldi		r25,0x70		;MEMCTR
			ldi		r24,0xC7
			mov		XH,r18			;bank
			rcall		ccxx_xdata_write

			movw		r24,r16			;addr
			rcall		ccxx_write_dptr

			lds		r24,rxlen_l		;bytes to do
			lds		r25,rxlen_h

ccxx_read_1:		rcall		ccxx_read_data
			call		api_buf_bwrite
			rcall		ccxx_inc_dptr

			sbiw		r24,1
			brne		ccxx_read_1

			jmp		main_loop_ok


;-------------------------------------------------------------------------------
; write XDATA memory block
; Z		= address in Flash
; R24/R25	= addr in CC2541
; R23		= size
;-------------------------------------------------------------------------------
ccxx_xdata_wblock8:	ldi		r23,8
ccxx_xdata_wblock:	rcall		ccxx_write_dptr

ccxx_xdata_wblock_1:	ldi		XL,CCXX_INST2		;2 bytes instruction
			rcall		ccxx_send
			ldi		XL,0x74			;mov a, #x
			rcall		ccxx_send
			lpm		XL,Z+
			rcall		ccxx_send
			rcall		ccxx_read_status	;read status byte

			ldi		XL,CCXX_INST1		;1 bytes instruction
			rcall		ccxx_send
			ldi		XL,0xf0			;mov @dptr,a
			rcall		ccxx_send
			rcall		ccxx_read_status	;read status byte

			rcall		ccxx_inc_dptr

			dec		r23
			brne		ccxx_xdata_wblock_1
			ret

;-------------------------------------------------------------------------------
; write XDATA memory byte
; R24/R25	= addr in CC2541
; XH		= data
;-------------------------------------------------------------------------------
ccxx_xdata_write:	rcall		ccxx_write_dptr

ccxx_xdata_write1:	ldi		XL,CCXX_INST2		;2 bytes instruction
			rcall		ccxx_send
			ldi		XL,0x74			;mov a, #x
			rcall		ccxx_send
			mov		XL,XH
			rcall		ccxx_send
			rcall		ccxx_read_status	;read status byte

			ldi		XL,CCXX_INST1		;1 bytes instruction
			rcall		ccxx_send
			ldi		XL,0xf0			;movx @dptr,a
			rcall		ccxx_send
			rcall		ccxx_read_status	;read status byte

			rjmp		ccxx_inc_dptr


;-------------------------------------------------------------------------------
; set dptr register
; R24/R25	= value
;-------------------------------------------------------------------------------
ccxx_write_dptr:	ldi		XL,CCXX_INST3		;3 bytes instruction
			rcall		ccxx_send
			ldi		XL,0x90			;mov dptr, addr
			rcall		ccxx_send
			mov		XL,r25			;high addr
			rcall		ccxx_send
			mov		XL,r24			;low addr
			rcall		ccxx_send
			rjmp		ccxx_read_status	;read status byte

ccxx_read_data:		ldi		XL,CCXX_INST1		;1 bytes instruction
			rcall		ccxx_send
			ldi		XL,0xe0			;movx a,@dptr
			rcall		ccxx_send
			rjmp		ccxx_read_status		;read status byte

ccxx_inc_dptr:		ldi		XL,CCXX_INST1		;1 bytes instruction
			rcall		ccxx_send
			ldi		XL,0xa3			;inc dptr
			rcall		ccxx_send
			rjmp		ccxx_read_status	;read status byte


;-------------------------------------------------------------------------------
; read XDATA memory byte
; R24/R25	= addr in CC2541
; XH		= data
;-------------------------------------------------------------------------------
ccxx_xdata_read:	rcall		ccxx_write_dptr

			ldi		XL,CCXX_INST1		;1 bytes instruction
			rcall		ccxx_send
			ldi		XL,0xe0			;movx a,@dptr
			rcall		ccxx_send
			rcall		ccxx_read_status		;read status byte
			mov		XH,XL			;copy
			ret


;-------------------------------------------------------------------------------
; send byte
;-------------------------------------------------------------------------------
ccxx_send:		cbi		CTRLPORT,CCXX_DD	;clear
			sbi		CTRLDDR,CCXX_DD		;output

			ldi		r20,8
ccxx_send_1:		sbrc		XL,7
			sbi		CTRLPORT,CCXX_DD
			sbrs		XL,7
			cbi		CTRLPORT,CCXX_DD
			sbi		CTRLPORT,CCXX_DC
			rcall	ccxx_send_e
			cbi		CTRLPORT,CCXX_DC
			rcall	ccxx_send_e
			lsl		XL
			dec		r20
			brne		ccxx_send_1
			cbi		CTRLDDR,CCXX_DD		;input
			sbi		CTRLPORT,CCXX_DD	;enable pull-up
ccxx_send_e:		ret


;-------------------------------------------------------------------------------
; receive byte
;-------------------------------------------------------------------------------
ccxx_recv:		cbi		CTRLDDR,CCXX_DD		;input
			sbi		CTRLPORT,CCXX_DD	;enable pull-up

ccxx_recv_0:		ldi		r20,8
ccxx_recv_1:		lsl		XL
			sbi		CTRLPORT,CCXX_DC
			rcall	ccxx_recv_e
			sbic		CTRLPIN,CCXX_DD
			inc		XL
			cbi		CTRLPORT,CCXX_DC
			rcall	ccxx_recv_e
			dec		r20
			brne		ccxx_recv_1
ccxx_recv_e:		ret

;-------------------------------------------------------------------------------
; wait for ready
;-------------------------------------------------------------------------------
ccxx_read_status:	ldi		r21,32			;tries
			clt					;OK
ccxx_wready_1:		sbis		CTRLPIN,CCXX_DD		;skip if one
			rjmp		ccxx_recv		;get data
			rcall		ccxx_recv		;dummy read data
			dec		r21
			brne		ccxx_wready_1
			set					;timed out
			ret

;-------------------------------------------------------------------------------
; some wait routines
;-------------------------------------------------------------------------------
ccxx_w1:		ldi	ZL,1
			clr	ZH
			jmp	api_wait_ms

ccxx_w0:		ldi	ZL,33
ccxx_w0_1:		dec	ZL
			brne	ccxx_w0_1
ccxx_w0_2:		ret
