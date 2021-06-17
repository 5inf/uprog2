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


void show_cortex_registers(void)
{
	int i;
	i=0;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=1;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=2;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=3;printf("R%d : %02X%02X%02X%02X\n",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);

	i=4;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=5;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=6;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=7;printf("R%d : %02X%02X%02X%02X\n",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);

	i=8;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=9;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=10;printf("R%d: %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=11;printf("R%d: %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=12;printf("R%d: %02X%02X%02X%02X\n",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);

	i=13;printf("SP : %02X%02X%02X%02X\n",memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=14;printf("LR : %02X%02X%02X%02X\n",memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=15;printf("PC : %02X%02X%02X%02X --> ",memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);

	i=16;
		if((memory[i*4-4] & 0x02) == 0x02)
		{
			printf("%02X%02X %02X%02X %02X%02X\n",memory[67],memory[66],memory[69],memory[68],memory[71],memory[70]);
		}
		else
		{
			printf("%02X%02X %02X%02X %02X%02X\n",memory[65],memory[64],memory[67],memory[66],memory[69],memory[68]);
		}

	printf("\n");
}


void debug_armcortex(int mode)
{
	int errc,blocks,tblock,bsize,i,j,eblock=0;
	unsigned long len,addr,maddr;

	int debug_flash=0;
	size_t dbg_len=80;
	char *dbg_line;
	char *dbg_ptr;
	char c;
	unsigned long dbg_addr,dbg_val;
	
	dbg_line=malloc(100);
	

	//debug code in RAM
	if(mode == 0)
	{
		len = read_block(param[4],param[5],0);
		printf("BYTES= %04lX\n",len);
		if(len < 8)
		{	
			len = read_block(0,param[5],0);	//read from addr 0
			printf("LOW BYTES= %04lX\n",len);
		}

		printf("TRANSFER & STEP CODE\n");
		addr=param[4];
		maddr=0;
		blocks=(param[5]+2047) >> 11;

		progress("TRANSFER ",blocks,0);

		for(i=0;i<blocks;i++)
		{
			errc=prg_comm(0xb2,max_blocksize,0,maddr,0,		//write 1.K
				(addr >> 8) & 0xff,
				(addr >> 16) & 0xff,
				0x20,max_blocksize >> 8);
		
			addr+=max_blocksize;
			maddr+=max_blocksize;
			progress("TRANSFER ",blocks,i+1);
		}


		addr=param[4];

		printf("\nSTART CODE AT 0x%02x%02x%02x%02x\n",memory[7],memory[6],memory[5],memory[4] & 0xFE);
		
		errc=prg_comm(0x128,8,12,0,0,0,0,0,0);	//set pc + sp	

		errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
		show_cortex_registers();		

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
					errc=prg_comm(0x129,0,100,0,0,0,0,0,0);	
					show_cortex_registers();		
				}
			
				//cont
				if((strstr(dbg_line,"c")-dbg_line) == 0)
				{
					errc=prg_comm(0x12B,0,0,0,0,0,0,0,0);		// run
					waitkey_dbg2();
				
					errc=prg_comm(0x23b,0,100,0,0,0,0,0,0);		// halt	
					show_cortex_registers();	
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the address		
							memory[0]=15;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_addr & 0xff;			
							memory[5]=(dbg_addr >> 8) & 0xff;			
							memory[6]=(dbg_addr >> 16) & 0xff;			
							memory[7]=(dbg_addr >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);		// write register
							errc=prg_comm(0x12B,0,0,0,0,0,0,0,0);		// run
							waitkey_dbg2();
				
							errc=prg_comm(0x23b,0,100,0,0,0,0,0,0);		// halt	
							show_cortex_registers();
						}
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the address		
							errc=prg_comm(0x238,0,24,0,0,dbg_addr & 0xff, (dbg_addr >> 8) & 0xff, (dbg_addr >> 16) & 0xff, (dbg_addr >> 24) & 0xff);	
							errc=prg_comm(0x12B,0,0,0,0,0,0,0,0);	//RUN	
							printf("PRESS ESC TO BREAK MANUALLY\n");	
							do
							{
								usleep(10000);
								if(get_currentkey() == 0x1B) prg_comm(0x129,0,100,0,0,0,0,0,0);		//force debug
								prg_comm(0x23A,0,4,0,0,0,0,0,0); //check if breakpoint

							}
							while((memory[2] & 2) == 0);
				
							errc=prg_comm(0x239,0,0,0,0,0,0,0,0);	//clear breakpoint
							errc=prg_comm(0x12A,0,100,0,0,0,0,0,0); //read registers
							printf("\r");show_cortex_registers();			
						}	
					}			
				}			

				//write reg 0
				if((strstr(dbg_line,"r0=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=0;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}			


				//write reg 1
				if((strstr(dbg_line,"r1=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=1;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 2
				if((strstr(dbg_line,"r2=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=2;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 3
				if((strstr(dbg_line,"r3=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=3;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 4
				if((strstr(dbg_line,"r4=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=4;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 5
				if((strstr(dbg_line,"r5=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=5;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 6
				if((strstr(dbg_line,"r6=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=6;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 7
				if((strstr(dbg_line,"r7=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=7;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 8
				if((strstr(dbg_line,"r8=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=8;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 9
				if((strstr(dbg_line,"r9=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=9;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}			
			
				//write reg 10
				if((strstr(dbg_line,"r10=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=10;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 11
				if((strstr(dbg_line,"r11=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=11;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 12
				if((strstr(dbg_line,"r12=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=12;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
						
				//write reg 13
				if((strstr(dbg_line,"r13=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=13;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}	
						
				//write reg 14
				if((strstr(dbg_line,"r14=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=14;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}			


				//write reg 15
				if((strstr(dbg_line,"r15=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=15;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the address
							memory[0]=4;			
							errc=prg_comm(0x23c,4,32,0,0,dbg_addr & 0xff,(dbg_addr >> 8) & 0xff,(dbg_addr >> 16) & 0xff,(dbg_addr >> 24) & 0xff);
							show_bdata(0,16,dbg_addr);
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the address
							memory[0]=4;			
							errc=prg_comm(0x23c,4,32,0,0,dbg_addr & 0xff,(dbg_addr >> 8) & 0xff,(dbg_addr >> 16) & 0xff,(dbg_addr >> 24) & 0xff);
							show_wdata(0,16,dbg_addr);
						}	
					}			
				}			


				//read longs
				if((strstr(dbg_line,"rl")-dbg_line) == 0)
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the address
							memory[0]=4;			
							errc=prg_comm(0x23c,4,32,0,0,dbg_addr & 0xff,(dbg_addr >> 8) & 0xff,(dbg_addr >> 16) & 0xff,(dbg_addr >> 24) & 0xff);
							show_ldata(0,16,dbg_addr);
						}	
					}			
				}			


				//write long
				if((strstr(dbg_line,"wl")-dbg_line) == 0)
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
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
										dbg_val &= 0xffffffff;	dbg_ptr++;
									}
							
									//OK we have the data
									memory[0]=dbg_addr & 0xfc;			
									memory[1]=(dbg_addr >> 8) & 0xff;			
									memory[2]=(dbg_addr >> 16) & 0xff;			
									memory[3]=(dbg_addr >> 24) & 0xff;			
									memory[4]=dbg_val & 0xff;			
									memory[5]=(dbg_val >> 8) & 0xff;			
									memory[6]=(dbg_val >> 16) & 0xff;			
									memory[7]=(dbg_val >> 24) & 0xff;			
									errc=prg_comm(0x23d,8,0,0,0,0,0,0,0);
								}
							}
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
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
										dbg_val &= 0xffffffff;	dbg_ptr++;
									}
							
									//OK we have the data
									memory[0]=dbg_addr & 0xfe;			
									memory[1]=(dbg_addr >> 8) & 0xff;			
									memory[2]=(dbg_addr >> 16) & 0xff;			
									memory[3]=(dbg_addr >> 24) & 0xff;			
									memory[4]=(dbg_val) & 0xff;			
									memory[5]=(dbg_val >> 8) & 0xff;			
									memory[6]=(dbg_val) & 0xff;			
									memory[7]=(dbg_val >> 8) & 0xff;			
									errc=prg_comm(0x23e,8,0,0,0,0,0,0,0);
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
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
										dbg_val &= 0xffffffff;	dbg_ptr++;
									}
							
									//OK we have the data
									memory[0]=dbg_addr & 0xff;			
									memory[1]=(dbg_addr >> 8) & 0xff;			
									memory[2]=(dbg_addr >> 16) & 0xff;			
									memory[3]=(dbg_addr >> 24) & 0xff;			
									memory[4]=(dbg_val) & 0xff;			
									memory[5]=(dbg_val) & 0xff;			
									memory[6]=(dbg_val) & 0xff;			
									memory[7]=(dbg_val) & 0xff;			
									errc=prg_comm(0x23f,8,0,0,0,0,0,0,0);
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
				printf("r0= data     : Set processor register 0\n");
				printf("r15= data    : Set processor register 15 (PC)\n");
				printf("rb addr      : Read memory (16 bytes from addr)\n");
				printf("rw addr      : Read memory (8 words from addr)\n");
				printf("rl addr      : Read memory (4 longs from addr)\n");
				printf("wb addr data : Write memory (1 byte)\n");
				printf("ww addr data : Write memory (1 word)\n");
				printf("wl addr data : Write memory (1 long)\n\n");
			}
	
		}while(j == 0);	//quit


	}

	//debug code in FLASH
	if(mode == 1)
	{
		addr=param[0];
	
		errc=prg_comm(0xbf,0,2048,0,0,
						(addr >> 8) & 0xff,
						(addr >> 16) & 0xff,
						(addr >> 24) & 0xff,
						max_blocksize >> 8);
	
		addr=param[4];

		printf("\nSTART CODE AT 0x%02x%02x%02x%02x\n",memory[7],memory[6],memory[5],memory[4] & 0xFE);
		
		errc=prg_comm(0x128,8,12,0,0,0,0,0,0);	//set pc + sp	
		errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
		show_cortex_registers();		

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
					errc=prg_comm(0x129,0,100,0,0,0,0,0,0);	
					show_cortex_registers();		
				}
			
				//continue
				if((strstr(dbg_line,"c")-dbg_line) == 0)
				{
					errc=prg_comm(0x12B,0,0,0,0,0,0,0,0);		// run
					waitkey_dbg2();
				
					errc=prg_comm(0x23b,0,100,0,0,0,0,0,0);		// halt	
					show_cortex_registers();	
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the address		
							memory[0]=15;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_addr & 0xff;			
							memory[5]=(dbg_addr >> 8) & 0xff;			
							memory[6]=(dbg_addr >> 16) & 0xff;			
							memory[7]=(dbg_addr >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);		// write register
							errc=prg_comm(0x12B,0,0,0,0,0,0,0,0);		// run
							waitkey_dbg2();
				
							errc=prg_comm(0x23b,0,100,0,0,0,0,0,0);		// halt	
							show_cortex_registers();
						}
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the address		
							errc=prg_comm(0x238,0,24,0,0,dbg_addr & 0xff, (dbg_addr >> 8) & 0xff, (dbg_addr >> 16) & 0xff, (dbg_addr >> 24) & 0xff);	
							errc=prg_comm(0x12B,0,0,0,0,0,0,0,0);	//RUN	
							printf("PRESS ESC TO BREAK MANUALLY\n");	
							do
							{
								usleep(10000);
								if(get_currentkey() == 0x1B) prg_comm(0x129,0,100,0,0,0,0,0,0);		//force debug
								prg_comm(0x23A,0,4,0,0,0,0,0,0); //check if breakpoint

							}
							while((memory[2] & 2) == 0);
				
							errc=prg_comm(0x239,0,0,0,0,0,0,0,0);	//clear breakpoint
							errc=prg_comm(0x12A,0,100,0,0,0,0,0,0); //read registers
							printf("\r");show_cortex_registers();			
						}	
					}			
				}			

				//write reg 0
				if((strstr(dbg_line,"r0=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=0;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}			

				//write reg 1
				if((strstr(dbg_line,"r1=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=1;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 2
				if((strstr(dbg_line,"r2=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=2;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 3
				if((strstr(dbg_line,"r3=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=3;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 4
				if((strstr(dbg_line,"r4=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=4;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 5
				if((strstr(dbg_line,"r5=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=5;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 6
				if((strstr(dbg_line,"r6=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=6;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 7
				if((strstr(dbg_line,"r7=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=7;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 8
				if((strstr(dbg_line,"r8=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=8;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 9
				if((strstr(dbg_line,"r9=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=9;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}			
			
				//write reg 10
				if((strstr(dbg_line,"r10=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=10;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 11
				if((strstr(dbg_line,"r11=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=11;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
				
				//write reg 12
				if((strstr(dbg_line,"r12=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=12;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}
						
				//write reg 13
				if((strstr(dbg_line,"r13=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=13;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}	
						
				//write reg 14
				if((strstr(dbg_line,"r14=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=14;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
						}	
					}			
				}			


				//write reg 15
				if((strstr(dbg_line,"r15=")-dbg_line) == 0)
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
								dbg_val &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the data
							memory[0]=15;			
							memory[1]=0;			
							memory[2]=1;			
							memory[3]=0;			

							memory[4]=dbg_val & 0xff;			
							memory[5]=(dbg_val >> 8) & 0xff;			
							memory[6]=(dbg_val >> 16) & 0xff;			
							memory[7]=(dbg_val >> 24) & 0xff;			
							errc=prg_comm(0x236,8,0,0,0,0,0,0,0);
							errc=prg_comm(0x12a,0,100,0,0,0,0,0,0);	
							show_cortex_registers();
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the address
							memory[0]=4;			
							errc=prg_comm(0x23c,4,32,0,0,dbg_addr & 0xff,(dbg_addr >> 8) & 0xff,(dbg_addr >> 16) & 0xff,(dbg_addr >> 24) & 0xff);
							show_bdata(0,16,dbg_addr);
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the address
							memory[0]=4;			
							errc=prg_comm(0x23c,4,32,0,0,dbg_addr & 0xff,(dbg_addr >> 8) & 0xff,(dbg_addr >> 16) & 0xff,(dbg_addr >> 24) & 0xff);
							show_wdata(0,16,dbg_addr);
						}	
					}			
				}			


				//read longs
				if((strstr(dbg_line,"rl")-dbg_line) == 0)
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
							}
							//OK we have the address
							memory[0]=4;			
							errc=prg_comm(0x23c,4,32,0,0,dbg_addr & 0xff,(dbg_addr >> 8) & 0xff,(dbg_addr >> 16) & 0xff,(dbg_addr >> 24) & 0xff);
							show_ldata(0,16,dbg_addr);
						}	
					}			
				}			


				//write long
				if((strstr(dbg_line,"wl")-dbg_line) == 0)
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
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
										dbg_val &= 0xffffffff;	dbg_ptr++;
									}
							
									//OK we have the data
									memory[0]=dbg_addr & 0xfc;			
									memory[1]=(dbg_addr >> 8) & 0xff;			
									memory[2]=(dbg_addr >> 16) & 0xff;			
									memory[3]=(dbg_addr >> 24) & 0xff;			
									memory[4]=dbg_val & 0xff;			
									memory[5]=(dbg_val >> 8) & 0xff;			
									memory[6]=(dbg_val >> 16) & 0xff;			
									memory[7]=(dbg_val >> 24) & 0xff;			
									errc=prg_comm(0x23d,8,0,0,0,0,0,0,0);
								}
							}
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
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
										dbg_val &= 0xffffffff;	dbg_ptr++;
									}
							
									//OK we have the data
									memory[0]=dbg_addr & 0xfe;			
									memory[1]=(dbg_addr >> 8) & 0xff;			
									memory[2]=(dbg_addr >> 16) & 0xff;			
									memory[3]=(dbg_addr >> 24) & 0xff;			
									memory[4]=(dbg_val) & 0xff;			
									memory[5]=(dbg_val >> 8) & 0xff;			
									memory[6]=(dbg_val) & 0xff;			
									memory[7]=(dbg_val >> 8) & 0xff;			
									errc=prg_comm(0x23e,8,0,0,0,0,0,0,0);
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
								dbg_addr &= 0xffffffff;	dbg_ptr++;
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
										dbg_val &= 0xffffffff;	dbg_ptr++;
									}
							
									//OK we have the data
									memory[0]=dbg_addr & 0xff;			
									memory[1]=(dbg_addr >> 8) & 0xff;			
									memory[2]=(dbg_addr >> 16) & 0xff;			
									memory[3]=(dbg_addr >> 24) & 0xff;			
									memory[4]=(dbg_val) & 0xff;			
									memory[5]=(dbg_val) & 0xff;			
									memory[6]=(dbg_val) & 0xff;			
									memory[7]=(dbg_val) & 0xff;			
									errc=prg_comm(0x23f,8,0,0,0,0,0,0,0);
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
				printf("r0= data     : Set processor register 0\n");
				printf("r15= data    : Set processor register 15 (PC)\n");
				printf("rb addr      : Read memory (16 bytes from addr)\n");
				printf("rw addr      : Read memory (8 words from addr)\n");
				printf("rl addr      : Read memory (4 longs from addr)\n");
				printf("wb addr data : Write memory (1 byte)\n");
				printf("ww addr data : Write memory (1 word)\n");
				printf("wl addr data : Write memory (1 long)\n\n");
			}
	
		}while(j == 0);	//quit
	}


	errc|=prg_comm(0x9A,0,0,0,0,0x00,0x00,0x00,0x00);			//exit debug
}

