
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int getpids(char *pname)
{
	char line[100];
	FILE *cmd;
	int pids,p;

	strcpy(line,"pidof ");
	strcat(line,pname);

	cmd=popen(line,"r");
	line[0]=0;
	fgets(line,100,cmd);
	pclose(cmd);

	if(strlen(line)==0) return 0;

	pids=1;
	for(p=0;p<strlen(line);p++)
	{
		if(line[p] == 0x20) pids++;
	}	
	return pids;
}

int check_shm(unsigned long key)
{
	char line[100];
	char skey[20];
	FILE *cmd;
	int pids,p;

	sprintf(skey,"0x%08lx",key);

	strcpy(line,"ipcs | grep ");
	strcat(line,skey);

	cmd=popen(line,"r");
	line[0]=0;
	fgets(line,100,cmd);
	pclose(cmd);

	if(strlen(line)==0)
	{
		printf("key %s not found\n", skey);
		return 0;
	}
	printf("key found %s\n", skey);
	
	return 1;
}
