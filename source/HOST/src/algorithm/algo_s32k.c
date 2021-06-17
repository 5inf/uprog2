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
#include "exec/s32k/exec_s32k.h"

void print_s32kswd_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(timeout: no ACK)",errc);
				break;

		case 0x42:	set_error("(erase timeout)",errc);
				break;

		case 0x48:	set_error("(bootcode timeout)",errc);
				break;

		case 0x50:	set_error("(wrong ID)",errc);
				break;

		case 0x51:	set_error("(verify error)",errc);
				break;

		case 0x52:	set_error("(program check)",errc);
				break;

		case 0x54:	set_error("(partition error)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_s32kswd(void)
{
	int errc,blocks,i,j;
	unsigned long addr,len,maddr;
	int mass_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int main_check=0;
	int data_prog=0;
	int data_verify=0;
	int data_readout=0;
	int data_check=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int dev_start=0;
	int run_ram=0;
	int unsecure=0;
	int ignore_id=0;	
	int debug_ram=0;
	int debug_flash=0;
	int partition=0;
	int pstatus=0;
	int eds=0;
	int pcode=0;
	int flexramfunc=0;
	int fcnfgm=0;
	int dfsize=0;
	int eesize=0;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- ea -- erase all (mass erase)\n");
		printf("-- un -- unsecure code (set FSEC to 0xFE)\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- cm -- main flash verify (margin check)\n");
		printf("-- rm -- main flash readout\n");
		printf("-- pd -- data flash program\n");
		printf("-- vd -- data flash verify\n");
		printf("-- cd -- data flash verify (margin check)\n");
		printf("-- rd -- data flash readout\n");
		printf("-- pe -- emulated eeprom program\n");
		printf("-- ve -- emulated eeprom verify\n");
		printf("-- re -- emulated eeprom readout\n");

		if(param[10] < 130)
		{
			printf("-- PD3200 -- parition only 32K dataflash\n");
			printf("-- PD0032 -- parition only 2K EEPROM\n");
			printf("-- PD0824 -- parition 8K dataflash / 2K EEPROM\n");
		}

		if(param[10] > 130)
		{
			printf("-- PD6400 -- parition only 64K dataflash\n");
			printf("-- PD0064 -- parition only 4K EEPROM\n");
			printf("-- PD1648 -- parition 16K dataflash / 4K EEPROM\n");
			printf("-- PD3232 -- parition 32K dataflash / 4K EEPROM\n");
		}

		printf("-- ii -- ignore ID\n");

		printf("-- rr -- run code in RAM\n");
		printf("-- dr -- debug code in RAM\n");
		printf("-- df -- debug code in FLASH\n");
		printf("-- st -- start device\n");
 		printf("-- d2 -- switch to device 2\n");

		return 0;
	}

	if(find_cmd("5v"))
	{
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		printf("## using 5V VDD\n");
	}


	if(find_cmd("d2"))
	{
		errc=prg_comm(0x2ee,0,0,0,0,0,0,0,0);	//dev 2
		printf("## switch to device 2\n");
	}

	if(find_cmd("ii"))
	{
		ignore_id=1;
		printf("## ignore ID\n");
	}

	if(find_cmd("un"))
	{
		unsecure=1;
		printf("## unsecure code\n");
	}

	if(((strstr(cmd,"PD3200")) && ((strstr(cmd,"PD3200") - cmd) == 1)) && (param[10] < 130))
	{
		partition=1;
		printf("## partition only 32K dataflash\n");
		eds=0x0F;
		pcode=0x00;
		flexramfunc=0xff;
		fcnfgm=0x02;	
	}
	else if(((strstr(cmd,"PD6400")) && ((strstr(cmd,"PD6400") - cmd) == 1)) && (param[10] > 130))
	{
		partition=1;
		printf("## partition only 64K dataflash\n");
		eds=0x0F;
		pcode=0x00;
		flexramfunc=0xff;
		fcnfgm=0x02;	
	}
	else if(((strstr(cmd,"PD0032")) && ((strstr(cmd,"PD0032") - cmd) == 1)) && (param[10] < 130))
	{
		partition=1;
		printf("## partition only 2K EEPROM\n");
		partition=1;
		eds=0x03;
		pcode=0x08;
		flexramfunc=0x00;
		fcnfgm=0x01;
	}
	else if(((strstr(cmd,"PD0064")) && ((strstr(cmd,"PD0064") - cmd) == 1)) && (param[10] > 130))
	{
		partition=1;
		printf("## partition only 4K EEPROM\n");
		partition=1;
		eds=0x02;
		pcode=0x08;
		flexramfunc=0x00;
		fcnfgm=0x01;
	}
	else if(((strstr(cmd,"PD0824")) && ((strstr(cmd,"PD0824") - cmd) == 1)) && (param[10] < 130))
	{
		partition=1;
		printf("## partition 8K dataflash / 2K EEPROM\n");
		partition=1;
		eds=0x03;
		pcode=0x09;
		flexramfunc=0x00;
		fcnfgm=0x01;
	}
	else if(((strstr(cmd,"PD1648")) && ((strstr(cmd,"PD1648") - cmd) == 1)) && (param[10] > 130))
	{
		partition=1;
		printf("## partition 16K dataflash / 4K EEPROM\n");
		partition=1;
		eds=0x02;
		pcode=0x0A;
		flexramfunc=0x00;
		fcnfgm=0x01;
	}
	else if(((strstr(cmd,"PD3232")) && ((strstr(cmd,"PD3232") - cmd) == 1)) && (param[10] > 130))
	{
		partition=1;
		printf("## partition 32K dataflash / 4K EEPROM\n");
		partition=1;
		eds=0x02;
		pcode=0x0B;
		flexramfunc=0x00;
		fcnfgm=0x01;
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
			goto S32KSWD_ORUN;
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
			debug_ram = 1;
			printf("## Action: debug code in RAM using %s\n",sfile);
			goto S32KSWD_ORUN;
		}
	}
	else if(find_cmd("df"))
	{
		debug_flash = 1;
		printf("## Action: debug code in FLASH\n");
		goto S32KSWD_ORUN;
	}
	else
	{
		if(find_cmd("un"))
		{
			unsecure=1;
			printf("## Action: unsecure device\n");
		}

		if(find_cmd("ea"))
		{
			mass_erase=1;
			printf("## Action: mass erase\n");
		}

		main_prog=check_cmd_prog("pm","code flash");
		main_verify=check_cmd_verify("vm","code flash");
		main_check=check_cmd_verify("cm","code flash (margin check)");
		main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
		data_prog=check_cmd_prog("pd","data flash");
		data_verify=check_cmd_verify("vd","data flash");
		data_check=check_cmd_verify("cd","data flash (margin check)");
		data_readout=check_cmd_read("rd","data flash",&data_prog,&data_verify);
		eeprom_prog=check_cmd_prog("pe","eeprom");
		eeprom_verify=check_cmd_verify("ve","eeprom");
		eeprom_readout=check_cmd_read("re","eeprom",&eeprom_prog,&eeprom_verify);



		if(find_cmd("st"))
		{
			dev_start=1;
			printf("## Action: start device\n");
		}
	}
	printf("\n");

S32KSWD_ORUN:

	//open file if read 
	if((main_readout == 1) || (data_readout == 1) || (eeprom_readout == 1))
	{
		errc=writeblock_open();
	}

	if(errc > 0) return errc;

	if(dev_start == 0)
	{
		if((mass_erase == 1) && (errc == 0))
		{
			errc=prg_comm(0x1D0,0,16,0,0,0,0,0,0x55);	//init
			if(errc > 0) goto ERR_EXIT;
			printf("JID: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
			printf("ERASE FLASH\n");
			errc=prg_comm(0x1D2,0,4,0,0,0,0,0,0);		//erase direct
			if(errc > 0) goto ERR_EXIT;
//			show_data(0,4);
			printf("RE-INIT\n");
			errc=prg_comm(0x91,0,0,0,0,0,0,0,0);		//exit
			errc=prg_comm(0x1D0,0,16,0,0,0,0,0,0);		//re-init
		}
		else
		{
			printf("READ ID\n");
			errc=prg_comm(0x1D0,0,16,0,0,0,0,0,0);					//init
			if(errc > 0)
			{
				printf("ACK STATUS = %02X\n",memory[0]);
				goto ERR_EXIT;
			}
			printf("JID: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
		}
	
		if(errc != 0) goto ERR_EXIT;
		
		errc=prg_comm(0x1D1,0,4,0,0,0x24,0x80,0x04,0x40);				//READ DEVID
		j=(memory[3] >> 4)*100+(memory[3] & 0x0F)*10+(memory[2] >> 4);

		if((j == 1665))
		{
			printf("INVALID DEVICE CODE, DEVICE MIGHT BE PROTECTED\n",j,(int)param[10]);
			errc=0x50;	
			goto ERR_EXIT;
		}

		else if((j != param[10]) && (ignore_id==0))
		{
			printf("DEVICE CODE = %d, SHOULD BE %d\n",j,(int)param[10]);
			errc=0x50;	
			goto ERR_EXIT;
		}
		else
		{
			printf("DEVICE: S32K%d\n",j);
			if(memory[0] & 0x80) printf("++ Security\n");
			if(memory[0] & 0x40) printf("++ ISO CAN-FD\n");
			if(memory[0] & 0x20) printf("++ FlexIO\n");
			if(memory[0] & 0x10) printf("++ QuadSPI\n");
			if(memory[0] & 0x08) printf("++ Ethernet\n");
			if(memory[0] & 0x04) printf("++ undef (2)\n");
			if(memory[0] & 0x02) printf("++ SAI\n");
			if(memory[0] & 0x01) printf("++ undef (0)\n");

			errc=prg_comm(0x1D1,0,4,0,0,0x4c,0x80,0x04,0x40);				//READ DEVID
			//show_data(0,4);
			if((memory[2] & 0x0f) == 2) printf("++ 4K FlexRAM\n");
			if((memory[2] & 0x0f) == 3) printf("++ 2K FlexRAM\n");
			if((memory[2] & 0xF0) != 0) 
			{
				printf("++ NO DFLASH PARTITION\n");
				if((pstatus == 0) && ((memory[2] & 0x0f)== 3)) dfsize=32768;
				if((pstatus == 0) && ((memory[2] & 0x0f)== 2)) dfsize=65536;
			}
			else
			{
				pstatus=memory[1] >> 4;
				printf("++ DFLASH PARTITION CODE %X\n",pstatus);
				if((pstatus == 0) && ((memory[2] & 0x0f)== 3)) dfsize=32768;
				if((pstatus == 3) && ((memory[2] & 0x0f)== 3)) {eesize=2048;}
				if((pstatus == 8) && ((memory[2] & 0x0f)== 3)) {eesize=2048;}
				if((pstatus == 9) && ((memory[2] & 0x0f)== 3)) {dfsize=8192;eesize=2048;}
				if((pstatus == 11) && ((memory[2] & 0x0f)== 3)) dfsize=32768;
								
				if((pstatus == 0) && ((memory[2] & 0x0f)== 2)) dfsize=65536;
				if((pstatus == 3) && ((memory[2] & 0x0f)== 2)) {dfsize=32768;eesize=4096;}
				if((pstatus == 8) && ((memory[2] & 0x0f)== 2)) {eesize=4096;}
				if((pstatus == 10) && ((memory[2] & 0x0f)== 2)) {dfsize=16384;eesize=4096;}
				if((pstatus == 11) && ((memory[2] & 0x0f)== 2)) {dfsize=32768;eesize=4096;}				
				if((pstatus == 12) && ((memory[2] & 0x0f)== 2)) dfsize=65536;
				
				printf("  ++ DFLASH SIZE %d\n",dfsize);
				printf("  ++ EEPROM SIZE %d\n",eesize);
				
				if(partition == 1)
				{
					printf("!! DFLASH PARTITION COMMAND WILL BE IGNORED !!\n");
					partition=0;
				}
			}
		}		
		
		if((data_prog == 1) && (dfsize == 0))
		{
			printf("!! DFLASH PROGRAMMING DISABLED (NO DFLASH PARTITION)\n");
			data_prog=0;
		}

		if((data_verify == 1) && (dfsize == 0))
		{
			printf("!! DFLASH VERIFY DISABLED (NO DFLASH PARTITION)\n");
			data_verify=0;
		}


		if((data_readout == 1) && (dfsize == 0))
		{
			printf("!! DFLASH READOUT DISABLED (NO DFLASH PARTITION)\n");
			data_readout=0;
		}

		if((data_check == 1) && (dfsize == 0))
		{
			printf("!! DFLASH MRGIN CHECK DISABLED (NO DFLASH PARTITION)\n");
			data_check=0;
		}

		
		if((eeprom_prog == 1) && (eesize == 0))
		{
			printf("!! EEPROM PROGRAMMING DISABLED (NO DFLASH PARTITION)\n");
			eeprom_prog=0;
		}

		if((eeprom_verify == 1) && (eesize == 0))
		{
			printf("!! EEPROM VERIFY DISABLED (NO DFLASH PARTITION)\n");
			eeprom_verify=0;
		}


		if((eeprom_readout == 1) && (eesize == 0))
		{
			printf("!! EEPROM READOUT DISABLED (NO DFLASH PARTITION)\n");
			eeprom_readout=0;
		}
		
						//transfer loader to ram
		if((run_ram == 0) && (errc == 0) && ((main_prog == 1) || (main_check == 1) || (data_prog == 1) || (data_check == 1) || 
		(eeprom_prog == 1) || (eeprom_readout == 1) || (eeprom_verify == 1) || (partition > 0)))
		{
			printf("TRANSFER LOADER\n");
			for(j=0;j<512;j++)
			{
				switch(algo_nr)
				{
					case 53:	memory[j]=exec_s32k[j]; break;
					default:	memory[j]=0xff;
				}
			}

			addr=param[4];				//RAM start

			errc=prg_comm(0xb2,0x200,0,0,0,		//write 0,5 K bootloader
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff,
				2);
		
			errc=prg_comm(0x128,8,12,0,0,	
					addr & 0xff,
					(addr >> 8) & 0xff,
					(addr >> 16) & 0xff,
					(addr >> 24) & 0xff);

			errc=prg_comm(0x12b,0,64,0,0,0,0,0,0);	

		}


		if(partition > 0)
		{
			printf("PARTITION DATAFLASH (EESIZE= %02X    DEPART= %02X)\n",eds,pcode);
			errc=prg_comm(0x59,0,4,0,ROFFSET,0x58,0x00,eds,pcode);
//			show_data(ROFFSET,4);

			if((memory[ROFFSET+1] != 0) && (errc==0))
			{
				errc=0x54;
				maddr=(memory[ROFFSET+2] + (memory[ROFFSET+3] << 8)) & 0x7ff;
				if((memory[ROFFSET+1] & 16) != 0) printf("!!! PROTECTION VIOLATION\n");
				if((memory[ROFFSET+1] & 32) != 0) printf("!!! ACCESS ERROR\n");
				if((memory[ROFFSET+1] & 64) != 0) printf("!!! READ COLLISION\n");
			}
			
			printf("SET FlexRAM FUNCTION (FCODE= %02X  %02X)\n",flexramfunc,fcnfgm);
			errc=prg_comm(0x59,0,4,0,ROFFSET,0x5A,flexramfunc,fcnfgm,0);
//			show_data(ROFFSET,4);

			if((memory[ROFFSET+1] != 0) && (errc==0))
			{
				errc=0x54;
				maddr=(memory[ROFFSET+2] + (memory[ROFFSET+3] << 8)) & 0x7ff;
				if((memory[ROFFSET+1] & 16) != 0) printf("!!! PROTECTION VIOLATION\n");
				if((memory[ROFFSET+1] & 32) != 0) printf("!!! ACCESS ERROR\n");
				if((memory[ROFFSET+1] & 64) != 0) printf("!!! READ COLLISION\n");
			}
			

		}

	}
	
	
	if((run_ram == 0) && (errc == 0) && (dev_start == 0))
	{
		if((main_prog == 1) && (errc == 0))
		{
			addr=param[0];
			maddr=0;
			blocks=param[1]/max_blocksize;
			len=read_block(param[0],param[1],0);		//read flash
			if(unsecure==1) memory[0x40c]=0xFE;

			//erase sector 0
			printf("ERASE FIRST FLASH SECTOR\n");
			errc=prg_comm(0x59,0,0,0,0,0x53,0,0,0);

			progress("FLASH PROG  ",blocks,0);
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);


			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,max_blocksize) && (errc==0))
				{
					//transfer data
					errc=prg_comm(0xb2,max_blocksize,0,maddr,0,
						0x04,0x00,0x20,max_blocksize >> 8);

					//execute prog
					errc=prg_comm(0x59,0,0,0,0,
						0x52,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);

				}
				addr+=max_blocksize;
				maddr+=max_blocksize;
				progress("FLASH PROG  ",blocks,i+1);
			}
			printf("\n");
		}


		if((main_check == 1) && (errc == 0))
		{
			addr=param[0];
			maddr=0;
			blocks=param[1]/max_blocksize;
			len=read_block(param[0],param[1],0);		//read flash
			if(unsecure==1) memory[0x40c]=0xFE;
			progress("FLASH CHECK ",blocks,0);
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);

			for(i=0;i<blocks;i++)
			{
				if(errc==0)
				{
					//transfer data to 0x20000400
					errc=prg_comm(0xb2,max_blocksize,0,maddr,0,0x04,0x00,0x20,max_blocksize >> 8);

					//execute check
					errc=prg_comm(0x59,0,4,0,ROFFSET,
						0x54,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);

//					printf("ADDR = %08lx\n",addr);
//					show_data(ROFFSET,4);
					
					progress("FLASH CHECK ",blocks,i+1);
					if((memory[ROFFSET+1] != 0) && (errc==0))
					{
						printf("\n");
						errc=0x52;
						maddr=(memory[ROFFSET+2] + (memory[ROFFSET+3] << 8)) & 0x7ff;
						if((memory[ROFFSET+1] & 1) != 0) printf("!!! COMPARSION FAILED AT %08lX-%08lX\n",maddr+addr,maddr+addr+3);
						if((memory[ROFFSET+1] & 2) != 0) printf("!!! COMPARSION FAILED AT %08lX-%08lX\n",maddr+addr,maddr+addr+3);
						if((memory[ROFFSET+1] & 16) != 0) printf("!!! PROTECTION VIOLATION AT %08lX-%08lX\n",maddr+addr,maddr+addr+3);
						if((memory[ROFFSET+1] & 32) != 0) printf("!!! ACCESS ERROR AT %08lX-%08lX\n",maddr+addr,maddr+addr+3);
						if((memory[ROFFSET+1] & 64) != 0) printf("!!! READ COLLISION AT %08lX-%08lX\n",maddr+addr,maddr+addr+3);
					}
					else
					{
						addr+=max_blocksize;
						maddr+=max_blocksize;
					}
				}
			}
			printf("\n");
		}


		if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
		{
			maddr=0;
			addr=param[0];
			blocks=param[1]/max_blocksize;
			progress("FLASH READ  ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(errc==0)
				{
					if(addr==0)
					{
						errc=prg_comm(0xbf,0,2,0,ROFFSET+maddr,
							(addr >> 8) & 0xff,
							(addr >> 16) & 0xff,
							(addr >> 24) & 0xff,
							max_blocksize >> 8);

						errc=prg_comm(0xbf,0,2,0,ROFFSET+maddr,
							(addr >> 8) & 0xff,
							(addr >> 16) & 0xff,
							(addr >> 24) & 0xff,
							max_blocksize >> 8);
					}

					errc=prg_comm(0xbf,0,2048,0,ROFFSET+maddr,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff,
						max_blocksize >> 8);

					

					addr+=max_blocksize;
					maddr+=max_blocksize;
					progress("FLASH READ  ",blocks,i+1);
				}
			}
			printf("\n");
		}


		if((main_readout == 1) && (errc == 0))
		{
			writeblock_data(0,param[1],param[0]);
		}

		//verify main
		if((main_verify == 1) && (errc == 0))
		{
			read_block(param[0],param[1],0);
			if(unsecure==1) memory[0x40c]=0xFE;
			printf("VERIFY FLASH (%ld KBytes)\n",param[1]/1024);
			addr = param[0];
			maddr=0;
			len = param[1];
			for(j=0;j<len;j++)
			{
				if(memory[maddr+j] != memory[maddr+j+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr+j,memory[maddr+j],memory[maddr+j+ROFFSET]);
					errc=0x51;
				}
			}
		}


		if((data_prog == 1) && (errc == 0))
		{
			addr=param[2];
			maddr=0;
			blocks=dfsize/max_blocksize;
			len=read_block(param[2],dfsize,0);		//read flash
			progress("DFLASH PROG ",blocks,0);
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);

			addr-=0x10000000;
			addr+=0x800000;

			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,max_blocksize) && (errc==0))
				{
					//transfer data
					errc=prg_comm(0xb2,max_blocksize,0,maddr,0,
						0x04,0x00,0x20,max_blocksize >> 8);

					//execute prog
					errc=prg_comm(0x59,0,0,0,0,
						0x52,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);

				}
				addr+=max_blocksize;
				maddr+=max_blocksize;
				progress("DFLASH PROG ",blocks,i+1);
			}
			printf("\n");
		}
		
		if((data_check == 1) && (errc == 0))
		{
			addr=param[2];
			maddr=0;
			blocks=dfsize/max_blocksize;
			len=read_block(param[2],dfsize,0);		//read flash
			progress("DFLASH CHECK ",blocks,0);
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);
			addr-=0x10000000;
			addr+=0x800000;

			for(i=0;i<blocks;i++)
			{
				if(errc==0)
				{
					//transfer data
					errc=prg_comm(0xb2,max_blocksize,0,maddr,0,
						0x04,0x00,0x20,max_blocksize >> 8);

					//execute prog
					errc=prg_comm(0x59,0,4,0,ROFFSET,
						0x54,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);

					progress("DFLASH CHECK ",blocks,i+1);
					if((memory[ROFFSET+1] != 0) && (errc==0))
					{
						printf("\n");
						errc=0x52;
						maddr=(memory[ROFFSET+2] + (memory[ROFFSET+3] << 8)) & 0x7ff;
						if((memory[ROFFSET+1] & 1) != 0) printf("!!! COMPARSION FAILED AT %08lX-%08lX\n",maddr+addr,maddr+addr+3);
						if((memory[ROFFSET+1] & 2) != 0) printf("!!! COMPARSION FAILED AT %08lX-%08lX\n",maddr+addr,maddr+addr+3);
						if((memory[ROFFSET+1] & 16) != 0) printf("!!! PROTECTION VIOLATION AT %08lX-%08lX\n",maddr+addr,maddr+addr+3);
						if((memory[ROFFSET+1] & 32) != 0) printf("!!! ACCESS ERROR AT %08lX-%08lX\n",maddr+addr,maddr+addr+3);
						if((memory[ROFFSET+1] & 64) != 0) printf("!!! READ COLLISION AT %08lX-%08lX\n",maddr+addr,maddr+addr+3);
					}
					else
					{
						addr+=max_blocksize;
						maddr+=max_blocksize;	
					}
				}
			}
			printf("\n");
		}		

		if(((data_readout == 1) || (data_verify == 1)) && (errc == 0))
		{
			maddr=0;
			addr=param[2];
			blocks=dfsize/max_blocksize;
//			addr=0x20000000;
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);
			progress("DFLASH READ ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(errc==0)
				{
					errc=prg_comm(0xbf,0,2048,0,ROFFSET+maddr,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff,
						max_blocksize >> 8);
					addr+=max_blocksize;
					maddr+=max_blocksize;
					progress("DFLASH READ ",blocks,i+1);
				}
			}
			printf("\n");
		}

		if((data_readout == 1) && (errc == 0))
		{
			writeblock_data(0,dfsize,param[2]);
		}

		//verify data
		if((data_verify == 1) && (errc == 0))
		{
			read_block(param[2],dfsize,0);
			printf("VERIFY DFLASH (%ld KBytes)\n",dfsize/1024);
			addr = param[2];
			maddr=0;
			len = dfsize;
			for(j=0;j<len;j++)
			{
				if(memory[maddr+j] != memory[maddr+j+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr+j,memory[maddr+j],memory[maddr+j+ROFFSET]);
					errc=0x51;
				}
			}
		}

		if((eeprom_prog == 1) && (errc == 0))
		{
			addr=param[8];
			maddr=0;
			blocks=eesize/max_blocksize;
			len=read_block(param[8],eesize,0);		//read flash
			printf("WAIT FOR EEPROM READY...\n");
			errc=prg_comm(0x59,0,0,0,0,0x5d,0,0,0);
			if(errc != 0) goto ERR_EXIT;
			progress("EEPROM PROG ",blocks,0);
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);

			for(i=0;i<blocks;i++)
			{
				if(must_prog(maddr,max_blocksize) && (errc==0))
				{
					//transfer data
					errc=prg_comm(0xb2,max_blocksize,0,maddr,0,
						0x04,0x00,0x20,max_blocksize >> 8);

					//execute prog
					errc=prg_comm(0x59,0,0,0,0,
						0x5E,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff);

				}
				addr+=max_blocksize;
				maddr+=max_blocksize;
				progress("EEPROM PROG ",blocks,i+1);
			}
			printf("\n");
			if(errc != 0) goto ERR_EXIT;
			printf("WAIT FOR EEPROM READY...\n");
			errc=prg_comm(0x59,0,0,0,0,0x5d,0,0,0);
			if(errc != 0) goto ERR_EXIT;
		}

		if(((eeprom_readout == 1) || (eeprom_verify == 1)) && (errc == 0))
		{
			maddr=0;
			addr=param[8];
			blocks=eesize/max_blocksize;
//			addr=0x20000000;
//			printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);
			printf("WAIT FOR EEPROM READY...\n");
			errc=prg_comm(0x59,0,0,0,0,0x5c,0,0,0);
			if(errc != 0) goto ERR_EXIT;
			progress("EEPROM READ ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(errc==0)
				{
					errc=prg_comm(0xbf,0,2048,0,ROFFSET+maddr,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff,
						max_blocksize >> 8);
					addr+=max_blocksize;
					maddr+=max_blocksize;
					progress("EEPROM READ ",blocks,i+1);
				}
			}
			printf("\n");
		}

		if((eeprom_readout == 1) && (errc == 0))
		{
			writeblock_data(0,eesize,param[8]);
		}

		//verify data
		if((eeprom_verify == 1) && (errc == 0))
		{
			read_block(param[8],dfsize,0);
			printf("VERIFY EEPROM (%ld KBytes)\n",eesize/1024);
			addr = param[8];
			maddr=0;
			len = eesize;
			for(j=0;j<len;j++)
			{
				if(memory[maddr+j] != memory[maddr+j+ROFFSET])
				{
					printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
						addr+j,memory[maddr+j],memory[maddr+j+ROFFSET]);
					errc=0x51;
				}
			}
		}

		//open file if was read 
		if((main_readout == 1) || (data_readout == 1) || (eeprom_readout == 1))
		{
			writeblock_close();
		}
	}




	if((run_ram == 1) && (errc == 0))
	{
		len = read_block(param[4],param[5],0);
		printf("BYTES= %04lX\n",len);
		if(len < 8)
		{	
			len = read_block(0,param[5],0);	//read from addr 0
			printf("LOW BYTES= %04lX\n",len);
		}

		printf("TRANSFER & START CODE\n");
		addr=param[4];
		maddr=0;
		blocks=(param[5]+2047) >> 11;

		progress("TRANSFER ",blocks,0);

		for(i=0;i<blocks;i++)
		{
			errc=prg_comm(0xb2,max_blocksize,0,maddr,0,		//write 1.K
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				0x20,max_blocksize >> 8);
		
			addr+=max_blocksize;
			maddr+=max_blocksize;
			progress("TRANSFER ",blocks,i+1);
		}


		addr=param[4];

		printf("\nSTART CODE AT 0x%02x%02x%02x%02x\n",memory[7],memory[6],memory[5],memory[4]);
		
		errc=prg_comm(0x128,8,12,0,0,0,0,0,0);	//set pc + sp	

		errc=prg_comm(0x12b,0,100,0,0,0,0,0,0);	
		
		if(errc == 0)
		{
			waitkey();
		}		

	}

	if((debug_ram==1) && (errc==0)) debug_armcortex(0);
	if((debug_flash==1) && (errc==0)) debug_armcortex(1);
	
	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
		i=prg_comm(0x0f,0,0,0,0,0,0,0,0);					//exit
	}

ERR_EXIT:

	i=prg_comm(0x91,0,0,0,0,0,0,0,0);					//SWIM exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_s32kswd_error(errc);

	return errc;
}

