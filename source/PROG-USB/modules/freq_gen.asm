;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;#										#
;# copyright (c) 2012-2017 Joerg Wolfram (joerg@jcwolfram.de)			#
;#										#
;#										#
;# This program is free software; you can redistribute it and/or		#
;# modify it under the terms of the GNU General Public License			#
;# as published by the Free Software Foundation; either version 2		#
;# of the License, or (at your option) any later version.			#
;#										#
;# This program is distributed in the hope that it will be useful,		#
;# but WITHOUT ANY WARRANTY; without even the implied warranty of		#
;# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the GNU		#
;# General Public License for more details.					#
;#										#
;# You should have received a copy of the GNU General Public			#
;# License along with this library; if not, write to the			#
;# Free Software Foundation, Inc., 59 Temple Place - Suite 330,			#
;# Boston, MA 02111-1307, USA.							#
;#										#
;################################################################################

;------------------------------------------------------------------------------
; frequency generator, delay=n*50ns
; par3 delay LOW
; par4 delay HI
;------------------------------------------------------------------------------
freq_gen_start:		cpi	r19,0
			brne	freq_gen_0	; > 256
			cpi	r18,4
			brcc	freq_gen_0
			ldi	r16,0x41	;not allowed
			jmp	main_loop

freq_gen_0:		ldi	XL,0x00		;OK
			call	host_put
			ldi	XL,0x98
			sts	UCSR0B,XL	;enable INT
			sei
			call	api_vcc_on
	
freq_gen_1:		ldi	XL,0x3f
			out	CTRLPORT,const_0
			out	CTRLDDR,XL
			cpi	r19,0
			breq	freq_gen_s1
			rjmp	freq_gen_mm


freq_gen_s1:		cpi	r18,4			;200ns
			brne	freq_gen_2
			
freq_gen_200n:		out	CTRLPORT,XL		;1
			inc	XL			;1
			rjmp	freq_gen_200n		;2

freq_gen_2:		cpi	r18,5			;250ns
			brne	freq_gen_3
			
freq_gen_250n:		out	CTRLPORT,XL		;1
			nop				;1
			inc	XL			;1
			rjmp	freq_gen_250n		;2
			

freq_gen_3:		cpi	r18,6			;300ns
			brne	freq_gen_4
			
freq_gen_300n:		out	CTRLPORT,XL		;1
			nop				;1
			nop				;1
			inc	XL			;1
			rjmp	freq_gen_300n		;2

freq_gen_4:		cpi	r18,7			;350ns
			brne	freq_gen_mm
			
freq_gen_350n:		out	CTRLPORT,XL		;1
			nop				;1
			nop				;1
			inc	XL			;1
			rjmp	freq_gen_350n		;2

						
freq_gen_mm:		sbrc	r18,1
			rjmp	freq_gen_mm2p
			sbrs	r18,0
			rjmp	freq_gen_mm0
			rjmp	freq_gen_mm1
			
freq_gen_mm2p:		sbrs	r18,0
			rjmp	freq_gen_mm2
			rjmp	freq_gen_mm3
						
			
freq_gen_mm0:		movw	r24,r18
			lsr	r25
			ror	r24
			lsr	r25
			ror	r24
			sbiw	r24,1
freq_gen_mm0_l1:	out	CTRLPORT,XL		;1
			inc	XL			;1
			movw	ZL,r24			;1
freq_gen_mm0_l2:	sbiw	ZL,1			;2
			brne	freq_gen_mm0_l2		;2/1
			rjmp	freq_gen_mm0_l1		;2

			
freq_gen_mm1:		movw	r24,r18
			lsr	r25
			ror	r24
			lsr	r25
			ror	r24
			sbiw	r24,1
freq_gen_mm1_l1:	out	CTRLPORT,XL		;1
			inc	XL			;1
			movw	ZL,r24			;1
freq_gen_mm1_l2:	sbiw	ZL,1			;2
			brne	freq_gen_mm1_l2		;2/1
			nop				;1
			rjmp	freq_gen_mm1_l1		;2
				
			
freq_gen_mm2:		movw	r24,r18
			lsr	r25
			ror	r24
			lsr	r25
			ror	r24
			sbiw	r24,1
freq_gen_mm2_l1:	out	CTRLPORT,XL		;1
			inc	XL			;1
			movw	ZL,r24			;1
freq_gen_mm2_l2:	sbiw	ZL,1			;2
			brne	freq_gen_mm2_l2		;2/1
			nop				;1
			nop				;1
			rjmp	freq_gen_mm2_l1		;2

			
freq_gen_mm3:		movw	r24,r18
			lsr	r25
			ror	r24
			lsr	r25
			ror	r24
			sbiw	r24,1
freq_gen_mm3_l1:	out	CTRLPORT,XL		;1
			inc	XL			;1
			movw	ZL,r24			;1
freq_gen_mm3_l2:	sbiw	ZL,1			;2
			brne	freq_gen_mm3_l2		;2/1
			nop				;1
			nop				;1
			nop				;1
			rjmp	freq_gen_mm3_l1		;2
	
freq_gen_stop:		out	CTRLPORT,const_0
			ldi	ZL,5
			ldi	ZH,1
			call	api_wait_ms
			out	CTRLDDR,const_0
			call	api_vcc_off
			jmp	main_loop_ok
			
											