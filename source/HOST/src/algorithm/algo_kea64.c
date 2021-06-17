//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2012-2018 Joerg Wolfram (joerg@jcwolfram.de)			#
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
#include "exec/kea64/exec_kea64.h"

void print_kea64swd_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(timeout: no ACK)",errc);
				break;

		case 0x42:	set_error("(erase timeout)",errc);
				break;

		case 0x43:	set_error("(mass erase error)",errc);
				break;

		case 0x50:	set_error("(wrong ID)",errc);
				break;

		case 0x51:	set_error("(verify error)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

void show_kea64swd_registers(void)
{
	int i;
	for(i=0;i<13;i++)
	{
		printf("R%2d: %02X%02X%02X%02X\n",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	}
	i=13;
		printf("SP : %02X%02X%02X%02X\n",memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=14;
		printf("LR : %02X%02X%02X%02X\n",memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=15;
		printf("PC : %02X%02X%02X%02X --> ",memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=16;
		if((memory[i*4-4] & 0x02) == 0x02)
		{
			printf("%02X%02X %02X%02X %02X%02X\n",memory[67],memory[66],memory[69],memory[68],memory[71],memory[70]);
		}
		else
		{
			printf("%02X%02X %02X%02X %02X%02X\n",memory[65],memory[64],memory[67],memory[66],memory[69],memory[68]);
		}
		


	printf("\n");
}

int prog_kea64swd(void)
{
	int errc,blocks,i,j;
	unsigned long addr,len,maddr;
	int mass_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;

	int dev_start=0;
	int run_ram=0;
	int unsecure=0;
	int debug_ram=0;
	int debug_flash=0;
	size_t dbg_len = 80;
	char *dbg_line;
	char *dbg_ptr;
	char c;
	unsigned long dbg_addr,dbg_val;

	dbg_line=malloc(100);
		
	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- ea -- erase all (mass erase)\n");
		printf("-- un -- unsecure device\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		printf("-- pe -- eeprom program\n");
		printf("-- ve -- eeprom verify\n");
		printf("-- re -- eeprom readout\n");

		printf("-- rr -- run code in RAM\n");
		printf("-- dr -- debug code in RAM\n");
		printf("-- df -- debug code in FLASH\n");
		printf("-- st -- start device\n");
 		printf("-- d2 -- switch to device 2\n");

		return 0;
	}

//	errc=prg_comm(0xfe,0,0,0,0,1,1,0,0);	//enable PU

	if(find_cmd("5v"))
	{
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		printf("## using 5V VDD\n");
	}


	if(find_cmd("d2"))
	{
		errc=prg_comm(0x2ee,0,0,0,0,0,0,0,0);	//dev 2
		printf("## switch to device 2\n");
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
			goto KEA64SWD_ORUN;
		}
	}
	else if(find_cmd("dr"))
	{
		if(file_found < 2)
		{
			debug_ram = 0;
			printf("## Action: debug code in RAM !! DISABLED BECAUSE OF NO FILE !!\n");
		}
		else
		{
			debug_ram = 1;
			printf("## Action: debug code in RAM using %s\n",sfile);
			goto KEA64SWD_ORUN;
		}
	}
	else if(find_cmd("df"))
	{
		debug_flash = 1;
		printf("## Action: debug code in FLASH\n");
		goto KEA64SWD_ORUN;
	}
	else
	{
		if(find_cmd("un"))
		{
			unsecure=1;
			printf("## Action: unsecure device\n");
		}

		if(find_cmd("ea"))
		{
			mass_erase=1;
			printf("## Action: mass erase\n");
		}

		main_prog=check_cmd_prog("pm","code flash");
		main_verify=check_cmd_verify("vm","code flash");
		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);

		eeprom_prog=check_cmd_prog("pe","eeprom");
		eeprom_verify=check_cmd_verify("ve","eeprom");
		eeprom_readout=check_cmd_read("re","eeprom",&eeprom_prog,&eeprom_verify);


		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

KEA64SWD_ORUN:

	//open file if read 
	if((main_readout == 1) || (eeprom_readout == 1))
	{
		errc=writeblock_open();
	}

	if(errc > 0) return errc;

	if(dev_start == 0)
	{

		if((mass_erase == 1) && (errc == 0))
		{
			errc=prg_comm(0x1D0,0,16,0,0,0,0,0,0x55);	//init
			printf("JID: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
			if(errc > 0) goto ERR_EXIT;
			printf("ERASE FLASH\n");
			errc=prg_comm(0x1D4,0,4,0,0,0,0,0,0);		//erase direct
			printf("MASS ERASE_TIME: %d ms\n",(20-memory[0])*20);
			if(errc > 0) goto ERR_EXIT;
			printf("RE-INIT\n");
			errc=prg_comm(0x1D0,0,16,0,0,0,0,0,0);		//re-init
		}
		else
		{
			errc=prg_comm(0x1D0,0,16,0,0,0,0,0,0);					//init
			printf("JID: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
			if(errc > 0) goto ERR_EXIT;
		}

		errc=prg_comm(0x1D1,0,4,0,0,0x00,0x80,0x04,0x40);				//READ DEVID
		j=(memory[3])*256+(memory[2]);
/*
		if((j & 0xFF00) != 0x200)
		{
			printf("UNKNOWN DEVICE ID: %04x\n",j);
			errc= 0x50;
			goto ERR_EXIT;
		}
*/
		printf("DEVICE: %04x\n",j);

		switch(j & 15)
		{
			case 0:		printf(">> 8 PIN DEVICE\n");break;
			case 1:		printf(">> 16 PIN DEVICE\n");break;
			case 2:		printf(">> 20 PIN DEVICE\n");break;
			case 3:		printf(">> 24 PIN DEVICE\n");break;
			case 4:		printf(">> 32 PIN DEVICE\n");break;
			case 5:		printf(">> 44 PIN DEVICE\n");break;
			case 6:		printf(">> 48 PIN DEVICE\n");break;
			case 7:		printf(">> 64 PIN DEVICE\n");break;
			case 8:		printf(">> 80 PIN DEVICE\n");break;
			case 10:	printf(">> 100 PIN DEVICE\n");break;
			default:	printf("!! UNKNOWN DEVICE\n");
		}

		max_blocksize=1024;

		//transfer loader to ram
		if((run_ram == 0) && (errc == 0) && ((main_prog == 1) || (eeprom_prog == 1) || (eeprom_readout == 1) || (eeprom_verify == 1)))
		{
			printf("TRANSFER LOADER\n");
			for(j=0;j<512;j++)
			{
				switch(algo_nr)
				{
					case 56:	memory[j]=exec_kea64[j]; break;
					default:	memory[j]=0xff;
				}
			}

			addr=param[4];				//RAM start

			errc=prg_comm(0xb2,0x200,0,0,0,		//write 0,5 K bootloader to ramstart
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff,
				2);
		
			errc=prg_comm(0x128,8,12,0,0,		//write SP/PC (prepare)	
					addr & 0xff,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 24) & 0xff);

			errc=prg_comm(0x12b,0,64,0,0,0,0,0,0);	//run (sgo)

		}
	}
	
	
	if((run_ram == 0) && (errc == 0) && (dev_start == 0))
	{
		if((main_prog == 1) && (errc == 0))
		{
			addr=param[0];
			maddr=0;
			blocks=param[1]/max_blocksize;
			len=read_block(param[0],param[1],0);		//read flash
			progress("FLASH PROG   ",blocks,0);
			if(unsecure == 1) memory[0x40D]=0xFE;
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);

			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,max_blocksize) && (errc==0))
				{
					//transfer data
					errc=prg_comm(0xb2,max_blocksize,0,maddr,0,
						0x02,0x00,0x20,max_blocksize >> 8);

					//execute prog
					errc=prg_comm(0x58,0,0,0,0,
						0x52,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);

				}
				addr+=max_blocksize;
				maddr+=max_blocksize;
				progress("FLASH PROG   ",blocks,i+1);
			}
			printf("\n");
		}

		if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
		{
			maddr=0;
			addr=param[0];
			blocks=param[1]/max_blocksize;
			progress("FLASH READ   ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(errc==0)
				{
					errc=prg_comm(0xbf,0,2048,0,ROFFSET+maddr,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff,
						max_blocksize >> 8);
					addr+=max_blocksize;
					maddr+=max_blocksize;
					progress("FLASH READ   ",blocks,i+1);
				}
			}
			printf("\n");
		}


		if((main_readout == 1) && (errc == 0))
		{
			writeblock_data(0,param[1],param[0]);
		}

		//verify main
		if((main_verify == 1) && (errc == 0))
		{
			read_block(param[0],param[1],0);
			printf("VERIFY FLASH (%ld KBytes)\n",param[1]/1024);
			addr = param[0];
			maddr=0;
			len = param[1];
			for(j=0;j<len;j++)
			{
				if(memory[maddr+j] != memory[maddr+j+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr+j,memory[maddr+j],memory[maddr+j+ROFFSET]);
					errc=0x51;
				}
			}
		}


		if((eeprom_prog == 1) && (errc == 0))
		{
			addr=param[2];
			maddr=0;
			blocks=1;
			len=read_block(param[2],param[3],0);		//read flash
//			show_data(0,16);
			progress("EEPROM PROG  ",blocks,0);
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);


			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,max_blocksize) && (errc==0))
				{
					//transfer data
					errc=prg_comm(0xb2,256,0,maddr,0,0x02,0x00,0x20,1);

					//execute prog
					errc=prg_comm(0x58,0,0,0,0,
						0x62,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);

				}

				addr+=max_blocksize;
				maddr+=max_blocksize;
				progress("EEPROM PROG  ",blocks,i+1);
			}
			printf("\n");
		}



		if(((eeprom_readout == 1) || (eeprom_verify == 1)) && (errc == 0))
		{
			maddr=0;
			addr=param[2];
			blocks=1;
			progress("EEPROM READ  ",blocks,0);

			for(i=0;i<blocks;i++)
			{
				if(errc==0)
				{

					//execute read
					errc=prg_comm(0x58,0,0,0,0,
						0x61,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);

						addr=0x20000200;

					errc=prg_comm(0xbf,0,2048,0,ROFFSET+maddr,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff,
						1);
					progress("EEPROM READ  ",blocks,i+1);

				}
			}
			printf("\n");
//			show_data(ROFFSET,16);
		}

	

		if((eeprom_readout == 1) && (errc == 0))
		{
			writeblock_data(0,param[3],param[2]);
		}

		//verify eeprom
		if((eeprom_verify == 1) && (errc == 0))
		{
			read_block(param[2],param[3],0);
			printf("VERIFY EEPROM (%ld Bytes)\n",param[3]);
			addr = param[2];
			maddr=0;
			len = param[3];
			for(j=0;j<len;j++)
			{
				if(memory[maddr+j] != memory[maddr+j+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr+j,memory[maddr+j],memory[maddr+j+ROFFSET]);
					errc=0x51;
				}
			}
		}



		//open file if was read 
		if((main_readout == 1) || (eeprom_readout == 1))
		{
			writeblock_close();
		}
	}

	if((run_ram == 1) && (errc == 0))
	{
		len = read_block(param[4],param[5],0);
		printf("BYTES= %04lX\n",len);
		if(len < 8)
		{	
			len = read_block(0,param[5],0);	//read from addr 0
			printf("LOW BYTES= %04lX\n",len);
		}

		printf("TRANSFER & START CODE\n");
		addr=param[4];
		maddr=0;
		blocks=(param[5]+2047) >> 11;

		progress("TRANSFER ",blocks,0);

		for(i=0;i<blocks;i++)
		{
			errc=prg_comm(0xb2,max_blocksize,0,maddr,0,		//write 1.K
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				0x20,max_blocksize >> 8);
		
			addr+=max_blocksize;
			maddr+=max_blocksize;
			progress("TRANSFER ",blocks,i+1);
		}


		addr=param[6];

		printf("\nSTART CODE AT 0x%02x%02x%02x%02x\n",memory[7],memory[6],memory[5],memory[4]);
		
		errc=prg_comm(0x128,8,12,0,0,0,0,0,0);	//set pc + sp	
		errc=prg_comm(0x12b,0,100,0,0,0,0,0,0);		//go
		
		if(errc == 0)
		{
			waitkey();
		}
		
	}

#include "dbg_cortex.c"

	errc|=prg_comm(0x9A,0,0,0,0,0x00,0x00,0x00,0x00);			//exit debug


	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
		i=prg_comm(0x0f,0,0,0,0,0,0,0,0);					//exit
	}

ERR_EXIT:

	i=prg_comm(0x91,0,0,0,0,0,0,0,0);					//SWIM exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	prg_comm(0xfe,0,0,0,0,0,0,0,0);		//disable PU

	print_kea64swd_error(errc);

	return errc;
}

