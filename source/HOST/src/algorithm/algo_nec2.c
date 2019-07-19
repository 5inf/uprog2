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
	int errc,blocks,tblock,bsize,eblock=0;
	unsigned long addr,maddr;
	int chip_erase=0;
	int main_blank=0;
	int main_prog=0;
	int main_verify=0;
	int dflash_prog=0;
	int dflash_verify=0;
	int dev_start=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- ea -- chip erase\n");
		printf("-- ba -- blank check\n");

		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");

		printf("-- pd -- data flash program\n");
		printf("-- vd -- data flash verify\n");

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

	main_prog=check_cmd_prog("pm","code flash");
	dflash_prog=check_cmd_prog("pd","data flash");

	main_verify=check_cmd_verify("vm","code flash");
	dflash_verify=check_cmd_verify("vd","data flash");

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
	

	//erase
	if ((errc == 0) && (chip_erase == 1))	//unlock
	{
		printf("CHIP ERASE\n");
		errc=prg_comm(0x61,0,00,0,0,0,0,0,0);	//program
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

	//program dflash
	if ((errc == 0) && (dflash_prog == 1))
	{
		read_block(param[2],param[3],0);
		bsize = max_blocksize;
		addr=param[2];
		blocks=param[3]/bsize;
		maddr=0;

		progress("DATA PROG   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			progress("DATA PROG   ",blocks,tblock+1);
			if(errc == 0)
			{
				errc=prg_comm(0x63,bsize,0,maddr,0,
					(addr >> 8) & 0xff,(addr >> 16) & 0xff,0,0);	//program
				eblock=tblock;
				addr+=bsize;
				maddr+=bsize;
			}
		}
		printf("\n");
	}

	//verify dflash
	if ((errc == 0) && (dflash_verify == 1))
	{
		read_block(param[2],param[3],0);
		bsize = max_blocksize;
		addr=param[2];
		blocks=param[3]/bsize;
		maddr=0;

		progress("DATA VERIFY ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			progress("DATA VERIFY ",blocks,tblock+1);
			if(errc == 0)
			{
				errc=prg_comm(0x64,bsize,0,maddr,0,
					(addr >> 8) & 0xff,(addr >> 16) & 0xff,0,0);	//verify
				eblock=tblock;
				addr+=bsize;
				maddr+=bsize;
			}
		}
		printf("\n");
	}

	if(dev_start == 1)
	{
		if(errc == 0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
	}

	prg_comm(0x65,0,0,0,0,8,0,0,0);	//exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_nec2_error(errc,eblock*1024);

	return errc;
}






