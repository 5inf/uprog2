//###############################################################################
//#										#
//# UPOG2 universal programmer							#
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

void print_stm8_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x21:	set_error("(no SYNC)",errc);
				break;

		case 0x22:	set_error("(SYNC pulse too long)",errc);
				break;

		case 0x23:	set_error("(unsupported SWIM frequency)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_stm8(void)
{
	int errc,blocks,bsize,i,j,subblock,sbb,ifreq;
	unsigned long ramsize,ramstart,addr,flash_addr,flash_size,faddr,maddr;
	float freq;
	int unsecure = 0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dev_start=0;
	int run_ram=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int option_prog=0;
	int option_verify=0;
	int option_readout=0;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		
		printf("-- un -- unsecure device\n");

//		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

//		printf("-- ee -- eeprom erase\n");
		printf("-- pe -- eeprom program\n");
		printf("-- ve -- eeprom verify\n");
		printf("-- re -- eeprom readout\n");

//		printf("-- eo -- option bytes erase\n");
		printf("-- po -- option bytes program\n");
		printf("-- vo -- option bytes verify\n");
		printf("-- ro -- option bytes readout\n");

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

	if(find_cmd("5v"))
	{
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		printf("## using 5V VDD\n");
	}

	if(find_cmd("un"))
	{
		unsecure=1;
		printf("## Action: remove ROP\n");
	}

	errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);	//enable PU



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
		main_prog=check_cmd_prog("pm","code flash");
		eeprom_prog=check_cmd_prog("pe","eeprom");
		option_prog=check_cmd_prog("po","option bytes");

		main_verify=check_cmd_verify("vm","code flash");
		eeprom_verify=check_cmd_verify("ve","eeprom");
		option_verify=check_cmd_verify("vo","option bytes");

		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
		eeprom_readout=check_cmd_read("re","eeprom",&eeprom_prog,&eeprom_verify);
		option_readout=check_cmd_read("ro","option bytes",&option_prog,&option_verify);

		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

	if((main_readout || eeprom_readout || option_readout) > 0)
	{
		errc=writeblock_open();
	}


	if(dev_start == 0)
	{
		errc=prg_comm(0x50,0,1,0,0x5000,0,0,0,0);					//SWIM init
		if(errc == 0)
		{
			freq=512.0/memory[0x5000];
			ifreq=(int)(freq+0.5);
			printf("SWIM FREQ = %2.1f (%d)MHz\n\n",freq,ifreq);
			
			switch(ifreq)
			{
				case 8:		errc=prg_comm(0x52,0,0,0,0,13,1,6,0);break;	
				default:	errc=0x23;
			}
			
		}
	}

	//unsecure
	if((unsecure == 1) && (errc == 0))
	{
		printf("REMOVE ROP\n");
		addr=0x3000;
		//write DUKR
		memory[addr++]=0x01;			//1 byte
		memory[addr++]=0x00;			//AE
		memory[addr++]=param[14] >> 8;		//AH
		memory[addr++]=param[14] & 0xff;	//AL
		memory[addr++]=0xAE;			//data

		//wait 1ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x01;			//low
		memory[addr++]=0x00;			//high
		
		//write DUKR
		memory[addr++]=0x01;			//1 byte
		memory[addr++]=0x00;			//AE
		memory[addr++]=param[14] >> 8;		//AH
		memory[addr++]=param[14] & 0xff;	//AL
		memory[addr++]=0x56;			//data

		//wait 1ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x01;			//low
		memory[addr++]=0x00;			//high

		if(param[15] > 0x100) //does we have flash_ncr2?
		{
			memory[addr++]=0x02;			//1 byte
			memory[addr++]=0x00;			//AE
			memory[addr++]=param[12] >> 8;		//AH
			memory[addr++]=param[12] & 0xff;	//AL
			memory[addr++]=param[15] & 0xff;	//data
			memory[addr++]=~(param[15] & 0xff);	//inv data
		}
		else
		{
			memory[addr++]=0x01;			//1 byte
			memory[addr++]=0x00;			//AE
			memory[addr++]=param[12] >> 8;		//AH
			memory[addr++]=param[12] & 0xff;	//AL
			memory[addr++]=param[15] & 0xff;	//data
		}
		//wait 1ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x01;			//low
		memory[addr++]=0x00;			//high

		//write OPT0 (ROP)
		memory[addr++]=0x01;			//1 byte
		memory[addr++]=0x00;			//AE
		memory[addr++]=0x48;			//AH
		memory[addr++]=0x00;			//AL
		memory[addr++]=0xaa; //param[4];		//data

		//wait 512ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x00;			//low
		memory[addr++]=0x02;			//high

		if(param[16] & 0x01) //does we have nopt1 ?
		{
			memory[addr++]=0x02;			//1 byte
			memory[addr++]=0x00;			//AE
			memory[addr++]=0x48;			//AH
			memory[addr++]=0x01;			//AL
			memory[addr++]=0x00;			//data
			memory[addr++]=0xff;			//inv data
		}
		else
		{
			memory[addr++]=0x01;			//1 byte
			memory[addr++]=0x00;			//AE
			memory[addr++]=0x48;			//AH
			memory[addr++]=0x01;			//AL
			memory[addr++]=0x00;			//data
		}
		//wait 5ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x05;			//low
		memory[addr++]=0x00;			//high

		//write DUKR
		memory[addr++]=0x01;			//1 byte
		memory[addr++]=0x00;			//AE
		memory[addr++]=param[14] >> 8;		//AH
		memory[addr++]=param[14] & 0xff;	//AL
		memory[addr++]=0xAE;			//data

		//wait 1ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x01;			//low
		memory[addr++]=0x00;			//high
		
		//write DUKR
		memory[addr++]=0x01;			//1 byte
		memory[addr++]=0x00;			//AE
		memory[addr++]=param[14] >> 8;		//AH
		memory[addr++]=param[14] & 0xff;	//AL
		memory[addr++]=0x56;			//data

		//wait 1ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x01;			//low
		memory[addr++]=0x00;			//high

		if(param[15] > 0x100) //does we have flash_ncr2?
		{
			memory[addr++]=0x02;			//1 byte
			memory[addr++]=0x00;			//AE
			memory[addr++]=param[12] >> 8;		//AH
			memory[addr++]=param[12] & 0xff;	//AL
			memory[addr++]=param[15] & 0xff;	//data
			memory[addr++]=~(param[15] & 0xff);	//inv data
		}
		else
		{
			memory[addr++]=0x01;			//1 byte
			memory[addr++]=0x00;			//AE
			memory[addr++]=param[12] >> 8;		//AH
			memory[addr++]=param[12] & 0xff;	//AL
			memory[addr++]=param[15] & 0xff;	//data
		}
		//wait 1ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x01;			//low
		memory[addr++]=0x00;			//high

		//write OPT0 (ROP)
		memory[addr++]=0x01;			//1 byte
		memory[addr++]=0x00;			//AE
		memory[addr++]=0x48;			//AH
		memory[addr++]=0x00;			//AL
		memory[addr++]=0xaa; //param[4];		//data

		//wait 10ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x0a;			//low
		memory[addr++]=0x00;			//high

		if(param[16] & 0x01) //does we have nopt1 ?
		{
			memory[addr++]=0x02;			//1 byte
			memory[addr++]=0x00;			//AE
			memory[addr++]=0x48;			//AH
			memory[addr++]=0x01;			//AL
			memory[addr++]=0x00;			//data
			memory[addr++]=0xff;			//inv data
		}
		else
		{
			memory[addr++]=0x01;			//1 byte
			memory[addr++]=0x00;			//AE
			memory[addr++]=0x48;			//AH
			memory[addr++]=0x0a;			//AL
			memory[addr++]=0x01;			//data
		}
		//wait 5ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x05;			//low
		memory[addr++]=0x00;			//high



		//end of sequence
		memory[addr++]=0xff;			//end

		errc=prg_comm(0x53,addr-0x3000,0,0x3000,0,0,0,0,0);	//SWIM sequence
		errc=prg_comm(0x50,0,1,0,0x5000,0,0,0,0);		//SWIM init
		errc=prg_comm(0x52,0,0,0,0,0,0,0,0);			//SWIM config
	}


	//program main flash
	if((main_prog == 1) && (errc == 0))
	{
		addr=0x20000;
		read_block(param[0],param[1],param[0]);
		//write PUKR
		memory[addr++]=0x01;			//1 byte
		memory[addr++]=0x00;			//AE
		memory[addr++]=param[13] >> 8;		//AH
		memory[addr++]=param[13] & 0xff;	//AL
		memory[addr++]=0x56;			//data

		//wait 1ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x01;			//low
		memory[addr++]=0x00;			//high
		
		//write PUKR
		memory[addr++]=0x01;			//1 byte
		memory[addr++]=0x00;			//AE
		memory[addr++]=param[13] >> 8;		//AH
		memory[addr++]=param[13] & 0xff;	//AL
		memory[addr++]=0xAE;			//data

		//wait 1ms
		memory[addr++]=0xa0;			//time
		memory[addr++]=0x01;			//low
		memory[addr++]=0x00;			//high

		//end of sequence
		memory[addr++]=0xff;			//end

//waitkey();

		errc=prg_comm(0x53,addr-0x20000,0,0x20000,0,0,0,0,0);	//SWIM sequence

//waitkey();

		faddr = param[0];
		bsize = 1024;
		if(bsize > param[1]) bsize=param[1];
		blocks = param[1] / bsize;
		progress("PROG FLASH  ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			if(errc == 0)
			{
//				printf("BLK : %06X LEN %04X\n",faddr,bsize);
				addr=0x20000;
				sbb=1024/param[6];
				for(subblock=0;subblock<sbb;subblock++)
				{
					if(param[17] > 0x100) //does we have flash_ncr2?
					{
						memory[addr++]=0x02;			//2 bytes
						memory[addr++]=0x00;			//AE
						memory[addr++]=param[12] >> 8;		//AH
						memory[addr++]=param[12] & 0xff;	//AL
						memory[addr++]=param[17] & 0xff;	//data
						memory[addr++]=~(param[17] & 0xff);	//inv data
					}
					else
					{
						memory[addr++]=0x01;			//1 byte
						memory[addr++]=0x00;			//AE
						memory[addr++]=param[12] >> 8;		//AH
						memory[addr++]=param[12] & 0xff;	//AL
						memory[addr++]=param[17] & 0xff;	//data
					}

					//wait 1ms
					memory[addr++]=0xa0;			//time
					memory[addr++]=0x01;			//low
					memory[addr++]=0x00;			//high

					memory[addr++]=param[6];		//pagesize
					memory[addr++]=(faddr >> 16) & 0xff;	//AE
					memory[addr++]=(faddr >> 8) & 0xff;	//AH
					memory[addr++]=faddr & 0xff;		//AL
					for(i=0;i<param[6];i++)
					{
						memory[addr++]=memory[faddr++];
					}

					//wait 10ms
					memory[addr++]=0xa0;			//time
					memory[addr++]=0x20;			//low
					memory[addr++]=0x00;			//high
				}

				//end of sequence
				memory[addr++]=0xff;			//end

				errc=prg_comm(0x53,addr-0x20000,0,0x20000,0,0,0,0,0);	//SWIM sequence

				progress("PROG FLASH  ",blocks,j+1);
			//	printf("data: %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3]);
			}
		}
		printf("\n");
	}

	//readout main flash
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		bsize=max_blocksize;
		flash_addr=param[0];
		flash_size=param[1];
		if(bsize > param[1]) bsize=param[1];
		blocks = flash_size / bsize;
		maddr=0;
		
		progress("READ FLASH  ",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",flash_addr,bsize);
			errc=prg_comm(0x56,0,bsize,0,maddr+ROFFSET,
			(flash_addr & 0xff),(flash_addr >> 8) & 0xff,(flash_addr >> 16) & 0xff,0);
			progress("READ FLASH  ",blocks,j+1);
			flash_addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	if((main_verify == 1) && (errc == 0))
	{
		read_file();
		printf("VERIFY FLASH\n");
		flash_addr=param[0];
		flash_size=param[1];
		maddr=0;
		for(j=0;j<flash_size;j++)
		{
			if(memory[flash_addr+j] != memory[maddr+j+ROFFSET])
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",
				flash_addr+j,memory[flash_addr+j],memory[flash_addr+j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((main_readout == 1) && (errc == 0))
	{
		printf("SAVE FLASH\n");
		writeblock_data(0,param[1],param[0]);
	}


	//readout eeprom
	if(((eeprom_readout == 1) || (eeprom_verify == 1)) && (errc == 0))
	{
		bsize=max_blocksize;
		flash_addr=param[2];
		flash_size=param[3];
		if(flash_size < bsize) bsize=flash_size;
		blocks = flash_size / bsize;

		progress("READ EEPROM ",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",flash_addr,bsize);
			errc=prg_comm(0x56,0,bsize,0,flash_addr+ROFFSET,
			(flash_addr & 0xff),(flash_addr >> 8) & 0xff,(flash_addr >> 16) & 0xff,0);
			progress("READ EEPROM ",blocks,j+1);
			flash_addr+=bsize;
		}
		printf("\n");
	}

	if((eeprom_verify == 1) && (errc == 0))
	{
		read_block(param[2],param[3],param[2]);
		printf("VERIFY EEPROM\n");
		flash_addr=param[2];
		flash_size=param[3];
		for(j=0;j<flash_size;j++)
		{
			if(memory[flash_addr+j] != memory[flash_addr+j+ROFFSET])
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",
				flash_addr+j,memory[flash_addr+j],memory[flash_addr+j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((eeprom_readout == 1) && (errc == 0))
	{
		printf("SAVE EEPROM\n");
		writeblock_data(0,param[3],param[2]);
	}


	//readout option
	if(((option_readout == 1) || (option_verify == 1)) && (errc == 0))
	{
		bsize=1024;
		flash_addr=0x4800;
		flash_size=param[6];

		printf("READ OPTION \n");
		errc=prg_comm(0x56,0,flash_size,0,flash_addr+ROFFSET,
		(flash_addr & 0xff),(flash_addr >> 8) & 0xff,(flash_addr >> 16) & 0xff,0);
	}

	if((option_verify == 1) && (errc == 0))
	{
		read_block(0x4800,param[6],0x4800);
		printf("VERIFY OPTION\n");
		flash_addr=0x4800;
		flash_size=param[6];
		for(j=0;j<flash_size;j++)
		{
			if(memory[flash_addr+j] != memory[flash_addr+j+ROFFSET])
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",
				flash_addr+j,memory[flash_addr+j],memory[flash_addr+j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((option_readout == 1) && (errc == 0))
	{
		printf("SAVE OPTION BYTES\n");
		writeblock_data(0,param[6],0x4800);
	}

	if((run_ram == 1) && (errc == 0))
	{
		printf("TRANSFER & START CODE\n");
		ramstart = param[8];
		ramsize = param[9];
		read_block(ramstart,ramsize,ramstart);
		bsize=max_blocksize;
		if(bsize > ramsize) bsize = ramsize;

//		errc=prg_comm(0x53,0,256,0,ROFFSET,0,0,0,0);			//SWIM test
		if(errc == 0) errc=prg_comm(0x54,bsize,0,ramstart,0,0,4,0,0);	//write data (4 blocks)
		if(errc == 0) errc=prg_comm(0x55,0,0,0,0,0,0,0,0);		//start code at 0x00
		if(errc == 0) waitkey();
	}


	if((main_readout || eeprom_readout || option_readout) > 0)
	{
		writeblock_close();
	}

	if(dev_start == 1)
	{
		prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
		prg_comm(0x0f,0,0,0,0,0,0,0,0);			//exit
	}

	prg_comm(0x51,0,0,0,0,0,0,0,0);				//SWIM exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	errc=prg_comm(0xfe,0,0,0,0,0,0,0,0);	//disable PU

	print_stm8_error(errc);

	return errc;
}






