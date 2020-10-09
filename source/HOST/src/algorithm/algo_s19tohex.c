//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2012-2020 Joerg Wolfram (joerg@jcwolfram.de)			#
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

int s19tohex(void)
{
	int errc,j;
	int bpl=0;

	printf("## S19 TO HEX converter\n");
	printf("## IN:  %s\n",sfile);
	printf("## OUT: %s\n",tfile);


	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 04 -- 4 bytes per line\n");
		printf("-- 08 -- 8 bytes per line\n");
		printf("-- 16 -- 16 bytes per line\n");
		return 0;
	}

	bpl=32;

	if(find_cmd("04"))
	{
		printf("## 4 bytes per line\n");
		bpl=4;
	}

	if(find_cmd("08"))
	{
		printf("## 8 bytes per line\n");
		bpl=8;
	}

	if(find_cmd("16"))
	{
		printf("## 16 bytes per line\n");
		bpl=16;
	}

	if(file_found < 2)
	{
		printf("## !! ABORTED BECAUSE OF NO INPUT FILE !!\n");
		goto S192HEX_ERR;
	}

	if(tfile_found < 1)
	{
		printf("## !! ABORTED BECAUSE OF NO OUTPUT FILE !!\n");
		goto S192HEX_ERR;
	}

	read_block(0,65536,0);		//get data
	for(j=0;j<65536;j++)
	{
		memory[ROFFSET+j]=memory[j];
	}
	write_hexblock(loaddr,hiaddr-loaddr+1,loaddr,bpl);	

S192HEX_ERR:

	return errc;
}



