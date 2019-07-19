;---------------------------------------------------------------------
; generated file for frequency = 9 MHz
; Send:
; SIZE-0 = 9 clocks
; SIZE-D = 20 clocks
; SIZE-1 = 9 clocks
; Receive:
; SIZE-0 = 9 clocks
; SIZE-S = 13 clocks
; SIZE-W = 16 clocks
;---------------------------------------------------------------------
.org (pc + 255) & 0xff00
bdms9_send8:	ldi	r20,8
		mov	XH,XL
		rjmp	bdms9_send16_1

.org (pc & 0xff00) + BDM_SUB_SWORD
bdms9_send16:	ldi	r20,16
bdms9_send16_1:	sbi	CTRLDDR,SIG2
		out	CTRLPORT,r0
		ldi	r21,2
bdms9_send16_2:	dec	r21
		brne	bdms9_send16_2
		nop
		sbrc	XH,7
		out	CTRLPORT,r1
		ldi	r21,6
bdms9_send16_3:	dec	r21
		brne	bdms9_send16_3
		nop
		out	CTRLPORT,r1
		cbi	CTRLDDR,SIG2
		nop
		nop
		lsl	XL
		rol	XH
		dec	r20
		brne	bdms9_send16_1
		ret

.org (pc & 0xff00) + BDM_SUB_RBYTE
bdms9_recv8:	ldi	r20,8
		rjmp	bdms9_recv16_1

.org (pc & 0xff00) + BDM_SUB_RWORD
bdms9_recv16:	ldi	r20,16
bdms9_recv16_1:	sbi	CTRLDDR,SIG2
		out	CTRLPORT,r0
		ldi	r21,2
bdms9_recv16_2:	dec	r21
		brne	bdms9_recv16_2
		nop
		nop
		cbi	CTRLDDR,SIG2
		out	CTRLPORT,r1
		ldi	r21,2
bdms9_recv16_3:	dec	r21
		brne	bdms9_recv16_3
		nop
		nop
		lsl	XL
		rol	XH
		sbic	CTRLPIN,SIG2
		inc	XL
		ldi	r21,4
bdms9_recv16_4:	dec	r21
		brne	bdms9_recv16_4
		nop
		dec	r20
		brne	bdms9_recv16_1
		ret

.org (pc & 0xff00) + BDM_SUB_WAIT16
bdms9_wait16:	
		ldi	r21,9
bdms9_wait16_1:	dec	r21
		brne	bdms9_wait16_1
		nop
		nop
		ret

.org (pc & 0xff00) + BDM_SUB_WAIT160
bdms9_wait160:	
		ldi	r21,123
bdms9_wait160_1:	dec	r21
		brne	bdms9_wait160_1
		ret

.org (pc & 0xff00) + BDM_SUB_BREAD8
bdms9_bread8:	ldi	XL,0xe0
		rcall	bdms9_send8
		movw	XL,r24
		rcall	bdms9_send16
		call	bdm_wait2_ack
		rcall	bdms9_wait16
		rcall	bdms9_recv8
		call	api_buf_bwrite
		adiw	r24,1
		ret

.org (pc & 0xff00) + BDM_SUB_BWRITE8
bdms9_bwrite8:	ldi	XL,0xc0
		rcall	bdms9_send8
		movw	XL,r24
		rcall	bdms9_send16
		call	api_buf_bread
		rcall	bdms9_send8
		call	bdm_wait2_ack
		rcall	bdms9_wait16
		adiw	r24,1
		ret

.org (pc & 0xff00) + BDM_SUB_BREADF8
bdms9_breadf8:	ldi	XL,0xe0
		rcall	bdms9_send8
		movw	XL,r22
		rcall	bdms9_send16
		call	bdm_wait2_ack
		rcall	bdms9_wait16
		rjmp	bdms9_recv8

.org (pc & 0xff00) + BDM_SUB_BWRITEF8
		push	XL
bdms9_bwritef8:	ldi	XL,0xc0
		rcall	bdms9_send8
		movw	XL,r22
		rcall	bdms9_send16
		pop	XL
		rcall	bdms9_send8
		call	bdm_wait2_ack
		rjmp	bdms9_wait16

.org (pc & 0xff00) + BDM_SUB_BREADF16
bdms9_breadf16:	ldi	XL,0xe0
bdms9_breadf16a:	
		rcall	bdms9_send8
		movw	XL,r22
		rcall	bdms9_send16
		rcall	bdms9_wait160
		rcall	bdms9_recv16
		sbrs	r22,0
		mov	XL,XH
		ret

.org (pc & 0xff00) + BDM_SUB_BWRITEF16
		push	XL
bdms9_bwritef16:	ldi	XL,0xc0
bdms9_bwritef16a:	
		rcall	bdms9_send8
		movw	XL,r22
		rcall	bdms9_send16
		pop	XL
		mov	XH,XL
		rcall	bdms9_send16
		rcall	bdms9_wait160
		ret

.org (pc & 0xff00) + BDM_SUB_WREAD
bdms9_wread:	ldi	XL,0xe8
		rcall	bdms9_send8
		movw	XL,r24
		rcall	bdms9_send16
		rcall	bdms9_wait160
		rcall	bdms9_recv16
		call	api_buf_mwrite
		adiw	r24,2
		ret

.org (pc & 0xff00) + BDM_SUB_WWRITE
bdms9_wwrite:	ldi	XL,0xc8
		rcall	bdms9_send8
		movw	XL,r24
		rcall	bdms9_send16
		call	api_buf_mread
		rcall	bdms9_send16
		rcall	bdms9_wait160
		adiw	r24,2
		ret

.org (pc & 0xff00) + BDM_SUB_WREADF
bdms9_wreadf:	ldi	XL,0xe8
		rcall	bdms9_send8
		movw	XL,r22
		rcall	bdms9_send16
		rcall	bdms9_wait160
		rcall	bdms9_recv16
		ret

.org (pc & 0xff00) + BDM_SUB_WWRITEF
bdms9_wwritef:	movw	r18,XL
		ldi	XL,0xc8
		rcall	bdms9_send8
		movw	XL,r22
		rcall	bdms9_send16
		movw	XL,r18
		rcall	bdms9_send16
		rjmp	bdms9_wait160

.org (pc & 0xff00) + BDM_SUB_RSTAT
bdms9_bstat16:	ldi	XL,0xe4
		ldi	r22,0x01
		ldi	r23,0xff
		rjmp	bdms9_breadf16a

.org (pc & 0xff00) + BDM_SUB_WSTAT
		push	XL
bdms9_wstat16:	ldi	XL,0xc4
		ldi	r22,0x01
		ldi	r23,0xff
		rjmp	bdms9_bwritef16a


