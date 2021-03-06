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
#include "exec/ppcjtag_0b/exec_ppcjtag.h"
#include "exec/ppcjtag_0p/exec_ppcjtag.h"

extern unsigned char proto_shadow_0b[16384];
extern unsigned char proto_shadow_0p[16384];


void print_ppcjtag_error(int errc)
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

void ppcjtag_setcpu(void)
{
	memory[ 0]=0x00;		//WBBRl
	memory[ 1]=0x00;
	memory[ 2]=0x00;
	memory[ 3]=0x00;

	memory[ 4]=0x00;		//WBBRh
	memory[ 5]=0x00;
	memory[ 6]=0x00;
	memory[ 7]=0x00;
		
	memory[ 8]=0x00;		//MSR
	memory[ 9]=0x00;
	memory[10]=0x00;
	memory[11]=0x00;
		
	memory[12]=0xFE;		//PC
	memory[13]=0x00;
	memory[14]=0x00;
	memory[15]=0x40;
		
	memory[16]=0x22;		//IR
	memory[17]=0x44;
	memory[18]=0x22;
	memory[19]=0x44;
		
	memory[20]=0x03;		//CTL
	memory[21]=0x00;
	memory[22]=0x00;
	memory[23]=0x00;

	prg_comm(0x180,24,0,0,0,0,0,0,0);		//-> write CPUSCR
}


void ppcjtag_oncestat(void)
{
	unsigned short stat;
	prg_comm(0x185,0,2,0,0,0,0,0,0);					//read OnCE status register
	stat=memory[0] + (memory[1] << 8);
	printf("OnCE-STAT = %04X\n",stat);	
	prg_comm(0x179,0,0,0,0,0,0,0,0);					//enable Nexus
}

int prog_ppcjtag(void)
{
	int errc,blocks,bsize;
	unsigned long addr,maddr,i,j,devid,idreg;
	long len;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int test_prog=0;
	int test_verify=0;
	int test_readout=0;
	int dev_start=0;
	int run_ram=0;
	int unlock=0;
	int dflash_erase=0;
	int dflash_prog=0;
	int dflash_verify=0;
	int dflash_readout=0;
	int shadow_erase=0;
	int shadow_prog=0;
	int shadow_verify=0;
	int shadow_readout=0;
	int lb0,lb1,lb2,lb3,lb4,lb5,lb6,lb7,lbx;
	char hexbyte[5];
	char *parptr;

	errc=0;

	lb0=0xfe;	//default KEY
	lb1=0xed;
	lb2=0xfa;
	lb3=0xce;
	lb4=0xca;
	lb5=0xfe;
	lb6=0xbe;
	lb7=0xef;


	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- key: -- set key (hex)\n");

		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		printf("-- ed -- data flash erase\n");
		printf("-- pd -- data flash program\n");
		printf("-- vd -- data flash verify\n");
		printf("-- rd -- data flash readout\n");

		printf("-- es -- shadow flash erase\n");
		printf("-- ps -- shadow flash program\n");
		printf("-- vs -- shadow flash verify\n");
		printf("-- rs -- shadow flash readout\n");

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

	if((strstr(cmd,"key:")) && ((strstr(cmd,"key:") - cmd) % 2 == 1))
	{
		parptr=strstr(cmd,"key:");
		strncpy(&hexbyte[0],parptr + 4 * sizeof(char),2);
		hexbyte[2]=0;
		sscanf(hexbyte,"%x",&lb0);
		strncpy(&hexbyte[0],parptr + 6 * sizeof(char),2);
		hexbyte[2]=0;
		sscanf(hexbyte,"%x",&lb1);
		strncpy(&hexbyte[0],parptr + 8 * sizeof(char),2);
		hexbyte[2]=0;
		sscanf(hexbyte,"%x",&lb2);
		strncpy(&hexbyte[0],parptr + 10 * sizeof(char),2);
		hexbyte[2]=0;
		sscanf(hexbyte,"%x",&lb3);
		strncpy(&hexbyte[0],parptr + 12 * sizeof(char),2);
		hexbyte[2]=0;
		sscanf(hexbyte,"%x",&lb4);
		strncpy(&hexbyte[0],parptr + 14 * sizeof(char),2);
		hexbyte[2]=0;
		sscanf(hexbyte,"%x",&lb5);
		strncpy(&hexbyte[0],parptr + 16 * sizeof(char),2);
		hexbyte[2]=0;
		sscanf(hexbyte,"%x",&lb6);
		strncpy(&hexbyte[0],parptr + 18 * sizeof(char),2);
		hexbyte[2]=0;
		sscanf(hexbyte,"%x",&lb7);
		strncpy(&hexbyte[0],parptr + 20 * sizeof(char),2);
		hexbyte[2]=0;
		sscanf(hexbyte,"%x",&lbx);
		printf("## Action: unlock device using %02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X - %02X\n",
		lb0,lb1,lb2,lb3,lb4,lb5,lb6,lb7,lbx);
		unlock=1;
	}

	errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);	//enable PU


	if(find_cmd("5v"))
	{
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		printf("## using 5V VDD\n");
	}

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

		if(find_cmd("em"))
		{
			main_erase=1;
			printf("## Action: code flash erase\n");
		}

		if(find_cmd("ed"))
		{
			dflash_erase=1;
			printf("## Action: data flash erase\n");
		}

		if(find_cmd("es"))
		{
			shadow_erase=1;
			printf("## Action: shadow flash erase and unlock\n");
		}

		main_prog=check_cmd_prog("pm","code flash");
		dflash_prog=check_cmd_prog("pd","data flash");
		shadow_prog=check_cmd_prog("ps","shadow flash");
		test_prog=check_cmd_prog("pt","test block in ram");

		main_verify=check_cmd_verify("vm","code flash");
		dflash_verify=check_cmd_verify("vd","data flash");
		shadow_verify=check_cmd_verify("vs","shadow flash");
		test_verify=check_cmd_verify("vt","test block in ram");

		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
		dflash_readout=check_cmd_read("rd","data flash",&dflash_prog,&dflash_verify);
		shadow_readout=check_cmd_read("rs","shadow flash",&shadow_prog,&shadow_verify);
		test_readout=check_cmd_read("rt","test block in ram",&test_prog,&test_verify);

		if(find_cmd("st"))
		if(strstr(cmd,"st") && ((strstr(cmd,"st") - cmd) %2 == 1))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

	if((main_readout == 1) || (dflash_readout == 1) || (shadow_readout == 1) || (test_readout == 1))
	{
		errc=writeblock_open();
	}

	if(dev_start == 0)
	{
		printf("INIT DEVICE \n");
		errc=prg_comm(0x174,0,4,0,0,0,0,0,5);					//init
		idreg=memory[0] + (memory[1] << 8) + (memory[2] << 16) + (memory[3] << 24);
		printf("ID-REG    = %08lX\n",idreg);	

		if(unlock == 1)
		{
			printf("TRY TO UNLOCK....\n");
			memory[0]=lb0;memory[1]=lb1;memory[2]=lb2;memory[3]=lb3;
			memory[4]=lb4;memory[5]=lb5;memory[6]=lb6;memory[7]=lb7;


			errc=prg_comm(0x184,8,0,0,0,lbx,0,0,0);				//unlock
		}


//		printf("ENABLE OnCE \n");
//		errc=prg_comm(0x188,0,0,0,0,0x11,0,0,5);			//enable OnCE
		errc=prg_comm(0x176,0,6,0,0,0x11,0,0,5);				//read JTAG ID
		devid=memory[0] + (memory[1] << 8) + (memory[2] << 16) + (memory[3] << 24);



		if(devid != param[10])
		{			
			printf("JTAG ID =%08lX   , must be %08lX\n",devid,param[10]);
			errc=0x43;
			if((devid == 0) && (idreg != 0)) errc=0x44;
			goto PPCJTAG_END;
		}
		else
		{
			printf("JTAG ID   = %08lX\n",devid);	
		}

		ppcjtag_oncestat();							//print status


		printf("HALT CPU\n");
		errc=prg_comm(0x177,0,0,0,0,0,0,0,0);					//init debug mode
		errc=prg_comm(0x186,0,0,0,0,0,0,0,0);					//init debug mode
		ppcjtag_oncestat();							//print status


	}

	if((run_ram == 0) && (errc == 0) && (dev_start == 0))
	{
		memory[0]=0x80;
		memory[1]=0x5A;
		

		for(j=2;j<0x100;j++) memory[j]=0;
	
		for(j=0;j<0x400;j++)
		{
			if ((param[6] & 0xf0) == 0x00) memory[j+0x100]=exec_ppcjtag_0b[j];
			if ((param[6] & 0xf0) == 0x20) memory[j+0x100]=exec_ppcjtag_0p[j];
		}
		printf("TRANSFER & EXEC LOADER\n");
		errc=prg_comm(0x17e,2048,0,0,0,0x40,0x00,0x00,0x00);			//write 2K loader code

		//set a wrong address
		memory[0]=0xFE;
		memory[1]=0xFD;
		memory[2]=0xFC;
		memory[3]=0xFB;
		errc=prg_comm(0x17A,4,0,0,0,0x40,0x00,0x04,0xfc);					//-> write

		printf("START CPU\n");
		ppcjtag_setcpu();						//set new cpu state
		errc=prg_comm(0x178,0,0,0,0,0,0,0,0);				//start cpu

		usleep(200000);

		ppcjtag_oncestat();						//print status

		errc=prg_comm(0x17f,0,4,0,0,0x40,0x00,0x04,0xf8);
		if(memory[0] != 0) 
		{
			show_data(0,4);	
			errc= 0x42;
		}
		
//		printf("ERRC=%02X\n",errc);


		if((main_erase == 1) && (errc == 0))
		{
			printf("ERASE CODE FLASH\n");

			memory[ 0]=0x15;		//ERASE CF
			memory[ 1]=0x00;
			memory[ 2]=0x00;
			memory[ 3]=0x00;
			errc=prg_comm(0x17A,4,0,0,0,0x40,0x00,0x04,0xf8);			//-> write
	
			do{
				errc=prg_comm(0x17f,0,4,0,0,0x40,0x00,0x04,0xf8);
			}while(memory[3] != 0);

		}

		if((main_prog == 1) && (errc == 0))
		{
			read_block(param[0],param[1],0);
			addr=param[0];
			bsize=max_blocksize;
			blocks=param[1] / bsize;
			maddr=0;
			
			progress("CFLASH PROG ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,bsize) && (errc==0))
				{
//					printf("ADDR = %08lX  LEN: %08lX\n",addr,maddr);
					//transfer 2K
					errc=prg_comm(0x17e,2048,0,maddr,0,0x40,0x00,0x10,0x00);
					
					//set addr
					memory[ROFFSET+3]=(addr >> 24) & 0xff;
					memory[ROFFSET+2]=(addr >> 16) & 0xff;
					memory[ROFFSET+1]=(addr >> 8) & 0xff;
					memory[ROFFSET+0]=(addr) & 0xff;
					errc=prg_comm(0x17A,4,0,ROFFSET,0,0x40,0x00,0x04,0xfc);		//-> write
				
					memory[ROFFSET+0]=0x0D;		//PROGRAM CF
					memory[ROFFSET+1]=0x00;
					memory[ROFFSET+2]=0x00;
					memory[ROFFSET+3]=0x00;
					errc=prg_comm(0x17A,4,0,ROFFSET,0,0x40,0x00,0x04,0xf8);		//-> write
	
					do{
						errc=prg_comm(0x17f,0,4,0,ROFFSET,0x40,0x00,0x04,0xf8);
					}while(memory[ROFFSET+3] != 0);
				}
				addr+=bsize;
				maddr+=bsize;
				progress("CFLASH PROG ",blocks,i+1);
			}
			printf("\n");
		}

		if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
		{
			addr=param[0];
			bsize=max_blocksize;
			blocks=param[1] / bsize;
			maddr=0;
			progress("CFLASH READ ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				errc=prg_comm(0x17d,0,bsize,0,ROFFSET+maddr,
					(addr >> 24) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 8) & 0xff,
					(addr) & 0xff);
				addr+=bsize;
				maddr+=bsize;
				progress("CFLASH READ ",blocks,i+1);
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
			addr = param[0];
			len = param[1];
			i=0;
			printf("CFLASH VERIFY\n");
			for(j=0;j<len;j++)
			{
				if(memory[j] != memory[j+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr+j,memory[j],memory[j+ROFFSET]);
					errc=0x45;
				}
			}
		}


		if((shadow_erase == 1) && (errc == 0))
		{
			printf("ERASE SHADOW FLASH\n");
			memory[ 0]=0x16;		//ERASE SF
			memory[ 1]=0x00;
			memory[ 2]=0x00;
			memory[ 3]=0x00;
			errc=prg_comm(0x17A,4,0,0,0,0x40,0x00,0x04,0xf8);			//-> write
	
			do{
				errc=prg_comm(0x17f,0,4,0,0,0x40,0x00,0x04,0xf8);
			}while(memory[3] != 0);
			
		}

		if(((shadow_prog == 1) || (shadow_erase == 1)) && (errc == 0) && (param[5]>0))
		{
			addr=param[4];
			bsize=max_blocksize;
			blocks=param[5] / bsize;
			maddr=0;
			if(shadow_prog == 1)
			{
				read_block(param[4],param[5],0);
			}
			else
			{
				for(j=0;j<0x4000;j++)
				{
					if ((param[6] & 0xf0) == 0x00) memory[j+maddr]=proto_shadow_0b[j];
					if ((param[6] & 0xf0) == 0x20) memory[j+maddr]=proto_shadow_0p[j];
				}
			}
			progress("SHADOW PROG ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,bsize) && (errc==0))
				{
//					printf("ADDR = %08lX  LEN: %08lX\n",addr,maddr);
					//transfer 2K
					errc=prg_comm(0x17e,2048,0,maddr,0,0x40,0x00,0x10,0x00);
					
					//set addr
					memory[ROFFSET+3]=(addr >> 24) & 0xff;
					memory[ROFFSET+2]=(addr >> 16) & 0xff;
					memory[ROFFSET+1]=(addr >> 8) & 0xff;
					memory[ROFFSET+0]=(addr) & 0xff;
					errc=prg_comm(0x17A,4,0,ROFFSET,0,0x40,0x00,0x04,0xfc);		//-> write
				
					memory[ROFFSET+0]=0x0E;		//PROGRAM SF
					memory[ROFFSET+1]=0x00;
					memory[ROFFSET+2]=0x00;
					memory[ROFFSET+3]=0x00;
					errc=prg_comm(0x17A,4,0,ROFFSET,0,0x40,0x00,0x04,0xf8);		//-> write
	
					do{
						errc=prg_comm(0x17f,0,4,0,ROFFSET,0x40,0x00,0x04,0xf8);
					}while(memory[ROFFSET+3] != 0);
				}
				addr+=bsize;
				maddr+=bsize;
				progress("SHADOW PROG ",blocks,i+1);
			}
			printf("\n");
		}



		if(((shadow_readout == 1) || (shadow_verify == 1)) && (errc == 0) && (param[5]>0))
		{
			bsize=max_blocksize;
			addr=param[4];
			blocks=param[5] / bsize;
			maddr=0;
			progress("SHADOW READ ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				errc=prg_comm(0x17d,0,bsize,0,ROFFSET+maddr,
					(addr >> 24) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 8) & 0xff,
					(addr) & 0xff);
				addr+=bsize;
				maddr+=bsize;
				progress("SHADOW READ ",blocks,i+1);
			}
			printf("\n");
		}

		if((shadow_readout == 1) && (errc == 0) && (param[5]>0))
		{
			writeblock_data(0,param[5],param[4]);
		}

		//verify shadow
		if((shadow_verify == 1) && (errc == 0) && (param[5]>0))
		{
			read_block(param[4],param[5],0);
			addr = param[4];
			len = param[5];
			i=0;
			printf("SHADOW VERIFY\n");
			for(j=0;j<len;j++)
			{
				if(memory[j] != memory[j+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr+j,memory[j],memory[j+ROFFSET]);
					errc=0x45;
				}
			}
		}

		if((dflash_erase == 1) && (errc == 0))
		{
			printf("ERASE DATA FLASH\n");
			memory[ 0]=0x17;		//ERASE DF
			memory[ 1]=0x00;
			memory[ 2]=0x00;
			memory[ 3]=0x00;
			errc=prg_comm(0x17A,4,0,0,0,0x40,0x00,0x04,0xf8);			//-> write
	
			do{
				errc=prg_comm(0x17f,0,4,0,0,0x40,0x00,0x04,0xf8);
			}while(memory[3] != 0);
		}



		if((dflash_prog == 1) && (errc == 0) && (param[3]>0))
		{
			read_block(param[2],param[3],0);
			addr=param[2];
			bsize=max_blocksize;
			blocks=param[3] / bsize;
			maddr=0;
			progress("DFLASH PROG ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,bsize) && (errc==0))
				{
//					printf("ADDR = %08lX  LEN: %08lX\n",addr,maddr);
					//transfer 2K
					errc=prg_comm(0x17e,2048,0,maddr,0,0x40,0x00,0x10,0x00);
					
					//set addr
					memory[ROFFSET+3]=(addr >> 24) & 0xff;
					memory[ROFFSET+2]=(addr >> 16) & 0xff;
					memory[ROFFSET+1]=(addr >> 8) & 0xff;
					memory[ROFFSET+0]=(addr) & 0xff;
					errc=prg_comm(0x17A,4,0,ROFFSET,0,0x40,0x00,0x04,0xfc);		//-> write
				
					memory[ROFFSET+0]=0x0F;		//PROGRAM DF
					memory[ROFFSET+1]=0x00;
					memory[ROFFSET+2]=0x00;
					memory[ROFFSET+3]=0x00;
					errc=prg_comm(0x17A,4,0,ROFFSET,0,0x40,0x00,0x04,0xf8);		//-> write
	
					do{
						errc=prg_comm(0x17f,0,4,0,ROFFSET,0x40,0x00,0x04,0xf8);
					}while(memory[ROFFSET+3] != 0);
				}
				addr+=bsize;
				maddr+=bsize;
				progress("DFLASH PROG ",blocks,i+1);
			}
			printf("\n");
		}

		if(((dflash_readout == 1) || (dflash_verify == 1)) && (errc == 0) && (param[3]>0))
		{
			addr=param[2];
			bsize=max_blocksize;
			blocks=param[3] / bsize;
			maddr=0;
			progress("DFLASH READ ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				errc=prg_comm(0x17d,0,bsize,0,ROFFSET+maddr,
					(addr >> 24) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 8) & 0xff,
					(addr) & 0xff);
				addr+=bsize;
				maddr+=bsize;
				progress("DFLASH READ ",blocks,i+1);
			}
			printf("\n");
		}

		if((dflash_readout == 1) && (errc == 0) && (param[3]>0))
		{
			writeblock_data(0,param[3],param[2]);
		}

		//verify dflash
		if((dflash_verify == 1) && (errc == 0) && (param[3]>0))
		{
			read_block(param[2],param[3],0);
			addr = param[2];
			len = param[3];
			i=0;
			printf("DFLASH VERIFY\n");
			for(j=0;j<len;j++)
			{
				if(memory[j] != memory[j+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr+j,memory[j],memory[j+ROFFSET]);
					errc=0x45;
				}
			}
		}

	}


	if((run_ram == 1) && (errc == 0))
	{
		len=read_block(param[8],param[9],0);
		if (len < 1) len=read_block(0,param[9],0);
		if (len < 1 ) goto PPCJTAG_END;

		printf("TRANSFER & START CODE\n");
//		waitkey();

		len+=2;
		printf("## transfer size: %ld bytes\n",len);

		blocks=(len + max_blocksize -1)/max_blocksize;
		i=0;

//		show_data(0x100,16);

		progress("TRANSFER ",blocks,0);

		maddr=0x00000100;		//mem addr
		addr =0x40000100;		///µC addr
		
		while(len > 0)
		{
//			printf("ADDR = %08lX  LEN: %04X\n",addr,len);
			bsize=max_blocksize;
			errc=prg_comm(0x17e,bsize,0,maddr,0,
						(addr >> 24) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 8) & 0xff,
						(addr) & 0xff);
	
			progress("TRANSFER ",blocks,i+1);
			maddr+=bsize;
			addr+=bsize;
			len-=bsize;
			i++;
		}

		printf("\nSET PC & GO\n");
		ppcjtag_setcpu();						//set new cpu state
//		printf("START CPU\n");
//		ppcjtag_oncestat();							//print status
		errc=prg_comm(0x178,0,0,0,0,0,0,0,0);					//start cpu

		usleep(200000);

		ppcjtag_oncestat();							//print status

		if(errc == 0)
		{
			waitkey();
		}
	}

	if((main_readout == 1) || (dflash_readout == 1) || (shadow_readout == 1) || (test_readout == 1))
	{
		i=writeblock_close();
	}

	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);		//init
		i=prg_comm(0x1e4,0,0,0,0,0,0,0,0x10);		//reset 0
		i=prg_comm(0x1e3,0,0,0,0,0,0,0,0x10);		//reset out
		i=prg_comm(0x1e1,0,0,0,0,0,0,0,0x10);		//reset 1
		i=prg_comm(0x1e5,0,0,0,0,0,0,0,0x10);		//reset in
		waitkey();					//exit
	}

PPCJTAG_END:

	i=prg_comm(0x0f,0,0,0,0,0,0,0,0);			//exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_ppcjtag_error(errc);
	return errc;
}







