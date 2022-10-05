;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;#										#
;# copyright (c) 2012-2021 Joerg Wolfram (joerg@jcwolfram.de)			#
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
; write 0x100-0x103
;------------------------------------------------------------------------------
gen_wres:		sts	0x0100,r20
			sts	0x0101,r21
			sts	0x0102,r22
			sts	0x0103,r23
			ret

gen_w32:		st	Y+,r20
			st	Y+,r21
			st	Y+,r22
			st	Y+,r23
			ret

gen_r32:		ld	r20,Y+
			ld	r21,Y+
			ld	r22,Y+
			ld	r23,Y+
			ret
