;---------------------------------------------------------------------
; generated file for frequency = 6 MHz
; Send:
; SIZE-0 = 13 clocks
; SIZE-D = 30 clocks
; SIZE-1 = 14 clocks
; Receive:
; SIZE-0 = 13 clocks
; SIZE-S = 20 clocks
; SIZE-W = 24 clocks
;---------------------------------------------------------------------
.org (pc + 255) & 0xff00
bdms6_send8:	ldi	r20,8
		mov	XH,XL
		rjmp	bdms6_send16_1

.org (pc & 0xff00) + BDM_SUB_SWORD
bdms6_send16:	ldi	r20,16
bdms6_send16_1:	sbi	CTRLDDR,SIG2
		out	CTRLPORT,r0
		ldi	r21,3
bdms6_send16_2:	dec	r21
		brne	bdms6_send16_2
		nop
		nop
		sbrc	XH,7
		out	CTRLPORT,r1
		ldi	r21,9
bdms6_send16_3:	dec	r21
		brne	bdms6_send16_3
		nop
		nop
		out	CTRLPORT,r1
		cbi	CTRLDDR,SIG2
		ldi	r21,2
bdms6_send16_4:	dec	r21
		brne	bdms6_send16_4
		nop
		lsl	XL
		rol	XH
		dec	r20
		brne	bdms6_send16_1
		ret

.org (pc & 0xff00) + BDM_SUB_RBYTE
bdms6_recv8:	ldi	r20,8
		rjmp	bdms6_recv16_1

.org (pc & 0xff00) + BDM_SUB_RWORD
bdms6_recv16:	ldi	r20,16
bdms6_recv16_1:	sbi	CTRLDDR,SIG2
		out	CTRLPORT,r0
		ldi	r21,4
bdms6_recv16_2:	dec	r21
		brne	bdms6_recv16_2
		cbi	CTRLDDR,SIG2
		out	CTRLPORT,r1
		ldi	r21,5
bdms6_recv16_3:	dec	r21
		brne	bdms6_recv16_3
		lsl	XL
		rol	XH
		sbic	CTRLPIN,SIG2
		inc	XL
		ldi	r21,7
bdms6_recv16_4:	dec	r21
		brne	bdms6_recv16_4
		dec	r20
		brne	bdms6_recv16_1
		ret

.org (pc & 0xff00) + BDM_SUB_WAIT16
bdms6_wait16:	
		ldi	r21,16
bdms6_wait16_1:	dec	r21
		brne	bdms6_wait16_1
		ret

.org (pc & 0xff00) + BDM_SUB_WAIT160
bdms6_wait160:	
		ldi	r21,186
bdms6_wait160_1:	dec	r21
		brne	bdms6_wait160_1
		ret

.org (pc & 0xff00) + BDM_SUB_BREAD8
bdms6_bread8:	ldi	XL,0xe0
		rcall	bdms6_send8
		movw	XL,r24
		rcall	bdms6_send16
		call	bdm_wait2_ack
		rcall	bdms6_wait16
		rcall	bdms6_recv8
		call	api_buf_bwrite
		adiw	r24,1
		ret

.org (pc & 0xff00) + BDM_SUB_BWRITE8
bdms6_bwrite8:	ldi	XL,0xc0
		rcall	bdms6_send8
		movw	XL,r24
		rcall	bdms6_send16
		call	api_buf_bread
		rcall	bdms6_send8
		call	bdm_wait2_ack
		rcall	bdms6_wait16
		adiw	r24,1
		ret

.org (pc & 0xff00) + BDM_SUB_BREADF8
bdms6_breadf8:	ldi	XL,0xe0
		rcall	bdms6_send8
		movw	XL,r22
		rcall	bdms6_send16
		call	bdm_wait2_ack
		rcall	bdms6_wait16
		rjmp	bdms6_recv8

.org (pc & 0xff00) + BDM_SUB_BWRITEF8
		push	XL
bdms6_bwritef8:	ldi	XL,0xc0
		rcall	bdms6_send8
		movw	XL,r22
		rcall	bdms6_send16
		pop	XL
		rcall	bdms6_send8
		call	bdm_wait2_ack
		rjmp	bdms6_wait16

.org (pc & 0xff00) + BDM_SUB_BREADF16
bdms6_breadf16:	ldi	XL,0xe0
bdms6_breadf16a:	
		rcall	bdms6_send8
		movw	XL,r22
		rcall	bdms6_send16
		rcall	bdms6_wait160
		rcall	bdms6_recv16
		sbrs	r22,0
		mov	XL,XH
		ret

.org (pc & 0xff00) + BDM_SUB_BWRITEF16
		push	XL
bdms6_bwritef16:	ldi	XL,0xc0
bdms6_bwritef16a:	
		rcall	bdms6_send8
		movw	XL,r22
		rcall	bdms6_send16
		pop	XL
		mov	XH,XL
		rcall	bdms6_send16
		rcall	bdms6_wait160
		ret

.org (pc & 0xff00) + BDM_SUB_WREAD
bdms6_wread:	ldi	XL,0xe8
		rcall	bdms6_send8
		movw	XL,r24
		rcall	bdms6_send16
		rcall	bdms6_wait160
		rcall	bdms6_recv16
		call	api_buf_mwrite
		adiw	r24,2
		ret

.org (pc & 0xff00) + BDM_SUB_WWRITE
bdms6_wwrite:	ldi	XL,0xc8
		rcall	bdms6_send8
		movw	XL,r24
		rcall	bdms6_send16
		call	api_buf_mread
		rcall	bdms6_send16
		rcall	bdms6_wait160
		adiw	r24,2
		ret

.org (pc & 0xff00) + BDM_SUB_WREADF
bdms6_wreadf:	ldi	XL,0xe8
		rcall	bdms6_send8
		movw	XL,r22
		rcall	bdms6_send16
		rcall	bdms6_wait160
		rcall	bdms6_recv16
		ret

.org (pc & 0xff00) + BDM_SUB_WWRITEF
bdms6_wwritef:	movw	r18,XL
		ldi	XL,0xc8
		rcall	bdms6_send8
		movw	XL,r22
		rcall	bdms6_send16
		movw	XL,r18
		rcall	bdms6_send16
		rjmp	bdms6_wait160

.org (pc & 0xff00) + BDM_SUB_RSTAT
bdms6_bstat16:	ldi	XL,0xe4
		ldi	r22,0x01
		ldi	r23,0xff
		rjmp	bdms6_breadf16a

.org (pc & 0xff00) + BDM_SUB_WSTAT
		push	XL
bdms6_wstat16:	ldi	XL,0xc4
		ldi	r22,0x01
		ldi	r23,0xff
		rjmp	bdms6_bwritef16a


