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
//#include "exec/c2000/exec_c2000.c"

void print_c2000_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",0);
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


int prog_c2000(void)
{
	int errc,blocks,i,j,k,bsize;
	unsigned long addr,len,flash_addr,flash_size,faddr,maddr;
	int main_erase=0;
	int unsecure = 0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dev_start=0;
	int run_ram=0;
	int small_model=1;
	int otp_prog=0;
	int otp_verify=0;
	int otp_readout=0;
	int testmode=0;

	errc=0;


	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- ea -- all flash erase\n");
		printf("-- key:  unsecure with hex key\n");

		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		printf("-- po -- otp program\n");
		printf("-- vo -- otp verify\n");
		printf("-- ro -- otp readout\n");

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


		main_prog=check_cmd_prog("pm","code flash");
		otp_prog=check_cmd_prog("pd","data flash");

		main_verify=check_cmd_verify("vm","code flash");
		otp_verify=check_cmd_verify("vd","data flash");

		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
		otp_readout=check_cmd_read("rd","data flash",&otp_prog,&otp_verify);


		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

	if((main_readout || otp_readout) > 0)
	{
		errc=writeblock_open();
	}


	if((dev_start == 0) && (errc==0))
	{
		errc=prg_comm(0x90,0,0,0,0,0,0,0,0);					//init
	}

	if((run_ram == 0) && (errc == 0) && (dev_start == 0))
	{
		for(j=0;j<0x700;j++)
		{
//			memory[j+0x400]=exec_c2000[j];
		}
		printf("TRANSFER LOADER\n");
		errc=prg_comm(0x92,0x700,0,0x400,0,0,0,0,0);				//transfer loader & exec

		for(j=0;j<0x700;j++)
		{
			memory[j+0x400]=0xff;
		}

		if((main_erase == 1) && (errc == 0))
		{
			printf("ERASE MAIN FLASH\n");
			errc=prg_comm(0x95,0,0,0,0,0,0x03,0,0x3f);				//erase
		}

		if((main_prog == 1) && (errc == 0))
		{
			read_block(param[0],param[1],0);
			bsize=max_blocksize;
			addr=param[0];
			blocks=param[1]/bsize;
			maddr=0;
			
			progress("MAIN PROG ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,bsize) && (errc == 0))
				{
					errc=prg_comm(0x94,bsize,0,maddr,0,
						(addr >> 24) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 8) & 0xff,
						(addr) & 0xff);
				}
				addr+=bsize;
				maddr+=bsize;
				progress("MAIN PROG ",blocks,i+1);
			}
		}

		if((otp_prog == 1) && (errc == 0))
		{
			read_block(param[2],param[3],0);
			bsize=max_blocksize;
			addr=param[2];
			if(bsize < param[3]) bsize=param[3];
			blocks=param[3]/bsize;
			maddr=0;
			
			progress("OTP PROG  ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,bsize) && (errc == 0))
				{
					errc=prg_comm(0x96,bsize,0,maddr,0,
						(addr >> 24) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 8) & 0xff,
						(addr) & 0xff);
				}
				addr+=bsize;
				maddr+=bsize;
				progress("OTP PROG  ",blocks,i+1);
			}
		}


		if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
		{
			bsize=max_blocksize;
			addr=param[0];
			blocks=param[1]/bsize;
			maddr=0;

			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);
			progress("MAIN READ ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				errc=prg_comm(0x93,0,1024,0,ROFFSET+maddr,
					(addr >> 24) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 8) & 0xff,
					(addr) & 0xff);
				addr+=bsize;
				maddr+=bsize;
				addr+=1024;
				progress("MAIN READ ",blocks,i+1);
			}
		}

		if((main_readout == 1) && (errc == 0))
		{
			writeblock_data(0,param[1],param[0]);
		}


		if(((otp_readout == 1) || (otp_verify == 1)) && (errc == 0))
		{
			bsize=max_blocksize;
			addr=param[2];
			if(bsize < param[3]) bsize=param[3];
			blocks=param[3]/bsize;
			maddr=0;

			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);
			progress("OTP READ  ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				errc=prg_comm(0x93,0,1024,0,ROFFSET+maddr,
					(addr >> 24) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 8) & 0xff,
					(addr) & 0xff);
				addr+=bsize;
				maddr+=bsize;
				progress("OTP READ  ",blocks,i+1);
			}
		}

		if((otp_readout == 1) && (errc == 0))
		{
			writeblock_data(0,param[3],param[2]);
		}

	}


	if((run_ram == 1) && (errc == 0))
	{
		len=read_block(param[4],param[5],0);
		printf("TRANSFER & START CODE\n");
		addr=loaddr;
		bsize=max_blocksize;

		errc=prg_comm(0x92,0x700,0,0x400,0,0,0,0,0);				//transfer & exec

		if(errc == 0)
		{
			waitkey();
		}
	}


	if((main_readout || otp_readout) > 0)
	{
		writeblock_close();
	}

	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
		i=prg_comm(0x0f,0,0,0,0,0,0,0,0);					//exit
	}

	i=prg_comm(0x91,0,0,0,0,0,0,0,0);					//SWIM exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_c2000_error(errc);

	return errc;
}






