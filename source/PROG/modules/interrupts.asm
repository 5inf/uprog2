;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;#										#
;# copyright (c) 2012-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
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
reset_vector:		jmp	bl_reset	;B+00	bootloader starts here

			jmp	noint		;B+02	ext0
			jmp	noint		;B+04	ext1
			jmp	noint		;B+06	ext2
			jmp	noint		;B+08	pcint0
			jmp	noint		;B+0A	pcint1
			jmp	noint		;B+0C	pcint2
			jmp	noint		;B+0E	pcint3
			jmp	noint		;B+10	wdt
			jmp	noint		;B+12	T2A
			jmp	noint		;B+14	T2B
			jmp	noint		;B+16	T2O
			jmp	noint		;B+18	T1C
			jmp	noint		;B+1A	T1A
			jmp	noint		;B+1C	T1B
			jmp	noint		;B+1E	T1O
			jmp	pdi_clk_int	;B+20	T0A
			jmp	pdi_clk_int	;B+22	T0B
			jmp	pdi_clk_int	;B+24	T0O
			jmp	noint		;B+26	SPI
			jmp	ser_break_int	;B+28	U0RX 
			jmp	noint		;B+2A	U0DA
			jmp	noint		;B+2C	U0TX
			jmp	noint		;B+2E	ACOMP
			jmp	noint		;B+30	ADC
			jmp	noint		;B+32	EE
			jmp	noint		;B+34	TWI
			jmp	noint		;B+36	SPM
						
pdi_clk_int:		out	PINC,const_1	;toggle CLK
noint:			sei
			reti

			
ser_break_int:		pop	r0		;discard stack entry
			pop	r0
;			sts	0x900,r24
;			sts	0x901,r25
			ldi	XL,0x18
			sts	UCSR0B,XL	;disable further RX0 interrupts		
			lds	XL,UDR0	
			sei
			jmp	main_loop_04
			