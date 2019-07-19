//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2010-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
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

void print_s12xd_error(int errc)
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


int prog_s12xd(void)
{
	int errc,blocks,bsize,fblockaddr,fblocksize,i,j;
	unsigned long addr,flashblockaddr,flashblocksize,faddr,maddr,len;
	int prdiv8,bfreq=0,fcdiv=0,jj,flash_erased=0,flashpage,flash_secured=0;
	float freq,bdmfreq;
	int main_erase=0;
	int unsecure = 0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dev_start=0;
	int run_ram=0;
	int small_model=1;
	int eeprom_erase=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int set_pll = 1;

	errc=0;
	maddr=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- lm -- large memory mode\n");
		printf("-- x2 -- set PLL to F*2\n");
		printf("-- x4 -- set PLL to F*4\n");
		printf("-- un -- unsecure device\n");

		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");
		
		printf("-- ee -- eeprom erase\n");
		printf("-- pe -- eeprom program\n");
		printf("-- ve -- eeprom verify\n");
		printf("-- re -- eeprom readout\n");

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

	if(find_cmd("rc"))
	{
		if(file_found < 2)
		{
			run_ram = 0;
			printf("## Action: run code in RAM !! DISABLED BECAUSE OF NO FILE !!\n");
		}
		else
		{
			run_ram=2;
			printf("## Action: run code in RAM using %s\n",sfile);
		}
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

		if(find_cmd("ee"))
		{
			eeprom_erase=1;
			printf("## Action: eeprom erase\n");
		}

		if(find_cmd("un"))
		{
			unsecure=1;
			printf("\n");
		}



		main_prog=check_cmd_prog("pm","code flash");
		eeprom_prog=check_cmd_prog("pe","eeprom");

		main_verify=check_cmd_verify("vm","code flash");
		eeprom_verify=check_cmd_verify("ve","eeprom");

		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
		eeprom_readout=check_cmd_read("re","eeprom",&eeprom_prog,&eeprom_verify);

		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");
	
	if((main_readout || eeprom_readout) > 0)
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
			if((freq) > 12.6)
			{
				freq /=8;
				prdiv8=64;
			}
			bfreq=(int)(bdmfreq+0.5);
			fcdiv=(int)(freq*5.01)+prdiv8;

			printf("BDM FREQ = %2.1fMHz     USED MODE = %dMHz     FCDIV = 0x%02x\n\n",bdmfreq,bfreq,fcdiv);
			errc=prg_comm(0x30,0,0,0,0,fcdiv,bfreq-1,0,0);
			if(errc == 0xc0)
			{
				errc = 0;
				flash_erased = 0;
			}
			if(errc == 0xc2)
			{
				errc = 0;
				flash_secured = 1;
			}
			if(errc == 0xc4)
			{
				errc = 0;
				flash_erased = 1;
			}
			

			if(set_pll == 2)
			{
				bfreq*=2;
				errc=prg_comm(0x3b,0,0,0,0,2,0,0,0);		//set PLL
				if(errc==0) errc=prg_comm(0x1f,0,1,0,0,bfreq-1,0,0,0);		//re-init
			}
			if(set_pll == 4)
			{
				bfreq*=4;
				errc=prg_comm(0x3b,0,0,0,0,4,0,0,0);		//set PLL
				if(errc==0) errc=prg_comm(0x1f,0,1,0,0,bfreq-1,0,0,0);		//re-init
			}

			if(set_pll > 1)
			{
				bdmfreq=512/memory[0];
				printf("NEW BDM FREQ = %2.1fMHz\n\n",bdmfreq);
			}
		}
	}

	if(flash_erased == 1)
	{
		printf("DEVICE IS ERASED\n");
		main_erase = 0;
	}


	//erase eeprom
	if((eeprom_erase == 1) && (errc == 0))
	{
		printf("ERASE EEPROM\n");
		errc=prg_comm(0x38,0,0,0,0,0,0,0,0);			//main erase
		if((errc == 0xc0) || (errc == 0xc4))
		{
			errc = 0;
		}
	}

	//erase flash
	if((main_erase == 1) && (errc == 0))
	{
		printf("ERASE FLASH\n");
		errc=prg_comm(0x33,0,0,0,0,0,0,0,0);			//main erase
		if((errc == 0xc0) || (errc == 0xc4))
		{
			errc = 0;
		}
	}

	//unsecure
	if((unsecure == 1) && ((errc == 0) || (errc == 0xc2)))
	{
		printf("UNSECURE DEVICE\n");
		errc=prg_comm(0x34,0,0,0,0,0,0,fcdiv,bfreq-1);		//main erase + unsecure
		if((errc == 0xc0) || (errc == 0xc4))
		{
			errc = 0;
		}
	}



	if(flash_secured == 1)
	{
		printf("DEVICE IS SECURED\n");
		errc = 0xc2;
	}




	//program main flash (small model)
	if((main_prog == 1) && (errc == 0) && (small_model == 1))
	{
		read_block(0x4000,0xc000,0);
		addr = 0x4000;			//48 K useable Flash
		bsize = max_blocksize;
		blocks = 49152 / bsize;
		maddr=0;
		progress("PROG FLASH ",blocks,0);

		for(j=0;j<blocks;j++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))
			{
//				printf("WBLK : %06X LEN %04X\n",addr,bsize);
				errc=prg_comm(0x35,bsize,0,maddr,0,
					0,0xfe,addr & 0xff,(addr >> 8) & 0xff);
				if((errc == 0xc0) || (errc == 0xc4))
				{
					errc = 0;
				}
			}
			progress("PROG FLASH ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}


	//program main flash (large model)
	if((main_prog == 1) && (errc == 0) && (small_model == 0))
	{
		read_block(0x700000,0x100000,0);		//max 1M
		for(i=0;i<8;i++)
		{
			fblockaddr=param[0];
			if(i > 3) fblockaddr=param[2];
			jj = (3 - (i & 3)) * 8;
			flashblockaddr = (fblockaddr >> jj) & 0xff;
			addr = flashblockaddr << 16;
			maddr=addr-0x700000;

			if(flashblockaddr != 0)
			{
				flashblocksize=param[1];
				if(i > 3) fblocksize=param[3];
				jj = (3 - (i & 3)) * 8;
				bsize = max_blocksize;
				fblocksize = (flashblocksize >> jj) & 0xff;
				blocks = (fblocksize << 12) / bsize;

				printf("BLOCK AT ADDR : %06lX\n",addr);

				progress("PROG FLASH BLOCK ",blocks,0);
				for(j=0;j<blocks;j++)
				{
					if(must_prog(maddr,bsize) && (errc == 0))
					{
//						printf("BLK : %06X LEN %04X\n",addr,bsize);
						faddr=(addr & 0x3FFF) + 0x8000;
						flashpage=(addr >> 14) - 0x100;
						errc=prg_comm(0x35,bsize,0,maddr,0,
							0,flashpage,faddr & 0xff,(faddr >> 8) & 0xff);
						if((errc == 0xc0) || (errc == 0xc4))
						{
							errc = 0;
						}
					}
						progress("PROG FLASH BLOCK ",blocks,j+1);
						addr+=bsize;
						maddr+=bsize;
				}
				printf("\n");
			}
		}
	}

	//readout main flash (small model)
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0) && (small_model == 1))
	{
		bsize = max_blocksize;
		blocks = 49152 / bsize;
		maddr=0;

		progress("READ FLASH ",blocks,0);
		addr = 0x004000;
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",addr,bsize);
			errc=prg_comm(0x37,0,bsize,0,maddr+ROFFSET,0xfe,0xff,addr & 0xff,(addr >> 8) & 0xff);
			progress("READ FLASH ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}


	//readout main flash (large model)
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0) && (small_model == 0))
	{
		bsize = max_blocksize;
		
		for(i=0;i<4;i++)
		{
			flashblockaddr=param[0];
			if(i > 3) flashblockaddr=param[2];
			jj = (3 - (i & 3)) * 8;
			flashblockaddr = (flashblockaddr >> jj) & 0xff;
			addr = flashblockaddr << 16;
			maddr=addr-0x700000;
			//first flash page			
			flashpage = (flashblockaddr * 4) & 0xff;

			if(flashblockaddr != 0)		//active block
			{
				flashblocksize=param[1];
				if(i > 3) flashblocksize=param[3];
				jj = (3 - (i & 3)) * 8;
				blocks = ((flashblocksize >> jj) & 0xff) * 4096 / bsize;

				printf("PAGE : %02X LEN : %d Blocks\n",flashpage,blocks);

				faddr=0x8000;

				progress("READ ",blocks,0);
				for(j=0;j<blocks;j++)
				{
					if(errc == 0)
					{
//						printf("BLK : %06lX PAGE %02X\n",addr,flashpage);
						errc=prg_comm(0x46,0,bsize,0,maddr+ROFFSET,flashpage,0xff,
						faddr & 0xff,(faddr >> 8) & 0xff);
						progress("READ ",blocks,j+1);
						addr+=bsize;
						maddr+=bsize;
						faddr+=bsize;
						if(faddr > 0xbfff) 
						{
							flashpage++;
							faddr=0x8000;
						}
					}
				}
				printf("\n");
			}
		}
	}




	//verify (small model)
	if((main_verify == 1) && (errc == 0) && (small_model == 1))
	{
		read_block(0x4000,0xC000,0);
		addr = 0x4000;
		i=0;
		for(j=0;j<0xc000;j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %04lX  FILE= %02X  READ= %02X\n",
					addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	//verify (large model)
	if((main_verify == 1) && (errc == 0) && (small_model == 0))
	{
		read_block(0x700000,0x100000,0);	//read 1M

		for(i=3;i>=0;i--)
		{
			flashblockaddr=param[0];
			if(i > 3) flashblockaddr=param[2];
			jj = (3 - (i & 3)) * 8;
			flashblockaddr = (flashblockaddr >> jj) & 0xff;
			addr = flashblockaddr << 16;
			maddr=addr-0x700000;			

			if(flashblockaddr != 0)
			{
				flashblocksize=param[1];
				if(i > 3) flashblocksize=param[3];
				jj = (3 - (i & 3)) * 8;
				len=((flashblocksize >> jj) & 0xff) * 4096;
				
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
		}
	}


	if((main_readout == 1) && (errc == 0) && (small_model == 1))
	{
		writeblock_data(0,0xC000,0x4000);
	}

	if((main_readout == 1) && (errc == 0) && (small_model == 0))
	{
		for(i=3;i>=0;i--)
		{
			flashblockaddr=param[0];
			if(i > 3) flashblockaddr=param[2];
			jj = (3 - (i & 3)) * 8;
			flashblockaddr = (flashblockaddr >> jj) & 0xff;
			addr = flashblockaddr << 16;
			maddr=addr-0x700000;			

			if(flashblockaddr != 0)
			{
				flashblocksize=param[1];
				if(i > 3) flashblocksize=param[3];
				jj = (3 - (i & 3)) * 8;
				len=((flashblocksize >> jj) & 0xff) * 4096;
				
				writeblock_data(maddr,len,addr);
			}
		}
	}



	//program eeprom
	if((eeprom_prog == 1) && (errc == 0))
	{
		read_block(0x140000-param[5],param[5],0);	//read eeprom block
		bsize = max_blocksize;
		if(bsize > param[5]) bsize=param[5];
		blocks = param[5] / bsize;
		maddr=0;
		
		progress("PROG EEPROM ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			if(errc == 0)
			{
//				printf("BLK : %02X PG %02X\n",j,0x100-blocks+j);
				errc=prg_comm(0x36,bsize,0,maddr,0,0x100-blocks+j,0,0,0);
				if((errc == 0xc0) || (errc == 0xc4))
				{
					errc = 0;
				}
			}
			progress("PROG EEPROM ",blocks,j+1);
			//	printf("data: %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3]);
			maddr+=bsize;
		}
		printf("\n");
	}


	//readout eeprom
	if(((eeprom_readout == 1) || (eeprom_verify == 1)) && (errc == 0))
	{
		maddr=0;
		bsize = max_blocksize;
		if(bsize > param[5]) bsize=param[5];
		blocks = param[5] / bsize;

		progress("READ EEPROM ",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",addr,bsize);
			errc=prg_comm(0x3c,0,bsize,0,maddr+ROFFSET,0x100-blocks+j,0,0,0);
			progress("READ EEPROM ",blocks,j+1);
			maddr+=bsize;
		}
		printf("\n");
	}


	//verify eeprom
	if((eeprom_verify == 1) && (errc == 0))
	{
		read_block(0x140000-param[5],param[5],0);	//read eeprom block
		addr=0x140000-param[5];
		printf("VERIFY EEPROM\n");
		i=0;
		for(j=0;j<param[5];j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",
				addr+j,memory[addr+j],memory[addr+j+ROFFSET]);
				errc=1;
			}
		}
	}

	//readout eeprom
	if((eeprom_readout == 1) && (errc == 0))
	{
		printf("SAVE EEPROM\n");
		writeblock_data(0,param[5],0x140000-param[5]);
	}

	if((run_ram == 1) && (errc == 0))
	{
		len=read_block(param[8],param[9]+1,0);
		if(len > param[9])
		{
			printf("!! ERROR, RAM IMAGE TO BIG !!\n");
		}
		else
		{
			printf("TRANSFER CODE\n");
			bsize = max_blocksize;
			if(bsize > param[9]) bsize=param[9];
			blocks=param[9]/bsize;
			addr=param[8];
			progress("WRITE RAM ",blocks,0);

			errc=prg_comm(0x39,0,0,0,0,3,3,0,0);	//active mode
			for(i=0;i<blocks;i++)
			{
//				printf("BLK : %06X LEN %04X\n",addr,bsize);
				if(errc == 0) errc=prg_comm(0x3a,bsize,0,maddr,0,0,(addr >> 8),0,bsize >> 9);	//write words
				addr+=bsize;
				maddr+=bsize;
				progress("WRITE RAM ",blocks,i+1);
			}

			if(errc == 0)
			{
				printf("\nSTART CODE\n");

				if(errc == 0) errc=prg_comm(0x31,0,0,0,0,loaddr & 0xff,(loaddr >> 8),0,0);	//exec
				if(errc == 0) waitkey();
			}
		}
	}

	if((run_ram == 2) && (errc == 0))
	{
		read_block(param[8],param[9],0);
		sleep(1);
		printf("TRANSFER & START CODE (HH12X)\n");
		bsize = max_blocksize;
		if(bsize > param[9]) bsize=param[9];
		blocks=param[9]/bsize;
		addr=param[8];
		maddr=0;
		
		progress("WRITE RAM ",blocks,0);
		for(i=0;i<blocks;i++)
		{
			if(errc == 0) errc=prg_comm(0x3a,bsize,0,maddr,0,0,(addr >> 8),0,bsize >> 9);	//write words
			addr+=bsize;
			maddr+=bsize;
			progress("WRITE RAM ",blocks,i+1);
		}

		errc=prg_comm(0x31,0,0,0,0,0x60,0xC0,0,0);	//exec
		waitkey();
		errc=0;
	}

	if((main_readout || eeprom_readout) > 0)
	{
		writeblock_close();
	}	


	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);		//init
		waitkey();
		i=prg_comm(0x0f,0,0,0,0,0,0,0,0);		//exit
	}

	i=prg_comm(0x0f,0,0,0,0,0,0,0,0);			//exit
	i=prg_comm(0x11,0,0,0,0,0,0,0,0);			//BDM exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_s12xd_error(errc);

	return errc;
}







