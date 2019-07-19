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

void print_avr_error(int errc,unsigned long addr)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",0);
				break;

		case 1:		set_error("WRONG COMMAND",1);
				break;

		case 0x7e:	set_error("(signature not match)",errc);
				break;

		case 0x41:	set_error("(no echo)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int prog_avr(void)
{
	int errc,blocks,tblock,bsize,j,eblock=0,tbyte;
	int pagesize,wpp;
	unsigned long addr,maddr;
	int chip_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int rom_readout=0;
	int rom_dummy=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int eeprom_ext=0;
	int lfuse_prog=0;
	int hfuse_prog=0;
	int efuse_prog=0;
	int lock_prog=0;
	int dev_start=0;
	int ignore_devid=0;
	int cal_value=0x80;
	int cal_set=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5v -- set VDD to 5V\n");
		printf("-- ls -- low spi speed\n");
		printf("-- ea -- chip erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");
		printf("-- pe -- eeprom program\n");
		printf("-- ve -- eeprom verify\n");
		printf("-- re -- eeprom readout\n");
		if(param[9] != 0)
		{
			printf("-- ro -- rom readout\n");
			printf("-- ex -- include eeprom extension\n");
		}
		printf("-- lf -- set low fuse\n");
		printf("-- hf -- set high fuse\n");
		printf("-- ef -- set ext fuse\n");
		printf("-- lb -- set lock bits\n");
		printf("-- wc -- write calibration value to flash\n");
		printf("-- st -- start device\n");
		printf("-- ii -- ignore wrong ID\n");
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


	if(find_cmd("ls"))
	{
		errc=prg_comm(0x02,0,0,0,0,0,0,0,0);	//ls mode
		printf("## using low speed spi mode\n");
	}
	else
	{
		errc=prg_comm(0x02,0,0,0,0,0,0,0,1);	//hs mode
		printf("## using high speed spi mode\n");	
	}

	if(find_cmd("ii"))
	{
		ignore_devid=1;
		printf("## Ignore device ID\n");
	}

	if(find_cmd("ex"))
	{
		eeprom_ext=1;
		param[3]+=384;
		printf("## Include eeprom extension\n");
	}

	if(find_cmd("ea"))
	{
		chip_erase=1;
		printf("## Action: chip erase\n");
	}

	if(find_cmd("wc"))
	{
		cal_set=1;
		printf("## Action: write calibration to flash\n");
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
	rom_readout=check_cmd_read("ro","rom",&rom_dummy,&rom_dummy);

	if(find_cmd("lf"))
	{
		if(have_expar < 1)
		{
			lfuse_prog = 0;
			printf("## Action: low fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			lfuse_prog=1;
			have_expar=0;
			printf("## Action: low fuse program with value 0x%02X\n",(int)(expar & 0xff));
		}
	}

	if(find_cmd("hf") && (param[6] > 1)) 
	{
		if(have_expar < 1)
		{
			hfuse_prog = 0;
			printf("## Action: high fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			hfuse_prog=1;
			have_expar=0;
			printf("## Action: high fuse program with value 0x%02X\n",(int)(expar & 0xff));
		}
	}

	if(find_cmd("ef") && (param[6] > 2)) 
	{
		if(have_expar < 1)
		{
			efuse_prog = 0;
			printf("## Action: ext fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			efuse_prog=1;
			have_expar=0;
			printf("## Action: ext fuse program with value 0x%02X\n",(int)(expar & 0xff));
		}
	}

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

	if((main_readout || eeprom_readout || rom_readout) > 0)
	{
		errc=writeblock_open();
	}

	printf("INIT\n");
	errc=prg_comm(0x01,0,0,0,0,0,0,0,0x50);	//slow

	if (errc == 0) 
	{
		printf("READ ID\n");
		errc=prg_comm(0x03,0,8,0,0,0,0,0,0x50);	//read ID

		tbyte=(param[10] >> 16) & 0xff;
		printf("SIGNATURE  = %02X %02X %02X\n",memory[0],memory[1],memory[2]);
		
		if (memory[0] != tbyte) 
		{
			errc = 0x7e;
			printf("Signature 0x00 = 0x%02X    Expected 0x%02X\n",memory[0],tbyte);
		}

		tbyte=(param[10] >> 8) & 0xff;
		if (memory[1] != tbyte) 
		{
			errc = 0x7e;
			printf("Signature 0x01 = 0x%02X    Expected 0x%02X\n",memory[1],tbyte);
		}

		tbyte=param[10] & 0xff;
		if (memory[2] != tbyte) 
		{
			errc = 0x7e;
			printf("Signature 0x02 = 0x%02X    Expected 0x%02X\n",memory[2],tbyte);
		}



		if(param[6] > 0)
		{
			printf("FUSE LOW       = 0x%02X\n",memory[3]);
		}
		if(param[6] > 1)
		{
			printf("FUSE HIGH      = 0x%02X\n",memory[4]);
		}
		if(param[6] > 2)
		{
			printf("FUSE EXT       = 0x%02X\n",memory[5]);
		}
		printf("Lock Bits      = 0x%02X\n",memory[6]);
		printf("Calibration    = 0x%02X\n",memory[7]);
		cal_value=memory[7];
		if(errc == 0x7e)
		{
			printf("ID bytes not matching %s",name);
		}

		if((ignore_devid == 1) && (errc == 0x7e)) errc=0; 

	}


	if ((errc == 0) && (chip_erase == 1))
	{
		printf("CHIP ERASE\n");
		if(param[11]==0)
			errc=prg_comm(0x04,0,0,0,0,0,0,0,0);	//mass erase
		if(param[11]==1)
			errc=prg_comm(0x1ae,0,0,0,0,0,0,0,0);	//mass erase
		
	}

	if ((errc == 0) && (lfuse_prog == 1))
	{
		printf("PROGRAM LOW FUSE\n");
		errc=prg_comm(0x09,0,0,0,0,(expar & 0xff),0,0,param[11]);	//write low fuse
	}

	if ((errc == 0) && (hfuse_prog == 1))
	{
		printf("PROGRAM HIGH FUSE\n");
		errc=prg_comm(0x0a,0,0,0,0,(expar & 0xff),0,0,param[11]);	//write high fuse
	}

	if ((errc == 0) && (efuse_prog == 1))
	{
		printf("PROGRAM EXT FUSE\n");	
		errc=prg_comm(0x0b,0,0,0,0,(expar & 0xff),0,0,param[11]);	//write ext fuse
	}

	if ((errc == 0) && (lock_prog == 1))
	{
		printf("PROGRAM LOCK BITS\n");
		errc=prg_comm(0x0c,0,0,0,0,(expar & 0xff),0,0,param[11]);	//write lock bits
	}

	//program main
	if ((errc == 0) && (main_prog == 1) && (param[1] > 0))
	{
		read_block(param[0],param[1],0);		//get data
		if(cal_set==1) memory[param[1]-1]=cal_value;
		bsize = max_blocksize;
		if(param[1]<bsize) bsize=param[1];
		addr=param[0];
		blocks=param[1]/bsize;
		pagesize=param[4]/2;
		wpp=bsize/param[4];
		maddr=0;

		progress("MAIN PROG   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))
			{
				if(param[11]==0)
				{
					errc=prg_comm(0x05,bsize,0,maddr,0,(addr >> 1) & 0xff,(addr >> 9) & 0xff,
					wpp,pagesize);	//program
				}
				if(param[11]==1)
				{
					errc=prg_comm(0x1ac,bsize,0,maddr,0,(addr >> 1) & 0xff,(addr >> 9) & 0xff,
					wpp,pagesize);	//program
				}
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
		addr=param[0];
		blocks=param[1]/bsize;
		maddr=0;

//		printf("\nBSIZE = %d\n",bsize);

		progress("MAIN READ   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(errc == 0)
			{
				errc=prg_comm(0x06,0,bsize,0,maddr+ROFFSET,(addr >> 1) & 0xff,(addr >> 9) & 0xff,
				(bsize >> 1) & 0xff,(bsize >> 9) & 0xff);	//read
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
		if(cal_set==1) memory[param[1]-1]=cal_value;
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
		pagesize=param[5];
		wpp=bsize/param[5];
		maddr=0;

		printf("EEPROM PROG %d Blocks Pagesize=%d  (%d)\n",blocks,pagesize,wpp);

		progress("EEPROM PROG ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))
			{
				if(param[11]==0)
				{
					errc=prg_comm(0x07,bsize,0,maddr,0,(addr) & 0xff,(addr >> 8) & 0xff,
					wpp,pagesize);	//program
				}
				if(param[11]==1)
				{
					errc=prg_comm(0x1ad,bsize,0,maddr,0,(addr) & 0xff,(addr >> 8) & 0xff,
					wpp,pagesize);	//program
				}
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
		pagesize=param[5]/2;
		wpp=bsize/param[5];
		maddr=0;

		progress("EEPROM READ ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
//			printf("ADDR= %04lX  LEN= %d\n",addr,bsize);
			if(errc == 0)
			{
				errc=prg_comm(0x08,0,bsize,0,maddr+ROFFSET,(addr) & 0xff,(addr >> 8) & 0xff,
				(bsize) & 0xff,(bsize >> 8) & 0xff);	//read
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

	if((eeprom_readout==1) && (errc==0))
	{
		writeblock_data(0,param[3],param[2]);
	}

	//read rom
	if ((errc == 0) && (rom_readout == 1) && (param[9] > 0))
	{
		bsize = max_blocksize;
		if(param[9]<bsize) bsize=param[9];
		addr=param[8];
		blocks=param[9]/bsize;
		maddr=0;

//		printf("\nBSIZE = %d\n",bsize);

		progress("ROM READ    ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(errc == 0)
			{
				errc=prg_comm(0x06,0,bsize,0,maddr+ROFFSET,(addr >> 1) & 0xff,(addr >> 9) & 0xff,
				(bsize >> 1) & 0xff,(bsize >> 9) & 0xff);	//read
				eblock=tblock;
				addr+=bsize;
				maddr+=bsize;
			}
			if(errc !=0)
			{
				printf("ERR at %05lX\n",addr-bsize);
			}
			progress("ROM READ    ",blocks,tblock+1);
		}
		printf("\n");
	}

	if((rom_readout==1) && (errc==0))
	{
		writeblock_data(0,param[9],param[8]);
	}

	if((main_readout || eeprom_readout || rom_readout) > 0)
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

	print_avr_error(errc,eblock*max_blocksize);

	return errc;
}



