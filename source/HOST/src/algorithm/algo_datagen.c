//###############################################################################
//#										#
//# UPROG universal programmer							#
//#										#
//# copyright (c) 2012-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
//#										#
//#										#
//# This program is free software; you can redistribute it and/or		#
//# modify it under the terms of the GNU General Public License			#
//# as published by the Free Software Foundation; either version 2		#
//# of the License, or (at your option) any later version.			#
//#										#
//# This program is distributed in the hope that it will be useful,		#
//# but WITHOUT ANY WARRANTY; without even the implied warranty of		#
//# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the GNU		#
//# General Public License for more details.					#
//#										#
//# You should have received a copy of the GNU General Public			#
//# License along with this library// if not, write to the			#
//# Free Software Foundation, Inc., 59 Temple Place - Suite 330,		#
//# Boston, MA 02111-1307, USA.							#
//#										#
//###############################################################################

#include <main.h>

void print_dgen_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_dgen(void)
{
	int errc=0;
	unsigned long addr;

	printf("\n");
	
	errc=writeblock_open();

	for(addr=0;addr<param[1];addr++)
	{
		memory[addr+ROFFSET]= (~addr) & 0xff;
	}		

	writeblock_data(0,param[1],param[0]);
	writeblock_close();

	print_dgen_error(errc);

	return errc;
}
