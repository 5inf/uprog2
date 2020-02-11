;---------------------------------------------------------------------
; generated file for frequency = 7 MHz
; Send:
; SIZE-0 = 11 clocks
; SIZE-D = 26 clocks
; SIZE-1 = 12 clocks
; Receive:
; SIZE-0 = 11 clocks
; SIZE-S = 17 clocks
; SIZE-W = 20 clocks
;---------------------------------------------------------------------
.org (pc + 255) & 0xff00
bdms7_send8:	ldi	r20,8
		mov	XH,XL
		rjmp	bdms7_send16_1

.org (pc & 0xff00) + BDM_SUB_SWORD
bdms7_send16:	ldi	r20,16
bdms7_send16_1:	sbi	CTRLDDR,SIG2
		out	CTRLPORT,r0
		ldi	r21,3
bdms7_send16_2:	dec	r21
		brne	bdms7_send16_2
		sbrc	XH,7
		out	CTRLPORT,r1
		ldi	r21,8
bdms7_send16_3:	dec	r21
		brne	bdms7_send16_3
		nop
		out	CTRLPORT,r1
		cbi	CTRLDDR,SIG2
		ldi	r21,1
bdms7_send16_4:	dec	r21
		brne	bdms7_send16_4
		nop
		nop
		lsl	XL
		rol	XH
		dec	r20
		brne	bdms7_send16_1
		ret

.org (pc & 0xff00) + BDM_SUB_RBYTE
bdms7_recv8:	ldi	r20,8
		rjmp	bdms7_recv16_1

.org (pc & 0xff00) + BDM_SUB_RWORD
bdms7_recv16:	ldi	r20,16
bdms7_recv16_1:	sbi	CTRLDDR,SIG2
		out	CTRLPORT,r0
		ldi	r21,3
bdms7_recv16_2:	dec	r21
		brne	bdms7_recv16_2
		nop
		cbi	CTRLDDR,SIG2
		out	CTRLPORT,r1
		ldi	r21,4
bdms7_recv16_3:	dec	r21
		brne	bdms7_recv16_3
		lsl	XL
		rol	XH
		sbic	CTRLPIN,SIG2
		inc	XL
		ldi	r21,5
bdms7_recv16_4:	dec	r21
		brne	bdms7_recv16_4
		nop
		nop
		dec	r20
		brne	bdms7_recv16_1
		ret

.org (pc & 0xff00) + BDM_SUB_WAIT16
bdms7_wait16:	
		ldi	r21,13
bdms7_wait16_1:	dec	r21
		brne	bdms7_wait16_1
		nop
		ret

.org (pc & 0xff00) + BDM_SUB_WAIT160
bdms7_wait160:	
		ldi	r21,159
bdms7_wait160_1:	dec	r21
		brne	bdms7_wait160_1
		ret

.org (pc & 0xff00) + BDM_SUB_BREAD8
bdms7_bread8:	ldi	XL,0xe0
		rcall	bdms7_send8
		movw	XL,r24
		rcall	bdms7_send16
		call	bdm_wait2_ack
		rcall	bdms7_wait16
		rcall	bdms7_recv8
		call	api_buf_bwrite
		adiw	r24,1
		ret

.org (pc & 0xff00) + BDM_SUB_BWRITE8
bdms7_bwrite8:	ldi	XL,0xc0
		rcall	bdms7_send8
		movw	XL,r24
		rcall	bdms7_send16
		call	api_buf_bread
		rcall	bdms7_send8
		call	bdm_wait2_ack
		rcall	bdms7_wait16
		adiw	r24,1
		ret

.org (pc & 0xff00) + BDM_SUB_BREADF8
bdms7_breadf8:	ldi	XL,0xe0
		rcall	bdms7_send8
		movw	XL,r22
		rcall	bdms7_send16
		call	bdm_wait2_ack
		rcall	bdms7_wait16
		rjmp	bdms7_recv8

.org (pc & 0xff00) + BDM_SUB_BWRITEF8
		push	XL
bdms7_bwritef8:	ldi	XL,0xc0
		rcall	bdms7_send8
		movw	XL,r22
		rcall	bdms7_send16
		pop	XL
		rcall	bdms7_send8
		call	bdm_wait2_ack
		rjmp	bdms7_wait16

.org (pc & 0xff00) + BDM_SUB_BREADF16
bdms7_breadf16:	ldi	XL,0xe0
bdms7_breadf16a:	
		rcall	bdms7_send8
		movw	XL,r22
		rcall	bdms7_send16
		rcall	bdms7_wait160
		rcall	bdms7_recv16
		sbrs	r22,0
		mov	XL,XH
		ret

.org (pc & 0xff00) + BDM_SUB_BWRITEF16
		push	XL
bdms7_bwritef16:	ldi	XL,0xc0
bdms7_bwritef16a:	
		rcall	bdms7_send8
		movw	XL,r22
		rcall	bdms7_send16
		pop	XL
		mov	XH,XL
		rcall	bdms7_send16
		rcall	bdms7_wait160
		ret

.org (pc & 0xff00) + BDM_SUB_WREAD
bdms7_wread:	ldi	XL,0xe8
		rcall	bdms7_send8
		movw	XL,r24
		rcall	bdms7_send16
		rcall	bdms7_wait160
		rcall	bdms7_recv16
		call	api_buf_mwrite
		adiw	r24,2
		ret

.org (pc & 0xff00) + BDM_SUB_WWRITE
bdms7_wwrite:	ldi	XL,0xc8
		rcall	bdms7_send8
		movw	XL,r24
		rcall	bdms7_send16
		call	api_buf_mread
		rcall	bdms7_send16
		rcall	bdms7_wait160
		adiw	r24,2
		ret

.org (pc & 0xff00) + BDM_SUB_WREADF
bdms7_wreadf:	ldi	XL,0xe8
		rcall	bdms7_send8
		movw	XL,r22
		rcall	bdms7_send16
		rcall	bdms7_wait160
		rcall	bdms7_recv16
		ret

.org (pc & 0xff00) + BDM_SUB_WWRITEF
bdms7_wwritef:	movw	r18,XL
		ldi	XL,0xc8
		rcall	bdms7_send8
		movw	XL,r22
		rcall	bdms7_send16
		movw	XL,r18
		rcall	bdms7_send16
		rjmp	bdms7_wait160

.org (pc & 0xff00) + BDM_SUB_RSTAT
bdms7_bstat16:	ldi	XL,0xe4
		ldi	r22,0x01
		ldi	r23,0xff
		rjmp	bdms7_breadf16a

.org (pc & 0xff00) + BDM_SUB_WSTAT
		push	XL
bdms7_wstat16:	ldi	XL,0xc4
		ldi	r22,0x01
		ldi	r23,0xff
		rjmp	bdms7_bwritef16a


