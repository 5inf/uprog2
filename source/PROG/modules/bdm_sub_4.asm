;---------------------------------------------------------------------
; generated file for frequency = 4 MHz
; Send:
; SIZE-0 = 20 clocks
; SIZE-D = 45 clocks
; SIZE-1 = 20 clocks
; Receive:
; SIZE-0 = 20 clocks
; SIZE-S = 30 clocks
; SIZE-W = 35 clocks
;---------------------------------------------------------------------
.org (pc + 255) & 0xff00
bdms4_send8:		ldi	r20,8
			mov	XH,XL
			rjmp	bdms4_send16_1

.org (pc & 0xff00) + BDM_SUB_SWORD
bdms4_send16:		ldi	r20,16
bdms4_send16_1:		sbi	CTRLDDR,SIG2
			out	CTRLPORT,r0
			ldi	r21,6
bdms4_send16_2:		dec	r21
			brne	bdms4_send16_2
			sbrc	XH,7
			out	CTRLPORT,r1
			ldi	r21,14
bdms4_send16_3:		dec	r21
			brne	bdms4_send16_3
			nop
			nop
			out	CTRLPORT,r1
			cbi	CTRLDDR,SIG2
			ldi	r21,4
bdms4_send16_4:		dec	r21
			brne	bdms4_send16_4
			nop
			lsl	XL
			rol	XH
			dec	r20
			brne	bdms4_send16_1
			ret

.org (pc & 0xff00) + BDM_SUB_RBYTE
bdms4_recv8:		ldi	r20,8
			rjmp	bdms4_recv16_1

.org (pc & 0xff00) + BDM_SUB_RWORD
bdms4_recv16:		ldi	r20,16
bdms4_recv16_1:		sbi	CTRLDDR,SIG2
			out	CTRLPORT,r0
			ldi	r21,6
bdms4_recv16_2:		dec	r21
			brne	bdms4_recv16_2
			nop
			cbi	CTRLDDR,SIG2
			out	CTRLPORT,r1
			ldi	r21,8
bdms4_recv16_3:		dec	r21
			brne	bdms4_recv16_3
			nop
			lsl	XL
			rol	XH
			sbic	CTRLPIN,SIG2
			inc	XL
			ldi	r21,10
bdms4_recv16_4:		dec	r21
			brne	bdms4_recv16_4
			nop
			nop
			dec	r20
			brne	bdms4_recv16_1
			ret

.org (pc & 0xff00) + BDM_SUB_WAIT16
bdms4_wait16:		
			ldi	r21,25
bdms4_wait16_1:		dec	r21
			brne	bdms4_wait16_1
			nop
			ret

.org (pc & 0xff00) + BDM_SUB_WAIT160
bdms4_wait160:		
			ldi	r20,8
bdms4_wait160_1:	
			ldi	r21,34
bdms4_wait160_2:	dec	r21
			brne	bdms4_wait160_2
			dec	r20
			brne	bdms4_wait160_1
			ret

.org (pc & 0xff00) + BDM_SUB_BREAD8
bdms4_bread8:		ldi	XL,0xe0
			rcall	bdms4_send8
			movw	XL,r24
			rcall	bdms4_send16
			call	bdm_wait2_ack
			rcall	bdms4_wait16
			rcall	bdms4_recv8
			call	api_buf_bwrite
			adiw	r24,1
			ret

.org (pc & 0xff00) + BDM_SUB_BWRITE8
bdms4_bwrite8:		ldi	XL,0xc0
			rcall	bdms4_send8
			movw	XL,r24
			rcall	bdms4_send16
			call	api_buf_bread
			rcall	bdms4_send8
			call	bdm_wait2_ack
			rcall	bdms4_wait16
			adiw	r24,1
			ret

.org (pc & 0xff00) + BDM_SUB_BREADF8
bdms4_breadf8:		ldi	XL,0xe0
			rcall	bdms4_send8
			movw	XL,r22
			rcall	bdms4_send16
			call	bdm_wait2_ack
			rcall	bdms4_wait16
			rjmp	bdms4_recv8

.org (pc & 0xff00) + BDM_SUB_BWRITEF8
			push	XL
bdms4_bwritef8:		ldi	XL,0xc0
			rcall	bdms4_send8
			movw	XL,r22
			rcall	bdms4_send16
			pop	XL
			rcall	bdms4_send8
			call	bdm_wait2_ack
			rjmp	bdms4_wait16

.org (pc & 0xff00) + BDM_SUB_BREADF16
bdms4_breadf16:		ldi	XL,0xe0
bdms4_breadf16a:	
			rcall	bdms4_send8
			movw	XL,r22
			rcall	bdms4_send16
			rcall	bdms4_wait160
			rcall	bdms4_recv16
			sbrs	r22,0
			mov	XL,XH
			ret

.org (pc & 0xff00) + BDM_SUB_BWRITEF16
			push	XL
bdms4_bwritef16:	ldi	XL,0xc0
bdms4_bwritef16a:	
			rcall	bdms4_send8
			movw	XL,r22
			rcall	bdms4_send16
			pop	XL
			mov	XH,XL
			rcall	bdms4_send16
			rcall	bdms4_wait160
			ret

.org (pc & 0xff00) + BDM_SUB_WREAD
bdms4_wread:		ldi	XL,0xe8
			rcall	bdms4_send8
			movw	XL,r24
			rcall	bdms4_send16
			rcall	bdms4_wait160
			rcall	bdms4_recv16
			call	api_buf_mwrite
			adiw	r24,2
			ret

.org (pc & 0xff00) + BDM_SUB_WWRITE
bdms4_wwrite:		ldi	XL,0xc8
			rcall	bdms4_send8
			movw	XL,r24
			rcall	bdms4_send16
			call	api_buf_mread
			rcall	bdms4_send16
			rcall	bdms4_wait160
			adiw	r24,2
			ret

.org (pc & 0xff00) + BDM_SUB_WREADF
bdms4_wreadf:		ldi	XL,0xe8
			rcall	bdms4_send8
			movw	XL,r22
			rcall	bdms4_send16
			rcall	bdms4_wait160
			rcall	bdms4_recv16
			ret

.org (pc & 0xff00) + BDM_SUB_WWRITEF
bdms4_wwritef:		movw	r18,XL
			ldi	XL,0xc8
			rcall	bdms4_send8
			movw	XL,r22
			rcall	bdms4_send16
			movw	XL,r18
			rcall	bdms4_send16
			rjmp	bdms4_wait160

.org (pc & 0xff00) + BDM_SUB_RSTAT
bdms4_bstat16:		ldi	XL,0xe4
			ldi	r22,0x01
			ldi	r23,0xff
			rjmp	bdms4_breadf16a

.org (pc & 0xff00) + BDM_SUB_WSTAT
			push	XL
bdms4_wstat16:		ldi	XL,0xc4
			ldi	r22,0x01
			ldi	r23,0xff
			rjmp	bdms4_bwritef16a


