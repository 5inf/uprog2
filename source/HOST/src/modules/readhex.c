#include <main.h>

unsigned long read_file()
{
	char line[2000];
	int bytes,index,rtype;
	unsigned long addr,ioffset;
	unsigned int rbytes;
	
	datei = fopen (sfile, "r");
	rbytes=-1;
	loaddr=0xffffffff;
	hiaddr=0;
	ioffset=0;

	for(addr=0;addr<0x4000000;addr++)
	{
		memory[addr]=0xff;
	}
	addr=0;

	if (datei != NULL)
	{
		rbytes=0;
		while((fscanf(datei,"%s\n",&line[0])) != EOF )
		{
			if(!(strncmp(line,"S1", 2)))
			{
				sscanf(strndup(line+2, 2),"%x",&bytes);
				bytes-=3;
				sscanf(strndup(line+4, 4),"%lx",&addr);
//				printf("ADDR= %08X\n",addr);
				if(addr < loaddr) loaddr=addr;
				for(index=0;index<bytes;index++)
				{
					sscanf(strndup(line+8+2*index, 2),"%hhx",&memory[addr]);
					if(addr > hiaddr) hiaddr=addr;
					rbytes++;
					addr++;	
				}
			}
			if(!(strncmp(line,"S2", 2)))
			{
				sscanf(strndup(line+2, 2),"%x",&bytes);
				bytes-=4;
				sscanf(strndup(line+4, 6),"%lx",&addr);
//				printf("ADDR= %08X\n",addr);
				if(addr < loaddr) loaddr=addr;
				for(index=0;index<bytes;index++)
				{
					sscanf(strndup(line+10+2*index, 2),"%hhx",&memory[addr]);
					if(addr > hiaddr) hiaddr=addr;
					rbytes++;
					addr++;	
				}
			}
			if(!(strncmp(line,"S3", 2)))
			{
				sscanf(strndup(line+2, 2),"%x",&bytes);
				bytes-=5;
				sscanf(strndup(line+4, 8),"%lx",&addr);
				addr &= 0x3FFFFFF;
//				printf("ADDR= %08X\n",addr);
				if(addr < loaddr) loaddr=addr;
				for(index=0;index<bytes;index++)
				{
					sscanf(strndup(line+12+2*index, 2),"%hhx",&memory[addr]);
					if(addr > hiaddr) hiaddr=addr;
					rbytes++;
					addr++;	
				}
			}
			if(!(strncmp(line,":", 1)))
			{
				sscanf(strndup(line+1, 2),"%x",&bytes);
				sscanf(strndup(line+3, 4),"%lx",&addr);
				sscanf(strndup(line+7, 2),"%x",&rtype);
//				printf("ADDR= %08X\n",addr);
				if(rtype==0)
				{
					addr+=ioffset;
					addr &= 0x3FFFFFF;
					if(addr < loaddr) loaddr=addr;
					if(addr < 0x4000000)
					{
						for(index=0;index<bytes;index++)
						{
							sscanf(strndup(line+9+2*index, 2),"%hhx",&memory[addr]);
							if(addr > hiaddr) hiaddr=addr;
							rbytes++;
							addr++;
						}
					}
				}
				if(rtype==2)
				{
					sscanf(strndup(line+9, 4),"%lx",&ioffset);
					ioffset *= 16;
//					printf("Segment: %05lX\n",ioffset);
				}
				if(rtype==4)
				{
					sscanf(strndup(line+9, 4),"%lx",&ioffset);
					ioffset *= 65536;
//					printf("HIGH ADDR: %08lX\n",ioffset);
				}
	
			}
			if(!(strncmp(line,"#", 1)))
			{
				sscanf(strndup(line+1, 2),"%hhx",&memory[addr]);
				addr++;
			}
		}
		fclose (datei);
	}
	for(addr=0;addr<16;addr++)
	{
//		printf("DATA= %02X\n",memory[addr]);
	}
	
	return rbytes;
}

void init_mem(void)
{
	unsigned long addr;

	for(addr=0;addr<0x4000000;addr++)
	{
		memory[addr]=0xff;
	}
}	


unsigned long read_blockx(char * fname,unsigned long start_addr,unsigned long block_len,unsigned long dest_addr)
{
	char line[210];
	int bytes,index,rtype,ii;
	unsigned long addr,ioffset;
	unsigned long rbytes,end_addr;
	unsigned char dbyte;
	long dptr;
	int servermode=0;

	end_addr=start_addr+block_len;

	//clear memory area
	for(rbytes=0;rbytes<block_len;rbytes++)
	{
		memory[dest_addr+rbytes]=0xff;
	}

	if(servermode == 0)
	{
		//printf("READ DAT FROM %s\n",sfile);
		datei = fopen (fname, "r");

		addr=0;
		loaddr=0xffffffff;
		hiaddr=0;
		ioffset=0;

		if (datei != NULL)
		{
//			while((fscanf(datei,"%s\n",&line[0])) != EOF )
			while(fgets(line,200,datei))
			{
				if(!(strncmp(line,"S1", 2)))
				{
					sscanf(strndup(line+2, 2),"%x",&bytes);
					bytes-=3;
					sscanf(strndup(line+4, 4),"%lx",&addr);
					for(index=0;index<bytes;index++)
					{
						sscanf(strndup(line+8+2*index, 2),"%hhx",&dbyte);
						if((addr >= start_addr) && (addr < end_addr))
						{
							memory[addr-start_addr+dest_addr]=dbyte;
							if(addr < loaddr) loaddr=addr;
							if(addr > hiaddr) hiaddr=addr;
						}
						addr++;	
					}
				}
				if(!(strncmp(line,"S2", 2)))
				{
					sscanf(strndup(line+2, 2),"%x",&bytes);
					bytes-=4;
					sscanf(strndup(line+4, 6),"%lx",&addr);
					for(index=0;index<bytes;index++)
					{
						sscanf(strndup(line+10+2*index, 2),"%hhx",&dbyte);
						if((addr >= start_addr) && (addr < end_addr))
						{
							memory[addr-start_addr+dest_addr]=dbyte;
							if(addr < loaddr) loaddr=addr;
							if(addr > hiaddr) hiaddr=addr;
						}
						addr++;	
					}
				}
				if(!(strncmp(line,"S3", 2)))
				{

					sscanf(strndup(line+4, 8),"%lx",&addr);
					if((addr >= start_addr) && (addr < end_addr))
					{
						sscanf(strndup(line+2, 2),"%x",&bytes);
						bytes-=5;
						for(index=0;index<bytes;index++)
						{
							sscanf(strndup(line+12+2*index, 2),"%hhx",&dbyte);
							if((addr >= start_addr) && (addr < end_addr))
							{
								memory[addr-start_addr+dest_addr]=dbyte;
								if(addr < loaddr) loaddr=addr;
								if(addr > hiaddr) hiaddr=addr;
							}
							addr++;	
						}
					}
				}

				if(!(strncmp(line,":", 1)))
				{
					sscanf(strndup(line+1, 2),"%x",&bytes);
					sscanf(strndup(line+3, 4),"%lx",&addr);
					sscanf(strndup(line+7, 2),"%x",&rtype);
					if(rtype==0)
					{
						addr+=ioffset;
						for(index=0;index<bytes;index++)
						{
							sscanf(strndup(line+9+2*index, 2),"%hhx",&dbyte);
							if((addr >= start_addr) && (addr < end_addr))
							{
								memory[addr-start_addr+dest_addr]=dbyte;
								if(addr < loaddr) loaddr=addr;
								if(addr > hiaddr) hiaddr=addr;
							}
							addr++;	
						}
					}
					if(rtype==2)
					{
						sscanf(strndup(line+9, 4),"%lx",&ioffset);
						ioffset *= 16;
						//printf("Segment: %05lX\n",ioffset);
					}
					if(rtype==4)
					{
						sscanf(strndup(line+9, 4),"%lx",&ioffset);
						ioffset *= 65536;
	//					printf("HIGH ADDR: %08lX\n",ioffset);
					}
	
				}
				if(!(strncmp(line,"#", 1)))
				{
					sscanf(strndup(line+1, 2),"%hhx",&memory[addr+dest_addr]);
					addr++;
				}
			}
			fclose (datei);
		}
	}
	else
	{
		addr=0;
		loaddr=0xffffffff;
		hiaddr=0;
		ioffset=0;
		dptr=post_data_start;

		while(dptr < (max_post_data-6))
		{
			line[0]=0;	//empty
			ii=0;
			while(web_buffer[dptr] != '%')
			{
				line[ii]=web_buffer[dptr];
				line[ii+1]=0;
				dptr++;
				ii++;
			}
			dptr+=5;
			//printf("%s\n",line);
					
			if(!(strncmp(line,"S1", 2)))
			{
				sscanf(strndup(line+2, 2),"%x",&bytes);
				bytes-=3;
				sscanf(strndup(line+4, 4),"%lx",&addr);
				for(index=0;index<bytes;index++)
				{
					sscanf(strndup(line+8+2*index, 2),"%hhx",&dbyte);
					if((addr >= start_addr) && (addr < (start_addr+block_len)))
					{
						memory[addr-start_addr+dest_addr]=dbyte;
						if(addr < loaddr) loaddr=addr;
						if(addr > hiaddr) hiaddr=addr;
					}
					addr++;	
				}
			}
			if(!(strncmp(line,"S2", 2)))
			{
				sscanf(strndup(line+2, 2),"%x",&bytes);
				bytes-=4;
				sscanf(strndup(line+4, 6),"%lx",&addr);
				for(index=0;index<bytes;index++)
				{
					sscanf(strndup(line+10+2*index, 2),"%hhx",&dbyte);
					if((addr >= start_addr) && (addr < (start_addr+block_len)))
					{
						memory[addr-start_addr+dest_addr]=dbyte;
						if(addr < loaddr) loaddr=addr;
						if(addr > hiaddr) hiaddr=addr;
					}
					addr++;	
				}
			}
			if(!(strncmp(line,"S3", 2)))
			{
				sscanf(strndup(line+2, 2),"%x",&bytes);
				bytes-=5;
				sscanf(strndup(line+4, 8),"%lx",&addr);
				for(index=0;index<bytes;index++)
				{
					sscanf(strndup(line+12+2*index, 2),"%hhx",&dbyte);
					if((addr >= start_addr) && (addr < (start_addr+block_len)))
					{
						memory[addr-start_addr+dest_addr]=dbyte;
						if(addr < loaddr) loaddr=addr;
						if(addr > hiaddr) hiaddr=addr;
					}
					addr++;	
				}
			}

			if(!(strncmp(line,":", 1)))
			{
				sscanf(strndup(line+1, 2),"%x",&bytes);
				sscanf(strndup(line+3, 4),"%lx",&addr);
				sscanf(strndup(line+7, 2),"%x",&rtype);
				if(rtype==0)
				{
					addr+=ioffset;
					for(index=0;index<bytes;index++)
					{
						sscanf(strndup(line+9+2*index, 2),"%hhx",&dbyte);
						if((addr >= start_addr) && (addr < (start_addr+block_len)))
						{
							memory[addr-start_addr+dest_addr]=dbyte;
							if(addr < loaddr) loaddr=addr;
							if(addr > hiaddr) hiaddr=addr;
						}
						addr++;	
					}
				}
				if(rtype==2)
				{
					sscanf(strndup(line+9, 4),"%lx",&ioffset);
					ioffset *= 16;
//					printf("Segment: %05lX\n",ioffset);
				}
				if(rtype==4)
				{
					sscanf(strndup(line+9, 4),"%lx",&ioffset);
					ioffset *= 65536;
//					printf("HIGH ADDR: %08lX\n",ioffset);
				}
			}
			if(!(strncmp(line,"#", 1)))
			{
				sscanf(strndup(line+1, 2),"%hhx",&memory[addr+dest_addr]);
				addr++;
			}
			dptr++;
		}
	}
	
	if(hiaddr > loaddr) return (hiaddr-loaddr+1);
	else return 0;
}


unsigned long read_block(unsigned long start_addr,unsigned long block_len,unsigned long dest_addr)
{
	unsigned long res;
	
	res=0;
	
	if(file_found==2) res+=read_blockx(sfile,start_addr,block_len,dest_addr);
	if(file2_found==2) res+=read_blockx(sfile2,start_addr,block_len,dest_addr);
	if(file3_found==2) res+=read_blockx(sfile3,start_addr,block_len,dest_addr);
	if(file4_found==2) res+=read_blockx(sfile4,start_addr,block_len,dest_addr);
	return res;
}


unsigned long read_blockx_zfill(char* fname,unsigned long start_addr,unsigned long block_len,unsigned long dest_addr)
{
	char line[120];
	int bytes,index,rtype,ii;
	unsigned long addr,ioffset;
	unsigned long rbytes,end_addr;
	unsigned char dbyte;
	long dptr;
	int servermode=0;

	end_addr=start_addr+block_len;

	//clear memory area
	for(rbytes=0;rbytes<block_len;rbytes++)
	{
		memory[dest_addr+rbytes]=0x00;
	}

	if(servermode == 0)
	{
		//printf("READ DAT FROM %s\n",sfile);
		datei = fopen (fname, "r");

		addr=0;
		loaddr=0xffffffff;
		hiaddr=0;
		ioffset=0;

		if (datei != NULL)
		{
//			while((fscanf(datei,"%s\n",&line[0])) != EOF )
			while(fgets(line,100,datei))
			{
				if(!(strncmp(line,"S1", 2)))
				{
					sscanf(strndup(line+2, 2),"%x",&bytes);
					bytes-=3;
					sscanf(strndup(line+4, 4),"%lx",&addr);
					for(index=0;index<bytes;index++)
					{
						sscanf(strndup(line+8+2*index, 2),"%hhx",&dbyte);
						if((addr >= start_addr) && (addr < end_addr))
						{
							memory[addr-start_addr+dest_addr]=dbyte;
							if(addr < loaddr) loaddr=addr;
							if(addr > hiaddr) hiaddr=addr;
						}
						addr++;	
					}
				}
				if(!(strncmp(line,"S2", 2)))
				{
					sscanf(strndup(line+2, 2),"%x",&bytes);
					bytes-=4;
					sscanf(strndup(line+4, 6),"%lx",&addr);
					for(index=0;index<bytes;index++)
					{
						sscanf(strndup(line+10+2*index, 2),"%hhx",&dbyte);
						if((addr >= start_addr) && (addr < end_addr))
						{
							memory[addr-start_addr+dest_addr]=dbyte;
							if(addr < loaddr) loaddr=addr;
							if(addr > hiaddr) hiaddr=addr;
						}
						addr++;	
					}
				}
				if(!(strncmp(line,"S3", 2)))
				{

					sscanf(strndup(line+4, 8),"%lx",&addr);
					if((addr >= start_addr) && (addr < end_addr))
					{
						sscanf(strndup(line+2, 2),"%x",&bytes);
						bytes-=5;
						for(index=0;index<bytes;index++)
						{
							sscanf(strndup(line+12+2*index, 2),"%hhx",&dbyte);
							if((addr >= start_addr) && (addr < end_addr))
							{
								memory[addr-start_addr+dest_addr]=dbyte;
								if(addr < loaddr) loaddr=addr;
								if(addr > hiaddr) hiaddr=addr;
							}
							addr++;	
						}
					}
				}

				if(!(strncmp(line,":", 1)))
				{
					sscanf(strndup(line+1, 2),"%x",&bytes);
					sscanf(strndup(line+3, 4),"%lx",&addr);
					sscanf(strndup(line+7, 2),"%x",&rtype);
					if(rtype==0)
					{
						addr+=ioffset;
						for(index=0;index<bytes;index++)
						{
							sscanf(strndup(line+9+2*index, 2),"%hhx",&dbyte);
							if((addr >= start_addr) && (addr < end_addr))
							{
								memory[addr-start_addr+dest_addr]=dbyte;
								if(addr < loaddr) loaddr=addr;
								if(addr > hiaddr) hiaddr=addr;
							}
							addr++;	
						}
					}
					if(rtype==2)
					{
						sscanf(strndup(line+9, 4),"%lx",&ioffset);
						ioffset *= 16;
						//printf("Segment: %05lX\n",ioffset);
					}
					if(rtype==4)
					{
						sscanf(strndup(line+9, 4),"%lx",&ioffset);
						ioffset *= 65536;
						//printf("HIGH ADDR: %08lX\n",ioffset);
					}
	
				}
				if(!(strncmp(line,"#", 1)))
				{
					sscanf(strndup(line+1, 2),"%hhx",&memory[addr+dest_addr]);
					addr++;
				}
			}
			fclose (datei);
		}
	}
	else
	{
		addr=0;
		loaddr=0xffffffff;
		hiaddr=0;
		ioffset=0;
		dptr=post_data_start;

		while(dptr < (max_post_data-6))
		{
			line[0]=0;	//empty
			ii=0;
			while(web_buffer[dptr] != '%')
			{
				line[ii]=web_buffer[dptr];
				line[ii+1]=0;
				dptr++;
				ii++;
			}
			dptr+=5;
			//printf("%s\n",line);
					
			if(!(strncmp(line,"S1", 2)))
			{
				sscanf(strndup(line+2, 2),"%x",&bytes);
				bytes-=3;
				sscanf(strndup(line+4, 4),"%lx",&addr);
				for(index=0;index<bytes;index++)
				{
					sscanf(strndup(line+8+2*index, 2),"%hhx",&dbyte);
					if((addr >= start_addr) && (addr < (start_addr+block_len)))
					{
						memory[addr-start_addr+dest_addr]=dbyte;
						if(addr < loaddr) loaddr=addr;
						if(addr > hiaddr) hiaddr=addr;
					}
					addr++;	
				}
			}
			if(!(strncmp(line,"S2", 2)))
			{
				sscanf(strndup(line+2, 2),"%x",&bytes);
				bytes-=4;
				sscanf(strndup(line+4, 6),"%lx",&addr);
				for(index=0;index<bytes;index++)
				{
					sscanf(strndup(line+10+2*index, 2),"%hhx",&dbyte);
					if((addr >= start_addr) && (addr < (start_addr+block_len)))
					{
						memory[addr-start_addr+dest_addr]=dbyte;
						if(addr < loaddr) loaddr=addr;
						if(addr > hiaddr) hiaddr=addr;
					}
					addr++;	
				}
			}
			if(!(strncmp(line,"S3", 2)))
			{
				sscanf(strndup(line+2, 2),"%x",&bytes);
				bytes-=5;
				sscanf(strndup(line+4, 8),"%lx",&addr);
				for(index=0;index<bytes;index++)
				{
					sscanf(strndup(line+12+2*index, 2),"%hhx",&dbyte);
					if((addr >= start_addr) && (addr < (start_addr+block_len)))
					{
						memory[addr-start_addr+dest_addr]=dbyte;
						if(addr < loaddr) loaddr=addr;
						if(addr > hiaddr) hiaddr=addr;
					}
					addr++;	
				}
			}

			if(!(strncmp(line,":", 1)))
			{
				sscanf(strndup(line+1, 2),"%x",&bytes);
				sscanf(strndup(line+3, 4),"%lx",&addr);
				sscanf(strndup(line+7, 2),"%x",&rtype);
				if(rtype==0)
				{
					addr+=ioffset;
					for(index=0;index<bytes;index++)
					{
						sscanf(strndup(line+9+2*index, 2),"%hhx",&dbyte);
						if((addr >= start_addr) && (addr < (start_addr+block_len)))
						{
							memory[addr-start_addr+dest_addr]=dbyte;
							if(addr < loaddr) loaddr=addr;
							if(addr > hiaddr) hiaddr=addr;
						}
						addr++;	
					}
				}
				if(rtype==2)
				{
					sscanf(strndup(line+9, 4),"%lx",&ioffset);
					ioffset *= 16;
//					printf("Segment: %05lX\n",ioffset);
				}
				if(rtype==4)
				{
					sscanf(strndup(line+9, 4),"%lx",&ioffset);
					ioffset *= 65536;
//					printf("HIGH ADDR: %08lX\n",ioffset);
				}
			}
			if(!(strncmp(line,"#", 1)))
			{
				sscanf(strndup(line+1, 2),"%hhx",&memory[addr+dest_addr]);
				addr++;
			}
			dptr++;
		}
	}
	
	if(hiaddr > loaddr) return (hiaddr-loaddr+1);
	else return 0;
}


unsigned long read_block_zfill(unsigned long start_addr,unsigned long block_len,unsigned long dest_addr)
{
	unsigned long res;
	
	res=0;
	
	if(file_found==2) res+=read_blockx_zfill(sfile,start_addr,block_len,dest_addr);
	if(file2_found==2) res+=read_blockx_zfill(sfile2,start_addr,block_len,dest_addr);
	if(file3_found==2) res+=read_blockx_zfill(sfile3,start_addr,block_len,dest_addr);
	if(file4_found==2) res+=read_blockx_zfill(sfile4,start_addr,block_len,dest_addr);
	return res;
}
