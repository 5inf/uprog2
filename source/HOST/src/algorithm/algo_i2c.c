//###############################################################################
//#										#
//# UPROG universal programmer							#
//#										#
//# copyright (c) 2012-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
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

void print_i2c_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x40:	set_error("(No ACK at adressing)",errc);
				break;

		case 0x41:	set_error("(I2C error)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_i2c(void)
{
	int errc,blocks,i;
	unsigned char abyte;
	unsigned long addr,maddr;
	int bsize;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int speedmode=0;
	int iaddr=0;
	unsigned int csum;

	errc=0;


	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- hs -- set high speed (400kHz)\n");
		printf("-- an -- set device address (a0-a7, defaut is a0)\n");
		printf("-- ee -- eeprom erase\n");
		printf("-- pe -- eeprom program\n");
		printf("-- ve -- eeprom verify\n");
		printf("-- re -- eeprom read\n");
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
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		printf("## using 5V VDD\n");
	}

	if(find_cmd("hs"))
	{
		speedmode=1;
		printf("## using 400kHz speed\n");
	}
	
	//select addr
	if(find_cmd("a1")) iaddr=2;
	if(find_cmd("a2")) iaddr=4;
	if(find_cmd("a3")) iaddr=6;
	if(find_cmd("a4")) iaddr=8;
	if(find_cmd("a5")) iaddr=10;
	if(find_cmd("a6")) iaddr=12;
	if(find_cmd("a7")) iaddr=14;

	printf("## programming device at address %d\n",iaddr);
	iaddr+=param[4];


	if(find_cmd("ee"))
	{
		main_erase=1;
		printf("## Action: eeprom erase\n");
	}


	main_prog=check_cmd_prog("pe","eeprom");
	main_verify=check_cmd_verify("ve","eeprom");
	main_readout=check_cmd_read("re","eeprom",&main_prog,&main_verify);

	printf("\n");
	
	if(main_readout > 0)
	{
		errc=writeblock_open();
	}

	if(errc==0) 
	{
		errc=prg_comm(0xfe,0,0,0,0,3,3,0,0);					//enable pull-up
		errc=prg_comm(0xa0,0,0,0,0,speedmode,param[2],param[3],param[6]);	//init
	}
	
	if((main_erase == 1) && (errc == 0))
	{
		printf("ERASE EEPROM\n");
		for(maddr=param[0];maddr<param[1];maddr++) memory[maddr]=255;
		
		bsize=max_blocksize;
		if(param[3] == 1) bsize=256;
		addr=param[0];
		if(bsize > param[1]) bsize=param[1];
		blocks=param[1]/bsize;
		maddr=0;

		progress("PROG ",blocks,0);
		for(i=0;i<blocks;i++)
		{
			abyte=((iaddr | param[4]) & param[5]) | ((addr >> 7) & ~(param[5]));
			if(errc==0) errc=prg_comm(0xa3,bsize,0,maddr,0,
			addr & 0xff,			//LOW addr
			addr >> 8,			//HIGH addr
			abyte,				//address byte
			bsize / param[2]);		//pages
			addr+=bsize;			
			maddr+=bsize;
			progress("PROG ",blocks,i+1);
		}
	}

	if((main_prog == 1) && (errc == 0))
	{
		read_block(param[0],param[1],0);
		bsize=max_blocksize;
		if(param[3] == 1) bsize=256;
		addr=param[0];
		if(bsize > param[1]) bsize=param[1];
		blocks=param[1]/bsize;
		maddr=0;

		//calculate checksum
		if(param[8] != 0)
		{
			csum=0;
			for(maddr=0;maddr<param[8];maddr++)
			{
				csum+=memory[maddr];
			}
			memory[param[8]]= (csum >> 8) & 0xff;	//CSUM HIGH
			memory[param[8]+1]= csum & 0xff;	//CSUM LOW
		
			maddr=0;
		}


//		show_data(0,16);

		progress("PROG ",blocks,0);
		for(i=0;i<blocks;i++)
		{
			abyte=((iaddr | param[4]) & param[5]) | ((addr >> 7) & ~(param[5]));
			if(errc==0) errc=prg_comm(0xa3,bsize,0,maddr,0,
			addr & 0xff,			//LOW addr
			addr >> 8,			//HIGH addr
			abyte,				//address byte
			bsize / param[2]);		//pages
			addr+=bsize;			
			maddr+=bsize;
			progress("PROG ",blocks,i+1);
		}
	}


	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		bsize=max_blocksize;
		if(param[3] == 1) bsize=256;
		addr=param[0];
		if(bsize > param[1]) bsize=param[1];
		blocks=param[1]/bsize;
		maddr=0;

		progress("READ ",blocks,0);
		for(i=0;i<blocks;i++)
		{
			abyte=((iaddr | param[4]) & param[5]) | ((addr >> 7) & ~(param[5]));
			if(errc==0) errc=prg_comm(0xa2,0,bsize,0,maddr+ROFFSET,
			addr & 0xff,			//LOW addr
			addr >> 8,			//HIGH addr
			abyte,				//address byte
			bsize / param[2]);		//pages per block
			addr+=bsize;
			maddr+=bsize;
			progress("READ ",blocks,i+1);
		}
	}

	if((main_readout == 1) && (errc == 0))
	{
		writeblock_data(0,param[1],param[0]);
	}

	if(main_readout > 0)
	{
		writeblock_close();
	}


	i=prg_comm(0xa1,0,0,0,0,0,0,0,0);					//I2C exit
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_i2c_error(errc);

	return errc;
}

