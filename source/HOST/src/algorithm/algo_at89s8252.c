//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2012-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
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

void print_at89s8252_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",0);
				break;

		case 1:		set_error("VERIFY ERROR",1);
				break;

		case 0x7e:	set_error("(signature not match)",errc);
				break;

		case 0x41:	set_error("(no echo)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int prog_at89s8252(void)
{
	int errc,blocks,tblock,bsize,j;
	unsigned long addr,maddr;
	int chip_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int lock_prog=0;
	int dev_start=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5v -- set VDD to 5V\n");
		printf("-- ea -- chip erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");
		printf("-- pe -- eeprom program\n");
		printf("-- ve -- eeprom verify\n");
		printf("-- re -- eeprom readout\n");
		printf("-- lb -- set lock bits\n");
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

	if(find_cmd("st"))
	{
		dev_start=1;
		printf("## Action: start device\n");
	}


	main_prog=check_cmd_prog("pm","flash");
	eeprom_prog=check_cmd_prog("pe","eeprom");

	main_verify=check_cmd_verify("vm","flash");
	eeprom_verify=check_cmd_verify("ve","eeprom");

	main_readout=check_cmd_read("rm","flash",&main_prog,&main_verify);
	eeprom_readout=check_cmd_read("re","eeprom",&eeprom_prog,&eeprom_verify);


	if(find_cmd("lb")) 
	{
		if(have_expar < 1)
		{
			lock_prog = 0;
			printf("## Action: ext fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			lock_prog=1;
			have_expar=0;
			printf("## Action: ext fuse program with value 0x%02X\n",(int)(expar & 0xff));
		}
	}
	printf("\n");

	errc=0;

	if((main_readout || eeprom_readout) > 0)
	{
		errc=writeblock_open();
	}

	printf("INIT\n");
	errc=prg_comm(0x210,0,0,0,0,0,0,0,0x50);	//init


	if ((errc == 0) && (chip_erase == 1))
	{
		printf("CHIP ERASE\n");
		errc=prg_comm(0x212,0,0,0,0,0,0,0,0);	//mass erase
		
	}

	if ((errc == 0) && (lock_prog == 1))
	{
		printf("PROGRAM LOCK BITS\n");
		errc=prg_comm(0x217,0,0,0,0,(expar & 0xff),0,0,0);	//write lock bits
	}

	//program main
	if ((errc == 0) && (main_prog == 1))
	{
		read_block(param[0],param[1],0);		//get data
		bsize = max_blocksize;
		if(param[1]<bsize) bsize=param[1];
		addr=param[0];
		blocks=param[1]/bsize;
		maddr=0;

		progress("MAIN PROG   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize))
			{
				errc=prg_comm(0x213,bsize,0,maddr,0,addr & 0xff,(addr >> 8) & 0xff,bsize & 0xff,(bsize >> 8) & 0xff);
			}
			addr+=bsize;
			maddr+=bsize;
			progress("MAIN PROG   ",blocks,tblock+1);
		}
		printf("\n");
	}

	//read / verify main
	if ((errc == 0) && ((main_verify == 1) || (main_readout == 1)) && (param[1] > 0))
	{
		bsize = max_blocksize;
		if(param[1]<bsize) bsize=param[1];
		addr=param[0];
		blocks=param[1]/bsize;
		maddr=0;

		progress("MAIN READ   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			errc=prg_comm(0x214,0,bsize,0,maddr+ROFFSET,addr & 0xff,(addr >> 8) & 0xff,bsize & 0xff,(bsize >> 8) & 0xff);
			addr+=bsize;
			maddr+=bsize;
			progress("MAIN READ   ",blocks,tblock+1);
		}
		printf("\n");
	}

	if((main_verify == 1) && (errc == 0))
	{
		read_block(param[0],param[1],0);
		addr = param[0];
		for(j=0;j<param[1];j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %06lX  DATA= %02X  READ= %02X\n",
				addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((main_readout==1) && (errc==0))
	{
		writeblock_data(0,param[1],param[0]);
	}

	//program eeprom
	if ((errc == 0) && (eeprom_prog == 1))
	{
		read_block(param[2],param[3],0);
		bsize = max_blocksize;
		if(param[3]<bsize) bsize=param[3];
		addr=param[2];
		blocks=param[3]/bsize;
		maddr=0;

		progress("EEPROM PROG ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize))
			{
				errc=prg_comm(0x215,bsize,0,maddr,0,addr & 0xff,(addr >> 8) & 0xff,bsize & 0xff,(bsize >> 8) & 0xff);
			}
			addr+=bsize;
			maddr+=bsize;
			progress("EEPROM PROG ",blocks,tblock+1);
		}
		printf("\n");
	}

	//verify and readout eeprom
	if ((errc == 0) && ((eeprom_verify == 1) || (eeprom_readout == 1)) && (param[3] > 0))
	{
		bsize = max_blocksize;
		if(param[3]<bsize) bsize=param[3];
		addr=param[2];
		blocks=(param[3]+bsize-1)/bsize;
		maddr=0;

		progress("EEPROM READ ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			errc=prg_comm(0x216,0,bsize,0,maddr+ROFFSET,addr & 0xff,(addr >> 8) & 0xff,bsize & 0xff,(bsize >> 8) & 0xff);
			addr+=bsize;
			maddr+=bsize;
			progress("EEPROM_READ ",blocks,tblock+1);
		}
		printf("\n");
	}

	if((eeprom_verify == 1) && (errc == 0))
	{
		read_block(param[2],param[3],0);
		addr = param[2];
		for(j=0;j<param[3];j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",
				addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((eeprom_readout==1) && (errc==0))
	{
		writeblock_data(0,param[3],param[2]);
	}


	if((main_readout || eeprom_readout) > 0)
	{
		writeblock_close();
	}

	if(dev_start == 1)
	{
		if(errc == 0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
	}

	prg_comm(0x0d,0,0,0,0,0,0,0,0);		//exit
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_at89s8252_error(errc);

	return errc;
}



