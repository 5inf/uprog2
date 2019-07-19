//###############################################################################
//#										#
//#										#
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

void print_r8c_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(TIMEOUT)",errc);
				break;

		case 0x42:	set_error("(wrong answer B0)",errc);
				break;

		case 0x43:	set_error("(wrong answer B7)",errc);
				break;

		case 0x40:	set_error("(TIMEOUT READ)",errc);
				break;

		case 0x45:	set_error("(not ready)",errc);
				break;

		case 0x46:	set_error("(TIMEOUT, no connection?)",errc);
				break;

		case 0x49:	set_error("(SRD error)",errc);
				break;

		case 0x4a:	set_error("(SRD error)",errc);
				break;

		case 0x4b:	set_error("(SRD error)",errc);
				break;

		case 0x4c:	set_error("(SRD1 error)",errc);
				break;

		case 0x4d:	set_error("(SRD1 error)",errc);
				break;

		case 0x4e:	set_error("(SRD1 error)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int prog_r8c(void)
{
	int errc,blocks,tblock,bsize,j,sh,sm,ii;
	unsigned long ramsize,addr,maddr;
	int main_erase=0;
	int main_blank=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dflash_erase=0;
	int dflash_prog=0;
	int dflash_verify=0;
	int dflash_readout=0;
	int dev_start=0;
	int run_ram=0;
	int have_unlock=0;
	int all_erase=0;
	int lb0,lb1,lb2,lb3,lb4,lb5,lb6;
	char *parptr;
	char hexbyte[5];

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- ea -- chip erase\n");
		printf("-- key:  unsecure with hex key\n");
		
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

	errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);		// enable pull-up

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
		if((strstr(cmd,"key:")) && ((strstr(cmd,"key:") - cmd) % 2 == 1))
		{
			have_unlock=1;
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
			printf("## Action: unlock device using %02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
			lb0,lb1,lb2,lb3,lb4,lb5,lb6);
		}

		if(find_cmd("ea"))
		{
			all_erase=1;
			printf("## Action: chip erase\n");
		}

		if(find_cmd("em"))
		{
			main_erase=1;
			printf("## Action: main flash erase\n");
		}

		if(find_cmd("bm"))
		{
			main_blank=1;
			printf("## Action: main flash blank check\n");
		}

		if(find_cmd("ed"))
		{
			dflash_erase=1;
			printf("## Action: data flash erase\n");
		}

		main_prog=check_cmd_prog("pm","code flash");
		dflash_prog=check_cmd_prog("pd","data flash");

		main_verify=check_cmd_verify("vm","code flash");
		dflash_verify=check_cmd_verify("vd","data flash");

		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
		dflash_readout=check_cmd_read("rd","data flash",&dflash_prog,&dflash_verify);

		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

	errc=0;

	if((main_readout || dflash_readout) > 0)
	{
		errc=writeblock_open();
	}

	if(dev_start == 0)
	{
		printf("INIT\n");
		prg_comm(0x23,0,0,0,0,0,0,0,0);	//exit
		usleep(100);
		errc=prg_comm(0x20,1,0,0,0,0,0,0,0);	//init
		if(errc !=0)
		{
			printf("ERR: received value = %02X\n",memory[0]);
		}
	}
	
	if ((errc == 0) && (dev_start == 0))				//unlock
	{
		if(all_erase == 1)
		{
			printf("MASS ERASE...\n");
			memory[0]=0x41;
			memory[1]=0x4c;
			memory[2]=0x65;
			memory[3]=0x52;
			memory[4]=0x41;
			memory[5]=0x53;
			memory[6]=0x45;
		}
		else
		{
			memory[0]=0xff;
			memory[1]=0xff;
			memory[2]=0xff;
			memory[3]=0xff;
			memory[4]=0xff;
			memory[5]=0xff;
			memory[6]=0xff;
		}
		errc=prg_comm(0x22,7,40,0,0,0,0,0,0);	//check ID
		if(errc > 0)
		{
			printf("DEVICE IS SECURED (ERRC=%02X)\n",errc);
			if(have_unlock == 1)
			{
				printf("TRY TO UNLOCKING...\n");
				memory[0]=lb0;
				memory[1]=lb1;
				memory[2]=lb2;
				memory[3]=lb3;
				memory[4]=lb4;
				memory[5]=lb5;
				memory[6]=lb6;
				errc=prg_comm(0x22,7,40,0,0,0,0,0,0);	//check ID
			}
			else
			{
				printf("FORCE MASS ERASE BECAUSE OF LOCKED DEVICE (ERRC=%02X)\n",errc);
				memory[0]=0x41;
				memory[1]=0x4c;
				memory[2]=0x65;
				memory[3]=0x52;
				memory[4]=0x41;
				memory[5]=0x53;
				memory[6]=0x45;
				errc=prg_comm(0x22,7,40,0,0,0,0,0,0);	//check ID
			}
		}
		else
		{
			printf("DEVICE IS UNLOCKED\n");
		}

		if(errc==0)
		{
			errc=prg_comm(0x28,0,40,0,0,0,0,0,0);	//check ID
			if(errc == 0)
			{
				printf("BL-Version = ");
				for(ii=0;ii<8;ii++)
				{
					printf("%c",memory[ii]);
				}
				printf("\n");
			}
		}
	}

	usleep(1000);

	//main erase
	if ((errc == 0) && (main_erase == 1))	//unlock
	{
		printf("ERASE MAIN\n");
		memory[0]=(param[2] >> 24) & 0xff;
		memory[1]=(param[2] >> 16) & 0xff;

		memory[2]=(param[2] >> 8) & 0xff;
		memory[3]=(param[2]) & 0xff;

		memory[4]=(param[3] >> 24) & 0xff;
		memory[5]=(param[3] >> 16) & 0xff;
		memory[6]=(param[3] >> 8) & 0xff;
		memory[7]=(param[3]) & 0xff;

		memory[8]=(param[4] >> 24) & 0xff;
		memory[9]=(param[4] >> 16) & 0xff;
		memory[10]=(param[4] >> 8) & 0xff;
		memory[11]=(param[4]) & 0xff;

		memory[12]=(param[5] >> 24) & 0xff;
		memory[13]=(param[5] >> 16) & 0xff;
		memory[14]=(param[5] >> 8) & 0xff;
		memory[15]=(param[5]) & 0xff;

		errc=prg_comm(0x26,18,40,0,0,0,0,0,0);	//program
		if(errc > 9)
		{
			printf("BLK ADDR = 0x%06X\n",memory[0]*0x10000+memory[1]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[2]*0x10000+memory[3]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[4]*0x10000+memory[5]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[6]*0x10000+memory[7]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[8]*0x10000+memory[9]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[10]*0x10000+memory[11]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[12]*0x10000+memory[13]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[14]*0x10000+memory[15]*0x100);
		}
	}

	//blank check
	if ((errc == 0) && (main_blank == 1))	//unlock
	{
		printf("BLANK CHECK\n");
		errc=prg_comm(0x27,0,40,0,0,0,0,0,0);	//check ID
		if(errc > 9) printf("ST= %02X %02X %02X %02X\n",memory[32],memory[33],memory[34],memory[35]);
	}

	//program
	if ((errc == 0) && (main_prog == 1))
	{
		read_block(param[0],param[1],0);
		bsize = max_blocksize;
		addr=param[0];
		if(param[1] < bsize) bsize = param[1];		//flash_size < MAX_BSIZE
		blocks=param[1]/bsize;		//max blocks per comm
		maddr=0;

		progress("PROG MAIN ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))	//program only if not empty
			{
				sh= ((addr) >> 16) & 0xff;
				sm= ((addr) >> 8) & 0xff;
				errc=prg_comm(0x24,bsize,0,maddr,0,sm,sh,(bsize >> 8) & 0xff,0);	//program
			}
			addr+=bsize;
			maddr+=bsize;
			progress("PROG MAIN ",blocks,tblock+1);
		}		
		printf("\n");
	}

	//verify and readout
	if ((errc == 0) && ((main_verify == 1) || (main_readout == 1)))
	{
		bsize = max_blocksize;
		addr=param[0];
		if(param[1] < bsize) bsize = param[1];
		blocks=param[1]/bsize;		//max blocks per comm
		maddr=0;
		
		progress("READ MAIN ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(errc == 0)
			{
//				printf("ADDR= %06X  LEN= %d\n",addr,bsize);
				progress("READ MAIN ",blocks,tblock+1);
				sh= ((addr) >> 16) & 0xff;
				sm= ((addr) >> 8) & 0xff;
				errc=prg_comm(0x25,0,bsize,0,maddr+ROFFSET,sm,sh,(bsize >> 8) & 0xff,0);	//read
			}
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	if((errc == 0) && (main_verify == 1))
	{
		printf("VERIFY MAIN\n");
		read_block(param[0],param[1],0);
		addr = param[0];
		ii=0;
		for(j=0;j<param[1];j++)
		{
			if((ii < 10) && (memory[j] != memory[j+ROFFSET]))
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
				ii++;
			}
		}
	}

	if((errc == 0) && (main_readout == 1))
	{
		writeblock_data(0,param[1],param[0]);
	}



	if ((errc == 0) && (dflash_erase == 1))	//unlock
	{
		printf("ERASE DATA\n");
		memory[0]=(param[13] >> 24) & 0xff;
		memory[1]=(param[13] >> 16) & 0xff;

		memory[2]=(param[13] >> 8) & 0xff;
		memory[3]=(param[13]) & 0xff;

		memory[4]=(param[14] >> 24) & 0xff;
		memory[5]=(param[14] >> 16) & 0xff;
		memory[6]=(param[14] >> 8) & 0xff;
		memory[7]=(param[14]) & 0xff;

		memory[8]=(param[15] >> 24) & 0xff;
		memory[9]=(param[15] >> 16) & 0xff;
		memory[10]=(param[15] >> 8) & 0xff;
		memory[11]=(param[15]) & 0xff;

		memory[12]=(param[16] >> 24) & 0xff;
		memory[13]=(param[16] >> 16) & 0xff;
		memory[14]=(param[16] >> 8) & 0xff;
		memory[15]=(param[16]) & 0xff;
		errc=prg_comm(0x26,16,40,0,0,0,0,0,0);	//program
		if(errc > 9)
		{
			printf("BLK ADDR = 0x%06X\n",memory[0]*0x10000+memory[1]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[2]*0x10000+memory[3]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[4]*0x10000+memory[5]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[6]*0x10000+memory[7]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[8]*0x10000+memory[9]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[10]*0x10000+memory[11]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[12]*0x10000+memory[13]*0x100);
			printf("BLK ADDR = 0x%06X\n",memory[14]*0x10000+memory[15]*0x100);
		}
	}


	//program data
	if ((errc == 0) && (dflash_prog == 1))
	{
		read_block(param[11],param[12],0);
		bsize = max_blocksize;
		addr=param[11];
		if(param[12] < bsize) bsize = param[12];		//flash_size < MAX_BSIZE
		blocks=param[12]/bsize;					//max blocks per comm
		maddr=0;

		progress("PROG DATA ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))	//program only if not empty
			{
				sh= ((addr) >> 16) & 0xff;
				sm= ((addr) >> 8) & 0xff;
				errc=prg_comm(0x24,bsize,0,maddr,0,sm,sh,(bsize >> 8) & 0xff,0);	//program
			}
			addr+=bsize;
			maddr+=bsize;
			progress("PROG DATA ",blocks,tblock+1);
		}
		printf("\n");
	}

	//verify
	if ((errc == 0) && ((dflash_verify == 1) || (dflash_readout == 1)))
	{
		bsize = max_blocksize;
		addr=param[11];
		if(param[12] < bsize) bsize = param[12];
		blocks=param[12]/bsize;		//max blocks per comm
		maddr=0;
		
		progress("READ DATA ",blocks,0);
		for(tblock=0;tblock<blocks;tblock++)
		{
			if(errc == 0)
			{
//				printf("ADDR= %06lX  LEN= %d\n",addr,bsize);
				progress("READ DATA ",blocks,tblock+1);
				sh= ((addr) >> 16) & 0xff;
				sm= ((addr) >> 8) & 0xff;
				errc=prg_comm(0x25,0,bsize,0,maddr+ROFFSET,sm,sh,(bsize >> 8) & 0xff,0);	//read
			}
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	if((errc == 0) && (dflash_verify == 1))
	{
		printf("VERIFY DATA\n");
		read_block(param[11],param[12],0);
		addr = param[11];
		for(j=0;j<param[12];j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %06lX  DATA= %02X  READ= %02X\n",addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((errc == 0) && (dflash_readout == 1))
	{
		writeblock_data(0,param[12],param[11]);
	}


	if(run_ram == 1)
	{
		j=read_block(param[8],param[9]+1,0);
		if(j > (param[9]+1))
		{
			printf("!! ERROR, RAM IMAGE TO BIG (%d > %d bytes) !!\n",j,param[9]);
		}
		else
		{
			printf("TRANSFER DATA (%d) BYTES\n",j);
			if(j <= max_blocksize)
			{
				bsize=max_blocksize;
				ramsize = param[9];
		
				if(bsize > ramsize) bsize = ramsize;
				if(errc == 0) errc=prg_comm(0x21,bsize,0,0,0,bsize & 0xff,(bsize >> 8) & 0xff,0,0);	//exec
				waitkey();
			}
			else
			{
				
				ii=0;
				for(maddr=0;maddr<j;maddr++) ii+=memory[maddr];

//				printf("TRANSFER CHECKSUM %02X\n",ii & 0xff);

				maddr=0;
				bsize=max_blocksize;
				blocks=((j-1) / bsize)+1;
				progress("TRANSFER ",blocks,0);
				
				if(errc == 0) errc=prg_comm(0x9B,bsize,0,maddr,0,j & 0xff,(j >> 8) & 0xff,0,ii & 0xff);	//exec
				
				j-=bsize;
				maddr+=bsize;
				ii=0;
				
				while(j > 0)
				{
					sm=max_blocksize;
					if(sm > j) sm=j;
					if(errc == 0) errc=prg_comm(0x9C,sm,0,maddr,0,sm & 0xff,(sm >> 8) & 0xff,0,0);	//exec3
					j-=sm;
					maddr+=sm;
					ii++;
					progress("TRANSFER ",blocks,ii+1);
				}
				waitkey();
			}
		}
	}

	if((main_readout || dflash_readout) > 0)
	{
		writeblock_close();
	}


	if(dev_start == 1)
	{
		if(errc == 0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
	}

	prg_comm(0x23,0,0,0,0,8,0,0,0);	//exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_r8c_error(errc);
	return errc;
}







