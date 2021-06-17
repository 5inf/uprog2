;---------------------------------------------------------------------
; generated file for frequency = 16 MHz
; Send:
; SIZE-0 = 5 clocks
; SIZE-D = 11 clocks
; SIZE-1 = 5 clocks
; Receive:
; SIZE-0 = 5 clocks
; SIZE-S = 8 clocks
; SIZE-W = 9 clocks
;---------------------------------------------------------------------
.org (pc + 255) & 0xff00
bdms16_send8:		ldi	r20,8
			mov	XH,XL
			rjmp	bdms16_send16_1

.org (pc & 0xff00) + BDM_SUB_SWORD
bdms16_send16:		ldi	r20,16
bdms16_send16_1:	sbi	CTRLDDR,SIG2
			out	CTRLPORT,r0
			ldi	r21,1
bdms16_send16_2:	dec	r21
			brne	bdms16_send16_2
			sbrc	XH,7
			out	CTRLPORT,r1
			ldi	r21,3
bdms16_send16_3:	dec	r21
			brne	bdms16_send16_3
			nop
			out	CTRLPORT,r1
			cbi	CTRLDDR,SIG2
			nop
			lsl	XL
			rol	XH
			dec	r20
			brne	bdms16_send16_1
			ret

.org (pc & 0xff00) + BDM_SUB_RBYTE
bdms16_recv8:		ldi	r20,8
			rjmp	bdms16_recv16_1

.org (pc & 0xff00) + BDM_SUB_RWORD
bdms16_recv16:		ldi	r20,16
bdms16_recv16_1:	sbi	CTRLDDR,SIG2
			out	CTRLPORT,r0
			ldi	r21,1
bdms16_recv16_2:	dec	r21
			brne	bdms16_recv16_2
			nop
			cbi	CTRLDDR,SIG2
			out	CTRLPORT,r1
			ldi	r21,1
bdms16_recv16_3:	dec	r21
			brne	bdms16_recv16_3
			lsl	XL
			rol	XH
			sbic	CTRLPIN,SIG2
			inc	XL
			ldi	r21,2
bdms16_recv16_4:	dec	r21
			brne	bdms16_recv16_4
			dec	r20
			brne	bdms16_recv16_1
			ret

.org (pc & 0xff00) + BDM_SUB_WAIT16
bdms16_wait16:		
			ldi	r21,4
bdms16_wait16_1:	dec	r21
			brne	bdms16_wait16_1
			ret

.org (pc & 0xff00) + BDM_SUB_WAIT160
bdms16_wait160:		
			ldi	r21,68
bdms16_wait160_1:	dec	r21
			brne	bdms16_wait160_1
			ret

.org (pc & 0xff00) + BDM_SUB_BREAD8
bdms16_bread8:		ldi	XL,0xe0
			rcall	bdms16_send8
			movw	XL,r24
			rcall	bdms16_send16
			call	bdm_wait2_ack
			rcall	bdms16_wait16
			rcall	bdms16_recv8
			call	api_buf_bwrite
			adiw	r24,1
			ret

.org (pc & 0xff00) + BDM_SUB_BWRITE8
bdms16_bwrite8:		ldi	XL,0xc0
			rcall	bdms16_send8
			movw	XL,r24
			rcall	bdms16_send16
			call	api_buf_bread
			rcall	bdms16_send8
			call	bdm_wait2_ack
			rcall	bdms16_wait16
			adiw	r24,1
			ret

.org (pc & 0xff00) + BDM_SUB_BREADF8
bdms16_breadf8:		ldi	XL,0xe0
			rcall	bdms16_send8
			movw	XL,r22
			rcall	bdms16_send16
			call	bdm_wait2_ack
			rcall	bdms16_wait16
			rjmp	bdms16_recv8

.org (pc & 0xff00) + BDM_SUB_BWRITEF8
			push	XL
bdms16_bwritef8:	ldi	XL,0xc0
			rcall	bdms16_send8
			movw	XL,r22
			rcall	bdms16_send16
			pop	XL
			rcall	bdms16_send8
			call	bdm_wait2_ack
			rjmp	bdms16_wait16

.org (pc & 0xff00) + BDM_SUB_BREADF16
bdms16_breadf16:	ldi	XL,0xe0
bdms16_breadf16a:	
			rcall	bdms16_send8
			movw	XL,r22
			rcall	bdms16_send16
			rcall	bdms16_wait160
			rcall	bdms16_recv16
			sbrs	r22,0
			mov	XL,XH
			ret

.org (pc & 0xff00) + BDM_SUB_BWRITEF16
			push	XL
bdms16_bwritef16:	ldi	XL,0xc0
bdms16_bwritef16a:	
			rcall	bdms16_send8
			movw	XL,r22
			rcall	bdms16_send16
			pop	XL
			mov	XH,XL
			rcall	bdms16_send16
			rcall	bdms16_wait160
			ret

.org (pc & 0xff00) + BDM_SUB_WREAD
bdms16_wread:		ldi	XL,0xe8
			rcall	bdms16_send8
			movw	XL,r24
			rcall	bdms16_send16
			rcall	bdms16_wait160
			rcall	bdms16_recv16
			call	api_buf_mwrite
			adiw	r24,2
			ret

.org (pc & 0xff00) + BDM_SUB_WWRITE
bdms16_wwrite:		ldi	XL,0xc8
			rcall	bdms16_send8
			movw	XL,r24
			rcall	bdms16_send16
			call	api_buf_mread
			rcall	bdms16_send16
			rcall	bdms16_wait160
			adiw	r24,2
			ret

.org (pc & 0xff00) + BDM_SUB_WREADF
bdms16_wreadf:		ldi	XL,0xe8
			rcall	bdms16_send8
			movw	XL,r22
			rcall	bdms16_send16
			rcall	bdms16_wait160
			rcall	bdms16_recv16
			ret

.org (pc & 0xff00) + BDM_SUB_WWRITEF
bdms16_wwritef:		movw	r18,XL
			ldi	XL,0xc8
			rcall	bdms16_send8
			movw	XL,r22
			rcall	bdms16_send16
			movw	XL,r18
			rcall	bdms16_send16
			rjmp	bdms16_wait160

.org (pc & 0xff00) + BDM_SUB_RSTAT
bdms16_bstat16:		ldi	XL,0xe4
			ldi	r22,0x01
			ldi	r23,0xff
			rjmp	bdms16_breadf16a

.org (pc & 0xff00) + BDM_SUB_WSTAT
			push	XL
bdms16_wstat16:		ldi	XL,0xc4
			ldi	r22,0x01
			ldi	r23,0xff
			rjmp	bdms16_bwritef16a


