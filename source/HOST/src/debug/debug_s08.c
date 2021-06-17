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

void show_s08_registers(void)
{
	prg_comm(0x202,0,16,0,0,0,0,0,0);	//read registers
	printf("A : %02X          CCR: %02X (",memory[0],memory[1]);
	if((memory[1] & 0x80) == 0) printf("v**"); else printf("V**");
	if((memory[1] & 0x10) == 0) printf("h"); else printf("H");
	if((memory[1] & 0x08) == 0) printf("i"); else printf("I");
	if((memory[1] & 0x04) == 0) printf("n"); else printf("N");
	if((memory[1] & 0x02) == 0) printf("z"); else printf("Z");
	if((memory[1] & 0x01) == 0) printf("c)\n"); else printf("C)\n");
	printf("HX: %02X %02X       SP : %02X%02X\n",memory[2],memory[3],memory[6],memory[7]);
/*
	if((memory[10] & 0x20) == 0)
		printf("BP: DIS (%02X%02X)  BDC: %02X\n",memory[8],memory[9],memory[10]);
	else
		printf("BP: %02X%02X        BDC: %02X\n",memory[8],memory[9],memory[10]);
*/
	printf("PC: %02X%02X  -> ",memory[4],memory[5]);
	prg_comm(0x17,0,4,0,0,memory[5],memory[4],4,0);	//read memory
	printf("%02X %02X %02X %02X\n",memory[0],memory[1],memory[2],memory[3]);
	
	printf("\n");
}


void debug_s08(int mode)
{
	int errc,blocks,tblock,bsize,i,j,eblock=0;
	unsigned short ramsize,ramstart,addr,len;
	float freq,bdmfreq;
	int bfreq;

	size_t dbg_len=80;
	char *dbg_line;
	char *dbg_ptr;
	char c;
	unsigned short dbg_addr,dbg_val;
	
	dbg_line=malloc(100);
	
	//debug in RAM
	if(mode == 0)
	{
		printf("TRANSFER & STEP CODE\n");
		len=read_block(param[8],param[9],param[8]);
		printf("BYTES= %04X\n",len);
		ramstart = param[8];
		ramsize = param[9];
		if(ramsize > max_blocksize) ramsize = max_blocksize;
		errc=prg_comm(0x18,ramsize,0,ramstart,0,ramstart & 0xff,ramstart >> 8,ramsize & 0xff,ramsize >> 8);	//write bytes

		addr=param[8];

//		printf("\nSTART CODE AT 0x%04X\n",addr);
		errc=prg_comm(0x205,0,0,0,0,addr & 0xff,(addr >> 8) & 0xff,0,0x4B);	//set pc	
		show_s08_registers();		

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
					errc=prg_comm(0x200,0,0,0,0,0,0,0,0x10);	
					show_s08_registers();		
				}
			
				//cont
				if((strstr(dbg_line,"c")-dbg_line) == 0)
				{
					errc=prg_comm(0x200,0,0,0,0,0,0,0,0x08);	// run
					waitkey_dbg2();
											
					errc=prg_comm(0x2b,0,2,0,0,0,0,0,0);		//re-init
					if(memory[0] == 0)
					{
						printf("Connection lost\n");
					}
					else
					{
						bdmfreq=512/memory[0];
						bfreq=(int)(bdmfreq + 0.5);
						printf("BDM FREQ = %2.1fMHz, USED MODE = %dMHz\n",bdmfreq,bfreq);
						usleep(1000);
						errc=prg_comm(0x204,0,0,0,0,0xC8,0,0,0xC4);		//enable BDM
						errc=prg_comm(0x200,0,0,0,0,0,0,0,0x90);		//halt	
						show_s08_registers();	
					}
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
							else
							{
								bdmfreq=512/memory[0];
								bfreq=(int)(bdmfreq + 0.5);
							//	printf("BDM FREQ = %2.1fMHz, USED MODE = %dMHz\n",bdmfreq,bfreq);	
								usleep(1000);

								errc=prg_comm(0x204,0,0,0,0,0xC8,0,0,0xC4);		//enable BDM
								errc=prg_comm(0x200,0,0,0,0,0,0,0,0x90);		//halt	
								show_s08_registers();
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
							errc=prg_comm(0x205,0,0,0,0,dbg_addr & 0xff,(dbg_addr >> 8) & 0xff,0,0xC2);	//set bp
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
									else
									{
										bdmfreq=512/memory[0];
										bfreq=(int)(bdmfreq + 0.5);
									//	printf("BDM FREQ = %2.1fMHz, USED MODE = %dMHz\n",bdmfreq,bfreq);	
										usleep(1000);

										errc=prg_comm(0x204,0,0,0,0,0xC8,0,0,0xC4);		//enable BDM
										errc=prg_comm(0x200,0,0,0,0,0,0,0,0x90);		//halt	
									}
								}	
								prg_comm(0x206,0,1,0,0,0,0,0,0); //check if debug

							}
							while((memory[0] & 0x40) == 0);
							errc=prg_comm(0x204,0,0,0,0,0x98,0,0,0xC4);	//disable breakpoint
							printf("\r");show_s08_registers();			
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
							show_s08_registers();
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
							show_s08_registers();
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
							show_s08_registers();
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


	}


	//debug in Flash
	if(mode == 0)
	{
		errc=prg_comm(0x17,0,16,0,0,0xFE,0xFF,2,0);

		addr=(memory[0] << 8) + memory[1];
		
//		printf("\nSTART CODE AT 0x%04X\n",addr);

//		memory[0]=addr & 0xff;
//		memory[1]=(addr >> 8) & 0xff;		
//		errc=prg_comm(0x243,4,0,0,0,0,0,0,0);	//set pc	
		show_s08_registers();		

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
					errc=prg_comm(0x200,0,0,0,0,0,0,0,0x10);	
					show_s08_registers();		
				}
			
				//cont
				if((strstr(dbg_line,"c")-dbg_line) == 0)
				{
					errc=prg_comm(0x200,0,0,0,0,0,0,0,0x08);	// run
					waitkey_dbg2();
											
					errc=prg_comm(0x2b,0,2,0,0,0,0,0,0);		//re-init
					if(memory[0] == 0)
					{
						printf("Connection lost\n");
					}
					else
					{
						bdmfreq=512/memory[0];
						bfreq=(int)(bdmfreq + 0.5);
						printf("BDM FREQ = %2.1fMHz, USED MODE = %dMHz\n",bdmfreq,bfreq);
						usleep(1000);
						errc=prg_comm(0x204,0,0,0,0,0xC8,0,0,0xC4);		//enable BDM
						errc=prg_comm(0x200,0,0,0,0,0,0,0,0x90);		//halt	
						show_s08_registers();	
					}
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
							errc=prg_comm(0x205,4,0,0,0,addr & 0xff,(addr >> 8) & 0xff,0,0x4B);	//set pc
							errc=prg_comm(0x206,0,1,0,0,0,0,0,0);		//get BDC status	
//							printf("STATUS = %02X\n",memory[0]);
							errc=prg_comm(0x200,0,0,0,0,0,0,0,0x08);	// run
							waitkey_dbg2();
														
							errc=prg_comm(0x2b,0,2,0,0,0,0,0,0);		//re-init
							if(memory[0] == 0)
							{
								printf("Connection lost\n");
							}
							else
							{
								bdmfreq=512/memory[0];
								bfreq=(int)(bdmfreq + 0.5);
							//	printf("BDM FREQ = %2.1fMHz, USED MODE = %dMHz\n",bdmfreq,bfreq);	
								usleep(1000);

								errc=prg_comm(0x204,0,0,0,0,0xC8,0,0,0xC4);		//enable BDM
								errc=prg_comm(0x200,0,0,0,0,0,0,0,0x90);		//halt	
								show_s08_registers();
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
									else
									{
										bdmfreq=512/memory[0];
										bfreq=(int)(bdmfreq + 0.5);
									//	printf("BDM FREQ = %2.1fMHz, USED MODE = %dMHz\n",bdmfreq,bfreq);	
										usleep(1000);

										errc=prg_comm(0x204,0,0,0,0,0xC8,0,0,0xC4);		//disable BDM
										errc=prg_comm(0x200,0,0,0,0,0,0,0,0x90);		//halt	
									}
								}	
								prg_comm(0x206,0,1,0,0,0,0,0,0); //check if debug

							}
							while((memory[0] & 0x40) == 0);
							errc=prg_comm(0x204,0,0,0,0,0x98,0,0,0xc4);	//disable breakpoint
							printf("\r");show_s08_registers();			
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
							show_s08_registers();
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
							show_s08_registers();
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
							show_s08_registers();
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


	}

	//	errc|=prg_comm(0x9A,0,0,0,0,0x00,0x00,0x00,0x00);			//exit debug
}
