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

void print_spieeprom_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(TIMEOUT)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_spieeprom(void)
{
	int errc,blocks,i,loops,maxloops,rstat;
	unsigned long addr,maddr,len;
	int bsize,bank;
	int main_erase=0;
	int main_prog=0;
	int main_verify=0;
	int main_readout=0;
	int unprotect=0;
	int protect=0;

	errc=0;


	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- un -- unprotect\n");
		printf("-- pr -- protect all\n");
		printf("-- em -- memory erase\n");
		printf("-- pm -- memory program\n");
		printf("-- vm -- memory verify\n");
		printf("-- rm -- memory read\n");
 		printf("-- d2 -- switch to device 2\n");

		return 0;
	}

	if(find_cmd("d2"))
	{
		errc=prg_comm(0x2ee,0,0,0,0,0,0,0,0);	//dev 2
		printf("## switch to device 2\n");
	}

	if(find_cmd("em"))
	{
		main_erase=1;
		printf("## Action: memory erase (overwrite)\n");
	}

	if(find_cmd("un"))
	{
		unprotect=1;
		printf("## Action: disable all write protection\n");
	}

	if(find_cmd("pr"))
	{
		protect=1;
		printf("## Action: enable all write protection\n");
	}


	main_prog=check_cmd_prog("pm","memory");
	main_verify=check_cmd_verify("vm","memory");
	main_readout=check_cmd_read("rm","memory",&main_prog,&main_verify);

	
	if(main_readout > 0)
	{
		errc=writeblock_open();
	}

	if(errc==0) 
	{
		errc=prg_comm(0x198,0,0,0,0,0,0,0,0);				//init
		errc=prg_comm(0x19C,0,1,0,0,0,0,0,0);				//get status
		if(errc==0)
		{
			if((memory[0] & 0x0c) == 0) 
				printf("## NO WRITE PROTECTION\n");
			else
				printf("## WRITE PROTECTION %02X\n",(memory[0] & 0x0c));
		}
	}

	
	if((unprotect == 1) && (errc == 0))
	{
		printf("DISABLE WRITE PROTECTION\n");
		errc=prg_comm(0x19D,0,0,0,0,0,0,0,param[13]);
	}	
	
	if((main_erase == 1) && (errc == 0))
	{
		len=param[1];
		for(i=0;i<param[1];i++) memory[i]=255;
		bsize=max_blocksize;
		if(param[1] < bsize) bsize=param[1];
		
		addr=param[0];
		blocks=len/bsize;
		maddr=0;

		progress("ERASE",blocks,0);
		
		for(i=0;i<blocks;i++)
		{
//			printf("BLOCK=%d   ADDR=%08lX  SIZE=%d\n",i,addr,bsize);
			if(param[15] == 1) errc=prg_comm(0x19B,bsize,0,maddr,0,
			(addr & 0xff),(addr >> 8) & 0xff,param[11],param[12]);
			if(param[15] == 2) errc=prg_comm(0x197,bsize,0,maddr,0,
			(addr & 0xff),(addr >> 8) & 0xff,param[11],param[12]);
			addr+=bsize;			
			maddr+=bsize;
			progress("ERASE",blocks,i+1);
			printf("\n");
		}

	}	


	if((main_prog == 1) && (errc == 0))
	{
		len=param[1];
		read_block(param[0],len,0);
		bsize=max_blocksize;
		if(param[1] < bsize) bsize=param[1];
		
		addr=param[0];
		blocks=len/bsize;
		maddr=0;

		progress("PROG ",blocks,0);
		
		for(i=0;i<blocks;i++)
		{
//			printf("BLOCK=%d   ADDR=%08lX  SIZE=%d\n",i,addr,bsize);
			if(param[15] == 1) errc=prg_comm(0x19B,bsize,0,maddr,0,
			(addr & 0xff),(addr >> 8) & 0xff,param[11],param[12]);
			if(param[15] == 2) errc=prg_comm(0x197,bsize,0,maddr,0,
			(addr & 0xff),(addr >> 8) & 0xff,param[11],param[12]);
			addr+=bsize;			
			maddr+=bsize;
			progress("PROG ",blocks,i+1);
			printf("\n");
		}
	}

	if(((main_readout == 1) || (main_verify == 1)) && (errc == 0))
	{
		len=param[1];
		bsize=max_blocksize;
		if(param[1] < bsize) bsize=param[1];
		
		addr=param[0];
		blocks=len/bsize;
		maddr=0;

			
		progress("READ ",blocks,0);
		for(i=0;i<blocks;i++)
		{
//			printf("BLOCK=%d   ADDR=%08lX\n",i,addr);
			if(errc == 0)
			{
				if(param[15] == 1) errc=prg_comm(0x19A,0,bsize,0,maddr+ROFFSET,
				(addr & 0xff),(addr >> 8) & 0xff,bsize & 0xff,bsize >> 8);		//blocks
				if(param[15] == 2) errc=prg_comm(0x196,0,bsize,0,maddr+ROFFSET,
				(addr & 0xff),(addr >> 8) & 0xff,bsize & 0xff,bsize >> 8);		//blocks
			}
			addr+=bsize;
			maddr+=bsize;
			progress("READ ",blocks,i+1);
		}
		printf("\n");
	}
	
	//verify main
	if((main_verify == 1) && (errc == 0))
	{
		read_block(param[0],len,0);
		maddr=param[0];		
		for(addr=maddr;addr<(maddr+len);addr++)

		if(memory[addr] != memory[addr+ROFFSET])
		{
			printf("ERR -> ADDR= %08lX  FILE= %02X  READ= %02X\n",
				addr,memory[addr],memory[addr+ROFFSET]);
			errc=1;
		}
	}

	if((main_readout == 1) && (errc == 0))
	{
//		printf("SAVE=%08lx   SIZE=%08lX\n",param[0],len);
		writeblock_data(0,len,param[0]+(bank << 24));
	}

	if(main_readout > 0)
	{
		writeblock_close();
	}

	
	if((protect == 1) && (errc == 0))
	{
		printf("ENABLE WRITE PROTECTION\n");
		errc=prg_comm(0x19D,0,0,0,0,0,0,0,param[14]);
	}	


	i=prg_comm(0x101,0,0,0,0,0,0,0,0);					//spieeprom exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_spieeprom_error(errc);

	return errc;
}







