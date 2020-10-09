//###############################################################################
//#										#
//# UPROG2 universal programmer							#
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

void print_s12z_error(int errc)
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

		case 0x65:	set_error("(BDM Freq out of range)",errc);
				break;

		case 0x77:	set_error("(Verify error)",errc);
				break;

		case 0x78:	set_error("(Device is secured)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

void s12z_show_exec(int step)
{
	long pos=ROFFSET+8*step;
	long pc;
	pc=(memory[pos+0]<<16) + (memory[pos+1]<<8) + (memory[pos+2]);
	
	printf("PC= %06lX ( %02X %02X %02X %02X %02X )\n",pc,memory[pos+3],memory[pos+4],memory[pos+5],memory[pos+6],memory[pos+7]);
}


int prog_s12z(void)
{
	int errc,blocks,bsize,i,j;
	unsigned int ramsize,len;
	int prdiv8,bfreq,fcdiv=0;
	float freq,bdmfreq;
	int mass_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int dev_start=0;
	int run_ram=0;
	int no_unsecure=0;
	int no_secure=0;
	int do_secure=0;
	long trim=0,addr,maddr;
	int res_norel=0;
	errc=0;


	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- ea -- mass erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");
		printf("-- pe -- eeprom program\n");
		printf("-- ve -- eeprom verify\n");
		printf("-- re -- eeprom readout\n");
		printf("-- nu -- do not unsecure (mass erase if secured)\n");
		printf("-- ns -- unsecure main flash\n");
		printf("-- pr -- secure main flash (protect)\n");
		printf("-- hr -- hold reset to 1 (no release)\n");
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

	errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);	//enable Pull-up

	if(find_cmd("5v"))
	{
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		printf("## using 5V VDD\n");
	}

	if(find_cmd("hr"))
	{
		res_norel=128;
		printf("## hold reset to 1 (no release)\n");
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
			mass_erase=1;
			printf("## Action: mass erase\n");
		}

		main_prog=check_cmd_prog("pm","main flash");
		main_verify=check_cmd_verify("vm","main flash");
		main_readout=check_cmd_read("rm","main flash",&main_prog,&main_verify);

		eeprom_prog=check_cmd_prog("pe","eeprom");
		eeprom_verify=check_cmd_verify("ve","eeprom");
		eeprom_readout=check_cmd_read("re","eeprom",&eeprom_prog,&eeprom_verify);


		if(find_cmd("nu"))
		{
			no_unsecure = 1;
		}
		if(find_cmd("ns"))
		{
			no_secure = 1;
			printf("## Action: writing SEC to unsecured state\n");
		}
		if(find_cmd("pr"))
		{
			do_secure = 1;
			printf("## Action: writing SEC to secured state\n");
		}
		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

	if((main_readout == 1) || (eeprom_readout ==1))
	{
		errc=writeblock_open();
	}

	if(dev_start == 0)
	{
		errc=prg_comm(0x10,0,1,0,0,0,0,0,res_norel);					//BDM init
		if(errc == 0)
		{
			bdmfreq=171/memory[0];			
			freq=bdmfreq;			//bus clock
			bfreq=(int)(bdmfreq+0.5);

			printf("BDM FREQ = %2.1fMHz     USED MODE = %dMHz\n",bdmfreq,bfreq);
			errc=prg_comm(0x220,0,2,0,0,fcdiv,bfreq-1,0,1);
//			printf("FCLKDIV      = %02X\n",memory[0]);

			if(errc == 0) errc=prg_comm(0x1f,0,4,0,0,5,0,0,0);				//resync

			bdmfreq=171/memory[0];			
			freq=bdmfreq;			//bus clock
			bfreq=(int)(bdmfreq+0.5);
			fcdiv=(int)(freq*5)+prdiv8;

			printf("NEW BDM FREQ = %2.1fMHz\n",bdmfreq);

			if(errc == 0) errc=prg_comm(0x228,0,2,0,0,0,0,0,0);	//test

//			printf(">> CHECK SECURITY\n");
			if(((memory[0] & 3) == 2) && (memory[0] != 0xEE)) 
			{
				printf("** DEVICE IS UNSECURED (FSEC=0x%02X) **\n",memory[0]);
			}
			else
			{
				if(no_unsecure == 1)
				{
					printf("** DEVICE IS SECURED (FSEC=0x%02X) **\n",memory[0]);
					errc=0x78;				
				}
				else
				{
					printf(">> DEVICE IS SECURED (FSEC=0x%02X), FORCE MASS ERASE\n",memory[0]);
					mass_erase=1;
				}
			}
		}
	}

	if(errc != 0) goto S12Z_END;

	
	//erase
	if((mass_erase == 1) && (errc == 0))
	{
		printf("ERASE\n");
		if(errc == 0) errc=prg_comm(0x225,0,0,0,0,0,0,0,0);			//main erase


		errc=prg_comm(0x10,0,1,0,0,0,0,0,res_norel);					//BDM init
		if(errc == 0)
		{
			bdmfreq=171/memory[0];			
			freq=bdmfreq;			//bus clock
			bfreq=(int)(bdmfreq+0.5);

			printf("BDM FREQ = %2.1fMHz     USED MODE = %dMHz\n",bdmfreq,bfreq);
			errc=prg_comm(0x220,0,2,0,0,fcdiv,bfreq-1,0,1);
//			printf("FCLKDIV      = %02X\n",memory[0]);

			if(errc == 0) errc=prg_comm(0x1f,0,0,0,0,5,0,0,0);				//resync

			bdmfreq=171/memory[0];			
			freq=bdmfreq;			//bus clock
			bfreq=(int)(bdmfreq+0.5);
			fcdiv=(int)(freq*5)+prdiv8;

			printf("NEW BDM FREQ = %2.1fMHz\n",bdmfreq);

			if(errc == 0) errc=prg_comm(0x228,0,2,0,0,0,0,0,0);	//test

//			printf(">> CHECK SECURITY\n");
			if(((memory[0] & 3) == 2) && (memory[0] != 0xEE)) 
			{
				printf("** DEVICE IS UNSECURED (FSEC=0x%02X) **\n",memory[0]);
			}
			else
			{
				printf("** DEVICE IS SECURED (FSEC=0x%02X) **\n",memory[0]);
			}
		}




	}

	//program main flash
	if((main_prog == 1) && (errc == 0))
	{
//		waitkey();

		read_block(param[0],param[1],0);

		if(trim > 0) { memory[0xffae]=0; memory[0xffaf]=trim;} 
		if(no_secure == 1) memory[param[1]-0x1f1]= (memory[param[1]-0x1f1] | 3 ) & 0xfe;		
		if(do_secure == 1) memory[param[1]-0x1f1]= (memory[param[1]-0x1f1] | 3 ) & 0xfd;		
		bsize = max_blocksize;
		if(param[1] < bsize) bsize=param[1];	//memory is smaller than max blocksize
		addr = param[0];
		maddr=0;
		blocks = param[1] / bsize;

		progress("PROG FLASH",blocks,0);
		
		for(j=0;j<blocks;j++)
		{
			if(errc == 0)
			{
				if(must_prog(maddr,bsize))
				{
//					printf("BLK : %06X LEN %04X\n",addr,bsize);
					errc=prg_comm(0x224,bsize,4,maddr,0,addr & 0xff,addr >> 8,addr >> 16,0);
				}
				progress("PROG FLASH",blocks,j+1);
			//	printf("data: %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3]);
				addr+=bsize;
				maddr+=bsize;
			}
		}
		printf("\n");
	}


	//program eeprom
	if((eeprom_prog == 1) && (errc == 0))
	{
		read_block(param[2],param[3],0);
		bsize = max_blocksize;
		addr = param[2];
		maddr=0;
		j=0;
		blocks = param[3] / bsize;

		progress("PROG EEPROM",blocks,0);

		if(param[3] < max_blocksize)
		{
			errc=prg_comm(0x226,bsize,4,maddr,0,addr & 0xff,addr >> 8,addr >> 16,param[3] >> 3);
			progress("PROG EEPROM",blocks,j+1);
		}
		else
		{		
			for(j=0;j<blocks;j++)
			{
				if(errc == 0)
				{
					errc=prg_comm(0x226,bsize,4,maddr,0,addr & 0xff,addr >> 8,addr >> 16,0);
					progress("PROG EEPROM",blocks,j+1);
					addr+=bsize;
					maddr+=bsize;
				}
			}
		}
		printf("\n");
	}


	//verify eeprom
	if(((eeprom_readout == 1) || (eeprom_verify == 1)) && (errc == 0))
	{
		addr = param[2];
		bsize = max_blocksize;
		if(param[3] < bsize) bsize = param[3];
		blocks = param[3] / bsize;
		maddr=0;

		progress("READ EEPROM",blocks,0);
		if(param[3] < max_blocksize)
		{
			if(errc == 0) errc=prg_comm(0x223,0,bsize,0,maddr+ROFFSET,addr & 0xff,addr >> 8,addr >> 16,param[3] >> 3);
			progress("READ EEPROM",blocks,1);		
		}
		else
		{
			for(j=0;j<blocks;j++)
			{
//				printf("BLK : %06X LEN %04X\n",addr,bsize);
				if(errc == 0) errc=prg_comm(0x223,0,bsize,0,maddr+ROFFSET,addr & 0xff,addr >> 8,addr >> 16,0);
				progress("READ EEPROM",blocks,j+1);
				addr+=bsize;
				maddr+=bsize;
			}
		}
		printf("\n");
	}

	if((eeprom_verify == 1) && (errc == 0))
	{
		read_block(param[2],param[3],0);

		addr = 0;
		i=0;
		for(j=0;j<param[3];j++)
		{
			if((memory[addr+j] != memory[addr+j+ROFFSET]) && (i<25))
			{
				i++;
				printf("ERR -> ADDR= %08lX  DATA= %02X  READ= %02X\n",j+param[2],memory[addr+j],memory[addr+j+ROFFSET]);
				errc=0x77;
			}
		}
		if(i>24)
		{
			printf("!! Maximum Verify errors reached...\n");		
		}
	}

	if((eeprom_readout == 1) && (errc == 0))
	{
		writeblock_data(0,param[3],param[2]);
	}

	//verify main flash
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		addr = param[0];
		bsize = max_blocksize;
		if(param[1] < bsize) bsize = param[1];
		blocks = param[1] / bsize;
		maddr=0;

		progress("READ FLASH",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",addr,bsize);
			if(errc == 0) errc=prg_comm(0x223,0,bsize,0,maddr+ROFFSET,addr & 0xff,addr >> 8,addr >> 16,0);
			progress("READ FLASH",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	if((main_verify == 1) && (errc == 0))
	{
		read_block(param[0],param[1],0);
		if(no_secure == 1) memory[param[1]-0x1f1]= (memory[param[1]-0x1f1] | 3 ) & 0xfe;		

		addr=0;
		i=0;
		for(j=0;j<param[1];j++)
		{
			if((memory[addr+j] != memory[addr+j+ROFFSET]) && (i<25))
			{
				i++;
				printf("ERR -> ADDR= %08lX  DATA= %02X  READ= %02X\n",param[0]+j,memory[addr+j],memory[addr+j+ROFFSET]);
				errc=0x77;
			}
		}
		if(i>24)
		{
			printf("!! Maximum Verify errors reached...\n");		
		}
	}

	if((main_readout == 1) && (errc == 0))
	{
		writeblock_data(0,param[1],param[0]);
	}



	if((main_readout == 1) || (eeprom_readout == 1))
	{
		writeblock_close();
	}
	
	if((run_ram == 1) && (errc == 0))
	{
		printf("** TRANSFER CODE AND START **\n");
		ramsize=read_block(param[8],param[9],0);
		printf(">> READ %d bytes\n",ramsize);
		len=(ramsize+255) >> 8;
		blocks=(len+7) >> 3;
		addr = param[8];
		maddr=0;
		i=0;
		
		progress("WRITE RAM ",blocks,i);
		
		while(len > 0)
		{
//			printf("chunks= %d blocks=%d \n",len,i);
			if(len > 8)
			{
				if(errc == 0) errc=prg_comm(0x221,ramsize,0,maddr,0,addr & 0xff,addr >> 8,addr >> 16,8);	//write words
				len-=8;
				addr+=2048;
				maddr+=2048;
				i++;
			}
			else
			{
				if(errc == 0) errc=prg_comm(0x221,ramsize,0,maddr,0,addr & 0xff,addr >> 8,addr >> 16,len);	//write words
				len=0;
				i++;
			}		
			progress("WRITE RAM ",blocks,i);
		}
		
		addr = param[8];
		if(errc == 0) errc=prg_comm(0x222,0,0,0,0,addr & 0xff,addr >> 8,addr >> 16,0);	//execute
		
		if(errc == 0) waitkey();
	}

	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);		//init
		waitkey();
	}

S12Z_END:

	i=prg_comm(0x0f,0,0,0,0,0,0,0,0);			//exit
	i=prg_comm(0x11,0,0,0,0,0,0,0,0);			//BDM exit
	i=prg_comm(0xfe,0,0,0,0,0,0,0,0);			//disable Pull-up
	
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);			//dev 1
	print_s12z_error(errc);

	return errc;
}




