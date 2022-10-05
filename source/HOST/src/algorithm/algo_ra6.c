//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2012-2022 Joerg Wolfram (joerg@jcwolfram.de)			#
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

unsigned long flashblocks[134]={	0x000000,0x002000,0x004000,0x006000,0x008000,0x00A000,0x00C000,0x00E000,
					0x010000,0x018000,0x020000,0x028000,0x030000,0x038000,0x040000,0x048000,
					0x050000,0x058000,0x060000,0x068000,0x070000,0x078000,0x080000,0x088000,
					0x090000,0x098000,0x0A0000,0x0A8000,0x0B0000,0x0B8000,0x0C0000,0x0C8000,
					0x0D0000,0x0D8000,0x0E0000,0x0E8000,0x0F0000,0x0F8000,0x100000,0x108000,

					0x110000,0x118000,0x120000,0x128000,0x130000,0x138000,0x140000,0x148000,
					0x150000,0x158000,0x160000,0x168000,0x170000,0x178000,0x180000,0x188000,
					0x190000,0x198000,0x1A0000,0x1A8000,0x1B0000,0x1B8000,0x1C0000,0x1C8000,
					0x1D0000,0x1D8000,0x1E0000,0x1E8000,0x1F0000,0x1F8000,
					
					0x200000,0x208000,0x210000,0x218000,0x220000,0x228000,0x230000,0x238000,
					0x240000,0x248000,0x250000,0x258000,0x260000,0x268000,0x270000,0x278000,
					0x280000,0x288000,0x290000,0x298000,0x2A0000,0x2A8000,0x2B0000,0x2B8000,
					0x2C0000,0x2C8000,0x2D0000,0x2D8000,0x2E0000,0x2E8000,0x2F0000,0x2F8000,

					0x300000,0x308000,0x310000,0x318000,0x320000,0x328000,0x330000,0x338000,
					0x340000,0x348000,0x350000,0x358000,0x360000,0x368000,0x370000,0x378000,
					0x380000,0x388000,0x390000,0x398000,0x3A0000,0x3A8000,0x3B0000,0x3B8000,
					0x3C0000,0x3C8000,0x3D0000,0x3D8000,0x3E0000,0x3E8000,0x3F0000,0x3F8000};


void print_ra6_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x01:	set_error("(wrong CMD)",errc);
				break;

		case 0x41:	set_error("(timeout: no ACK)",errc);
				break;

		case 0x42:	set_error("(timeout: prog/erase)",errc);
				break;

		case 0x43:	set_error("(authentication failed)",errc);
				break;

		case 0x50:	set_error("(wrong ID)",errc);
				break;

		case 0x60:	set_error("(Write Protection Error)",errc);
				break;

		case 0x61:	set_error("(Erase timeout error)",errc);
				break;



		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

void ra6_set32(void)
{
	int i;
	
	i=0;
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits
	prg_comm(0x9d,i,0,0,ROFFSET,0,0,2,i/5);
}



void ra6_showreg32(unsigned long addr,char* rtext)
{
	int i;
	
	i=0;
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits
	prg_comm(0x9d,i,0,0,ROFFSET,0,0,2,i/5);


	memory[ROFFSET]=1;
	prg_comm(0x23c,1,4,ROFFSET,ROFFSET,		//read 4 bytes
			(addr >> 0) & 0xff,
			(addr >> 8) & 0xff,
			(addr >> 16) & 0xff,
			(addr >> 24) & 0xff);
	
	printf("%s: %02X%02X%02X%02X\n",rtext,memory[ROFFSET+3],memory[ROFFSET+2],memory[ROFFSET+1],memory[ROFFSET+0]);
}

void ra6_showreg16(unsigned long addr,char* rtext)
{
	int i;
	
	i=0;
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x01;		//DBG access enable, 16bits
	prg_comm(0x9d,i,0,0,ROFFSET,0,0,2,i/5);

	memory[ROFFSET]=1;
	prg_comm(0x23c,1,4,ROFFSET,ROFFSET,		//read 4 bytes
			(addr >> 0) & 0xff,
			(addr >> 8) & 0xff,
			(addr >> 16) & 0xff,
			(addr >> 24) & 0xff);

	if(addr & 2)
		printf("%s: %02X%02X\n",rtext,memory[ROFFSET+3],memory[ROFFSET+2]);
	else
		printf("%s: %02X%02X\n",rtext,memory[ROFFSET+1],memory[ROFFSET+0]);
}


void ra6_showreg08(unsigned long addr,char* rtext)
{
	int i;
	
	i=0;
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//DBG access enable, 8bits
	prg_comm(0x9d,i,0,0,ROFFSET,0,0,2,i/5);

	memory[ROFFSET]=1;
	prg_comm(0x23c,1,4,ROFFSET,ROFFSET,		//read 4 bytes
			(addr >> 0) & 0xff,
			(addr >> 8) & 0xff,
			(addr >> 16) & 0xff,
			(addr >> 24) & 0xff);

	switch(addr & 3)
	{
		case 1:		printf("%s: %02X\n",rtext,memory[ROFFSET+1]);break;
		case 2:		printf("%s: %02X\n",rtext,memory[ROFFSET+2]);break;
		case 3:		printf("%s: %02X\n",rtext,memory[ROFFSET+3]);break;
		default:	printf("%s: %02X\n",rtext,memory[ROFFSET+0]);
	}
}




int ra6_init(unsigned char *idb)
{
	int i,e;
	unsigned long addr;


	i=0;
	// SEL = 0x01000000
	memory[i++]=0x8d;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0xF0;		//SEL = APB-AP
	e=prg_comm(0x9d,i,0,0,ROFFSET,0,0,0,i/5);

	e=prg_comm(0x235,0,5,0,0,0,0,0,0);		//read 4 bytes
	printf("AHB-ID : %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);

	// SEL = 0x01000000
	i=0;
	memory[i++]=0x8d;	memory[i++]=0x01;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0xF0;		//SEL = APB-AP
	e=prg_comm(0x9d,i,0,0,ROFFSET,0,0,0,i/5);

	e=prg_comm(0x235,0,5,0,0,0,0,0,0);		//read 4 bytes
	printf("APB-ID : %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);


	i=0;
	// SEL = 0x01000000
	memory[i++]=0x8d;	memory[i++]=0x01;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//SEL = APB-AP

	// CSW = 0x80000002
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits

	// IAUTH0
	memory[i++]=0xd1;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//TAR = IAUTH0
	memory[i++]=0xdd;	memory[i++]=idb[3];	memory[i++]=idb[2];	memory[i++]=idb[1];		memory[i++]=idb[0];

	// IAUTH1
	memory[i++]=0xd1;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x01;		memory[i++]=0x00;		//TAR = IAUTH1
	memory[i++]=0xdd;	memory[i++]=idb[7];	memory[i++]=idb[6];	memory[i++]=idb[5];		memory[i++]=idb[4];

	// IAUTH2
	memory[i++]=0xd1;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x02;		memory[i++]=0x00;		//TAR = IAUTH2
	memory[i++]=0xdd;	memory[i++]=idb[11];	memory[i++]=idb[10];	memory[i++]=idb[9];		memory[i++]=idb[8];

	// IAUTH3
	memory[i++]=0xd1;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x03;		memory[i++]=0x00;		//TAR = IAUTH3
	memory[i++]=0xdd;	memory[i++]=idb[15];	memory[i++]=idb[14];	memory[i++]=idb[13];		memory[i++]=idb[12];

	// MCUCTRL
	memory[i++]=0xd1;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x04;		memory[i++]=0x10;		//TAR = MCUCTRL
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//clear all flags

	// MCUCTRL
	memory[i++]=0xd1;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x04;		memory[i++]=0x10;		//TAR = MCUCTRL
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x01;		memory[i++]=0x01;		//set debug mode

	e=prg_comm(0x9d,i,0,0,ROFFSET,0,0,0,i/5);

	addr=0x80000410;
	memory[0]=1;
	e=prg_comm(0x23c,1,4,0,0,		//read 4 bytes
			(addr >> 0) & 0xff,
			(addr >> 8) & 0xff,
			(addr >> 16) & 0xff,
			(addr >> 24) & 0xff);
	
//	printf("MCUCTRL: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);


	addr=0x80000400;
	memory[0]=1;
	e=prg_comm(0x23c,1,4,0,0,		//read 4 bytes
			(addr >> 0) & 0xff,
			(addr >> 8) & 0xff,
			(addr >> 16) & 0xff,
			(addr >> 24) & 0xff);
	
//	printf("MCUSTAT: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
	if(memory[0] == 0) return 0x43;

	i=0;
	// SEL = 0x00000000
	memory[i++]=0x8d;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//SEL = AHB-AP

	// CSW = 0x80000001
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x01;		//DBG access enable, 16bits

	// PRCR
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x01;	memory[i++]=0xE3;		memory[i++]=0xFE;		//TAR = PRCR
	memory[i++]=0xdd;	memory[i++]=0xA5;	memory[i++]=0x0B;	memory[i++]=0xA5;		memory[i++]=0x0B;

	// CSW = 0x80000000
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//DBG access enable, 8bits

	// SYOCDCR
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x01;	memory[i++]=0xE4;		memory[i++]=0x0E;		//TAR = SYOCDCR
	memory[i++]=0xdd;	memory[i++]=0x80;	memory[i++]=0x80;	memory[i++]=0x80;		memory[i++]=0x80;

	// CSW = 0x80000001
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits

	e=prg_comm(0x9d,i,0,0,ROFFSET,0,0,0,i/5);

	i=0;
	// CSW = 0x80000001
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x01;		//DBG access enable, 16bits
	e=prg_comm(0x9d,i,0,0,ROFFSET,0,0,0,i/5);


	addr=0x4001E3FE;
	memory[0]=1;
	e=prg_comm(0x23c,1,4,0,0,		//read 4 bytes
			(addr >> 0) & 0xff,
			(addr >> 8) & 0xff,
			(addr >> 16) & 0xff,
			(addr >> 24) & 0xff);
	
//	printf("PRCR   : %02X%02X\n",memory[3],memory[2]);

	i=0;
	// CSW = 0x80000001
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//DBG access enable, 16bits
	e=prg_comm(0x9d,i,0,0,ROFFSET,0,0,0,i/5);

	addr=0x4001E40E;
	memory[0]=1;
	e=prg_comm(0x23c,1,4,0,0,		//read 4 bytes
			(addr >> 0) & 0xff,
			(addr >> 8) & 0xff,
			(addr >> 16) & 0xff,
			(addr >> 24) & 0xff);
	
//	printf("SYOCDCR: %02X\n",memory[2]);
	
	// CSW = 0x80000002
	i=0;
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits
	e=prg_comm(0x9d,i,0,0,ROFFSET,0,0,0,i/5);


//	ra6_showreg32(0x407FE080,	"FSTATR  ");

	return e;
}



int ra6_cmd_entry(unsigned char mode)
{
	int i,k,e;
	unsigned long addr;

//	printf("----------------- CMD ENTRY -------------------\n");

	i=0;
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x01;		//DBG access enable, 16bits
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7F;	memory[i++]=0xE0;		memory[i++]=0x84;		//TAR = FENTRYR
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0xAA;		memory[i++]=mode;

	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//DBG access enable, 8bits
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x01;	memory[i++]=0xE4;		memory[i++]=0x16;		//TAR = FWEPROR
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x01;	memory[i++]=0x00;		memory[i++]=0x01;

	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//DBG access enable, 8bits
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7F;	memory[i++]=0xE0;		memory[i++]=0x14;		//TAR = FAEINT
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x01;		memory[i++]=0x00;

	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//DBG access enable, 8bits
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7E;	memory[i++]=0x00;		memory[i++]=0x00;		//TAR = command area
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x50;		//CMD	

	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits

	e=prg_comm(0x9d,i,0,0,ROFFSET,0,0,2,i/5);

	usleep(100000);

	return 0;
	
	//read back registers
	ra6_showreg08(0x4001E416,	"FWEPROR ");
	ra6_showreg16(0x407FE084,	"FENTRYR ");
	ra6_showreg08(0x407FE014,	"FAEINT  ");
	ra6_showreg08(0x407FE010,	"FASTAT  ");
	ra6_showreg32(0x407FE080,	"FSTATR  ");

	ra6_set32();

	return 0;
}



int ra6_prog_block(unsigned long addr, unsigned long maddr,int blen)
{
	int k,e;
	unsigned long i;

//	printf("------ PROGAMMING BLOCK AT 0x%08lX WITH DATA FROM 0x%08lX -------------------\n",addr,maddr);

	i=ROFFSET;
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7F;	memory[i++]=0xE0;		memory[i++]=0x30;		//TAR = FSADDR
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits
	memory[i++]=0xdd;	memory[i++]=(addr >> 24) & 0xff;	
				memory[i++]=(addr >> 16) & 0xff;
				memory[i++]=(addr >> 8) & 0xff;
				memory[i++]=addr & 0xff;

	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7E;	memory[i++]=0x00;		memory[i++]=0x00;		//TAR = command area
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//DBG access enable, 8bits

	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0xE8;		//CMD
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=blen;		//num

	
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x01;		//DBG access enable, 16bits
	for(k=0;k<blen;k++)
	{										//LOW				//HIGH
		memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=memory[maddr+1];		memory[i++]=memory[maddr];		//data
		maddr+=2;
	}	
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//DBG access enable, 8bits
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0xD0;		//CMD


	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7F;	memory[i++]=0xE0;		memory[i++]=0x80;		//TAR = FSTATR
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits
	memory[i++]=0x55;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x80;		memory[i++]=0x00;		//wait for 1 in FRDY

	return prg_comm(0xa5,i-ROFFSET,0,ROFFSET,50,0,0,0,(i-ROFFSET)/5);
}

int ra6_prog_id(unsigned char *idb)
{

	unsigned long addr;
	int k,e,maddr;
	unsigned long i;
	
	addr=0x0000A150;
	maddr=0;

//	printf("------ PROGAMMING BLOCK AT 0x%08lX WITH DATA FROM 0x%08lX -------------------\n",addr,maddr);

//	memory[1000]=1;
//	e=prg_comm(0x23c,1,4,1000,1000,0x80,0xE0,0x7F,0x40);		//read 4 bytes
//	printf("FSTATR: %02X%02X%02X%02X\n\n",memory[1003],memory[1002],memory[1001],memory[1000]);


	i=ROFFSET;
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7F;	memory[i++]=0xE0;		memory[i++]=0x30;		//TAR = FSADDR
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits
	memory[i++]=0xdd;	memory[i++]=(addr >> 24) & 0xff;	
				memory[i++]=(addr >> 16) & 0xff;
				memory[i++]=(addr >> 8) & 0xff;
				memory[i++]=addr & 0xff;

	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7E;	memory[i++]=0x00;		memory[i++]=0x00;		//TAR = command area
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//DBG access enable, 8bits

	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x40;		//CMD
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x08;		//num

	
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x01;		//DBG access enable, 16bits

	for(k=0;k<8;k++)
	{										//LOW				//HIGH
		memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=idb[maddr+1];	memory[i++]=idb[maddr];		//data
		maddr+=2;
	}	
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//DBG access enable, 8bits
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0xD0;		//CMD


	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7F;	memory[i++]=0xE0;		memory[i++]=0x80;		//TAR = FSTATR
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits
	memory[i++]=0x55;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x80;		memory[i++]=0x00;		//wait for 1 in FRDY

	prg_comm(0xa5,i-ROFFSET,0,ROFFSET,0,4,0,0,(i-ROFFSET)/5);

	sleep(1);
}


int ra6_era_block(unsigned long addr)
{
	int i,k,e;

//	memory[1000]=1;
//	e=prg_comm(0x23c,1,4,1000,1000,0x80,0xE0,0x7F,0x40);		//read 4 bytes
//	printf("FSTATR: %02X%02X%02X%02X\n\n",memory[1003],memory[1002],memory[1001],memory[1000]);


	i=0;
	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7F;	memory[i++]=0xE0;		memory[i++]=0x30;		//TAR = FSADDR
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits
	memory[i++]=0xdd;	memory[i++]=(addr >> 24) & 0xff;	
				memory[i++]=(addr >> 16) & 0xff;
				memory[i++]=(addr >> 8) & 0xff;
				memory[i++]=addr & 0xff;

	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7E;	memory[i++]=0x00;		memory[i++]=0x00;		//TAR = command area
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//DBG access enable, 8bits
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x20;		//CMD
	memory[i++]=0xdd;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0xD0;		//num

	memory[i++]=0xd1;	memory[i++]=0x40;	memory[i++]=0x7F;	memory[i++]=0xE0;		memory[i++]=0x80;		//TAR = FSTATR
	memory[i++]=0xc5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits
	memory[i++]=0x55;	memory[i++]=0x00;	memory[i++]=0x00;	memory[i++]=0x80;		memory[i++]=0x00;		//wait for 1 in FRDY

	return prg_comm(0xa5,i,0,0,ROFFSET,0,1,0,i/5);

}


int ra6_aerase(void)
{
	int i,e;
	unsigned long addr;

	i=0;
	// SEL APB-AB
	memory[i++]=0x8d;	memory[i++]=0x01;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//SEL APB AB

	// CSW = 0x80000000
	memory[i++]=0xC5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits

	// IAUTH0
	memory[i++]=0xd1;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//TAR = IAUTH0
	memory[i++]=0xdd;	memory[i++]=0xFF;	memory[i++]=0xFF;	memory[i++]=0xFF;		memory[i++]=0xFF;

	// IAUTH1
	memory[i++]=0xd1;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x01;		memory[i++]=0x00;		//TAR = IAUTH1
	memory[i++]=0xdd;	memory[i++]=0xFF;	memory[i++]=0xFF;	memory[i++]=0xFF;		memory[i++]=0xFF;

	// IAUTH2
	memory[i++]=0xd1;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x02;		memory[i++]=0x00;		//TAR = IAUTH2
	memory[i++]=0xdd;	memory[i++]=0x41;	memory[i++]=0x53;	memory[i++]=0x45;		memory[i++]=0xFF;

	// IAUTH3
	memory[i++]=0xd1;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x03;		memory[i++]=0x00;		//TAR = IAUTH3
	memory[i++]=0xdd;	memory[i++]=0x41;	memory[i++]=0x4c;	memory[i++]=0x65;		memory[i++]=0x52;
	
	// SEL = 0x02000000
	memory[i++]=0x8d;	memory[i++]=0x02;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//SEL

	// CTRL = 0x4000000
	memory[i++]=0x95;	memory[i++]=0x40;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//CTRLSTAT

	e=prg_comm(0xa5,i,0,0,ROFFSET,0,1,0,i/5);

	usleep(1000);

	e=prg_comm(0x257,0,4,0,0,0,0,0,0xB1);					//get ctrlstat
//	printf("CTRLSTAT: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);

	progress("ALL ERASE ",32,0);

	e=prg_comm(0x258,0,0,0,0,0,0,0,0);

	sleep(1);

	e=prg_comm(0x254,0,16,0,0,0,0,0,0);					//init


	i=0;
	// SEL APB-AB
	memory[i++]=0x8d;	memory[i++]=0x01;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x00;		//SEL APB AB

	// CSW = 0x80000000
	memory[i++]=0xC5;	memory[i++]=0x80;	memory[i++]=0x00;	memory[i++]=0x00;		memory[i++]=0x02;		//DBG access enable, 32bits

	e=prg_comm(0xa5,i,0,0,ROFFSET,0,1,0,i/5);


	i=0;
	do
	{
		addr=0x80000400;
		memory[0]=1;
		e=prg_comm(0x23c,1,4,0,0,		//read 4 bytes
				(addr >> 0) & 0xff,
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				(addr >> 24) & 0xff);
	
//		printf("MCUSTAT: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
		usleep(500000);
		i++;
		progress("ALL ERASE ",32,i);

	}while(((memory[0] & 2) != 2) && (i < 32));

	i=prg_comm(0x258,0,0,0,0,0,0,0,0);

	sleep(1);

	e=prg_comm(0x254,0,16,0,0,0,0,0,0);					//init

	progress("ALL ERASE ",32,33);

	printf("\nDONE\n");

	return e;
}


int prog_ra6(void)
{
	int errc,blocks,i,j,stmp;
	unsigned long addr,len,maddr;
	int all_erase=0;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int data_erase=0;
	int data_prog=0;
	int data_verify=0;
	int data_readout=0;
	int dev_start=0;
	int config_view=0;
	int config_readout=0;
	int set_id=0;
	unsigned char idkey[16];
	unsigned char newkey[16];
	char hexbyte[4];
	char *parptr;
	
	for(i=0;i<16;i++) 
	{
		idkey[i]=0xff;
		newkey[i]=0xff;
	}
	
	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- ea -- all erase\n");

		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		printf("-- ed -- data flash erase\n");
		printf("-- pd -- data flash program\n");
		printf("-- rd -- data flash readout\n");
		printf("-- vc -- config bytes view\n");
		printf("-- rc -- config bytes readout\n");

		printf("-- cid: -- check ID (16 bytes hex)\n");
		printf("-- sid: -- set ID (16 bytes hex)\n");

		printf("-- st -- start device\n");
 		printf("-- d2 -- switch to device 2\n");

		return 0;
	}

	if(find_cmd("st"))
	{
		dev_start=1;
		printf("## Action: start device\n");
		goto RA6_START;
	}

	if(find_cmd("d2"))
	{
		errc=prg_comm(0x2ee,0,0,0,0,0,0,0,0);	//dev 2
		printf("## switch to device 2\n");
	}


	if(find_cmd("em"))
	{
		main_erase=1;
		printf("## Action: main flash erase\n");
	}

	if(find_cmd("ea"))
	{
		all_erase=1;
		printf("## Action: all erase\n");
	}


	if(find_cmd("ed"))
	{
		data_erase=1;
		printf("## Action: data flash erase\n");
	}

	main_prog=check_cmd_prog("pm","code flash");
	main_verify=check_cmd_verify("vm","code flash");
	main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);

	data_prog=check_cmd_prog("pd","data flash");
	data_readout=check_cmd_read("rd","data flash",&data_prog,&data_verify);

	if(find_cmd("rc"))
	{
		printf("## Action: config bytes readout\n");
		config_readout=1;
	}

	if(find_cmd("vc"))
	{
		printf("## Action: config bytes view\n");
		config_view=1;
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
		printf("## Action: Auth device using key ");
		for(i=0;i<16;i++) printf("%02X ",idkey[i]);
		printf("\n");
	}


	if((strstr(cmd,"sid:")) && ((strstr(cmd,"sid:") - cmd) % 2 == 1))
	{
		strcat(cmd,"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");
		parptr=strstr(cmd,"sid:");
		strncpy(&hexbyte[0],parptr + 4 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[0]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 6 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[1]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 8 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[2]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 10 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[3]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 12 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[4]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 14 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[5]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 16 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[6]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 18 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[7]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 20 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[8]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 22 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[9]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 24 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[10]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 26 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[11]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 28 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[12]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 30 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[13]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 32 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[14]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 34 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);newkey[15]=stmp & 0xff;
		printf("## Action: Set device auth to ");
		for(i=0;i<16;i++) printf("%02X ",newkey[i]);
		printf("\n");
		set_id=1;
	}


	printf("\n");

	//open file if read 
	if((main_readout == 1) || (data_readout == 1) || (config_readout == 1))
	{
		errc=writeblock_open();
	}

	if(errc > 0) goto RA6_EXIT;

	errc=prg_comm(0x254,0,16,0,0,0,0,0,0);					//init

	if(errc > 0) 
	{
		printf("ACK STATUS: %d\n",memory[0]);
		goto RA6_EXIT;
	}

	printf("JID: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
//	printf("CTL: %02X%02X%02X%02X\n",memory[7],memory[6],memory[5],memory[4]);

	if(all_erase ==1)
	{
//		printf("ERASE ALL\n");
		errc=ra6_aerase();

		i=prg_comm(0x91,0,0,0,0,0,0,0,0);					//SWD exit
		errc=prg_comm(0x254,0,16,0,0,0,0,0,0);					//init

		if(errc > 0) 
		{
			printf("ACK STATUS: %d\n",memory[0]);
			goto RA6_EXIT;
		}

		printf("JID: %02X%02X%02X%02X\n",memory[3],memory[2],memory[1],memory[0]);
//		printf("CTL: %02X%02X%02X%02X\n",memory[7],memory[6],memory[5],memory[4]);
	}

	errc=ra6_init(idkey);
	if(errc > 0) goto RA6_EXIT;

	ra6_cmd_entry(0x01);

	if((main_erase == 1) && (errc == 0))
	{
		blocks=param[11];
			
		progress("FLASH ERASE ",blocks,0);
			
		for(i=0;i<blocks;i++)
		{
			if(errc == 0)
			{
				errc=ra6_era_block(flashblocks[0]);
			}	
			progress("FLASH ERASE ",blocks,i+1);
		}
		printf("\n");
	}
	
	if((main_prog == 1) && (errc == 0))
	{
		addr=param[0];
		maddr=0;
		blocks=param[1]/128;
		len=read_block(param[0],param[1],0);			//read flash

		progress("FLASH PROG ",blocks,0);
//		printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);

		for(i=0;i<blocks;i++)
		{
			if(must_prog(maddr,128) && (errc==0))
			{
				errc=ra6_prog_block(addr,maddr,64);
			}
			addr+=128;
			maddr+=128;
			progress("FLASH PROG ",blocks,i+1);
		}
		printf("\n");
	}

	ra6_cmd_entry(0x00);
	ra6_cmd_entry(0x80);

	if((data_erase == 1) && (errc == 0))
	{
		blocks=param[3]/64;
			
		progress("DFLASH ERASE ",blocks,0);
			
		for(i=0;i<blocks;i++)
		{
			ra6_era_block(param[2]+64*i);	
			progress("DFLASH ERASE ",blocks,i+1);
		}
		printf("\n");
	}

	if((data_prog == 1) && (errc == 0))
	{
		addr=param[2];
		maddr=0;
		blocks=param[3]/16;
		len=read_block(param[2],param[3],0);			//read flash

		progress("DFLASH PROG ",blocks,0);
//		printf("ADDR = %08lx  LEN= %d Blocks\n",addr,blocks);

		for(i=0;i<blocks;i++)
		{
			if(must_prog(maddr,128) && (errc==0))
			{
				ra6_prog_block(addr,maddr,8);
			}
			addr+=16;
			maddr+=16;
			progress("DFLASH PROG ",blocks,i+1);
		}
		printf("\n");
	}


	ra6_cmd_entry(0x00);	//switcback to read mode


	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		maddr=0;
		addr=param[0];
		blocks=param[1]/max_blocksize;
		progress("FLASH READ ",blocks,0);
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
				progress("FLASH READ ",blocks,i+1);
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
		len=read_block(param[0],param[1],0);			//read flash
		printf("VERIFY MAIN (%ld KBytes)\n",param[1]/1024);
		addr = param[0];
		maddr=0;
		len = param[1];
		for(j=0;j<len;j++)
		{
			if(memory[maddr+j] != memory[maddr+j+ROFFSET])
			{
				printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
					addr+j,memory[maddr+j],memory[maddr+j+ROFFSET]);
				errc=1;
			}
		}
	}


	if(((data_readout == 1) || (data_verify == 1)) && (errc == 0))
	{
		maddr=0;
		addr=param[2];
		blocks=param[3]/max_blocksize;
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
		writeblock_data(0,param[3],param[2]);
	}


	if((set_id == 1) && (errc == 0))
	{
		//check if already programmed
		addr=0x0100A100;
		errc=prg_comm(0xbf,0,256,0,ROFFSET,
			(addr >> 8) & 0xff,
			(addr >> 16) & 0xff,
			(addr >> 24) & 0xff,
			1);

		i=0;
		for(j=0x53;j<0x5D;j++)
		{
			if(memory[ROFFSET+j] != 0xff) i=1;
		}
		if(i==1)
		{
			printf("!!! ID IS ALREADY SET, CANNOT OVERWRITE !!!\n");
		}
		else
		{
			ra6_cmd_entry(0x01);
			progress("PROG ID ",20,0);
			ra6_prog_id(newkey);
			progress("PROG ID ",20,21);
			printf("\n");
			ra6_cmd_entry(0x00);
		}
	}

	if(((config_readout == 1) || (config_view == 1)) && (errc == 0))
	{
		addr=0x0100A100;

		errc=prg_comm(0xbf,0,256,0,ROFFSET,
			(addr >> 8) & 0xff,
			(addr >> 16) & 0xff,
			(addr >> 24) & 0xff,
			1);

		printf("OSIS  : ");
		printf(" %02X%02X%02X%02X  %02X%02X%02X%02X  %02X%02X%02X%02X  %02X%02X%02X%02X\n",
		memory[ROFFSET+0x53],memory[ROFFSET+0x52],memory[ROFFSET+0x51],memory[ROFFSET+0x50],
		memory[ROFFSET+0x57],memory[ROFFSET+0x56],memory[ROFFSET+0x55],memory[ROFFSET+0x54],
		memory[ROFFSET+0x5B],memory[ROFFSET+0x5A],memory[ROFFSET+0x59],memory[ROFFSET+0x58],
		memory[ROFFSET+0x5F],memory[ROFFSET+0x5E],memory[ROFFSET+0x5D],memory[ROFFSET+0x5C]);
		writeblock_data(0x50,16,0x0100A150);

		printf("AWE   : ");
		printf(" %02X%02X%02X%02X\n",
		memory[ROFFSET+0x67],memory[ROFFSET+0x66],memory[ROFFSET+0x65],memory[ROFFSET+0x64]);
		writeblock_data(0x64,4,0x0100A164);

		printf("\n");
			
	}

	//open file if was read 
	if((main_readout == 1) || (data_readout == 1) || (config_readout == 1))
	{
		writeblock_close();
	}

RA6_START:

	if(dev_start == 1)
	{
		i=prg_comm(0x0e,0,0,0,0,0,0,0,0);	//init
		waitkey();
		i=prg_comm(0x0f,0,0,0,0,0,0,0,0);	//exit
	}

RA6_EXIT:

	i=prg_comm(0x91,0,0,0,0,0,0,0,0);	//SWD exit
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_ra6_error(errc);

	return errc;
}


