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

void print_xc9500_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x51:	set_error("(compare error)",errc);
				break;

		case 0x52:	set_error("(DEVICE ID NOT MATCH)",errc);
				break;

		case 0x53:	set_error("(DEVICE IS PROTECTED)",errc);
				break;

		case 0x57:	set_error("(DEVICE IN SVF DOES NOT MATCH)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_xc9500(void)
{
	int errc,blocks,bsize,i,chunksize,chunks_per_block,chunks;
	unsigned long devid,maddr;
	int erase = 0;
	int program=0;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- el -- erase logic\n");
		printf("-- pl -- program logic\n");
		printf("-- st -- start device\n");
		printf("-- d2 -- switch to device 2\n");


		return 0;
	}

	if(find_cmd("d2"))
	{
		errc=prg_comm(0x2ee,0,0,0,0,0,0,0,0);	//dev 2
		printf("## switch to device 2\n");
	}

	if(param[2]==5)
	{
		errc=prg_comm(0xfb,0,0,0,0,0,0,0,0);	//5V mode
		printf("## using 5V VDD\n");
	}

	if(find_cmd("st"))
	{
		printf("## Action: start device\n");
		errc=prg_comm(0x0e,0,0,0,0,0,0,0,0);	//on
		waitkey();
		errc=prg_comm(0x0f,0,0,0,0,0,0,0,0);	//on
		return errc;
	}

	if(find_cmd("el"))
	{
		erase=1;
		printf("## Action: erase logic\n");
	}

	if(find_cmd("pl"))
	{
		if(file_found < 2)
		{
			program = 0;
			printf("## Action: program logic !! DISABLED BECAUSE OF NO FILE !!\n");
		}
		else
		{
			program=1;
			printf("## Action: program logic using %s\n",sfile);
		}
	}

	printf("\n");

	errc=prg_comm(0x10D,0,8,0,0,0,0,0,0);		//init and get ID
	
	devid=memory[0]+(memory[1] << 8)+(memory[2] << 16)+(memory[3] << 24);
	
//	if((devid & 0xF0000000) == 0x50000000) devid |= 0xF0000000;


	if(devid != param[10])
	{
		printf("DEVICE ID= %08lX, SHOULD BE %08lX\n",devid,param[10]);
		errc=0x52;
	}
	else
	{
		printf("DEVICE ID= %08lX\n",devid);
	}
	
	
	if((memory[4] != 0x01) || (memory[5] != 0x01) || (memory[6] != 0xAA))
	{
		printf("DEVICE IS PROTECTED (%02X)\n",memory[4]);
		errc=0x52;
	}
	else
	{
		printf("DEVICE IS NOT PROTECTED (%02X)\n",memory[4]);
	}
	 
	
	if((erase==1) && (errc==0) && (param[3]==1))
	{	
		printf("ERASE LOGIC\n");
		errc=prg_comm(0x108,0,2,0,0,param[4] & 0xff,param[4] >> 8,param[5] & 0xff,param[5] >> 8);	//erase XC9500
		if(errc != 0) printf("ERRCODE = %02X / %02X\n",memory[0],memory[1]);
	}
	if((erase==1) && (errc==0) && (param[3]==2))
	{	
		printf("ERASE LOGIC\n");
		errc=prg_comm(0x109,0,2,0,0,param[4] & 0xff,param[4] >> 8,param[5] & 0xff,param[5] >> 8);	//erase XC9500XL
		if(errc != 0) printf("ERRCODE = %02X%02X%02X\n",memory[2],memory[1],memory[0]);
	}
	
	if((program==1) && (errc==0) && (param[3]==1))
	{	
		
//		printf("PROGRAM LOGIC\n");
		chunks=read_svf(param[10]);		//get chunks to shift
		if(chunks == 0)
		{
			errc=0x57;
			
		}
		else
		{
			chunksize=(cpld_datasize+7)/8;		//bytes per chunk
//			printf("%d chunks a %d bytes\n",chunks,chunksize);
		
			bsize=max_blocksize;
			chunks_per_block=bsize/chunksize;	//maximal chunks per block		
			bsize=chunksize*chunks_per_block;	//new blocksize is used bytes per block
			blocks=(chunks+chunks_per_block-1)/chunks_per_block;		//how many blocks to do

//			printf("%d blocks a %d bytes\n",blocks,bsize);

			maddr=0;					//memory addr
			errc=prg_comm(0x10a,0,0,0,0,0,0,0,0);		//start PRG

			progress("PROG ",blocks,0);
			for(i=0;i<blocks;i++)
			{
				if(bsize > chunksize*chunks) bsize=chunksize*chunks;	

				if((errc==0) && (bsize > 0)) errc=prg_comm(0x10b,bsize,0,maddr,0,
				cpld_datasize,			//bits to shift
				param[6],			//program time (*10us)
				chunks_per_block & 0xff,	//number of chunks low
				chunks_per_block >> 8);		//number of chunks high			
				maddr+=bsize;
				chunks-=chunks_per_block;
				progress("PROG ",blocks,i+1);
			}

			prg_comm(0x10c,0,0,0,0,0,0,0,0);	//end PRG
		
			printf("\n");
		}
	}

	if((program==1) && (errc==0) && (param[3]==2))
	{	
		
//		printf("PROGRAM LOGIC\n");
//		waitkey();
		chunks=read_svf(param[10]);		//get chunks to shift
		chunksize=(cpld_datasize+7)/8;		//bytes per chunk

//		printf("%d chunks a %d bytes (%d bits)\n",chunks,chunksize,cpld_datasize);

		bsize=max_blocksize;
		chunks_per_block=bsize/chunksize;	//maximal chunks per block
		chunks_per_block &= 0xfff0;		//		
		bsize=chunksize*chunks_per_block;	//new blocksize is used bytes per block

		blocks=(chunks+chunks_per_block-1)/chunks_per_block;		//how many blocks to do
		maddr=0;				//memory addr

//		show_data(0,16);
//		printf("%d blocks a %d bytes  (%d ms wait time)\n",blocks,bsize,param[6]);

		errc=prg_comm(0x11a,0,0,0,0,0,0,0,0);		//start PRG
		if(errc != 0) goto XC9500_END;

		progress("PROG ",blocks,0);
		for(i=0;i<blocks;i++)
		{
//			printf("%d chunks  %d bisze  %d errc\n",chunks,bsize,errc);
			if(bsize > chunksize*chunks) bsize=chunksize*chunks;
			if((errc==0) && (bsize > 0)) errc=prg_comm(0x11b,bsize,0,maddr,0,
			cpld_datasize,			//bits to shift
			param[6],			//program time (*ms)
			chunks_per_block & 0xff,	//number of chunks low
			chunks_per_block >> 8);		//number of chunks high			
			maddr+=bsize;
			chunks-=chunks_per_block;
			progress("PROG ",blocks,i+1);
		}

		if(errc== 0) errc=prg_comm(0x11c,0,0,0,0,0,0,0,0);		//end PRG
		printf("\n");
	}
	
XC9500_END:

	prg_comm(0x10E,0,0,0,0,0,0,0,0);	//exit

	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1

	print_xc9500_error(errc);

	return errc;
}





