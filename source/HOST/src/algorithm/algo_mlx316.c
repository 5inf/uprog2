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

void print_mlx316_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("Communication Error",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_mlx316(void)
{
	long errc;
	int angle;
	float fangle;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5v   -- using 5V VDD\n");	
		printf("-- read -- read angle/status\n");
		printf("-- d2 -- switch to device 2\n");
		return 0;
	}

	if(find_cmd("d2"))
	{
		errc=prg_comm(0x2ee,0,0,0,0,0,0,0,0);	//dev 2
		printf("## switch to device 2\n");
	}

	if(find_cmd("5v"))
	{
		printf("## using 5V VDD\n");	
		prg_comm(0xFB,0,0,0,0,0,0,0,0);	//set 5V		
	
	}
	
	if(find_cmd("read"))
	{
		prg_comm(0xFE,0,0,0,0,3,3,0,0);		//enable PU		
		prg_comm(0x173,0,4,0,0,0,0,0,0);	//readout		
//		show_data(0,4);

		angle= memory[0];
		angle <<= 8;
		angle |= memory[1];
		printf("RAW = %04X\n",angle);

		if((angle & 3) == 0x01)		//normal state
		{			
			angle >>= 2;
//			printf("RAW = %04X\n",angle);
//			printf("RAW = %d\n",angle);
			fangle=angle;
			fangle=fangle*360/16384;
			printf("DEG = %3.2f°\n",fangle);		
		}
		else if ((angle & 3) == 0x02)	//error state
		{
			if((memory[1] & 0x04) != 0) printf("!! Status: ADC FAILURE\n");	
			if((memory[1] & 0x08) != 0) printf("!! Status: ADC SATURATION\n");	
			if((memory[1] & 0x30) != 0) printf("!! Status: FIELD TO WEAK\n");	
			if((memory[1] & 0xC0) != 0) printf("!! Status: FIELD TO STRONG\n");
		
		}
		else errc=0x41;
	}	

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_mlx316_error(errc);
	return errc;
}





