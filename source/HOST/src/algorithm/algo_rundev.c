//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2012-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
//#										#
//#										#
//# This program is free software; you can redistribute it and/or		#
//# modify it under the terms of the GNU General Public License			#
//# as published by the Free Software Foundation; either version 3		#
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

void print_rundev_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",0);
				break;

		case 1:		set_error("WRONG COMMAND",1);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int prog_rundev(void)
{
	int errc=0;

	if(find_cmd("s5"))
	{
		printf("## starting at 5V VDD\n");
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);			//5V mode
		if(errc==0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);	//init
		hold_vdd=1;
	}

	if(find_cmd("s3"))
	{
		printf("## starting at 3,3V VDD\n");
		errc=prg_comm(0xfa,0,0,0,0,0,0,0,0);			//3,3V mode
		if(errc==0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);	//init
		hold_vdd=1;
	}

	if(find_cmd("s6"))
	{
		printf("## starting at 5V VDD\n");
		errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);			//enable PU
		if(errc==0) errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		if(errc==0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);	//init
		hold_vdd=1;
	}

	if(find_cmd("s4"))
	{
		printf("## starting at 3,3V VDD\n");
		errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);			//enable PU
		if(errc==0) errc=prg_comm(0xfa,0,0,0,0,0,0,0,0);	//3,3V mode
		if(errc==0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);	//init
		hold_vdd=1;
	}


	if(find_cmd("s0"))
	{
		printf("## stopping device\n");
		errc=prg_comm(0x0f,0,0,0,0,0,0,0,0);			//exit
		errc=prg_comm(0xfe,0,0,0,0,0,0,0,0);			//disable PU
		errc=prg_comm(0xfa,0,0,0,0,0,0,0,0);			//3,3V mode
		hold_vdd=0;
	}

	print_rundev_error(errc);

	return errc;
}
