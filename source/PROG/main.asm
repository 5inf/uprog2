;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;# copyright (c) 2012-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
;#										#
;#										#
;# This program is free software; you can redistribute it and/or		#
;# modify it under the terms of the GNU General Public				#
;# License as published by the Free Software Foundation; either			#
;# version 2 of the License, or (at your option) any later version.		#
;#										#
;# This library is distributed in the hope that it will be useful,		#
;# but WITHOUT ANY WARRANTY; without even the implied warranty of		#
;# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU		#
;# General Public License for more details.					#
;#										#
;# You should have received a copy of the GNU General Public			#
;# License along with this library; if not, write to the			#
;# Free Software Foundation, Inc., 59 Temple Place - Suite 330,			#
;# Boston, MA 02111-1307, USA.							#
;#										#
;################################################################################

.CSEG
.include	"/usr/local/include/avr/m644def.inc"

.def		const_0		= r2
.def		const_1		= r3

.equ		sysver_high	= 0x00	
.equ		sysver_low	= 0x0F

.equ		buffer		= 0x100		;data buffer
.equ		stack		= 0x10ff	;system/return stack

;system variables
.equ		parbuffer	= 0x1000
.equ		txlen_l		= 0x1080
.equ		txlen_h		= 0x1081
.equ		rxlen_l		= 0x1082
.equ		rxlen_h		= 0x1083
.equ		par_1		= 0x1084
.equ		par_2		= 0x1085
.equ		par_3		= 0x1086
.equ		par_4		= 0x1087
.equ		tabselect	= 0x1088
.equ		pull_sel	= 0x108a
.equ		pull_pol	= 0x108b
.equ		int_stat	= 0x108c
.equ		devbuf		= 0x1090

.equ		LEDPORT		= PORTB
.equ		BUSY_LED	= 2
.equ		VOLT_LED	= 3

.equ		CTRLPORT	= PORTC
.equ		CTRLDDR		= DDRC
.equ		CTRLPIN		= PINC
.equ		SIG1		= 0
.equ		SIG2		= 1
.equ		SIG3		= 2
.equ		SIG4		= 3
.equ		SIG5		= 4
.equ		SIG6		= 5
.equ		SIG1_AND	= 0xfe
.equ		SIG2_AND	= 0xfd
.equ		SIG3_AND	= 0xfb
.equ		SIG4_AND	= 0xf7
.equ		SIG5_AND	= 0xef
.equ		SIG6_AND	= 0xdf
.equ		SIG1_OR		= 0x01
.equ		SIG2_OR		= 0x02
.equ		SIG3_OR		= 0x04
.equ		SIG4_OR		= 0x08
.equ		SIG5_OR		= 0x10
.equ		SIG6_OR		= 0x20

.org 0x0000
.include	"modules/interrupts.asm"
.org 0x01e0
.include	"modules/version.asm"
.org 0x0200
.include	"modules/interpreter.asm"

;communication modules
.include	"modules/spi.asm"
.include	"modules/bdm.asm"
.include	"modules/serial1.asm"
.include	"modules/serial2.asm"
.include	"modules/sercomm.asm"
.include	"modules/serial3.asm"
.include	"modules/serial4.asm"
.include	"modules/serial_e.asm"
.include	"modules/i2c.asm"
.include	"modules/jtag.asm"
.include	"modules/freq_gen.asm"
.include	"modules/la_1m.asm"
.include	"modules/la_100k.asm"
.include	"modules/la_10k.asm"
;.include	"modules/swd.asm"

;device modules
.include	"devices/s08.asm"
.include	"devices/r8c.asm"
.include	"devices/avr.asm"
.include	"devices/rh850.asm"
.include	"devices/s12x.asm"
.include	"devices/s12xd.asm"
.include	"devices/s12xe.asm"
.include	"devices/msp430_sbw.asm"
.include	"devices/stm8a.asm"
.include	"devices/dspic33.asm"
.include	"devices/nec1.asm"
.include	"devices/nec2.asm"
.include	"devices/pic1.asm"
.include	"devices/pic2.asm"
.include	"devices/ppcbam.asm"
.include	"devices/rl78.asm"
.include	"devices/stm7.asm"
.include	"devices/cc2541.asm"
.include	"devices/psoc4.asm"
.include	"devices/stm32swd.asm"
.include	"devices/s32k.asm"
.include	"devices/spiflash.asm"
.include	"devices/spieeprom.asm"
.include	"devices/dataflash.asm"
.include	"devices/pdi.asm"
.include	"devices/xc9500.asm"
.include	"devices_no_public/zspm.asm"		;xprivate
.include	"devices_no_public/mrk3.asm"		;xprivate
.include	"devices_no_public/elmos_sbw.asm"	;xprivate
.include	"devices/v850.asm"
.include	"devices_no_public/tee.asm"		;xprivate
.include	"devices_no_public/mb91.asm"		;xprivate
.include	"devices_no_public/sp40.asm"		;xprivate
.include	"devices/mlx363.asm"
.include	"devices/mlx316.asm"
.include	"devices/ppcjtag.asm"
.include	"devices/cc2640.asm"
.include	"devices/sici.asm"
.include	"devices/updi.asm"
.include	"devices/at89s8252.asm"
.include	"devices/s12z.asm"
.include	"devices/efm32swd.asm"

;tables
bdm_ctab:
.include	"tables/bdmftable.inc"
.include	"tables/st7_code.inc"


;bootloader and system stuff
.org 0x7C00
bootloader:
.include	"system/boot.asm"
.include	"system/memory.asm"

