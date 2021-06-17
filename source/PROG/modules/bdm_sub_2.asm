;---------------------------------------------------------------------
; generated file for frequency = 2 MHz
; Send:
; SIZE-0 = 40 clocks
; SIZE-D = 90 clocks
; SIZE-1 = 40 clocks
; Receive:
; SIZE-0 = 40 clocks
; SIZE-S = 60 clocks
; SIZE-W = 70 clocks
;---------------------------------------------------------------------
.org (pc + 255) & 0xff00
bdms2_send8:		ldi	r20,8
			mov	XH,XL
			rjmp	bdms2_send16_1

.org (pc & 0xff00) + BDM_SUB_SWORD
bdms2_send16:		ldi	r20,16
bdms2_send16_1:		sbi	CTRLDDR,SIG2
			out	CTRLPORT,r0
			ldi	r21,12
bdms2_send16_2:		dec	r21
			brne	bdms2_send16_2
			nop
			nop
			sbrc	XH,7
			out	CTRLPORT,r1
			ldi	r21,29
bdms2_send16_3:		dec	r21
			brne	bdms2_send16_3
			nop
			nop
			out	CTRLPORT,r1
			cbi	CTRLDDR,SIG2
			ldi	r21,11
bdms2_send16_4:		dec	r21
			brne	bdms2_send16_4
			lsl	XL
			rol	XH
			dec	r20
			brne	bdms2_send16_1
			ret

.org (pc & 0xff00) + BDM_SUB_RBYTE
bdms2_recv8:		ldi	r20,8
			rjmp	bdms2_recv16_1

.org (pc & 0xff00) + BDM_SUB_RWORD
bdms2_recv16:		ldi	r20,16
bdms2_recv16_1:		sbi	CTRLDDR,SIG2
			out	CTRLPORT,r0
			ldi	r21,13
bdms2_recv16_2:		dec	r21
			brne	bdms2_recv16_2
			cbi	CTRLDDR,SIG2
			out	CTRLPORT,r1
			ldi	r21,18
bdms2_recv16_3:		dec	r21
			brne	bdms2_recv16_3
			nop
			lsl	XL
			rol	XH
			sbic	CTRLPIN,SIG2
			inc	XL
			ldi	r21,22
bdms2_recv16_4:		dec	r21
			brne	bdms2_recv16_4
			nop
			dec	r20
			brne	bdms2_recv16_1
			ret

.org (pc & 0xff00) + BDM_SUB_WAIT16
bdms2_wait16:		
			ldi	r21,53
bdms2_wait16_1:		dec	r21
			brne	bdms2_wait16_1
			nop
			nop
			ret

.org (pc & 0xff00) + BDM_SUB_WAIT160
bdms2_wait160:		
			ldi	r20,8
bdms2_wait160_1:	
			ldi	r21,69
bdms2_wait160_2:	dec	r21
			brne	bdms2_wait160_2
			nop
			dec	r20
			brne	bdms2_wait160_1
			ret

.org (pc & 0xff00) + BDM_SUB_BREAD8
bdms2_bread8:		ldi	XL,0xe0
			rcall	bdms2_send8
			movw	XL,r24
			rcall	bdms2_send16
			call	bdm_wait2_ack
			rcall	bdms2_wait16
			rcall	bdms2_recv8
			call	api_buf_bwrite
			adiw	r24,1
			ret

.org (pc & 0xff00) + BDM_SUB_BWRITE8
bdms2_bwrite8:		ldi	XL,0xc0
			rcall	bdms2_send8
			movw	XL,r24
			rcall	bdms2_send16
			call	api_buf_bread
			rcall	bdms2_send8
			call	bdm_wait2_ack
			rcall	bdms2_wait16
			adiw	r24,1
			ret

.org (pc & 0xff00) + BDM_SUB_BREADF8
bdms2_breadf8:		ldi	XL,0xe0
			rcall	bdms2_send8
			movw	XL,r22
			rcall	bdms2_send16
			call	bdm_wait2_ack
			rcall	bdms2_wait16
			rjmp	bdms2_recv8

.org (pc & 0xff00) + BDM_SUB_BWRITEF8
			push	XL
bdms2_bwritef8:		ldi	XL,0xc0
			rcall	bdms2_send8
			movw	XL,r22
			rcall	bdms2_send16
			pop	XL
			rcall	bdms2_send8
			call	bdm_wait2_ack
			rjmp	bdms2_wait16

.org (pc & 0xff00) + BDM_SUB_BREADF16
bdms2_breadf16:		ldi	XL,0xe0
bdms2_breadf16a:	
			rcall	bdms2_send8
			movw	XL,r22
			rcall	bdms2_send16
			rcall	bdms2_wait160
			rcall	bdms2_recv16
			sbrs	r22,0
			mov	XL,XH
			ret

.org (pc & 0xff00) + BDM_SUB_BWRITEF16
			push	XL
bdms2_bwritef16:	ldi	XL,0xc0
bdms2_bwritef16a:	
			rcall	bdms2_send8
			movw	XL,r22
			rcall	bdms2_send16
			pop	XL
			mov	XH,XL
			rcall	bdms2_send16
			rcall	bdms2_wait160
			ret

.org (pc & 0xff00) + BDM_SUB_WREAD
bdms2_wread:		ldi	XL,0xe8
			rcall	bdms2_send8
			movw	XL,r24
			rcall	bdms2_send16
			rcall	bdms2_wait160
			rcall	bdms2_recv16
			call	api_buf_mwrite
			adiw	r24,2
			ret

.org (pc & 0xff00) + BDM_SUB_WWRITE
bdms2_wwrite:		ldi	XL,0xc8
			rcall	bdms2_send8
			movw	XL,r24
			rcall	bdms2_send16
			call	api_buf_mread
			rcall	bdms2_send16
			rcall	bdms2_wait160
			adiw	r24,2
			ret

.org (pc & 0xff00) + BDM_SUB_WREADF
bdms2_wreadf:		ldi	XL,0xe8
			rcall	bdms2_send8
			movw	XL,r22
			rcall	bdms2_send16
			rcall	bdms2_wait160
			rcall	bdms2_recv16
			ret

.org (pc & 0xff00) + BDM_SUB_WWRITEF
bdms2_wwritef:		movw	r18,XL
			ldi	XL,0xc8
			rcall	bdms2_send8
			movw	XL,r22
			rcall	bdms2_send16
			movw	XL,r18
			rcall	bdms2_send16
			rjmp	bdms2_wait160

.org (pc & 0xff00) + BDM_SUB_RSTAT
bdms2_bstat16:		ldi	XL,0xe4
			ldi	r22,0x01
			ldi	r23,0xff
			rjmp	bdms2_breadf16a

.org (pc & 0xff00) + BDM_SUB_WSTAT
			push	XL
bdms2_wstat16:		ldi	XL,0xc4
			ldi	r22,0x01
			ldi	r23,0xff
			rjmp	bdms2_bwritef16a


