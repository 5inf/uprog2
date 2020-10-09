//###############################################################################
//#										#
//#										#
//#										#
//# copyright (c) 2010-2020 Joerg Wolfram (joerg@jcwolfram.de)			#
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
#include <poll.h>

//----------------------------------------------------------------------------------
// send a command to programmer
//----------------------------------------------------------------------------------
int prg_comm(int cmd,int txlen,int rxlen,long txaddr,long rxaddr,int p1,int p2,int p3,int p4)
{
	int offset;
	int lt,ht,lr,hr,i;
	lt = txlen & 0xff;
	ht = (txlen >> 8) & 0xff;
	lr = rxlen & 0xff;
	hr = (rxlen >> 8) & 0xff;

	shm[4]=(0xab + (cmd >> 8)) & 0xff;
	shm[5]=cmd & 0xff;
	shm[6]=lt;
	shm[7]=ht;
	shm[8]=lr;
	shm[9]=hr;
	shm[10]=p1 & 0xff;
	shm[11]=p2 & 0xff;
	shm[12]=p3 & 0xff;
	shm[13]=p4 & 0xff;

	if(txlen > 0)
	{
		for(i=0;i<txlen;i++)
		{
			shm[14+i]=memory[txaddr+i];
		}
	}
	shm[txlen+14]=0xcc;		//last byte is 0xcc

	shm[1]=0xcd;			//start transfer
	
//	printf("sent data\n");
	
//	printf("CMD = %02X %02X\n",shm[4],shm[5]);
	
	while(shm[1] == 0xcd) usleep(10);

//	printf("get data\n");

	
	//now read back result
	offset=0;
	while(offset < rxlen)
	{
		memory[rxaddr+offset]=shm[14+offset];
		offset++;
	}

//	printf("RES = %02X %02X\n",shm[1],shm[14]);

	return shm[14+offset] & 0xff;
}


//----------------------------------------------------------------------------------
// read voltages from programmer
//----------------------------------------------------------------------------------
int read_volt()
{
	int result;

//	result = prg_comm(int cmd,int txlen,int rxlen,long txaddr,long rxaddr,int p1,int p2,int p3,int p4)
	result = prg_comm(0xf8,0,3,0,0,0,0,0,0);

	if(result == 0)
	{
		v_batt=memory[0];
		v_ext=memory[1];
		v_prog=memory[2];
		v_batt/=10;
		v_ext/=10;
		v_prog/=10;
		if(interface_type == 1) printf("V-batt  = %4.1fV\n",v_batt);
		printf("V-Ext   = %4.1fV\n",v_ext);
		printf("V-PROG  = %4.1fV\n",v_prog);
	}
	else
	{
		printf("ERROR CODE %X\n\n",result);
	}
	return result;
}

//----------------------------------------------------------------------------------
// read info from programmer
//----------------------------------------------------------------------------------
int read_info()
{
	int result;
	float ver;

//	result = prg_comm(int cmd,int txlen,int rxlen,long txaddr,long rxaddr,int p1,int p2,int p3,int p4)
	result = prg_comm(0xf0,0,4,0,0,0,0,0,0);


	if(result == 0)
	{
		blver=memory[0];
		ver=blver & 0x3f;
		ver=ver/10;
		max_blocksize=2048;			//fixed from v1.20
		printf("SYS-Ver = %4.1f\n",ver);
		sysversion=265*memory[2]+memory[3];
		printf("PRG-Ver =  %04d\n",memory[2]*256+memory[3]);
	}
	else
	{
		sysversion=0;
		printf("ERROR CODE %X\n\n",result);
	}
	return result;
}

//----------------------------------------------------------------------------------
// progress bar
//----------------------------------------------------------------------------------
void progress(char *mystring, int v_max, int v_act)
{
	char funct[22];
	char fill[52];
	int i;
	strncpy(funct,mystring,20);
	for(i=strlen(mystring);i<21;i++) funct[i]=0x20;
	funct[i]=0;
	
	for(i=0;i<50;i++)
	{
		if(i<=((v_act*50)/v_max))
			fill[i]='*';
		else
			fill[i]='.';
	}
	fill[50]=0;
	printf("%s |%s|\r",funct,fill);
	fflush(stdout);
}

//----------------------------------------------------------------------------------
// check for block is completely 0xff
//----------------------------------------------------------------------------------
int must_prog(long mad,int blen)
{
	int i,j;
	j=0;
	for(i=0;i<blen;i++)
	{
		if(memory[mad+i] != 255) j=1;
	}
//	printf("ADDR= %04X RES: %d\n",mad,j);
	return j;
}

int must_prog_pic16(long mad,int blen)
{
	int i,j;
	j=0;
	for(i=0;i<blen;i+=2)
	{
		if(memory[mad+i] != 0xFF) j=1;
		if((memory[mad+i+1] & 0x3F) != 0x3F) j=1;
	}
//	printf("ADDR= %04X RES: %d\n",mad,j);
	return j;
}


//----------------------------------------------------------------------------------
// check for block is completely 0x00
//----------------------------------------------------------------------------------
int check_00(long mad,int blen)
{
	int i,j;
	j=1;
	for(i=0;i<blen;i++)
	{
		if(memory[mad+i] != 0) j=0;
	}
//	printf("ADDR= %04X RES: %d\n",mad,j);
	return j;
}

int kbhit()
{
    struct timeval tv;
    fd_set fds;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds); //STDIN_FILENO is 0
    select(STDIN_FILENO+1, &fds, NULL, NULL, &tv);
    return FD_ISSET(STDIN_FILENO, &fds);
}

void waitkey(void)
{
		printf("\nPRESS ENTER TO EXIT \n");
		getchar();
}


int abortkey(void)
{
	int j;
	
	printf("\nPRESS ENTER TO ABORT \n");
	do
	{
		usleep(1000);
		memory[0]=0;
		j=prg_comm(0x19f,1,0,0,0,0,0,0,0);	//check if done
	}while((!(kbhit())) && (j==0));

	printf("RDAT: %02X %02X\n",shm[1],shm[14]);
		
	if(j==0)
	{
		printf("==> Aborted\n");
		return 1;
	}
	else
	{
		printf("==> Done\n");
	}
	return 0;	
}



int find_cmd(char *cptr)
{
	if(strstr(cmd,cptr) && ((strstr(cmd,cptr)-cmd) %2 == 1))
	{
		return(1);
	}
	else return(0);
}

void show_data(long addr, int len)
{
	int i;
	for(i=0;i<len;i++)
	{
		printf("ADDR= %08lX  DATA= %02X\n",addr+i,memory[addr+i]);
	}
}

void show_data4_b(long addr, int len)
{
	int i;
	for(i=0;i<len;i++)
	{
		printf("ADDR= %08lX  DATA= %08lX\n",addr+4*i,	(unsigned long)((memory[addr+4*i]<<24) |
								(memory[addr+4*i+1]<<16) |
								(memory[addr+4*i+2]<<8) |
								(memory[addr+4*i+3])));
	}
}

void show_data4_l(long addr, int len)
{
	int i;
	for(i=0;i<len;i++)
	{
		printf("ADDR= %08lX  DATA= %08lX\n",addr+4*i,	(unsigned long)((memory[addr+4*i]) |
								(memory[addr+4*i+1]<<8) |
								(memory[addr+4*i+2]<<16) |
								(memory[addr+4*i+3]<<24)));
	}
}



//----------------------------------------------------------------------------------
// flag check tests
//----------------------------------------------------------------------------------
int check_cmd_prog(char *cptr,char *tptr)
{
	if(strstr(cmd,cptr) && ((strstr(cmd,cptr)-cmd) %2 == 1))
	{
		if(file_found < 2)
		{
			printf("## Action: %s program !! DISABLED BECAUSE OF NO FILE !!\n",tptr);
			return 0;
		}
		else
		{
			printf("## Action: %s program using %s",tptr,sfile);
			if(file2_found ==2) printf(", %s",sfile2);
			if(file3_found ==2) printf(", %s",sfile3);
			if(file4_found ==2) printf(", %s",sfile4);
			printf("\n");
			return 1;
		}
	}
	return 0;
}

int check_cmd_verify(char *cptr,char *tptr)
{
	if(strstr(cmd,cptr) && ((strstr(cmd,cptr)-cmd) %2 == 1))
	{
		if(file_found < 2)
		{
			printf("## Action: %s verify !! DISABLED BECAUSE OF NO FILE !!\n",tptr);
			return 0;
		}
		else
		{
			printf("## Action: %s verify using %s",tptr,sfile);
			if(file2_found ==2) printf(", %s",sfile2);
			if(file3_found ==2) printf(", %s",sfile3);
			if(file4_found ==2) printf(", %s",sfile4);
			printf("\n");
			return 1;
		}
	}
	return 0;
}


int check_cmd_read(char *cptr,char *tptr,int *pptr,int *vptr)
{
	if(strstr(cmd,cptr) && ((strstr(cmd,cptr)-cmd) %2 == 1))
	{
		if((*pptr + *vptr) > 0)
		{
			printf("## Action: %s read !! DISABLED BECAUSE OF PROG/VERIFY !!\n",tptr);
			return 0;
		}
		
		if(file_found < 1)
		{
			printf("## Action: %s read !! DISABLED BECAUSE OF NO FILE !!\n",tptr);
			return 0;
		}
		else
		{
			printf("## Action: %s read to %s\n",tptr,sfile);
			return 1;
		}
	}
	return 0;
}


int check_cmd_read2(char *cptr,char *tptr)
{
	if(strstr(cmd,cptr) && ((strstr(cmd,cptr)-cmd) %2 == 1))
	{
		if(file_found < 1)
		{
			printf("## Action: %s read !! DISABLED BECAUSE OF NO FILE !!\n",tptr);
			return 0;
		}
		else
		{
			printf("## Action: %s read to %s\n",tptr,sfile);
			return 1;
		}
	}
	return 0;
}


int check_cmd_run(char *cptr)
{
	if(strstr(cmd,cptr) && ((strstr(cmd,cptr)-cmd) %2 == 1))
	{
		if(file_found < 2)
		{
			printf("## Action: run code !! DISABLED BECAUSE OF NO FILE !!\n");
			return 0;
		}
		else
		{
			printf("## Action: run code using %s",sfile);
			if(file2_found ==2) printf(", %s",sfile2);
			if(file3_found ==2) printf(", %s",sfile3);
			if(file4_found ==2) printf(", %s",sfile4);
			printf("\n");
			return 1;
		}
	}
	return 0;
}


void set_error(char *emessage,int errnum)
{
	int i,l;

	if(errnum < 10)
	{
		sprintf(error_line,"%s",emessage);
	}
	else
	{
		sprintf(error_line,"ERROR %02X (%d):  %s",errnum,errnum,emessage);
	}
	
	l=strlen(error_line);
	for(i=l;i<99;i++) error_line[i]=0x20;
	error_line[99]=0x00;
}

void set_error2(char *emessage,int errnum,unsigned long addr)
{
	int i,l;

	if(errnum < 10)
	{
		sprintf(error_line,"%s",emessage);
	}
	else
	{
		sprintf(error_line,"ERROR %02X (%d):  %s AT 0x%08lX",errnum,errnum,emessage,addr);
	}
	
	l=strlen(error_line);
	for(i=l;i<99;i++) error_line[i]=0x20;
	error_line[99]=0x00;
}

void print_error(void)
{
	printf("%s\n",error_line);
}
