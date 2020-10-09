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

void print_pic16c_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x7e:	set_error("(WRONG DEVICE ID)",errc);
				break;

		case 0x52:	set_error("(LOCK ERROR)",errc);
				break;

		case 0x53:	set_error("(SYNC ERROR)",errc);
				break;

		case 0x55:	set_error("(FETCH ERROR)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_pic16c()
{
	int errc,blocks,bsize,j,dev_id;
	unsigned int addr,len,fdata,rdata,maddr;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int eeprom_readout=0;
	int conf_prog=0;
	int conf_verify=0;
	int conf_readout=0;
	int uid_prog=0;
	int uid_verify=0;
	int uid_readout=0;
	int dev_start=0;
	int all_erase=0;
	int ignore_devid=0;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5V -- set VDD to 5V\n");
		printf("-- ea -- chip erase\n");

		printf("-- em -- main flash erase\n");
		printf("-- pm -- main flash program\n");
		printf("-- vm -- main flash verify\n");
		printf("-- rm -- main flash readout\n");

		printf("-- pc -- configuration program\n");
		printf("-- vc -- configuration verify\n");
		printf("-- rc -- configuration readout\n");

		printf("-- pu -- cuser id program\n");
		printf("-- vu -- cuser id verify\n");
		printf("-- ru -- cuser id readout\n");

		printf("-- ii -- ignore wrong ID\n");
		printf("-- st -- start device\n");
		return 0;
	}


	if(find_cmd("5v"))
	{
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		printf("## using 5V VDD\n");
	}

	if(find_cmd("ii"))
	{
		ignore_devid=1;
		printf("## Ignore device ID\n");
	}

	if(find_cmd("em"))
	{
		main_erase=1;
		printf("## Action: main flash erase\n");
	}


	if(find_cmd("ea"))
	{
		all_erase=1;
		printf("## Action: chip (bulk) erase\n");
	}

	main_prog=check_cmd_prog("pm","code flash");
	conf_prog=check_cmd_prog("pc","config");
	uid_prog=check_cmd_prog("pu","user id");

	main_verify=check_cmd_verify("vm","code flash");
	conf_verify=check_cmd_verify("vc","config");
	uid_verify=check_cmd_verify("vu","user id");

	main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
	conf_readout=check_cmd_read("rc","config",&conf_prog,&conf_verify);
	uid_readout=check_cmd_read("ru","user id",&uid_prog,&uid_verify);


	if(find_cmd("st"))
	{
		dev_start=1;
		printf("## Action: start device\n");
	}
	printf("\n");

	if((main_readout || eeprom_readout || conf_readout || uid_readout) > 0)
	{
		errc=writeblock_open();
	}

	//init
	if(dev_start == 0)
	{
		if(errc == 0) errc=prg_comm(0xf5,0,0,0,0,0,0,0,0);			//vpp off
		if(errc == 0) errc=prg_comm(0xf2,0,0,0,0,param[8],0,0,0);		//set vpp
		read_volt();
		if(errc == 0) errc=prg_comm(0x70,0,0,0,0,0,0,0,0);			//init
		if(errc == 0) errc=prg_comm(0x1b8,0,2,0,0,0,0,0,0);			//get ID

		dev_id=(memory[0]+256*memory[1]) & 0xFFFF;
		if(dev_id != param[10])
		{
			printf("ID READ = %04X, SHOULD BE %04lX\n",dev_id,param[10]);
			errc=0x7e;
		}
		else
		{
			printf("ID = %04X\n",dev_id);
		}

		if((ignore_devid == 1) && (errc == 0x7e)) errc=0;
		if(errc != 0) goto PROG_END; 

	}

	//erase
	if((all_erase == 1) && (errc == 0))
	{
		errc=prg_comm(0x1ba,0,0,0,0,param[9],0,0x00,0x80);			//erase all
	}

	if((main_erase == 1) && (errc == 0))
	{
		errc=prg_comm(0x1ba,0,0,0,0,param[9],0,0xFE,0x80);			//erase flash
	}

	//program main flash
	if((main_prog == 1) && (errc == 0))
	{
		read_block(param[0]*2,param[1]*2,0);
		addr = param[0];
		len=param[1];
		bsize = max_blocksize;
		if((len*2) < bsize) bsize = len*2;
		blocks = len * 2 / bsize;
		len = bsize / 2;
		addr >>= 2;
		maddr=0;

		progress("PROG MAIN ",blocks,0);
		for(j=0;j<blocks;j++)
		{
//			printf("bsize= %04X  addr= %04X\n",bsize,maddr);
			if(errc == 0) 
			{
				errc=prg_comm(0x1bb,bsize,0,maddr,0,
				param[11],0,addr & 0xFF,(addr >> 8) & 0xFF);	//program block
			}
			addr+=len;
			maddr+=bsize;
			progress("PROG MAIN ",blocks,j+1);
		}
		printf("\n");
	}

	//verify/readout main flash
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		addr = param[0];
		len=param[1];
		bsize = max_blocksize;
		if((len*2) < bsize) bsize = len*2;
		blocks = len * 2 / bsize;
		len = bsize / 2;
		addr >>= 1;
		maddr=0;

		progress("READ MAIN ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			if(errc == 0) 
			{
				errc=prg_comm(0x1b9,0,bsize,0,maddr+ROFFSET,
				len & 0xff,(len >> 8) & 0xff,addr & 0xff,(addr >> 8) & 0xFF);	//read block
			}
			progress("READ MAIN ",blocks,j+1);
			addr+=len;
			maddr+=bsize;
		}
		printf("\n");
	}

	if(main_verify == 1)
	{
		read_block(param[0]*2,param[1]*2,0);
		addr = param[0];
		len = param[1] * 2;

		for(j=0;j<len;j+=2)
		{
			rdata=(memory[j+ROFFSET]+256*memory[j+ROFFSET+1]) & 0x3FFF;
			fdata=(memory[j]+256*memory[j+1]) & 0x3FFF;
			
			if(rdata != fdata)
			{
				printf("ERR -> ADDR= %04X  DATA= %04X  READ= %04X\n",addr+j,fdata,rdata);
				errc=1;
			}
		}
	}

	if(main_readout == 1)
	{
		writeblock_data(0,param[1]*2,param[0]*2);
	}


	//program user ID
	if((uid_prog == 1) && (errc == 0))
	{
		read_block(param[6]*2,param[7]*2,0);
		addr = param[6] * 2;
		bsize = param[7] * 2;
		len=bsize / 2;
		maddr=0;

		progress("PROG UID  ",1,0);
		errc=prg_comm(0x1bc,2,0,0,0,param[12],0,0x00,0x80);		//program word
		errc=prg_comm(0x1bc,2,0,2,0,param[12],0,0x01,0x80);		//program word
		errc=prg_comm(0x1bc,2,0,4,0,param[12],0,0x02,0x80);		//program word
		errc=prg_comm(0x1bc,2,0,6,0,param[12],0,0x03,0x80);		//program word
		progress("PROG UID  ",1,1);
		printf("\n");
	}

	//verify/readout user ID
	if(((uid_readout == 1) || (uid_verify == 1)) && (errc == 0))
	{
		addr = param[6]*2;
		bsize = param[7]*2;
		maddr=0;

		progress("READ UID  ",1,0);
		errc=prg_comm(0x1B9,0,8,0,maddr+ROFFSET,4,0,0x00,0x80);		//read 4 words
		progress("READ UID  ",1,1);
		printf("\n");
	}

	if(uid_verify == 1)
	{
		read_block(param[6]*2,param[7]*2,0);
		addr = param[6] * 2;
		len = param[7] * 2;
		for(j=0;j<len;j+=2)
		{
			rdata=(memory[j+ROFFSET]+256*memory[j+ROFFSET+1]) & 0x3FFF;
			fdata=(memory[j]+256*memory[j+1]) & 0x3FFF;
			
			if(rdata != fdata)
			{
				printf("ERR -> ADDR= %04X  DATA= %04X  READ= %04X\n",addr+j,fdata,rdata);
				errc=1;
			}
		}
	}

	if(uid_readout == 1)
	{
		writeblock_data(0,param[7]*2,param[6]*2);
	}

	//program config words
	if((conf_prog == 1) && (errc == 0))
	{
		read_block(param[4]*2,param[5]*2,0);
		addr = param[4]*2;
		bsize = param[5]*2;
		len=bsize / 2;
		maddr=0;

//		printf("CONF= %02X%02X %02X%02X\n",memory[1],memory[0],memory[3],memory[2]);

		progress("PROG CONF ",1,0);
		errc=prg_comm(0x1bc,2,0,0,0,param[12],0,0x07,0x80);		//program word
		errc=prg_comm(0x1bc,2,0,2,0,param[12],0,0x08,0x80);		//program word
		errc=prg_comm(0x1bc,2,0,4,0,param[12],0,0x09,0x80);		//program word
		errc=prg_comm(0x1bc,2,0,6,0,param[12],0,0x0a,0x80);		//program word
		errc=prg_comm(0x1bc,2,0,8,0,param[12],0,0x0b,0x80);		//program word
		progress("PROG CONF ",1,1);
		printf("\n");
	}

	//verify/readout config words
	if(((conf_readout == 1) || (conf_verify == 1)) && (errc == 0))
	{
		addr = param[4]*2;
		bsize = param[5]*2;
		len=bsize / 2;
		maddr=0;
		
//		printf("bsize= %04X  addr= %04X\n",bsize,addr);
		progress("READ CONF ",1,0);
		errc=prg_comm(0x1B9,0,10,0,maddr+ROFFSET,4,0,0x07,0x80);		//read 5 words
		progress("READ CONF ",1,1);
		printf("\n");

//		printf("CONF= %02X%02X %02X%02X\n",memory[1+ROFFSET],memory[ROFFSET],
//		memory[3+ROFFSET],memory[2+ROFFSET]);

	}

	if(conf_verify == 1)
	{
		read_block(param[4]*2,param[5]*2,0);
		addr = param[4] * 2;
		len = param[5] * 2;
		
		for(j=0;j<len;j+=2)
		{
			rdata=(memory[j+ROFFSET]+256*memory[j+ROFFSET+1]) & param[13+j/2];
			fdata=(memory[j]+256*memory[j+1]) & param[13+j/2];
//			rdata|=param[13+j/2];
//			fdata|=param[13+j/2];

			if(rdata != fdata)
			{
				printf("ERR -> ADDR= %04X  DATA= %04X  READ= %04X\n",addr+j,fdata,rdata);
				errc=1;
			}
		}
	}
	if(conf_readout == 1)
	{
		writeblock_data(0,param[5]*2,param[4]*2);
	}

	if((main_readout || eeprom_readout || conf_readout || uid_readout) > 0)
	{
		errc=writeblock_close();
	}


	if(dev_start == 1)
	{
		if(errc == 0) errc=prg_comm(0x70,0,0,0,0,4,0,0,0);			//init
		waitkey();
		prg_comm(0x71,0,0,0,0,0,0,0,0);						//exit
	}

PROG_END:

	prg_comm(0x71,0,0,0,0,0,0,0,0);					//exit
	prg_comm(0xf5,0,0,0,0,0,0,0,0);					//vpp off
	prg_comm(0xf2,0,0,0,0,0,0,0,0);					//disable vpp

	print_pic16c_error(errc);
	return errc;

}


