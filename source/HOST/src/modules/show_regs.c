#include "main.h"

void show_cortex_registers(void)
{
	int i;
	i=0;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=1;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=2;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=3;printf("R%d : %02X%02X%02X%02X\n",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);

	i=4;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=5;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=6;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=7;printf("R%d : %02X%02X%02X%02X\n",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);

	i=8;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=9;printf("R%d : %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=10;printf("R%d: %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=11;printf("R%d: %02X%02X%02X%02X    ",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=12;printf("R%d: %02X%02X%02X%02X\n",i,memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);

	i=13;printf("SP : %02X%02X%02X%02X\n",memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=14;printf("LR : %02X%02X%02X%02X\n",memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);
	i=15;printf("PC : %02X%02X%02X%02X --> ",memory[i*4+3],memory[i*4+2],memory[i*4+1],memory[i*4+0]);

	i=16;
		if((memory[i*4-4] & 0x02) == 0x02)
		{
			printf("%02X%02X %02X%02X %02X%02X\n",memory[67],memory[66],memory[69],memory[68],memory[71],memory[70]);
		}
		else
		{
			printf("%02X%02X %02X%02X %02X%02X\n",memory[65],memory[64],memory[67],memory[66],memory[69],memory[68]);
		}

	printf("\n");
}

