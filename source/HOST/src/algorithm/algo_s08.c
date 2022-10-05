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

void print_s08_error(int errc)
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

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_s08(void)
{
	int errc,blocks,bsize,j,fbsize;
	unsigned int ramsize,ramstart,addr;
	int prdiv8,bfreq,fcdiv;
	float freq,bdmfreq;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int dev_start=0;
	int run_ram=0;
	int no_unsecure=0;
	int no_secure=0;
	int do_secure=0;
	long trim=0;
	int force_4m=0;
	int force_8m=0;
	int res_norel=0;
	int trim_min,trim_max,trim_cyc=0;

	int debug_ram=0;
	int debug_flash=0;
	
	errc=0;


	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		if(param[2] != 0)
		{
			printf("-- pl -- lower flash block program\n");
			printf("-- vl -- lower flash block verify\n");
			printf("-- rl -- lower flash block readout\n");
		}

		printf("-- ns -- unsecure main flash\n");
		printf("-- nu -- do not unsecure\n");
		printf("-- pr -- secure main flash (protect)\n");
		printf("-- hr -- hold reset to 1 (no release)\n");
		printf("-- f4 -- force 4MHz BDM frequency\n");
		printf("-- f8 -- force 8MHz BDM frequency\n");
		printf("-- t8 -- trim internal osc to 8 MHz\n");
		printf("-- t9 -- trim internal osc to 9 MHz\n");
		printf("-- ta -- trim internal osc to 10 MHz\n");
		printf("-- rr -- run code in RAM\n");
		printf("-- dr -- debug code in RAM\n");
		printf("-- df -- debug code in FLASH\n");
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

	if(find_cmd("f4"))
	{
		force_4m=1;
		printf("## force 4MHz BDM frequency\n");
	}

	if(find_cmd("f8"))
	{
		force_8m=1;
		printf("## force 8MHz BDM frequency\n");
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
			goto S08_ORUN;
		}
	}

	else if(find_cmd("dr"))
	{
		if(file_found < 2)
		{
			debug_ram = 0;
			printf("## Action: debug code in RAM !! DISABLED BECAUSE OF NO FILE !!\n");
		}
		else
		{
			debug_ram=1;
			printf("## Action: debug code in RAM using %s\n",sfile);
			goto S08_ORUN;
		}
	}

	else if(find_cmd("df"))
	{
		debug_flash=1;
		printf("## Action: debug code in FLASH\n");
		goto S08_ORUN;
	}

	else
	{
		if(find_cmd("em"))
		{
			main_erase=1;
			printf("## Action: main flash erase\n");
		}

		main_prog=check_cmd_prog("pm","main flash");
		main_verify=check_cmd_verify("vm","main flash");
		main_readout=check_cmd_read("rm","main flash",&main_prog,&main_verify);


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
		if(find_cmd("t8"))
		{
			trim = 8;
			trim_cyc=80;
			printf("## Action: trimming ICG to 8Mhz\n");
		}
		if(find_cmd("t9"))
		{
			trim = 9;
			trim_cyc=71;
			printf("## Action: trimming ICG to 9Mhz\n");
		}
		if(find_cmd("ta"))
		{
			trim = 10;
			trim_cyc=64;
			printf("## Action: trimming ICG to 10Mhz\n");
		}
		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

S08_ORUN:

	if(main_readout == 1)
	{
		errc=writeblock_open();
	}

	if(dev_start == 0)
	{
		errc=prg_comm(0x10,0,1,0,0,0,0,0,res_norel);					//BDM init
		prdiv8=0;
		if(errc == 0)
		{
			bdmfreq=512/memory[0];
			if(force_4m==1)
			{
				printf("BDM FREQ = %2.1fMHz     FORCED TO = 4MHz\n",bdmfreq);
				bdmfreq=4.0;
			}
			if(force_8m==1)
			{
				printf("BDM FREQ = %2.1fMHz     FORCED TO = 8MHz\n",bdmfreq);
				bdmfreq=8.0;
			}
			
			
			freq=bdmfreq;			//bus clock
			if((freq) > 12.6)
			{
				freq /=8;
				prdiv8=64;
			}
			bfreq=(int)(bdmfreq+0.5);
			fcdiv=(int)(freq*5)+prdiv8;

			if(bfreq < 17)
			{
				printf("BDM FREQ = %2.1fMHz     USED MODE = %dMHz     FCDIV = 0x%02x\n",bdmfreq,bfreq,fcdiv);
				errc=prg_comm(0x12,0,0,0,0,fcdiv,bfreq-1,0,0);
//				printf("EEE = %02X\n",errc);
				
				if((errc == 0) && (no_unsecure == 0))
				{
					printf(">> CHECK SECURITY\n");
					errc=prg_comm(0x15,0,2,0,0,0,0,0,0);			//unsecure
//					printf ("FOPT = %02X,%02X\n",memory[0],memory[1]);
					if(errc == 0x10)
					{
						printf("** DEVICE UNSECURED BY MASS ERASE **\n");
						errc=0;
					}
					if(errc == 0)
					{
						printf("** DEVICE IS UNSECURED **\n");
					}
				}
			}
			else
			{
				errc=101;
			}

		}
	}

	//erase
	if((main_erase == 1) && (errc == 0))
	{
		printf("ERASE\n");
		if(errc == 0) errc=prg_comm(0x14,0,0,0,0,0,0,0,0);			//main erase
	}

	//trim
	if((trim > 0) && (errc == 0))
	{
		progress("TRIM",240,0);
		memory[4]=0xE0;
		trim_min=0;
		trim_max=0;

		do
		{
			if(errc == 0) errc=prg_comm(0x18,1,0,4,0,param[11],0,1,0);	//set trim reg to center
			if(errc == 0) errc=prg_comm(0x2b,0,4,0,0,0,0,0,0);		//sync and meas
			trim=memory[2];
//			printf("trim value: % 3d at 0x%04lX\n",trim,memory[4]);
			if((trim == trim_cyc) && (trim_max == 0)) trim_max=memory[4];
			if(trim == trim_cyc) trim_min=memory[4];
			memory[4]--;
			if(trim > (trim_cyc + 32)) memory[4]-=8;
			if(trim > (trim_cyc + 16)) memory[4]-=4;
			if(trim > (trim_cyc + 8)) memory[4]-=2;
			if(trim > (trim_cyc + 4)) memory[4]--;
			progress("TRIM",240,240-memory[4]);
		}
		while((trim >= trim_cyc) && (errc==0));

		trim=(trim_max+trim_min) >> 1;
//		trim=0x76;
		printf("\nnew trim value: 0x%02lX\n",trim);

		prdiv8=0;
		if(errc == 0)
		{
			bdmfreq=512/memory[0];
			freq=bdmfreq;			//bus clock
			if((freq) > 12.6)
			{
				freq /=8;
				prdiv8=64;
			}
			bfreq=(int)(bdmfreq+0.5);
			fcdiv=(int)(freq*5)+prdiv8;

			errc=prg_comm(0x12,0,0,0,0,fcdiv,bfreq-1,0,0);
		}
		memory[4]=trim;
		memory[0xffaf]=trim;
		memory[0xffae]=0;

//		if(errc == 0) errc=prg_comm(0x18,1,0,4,0,param[11],0,1,0);			//set trim reg to center
		if(errc == 0) errc=prg_comm(0x2b,0,4,0,0,0,0,0,0);				//sync

		prdiv8=0;
		if(errc == 0)
		{
			bdmfreq=512/memory[0];
			freq=bdmfreq;			//bus clock
			if((freq) > 12.6)
			{
				freq /=8;
				prdiv8=64;
			}
			bfreq=(int)(bdmfreq+0.5);
			fcdiv=(int)(freq*5)+prdiv8;

			if(bfreq < 17)
			{
				printf("BDM FREQ = %2.1fMHz     USED MODE = %dMHz     FCDIV = 0x%02x\n",bdmfreq,bfreq,fcdiv);
				errc=prg_comm(0x12,0,0,0,0,fcdiv,bfreq-1,0,0);
			}
		}
	}


	//program lower flash
	if((main_prog == 1) && (errc == 0) && (param[2]!=0))
	{
		read_block(param[2],param[3],param[2]);
		bsize = max_blocksize;
		if(param[3] < bsize) bsize=param[3];	//memory is smaller than max blocksize
		addr = param[2];
		blocks = param[3] / bsize;

		progress("PRGL",blocks,0);
		
		//flash dont start at block boundary
		if((param[2] & 0x7FF) != 0)
		{
			fbsize=0x800-(param[2] & 0x7FF);
			if(must_prog(addr,bsize))
			{
				errc=prg_comm(0x16,fbsize,0,addr,0,addr & 0xff,addr >> 8,fbsize & 0xff,fbsize >> 8);
			}
			addr+=fbsize;
		}

		for(j=0;j<blocks;j++)
		{
			if(errc==0)
			{
			//	printf("BLK : %06X LEN %04X\n",addr,bsize);
				if(must_prog(addr,bsize))
				{
					errc=prg_comm(0x16,bsize,0,addr,0,addr & 0xff,addr >> 8,bsize & 0xff,bsize >> 8);
				}
				progress("PRGL",blocks,j+1);
			//	printf("data: %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3]);
				addr+=bsize;
			}
		}
		printf("\n");
	}



	//program main flash
	if((main_prog == 1) && (errc == 0))
	{
		read_block(param[0],param[1],param[0]);
		if(trim > 0) { memory[0xffae]=0; memory[0xffaf]=trim;} 
		if(no_secure == 1) memory[0xffbf]= (memory[0xffbf] | 3 ) & 0xfe;		
		if(do_secure == 1) memory[0xffbf]= (memory[0xffbf] | 3 ) & 0xfd;		
		bsize = max_blocksize;
		if(param[1] < bsize) bsize=param[1];	//memory is smaller than max blocksize
		addr = param[0];
		blocks = param[1] / bsize;

		progress("PROG",blocks,0);
		
		//flash dont start at block boundary
		if((param[0] & 0x7FF) != 0)
		{
			fbsize=0x800-(param[0] & 0x7FF);
			if(must_prog(addr,bsize))
			{
				errc=prg_comm(0x16,fbsize,0,addr,0,addr & 0xff,addr >> 8,fbsize & 0xff,fbsize >> 8);
			}
			addr+=fbsize;
		}

		for(j=0;j<blocks;j++)
		{
			if(errc == 0)
			{
//				printf("BLK : %06X LEN %04X\n",addr,bsize);
				if(must_prog(addr,bsize))
				{
					errc=prg_comm(0x16,bsize,4,addr,0,addr & 0xff,addr >> 8,0,bsize >> 8);
				}
				progress("PROG",blocks,j+1);
			//	printf("data: %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3]);
				addr+=bsize;
			}
		}
		printf("\n");
	}


	//verify main flash
	if(((main_readout == 1) || (main_verify == 1)) && (param[2] != 0) && (errc == 0))
	{
		addr = param[2];
		bsize = max_blocksize;
		if(param[3] < bsize) bsize = param[3];
		blocks = param[3] / bsize;

//		waitkey();

		//flash dont start at block boundary (fractional block)
		if((param[2] & 0x7FF) != 0)
		{
			fbsize=0x800-(param[2] & 0x7FF);
			errc=prg_comm(0x17,0,bsize,0,addr+ROFFSET,addr & 0xff,addr >> 8,fbsize & 0xff,fbsize >> 8);
			addr+=fbsize;
		}


		progress("RDL ",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",addr,bsize);
			if(errc == 0) errc=prg_comm(0x17,0,bsize,0,addr+ROFFSET,addr & 0xff,addr >> 8,bsize & 0xff,bsize >> 8);
			progress("RDL ",blocks,j+1);
			addr+=bsize;
		}
		printf("\n");
	}

	if((main_verify == 1) && (errc == 0) && (param[2] != 0))
	{
		read_block(param[2],param[3],param[2]);
		if(no_secure == 1) memory[0xffbf]= (memory[0xffbf] | 3 ) & 0xfe;		
		if(trim > 0) { memory[0xffae]=0; memory[0xffaf]=trim;} 

		addr = param[2];
		
		for(j=0;j<param[3];j++)
		{
			if(memory[addr+j] != memory[addr+j+ROFFSET])
			{
				printf("ERR -> ADDR= %04X  DATA= %02X  READ= %02X\n",addr+j,memory[addr+j],memory[addr+j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((main_readout == 1) && (errc == 0) && (param[2] != 0))
	{
		writeblock_data(param[2],param[3],param[2]);
	}



	//verify main flash
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		addr = param[0];
		bsize = max_blocksize;
		if(param[1] < bsize) bsize = param[1];
		blocks = param[1] / bsize;

//		waitkey();

		//flash dont start at block boundary (fractional block)
		if((param[0] & 0x7FF) != 0)
		{
			fbsize=0x800-(param[0] & 0x7FF);
			errc=prg_comm(0x17,0,bsize,0,addr+ROFFSET,addr & 0xff,addr >> 8,fbsize & 0xff,fbsize >> 8);
			addr+=fbsize;
		}


		progress("READ",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("BLK : %06X LEN %04X\n",addr,bsize);
			if(errc == 0) errc=prg_comm(0x17,0,bsize,0,addr+ROFFSET,addr & 0xff,addr >> 8,bsize & 0xff,bsize >> 8);
			progress("READ",blocks,j+1);
			addr+=bsize;
		}
		printf("\n");
	}

	if((main_verify == 1) && (errc == 0))
	{
		read_block(param[0],param[1],param[0]);
		if(no_secure == 1) memory[0xffbf]= (memory[0xffbf] | 3 ) & 0xfe;		
		if(trim > 0) { memory[0xffae]=0; memory[0xffaf]=trim;} 

		addr = param[0];

		for(j=0;j<param[1];j++)
		{
			if(memory[addr+j] != memory[addr+j+ROFFSET])
			{
				printf("ERR -> ADDR= %04X  DATA= %02X  READ= %02X\n",addr+j,memory[addr+j],memory[addr+j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((main_readout == 1) && (errc == 0))
	{
		writeblock_data(param[0],param[1],param[0]);
	}

	if((main_readout == 1))
	{
		writeblock_close();
	}
	
	if((run_ram == 1) && (errc == 0))
	{
		printf("** TRANSFER CODE AND START **\n");
		read_block(param[8],param[9],param[8]);
		ramstart = param[8];
		ramsize = param[9];
//		show_data(ramstart,8);
		if(ramsize > max_blocksize) ramsize = max_blocksize;
		if(errc == 0) errc=prg_comm(0x18,ramsize,0,ramstart,0,ramstart & 0xff,ramstart >> 8,ramsize,ramsize >> 8);	//write bytes
		if(errc == 0) errc=prg_comm(0x200,0,0,0,0,0,0,0,0x90);					//Background
		if(errc == 0) errc=prg_comm(0x205,0,0,0,0,ramstart & 0xff,ramstart >> 8,0,0x4b);	//set PC
		if(errc == 0) errc=prg_comm(0x200,0,0,0,0,0,0,0,0x08);					//Go
		if(errc == 0) waitkey();
	}

	if((debug_ram==1) && (errc==0)) debug_s08(0);
	if((debug_flash==1) && (errc==0)) debug_s08(1);
		
	if(dev_start == 1)
	{
		prg_comm(0x0e,0,0,0,0,0,0,0,0);		//init
		waitkey();
	}

	prg_comm(0x0f,0,0,0,0,0,0,0,0);			//exit
	prg_comm(0x11,0,0,0,0,0,0,0,0);			//BDM exit
	prg_comm(0xfe,0,0,0,0,0,0,0,0);			//disable Pull-up
	
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);		//dev 1
	print_s08_error(errc);

	return errc;
}




