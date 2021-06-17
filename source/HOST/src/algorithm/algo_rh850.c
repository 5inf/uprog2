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

void print_rh850_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(sync timeout)",errc);
				break;

		case 0x42:	set_error("(no sync at start)",errc);
				break;

		case 0x43:	set_error("(status timeout)",errc);
				break;

		case 0x44:	set_error("(wrong status)",errc);
				break;

		case 0xC1:	set_error("(packet error)",errc);
				break;

		case 0xC2:	set_error("(checksum error)",errc);
				break;

		case 0xC3:	set_error("(flow error)",errc);
				break;

		case 0xD0:	set_error("(address error)",errc);
				break;

		case 0xD1:	set_error("(OSC clock frequency error)",errc);
				break;

		case 0xD2:	set_error("(CPU clock frequency error)",errc);
				break;

		case 0xD5:	set_error("(area error)",errc);
				break;

		case 0xDB:	set_error("(wrong ID error)",errc);
				break;

		case 0xDC:	set_error("(serial programming disabled)",errc);
				break;

		case 0xDA:	set_error("(protection error)",errc);
				break;

		case 0xE0:	set_error("(blank check error)",errc);
				break;

		case 0xE1:	set_error("(erase error)",errc);
				break;

		case 0xE2:	set_error("(write error)",errc);
				break;

		case 0xE3:	set_error("(verify error)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

void showframe_rh850(unsigned long faddr)
{
	int j,flen,sod,ack,csum,etx;
	
	sod=memory[faddr+ROFFSET];
	flen=(memory[faddr+ROFFSET+1] << 8) + memory[faddr+ROFFSET+2];
	ack=memory[faddr+ROFFSET+3];
		
	printf("RH 850 FRAME\n");
	printf("------------------------------------\n");
	printf("SOD = %02X    LEN= %04X    ACK= %02X\n",sod,flen,ack);
	
	for(j=1;j<flen;j++)
	{
		printf("%02X ",memory[faddr+ROFFSET+3+j]);
		if((j % 16) == 0) printf("\n");
	}
	printf("\n");
	csum=memory[faddr+ROFFSET+3+flen];
	etx=memory[faddr+ROFFSET+4+flen];
	printf("CSUM = %02X    ETX= %02X\n\n",csum,etx);
}

unsigned long flashblocks_a[70]={	0x000000,0x002000,0x004000,0x006000,0x008000,0x00A000,0x00C000,0x00E000,
					0x010000,0x018000,0x020000,0x028000,0x030000,0x038000,0x040000,0x048000,
					0x050000,0x058000,0x060000,0x068000,0x070000,0x078000,0x080000,0x088000,
					0x090000,0x098000,0x0A0000,0x0A8000,0x0B0000,0x0B8000,0x0C0000,0x0C8000,
					0x0D0000,0x0D8000,0x0E0000,0x0E8000,0x0F0000,0x0F8000,0x100000,0x108000,

					0x110000,0x118000,0x120000,0x128000,0x130000,0x138000,0x140000,0x148000,
					0x150000,0x158000,0x160000,0x168000,0x170000,0x178000,0x180000,0x188000,
					0x190000,0x198000,0x1A0000,0x1A8000,0x1B0000,0x1B8000,0x1C0000,0x1C8000,
					0x1D0000,0x1D8000,0x1E0000,0x1E8000,0x1F0000,0x1F8000};

unsigned long flashblocks_b[64]={	0x800000,0x808000,0x810000,0x818000,0x820000,0x828000,0x830000,0x838000,
					0x840000,0x848000,0x850000,0x858000,0x860000,0x868000,0x870000,0x878000,
					0x880000,0x888000,0x890000,0x898000,0x8A0000,0x8A8000,0x8B0000,0x8B8000,
					0x8C0000,0x8C8000,0x8D0000,0x8D8000,0x8E0000,0x8E8000,0x8F0000,0x8F8000,
				
					0x900000,0x908000,0x910000,0x918000,0x920000,0x928000,0x930000,0x938000,
					0x940000,0x948000,0x950000,0x958000,0x960000,0x968000,0x970000,0x978000,
					0x980000,0x988000,0x990000,0x998000,0x9A0000,0x9A8000,0x9B0000,0x9B8000,
					0x9C0000,0x9C8000,0x9D0000,0x9D8000,0x9E0000,0x9E8000,0x9F0000,0x9F8000};
					



int prog_rh850(void)
{
//	unsigned long flashblock_a[32];
//	unsigned int flashblocks;
	int errc,blocks,bsize,stmp;
	unsigned long addr,len,maddr,i,j,freq;
	int main_blank=0;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int main_crc=0;
	int dev_start=0;
	int dflash_blank=0;
	int dflash_erase=0;
	int dflash_prog=0;
	int partial_mode=0;	//partial
	int dflash_verify=0;
	int dflash_readout=0;
	int dflash_crc=0;
	int extended_blank=0;
	int extended_erase=0;
	int extended_prog=0;
	int extended_verify=0;
	int extended_readout=0;
	int extended_crc=0;
	int opt_read=0;
	int get_prot=0xff;
	int set_prot=0xff;
	int opt0_write=0;
	int opt1_write=0;
	int opt2_write=0;
	int opt3_write=0;
	int sb_write=0;
	int osc_sel=0;
	float dfreq;
	int verify_mode=0;
	int run_ram=0;
	int set_id=0;
	int prog_id=0;
	int check_id=0;
	int authmode=-1;
	unsigned long p6=0,p7=0;
	unsigned char devtype[16];
	unsigned char idkey[32];
	unsigned char idset[32];
	char hexbyte[4];
	char* parptr;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5v -- use 5V vdd\n");
		printf("-- fr12  12MHz Osc (default 8MHz)\n");
		printf("-- fr16  16MHz Osc (default 8MHz)\n");
		printf("-- fr20  20MHz Osc (default 8MHz)\n");
		printf("-- fr24  24MHz Osc (default 8MHz)\n");
		printf("-- frint internal Osc (default 8MHz crystal)\n");

		printf("-- em -- main flash erase\n");
		printf("-- bm -- main flash blank check\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");
		printf("-- cm -- main flash CRC\n");

		printf("-- ed -- data flash erase\n");
		printf("-- bd -- data flash blank check\n");
		printf("-- pd -- data flash program\n");
		printf("-- vd -- data flash verify\n");
		printf("-- rd -- data flash readout\n");
		printf("-- cd -- data flash CRC\n");
	

		printf("-- ex -- ext user area erase\n");
		printf("-- bx -- ext user area blank check\n");
		printf("-- px -- ext user area program\n");
		printf("-- vx -- ext user area verify\n");
		printf("-- rx -- ext user area readout\n");
		printf("-- cx -- ext user area CRC\n");

		printf("-- ro -- read option bytes\n");
		printf("-- wopt0 write option byte 0\n");
		printf("-- wopt1 write option byte 1\n");
		printf("-- wopt2 write option byte 2\n");
		printf("-- wopt3 write option byte 3\n");
		
		printf("-- gp -- get protection status\n");
		printf("-- nr -- protect readout\n");
		printf("-- nw -- protect write\n");
		printf("-- ne -- protect erase\n");

//		printf("-- rr -- run code in RAM\n");
		printf("-- st -- start device\n");
 		printf("-- d2 -- switch to device 2\n");

		printf("-- cid: -- check ID (16 Bytes hex)\n");
		printf("-- sid: -- set ID without SPIE (16 Bytes hex)\n");
		printf("-- pid: -- program ID with SPIE (16 Bytes hex)\n");

		printf("-- em -- main flash erase\n");

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

	if(find_cmd("fr12"))
	{
		osc_sel=1;		
		printf("## assuming 12 MHz crystal\n");
	}

	if(find_cmd("fr16"))
	{
		osc_sel=2;		
		printf("## assuming 16 MHz crystal\n");
	}

	if(find_cmd("fr20"))
	{
		osc_sel=3;		
		printf("## assuming 20 MHz crystal\n");
	}

	if(find_cmd("fr24"))
	{
		osc_sel=4;		
		printf("## assuming 24 MHz crystal\n");
	}

	if(find_cmd("frint"))
	{
		osc_sel=5;		
		printf("## using internal oscillator\n");
	}

	if(find_cmd("sb"))
	{
		sb_write=1;		
		printf("## write single byte\n");
	}


	if(find_cmd("pt"))
	{
		partial_mode=1;		
		printf("## partial mode\n");
	}

	if(find_cmd("rr"))
	{
		run_ram=1;		
		printf("## run code in RAM (bootstrap)\n");
		goto RH850_INIT;
	}


	if(find_cmd("ro"))
	{
		opt_read=1;
		printf("## Action: read option bytes\n");
	}

	if(find_cmd("wopt0"))
	{
		opt0_write=1;
		printf("## Action: write option byte 0 to 0x%08lX\n",expar & 0xFFFFFFFF);
		goto RH850_INIT;
	}

	if(find_cmd("wopt1"))
	{
		opt1_write=1;
		printf("## Action: write option byte 1 to 0x%08lX\n",expar & 0xFFFFFFFF);
		goto RH850_INIT;
	}
	if(find_cmd("wopt2"))
	{
		opt2_write=1;
		printf("## Action: write option byte 2 to 0x%08lX\n",expar & 0xFFFFFFFF);
		goto RH850_INIT;
	}
	if(find_cmd("wopt3"))
	{
		opt3_write=1;
		printf("## Action: write option byte 3 to 0x%08lX\n",expar & 0xFFFFFFFF);
		goto RH850_INIT;
	}
	
	if(find_cmd("em"))
	{
		main_erase=1;
		printf("## Action: code flash erase\n");
	}

	if(find_cmd("ed"))
	{
		dflash_erase=1;
		printf("## Action: data flash erase\n");
	}

	if(find_cmd("ex"))
	{
		extended_erase=1;
		printf("## Action: extended user area erase\n");
	}

	if(find_cmd("bm"))
	{
		main_blank=1;
		printf("## Action: code flash blank check\n");
	}

	if(find_cmd("bd"))
	{
		dflash_blank=1;
		printf("## Action: data flash blank check\n");
	}

	if(find_cmd("bx"))
	{
		extended_blank=1;
		printf("## Action: extended user area blank check\n");
	}


	if(find_cmd("cm"))
	{
		main_crc=1;
		printf("## Action: code flash CRC calculation\n");
	}


	if(find_cmd("cd"))
	{
		dflash_crc=1;
		printf("## Action: data flash CRC calculation\n");
	}

	if(find_cmd("cx"))
	{
		extended_crc=1;
		printf("## Action: extended user area CRC calculation\n");
	}

	main_prog=check_cmd_prog("pm","code flash");
	dflash_prog=check_cmd_prog("pd","data flash");
	extended_prog=check_cmd_prog("px","extended user area");
	main_verify=check_cmd_verify("vm","code flash");
	dflash_verify=check_cmd_verify("vd","data flash");
	extended_verify=check_cmd_verify("vx","extended user area");

	main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
	dflash_readout=check_cmd_read("rd","data flash",&dflash_prog,&dflash_verify);
	extended_readout=check_cmd_read("rx","extended user area",&extended_prog,&extended_verify);

	if(find_cmd("nr"))
	{
		set_prot &= 0x7F;
		printf("## Action: set readout protection\n");
	}
	if(find_cmd("nw"))
	{
		set_prot &= 0xBF;
		printf("## Action: set write protection\n");
	}

	if(find_cmd("ne"))
	{
		set_prot &= 0xDF;
		printf("## Action: set erase protection\n");
	}

	if(find_cmd("st"))
	{
		dev_start=1;
		printf("## Action: start device\n");
		goto RH850_START;
	}


	if((strstr(cmd,"sid:")) && ((strstr(cmd,"sid:") - cmd) % 2 == 1))
	{
		strcat(cmd,"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");
		parptr=strstr(cmd,"sid:");
		strncpy(&hexbyte[0],parptr + 4 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[0]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 6 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[1]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 8 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[2]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 10 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[3]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 12 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[4]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 14 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[5]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 16 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[6]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 18 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[7]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 20 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[8]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 22 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[9]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 24 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[10]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 26 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[11]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 28 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[12]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 30 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[13]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 32 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[14]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 34 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[15]=stmp & 0xff;
		printf("## Action: set device ID using ");
		for(i=0;i<16;i++) printf("%02X ",idset[i]);
		printf("\n");
		set_id=1;
	}

	if((strstr(cmd,"pid:")) && ((strstr(cmd,"pid:") - cmd) % 2 == 1))
	{
		strcat(cmd,"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");
		parptr=strstr(cmd,"pid:");
		strncpy(&hexbyte[0],parptr + 4 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[0]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 6 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[1]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 8 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[2]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 10 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[3]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 12 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[4]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 14 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[5]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 16 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[6]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 18 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[7]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 20 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[8]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 22 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[9]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 24 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[10]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 26 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[11]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 28 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[12]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 30 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[13]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 32 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[14]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 34 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idset[15]=stmp & 0xff;
		printf("## Action: set device ID (with SPIE) using ");
		for(i=0;i<16;i++) printf("%02X ",idset[i]);
		printf("\n");
		prog_id=1;
	}

	if((strstr(cmd,"cid:")) && ((strstr(cmd,"cid:") - cmd) % 2 == 1))
	{
		strcat(cmd,"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");
		parptr=strstr(cmd,"cid:");
		strncpy(&hexbyte[0],parptr + 4 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[0]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 6 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[1]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 8 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[2]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 10 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[3]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 12 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[4]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 14 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[5]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 16 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[6]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 18 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[7]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 20 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[8]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 22 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[9]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 24 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[10]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 26 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[11]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 28 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[12]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 30 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[13]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 32 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[14]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 34 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);idkey[15]=stmp & 0xff;
		printf("## Action: check device ID using ");
		for(i=0;i<16;i++) printf("%02X ",idkey[i]);
		printf("\n");
		check_id=1;
	}



RH850_INIT:
		
	printf("\n");


	if((main_readout == 1) || (dflash_readout == 1) || (extended_readout == 1))
	{
		errc=writeblock_open();
	}

	printf("INIT DEVICE (%ldms wait time, %ld pulses)\n",param[11] >> 8,param[11] & 0xff);
	if(dev_start == 0)
	{
		errc=prg_comm(0x140,0,0,0,0,0,(param[11] >> 8) & 0xff,param[12],param[11] & 0xff);			//init
		if(errc!=0) goto RH850_END;

		errc=prg_comm(0x144,0,100,0,ROFFSET,0,0,0,0);				//get device info
//		showframe_rh850(0);

		printf(">> TYPE   = ");
		for(i=4;i<11;i++) 
		{
			devtype[i-3]=memory[ROFFSET+i];		// use array from 1..8 
			printf("%02X ",memory[ROFFSET+i]);
		}
		printf("\n");
		
		freq=	(memory[ROFFSET+16] << 24) + 
			(memory[ROFFSET+17] << 16) +
			(memory[ROFFSET+18] << 8) + memory[ROFFSET+19];
		 
		dfreq=freq;
		dfreq=dfreq/1000000;
		printf(">> MIN OSC FREQ = %7.2f MHz\n",dfreq); 

		freq=	(memory[ROFFSET+12] << 24) + 
			(memory[ROFFSET+13] << 16) +
			(memory[ROFFSET+14] << 8) + memory[ROFFSET+15];
			
		dfreq=freq;
		dfreq=dfreq/1000000;
		printf(">> MAX OSC FREQ = %7.2f MHz\n",dfreq);

		freq=	(memory[ROFFSET+24] << 24) + 
			(memory[ROFFSET+25] << 16) +
			(memory[ROFFSET+26] << 8) + memory[ROFFSET+27];
			
		dfreq=freq;
		dfreq=dfreq/1000000;
		printf(">> MIN CPU FREQ = %7.2f MHz\n",dfreq); 
		
		freq=	(memory[ROFFSET+20] << 24) + 
			(memory[ROFFSET+21] << 16) +
			(memory[ROFFSET+22] << 8) + memory[ROFFSET+23];
			
		dfreq=freq;
		dfreq=dfreq/1000000;
		printf(">> MAX CPU FREQ = %7.2f MHz\n",dfreq);

		errc=prg_comm(0x145,0,100,0,ROFFSET,0,0,0,osc_sel+param[17]);				//set frequency
		if(errc!=0) goto RH850_END;
		//showframe_rh850(0);

		freq=	(memory[ROFFSET+4] << 24) + 
			(memory[ROFFSET+5] << 16) +
			(memory[ROFFSET+6] << 8) + memory[ROFFSET+7];
		 
		dfreq=freq;
		dfreq=dfreq/1000000;
		 
		printf(">> DEVICE FREQ  = %7.2f MHz\n",dfreq); 

		freq=	(memory[ROFFSET+8] << 24) + 
			(memory[ROFFSET+9] << 16) +
			(memory[ROFFSET+10] << 8) + memory[ROFFSET+11];

		dfreq=freq;
		dfreq=dfreq/1000000;
			
		printf(">> PERIPH FREQ  = %7.2f MHz\n",dfreq);

		prg_comm(0x143,0,0,0,0,0,0,0,0);					//HS


		errc=prg_comm(0x146,0,100,0,ROFFSET,0,0,0,0);				//Inquiry
		if(errc!=0) goto RH850_END;
		

		errc=prg_comm(0x147,0,100,0,ROFFSET,0,0,0,0);				//ID authmode get
		if(errc!=0) goto RH850_END;
//		showframe_rh850(0);
		switch(memory[ROFFSET+4])
		{
			case 0x00:	printf(">> ID authentication mode\n");
					if(check_id == 1)
					{
						printf(">> UNLOCK WITH ID...");
						for(i=0;i<16;i++) memory[i]=idkey[i];
						errc=prg_comm(0x20A,32,0,0,0,0,0,0,0);	//ID set
						if(errc!=0) 
						{					
							printf("!!! CHECK DEVICE ID FAILED !!!\n");
							goto RH850_END;
						}
						else
						{					
							printf("SUCCESS !\n");
						}
						
					}
					else
					{					
						printf("!!! CHECK DEVICE ID NEEDED !!!\n");
						goto RH850_END;
					}
					break;

			case 0x55:	printf(">> command protection mode (incomplete)\n");
					break;

			case 0xFF:	printf(">> command protection mode\n");
					break;

			default:	printf(">> unsupported mode\n");
		}
		authmode=memory[ROFFSET+4];

		errc=prg_comm(0x148,0,100,0,ROFFSET,0,0,0,0);				//signature
		if(errc!=0)
		{
			errc=memory[ROFFSET+4];
			goto RH850_END;
		}

		printf(">> DEVICE = ");
		for(i=4;i<21;i++) printf("%c",memory[ROFFSET+i]);
		printf("\n");
		

		if(check_id ==1 ) goto RH850_NCHK;
		
/*
		j=6;		
		for(i=0;i<j;i++)
		{
			fbtype=	memory[ROFFSET+20+7*i]; 
		
		
			fbsize=	(memory[ROFFSET+21+7*i] << 24) + 
				(memory[ROFFSET+22+7*i] << 16) +
				(memory[ROFFSET+23+7*i] << 8) + memory[ROFFSET+24+7*i];

			fbnum=	(memory[ROFFSET+25+7*i] << 8) + memory[ROFFSET+26+7*i];
		
			printf(">> FBLOCK %04X ",fbnum);
			switch(fbtype)
			{
				case 0x00:	printf("(code flash) ");
						break;

				case 0x01:	printf("(space)      ");
						break;

				case 0x02:	printf("(user boot)  ");
						break;

				case 0x03:	printf("(data flash) ");
						break;

				default:	printf("(undefined)  ");
			}
			printf(">> SIZE: %08lX\n",fbsize);
		}
*/		

	}

	if(param[13] == 1)
	{
		errc=prg_comm(0x149,0,100,0,ROFFSET,0,0,0,0);				//lockbit enable
		showframe_rh850(0);
		if(errc!=0)
		{
			errc=memory[ROFFSET+4];
			goto RH850_END;
		}
	}

//	waitkey();

	errc=prg_comm(0x15c,0,2,0,ROFFSET,0,0,0,0);				//get prot status
	printf(">> PROT STATUS  = 0x%02X\n",memory[ROFFSET]);
	if(memory[ROFFSET] & 0x80)
		printf("   * READ ENABLED\n");
	else
	{
		printf("   * READ DISABLED\n");
		verify_mode=1;
	}
	if(memory[ROFFSET] & 0x40)
		printf("   * WRITE ENABLED\n");
	else
		printf("   * WRITE DISABLED\n");
	
	if(memory[ROFFSET] & 0x20)
		printf("   * ERASE ENABLED\n");
	else
		printf("   * ERASE DISABLED\n");
		
	get_prot=memory[ROFFSET];


	errc=prg_comm(0x209,0,100,0,ROFFSET,0,0,0,0);				//get ID
	if(errc!=0)
	{
		errc=memory[ROFFSET+4];
		goto RH850_END;
	}
//	showframe_rh850(0);
	printf(">> ID = ");
	for(i=4;i<19;i++) printf("%02X ",memory[ROFFSET+i]);
	printf("\n\n");

RH850_NCHK:


	if((errc == 0) && (dev_start == 0))
	{
		if(opt_read == 1)
		{
			printf("\nOPTION BYTES:\n-------------\n");
			errc=prg_comm(0x14a,0,100,0,ROFFSET,0,0,0,0);				//bcheck
			for(i=0;i<8;i++)
			{
				addr=memory[ROFFSET+4+4*i] | (memory[ROFFSET+5+4*i] << 8) | (memory[ROFFSET+6+4*i] << 16)| (memory[ROFFSET+7+4*i] << 24);
				printf("OPTB%ld = 0x%08lX\n",i,addr);
			}
		
		}
	
		if(opt0_write == 1)
		{
			errc=prg_comm(0x14a,0,100,0,ROFFSET,0,0,0,0);				//bcheck
			printf("\nOLD OPTION BYTES:\n-----------------\n");
			for(i=0;i<8;i++)
			{
				addr=memory[ROFFSET+4+4*i] | (memory[ROFFSET+5+4*i] << 8) | (memory[ROFFSET+6+4*i] << 16)| (memory[ROFFSET+7+4*i] << 24);
				printf("OPTB%ld = 0x%08lX\n",i,addr);
			}
		
			for(i=0;i<32;i++) memory[i]=memory[ROFFSET+i+4];
			
			memory[0]=expar & 0xFF;
			memory[1]=(expar >> 8) & 0xFF;
			memory[2]=(expar >> 16) & 0xFF;
			memory[3]=(expar >> 24) & 0xFF;

			errc=prg_comm(0x14b,40,0,0,0,0,0,0,0);				//bcheck
		
			errc=prg_comm(0x14a,0,100,0,ROFFSET,0,0,0,0);				//bcheck
			printf("\nNEW OPTION BYTES:\n-----------------\n");
			for(i=0;i<8;i++)
			{
				addr=memory[ROFFSET+4+4*i] | (memory[ROFFSET+5+4*i] << 8) | (memory[ROFFSET+6+4*i] << 16)| (memory[ROFFSET+7+4*i] << 24);
				printf("OPTB%ld = 0x%08lX\n",i,addr);
			}
		
		}

		if(opt1_write == 1)
		{
			errc=prg_comm(0x14a,0,100,0,ROFFSET,0,0,0,0);				//bcheck
			printf("\nOLD OPTION BYTES:\n-----------------\n");
			for(i=0;i<8;i++)
			{
				addr=memory[ROFFSET+4+4*i] | (memory[ROFFSET+5+4*i] << 8) | (memory[ROFFSET+6+4*i] << 16)| (memory[ROFFSET+7+4*i] << 24);
				printf("OPTB%ld = 0x%08lX\n",i,addr);
			}
		
			for(i=0;i<32;i++) memory[i]=memory[ROFFSET+i+4];
			
			memory[4]=expar & 0xFF;
			memory[5]=(expar >> 8) & 0xFF;
			memory[6]=(expar >> 16) & 0xFF;
			memory[7]=(expar >> 24) & 0xFF;

			errc=prg_comm(0x14b,40,0,0,0,0,0,0,0);				//bcheck
		
			errc=prg_comm(0x14a,0,100,0,ROFFSET,0,0,0,0);				//bcheck
			printf("\nNEW OPTION BYTES:\n-----------------\n");
			for(i=0;i<8;i++)
			{
				addr=memory[ROFFSET+4+4*i] | (memory[ROFFSET+5+4*i] << 8) | (memory[ROFFSET+6+4*i] << 16)| (memory[ROFFSET+7+4*i] << 24);
				printf("OPTB%ld = 0x%08lX\n",i,addr);
			}
		
		}

		if(opt2_write == 1)
		{
			errc=prg_comm(0x14a,0,100,0,ROFFSET,0,0,0,0);				//bcheck
			printf("\nOLD OPTION BYTES:\n-----------------\n");
			for(i=0;i<8;i++)
			{
				addr=memory[ROFFSET+4+4*i] | (memory[ROFFSET+5+4*i] << 8) | (memory[ROFFSET+6+4*i] << 16)| (memory[ROFFSET+7+4*i] << 24);
				printf("OPTB%ld = 0x%08lX\n",i,addr);
			}
		
			for(i=0;i<32;i++) memory[i]=memory[ROFFSET+i+4];
			
			memory[8]=expar & 0xFF;
			memory[9]=(expar >> 8) & 0xFF;
			memory[10]=(expar >> 16) & 0xFF;
			memory[11]=(expar >> 24) & 0xFF;

			errc=prg_comm(0x14b,40,0,0,0,0,0,0,0);				//bcheck
		
			errc=prg_comm(0x14a,0,100,0,ROFFSET,0,0,0,0);				//bcheck
			printf("\nNEW OPTION BYTES:\n-----------------\n");
			for(i=0;i<8;i++)
			{
				addr=memory[ROFFSET+4+4*i] | (memory[ROFFSET+5+4*i] << 8) | (memory[ROFFSET+6+4*i] << 16)| (memory[ROFFSET+7+4*i] << 24);
				printf("OPTB%ld = 0x%08lX\n",i,addr);
			}
		
		}

		if(opt3_write == 1)
		{
			errc=prg_comm(0x14a,0,100,0,ROFFSET,0,0,0,0);				//bcheck
			printf("\nOLD OPTION BYTES:\n-----------------\n");
			for(i=0;i<8;i++)
			{
				addr=memory[ROFFSET+4+4*i] | (memory[ROFFSET+5+4*i] << 8) | (memory[ROFFSET+6+4*i] << 16)| (memory[ROFFSET+7+4*i] << 24);
				printf("OPTB%ld = 0x%08lX\n",i,addr);
			}
		
			for(i=0;i<32;i++) memory[i]=memory[ROFFSET+i+4];
			
			memory[12]=expar & 0xFF;
			memory[13]=(expar >> 8) & 0xFF;
			memory[14]=(expar >> 16) & 0xFF;
			memory[15]=(expar >> 24) & 0xFF;

			errc=prg_comm(0x14b,40,0,0,0,0,0,0,0);				//bcheck
		
			errc=prg_comm(0x14a,0,100,0,ROFFSET,0,0,0,0);				//bcheck
			printf("\nNEW OPTION BYTES:\n-----------------\n");
			for(i=0;i<8;i++)
			{
				addr=memory[ROFFSET+4+4*i] | (memory[ROFFSET+5+4*i] << 8) | (memory[ROFFSET+6+4*i] << 16)| (memory[ROFFSET+7+4*i] << 24);
				printf("OPTB%ld = 0x%08lX\n",i,addr);
			}
		
		}

//		waitkey();
		
		if((main_erase == 1) && (errc == 0))
		{
			if(param[1] > 0)
			{
				blocks=(param[14] >> 8) & 0xff;
				progress("CFLASH A ERASE ",blocks,0);
				for(i=0;i<blocks;i++)
				{				
					addr=flashblocks_a[i];
					errc=prg_comm(0x151,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
					if(errc > 0) 
					{
						printf("\n Error at addr %08lX\n",addr);
						goto RH850_END;
					}
					progress("CFLASH A ERASE ",blocks,i+1);
				}
				printf("\n");
			}

			if(param[3] > 0)
			{
				blocks=(param[14]) & 0xff;
				progress("CFLASH B ERASE ",blocks,0);
				for(i=0;i<blocks;i++)
				{				
					addr=flashblocks_b[i];
					errc=prg_comm(0x151,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
					if(errc > 0) goto RH850_END;
					progress("CFLASH B ERASE ",blocks,i+1);
				}
				printf("\n");
			}
		}

		if((dflash_erase == 1) && (errc == 0))
		{
			if(param[7] > 0)
			{
				blocks=param[15]/32;
				addr=param[6];

				progress("DFLASH ERASE   ",blocks,0);
				for(i=0;i<blocks;i++)
				{				
					errc=prg_comm(0x157,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
					if(errc > 0) 
					{
						printf("\n Error at addr %08lX\n",addr);
						goto RH850_END;
					}
					addr+=1024;
					progress("DFLASH ERASE   ",blocks,i+1);
				}
				printf("\n");
			}
		}

		if((extended_erase == 1) && (errc == 0))
		{
			if(param[5] > 0)
			{
				printf("EXTENDED FLASH ERASE ...");
				addr=param[4];
				errc=prg_comm(0x151,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				if(errc==0)
				{
					printf("OK\n");		
				}
				else
				{
					printf("!! ERROR !!\n");
					goto RH850_END;
				}		
				printf("\n");
			}
		}

		if((main_blank == 1) && (errc == 0))
		{
			if(param[1] > 0)
			{
				printf("BLANK CHECK CODE FLASH BANK A ");
				addr=param[0];
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[0]+param[1]-1;
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x150,0,100,0,ROFFSET,0,0,0,0);				//bcheck
//				showframe_rh850(0);
				if(memory[ROFFSET+3]==0x10)
				{
					printf("...BLANK\n");		
				}
				else
				{
					switch(memory[ROFFSET+4])
					{
						case 0xe0:	printf(">> NOT BLANK\n");
								break;

						case 0xDA:	printf("!! PROTECTION ERROR\n");
								break;
													
						default:	printf("!! ERROR %02X\n",memory[ROFFSET+4]);
					}
				}		
			}

			if(param[3] > 0)
			{
				printf("BLANK CHECK CODE FLASH BANK B ");
				addr=param[2];
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[2]+param[3]-1;
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x150,0,100,0,ROFFSET,0,0,0,0);				//bcheck
//				showframe_rh850(0);
				if(memory[ROFFSET+3]==0x10)
				{
					printf("...BLANK\n");		
				}
				else
				{
					switch(memory[ROFFSET+4])
					{
						case 0xe0:	printf(">> NOT BLANK\n");
								break;

						case 0xda:	printf("!! PROTECTION ERROR\n");
								break;
													
						default:	printf("!! ERROR %02X\n",memory[ROFFSET+4]);
					}
				}		
			}
		}

		if((dflash_blank == 1) && (errc == 0))
		{
			printf("BLANK CHECK DATA FLASH        ");
			if(param[7] > 0)
			{
				addr=param[6];
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[6]+param[7]-1;
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x150,0,100,0,ROFFSET,0,0,0,0);				//bcheck
//				showframe_rh850(0);
				if(memory[ROFFSET+3]==0x10)
				{
					printf("...BLANK\n");		
				}
				else
				{
					switch(memory[ROFFSET+4])
					{
						case 0xe0:	printf(">> NOT BLANK\n");
								break;

						case 0xda:	printf("!! PROTECTION ERROR\n");
								break;
													
						default:	printf("!! ERROR %02X\n",memory[ROFFSET+4]);
					}
				}		
			}
		}

		if((extended_blank == 1) && (errc == 0))
		{
			printf("BLANK CHECK EXTENDED FLASH    ");
			if(param[5] > 0)
			{
				addr=param[4];
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[4]+param[5]-1;
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x150,0,100,0,ROFFSET,0,0,0,0);				//bcheck
//				showframe_rh850(0);
				if(memory[ROFFSET+3]==0x10)
				{
					printf("...BLANK\n");		
				}
				else
				{
					switch(memory[ROFFSET+4])
					{
						case 0xe0:	printf(">> NOT BLANK\n");
								break;

						case 0xeb:	printf("!! PROTECTION ERROR\n");
								break;
													
						default:	printf("!! ERROR %02X\n",memory[ROFFSET+4]);
					}
				}		
			}
		}

		if(partial_mode == 1) param[1]-=256;

		if((main_prog == 1) && (errc == 0))
		{
			if(param[1] > 0)
			{ 
				read_block(param[0],param[1],0);	//bank A
				addr=param[0];
				bsize=1024;
				blocks=param[1] / bsize;
				maddr=0;
		
			
				addr=param[0];
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[0]+param[1]-1;
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x152,0,100,0,ROFFSET,0,0,0x13,0);				//prepare prog

				progress("CFLASH A PROG ",blocks,0);
				if(blocks > 1)
				for(i=1;i<blocks;i++)
				{
					errc=prg_comm(0x153,bsize,0,maddr,0,0,0,0x13,0x17);
					if(errc > 0) 
					{
						printf("\n Error at addr %08lX\n",addr);
						goto RH850_END;
					}

					addr+=bsize;
					maddr+=bsize;
					progress("CFLASH A PROG ",blocks,i+1);					
				}
				errc=prg_comm(0x153,bsize,0,maddr,0,0,0,0x13,0x03);
				printf("\n");
			}

			if(param[3] > 0)
			{ 
				read_block(param[2],param[3],0);	//bank B
				addr=param[2];
				bsize=1024;
				blocks=param[3] / bsize;
				maddr=0;

				addr=param[2];
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[2]+param[3]-1;
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x152,0,100,0,ROFFSET,0,0,0x13,0);				//bcheck

				progress("CFLASH B PROG ",blocks,0);
				for(i=1;i<blocks;i++)
				{
					errc=prg_comm(0x153,bsize,0,maddr,0,0,0,0x13,0x17);
					if(errc > 0) 
					{
						printf("\n Error at addr %08lX\n",addr);
						goto RH850_END;
					}
					addr+=bsize;
					maddr+=bsize;
					progress("CFLASH B PROG ",blocks,i+1);					
				}
				errc=prg_comm(0x153,bsize,0,maddr,0,0,0,0x13,0x03);
				printf("\n");
			}
		}
		
		if(partial_mode == 1)
		{
			p6=param[6];
			p7=param[7];
			param[6]=0xFF20FD80;
			param[7]=144;
		}

		if((dflash_prog == 1) && (errc == 0) && (param[7]>0))
		{
			read_block(param[6],param[7],0);	//DFLASH
			addr=param[6];
			bsize=1024;
			blocks=param[7] / bsize;
			maddr=0;

//			show_data(0,16);
			
//			waitkey();

			addr=param[6];
			errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			addr=param[6]+param[7]-1;
			errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			errc=prg_comm(0x152,0,100,0,ROFFSET,0,0,0x13,0);				//prog

			if(partial_mode == 1)
			{
				errc=prg_comm(0x158,bsize,0,maddr,0,144,0,0x13,0x03);
				progress("DFLASH PROG   ",1,1);
				goto nbx;
			}
			

			progress("DFLASH PROG   ",blocks,0);

			for(i=1;i<blocks;i++)
			{
				errc=prg_comm(0x153,bsize,0,maddr,0,0,0,0x13,0x17);

				if(errc > 0) 
				{
					printf("\n Error at addr %08lX\n",addr);
					goto RH850_END;
				}
				addr+=bsize;
				maddr+=bsize;
				progress("DFLASH PROG   ",blocks,i+1);					
			}
			errc=prg_comm(0x153,bsize,0,maddr,0,0,0,0x13,0x03);
nbx:
			printf("\n");
		}


		if(partial_mode == 1)
		{
			param[6]=p6;
			param[7]=p7;
		}

		if((extended_prog == 1) && (errc == 0) && (param[5]>0))
		{
			read_block(param[4],param[5],0);	//EXTFLASH
			addr=param[4];
			bsize=1024;
			blocks=param[5] / bsize;
			maddr=0;

			addr=param[4];
			errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			addr=param[4]+param[5]-1;
			errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			errc=prg_comm(0x152,0,100,0,ROFFSET,0,0,0x13,0);				//bcheck


			progress("EXTFLASH PROG ",blocks,0);
			for(i=1;i<blocks;i++)
			{
				errc=prg_comm(0x153,bsize,0,maddr,0,0,0,0x13,0x17);
				if(errc > 0) 
				{
					printf("\n Error at addr %08lX\n",addr);
					goto RH850_END;
				}
				addr+=bsize;
				maddr+=bsize;
				progress("EXTFLASH PROG ",blocks,i+1);					
			}
			errc=prg_comm(0x153,bsize,0,maddr,0,0,0,0x13,0x03);
			printf("\n");

		}



		if((verify_mode == 0) && (main_verify == 1) && (errc == 0))
		{
			if(param[1] > 0)
			{ 
				addr=param[0];
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[0]+param[1]-1;
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x155,0,100,0,ROFFSET,0,0,0,0);				//prepare read
			
				addr=param[0];
				bsize=2048;
				blocks=param[1] / bsize;
				maddr=0;
				progress("CFLASH A READ ",blocks,0);
				for(i=0;i<blocks;i++)
				{
					errc=prg_comm(0x156,0,bsize,0,ROFFSET+maddr,0,0,0,0);
					if(errc > 0) 
					{
						printf("\n Error at addr %08lX\n",addr);
						goto RH850_END;
					}
					addr+=bsize;
					maddr+=bsize;
					progress("CFLASH A READ ",blocks,i+1);
				}
				printf("\n");


				if(errc == 0)
				{
					read_block(param[0],param[1],0);
					addr = param[0];
					len = param[1];
					i=0;
					printf("CFLASH A VERIFY\n");
					for(j=0;j<len;j++)
					{
						if(memory[j] != memory[j+ROFFSET])
						{
							printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
								addr+j,memory[j],memory[j+ROFFSET]);
							errc=1;
						}
					}
				}
			}

			if(param[3] > 0)
			{ 
				addr=param[2];
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[2]+param[3]-1;
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x155,0,100,0,ROFFSET,0,0,0,0);				//prepare read
			
				addr=param[2];
				bsize=2048;
				blocks=param[3] / bsize;
				maddr=0;
				progress("CFLASH B READ ",blocks,0);
				for(i=0;i<blocks;i++)
				{
					errc=prg_comm(0x156,0,bsize,0,ROFFSET+maddr,0,0,0,0);
					if(errc > 0) 
					{
						printf("\n Error at addr %08lX\n",addr);
						goto RH850_END;
					}
					addr+=bsize;
					maddr+=bsize;
					progress("CFLASH B READ ",blocks,i+1);
				}
				printf("\n");

				if(errc == 0)
				{
					read_block(param[2],param[3],0);
					addr = param[2];
					len = param[3];
					i=0;
					printf("CFLASH B VERIFY\n");
					for(j=0;j<len;j++)
					{
						if(memory[j] != memory[j+ROFFSET])
						{
							printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
								addr+j,memory[j],memory[j+ROFFSET]);
							errc=1;
						}
					}
				}
			}	
		}


		if((verify_mode == 0) && (extended_verify == 1) && (errc == 0) && (param[5]>0))
		{
			addr=param[4];
			errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			addr=param[4]+param[5]-1;
			errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			errc=prg_comm(0x155,0,100,0,ROFFSET,0,0,0,0);				//prepare read

			addr=param[4];
			bsize=2048;
			blocks=param[5] / bsize;
			maddr=0;
			progress("EXTFLASH READ ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				errc=prg_comm(0x156,0,bsize,0,ROFFSET+maddr,0,0,0,0);
				if(errc > 0) 
				{
					printf("\n Error at addr %08lX\n",addr);
					goto RH850_END;
				}
				addr+=bsize;
				maddr+=bsize;
				progress("EXTFLASH READ ",blocks,i+1);
			}
			printf("\n");

			//verify extended
			if(errc == 0)
			{
				read_block(param[4],param[5],0);
				addr = param[4];
				len = param[5];
				i=0;
				printf("EXTEND VERIFY\n");
				for(j=0;j<len;j++)
				{
					if(memory[j] != memory[j+ROFFSET])
					{
						printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
							addr+j,memory[j],memory[j+ROFFSET]);
						errc=1;
					}
				}
			}
		}

		if((verify_mode == 0) && (dflash_verify == 1) && (errc == 0) && (param[7]>0))
		{
//			waitkey();
			addr=param[6];
			errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			addr=param[6]+param[7]-1;
			errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			errc=prg_comm(0x155,0,100,0,ROFFSET,0,0,0,0);				//prepare read

			addr=param[6];
			bsize=2048;
			blocks=param[7] / bsize;
			maddr=0;
			progress("DFLASH READ   ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				errc=prg_comm(0x156,0,bsize,0,ROFFSET+maddr,0,0,0,0);
				if(errc > 0) 
				{
					printf("\n Error at addr %08lX\n",addr);
					goto RH850_END;
				}
				addr+=bsize;
				maddr+=bsize;
				progress("DFLASH READ   ",blocks,i+1);
			}
			printf("\n");

			//verify dflash
			if(errc == 0)
			{
				read_block(param[6],param[7],0);
				addr = param[6];
				len = param[7];
				i=0;
				printf("DFLASH VERIFY\n");
				for(j=0;j<len;j++)
				{
					if(memory[j] != memory[j+ROFFSET])
					{
						printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
							addr+j,memory[j],memory[j+ROFFSET]);
						errc=1;
					}
				}
			}
		
		}
		


		if((verify_mode == 1) && (main_verify == 1) && (errc == 0))
		{
			if(param[1] > 0)
			{ 
				read_block(param[0],param[1],0);	//bank A
				addr=param[0];
				bsize=1024;
				blocks=param[1] / bsize;
				maddr=0;

				addr=param[0];
	//			printf("Start = %08lx\n",addr);
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[0]+param[1]-1;
	//			printf("End = %08lx\n",addr);
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x20e,0,100,0,ROFFSET,0,0,0x16,0);				//verify

				progress("CFLASH A VERIFY ",blocks,0);
				if(blocks > 1)
				for(i=1;i<blocks;i++)
				{
					errc=prg_comm(0x20f,bsize,0,maddr,0,0,0,0x16,0x17);
					if(errc > 0) 
					{
						printf("\n Error at addr %08lX\n",addr);
						goto RH850_END;
					}

					addr+=bsize;
					maddr+=bsize;
					progress("CFLASH A VERIFY ",blocks,i+1);					
				}
				errc=prg_comm(0x20f,bsize,0,maddr,0,0,0,0x16,0x03);
				printf("\n");
			}

			if(param[3] > 0)
			{ 
				read_block(param[2],param[3],0);	//bank B
				addr=param[2];
				bsize=1024;
				blocks=param[3] / bsize;
				maddr=0;

				addr=param[2];
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[2]+param[3]-1;
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x20e,0,100,0,ROFFSET,0,0,0x16,0);				//verify

				progress("CFLASH B VERIFY ",blocks,0);
				for(i=1;i<blocks;i++)
				{
					errc=prg_comm(0x20f,bsize,0,maddr,0,0,0,0x16,0x17);
					if(errc > 0) 
					{
						printf("\n Error at addr %08lX\n",addr);
						goto RH850_END;
					}
					addr+=bsize;
					maddr+=bsize;
					progress("CFLASH B VERIFY ",blocks,i+1);					
				}
				errc=prg_comm(0x20f,bsize,0,maddr,0,0,0,0x16,0x03);
				printf("\n");
			}
		}

		if((verify_mode == 1) && (dflash_verify == 1) && (errc == 0) && (param[7]>0))
		{
			read_block(param[6],param[7],0);	//DFLASH
			addr=param[6];
			bsize=1024;
			blocks=param[7] / bsize;
			maddr=0;

			addr=param[6];
			errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			addr=param[6]+param[7]-1;
			errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			errc=prg_comm(0x20e,0,100,0,ROFFSET,0,0,0x16,0);				//verify

			progress("DFLASH VERIFY   ",blocks,0);
			for(i=1;i<blocks;i++)
			{
				errc=prg_comm(0x20f,bsize,0,maddr,0,0,0,0x16,0x17);
				if(errc > 0) 
				{
					printf("\n Error at addr %08lX\n",addr);
					goto RH850_END;
				}
				addr+=bsize;
				maddr+=bsize;
				progress("DFLASH VERIFY   ",blocks,i+1);					
			}
			errc=prg_comm(0x20f,bsize,0,maddr,0,0,0,0x16,0x03);
			printf("\n");
		}

		if((verify_mode == 1) && (extended_verify == 1) && (errc == 0) && (param[5]>0))
		{
			read_block(param[4],param[5],0);	//EXTFLASH
			addr=param[4];
			bsize=1024;
			blocks=param[5] / bsize;
			maddr=0;

			addr=param[4];
			errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			addr=param[4]+param[5]-1;
			errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			errc=prg_comm(0x20e,0,100,0,ROFFSET,0,0,0x16,0);				//bcheck

			progress("EXTFLASH VERIFY ",blocks,0);
			for(i=1;i<blocks;i++)
			{
				errc=prg_comm(0x20f,bsize,0,maddr,0,0,0,0x16,0x17);
				if(errc > 0) 
				{
					printf("\n Error at addr %08lX\n",addr);
					goto RH850_END;
				}
				addr+=bsize;
				maddr+=bsize;
				progress("EXTFLASH VERIFY ",blocks,i+1);					
			}
			errc=prg_comm(0x20f,bsize,0,maddr,0,0,0,0x16,0x03);
			printf("\n");
		}


		if((main_readout == 1) && (errc == 0))
		{
			if(param[1] > 0)
			{ 
				addr=param[0];
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[0]+param[1]-1;
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x155,0,100,0,ROFFSET,0,0,0,0);				//prepare read
			
				addr=param[0];
				bsize=2048;
				blocks=param[1] / bsize;
				maddr=0;
				progress("CFLASH A READ ",blocks,0);
				for(i=0;i<blocks;i++)
				{
					errc=prg_comm(0x156,0,bsize,0,ROFFSET+maddr,0,0,0,0);
					if(errc > 0) 
					{
						printf("\n Error at addr %08lX\n",addr);
						goto RH850_END;
					}
					addr+=bsize;
					maddr+=bsize;
					progress("CFLASH A READ ",blocks,i+1);
				}
				printf("\n");

				writeblock_data(0,param[1],param[0]);
			}

			if(param[3] > 0)
			{ 
				addr=param[2];
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				addr=param[2]+param[3]-1;
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
				errc=prg_comm(0x155,0,100,0,ROFFSET,0,0,0,0);				//prepare read
			
				addr=param[2];
				bsize=2048;
				blocks=param[3] / bsize;
				maddr=0;
				progress("CFLASH B READ ",blocks,0);
				for(i=0;i<blocks;i++)
				{
					errc=prg_comm(0x156,0,bsize,0,ROFFSET+maddr,0,0,0,0);
					if(errc > 0) 
					{
						printf("\n Error at addr %08lX\n",addr);
						goto RH850_END;
					}
					addr+=bsize;
					maddr+=bsize;
					progress("CFLASH B READ ",blocks,i+1);
				}
				printf("\n");
				writeblock_data(0,param[3],param[2]);
			}	
		}


		if((extended_readout == 1) && (errc == 0) && (param[5]>0))
		{
			addr=param[4];
			errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			addr=param[4]+param[5]-1;
			errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			errc=prg_comm(0x155,0,100,0,ROFFSET,0,0,0,0);				//prepare read

			addr=param[4];
			bsize=2048;
			blocks=param[5] / bsize;
			maddr=0;
			progress("EXTFLASH READ ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				errc=prg_comm(0x156,0,bsize,0,ROFFSET+maddr,0,0,0,0);
				if(errc > 0) 
				{
					printf("\n Error at addr %08lX\n",addr);
					goto RH850_END;
				}
				addr+=bsize;
				maddr+=bsize;
				progress("EXTFLASH READ ",blocks,i+1);
			}
			printf("\n");
			writeblock_data(0,param[5],param[4]);
		}

		if((run_ram == 1) && (errc == 0) && (param[9]>0))
		{
			len=read_block(param[8],param[9],0);	//DFLASH
			len=(len+1023) & 0xFC00;

			addr=param[8];
			bsize=1024;
			blocks=len / bsize;
			maddr=0;

			addr=param[8];
			printf("Start = %08lx\n",addr);
				errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			addr=len;
			printf("LEN   = %08lx  Blocks=%d\n",addr,blocks);
				errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			errc=prg_comm(0x20c,0,100,0,ROFFSET,0,0,0x3F,0);				//bootstrap
			addr=param[8];

			if(errc > 0) 
			{
				printf("\n Error: NOT SUPPORTED\n");
				goto RH850_END;
			}

			progress("TRANSFER CODE",blocks,0);
			for(i=1;i<blocks;i++)
			{
				errc=prg_comm(0x20d,bsize,0,maddr,0,0,0,0x3F,0x17);
				if(errc > 0) 
				{
					printf("\n Error at addr %08lX\n",addr);
					goto RH850_END;
				}
				addr+=bsize;
				maddr+=bsize;
				progress("TRANSFER CODE",blocks,i+1);					
			}
			errc=prg_comm(0x20d,bsize,0,maddr,0,0,0,0x3F,0x03);
			if(errc > 0) 
			{
				printf("\n Error at addr %08lX\n",addr);
				goto RH850_END;
			}
			printf("\n");
			
			if(errc==0) waitkey();

			goto RH850_END;

		}



		if((sb_write == 1) && (errc == 0))
		{
			waitkey();
			addr=0xFF200000;
			memory[0]=0xAA;
			memory[1]=0x11;
			memory[2]=0x22;
			memory[3]=0x33;

//			errc=prg_comm(0x159,0,0,0,0,0,0,0,0x20);

			errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			addr+=1;
			errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			errc=prg_comm(0x152,0,100,0,ROFFSET,0,0,0,0);				//prog
			errc=prg_comm(0x158,4,0,0,0,4,0,0,0x03);

			printf("\n");
		}



		if((dflash_readout == 1) && (errc == 0) && (param[7]>0))
		{
//			waitkey();
			addr=param[6];
			errc=prg_comm(0x14e,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			addr=param[6]+param[7]-1;
			errc=prg_comm(0x14f,0,0,0,0,(addr & 0xff),(addr>>8) & 0xff,(addr>>16) & 0xff,(addr >> 24) & 0xff);
			errc=prg_comm(0x155,0,100,0,ROFFSET,0,0,0,0);				//prepare read

			addr=param[6];
			bsize=2048;
			blocks=param[7] / bsize;
			maddr=0;
			progress("DFLASH READ   ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				errc=prg_comm(0x156,0,bsize,0,ROFFSET+maddr,0,0,0,0);
				if(errc > 0) 
				{
					printf("\n Error at addr %08lX\n",addr);
					goto RH850_END;
				}
				addr+=bsize;
				maddr+=bsize;
				progress("DFLASH READ   ",blocks,i+1);
			}
			printf("\n");

			if(partial_mode == 1)
			{
				writeblock_data(0xFD80,144,0xFF20FD80);
			}
			else
			{
				writeblock_data(0,param[7],param[6]);
			}
		}
	}		
		
		
		
	if((main_readout == 1) || (dflash_readout == 1) || (extended_readout == 1))
	{
		i=writeblock_close();
	}

	if(main_crc==1)
	{
		addr=param[0];
		memory[0]=(addr>>24) & 0xff;
		memory[1]=(addr>>16) & 0xff;
		memory[2]=(addr>>8) & 0xff;
		memory[3]=addr & 0xff;

		addr=param[0]+param[1]-1;
		memory[4]=(addr>>24) & 0xff;
		memory[5]=(addr>>16) & 0xff;
		memory[6]=(addr>>8) & 0xff;
		memory[7]=addr & 0xff;
		
		errc=prg_comm(0x14c,8,16,0,ROFFSET,0,0,0,0);
		addr=(memory[ROFFSET+4] << 24) | (memory[ROFFSET+5] << 16) | (memory[ROFFSET+6] << 8) | memory[ROFFSET+7];		
		printf("CRC BANK A = 0x%08lX\n",addr & 0xFFFFFFFF);
//		showframe_rh850(0);
	
		if(param[2] != 0)
		{
			addr=param[2];
			memory[0]=(addr>>24) & 0xff;
			memory[1]=(addr>>16) & 0xff;
			memory[2]=(addr>>8) & 0xff;
			memory[3]=addr & 0xff;

			addr=param[2]+param[3]-1;
			memory[4]=(addr>>24) & 0xff;
			memory[5]=(addr>>16) & 0xff;
			memory[6]=(addr>>8) & 0xff;
			memory[7]=addr & 0xff;
		
			errc=prg_comm(0x14c,8,16,0,ROFFSET,0,0,0,0);
			addr=(memory[ROFFSET+4] << 24) | (memory[ROFFSET+5] << 16) | (memory[ROFFSET+6] << 8) | memory[ROFFSET+7];		
			printf("CRC BANK B = 0x%08lX\n",addr & 0xFFFFFFFF);
//			showframe_rh850(0);
		
		}

	}

	if((extended_crc==1) && (param[4] != 0))
	{
		addr=param[4];
		memory[0]=(addr>>24) & 0xff;
		memory[1]=(addr>>16) & 0xff;
		memory[2]=(addr>>8) & 0xff;
		memory[3]=addr & 0xff;

		addr=param[4]+param[5]-1;
		memory[4]=(addr>>24) & 0xff;
		memory[5]=(addr>>16) & 0xff;
		memory[6]=(addr>>8) & 0xff;
		memory[7]=addr & 0xff;
		
		errc=prg_comm(0x14c,8,16,0,ROFFSET,0,0,0,0);
		addr=(memory[ROFFSET+4] << 24) | (memory[ROFFSET+5] << 16) | (memory[ROFFSET+6] << 8) | memory[ROFFSET+7];		
		printf("CRC EXTEND = 0x%08lX\n",addr & 0xFFFFFFFF);
//		showframe_rh850(0);
	}

	if((dflash_crc==1) && (param[6] != 0))
	{
		addr=param[6];
		memory[0]=(addr>>24) & 0xff;
		memory[1]=(addr>>16) & 0xff;
		memory[2]=(addr>>8) & 0xff;
		memory[3]=addr & 0xff;

		addr=param[6]+param[7]-1;
		memory[4]=(addr>>24) & 0xff;
		memory[5]=(addr>>16) & 0xff;
		memory[6]=(addr>>8) & 0xff;
		memory[7]=addr & 0xff;
		
		errc=prg_comm(0x14c,8,16,0,ROFFSET,0,0,0,0);
		addr=(memory[ROFFSET+4] << 24) | (memory[ROFFSET+5] << 16) | (memory[ROFFSET+6] << 8) | memory[ROFFSET+7];		
		printf("CRC DFLASH = 0x%08lX\n",addr & 0xFFFFFFFF);
//		showframe_rh850(0);
	}

	if((set_prot != 0xff) & (errc == 0))
	{
		printf("SET PROTECTION TO 0x%02X\n",(set_prot & get_prot));
		errc=prg_comm(0x159,0,0,0,0,0,0,0,(set_prot & get_prot));
	}	

	if((set_id == 1) & (errc == 0))
	{
		printf("SET DEVICE ID WITHOUT SPIE\n");
		for(i=0;i<16;i++) memory[i]=idset[i];
		errc=prg_comm(0x20B,16,32,0,ROFFSET,0,0,0,0);	//ID set
		if(memory[ROFFSET+3] != 0x2A)
		{
			errc=memory[ROFFSET+4];
			goto RH850_END;
		}

		if(authmode != 0)
		{
			errc=prg_comm(0x209,0,100,0,ROFFSET,0,0,0,0);				//get ID
			if(errc!=0) 
			{
				printf("GET DEVICE ID FAILED\n\n");
				errc=memory[ROFFSET+4];
			}
			else
			{
				printf("GET DEVICE ID = ");
				for(i=4;i<20;i++) printf("%02X ",memory[ROFFSET+i]);
				printf("\n\n");
			}
		}
	}	



	if((prog_id == 1) & (errc == 0))
	{
		printf("SET DEVICE ID WITH SPIE\n");
		for(i=0;i<16;i++) memory[i]=idset[i];
		errc=prg_comm(0x208,32,32,0,ROFFSET,0,0,0,0);	//ID set
		if(memory[ROFFSET+3] != 0x28)
		{
			errc=memory[ROFFSET+4];
			goto RH850_END;
		}

		if(authmode != 0)
		{
			errc=prg_comm(0x209,0,100,0,ROFFSET,0,0,0,0);				//get ID
			if(errc!=0) 
			{
				printf("GET DEVICE ID FAILED\n\n");
				errc=memory[ROFFSET+4];
			}
			else
			{
				printf("GET DEVICE ID = ");
				for(i=4;i<20;i++) printf("%02X ",memory[ROFFSET+i]);
				printf("\n\n");
			}
		}
	}	



RH850_START:


	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);		//init
		if(have_expar == 1)
		{
			return 0;
		}
		else
		{
			waitkey();					//exit
		}
	}
	
RH850_END:

	i=prg_comm(0x0f,0,0,0,0,0,0,0,0);			//exit


	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_rh850_error(errc);
	return errc;
}





