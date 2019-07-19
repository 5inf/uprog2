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

void print_mlx363_error(int errc)
{
	printf("\n");
	switch(errc)
	{
		case 0:		set_error("OK",errc);
				break;

		case 0x41:	set_error("(NO ACK)",errc);
				break;

		default:	set_error("(unexpected error)",errc);
	}
	print_error();
}


int prog_mlx363(void)
{
	long errc,vx,vy,vz,sx,sy,sz,i,j;

	errc=0;

	if((strstr(cmd,"help")) && ((strstr(cmd,"help") - cmd) == 1))
	{
		printf("-- 5v   -- using 5V VDD\n");	
		printf("-- rxyz -- read raw XYZ values\n");
		printf("-- rraw -- read raw XYZ values (mean over 16 cycles)\n");
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
		errc=prg_comm(0xFB,0,0,0,0,0,0,0,0);	//set 5V		
	
	}
	
	errc=prg_comm(0x170,0,8,0,0,0,0,0,0);	//init		
	
	
//	show_data(0,8);
	
	if(errc != 0) goto MLX363_END;
	
	
	if(find_cmd("rxyz"))
	{
		errc=prg_comm(0x172,0,8,0,0,0,0,0,0);	//init		
		show_data(0,8);
		vx=(memory[0]+(memory[1]<<8)) & 0x3FFF;
		vy=(memory[2]+(memory[3]<<8)) & 0x3FFF;
		vz=(memory[4]+(memory[5]<<8)) & 0x3FFF;

		if(vx > 0x1fff) vx=(vx & 0x1fff) - 0x2000;  
		if(vy > 0x1fff) vy=(vy & 0x1fff) - 0x2000;  
		if(vz > 0x1fff) vz=(vz & 0x1fff) - 0x2000;  

		printf("X= %d\n",vx);
		printf("Y= %d\n",vy);
		printf("Z= %d\n",vz);
	}

	if(find_cmd("rraw"))
	{
		sx=0;
		sy=0;
		sz=0;
	
		for(i=0;i<16;i++)
		{
	
			errc=prg_comm(0x172,0,8,0,0,0,0,0,0);	//init		
			vx=(memory[0]+(memory[1]<<8)) & 0x3FFF;
			vy=(memory[2]+(memory[3]<<8)) & 0x3FFF;
			vz=(memory[4]+(memory[5]<<8)) & 0x3FFF;

			if(vx > 0x1fff) vx=(vx & 0x1fff) - 0x2000;  
			if(vy > 0x1fff) vy=(vy & 0x1fff) - 0x2000;  
			if(vz > 0x1fff) vz=(vz & 0x1fff) - 0x2000;  
		
			sx+=vx;
			sy+=vy;
			sz+=vz;
		}

		sx >>=4;
		sy >>=4;
		sz >>=4;

		printf("X= %d\n",sx);
		printf("Y= %d\n",sy);
		printf("Z= %d\n",sz);
	}


MLX363_END:

	prg_comm(0x171,0,0,0,0,0,0,0,0);
	prg_comm(0x2ef,0,0,0,0,0,0,0,0);	//dev 1
	print_mlx363_error(errc);
	return errc;
}






