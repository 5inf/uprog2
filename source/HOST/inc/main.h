#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<termios.h>
#include<unistd.h>
#include<fcntl.h>
#include<subfunct.h>
#include<readhex.h>
#include<writehex.h>
#include<debug.h>

#define ROFFSET 0x2000000			//max 32MB
#define SHM_SIZE 2064
#define DEBUG_OUTPUT 0

unsigned char *memory;		//global memory map
unsigned char *shm;
unsigned long shmkey;
char sfile[300];		//data file
char sfile2[300];		//data file
char sfile3[300];		//data file
char sfile4[300];		//data file
char tfile[300];		//temporary data file
char cmd[100];			//command
char stype[300];
char name[50];			//device name
char error_line[100];
char *web_buffer;
long max_post_data;
long post_data_start;
int hold_vdd;
int range_err;

unsigned long loaddr,hiaddr;
unsigned long s1,e1,s2,e2,s3,e3,s4,e4,devid;
unsigned long err_addr;
char err_mdata[10];
char err_rdata[10];
int save_data,dev_found,cmd_found,file_found,tfile_found,file2_found,file3_found,file4_found;
//int fd;
int is_error;
int pmode;
int pvalue;
unsigned int have_expar,have_expar2,have_expar3,have_expar4;
unsigned long expar,expar2,expar3,expar4;
unsigned long param[20];
int algo_nr;
FILE *datei;
FILE *tdatei;
float v_batt,v_ext,v_prog;
unsigned char rwbuffer[4096];
int max_blocksize;
int interface_type;
int file_mode,blver,tfile_mode,file2_mode,file3_mode,file4_mode;
unsigned int sysversion;

int cpld_datasize;

typedef struct typelist
{
	char name[40];
	int algo;
	unsigned long par[19];
} devicedat;

int force_exit;
