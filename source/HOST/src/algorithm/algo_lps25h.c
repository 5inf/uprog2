//##############################################################################
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

void print_lps25h_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(NO ACK)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int read_lps25h(void)
{
	int errc;
	int dev_addr=0xb8;
	unsigned long value;
	float fvalue;

	errc=0;

	errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);	//enable PU

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- r0 -- read all, ADDR=0\n");
		printf("-- r1 -- read all, ADDR=1\n");
		printf("-- d2 -- switch to device 2\n");
		return 0;
	}

	if(find_cmd("d2"))
	{
		errc=prg_comm(0x2ee,0,0,0,0,0,0,0,0);	//dev 2
		printf("## switch to device 2\n");
	}

	errc=prg_comm(0x0a0,0,0,0,0,0,6,1,0);	//i2c init 400kHz		

	if(find_cmd("r1")) dev_addr=0xBA;

	if((find_cmd("r0")) || (find_cmd("r1")))
	{
		if(errc==0) errc=prg_comm(0xA4,0,0,0,0,0,0,dev_addr,0);		//start

		if(errc==0) errc=prg_comm(0xA2,0,1,0,0,15,0,dev_addr,1);	//read ID
		
		if(errc==0)
		{
			printf("  ID:     %02X\n",memory[0]);
		}	

		if(errc==0) errc=prg_comm(0xA2,0,7,0,0,39+128,0,dev_addr,1);	//read PH
		
		value=(unsigned long)memory[1]	+ ((unsigned long)memory[2] << 8) + ((unsigned long)memory[3] << 16);	
	
		fvalue=(float)value;
		fvalue /= 4096;

		if(errc==0)
		{
			printf("  PRESS:  %f hPa\n",fvalue);
		}	

		value=(unsigned long)memory[4]	+ ((unsigned long)memory[5] << 8);	
	
		if(value & 0x8000) fvalue=0-(float) (65535-value); 
		else fvalue=(float)value;

		fvalue /= 480;
		fvalue += 42.5;

		if(errc==0)
		{
			printf("  TEMP:   %f °C\n",fvalue);
		}
	}	
	
	prg_comm(0xa1,0,0,0,0,0,0,0,0);
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_lps25h_error(errc);
	return errc;
}




