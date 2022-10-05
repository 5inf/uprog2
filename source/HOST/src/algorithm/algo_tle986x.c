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
#include "exec/tle986x/exec_tle986x.h"

void print_tle986x_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x01:	set_error("(Verify error)",errc);
				break;


		case 0x41:	set_error("(timeout: no ACK)",errc);
				break;

		case 0x50:	set_error("(wrong ID)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


void print_tle986x_ackstat(int stat)
{
	switch(stat)
	{
		case 4:		printf("ACK STATUS: OK\n");
				break;
		case 2:		printf("ACK STATUS: WAIT\n");
				break;
		case 1:		printf("ACK STATUS: FAULT\n");
				break;
		default:	printf("ACK STATUS: CONN LOST\n");
	}		
}

int prog_tle986x(void)
{
	int errc,blocks,i,j;
	unsigned long addr,len,maddr;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dev_start=0;
	int run_ram=0;
	int udata_erase=0;
	int udata_prog=0;
	int udata_verify=0;
	int udata_readout=0;
	int lock_readout=0;
	int unsecure=0;
	int dlock=0;
	int debug_ram=0;
	int debug_flash=0;
	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
//		printf("-- un -- unsecure\n");
		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		printf("-- rr -- run code in RAM\n");
		printf("-- dr -- debug code in RAM\n");
		printf("-- df -- debug code in FLASH\n");
		printf("-- st -- start device\n");
 		printf("-- d2 -- switch to device 2\n");

		return 0;
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
			goto tle986x_ORUN;
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
			goto tle986x_ORUN;
		}
	}
	else if(find_cmd("df"))
	{
		debug_flash = 1;
		printf("## Action: debug code in FLASH\n");
		goto tle986x_ORUN;
	}
	else
	{
		if(find_cmd("em"))
		{
			main_erase=1;
			printf("## Action: main flash erase\n");
		}


		main_prog=check_cmd_prog("pm","code flash");
		main_verify=check_cmd_verify("vm","code flash");
		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);

		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

tle986x_ORUN:

	//open file if read 
	if((main_readout == 1) || (udata_readout == 1) || (lock_readout == 1))
	{
		errc=writeblock_open();
	}

	if(errc > 0) goto tle986x_EXIT;

	if(dev_start == 0)
	{
		errc=prg_comm(0x253,0,64,0,0,0,0,0,0);					//init

		printf("JID:   %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
		printf("CPUID: %02X%02X%02X%02X\n",memory[7],memory[6],memory[5],memory[4]);

		if(errc > 0) 
		{
			print_tle986x_ackstat(memory[63]);
			goto tle986x_EXIT;
		}

		//transfer loader to ram
		if((run_ram == 0) && (errc == 0) && ((main_prog == 1) || (main_erase == 1)))
		{
			printf("TRANSFER LOADER...");
			for(j=0;j<512;j++)
			{
				memory[j]=exec_tle986x[j];
			}

			addr=param[4];

			errc=prg_comm(0xb2,0x200,0,0,0,		//write 1 K bootloader
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

			printf("STARTED\n");

		}
	}
	
	if((run_ram == 0) && (errc == 0) && (dev_start == 0))
	{
		
		if((main_erase == 1) && (errc == 0))
		{
			addr=param[0];
			blocks=param[1]/max_blocksize;

			progress("FLASH ERASE ",blocks,0);

			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,max_blocksize) && (errc==0))
				{
					//execute prog
					errc=prg_comm(0x4A,0,0,0,0,
						0x54,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);
					//	printf("ADDR=%08lX (%08lX)\n",addr,memory[maddr+0]+(memory[maddr+1] << 8)+(memory[maddr+2] << 16)+(memory[maddr+3] << 24));

				}
				addr+=max_blocksize;
				progress("FLASH ERASE ",blocks,i+1);
			}
			printf("\n");

//			printf("RE-INIT\n");

//			errc=prg_comm(0x253,0,64,0,0,0,0,0,0);					//init

//			printf("JID:   %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
//			printf("CPUID: %02X%02X%02X%02X\n",memory[7],memory[6],memory[5],memory[4]);

		}

		if((main_prog == 1) && (errc == 0))
		{
			addr=param[0];
			maddr=0;
			blocks=param[1]/max_blocksize;
			len=read_block(param[0],param[1],0);			//read flash
			if(len==0) len=read_block(0,param[1],0);		//read flash from addr=0

			progress("FLASH PROG ",blocks,0);
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);

//			errc=prg_comm(0x59,0,0,0,0,0x55,0x00,0x00,0x00);			//unlock main

			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,max_blocksize) && (errc==0))
				{
					//transfer data
					errc=prg_comm(0xb2,max_blocksize,0,maddr,0,
						0x04,0x00,0x18,max_blocksize >> 8);

					//execute prog
					errc=prg_comm(0x4A,0,0,0,0,
						0x52,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);
					//	printf("ADDR=%08lX (%08lX)\n",addr,memory[maddr+0]+(memory[maddr+1] << 8)+(memory[maddr+2] << 16)+(memory[maddr+3] << 24));

				}
				addr+=max_blocksize;
				maddr+=max_blocksize;
				progress("FLASH PROG ",blocks,i+1);
			}
			printf("\n");
		}

		if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
		{
			maddr=0;
			addr=param[0];
			blocks=param[1]/max_blocksize;
//			addr=0x20000000;
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);
			progress("FLASH READ ",blocks,0);
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
					progress("FLASH READ ",blocks,i+1);
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
			len=read_block(param[0],param[1],0);			//read flash
			if(len==0) len=read_block(0,param[1],0);		//read flash from addr=0
			printf("VERIFY DATA (%ld KBytes)\n",param[1]/1024);
			addr = param[0];
			maddr=0;
			len = param[1];
			for(j=0;j<len;j++)
			{
				if(memory[maddr+j] != memory[maddr+j+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr+j,memory[maddr+j],memory[maddr+j+ROFFSET]);
					errc=1;
				}
			}
		}


		//close file if was read 
		if((main_readout == 1) || (udata_readout == 1) || (lock_readout == 1))
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

		addr=param[4];
		printf("TRANSFER & START CODE (ADDR = %08X)\n",addr & 0xFFFFFFFF);
		maddr=0;
		blocks=(param[5]+2047) >> 11;

		progress("TRANSFER ",blocks,0);

		for(i=0;i<blocks;i++)
		{
			errc=prg_comm(0xb2,max_blocksize,0,maddr,0,		//write 1.K
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff,
				max_blocksize >> 8);
		
			addr+=max_blocksize;
			maddr+=max_blocksize;
			progress("TRANSFER ",blocks,i+1);
		}


		addr=param[4];

		printf("\n");

		printf("START CODE AT 0x%02x%02x%02x%02x\n",memory[7],memory[6],memory[5],memory[4]);
		
		errc=prg_comm(0x128,8,12,0,0,0,0,0,0);	//set pc + sp	
		errc=prg_comm(0x12b,0,100,0,0,0,0,0,0);	
		
		if(errc == 0)
		{
			waitkey();
		}
//		memory[0]=18;	//LONGS TO READ
//		errc=prg_comm(0x23c,2,68,0,0,0x00,0x80,0x02,0x48);	//set pc + sp	
//		show_data(0,68);

	}


	if((debug_ram == 1) && (errc==0)) debug_armcortex(0);
	if((debug_flash == 1) && (errc==0)) debug_armcortex(1);

	errc|=prg_comm(0x9A,0,0,0,0,0x00,0x00,0x00,0x00);			//exit debug


	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
		i=prg_comm(0x0f,0,0,0,0,0,0,0,0);					//exit
	}

tle986x_EXIT:

	i=prg_comm(0x91,0,0,0,0,0,0,0,0);					//SWIM exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_tle986x_error(errc);

	return errc;
}

