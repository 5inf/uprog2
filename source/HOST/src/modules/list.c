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

void listgroup(int index1,int index2,int index3,char *dname)
{
	int i,j;
	int l=strlen(dname);
	printf("\n%s\n",dname);
	for(i=0;i<l;i++) printf("-");
	printf("\n");
	i=0;
	j=0;
	do
	{
		if((valid_devices[i].algo == index1) || (valid_devices[i].algo == index2) ||(valid_devices[i].algo == index3))
		{
			printf("%s ",valid_devices[i].name);
			j++;
			if((j % 8) == 0) printf("\n");
		}
		i++;
	}
	while(strncmp("END",valid_devices[i].name,20)!=0);
	printf("\n");
}

void list_devices(void)
{
	listgroup(3,0,0,"Atmel AVR");
	listgroup(60,0,0,"Atmel AVR0");
	listgroup(40,0,0,"Atmel ATxmega");
	listgroup(61,0,0,"Atmel AT89xxxx");
	listgroup(38,0,0,"Microchip PIC12");
	listgroup(14,15,0,"Microchip PIC16");
	listgroup(17,0,0,"Microchip PIC18");
	listgroup(18,0,0,"Microchip dsPIC30");
	listgroup(10,0,0,"Microchip dsPIC33");
	listgroup(4,5,0,"Texas Instruments MSP430");
	listgroup(31,0,0,"Texas Instruments CC25xx");
	listgroup(51,0,0,"Texas Instruments CC2640");
	listgroup(1,0,0,"Freescale HCS08");
	listgroup(6,7,11,"Freescale S12X");
	listgroup(2,0,0,"Renesas R8C");
	listgroup(12,0,0,"Renesas 78K0R");
	listgroup(13,0,0,"Renesas RL78");
	listgroup(42,0,0,"Renesas V850");
	listgroup(26,0,0,"Renesas RH850");
	listgroup(20,0,0,"STMicro ST7");
	listgroup(8,0,0,"STMicro STM8");
	listgroup(16,0,0,"STMicro SPC56xx (BAM)");
	listgroup(44,45,0,"STMicro SPC56xx (JTAG)");
	listgroup(33,0,0,"STMicro STM32F0xx");
	listgroup(34,0,0,"STMicro STM32F1xx");
	listgroup(35,0,0,"STMicro STM32F2xx");
	listgroup(36,0,0,"STMicro STM32F3xx");
	listgroup(37,0,0,"STMicro STM32F4xx");
	listgroup(52,0,0,"STMicro STM32L4xx");
	listgroup(56,0,0,"NXP S9KEA");
	listgroup(53,0,0,"NXP S32K");
	listgroup(62,0,0,"NXP S12Z");
	listgroup(32,0,0,"Cypress PSoC4");
	listgroup(21,0,0,"I2C EEPROM");
	listgroup(22,0,0,"SPI Flash");
	listgroup(23,0,0,"DATA Flash");
	listgroup(30,0,0,"XC9500(XL) CPLD");

}
