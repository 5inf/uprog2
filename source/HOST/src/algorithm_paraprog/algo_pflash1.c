//###############################################################################
//#										#
//# UPROG2-PARPROG universal parallel programmer				#
//#										#
//# copyright (c) 2020-2022 Joerg Wolfram (joerg@jcwolfram.de)			#
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

void print_pflash_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(TIMEOUT)",errc);
				break;

		case 0x48:	set_error("(VPP < VPPLK)",errc);
				break;

		case 0x49:	set_error("(ERASE ERROR)",errc);
				break;

		case 0x4A:	set_error("(PROGRAM ERROR)",errc);
				break;

		case 0x4B:	set_error("(SEQUENCE ERROR)",errc);
				break;

		case 0x43:	set_error("(wrong size)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int pflash_unlock(void)
{
	int i,errc;

	printf("OLD LOCK STATE: ");
	
	errc=prg_comm(0x15,0,2048,0,0,(param[3] & 0xff),(param[3] >> 8) & 0xff,(param[3] >> 16) & 0xff,(param[3] >> 24) & 0xff);

	for(i=0;i<(param[3] & 0xffff);i++)
	{
		switch(memory[2*i])
		{
			case 1:		printf("L");break;
			case 2:		printf("D");break;
			case 3:		printf("D");break;
			default:	 printf("u");
		}
	}

	printf("\n");
	
	errc=prg_comm(0x16,0,2048,0,0,(param[3] & 0xff),(param[3] >> 8) & 0xff,(param[3] >> 16) & 0xff,(param[3] >> 24) & 0xff);

	printf("NEW LOCK STATE: ");
	
	errc=prg_comm(0x15,0,2048,0,0,(param[3] & 0xff),(param[3] >> 8) & 0xff,(param[3] >> 16) & 0xff,(param[3] >> 24) & 0xff);

	for(i=0;i<(param[3] & 0xffff);i++)
	{
		switch(memory[2*i])
		{
			case 1:		printf("L");break;
			case 2:		printf("D");break;
			case 3:		printf("D");break;
			default:	 printf("u");
		}
	}
	printf("\n");
	return errc;
}

int prog_pflash(void)
{
	int errc,blocks,i;
	unsigned long addr,maddr,len;
	int bsize;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int unprotect=0;
	int protect=0;
	int otp_readout=0;
	int debug_signals=0;
	unsigned short z;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
//		printf("-- un -- unprotect\n");
//		printf("-- pr -- protect all\n");
		printf("-- em -- memory erase\n");
		printf("-- pm -- memory program\n");
		printf("-- vm -- memory verify\n");
		printf("-- rm -- memory read\n");
		printf("-- ro -- otp read\n");
		printf("-- db -- show signals (debug)\n");
		return 0;
	}

	if(find_cmd("em"))
	{
		main_erase=1;
		printf("## Action: memory erase\n");
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

	if(find_cmd("ro"))
	{
		otp_readout=1;
		printf("## Action: eadout OTP area\n");
	}

	if(find_cmd("db"))
	{
		debug_signals=1;
		printf("## Action: show signal states\n");
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
		errc=prg_comm(0x10,0,0,0,0,0,0,0,0);				//init
		errc=prg_comm(0x12,0,128,0,0,0,0,0,0);				//get info
		if(debug_signals == 1)
		{
			printf("-------------------------------------------------------\n");
			paraprog_view(4);
			paraprog_view(12);
			paraprog_view(20);
			paraprog_view(28);
			paraprog_view(36);
			printf("-------------------------------------------------------\n");
		}
		printf(" Manufacturer-ID:  %02X%02X ",memory[1],memory[0]);
		z=memory[0]+256*memory[1];
		switch(z)
		{
			case 0x01:	printf("(AMD/Spansion)\n");break;
			case 0x52:	printf("(Alliance)\n");break;
			case 0x7F37:
			case 0x1F:	printf("(Atmel/Adesto)\n");break;
			case 0x7F1C:
			case 0x1C:	printf("(EON)\n");break;
			case 0x04:	printf("(Fujitsu)\n");break;
			case 0xAD:	printf("(Hyundai)\n");break;
			case 0xC2:	printf("(Macronix)\n");break;
			case 0x89:	printf("(Numonyx/Micron/Intel)\n");break;
			case 0x7F9D:
			case 0x9D:	printf("(PMC)\n");break;
			case 0xB0:	printf("(Sharp)\n");break;
			case 0xBF:	printf("(SST)\n");break;
			case 0x20:	printf("(STMicro)\n");break;
			case 0xDA:	printf("(Winbond)\n");break;
			
			
			default:	printf("(unknown)\n");
		
		}
		printf(" Device.-ID:       %02X%02X ",memory[3],memory[2]);
		z=memory[2]+256*memory[3];
		switch(z)
		{
			case 0x8820:	printf("(64 MBit, bottom boot blocks)\n");break;
			case 0x8821:	printf("(128 MBit, bottom boot blocks)\n");break;
			case 0x881D:	printf("(64 MBit, top boot blocks)\n");break;
			case 0x881E:	printf("(128 MBit, top boot blocks)\n");break;
			default:	printf("(unknown)\n");
		
		}
	}

	if((otp_readout == 1) && (errc==0)) 
	{
		errc=prg_comm(0x12,0,512,0,0,0,0,0,0);				//get info

		printf(" Manufacturer-OTP:    %02X%02X %02X%02X %02X%02X %02X%02X",memory[1],memory[0],memory[3],memory[2],memory[5],memory[4],memory[7],memory[6]);
		printf(" 64Bits User-OTP:     %02X%02X %02X%02X %02X%02X %02X%02X",memory[9],memory[8],memory[11],memory[10],memory[13],memory[12],memory[15],memory[14]);


		z=16;
		
		for(i=0;i<16;i++)
		{
			printf("128Bits User-OTP %2d:  %02X%02X %02X%02X %02X%02X %02X%02X %02X%02X %02X%02X %02X%02X %02X%02X",i,
				memory[z+1],memory[z+0],memory[z+3],memory[z+2],memory[z+5],memory[z+4],memory[z+7],memory[z+6],
				memory[z+9],memory[z+8],memory[z+11],memory[z+10],memory[z+13],memory[z+12],memory[z+15],memory[z+14]);
				z+=16;
		}
		printf("\n");
	}
		
	if((unprotect == 1) && (errc == 0))
	{
		printf("DISABLE WRITE PROTECTION\n");
		memory[0]=(param[7] >> 24) & 0xff;
		memory[1]=(param[7] >> 16) & 0xff;
		memory[2]=(param[7] >> 8) & 0xff;
		memory[3]=(param[7]) & 0xff;
		
		errc=prg_comm(0x18,4,0,0,0,
				param[6] & 0xff,		//num data
				(param[6] >> 8) & 0xff,		//CMD
				10,				//100ms max
				0);
	}	
	
	if((main_erase == 1) && (errc == 0))
	{
		pflash_unlock();
		blocks=param[3] & 0xFFFF;
		progress("ERASE ",blocks,0);

		for(i=0;i<blocks;i++)
		{
			memory[0]=i & 0xff;
			memory[1]=(i >> 8) & 0xff;
			if(errc==0) errc=prg_comm(0x17,2,128,0,0,(param[3] & 0xff),(param[3] >> 8) & 0xff,(param[3] >> 16) & 0xff,(param[3] >> 24) & 0xff);
			if(debug_signals == 2)
			{
				printf("-------------------------------------------------------\n");
				paraprog_view(4);
				paraprog_view(12);
				paraprog_view(20);
				paraprog_view(28);
				paraprog_view(36);
				paraprog_view(42);
				paraprog_view(50);
				printf("-------------------------------------------------------\n");
			}


			progress("ERASE ",blocks,i+1);
		
		}
	}	

	if((main_prog == 1) && (errc == 0))
	{
		pflash_unlock();
		len=param[1];
		if(len > 0x4000000) len=0x4000000;
		
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
				errc=prg_comm(0x18,bsize,0,maddr,ROFFSET,
				(addr & 0xff),
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff);
			}
			addr+=(bsize / 2);			
			maddr+=bsize;
			progress("PROG ",blocks,i+1);
		}
	}

	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		bsize=max_blocksize;
		len=param[1];
		if(len > 0x4000000) len=0x4000000;
		blocks=len/bsize;
		maddr=0;
		addr=0;

		progress("READ ",blocks,0);
		for(i=0;i<blocks;i++)
		{
//			printf("BLOCK=%d   ADDR=%08lX ",i,addr);
			if(errc == 0)
			{
				errc=prg_comm(0x14,0,bsize,0,maddr+ROFFSET,
				(addr & 0xff),
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff);
			}
			addr+=(bsize / 2);
			maddr+=bsize;
			progress("READ ",blocks,i+1);
		}
		printf("\n");
	
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

	if(main_readout > 0)
	{
		writeblock_close();
	}

	
	if((protect == 1) && (errc == 0))
	{
		printf("ENABLE WRITE PROTECTION\n");
		memory[0]=(param[9] >> 24) & 0xff;
		memory[1]=(param[9] >> 16) & 0xff;
		memory[2]=(param[9] >> 8) & 0xff;
		memory[3]=(param[9]) & 0xff;
		
		errc=prg_comm(0x19,4,0,0,0,
				param[8] & 0xff,		//num data
				(param[8] >> 8) & 0xff,		//CMD
				10,				//100ms max
				0);
	}	

	i=prg_comm(0x11,0,0,0,0,0,0,0,0);					//pflash exit

	print_pflash_error(errc);

	return errc;
}







