//##############################################################################
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

void print_sici_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("Communication Error",errc);
				break;

		case 0x42:	set_error("(wrong echo)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}

unsigned char tle5014_crc(unsigned char start,unsigned char len)
{
	unsigned char crc,pos,cbit,cbyte;
	
	crc=0xff;
	pos=start;
	
	while(pos < (start+len))
	{	
		if(pos & 1) cbyte=memory[ROFFSET+pos-1];
		else cbyte=memory[ROFFSET+pos+1];
		
//		printf("POS= %02X   BYTE = %02X\n",pos,cbyte);
		
		crc ^= cbyte;
		for(cbit=0;cbit<8;cbit++)
			crc = crc & 0x80 ? (crc << 1) ^ 0x1d : crc << 1;
		pos++;
	}	
	crc &=0xFF;
	crc ^= 0xFF;
	return crc;
}


unsigned char tle5014_crc2(unsigned char start,unsigned char len)
{
	unsigned char crc,pos,cbit,cbyte;
	
	crc=0xff;
	pos=start;
	
	while(pos < (start+len))
	{	
		if(pos & 1) cbyte=memory[pos-1];
		else cbyte=memory[pos+1];
		
//		printf("POS= %02X   BYTE = %02X\n",pos,cbyte);
		
		crc ^= cbyte;
		for(cbit=0;cbit<8;cbit++)
			crc = crc & 0x80 ? (crc << 1) ^ 0x1d : crc << 1;
		pos++;
	}	
	crc &=0xFF;
	crc ^= 0xFF;
	return crc;
}


int prog_sici(void)
{
	long errc;
	int i,page,block;
	unsigned short val1,val2,val3;
	int ee_prog=0;
	int ee_verify=0;
	int ee_readout=0;
	int madr;
	int wait_ext=0;
	unsigned char crc;
	


	prg_comm(0xFE,0,0,0,0,3,3,0,0);	//enable PU		
	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5v   -- using 5V VDD\n");	
		printf("-- read -- read angle/status\n");
		printf("-- re   -- read eeprom\n");
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
		printf("## using 5V VDD\n");	
		prg_comm(0xFB,0,0,0,0,0,0,0,0);	//set 5V		
	
	}

	if(find_cmd("wx"))
	{
		printf("## waiting for external supply\n");	
		wait_ext=1;		
	
	}



	ee_prog=check_cmd_prog("pe","eeprom");
	ee_verify=check_cmd_verify("ve","eeprom");
	ee_readout=check_cmd_read("re","eeprom",&ee_prog,&ee_verify);


	if(find_cmd("read"))
	{
		errc=prg_comm(0x1ca,0,48,0,0,0,0,0,1);	//init		
	
		if(errc !=0)
		{
			printf("\n!!! WRONG ECHO !!!\n");
			for(i=0;i<1;i++)
			{
				val1=memory[12*i] + (memory[12*i+1] << 8);
				val2=memory[12*i+4] + (memory[12*i+5] << 8);
				val3=memory[12*i+8] + (memory[12*i+9] << 8);
				printf("%04X %04X %04X -> ",val1,val2,val3);
				val1=memory[12*i+2] + (memory[12*i+3] << 8);
				val2=memory[12*i+6] + (memory[12*i+7] << 8);
				val3=memory[12*i+10] + (memory[12*i+11] << 8);
				printf("%04X %04X %04X\n",val1,val2,val3);
			}
			printf("\n");
		}

		errc=prg_comm(0x1cc,0,48,0,0,0,0,0,0);	//read working reg		
		if(errc !=0)
		{
			printf("\n!!! WRONG ECHO !!!\n");
			for(i=0;i<1;i++)
			{
				val1=memory[12*i] + (memory[12*i+1] << 8);
				val2=memory[12*i+4] + (memory[12*i+5] << 8);
				val3=memory[12*i+8] + (memory[12*i+9] << 8);
				printf("%04X %04X %04X -> ",val1,val2,val3);
				val1=memory[12*i+2] + (memory[12*i+3] << 8);
				val2=memory[12*i+6] + (memory[12*i+7] << 8);
				val3=memory[12*i+10] + (memory[12*i+11] << 8);
				printf("%04X %04X %04X\n",val1,val2,val3);
			}
			printf("\n");
		}
		else
		{
				i=1;
				val2=memory[12*i+6] + (memory[12*i+7] << 8);
				printf("Angle= %d (%04X)\n",val2,val2);	
	
		}


	}
	else
	{	

		errc=prg_comm(0x1ca,0,48,0,0,0,0,wait_ext,0);	//init		

			for(i=0;i<3;i++)
			{
				val1=memory[12*i] + (memory[12*i+1] << 8);
				val2=memory[12*i+4] + (memory[12*i+5] << 8);
				val3=memory[12*i+8] + (memory[12*i+9] << 8);
				printf("%04X %04X %04X -> ",val1,val2,val3);
				val1=memory[12*i+2] + (memory[12*i+3] << 8);
				val2=memory[12*i+6] + (memory[12*i+7] << 8);
				val3=memory[12*i+10] + (memory[12*i+11] << 8);
				printf("%04X %04X %04X\n",val1,val2,val3);
			}
			printf("\n");
	
		if(errc !=0)
		{
			printf("\n!!! WRONG ECHO !!!\n");
			for(i=0;i<3;i++)
			{
				val1=memory[12*i] + (memory[12*i+1] << 8);
				val2=memory[12*i+4] + (memory[12*i+5] << 8);
				val3=memory[12*i+8] + (memory[12*i+9] << 8);
				printf("%04X %04X %04X -> ",val1,val2,val3);
				val1=memory[12*i+2] + (memory[12*i+3] << 8);
				val2=memory[12*i+6] + (memory[12*i+7] << 8);
				val3=memory[12*i+10] + (memory[12*i+11] << 8);
				printf("%04X %04X %04X\n",val1,val2,val3);
			}
			printf("\n");
		}
		
		if(ee_prog == 1)
		{
			read_block(param[0],param[1],0);		//read flash
			crc=tle5014_crc2(6,15);printf("Config CRC = %02X, should be %02X\n",memory[20],crc);
			if(memory[20] != crc)
			{
				printf(" !! Updating wrong Config CRC to %2X !!\n",crc);
				memory[20]=crc;
			
			}
			crc=tle5014_crc2(32,65);printf("LUT CRC    = %02X, should be %02X\n",memory[96],crc);
			if(memory[96] != crc)
			{
				printf(" !! Updating wrong LUT CRC to %2X !!\n",crc);
				memory[96]=crc;
			
			}

			progress("PROGRAM ",7,0);
			for(block=0;block<7;block++)
			{
				page=block+9;
				errc |=prg_comm(0x1ce,256,0,0,0,0,0,block & 0x0F,page & 0x0F);	//init		
				progress("PROGRAM ",7,block+1);
			}

		}

		if(ee_readout == 1)
		{
			errc=writeblock_open();
			madr=0;
			for(page=9;page<16;page++)
			{
				errc |=prg_comm(0x1cd,0,400,0,0,0,0,0,page & 0x0F);	//init		
				if(errc == 0)
				{
					printf("PAGE %02X:  ",page); 
					for(i=0;i<8;i++)
					{
						val2=memory[12*i+6+12] + (memory[12*i+7+12] << 8);
						printf("%04X  ",val2);
						memory[madr+ROFFSET]=memory[12*i+6+12];
						memory[madr+ROFFSET+1]=memory[12*i+7+12];
						madr+=2;
					}
					printf("\n"); 
				}			
			
			}		
			if(errc == 0)	writeblock_data16(0,param[1],param[0]);

			crc=tle5014_crc(6,15);
			if(memory[20+ROFFSET] != crc)
			{
				printf("!! Wrong Config CRC = %02X, should be %02X\n",memory[ROFFSET+20],crc);
			
			}
			else
			{
				printf("** Config CRC OK (%02X)\n",memory[ROFFSET+20]);
			
			}
			
			crc=tle5014_crc(32,65);
			if(memory[96+ROFFSET] != crc)
			{
				printf("!! Wrong LUT CRC    = %02X, should be %02X\n",memory[ROFFSET+96],crc);
			
			}
			else
			{
				printf("** LUT CRC OK (%02X)\n",memory[ROFFSET+96]);
			
			}
			
			
		}
		
	}

	//open file if was read 
	if(ee_readout == 1)
	{
		writeblock_close();
	}

	prg_comm(0x1cb,0,0,0,0,0,0,0,0);	//exit
	prg_comm(0x0fe,0,0,0,0,0,0,0,0);	//disable PU		
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_sici_error(errc);
	return errc;
}


