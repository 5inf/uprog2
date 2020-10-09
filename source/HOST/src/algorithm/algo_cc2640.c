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
#include "exec/cc2640/exec_cc2640.h"

void print_cc2640_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(TimeOut)",errc);
				break;

		case 0x42:	set_error("Bootloader: no start",errc);
				break;

		case 0x43:	set_error("(Wrong JTAD ID)",errc);
				break;

		case 0x44:	set_error("(Device is protected)",errc);
				break;

		case 0x45:	set_error("(Verify error)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int prog_cc2640(void)
{
	int errc,blocks,bsize;
	unsigned long addr,maddr,i,j;
	long len;
	int mass_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int info_readout=0;
	int dev_start=0;
	int run_ram=0;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- key: -- set key (hex)\n");

		printf("-- ea -- mass erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

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

	errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);	//enable PU

	if(find_cmd("rr"))
	{
		if(file_found < 2)
		{
			run_ram = 0;
			printf("## Action: runcode in RAM !! DISABLED BECAUSE OF NO FILE !!\n");
		}
		else
		{
			run_ram=1;
			printf("## Action: run code in RAM using %s\n",sfile);
		}
	}
	else
	{

		if(find_cmd("ea"))
		{
			mass_erase=1;
			printf("## Action: mass erase\n");
		}

		main_prog=check_cmd_prog("pm","code flash");
		main_verify=check_cmd_verify("vm","code flash");
		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
		info_readout=check_cmd_read("ri","info",&main_prog,&main_verify);

		if(find_cmd("st"))
		if(strstr(cmd,"st") && ((strstr(cmd,"st") - cmd) %2 == 1))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

	if((main_readout == 1) || (info_readout == 1))
	{
		errc=writeblock_open();
	}

	if(dev_start == 0)
	{
		printf("INIT DEVICE \n");
		errc=prg_comm(0x1C0,0,4,0,0,0,0,0,0);					//init
		printf("ID-REG     = %04X%04X\n",memory[2] + (memory[3] << 8),memory[0] + (memory[1] << 8));	
	}

	if(mass_erase == 1)
	{
		printf("MASS ERASE\n");
		errc=prg_comm(0x1c1,0,0,0,0,1,0,0,1);			//-> write
		i=prg_comm(0x0f,0,0,0,0,0,0,0,0);			//exit
		printf("RE-INIT DEVICE \n");
		errc=prg_comm(0x1C0,0,4,0,0,0,0,0,0);
		printf("ID-REG     = %04X%04X\n",memory[2] + (memory[3] << 8),memory[0] + (memory[1] << 8));
	}					//init
		errc=prg_comm(0x1c1,0,0,0,0,0,0,0,0);			//-> write

	errc=prg_comm(0x1c2,2048,16,0,0,0x40,0x00,0x00,0x00);		//init core
	printf("CM3 ID-REG = %04X%04X\n",memory[2] + (memory[3] << 8),memory[0] + (memory[1] << 8));	
//	show_data(4,5);


	if((run_ram == 0) && (errc == 0) && (main_prog == 1))
	{	
		len=sizeof(exec_cc2640);
		for(j=0;j<len;j++)
		{
			memory[j]=exec_cc2640[j];
		}
		printf("TRANSFER & EXEC LOADER\n");
//		show_data(0,8);

		blocks=(len + max_blocksize -1)/max_blocksize;
		i=0;

		maddr=0x00000000;		//mem addr
		addr =0x20000000;		///µC addr
		bsize=2048;
		
		i=0;

		progress("TRANSFER   ",blocks,0);
		
		while(len > 0)
		{
//			printf("ADDR = %08lX  LEN: %04X\n",addr,len);
			bsize=max_blocksize;
			errc=prg_comm(0x1c3,bsize,0,maddr,0,
					(addr) & 0xff,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 24) & 0xff);
	
			progress("TRANSFER   ",blocks,i+1);
			maddr+=bsize;
			addr+=bsize;
			len-=bsize;
			i++;
		}
		printf("\n");

		errc=prg_comm(0x1c4,0,0,0,0,memory[4],memory[5],memory[6],memory[7]);	//start cpu

		usleep(200000);

		if((main_prog == 1) && (errc == 0))
		{
			read_block(param[0],param[1],0);
			addr=param[0];
			bsize=max_blocksize;
			blocks=param[1] / bsize;
			maddr=0;
			
			progress("FLASH PROG ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,bsize) && (errc==0))
				{
//					printf("ADDR = %08lX  LEN: %08lX\n",addr,maddr);
					//transfer 2K
					errc=prg_comm(0x1c7,2048,0,maddr,0,
						addr & 0xff,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);
						while(prg_comm(0x1c8,0,0,0,0,0x00,0x28,0x00,0x20) != 0xFF);
				}
				addr+=bsize;
				maddr+=bsize;
				progress("FLASH PROG ",blocks,i+1);
			}
			printf("\n");
		}
	}
		if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
		{
			addr=param[0];
			bsize=max_blocksize;
			blocks=param[1] / bsize;
			maddr=0;
			progress("FLASH READ ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				prg_comm(0x1c5,0,bsize,0,ROFFSET+maddr,
					(addr) & 0xff,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 24) & 0xff);
				addr+=bsize;
				maddr+=bsize;
				progress("FLASH READ ",blocks,i+1);
			}
			printf("\nDONE\n");
		}


		if((main_readout == 1) && (errc == 0))
		{
			writeblock_data(0,param[1],param[0]);
		}

		if((info_readout == 1) && (errc == 0))
		{
			addr=0x50001000;
			bsize=max_blocksize;
			maddr=0;
			blocks=1;
			progress("INFO READ  ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				prg_comm(0x1c5,0,bsize,0,ROFFSET+maddr,
					(addr) & 0xff,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 24) & 0xff);
				addr+=bsize;
				maddr+=bsize;
				progress("FLASH READ ",blocks,i+1);
			}
			printf("\nDONE\n");
		}


		if((info_readout == 1) && (errc == 0))
		{
			writeblock_data(0,1024,0x50001000);
		}

		//verify main
		if((main_verify == 1) && (errc == 0))
		{
			read_block(param[0],param[1],0);
			addr = param[0];
			len = param[1];
			i=0;
			printf("CFLASH VERIFY\n");
			for(j=0;j<(len-40);j++)
			{
				if(memory[j] != memory[j+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr+j,memory[j],memory[j+ROFFSET]);
					errc=0x45;
				}
			}
		}


	if((run_ram == 1) && (errc == 0))
	{
		len=read_block(param[4],param[5],0);
		if (len < 1) len=read_block(0,param[5],0);
		if (len < 1 ) goto cc2640_END;

		printf("TRANSFER & START CODE\n");
		len+=2;
		printf("## transfer size: %ld bytes\n",len);

		blocks=(len + max_blocksize -1)/max_blocksize;
		i=0;

		progress("TRANSFER ",blocks,0);

		maddr=0x00000000;		//mem addr
		addr =0x20000000;		///µC addr
		
		while(len > 0)
		{
//			printf("ADDR = %08lX  LEN: %04X\n",addr,len);
			bsize=max_blocksize;
			errc=prg_comm(0x1c3,bsize,0,maddr,0,
					(addr) & 0xff,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 24) & 0xff);
	
			progress("TRANSFER ",blocks,i+1);
			maddr+=bsize;
			addr+=bsize;
			len-=bsize;
			i++;
		}

		printf("\nSET PC & GO\n");
		errc=prg_comm(0x1c4,0,0,0,0,memory[4],memory[5],memory[6],memory[7]);	//start cpu

		usleep(200000);

		if(errc == 0)
		{
			waitkey();
		}
/*
			errc=prg_comm(0x1c7,bsize,0,0,0,
					0x00,
					0x40,
					0x00,
					0x00);


			prg_comm(0x1c5,0,bsize,0,ROFFSET,
					0x00,
					0x28,
					0x00,
					0x20);

	show_data(ROFFSET,8);


			waitkey();
*/

	}

	if((main_readout == 1) || (info_readout == 1))
	{
		i=writeblock_close();
	}

	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);		//init
		waitkey();					//exit
	}

cc2640_END:

	i=prg_comm(0x0f,0,0,0,0,0,0,0,0);			//exit
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);		//dev 1




	print_cc2640_error(errc);
	return errc;
}


