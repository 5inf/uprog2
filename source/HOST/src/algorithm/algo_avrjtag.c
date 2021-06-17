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

void print_avrjtag_error(int errc,unsigned long addr)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",0);
				break;

		case 1:		set_error("WRONG COMMAND",1);
				break;

		case 0x7e:	set_error("(JTAG ID not match)",errc);
				break;

		case 0x41:	set_error("(no echo)",errc);
				break;

		case 0x42:	set_error("(erase time out)",errc);
				break;

		case 0x43:	set_error("(fuse program time out)",errc);
				break;

		case 0x44:	set_error("(flash program time out)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int prog_avrjtag(void)
{
	int errc,blocks,tblock,bsize,i,j,eblock=0;
	unsigned long addr,maddr,signature;
	int chip_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int lfuse_prog=0;
	int hfuse_prog=0;
	int efuse_prog=0;
	int lock_prog=0;
	int dev_start=0;
	int ignore_devid=0;
	int cal_value=0x80;
	int cal_set=0;
	int tout;

	int debug_flash=0;
	size_t dbg_len=80;
	char *dbg_line;
	char *dbg_ptr;
	char c;
	unsigned short dbg_addr,dbg_val;
	
	dbg_line=malloc(100);
	

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
//		printf("-- df -- debug code in FLASH\n");
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

	if(find_cmd("ii"))
	{
		ignore_devid=1;
		printf("## Ignore device ID\n");
	}

/*	if(find_cmd("df"))
	{
		debug_flash=1;
		printf("## Action: debug code in FLASH\n");
		goto AVRJTAG_ORUN;
	}
*/
	if(find_cmd("ex"))
	{
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


AVRJTAG_ORUN:

	errc=0;

	if((main_readout || eeprom_readout) > 0)
	{
		errc=writeblock_open();
	}

	printf("INIT\n");
	errc=prg_comm(0x240,0,0,0,0,0,0,0,0);	//init

	if (errc == 0) 
	{
		printf("READ ID\n");
		errc=prg_comm(0x24C,0,8,0,0,0,0,0,0);	//read ID

		printf("JTAG ID = %02X %02X %02X %02X\n",memory[3],memory[2],memory[1],memory[0]);
		
		memory[3] &= 0x0F;

		signature=(memory[3] << 24) | (memory[2] << 16) | (memory[1] << 8) | (memory[0]);
		
		if (param[10] != signature) 
		{
			printf("JTAG ID : 0x%08lX      Expected : 0x%08lX\n",signature,param[10]);
			printf("ID bytes not matching %s",name);
			if(ignore_devid == 0)
			{
				errc = 0x7e;
				goto AVRJTAG_ERR;
			}
			else
			{
				printf("!!! IGNORE SIGNATURE BY COMMAND OVERRIDE !!!\n");	
			}
		}

		if(debug_flash==1) goto AVRJTAG_NRD;


		errc=prg_comm(0x249,0,0,0,0,0,0,0,0);	//PRGEN
		errc=prg_comm(0x24d,0,0,0,0,0,0,0x04,0x23);	//enter fuse read


		if(param[6] > 0)
		{
			errc=prg_comm(0x24d,0,4,0,0,0,0,0x00,0x32);	//fuse low read
			errc=prg_comm(0x24e,0,4,0,0,0,0,0x00,0x33);	//fuse low read	
			printf("FUSE LOW       = 0x%02X\n",memory[0]);
		}
		if(param[6] > 1)
		{
			errc=prg_comm(0x24d,0,4,0,0,0,0,0x00,0x3E);	//fuse high read
			errc=prg_comm(0x24e,0,4,0,0,0,0,0x00,0x3F);	//fuse high read	
			printf("FUSE HIGH      = 0x%02X\n",memory[0]);
		}
		if(param[6] > 2)
		{
			errc=prg_comm(0x24d,0,4,0,0,0,0,0x00,0x3A);	//fuse ext read
			errc=prg_comm(0x24e,0,4,0,0,0,0,0x00,0x3B);	//fuse ext read	
			printf("FUSE EXT       = 0x%02X\n",memory[0]);
		}
		errc=prg_comm(0x24d,0,4,0,0,0,0,0x00,0x36);	//lockbits read
		errc=prg_comm(0x24e,0,4,0,0,0,0,0x00,0x37);	//lockbits read	
		printf("Lock Bits      = 0x%02X\n",memory[0]);
		errc=prg_comm(0x24d,0,0,0,0,0,0,0x08,0x23);	//enter calibration read
		errc=prg_comm(0x24e,0,4,0,0,0,0,0x00,0x36);	//lockbits read
		errc=prg_comm(0x24e,0,4,0,0,0,0,0x00,0x37);	//lockbits read	
		printf("Calibration    = 0x%02X\n",memory[0]);
		cal_value=memory[0];

	}

AVRJTAG_NRD:

	if ((errc == 0) && (chip_erase == 1))
	{
		printf("CHIP ERASE\n");
		prg_comm(0x24d,0,0,0,0,0,0,0x80,0x23);	//chip erase
		prg_comm(0x24e,0,0,0,0,0,0,0x80,0x31);	//chip erase
		prg_comm(0x24e,0,0,0,0,0,0,0x80,0x33);	//chip erase
		prg_comm(0x24e,0,0,0,0,0,0,0x80,0x33);	//chip erase
		
		tout=100;
		do
		{
			prg_comm(0x24e,0,2,0,0,0,0,0x80,0x33);	//poll
			usleep(10000);tout--;if((memory[1] & 2) == 0) tout=-1;
		}while(tout > 0);
		
		if(tout == 0)
		{
			errc=0x42;goto AVRJTAG_ERR;
		}	
		errc=prg_comm(0x240,0,0,0,0,0,0,0,0);	//init

	}

	if ((errc == 0) && (lfuse_prog == 1))
	{
		printf("PROGRAM LOW FUSE\n");
		errc=prg_comm(0x24d,0,0,0,0,0,0,0x40,0x23);			//enter fuse WRITE
		errc=prg_comm(0x24C,0,0,0,0,0,0,(expar & 0xff),0x13);		//load value
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x33);				//write low fuse
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x31);				//write low fuse
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x33);				//write low fuse
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x33);				//write low fuse

		tout=100;
		do
		{
			prg_comm(0x24e,0,2,0,0,0,0,0x00,0x33);			//poll
			usleep(10000);tout--;if((memory[1] & 2) == 0) tout=-1;
		}while(tout > 0);
		
		if(tout == 0)
		{
			errc=0x43;goto AVRJTAG_ERR;
		}	
	}

	if ((errc == 0) && (hfuse_prog == 1))
	{
		printf("PROGRAM HIGH FUSE\n");
		errc=prg_comm(0x24d,0,0,0,0,0,0,0x40,0x23);			//enter fuse WRITE
		errc=prg_comm(0x24C,0,0,0,0,0,0,(expar & 0xff),0x13);		//load value
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x37);				//write low fuse
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x35);				//write low fuse
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x37);				//write low fuse
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x37);				//write low fuse

		tout=100;
		do
		{
			prg_comm(0x24e,0,2,0,0,0,0,0x00,0x37);			//poll
			usleep(10000);tout--;if((memory[1] & 2) == 0) tout=-1;
		}while(tout > 0);
		
		if(tout == 0)
		{
			errc=0x43;goto AVRJTAG_ERR;
		}	
	}

	if ((errc == 0) && (efuse_prog == 1))
	{
		printf("PROGRAM EXT FUSE\n");	
		errc=prg_comm(0x24d,0,0,0,0,0,0,0x40,0x23);			//enter fuse WRITE
		errc=prg_comm(0x24C,0,0,0,0,0,0,(expar & 0xff),0x13);		//load value
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x3B);				//write low fuse
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x39);				//write low fuse
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x3B);				//write low fuse
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x3B);				//write low fuse

		tout=100;
		do
		{
			prg_comm(0x24e,0,2,0,0,0,0,0x00,0x3B);			//poll
			usleep(10000);tout--;if((memory[1] & 2) == 0) tout=-1;
		}while(tout > 0);
		
		if(tout == 0)
		{
			errc=0x43;goto AVRJTAG_ERR;
		}	
	}

	if ((errc == 0) && (lock_prog == 1))
	{
		printf("PROGRAM LOCK BITS\n");
		errc=prg_comm(0x24d,0,0,0,0,0,0,0x20,0x23);			//enter lb WRITE
		errc=prg_comm(0x24C,0,0,0,0,0,0,(expar & 0xff),0x13);		//load value
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x33);				//write lock bits
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x31);				//write lock bits
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x33);				//write lock bits
		prg_comm(0x24e,0,0,0,0,0,0,0x00,0x33);				//write lock bits

		tout=100;
		do
		{
			prg_comm(0x24e,0,2,0,0,0,0,0x00,0x33);			//poll
			usleep(10000);tout--;if((memory[1] & 2) == 0) tout=-1;
		}while(tout > 0);
		
		if(tout == 0)
		{
			errc=0x43;goto AVRJTAG_ERR;
		}	
	}

	//program main
	if ((errc == 0) && (main_prog == 1) && (param[1] > 0))
	{
		read_block(param[0],param[1],0);		//get data
		if(cal_set==1) memory[param[1]-1]=cal_value;

		bsize = param[4];
		addr=param[0];
		blocks=param[1]/bsize;
		maddr=0;

		errc=prg_comm(0x249,0,0,0,0,0,0,0,0);	//PRGEN
		errc=prg_comm(0x24d,0,0,0,0,0,0,0x10,0x23);			//enter flash WRITE
		
		progress("MAIN PROG   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))
			{
				prg_comm(0x24d,0,0,0,0,0,0,(addr >> 16) & 0xff,0x0B);		//addr ext
				prg_comm(0x24e,0,0,0,0,0,0,(addr >> 8) & 0xff,0x07);		//addr hi
				prg_comm(0x24e,0,0,0,0,0,0,addr & 0xff,0x03);			//addr lo
			
				errc=prg_comm(0x24A,bsize,0,maddr,0,0,0,0,bsize & 0xff);	//page load

				prg_comm(0x24d,0,0,0,0,0,0,0x00,0x37);				//write page
				prg_comm(0x24e,0,0,0,0,0,0,0x00,0x35);				//write page
				prg_comm(0x24e,0,0,0,0,0,0,0x00,0x37);				//write page
				prg_comm(0x24e,0,0,0,0,0,0,0x00,0x37);				//write page

				tout=100;
				do
				{
					prg_comm(0x24e,0,2,0,0,0,0,0x00,0x37);			//poll
					usleep(10000);tout--;if((memory[1] & 2) == 0) tout=-1;
				}while(tout > 0);
		
				if(tout == 0)
				{
					errc=0x44;goto AVRJTAG_ERR;
				}	

				eblock=tblock;
			}
			addr+=(bsize / 2);
			maddr+=bsize;
			progress("MAIN PROG   ",blocks,tblock+1);
		}
		printf("\n");
//		if(errc > 9) printf("ST= %02X %02X %02X %02X\n",memory[32],memory[33],memory[34],memory[35]);
	}

	//read / verify main
	if ((errc == 0) && ((main_verify == 1) || (main_readout == 1)) && (param[1] > 0))
	{
		bsize = param[4];
		addr=param[0];
		blocks=param[1]/bsize;
		maddr=0;

		errc=prg_comm(0x24d,0,0,0,0,0,0,0x02,0x23);				//enter flash READ		

		progress("MAIN READ   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(errc == 0)
			{
				errc=prg_comm(0x24d,0,0,0,0,0,0,(addr >> 16) & 0xff,0x0B);		//addr ext
				errc=prg_comm(0x24e,0,0,0,0,0,0,(addr >> 8) & 0xff,0x07);		//addr hi
				errc=prg_comm(0x24e,0,0,0,0,0,0,addr & 0xff,0x03);			//addr lo

				errc=prg_comm(0x24B,0,bsize,0,maddr+ROFFSET,0,0,0,bsize & 0xff);	//read
				eblock=tblock;
				addr+=(bsize / 2);
				maddr+=bsize;
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
		bsize = param[5];			//page size
		blocks=param[3]/bsize;
		maddr=0;
		addr=param[2];

		errc=prg_comm(0x249,0,0,0,0,0,0,0,0);			//PRGEN
		errc=prg_comm(0x24d,0,0,0,0,0,0,0x11,0x23);					//enter EEPROM WRITE		

		printf("EEPROM PROG %d Blocks Pagesize=%d\n",blocks,bsize);

		progress("EEPROM PROG ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))
			{
				errc=prg_comm(0x250,bsize,0,maddr,0,bsize,0,addr & 0xff,(addr >> 8) & 0xff);		//EEPROM WRITE		
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
		bsize = 64;
		addr=param[2];
		blocks=param[3]/bsize;
		maddr=0;

		errc=prg_comm(0x24d,0,0,0,0,0,0,0x03,0x23);					//enter EEPROM READ		

		progress("EEPROM READ ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			prg_comm(0x24f,0,bsize,0,maddr+ROFFSET,bsize,0,addr & 0xff,(addr >> 8) & 0xff);		//read	
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

	if((main_readout || eeprom_readout ) > 0)
	{
		writeblock_close();
	}

/*
	if(param[12] > 0)
	{
		if((debug_flash==1) && (errc==0) && (param[12]==1)) debug_avrjtag_t1();
	}
	else
	{
		printf("!! Debugging is not supported for %s !!\n",name);
	
	}
*/
	if(dev_start == 1)
	{
		if(errc == 0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
	}

AVRJTAG_ERR:

	prg_comm(0x0d,0,0,0,0,0,0,0,0);		//exit
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_avrjtag_error(errc,eblock*max_blocksize);

	return errc;
}



