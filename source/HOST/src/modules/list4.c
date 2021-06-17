//###############################################################################
//#										#
//# UPROG2 universal programmer							#
//#										#
//# copyright (c) 2010-2020 Joerg Wolfram (joerg@jcwolfram.de)			#
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

extern devicedat valid_devices[1000];

void list4group(int index1,int index2,int index3,char *dname)
{
	int i,j;
	int l=strlen(dname);
	printf("\n%s\n",dname);
	for(i=0;i<l;i++) printf("-");
	printf("\n");
	printf("\\subsection{Unterstützte Typen}\n");
	printf("%stables=80,25,25,25,25\n","%%");
	printf("\\begin{tabular}{|p{0.20\\textwidth}|p{0.20\\textwidth}|p{0.20\\textwidth}|p{0.20\\textwidth}|}\n");
	i=0;
	j=0;
	do
	{
		if((valid_devices[i].algo == index1) || (valid_devices[i].algo == index2) ||(valid_devices[i].algo == index3))
		{
			if((j % 4) != 0) printf("\t&");
			printf("%s ",valid_devices[i].name);
			j++;
			if((j % 4) == 0) printf("\\tabularnewline\n\\hline\n");
		}
		i++;
	}
	while(strncmp("END",valid_devices[i].name,20)!=0);
	printf("\n");
}

void list4_devices(void)
{
	list4group(3,0,0,"Atmel AVR");
	list4group(60,0,0,"Atmel AVR0/AVR1");
	list4group(40,0,0,"Atmel ATxmega");
	list4group(61,0,0,"Atmel AT89xxxx");
	list4group(38,0,0,"Microchip PIC12");
	list4group(14,15,0,"Microchip PIC16");
	list4group(17,0,0,"Microchip PIC18");
	list4group(18,0,0,"Microchip dsPIC30");
	list4group(10,0,0,"Microchip dsPIC33");
	list4group(4,5,0,"Texas Instruments MSP430");
	list4group(31,0,0,"Texas Instruments CC25xx");
	list4group(51,0,0,"Texas Instruments CC2640");
	list4group(1,0,0,"Freescale HCS08");
	list4group(6,7,11,"Freescale S12X");
	list4group(2,0,0,"Renesas R8C");
	list4group(12,0,0,"Renesas 78K0R");
	list4group(13,0,0,"Renesas RL78");
	list4group(42,0,0,"Renesas V850");
	list4group(26,0,0,"Renesas RH850");
	list4group(20,0,0,"STMicro ST7");
	list4group(8,0,0,"STMicro STM8");
	list4group(16,0,0,"STMicro SPC56xx (BAM)");
	list4group(44,45,0,"STMicro SPC56xx (JTAG)");
	list4group(63,0,0,"STMicro SPC58xx (JTAG)");
	list4group(33,0,0,"STMicro STM32F0xx");
	list4group(34,0,0,"STMicro STM32F1xx");
	list4group(35,0,0,"STMicro STM32F2xx");
	list4group(36,0,0,"STMicro STM32F3xx");
	list4group(37,0,0,"STMicro STM32F4xx");
	list4group(65,0,0,"STMicro STM32F7xx");
	list4group(52,0,0,"STMicro STM32L4xx");
	list4group(56,0,0,"NXP S9KEA");
	list4group(53,0,0,"NXP S32K");
	list4group(62,0,0,"NXP S12Z");
	list4group(54,0,0,"NXP MPC57xx (JTAG)");
	list4group(64,0,0,"Silabs EFM32/EFR32");	
	list4group(32,0,0,"Cypress PSoC4");
	list4group(21,0,0,"I2C EEPROM");
	list4group(22,0,0,"SPI Flash");
	list4group(23,0,0,"DATA Flash");
	list4group(66,0,0,"OneWire EEPROM");
	list4group(30,0,0,"XC9500(XL) CPLD");
}
