//###############################################################################
//#										#
//# write hex files								#
//#										#
//# copyright (c) 2010-2020 Joerg Wolfram (joerg@jcwolfram.de)			#
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
// open file for block writing
//------------------------------------------------------------------------------
int writeblock_open()
{
	datei = fopen (sfile, "w+");
	if (datei != NULL)
	{
		if(file_mode == 0)	//srec
		{
			fprintf(datei,"S00441424335\n");
		}
		return 0;

	}
	else
	{
		printf("!!! CANNOT WRITE FILE !!!\n");
		return 1;
	}
}


//------------------------------------------------------------------------------
// open file for block writing
//------------------------------------------------------------------------------
int writelist_open()
{
	datei = fopen (sfile, "w+");
	if (datei != NULL)
	{
		return 0;
	}
	else
	{
		printf("!!! CANNOT WRITE FILE !!!\n");
		return 1;
	}
}


//------------------------------------------------------------------------------
// close block file
//------------------------------------------------------------------------------
int writeblock_close()
{
	if (datei != NULL)
	{
		if(file_mode == 1)	//ihex
		{
			fprintf(datei,":00000001FF\n");
		}
		fclose (datei);
		return 0;
	}
	else
	{
		return 1;
	}
}

//------------------------------------------------------------------------------
// write block
//------------------------------------------------------------------------------
int writeblock_data(unsigned long start_addr, unsigned long block_len,unsigned long dest_addr)
{
	int csum,j;
	unsigned int llen;
	unsigned long blen=block_len;
	unsigned long daddr=dest_addr;
	unsigned long addr=start_addr;	
	long offset=-1;
	
	if (datei != NULL)
	{
		if(file_mode == 1)	//ihex 
		{
			while(blen > 0)
			{
				//set extended linear address record
				if(((daddr >> 16) & 0xffff) != offset)
				{
					csum=6;
					offset=(daddr >> 16) & 0xffff;		//our new offset
					fprintf(datei,":02000004");
					csum=csum+(offset & 0xff)+((offset >> 8) & 0xff);
					fprintf(datei,"%04lX",offset & 0xffff);
					csum=256-(csum & 255);
					fprintf(datei,"%02X\n",csum & 0xff);
				}
				//write data
				llen=32;
				if(blen < llen) llen=blen;
				
				csum=llen+(daddr & 0xff)+((daddr >> 8) & 0xff);
				fprintf(datei,":%02X%04lX00",llen,daddr & 0xffff);

				for(j=0;j<llen;j++)
				{
					fprintf(datei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET];
				}
				csum=256-(csum & 255);
				fprintf(datei,"%02X\n",csum & 0xff);
				addr+=llen;
				daddr+=llen;
				blen-=llen;		
			}		
		
		}

		else if(file_mode == 2)	//S28
		{
			if(daddr >= 0x01000000) range_err=1;			
			while((blen > 0) && (daddr < 0x01000000))
			{
				//write data
				llen=32;
				if(blen < llen) llen=blen;
				
				csum=llen+4;		//byte count
				csum+=((daddr >> 16) & 0xff);
				csum+=((daddr >> 8) & 0xff);
				csum+=((daddr >> 0) & 0xff);
				fprintf(datei,"S2%02X%06lX",llen+4,daddr);
				for(j=0;j<llen;j++)
				{
					fprintf(datei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET] & 0xff;
				}
				csum=255-(csum & 255);
				fprintf(datei,"%02X\n",csum);
				if((daddr+llen-1) >= 0x01000000) range_err=1;			
				addr+=llen;
				daddr+=llen;
				blen-=llen;
			}		
		}

		else if(file_mode == 3)	//S19
		{

			if(daddr >= 0x010000) range_err=1;			
			while((blen > 0) && (daddr < 0x010000))
			{
				//write data
				llen=32;
				if(blen < llen) llen=blen;
				
				csum=llen+3;		//byte count
				csum+=((daddr >> 8) & 0xff);
				csum+=((daddr >> 0) & 0xff);
				fprintf(datei,"S1%02X%04lX",llen+3,daddr);
				for(j=0;j<llen;j++)
				{
					fprintf(datei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET] & 0xff;
				}
				csum=255-(csum & 255);
				fprintf(datei,"%02X\n",csum);
				if((daddr+llen-1) >= 0x010000) range_err=1;			
				addr+=llen;
				daddr+=llen;
				blen-=llen;
			}		
		}

		else
		{
			while(blen > 0)
			{
				//write data
				llen=32;
				if(blen < llen) llen=blen;
				
				csum=llen+5;		//byte count
				csum+=((daddr >> 24) & 0xff);
				csum+=((daddr >> 16) & 0xff);
				csum+=((daddr >> 8) & 0xff);
				csum+=((daddr >> 0) & 0xff);
				fprintf(datei,"S3%02X%08lX",llen+5,daddr);
				for(j=0;j<llen;j++)
				{
					fprintf(datei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET] & 0xff;
				}
				csum=255-(csum & 255);
				fprintf(datei,"%02X\n",csum);
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
}

//------------------------------------------------------------------------------
// write block
//------------------------------------------------------------------------------
int writeblock_data16(unsigned long start_addr, unsigned long block_len,unsigned long dest_addr)
{
	int csum,j;
	unsigned int llen;
	unsigned long blen=block_len;
	unsigned long daddr=dest_addr;
	unsigned long addr=start_addr;	
	long offset=-1;
	
	if (datei != NULL)
	{
		if(file_mode == 1)	//ihex 
		{
			while(blen > 0)
			{
				//set extended linear address record
				if(((daddr >> 16) & 0xffff) != offset)
				{
					csum=6;
					offset=(daddr >> 16) & 0xffff;		//our new offset
					fprintf(datei,":02000004");
					csum=csum+(offset & 0xff)+((offset >> 8) & 0xff);
					fprintf(datei,"%04lX",offset & 0xffff);
					csum=256-(csum & 255);
					fprintf(datei,"%02X\n",csum & 0xff);
				}
				//write data
				llen=16;
				if(blen < llen) llen=blen;
				
				csum=llen+(daddr & 0xff)+((daddr >> 8) & 0xff);
				fprintf(datei,":%02X%04lX00",llen,daddr & 0xffff);

				for(j=0;j<llen;j++)
				{
					fprintf(datei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET];
				}
				csum=256-(csum & 255);
				fprintf(datei,"%02X\n",csum & 0xff);
				addr+=llen;
				daddr+=llen;
				blen-=llen;		
			}		
		
		}

		else if(file_mode == 2)	//S28
		{
			if(daddr >= 0x01000000) range_err=1;			
			while((blen > 0) && (daddr < 0x01000000))
			{
				//write data
				llen=16;
				if(blen < llen) llen=blen;
				
				csum=llen+4;		//byte count
				csum+=((daddr >> 16) & 0xff);
				csum+=((daddr >> 8) & 0xff);
				csum+=((daddr >> 0) & 0xff);
				fprintf(datei,"S2%02X%06lX",llen+4,daddr);
				for(j=0;j<llen;j++)
				{
					fprintf(datei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET] & 0xff;
				}
				csum=255-(csum & 255);
				fprintf(datei,"%02X\n",csum);
				if((daddr+llen-1) >= 0x01000000) range_err=1;			
				addr+=llen;
				daddr+=llen;
				blen-=llen;
			}		
		}

		else if(file_mode == 3)	//S19
		{

			if(daddr >= 0x010000) range_err=1;			
			while((blen > 0) && (daddr < 0x010000))
			{
				//write data
				llen=16;
				if(blen < llen) llen=blen;
				
				csum=llen+3;		//byte count
				csum+=((daddr >> 8) & 0xff);
				csum+=((daddr >> 0) & 0xff);
				fprintf(datei,"S1%02X%04lX",llen+3,daddr);
				for(j=0;j<llen;j++)
				{
					fprintf(datei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET] & 0xff;
				}
				csum=255-(csum & 255);
				fprintf(datei,"%02X\n",csum);
				if((daddr+llen-1) >= 0x010000) range_err=1;			
				addr+=llen;
				daddr+=llen;
				blen-=llen;
			}		
		}

		else
		{
			while(blen > 0)
			{
				//write data
				llen=16;
				if(blen < llen) llen=blen;
				
				csum=llen+5;		//byte count
				csum+=((daddr >> 24) & 0xff);
				csum+=((daddr >> 16) & 0xff);
				csum+=((daddr >> 8) & 0xff);
				csum+=((daddr >> 0) & 0xff);
				fprintf(datei,"S3%02X%08lX",llen+5,daddr);
				for(j=0;j<llen;j++)
				{
					fprintf(datei,"%02X",memory[addr+j+ROFFSET]);
					csum+=memory[addr+j+ROFFSET] & 0xff;
				}
				csum=255-(csum & 255);
				fprintf(datei,"%02X\n",csum);
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
}




//------------------------------------------------------------------------------
// write block
//------------------------------------------------------------------------------
int writeblock_list(unsigned long start_addr, unsigned long block_len)
{
	int csum,j;
	unsigned int llen;
	unsigned long blen=block_len;
	unsigned long addr=start_addr;	
	
	if (datei != NULL)
	{
		while(blen > 0)
		{
			//write data
			llen=16;
			if(blen < llen) llen=blen;
				
			fprintf(datei,"\t");
			for(j=0;j<llen;j++)
			{
				fprintf(datei,"0x%02X,",memory[addr+j+ROFFSET]);
				csum+=memory[addr+j+ROFFSET] & 0xff;
			}
			fprintf(datei,"\n");
			addr+=llen;
			blen-=llen;
		}		
		
		return 0;	//write OK
	}
	else
	{
		return 1;	//write failed
	}
}


