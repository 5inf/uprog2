;---------------------------------------------------------------------
; generated file for frequency = 15 MHz
; Send:
; SIZE-0 = 5 clocks
; SIZE-D = 12 clocks
; SIZE-1 = 6 clocks
; Receive:
; SIZE-0 = 5 clocks
; SIZE-S = 8 clocks
; SIZE-W = 10 clocks
;---------------------------------------------------------------------
.org (pc + 255) & 0xff00
bdms15_send8:		ldi	r20,8
			mov	XH,XL
			rjmp	bdms15_send16_1

.org (pc & 0xff00) + BDM_SUB_SWORD
bdms15_send16:		ldi	r20,16
bdms15_send16_1:	sbi	CTRLDDR,SIG2
			out	CTRLPORT,r0
			ldi	r21,1
bdms15_send16_2:	dec	r21
			brne	bdms15_send16_2
			sbrc	XH,7
			out	CTRLPORT,r1
			ldi	r21,3
bdms15_send16_3:	dec	r21
			brne	bdms15_send16_3
			nop
			nop
			out	CTRLPORT,r1
			cbi	CTRLDDR,SIG2
			nop
			nop
			lsl	XL
			rol	XH
			dec	r20
			brne	bdms15_send16_1
			ret

.org (pc & 0xff00) + BDM_SUB_RBYTE
bdms15_recv8:		ldi	r20,8
			rjmp	bdms15_recv16_1

.org (pc & 0xff00) + BDM_SUB_RWORD
bdms15_recv16:		ldi	r20,16
bdms15_recv16_1:	sbi	CTRLDDR,SIG2
			out	CTRLPORT,r0
			ldi	r21,1
bdms15_recv16_2:	dec	r21
			brne	bdms15_recv16_2
			nop
			cbi	CTRLDDR,SIG2
			out	CTRLPORT,r1
			ldi	r21,1
bdms15_recv16_3:	dec	r21
			brne	bdms15_recv16_3
			lsl	XL
			rol	XH
			sbic	CTRLPIN,SIG2
			inc	XL
			ldi	r21,2
bdms15_recv16_4:	dec	r21
			brne	bdms15_recv16_4
			nop
			dec	r20
			brne	bdms15_recv16_1
			ret

.org (pc & 0xff00) + BDM_SUB_WAIT16
bdms15_wait16:		
			ldi	r21,4
bdms15_wait16_1:	dec	r21
			brne	bdms15_wait16_1
			nop
			nop
			ret

.org (pc & 0xff00) + BDM_SUB_WAIT160
bdms15_wait160:		
			ldi	r21,72
bdms15_wait160_1:	dec	r21
			brne	bdms15_wait160_1
			nop
			nop
			ret

.org (pc & 0xff00) + BDM_SUB_BREAD8
bdms15_bread8:		ldi	XL,0xe0
			rcall	bdms15_send8
			movw	XL,r24
			rcall	bdms15_send16
			call	bdm_wait2_ack
			rcall	bdms15_wait16
			rcall	bdms15_recv8
			call	api_buf_bwrite
			adiw	r24,1
			ret

.org (pc & 0xff00) + BDM_SUB_BWRITE8
bdms15_bwrite8:		ldi	XL,0xc0
			rcall	bdms15_send8
			movw	XL,r24
			rcall	bdms15_send16
			call	api_buf_bread
			rcall	bdms15_send8
			call	bdm_wait2_ack
			rcall	bdms15_wait16
			adiw	r24,1
			ret

.org (pc & 0xff00) + BDM_SUB_BREADF8
bdms15_breadf8:		ldi	XL,0xe0
			rcall	bdms15_send8
			movw	XL,r22
			rcall	bdms15_send16
			call	bdm_wait2_ack
			rcall	bdms15_wait16
			rjmp	bdms15_recv8

.org (pc & 0xff00) + BDM_SUB_BWRITEF8
			push	XL
bdms15_bwritef8:	ldi	XL,0xc0
			rcall	bdms15_send8
			movw	XL,r22
			rcall	bdms15_send16
			pop	XL
			rcall	bdms15_send8
			call	bdm_wait2_ack
			rjmp	bdms15_wait16

.org (pc & 0xff00) + BDM_SUB_BREADF16
bdms15_breadf16:	ldi	XL,0xe0
bdms15_breadf16a:	
			rcall	bdms15_send8
			movw	XL,r22
			rcall	bdms15_send16
			rcall	bdms15_wait160
			rcall	bdms15_recv16
			sbrs	r22,0
			mov	XL,XH
			ret

.org (pc & 0xff00) + BDM_SUB_BWRITEF16
			push	XL
bdms15_bwritef16:	ldi	XL,0xc0
bdms15_bwritef16a:	
			rcall	bdms15_send8
			movw	XL,r22
			rcall	bdms15_send16
			pop	XL
			mov	XH,XL
			rcall	bdms15_send16
			rcall	bdms15_wait160
			ret

.org (pc & 0xff00) + BDM_SUB_WREAD
bdms15_wread:		ldi	XL,0xe8
			rcall	bdms15_send8
			movw	XL,r24
			rcall	bdms15_send16
			rcall	bdms15_wait160
			rcall	bdms15_recv16
			call	api_buf_mwrite
			adiw	r24,2
			ret

.org (pc & 0xff00) + BDM_SUB_WWRITE
bdms15_wwrite:		ldi	XL,0xc8
			rcall	bdms15_send8
			movw	XL,r24
			rcall	bdms15_send16
			call	api_buf_mread
			rcall	bdms15_send16
			rcall	bdms15_wait160
			adiw	r24,2
			ret

.org (pc & 0xff00) + BDM_SUB_WREADF
bdms15_wreadf:		ldi	XL,0xe8
			rcall	bdms15_send8
			movw	XL,r22
			rcall	bdms15_send16
			rcall	bdms15_wait160
			rcall	bdms15_recv16
			ret

.org (pc & 0xff00) + BDM_SUB_WWRITEF
bdms15_wwritef:		movw	r18,XL
			ldi	XL,0xc8
			rcall	bdms15_send8
			movw	XL,r22
			rcall	bdms15_send16
			movw	XL,r18
			rcall	bdms15_send16
			rjmp	bdms15_wait160

.org (pc & 0xff00) + BDM_SUB_RSTAT
bdms15_bstat16:		ldi	XL,0xe4
			ldi	r22,0x01
			ldi	r23,0xff
			rjmp	bdms15_breadf16a

.org (pc & 0xff00) + BDM_SUB_WSTAT
			push	XL
bdms15_wstat16:		ldi	XL,0xc4
			ldi	r22,0x01
			ldi	r23,0xff
			rjmp	bdms15_bwritef16a


