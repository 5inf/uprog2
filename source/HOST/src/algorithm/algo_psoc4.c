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

void print_psoc4_error(int errc)
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

		case 0x43:	set_error("(Device is Protected)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_psoc4(void)
{
	int errc,blocks,bsize,j;
	unsigned long addr,flash_addr,flash_size,sid,row,maddr,idval;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dev_start=0;
	int unprot = 0;
	int protect=0;

	errc=0;


	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- ea -- chip erase\n");
		printf("-- un -- un-protect device\n");
		printf("-- pr -- protect device\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");
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
		printf("## Action: erase chip\n");
	}

	if(find_cmd("un"))
	{
		unprot=1;
		printf("## Action: un-protect chip\n");
	}

	if(find_cmd("pr"))
	{
		protect=1;
		printf("## Action: protect chip\n");
	}

	main_prog=check_cmd_prog("pm","code flash");
	main_verify=check_cmd_verify("vm","code flash");
	main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);

	if(find_cmd("st"))
	{
		dev_start=1;
		printf("## Action: start device\n");
	}

	printf("\n");

	if(main_readout > 0)
	{
		errc=writeblock_open();
	}

	if(dev_start == 0)
	{
		printf("MODE     = %lu\n",param[13] & 0xff);
		errc=prg_comm(0xb8,0,4,0,ROFFSET,0,0,0,param[13] & 0xff);				//init & read ID
		if(errc == 0)
		{
			idval=memory[ROFFSET]+(memory[ROFFSET+1] << 8)+(memory[ROFFSET+2] << 16)+(memory[ROFFSET+3] << 24);
			if(idval != param[11])
			{
				printf("JID READ = %08lX     MUST BE= %08lX\n",idval,param[11]);
			}
			else
			{
				printf("JID READ = %08lX -> OK\n",idval);
			}			
		}
		else
		{
			printf("STATUS = %02X       MUST BE= 01\n",memory[ROFFSET]);
		}

		errc=prg_comm(0xb9,0,5,0,ROFFSET,0,0,0,0);				//read silicon ID + prot status
		if(errc == 0)
		{
			sid=memory[ROFFSET+3]+(memory[ROFFSET+2] << 8)+	(memory[ROFFSET+1] << 16)+(memory[ROFFSET+0] << 24);
			if(sid != param[10])
			{
				printf("SID READ = %08lX     MUST BE= %08lX\n",sid,param[10]);
			}
			else
			{
				printf("SID READ = %08lX -> OK\n",sid);
			}
			printf("PROTECT  = %02X (",memory[ROFFSET+4]);
			switch(memory[ROFFSET+4])
			{
				case 00:	printf("VIRGIN)\n");
						break;
				case 01:	printf("OPEN)\n");
						break;
				case 02:	printf("PROTECTED)\n");
						errc=0x43;
						break;
				case 03:	printf("KILL)\n");
						errc=0x43;
						break;
				default:	printf("UNDEF)\n");
			}
		}
		else
		{
			printf("STATUS = %02X       MUST BE= 01\n",memory[ROFFSET]);
		}

		//erase
		if((main_erase == 1) && (errc == 0))
		{
			printf("ERASE CHIP\n");
			errc=prg_comm(0xbb,0,0,0,0,0,0,0,0);						//erase
		}

		//program flash
		if((main_prog == 1) && (errc == 0))
		{
			read_block(param[0],param[1],0);
			bsize = max_blocksize;
			flash_addr=param[0];
			flash_size=param[1];
			if (flash_size < bsize) bsize = flash_size;
			blocks = flash_size / bsize;
			maddr=0;

//			printf("DAT= %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3]);

			progress("PROG FLASH ",blocks,0);
			addr=flash_addr;
			row=0;

			for(j=0;j<blocks;j++)
			{
//				printf("BLK : %06X LEN %04X\n",addr,bsize);
				if (errc == 0) errc=prg_comm(0xbd,bsize,0,maddr,0,
				0,0,
				(row) & 0xff,
				(row >> 8) & 0xff);
				progress("PROG FLASH ",blocks,j+1);
				addr+=bsize;
				maddr+=bsize;
				row+=(bsize / 128);
			}
			printf("\n");
		}

//		printf("ERRC = %02X\n",errc);

		//readout flash
		if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
		{
			bsize = max_blocksize;
			flash_addr=param[0];
			flash_size=param[1];
			if (flash_size < bsize) bsize = flash_size;
			blocks = flash_size / bsize;
			maddr=0;
	
			progress("READ FLASH ",blocks,0);

			addr=flash_addr;

			for(j=0;j<blocks;j++)
			{
				if (errc == 0) 
				{
//					printf("BLK : %08X LEN %04X\n",addr,bsize);
					errc=prg_comm(0xbc,0,bsize,0,maddr+ROFFSET,
					addr & 0xff,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 24) & 0xff);
					progress("READ FLASH ",blocks,j+1);
					addr+=bsize;
					maddr+=bsize;
				}
			}
			printf("\n");
		}

		if((main_verify == 1) && (errc == 0))
		{
			read_block(param[0],param[1],0);
			flash_addr=param[0];
			flash_size=param[1];
			printf("VERIFY FLASH\n");
			for(j=0;j<flash_size;j++)
			{
				if(memory[j] != memory[j+ROFFSET])
				{
					printf("ERR -> ADDR= %04lX  DATA= %02hhX  READ= %02hhX\n",
					flash_addr+j,memory[j],memory[j+ROFFSET]);
					errc=1;
				}
			}
		}


		if((main_readout == 1) && (errc == 0))
		{
			printf("SAVE FLASH\n");
			writeblock_data(0,param[1],param[0]);
		}
	}

	if(main_readout > 0)
	{
		writeblock_close();
	}


	if(protect == 1)
	{
		printf("PROTECT DEVICE...\n");
		errc=prg_comm(0xc5,0,0,0,0,0,0,0,0);					//protect	
	}


	if(unprot == 1)
	{
		printf("UNPROTECT DEVICE...\n");
		errc=prg_comm(0xba,0,0,0,0,0,0,0,0);					//protect	
	}

	if(dev_start == 1)
	{
		prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
	}


	prg_comm(0x0f,0,0,0,0,0,0,0,0);				//exit

	if(errc > 0x8f)
	{
		printf("STATUS = %02X       MUST BE= 01\n",memory[ROFFSET]);
	}

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_psoc4_error(errc);
	return errc;
}





