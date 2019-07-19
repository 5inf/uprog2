//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2012-2015 Joerg Wolfram (joerg@jcwolfram.de)			#
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

void print_cc25xx_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(Timeout)",errc);
				break;

		case 0x42:	set_error("(ID does not match)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_cc25xx(void)
{
	int errc,blocks,bsize,j;
	unsigned long addr,flash_addr,flash_size,maddr;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dev_start=0;
	int ignore_id=0;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- rr -- run code in RAM\n");
		printf("-- ea -- chip erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");
		printf("-- ii -- ignore device ID\n");
		printf("-- st -- start device\n");
		printf("-- d2 -- switch to device 2\n");

		return 0;
	}

	if(find_cmd("d2"))
	{
		errc=prg_comm(0x2ee,0,0,0,0,0,0,0,0);	//dev 2
		printf("## switch to device 2\n");
	}


	if(find_cmd("ea"))
	{
		main_erase=1;
		printf("## Action: chip erase\n");
	}

	if(find_cmd("ii"))
	{
		ignore_id=1;
		printf("## ignore device ID\n");
	}

	main_prog=check_cmd_prog("pm","main flash");
	main_verify=check_cmd_verify("vm","main flash");
	main_readout=check_cmd_read("rm","main flash",&main_prog,&main_verify);

	if(find_cmd("st"))
	{
		dev_start=1;
		printf("## Action: start device\n");
	}

	printf("\n");
	
	if(main_readout == 1)
	{
		errc=writeblock_open();
	}

	if(dev_start == 0)
	{
		errc=prg_comm(0xb4,0,2,0,ROFFSET,0,0,0,0);					//init & read ID
		if(memory[ROFFSET] !=param[10])
		{
			printf("ID READ = %02X      MUST BE= %02lX\n",memory[ROFFSET],param[10] & 0xff);
			if(ignore_id == 0)
			{
				errc=0x42;		
			}
			else
			{
				printf("IGNORING WRONG DEVICE ID\n");		
			}
		}
		
		//erase
		if((main_erase == 1) && (errc == 0))
		{
			printf("ERASE CHIP\n");
			errc=prg_comm(0xb5,0,0,0,0,0,0,0,0);						//erase
		}

		//program flash
		if((main_prog == 1) && (errc == 0))
		{
			bsize = max_blocksize;
			bsize=1024;
			flash_addr=param[0];
			flash_size=param[1];
			maddr=0;
			read_block(0,flash_size,flash_addr);
			
			if (flash_size < bsize) bsize = flash_size;
			blocks = flash_size / bsize;

//			printf("DAT= %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3]);

			progress("PROG FLASH ",blocks,0);
			addr=flash_addr;

			for(j=0;j<blocks;j++)
			{
				if(must_prog(maddr,bsize) & (errc == 0))
				{
//					printf("BLK : %06X LEN %04X\n",addr,bsize);
					errc=prg_comm(0xB6,bsize,0,maddr,0,
					addr & 0xff,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,0);
				}
				progress("PROG FLASH ",blocks,j+1);
				addr+=bsize;
				maddr+=bsize;
			}
			printf("\n");
		}


//		printf("ERRC = %02X\n",errc);

		//readout flash
		if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
		{
			bsize = max_blocksize;
			bsize=1024;
			flash_addr=param[0];
			flash_size=param[1];
			maddr=0;
			if (flash_size < bsize) bsize = flash_size;
			blocks = flash_size / bsize;

			progress("READ FLASH ",blocks,0);

			addr=flash_addr;

			for(j=0;j<blocks;j++)
			{
//				printf("BLK : %06X LEN %04X\n",addr,bsize);
				if (errc == 0) errc=prg_comm(0xB7,0,bsize,0,maddr+ROFFSET,
				addr & 0xff,			//LOW addr
				((addr >> 8) & 0xff) | 0x80,	//HIGH addr (upper 32K)
				(addr >> 15) & 0x07,		//32K bank
				0);
				progress("READ FLASH ",blocks,j+1);
				addr+=bsize;
				maddr+=bsize;
			}
			printf("\n");
		}

		if((main_verify == 1) && (errc == 0))
		{
			printf("VERIFY FLASH\n");
			flash_addr=param[0];
			flash_size=param[1];
			read_block(0,flash_size,flash_addr);

			for(j=0;j<flash_size;j++)
			{
				if(memory[j] != memory[j+ROFFSET])
				{
					printf("ERR -> ADDR= %06lX  DATA= %02X  READ= %02X\n",
					flash_addr+j,memory[j],memory[j+ROFFSET]);
					errc=1;
				}
			}
		}


		if((main_readout == 1) && (errc == 0))
		{
			printf("SAVE FLASH\n");
			writeblock_data(0,param[1],param[2]);
		}

	}

	if(main_readout == 1)
	{
		writeblock_close();
	}


	if(dev_start == 1)
	{
		prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
	}


	prg_comm(0x0f,0,0,0,0,0,0,0,0);				//exit
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_cc25xx_error(errc);

	return errc;
}
