//###############################################################################
//#										#
//# UPROG universal programmer							#
//#										#
//# copyright (c) 2012-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
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

void print_dataflash_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(TIMEOUT)",errc);
				break;

		case 0x7e:	set_error("(WRONG ID)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_dataflash(void)
{
	int errc,blocks,i,psize,fact,pages_per_block;
	unsigned long addr,maddr,nextaddr;
	int bsize;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int shortpage=0;
	int rawpage=0;
	int ignore_devid=0;
	int setbin=0;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5v -- using 5V VDD\n");
		printf("-- ea -- bulk erase\n");
		printf("-- pm -- memory program\n");
		printf("-- vm -- memory verify\n");
		printf("-- rm -- memory read\n");
		printf("-- fp -- full page mode\n");
		printf("-- ii -- ignore wrong ID\n");
		printf("-- d2 -- switch to device 2\n");
		printf("-- setbin -- set permanent to binary page mode\n");		
		return 0;
	}

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
	
	if(find_cmd("fp"))
	{
		rawpage=1;
		printf("## full page mode\n");
	}
	
	if(find_cmd("ii"))
	{
		ignore_devid=1;
		printf("## Ignore device ID\n");
	}

	if(find_cmd("setbin"))
	{
		setbin=1;
		printf("## set permanent to binary page mode\n");
	}


	if(find_cmd("ea"))
	{
		main_erase=1;
		printf("## Action: bulk memory erase\n");
	}


	main_prog=check_cmd_prog("pm","memory");
	main_verify=check_cmd_verify("vm","memory");
	main_readout=check_cmd_read("rm","memory",&main_prog,&main_verify);
	
	if(main_readout > 0)
	{
		errc=writeblock_open();
	}

	nextaddr=param[3];
	bsize=max_blocksize;
	pages_per_block=bsize/param[3];

	if(errc==0) 
	{
		errc=prg_comm(0x110,0,0,0,0,0,0,0,0);		//init
		i=prg_comm(0x115,0,0,0,0,0,0,0,0);		//get info
		if((i & param[4]) != param[5])
		{
			printf("## ID: 0x%02X, should be 0x%02X\n",(i /*& param[4]*/),(unsigned char)(param[5]) & 0xff);	
			errc=0x7e;
		}
		if((ignore_devid == 1) && (errc == 0x7e)) errc=0;
		psize=param[3];

		//device has long pages		
		if(!(i & 1))
		{
			psize = psize + (psize >> 5);
			nextaddr <<= 1;
			shortpage=0x80;
		}
		else
		{
			rawpage=0;
		}
		printf("## PSIZE: %d bytes per page\n",psize);
	}

	printf("\n");
	if(errc != 0) goto DF_END;


//###############################################################################
// set to binary mode
//###############################################################################

	if(setbin==1)
	{
		if(shortpage==0x00)
		{
			printf(">> device is already in binary page mode\n");	
		}
		else
		{
				printf("SET BINARY PAGE MODE\n");		
				errc=prg_comm(0x119,0,0,0,0,0,0,20,0);
		}	
		goto DF_END;
	}

//###############################################################################
// erase
//###############################################################################
	if(main_erase > 0)
	{
		addr=0;
		blocks=param[1]/8;

		progress("ERASE ",blocks,0);
		for(i=0;i<blocks;i++)
		{
			if(errc == 0)
			{
				errc=prg_comm(0x114,0,0,0,0,
				(addr >> 8) & 0xff,		//ADDR M
				(addr >> 16) & 0xff,		//ADDR H
				100,				//max 100ms
				0);
			}
			addr+=nextaddr * 8;
			progress("ERASE ",blocks,i+1);
		}
		printf("\n");
	}

//###############################################################################
// program
//###############################################################################
	if((main_prog == 1) && (errc == 0))
	{
		if(rawpage == 0)
		{
			read_block(0,param[1]*param[3],0);	//get data from file
			psize=param[3];				//page size from parameter table
			blocks=(param[1]*psize)/bsize;
			addr=0;
			maddr=0;
			printf("## PROG %d blocks (%d pages of %d bytes per block)\n",blocks,bsize/psize,psize);
			progress("PROG  ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(errc == 0)
				{
					errc=prg_comm(0x113,bsize,0,maddr,0,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					((psize >> 8) & 0x7f) | shortpage,
					pages_per_block);		//pages per block
				}
				addr+=(nextaddr * pages_per_block);
				maddr+=bsize;
				progress("PROG  ",blocks,i+1);
			}
		} 
		else
		{
			read_block(0,param[1]*param[3]*2,0);
			psize=param[3];					//page size from parameter table
			blocks=(param[1]*psize*2)/bsize;
			addr=0;
			maddr=0;
			printf("## PROG %d blocks (%d pages of %d bytes per block)\n",blocks,bsize/(psize*2),psize*2);

			progress("PROG  ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(errc == 0)
				{
					errc=prg_comm(0x118,bsize,0,maddr,0,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(psize >> 8) & 0xff,
					pages_per_block/2);		//pages per block
				}
				addr+=(nextaddr * pages_per_block * 2);
				maddr+=bsize;
				progress("PROG  ",blocks,i+1);
			}
		}
		printf("\n");
	}
	
//###############################################################################
// readout /verify
//###############################################################################
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		if(rawpage == 0)
		{
			psize=param[3];					//page size 
			blocks=(param[1]*psize)/bsize;
			addr=0;
			maddr=0;
			printf("## READ %d blocks (%d pages of %d bytes per block)\n",blocks,bsize/psize,psize);

			progress("READ  ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(errc == 0)
				{
					errc=prg_comm(0x112,0,bsize,0,maddr+ROFFSET,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					((psize >> 8) & 0x7f) | shortpage,
					pages_per_block);		//pages per block
				}
				addr+=nextaddr*pages_per_block;
				maddr+=bsize;
				progress("READ  ",blocks,i+1);
			}
		} 
		else
		{
			bsize=max_blocksize;
			psize=param[3];					//page size from parameter table
			blocks=(param[1]*param[3]*2)/bsize;
			addr=0;
			maddr=0;
			printf("## READ %d blocks (%d pages of %d bytes per block)\n",blocks,bsize/(psize*2),psize*2);

			progress("READ  ",blocks,0);
			for(i=0;i<blocks;i++)
			{
//				printf("ADDR= %08lX\n",maddr);
				if(errc == 0)
				{
					errc=prg_comm(0x117,0,bsize,0,maddr+ROFFSET,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(psize >> 8) & 0xff,
					pages_per_block/2);		//pages per block
				}
				addr+=(nextaddr * pages_per_block * 2);
				maddr+=bsize;
				progress("READ  ",blocks,i+1);
			}
		}
		printf("\n");
	}

	//verify main
	if((main_verify == 1) && (errc == 0))
	{
		printf("VERIFY DATA\n");
		if(rawpage == 0)
		{
			read_block(0,param[1]*param[3],0);
			for(addr=0;addr<(param[1]*param[3]);addr++)
			{
				if(memory[addr] != memory[addr+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr,memory[addr],memory[addr+ROFFSET]);
					errc=1;
				}
			}
		}
		else
		{
			read_block(0,param[1]*param[3]*2,0);
			for(addr=0;addr<(param[1]*param[3]*2);addr++)
			{
				if(memory[addr] != memory[addr+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr,memory[addr],memory[addr+ROFFSET]);
					errc=1;
				}
			}
		}		
	}


	if((main_readout == 1) && (errc == 0))
	{
		if(rawpage == 0)
		{
			writeblock_data(0,param[1]*param[3],0);
		}
		else
		{
			writeblock_data(0,param[1]*param[3]*2,0);
		}
	}

	if(main_readout > 0)
	{
		writeblock_close();
	}

DF_END:

	i=prg_comm(0x111,0,0,0,0,0,0,0,0);					//dataflash exit
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_dataflash_error(errc);

	return errc;
}

 


