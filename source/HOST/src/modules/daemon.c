//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2010-2016 Joerg Wolfram (joerg@jcwolfram.de)			#
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

#ifdef COMP_32
#include<ftdi.h>
#else
#include<libftdi1/ftdi.h>
#endif

#include <main.h>

//#define DEBUG_OUTPUT 1

int daemon_task(void)
{
	struct ftdi_context ftdic;
	struct sockaddr_rc btaddr = { 0 };
	struct pollfd pfd;

	unsigned long tstamp1;
	int usb_stat,status,read_timeout;
	int shmid;
	int slen,offset;
	int i,txlen,rxlen,timeout;
	char bt_address[20];
	unsigned char ping_data[32];
	int ping_enabled;

	inquiry_info *ii = NULL;
	int max_rsp, num_rsp;
	int dev_id, sock, len, flags;
	char addr[19] = { 0 };
	char name[248] = { 0 };


	ping_data[0]=0xaa;	//query
	ping_data[1]=0xf9;	//returns a "invalid" answer
	ping_data[2]=0x00;	//query
	ping_data[3]=0x00;	//query
	ping_data[4]=0x00;	//query
	ping_data[5]=0x00;	//query
	ping_data[6]=0x00;	//query
	ping_data[7]=0x00;	//query
	ping_data[8]=0x00;	//query
	ping_data[9]=0x00;	//query
	ping_data[10]=0xcc;	//query
	
	ping_enabled=1;
	
	
#if DEBUG_OUTPUT == 0
		umask(0);
		setsid();
		close(STDIN_FILENO);
		close(STDOUT_FILENO);
		close(STDERR_FILENO);
#endif

	//rename our deamon
	prctl(PR_SET_NAME,"uprog2d");

#if DEBUG_OUTPUT == 1
	printf("+++ ACTIVATE SHARED MEMORY\n");
#endif	
	interface_type=0;				//no interface active
	timeout=0;

	shmid=shmget(1887699,SHM_SIZE,0);

	if(shmid < 0)
	{
		shmid=shmget(1887699,SHM_SIZE, IPC_EXCL | IPC_CREAT | 0666);
		if(shmid < 0)
		{
#if DEBUG_OUTPUT == 1
			printf("!!! CANNOT GET SHARED MEMORY\n");
#endif
			goto daemon_end;				//cannot create shared memory
		}
	}
	else
	{
#if DEBUG_OUTPUT == 1
			printf("??? SHARED MEMORY IS ALREADY DEFINED\n");
#endif	
	}
	
	shm = shmat(shmid,NULL,0);
	if(shm == (unsigned char *) -1) goto daemon_end;	//cannot attach shared memory

	shm[0] = 0x00;						//searching for interface
	shm[1] = 0x00;						//no command
	
	//try to open communication with FTDI device
	interface_type=2;	//preset to FTDI

#if DEBUG_OUTPUT == 1
	printf("+++ CHECK USB INTEFACE\n");
#endif

	if(ftdi_init(&ftdic) < 0)
	{
#if DEBUG_OUTPUT == 1
		printf("ERROR INIT FTDI INTEFACE\n");
#endif
		interface_type=1;
	}

	if((interface_type == 2) && ((usb_stat = ftdi_usb_open(&ftdic,0x0403,0x6661)) != 0))
	{
#if DEBUG_OUTPUT == 1
		printf("NO FTDI DEVICE (%s)\n",ftdi_get_error_string(&ftdic));
#endif
		interface_type=1;
	}

	if((interface_type == 2) && ((usb_stat = ftdi_set_baudrate(&ftdic,1250000)) != 0))
	{
#if DEBUG_OUTPUT == 1
		printf("ERROR SET BAUDRATE (%s)\n",ftdi_get_error_string(&ftdic));
#endif
		interface_type=0;
	}

	if((interface_type == 2) && ((usb_stat = ftdi_set_line_property(&ftdic,8,STOP_BIT_2,NONE)) != 0))
	{
#if DEBUG_OUTPUT == 1
		printf("ERROR SET LINE (%s)\n",ftdi_get_error_string(&ftdic));
#endif
		interface_type=0;
	}

	if((interface_type == 2) && ((usb_stat = ftdi_setflowctrl(&ftdic,SIO_RTS_CTS_HS)) != 0))
	{
#if DEBUG_OUTPUT == 1
		printf("ERROR SET FLOW CONTROL (%s)\n",ftdi_get_error_string(&ftdic));
#endif
		interface_type=0;
	}

	if((interface_type == 2) && ((usb_stat = ftdi_setrts(&ftdic,SIO_SET_MODEM_CTRL_REQUEST)) != 0))
	{
#if DEBUG_OUTPUT == 1
		printf("ERROR SET FLOW CONTROL (%s)\n",ftdi_get_error_string(&ftdic));
#endif
		interface_type=0;
	}

	if((interface_type == 2) && ((usb_stat = ftdi_set_latency_timer(&ftdic,28)) != 0))
	{
#if DEBUG_OUTPUT == 1
		printf("ERROR SET LATENCY TIMER (%s)\n",ftdi_get_error_string(&ftdic));
#endif
		interface_type=0;
	}


	if((interface_type == 2) && ((usb_stat = ftdi_read_data_set_chunksize(&ftdic,2176)) != 0))
	{
#if DEBUG_OUTPUT == 1
		printf("ERROR SET RX CHUNKSIZE (%s)\n",ftdi_get_error_string(&ftdic));
#endif
		interface_type=0;
	}


	if((interface_type == 2) && ((usb_stat = ftdi_write_data_set_chunksize(&ftdic,2176)) != 0))
	{
#if DEBUG_OUTPUT == 1
		printf("ERROR SET TX CHUNKSIZE (%s)\n",ftdi_get_error_string(&ftdic));
#endif
		interface_type=0;
	}

	if(interface_type == 1) 
	{
		interface_type=0;
		dev_id = hci_get_route(NULL);
		sock = hci_open_dev( dev_id );
		if (dev_id < 0 || sock < 0)
		{
#if DEBUG_OUTPUT == 1
			printf("NO BT ADAPTER\n");
#endif
			interface_type=0;
		}
		else
		{
#if DEBUG_OUTPUT == 1
			printf("SOCK = %d\n",sock);
#endif

			len  = 8;
			max_rsp = 5;
	
			flags = IREQ_CACHE_FLUSH;
			ii = (inquiry_info*)malloc(max_rsp * sizeof(inquiry_info));
    
			num_rsp = hci_inquiry(dev_id, len, max_rsp, NULL, &ii, flags);
			if( num_rsp < 0 ) perror("hci_inquiry");

    			for (i = 0; i < num_rsp; i++) 
    			{
        			ba2str(&(ii+i)->bdaddr, addr);
        			memset(name, 0, sizeof(name));
        			if (hci_read_remote_name(sock, &(ii+i)->bdaddr, sizeof(name),name, 0) < 0)
					strcpy(name, "[unknown]");
#if DEBUG_OUTPUT == 1
				printf("%s  %s\n", addr, name);
#endif
				if(strcmp(name,"UPROG2") == 0)
				{
					strcpy(bt_address,addr);
#if DEBUG_OUTPUT == 1
					printf("BT PROGRAMMER FOUND (%s)\n",bt_address);
#endif
					interface_type=1;
				}
			}

 			free( ii );
 		}
    		close( sock );
	}

	//now connect rfcomm	
	if(interface_type == 1) 
	{
		sock=socket(AF_BLUETOOTH,SOCK_STREAM,BTPROTO_RFCOMM);
		btaddr.rc_family =  AF_BLUETOOTH;
		btaddr.rc_channel =  1;
		str2ba(bt_address, &btaddr.rc_bdaddr);

		status= connect(sock, (struct sockaddr *)&btaddr,sizeof(btaddr));
		if(status != 0) interface_type=0;		
	
		usleep(1000000);				//wait a little bit for connection handling
	}
	
	if(interface_type == 0)
	{	
		shm[0]=0x1f;					//no interface found
		shm[2]=0;
#if DEBUG_OUTPUT == 1
		printf("+++ NO INTERFACE\n");
#endif
		while(shm[0] == 0x1f) usleep(1000);		//wait for client
		usleep(100000);
#if DEBUG_OUTPUT == 1
		printf("+++ END DAEMON\n");
#endif
		goto daemon_end;				//exit
	}

	if(interface_type == 2)					//FTDI
	{	
		shm[0]=0x10;					//interface found
		shm[2]=2;
		while(shm[0] == 0x11) usleep(1000);		//wait for client
	}

	if(interface_type == 1)					//BT
	{	
		shm[0]=0x10;					//interface found
		shm[2]=1;
		while(shm[0] == 0x10) usleep(1000);		//wait for client
	}


	while(shm[0] != 0x2f)
	{
DAEMON_W1:
		usleep(1000);
		if(shm[1]== 0xcd)				//new cmd
		{
			txlen=shm[6]+256*shm[7];
			rxlen=shm[8]+256*shm[9];
#if DEBUG_OUTPUT == 1
			printf("CMD %02X %02X %02X %02X\n",shm[4],shm[5],shm[6],shm[7]);
			printf("DLEN %d %d\n",txlen,rxlen);			
#endif

			//check for byte from programmer
			if((shm[4]==0xAC) && (shm[5]==0x9F))
			{
				shm[14]=0x00;	//no char

				if(interface_type == 1)
				{
#if DEBUG_OUTPUT == 1
					printf("check...\n");				
#endif
					i=read(sock,&shm[14],1);
				}

				if(interface_type == 2)
				{
#if DEBUG_OUTPUT == 1
					printf("check...\n");				
#endif					
					i=ftdi_read_data(&ftdic,&shm[14],1);					
				}
			
			//	shm[14]=1;
				shm[1]=0xad;	//OK
				goto DAEMON_W1;
			}

			//disable BT ping for frequency generator and logic analyzer
			ping_enabled=1;
			if((shm[4]==0xac) && ((shm[5] & 0xf0) == 0x90))
			{
				ping_enabled=0;
			}


			if(interface_type == 2)			//clear FTDI buffer
			{
				i=ftdi_usb_purge_tx_buffer(&ftdic);
				i=ftdi_usb_purge_rx_buffer(&ftdic);
			}
			slen=11+txlen;		//10 head + data + 0xcc
			offset=0;
			i=0;

			if(interface_type == 2)
			{
#if DEBUG_OUTPUT == 1
				printf("write...\n");				
#endif
				i=ftdi_write_data(&ftdic,&shm[offset+4],slen);
#if DEBUG_OUTPUT == 1
				printf("written: %d\n",i);
#endif
			}
			else
			{
				do
				{
#if DEBUG_OUTPUT == 1
					printf("write...\n");				
#endif
					i=write(sock,&shm[offset+4],slen);
#if DEBUG_OUTPUT == 1
					printf("written: %d\n",i);
#endif
					if(i > 0)
					{
						slen-=i;
						offset+=i;
					}
					usleep(200);
				}while(slen > 0);
			}
	
			//now read back result
			offset=0;
			tstamp1=time(NULL);
			read_timeout=0;
			if(interface_type == 1)
			{
#if DEBUG_OUTPUT == 1
				printf("read...\n");				
#endif
//				i=read(sock,&shm[offset+14],rxlen+1);

				while((offset <= rxlen) && (read_timeout == 0))
				{
					i=read(sock,&shm[offset+14],rxlen+1);
#if DEBUG_OUTPUT == 1
				printf("read %i bytes = %02X %02X %02X %02X\n",i,shm[offset+14],shm[offset+15],
					shm[offset+16],shm[offset+17]);				
#endif
					offset+=i;
					if(offset < rxlen) usleep(500);
					if((time(NULL) -tstamp1) > 30) read_timeout=1;
				}
			}

			if(interface_type == 2)
			{
#if DEBUG_OUTPUT == 1
				printf("read...\n");				
#endif
				while((offset <= rxlen) && (read_timeout == 0))
				{
					i=ftdi_read_data(&ftdic,&shm[offset+14],rxlen+1);
					offset+=i;
					if(offset < rxlen) usleep(100);
					if((time(NULL) -tstamp1) > 30)
						read_timeout=1;
						
//					printf(">>> Time = %08lX\n",time(NULL));

				}
			}

			if(read_timeout != 0) 
			{
#if DEBUG_OUTPUT == 1
				printf("!!! READ TIMEOUT !!!\n");
#endif		
				shm[14+rxlen]=0x9f;	//timeout error
				shm[1]=0xab;		//done
				goto daemon_end;
			}


#if DEBUG_OUTPUT == 1
			printf("WRITE OK\n");
#endif
			shm[1]=0xab;		//done

			while(shm[1] != 0xab) 
			{
				usleep(100);
				shm[1]=0xab;
			}
			timeout=0;
#if DEBUG_OUTPUT == 1
			printf("CMD DONE\n");
#endif
		}
		timeout++;
		if(timeout > 2000)
		{
			if((interface_type == 2) && ((usb_stat = ftdi_set_baudrate(&ftdic,1250000)) != 0))
			{
#if DEBUG_OUTPUT == 1
				printf("\nCONNECTION TO PROGRAMMER LOST\n");
#endif
				goto daemon_end;
			}
			if((interface_type == 1) && (ping_enabled == 1))
			{
				pfd.fd=sock;
				pfd.events=POLLIN;	
				i=write(sock,ping_data,11);
				i=poll(&pfd,1,1000);
				
				if(i < 1)
				{		
#if DEBUG_OUTPUT == 1
					printf("\nCONNECTION TO PROGRAMMER LOST\n");
#endif
					goto daemon_end;
				}
				else
				{
					i=read(sock,&ping_data[16],1);
#if DEBUG_OUTPUT == 1
					printf("PING data %d\n",i);			
#endif
				}
			}
			timeout=0;		
		}
	}
	
daemon_end:

	if(interface_type == 1)
	{
		close(sock);
	}

	if(interface_type == 2)
	{
		ftdi_usb_close(&ftdic);
		ftdi_deinit(&ftdic);
	}

	shmdt(shm);			//detach shared memory	
	shmctl(shmid,IPC_RMID,0);
#if DEBUG_OUTPUT == 1
			printf("+++ DAEMON EXIT\n");
#endif
	return(EXIT_SUCCESS);
}
