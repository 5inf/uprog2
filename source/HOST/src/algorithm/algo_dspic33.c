//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2010-2015 Joerg Wolfram (joerg@jcwolfram.de)			#
//#										#
//#										#
//# This program is free software; you can redistribute it and/or		#
//# modify it under the terms of the GNU General Public License			#
//# as published by the Free Software Foundation; either version 2		#
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
#include "exec/dspic33/exec_dspic33e.h"

void print_dspic33_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x30:	set_error("(SANITY CHECK FAILED)",errc);
				break;

		case 0x31:	set_error("(No SYNC answer)",errc);
				break;

		case 0x32:	set_error("(SYNC pulse too long)",errc);
				break;

		case 0x33:	set_error("(No ACK pulse)",errc);
				break;

		case 0x34:	set_error("(ACK pulse too long)",errc);
				break;

		case 0x35:	set_error("(device remains busy)",errc);
				break;

		case 0x36:	set_error("(RESET pulse at LOW)",errc);
				break;

		case 0x38:	set_error("(UNSECURE failed)",errc);
				break;

		case 0x41:	set_error("(TIMEOUT)",errc);
				break;

		case 0xC2:	set_error("(Device is secured)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_dspic33(void)
{
	int errc,blocks,bsize,i,j;
	unsigned long addr,faddr,maddr;
	int flash_erased=0;
	int bulk_erase=0;
	int total_erase=0;
	int exec_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int aux_prog=0;
	int aux_verify=0;
	int aux_readout=0;
	int conf_prog=0;
	int conf_verify=0;
	int conf_readout=0;
	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- ea -- bulk erase\n");
		printf("-- et -- total erase\n");
		printf("-- ex -- erase programming executive\n");

		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		printf("-- pd -- aux flash program\n");
		printf("-- vd -- aux flash verify\n");
		printf("-- rd -- aux flash readout\n");

		printf("-- pc -- configuration program\n");
		printf("-- vc -- configuration verify\n");
		printf("-- rc -- configuration readout\n");

//		printf("-- st -- start device\n");
		return 0;
	}


	if(find_cmd("ea"))
	{
		bulk_erase=1;
		printf("## Action: bulk erase\n");
	}

	if(find_cmd("et"))
	{
		total_erase=1;
		printf("## Action: total erase\n");
	}

	if(find_cmd("ex"))
	{
		exec_erase=1;
		printf("## Action: erase programming executive\n");
	}


	main_prog=check_cmd_prog("pm","code flash");
	aux_prog=check_cmd_prog("pd","aux");
	conf_prog=check_cmd_prog("pc","config");

	main_verify=check_cmd_verify("vm","code flash");
	aux_verify=check_cmd_verify("vd","aux");
	conf_verify=check_cmd_verify("vc","config");

	main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
	aux_readout=check_cmd_read("rd","aux",&aux_prog,&aux_verify);
	conf_readout=check_cmd_read("rc","config",&conf_prog,&conf_verify);

	printf("\n");
	
	if((main_readout && aux_readout && conf_readout) > 0)
	{
		errc=writeblock_open();
	} 
	
	printf("INIT DEVICE IN ICSP MODE\n");
	errc=prg_comm(0xc0,0,0,0,0,0,0,0,0);					// init

	printf("READ DEVICE + APPLICATION IDs \n");
	errc=prg_comm(0xc2,0,6,0,0,0,0,0,0);					// read ID
	printf("DEV = 0x%04X     REV = 0x%04X     APP = 0x%04X\n",
		memory[0]+256*memory[1],memory[2]+256*memory[3],memory[4]+256*memory[5]);

	if(total_erase == 1)
	{
		printf("SET CONFIG REGISTERS TO DEFAULT VALUE\n");
		errc=prg_comm(0xc7,0,0,0,0,0,0,0,0);					// erase
		printf("ERASE ALL\n");
		errc=prg_comm(0xc6,0,0,0,0,0,0,0,0);					// erase
		printf("INIT DEVICE IN ICSP MODE\n");
		errc=prg_comm(0xc0,0,0,0,0,0,0,0,0);					// init
		printf("READ DEVICE + APPLICATION IDs \n");
		errc=prg_comm(0xc2,0,6,0,0,0,0,0,0);					// read ID
		printf("DEV = 0x%04X     REV = 0x%04X     APP = 0x%04X\n",
			memory[0]+256*memory[1],memory[2]+256*memory[3],memory[4]+256*memory[5]);
	}

	if(((memory[4]+256*memory[5]) != 0x00DD) && (exec_erase == 0) && (total_erase == 0))
	{
		printf("ERASE EXECUTIVE MEMORY\n");
		errc=prg_comm(0xc3,0,0,0,0,0,0,0,0);					// erase
		progress("PROG EXEC   ",8,0);
		for(i=0;i<8;i++)
		{
			for(j=0;j<1024;j++)
			{
				memory[j]=exec_dspic33e[j+1024*i];
			}
			errc=prg_comm(0xc4,1024,0,0,0,0,i*2,0,0);					//write
			progress("PROG EXEC   ",8,i+1);
		}
		printf("\n");
	}

	if(exec_erase == 1)
	{
		printf("SET CONFIG REGISTERS TO DEFAULT VALUE\n");
		errc=prg_comm(0xc7,0,0,0,0,0,0,0,0);					// erase
		printf("ERASE EXECUTIVE MEMORY\n");
		errc=prg_comm(0xc3,0,0,0,0,0,0,0,0);					// erase
	}
	else if (total_erase == 0)
	{
		printf("INIT DEVICE IN EICSP MODE\n");
		errc=prg_comm(0xc8,0,0,0,0,0,0,0,0);					//init in EICSP mode

		printf("SANITY CHECK:        ");
		memory[0]=255;
		memory[1]=255;
		memory[2]=255;
		memory[3]=255;

		errc=prg_comm(0xc9,0,4,0,0,0,0,0,0);					// sanity check
		printf("R1 = 0x%04X      R2 = 0x%04X  -> ",memory[0]+256*memory[1],memory[2]+256*memory[3]);
	}

	if ((total_erase == 0) && (exec_erase == 0))
	{
		if(((memory[0]+256*memory[1]) == 0x1000) && ((memory[2]+256*memory[3]) == 0x0002))
		{
			printf("PASS\n");
		}
		else
		{
			printf("FAIL\n");
			errc=0x30;
		}
	}

	//bulk erase
	if((bulk_erase == 1) && (errc == 0))
	{
		printf("BULK ERASE:          ");
		errc=prg_comm(0xca,0,4,0,0,0,0,0,0);			//bulk erase
		printf("R1 = 0x%04X      R2 = 0x%04X  -> ",memory[0]+256*memory[1],memory[2]+256*memory[3]);
		if(((memory[0]+256*memory[1]) == 0x1700) && ((memory[2]+256*memory[3]) == 0x0002))
		{
			printf("PASS\n");
		}
		else
		{
			printf("FAIL\n");
			errc=0x31;
		}
	}


	//program main flash
	if((main_prog == 1) && (errc == 0))
	{
		read_block(param[0],param[1],0);
		addr=param[0];
		bsize=max_blocksize;
		blocks = param[1]/bsize;
		maddr=0;
		
		progress("PROG MAIN   ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			faddr=addr/2;
			if(must_prog(maddr,bsize) && (errc==0))
			{
				errc=prg_comm(0xcb,bsize,4,maddr,0,0x00,(faddr >> 8) & 0xff,(faddr >> 16) & 0xff,0);
			}
			progress("PROG MAIN   ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
			
			if((((memory[0]+256*memory[1]) == 0x1500) && ((memory[2]+256*memory[3]) == 0x0002)) || (flash_erased == 1))
			{
//				printf("ADDR=%06lX   R1 = 0x%04X      R2 = 0x%04X  -> PASS\n",faddr,memory[0]+256*memory[1],memory[2]+256*memory[3]);
			}
			else
			{
				printf("\nADDR=%06lX   R1 = 0x%04X      R2 = 0x%04X  -> FAIL\n",faddr,memory[0]+256*memory[1],memory[2]+256*memory[3]);
				errc=0x32;
			}
		}
		printf("\n");
	}


	//readout main flash
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		for(addr=0;addr < (ROFFSET/2);addr++)
		{
			memory[addr*4]=255;
			memory[addr*4+1]=255;
			memory[addr*4+2]=255;
			memory[addr*4+3]=0;
		}
		addr=param[0];
		bsize=max_blocksize;
		blocks = param[1]/bsize;
		maddr=0;
	
		progress("READ MAIN   ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			faddr=addr/2;
			flash_erased=1;
			if(errc == 0)
			{
				errc=prg_comm(0xcd,0,bsize,0,maddr+ROFFSET,0x00,(faddr >> 8) & 0xff,(faddr >> 16) & 0xff,0);
			}
			progress("READ MAIN   ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	if((main_verify == 1) && (errc == 0))
	{
		printf("VERIFY MAIN FLASH\n");
		read_block(param[0],param[1],0);
		addr = param[0];

		i=0;
		for(j=0;j<(param[1]);j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %06lX  DATA= %04X  READ= %04X\n",
				(addr+j)/2,
				memory[j]+256*memory[j+1],
				memory[j+ROFFSET]+256*memory[j+ROFFSET+1]);
				errc=1;
			}
		}
	}

	if((main_readout == 1) && (errc == 0))
	{
		printf("SAVE FLASH\n");
		writeblock_data(0,param[1],param[0]);
	}

	//program auxiliary flash
	if((aux_prog == 1) && (errc == 0))
	{
		addr=param[2];
		read_block(param[2],param[3],0);
		bsize=max_blocksize;
		blocks = param[3] / bsize;
		maddr=0;

		progress("PROG AUX    ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			faddr=addr/2;
			if(errc == 0)
			{
				errc=prg_comm(0xcb,1024,4,maddr,0,0x00,(faddr >> 8) & 0xff,(faddr >> 16) & 0xff,0);
			}
			addr+=1024;
			maddr+=1024;
			progress("PROG AUX    ",blocks,j+1);
			if(((memory[0]+256*memory[1]) == 0x1500) && ((memory[2]+256*memory[3]) == 0x0002))
			{
//				printf("ADDR=%06lX   R1 = 0x%04X      R2 = 0x%04X  -> PASS\n",faddr,memory[0]+256*memory[1],memory[2]+256*memory[3]);
			}
			else
			{
				printf("\nADDR=%06lX   R1 = 0x%04X      R2 = 0x%04X  -> FAIL\n",faddr,memory[0]+256*memory[1],memory[2]+256*memory[3]);
				errc=0x32;
			}
		}
		printf("\n");
	}

	//readout auxiliary flash
	if(((aux_readout == 1) || (aux_verify == 1)) && (errc == 0))
	{
		for(addr=0;addr < (ROFFSET / 2);addr++)
		{
			memory[addr*4]=255;
			memory[addr*4+1]=255;
			memory[addr*4+2]=255;
			memory[addr*4+3]=0;
		}
		addr=param[2];
		bsize=max_blocksize;
		blocks = param[3] / bsize;
		maddr=0;

		progress("READ AUX    ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			faddr=addr/2;
			flash_erased=1;
			if(errc == 0)
			{
				errc=prg_comm(0xcd,0,1028,0,maddr+ROFFSET,0x00,(faddr >> 8) & 0xff,(faddr >> 16) & 0xff,0);
//				printf("R1 = 0x%04X      R2 = 0x%04X\n",
//				memory[ROFFSET+1024]+256*memory[ROFFSET+1025],
//				memory[ROFFSET+1026]+256*memory[ROFFSET+1027]);
			}
			progress("READ AUX    ",blocks,j+1);
			addr+=1024;
			maddr+=1024;
		}
		printf("\n");
	}

	//verify auxiliary flash
	if((aux_verify == 1) && (errc == 0))
	{
		printf("VERIFY AUXILIARY FLASH\n");
		addr=param[2];
		read_block(param[2],param[3],0);
		
		i=0;
		for(j=0;j<param[3];j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %06lX  DATA= %04X  READ= %04X\n",
				(addr+j)/2,
				memory[j]+256*memory[j+1],
				memory[j+ROFFSET]+256*memory[j+ROFFSET+1]);
				errc=1;
			}
		}
	}

	//readout auxiliary flash
	if((aux_readout == 1) && (errc == 0))
	{
		printf("SAVE AUXILIARY FLASH\n");
		writeblock_data(0,param[3],param[2]);
	}

	//program config
	if((conf_prog == 1) && (errc == 0))
	{
		read_block(0x01F00000,40,0x1000);
		maddr=0;

		printf("PROGRAM CONFIG\n");

		for(addr=0;addr<0x24;addr++)
		{
			memory[addr]=0;
		}
		memory[0] = memory[0x1008] & 0x33;	//F80004
		memory[1] = memory[0x100c] & 0x87;	//F80006
		memory[2] = memory[0x1010] & 0xE7;	//F80008
		memory[3] = memory[0x1014] & 0xFF;	//F8000A
		memory[4] = memory[0x1018] & 0x3F;	//F8000C
		memory[5] = memory[0x101c] & 0xF7;	//F8000E
		memory[6] = memory[0x1020] & 0x33;	//F80010
		memory[7] = memory[0x1024] & 0xFF;	//F80012

		addr=0;
		printf("FGS     = %02X\n",memory[addr]);
		printf("FOSCSEL = %02X\n",memory[1]);
		printf("FOSC    = %02X\n",memory[2]);
		printf("FWDT    = %02X\n",memory[3]);
		printf("FPOR    = %02X\n",memory[4]);
		printf("FICD    = %02X\n",memory[5]);
		printf("FAS     = %02X\n",memory[6]);
		printf("FUID0   = %02X\n",memory[7]);
		errc=prg_comm(0xcc,8,0,maddr,0,0,0,0,0);
	}

	//readout config
	if(((conf_readout == 1) || (conf_verify == 1)) && (errc == 0))
	{
		for(addr=0;addr < (ROFFSET/2);addr++)
		{
			memory[addr*4]=255;
			memory[addr*4+1]=255;
			memory[addr*4+2]=255;
			memory[addr*4+3]=255;
		}
		printf("READOUT CONFIG\n");
		
		maddr=0;

		errc=prg_comm(0xce,0,64,0,0x1000,0,0,0,0);
		printf("R1 = 0x%04X      R2 = 0x%04X\n",
			memory[0x1030]+256*memory[0x1031],
			memory[0x1032]+256*memory[0x1033]);

		memory[ROFFSET+0] = memory[0x1008] & 0x33;	//F80004
		memory[ROFFSET+1] = memory[0x100c] & 0x87;	//F80006
		memory[ROFFSET+2] = memory[0x1010] & 0xE7;	//F80008
		memory[ROFFSET+3] = memory[0x1014] & 0xFF;	//F8000A
		memory[ROFFSET+4] = memory[0x1018] & 0x3F;	//F8000C
		memory[ROFFSET+5] = memory[0x101c] & 0xF7;	//F8000E
		memory[ROFFSET+6] = memory[0x1020] & 0x33;	//F80010
		memory[ROFFSET+7] = memory[0x1024] & 0xFF;	//F80012

		addr=0;
		printf("FGS     = %02X\n",memory[ROFFSET+0]);
		printf("FOSCSEL = %02X\n",memory[ROFFSET+1]);
		printf("FOSC    = %02X\n",memory[ROFFSET+2]);
		printf("FWDT    = %02X\n",memory[ROFFSET+3]);
		printf("FPOR    = %02X\n",memory[ROFFSET+4]);
		printf("FICD    = %02X\n",memory[ROFFSET+5]);
		printf("FAS     = %02X\n",memory[ROFFSET+6]);
		printf("FUID0   = %02X\n",memory[ROFFSET+7]);

	}

	if((conf_verify == 1) && (errc == 0))
	{
		printf("VERIFY CONFIG\n");
		read_block(0x1F00000,40,0);
		addr = 0x1F00000;
		i=0;
		for(j=8;j<40;j+=4)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %06lX  DATA= %04X  READ= %04X\n",
				(addr+j)/2,
				memory[j]+256*memory[j+1],
				memory[j+ROFFSET]+256*memory[j+ROFFSET+1]);
				errc=1;
			}
		}
	}

	if((conf_readout == 1) && (errc == 0))
	{
		printf("SAVE CONFIG\n");
		writeblock_data(0,0x40,0x1F00000);
	}

	
	if((main_readout && aux_readout && conf_readout) > 0)
	{
		writeblock_close();
	} 

	errc=prg_comm(0xc1,0,0,0,0,0,0,0,0);					// exit
	errc=prg_comm(0xf5,0,0,0,0,0,0,0,0);					// VPP off

	print_dspic33_error(errc);

	return errc;
}




