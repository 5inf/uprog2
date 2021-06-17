//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2012-2021 Joerg Wolfram (joerg@jcwolfram.de)			#
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


unsigned short avrjtag_rocd(int num,char backsteps)
{
	unsigned short rval;
	prg_comm(0x247,0,2,0,0,0,0,backsteps,num);	//get OCD
	rval=memory[0]+(memory[1]<<8);
	return rval;				
}

void avrjtag_wocd(int num,unsigned short val,char backsteps)
{
	prg_comm(0x248,0,0,0,0,val & 0xff,(val >> 8) & 0xff,backsteps,num);	//put OCD
}

void avrjtag_instr(unsigned short cmd,char backsteps)
{
	prg_comm(0x245,0,0,0,0,cmd & 0xff,(cmd >> 8) & 0xff,backsteps,0);	//instr
}

unsigned short avrjtag_getpc(char backsteps)
{
	unsigned short rval;
	prg_comm(0x246,0,4,0,0,0,0,backsteps,0);	//get PC
	rval=memory[0]+(memory[1]<<8);
//	printf("PCRAW = %02X %02X %02X %02X\n",memory[3],memory[2],memory[1],memory[0]);
	return rval;				
}


void show_avr_registers_t1(int bmode)
{
	unsigned short pcval;

	int back_rocd,back_getpc,back_cmd,back_cmdr;

	if(bmode==1)
	{
		back_rocd=4;
		back_getpc=3;
		back_cmd=3;
		back_cmdr=2;
	}


	printf("PC PRE  = %04X    ",avrjtag_getpc(back_getpc));
	printf("%04X\n",avrjtag_getpc(back_getpc));

	pcval=avrjtag_rocd(0,back_rocd);
	avrjtag_instr(0xBE01,back_cmd);	//R0->OCD

	printf("PC IMM  = %04X    ",avrjtag_getpc(back_getpc));
	printf("%04X\n",avrjtag_getpc(back_getpc));

	pcval=avrjtag_rocd(0,back_rocd);

	printf("PC PAST = %04X    ",avrjtag_getpc(back_getpc));
	printf("%04X\n",avrjtag_getpc(back_getpc));
	
	avrjtag_instr(0xBE01,back_cmdr);	//R0->OCD
	printf("R0 : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBE11,back_cmdr);	//R1->OCD
	printf("R1 : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBE21,back_cmdr);	//R2->OCD
	printf("R2 : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBE31,back_cmdr);	//R3->OCD
	printf("R3 : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBE41,back_cmdr);	//R4->OCD
	printf("R4 : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBE51,back_cmdr);	//R5->OCD
	printf("R5 : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBE61,back_cmdr);	//R6->OCD
	printf("R6 : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBE71,back_cmdr);	//R7->OCD
	printf("R7 : %02X\n",avrjtag_rocd(12,back_rocd) >> 8);


	avrjtag_instr(0xBE81,back_cmdr);	//R8->OCD
	printf("R8 : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBE81,back_cmdr);	//R9->OCD
	printf("R9 : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBEA1,back_cmdr);	//R10->OCD
	printf("R10: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBEB1,back_cmdr);	//R11->OCD
	printf("R11: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBEC1,back_cmdr);	//R12->OCD
	printf("R12: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBED1,back_cmdr);	//R13->OCD
	printf("R13: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBEE1,back_cmd);	//R14->OCD
	printf("R14: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBEF1,back_cmdr);	//R15->OCD
	printf("R15: %02X\n",avrjtag_rocd(12,back_rocd) >> 8);

	avrjtag_instr(0xBF01,back_cmdr);	//R16->OCD
	printf("R16: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBF11,back_cmdr);	//R17->OCD
	printf("R17: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBF21,back_cmdr);	//R18->OCD
	printf("R18: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBF31,back_cmdr);	//R19->OCD
	printf("R19: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBF41,back_cmdr);	//R20->OCD
	printf("R20: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBF51,back_cmdr);	//R21->OCD
	printf("R21: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBF61,back_cmdr);	//R22->OCD
	printf("R22: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBF71,back_cmdr);	//R23->OCD
	printf("R23: %02X\n",avrjtag_rocd(12,back_rocd) >> 8);
	
	avrjtag_instr(0xBF81,back_cmdr);	//R24->OCD
	printf("R24: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBF91,back_cmdr);	//R25->OCD
	printf("R25: %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBFA1,back_cmdr);	//R26->OCD
	printf("XL : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBFB1,back_cmdr);	//R27->OCD
	printf("XH : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBFC1,back_cmdr);	//R28->OCD
	printf("YL : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBFD1,back_cmdr);	//R29->OCD
	printf("YH : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBFE1,back_cmdr);	//R30->OCD
	printf("ZL : %02X      ",avrjtag_rocd(12,back_rocd) >> 8);
	avrjtag_instr(0xBFF1,back_cmdr);	//R31->OCD
	printf("ZH : %02X\n",avrjtag_rocd(12,back_rocd) >> 8);
	printf("\n");

	printf("PC LAST = %04X    ",avrjtag_getpc(back_getpc));
	printf("%04X\n",avrjtag_getpc(back_getpc));


	pcval=avrjtag_rocd(13,back_rocd);
//	if((pcval & 0xFF) == 0x00) printf("Status = Run\n");
//	else if((pcval & 0xff) == 0x01) printf("Status = Reset\n");
//	else if((pcval & 0xff) == 0x0C) printf("Status = Break\n");
	printf("CSR = %04X\n",pcval);
	
	printf("PC = %04X    ",avrjtag_getpc(back_getpc));
	printf("PC = %04X    \n",avrjtag_getpc(back_getpc));


	pcval=avrjtag_rocd(9,back_rocd);
	if(pcval & 1) printf("Break Instruction\n");
	if(pcval & 2) printf("Break by OCD\n");
	if(pcval & 4) printf("Break bit2\n");
	if(pcval & 8) printf("Breakpoint PDMSBB\n");
	if(pcval & 16) printf("Breakponit PDSBB\n");
	if(pcval & 32) printf("Breakpoint PSB1\n");
	if(pcval & 64) printf("Breakpoint PSB0\n");
	if(pcval & 128) printf("Break on change program flow\n");
	if(pcval & 256) printf("Single Step break\n");
	printf("PC = %04X    ",avrjtag_getpc(back_getpc));
	printf("PC = %04X    \n",avrjtag_getpc(back_getpc));

	printf("\n\n");


}

void show_avr_debug_regs(void)
{
	int i;
	
	for(i=0;i<8;i++)
	{
		avrjtag_instr(0x0000,2);	//NOP
		printf("R%02d: %04X        ",i,avrjtag_rocd(i,1));
	}

	printf("\n");

	for(i=8;i<16;i++)
	{
		avrjtag_instr(0x0000,2);	//NOP
		printf("R%02d: %04X        ",i,avrjtag_rocd(i,1));
	}

	printf("\n");
	printf("\n");
}





void debug_avrjtag_t1(void)
{
	int errc,blocks,tblock,bsize,i,j,eblock=0;

	int debug_flash=0;
	size_t dbg_len=80;
	char *dbg_line;
	char *dbg_ptr;
	char c;
	unsigned short dbg_addr,dbg_val;
	
	dbg_line=malloc(100);
	

	printf("\n");
	errc=prg_comm(0x242,0,0,0,0,0,0,0,1);		//reset
//	errc=prg_comm(0x243,0,0,0,0,0,0,0,0);		//break
//	errc=prg_comm(0x242,0,0,0,0,0,0,0,0);		//un-reset
	avrjtag_wocd(0,0x0000,2);	//set breakpoint at 0
	avrjtag_wocd(13,0xC000,2);	//enable OCD
	avrjtag_wocd(8,0x8898,2);	//enable break at PSB0

	usleep(250000);
	
//	errc=prg_comm(0x243,0,0,0,0,0,0,0,0);		//break
	show_avr_registers_t1(1);	
/*			
	show_avr_debug_regs();

	show_avr_registers_t1(1);		

	show_avr_registers_t1(1);		
*/

	j=0;

	do
	{
		printf("DBG>");
		
		i=getline(&dbg_line,&dbg_len,stdin);
		if(i>1)
		{
			//quit
			if((strstr(dbg_line,"q")-dbg_line) == 0) j=999;
		
			//step
			if((strstr(dbg_line,"s")-dbg_line) == 0)
			{
				i=avrjtag_rocd(8,3) | 0x0000;
				avrjtag_wocd(8,i & 0xFFFF,3);
				prg_comm(0x244,0,0,0,0,0,0,0,0);	
				usleep(1000);
				errc=prg_comm(0x243,0,0,0,0,0,0,0,0);		//break					
				show_avr_registers_t1(1);		
			}
		
			//cont
			if((strstr(dbg_line,"c")-dbg_line) == 0)
			{
				errc=prg_comm(0x244,0,0,0,0,0,0,0,0);		// run
				waitkey_dbg2();
				errc=prg_comm(0x243,0,0,0,0,0,0,0,0);		//break
				show_avr_registers_t1(1);		
			}
		
			//go
			if((strstr(dbg_line,"g")-dbg_line) == 0)
			{
				dbg_addr=0;dbg_ptr=dbg_line;
				while(*dbg_ptr > 0x20) dbg_ptr++;	//sarch for space or end
				
				if(*dbg_ptr == 0x20)
				{				
					while(*dbg_ptr == 0x20) dbg_ptr++;	//sarch for no space
					if(*dbg_ptr > 0x20)
					{				
						while(*dbg_ptr > 0x20) 
						{
							c=*dbg_ptr;if(c > 0x60) c-=0x20;
							
							if(c==0x30) dbg_addr = (dbg_addr << 4) + 0;if(c==0x31) dbg_addr = (dbg_addr << 4) + 1;
							if(c==0x32) dbg_addr = (dbg_addr << 4) + 2;if(c==0x33) dbg_addr = (dbg_addr << 4) + 3;
							if(c==0x34) dbg_addr = (dbg_addr << 4) + 4;if(c==0x35) dbg_addr = (dbg_addr << 4) + 5;
							if(c==0x36) dbg_addr = (dbg_addr << 4) + 6;if(c==0x37) dbg_addr = (dbg_addr << 4) + 7;
							if(c==0x38) dbg_addr = (dbg_addr << 4) + 8;if(c==0x39) dbg_addr = (dbg_addr << 4) + 9;
							if(c==0x41) dbg_addr = (dbg_addr << 4) + 10;if(c==0x42) dbg_addr = (dbg_addr << 4) + 11;
							if(c==0x43) dbg_addr = (dbg_addr << 4) + 12;if(c==0x44) dbg_addr = (dbg_addr << 4) + 13;
							if(c==0x45) dbg_addr = (dbg_addr << 4) + 14;if(c==0x46) dbg_addr = (dbg_addr << 4) + 15;
							dbg_addr &= 0xffff;	dbg_ptr++;
						}
						//OK we have the address		
						errc=prg_comm(0x205,4,0,0,0,dbg_addr & 0xff,(dbg_addr >> 8) & 0xff,0,0x4B);	//set pc
						errc=prg_comm(0x206,0,1,0,0,0,0,0,0);		//get BDC status	
//							printf("STATUS = %02X\n",memory[0]);
						errc=prg_comm(0x200,0,0,0,0,0,0,0,0x08);	// run
						waitkey_dbg2();
													
						errc=prg_comm(0x2b,0,2,0,0,0,0,0,0);		//re-init
						if(memory[0] == 0)
						{
							printf("Connection lost\n");
						}
					}
					else
					{
						printf("!! ADDRESS IS MISSING !!\n");
					}
				}	
				else
				{
					printf("!! ADDRESS IS MISSING !!\n");
				}
			}
		
			//breakpoint
			if((strstr(dbg_line,"b")-dbg_line) == 0)
			{	
				dbg_addr=0;dbg_ptr=dbg_line;
				while(*dbg_ptr > 0x20) dbg_ptr++;	//sarch for space or end
				
				if(*dbg_ptr == 0x20)
				{				
					while(*dbg_ptr == 0x20) dbg_ptr++;	//sarch for no space
					if(*dbg_ptr > 0x20)
					{				
						while(*dbg_ptr > 0x20) 
						{
							c=*dbg_ptr;if(c > 0x60) c-=0x20;
							
							if(c==0x30) dbg_addr = (dbg_addr << 4) + 0;if(c==0x31) dbg_addr = (dbg_addr << 4) + 1;
							if(c==0x32) dbg_addr = (dbg_addr << 4) + 2;if(c==0x33) dbg_addr = (dbg_addr << 4) + 3;
							if(c==0x34) dbg_addr = (dbg_addr << 4) + 4;if(c==0x35) dbg_addr = (dbg_addr << 4) + 5;
							if(c==0x36) dbg_addr = (dbg_addr << 4) + 6;if(c==0x37) dbg_addr = (dbg_addr << 4) + 7;
							if(c==0x38) dbg_addr = (dbg_addr << 4) + 8;if(c==0x39) dbg_addr = (dbg_addr << 4) + 9;
							if(c==0x41) dbg_addr = (dbg_addr << 4) + 10;if(c==0x42) dbg_addr = (dbg_addr << 4) + 11;
							if(c==0x43) dbg_addr = (dbg_addr << 4) + 12;if(c==0x44) dbg_addr = (dbg_addr << 4) + 13;
							if(c==0x45) dbg_addr = (dbg_addr << 4) + 14;if(c==0x46) dbg_addr = (dbg_addr << 4) + 15;
							dbg_addr &= 0xffff;	dbg_ptr++;
						}
						//OK we have the address
						printf("SET BP TO 0x%04X, ",dbg_addr);				
						errc=prg_comm(0x205,4,0,0,0,dbg_addr & 0xff,(dbg_addr >> 8) & 0xff,0,0xC2);	//set bp	

						errc=prg_comm(0x204,0,0,0,0,0xB8,0,0,0xC4);		//enable breakpoint
						errc=prg_comm(0x200,0,0,0,0,0,0,0,0x08);	//RUN	
						printf("PRESS ESC TO BREAK MANUALLY\n");	
						do
						{
							usleep(10000);
							if(get_currentkey() == 0x1B) 
							{							
							
								errc=prg_comm(0x2b,0,2,0,0,0,0,0,0);		//re-init
								if(memory[0] == 0)
								{
									printf("Connection lost\n");
								}
							}	
							prg_comm(0x206,0,1,0,0,0,0,0,0); //check if debug

						}
						while((memory[0] & 0x40) == 0);
						errc=prg_comm(0x204,0,0,0,0,0x98,0,0,0xc4);	//disable breakpoint
						printf("\r");show_avr_registers_t1(1);			
					}	
				}			
			}			

			//write reg A
			if((strstr(dbg_line,"A=")-dbg_line) == 0)
			{	
				dbg_val=0;dbg_ptr=dbg_line;
				while(*dbg_ptr > 0x20) dbg_ptr++;	//sarch for space or end
				
				if(*dbg_ptr == 0x20)
				{				
					while(*dbg_ptr == 0x20) dbg_ptr++;	//sarch for no space
					if(*dbg_ptr > 0x20)
					{				
						while(*dbg_ptr > 0x20) 
						{
							c=*dbg_ptr;if(c > 0x60) c-=0x20;
							
							if(c==0x30) dbg_val = (dbg_val << 4) + 0;if(c==0x31) dbg_val = (dbg_val << 4) + 1;
							if(c==0x32) dbg_val = (dbg_val << 4) + 2;if(c==0x33) dbg_val = (dbg_val << 4) + 3;
							if(c==0x34) dbg_val = (dbg_val << 4) + 4;if(c==0x35) dbg_val = (dbg_val << 4) + 5;
							if(c==0x36) dbg_val = (dbg_val << 4) + 6;if(c==0x37) dbg_val = (dbg_val << 4) + 7;
							if(c==0x38) dbg_val = (dbg_val << 4) + 8;if(c==0x39) dbg_val = (dbg_val << 4) + 9;
							if(c==0x41) dbg_val = (dbg_val << 4) + 10;if(c==0x42) dbg_val = (dbg_val << 4) + 11;
							if(c==0x43) dbg_val = (dbg_val << 4) + 12;if(c==0x44) dbg_val = (dbg_val << 4) + 13;
							if(c==0x45) dbg_val = (dbg_val << 4) + 14;if(c==0x46) dbg_val = (dbg_val << 4) + 15;
							dbg_val &= 0xff;	dbg_ptr++;
						}
						//OK we have the data
						errc=prg_comm(0x204,8,0,0,0,dbg_val,0,0,0x48);
						show_avr_registers_t1(1);
					}	
				}			
			}			


			//write reg HX
			if((strstr(dbg_line,"HX=")-dbg_line) == 0)
			{	
				dbg_val=0;dbg_ptr=dbg_line;
				while(*dbg_ptr > 0x20) dbg_ptr++;	//sarch for space or end
				
				if(*dbg_ptr == 0x20)
				{				
					while(*dbg_ptr == 0x20) dbg_ptr++;	//sarch for no space
					if(*dbg_ptr > 0x20)
					{				
						while(*dbg_ptr > 0x20) 
						{
							c=*dbg_ptr;if(c > 0x60) c-=0x20;
							
							if(c==0x30) dbg_val = (dbg_val << 4) + 0;if(c==0x31) dbg_val = (dbg_val << 4) + 1;
							if(c==0x32) dbg_val = (dbg_val << 4) + 2;if(c==0x33) dbg_val = (dbg_val << 4) + 3;
							if(c==0x34) dbg_val = (dbg_val << 4) + 4;if(c==0x35) dbg_val = (dbg_val << 4) + 5;
							if(c==0x36) dbg_val = (dbg_val << 4) + 6;if(c==0x37) dbg_val = (dbg_val << 4) + 7;
							if(c==0x38) dbg_val = (dbg_val << 4) + 8;if(c==0x39) dbg_val = (dbg_val << 4) + 9;
							if(c==0x41) dbg_val = (dbg_val << 4) + 10;if(c==0x42) dbg_val = (dbg_val << 4) + 11;
							if(c==0x43) dbg_val = (dbg_val << 4) + 12;if(c==0x44) dbg_val = (dbg_val << 4) + 13;
							if(c==0x45) dbg_val = (dbg_val << 4) + 14;if(c==0x46) dbg_val = (dbg_val << 4) + 15;
							dbg_val &= 0xffff;	dbg_ptr++;
						}
						//OK we have the data
						errc=prg_comm(0x205,0,0,0,0,dbg_val & 0xff,(dbg_val >> 8) & 0xff,0,0x4C);
						show_avr_registers_t1(1);
					}	
				}			
			}
			
			//write reg SP
			if((strstr(dbg_line,"SP=")-dbg_line) == 0)
			{	
				dbg_val=0;dbg_ptr=dbg_line;
				while(*dbg_ptr > 0x20) dbg_ptr++;	//sarch for space or end
				
				if(*dbg_ptr == 0x20)
				{				
					while(*dbg_ptr == 0x20) dbg_ptr++;	//sarch for no space
					if(*dbg_ptr > 0x20)
					{				
						while(*dbg_ptr > 0x20) 
						{
							c=*dbg_ptr;if(c > 0x60) c-=0x20;
							
							if(c==0x30) dbg_val = (dbg_val << 4) + 0;if(c==0x31) dbg_val = (dbg_val << 4) + 1;
							if(c==0x32) dbg_val = (dbg_val << 4) + 2;if(c==0x33) dbg_val = (dbg_val << 4) + 3;
							if(c==0x34) dbg_val = (dbg_val << 4) + 4;if(c==0x35) dbg_val = (dbg_val << 4) + 5;
							if(c==0x36) dbg_val = (dbg_val << 4) + 6;if(c==0x37) dbg_val = (dbg_val << 4) + 7;
							if(c==0x38) dbg_val = (dbg_val << 4) + 8;if(c==0x39) dbg_val = (dbg_val << 4) + 9;
							if(c==0x41) dbg_val = (dbg_val << 4) + 10;if(c==0x42) dbg_val = (dbg_val << 4) + 11;
							if(c==0x43) dbg_val = (dbg_val << 4) + 12;if(c==0x44) dbg_val = (dbg_val << 4) + 13;
							if(c==0x45) dbg_val = (dbg_val << 4) + 14;if(c==0x46) dbg_val = (dbg_val << 4) + 15;
							dbg_val &= 0xffff;	dbg_ptr++;
						}
						//OK we have the data
						errc=prg_comm(0x205,0,0,0,0,dbg_val & 0xff,(dbg_val >> 8) & 0xff,0,0x4F);
						show_avr_registers_t1(1);
					}	
				}			
			}

			//read bytes
			if((strstr(dbg_line,"rb")-dbg_line) == 0)
			{	
				dbg_addr=0;dbg_ptr=dbg_line;
				while(*dbg_ptr > 0x20) dbg_ptr++;	//sarch for space or end
				
				if(*dbg_ptr == 0x20)
				{				
					while(*dbg_ptr == 0x20) dbg_ptr++;	//sarch for no space
					if(*dbg_ptr > 0x20)
					{				
						while(*dbg_ptr > 0x20) 
						{
							c=*dbg_ptr;if(c > 0x60) c-=0x20;
							
							if(c==0x30) dbg_addr = (dbg_addr << 4) + 0;if(c==0x31) dbg_addr = (dbg_addr << 4) + 1;
							if(c==0x32) dbg_addr = (dbg_addr << 4) + 2;if(c==0x33) dbg_addr = (dbg_addr << 4) + 3;
							if(c==0x34) dbg_addr = (dbg_addr << 4) + 4;if(c==0x35) dbg_addr = (dbg_addr << 4) + 5;
							if(c==0x36) dbg_addr = (dbg_addr << 4) + 6;if(c==0x37) dbg_addr = (dbg_addr << 4) + 7;
							if(c==0x38) dbg_addr = (dbg_addr << 4) + 8;if(c==0x39) dbg_addr = (dbg_addr << 4) + 9;
							if(c==0x41) dbg_addr = (dbg_addr << 4) + 10;if(c==0x42) dbg_addr = (dbg_addr << 4) + 11;
							if(c==0x43) dbg_addr = (dbg_addr << 4) + 12;if(c==0x44) dbg_addr = (dbg_addr << 4) + 13;
							if(c==0x45) dbg_addr = (dbg_addr << 4) + 14;if(c==0x46) dbg_addr = (dbg_addr << 4) + 15;
							dbg_addr &= 0xffff;	dbg_ptr++;
						}
						//OK we have the address
						errc=prg_comm(0x17,0,16,0,0,dbg_addr & 0xff,(dbg_addr >> 8) & 0xff,16,0);
						show_bdata1(0,16,dbg_addr);
					}	
				}			
			}			


			//read words
			if((strstr(dbg_line,"rw")-dbg_line) == 0)
			{	
				dbg_addr=0;dbg_ptr=dbg_line;
				while(*dbg_ptr > 0x20) dbg_ptr++;	//sarch for space or end
				
				if(*dbg_ptr == 0x20)
				{				
					while(*dbg_ptr == 0x20) dbg_ptr++;	//sarch for no space
					if(*dbg_ptr > 0x20)
					{				
						while(*dbg_ptr > 0x20) 
						{
							c=*dbg_ptr;if(c > 0x60) c-=0x20;
							
							if(c==0x30) dbg_addr = (dbg_addr << 4) + 0;if(c==0x31) dbg_addr = (dbg_addr << 4) + 1;
							if(c==0x32) dbg_addr = (dbg_addr << 4) + 2;if(c==0x33) dbg_addr = (dbg_addr << 4) + 3;
							if(c==0x34) dbg_addr = (dbg_addr << 4) + 4;if(c==0x35) dbg_addr = (dbg_addr << 4) + 5;
							if(c==0x36) dbg_addr = (dbg_addr << 4) + 6;if(c==0x37) dbg_addr = (dbg_addr << 4) + 7;
							if(c==0x38) dbg_addr = (dbg_addr << 4) + 8;if(c==0x39) dbg_addr = (dbg_addr << 4) + 9;
							if(c==0x41) dbg_addr = (dbg_addr << 4) + 10;if(c==0x42) dbg_addr = (dbg_addr << 4) + 11;
							if(c==0x43) dbg_addr = (dbg_addr << 4) + 12;if(c==0x44) dbg_addr = (dbg_addr << 4) + 13;
							if(c==0x45) dbg_addr = (dbg_addr << 4) + 14;if(c==0x46) dbg_addr = (dbg_addr << 4) + 15;
							dbg_addr &= 0xffff;	dbg_ptr++;
						}
						//OK we have the address
						memory[0]=4;			
						errc=prg_comm(0x17,0,16,0,0,dbg_addr & 0xff,(dbg_addr >> 8) & 0xff,16,0);
						show_wdata1(0,8,dbg_addr);
					}	
				}			
			}			

		
			//write word
			if((strstr(dbg_line,"ww")-dbg_line) == 0)
			{	
				dbg_addr=0;dbg_ptr=dbg_line;
				while(*dbg_ptr > 0x20) dbg_ptr++;	//sarch for space or end
				
				if(*dbg_ptr == 0x20)
				{				
					while(*dbg_ptr == 0x20) dbg_ptr++;	//sarch for no space
					if(*dbg_ptr > 0x20)
					{				
						while(*dbg_ptr > 0x20) 
						{
							c=*dbg_ptr;if(c > 0x60) c-=0x20;
							
							if(c==0x30) dbg_addr = (dbg_addr << 4) + 0;if(c==0x31) dbg_addr = (dbg_addr << 4) + 1;
							if(c==0x32) dbg_addr = (dbg_addr << 4) + 2;if(c==0x33) dbg_addr = (dbg_addr << 4) + 3;
							if(c==0x34) dbg_addr = (dbg_addr << 4) + 4;if(c==0x35) dbg_addr = (dbg_addr << 4) + 5;
							if(c==0x36) dbg_addr = (dbg_addr << 4) + 6;if(c==0x37) dbg_addr = (dbg_addr << 4) + 7;
							if(c==0x38) dbg_addr = (dbg_addr << 4) + 8;if(c==0x39) dbg_addr = (dbg_addr << 4) + 9;
							if(c==0x41) dbg_addr = (dbg_addr << 4) + 10;if(c==0x42) dbg_addr = (dbg_addr << 4) + 11;
							if(c==0x43) dbg_addr = (dbg_addr << 4) + 12;if(c==0x44) dbg_addr = (dbg_addr << 4) + 13;
							if(c==0x45) dbg_addr = (dbg_addr << 4) + 14;if(c==0x46) dbg_addr = (dbg_addr << 4) + 15;
							dbg_addr &= 0xffff;	dbg_ptr++;
						}
						
						//OK we have the address
						dbg_val=0;
						if(*dbg_ptr == 0x20)
						{				
							while(*dbg_ptr == 0x20) dbg_ptr++;	//sarch for no space
							if(*dbg_ptr > 0x20)
							{				
								while(*dbg_ptr > 0x20) 
								{
									c=*dbg_ptr;if(c > 0x60) c-=0x20;
							
									if(c==0x30) dbg_val = (dbg_val << 4) + 0;if(c==0x31) dbg_val = (dbg_val << 4) + 1;
									if(c==0x32) dbg_val = (dbg_val << 4) + 2;if(c==0x33) dbg_val = (dbg_val << 4) + 3;
									if(c==0x34) dbg_val = (dbg_val << 4) + 4;if(c==0x35) dbg_val = (dbg_val << 4) + 5;
									if(c==0x36) dbg_val = (dbg_val << 4) + 6;if(c==0x37) dbg_val = (dbg_val << 4) + 7;
									if(c==0x38) dbg_val = (dbg_val << 4) + 8;if(c==0x39) dbg_val = (dbg_val << 4) + 9;
									if(c==0x41) dbg_val = (dbg_val << 4) + 10;if(c==0x42) dbg_val = (dbg_val << 4) + 11;
									if(c==0x43) dbg_val = (dbg_val << 4) + 12;if(c==0x44) dbg_val = (dbg_val << 4) + 13;
									if(c==0x45) dbg_val = (dbg_val << 4) + 14;if(c==0x46) dbg_val = (dbg_val << 4) + 15;
									dbg_val &= 0xffff;	dbg_ptr++;
								}
						
								//OK we have the data
								memory[0]=(dbg_val) & 0xff;			
								memory[1]=(dbg_val >> 8) & 0xff;			
								errc=prg_comm(0x18,2,0,0,0,dbg_addr & 0xff,dbg_addr >> 8,2,0);	//write 2 bytes
								
							}
						}
					}	
				}			
			}			

			//write byte
			if((strstr(dbg_line,"wb")-dbg_line) == 0)
			{	
				dbg_addr=0;dbg_ptr=dbg_line;
				while(*dbg_ptr > 0x20) dbg_ptr++;	//sarch for space or end
				
				if(*dbg_ptr == 0x20)
				{				
					while(*dbg_ptr == 0x20) dbg_ptr++;	//sarch for no space
					if(*dbg_ptr > 0x20)
					{				
						while(*dbg_ptr > 0x20) 
						{
							c=*dbg_ptr;if(c > 0x60) c-=0x20;
							
							if(c==0x30) dbg_addr = (dbg_addr << 4) + 0;if(c==0x31) dbg_addr = (dbg_addr << 4) + 1;
							if(c==0x32) dbg_addr = (dbg_addr << 4) + 2;if(c==0x33) dbg_addr = (dbg_addr << 4) + 3;
							if(c==0x34) dbg_addr = (dbg_addr << 4) + 4;if(c==0x35) dbg_addr = (dbg_addr << 4) + 5;
							if(c==0x36) dbg_addr = (dbg_addr << 4) + 6;if(c==0x37) dbg_addr = (dbg_addr << 4) + 7;
							if(c==0x38) dbg_addr = (dbg_addr << 4) + 8;if(c==0x39) dbg_addr = (dbg_addr << 4) + 9;
							if(c==0x41) dbg_addr = (dbg_addr << 4) + 10;if(c==0x42) dbg_addr = (dbg_addr << 4) + 11;
							if(c==0x43) dbg_addr = (dbg_addr << 4) + 12;if(c==0x44) dbg_addr = (dbg_addr << 4) + 13;
							if(c==0x45) dbg_addr = (dbg_addr << 4) + 14;if(c==0x46) dbg_addr = (dbg_addr << 4) + 15;
							dbg_addr &= 0xffff;	dbg_ptr++;
						}
						
						//OK we have the address
						dbg_val=0;
						if(*dbg_ptr == 0x20)
						{				
							while(*dbg_ptr == 0x20) dbg_ptr++;	//sarch for no space
							if(*dbg_ptr > 0x20)
							{				
								while(*dbg_ptr > 0x20) 
								{
									c=*dbg_ptr;if(c > 0x60) c-=0x20;
							
									if(c==0x30) dbg_val = (dbg_val << 4) + 0;if(c==0x31) dbg_val = (dbg_val << 4) + 1;
									if(c==0x32) dbg_val = (dbg_val << 4) + 2;if(c==0x33) dbg_val = (dbg_val << 4) + 3;
									if(c==0x34) dbg_val = (dbg_val << 4) + 4;if(c==0x35) dbg_val = (dbg_val << 4) + 5;
									if(c==0x36) dbg_val = (dbg_val << 4) + 6;if(c==0x37) dbg_val = (dbg_val << 4) + 7;
									if(c==0x38) dbg_val = (dbg_val << 4) + 8;if(c==0x39) dbg_val = (dbg_val << 4) + 9;
									if(c==0x41) dbg_val = (dbg_val << 4) + 10;if(c==0x42) dbg_val = (dbg_val << 4) + 11;
									if(c==0x43) dbg_val = (dbg_val << 4) + 12;if(c==0x44) dbg_val = (dbg_val << 4) + 13;
									if(c==0x45) dbg_val = (dbg_val << 4) + 14;if(c==0x46) dbg_val = (dbg_val << 4) + 15;
									dbg_val &= 0xff;	dbg_ptr++;
								}
						
								//OK we have the data
								memory[0]=(dbg_val) & 0xff;			
							//	printf("ADDR=%04X    DATA=%02X\n",dbg_addr,dbg_val);
								errc=prg_comm(0x18,2,0,0,0,dbg_addr & 0xff,dbg_addr >> 8,1,0);	//write 1 byte
							}
						}
					}	
				}			
			}			
		}
		else
		{
			printf("q            : Quit\n");
			printf("s            : Step\n");
			printf("c            : Continue\n");
			printf("g addr       : Go\n");
			printf("b addr       : Set breakpoint and continue\n");
			printf("A= data      : Set processor register A\n");
			printf("HX= data     : Set processor register HX\n");
			printf("SP= data     : Set processor stack pointer\n");
			printf("rb addr      : Read memory (16 bytes from addr)\n");
			printf("rw addr      : Read memory (8 words from addr)\n");
			printf("wb addr data : Write memory (1 byte)\n");
			printf("ww addr data : Write memory (1 word)\n\n");
		}

	}while(j == 0);	//quit

	errc=prg_comm(0x241,0,0,0,0,0,0,0,0);	//exit debug

}
	
