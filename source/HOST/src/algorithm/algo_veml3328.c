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

void print_veml3328_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(NO START)",errc);
				break;

		case 0x42:	set_error("(NO ACK)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int read_veml3328(void)
{
	int errc;
	float fvalue;
	int red,green,blue,clear,ired;
	float f_red,f_green,f_blue,f_clear,f_ired;
	int min_rgb, max_rgb, hue,saturation,value,itime,lb,hb,sens;

	errc=0;

	errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);	//enable PU

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- r0 -- read all with integration time 50ms\n");
		printf("-- r1 -- read all with integration time 100ms\n");
		printf("-- r2 -- read all with integration time 200ms\n");
		printf("-- r4 -- read all with integration time 400ms\n");
		printf("-- ls -- use 1/3 sensitivity\n");
		printf("-- d2 -- switch to device 2\n");
		return 0;
	}

	itime=0;
	sens=1;
	lb=0x0c;
	hb=0x00;

	if(find_cmd("r0"))
	{
		itime=50;
		printf("# use integration time 50ms\n");			
	}


	if(find_cmd("r1"))
	{
		itime=100;
		lb |= 0x10;
		printf("# use integration time 100ms\n");	
	}


	if(find_cmd("r2"))
	{
		itime=200;
		lb |= 0x20;
		printf("# use integration time 200ms\n");	
	}

	if(find_cmd("r4"))
	{
		itime=400;
		lb |= 0x30;
		printf("# use integration time 400ms\n");	
	}

	if(find_cmd("ls"))
	{
		sens=3;
		lb |= 0x40;
		printf("# use 1/3 sensitivity\n");	
	}


	if(find_cmd("d2"))
	{
		errc=prg_comm(0x2ee,0,0,0,0,0,0,0,0);	//dev 2
		printf("## switch to device 2\n");
	}

	errc=prg_comm(0x0a0,0,0,0,0,0,6,1,0);	//i2c init 400kHz		
	
	
	if(itime > 0)
	{
		if(errc==0) errc=prg_comm(0x1AA,0,0,0,0,0,0,lb,hb);		//start
		if(errc==0) errc=prg_comm(0x1AB,0,16,0,0,0,0,0,0);		//read data
		
		if(errc==0)
		{
//			show_data(0,14);
			
			clear=memory[4]+256*memory[5];
			red=memory[6]+256*memory[7];
			green=(memory[8]+256*memory[9]);
			blue=memory[10]+256*memory[11];
			ired=memory[12]+256*memory[13];
			clear=clear * 16 / 1048;
			red=red * 16 / 1048;
			green=green * 16 / 1048;
			blue=blue * 16 / 1048;
			ired=ired * 16 / 1048;
			
			printf("\n----------------------------\n");
			printf("ID    = 0x%02X\n",memory[2]);			
			printf("CLEAR = %d\n",clear);
			printf("----------------------------\n");
			printf("RED   = %d\n",red);
			printf("GREEN = %d\n",green);
			printf("BLUE  = %d\n",blue);
			printf("IRED  = %d\n",ired);
			printf("----------------------------\n");


			hue=0;
			saturation=0;
			value=0;

			min_rgb = red < green ? (red < blue ? red : blue) : (green < blue ? green : blue);
			max_rgb = red > green ? (red > blue ? red : blue) : (green > blue ? green : blue);

			value = max_rgb;
			
			if (value == 0)
			{
				hue = 0;
				saturation = 0;
				goto PRINT_HSV;
			}

			saturation = 1000 * (max_rgb - min_rgb) / value;
			value=(red + green + blue) /3;
			
			if (saturation == 0)
			{
				hue = 0;
				goto PRINT_HSV;
			}

			if (max_rgb == red) hue = 60 * (green - blue) / (max_rgb - min_rgb);
			else if (max_rgb == green) hue = 120 + 60 * (blue - red) / (max_rgb - min_rgb);
			else hue = 240 + 60 * (red - green) / (max_rgb - min_rgb);

PRINT_HSV:
			printf("HUE   = %d deg\n",hue);
			printf("SAT   = %d\n",saturation);
			printf("VAL   = %d\n",value);
			printf("----------------------------\n\n");


			
		}	
	}	
	prg_comm(0xa1,0,0,0,0,0,0,0,0);
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_veml3328_error(errc);
	return errc;
}

