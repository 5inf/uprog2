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

void print_atxmega_error(int errc,unsigned long addr)
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

		case 0x41:	set_error("(TIMEOUT)",errc);
				break;

		case 0x42:	set_error("(NVM NOT READY)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int prog_atxmega(void)
{
	int errc,blocks,tblock,bsize,i,j,eblock=0,tbyte;
	unsigned long addr,maddr;
	int chip_erase=0;
	int main_erase=0;
	int boot_erase=0;
	int eeprom_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int boot_prog=0;
	int boot_verify=0;
	int boot_readout=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int f0_prog=0;
	int f1_prog=0;
	int f2_prog=0;
	int f4_prog=0;
	int f5_prog=0;
	int lock_prog=0;
	int dev_start=0;
	int ignore_devid=0;






	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- ea -- chip erase\n");
		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");
		printf("-- eb -- boot section erase\n");
		printf("-- pb -- boot section program\n");
		printf("-- vb -- boot section verify\n");
		printf("-- rb -- boot section readout\n");
		printf("-- ee -- eeprom erase\n");
		printf("-- pe -- eeprom program\n");
		printf("-- ve -- eeprom verify\n");
		printf("-- re -- eeprom readout\n");
		printf("-- f0 -- set fuse byte 0\n");
		printf("-- f1 -- set fuse byte 1\n");
		printf("-- f2 -- set fuse byte 2\n");
		printf("-- f4 -- set fuse byte 4\n");
		printf("-- f5 -- set fuse byte 5\n");
		printf("-- lb -- set lock bits\n");
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

	if(find_cmd("ii"))
	{
		ignore_devid=1;
		printf("## Ignore device ID\n");
	}

	if(find_cmd("ea"))
	{
		chip_erase=1;
		printf("## Action: chip erase\n");
	}

	if(find_cmd("em"))
	{
		main_erase=1;
		printf("## Action: appl. section erase\n");
	}
	if(find_cmd("eb"))
	{
		boot_erase=1;
		printf("## Action: boot section erase\n");
	}
	if(find_cmd("ee"))
	{
		eeprom_erase=1;
		printf("## Action: eeprom erase\n");
	}

	if(find_cmd("st"))
	{
		dev_start=1;
		printf("## Action: start device\n");
	}

	main_prog=check_cmd_prog("pm","flash");
	boot_prog=check_cmd_prog("pb","boot section");
	eeprom_prog=check_cmd_prog("pe","eeprom");


	main_verify=check_cmd_verify("vm","flash");
	boot_verify=check_cmd_verify("vb","boot section");
	eeprom_verify=check_cmd_verify("ve","eeprom");

	main_readout=check_cmd_read("rm","flash",&main_prog,&main_verify);
	boot_readout=check_cmd_read("rb","boot section",&boot_prog,&boot_verify);
	eeprom_readout=check_cmd_read("re","eeprom",&eeprom_prog,&eeprom_verify);

	if(find_cmd("f0"))
	{
		if(have_expar < 1)
		{
			f0_prog = 0;
			printf("## Action: fuse byte 0 program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			f0_prog=1;
			have_expar=0;
			printf("## Action: fuse byte 0 program with value 0x%02X\n",(int)(expar & 0xff));
		}
	}
	if(find_cmd("f1"))
	{
		if(have_expar < 1)
		{
			f1_prog = 0;
			printf("## Action: fuse byte 1 program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			f1_prog=1;
			have_expar=0;
			printf("## Action: fuse byte 1 program with value 0x%02X\n",(int)(expar & 0xff));
		}
	}

	if(find_cmd("f2"))
	{
		if(have_expar < 1)
		{
			f2_prog = 0;
			printf("## Action: fuse byte 2 program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			f2_prog=1;
			have_expar=0;
			printf("## Action: fuse byte 2 program with value 0x%02X\n",(int)(expar & 0xff));
		}
	}
	if(find_cmd("f4"))
	{
		if(have_expar < 1)
		{
			f4_prog = 0;
			printf("## Action: fuse byte 4 program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			f4_prog=1;
			have_expar=0;
			printf("## Action: fuse byte 4 program with value 0x%02X\n",(int)(expar & 0xff));
		}
	}
	if(find_cmd("f5"))
	{
		if(have_expar < 1)
		{
			f5_prog = 0;
			printf("## Action: fuse byte 5 program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			f5_prog=1;
			have_expar=0;
			printf("## Action: fuse byte 5 program with value 0x%02X\n",(int)(expar & 0xff));
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

	if((main_readout || boot_readout || eeprom_readout) > 0)
	{
		errc=writeblock_open();
	}

	printf("INIT\n");

	for(i=0;i<16;i++) memory[i]=0;

	errc=prg_comm(0x0fe,0,0,0,0,0,0,0,0);		//enable PU
	errc=prg_comm(0x130,0,3,0,0,0,0,0,0);		//init

	if (errc == 0) 
	{
	
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

		errc=prg_comm(0x134,0,8,0,8,0x00,0x00,0x00,0x00);	//read fuse byte 0 at 0x008f0020	

		if(param[6] & 1) 	printf("FUSE 0 (JID) = 0x%02X\n",memory[8]);
		if(param[6] & 2)	printf("FUSE 1       = 0x%02X\n",memory[9]);
		if(param[6] & 4)	printf("FUSE 2       = 0x%02X\n",memory[10]);
		if(param[6] & 8)	printf("FUSE 3       = 0x%02X\n",memory[42]);
		if(param[6] & 16)	printf("FUSE 4       = 0x%02X\n",memory[12]);
		if(param[6] & 32)	printf("FUSE 5       = 0x%02X\n",memory[13]);
		if(param[6] & 64)	printf("FUSE 6       = 0x%02X\n",memory[14]);
		printf("Lock Bits    = 0x%02X\n",memory[15]);


//		printf("Calibration    = 0x%02X\n",memory[7]);
		if(errc == 0x7e)
		{
			printf("ID bytes not matching %s",name);
		}

		if((ignore_devid == 1) && (errc == 0x7e)) errc=0; 

	}

	if ((errc == 0) && (chip_erase == 1))
	{
		printf("CHIP ERASE\n");
	}

	if ((errc == 0) && (main_erase == 1))
	{
		printf("MAIN FLASH ERASE\n");
		addr=param[0];
		errc=prg_comm(0x136,0,0,0,0,(addr >> 24) & 0xff,(addr >> 16) & 0xff,(addr >> 8) & 0xff,(addr) & 0xff);
	}

	if ((errc == 0) && (boot_erase == 1))
	{
		printf("BOOT SECTION ERASE\n");
		addr=param[8];
		errc=prg_comm(0x137,0,0,0,0,(addr >> 24) & 0xff,(addr >> 16) & 0xff,(addr >> 8) & 0xff,(addr) & 0xff);
	}

	if ((errc == 0) && (eeprom_erase == 1))
	{
		printf("EEPROM ERASE\n");

		for(i=0;i<2048;i++) memory[i]=0xff;

		bsize = max_blocksize;
		if(param[3]<bsize) bsize=param[3];
		addr=param[2];
		blocks=param[3]/bsize;
		maddr=0;

		for(tblock=0;tblock<blocks;tblock++)
		{
			if(errc == 0)
			{
				errc=prg_comm(0x138,bsize,0,0,0,
				(addr >> 24) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 8) & 0xff,
				param[5]);	//program
				eblock=tblock;
				addr+=bsize;

			}
		}
	}

	if ((errc == 0) && (f0_prog == 1))
	{
		printf("PROGRAM FUSE BYTE 0\n");
		errc=prg_comm(0x13e,0,0,0,0,0,0,0,(expar & 0xff));	//write fuse 0 byte
	}
	if ((errc == 0) && (f1_prog == 1))
	{
		printf("PROGRAM FUSE BYTE 1\n");
		errc=prg_comm(0x13e,0,0,0,0,1,0,0,(expar & 0xff));	//write fuse 0 byte
	}
	if ((errc == 0) && (f2_prog == 1))
	{
		printf("PROGRAM FUSE BYTE 2\n");
		errc=prg_comm(0x13e,0,0,0,0,2,0,0,(expar & 0xff));	//write fuse 0 byte
	}
	if ((errc == 0) && (f4_prog == 1))
	{
		printf("PROGRAM FUSE BYTE 4\n");
		errc=prg_comm(0x13e,0,0,0,0,4,0,0,(expar & 0xff));	//write fuse 0 byte
	}
	if ((errc == 0) && (f5_prog == 1))
	{
		printf("PROGRAM FUSE BYTE 5\n");
		errc=prg_comm(0x13e,0,0,0,0,5,0,0,(expar & 0xff));	//write fuse 0 byte
	}


	if ((errc == 0) && (lock_prog == 1))
	{
		printf("PROGRAM LOCK BITS\n");
		errc=prg_comm(0x13e,0,0,0,0,7,0,0,(expar & 0xff));	//write lock bits
	}

	//program main
	if ((errc == 0) && (main_prog == 1) && (param[1] > 0))
	{
		read_block(param[0]-0x800000,param[1],0);		//get data
		bsize = max_blocksize;
		if(param[1]<bsize) bsize=param[1];
		addr=param[0];
		blocks=param[1]/bsize;
		maddr=0;

		show_data(maddr,8);

		progress("MAIN PROG   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))
			{
				errc=prg_comm(0x13a,bsize,0,maddr,0,
				(addr >> 24) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 8) & 0xff,
				param[4]);	//program
				eblock=tblock;
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

//		printf("\nBSIZE = %d\n",bsize);

		progress("MAIN READ   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(errc == 0)
			{
				errc=prg_comm(0x133,0,bsize,0,maddr+ROFFSET,
				(addr >> 24) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 8) & 0xff,
				(addr) & 0xff);	//read
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
		read_block(param[0]-0x800000,param[1],0);
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
		writeblock_data(0,param[1],param[0]-0x800000);
	}


	//program boot
	if ((errc == 0) && (boot_prog == 1) && (param[9] > 0))
	{
		read_block(param[8]-0x800000,param[9],0);		//get data
		bsize = max_blocksize;
		if(param[9]<bsize) bsize=param[9];
		addr=param[8];
		blocks=param[9]/bsize;
		maddr=0;

		progress("BOOT PROG   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))
			{
				errc=prg_comm(0x13b,bsize,0,maddr,0,
				(addr >> 24) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 8) & 0xff,
				param[4]);	//program
				eblock=tblock;
				addr+=bsize;
				maddr+=bsize;
			}
			progress("BOOT PROG   ",blocks,tblock+1);
		}
		printf("\n");
	}

	//read / verify boot
	if ((errc == 0) && ((boot_verify == 1) || (boot_readout == 1)) && (param[9] > 0))
	{
		bsize = max_blocksize;
		if(param[9]<bsize) bsize=param[9];
		addr=param[8];
		blocks=param[9]/bsize;
		maddr=0;

//		printf("\nBSIZE = %d\n",bsize);

		progress("BOOT READ   ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(errc == 0)
			{
				errc=prg_comm(0x133,0,bsize,0,maddr+ROFFSET,
				(addr >> 24) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 8) & 0xff,
				(addr) & 0xff);	//read
				eblock=tblock;
				addr+=bsize;
				maddr+=bsize;
			}
			if(errc !=0)
			{
				printf("ERR at %05lX\n",addr-bsize);
			}
			progress("BOOT READ   ",blocks,tblock+1);
		}
		printf("\n");
	}

	if((boot_verify == 1) && (errc == 0))
	{
		read_block(param[8]-0x800000,param[9],0);
		addr = param[8]-0x800000;
		for(j=0;j<param[9];j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %06lX  DATA= %02X  READ= %02X\n",
				addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((boot_readout==1) && (errc==0))
	{
		writeblock_data(0,param[9],param[8]-0x800000);
	}


	//program eeprom
	if ((errc == 0) && (eeprom_prog == 1))
	{
		read_block(0,param[3],0);
		bsize = max_blocksize;
		if(param[3]<bsize) bsize=param[3];
		addr=param[2];
		blocks=param[3]/bsize;
		maddr=0;

		progress("EEPROM PROG ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(errc == 0)
			{
				errc=prg_comm(0x13c,bsize,0,maddr,0,
				(addr >> 24) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 8) & 0xff,
				param[5]);	//program
				eblock=tblock;
				addr+=bsize;
				maddr+=bsize;

			}
			progress("EEPROM PROG ",blocks,tblock+1);
		}
		printf("\n");
	}

	//verify an readout eeprom
	if ((errc == 0) && ((eeprom_verify == 1) || (eeprom_readout == 1)) && (param[3] > 0))
	{
		bsize = max_blocksize;
		if(param[3]<bsize) bsize=param[3];
		addr=param[2];
		blocks=param[3]/bsize;
		maddr=0;

		progress("EEPROM READ ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
//			printf("ADDR= %04lX  LEN= %d\n",addr,bsize);
			if(errc == 0)
			{
				errc=prg_comm(0x133,0,bsize,0,maddr+ROFFSET,
				(addr >> 24) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 8) & 0xff,
				(addr) & 0xff);	//read
				eblock=tblock;
				addr+=bsize;
				maddr+=bsize;
			}
			progress("EEPROM_READ ",blocks,tblock+1);
		}
		printf("\n");
	}

	if((eeprom_verify == 1) && (errc == 0))
	{
		read_block(0,param[3],0);
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
		writeblock_data(0,param[3],0);
	}

	if((main_readout || boot_readout || eeprom_readout) > 0)
	{
		writeblock_close();
	}



	if((dev_start == 1) && (errc == 0))
	{
		errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
	}

	if(errc==0) i=prg_comm(0x132,0,0,0,0,0,0,0,0);	//exit
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_atxmega_error(errc,eblock*max_blocksize);

	return errc;
}






