;---------------------------------------------------------------------
; generated file for frequency = 21 MHz
; Send:
; SIZE-0 = 4 clocks
; SIZE-D = 9 clocks
; SIZE-1 = 4 clocks
; Receive:
; SIZE-0 = 4 clocks
; SIZE-S = 6 clocks
; SIZE-W = 7 clocks
;---------------------------------------------------------------------
.org (pc + 255) & 0xff00
bdms21_send8:		ldi	r20,8
			mov	XH,XL
			rjmp	bdms21_send16_1

.org (pc & 0xff00) + BDM_SUB_SWORD
bdms21_send16:		ldi	r20,16
bdms21_send16_1:	sbi	CTRLDDR,SIG2
			out	CTRLPORT,r0
			nop
			nop
			sbrc	XH,7
			out	CTRLPORT,r1
			ldi	r21,2
bdms21_send16_3:	dec	r21
			brne	bdms21_send16_3
			nop
			nop
			out	CTRLPORT,r1
			cbi	CTRLDDR,SIG2
			lsl	XL
			rol	XH
			dec	r20
			brne	bdms21_send16_1
			ret

.org (pc & 0xff00) + BDM_SUB_RBYTE
bdms21_recv8:		ldi	r20,8
			rjmp	bdms21_recv16_1

.org (pc & 0xff00) + BDM_SUB_RWORD
bdms21_recv16:		ldi	r20,16
bdms21_recv16_1:	sbi	CTRLDDR,SIG2
			out	CTRLPORT,r0
			ldi	r21,1
bdms21_recv16_2:	dec	r21
			brne	bdms21_recv16_2
			cbi	CTRLDDR,SIG2
			out	CTRLPORT,r1
			nop
			lsl	XL
			rol	XH
			sbic	CTRLPIN,SIG2
			inc	XL
			ldi	r21,1
bdms21_recv16_4:	dec	r21
			brne	bdms21_recv16_4
			nop
			dec	r20
			brne	bdms21_recv16_1
			ret

.org (pc & 0xff00) + BDM_SUB_WAIT16
bdms21_wait16:		
			ldi	r21,2
bdms21_wait16_1:	dec	r21
			brne	bdms21_wait16_1
			nop
			ret

.org (pc & 0xff00) + BDM_SUB_WAIT160
bdms21_wait160:		
			ldi	r21,51
bdms21_wait160_1:	dec	r21
			brne	bdms21_wait160_1
			ret

.org (pc & 0xff00) + BDM_SUB_BREAD8
bdms21_bread8:		ldi	XL,0xe0
			rcall	bdms21_send8
			movw	XL,r24
			rcall	bdms21_send16
			call	bdm_wait2_ack
			rcall	bdms21_wait16
			rcall	bdms21_recv8
			call	api_buf_bwrite
			adiw	r24,1
			ret

.org (pc & 0xff00) + BDM_SUB_BWRITE8
bdms21_bwrite8:		ldi	XL,0xc0
			rcall	bdms21_send8
			movw	XL,r24
			rcall	bdms21_send16
			call	api_buf_bread
			rcall	bdms21_send8
			call	bdm_wait2_ack
			rcall	bdms21_wait16
			adiw	r24,1
			ret

.org (pc & 0xff00) + BDM_SUB_BREADF8
bdms21_breadf8:		ldi	XL,0xe0
			rcall	bdms21_send8
			movw	XL,r22
			rcall	bdms21_send16
			call	bdm_wait2_ack
			rcall	bdms21_wait16
			rjmp	bdms21_recv8

.org (pc & 0xff00) + BDM_SUB_BWRITEF8
			push	XL
bdms21_bwritef8:	ldi	XL,0xc0
			rcall	bdms21_send8
			movw	XL,r22
			rcall	bdms21_send16
			pop	XL
			rcall	bdms21_send8
			call	bdm_wait2_ack
			rjmp	bdms21_wait16

.org (pc & 0xff00) + BDM_SUB_BREADF16
bdms21_breadf16:	ldi	XL,0xe0
bdms21_breadf16a:	
			rcall	bdms21_send8
			movw	XL,r22
			rcall	bdms21_send16
			rcall	bdms21_wait160
			rcall	bdms21_recv16
			sbrs	r22,0
			mov	XL,XH
			ret

.org (pc & 0xff00) + BDM_SUB_BWRITEF16
			push	XL
bdms21_bwritef16:	ldi	XL,0xc0
bdms21_bwritef16a:	
			rcall	bdms21_send8
			movw	XL,r22
			rcall	bdms21_send16
			pop	XL
			mov	XH,XL
			rcall	bdms21_send16
			rcall	bdms21_wait160
			ret

.org (pc & 0xff00) + BDM_SUB_WREAD
bdms21_wread:		ldi	XL,0xe8
			rcall	bdms21_send8
			movw	XL,r24
			rcall	bdms21_send16
			rcall	bdms21_wait160
			rcall	bdms21_recv16
			call	api_buf_mwrite
			adiw	r24,2
			ret

.org (pc & 0xff00) + BDM_SUB_WWRITE
bdms21_wwrite:		ldi	XL,0xc8
			rcall	bdms21_send8
			movw	XL,r24
			rcall	bdms21_send16
			call	api_buf_mread
			rcall	bdms21_send16
			rcall	bdms21_wait160
			adiw	r24,2
			ret

.org (pc & 0xff00) + BDM_SUB_WREADF
bdms21_wreadf:		ldi	XL,0xe8
			rcall	bdms21_send8
			movw	XL,r22
			rcall	bdms21_send16
			rcall	bdms21_wait160
			rcall	bdms21_recv16
			ret

.org (pc & 0xff00) + BDM_SUB_WWRITEF
bdms21_wwritef:		movw	r18,XL
			ldi	XL,0xc8
			rcall	bdms21_send8
			movw	XL,r22
			rcall	bdms21_send16
			movw	XL,r18
			rcall	bdms21_send16
			rjmp	bdms21_wait160

.org (pc & 0xff00) + BDM_SUB_RSTAT
bdms21_bstat16:		ldi	XL,0xe4
			ldi	r22,0x01
			ldi	r23,0xff
			rjmp	bdms21_breadf16a

.org (pc & 0xff00) + BDM_SUB_WSTAT
			push	XL
bdms21_wstat16:		ldi	XL,0xc4
			ldi	r22,0x01
			ldi	r23,0xff
			rjmp	bdms21_bwritef16a


