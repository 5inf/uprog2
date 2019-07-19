//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2010-2015 Joerg Wolfram (joerg@jcwolfram.de)			#
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

void print_st7f_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x21:	set_error("(Timeout)",errc);
				break;

		case 0x22:	set_error("(SYNC pulse too long)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_st7f(void)
{
	int errc,blocks,bsize,j;
	unsigned long faddr,fsize,maddr;
	int unsecure = 0;
	int secure = 0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dev_start=0;
	int run_ram=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int option_prog=0;
	int option_readout=0;
	int extclock=0;

	errc=0;


	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- xc -- use external clock\n");
		
		printf("-- se -- secure device\n");
		printf("-- un -- unsecure device\n");

		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		printf("-- ee -- eeprom erase\n");
		printf("-- pe -- eeprom program\n");
		printf("-- ve -- eeprom verify\n");
		printf("-- re -- eeprom readout\n");

		printf("-- eo -- option bytes erase\n");
		printf("-- po -- option bytes program\n");
		printf("-- vo -- option bytes verify\n");
		printf("-- ro -- option bytes readout\n");

		printf("-- rr -- run code in RAM\n");
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



	if(find_cmd("xc"))
	{
		extclock=1;
		printf(">> use external clock\n");
	}


	if(find_cmd("un"))
	{
		unsecure=1;
		printf("## Action: remove ROP\n");
	}

	if(find_cmd("se"))
	{
		secure=1;
		printf("## Action: activate ROP\n");
	}

	if(find_cmd("rr"))
	{
		if(file_found < 2)
		{
			run_ram = 0;
			printf("## Action: run code in RAM !! DISABLED BECAUSE OF NO FILE !!\n");
		}
		else
		{
			run_ram=1;
			printf("## Action: run code in RAM using %s\n",sfile);
		}
	}
	else
	{


		main_prog=check_cmd_prog("pm","code flash");
		eeprom_prog=check_cmd_prog("pe","data flash");
		option_prog=check_cmd_prog("po","shadow flash");

		main_verify=check_cmd_verify("vm","code flash");
		eeprom_verify=check_cmd_verify("ve","data flash");

		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
		eeprom_readout=check_cmd_read("re","data flash",&eeprom_prog,&eeprom_verify);
		option_readout=check_cmd_read("ro","shadow flash",&option_prog,&option_prog);

		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}

	printf("\n");
	
	if((main_readout || eeprom_readout) > 9)
	{
		errc=writeblock_open();
	}
	
	errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);	//enable pull-up


	if(dev_start == 0)
	{
		printf("icc interface init\n");
		if(extclock==0)
		{
			errc=prg_comm(0x5a,0,0,0,0,0,0,0,38);					//ICC init intern clock
		}
		else
		{
			errc=prg_comm(0x5a,0,0,0,0,0,0,0,35);					//ICC init extern clock
		}
	}

	if((run_ram == 0) && (dev_start == 0))
	{
		printf("SEND BOOTLOADER\n");
		errc=prg_comm(0x84,0,0,0,0,0,0,0,0);			//transfer and start boot code
//		if(errc == 0) printf("\nPRESS ENTER TO CONT \n");
//		if(errc == 0) getchar();
	}


	//unsecure
	if((unsecure == 1) && (errc == 0))
	{
		printf("REMOVE ROP\n");
		errc=prg_comm(0x88,0,0,0,0,0x00,0xfa,0xfc,0xef);
		waitkey();
	}

	//secure
	if((secure == 1) && (errc == 0))
	{
		printf("ACTIVATE ROP\n");
		errc=prg_comm(0x88,0,0,0,0,0x00,0xfa,0xaf,0xfe);
	}

	//program main flash
	if((main_prog == 1) && (errc == 0))
	{
		read_block(param[0],param[1],0);
		bsize = 512;
		faddr=param[0];		//addr
		blocks=param[1]/512;		//512-bytes blocks
		maddr=0;

		progress("PROG FLASH  ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			errc=prg_comm(0x85,bsize,0,maddr,0,(faddr & 0xff),(faddr >> 8),16,0);
			progress("PROG FLASH  ",blocks,j+1);
			faddr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	//readout main flash
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		bsize = 512;
		faddr=param[0];		//addr
		blocks=param[1]/512;		//512-bytes blocks
		maddr=0;

		progress("READ FLASH  ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			errc=prg_comm(0x86,0,bsize,0,maddr+ROFFSET,(faddr & 0xff),(faddr >> 8),16,0);
			progress("READ FLASH  ",blocks,j+1);
			faddr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	if((main_verify == 1) && (errc == 0))
	{
		read_block(param[0],param[1],0);
		faddr=param[0];		//addr
		fsize=param[1];		//bytes
		
		printf("VERIFY FLASH\n");
		for(j=0;j<fsize;j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",
				faddr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((main_readout == 1) && (errc == 0))
	{
		printf("SAVE FLASH\n");
		writeblock_data(0,param[1],param[0]);
	}


	//program eeprom
	if((eeprom_prog == 1) && (errc == 0))
	{
		read_block(param[2],param[3],0);
		bsize = 128;
		faddr=param[2];		//addr
		blocks=param[3]/bsize;		//128-bytes blocks
		maddr=0;

		progress("PROG EEPROM ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			errc=prg_comm(0x87,bsize,0,maddr,0,(faddr & 0xff),(faddr >> 8),4,0);
			progress("PROG EEPROM ",blocks,j+1);
			faddr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	//readout eeprom
	if(((eeprom_readout == 1) || (eeprom_verify == 1)) && (errc == 0))
	{
		bsize = 128;
		faddr=param[2];		//addr
		blocks=param[3]/bsize;		//512-bytes blocks
		maddr=0;

		progress("READ EEPROM ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			errc=prg_comm(0x86,0,bsize,0,faddr+ROFFSET,(faddr & 0xff),(faddr >> 8),4,0);
			progress("READ EEPROM ",blocks,j+1);
			faddr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	if((eeprom_verify == 1) && (errc == 0))
	{
		read_block(param[2],param[3],0);
		faddr=param[2];		//addr
		fsize=param[3];		//bytes
		
		printf("VERIFY EEPROM\n");
		for(j=0;j<fsize;j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",
				faddr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((eeprom_readout == 1) && (errc == 0))
	{
		printf("SAVE EEPROM\n");
		writeblock_data(0,param[3],param[2]);
	}


	//program option bytes
	if((option_prog == 1) && (errc == 0))
	{
		printf("PROGRAM OPTION BYTES\n");
//		printf("Option byte 0 = 0x%02X\n",expar & 0xff);
//		printf("Option byte 1 = 0x%02X\n",expar >> 8);
		faddr=param[0];		//addr
		errc=prg_comm(0x88,0,32,0,0x2000,(faddr & 0xff),(faddr >> 8),expar & 0xff,expar >> 8);
	}


	//readout option bytes
	if((option_readout == 1) && (errc == 0))
	{
		printf("READOUT OPTION BYTES\n");
		faddr=param[0];		//addr
		errc=prg_comm(0x89,0,32,0,0x2000,(faddr & 0xff),(faddr >> 8),1,0);
		printf("Option byte 0 = 0x%02X\n",memory[0x2000]);
		printf("Option byte 1 = 0x%02X\n",memory[0x2001]);
	}

	if((run_ram == 1) && (errc == 0))
	{
		read_block(param[8],param[9],0);
		printf("TRANSFER & START CODE\n");
		printf("data: %02X %02X %02X %02X\n",memory[0xfc],memory[0xfd],memory[0xfe],memory[0xff]);

		errc=prg_comm(0x5c,256,0,0x84,0,0x84,0,0x7c,0);				//write and exec
		if(errc == 0) waitkey();
	}

	if((main_readout || eeprom_readout) > 9)
	{
		writeblock_close();
	}

	if(dev_start == 1)
	{
		prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
		prg_comm(0x0f,0,0,0,0,0,0,0,0);					//exit
	}


	prg_comm(0x5b,0,0,0,0,0,0,0,0);					//SWIM exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_st7f_error(errc);

	return errc;
}







