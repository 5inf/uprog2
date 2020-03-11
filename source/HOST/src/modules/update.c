//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2010-2015 Joerg Wolfram (joerg@jcwolfram.de)			#
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
#include "exec/system/system.h"		//USB+BT version

int update(void)
{
	int upage,errc,blocks;
	unsigned long faddr;

	blocks=31;				// Mega644 (2K SYSTEM)

	faddr=0;

	errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode

	read_block(0,0x10000,0);

	printf("UPDATE TO VERSION %04d\n",memory[960]*256+memory[961]);

	printf("STARTING UPDATE\n");
	upage = 0;
	do
	{
		errc=prg_comm(0xf1,max_blocksize,0,faddr,0,(faddr/2) & 0xff,(faddr>>9) & 0xff,0,0);
		progress("Update",blocks-1,upage);
		upage++;
		faddr+=max_blocksize;
	}while((upage < blocks) && (errc == 0));

	if(errc > 0)
	{
		printf("\nUPDATE ERROR %d AT BLOCK %d\n",errc,upage-1);
		return 1;
	}
	else
	{
		printf("\nUPDATE DONE\n");
		return 0;
	}
}


int check_update(void)
{
	int upage,errc,blocks,isv=0;
	unsigned long faddr;

	isv=256*system_644[960]+system_644[961];

	if(isv != sysversion)
	{
		printf("PROGRAMMER SYSTEM VERSION: %04d\n",sysversion);
		printf("REQUIRED SYSTEM VERSION:   %04d\n",isv);
			
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode

		for(faddr=0;faddr<57344;faddr++)
		{			
			memory[faddr]=system_644[faddr];
		}	

		blocks=28;				// Mega644
		faddr=0;

		printf("STARTING UPDATE\n");
		upage = 0;
		do
		{
			errc=prg_comm(0xf1,max_blocksize,0,faddr,0,(faddr/2) & 0xff,(faddr>>9) & 0xff,0,0);
			progress("Update",blocks-1,upage);
			upage++;
			faddr+=max_blocksize;
		}while((upage < blocks) && (errc == 0));

		errc=prg_comm(0xfa,0,0,0,0,0,0,0,0);	//3,3V mode

		if(errc > 0)
		{
			printf("\nUPDATE ERROR %d AT BLOCK %d\n",errc,upage-1);
			return 1;
		}
		else
		{
			printf("\nUPDATE DONE\n");
			return -1;
		}
	}
	return 1;
}

