#include <main.h>

unsigned long read_svf(unsigned long m_devid)
{
	char line[2000];
	int bytes,index,psize,pdata,i,dbyte,chunks;
	char c;
	unsigned long addr,f_devid;

	datei = fopen (sfile, "r");
	
	for(addr=0;addr<0x4000000;addr++)
	{
		memory[addr]=0xff;
	}
	addr=0;
	pdata=0;
	chunks=0;
	f_devid=0;

	if (datei != NULL)
	{
		while((fgets(line,1500,datei)) != NULL )
		{
//			printf("%s\n",line);
			if(!(strncmp(line,"SIR 8 TDI (ea) ;", 16)))
			{
				pdata = 1;	//reading enabled
			}	
			if(!(strncmp(line,"SIR 8 TDI (f0) ;", 16)))
			{
				pdata = 0;	//reading disabled
			}	

			//check device id
			if((pdata == 0) && (!(strncmp(line,"SDR 32 ", 7))))
			{
				index=44;f_devid=0;

				for(i=0;i<8;i++)
				{
					f_devid <<=4;
					c=line[index++]-0x30;
					if(c>9) c-=0x27;
					f_devid+=c;
				}
			}

			if((pdata == 1) && (!(strncmp(line,"SDR ", 4))))
			{
				index=4;psize=0;
				while(line[index] > 0x20)
				{
					psize*=10;
					psize=psize+line[index]-48;
					index++;
				}
				index+=6;
				bytes=(psize+7)/8;
				index+=(bytes*2);
				cpld_datasize=psize;
				
				for(i=0;i<bytes;i++)
				{
					c=line[--index]-0x30;
					if(c>9) c-=0x27;
					dbyte=c;
					c=line[--index]-0x30;
					if(c>9) c-=0x27;
					dbyte+=(c*16);
					memory[addr++]=dbyte;
				}		
				chunks++;		
//				printf("%d %c %d\n",psize,line[index],bytes);
			}	
			
		}
		fclose (datei);
		if(f_devid != m_devid)
		{
			printf("ID does not match: DEVICE=%08lX   FILE=%08lX\n",m_devid,f_devid);
			chunks=0;
		}		
	}
	return chunks;
}
