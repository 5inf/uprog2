

int writeblock_open(void);
int writelist_open(void);
int writeblock_close(void);
int writeblock_data(unsigned long,unsigned long,unsigned long);
int writeblock_data16(unsigned long,unsigned long,unsigned long);
int writeblock_list(unsigned long,unsigned long);
int write_hexblock(unsigned long,unsigned long,unsigned long,int);
