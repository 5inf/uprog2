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

void print_pic18a_error(int errc)
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


int prog_pic18a()
{
	int errc,blocks,bsize,i,j,dev_id;
	unsigned long addr,len,maddr;
	unsigned int rdata,fdata;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int eeprom_erase=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int conf_erase=0;
	int conf_prog=0;
	int conf_verify=0;
	int conf_readout=0;
	int uid_erase=0;
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
		
		printf("-- ee -- eeprom erase\n");
		printf("-- pe -- eeprom program\n");
		printf("-- ve -- eeprom verify\n");
		printf("-- re -- eeprom readout\n");

		printf("-- ec -- configuration erase\n");
		printf("-- pc -- configuration program\n");
		printf("-- vc -- configuration verify\n");
		printf("-- rc -- configuration readout\n");

		printf("-- eu -- cuser id erase\n");
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

	if(find_cmd("ee"))
	{
		eeprom_erase=1;
		printf("## Action: eeprom erase\n");
	}

	if(find_cmd("ea"))
	{
		all_erase=1;
		printf("## Action: all erase\n");
	}

	if(find_cmd("eu"))
	{
		uid_erase=1;
		printf("## Action: user id erase\n");
	}

	if(find_cmd("ec"))
	{
		conf_erase=1;
		printf("## Action: config erase\n");
	}


	main_prog=check_cmd_prog("pm","code flash");
	eeprom_prog=check_cmd_prog("pe","eeprom");
	conf_prog=check_cmd_prog("pc","config");
	uid_prog=check_cmd_prog("pu","user id");

	main_verify=check_cmd_verify("vm","code flash");
	eeprom_verify=check_cmd_verify("ve","eeprom");
	conf_verify=check_cmd_verify("vc","config");
	uid_verify=check_cmd_verify("vu","user id");

	main_readout=check_cmd_read("rm","code flash",&main_prog,&main_verify);
	eeprom_readout=check_cmd_read("re","eeprom",&eeprom_prog,&eeprom_verify);
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
		if((param[9] & 0xF0) == 0x00)	//K20
		{
			memory[0] = 0xa6;	//EECON1
			memory[1] = 0xa9;	//EEADR
			memory[2] = 0xaa;	//EEADRH
			memory[3] = 0xa8;	//EEDATA
			memory[4] = 0xf8;	//TBLPTRU
			memory[5] = 0xf7;	//TBLPTRH
			memory[6] = 0xf6;	//TBLPTRL
			memory[7] = 0xf5;	//TABLAT
			memory[8] = 0x00;	//unused
			memory[9] = 0x00;	//unused
			printf("## Mode: K20\n");
		}

		if((param[9] & 0xF0) == 0x10)	//K80
		{
			memory[0] = 0x7f;	//EECON1
			memory[1] = 0x74;	//EEADR
			memory[2] = 0x75;	//EEADRH
			memory[3] = 0x73;	//EEDATA
			memory[4] = 0xf8;	//TBLPTRU
			memory[5] = 0xf7;	//TBLPTRH
			memory[6] = 0xf6;	//TBLPTRL
			memory[7] = 0xf5;	//TABLAT
			memory[8] = 0x00;	//unused
			memory[9] = 0x00;	//unused
			printf("## Mode: K80\n");
		}

		if((param[9] & 0xF0) == 0x20)	//Fxx
		{
			memory[0] = 0xa6;	//EECON1
			memory[1] = 0xa9;	//EEADR
			memory[2] = 0xaa;	//EEADRH
			memory[3] = 0xa8;	//EEDATA
			memory[4] = 0xf8;	//TBLPTRU
			memory[5] = 0xf7;	//TBLPTRH
			memory[6] = 0xf6;	//TBLPTRL
			memory[7] = 0xf5;	//TABLAT
			memory[8] = 0x00;	//unused
			memory[9] = 0x00;	//unused
			printf("## Mode: PIC18F2xxx/PIC18F4xxx\n");
		}


		if(errc == 0) errc=prg_comm(0x82,8,0,0,0,0,0,0,param[9] & 0x01);		//init (with key)
		addr = 0x3FFFFE;
		errc=prg_comm(0x8e,0,2,0,0,addr & 0xff,(addr >> 8) & 0xff,(addr >> 16) & 0xff,2);		//read

		dev_id=(memory[0]+256*memory[1]) & 0xFFE0;
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
	}


	//erase
	if((all_erase == 1) && (errc == 0))
	{
		if((param[9] & 0xF0) == 0x00)	//K20
		{
			errc=prg_comm(0x8A,0,0,0,0,0,0,0x0F,0x8F);				//erase all
		}
		else
		{
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x01,0x04);				//erase prog blk0
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x02,0x04);				//erase prog blk1
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x04,0x04);				//erase prog blk2
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x08,0x04);				//erase prog blk3
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x00,0x05);				//erase boot block
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x00,0x04);				//erase eeprom
		}
	}

	if((main_erase == 1) && (errc == 0))
	{
		if((param[9] & 0xF0) == 0x00)	//K20
		{	
			errc=prg_comm(0x8A,0,0,0,0,0,0,0x01,0x80);				//erase prog blk0
			errc=prg_comm(0x8A,0,0,0,0,0,0,0x02,0x80);				//erase prog blk1
			errc=prg_comm(0x8A,0,0,0,0,0,0,0x04,0x80);				//erase prog blk2
			errc=prg_comm(0x8A,0,0,0,0,0,0,0x08,0x80);				//erase prog blk3
		}
		if((param[9] & 0xF0) == 0x10)	//K80
		{	
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x01,0x04);				//erase prog blk0
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x02,0x04);				//erase prog blk1
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x04,0x04);				//erase prog blk2
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x08,0x04);				//erase prog blk3
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x00,0x05);				//erase boot block
		}
		
	}

	if((eeprom_erase == 1) && (errc == 0))
	{
		if((param[9] & 0xF0) == 0x00)	//K20
		{	
			errc=prg_comm(0x8A,0,0,0,0,0,0,0x00,0x84);				//erase eeprom
		}
		if((param[9] & 0xF0) == 0x10)	//K80
		{	
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x00,0x04);			//erase eeprom
		}
	}

	if((uid_erase == 1) && (errc == 0))
	{
		if((param[9] & 0xF0) == 0x00)	//K20
		{	
			errc=prg_comm(0x8A,0,0,0,0,0,0,0x00,0x88);				//erase uid
		}
		if((param[9] & 0xF0) == 0x10)	//K80
		{	
			printf("!!! erase id loaction is not supported !!!\n");
		}
	}

	if((conf_erase == 1) && (errc == 0))
	{
		if((param[9] & 0xF0) == 0x00)	//K20
		{	
			errc=prg_comm(0x8A,0,0,0,0,0,0,0x00,0x82);				//erase config
		}
		if((param[9] & 0xF0) == 0x10)	//K80
		{	
			errc=prg_comm(0x8A,0,0,0,0,1,0x80,0x00,0x02);			//erase config
		}
	}

	//program main flash
	if((main_prog == 1) && (errc == 0))
	{
		read_block(param[0],param[1],0);
		addr = param[0];
		len=param[1];
		bsize = max_blocksize;
		blocks = len / bsize;
		maddr=0;

		progress("PROG FLASH  ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			if(must_prog(maddr,bsize) && (errc == 0))
			{
				errc=prg_comm(0x8d,bsize,0,maddr,0,
				addr & 0xff,(addr >> 8) & 0xff,(addr >> 16) & 0xff,param[13]);		//fprog 2K
			}
			progress("PROG FLASH  ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	//verify/readout main flash
	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		addr = param[0];
		len=param[1];
		bsize = max_blocksize;
		blocks = len / bsize;
		maddr=0;

		progress("READ FLASH  ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			if(errc == 0) 
			{
				errc=prg_comm(0x8b,0,bsize,0,maddr+ROFFSET,
				addr & 0xff,(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,bsize >> 8);		//read block
			}
			progress("READ FLASH  ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	if(main_verify == 1)
	{
		read_block(param[0]*2,param[1]*2,0);
		addr = param[0];
		len = param[1];
		i=0;
		for(j=0;j<len;j+=2)
		{
			rdata=(memory[j+ROFFSET]+256*memory[j+ROFFSET+1]) & 0x3FFF;
			fdata=(memory[j]+256*memory[j+1]) & 0x3FFF;
			
			if(rdata != fdata)
			{
				printf("ERR -> ADDR= %04lX  DATA= %04X  READ= %04X\n",addr+j,fdata,rdata);
				errc=1;
			}
		}
	}

	if(main_readout == 1)
	{
		writeblock_data(0,param[1],param[0]);
	}

	//program eeprom
	if((eeprom_prog == 1) && (errc == 0))
	{
		read_block(param[2],param[3],0);
		addr = param[2];
		len = param[3];
		bsize = max_blocksize;
		if(len < bsize) bsize = len;
		blocks = len / bsize;
		maddr=0;

		printf("bsize= %04X  addr= %04lX\n",bsize,addr);

		progress("PROG EEPROM ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			if(errc == 0) 
			{
				errc=prg_comm(0x8f,bsize,0,maddr,0,
				addr & 0xff,(addr >> 8) & 0xff,bsize & 0xff,bsize >> 8);	//prog
			}
			progress("PROG EEPROM ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	//verify/readout eeprom
	if(((eeprom_readout == 1) || (eeprom_verify == 1)) && (errc == 0))
	{
		addr = param[2];
		len = param[3];
		bsize = max_blocksize;
		if(len < bsize) bsize = len;
		blocks = len / bsize;
		maddr=0;

		progress("READ EEPROM ",blocks,0);
		for(j=0;j<blocks;j++)
		{
			if(errc == 0) 
			{
				errc=prg_comm(0x8c,0,bsize,0,maddr+ROFFSET,
				addr & 0xff,(addr >> 8) & 0xff,bsize & 0xff,bsize >> 8);		//read
			}
			progress("READ EEPROM ",blocks,j+1);
			addr+=bsize;
			maddr+=bsize;
		}
		printf("\n");
	}

	if(eeprom_verify == 1)
	{
		read_block(param[2],param[3],0);
		addr = param[2];
		len = param[3];
		i=0;
		for(j=0;j<len;j+=1)
		{
			rdata=memory[j+ROFFSET];
			fdata=memory[j];
			
			if(rdata != fdata)
			{
				printf("ERR -> ADDR= %04lX  DATA= %02X  READ= %02X\n",addr+j,fdata,rdata);
				errc=1;
			}
		}
	}

	if(eeprom_readout == 1)
	{
		printf("EER\n");
		writeblock_data(0,param[3],param[2]);
	}

	//program user ID
	if((uid_prog == 1) && (errc == 0))
	{
		read_block(param[6],param[7],0);
		addr = param[6];
		len = param[7];
		maddr=0;

		printf(">> UID = ");

		for(i=0;i<8;i++)
		{
			printf("%02X ",memory[i]);
		}

		printf("\n");

//		printf("len= %04X  addr= %06X\n",len,addr);
		progress("PROG USERID ",1,0);
			errc=prg_comm(0xb0,len,0,maddr,0,
			addr & 0xff,(addr >> 8) & 0xff,(addr >> 16) & 0xff,len);		//uprog
		progress("PROG USERID ",1,1);
		printf("\n");
	}

	//verify/readout user ID
	if(((uid_readout == 1) || (uid_verify == 1)) && (errc == 0))
	{
		addr = param[6];
		len = param[7];
		maddr=0;
		
		progress("READ USERID ",1,0);
			errc=prg_comm(0x8e,0,len,0,maddr+ROFFSET,
			addr & 0xff,(addr >> 8) & 0xff,(addr >> 16) & 0xff,len);		//read
		progress("READ USERID ",1,1);
		printf("\n");
	}

	if(uid_verify == 1)
	{
		read_block(param[6],param[7],0);
		addr = param[6];
		len = param[7];
		i=0;
		for(j=0;j<len;j+=2)
		{
			rdata=(memory[j+ROFFSET]+256*memory[j+ROFFSET+1]) & 0x3FFF;
			fdata=(memory[j]+256*memory[j+1]) & 0x3FFF;
			
			if(rdata != fdata)
			{
				printf("ERR -> ADDR= %04lX  DATA= %04X  READ= %04X\n",addr+j,fdata,rdata);
				errc=1;
			}
		}
	}

	if(uid_readout == 1)
	{
		writeblock_data(0,param[7],param[6]);
	}

	//program config words
	if((conf_prog == 1) && (errc == 0))
	{
		read_block(param[4],param[5],0);
		addr = param[4];
		len = param[5]/2;
		maddr=0;

		errc=prg_comm(0x8e,0,param[5],0,maddr+ROFFSET,
		addr & 0xff,(addr >> 8) & 0xff,(addr >> 16) & 0xff,param[5]);		//read

		memory[0]&=param[15] >> 24;
		memory[1]&=param[15] >> 16;
		memory[2]&=param[15] >> 8;
		memory[3]&=param[15];
		memory[4]&=param[16] >> 24;
		memory[5]&=param[16] >> 16;
		memory[6]&=param[16] >> 8;
		memory[7]&=param[16];
		memory[8]&=param[17] >> 24;
		memory[9]&=param[17] >> 16;
		memory[10]&=param[17] >> 8;
		memory[11]&=param[17];
		memory[12]&=param[18] >> 24;
		memory[13]&=param[18] >> 16;

		memory[0+ROFFSET]&=param[15] >> 24;
		memory[1+ROFFSET]&=param[15] >> 16;
		memory[2+ROFFSET]&=param[15] >> 8;
		memory[3+ROFFSET]&=param[15];
		memory[4+ROFFSET]&=param[16] >> 24;
		memory[5+ROFFSET]&=param[16] >> 16;
		memory[6+ROFFSET]&=param[16] >> 8;
		memory[7+ROFFSET]&=param[16];
		memory[8+ROFFSET]&=param[17] >> 24;
		memory[9+ROFFSET]&=param[17] >> 16;
		memory[10+ROFFSET]&=param[17] >> 8;
		memory[11+ROFFSET]&=param[17];
		memory[12+ROFFSET]&=param[18] >> 24;
		memory[13+ROFFSET]&=param[18] >> 16;

		printf(">> CFG (READ)  = ");
		for(i=0;i<14;i++)
		{
			printf("%02X ",memory[i+ROFFSET]);
		}
		printf("\n");

		printf(">> CFG (WRITE) = ");
		for(i=0;i<14;i++)
		{
			printf("%02X ",memory[i]);
		}
		printf("\n");

		progress("PROG CONFIG ",7,0);
		for(j=0;j<7;j++)
		{
			errc=prg_comm(0xb1,2,0,maddr,0,
			addr & 0xff,(addr >> 8) & 0xff,(addr >> 16) & 0xff,0);		//prog
			addr+=2;
			maddr+=2;
			progress("PROG CONFIG ",7,j+1);
		}
		printf("\n");
	}

	//verify/readout config words
	if(((conf_readout == 1) || (conf_verify == 1)) && (errc == 0))
	{
		addr = param[4];
		len = param[5];
		maddr=0;
//		printf("len= %04X  addr= %08X\n",len,addr);
		progress("READ CONFIG ",1,0);
			errc=prg_comm(0x8e,0,len,0,maddr+ROFFSET,
			addr & 0xff,(addr >> 8) & 0xff,(addr >> 16) & 0xff,len);		//read
		progress("READ CONFIG ",1,1);
		printf("\n");
	}

	if(conf_verify == 1)
	{
		read_block(param[4],param[5],0);
		addr = param[4];
		len = param[5];
		memory[0]&=param[15] >> 24;
		memory[1]&=param[15] >> 16;
		memory[2]&=param[15] >> 8;
		memory[3]&=param[15];
		memory[4]&=param[16] >> 24;
		memory[5]&=param[16] >> 16;
		memory[6]&=param[16] >> 8;
		memory[7]&=param[16];
		memory[8]&=param[17] >> 24;
		memory[9]&=param[17] >> 16;
		memory[10]&=param[17] >> 8;
		memory[11]&=param[17];
		memory[12]&=param[18] >> 24;
		memory[13]&=param[18] >> 16;

		memory[0+ROFFSET]&=param[15] >> 24;
		memory[1+ROFFSET]&=param[15] >> 16;
		memory[2+ROFFSET]&=param[15] >> 8;
		memory[3+ROFFSET]&=param[15];
		memory[4+ROFFSET]&=param[16] >> 24;
		memory[5+ROFFSET]&=param[16] >> 16;
		memory[6+ROFFSET]&=param[16] >> 8;
		memory[7+ROFFSET]&=param[16];
		memory[8+ROFFSET]&=param[17] >> 24;
		memory[9+ROFFSET]&=param[17] >> 16;
		memory[10+ROFFSET]&=param[17] >> 8;
		memory[11+ROFFSET]&=param[17];
		memory[12+ROFFSET]&=param[18] >> 24;
		memory[13+ROFFSET]&=param[18] >> 16;

		i=0;
		for(j=0;j<len;j+=2)
		{
			rdata=(memory[j+ROFFSET]);
			fdata=(memory[j]);
			if(rdata != fdata)
			{
				printf("ERR -> ADDR= %04lX  DATA= %04X  READ= %04X\n",addr+j,fdata,rdata);
				errc=1;
			}
		}
	}

	if(conf_readout == 1)
	{
		writeblock_data(0,param[5],param[4]);
	}


	if((main_readout || eeprom_readout || conf_readout || uid_readout) > 0)
	{
		writeblock_close();
	} 


	if(dev_start == 1)
	{
		if(errc == 0) errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);			//init
		waitkey();
		i=prg_comm(0x71,0,0,0,0,0,0,0,0);					//exit
	}

	prg_comm(0x71,0,0,0,0,0,0,0,0);					//exit
	prg_comm(0xf5,0,0,0,0,0,0,0,0);					//vpp off
	prg_comm(0xf2,0,0,0,0,0,0,0,0);					//vpp disable

	print_pic18a_error(errc);
	return errc;
}

