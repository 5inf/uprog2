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
#include "exec/78k0r_dump/N78k0r-dump-dflash.h"
#include "exec/78k0r_fdump/N78k0r-dump-flash.h"

void print_nec2_error(int errc,unsigned long addr)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(TIMEOUT at SYNC)",errc);
				break;

		case 0x42:	set_error("(wrong sync)",errc);
				break;

		case 0x43:	set_error("(TIMEOUT RESET)",errc);
				break;

		case 0x40:	set_error("(WRONG answer)",errc);
				break;

		case 0x45:	set_error2("(TIMEOUT ACK)",errc,addr);
				break;

		case 0x46:	set_error2("(NO ACK)",errc,addr);
				break;

		case 0x47:	set_error2("(VERIFY FAILED)",errc,addr);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int prog_nec2(void)
{
	int j,errc,blocks,tblock,bsize,eblock=0;
	unsigned long addr,maddr;
	int chip_erase=0;
	int main_blank=0;
	int main_prog=0;
	int main_verify=0;
	int dev_start=0;
	int main_dump=0;
	int dflash_dump=0;



	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- ea -- chip erase\n");
		printf("-- ba -- blank check\n");

		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- dm -- main flash dump (will erase first 2K of main)\n");
		printf("-- dd -- data flash dump (will erase first 2K of main)\n");

		printf("-- st -- start device\n");
		printf("-- d2 -- switch to device 2\n");
		
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

	if(find_cmd("ea"))
	{
		chip_erase=1;
		printf("## Action: chip erase\n");
	}

	if(find_cmd("ba"))
	{
		main_blank=1;
		printf("## Action: blank check\n");
	}

	if(find_cmd("dm"))
	{
		main_dump=1;
		printf("## Action: main flash dump\n");
		goto ONLY_DD;	
	}

	if(find_cmd("dd"))
	{
		dflash_dump=1;
		printf("## Action: data flash dump\n");
		goto ONLY_DD;	
	}


	main_prog=check_cmd_prog("pm","code flash");
	main_verify=check_cmd_verify("vm","code flash");

ONLY_DD:

	if(find_cmd("st"))
	{
		dev_start=1;
		printf("## Action: start device\n");
	}

	printf("\n");
	
	errc=0;

	if(dev_start == 0)
	{
		printf("INIT\n");
		prg_comm(0xfe,0,0,0,0,3,3,0,0);	//enable PU		
		prg_comm(0x65,0,0,0,0,0,0,0,0);	//exit
		usleep(100);
		errc=prg_comm(0x60,0,0,0,0,0,0,0,0);	//init
	}
	
	//mass erase
	if ((errc == 0) && (chip_erase == 1))	//unlock
	{
		printf("CHIP ERASE\n");
		errc=prg_comm(0x61,0,00,0,0,0,0,0,0);	//program
	}

	//block erase
	if ((errc == 0) && ((main_dump == 1) || (dflash_dump == 1)))	//unlock
	{
		printf("DUMP AREA ERASE\n");
		errc=prg_comm(0x62,0,00,0,0,0,0,0,0);	//first 1k block
		errc=prg_comm(0x62,0,00,0,0,4,0,0,0);	//second 1k block
	}

	//blank check
	if ((errc == 0) && (main_blank == 1))	//unlock
	{
		printf("BLANK CHECK\n");
		errc=prg_comm(0x27,0,40,0,0,0,0,0,0);	//check ID
		if(errc > 9) printf("ST= %02X %02X %02X %02X\n",memory[32],memory[33],memory[34],memory[35]);
	}

	//program main
	if ((errc == 0) && (main_prog == 1))
	{
		read_block(param[0],param[1],0);
		bsize = max_blocksize;
		addr=param[0];
		blocks=param[1]/bsize;
		maddr=0;

		progress("MAIN PROG   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if((errc == 0) && (must_prog(maddr,bsize)))
			{
				errc=prg_comm(0x63,bsize,0,maddr,0,
				(addr >> 8) & 0xff,(addr >> 16) & 0xff,0,0);	//program
				eblock=tblock;
			}
			addr+=bsize;
			maddr+=bsize;
			progress("MAIN PROG   ",blocks,tblock+1);
		}
		printf("\n");
	}

	//verify main
	if ((errc == 0) && (main_verify == 1))
	{
		read_block(param[0],param[1],0);
		bsize = max_blocksize;
		addr=param[0];
		blocks=param[1]/bsize;
		maddr=0;

		printf("ST= %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3]);

		progress("MAIN VERIFY ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			progress("MAIN VERIFY ",blocks,tblock+1);
			//if(errc == 0)
			{
				errc=prg_comm(0x64,bsize,0,maddr,0,
					(addr >> 8) & 0xff,(addr >> 16) & 0xff,0,0);	//verify
				eblock=tblock;
				addr+=bsize;
				maddr+=bsize;
			}
			if(errc !=0)
			{
				printf("ERR at %05lX\n",addr-bsize);
			}
		}
		printf("\n");
	}

	//program dumper
	if ((errc == 0) && (dflash_dump == 1))
	{
		bsize = 2048;
		if(bsize > param[1]) bsize=param[1];
		addr=param[0];
		blocks=1;
		maddr=0;

		for(j=0;j<2048;j++)
		{
			memory[j] = N78k0r_dump[j];
		}

		progress("DUMP PROG   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if((must_prog(maddr,bsize)) && (errc == 0))
			{
				//printf("ADDR = %08lX\n",addr);
				errc=prg_comm(0x63,bsize,7,maddr,0,
					(addr >> 8) & 0xff,(addr >> 16) & 0xff,0,0);	//program
				if(errc!=0) 
				{
					printf("RESP = %02X %02X %02X %02X %02X\n",memory[2],memory[3],memory[4],memory[5],memory[6]);		
				}
			}
			maddr+=bsize;
			addr+=bsize;
			progress("DUMP PROG   ",blocks,tblock+1);
		}
		printf("\n");
	}

	//program dumper
	if ((errc == 0) && (main_dump == 1))
	{
		bsize = 2048;
		if(bsize > param[1]) bsize=param[1];
		addr=param[0];
		blocks=1;
		maddr=0;

		for(j=0;j<2048;j++)
		{
			memory[j] = N78k0r_fdump[j];
		}

		progress("DUMP PROG   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if((must_prog(maddr,bsize)) && (errc == 0))
			{
				//printf("ADDR = %08lX\n",addr);
				errc=prg_comm(0x63,bsize,7,maddr,0,
					(addr >> 8) & 0xff,(addr >> 16) & 0xff,0,0);	//program
				if(errc!=0) 
				{
					printf("RESP = %02X %02X %02X %02X %02X\n",memory[2],memory[3],memory[4],memory[5],memory[6]);		
				}
			}
			maddr+=bsize;
			addr+=bsize;
			progress("DUMP PROG   ",blocks,tblock+1);
		}
		printf("\n");
	}


	if(dev_start == 1)
	{
		if(errc == 0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
	}

	prg_comm(0x65,0,0,0,0,8,0,0,0);	//exit

	if ((errc == 0) && (dflash_dump == 1))
	{
		bsize=2048;
		sleep(1);
		errc=writeblock_open();
		if(errc == 0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		maddr=0;
		blocks=param[3]/bsize;

		sleep(1);
		
		progress("READ DUMP   ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			errc=prg_comm(0x193,0,bsize,0,ROFFSET+maddr,0,0,0,0);
			maddr+=bsize;
			progress("READ DUMP   ",blocks,j+1);
		}
		writeblock_data(0,param[3],param[2]);
		writeblock_close();
		prg_comm(0x65,0,0,0,0,8,0,0,0);	//exit
	}


	if ((errc == 0) && (main_dump == 1))
	{
		bsize=2048;
		sleep(1);
		errc=writeblock_open();
		if(errc == 0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		maddr=0;
		blocks=param[1]/bsize;

		sleep(1);
		
		progress("READ DUMP   ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			errc=prg_comm(0x193,0,bsize,0,ROFFSET+maddr,0,0,0,0);
			maddr+=bsize;
			progress("READ DUMP   ",blocks,j+1);
		}
		writeblock_data(0,param[1],param[0]);
		writeblock_close();
		prg_comm(0x65,0,0,0,0,8,0,0,0);	//exit
	}



	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_nec2_error(errc,eblock*1024);

	return errc;
}





