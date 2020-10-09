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

void print_v850_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(no init)",errc);
				break;

		case 0x42:	set_error("(wrong status)",errc);
				break;

		case 0x43:	set_error("(status timeout)",errc);
				break;

		case 0x44:	set_error("(blankcheck fail)",errc);
				break;

		case 0x47:	set_error("(wrong type)",errc);
				break;

		case 0x48:	set_error("(wrong family)",errc);
				break;

		case 0x49:	set_error("(program error)",errc);
				break;

		case 0x4a:	set_error("(verify error)",errc);
				break;

		case 0x4b:	set_error("(secure error)",errc);
				break;

		case 0x4c:	set_error("(already secured)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int prog_v850(void)
{
	int errc,blocks,bsize;
	unsigned long addr,len,maddr,i;
	unsigned int osc_freq;
	int protect=0;
	int chip_erase=0;
	int main_blank=0;
	int main_prog=0;
	int main_verify=0;
	int data_blank=0;
	int data_prog=0;
	int data_verify=0;
	int blank_state=0;

	
	errc=0;
	osc_freq=8;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5v -- use 5V vdd\n");
		printf("-- fr04   4MHz Osc (default 8MHz)\n");
		printf("-- fr05   5MHz Osc (default 8MHz)\n");
		printf("-- fr10  10MHz Osc (default 8MHz)\n");
		printf("-- fr12  12MHz Osc (default 8MHz)\n");

		printf("-- ea -- chip erase\n");
		printf("-- bm -- main flash blank check\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- bd -- data flash blank check\n");
		printf("-- pd -- data flash program\n");
		printf("-- vd -- data flash verify\n");

		printf("-- sc -- secure device (set write prohibition)\n");
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
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);		
		printf("## using 5V VDD\n");
	}

	if(find_cmd("fr04"))
	{
		osc_freq=4;		
	printf("## assuming 4 MHz crystal\n");
	}

	if(find_cmd("fr05"))
	{
		osc_freq=5;		
		printf("## assuming 5 MHz crystal\n");
	}

	if(find_cmd("fr10"))
	{
		osc_freq=10;		
		printf("## assuming 10 MHz crystal\n");
	}

	if(find_cmd("fr12"))
	{
		osc_freq=12;		
		printf("## assuming 12 MHz crystal\n");
	}

	if(find_cmd("ea"))
	{
		chip_erase=1;
		printf("## Action: all erase\n");
	}

	if(find_cmd("bm"))
	{
		main_blank=1;
		printf("## Action: code flash blank check\n");
	}

	if(find_cmd("bd"))
	{
		data_blank=1;
		printf("## Action: data flash blank check\n");
	}

	if(find_cmd("sc"))
	{
		protect=1;
		printf("## Action: secure device (set write prohibition)\n");
	}


	main_prog=check_cmd_prog("pm","code flash");
	main_verify=check_cmd_verify("vm","code flash");
	data_prog=check_cmd_prog("pd","data flash");
	data_verify=check_cmd_verify("vd","data flash");

	if(find_cmd("st"))
	{
		printf("## Action: start device\n");
		i=prg_comm(0x162,0,0,0,0,0,0,0,0);		//init
		waitkey();					//exit
		goto V850_END;
	}
	printf("\n");

	printf("INIT DEVICE \n");
	errc=prg_comm(0x160,0,0,0,0,0,0,0,param[11]);				//init
	if(errc!=0) goto V850_END;
	errc=prg_comm(0x164,0,100,0,0,0,0,0,osc_freq);				//set osc freq
	if(errc!=0) goto V850_END;
	printf(">> DEVICE FREQ   = %d MHz\n",osc_freq); 
	errc=prg_comm(0x163,0,100,0,0,0,0,0,0);					//get signature
	if(errc!=0) goto V850_END;
//	show_data(0,32);	//debug only
	printf(">> VENDOR        = %02X\n",memory[1]); 			
	printf(">> FLASH TYPE    = %02X,%02X\n",memory[2],memory[3]); 
	printf(">> DEVICE NAME   = ");
	for(i=7;i<17;i++)
	{
		printf("%c",memory[i] & 0x7f);
	} 
	printf("\n");

	if(main_blank == 1)
	{
		printf("BLANK CHECK CODE FLASH");
		addr=param[0];
		len=param[1];
		errc=prg_comm(0x16C,0,0,0,0,(addr>>8) & 0xff,(addr>>16) & 0xff,(len>>8) & 0xff,(len>>16) & 0xff);
		if(errc==0)
		{
			printf("... BLANK\n");
			blank_state+=1;		
		}
		else if(errc==0x44)
		{
			printf("... !!! NOT BLANK !!!\n");
			errc=0;
		}		
	}
	
	if((data_blank == 1) && (param[3] > 0))
	{
		printf("BLANK CHECK DATA FLASH");
		addr=param[2];
		len=param[3];
		errc=prg_comm(0x16C,0,0,0,0,(addr>>8) & 0xff,(addr>>16) & 0xff,(len>>8) & 0xff,(len>>16) & 0xff);
		if(errc==0)
		{
			printf("... BLANK\n");		
			blank_state+=2;		
		}
		else if(errc==0x44)
		{
			printf("... !!! NOT BLANK !!!\n");
			errc=0;
		}		
	}
	
	
	if((data_blank == 1) && (param[3] == 0))
	{
			blank_state+=2;		
	}


	if(chip_erase == 1)
	{
		if(blank_state != 3)
		{
			printf("CHIP ERASE\n");
			errc=prg_comm(0x166,0,0,0,0,0,0,0,0);				//chip erase
		}
		else
		{
			printf("FLASH IS ERASED\n");		
		}
	}
	

	if(errc!=0) goto V850_END;
	
	if(main_prog == 1)
	{
		read_block(param[0],param[1],0);
		bsize=2048;
		blocks=param[1] / bsize;
		maddr=0;
		addr=param[0];

		progress("CFLASH PROG ",blocks,0);
		if(blocks > 1)
		for(i=0;i<blocks;i++)
		{
			if(must_prog(maddr,bsize))
			{
				errc=prg_comm(0x16b,bsize,0,maddr,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				if(errc > 0) 
				{
					printf("\n Error at addr %08lX\n",addr);
					errc=0x49;
					goto V850_END;
				}
			}
			addr+=bsize;
			maddr+=bsize;
			progress("CFLASH PROG ",blocks,i+1);					
		}
		printf("\n");
	}

	if((data_prog == 1) && (param[3] > 0))
	{
		read_block(param[2],param[3],0);
		bsize=2048;
		blocks=param[3] / bsize;
		maddr=0;
		addr=param[2];

		progress("DFLASH PROG ",blocks,0);
		if(blocks > 1)
		for(i=0;i<blocks;i++)
		{
			if(must_prog(maddr,bsize))
			{
				errc=prg_comm(0x16b,bsize,0,maddr,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				if(errc > 0) 
				{
					printf("\n Error at addr %08lX\n",addr);
					errc=0x49;
					goto V850_END;
				}
			}
			addr+=bsize;
			maddr+=bsize;
			progress("DFLASH PROG ",blocks,i+1);					
		}
		printf("\n");
	}
		


	if(main_verify == 1)
	{
		read_block(param[0],param[1],0);
		addr=param[0];
		len=param[1];
		bsize=2048;
		blocks=len / bsize;
		maddr=0;

		errc=prg_comm(0x16D,0,0,0,0,(addr>>8) & 0xff,(addr>>16) & 0xff,(len>>8) & 0xff,(len>>16) & 0xff);
		if(errc > 0) 
		{
			errc=0x4a;
			goto V850_END;
		}

		addr=0;
			
		progress("CFLASH VFY  ",blocks,0);
		if(blocks > 1)
		for(i=1;i<blocks;i++)
		{
			errc=prg_comm(0x16A,bsize,0,maddr,0,0,0,0,0x17);
			if(errc > 0) 
			{
				printf("\n Error at addr %08lX\n",addr);
				errc=0x4a;
				goto V850_END;
			}
			addr+=bsize;
			maddr+=bsize;
			progress("CFLASH VFY  ",blocks,i+1);					
		}
		errc=prg_comm(0x16A,bsize,0,maddr,0,0,0,0,0x03);
		if(errc > 0) 
		{
			printf("\n Error at addr %08lX\n",addr);
			errc=0x4a;
			goto V850_END;
		}
		printf("\n");
	}


	if((data_verify == 1) && (param[3] > 0))
	{
		read_block(param[2],param[3],0);
		addr=param[2];
		len=param[3];
		bsize=2048;
		blocks=len / bsize;
		maddr=0;

		errc=prg_comm(0x16D,0,0,0,0,(addr>>8) & 0xff,(addr>>16) & 0xff,(len>>8) & 0xff,(len>>16) & 0xff);
		if(errc > 0) 
		{
			errc=0x4a;
			goto V850_END;
		}

		addr=0;
			
		progress("DFLASH VFY  ",blocks,0);
		if(blocks > 1)
		for(i=1;i<blocks;i++)
		{
			errc=prg_comm(0x16A,bsize,0,maddr,0,0,0,0,0x17);
			if(errc > 0) 
			{
				printf("\n Error at addr %08lX\n",addr);
				errc=0x4a;
				goto V850_END;
			}
			addr+=bsize;
			maddr+=bsize;
			progress("DFLASH VFY  ",blocks,i+1);					
		}
		errc=prg_comm(0x16A,bsize,0,maddr,0,0,0,0,0x03);
		if(errc > 0) 
		{
			printf("\n Error at addr %08lX\n",addr);
			errc=0x4a;
			goto V850_END;
		}
		printf("\n");
	}


	if(protect == 1)
	{
		printf("SECURE\n");
		errc=prg_comm(0x167,0,0,0,0,0,0,0,0);				//chip erase
	}

V850_END:

	i=prg_comm(0x161,0,0,0,0,0,0,0,0);			//exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_v850_error(errc);
	return errc;
}






