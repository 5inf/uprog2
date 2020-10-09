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
#include "exec/stm32f0xx/exec_stm32f0xx.h"
#include "exec/stm32f1xx/exec_stm32f1xx.h"
#include "exec/stm32f2xx/exec_stm32f2xx.h"
#include "exec/stm32f3xx/exec_stm32f3xx.h"
#include "exec/stm32f4xx/exec_stm32f4xx.h"
#include "exec/stm32l4xx/exec_stm32l4xx.h"

void print_stm32swd_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(timeout: no ACK)",errc);
				break;

		case 0x50:	set_error("(wrong ID)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

void show_stm32swd_registers(void)
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

int prog_stm32swd(void)
{
	int errc,blocks,i,j;
	unsigned long addr,len,maddr;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dev_start=0;
	int run_ram=0;
	int option_erase=0;
	int option_prog=0;
	int option_verify=0;
	int option_readout=0;
	int unsecure=0;
	int ignore_id=0;
	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		printf("-- eo -- option bytes erase\n");
		printf("-- po -- option bytes program\n");
		printf("-- vo -- option bytes verify\n");
		printf("-- ro -- option bytes readout\n");

		printf("-- ii -- ignore ID\n");

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

	if(find_cmd("ii"))
	{
		ignore_id=1;
		printf("## ignore ID\n");
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

		if(find_cmd("em"))
		{
			main_erase=1;
			printf("## Action: main flash erase\n");
		}


		if(find_cmd("eo"))
		{
			option_erase=1;
			printf("## Action: option bytes erase\n");
		}

		main_prog=check_cmd_prog("pm","code flash");
		main_verify=check_cmd_verify("vm","code flash");
		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);

		if(algo_nr < 37)
		{
			option_prog=check_cmd_prog("po","option bytes");
			option_verify=check_cmd_verify("vo","option bytes");
			option_readout=check_cmd_read("ro","option bytes",&option_prog,&option_verify);
		}
		else
		{
			if(find_cmd("po"))
			{
				if(have_expar == 1)
				{
					printf("## Action: option bytes program to %08lX\n",expar);
					option_prog=1;
				}
				else
				{
					printf("## Action: option bytes disabled (no value given)\n");
					option_prog=0;
				}
			}
			if(find_cmd("ro"))
			{
				printf("## Action: option bytes readout\n");
				option_readout=1;
			}
		}

		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

	//open file if read 
	if((main_readout == 1) || ((option_readout == 1) && (algo_nr < 37)))
	{
		errc=writeblock_open();
	}

	if(errc > 0) goto STM32_EXIT;

	if(dev_start == 0)
	{
		errc=prg_comm(0xbe,0,16,0,0,0,0,0,0);					//init

		if(errc > 0) 
		{
			printf("ACK STATUS: %d\n",memory[0]);
			goto STM32_EXIT;
		}

		printf("JID: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);


		errc=prg_comm(0xbf,0,256,0,ROFFSET,0x20,0x04,0xe0,1);

		if(algo_nr < 53)
		{
			printf("ID : %03X\n",((memory[ROFFSET+0x01] << 8) + memory[ROFFSET+0x00]) & 0xfff);
			if((ignore_id == 0) && ((((memory[ROFFSET+0x01] << 8) + memory[ROFFSET+0x00]) & 0xfff) > 0xf00)) errc=0x50;
		}

//		printf("DHCSR: %02X%02X%02X%02X\n",memory[7],memory[6],memory[5],memory[4]);
//		printf("DEMCR: %02X%02X%02X%02X\n",memory[11],memory[10],memory[9],memory[8]);
//		printf("DHCSR: %02X%02X%02X%02X\n",memory[15],memory[14],memory[13],memory[12]);


		if((option_erase == 1) && (errc == 0) && (algo_nr < 37) && (param[9] > 0))
		{
			printf("ERASE OPTIONBYTES\n");
			errc=prg_comm(0x4e,0,4,0,0,param[9],0,0,0);	//erase direct
//			show_data(0,4);
			printf("RE-INIT\n");
			errc=prg_comm(0xbe,0,16,0,0,0,0,0,0);		//re-init
		}

		

		if((main_erase == 1) && (errc == 0))
		{
			printf("ERASE FLASH\n");
			errc=prg_comm(0x4e,0,4,0,0,param[8],0,0,0);	//erase direct
//			show_data(0,4);
			printf("RE-INIT\n");
			errc=prg_comm(0xbe,0,16,0,0,0,0,0,0);		//re-init
		}





		//transfer loader to ram
		if((run_ram == 0) && (errc == 0) && ((main_prog == 1) || (option_prog == 1) || (option_erase == 1) || (unsecure == 1)))
		{
			printf("TRANSFER LOADER...");
			for(j=0;j<512;j++)
			{
				switch(algo_nr)
				{
					case 33:	memory[j]=exec_stm32f0xx[j]; break;
					case 34:	memory[j]=exec_stm32f1xx[j]; break;
					case 35:	memory[j]=exec_stm32f2xx[j]; break;
					case 36:	memory[j]=exec_stm32f3xx[j]; break;
					case 37:	memory[j]=exec_stm32f4xx[j]; break;
					case 52:	memory[j]=exec_stm32l4xx[j]; break;
					default:	memory[j]=0xff;
				}
			}

			addr=param[4];				//RAM start

			errc=prg_comm(0xb2,0x200,0,0,0,		//write 1 K bootloader
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff,
				2);

//		
			errc=prg_comm(0x128,8,12,0,0,	
				addr & 0xff,
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff);

			errc=prg_comm(0x12b,0,64,0,0,0,0,0,0);	

			printf("STARTED\n");


/*
			errc=prg_comm(0xb3,8,12,0,0,		//go
				addr & 0xff,			
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff);
*/		}
	}
	
	if((run_ram == 0) && (errc == 0) && (dev_start == 0))
	{
		
		if((unsecure == 1) && (errc == 0) && (algo_nr == 37))
		{
			printf("UNSECURE DEVICE\n");
			expar=0x00FFAAED;
			have_expar=1;
			option_prog = 1;
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

			errc=prg_comm(0x59,0,0,0,0,0x55,0x00,0x00,0x00);			//unlock main

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


		if((option_prog == 1) && (errc == 0) && (algo_nr < 37))
		{
			printf("PROGRAM OPTIONBYTES: ");
			read_block(param[2],param[3],0);	//read option bytes
			addr=param[2];
			maddr=0;

			printf("ADDR = %08lX\n",addr);
			
			show_data(0,16);
			
			//transfer data
			errc=prg_comm(0xb2,256,0,maddr,0,
			0x04,0x00,0x20,1);

			//execute prog
			errc=prg_comm(0x59,0,0,0,0,
					0x72,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 24) & 0xff);

			for(i=0;i<16;i++) printf(" %02X",memory[i]);

			printf("\n");
		}

		if((option_prog == 1) && (errc == 0) && (algo_nr == 37))
		{
			printf("PROGRAM OPTIONBYTES: ");
			memory[0]=expar & 0xff;
			memory[1]=(expar >> 8) & 0xff;
			memory[2]=(expar >> 16) & 0xff;
			memory[3]=(expar >> 24) & 0xff;

			//transfer data
			errc=prg_comm(0xb2,256,0,0,0,0x04,0x00,0x20,1);

			//execute prog
			errc=prg_comm(0x59,0,0,0,0,0x72,0,0,0);

			printf(" %02X %02X %02X %02X\n",memory[3],memory[2],memory[1],memory[0]);
			printf("\n");
		}


		if(((option_readout == 1) || (option_verify == 1)) && (errc == 0) && (algo_nr < 37))
		{
			addr=param[2];

//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,algo_nr);
			

			printf("READ OPTIONBYTES   : ");

			errc=prg_comm(0xbf,0,256,0,ROFFSET,
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff,
				1);

			for(i=0;i<16;i++) printf(" %02X",memory[ROFFSET+i]);

			printf("\n");
		}


		if(((option_readout == 1) || (option_verify == 1)) && (errc == 0) && (algo_nr == 37))
		{
			addr=0x40023c00;

//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,algo_nr);
			
			errc=prg_comm(0xbf,0,256,0,ROFFSET,
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff,
				1);

			printf("READ OPTIONBYTES BLOCK 1  : ");

			printf(" %02X %02X %02X %02X\n",	memory[ROFFSET+0x17],
							memory[ROFFSET+0x16],
							memory[ROFFSET+0x15],
							memory[ROFFSET+0x14]);


			printf("READ OPTIONBYTES BLOCK 2  : ");

			printf(" %02X %02X %02X %02X\n",	memory[ROFFSET+0x1B],
							memory[ROFFSET+0x1A],
							memory[ROFFSET+0x19],
							memory[ROFFSET+0x18]);

			printf("\n");

			addr=param[2];

//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,algo_nr);
			
			errc=prg_comm(0xbf,0,16,0,ROFFSET,
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff,
				1);
			
			for(i=0;i<16;i++) printf(" %02X",memory[ROFFSET+i]);

			printf("\n");

			
		}


		if((option_readout == 1) && (errc == 0) && (algo_nr < 37))
		{
			writeblock_data(0,param[3],param[2]);
		}

		//verify option bytes
		if((option_verify == 1) && (errc == 0) && (algo_nr < 37))
		{
			read_block(param[2],param[3],0);	//read option bytes
			printf("VERIFY OPTION BYTES\n");
			addr = param[2];
			len = param[3];
			maddr=0;
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


		//open file if was read 
		if((main_readout == 1) || ((option_readout == 1) && (algo_nr < 37)))
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


/*		errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
		show_stm32swd_registers();		


		for(i=0;i<120;i++)
		{
			errc=prg_comm(0x129,0,100,0,0,0,0,0,0);	
//			show_stm32swd_registers();		
		}
		
*/
		errc=prg_comm(0x12b,0,100,0,0,0,0,0,0);	

/*		errc=prg_comm(0x129,0,100,0,0,0,0,0,0);	
		show_stm32swd_registers();		

*/

//		printf("DHCSR: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
//		printf("SP   : %02X%02X%02X%02X\n",memory[7],memory[6],memory[5],memory[4]);
//		printf("PC   : %02X%02X%02X%02X\n",memory[11],memory[10],memory[9],memory[8]);		
		
		if(errc == 0)
		{
			waitkey();
		}
		

		//read back
/**		
		addr=0x20000000;
		
		errc=prg_comm(0xbf,0,2048,0,ROFFSET,
		(addr >> 8) & 0xff,
		(addr >> 16) & 0xff,
		(addr >> 24) & 0xff,
		max_blocksize >> 8);

		show_data(ROFFSET,16);
**/		
	}

	errc|=prg_comm(0x9A,0,0,0,0,0x00,0x00,0x00,0x00);			//exit debug


	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
		i=prg_comm(0x0f,0,0,0,0,0,0,0,0);					//exit
	}

STM32_EXIT:

	i=prg_comm(0x91,0,0,0,0,0,0,0,0);					//SWIM exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_stm32swd_error(errc);

	return errc;
}

