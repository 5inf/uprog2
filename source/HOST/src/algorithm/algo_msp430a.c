//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2010-2015 Joerg Wolfram (joerg@jcwolfram.de)			#
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

void print_msp430a_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x51:	set_error("(WRONG JTAG ID)",errc);
				break;

		case 0x52:	set_error("(LOCK ERROR)",errc);
				break;

		case 0x53:	set_error("(SYNC ERROR)",errc);
				break;

		case 0x55:	set_error("(FETCH ERROR)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_msp430a()
{
	int errc,blocks,bsize,j;
	unsigned int ramsize,ramstart,addr,maddr;
	int all_erase=0;
	int allx_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;

	int info_prog=0;
	int info_verify=0;
	int info_readout=0;

	int all_readout=0;

	int dev_start=0;
	int run_ram=0;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- ea -- chip erase excl. INFO A\n");
		printf("-- ex -- chip erase incl. INFO A\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");
		printf("-- pi -- info flash program\n");
		printf("-- vi -- info flash verify\n");
		printf("-- ri -- info flash readout\n");
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

	if(find_cmd("st"))
	{
		dev_start=1;
		printf("## Action: start device\n");
		errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);			//enable pull-up
		errc=prg_comm(0x0e,0,0,0,0,1,0,1,0);			//init
		waitkey();
		goto MSP430A_END;		
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
		if(find_cmd("ea"))
		{
			all_erase=1;
			printf("## Action: chip erase (excluding info sector A)\n");
		}

		if(find_cmd("ex"))
		{
			allx_erase=1;
			all_erase=0;
			printf("## Action: chip erase (including info sector A)\n");
		}

		main_prog=check_cmd_prog("pm","code flash");
		info_prog=check_cmd_prog("pi","info flash");

		main_verify=check_cmd_verify("vm","code flash");
		info_verify=check_cmd_verify("vi","info flash");

		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
		info_readout=check_cmd_read("ri","info flash",&info_prog,&info_verify);
	}
	printf("\n");

	if((main_readout || info_readout) > 0)
	{
		errc=writeblock_open();
	}

	errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);				//enable pull-ups

	if(errc == 0) errc=prg_comm(0xd8,0,1,0,0,0x91,0,0x20,0x01);	//init
	printf("JTAG ID READ = %02X\n",memory[0]);

	//erase
	if(all_erase == 1)
	{
		printf("ERASE\n");
		if(errc == 0) errc=prg_comm(0xde,0,0,0,0,0,0,0,0);			//main erase
		if(errc == 0) prg_comm(0xd9,0,0,0,0,0,0,0,0);				//exit
		if(errc == 0) errc=prg_comm(0xd8,0,1,0,0,0x91,0,0x20,0x01);		//re-init
		printf("JTAG ID READ = %02X\n",memory[0]);
	}
	else if(allx_erase == 1)
	{
		printf("ERASE\n");
		if(errc == 0) errc=prg_comm(0xde,0,0,0,0,0,0,0,0);			//main erase
		if(errc == 0) prg_comm(0xd9,0,0,0,0,0x10,0,0,0);			//exit
		if(errc == 0) errc=prg_comm(0xd8,0,1,0,0,0x91,0,0x20,0x01);		//re-init
		printf("JTAG ID READ = %02X\n",memory[0]);
	}

	//program main flash
	if((main_prog == 1) && (errc == 0))
	{
		read_block(param[0],param[1],0);
		addr = param[0];
		bsize = max_blocksize;
		if(param[1] < bsize) bsize = param[1];
		blocks = param[1] / bsize;
		maddr=0;
		

		progress("PROG MAIN ",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",addr,bsize);
			if(must_prog(maddr,bsize) && (errc == 0))
			{
				errc=prg_comm(0xdf,bsize,0,maddr,
				0,0,addr >> 8,(bsize >> 1) & 0xff,(bsize >> 9) & 0xff);	//program block
			}
			addr+=bsize;
			maddr+=bsize;
			progress("PROG MAIN ",blocks,j+1);
		}
//		if(errc == 0) prg_comm(0xd9,0,0,0,0,0,0,0,0);					//exit
		printf("\n");
	}

	//verify main flash
	if((main_readout == 1) || (main_verify == 1))
	{
		addr = param[0];
		bsize = max_blocksize;
		if(param[1] < bsize) bsize = param[1];
		blocks = param[1] / bsize;
		maddr=0;

		progress("READ MAIN ",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",addr,bsize);
			if(errc == 0) errc=prg_comm(0xda,0,bsize,0,maddr+ROFFSET,0,addr >> 8,0,bsize >> 9);	//read block
			progress("READ MAIN ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
//			if(errc == 0) prg_comm(0xd9,0,0,0,0,0,0,0,0);					//exit
			printf("\n");
	}

	if(main_verify == 1)
	{
		read_block(param[0],param[1],0);
		addr = param[0];
		for(j=0;j<param[1];j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %04X  FILE= %02X  READ= %02X\n",
				addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((main_readout == 1) && (all_readout == 0))
	{
		writeblock_data(0,param[1],param[0]);
	}

	//program info flash
	if((info_prog == 1) && (errc == 0))
	{
		read_block(param[2],param[3],0);
		addr = param[2];
		bsize = max_blocksize;
		if(param[3] < bsize) bsize = param[3];
		blocks = param[3] / bsize;
		maddr=0;

		progress("PROG INFO ",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",addr,bsize);
			if(errc == 0) errc=prg_comm(0xdf,bsize,0,maddr,0,
				0,addr >> 8,(bsize >> 1) & 0xff,bsize >> 9);	//program block
			progress("PROG INFO ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
//		if(errc == 0) prg_comm(0xd9,0,0,0,0,0,0,0,0);					//exit
		printf("\n");
	}

	//verify info flash
	if((info_readout == 1) || (info_verify == 1))
	{
		addr = param[2];
		bsize = max_blocksize;
		if(param[3] < bsize) bsize = param[3];
		blocks = param[3] / bsize;
		maddr=0;
			
		progress("READ INFO ",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",addr,bsize);
			if(errc == 0) errc=prg_comm(0xda,0,bsize,0,maddr+ROFFSET,
				0,addr >> 8,(bsize >> 1) & 0xff,bsize >> 9);	//read block
			progress("READ INFO ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
//		if(errc == 0) prg_comm(0xd9,0,0,0,0,0,0,0,0);					//exit
		printf("\n");
	}

	if(info_verify == 1)
	{
		read_block(param[2],param[3],0);
		addr = param[2];
		for(j=0;j<param[3];j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %04X  DATA= %02X  READ= %02X\n",
				addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((info_readout == 1) && (all_readout == 0))
	{
		writeblock_data(0,param[3],param[2]);
	}

	if(run_ram == 1)
	{
		read_block(param[8],param[9],0);
		ramstart = param[8];
		ramsize = param[9];
		maddr=0;
		
		if(ramsize > max_blocksize) ramsize = max_blocksize;
		printf("TRANSFER %d BYTES CODE TO RAM\n",ramsize);
		if(errc == 0) errc=prg_comm(0xdc,ramsize,0,maddr,0,0,ramstart >> 8,ramsize >> 1,ramsize >> 9);	//write words
		if(errc == 0) errc=prg_comm(0xda,0,ramsize,0,ROFFSET,0,ramstart >> 8,ramsize >> 1,ramsize >> 9);//read block

//		printf("CHECK %d BYTES CODE OF RAM\n",ramsize);
		for(j=0;j<ramsize;j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %04X  DATA= %02X  READ= %02X\n",
				ramstart+j,memory[j],memory[j+ROFFSET]);
			}
		}

		if(errc == 0) errc=prg_comm(0xdd,0,0,0,0,ramstart & 0xff,ramstart >> 8,0,0);				//start code
		if(errc == 0) waitkey();
	}
	
	prg_comm(0xd9,0,0,0,0,0,0,0,0);				//SBW exit


MSP430A_END:

	prg_comm(0x0f,0,0,0,0,0,0,0,0);				//exit


	if((main_readout || info_readout) > 0)
	{
		writeblock_close();
	}

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_msp430a_error(errc);
	return errc;
}


