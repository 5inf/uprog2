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

.equ		BDM_SUB_SBYTE = 0x00
.equ		BDM_SUB_SWORD = 0x08
.equ		BDM_SUB_RBYTE = 0x28
.equ		BDM_SUB_RWORD = 0x30
.equ		BDM_SUB_WAIT16  = 0x50
.equ		BDM_SUB_WAIT160  = 0x56
.equ		BDM_SUB_BREAD8 = 0x60
.equ		BDM_SUB_BWRITE8 = 0x70
.equ		BDM_SUB_BREADF8 = 0x80
.equ		BDM_SUB_BWRITEF8 = 0x90
.equ		BDM_SUB_BREADF16 = 0xa0
.equ		BDM_SUB_BWRITEF16 = 0xb0
.equ		BDM_SUB_WREAD = 0xc0
.equ		BDM_SUB_WWRITE = 0xd0
.equ		BDM_SUB_WREADF = 0xe0
.equ		BDM_SUB_WWRITEF = 0xe8
.equ		BDM_SUB_RSTAT = 0xf3
.equ		BDM_SUB_WSTAT = 0xf8


bdm_prepare:	push	r21
		in	r21,CTRLPORT		;1
		andi	r21,SIG2_AND		;1 clear SIG2
		mov	r0,r21			;1 store for start bit
		ori	r21,SIG2_OR		;1
		mov	r1,r21			;1 set SIG2
		pop	r21
		ret

bdm_wait_ack:	clr	r20
bdm_wait_ack1:	sbis	CTRLPIN,SIG2
		rjmp	bdm_wait_ack2
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		sbis	CTRLPIN,SIG2
		rjmp	bdm_wait_ack2
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		dec	r20
		brne	bdm_wait_ack1
		ldi	r16,0x33		;no ack
		pop	r20
		pop	r20
		jmp	main_loop

bdm_wait_ack2:	clr	r20
bdm_wait_ack3:	sbic	CTRLPIN,SIG2
		rjmp	bdm_wait_ack4
		dec	r20
		brne	bdm_wait_ack3
		ldi	r16,0x34		;no ack release
		pop	r20
		pop	r20
		jmp	main_loop

bdm_wait_ack4:	jmp	bdm_wait16


bdm_wait2_ack:	clr	r20
		cbi	CTRLDDR,SIG2
bdm_wait2_ack1:	sbis	CTRLPIN,SIG2
		rjmp	bdm_wait2_ack2
		nop
		nop
		nop
		nop
		dec	r20
		brne	bdm_wait2_ack1
		ldi	r16,0x33		;no ack
		pop	r20
		pop	r20
		pop	r20
		pop	r20
		jmp	main_loop

bdm_wait2_ack2:	clr	r20
bdm_wait2_ack3:	sbic	CTRLPIN,SIG2
		rjmp	bdm_wait2_ack4
		dec	r20
		brne	bdm_wait2_ack3
		ldi	r16,0x34		;no ack release
		pop	r20
		pop	r20
		pop	r20
		pop	r20
		jmp	main_loop

bdm_wait2_ack4:	jmp	bdm_wait160

;------------------------------------------------------------------------------
; bdm Re-initialisierung
;------------------------------------------------------------------------------
bdm_setfreq:	ldi	r18,HIGH(bdm_jtab)
		add	r16,r18
		out	EEARL,r16
		rcall	reinit_bdm_nf
		jmp	main_loop

bdm_setfreqz:	ldi	r18,HIGH(bdm_jtab)
		add	r16,r18
		out	EEARL,r16
		rcall	reinit_bdmz_nf
		jmp	main_loop

bdm_setfreq0:	ldi	r18,HIGH(bdm_jtab)
		add	r16,r18
		out	EEARL,r16
		jmp	main_loop_ok
		sbi	CTRLPORT,SIG2		;BKGD HIGH
		sbi	CTRLDDR,SIG2		;activate BKGD
		ldi	ZL,3			;5ms
		clr	ZH
		call	wait_ms
		cbi	CTRLPORT,SIG2		;BKGD LOW
		ldi	ZH,0x10		
		rcall	reinit_bdm_s1		
		jmp	main_loop_ok


reinit_bdm:	cbi	CTRLPORT,SIG2		;BKGD LOW
		cbi	CTRLPORT,SIG1		;RESET LOW
		sbi	CTRLDDR,SIG2		;set to output
		sbi	CTRLDDR,SIG1
		ldi	ZL,50			;50ms wait for vcc
		clr	ZH
		call	wait_ms
		sbi	CTRLPORT,SIG1		;RESET HIGH
		cbi	CTRLDDR,SIG1		;realease reset
		ldi	ZH,0
		ldi	ZL,0
reinit_bdm_r0:	sbic	CTRLPIN,SIG1		;skip if reset is low
		rjmp	reinit_bdm_r1
		sbiw	ZL,1
		brne	reinit_bdm_r0
		ldi	r16,0x30		;RESET LOW
		ret

reinit_bdm_rp:	ldi	r16,0x36		;RESET PULSE
		ret

reinit_bdm_r1:	ldi	r20,200
reinit_bdm_r2:	sbis	CTRLPIN,SIG1
		rjmp	reinit_bdm_rp
		ldi	ZL,1			;200 x 1ms
		ldi	ZH,0
		call	wait_ms
		dec	r20
		brne	reinit_bdm_r2

reinit_bdm_nf:	sbi	CTRLPORT,SIG2		;BKGD HIGH
		sbi	CTRLDDR,SIG2		;activate BKGD
		ldi	ZL,3			;5ms
		clr	ZH
		call	wait_ms
		cbi	CTRLPORT,SIG2		;BKGD LOW
		ldi	ZH,0x40
reinit_bdm_s1:	ldi	ZL,19
reinit_bdm_s2:	dec	ZL
		brne	reinit_bdm_s2
		dec	ZH
		brne	reinit_bdm_s1
		sbi	CTRLPORT,SIG2		;BKGD HIGH
		clr	XH			;clear wsync timeout
		clr	XL			;clear msync timeout
		cbi	CTRLDDR,SIG2		;release BKGD

reinit_bdm_1:	sbis	CTRLPIN,SIG2		;2 wait for sync
		rjmp	reinit_bdm_2a		;branch, sync is started
		inc	XH			;1
		brne	reinit_bdm_1		;2 no timeout
		ldi	r16,0x31		;error-no sync pulse, BKGD remains high
		ret				;timeout -> no sync

reinit_bdm_2:	sbic	CTRLPIN,SIG2		;2 wait for no sync
		rjmp	reinit_bdm_3		;branch, sync is ended
reinit_bdm_2a:	inc	XL			;1
		brne	reinit_bdm_2		;2 no timeout
		ldi	r16,0x33		;error-SYNC pulse too long
		ret				;timeout -> no sync

reinit_bdm_3:	call	api_resetptr		;reset buf ptr
		call	api_buf_lwrite
		sbi	CTRLDDR,SIG2		;BKGD HIGH
		clr	r16
		ret


reinit_bdmz:	cbi	CTRLPORT,SIG2		;BKGD LOW
		cbi	CTRLPORT,SIG1		;RESET LOW
		sbi	CTRLDDR,SIG2		;set to output
		sbi	CTRLDDR,SIG1
		ldi	ZL,50			;50ms wait for vcc
		clr	ZH
		call	wait_ms
		sbi	CTRLPORT,SIG1		;RESET HIGH
		cbi	CTRLDDR,SIG1		;realease reset
		ldi	ZH,0
		ldi	ZL,0
reinit_bdmz_r0:	sbic	CTRLPIN,SIG1		;skip if reset is low
		rjmp	reinit_bdmz_r1
		sbiw	ZL,1
		brne	reinit_bdmz_r0
		ldi	r16,0x30		;RESET LOW
		ret

reinit_bdmz_rp:	ldi	r16,0x36		;RESET PULSE
		ret

reinit_bdmz_r1:	ldi	r20,200
reinit_bdmz_r2:	sbis	CTRLPIN,SIG1
		rjmp	reinit_bdmz_rp
		ldi	ZL,1			;200 x 1ms
		ldi	ZH,0
		call	wait_ms
		dec	r20
		brne	reinit_bdmz_r2

reinit_bdmz_nf:	sbi	CTRLPORT,SIG2		;BKGD HIGH
		sbi	CTRLDDR,SIG2		;activate BKGD
		ldi	ZL,3			;5ms
		clr	ZH
		call	wait_ms
		cbi	CTRLPORT,SIG2		;BKGD LOW
		ldi	ZH,0x40
reinit_bdmz_s1:	ldi	ZL,19
reinit_bdmz_s2:	dec	ZL
		brne	reinit_bdmz_s2
		dec	ZH
		brne	reinit_bdmz_s1
		sbi	CTRLPORT,SIG2		;BKGD HIGH
		clr	XH			;clear wsync timeout
		clr	XL			;clear msync timeout
		cbi	CTRLDDR,SIG2		;release BKGD

reinit_bdmz_1:	sbis	CTRLPIN,SIG2		;2 wait for sync
		rjmp	reinit_bdmz_2a		;branch, sync is started
		inc	XH			;1
		brne	reinit_bdmz_1		;2 no timeout
		ldi	r16,0x31		;error-no sync pulse, BKGD remains high
		ret				;timeout -> no sync

reinit_bdmz_2:	sbic	CTRLPIN,SIG2		;2 wait for no sync
		rjmp	reinit_bdmz_3		;branch, sync is ended
reinit_bdmz_2a:	inc	XL			;1
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop		
		brne	reinit_bdmz_2		;2 no timeout
		ldi	r16,0x33		;error-SYNC pulse too long
		ret				;timeout -> no sync

reinit_bdmz_3:	call	api_resetptr		;reset buf ptr
		call	api_buf_lwrite
		sbi	CTRLDDR,SIG2		;BKGD HIGH
		clr	r16
		ret



;------------------------------------------------------------------------------
; bdm Initialisierung
;------------------------------------------------------------------------------
init_bdm:	cbi	CTRLPORT,SIG2		;BKGD LOW
		cbi	CTRLPORT,SIG1		;RESET LOW
		sbi	CTRLDDR,SIG2		;set to output
		sbi	CTRLDDR,SIG1
		call	api_vcc_off
		ldi	ZL,50			;20ms
		clr	ZH
		call	wait_ms
		call	api_vcc_on
		ldi	ZL,200			;250ms wait for vcc
		clr	ZH
		call	wait_ms
		sbi	CTRLPORT,SIG1		;RESET HIGH
		sbrs	r19,7			;skip release if PAR4 > 127
		cbi	CTRLDDR,SIG1		;realease reset
		ldi	ZH,0
		ldi	ZL,0
init_bdm_r0:	sbic	CTRLPIN,SIG1		;skip if reset is low
		rjmp	init_bdm_r1
		sbiw	ZL,1
		brne	init_bdm_r0
		ldi	r16,0x30		;RESET LOW
		jmp	main_loop

init_bdm_rp:	ldi	r16,0x36		;RESET PULSE
		jmp	main_loop

init_bdm_r1:	ldi	r20,200
init_bdm_r2:	sbis	CTRLPIN,SIG1
		rjmp	init_bdm_rp
		ldi	ZL,1			;200 x 1ms
		ldi	ZH,0
		call	wait_ms
		dec	r20
		brne	init_bdm_r2

		sbi	CTRLPORT,SIG2		;BKGD HIGH
		sbi	CTRLDDR,SIG2		;activate BKGD
		ldi	ZL,3			;5ms
		clr	ZH
		call	wait_ms
		cbi	CTRLPORT,SIG2		;BKGD LOW
		ldi	ZH,0x40
init_bdm_s1:	ldi	ZL,19
init_bdm_s2:	dec	ZL
		brne	init_bdm_s2
		dec	ZH
		brne	init_bdm_s1
		sbi	CTRLPORT,SIG2		;BKGD HIGH
		clr	XH			;clear wsync timeout
		clr	XL			;clear msync timeout
		cbi	CTRLDDR,SIG2		;release BKGD

init_bdm_1:	sbis	CTRLPIN,SIG2		;2 wait for sync
		rjmp	init_bdm_2a		;branch, sync is started
		inc	XH			;1
		brne	init_bdm_1		;2 no timeout
		ldi	r16,0x31		;error-no sync pulse, BKGD remains high
		jmp	main_loop		;timeout -> no sync

init_bdm_2:	sbic	CTRLPIN,SIG2		;2 wait for no sync
		rjmp	init_bdm_3		;branch, sync is ended
init_bdm_2a:	inc	XL			;1
		brne	init_bdm_2		;2 no timeout
		ldi	r16,0x32		;error-SYNC pulse too long
		jmp	main_loop		;timeout -> no sync

init_bdm_3:	call	api_resetptr
		call	api_buf_lwrite
		sbi	CTRLDDR,SIG2		;BKGD HIGH
		jmp	main_loop_ok

;------------------------------------------------------------------------------
; bdm Initialisierung
;------------------------------------------------------------------------------
init_bdmz:	cbi	CTRLPORT,SIG2		;BKGD LOW
		cbi	CTRLPORT,SIG1		;RESET LOW
		sbi	CTRLDDR,SIG2		;set to output
		sbi	CTRLDDR,SIG1
		call	api_vcc_off
		ldi	ZL,50			;20ms
		clr	ZH
		call	wait_ms
		call	api_vcc_on
		ldi	ZL,200			;250ms wait for vcc
		clr	ZH
		call	wait_ms
		sbi	CTRLPORT,SIG1		;RESET HIGH
		sbrs	r19,7			;skip release if PAR4 > 127
		cbi	CTRLDDR,SIG1		;realease reset
		ldi	ZH,0
		ldi	ZL,0
init_bdmz_r0:	sbic	CTRLPIN,SIG1		;skip if reset is low
		rjmp	init_bdmz_r1
		sbiw	ZL,1
		brne	init_bdmz_r0
		ldi	r16,0x30		;RESET LOW
		jmp	main_loop

init_bdmz_rp:	ldi	r16,0x36		;RESET PULSE
		jmp	main_loop

init_bdmz_r1:	ldi	r20,200
init_bdmz_r2:	sbis	CTRLPIN,SIG1
		rjmp	init_bdmz_rp
		ldi	ZL,1			;200 x 1ms
		ldi	ZH,0
		call	wait_ms
		dec	r20
		brne	init_bdmz_r2

		sbi	CTRLPORT,SIG2		;BKGD HIGH
		sbi	CTRLDDR,SIG2		;activate BKGD
		ldi	ZL,3			;5ms
		clr	ZH
		call	wait_ms
		cbi	CTRLPORT,SIG2		;BKGD LOW
		ldi	ZH,0x40
init_bdmz_s1:	ldi	ZL,19
init_bdmz_s2:	dec	ZL
		brne	init_bdmz_s2
		dec	ZH
		brne	init_bdmz_s1
		sbi	CTRLPORT,SIG2		;BKGD HIGH
		clr	XH			;clear wsync timeout
		clr	XL			;clear msync timeout
		cbi	CTRLDDR,SIG2		;release BKGD

init_bdmz_1:	sbis	CTRLPIN,SIG2		;2 wait for sync
		rjmp	init_bdmz_2a		;branch, sync is started
		inc	XH			;1
		brne	init_bdmz_1		;2 no timeout
		ldi	r16,0x31		;error-no sync pulse, BKGD remains high
		jmp	main_loop		;timeout -> no sync

init_bdmz_2:	sbic	CTRLPIN,SIG2		;2 wait for no sync
		rjmp	init_bdmz_3		;branch, sync is ended
init_bdmz_2a:	inc	XL			;1
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop		

		brne	init_bdmz_2		;2 no timeout
		ldi	r16,0x32		;error-SYNC pulse too long
		jmp	main_loop		;timeout -> no sync

init_bdmz_3:	call	api_resetptr
		call	api_buf_lwrite
		sbi	CTRLDDR,SIG2		;BKGD HIGH
		jmp	main_loop_ok


;------------------------------------------------------------------------------
; bdm beenden
;------------------------------------------------------------------------------
exit_bdm:	ldi	ZL,10			;10ms
		clr	ZH
		call	wait_ms
		sbi	CTRLDDR,SIG2		;activate BKGD
		sbi	CTRLDDR,SIG1		;activate RES
		cbi	CTRLPORT,SIG2		;BKGD LOW
		cbi	CTRLPORT,SIG1		;RESET LOW
		ldi	ZL,20			;50ms
		clr	ZH
		call	api_wait_ms
		call	api_vcc_dis		;disconnect vcc
		cbi	CTRLDDR,SIG2		;release BKGD
		cbi	CTRLDDR,SIG1		;release RES
		jmp	main_loop_ok

;------------------------------------------------------------------------------
; Subfunktionen
;------------------------------------------------------------------------------
bdm8_bread:	ldi	ZL,BDM_SUB_BREAD8
		in	ZH,EEARL
		ijmp

bdm8_breadf:	ldi	ZL,BDM_SUB_BREADF8
		in	ZH,EEARL
		ijmp

bdm8_bwrite:	ldi	ZL,BDM_SUB_BWRITE8
		in	ZH,EEARL
		ijmp

bdm8_bwritef:	ldi	ZL,BDM_SUB_BWRITEF8
		in	ZH,EEARL
		ijmp

bdm16_breadf:	ldi	ZL,BDM_SUB_BREADF16
		in	ZH,EEARL
		ijmp

bdm16_bwritef:	ldi	ZL,BDM_SUB_BWRITEF16
		in	ZH,EEARL
		ijmp

bdm16_wread:	ldi	ZL,BDM_SUB_WREAD
		in	ZH,EEARL
		ijmp

bdm16_wreadf:	ldi	ZL,BDM_SUB_WREADF
		in	ZH,EEARL
		ijmp

bdm16_wwrite:	ldi	ZL,BDM_SUB_WWRITE
		in	ZH,EEARL
		ijmp

bdm16_wwritef:	ldi	ZL,BDM_SUB_WWRITEF
		in	ZH,EEARL
		ijmp

bdm_send_byte:	ldi	ZL,BDM_SUB_SBYTE
		in	ZH,EEARL
		ijmp

bdm_send_word:	ldi	ZL,BDM_SUB_SWORD
		in	ZH,EEARL
		ijmp

bdm_recv_byte:	ldi	ZL,BDM_SUB_RBYTE
		in	ZH,EEARL
		ijmp

bdm_recv_word:	ldi	ZL,BDM_SUB_RWORD
		in	ZH,EEARL
		ijmp

bdm_wait16:	ldi	ZL,BDM_SUB_WAIT16
		in	ZH,EEARL
		ijmp

bdm_wait160:	ldi	ZL,BDM_SUB_WAIT160
		in	ZH,EEARL
		ijmp

bdm_status:	ldi	ZL,BDM_SUB_RSTAT
		in	ZH,EEARL
		ijmp

bdm_wstatus:	ldi	ZL,BDM_SUB_WSTAT
		in	ZH,EEARL
		ijmp


.org (pc + 255) & 0xff00

bdm_jtab:
;------------------------------------------------------------------------------
; BDM functions table
;------------------------------------------------------------------------------
.include	"modules/bdm_sub_1.asm"
.include	"modules/bdm_sub_2.asm"
.include	"modules/bdm_sub_3.asm"
.include	"modules/bdm_sub_4.asm"
.include	"modules/bdm_sub_5.asm"
.include	"modules/bdm_sub_6.asm"
.include	"modules/bdm_sub_7.asm"
.include	"modules/bdm_sub_8.asm"
.include	"modules/bdm_sub_9.asm"
.include	"modules/bdm_sub_10.asm"
.include	"modules/bdm_sub_11.asm"
.include	"modules/bdm_sub_12.asm"
.include	"modules/bdm_sub_13.asm"
.include	"modules/bdm_sub_14.asm"
.include	"modules/bdm_sub_15.asm"
.include	"modules/bdm_sub_16.asm"

