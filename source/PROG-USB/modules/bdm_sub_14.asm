;---------------------------------------------------------------------
; generated file for frequency = 14 MHz
; Send:
; SIZE-0 = 6 clocks
; SIZE-D = 13 clocks
; SIZE-1 = 6 clocks
; Receive:
; SIZE-0 = 6 clocks
; SIZE-S = 9 clocks
; SIZE-W = 10 clocks
;---------------------------------------------------------------------
.org (pc + 255) & 0xff00
bdms14_send8:	ldi	r20,8
		mov	XH,XL
		rjmp	bdms14_send16_1

.org (pc & 0xff00) + BDM_SUB_SWORD
bdms14_send16:	ldi	r20,16
bdms14_send16_1:	sbi	CTRLDDR,SIG2
		out	CTRLPORT,r0
		ldi	r21,1
bdms14_send16_2:	dec	r21
		brne	bdms14_send16_2
		nop
		sbrc	XH,7
		out	CTRLPORT,r1
		ldi	r21,4
bdms14_send16_3:	dec	r21
		brne	bdms14_send16_3
		out	CTRLPORT,r1
		cbi	CTRLDDR,SIG2
		nop
		nop
		lsl	XL
		rol	XH
		dec	r20
		brne	bdms14_send16_1
		ret

.org (pc & 0xff00) + BDM_SUB_RBYTE
bdms14_recv8:	ldi	r20,8
		rjmp	bdms14_recv16_1

.org (pc & 0xff00) + BDM_SUB_RWORD
bdms14_recv16:	ldi	r20,16
bdms14_recv16_1:	sbi	CTRLDDR,SIG2
		out	CTRLPORT,r0
		ldi	r21,1
bdms14_recv16_2:	dec	r21
		brne	bdms14_recv16_2
		nop
		nop
		cbi	CTRLDDR,SIG2
		out	CTRLPORT,r1
		ldi	r21,1
bdms14_recv16_3:	dec	r21
		brne	bdms14_recv16_3
		nop
		lsl	XL
		rol	XH
		sbic	CTRLPIN,SIG2
		inc	XL
		ldi	r21,2
bdms14_recv16_4:	dec	r21
		brne	bdms14_recv16_4
		nop
		dec	r20
		brne	bdms14_recv16_1
		ret

.org (pc & 0xff00) + BDM_SUB_WAIT16
bdms14_wait16:	
		ldi	r21,5
bdms14_wait16_1:	dec	r21
		brne	bdms14_wait16_1
		ret

.org (pc & 0xff00) + BDM_SUB_WAIT160
bdms14_wait160:	
		ldi	r21,78
bdms14_wait160_1:	dec	r21
		brne	bdms14_wait160_1
		ret

.org (pc & 0xff00) + BDM_SUB_BREAD8
bdms14_bread8:	ldi	XL,0xe0
		rcall	bdms14_send8
		movw	XL,r24
		rcall	bdms14_send16
		call	bdm_wait2_ack
		rcall	bdms14_wait16
		rcall	bdms14_recv8
		call	api_buf_bwrite
		adiw	r24,1
		ret

.org (pc & 0xff00) + BDM_SUB_BWRITE8
bdms14_bwrite8:	ldi	XL,0xc0
		rcall	bdms14_send8
		movw	XL,r24
		rcall	bdms14_send16
		call	api_buf_bread
		rcall	bdms14_send8
		call	bdm_wait2_ack
		rcall	bdms14_wait16
		adiw	r24,1
		ret

.org (pc & 0xff00) + BDM_SUB_BREADF8
bdms14_breadf8:	ldi	XL,0xe0
		rcall	bdms14_send8
		movw	XL,r22
		rcall	bdms14_send16
		call	bdm_wait2_ack
		rcall	bdms14_wait16
		rjmp	bdms14_recv8

.org (pc & 0xff00) + BDM_SUB_BWRITEF8
		push	XL
bdms14_bwritef8:	ldi	XL,0xc0
		rcall	bdms14_send8
		movw	XL,r22
		rcall	bdms14_send16
		pop	XL
		rcall	bdms14_send8
		call	bdm_wait2_ack
		rjmp	bdms14_wait16

.org (pc & 0xff00) + BDM_SUB_BREADF16
bdms14_breadf16:	ldi	XL,0xe0
bdms14_breadf16a:	
		rcall	bdms14_send8
		movw	XL,r22
		rcall	bdms14_send16
		rcall	bdms14_wait160
		rcall	bdms14_recv16
		sbrs	r22,0
		mov	XL,XH
		ret

.org (pc & 0xff00) + BDM_SUB_BWRITEF16
		push	XL
bdms14_bwritef16:	ldi	XL,0xc0
bdms14_bwritef16a:	
		rcall	bdms14_send8
		movw	XL,r22
		rcall	bdms14_send16
		pop	XL
		mov	XH,XL
		rcall	bdms14_send16
		rcall	bdms14_wait160
		ret

.org (pc & 0xff00) + BDM_SUB_WREAD
bdms14_wread:	ldi	XL,0xe8
		rcall	bdms14_send8
		movw	XL,r24
		rcall	bdms14_send16
		rcall	bdms14_wait160
		rcall	bdms14_recv16
		call	api_buf_mwrite
		adiw	r24,2
		ret

.org (pc & 0xff00) + BDM_SUB_WWRITE
bdms14_wwrite:	ldi	XL,0xc8
		rcall	bdms14_send8
		movw	XL,r24
		rcall	bdms14_send16
		call	api_buf_mread
		rcall	bdms14_send16
		rcall	bdms14_wait160
		adiw	r24,2
		ret

.org (pc & 0xff00) + BDM_SUB_WREADF
bdms14_wreadf:	ldi	XL,0xe8
		rcall	bdms14_send8
		movw	XL,r22
		rcall	bdms14_send16
		rcall	bdms14_wait160
		rcall	bdms14_recv16
		ret

.org (pc & 0xff00) + BDM_SUB_WWRITEF
bdms14_wwritef:	movw	r18,XL
		ldi	XL,0xc8
		rcall	bdms14_send8
		movw	XL,r22
		rcall	bdms14_send16
		movw	XL,r18
		rcall	bdms14_send16
		rjmp	bdms14_wait160

.org (pc & 0xff00) + BDM_SUB_RSTAT
bdms14_bstat16:	ldi	XL,0xe4
		ldi	r22,0x01
		ldi	r23,0xff
		rjmp	bdms14_breadf16a

.org (pc & 0xff00) + BDM_SUB_WSTAT
		push	XL
bdms14_wstat16:	ldi	XL,0xc4
		ldi	r22,0x01
		ldi	r23,0xff
		rjmp	bdms14_bwritef16a


