//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2012-2020 Joerg Wolfram (joerg@jcwolfram.de)			#
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
#include "exec/s32k/exec_s32k.h"

void print_s32kswd_error(int errc)
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

		case 0x50:	set_error("(wrong ID)",errc);
				break;

		case 0x51:	set_error("(verify error)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

void show_s32kswd_registers(void)
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

int prog_s32kswd(void)
{
	int errc,blocks,i,j;
	unsigned long addr,len,maddr;
	int mass_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int data_prog=0;
	int data_verify=0;
	int data_readout=0;
	int dev_start=0;
	int run_ram=0;
	int unsecure=0;
	int ignore_id=0;
	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- ea -- erase all (mass erase)\n");
		printf("-- un -- unsecure code (set FSEC to 0xFE)\n");
//		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");
		printf("-- pd -- data flash program\n");
		printf("-- vd -- data flash verify\n");
		printf("-- rd -- data flash readout\n");
		printf("-- ii -- ignore ID\n");

		printf("-- rr -- run code in RAM\n");
		printf("-- st -- start device\n");
 		printf("-- d2 -- switch to device 2\n");

		return 0;
	}

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

	if(find_cmd("ii"))
	{
		ignore_id=1;
		printf("## ignore ID\n");
	}

	if(find_cmd("un"))
	{
		unsecure=1;
		printf("## unsecure code\n");
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
		if(find_cmd("un"))
		{
			unsecure=1;
			printf("## Action: unsecure device\n");
		}

/*		if(find_cmd("em"))
		{
			main_erase=1;
			printf("## Action: main flash erase\n");
		}
*/
		if(find_cmd("ea"))
		{
			mass_erase=1;
			printf("## Action: mass erase\n");
		}

		main_prog=check_cmd_prog("pm","code flash");
		main_verify=check_cmd_verify("vm","code flash");
		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
		data_prog=check_cmd_prog("pd","data flash");
		data_verify=check_cmd_verify("vd","data flash");
		data_readout=check_cmd_read("rd","data flash",&data_prog,&data_verify);

		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

	//open file if read 
	if((main_readout == 1) || (data_readout == 1))
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
			printf("ERASE FLASH\n");
			errc=prg_comm(0x1D2,0,4,0,0,0,0,0,0);		//erase direct
			if(errc > 0) goto ERR_EXIT;
//			show_data(0,4);
			printf("RE-INIT\n");
			errc=prg_comm(0x91,0,0,0,0,0,0,0,0);					//SWIM exit
			errc=prg_comm(0x1D0,0,16,0,0,0,0,0,0);		//re-init
		}
		else
		{
			errc=prg_comm(0x1D0,0,16,0,0,0,0,0,0);					//init
			printf("JID: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
		}


		errc=prg_comm(0x1D1,0,4,0,0,0x24,0x80,0x04,0x40);				//READ DEVID
		j=(memory[3] >> 4)*100+(memory[3] & 0x0F)*10+(memory[2] >> 4);
		if((j != param[10]) && (ignore_id==0))
		{
			printf("DEVICE CODE = %d, SHOULD BE %d\n",j,(int)param[10]);
			errc=0x50;	
			goto ERR_EXIT;
		}
		else
		{
			printf("DEVICE: S32K%d\n",j);
			if(memory[0] & 0x80) printf("++ Security\n");
			if(memory[0] & 0x40) printf("++ ISO CAN-FD\n");
			if(memory[0] & 0x20) printf("++ FlexIO\n");
			if(memory[0] & 0x10) printf("++ QuadSPI\n");
			if(memory[0] & 0x08) printf("++ Ethernet\n");
			if(memory[0] & 0x04) printf("++ undef (2)\n");
			if(memory[0] & 0x02) printf("++ SAI\n");
			if(memory[0] & 0x01) printf("++ undef (0)\n");
		}


		//transfer loader to ram
		if((run_ram == 0) && (errc == 0) && ((main_prog == 1) || (data_prog == 1)))
		{
			printf("TRANSFER LOADER\n");
			for(j=0;j<512;j++)
			{
				switch(algo_nr)
				{
					case 53:	memory[j]=exec_s32k[j]; break;
					default:	memory[j]=0xff;
				}
			}

			addr=param[4];				//RAM start

			errc=prg_comm(0xb2,0x200,0,0,0,		//write 0,5 K bootloader
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff,
				2);
		
			errc=prg_comm(0x128,8,12,0,0,	
					addr & 0xff,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 24) & 0xff);

			errc=prg_comm(0x12b,0,64,0,0,0,0,0,0);	

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
			if(unsecure==1) memory[0x40c]=0xFE;
			progress("FLASH PROG  ",blocks,0);
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);

			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,max_blocksize) && (errc==0))
				{
					//transfer data
					errc=prg_comm(0xb2,max_blocksize,0,maddr,0,
						0x04,0x00,0x20,max_blocksize >> 8);

					//execute prog
					errc=prg_comm(0x59,0,0,0,0,
						0x52,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);

				}
				addr+=max_blocksize;
				maddr+=max_blocksize;
				progress("FLASH PROG  ",blocks,i+1);
			}
			printf("\n");
		}

		if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
		{
			maddr=0;
			addr=param[0];
			blocks=param[1]/max_blocksize;
			progress("FLASH READ  ",blocks,0);
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
					progress("FLASH READ  ",blocks,i+1);
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
			if(unsecure==1) memory[0x40c]=0xFE;
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


		if((data_prog == 1) && (errc == 0))
		{
			addr=param[2];
			maddr=0;
			blocks=param[3]/max_blocksize;
			len=read_block(param[2],param[3],0);		//read flash
			progress("DFLASH PROG ",blocks,0);
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);

			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,max_blocksize) && (errc==0))
				{
					//transfer data
					errc=prg_comm(0xb2,max_blocksize,0,maddr,0,
						0x04,0x00,0x20,max_blocksize >> 8);

					//execute prog
					errc=prg_comm(0x59,0,0,0,0,
						0x52,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);

				}
				addr+=max_blocksize;
				maddr+=max_blocksize;
				progress("DFLASH PROG ",blocks,i+1);
			}
			printf("\n");
		}

		if(((data_readout == 1) || (data_verify == 1)) && (errc == 0))
		{
			maddr=0;
			addr=param[2];
			blocks=param[3]/max_blocksize;
//			addr=0x20000000;
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);
			progress("DFLASH READ ",blocks,0);
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
					progress("DFLASH READ ",blocks,i+1);
				}
			}
			printf("\n");
		}


		if((data_readout == 1) && (errc == 0))
		{
			writeblock_data(0,param[3],param[2]);
		}

		//verify data
		if((data_verify == 1) && (errc == 0))
		{
			read_block(param[2],param[3],0);
			printf("VERIFY DFLASH (%ld KBytes)\n",param[3]/1024);
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
		if((main_readout == 1) || (data_readout == 1))
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


		addr=param[4];

		printf("\nSTART CODE AT 0x%02x%02x%02x%02x\n",memory[7],memory[6],memory[5],memory[4]);
		
		errc=prg_comm(0x128,8,12,0,0,0,0,0,0);	//set pc + sp	

/*
		errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
		show_s32kswd_registers();		


		for(i=0;i<24;i++)
		{
			errc=prg_comm(0x129,0,100,0,0,0,0,0,0);	
			show_s32kswd_registers();		
			waitkey();
		}
		
*/
		errc=prg_comm(0x12b,0,100,0,0,0,0,0,0);	
/*
		errc=prg_comm(0x129,0,100,0,0,0,0,0,0);	
		show_s32kswd_registers();		

*/

//		printf("DHCSR: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
//		printf("SP   : %02X%02X%02X%02X\n",memory[7],memory[6],memory[5],memory[4]);
//		printf("PC   : %02X%02X%02X%02X\n",memory[11],memory[10],memory[9],memory[8]);		
		
		if(errc == 0)
		{
			waitkey();
		}
		

		//read back
		addr=0x20000000;
		
		errc=prg_comm(0xbf,0,2048,0,ROFFSET,
		(addr >> 8) & 0xff,
		(addr >> 16) & 0xff,
		(addr >> 24) & 0xff,
		1);

//		show_data(ROFFSET,16);
		

	}

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

	print_s32kswd_error(errc);

	return errc;
}

