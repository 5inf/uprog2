//###############################################################################
//#										#
//# UPROG universal programmer							#
//#										#
//# copyright (c) 2012-2020 Joerg Wolfram (joerg@jcwolfram.de)			#
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

void print_spiflash_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(TIMEOUT)",errc);
				break;

		case 0x43:	set_error("(wrong size)",errc);
				break;

		case 0x59:	set_error("(cannot set/reset quad mode)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int prog_spiflash(void)
{
	int errc,blocks,i,loops,maxloops,rstat;
	unsigned long addr,maddr,len;
	int bsize,bank;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int unprotect=0;
	int protect=0;
	int ignore_size=0;
	int is_quad=0;
	errc=0;


	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- ea -- bulk erase\n");
		printf("-- un -- unprotect\n");
		printf("-- pr -- protect all\n");
		printf("-- pm -- memory program\n");
		printf("-- vm -- memory verify\n");
		printf("-- rm -- memory read\n");
		printf("-- rc -- config bytes read\n");
		printf("-- is -- ignore size\n");
 		printf("-- d2 -- switch to device 2\n");

		return 0;
	}

	if(find_cmd("d2"))
	{
		errc=prg_comm(0x2ee,0,0,0,0,0,0,0,0);	//dev 2
		printf("## switch to device 2\n");
	}

	if(find_cmd("is"))
	{
		ignore_size=1;
		printf("## ignore size identifier\n");
	}

	if(find_cmd("ea"))
	{
		main_erase=1;
		printf("## Action: bulk erase\n");
	}

	if(find_cmd("un"))
	{
		unprotect=1;
		printf("## Action: disable all write protection\n");
	}

	if(find_cmd("pr"))
	{
		protect=1;
		printf("## Action: enable all write protection\n");
	}

	main_prog=check_cmd_prog("pm","memory");
	main_verify=check_cmd_verify("vm","memory");
	main_readout=check_cmd_read("rm","memory",&main_prog,&main_verify);
	
	if(main_readout > 0)
	{
		errc=writeblock_open();
	}

	if(errc==0) 
	{
		errc=prg_comm(0x100,0,0,0,0,0,0,0,0);				//init
		errc=prg_comm(0x105,0,4,0,0,4,param[4] & 0xff,0,0);		//get info
		printf(" Manuf.-ID:     %02X",memory[0]);
		switch(memory[0])
		{
			case 0x01:	printf(" (Spansion / AMD)\n");break;
			case 0x04:	printf(" (Fujitsu)\n");break;
			case 0x1F:	printf(" (Atmel / Adesto)\n");break;
			case 0x20:	printf(" (STM / Micron)\n");break;
			case 0x29:	printf(" (Microchip)\n");break;
			case 0x37:	printf(" (AMIC)\n");break;
			case 0x52:	printf(" (Alliance)\n");break;
			case 0x89:	printf(" (Intel)\n");break;
			case 0x97:	printf(" (Texas Instruments)\n");break;
			
			case 0xDA:
			case 0xEF:	printf(" (Winbond)\n");break;
			
			case 0xBF:	printf(" (SST)\n");break;
			case 0xC2:	printf(" (Macronix)\n");break;

			case 0x9D:
			case 0xD5:	printf(" (ISSI)\n");break;

			case 0xCE:	printf(" (Samsung)\n");break;
			case 0xC8:	printf(" (Giga)\n");break;
			
			default:	printf(" (unknown vendor)\n");
		}
		printf(" Memory type:   %02X\n",memory[1]);
		printf(" Memory size:   %02X",memory[2]);
		switch(memory[02])
		{
			case 0x14:	printf(" (1M, 25x80)\n");break;
			case 0x15:	printf(" (2M, 25x16)\n");break;
			case 0x16:	printf(" (4M, 25x32)\n");break;
			case 0x17:	printf(" (8M, 25x64)\n");break;
			case 0x18:	printf(" (16M, 25x128)\n");break;
			case 0x19:	printf(" (32M, 25x256)\n");break;
			case 0x1A:	printf(" (64M, 25x512)\n");break;
			case 0x20:	printf(" (64M, 25x512)\n");break;
			default:	printf(" (unknown size)\n");
		}


	}

	if((memory[2] != ((unsigned char)(param[5] >> 8) & 0xff)) && (ignore_size == 0))
	{
		printf(" Memory size:   %02X, should be %02X\n\n",memory[2],(unsigned char)(param[5] >> 8) & 0xff);
		errc=0x43;
		goto SPIF_FEXIT;
	}

	if((memory[0] != ((unsigned char)(param[5] >> 24) & 0xff)) && (ignore_size == 0) && (param[18]==1))
	{
		printf(" Vendor:        %02X, should be %02X\n\n",memory[0],(unsigned char)(param[5] >> 24) & 0xff);
		errc=0x43;
		goto SPIF_FEXIT;
	}
		
	if((unprotect == 1) && (errc == 0))
	{
		printf("DISABLE WRITE PROTECTION\n");
		memory[0]=(param[7] >> 24) & 0xff;
		memory[1]=(param[7] >> 16) & 0xff;
		memory[2]=(param[7] >> 8) & 0xff;
		memory[3]=(param[7]) & 0xff;
		
		errc=prg_comm(0x106,4,0,0,0,
				param[6] & 0xff,		//num data
				(param[6] >> 8) & 0xff,		//CMD
				10,				//100ms max
				0);
	}	
	
	if((main_erase == 1) && (errc == 0))
	{
		maxloops=(param[2] >> 8) & 0xff;
		progress("ERASE",maxloops,0);
		errc=prg_comm(0x124,0,0,0,0,0,0,0,0);
		loops=0;
		
		do
		{
			progress("ERASE",maxloops,loops);
			loops++;
			sleep(1);
			rstat=prg_comm(0x123,0,0,0,0,0,0,0,0);
		}while((loops < maxloops) && (rstat > 0x60));
		if(loops==maxloops) errc=0x41;
		printf("\n");
	}	


	if((main_prog == 1) && (errc == 0) && (param[3] == 0))
	{
		len=param[1]*256;
		if(len > 0x1000000) len=0x1000000;
		
		read_block(param[0],len,0);
		bsize=max_blocksize;
		addr=param[0];
		blocks=len/bsize;
		maddr=0;

		progress("PROG ",blocks,0);
		for(i=0;i<blocks;i++)
		{
			if(must_prog(maddr,bsize) && (errc==0))
			{
				if(param[11]==256)
				{
					errc=prg_comm(0x103,bsize,0,maddr,0,
						(addr & 0xff),
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						bsize >> 8);		//write
				}
				if(param[11]==512)
				{
					errc=prg_comm(0x10F,bsize,0,maddr,0,
						(addr & 0xff),
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						bsize >> 9);		//write
				}
			}
			addr+=bsize;			
			maddr+=bsize;
			progress("PROG ",blocks,i+1);
		}
	}

	if((main_prog == 1) && (errc == 0) && (param[3] > 0))
	{
		for(bank=0;bank<=param[3];bank++)
		{
			len=param[1]*256;
			if(len > 0x1000000) len=0x1000000;
		
			printf("PROGRAM DATA FOR BANK %d\n",bank);
			read_block(param[0]+(bank << 24),len,0);
			bsize=max_blocksize;
			addr=param[0]+(bank << 24);
			blocks=len/bsize;
			maddr=0;

			progress("PROG ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,bsize) && (errc==0))
				{
					if(param[11]==256)
					{
						errc=prg_comm(0x121,bsize,0,maddr,0,
							(addr & 0xff),
							(addr >> 8) & 0xff,
							(addr >> 16) & 0xff,
							bank);
					}
					if(param[11]==512)
					{
						errc=prg_comm(0x122,bsize,0,maddr,0,
							(addr & 0xff),
							(addr >> 8) & 0xff,
							(addr >> 16) & 0xff,
							bank);
					}
				}
				addr+=bsize;			
				maddr+=bsize;
				progress("PROG ",blocks,i+1);
			}
			printf("\n");
		}
	}



	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0) && (param[3]==0))
	{
		bsize=max_blocksize;
//		param[0]=0x800000;
		addr=param[0]+(bank << 24);
		len=param[1]*256;
		if(len > 0x1000000) len=0x1000000;
		blocks=len/bsize;
		maddr=0;

		progress("READ ",blocks,0);
		for(i=0;i<blocks;i++)
		{
//			printf("BLOCK=%d   ADDR=%08lX ",i,addr);
			if(errc == 0)
			{
				errc=prg_comm(0x12e,0,bsize,0,maddr+ROFFSET,
				(addr & 0xff),
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				bsize >> 8);		//blocks
			}
			memory[maddr]=0xbe;
			addr+=bsize;
			maddr+=bsize;
//			printf("DONE\n",i,addr);
			progress("READ ",blocks,i+1);
		}
		printf("\n");
//		printf("DONE (%02X)\n",errc);
	
		//verify main
		if((main_verify == 1) && (errc == 0))
		{
			read_block(param[0],len,0);
			maddr=param[0];		
			for(addr=maddr;addr<(maddr+len);addr++)

			if(memory[addr] != memory[addr+ROFFSET])
			{
				printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
					addr,memory[addr],memory[addr+ROFFSET]);
				errc=1;
			}
		}

		if((main_readout == 1) && (errc == 0))
		{
//			printf("SAVE=%08lx   SIZE=%08lX\n",param[0],len);
			writeblock_data(0,len,param[0]);
		}
	}


	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0) && (param[3]>0))
	{
		for(bank=0;bank<=param[3];bank++)
		{
			printf("READ DATA FROM BANK %d\n",bank);

			bsize=max_blocksize;
//			param[0]=0x800000;
			addr=param[0]+(bank << 24);
			len=param[1]*256;
			if(len > 0x1000000) len=0x1000000;
			blocks=len/bsize;
			maddr=0;

			progress("READ ",blocks,0);
			for(i=0;i<blocks;i++)
			{
//				printf("BLOCK=%d   ADDR=%08lX ",i,addr);
				if(errc == 0)
				{
					errc=prg_comm(0x125,0,bsize,0,maddr+ROFFSET,
					(addr & 0xff),
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					bank);
				}
//				memory[maddr]=0xbe;
				addr+=bsize;
				maddr+=bsize;
//				printf("DONE\n",i,addr);
				progress("READ ",blocks,i+1);
			}
			printf("\n");
//			printf("DONE (%02X)\n",errc);
	
			//verify main
			if((main_verify == 1) && (errc == 0))
			{
				read_block(param[0]+(bank << 24),len,0);
				maddr=param[0]+(bank << 24);		
				for(addr=maddr;addr<(maddr+len);addr++)

				if(memory[addr] != memory[addr+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr,memory[addr],memory[addr+ROFFSET]);
					errc=1;
				}
			}

			if((main_readout == 1) && (errc == 0))
			{
//				printf("SAVE=%08lx   SIZE=%08lX\n",param[0],len);
				writeblock_data(0,len,param[0]+(bank << 24));
			}
		}
	}

	if(main_readout > 0)
	{
		writeblock_close();
	}

	if(errc==0x9f) goto SPIF_FEXIT;
	
	if((protect == 1) && (errc == 0))
	{
		printf("ENABLE WRITE PROTECTION\n");
		memory[0]=(param[9] >> 24) & 0xff;
		memory[1]=(param[9] >> 16) & 0xff;
		memory[2]=(param[9] >> 8) & 0xff;
		memory[3]=(param[9]) & 0xff;
		
		errc=prg_comm(0x106,4,0,0,0,
				param[8] & 0xff,		//num data
				(param[8] >> 8) & 0xff,		//CMD
				10,				//100ms max
				0);
	}	

SPIF_FEXIT:

	i=prg_comm(0x101,0,0,0,0,0,0,0,0);					//spiflash exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_spiflash_error(errc);

	return errc;
}







