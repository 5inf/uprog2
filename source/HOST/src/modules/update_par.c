//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2010-2022 Joerg Wolfram (joerg@jcwolfram.de)			#
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
#include "exec/system_par/system.h"		//USB+BT version

int update_par(void)
{
	int upage,errc,blocks;
	unsigned long faddr,xaddr;
	int uversion;

	blocks=12;

	faddr=0;
	xaddr=0x08020000;

	read_block(0x08020000,(1024*384),0);

	uversion=memory[16384]*256+memory[16385];

//	printf("READ FROM FILE    %s\n",sfile);
	printf("UPDATE TO VERSION %04d\n",uversion);	

	printf("STARTING UPDATE\n");
	upage = 0;
	progress("Update",blocks-1,0);
	do
	{
		errc=prg_comm(0xe0,max_blocksize,0,faddr,0,xaddr & 0xff,(xaddr >> 8) & 0xff,(xaddr >> 16) & 0xff,(xaddr >> 24) & 0xff);
		progress("Update",blocks-1,upage);
		upage++;
		faddr+=max_blocksize;
		xaddr+=max_blocksize;
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


int check_update_par(void)
{
	int upage,errc,blocks,isv=0;
	unsigned long faddr,xaddr;

	isv=256*system_411[16384]+system_411[16385];

	if(isv != sysversion)
	{
		printf("PROGRAMMER SYSTEM VERSION: %04d\n",sysversion);
		printf("REQUIRED SYSTEM VERSION:   %04d\n",isv);
			
		for(faddr=0;faddr<(384*1024);faddr++)
		{			
			memory[faddr]=system_411[faddr];
		}	

		blocks=12;
		faddr=0;
		xaddr=0x08020000;

		printf("STARTING UPDATE\n");
		progress("Update",blocks-1,0);
		upage = 0;
		do
		{
			errc=prg_comm(0xe0,max_blocksize,0,faddr,0,xaddr & 0xff,(xaddr >> 8) & 0xff,(xaddr >> 16) & 0xff,(xaddr >> 24) & 0xff);
			progress("Update",blocks-1,upage);
			upage++;
			faddr+=max_blocksize;
			xaddr+=max_blocksize;
		}while((upage < blocks) && (errc == 0));

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

