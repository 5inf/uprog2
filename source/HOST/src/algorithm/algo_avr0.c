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

void print_avr0_error(int errc,unsigned long addr)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",0);
				break;

		case 0x41:	set_error("TIMEOUT",1);
				break;

		case 0x45:	set_error("PROTECTED",1);
				break;

		default:	set_error("(undefined error)",errc);
	}
	print_error();
}

int prog_avr0(void)
{
	int errc,blocks,tblock,bsize,j,eblock=0,tbyte;
	int pagesize,wpp;
	unsigned long addr,maddr;
	int chip_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int user_prog=0;
	int user_verify=0;
	int user_readout=0;
	int user_blind=0;
	int fuse_prog=0;
	int dev_start=0;
	int ignore_devid=0;
	int eep_erase=0;
	int rst_pulse=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5v      -- set VDD to 5V\n");
		printf("-- ea      -- chip erase\n");
		printf("-- pm      -- main flash program\n");
		printf("-- vm      -- main flash verify\n");
		printf("-- rm      -- main flash readout\n");
		printf("-- ee      -- eeprom erase\n");
		printf("-- pe      -- eeprom program\n");
		printf("-- ve      -- eeprom verify\n");
		printf("-- re      -- eeprom readout\n");
		printf("-- pu      -- user row program\n");
		printf("-- pb      -- blind user row program\n");
		printf("-- vu      -- user row verify\n");
		printf("-- ru      -- user row readout\n");
		printf("-- pf      -- program fuse (addr offset, value)\n");
		printf("-- WDTCFG  -- program fuse\n");
		printf("-- BODCFG  -- program fuse\n");
		printf("-- OSCCFG  -- program fuse\n");
		
		if(param[13] & 1)		
			printf("-- TCD0CFG -- program fuse\n");

		printf("-- SYSCFG0 -- program fuse\n");
		printf("-- SYSCFG1 -- program fuse\n");
		printf("-- APPEND  -- program fuse\n");
		printf("-- BOOTEND -- program fuse\n");
		printf("-- LOCKBIT -- program fuse\n");
		printf("-- st      -- start device\n");
		printf("-- ii      -- ignore wrong ID\n");
		printf("-- p12v    -- use 12V pulse\n");
		return 0;
	}


	if(find_cmd("5v"))
	{
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		printf("## using 5V VDD\n");
	}

	if((find_cmd("p12v")) && (param[7] > 0))
	{
		printf("## usie 12V pulse on RESET/UPDI\n");
		rst_pulse=1;
	}

	if(find_cmd("ii"))
	{
		ignore_devid=1;
		printf("## Ignore device ID\n");
	}


	if(find_cmd("WDTCFG"))
	{
		if(have_expar < 1) 
		{
			fuse_prog = 0;
			printf("## Action: fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			fuse_prog=1;
			expar2=expar & 0xff;
			expar=0;
			printf("## Action: fuse (%01X) program with value 0x%02X\n",(int)(expar & 0x0f),(int)(expar2 & 0xff));
			goto AVR0_NCMD;
		}
	}

	if(find_cmd("BODCFG"))
	{
		if(have_expar < 1) 
		{
			fuse_prog = 0;
			printf("## Action: fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			fuse_prog=1;
			expar2=expar & 0xff;
			expar=1;
			printf("## Action: fuse (%01X) program with value 0x%02X\n",(int)(expar & 0x0f),(int)(expar2 & 0xff));
			goto AVR0_NCMD;
		}
	}


	if(find_cmd("OSCCFG"))
	{
		if(have_expar < 1) 
		{
			fuse_prog = 0;
			printf("## Action: fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			fuse_prog=1;
			expar2=expar & 0x83;
			expar=2;
			printf("## Action: fuse (%01X) program with value 0x%02X\n",(int)(expar & 0x0f),(int)(expar2 & 0xff));
			goto AVR0_NCMD;
		}
	}

	if((param[13] & 1) && (find_cmd("TCD0CFG")))		
	{
		if(have_expar < 1) 
		{
			fuse_prog = 0;
			printf("## Action: fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			fuse_prog=1;
			expar2=expar & 0xFF;
			expar=4;
			printf("## Action: fuse (%01X) program with value 0x%02X\n",(int)(expar & 0x0f),(int)(expar2 & 0xff));
			goto AVR0_NCMD;
		}
	}

	if(find_cmd("SYSCFG0"))
	{
		if(have_expar < 1) 
		{
			fuse_prog = 0;
			printf("## Action: fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			fuse_prog=1;
			expar2=expar & 0xc9;
			expar=5;
			printf("## Action: fuse (%01X) program with value 0x%02X\n",(int)(expar & 0x0f),(int)(expar2 & 0xff));
			goto AVR0_NCMD;
		}
	}


	if(find_cmd("SYSCFG1"))
	{
		if(have_expar < 1) 
		{
			fuse_prog = 0;
			printf("## Action: fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			fuse_prog=1;
			expar2=expar & 0x07;
			expar=6;
			printf("## Action: fuse (%01X) program with value 0x%02X\n",(int)(expar & 0x0f),(int)(expar2 & 0xff));
			goto AVR0_NCMD;
		}
	}


	if(find_cmd("APPEND"))
	{
		if(have_expar < 1) 
		{
			fuse_prog = 0;
			printf("## Action: fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			fuse_prog=1;
			expar2=expar & 0xFF;
			expar=7;
			printf("## Action: fuse (%01X) program with value 0x%02X\n",(int)(expar & 0x0f),(int)(expar2 & 0xff));
			goto AVR0_NCMD;
		}
	}


	if(find_cmd("BOOTEND"))
	{
		if(have_expar < 1) 
		{
			fuse_prog = 0;
			printf("## Action: fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			fuse_prog=1;
			expar2=expar & 0xFF;
			expar=8;
			printf("## Action: fuse (%01X) program with value 0x%02X\n",(int)(expar & 0x0f),(int)(expar2 & 0xff));
			goto AVR0_NCMD;
		}
	}

	if(find_cmd("LOCKBIT"))
	{
		if(have_expar < 1) 
		{
			fuse_prog = 0;
			printf("## Action: fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			fuse_prog=1;
			expar2=expar;
			expar=10;
			printf("## Action: fuse (%01X) program with value 0x%02X\n",(int)(expar & 0x0f),(int)(expar2 & 0xff));
			goto AVR0_NCMD;
		}
	}


	if(find_cmd("pf"))
	{
		if((have_expar < 1) | (have_expar2 < 1)) 
		{
			fuse_prog = 0;
			printf("## Action: low fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			fuse_prog=1;
			have_expar=0;
			printf("## Action: fuse (%01X) program with value 0x%02X\n",(int)(expar & 0x0f),(int)(expar2 & 0xff));
			goto AVR0_NCMD;
		}
	}


	if(find_cmd("ea"))
	{
		chip_erase=1;
		printf("## Action: chip erase\n");
	}

	if(find_cmd("ee"))
	{
		eep_erase=1;
		printf("## Action: EEPROM erase\n");
	}

	if(find_cmd("st"))
	{
		dev_start=1;
		printf("## Action: start device\n");
	}


	main_prog=check_cmd_prog("pm","flash");
	eeprom_prog=check_cmd_prog("pe","eeprom");
	user_prog=check_cmd_prog("pu","user row");
	user_blind=check_cmd_prog("pb","user row (blind)");

	main_verify=check_cmd_verify("vm","flash");
	eeprom_verify=check_cmd_verify("ve","eeprom");
	user_verify=check_cmd_verify("vu","user row");

	main_readout=check_cmd_read("rm","flash",&main_prog,&main_verify);
	eeprom_readout=check_cmd_read("re","eeprom",&eeprom_prog,&eeprom_verify);
	user_readout=check_cmd_read("ru","user row",&user_prog,&user_verify);


AVR0_NCMD:

	printf("\n");

	errc=0;

	if((main_readout || eeprom_readout || user_readout) > 0)
	{
		errc=writeblock_open();
	}

	printf("INIT\n");
	
	if(param[7] > 0)
	{
		printf("VPP = %d\n",(int)param[7]);
		errc=prg_comm(0xf5,0,0,0,0,0,0,0,0);		//VPP off
		errc=prg_comm(0xf2,0,0,0,0,param[7],0,0,0);	//SET VPP
		usleep(1000);
		errc=prg_comm(0xf2,0,0,0,0,param[7],0,0,0);	//SET VPP
	}

	errc=prg_comm(0x01d8,0,16,0,0,0,0,0,rst_pulse);	//INIT

	if ((errc == 0) && ((chip_erase + user_blind) == 0))
	{
		printf("READ ID & FUSES\n");
		errc=prg_comm(0x01d6,0,16,0,0,param[12] & 0xff,(param[12] >> 8) & 0xff,param[11] & 0xff,(param[11] >> 8) & 0xff);	//read ID

		if(errc > 0)
		{
			printf("!!! DEVICE IS PROTECTED !!\n");
			goto AVR0_EXIT;
		}

		tbyte=(param[10] >> 16) & 0xff;
		printf("  SIGNATURE  = %02X %02X %02X\n",memory[0],memory[1],memory[2]);
		
		if (memory[0] != tbyte) 
		{
			errc = 0x7e;
			printf("  Signature 0x00 = 0x%02X    Expected 0x%02X\n",memory[0],tbyte);
		}

		tbyte=(param[10] >> 8) & 0xff;
		if (memory[1] != tbyte) 
		{
			errc = 0x7e;
			printf("  Signature 0x01 = 0x%02X    Expected 0x%02X\n",memory[1],tbyte);
		}

		tbyte=param[10] & 0xff;
		if (memory[2] != tbyte) 
		{
			errc = 0x7e;
			printf("  Signature 0x02 = 0x%02X    Expected 0x%02X\n",memory[2],tbyte);
		}

		printf("  WDTCFG     = 0x%02X\n",memory[3]);
		printf("  BODCFG     = 0x%02X\n",memory[4]);
		printf("  OSCCFG     = 0x%02X\n",memory[5]);
		if (param[13] & 1)
		printf("  TCD0CFG    = 0x%02X\n",memory[7]);
		printf("  SYSCFG0    = 0x%02X\n",memory[8]);
		printf("  SYSCFG1    = 0x%02X\n",memory[9]);
		printf("  APPEND     = 0x%02X\n",memory[10]);
		printf("  BOOTEND    = 0x%02X\n",memory[11]);
		printf("  LOCKBIT    = 0x%02X\n\n",memory[13]);

		if(errc == 0x7e)
		{
			printf("!! ID bytes not matching %s\n",name);
		}

		if((ignore_devid == 1) && (errc == 0x7e)) errc=0; 

	}


	if ((errc == 0) && (chip_erase == 1))
	{
		printf("CHIP ERASE\n");
		errc=prg_comm(0x1DB,0,0,0,0,0,0,0,0);	//mass erase
		goto AVR0_EXIT;
	}

	if ((errc == 0) && (eep_erase == 1))
	{
		printf("EEPROM ERASE\n");
		errc=prg_comm(0x1DD,0,0,0,0,0,0,0,0);	//mass erase
	}

	if ((errc == 0) && (fuse_prog == 1))
	{
		printf("PROGRAM FUSE (%ld) with %02lX\n",(expar & 0xff),(expar2 & 0xff));
		errc=prg_comm(0x1d7,0,1,0,0,0,0,(expar & 0xff),(expar2 & 0xff));	//write fuse
//		printf("Status = %02X\n",memory[0]); 

		printf("READ FUSES\n");
		errc=prg_comm(0x01d6,0,16,0,0,param[12] & 0xff,(param[12] >> 8) & 0xff,param[11] & 0xff,(param[11] >> 8) & 0xff);	//read ID

		if(errc > 0)
		{
			printf("!!! DEVICE IS PROTECTED !!\n");
			goto AVR0_EXIT;
		}
		else
		{
			printf("  WDTCFG     = 0x%02X\n",memory[3]);
			printf("  BODCFG     = 0x%02X\n",memory[4]);
			printf("  OSCCFG     = 0x%02X\n",memory[5]);
			if (param[13] & 1)
			printf("  TCD0CFG    = 0x%02X\n",memory[7]);
			printf("  SYSCFG0    = 0x%02X\n",memory[8]);
			printf("  SYSCFG1    = 0x%02X\n",memory[9]);
			printf("  APPEND     = 0x%02X\n",memory[10]);
			printf("  BOOTEND    = 0x%02X\n",memory[11]);
			printf("  LOCKBIT    = 0x%02X\n\n",memory[13]);
		}
	}

	//program main
	if ((errc == 0) && (main_prog == 1) && (param[1] > 0))
	{
		read_block(param[0],param[1],0);		//get data
		bsize = max_blocksize;
		if(param[1]<bsize) bsize=param[1];
		addr=param[0]+0x4000;
		blocks=param[1]/bsize;
		pagesize=param[4];
		maddr=0;
		
		progress("MAIN PROG   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))
			{
				errc=prg_comm(0x1dc,bsize,0,maddr,0,(addr) & 0xff,(addr >> 8) & 0xff,
				pagesize,2048/pagesize);	//program
				eblock=tblock;
			}
			addr+=bsize;
			maddr+=bsize;
			progress("MAIN PROG   ",blocks,tblock+1);
		}
		printf("\n");
//		if(errc > 9) printf("ST= %02X %02X %02X %02X\n",memory[32],memory[33],memory[34],memory[35]);
	}

	//read / verify main
	if ((errc == 0) && ((main_verify == 1) || (main_readout == 1)) && (param[1] > 0))
	{
		bsize = max_blocksize;
		if(param[1]<bsize) bsize=param[1];
		addr=param[0]+0x4000;
		blocks=param[1]/bsize;
		maddr=0;

//		printf("\nBSIZE = %d\n",bsize);

		progress("MAIN READ   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(errc == 0)
			{
				errc=prg_comm(0x1da,0,bsize,0,maddr+ROFFSET,(addr) & 0xff,(addr >> 8) & 0xff,
				(bsize) & 0xff,(bsize >> 8) & 0xff);	//read
				eblock=tblock;
				addr+=bsize;
				maddr+=bsize;
			}
			if(errc !=0)
			{
				printf("ERR at %05lX\n",addr-bsize);
			}
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
		addr=param[2]+0x1400;
		blocks=param[3]/bsize;
		pagesize=param[5];
		wpp=bsize/param[5];
		maddr=0;

		printf("EEPROM PROG %d Blocks Pagesize=%d  (%d)\n",blocks,pagesize,wpp);

//		waitkey();

		progress("EEPROM PROG ",blocks,0);


		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))
			{
				errc=prg_comm(0x1de,bsize,0,maddr,0,(addr) & 0xff,(addr >> 8) & 0xff,
				pagesize,wpp);	//program
				eblock=tblock;
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
		addr=param[2]+0x1400;
		blocks=(param[3]+bsize-1)/bsize;
		maddr=0;

		progress("EEPROM READ ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
//			printf("ADDR= %04lX  LEN= %d\n",addr,bsize);
			if(errc == 0)
			{
				errc=prg_comm(0x1df,0,bsize,0,maddr+ROFFSET,(addr) & 0xff,(addr >> 8) & 0xff,
				0,bsize / 32);	//read
				addr+=bsize;
				maddr+=bsize;
			}
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
	
	//program user row
	if ((errc == 0) && ((user_prog + user_blind) > 0))
	{
		read_block(0,param[5],0);
		bsize = param[5];
		blocks=1;

		progress("UROW PROG   ",blocks,0);


		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(0,bsize) && (errc == 0))
			{
				errc=prg_comm(0x1d5,bsize,0,0,0,(param[8]) & 0xff,(param[8] >> 8) & 0xff,
				0,param[5]);	//program
				eblock=tblock;
			}
			addr+=bsize;
			maddr+=bsize;
			progress("UROW PROG   ",blocks,tblock+1);
		}
		printf("\n");
	}


	//verify and readout user
	if ((errc == 0) && ((user_verify == 1) || (user_readout == 1)) && (param[5] > 0))
	{
		bsize =param[5];
		addr=0x1300;
		blocks=1;
		maddr=0;

		progress("UROW READ   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
//			printf("ADDR= %04lX  LEN= %d\n",addr,bsize);
			if(errc == 0)
			{
				errc=prg_comm(0x1df,0,bsize,0,maddr+ROFFSET,(addr) & 0xff,(addr >> 8) & 0xff,
				0,bsize / 32);	//read
				addr+=bsize;
				maddr+=bsize;
			}
			progress("UROW READ   ",blocks,tblock+1);
		}
		printf("\n");
	}

	if((user_verify == 1) && (errc == 0) && (param[5] > 0))
	{
		read_block(0,param[5],0);
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

	if((user_readout==1) && (errc==0) && (param[5] > 0))
	{
		writeblock_data(0,param[5],0);
	}

	if((main_readout || eeprom_readout || user_readout) > 0)
	{
		writeblock_close();
	}


	if(dev_start == 1)
	{
		if(errc == 0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
	}

AVR0_EXIT:

	prg_comm(0x1d9,0,0,0,0,0,0,0,0);	//exit
	prg_comm(0xf5,0,0,0,0,0,0,0,0);		//VPP off
	prg_comm(0xf2,0,0,0,0,0,0,0,0);		//SET VPP=0
	prg_comm(0xfe,0,0,0,0,0,0,0,0);		//disable PU
	print_avr0_error(errc,eblock*max_blocksize);

	return errc;
}



