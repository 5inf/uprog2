//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2010-2022 Joerg Wolfram (joerg@jcwolfram.de)			#
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

#include<signal.h>
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<termios.h>
#include<unistd.h>
#include<fcntl.h>
#include<libusb-1.0/libusb.h>
#include<sys/ipc.h>
#include<sys/shm.h>
#include<sys/prctl.h>
#include<poll.h>
#include<time.h>
#include<sys/socket.h>
#include<sys/stat.h>
#include<bluetooth/bluetooth.h>
#include<bluetooth/hci.h>
#include<bluetooth/hci_lib.h>
#include<bluetooth/rfcomm.h>

#include<libftdi1/ftdi.h>

#include <main.h>

struct ftdi_context ftdic;

int usb_io(int txlen,int rxlen)
{
	int read_timeout,offset,i;
	unsigned long tstamp1; 
	
	ftdi_write_data(&ftdic,com_buf,txlen+11);

	offset=0;
	tstamp1=time(NULL);
	read_timeout=0;

	while((offset <= rxlen) && (read_timeout == 0))
	{
		i=ftdi_read_data(&ftdic,&com_buf[offset+11],rxlen+1);
		offset+=i;
		if(offset < rxlen) usleep(100);
		if((time(NULL) -tstamp1) > 30)	read_timeout=1;					
	}

	return read_timeout;
}


int check_usb(int vpid)
{
	int usb_stat,i;

	if(ftdi_init(&ftdic) < 0)
	{
		printf("ERROR INIT FTDI DRIVER (%s)\n",ftdi_get_error_string(&ftdic));
		return 1;
	}

	if(vpid == 1)
	{
		usb_stat = ftdi_usb_open(&ftdic,0x0403,0x6001);			//vanilla
	}
	else
	{
		usb_stat = ftdi_usb_open(&ftdic,0x0403,0x6661);			//UPROG2
	}
	if(usb_stat != 0) usb_stat = ftdi_usb_open(&ftdic,0x2763,0xFFFF);	//5inf
	if(usb_stat != 0)
	{
		printf("NO FTDI CHIP FOUND (%s)\n",ftdi_get_error_string(&ftdic));
		return 2;
	}

	if((usb_stat = ftdi_set_baudrate(&ftdic,1250000)) != 0)
	{
		printf("ERROR SET FDTI BAUDRATE (%s)\n",ftdi_get_error_string(&ftdic));
		return 2;
	}

	if((usb_stat = ftdi_set_line_property(&ftdic,8,STOP_BIT_1,NONE)) != 0)
	{
		printf("ERROR SET LINE (%s)\n",ftdi_get_error_string(&ftdic));
		return 2;
	}

	if((usb_stat = ftdi_setflowctrl(&ftdic,SIO_RTS_CTS_HS)) != 0)
	{
		printf("ERROR SET FLOW CONTROL (%s)\n",ftdi_get_error_string(&ftdic));
		return 2;
	}

	if((usb_stat = ftdi_setrts(&ftdic,SIO_SET_MODEM_CTRL_REQUEST)) != 0)
	{
		printf("ERROR SET FLOW CONTROL (%s)\n",ftdi_get_error_string(&ftdic));
		return 2;
	}

	if((usb_stat = ftdi_set_latency_timer(&ftdic,2)) != 0)
	{
		printf("ERROR SET LATENCY TIMER (%s)\n",ftdi_get_error_string(&ftdic));
		return 2;
	}

	com_buf[0]=0xaa;	//query
	com_buf[1]=0xf9;	//returns a "invalid" answer
	com_buf[2]=0x00;	//query
	com_buf[3]=0x00;	//query
	com_buf[4]=0x00;	//query
	com_buf[5]=0x00;	//query
	com_buf[6]=0x00;	//query
	com_buf[7]=0x00;	//query
	com_buf[8]=0x00;	//query
	com_buf[9]=0x00;	//query
	com_buf[10]=0xcc;	//query

	ftdi_tcioflush(&ftdic);
	i=usb_io(0,0);

	if(i != 0)
	{
		printf("ERROR NO ECHO FROM PROGRAMMER\n");
		return 3;
	}

	if(com_buf[11] != 1)
	{
		printf("ERROR WRONG ECHO FROM PROGRAMMER\n");
		return 3;
	}

	return 0;
}



void close_usb(void)
{
	ftdi_usb_close(&ftdic);
	ftdi_deinit(&ftdic);
}


