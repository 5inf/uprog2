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
#include "exec/ppcbam_0b/exec_ppcbam.h"

#include "exec/ppcbam_el/exec_ppcbam.h"

#include "exec/ppcbam_0p/exec_ppcbam_08.h"
#include "exec/ppcbam_0p/exec_ppcbam_16.h"
#include "exec/ppcbam_0p/exec_ppcbam_20.h"
#include "exec/ppcbam_0p/exec_ppcbam_40.h"

#include "exec/ppc_shadow/spc560b/proto_shadow.h"
#include "exec/ppc_shadow/spc560p/proto_shadow.h"
#include "exec/ppc_shadow/spc56el/proto_shadow.h"


void print_ppcbam_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(password: no echo)",errc);
				break;

		case 0x42:	set_error("(password: wrong echo)",errc);
				break;

		case 0x43:	set_error("(data: no echo)",errc);
				break;

		case 0x44:	set_error("(data: wrong echo)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_ppcbam(void)
{
	int errc,blocks,bsize;
	unsigned long addr,maddr,i,j;
	long len;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dev_start=0;
	int run_ram=0;
	int dflash_erase=0;
	int dflash_prog=0;
	int dflash_verify=0;
	int dflash_readout=0;
	int shadow_erase=0;
	int shadow_prog=0;
	int shadow_verify=0;
	int shadow_readout=0;
	int lb0,lb1,lb2,lb3,lb4,lb5,lb6,lb7;
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
		printf("## Action: unlock device using %02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
		lb0,lb1,lb2,lb3,lb4,lb5,lb6,lb7);
	}


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

		main_verify=check_cmd_verify("vm","code flash");
		dflash_verify=check_cmd_verify("vd","data flash");
		shadow_verify=check_cmd_verify("vs","shadow flash");

		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
		dflash_readout=check_cmd_read("rd","data flash",&dflash_prog,&dflash_verify);
		shadow_readout=check_cmd_read("rs","shadow flash",&shadow_prog,&shadow_verify);

		if(find_cmd("st"))
		if(strstr(cmd,"st") && ((strstr(cmd,"st") - cmd) %2 == 1))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

	if((main_readout == 1) || (dflash_readout == 1) || (shadow_readout == 1))
	{
		errc=writeblock_open();
	}

	printf("INIT DEVICE \n");
	if(dev_start == 0)
	{
		errc=prg_comm(0x90,0,0,0,0,0,0,0,0);					//init
	}

	if((run_ram == 0) && (errc == 0) && (dev_start == 0))
	{
		memory[0x0f0]=lb0;	//KEY
		memory[0x0f1]=lb1;
		memory[0x0f2]=lb2;
		memory[0x0f3]=lb3;
		memory[0x0f4]=lb4;
		memory[0x0f5]=lb5;
		memory[0x0f6]=lb6;
		memory[0x0f7]=lb7;
		memory[0x0f8]=0x40;	//start addr
		memory[0x0f9]=0x00;
		memory[0x0fa]=0x04;
		memory[0x0fb]=0x00;
		memory[0x0fc]=0x80;	//length | VLE
		memory[0x0fd]=0x00;
		memory[0x0fe]=0x04;
		memory[0x0ff]=0x00;

		for(j=0;j<0x400;j++)
		{
			if ((param[6] & 0xf0) == 0x00) memory[j+0x100]=exec_ppcbam_0b[j];
			if ((param[6] & 0xf0) == 0x10) memory[j+0x100]=exec_ppcbam_el[j];
			if ((param[6] & 0xf0) == 0x20) memory[j+0x100]=exec_ppcbam_0p_08[j];
			if ((param[6] & 0xf0) == 0x30) memory[j+0x100]=exec_ppcbam_0p_16[j];
			if ((param[6] & 0xf0) == 0x40) memory[j+0x100]=exec_ppcbam_0p_20[j];
			if ((param[6] & 0xf0) == 0x50) memory[j+0x100]=exec_ppcbam_0p_40[j];
		}
		printf("TRANSFER LOADER\n");
		
//		show_data(0x100,16);
		
		errc=prg_comm(0x92,0x410,0,0x0f0,0,param[6] & 0xff,0,0x10,0x04);		//transfer loader & exec

		printf("SPD=%02X\n",param[6] & 0xff);
		

		sleep(1);

//		printf("ERRC=%02X\n",errc);


		if((main_erase == 1) && (errc == 0))
		{
			printf("ERASE CODE FLASH\n");
			errc=prg_comm(0x95,0,0,0,0,0,0x03,0,0x3f);				//erase
		}

		if((dflash_erase == 1) && (errc == 0))
		{
			printf("ERASE DATA FLASH\n");
			errc=prg_comm(0x97,0,0,0,0,0x00,0x00,0x00,0x0f);				//erase
		}

		if((shadow_erase == 1) && (errc == 0))
		{
			printf("ERASE SHADOW FLASH\n");
			errc=prg_comm(0x99,0,0,0,0,0x00,0x00,0x00,0x00);				//erase
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
					errc=prg_comm(0x94,bsize,0,maddr,0,
						(addr >> 24) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 8) & 0xff,
						(addr) & 0xff);
				}
				addr+=bsize;
				maddr+=bsize;
				progress("CFLASH PROG ",blocks,i+1);
			}
			printf("\n");
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
					errc=prg_comm(0x96,bsize,0,maddr,0,
						(addr >> 24) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 8) & 0xff,
						(addr) & 0xff);
				}
				addr+=bsize;
				maddr+=bsize;
				progress("DFLASH PROG ",blocks,i+1);
			}
			printf("\n");
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
					if ((param[6] & 0xf0) == 0x10) memory[j+maddr]=proto_shadow_el[j];
					if ((param[6] & 0xf0) == 0x20) memory[j+maddr]=proto_shadow_0p[j];
					if ((param[6] & 0xf0) == 0x20) memory[j+maddr]=proto_shadow_0p[j];
					if ((param[6] & 0xf0) == 0x40) memory[j+maddr]=proto_shadow_0p[j];
					if ((param[6] & 0xf0) == 0x50) memory[j+maddr]=proto_shadow_0p[j];
				}
			}
			progress("SHADOW PROG ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,bsize) && (errc==0))
				{
					errc=prg_comm(0x98,bsize,0,maddr,0,
						(addr >> 24) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 8) & 0xff,
						(addr) & 0xff);
				}
				addr+=bsize;
				maddr+=bsize;
				progress("SHADOW PROG ",blocks,i+1);
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
				errc=prg_comm(0x93,0,bsize,0,ROFFSET+maddr,
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
					errc=1;
				}
			}
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
				errc=prg_comm(0x93,0,bsize,0,ROFFSET+maddr,
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
					errc=1;
				}
			}
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
				errc=prg_comm(0x93,0,bsize,0,ROFFSET+maddr,
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
					errc=1;
				}
			}
		}
	}


	if((run_ram == 1) && (errc == 0))
	{
		len=read_block(param[8],param[9],0x100);
		if (len < 1) len=read_block(0x100,param[9],0x100);

		len+=1;
		
		printf("TRANSFER & START CODE\n");

		memory[0x0f0]=lb0;	//KEY
		memory[0x0f1]=lb1;
		memory[0x0f2]=lb2;
		memory[0x0f3]=lb3;
		memory[0x0f4]=lb4;
		memory[0x0f5]=lb5;
		memory[0x0f6]=lb6;
		memory[0x0f7]=lb7;
		memory[0x0f8]=(param[8] >> 24) & 0xff;	//start addr
		memory[0x0f9]=(param[8] >> 16) & 0xff;
		memory[0x0fa]=(param[8] >> 8) & 0xff;
		memory[0x0fb]=param[9] & 0xff;
		memory[0x0fc]=0x80;	//length | VLE
		memory[0x0fd]=0x00;
		memory[0x0fe]=(len >> 8) & 0xff;
		memory[0x0ff]=len & 0xff;

//		printf("DAT= %02X %02X %02X %02X\n",memory[i],memory[i+1],memory[i+2],memory[i+3]);

		len+=16;
		printf("## transfer size: %ld bytes\n",len);

		blocks=(len + max_blocksize -1)/max_blocksize;
		i=0;

//		show_data(0x100,16);

		progress("TRANSFER ",blocks,0);

		maddr=0x0f0;
		while(len > 0)
		{
			bsize=max_blocksize;
			if(bsize > len) bsize=len;
			errc=prg_comm(0x92,bsize,0,maddr,0,param[6] & 0xff,0,bsize & 0xff,(bsize >> 8) & 0xff);			//transfer & exec
			progress("TRANSFER ",blocks,i+1);
			maddr+=bsize;
			len-=bsize;
			i++;
		}

		if(errc == 0)
		{
			waitkey();
		}
	}

	if((main_readout == 1) || (dflash_readout == 1) || (shadow_readout == 1))
	{
		i=writeblock_close();
	}

	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);		//init
		i=prg_comm(0x1e4,0,0,0,0,0,0,0,0x01);		//reset 0
		i=prg_comm(0x1e3,0,0,0,0,0,0,0,0x01);		//reset out
		i=prg_comm(0x1e1,0,0,0,0,0,0,0,0x01);		//reset 1
		i=prg_comm(0x1e5,0,0,0,0,0,0,0,0x01);		//reset in
		waitkey();					//exit
	}

	i=prg_comm(0x0f,0,0,0,0,0,0,0,0);			//exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_ppcbam_error(errc);
	return errc;
}





