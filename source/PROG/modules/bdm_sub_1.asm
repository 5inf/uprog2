;---------------------------------------------------------------------
; generated file for frequency = 1 MHz
; Send:
; SIZE-0 = 80 clocks
; SIZE-D = 180 clocks
; SIZE-1 = 80 clocks
; Receive:
; SIZE-0 = 80 clocks
; SIZE-S = 120 clocks
; SIZE-W = 140 clocks
;---------------------------------------------------------------------
.org (pc + 255) & 0xff00
bdms1_send8:	ldi	r20,8
		mov	XH,XL
		rjmp	bdms1_send16_1

.org (pc & 0xff00) + BDM_SUB_SWORD
bdms1_send16:	ldi	r20,16
bdms1_send16_1:	sbi	CTRLDDR,SIG2
		out	CTRLPORT,r0
		ldi	r21,26
bdms1_send16_2:	dec	r21
		brne	bdms1_send16_2
		sbrc	XH,7
		out	CTRLPORT,r1
		ldi	r21,59
bdms1_send16_3:	dec	r21
		brne	bdms1_send16_3
		nop
		nop
		out	CTRLPORT,r1
		cbi	CTRLDDR,SIG2
		ldi	r21,24
bdms1_send16_4:	dec	r21
		brne	bdms1_send16_4
		nop
		lsl	XL
		rol	XH
		dec	r20
		brne	bdms1_send16_1
		ret

.org (pc & 0xff00) + BDM_SUB_RBYTE
bdms1_recv8:	ldi	r20,8
		rjmp	bdms1_recv16_1

.org (pc & 0xff00) + BDM_SUB_RWORD
bdms1_recv16:	ldi	r20,16
bdms1_recv16_1:	sbi	CTRLDDR,SIG2
		out	CTRLPORT,r0
		ldi	r21,26
bdms1_recv16_2:	dec	r21
		brne	bdms1_recv16_2
		nop
		cbi	CTRLDDR,SIG2
		out	CTRLPORT,r1
		ldi	r21,38
bdms1_recv16_3:	dec	r21
		brne	bdms1_recv16_3
		nop
		lsl	XL
		rol	XH
		sbic	CTRLPIN,SIG2
		inc	XL
		ldi	r21,45
bdms1_recv16_4:	dec	r21
		brne	bdms1_recv16_4
		nop
		nop
		dec	r20
		brne	bdms1_recv16_1
		ret

.org (pc & 0xff00) + BDM_SUB_WAIT16
bdms1_wait16:	
		ldi	r21,110
bdms1_wait16_1:	dec	r21
		brne	bdms1_wait16_1
		nop
		ret

.org (pc & 0xff00) + BDM_SUB_WAIT160
bdms1_wait160:	
		ldi	r20,8
bdms1_wait160_1:	
		ldi	r21,140
bdms1_wait160_2:	dec	r21
		brne	bdms1_wait160_2
		nop
		dec	r20
		brne	bdms1_wait160_1
		ret

.org (pc & 0xff00) + BDM_SUB_BREAD8
bdms1_bread8:	ldi	XL,0xe0
		rcall	bdms1_send8
		movw	XL,r24
		rcall	bdms1_send16
		call	bdm_wait2_ack
		rcall	bdms1_wait16
		rcall	bdms1_recv8
		call	api_buf_bwrite
		adiw	r24,1
		ret

.org (pc & 0xff00) + BDM_SUB_BWRITE8
bdms1_bwrite8:	ldi	XL,0xc0
		rcall	bdms1_send8
		movw	XL,r24
		rcall	bdms1_send16
		call	api_buf_bread
		rcall	bdms1_send8
		call	bdm_wait2_ack
		rcall	bdms1_wait16
		adiw	r24,1
		ret

.org (pc & 0xff00) + BDM_SUB_BREADF8
bdms1_breadf8:	ldi	XL,0xe0
		rcall	bdms1_send8
		movw	XL,r22
		rcall	bdms1_send16
		call	bdm_wait2_ack
		rcall	bdms1_wait16
		rjmp	bdms1_recv8

.org (pc & 0xff00) + BDM_SUB_BWRITEF8
		push	XL
bdms1_bwritef8:	ldi	XL,0xc0
		rcall	bdms1_send8
		movw	XL,r22
		rcall	bdms1_send16
		pop	XL
		rcall	bdms1_send8
		call	bdm_wait2_ack
		rjmp	bdms1_wait16

.org (pc & 0xff00) + BDM_SUB_BREADF16
bdms1_breadf16:	ldi	XL,0xe0
bdms1_breadf16a:	
		rcall	bdms1_send8
		movw	XL,r22
		rcall	bdms1_send16
		rcall	bdms1_wait160
		rcall	bdms1_recv16
		sbrs	r22,0
		mov	XL,XH
		ret

.org (pc & 0xff00) + BDM_SUB_BWRITEF16
		push	XL
bdms1_bwritef16:	ldi	XL,0xc0
bdms1_bwritef16a:	
		rcall	bdms1_send8
		movw	XL,r22
		rcall	bdms1_send16
		pop	XL
		mov	XH,XL
		rcall	bdms1_send16
		rcall	bdms1_wait160
		ret

.org (pc & 0xff00) + BDM_SUB_WREAD
bdms1_wread:	ldi	XL,0xe8
		rcall	bdms1_send8
		movw	XL,r24
		rcall	bdms1_send16
		rcall	bdms1_wait160
		rcall	bdms1_recv16
		call	api_buf_mwrite
		adiw	r24,2
		ret

.org (pc & 0xff00) + BDM_SUB_WWRITE
bdms1_wwrite:	ldi	XL,0xc8
		rcall	bdms1_send8
		movw	XL,r24
		rcall	bdms1_send16
		call	api_buf_mread
		rcall	bdms1_send16
		rcall	bdms1_wait160
		adiw	r24,2
		ret

.org (pc & 0xff00) + BDM_SUB_WREADF
bdms1_wreadf:	ldi	XL,0xe8
		rcall	bdms1_send8
		movw	XL,r22
		rcall	bdms1_send16
		rcall	bdms1_wait160
		rcall	bdms1_recv16
		ret

.org (pc & 0xff00) + BDM_SUB_WWRITEF
bdms1_wwritef:	movw	r18,XL
		ldi	XL,0xc8
		rcall	bdms1_send8
		movw	XL,r22
		rcall	bdms1_send16
		movw	XL,r18
		rcall	bdms1_send16
		rjmp	bdms1_wait160

.org (pc & 0xff00) + BDM_SUB_RSTAT
bdms1_bstat16:	ldi	XL,0xe4
		ldi	r22,0x01
		ldi	r23,0xff
		rjmp	bdms1_breadf16a

.org (pc & 0xff00) + BDM_SUB_WSTAT
		push	XL
bdms1_wstat16:	ldi	XL,0xc4
		ldi	r22,0x01
		ldi	r23,0xff
		rjmp	bdms1_bwritef16a


