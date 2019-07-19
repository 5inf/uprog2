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

.equ		PGC	= SIG2
.equ		PGD	= SIG1

;-------------------------------------------------------------------------------
; init/exit ICSP mode
;-------------------------------------------------------------------------------
pic_hvinit:	out	CTRLPORT,const_0
		sbi	CTRLDDR,PGD		;data LOW
		sbi	CTRLDDR,PGC		;clock LOW
		call	api_vcc_on
		rcall	pic_w20ms
		call	api_vpp_on
		rcall	pic_w20ms
		jmp	main_loop_ok

pic_hvexit:	mov	r24,r16			;save VPP value
		out	CTRLPORT,const_0
		call	api_vpp_off
		call	api_vcc_off
		call	api_vpp_dis		;disable VPP
		out	CTRLDDR,const_0
		jmp	main_loop_ok


pic1_reentry:	call	api_vpp_off		
;		call	api_vcc_off
		out	PORTA,const_0
		
		rcall	pic_w100ms
		call	api_vcc_on
		rcall	pic_w20ms
		call	api_vpp_on

pic_w20ms:	ldi	ZL,20
		ldi	ZH,0
		jmp	api_wait_ms

pic_w100ms:	ldi	ZL,100
		ldi	ZH,0
		jmp	api_wait_ms

;-------------------------------------------------------------------------------
; load config
;-------------------------------------------------------------------------------
pic1_loadconf:	ldi	XL,0x00
		rcall	pic1_cmd
		clr	XL
		clr	XH
		rjmp	pic1_wdat

;-------------------------------------------------------------------------------
; increment addr
;-------------------------------------------------------------------------------
pic1_incaddr:	ldi	XL,0x06
		rjmp	pic1_cmd

;-------------------------------------------------------------------------------
; end program
;-------------------------------------------------------------------------------
pic1_endprog:	ldi	XL,0x17
		rjmp	pic1_cmd

;-------------------------------------------------------------------------------
; read device ID
;-------------------------------------------------------------------------------
pic1_readid:	rcall	pic1_reentry
		rcall	pic1_loadconf
		ldi	r20,6
pic1_readid_1:	rcall	pic1_incaddr
		dec	r20
		brne	pic1_readid_1
		ldi	XL,0x04			;read prog data
		rcall	pic1_cmd
		rcall	pic1_rdat
		sts	0x100,XL		;DEVID L
		sts	0x101,XH		;DEVID H
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; read device ID
;-------------------------------------------------------------------------------
pic1_readid2:	ldi	XL,0x80
		rcall	pic1_cmd2
		ldi	XL,0x06
		ldi	XH,0x80
		rcall	pic1_waddr2

		ldi	XL,0xFE			;read prog data
		rcall	pic1_cmd2
		rcall	pic1_rdat2
		sts	0x100,XL		;DEVID L
		sts	0x101,XH		;DEVID H
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; mass erase
;-------------------------------------------------------------------------------
pic1_merase:	movw	r22,r16			;erase time
		rcall	pic1_reentry
		rcall	pic1_loadconf		;set erase to all
		ldi	XL,0x09			;bulk erase main
		rcall	pic1_cmd
		movw	ZL,r22
		call	api_wait_ms
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; mass erase3
;-------------------------------------------------------------------------------
pic1_merase3:	movw	r22,r16			;erase time
		ldi	XL,0x80
		rcall	pic1_cmd2
		ldi	XL,0x06
		ldi	XH,0x80
		rcall	pic1_waddr2

		ldi	XL,0x18			;bulk erase
		rcall	pic1_cmd2
		movw	ZL,r22
		call	api_wait_ms
		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; mass erase2
;-------------------------------------------------------------------------------
pic1_merase2:	movw	r22,r16			;erase time
		rcall	pic1_reentry
		rcall	pic1_loadconf		;set erase to all
		ldi	XL,0x1f			;bulk erase main
		rcall	pic1_cmd
		movw	ZL,r22
		call	api_wait_ms
		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; program flash erase
;-------------------------------------------------------------------------------
pic1_perase:	movw	r22,r16			;erase time
		rcall	pic1_reentry
		ldi	XL,0x09			;bulk erase program
		rcall	pic1_cmd
		movw	ZL,r22
		call	api_wait_ms
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; program flash erase 2
;-------------------------------------------------------------------------------
pic1_perase2:	movw	r22,r16			;erase time
		rcall	pic1_reentry
		ldi	XL,0x09			;bulk erase program
		rcall	pic1_cmd
		movw	ZL,r22
		call	api_wait_ms
		rcall	pic1_endprog
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; data flash erase
;-------------------------------------------------------------------------------
pic1_derase:	movw	r22,r16			;erase time
		rcall	pic1_reentry
		ldi	XL,0x0b			;bulk erase data
		rcall	pic1_cmd
		movw	ZL,r22
		call	api_wait_ms
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; data flash erase
;-------------------------------------------------------------------------------
pic1_derase2:	movw	r22,r16			;erase time
		rcall	pic1_reentry
		ldi	XL,0x0b			;bulk erase data
		rcall	pic1_cmd
		movw	ZL,r22
		call	api_wait_ms
		rcall	pic1_endprog
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; program prog flash (four-word)
;-------------------------------------------------------------------------------
pic1_pprog:	movw	r24,r16			;four-words to to
		lsr	r25			;/8
		ror	r24
		lsr	r25
		ror	r24
		lsr	r25
		ror	r24
		call	api_resetptr
		cpi	r19,0
		breq	pic1_pprog_1
		rcall	pic1_reentry
pic1_pprog_1:	ldi	r23,3
pic1_pprog_2:	ldi	XL,0x02			;load for pmem
		rcall	pic1_cmd
		call	api_buf_lread
		call	pic1_wdat
		rcall	pic1_incaddr
		dec	r23
		brne	pic1_pprog_2
		ldi	XL,0x02			;load for pmem
		rcall	pic1_cmd
		call	api_buf_lread
		call	pic1_wdat
		ldi	XL,0x08			;begin prog
		rcall	pic1_cmd
		mov	ZL,r18
		clr	ZH
		call	api_wait_ms
		rcall	pic1_incaddr
		sbiw	r24,1
		brne	pic1_pprog_1
		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; program main flash (rows)
;-------------------------------------------------------------------------------
pic1_prog2_row:		movw	r24,r16			;rows to do
			ldi	XL,0x80
			rcall	pic1_cmd2
			movw	XL,r18			;ADDR
			rcall	pic1_waddr2
			call	api_resetptr

			ldi	r24,32			;pages per block

pic1_prog2_row_1:	ldi	r25,31			;page size
pic1_prog2_row_2:	ldi	XL,0x02			;write+increment
			rcall	pic1_cmd2
			call	api_buf_lread
			call	pic1_waddr2		;write data

			ldi	XL,7
pic1_prog2_row_3:	dec	XL
			brne	pic1_prog2_row_3	

			dec	r25
			brne	pic1_prog2_row_2

			ldi	XL,0x00			;write
			rcall	pic1_cmd2
			call	api_buf_lread
			call	pic1_waddr2		;write data
		
			ldi	XL,0xE0			;start programming
			rcall	pic1_cmd2
				
			mov	ZL,r16
			clr	ZH
			call	api_wait_ms

			ldi	XL,0xF8			;increment address
			rcall	pic1_cmd2
			
			dec	r24
			brne	pic1_prog2_row_1		
			
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; program flash (words)
;-------------------------------------------------------------------------------
pic1_prog2_word:	call	api_resetptr
			ldi	XL,0x80
			rcall	pic1_cmd2
			movw	XL,r18			;ADDR
			rcall	pic1_waddr2
			call	api_resetptr

			ldi	XL,0x00			;write
			rcall	pic1_cmd2
			call	api_buf_lread
			call	pic1_waddr2		;write data
		
			ldi	XL,0xE0			;start programming
			rcall	pic1_cmd2
				
			mov	ZL,r16
			clr	ZH
			call	api_wait_ms
						
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; program prog flash (one-word)
;-------------------------------------------------------------------------------
pic1_pprog2:	movw	r24,r16			;bytes to to
		lsr	r25			;/2
		ror	r24
		call	api_resetptr
		cpi	r19,0
		breq	pic1_pprog2_1
		rcall	pic1_reentry
pic1_pprog2_1:	ldi	XL,0x02			;load for pmem
		rcall	pic1_cmd
		call	api_buf_lread
		call	pic1_wdat
		ldi	XL,0x18			;begin prog
		rcall	pic1_cmd
		mov	ZL,r18
		clr	ZH
		call	api_wait_ms
		rcall	pic1_endprog
		rcall	pic1_incaddr
		sbiw	r24,1
		brne	pic1_pprog2_1
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; read prog flash / config
;-------------------------------------------------------------------------------
pic1_pread:	movw	r24,r16			;words to do
		call	api_resetptr
		cpi	r19,0
		breq	pic1_pread_1
		rcall	pic1_reentry
pic1_pread_1:	ldi	XL,0x04			;read from pmem
		rcall	pic1_cmd
		call	pic1_rdat		;read
		call	api_buf_lwrite
		rcall	pic1_incaddr
		sbiw	r24,1
		brne	pic1_pread_1
		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; read memory
;-------------------------------------------------------------------------------
pic1_read2:		movw	r24,r16			;words to do
			ldi	XL,0x80
			rcall	pic1_cmd2
			movw	XL,r18			;ADDR
			rcall	pic1_waddr2

			call	api_resetptr
pic1_read2_1:		ldi	XL,0xFE			;read+increment
			rcall	pic1_cmd2
			call	pic1_rdat2		;read
			call	api_buf_lwrite
			sbiw	r24,1
			brne	pic1_read2_1
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; program data flash
;-------------------------------------------------------------------------------
pic1_dprog:	movw	r24,r16			;bytes to do
		call	api_resetptr
		cpi	r19,0
		breq	pic1_dprog_1
		rcall	pic1_reentry
pic1_dprog_1:	ldi	XL,0x03			;load for dmem
		rcall	pic1_cmd
		call	api_buf_bread
		clr	XH
		call	pic1_wdat
		ldi	XL,0x08			;begin prog
		rcall	pic1_cmd
		mov	ZL,r18
		clr	ZH
		call	api_wait_ms
		rcall	pic1_incaddr
		sbiw	r24,1
		brne	pic1_dprog_1
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; program data flash
;-------------------------------------------------------------------------------
pic1_dprog2:		movw	r24,r16			;bytes to do
			call	api_resetptr
			cpi	r19,0
			breq	pic1_dprog2_1
			rcall	pic1_reentry
pic1_dprog2_1:		ldi	XL,0x03			;load for dmem
			rcall	pic1_cmd
			call	api_buf_bread
			clr	XH
			call	pic1_wdat
			ldi	XL,0x08			;begin prog
			rcall	pic1_cmd
			mov	ZL,r18
			clr	ZH
			call	api_wait_ms
			rcall	pic1_endprog
			rcall	pic1_incaddr
			sbiw	r24,1
			brne	pic1_dprog2_1
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; program data flash
;-------------------------------------------------------------------------------
pic1_dprog3:		movw	r24,r16			;bytes to do
			call	api_resetptr
			cpi	r19,0
			breq	pic1_dprog3_1
			rcall	pic1_reentry
pic1_dprog3_1:		ldi	XL,0x03			;load for dmem
			rcall	pic1_cmd
			call	api_buf_bread
			clr	XH
			call	pic1_wdat
			ldi	XL,0x08			;begin prog
			rcall	pic1_cmd
			mov	ZL,r18
			clr	ZH
			call	api_wait_ms
			call	api_buf_bread		;read dummy byte
			rcall	pic1_incaddr
			sbiw	r24,1
			brne	pic1_dprog3_1
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; read data flash
;-------------------------------------------------------------------------------
pic1_dread:		movw	r24,r16
			call	api_resetptr
			cpi	r19,0
			breq	pic1_dread_1
			rcall	pic1_reentry
pic1_dread_1:		ldi	XL,0x05			;read from dmem
			rcall	pic1_cmd
			call	pic1_rdat		;read
			call	api_buf_bwrite
			rcall	pic1_incaddr
			sbiw	r24,1
			brne	pic1_dread_1
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; read data flash
;-------------------------------------------------------------------------------
pic1_dread3:		movw	r24,r16
			call	api_resetptr
			cpi	r19,0
			breq	pic1_dread3_1
			rcall	pic1_reentry
pic1_dread3_1:		ldi	XL,0x05			;read from dmem
			rcall	pic1_cmd
			call	pic1_rdat		;read
			call	api_buf_bwrite
			rcall	pic1_incaddr
			clr	XL
			call	api_buf_bwrite
			sbiw	r24,1
			brne	pic1_dread3_1
			jmp	main_loop_ok

;-------------------------------------------------------------------------------
; program config /UID
; p1: words to skip
; p2: words to prog
; p3: prog time
;-------------------------------------------------------------------------------
pic1_cprog:	movw	r24,r16			;four-words to to
		call	api_resetptr
		rcall	pic1_reentry
		rcall	pic1_loadconf
pic1_cprog_1:	cpi	r24,0
		breq	pic1_cprog_2
		rcall	pic1_incaddr
		dec	r24
		rjmp	pic1_cprog_1

pic1_cprog_2:	ldi	XL,0x02			;load for pmem
		rcall	pic1_cmd
		call	api_buf_lread
		call	pic1_wdat
		ldi	XL,0x08			;begin prog
		rcall	pic1_cmd
		mov	ZL,r18
		clr	ZH
		call	api_wait_ms
		rcall	pic1_incaddr
		dec	r25
		brne	pic1_cprog_1
		jmp	main_loop_ok

;-------------------------------------------------------------------------------
; program config /UID
; p1: words to skip
; p2: words to prog
; p3: prog time
;-------------------------------------------------------------------------------
pic1_cprog2:	movw	r24,r16			;four-words to to
		call	api_resetptr
		rcall	pic1_reentry
		rcall	pic1_loadconf
pic1_cprog2_1:	cpi	r24,0
		breq	pic1_cprog2_2
		rcall	pic1_incaddr
		dec	r24
		rjmp	pic1_cprog2_1

pic1_cprog2_2:	ldi	XL,0x02			;load for pmem
		rcall	pic1_cmd
		call	api_buf_lread
		call	pic1_wdat
		ldi	XL,0x08			;begin prog
		rcall	pic1_cmd
		mov	ZL,r18
		clr	ZH
		call	api_wait_ms
		rcall	pic1_endprog
		rcall	pic1_incaddr
		dec	r25
		brne	pic1_cprog2_1
		jmp	main_loop_ok


;-------------------------------------------------------------------------------
; read prog flash / config
; p1: words to skip
; p2: words to prog
;-------------------------------------------------------------------------------
pic1_cread:	movw	r24,r16			;words to do
		call	api_resetptr
		rcall	pic1_reentry
		rcall	pic1_loadconf
pic1_cread_1:	cpi	r24,0
		breq	pic1_cread_2
		rcall	pic1_incaddr
		dec	r24
		rjmp	pic1_cread_1

pic1_cread_2:	ldi	XL,0x04			;read from pmem
		rcall	pic1_cmd
		call	pic1_rdat		;read
		call	api_buf_lwrite
		rcall	pic1_incaddr
		dec	r25
		brne	pic1_cread_2
		jmp	main_loop_ok



;-------------------------------------------------------------------------------
; write command
; XL = CMD
;-------------------------------------------------------------------------------
pic1_cmd:	ldi	r21,6
pic1_cmd_1:	sbrc	XL,0			;1
		sbi	CTRLPORT,PGD		;2
		sbrs	XL,0			;1
		cbi	CTRLPORT,PGD		;2
		lsr	XL			;1
		sbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2
		dec	r21
		brne	pic1_cmd_1
		ldi	r21,4
pic1_cmd_2:	dec	r21
		brne	pic1_cmd_2
		ret

;-------------------------------------------------------------------------------
; write command
; XL = CMD
;-------------------------------------------------------------------------------
pic1_cmd2:	ldi	r21,8
pic1_cmd2_1:	sbrc	XL,7			;1
		sbi	CTRLPORT,PGD		;2
		sbrs	XL,7			;1
		cbi	CTRLPORT,PGD		;2
		lsl	XL			;1
		sbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2
		dec	r21
		brne	pic1_cmd2_1
		ldi	r21,4
pic1_cmd2_2:	dec	r21
		brne	pic1_cmd2_2
		ret

;-------------------------------------------------------------------------------
; write data
; X = data
;-------------------------------------------------------------------------------
pic1_wdat:	cbi	CTRLPORT,PGD		;2 start bit
		nop
		nop
		nop
		sbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2
		ldi	r21,14
		nop
		nop
pic1_wdat_1:	sbrc	XL,0			;1
		sbi	CTRLPORT,PGD		;2
		sbrs	XL,0			;1
		cbi	CTRLPORT,PGD		;2
		lsr	XH			;1
		ror	XL
		sbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2
		dec	r21
		brne	pic1_wdat_1
		nop
		cbi	CTRLPORT,PGD		;2 stop bit
		nop
		nop
		nop
		sbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2
		ldi	r21,4
pic1_wdat_2:	dec	r21
		brne	pic1_wdat_2
		ret

;-------------------------------------------------------------------------------
; write data (24 Bit)
; X = data
;-------------------------------------------------------------------------------
pic1_wdat2:	ldi	r21,8
		cbi	CTRLPORT,PGD		;10 start bits
		nop
		nop
		nop
pic1_wdat2_1:	sbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2
		dec	r21
		brne	pic1_wdat2_1
		
		ldi	r21,16
pic1_wdat2_2:	sbrc	XH,7			;1
		sbi	CTRLPORT,PGD		;2
		sbrs	XH,7			;1
		cbi	CTRLPORT,PGD		;2
		lsl	XL			;1
		rol	XH
		sbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2
		dec	r21
		brne	pic1_wdat2_2
		nop
		cbi	CTRLPORT,PGD		;2 stop bit
		nop
		nop
		nop
		sbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2

		ldi	r21,4
pic1_wdat2_3:	dec	r21
		brne	pic1_wdat2_3
		ret

;-------------------------------------------------------------------------------
; write data (24 Bit)
; X = data
;-------------------------------------------------------------------------------
pic1_waddr2:	ldi	r21,7
		cbi	CTRLPORT,PGD		;10 start bits
		nop
		nop
		nop
pic1_waddr2_1:	sbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2
		dec	r21
		brne	pic1_waddr2_1
		
		ldi	r21,16
pic1_waddr2_2:	sbrc	XH,7			;1
		sbi	CTRLPORT,PGD		;2
		sbrs	XH,7			;1
		cbi	CTRLPORT,PGD		;2
		lsl	XL			;1
		rol	XH
		sbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2
		dec	r21
		brne	pic1_waddr2_2
		nop
		cbi	CTRLPORT,PGD		;2 stop bit
		nop
		nop
		nop
		sbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2

		ldi	r21,4
pic1_waddr2_3:	dec	r21
		brne	pic1_waddr2_3
		ret


;-------------------------------------------------------------------------------
; read data
; X = data
;-------------------------------------------------------------------------------
pic1_rdat:	cbi	CTRLDDR,PGD		;2 
		ldi	r21,14
		clr	XL
		clr	XH
pic1_rdat_1:	sbi	CTRLPORT,PGC		; ignore start
		nop
		nop
		nop
		cbi	CTRLPORT,PGC		;2
		nop
		nop
		nop
pic1_rdat_2:	sbi	CTRLPORT,PGC		;2
		lsr	XH
		ror	XL
		nop
		sbic	CTRLPIN,PGD
		ori	XH,0x80
		cbi	CTRLPORT,PGC		;2
		dec	r21
		brne	pic1_rdat_2
		sbi	CTRLPORT,PGC		; ignore stopp
		lsr	XH
		ror	XL
		nop
		cbi	CTRLPORT,PGC		;
		lsr	XH
		ror	XL
		nop

		ldi	r21,4
pic1_rdat_3:	dec	r21
		brne	pic1_rdat_3
		sbi	CTRLDDR,PGD
		ret


;-------------------------------------------------------------------------------
; read data
; X = data
;-------------------------------------------------------------------------------
pic1_rdat2:	cbi	CTRLDDR,PGD		;2 
		ldi	r21,7
pic1_rdat2_1:	sbi	CTRLPORT,PGC		;2
		nop
		nop
		cbi	CTRLPORT,PGC		;2
		dec	r21
		brne	pic1_rdat2_1

		clr	XL
		clr	XH
		ldi	r21,16
pic1_rdat2_2:	sbi	CTRLPORT,PGC		;2
		lsl	XL
		rol	XH
		cbi	CTRLPORT,PGC		;2
		sbic	CTRLPIN,PGD
		ori	XL,0x01
		dec	r21
		brne	pic1_rdat2_2

		sbi	CTRLPORT,PGC		; ignore stopp
		nop
		nop
		cbi	CTRLPORT,PGC		;

		ldi	r21,4
pic1_rdat2_4:	dec	r21
		brne	pic1_rdat2_4
		sbi	CTRLDDR,PGD
		ret

