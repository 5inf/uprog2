//###############################################################################
//#										#
//#										#
//#										#
//# copyright (c) 2010-2019 Joerg Wolfram (joerg@jcwolfram.de)			#
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


//------------------------------------------------------------------------------
// write block
//------------------------------------------------------------------------------
int write_hexblock(unsigned long start_addr, unsigned long block_len,unsigned long dest_addr,int lsize)
{
	int csum,j;
	unsigned int llen;
	unsigned long blen=block_len;
	unsigned long daddr=dest_addr;
	unsigned long addr=start_addr;	
	long offset=-1;

	tdatei = fopen (tfile, "w+");
	
	if (tdatei != NULL)
	{
		if(tfile_mode == 1)	//ihex 
		{
			while(blen > 0)
			{
				//set extended linear address record
				if(((daddr >> 16) & 0xffff) != offset)
				{
					csum=6;
					offset=(daddr >> 16) & 0xffff;		//our new offset
					fprintf(tdatei,":02000004");
					csum=csum+(offset & 0xff)+((offset >> 8) & 0xff);
					fprintf(tdatei,"%04lX",offset & 0xffff);
					csum=256-(csum & 255);
					fprintf(tdatei,"%02X\n",csum & 0xff);
				}
				//write data
				llen=lsize;
				if(blen < llen) llen=blen;
				
				csum=llen+(daddr & 0xff)+((daddr >> 8) & 0xff);
				fprintf(tdatei,":%02X%04lX00",llen,daddr & 0xffff);

				for(j=0;j<llen;j++)
				{
					fprintf(tdatei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET];
				}
				csum=256-(csum & 255);
				fprintf(tdatei,"%02X\n",csum & 0xff);
				addr+=llen;
				daddr+=llen;
				blen-=llen;		
			}		
		
		}

		else if(tfile_mode == 2)	//S28
		{
			while((blen > 0) && (daddr < 0x01000000))
			{
				//write data
				llen=lsize;
				if(blen < llen) llen=blen;
				
				csum=llen+4;		//byte count
				csum+=((daddr >> 16) & 0xff);
				csum+=((daddr >> 8) & 0xff);
				csum+=((daddr >> 0) & 0xff);
				fprintf(tdatei,"S2%02X%08lX",llen+4,daddr);
				for(j=0;j<llen;j++)
				{
					fprintf(tdatei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET] & 0xff;
				}
				csum=255-(csum & 255);
				fprintf(tdatei,"%02X\n",csum);
				addr+=llen;
				daddr+=llen;
				blen-=llen;
			}		
		}

		else if(tfile_mode == 3)	//S19
		{
			while((blen > 0) && (daddr < 0x010000))
			{
				//write data
				llen=lsize;
				if(blen < llen) llen=blen;
				
				csum=llen+3;		//byte count
				csum+=((daddr >> 8) & 0xff);
				csum+=((daddr >> 0) & 0xff);
				fprintf(tdatei,"S1%02X%08lX",llen+3,daddr);
				for(j=0;j<llen;j++)
				{
					fprintf(tdatei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET] & 0xff;
				}
				csum=255-(csum & 255);
				fprintf(tdatei,"%02X\n",csum);
				addr+=llen;
				daddr+=llen;
				blen-=llen;
			}		
		
		
		}


		else //S37
		{
			while(blen > 0)
			{
				//write data
				llen=lsize;
				if(blen < llen) llen=blen;
				
				csum=llen+5;		//byte count
				csum+=((daddr >> 24) & 0xff);
				csum+=((daddr >> 16) & 0xff);
				csum+=((daddr >> 8) & 0xff);
				csum+=((daddr >> 0) & 0xff);
				fprintf(tdatei,"S3%02X%08lX",llen+5,daddr);
				for(j=0;j<llen;j++)
				{
					fprintf(tdatei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET] & 0xff;
				}
				csum=255-(csum & 255);
				fprintf(tdatei,"%02X\n",csum);
				addr+=llen;
				daddr+=llen;
				blen-=llen;
			}		
		}

		return 0;	//write OK
	}
	else
	{
		return 1;	//write failed
	}
	fclose (tdatei);

}

