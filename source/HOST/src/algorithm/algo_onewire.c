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

void print_onewire_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",0);
				break;

		case 1:		set_error("VERIFY ERROR",1);
				break;

		case 0x41:	set_error("(device not present)",errc);
				break;

		case 0x42:	set_error("(wrong family code)",errc);
				break;

		case 0x44:	set_error("(write error)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_onewire(void)
{
	int errc,blocks,tblock,bsize,j,stmp;
	unsigned long addr,maddr;
	int eeprom_erase=0;
	int eeprom_prog=0;
	int eeprom_verify=0;
	int eeprom_readout=0;
	int lock_prog=0;
	int dev_start=0;
	int overdrive=0;
	int id_prog=0;
	int protect0=0;
	int protect1=0;
	int protect2=0;
	int protect3=0;
	int eprom0=0;
	int eprom1=0;
	int eprom2=0;
	int eprom3=0;
	int cprotect=0;
	char hexbyte[16];
	unsigned char pagebuf[16];
	char *parptr;


	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5v -- set VDD to 5V\n");
		printf("-- ee -- eeprom erase (write 0xFF)\n");
		printf("-- pe -- eeprom program\n");
		printf("-- ve -- eeprom verify\n");
		printf("-- re -- eeprom readout\n");
		printf("-- p0 -- write protect page 0 (0x00-0x1F)\n");
		printf("-- p1 -- write protect page 1 (0x20-0x3F)\n");
		printf("-- p2 -- write protect page 2 (0x40-0x5F)\n");
		printf("-- p3 -- write protect page 3 (0x60-0x7F)\n");
		printf("-- e0 -- eeprom mode page 0 (0x00-0x1F)\n");
		printf("-- e1 -- eeprom mode page 1 (0x20-0x3F)\n");
		printf("-- e2 -- eeprom mode page 2 (0x40-0x5F)\n");
		printf("-- e3 -- eeprom mode page 3 (0x60-0x7F)\n");
		printf("-- cp -- copy protect all\n");
		printf("-- pid:nnnn  User ID program\n");

//		printf("-- od -- overdrive mode\n");
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


	if(find_cmd("od"))
	{
		overdrive=1;
		printf("## using overdrive mode\n");
	}

	if(find_cmd("ee"))
	{
		eeprom_erase=1;
		printf("## Action: erase EEPROM (write 0xff)\n");
	}

	if(find_cmd("p0"))
	{
		protect0=1;
		printf("## Action: Protect Page 0\n");
	}

	if(find_cmd("p1"))
	{
		protect1=1;
		printf("## Action: Protect Page 1\n");
	}

	if(find_cmd("p2"))
	{
		protect2=1;
		printf("## Action: Protect Page 2\n");
	}


	if(find_cmd("p3"))
	{
		protect3=1;
		printf("## Action: Protect Page 3\n");
	}

	if(find_cmd("e0"))
	{
		eprom0=1;
		printf("## Action: EPROM Mode Page 0\n");
	}

	if(find_cmd("e1"))
	{
		eprom1=1;
		printf("## Action: EPROM Mode Page 1\n");
	}

	if(find_cmd("e2"))
	{
		eprom2=1;
		printf("## Action: EPROM Mode Page 2\n");
	}


	if(find_cmd("e3"))
	{
		eprom3=1;
		printf("## Action: EPROM Mode Page 3\n");
	}

	if(find_cmd("cp"))
	{
		cprotect=1;
		printf("## Action: Copy Protect All\n");
	}

	if((strstr(cmd,"pid:")) && ((strstr(cmd,"pid:") - cmd) % 2 == 1))
	{
		strcat(cmd,"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");
		parptr=strstr(cmd,"pid:");
		strncpy(&hexbyte[0],parptr + 4 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);pagebuf[0]=stmp & 0xff;
		strncpy(&hexbyte[0],parptr + 6 * sizeof(char),2);hexbyte[2]=0;sscanf(hexbyte,"%x",&stmp);pagebuf[1]=stmp & 0xff;
		printf("## Action: set device ID using ");
		for(j=6;j<8;j++) printf("%02X ",memory[j]);
		printf("\n");
		id_prog=1;
	}

	eeprom_prog=check_cmd_prog("pe","eeprom");

	eeprom_verify=check_cmd_verify("ve","eeprom");

	eeprom_readout=check_cmd_read("re","eeprom",&eeprom_prog,&eeprom_verify);


	if(find_cmd("lb")) 
	{
		if(have_expar < 1)
		{
			lock_prog = 0;
			printf("## Action: ext fuse program !! DISABLED BECAUSE OF NO DATA !!\n");
		}
		else
		{
			lock_prog=1;
			have_expar=0;
			printf("## Action: ext fuse program with value 0x%02X\n",(int)(expar & 0xff));
		}
	}
	printf("\n");

	errc=0;




	if(eeprom_readout > 0)
	{
		errc=writeblock_open();
	}

	printf("INIT\n");
	errc=prg_comm(0x230,0,0,0,0,0,0,0,0);	//init
	if(errc != 0) goto ONEWIRE_END;

	printf("READ ID\n");
	prg_comm(0x232,0,16,0,0,0,0,0x33,8);

	printf("FAMILY CODE = %02X\n",memory[0]);
	printf("SERIAL NUM  = %02X %02X %02X %02X %02X %02X\n",memory[6],memory[5],memory[4],memory[3],memory[2],memory[1]);
	printf("CRC         = %02X\n\n",memory[7]);

	if(memory[0] != param[10])
	{
		printf("WRONG FAMILY CODE (%02X), SHOULD BE %02X\n",memory[0],(unsigned int)param[10]);
		errc=0x42;
		goto ONEWIRE_END;
	
	}

	//erase memory
	if ((errc == 0) && (eeprom_erase == 1))
	{
		for(j=0;j<8;j++) memory[j]=0xff;
		
		blocks=param[3];
		maddr=0;
		errc=0;

		progress("EEPROM ERASE  ",blocks,0);
		
		for(tblock=0;tblock<blocks;tblock++)
		{
			errc|=prg_comm(0x234,8,0,0,0,0,0,0,maddr);
			progress("EEPROM ERASE  ",blocks,tblock+1);
			maddr+=8;
		}
		printf("\n");
		if(errc != 0) printf("!!! Write Errors, probably protected pages !!!\n\n");
	}


	//program memory
	if ((errc == 0) && (eeprom_prog == 1))
	{
		read_block(param[0],param[1],0);		//get data
		blocks=param[3];
		maddr=0;
		errc=0;

		progress("EEPROM PROG   ",blocks,0);
		
		for(tblock=0;tblock<blocks;tblock++)
		{
			errc|=prg_comm(0x234,8,0,maddr,0,0,0,0,maddr);
			progress("EEPROM PROG   ",blocks,tblock+1);
			maddr+=8;
		}
		printf("\n");
		if(errc != 0) printf("!!! Write Errors, probably protected pages !!!\n\n");
	}



	//read / verify memory
	if ((errc == 0) && ((eeprom_verify == 1) || (eeprom_readout == 1)) && (param[1] > 0))
	{
		blocks=1;
		progress("EEPROM READ   ",blocks,0);
		errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
		progress("EEPROM READ   ",blocks,blocks);
		printf("\n");
	}

	if((eeprom_verify == 1) && (errc == 0))
	{
		read_block(param[0],param[1],0);
		addr = param[0];
		for(j=0;j<param[1];j++)
		{
			if(memory[j] != memory[j+ROFFSET])
			{
				printf("ERR -> ADDR= %06lX  DATA= %02X  READ= %02X\n",
				addr+j,memory[j],memory[j+ROFFSET]);
				errc=1;
			}
		}
	}

	if((eeprom_readout==1) && (errc==0))
	{
		writeblock_data(0,param[1],param[0]);
	}


	if(eeprom_readout > 0)
	{
		writeblock_close();
	}


	if(id_prog == 1)
	{
		printf("SET USER ID\n");
		errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
		if((memory[ROFFSET+0x84] != 0x55) && (memory[ROFFSET+0x84] != 0xAA))
		{ 
			for(j=0;j<8;j++) memory[j]=memory[ROFFSET+0x80+j];
			memory[6]=pagebuf[0];
			memory[7]=pagebuf[1];
			errc=prg_comm(0x234,8,8,0,ROFFSET,0,0,0,0x80);
			if(errc != 0) 
			{
				printf("WDATA = %02X %02X %02X %02X %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3],memory[4],memory[5],memory[6],memory[7]);
				printf("T1 = %02X\n",memory[ROFFSET]);printf("T2 = %02X\n",memory[ROFFSET+1]);printf("ES = %02X\n",memory[ROFFSET+2]);	
				goto ONEWIRE_END;
			}
		}
		else
		{
			printf("!!! LOCATION IS PROTECTED !!!\n");
		}		
	}


	if(protect0 == 1)
	{
		printf("WRITE PROTECT PAGE 0\n");
		errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
		if((memory[ROFFSET+0x80] != 0x55) && (memory[ROFFSET+0x80] != 0xAA) && (memory[ROFFSET+0x84] != 0x55) && (memory[ROFFSET+0x84] != 0xAA))
		{ 
			for(j=0;j<8;j++) memory[j]=memory[ROFFSET+0x80+j];
			memory[0]=0x55;
			errc=prg_comm(0x234,8,8,0,ROFFSET,0,0,0,0x80);
			if(errc != 0) 
			{
				printf("WDATA = %02X %02X %02X %02X %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3],memory[4],memory[5],memory[6],memory[7]);
				printf("T1 = %02X\n",memory[ROFFSET]);printf("T2 = %02X\n",memory[ROFFSET+1]);printf("ES = %02X\n",memory[ROFFSET+2]);	
				goto ONEWIRE_END;
			}
		}
		else
		{
			printf("!!! LOCATION IS PROTECTED !!!\n");
		}		
	}

	if(protect1 == 1)
	{
		printf("WRITE PROTECT PAGE 1\n");
		errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
		if((memory[ROFFSET+0x81] != 0x55) && (memory[ROFFSET+0x81] != 0xAA) && (memory[ROFFSET+0x84] != 0x55) && (memory[ROFFSET+0x84] != 0xAA))
		{ 
			for(j=0;j<8;j++) memory[j]=memory[ROFFSET+0x80+j];
			memory[1]=0x55;
			errc=prg_comm(0x234,8,8,0,ROFFSET,0,0,0,0x80);
			if(errc != 0) 
			{
				printf("WDATA = %02X %02X %02X %02X %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3],memory[4],memory[5],memory[6],memory[7]);
				printf("T1 = %02X\n",memory[ROFFSET]);printf("T2 = %02X\n",memory[ROFFSET+1]);printf("ES = %02X\n",memory[ROFFSET+2]);	
				goto ONEWIRE_END;
			}
		}
		else
		{
			printf("!!! LOCATION IS PROTECTED !!!\n");
		}		
	}

	if(protect2 == 1)
	{
		printf("WRITE PROTECT PAGE 2\n");
		errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
		if((memory[ROFFSET+0x82] != 0x55) && (memory[ROFFSET+0x82] != 0xAA) && (memory[ROFFSET+0x84] != 0x55) && (memory[ROFFSET+0x84] != 0xAA))
		{ 
			for(j=0;j<8;j++) memory[j]=memory[ROFFSET+0x80+j];
			memory[2]=0x55;
			errc=prg_comm(0x234,8,8,0,ROFFSET,0,0,0,0x80);
			if(errc != 0) 
			{
				printf("WDATA = %02X %02X %02X %02X %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3],memory[4],memory[5],memory[6],memory[7]);
				printf("T1 = %02X\n",memory[ROFFSET]);printf("T2 = %02X\n",memory[ROFFSET+1]);printf("ES = %02X\n",memory[ROFFSET+2]);	
				goto ONEWIRE_END;
			}
		}
		else
		{
			printf("!!! LOCATION IS PROTECTED !!!\n");
		}		
	}

	if(protect3 == 1)
	{
		printf("WRITE PROTECT PAGE 2\n");
		errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
		if((memory[ROFFSET+0x83] != 0x55) && (memory[ROFFSET+0x83] != 0xAA) && (memory[ROFFSET+0x84] != 0x55) && (memory[ROFFSET+0x84] != 0xAA))
		{ 
			for(j=0;j<8;j++) memory[j]=memory[ROFFSET+0x80+j];
			memory[3]=0x55;
			errc=prg_comm(0x234,8,8,0,ROFFSET,0,0,0,0x80);
			if(errc != 0) 
			{
				printf("WDATA = %02X %02X %02X %02X %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3],memory[4],memory[5],memory[6],memory[7]);
				printf("T1 = %02X\n",memory[ROFFSET]);printf("T2 = %02X\n",memory[ROFFSET+1]);printf("ES = %02X\n",memory[ROFFSET+2]);	
				goto ONEWIRE_END;
			}
		}
		else
		{
			printf("!!! LOCATION IS PROTECTED !!!\n");
		}		
	}

	if(eprom0 == 1)
	{
		printf("EPROM MODE PAGE 0\n");
		errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
		if((memory[ROFFSET+0x80] != 0x55) && (memory[ROFFSET+0x80] != 0xAA) && (memory[ROFFSET+0x84] != 0x55) && (memory[ROFFSET+0x84] != 0xAA))
		{ 
			for(j=0;j<8;j++) memory[j]=memory[ROFFSET+0x80+j];
			memory[0]=0xAA;
			errc=prg_comm(0x234,8,8,0,ROFFSET,0,0,0,0x80);
			if(errc != 0) 
			{
				printf("WDATA = %02X %02X %02X %02X %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3],memory[4],memory[5],memory[6],memory[7]);
				printf("T1 = %02X\n",memory[ROFFSET]);printf("T2 = %02X\n",memory[ROFFSET+1]);printf("ES = %02X\n",memory[ROFFSET+2]);	
				goto ONEWIRE_END;
			}
		}
		else
		{
			printf("!!! LOCATION IS PROTECTED !!!\n");
		}		
	}

	if(eprom1 == 1)
	{
		printf("EPROM MODE PAGE 1\n");
		errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
		if((memory[ROFFSET+0x81] != 0x55) && (memory[ROFFSET+0x81] != 0xAA) && (memory[ROFFSET+0x84] != 0x55) && (memory[ROFFSET+0x84] != 0xAA))
		{ 
			for(j=0;j<8;j++) memory[j]=memory[ROFFSET+0x80+j];
			memory[1]=0xAA;
			errc=prg_comm(0x234,8,8,0,ROFFSET,0,0,0,0x80);
			if(errc != 0) 
			{
				printf("WDATA = %02X %02X %02X %02X %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3],memory[4],memory[5],memory[6],memory[7]);
				printf("T1 = %02X\n",memory[ROFFSET]);printf("T2 = %02X\n",memory[ROFFSET+1]);printf("ES = %02X\n",memory[ROFFSET+2]);	
				goto ONEWIRE_END;
			}
		}
		else
		{
			printf("!!! LOCATION IS PROTECTED !!!\n");
		}		
	}


	if(eprom2 == 1)
	{
		printf("EPROM MODE PAGE 2\n");
		errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
		if((memory[ROFFSET+0x82] != 0x55) && (memory[ROFFSET+0x82] != 0xAA) && (memory[ROFFSET+0x84] != 0x55) && (memory[ROFFSET+0x84] != 0xAA))
		{ 
			for(j=0;j<8;j++) memory[j]=memory[ROFFSET+0x80+j];
			memory[2]=0xAA;
			errc=prg_comm(0x234,8,8,0,ROFFSET,0,0,0,0x80);
			if(errc != 0) 
			{
				printf("WDATA = %02X %02X %02X %02X %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3],memory[4],memory[5],memory[6],memory[7]);
				printf("T1 = %02X\n",memory[ROFFSET]);printf("T2 = %02X\n",memory[ROFFSET+1]);printf("ES = %02X\n",memory[ROFFSET+2]);	
				goto ONEWIRE_END;
			}
		}
		else
		{
			printf("!!! LOCATION IS PROTECTED !!!\n");
		}		
	}


	if(eprom3 == 1)
	{
		printf("EPROM MODE PAGE 3\n");
		errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
		if((memory[ROFFSET+0x83] != 0x55) && (memory[ROFFSET+0x83] != 0xAA) && (memory[ROFFSET+0x84] != 0x55) && (memory[ROFFSET+0x84] != 0xAA))
		{ 
			for(j=0;j<8;j++) memory[j]=memory[ROFFSET+0x80+j];
			memory[3]=0xAA;
			errc=prg_comm(0x234,8,8,0,ROFFSET,0,0,0,0x80);
			if(errc != 0) 
			{
				printf("WDATA = %02X %02X %02X %02X %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3],memory[4],memory[5],memory[6],memory[7]);
				printf("T1 = %02X\n",memory[ROFFSET]);printf("T2 = %02X\n",memory[ROFFSET+1]);printf("ES = %02X\n",memory[ROFFSET+2]);	
				goto ONEWIRE_END;
			}
		}
		else
		{
			printf("!!! LOCATION IS PROTECTED !!!\n");
		}		
	}

	if(cprotect == 1)
	{
		printf("COPY PROTECT ALL\n");
		errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
		if((memory[ROFFSET+0x84] != 0x55) && (memory[ROFFSET+0x84] != 0xAA))
		{ 
			for(j=0;j<8;j++) memory[j]=memory[ROFFSET+0x80+j];
			memory[4]=0xAA;
			errc=prg_comm(0x234,8,8,0,ROFFSET,0,0,0,0x80);
			if(errc != 0) 
			{
				printf("WDATA = %02X %02X %02X %02X %02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3],memory[4],memory[5],memory[6],memory[7]);
				printf("T1 = %02X\n",memory[ROFFSET]);printf("T2 = %02X\n",memory[ROFFSET+1]);printf("ES = %02X\n",memory[ROFFSET+2]);	
				goto ONEWIRE_END;
			}
		}
		else
		{
			printf("!!! LOCATION IS PROTECTED !!!\n");
		}		
	}


	errc=prg_comm(0x233,0,512,0,ROFFSET,0,0,0,0);
	printf("------------- STATUS ------------------\n");
	printf("Protection Control Byte Page 0 = %02X\n",memory[ROFFSET+0x80]);
	printf("Protection Control Byte Page 1 = %02X\n",memory[ROFFSET+0x81]);
	printf("Protection Control Byte Page 2 = %02X\n",memory[ROFFSET+0x82]);
	printf("Protection Control Byte Page 3 = %02X\n",memory[ROFFSET+0x83]);
	printf("Copy Protection Byte           = %02X\n",memory[ROFFSET+0x84]);
	printf("Factory Byte                   = %02X\n",memory[ROFFSET+0x85]);
	printf("User Bytes / Manufacturer ID   = %02X %02X\n",memory[ROFFSET+0x86],memory[ROFFSET+0x87]);
	printf("Chip Revision Code             = %02X\n\n",memory[ROFFSET+0xFF]);

ONEWIRE_END:

	prg_comm(0x231,0,0,0,0,0,0,0,0);	//exit
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_onewire_error(errc);

	return errc;
}

