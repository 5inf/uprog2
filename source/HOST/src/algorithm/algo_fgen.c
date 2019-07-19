//###############################################################################
//#										#
//#										#
//#										#
//# copyright (c) 2010-2015 Joerg Wolfram (joerg@jcwolfram.de)			#
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

void print_fgen_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(PARAMETER OUT OF RANGE 153 - 2500000 Hz)",errc);
				break;

		case 0x43:	set_error("(PARAMETER OUT OF RANGE 400 - 6553500 ns)",errc);
				break;

		case 0x42:	set_error("(Parameter missing)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

void print_freq(unsigned long period)
{
	float val;
	
	val=10000000/period;

	if(val > 999999)
	{
		printf("FREQUENCY  %f MHz \n",val/1000000);
	}
	else if (val > 999)
	{
		printf("FREQUENCY  %f KHz \n",val/1000);
	}
	else
	{
		printf("FREQUENCY  %f Hz \n",val);
	}
}


void print_period(unsigned long period)
{
	float val;
	
	val=period*100;

	if(val > 999999)
	{
		printf("PERIOD     %f ms \n",val/1000000);
	}
	else if (val > 999)
	{
		printf("PERIOD     %f us \n",val/1000);
	}
	else
	{
		printf("PERIOD     %f ns \n",val);
	}
}


int prog_fgen(void)
{
	int errc;
	unsigned long cperiod;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- of -- output frequency\n");
		printf("-- ot -- output time\n");
		printf("-- d2 -- switch to device 2\n");
		return 0;
	}

	errc=0;

	if(find_cmd("d2"))
	{
		errc=prg_comm(0x2ee,0,0,0,0,0,0,0,0);	//dev 2
		printf("## switch to device 2\n");
	}

	if(find_cmd("5v"))
	{
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		printf("## using 5V VDD\n");
	}

	if(have_expar < 1) errc=0x42;

	if((find_cmd("ot")) && (errc == 0))
	{
		printf("## period mode\n\n");
		cperiod=expar/100;
		
		if((cperiod < 4) || (cperiod > 65535))
		{
			errc=0x43;
			goto FGEN_END;
		}
		print_freq(cperiod);
		print_period(cperiod);

//		printf("## period mode %04X\n\n",cperiod);
		
		errc=prg_comm(0x191,0,0,0,0,0,0,(cperiod) & 0xff,(cperiod >> 8) & 0xff);	//start
		waitkey();
		prg_comm(0x12f,0,0,0,0,0,0,0,0);	//stop

	}

	if((find_cmd("of")) && (errc == 0))
	{
		printf("## frequency mode\n\n");
		cperiod=10000000/expar;
		
		if((cperiod < 4) || (cperiod >= 65535))
		{
			errc=0x41;
			goto FGEN_END;
		}		
		print_freq(cperiod);
		print_period(cperiod);
		
		errc=prg_comm(0x191,0,0,0,0,0,0,(cperiod) & 0xff,(cperiod >> 8) & 0xff);	//stop
		
		waitkey();
		errc=prg_comm(0x12f,0,0,0,0,0,0,0,0);	//stop

	}
	
FGEN_END:
	
	prg_comm(0x1f,0,0,0,0,0,0,0,0);	//exit
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_fgen_error(errc);
	return errc;
}

