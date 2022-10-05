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

void print_test_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

int paraprog_self_test(void)
{
	unsigned short minval,actval;
	long meanval,ltime;
	int errc,i,j;
	int data_test=0;
	int addrl_test=0;
	int addrh_test=0;
	int ctrl_test=0;
	int scan_test=0;
	int dist_test=0;
	int input_test=0;
	int read_test=0;
	int read_loop=0;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- da -- data lines test\n");
		printf("-- al -- low address lines test\n");
		printf("-- ah -- high address lines test\n");
		printf("-- ct -- control lines test\n");
		printf("-- sl -- signal locate\n");
		printf("-- dt -- disturb test\n");
		printf("-- it -- input test\n");
		printf("-- rt -- read test\n");
		printf("-- rl -- read test (loop)\n");
		return 0;
	}

	if(find_cmd("da"))
	{
		data_test=1;
		printf("## Action: data lines test\n");
	}

	if(find_cmd("al"))
	{
		addrl_test=1;
		printf("## Action: low address lines test\n");
	}

	if(find_cmd("ah"))
	{
		addrh_test=1;
		printf("## Action: high address lines test\n");
	}

	if(find_cmd("ct"))
	{
		ctrl_test=1;
		printf("## Action: control lines test\n");
	}

	if(find_cmd("sl"))
	{
		scan_test=1;
		printf("## Action: signal locate\n");
	}

	if(find_cmd("dt"))
	{
		dist_test=1;
		printf("## Action: disturb test\n");
	}

	if(find_cmd("it"))
	{
		input_test=1;
		printf("## Action: input test\n");
	}

	if(find_cmd("rt"))
	{
		read_test=1;
		printf("## Action: read test\n");
	}

	if(find_cmd("rl"))
	{
		read_loop=1;
		printf("## Action: read loop\n");
	}


	errc=prg_comm(0x10,0,0,0,0,0,0,0,0);				//init


	if(data_test == 1)
	{
		printf("DATA LINES TEST\n");
		errc=prg_comm(0xA0,0,0,0,0,0,0,0,0);				//start
		waitkey();
		errc=prg_comm(0x00,0,0,0,0,0,0,0,0);				//stop
	}

	if(addrl_test == 1)
	{
		printf("LOW ADDRESS LINES TEST\n");
		errc=prg_comm(0xA1,0,0,0,0,0,0,0,0);				//start
		waitkey();
		errc=prg_comm(0x00,0,0,0,0,0,0,0,0);				//stop
	}

	if(addrh_test == 1)
	{
		printf("HIGH ADDRESS LINES TEST\n");
		errc=prg_comm(0xA2,0,0,0,0,0,0,0,0);				//start
		waitkey();
		errc=prg_comm(0x00,0,0,0,0,0,0,0,0);				//stop
	}

	if(ctrl_test == 1)
	{
		printf("CONTROL LINES TEST\n");
		errc=prg_comm(0xA3,0,0,0,0,0,0,0,0);				//start
		waitkey();
		errc=prg_comm(0x00,0,0,0,0,0,0,0,0);				//stop
	}


	if(scan_test==1)
	{
		printf("<< PRESS ENTER TO EXIT >>\n");

		while(!(kbhit()))
		{
			errc=prg_comm(0xA4,0,107,0,ROFFSET,0,0,0,0);		//get data
			meanval=0;
			minval = 0xffff;
			actval=100;
			j=255;
	//		show_data(ROFFSET,16);
			for(i=0;i<53;i++)
			{
				actval=memory[ROFFSET+2*i] & 0xff;
				actval+=(memory[ROFFSET+2*i+1] << 8) & 0xff00;
				if(actval < minval) 
				{
					minval = actval;
					j=i;
				}
				meanval +=actval; 
			}
			meanval = meanval / 53;
	//		printf("\nMEAN = %d\n",meanval);
	//		printf("MIN  = %u\n",minval);
	//		printf("POS  = %d\n",j);
	//		printf("CHK  = %d\n",memory[ROFFSET+106]);
			

			if(minval < (meanval - 5000))
			{
				switch(j)
				{
					case 0:		printf("LOC = DATA  0     \r");break;
					case 1:		printf("LOC = DATA  1     \r");break;
					case 2:		printf("LOC = DATA  2     \r");break;
					case 3:		printf("LOC = DATA  3     \r");break;
					case 4:		printf("LOC = DATA  4     \r");break;
					case 5:		printf("LOC = DATA  5     \r");break;
					case 6:		printf("LOC = DATA  6     \r");break;
					case 7:		printf("LOC = DATA  7     \r");break;
					case 8:		printf("LOC = DATA  8     \r");break;
					case 9:		printf("LOC = DATA  9     \r");break;
					case 10:	printf("LOC = DATA 10     \r");break;
					case 11:	printf("LOC = DATA 11     \r");break;
					case 12:	printf("LOC = DATA 12     \r");break;
					case 13:	printf("LOC = DATA 13     \r");break;
					case 14:	printf("LOC = DATA 14     \r");break;
					case 15:	printf("LOC = DATA 15     \r");break;

					case 16:	printf("LOC = ADDR  0     \r");break;
					case 17:	printf("LOC = ADDR  1     \r");break;
					case 18:	printf("LOC = ADDR  2     \r");break;
					case 19:	printf("LOC = ADDR  3     \r");break;
					case 20:	printf("LOC = ADDR  4     \r");break;
					case 21:	printf("LOC = ADDR  5     \r");break;
					case 22:	printf("LOC = ADDR  6     \r");break;
					case 23:	printf("LOC = ADDR  7     \r");break;
					case 24:	printf("LOC = ADDR  8     \r");break;
					case 25:	printf("LOC = ADDR  9     \r");break;
					case 26:	printf("LOC = ADDR 10     \r");break;
					case 27:	printf("LOC = ADDR 11     \r");break;
					case 28:	printf("LOC = ADDR 12     \r");break;
					case 29:	printf("LOC = ADDR 13     \r");break;
					case 30:	printf("LOC = ADDR 14     \r");break;
					case 31:	printf("LOC = ADDR 15     \r");break;

					case 32:	printf("LOC = ADDR 16     \r");break;
					case 33:	printf("LOC = ADDR 17     \r");break;
					case 34:	printf("LOC = ADDR 18     \r");break;
					case 35:	printf("LOC = ADDR 19     \r");break;
					case 36:	printf("LOC = ADDR 20     \r");break;
					case 37:	printf("LOC = ADDR 21     \r");break;
					case 38:	printf("LOC = ADDR 22     \r");break;
					case 39:	printf("LOC = ADDR 23     \r");break;
					case 40:	printf("LOC = ADDR 24     \r");break;
					case 41:	printf("LOC = ADDR 25     \r");break;
					case 42:	printf("LOC = ADDR 26     \r");break;
					case 43:	printf("LOC = ADDR 27     \r");break;
					case 44:	printf("LOC = ADDR 28     \r");break;
					case 45:	printf("LOC = ADDR 29     \r");break;
					case 46:	printf("LOC = ADDR 30     \r");break;
					case 47:	printf("LOC = ADDR 31     \r");break;
					
					case 48:	printf("LOC = CS          \r");break;
					case 49:	printf("LOC = CSN         \r");break;
					case 50:	printf("LOC = OE          \r");break;
					case 51:	printf("LOC = WE          \r");break;
					case 52:	printf("LOC = RST         \r");break;
				
					default:	printf("LOC = !ERROR!     \r");
				
				}
			}
			else
			{			
				if(meanval < 10000)
				{
					printf("LOC = -GND-       \r");			
				}
				else
				{
					printf("LOC = -----       \r");
				}
			}
			fflush(stdout);
		}
		printf("\n\n## SIGNAL LOCATING STOPPED\n");
	}

	if(dist_test == 1)
	{
		printf("DISTURB TEST\n");
		errc=prg_comm(0xA5,0,32,0,0,0,0,0,0);				//start

		printf(">> DATA LINES\n");
		printf("   %02X%02X (must 0x5555)\n",memory[1],memory[0]);
		printf("   %02X%02X (must 0xAAAA)\n\n",memory[3],memory[2]);

		printf(">> ADDRL LINES\n");
		printf("   %02X%02X (must 0x5555)\n",memory[5],memory[4]);
		printf("   %02X%02X (must 0xAAAA)\n\n",memory[7],memory[6]);

		printf(">> ADDRH LINES\n");
		printf("   %02X%02X (must 0x5555)\n",memory[9],memory[8]);
		printf("   %02X%02X (must 0xAAAA)\n\n",memory[11],memory[10]);

		printf(">> CS LINE\n");
		printf("   %02X%02X (must 0xE000)\n",memory[13],memory[12]);
		printf("   %02X%02X (must 0xF000)\n\n",memory[15],memory[14]);

		printf(">> CSN LINE\n");
		printf("   %02X%02X (must 0xD000)\n",memory[17],memory[16]);
		printf("   %02X%02X (must 0xF000)\n\n",memory[19],memory[18]);

		printf(">> OE LINE\n");
		printf("   %02X%02X (must 0xB000)\n",memory[21],memory[20]);
		printf("   %02X%02X (must 0xF000)\n\n",memory[23],memory[22]);

		printf(">> WE LINE\n");
		printf("   %02X%02X (must 0x7000)\n",memory[25],memory[24]);
		printf("   %02X%02X (must 0xF000)\n\n",memory[27],memory[26]);

		printf(">> RST LINE\n");
		printf("   %02X%02X (must 0xF000)\n",memory[29],memory[28]);
		printf("   %02X%02X (must 0xF200)\n\n",memory[31],memory[30]);
	}	

	if(input_test == 1)
	{
		printf("INPUT TEST\n");
		errc=prg_comm(0xA6,0,32,0,0,3,0,0,0);				//start

		printf(">> DATA LINES\n");
		printf("   %02X%02X (must 0xFFFF)\n",memory[1],memory[0]);
		printf("   %02X%02X (must 0xFFFF)\n\n",memory[3],memory[2]);

		printf(">> ADDRL LINES\n");
		printf("   %02X%02X (must 0xFFFF)\n",memory[5],memory[4]);
		printf("   %02X%02X (must 0xFFFF)\n\n",memory[7],memory[6]);

		printf(">> ADDRH LINES\n");
		printf("   %02X%02X (must 0xFFFF)\n",memory[9],memory[8]);
		printf("   %02X%02X (must 0xFFFF)\n\n",memory[11],memory[10]);

		printf(">> SIGNAL LINES\n");
		printf("   %02X%02X (must 0xF000)\n",memory[13],memory[12]);
		printf("   %02X%02X (must 0xF000)\n\n",memory[15],memory[14]);

	}


	if(read_test==1)
	{
		printf("<< PRESS ENTER TO EXIT >>\n");
		errc=prg_comm(0xA8,0,0,0,0,0,0,0,0);				//start

		while(!(kbhit()))
		{	
			errc=prg_comm(0xA7,0,8,0,0,3,0,0,0);				//start
			if(memory[7] & 0x80) printf("-"); else printf("W");
			if(memory[7] & 0x40) printf("-"); else printf("O");
			if(memory[7] & 0x20) printf("- "); else printf("C ");
			if(memory[7] & 0x10) printf("D "); else printf("- ");
			if(memory[7] & 0x02) printf("-"); else printf("R");
			
			printf("  ADDR= %02X%02X%02X%02X  DATA = %02X%02X\n",memory[5],memory[4],memory[3],memory[2],memory[1],memory[0]);
		}
		printf("\n\n## STOPPED\n");
	}


	if(read_loop==1)
	{
		errc=prg_comm(0xA8,0,0,0,0,0,0,0,0);				//start
		errc=prg_comm(0xA9,0,max_blocksize,0,0,3,0,0,0);		//start

		ltime=0;

		for(i=0;i<4096;i++)
		{	
			printf("%08dns  -> ",ltime);
			ltime+=635;
			if(memory[i*8+7] & 0x80) printf("-"); else printf("W");
			if(memory[i*8+7] & 0x40) printf("-"); else printf("O");
			if(memory[i*8+7] & 0x20) printf("- "); else printf("C ");
			if(memory[i*8+7] & 0x10) printf("D "); else printf("- ");
			if(memory[i*8+7] & 0x02) printf("-"); else printf("R");
			
			printf("  ADDR= %02X%02X%02X%02X  DATA = %02X%02X\n",memory[i*8+5] & 0x7F,memory[i*8+4],memory[i*8+3],memory[i*8+2],memory[i*8+1],memory[i*8+0]);
		}
		printf("\n\n## STOPPED\n");
	}




	errc |= prg_comm(0x11,0,0,0,0,0,0,0,0);					//test exit

	print_test_error(errc);

	return errc;
}







