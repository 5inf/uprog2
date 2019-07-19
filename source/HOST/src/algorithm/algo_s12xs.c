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

void print_s12xs_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x30:	set_error("(RESET stucks at LOW)",errc);
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


int prog_s12xs(void)
{
	int errc,blocks,bsize,i,j,subblocks;
	unsigned long addr,len,faddr,maddr;
	int prdiv8,bfreq=0,fcdiv=0,ppage;
	float freq,bdmfreq;
	int main_erase=0;
	int unsecure = 0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dev_start=0;
	int run_ram=0;
	int small_model=1;
	int dflash_erase=0;
	int dflash_prog=0;
	int dflash_verify=0;
	int dflash_readout=0;
	int set_pll = 1;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- lm -- large memory model\n");
		printf("-- x2 -- set PLL to F*2\n");
		printf("-- x4 -- set PLL to F*4\n");
		
		printf("-- un -- unsecure device\n");

		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		printf("-- ed -- data flash erase\n");
		printf("-- pd -- data flash program\n");
		printf("-- vd -- data flash verify\n");
		printf("-- rd -- data flash readout\n");

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

	prg_comm(0xfe,0,0,0,0,3,3,0,0);					//enable pull-up

	if(find_cmd("5v"))
	{
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		printf("## using 5V Vcc\n");
	}

	if(find_cmd("lm"))
	{
		small_model=0;
		printf("## Using large memory model\n");
	}

	if(find_cmd("x2"))
	{
		set_pll=2;
		printf("## set PLL to fosc * 2\n");
	}

	if(find_cmd("x4"))
	{
		set_pll=4;
		printf("## set PLL to fosc * 4\n");
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
			printf("## Action: main flash erase\n");
		}

		if(find_cmd("ed"))
		{
			dflash_erase=1;
			printf("## Action: DFLASH erase\n");
		}

		if(find_cmd("un"))
		{
			unsecure=1;
			printf("## Action: write to unsecured state\n");
		}

		main_prog=check_cmd_prog("pm","main flash");
		dflash_prog=check_cmd_prog("pd","data flash");

		main_verify=check_cmd_verify("vm","main flash");
		dflash_verify=check_cmd_verify("vd","data flash");

		main_readout=check_cmd_read("rm","main flash",&main_prog,&main_verify);
		dflash_readout=check_cmd_read("rd","data flash",&dflash_prog,&dflash_verify);

		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

	if((main_readout || dflash_readout) > 0)
	{
		errc=writeblock_open();
	}

	if(dev_start == 0)
	{
		errc=prg_comm(0x10,0,1,0,0,0,0,0,0);					//BDM init
		prdiv8=0;
		if(errc == 0)
		{
			bdmfreq=512/memory[0];
			freq=bdmfreq*2;			//bus clock
			if((freq) > 31)
			{
				freq /=8;
				prdiv8=64;
			}
			bfreq=(int)(bdmfreq+0.5);
			fcdiv=(int)(freq*1)+prdiv8;

			printf("BDM FREQ = %2.1fMHz     USED MODE = %dMHz     FCDIV = 0x%02x\n\n",bdmfreq,bfreq,fcdiv);
			errc=prg_comm(0x40,0,0,0,0,fcdiv,bfreq-1,0,0);
			if(errc == 0x80)
			{
				errc = 0;
			}
//			printf("ERRC=%d\n",errc);

			if(set_pll == 2)
			{
				bfreq*=2;
				errc=prg_comm(0x4b,0,0,0,0,7,7,0,0);		//set PLL
				if(errc==0) errc=prg_comm(0x1f,0,1,0,0,bfreq-1,0,0,0);		//re-init BDM
			}
			if(set_pll == 4)
			{
				bfreq*=4;
				errc=prg_comm(0x4b,0,0,0,0,7,15,0,0);		//set PLL
				if(errc==0) errc=prg_comm(0x1f,0,1,0,0,bfreq-1,0,0,0);		//re-init BDM
			}

			if(set_pll > 1)
			{
				bdmfreq=512/memory[0];
				printf("NEW BDM FREQ = %2.1fMHz\n\n",bdmfreq);
			}
		}
	}

	//erase flash
	if((main_erase == 1) && (errc == 0))
	{
		printf("MASS ERASE\n");
		errc=prg_comm(0x43,0,0,0,0,0,0,0,0);			//main erase
		if((errc == 0x80) || (errc == 0x84))
		{
			errc = 0;
		}
	}

	//unsecure
	if((unsecure == 1) && ((errc == 0) || (errc == 0xc2)))
	{
		printf("UNSECURE DEVICE\n");
		errc=prg_comm(0x44,0,0,0,0,0,0,fcdiv,bfreq-1);		//main erase + unsecure
		if((errc == 0xc0) || (errc == 0xc4))
		{
			errc = 0;
		}
	}

	//program main flash (small model)
	if((main_prog == 1) && (errc == 0) && (small_model == 1))
	{
		addr = 0x7F4000;	//48 K useable Flash
		bsize=max_blocksize;
		blocks = 49152/bsize;
		maddr=0;

		read_block(0x4000,0xC000,0);
//		printf("bsize= %d\n",bsize);
		progress("PROG FLASH ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			if(errc == 0)
			{
//				printf("BLK : %06X LEN %04X\n",addr,bsize);
				if(must_prog(maddr,bsize) && (errc == 0))
				{
					errc=prg_comm(0x45,bsize,0,maddr,0,
						addr & 0xff,(addr >> 8) & 0xff,(addr >> 16) & 0xff,0x80);

					if((errc == 0x80) || (errc == 0x84))
					{
						errc = 0;
					}
				}
				progress("PROG FLASH ",blocks,j+1);
			//	printf("data: %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3]);
				addr+=bsize;
				maddr+=bsize;
			}
		}
		printf("\n");
	}


	//program main flash (large model)
	if((main_prog == 1) && (errc == 0) && (small_model == 0))
	{
		addr=param[0];
		bsize=max_blocksize;
		blocks=param[1]/bsize;
		maddr=0;
		read_block(param[0],param[1],0);

		progress("PROG FLASH ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			if(errc == 0)
			{
				if(must_prog(maddr,bsize) && (errc == 0))
				{
					errc=prg_comm(0x45,bsize,0,maddr,0,
					addr & 0xff,(addr >> 8) & 0xff,(addr >> 16) & 0xff,0x80);
					if((errc == 0x80) || (errc == 0x84))
					{
						errc = 0;
					}
				}
				progress("PROG FLASH ",blocks,j+1);
				addr+=bsize;
				maddr+=bsize;
			}
		}
		printf("\n");
	}

	//readout main flash (small model)
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0) && (small_model == 1))
	{
		bsize = max_blocksize;
		blocks = 49152 / bsize;

		progress("READ FLASH ",blocks,0);
		addr = 0x004000;
		maddr=0;

		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",addr,bsize);
			errc=prg_comm(0x46,0,bsize,0,maddr+ROFFSET,0xfe,0xff,addr & 0xff,(addr >> 8) & 0xff);
			progress("READ FLASH ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	//readout main flash (large model)
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0) && (small_model == 0))
	{
		addr=param[0];
		bsize=max_blocksize;
		blocks=param[1]/16384;
		maddr=0;

		progress("READ FLASH ",blocks*16,0);
		for(i=0;i<blocks;i++)
		{
			ppage=256-blocks+i;
//			printf ("PPAGE= %02x\n",ppage);
			faddr=0x8000;
			subblocks=16384/bsize;
			for(j=0;j<subblocks;j++)
			{
				if(errc == 0)
				{
			//		printf("BLK : %06X LEN %04X\n",addr,bsize);
					errc=prg_comm(0x46,0,bsize,0,maddr+ROFFSET,ppage,0xff,
					faddr & 0xff,(faddr >> 8) & 0xff);
					addr+=bsize;
					faddr+=bsize;
					maddr+=bsize;
					progress("READ FLASH ",blocks*16,i*16+j+1);
				}
			}
		}
		printf("\n");
	}


	if((main_verify == 1) && (errc == 0) && (small_model == 1))
	{
		addr = 0x4000;
		len=49152;
		read_block(0x4000,0xC000,0);
		
		printf("VERIFY FLASH\n");
		for(j=0;j<len;j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",
				addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((main_verify == 1) && (errc == 0) && (small_model == 0))
	{
		addr = param[0],
		len=param[1];
		read_block(param[0],param[1],0);

		printf("VERIFY FLASH ADDR=%06lX  LEN=%06lX\n",addr,len);
		for(j=0;j<len;j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",
				addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((main_readout == 1) && (errc == 0) && (small_model == 1))
	{
		printf("SAVE FLASH\n");
		writeblock_data(0,0xC000,0x4000);
	}


	if((main_readout == 1) && (errc == 0) && (small_model == 0))
	{
		printf("SAVE FLASH\n");
		writeblock_data(0,param[1],param[0]);
	}


	//program dflash
	if((dflash_prog == 1) && (errc == 0))
	{
		addr=0x100000;
		bsize = max_blocksize;
		if(bsize > 8192) bsize=8192;
		blocks = 8192 / bsize;
		maddr=0;

		read_block(addr,8192,0);

		progress("PROG DFLASH ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			if(errc == 0)
			{
//				printf("BLK : %02X PG %02X\n",j,0x100-blocks+j);
				errc=prg_comm(0x48,bsize,0,maddr,0,
					addr & 0xff,(addr >> 8) & 0xff,(addr >> 16) & 0xff,0x80);
				if((errc == 0x80) || (errc == 0x84))
				{
					errc = 0;
				}
			}
			progress("PROG DFLASH ",blocks,j+1);
			//	printf("data: %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3]);
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}


	//readout dflash
	if(((dflash_readout == 1) || (dflash_verify == 1)) && (errc == 0))
	{
		addr=0x100000;
		bsize = max_blocksize;
		if(bsize > 8192) bsize=8192;
		blocks = 8192 / bsize;
		maddr=0;

		progress("READ dflash ",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",addr,bsize);
			errc=prg_comm(0x46,0,bsize,0,maddr+ROFFSET,0xff,j,0,0x08);
			progress("READ dflash ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}


	//verify dflash
	if((dflash_verify == 1) && (errc == 0))
	{
		printf("VERIFY dflash\n");
		addr = 0x100000;

		read_block(addr,8192,0);
		
		for(j=0;j<8192;j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",
				addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	//readout dflash
	if((dflash_readout == 1) && (errc == 0))
	{
		printf("SAVE DFLASH\n");
		writeblock_data(0,8192,0x100000);
	}

	if((run_ram == 1) && (errc == 0))
	{
		read_block(param[8],param[9],0);
		printf("TRANSFER & START CODE\n");
		addr=param[8];
		maddr=0;
		bsize = max_blocksize;
		if(bsize > param[9]) bsize=param[9];
		blocks = param[9] / bsize;

		prg_comm(0x39,0,0,0,0,0,0,0,0);			//active mode
		progress("WRITE RAM ",blocks,0);
		for(i=0;i<blocks;i++)
		{
			if(errc == 0) errc=prg_comm(0x3a,bsize,0,maddr,0,0,(addr >> 8),0,bsize >> 9);	//write words
			addr+=bsize;
			maddr+=bsize;
			progress("WRITE RAM ",blocks,i+1);
		}
		printf("\nSTART ADDR: 0x%08lX\n",loaddr);		
		if(errc == 0) errc=prg_comm(0x31,0,0,0,0,loaddr & 0xff,(loaddr >> 8),0,0);	//exec
		if(errc == 0) waitkey();
	}

	if((main_readout || dflash_readout) > 0)
	{
		errc=writeblock_close();
	}

	if(dev_start == 1)
	{
		prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
		prg_comm(0x0f,0,0,0,0,0,0,0,0);					//exit
	}

	prg_comm(0x0f,0,0,0,0,0,0,0,0);					//exit
	prg_comm(0x11,0,0,0,0,0,0,0,0);					//BDM exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_s12xs_error(errc);

	return errc;
}






