//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2012-2022 Joerg Wolfram (joerg@jcwolfram.de)			#
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
#include "exec/stm32l4xx/exec_stm32l4xx.h"

void print_stm32l4_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(timeout: no ACK)",errc);
				break;

		case 0x42:	set_error("(timeout: prog/erase)",errc);
				break;

		case 0x50:	set_error("(wrong ID)",errc);
				break;

		case 0x60:	set_error("(Write Protection Error)",errc);
				break;

		case 0x61:	set_error("(Erase timeout error)",errc);
				break;



		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int stm32l4_wropt(int std)
{
	int i,e;
	
	if(std == 1)
	{
		//OPTR
		memory[0x103]=0xFF;	memory[0x102]=0xFF;	memory[0x101]=0xF8;	memory[0x100]=0xAA;
		//PCROP1_STRT
		memory[0x107]=0xFF;	memory[0x106]=0xFF;	memory[0x105]=0xFF;	memory[0x104]=0xFF;
		//PCROP1_END
		memory[0x10B]=0xFF;	memory[0x10A]=0xFF;	memory[0x109]=0x00;	memory[0x108]=0x00;
		//WRP1A
		memory[0x10F]=0xFF;	memory[0x10E]=0x00;	memory[0x10D]=0xFF;	memory[0x10C]=0xFF;
		//WRP1B
		memory[0x113]=0xFF;	memory[0x112]=0x00;	memory[0x111]=0xFF;	memory[0x110]=0xFF;
	}
	else
	{
		//OPTR
		memory[0x103]=memory[0x03];	memory[0x102]=memory[0x02];	memory[0x101]=memory[0x01];	memory[0x100]=memory[0x00];
		//PCROP1_STRT
		memory[0x107]=memory[0x0B];	memory[0x106]=memory[0x0A];	memory[0x105]=memory[0x09];	memory[0x104]=memory[0x08];
		//PCROP1_END
		memory[0x10B]=memory[0x13];	memory[0x10A]=memory[0x12];	memory[0x109]=memory[0x11];	memory[0x108]=memory[0x10];
		//WRP1A
		memory[0x10F]=memory[0x1B];	memory[0x10E]=memory[0x1A];	memory[0x10D]=memory[0x19];	memory[0x10C]=memory[0x18];
		//WRP1B
		memory[0x113]=memory[0x23];	memory[0x112]=memory[0x22];	memory[0x111]=memory[0x21];	memory[0x110]=memory[0x20];
	}
	i=0;
	// CR=0x00000000 (clear all)
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x14;		//TAR = CR
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//0x00 -> clear all

	// KEYR=0x45670123
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x08;		//TAR = KEYR
	memory[i++]=0xdd;	memory[i++]=0x45;	memory[i++]=0x67;	memory[i++]=0x01;		memory[i++]=0x23;

	// KEYR=0xCDEF89AB
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x08;		//TAR = KEYR
	memory[i++]=0xdd;	memory[i++]=0xCD;	memory[i++]=0xEF;	memory[i++]=0x89;		memory[i++]=0xAB;

	// OPTKEYR=0x08192A3B
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x0C;		//TAR = OPTKEYR
	memory[i++]=0xdd;	memory[i++]=0x08;	memory[i++]=0x19;	memory[i++]=0x2A;		memory[i++]=0x3B;

	// OPTKEYR=0x4C5D6E7F
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x0C;		//TAR = OPTKEYR
	memory[i++]=0xdd;	memory[i++]=0x4C;	memory[i++]=0x5D;	memory[i++]=0x6E;		memory[i++]=0x7F;

	// OPTR
	memory[i++]=0xd1;	memory[i++]=0x40;		memory[i++]=0x02;		memory[i++]=0x20;			memory[i++]=0x20;		//TAR = OPTR
	memory[i++]=0xdd;	memory[i++]=memory[0x103];	memory[i++]=memory[0x102];	memory[i++]=memory[0x101];		memory[i++]=memory[0x100];
	
	// PCROP1_STRT
	memory[i++]=0xd1;	memory[i++]=0x40;		memory[i++]=0x02;		memory[i++]=0x20;			memory[i++]=0x24;		//TAR = PCROP1_STRT
	memory[i++]=0xdd;	memory[i++]=memory[0x107];	memory[i++]=memory[0x106];	memory[i++]=memory[0x105];		memory[i++]=memory[0x104];

	// PCROP1_END
	memory[i++]=0xd1;	memory[i++]=0x40;		memory[i++]=0x02;		memory[i++]=0x20;			memory[i++]=0x28;		//TAR = PCROP1_END
	memory[i++]=0xdd;	memory[i++]=memory[0x10B];	memory[i++]=memory[0x10A];	memory[i++]=memory[0x109];		memory[i++]=memory[0x108];
	
	// WRP1A
	memory[i++]=0xd1;	memory[i++]=0x40;		memory[i++]=0x02;		memory[i++]=0x20;			memory[i++]=0x2C;		//TAR = WRP1A
	memory[i++]=0xdd;	memory[i++]=memory[0x10F];	memory[i++]=memory[0x10E];	memory[i++]=memory[0x10D];		memory[i++]=memory[0x10C];

	// WRP1B
	memory[i++]=0xd1;	memory[i++]=0x40;		memory[i++]=0x02;		memory[i++]=0x20;			memory[i++]=0x30;		//TAR = WRP1B
	memory[i++]=0xdd;	memory[i++]=memory[0x113];	memory[i++]=memory[0x112];	memory[i++]=memory[0x111];		memory[i++]=memory[0x110];

	// CLER SR
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x10;		//TAR = SR
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0xFF;		memory[i++]=0xFF;		//

	// CR=0x00020000 (OPTSTRT)
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x14;		//TAR = CR
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x02;	memory[i++]=0x00;		memory[i++]=0x00;		//0x00 -> clear all

	// SR
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x10;		//TAR = SR

//	printf( "SEND %d BYTES\npp\n",i);
//	waitkey();
	e=prg_comm(0x9d,i,0,0,ROFFSET,0,0,0,i/5);
	
	return e;
}


int stm32l4_erase(void)
{
	int i,e;
	
	i=0;
	// CR=0x00000000 (clear all)
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x14;		//TAR = CR
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//0x00 -> clear all

	// KEYR=0x45670123
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x08;		//TAR = KEYR
	memory[i++]=0xdd;	memory[i++]=0x45;	memory[i++]=0x67;	memory[i++]=0x01;		memory[i++]=0x23;

	// KEYR=0xCDEF89AB
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x08;		//TAR = KEYR
	memory[i++]=0xdd;	memory[i++]=0xCD;	memory[i++]=0xEF;	memory[i++]=0x89;		memory[i++]=0xAB;

	// CLER SR
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x10;		//TAR = SR
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x02;	memory[i++]=0xFF;		memory[i++]=0xFF;		//

	// CR=0x00000004 (MER1)
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x14;		//TAR = CR
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x04;		//MER1

	// CR=0x00010004 (MER1+STRT)
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x14;		//TAR = CR
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x01;	memory[i++]=0x00;		memory[i++]=0x04;		//MER1+STRT

	// SR
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x02;	memory[i++]=0x20;		memory[i++]=0x10;		//TAR = SR

//	printf( "SEND %d BYTES\n",i);
//	waitkey();
	e=prg_comm(0x9d,i,0,0,ROFFSET,0,0,0,i/5);
	return e;
}



int prog_stm32l4(void)
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
	int debug_ram=0;
	int debug_flash=0;
	int unsecure=0;
	int ignore_id=0;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		printf("-- eo -- option bytes erase (reset)\n");
		printf("-- po -- option bytes program\n");
		printf("-- vo -- option bytes verify\n");
		printf("-- ro -- option bytes readout\n");

		printf("-- ii -- ignore ID\n");

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
			goto stm32l4_ORUN;
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
			goto stm32l4_ORUN;
		}
	}
	else if(find_cmd("df"))
	{
		debug_flash = 1;
		printf("## Action: debug code in FLASH\n");
		goto stm32l4_ORUN;
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

		option_prog=check_cmd_prog("po","option bytes");
		option_verify=check_cmd_verify("vo","option bytes");
		option_readout=check_cmd_read("ro","option bytes",&option_prog,&option_verify);

		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

stm32l4_ORUN:

	//open file if read 
	if((main_readout == 1) || (option_readout == 1))
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

		printf("ID : %03X\n",((memory[ROFFSET+0x01] << 8) + memory[ROFFSET+0x00]) & 0xfff);
		if((ignore_id == 0) && ((((memory[ROFFSET+0x01] << 8) + memory[ROFFSET+0x00]) & 0xfff) > 0xf00)) errc=0x50;

		if((option_erase == 1) && (errc == 0))
		{
			progress("OPT RESET",10,0);
			errc=stm32l4_wropt(1);
			if(errc > 0) goto STM32_EXIT;
				
			i=0;j=0;
				
			while(i==0)
			{
				progress("OPT RESET",10,j+1);
				errc=prg_comm(0x194,0,4,0,0,0,0,0,0);		// read DRWX
				j++;
				if(j>10) i=1;
				if(((memory[2] & 1) == 0) && (errc==0)) i=1;
		
			}
			progress("OPT RESET",10,11);
			printf("\n");

			printf("RE-INIT\n");
			errc=prg_comm(0xbe,0,16,0,0,0,0,0,0);		//re-init
			if(errc > 0) goto STM32_EXIT;
		}

		if((main_erase == 1) && (errc == 0))
		{
			progress("FLASH ERASE",10,0);
			errc=stm32l4_erase();
			if(errc > 0) goto STM32_EXIT;
				
			i=0;j=0;
				
			while(i==0)
			{
				progress("FLASH ERASE",10,j+1);
				errc=prg_comm(0x194,0,4,0,0,0,0,0,0);		// read DRWX
				j++;
				if(j>10) i=1;
				if(((memory[2] & 1) == 0) && (errc==0)) i=1;
		
			}
			progress("FLASH ERASE",10,11);
			printf("\n");
			
			printf("RE-INIT\n");
//			prg_comm(0x0f,0,0,0,0,0,0,0,0);			//exit
			errc=prg_comm(0xbe,0,16,0,0,0,0,0,0);		//re-init
			if(errc > 0) goto STM32_EXIT;
		}

		//transfer loader to ram
		if((run_ram == 0) && (errc == 0) && ((main_prog == 1) || (option_prog == 1) || (option_erase == 1) || (unsecure == 1)))
		{
			printf("TRANSFER LOADER...");
			for(j=0;j<1024;j++)
			{
				memory[j]=exec_stm32l4xx[j];
			}

			addr=param[4];				//RAM start

			errc=prg_comm(0xb2,0x400,0,0,0,		//write 1 K bootloader
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff,
				4);

//			printf("\nSTART CODE AT 0x%02x%02x%02x%02x\n",memory[7],memory[6],memory[5],memory[4]);
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

		if((option_prog == 1) && (errc == 0))
		{
			read_block(param[2],param[3],0);	//read option bytes
			progress("OPT PROG",10,0);
			errc=stm32l4_wropt(0);
			if(errc > 0) goto STM32_EXIT;
				
			i=0;j=0;
				
			while(i==0)
			{
				progress("OPT PROG",10,j+1);
				errc=prg_comm(0x194,0,4,0,0,0,0,0,0);		// read DRWX
				j++;
				if(j>10) i=1;
				if(((memory[2] & 1) == 0) && (errc==0)) i=1;
		
			}
			progress("OPT PROG",10,11);
			printf("\n");
		}


		if(((option_readout == 1) || (option_verify == 1)) && (errc == 0))
		{
			printf("READ OPTIONBYTES   :\n");

			for(i=0;i<10;i++)
			{
				addr=param[2]+4*i;
	
				errc=prg_comm(0x1d1,0,4,0,ROFFSET+4*i,
					addr & 0xff,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 24) & 0xff);
			}


			printf(" %02X%02X%02X%02X - ",memory[ROFFSET+0x03],memory[ROFFSET+0x02],memory[ROFFSET+0x01],memory[ROFFSET+0x00]);
			printf(" %02X%02X%02X%02X      ",memory[ROFFSET+0x07],memory[ROFFSET+0x06],memory[ROFFSET+0x05],memory[ROFFSET+0x04]);

			printf("USER OPT:     %02X%02X%02X       RDP: %02X\n",	memory[ROFFSET+0x03],memory[ROFFSET+0x02],memory[ROFFSET+0x01],memory[ROFFSET+0x00]);

			printf(" %02X%02X%02X%02X - ",memory[ROFFSET+0x0B],memory[ROFFSET+0x0A],memory[ROFFSET+0x09],memory[ROFFSET+0x08]);
			printf(" %02X%02X%02X%02X      ",memory[ROFFSET+0x0F],memory[ROFFSET+0x0E],memory[ROFFSET+0x0D],memory[ROFFSET+0x0C]);

			printf("PCROPR1_STRT: %02X%02X\n",memory[ROFFSET+0x08],memory[ROFFSET+0x09]);

			printf(" %02X%02X%02X%02X - ",memory[ROFFSET+0x13],memory[ROFFSET+0x12],memory[ROFFSET+0x11],memory[ROFFSET+0x10]);
			printf(" %02X%02X%02X%02X      ",memory[ROFFSET+0x17],memory[ROFFSET+0x16],memory[ROFFSET+0x15],memory[ROFFSET+0x14]);

			printf("PCROPR1_END:  %02X%02X         RDP: %d\n",memory[ROFFSET+0x10],memory[ROFFSET+0x11],(memory[ROFFSET+0x13] >> 7));

			printf(" %02X%02X%02X%02X - ",memory[ROFFSET+0x1B],memory[ROFFSET+0x1A],memory[ROFFSET+0x19],memory[ROFFSET+0x18]);
			printf(" %02X%02X%02X%02X      ",memory[ROFFSET+0x1F],memory[ROFFSET+0x1E],memory[ROFFSET+0x1D],memory[ROFFSET+0x1C]);

			printf("WRP1A_STRT:   %02X     WRP1A_END: %02X\n",memory[ROFFSET+0x18],memory[ROFFSET+0x1A]);

			printf(" %02X%02X%02X%02X - ",memory[ROFFSET+0x23],memory[ROFFSET+0x22],memory[ROFFSET+0x21],memory[ROFFSET+0x20]);
			printf(" %02X%02X%02X%02X      ",memory[ROFFSET+0x27],memory[ROFFSET+0x26],memory[ROFFSET+0x25],memory[ROFFSET+0x24]);

			printf("WRP1B_STRT:   %02X     WRP1B_END: %02X\n",memory[ROFFSET+0x20],memory[ROFFSET+0x22]);

			printf("\n");

		}

		if((option_readout == 1) && (errc == 0))
		{
			writeblock_data(0,param[3],param[2]);
		}

		//verify option bytes
		if((option_verify == 1) && (errc == 0))
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
		if((main_readout == 1) || (option_readout == 1))
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

		errc=prg_comm(0x12b,0,100,0,0,0,0,0,0);	

		if(errc == 0)
		{
			waitkey();
		}
		
	}

	if((debug_ram==1) && (errc==0)) debug_armcortex(0);
	if((debug_flash==1) && (errc==0)) debug_armcortex(1);

	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
		i=prg_comm(0x0f,0,0,0,0,0,0,0,0);					//exit
	}

STM32_EXIT:

	i=prg_comm(0x91,0,0,0,0,0,0,0,0);					//SWIM exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_stm32l4_error(errc);

	return errc;
}

