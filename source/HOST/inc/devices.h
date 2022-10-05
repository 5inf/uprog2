#ifndef _DEVICE_LIST_

devicedat valid_devices[1000] = {

	"LIST",
	100,
	0x00000000,0x00000000,		//dummy data
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,		//RAM
	0x00000000,		//ID
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,


	"LIST4",
	112,
	0x00000000,0x00000000,		//dummy data
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,		//RAM
	0x00000000,		//ID
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,

	"KILL",
	101,
	0x00000000,0x00000000,		//dummy data
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,		//RAM
	0x00000000,		//ID
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,

	"WSERVER",
	104,
	0x00000000,0x00000000,		//dummy data
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,		//RAM
	0x00000000,		//ID
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,

	"S19TOHEX",
	110,
	0x00000000,0x00000000,		//dummy data
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,		//RAM
	0x00000000,		//ID
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,


	"UPDATE",
	99,
	0x00000000,0x00000000,		//dummy data
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,		//RAM
	0x00000000,		//ID
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,

	"RUNDEV",
	98,
	0x00000000,0x00000000,		//dummy data
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,		//RAM
	0x00000000,		//ID
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,


	"FGEN",
	97,
	0x00000000,0x00000000,		//dummy data
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,		//RAM
	0x00000000,		//ID
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,

	"LA1M",
	96,
	0x00000000,0x00000000,		//dummy data
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,		//RAM
	0x00000000,		//ID
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,

	"LA100K",
	95,
	0x00000000,0x00000000,		//dummy data
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,		//RAM
	0x00000000,		//ID
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,

	"LA10K",
	94,
	0x00000000,0x00000000,		//dummy data
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,		//RAM
	0x00000000,		//ID
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,
	0x0000,0x0000,


#include	"devices/devices_78K0R_FX3.h"
#include	"devices/devices_FSL_HCS08.h"
#include	"devices/devices_R8C.h"
#include	"devices/devices_MSP430x2.h"
#include	"devices/devices_MSP430x5.h"
#include	"devices/devices_AVR.h"
#include	"devices/devices_AVRJTAG.h"
#include	"devices/devices_STM8.h"
#include	"devices/devices_PIC12.h"
#include	"devices/devices_PIC16.h"
#include	"devices/devices_PIC18.h"
//#include	"devices/devices_DSPIC30.h"
#include	"devices/devices_DSPIC33.h"
#include	"devices/devices_PPCBAM.h"
#include	"devices/devices_SPC56.h"
#include	"devices/devices_MPC57.h"
#include	"devices/devices_RL78F12.h"
#include	"devices/devices_RL78F13.h"
#include	"devices/devices_RL78F14.h"
#include	"devices/devices_ST7FLITE.h"
#include	"devices/devices_I2C.h"
#include	"devices/devices_CC25xx.h"
#include	"devices/devices_PSOC4.h"
#include	"devices/devices_STM32F0.h"
#include	"devices/devices_STM32F1.h"
#include	"devices/devices_STM32F2.h"
#include	"devices/devices_STM32F3.h"
#include	"devices/devices_STM32F4.h"
#include	"devices/devices_STM32F7.h"
#include	"devices/devices_STM32L4.h"
#include	"devices/devices_XC95xx.h"
#include	"devices/devices_S12XD.h"
#include	"devices/devices_S12XE.h"
#include	"devices/devices_S12XS.h"
//#include	"devices/devices_C2000.h"
#include	"devices/devices_SPIFLASH.h"
#include	"devices/devices_DATAFLASH.h"
#include	"devices/devices_ATXMEGA.h"
#include	"devices/devices_RH850.h"
#include	"devices/devices_V850.h"
#include	"devices/devices_CC2640.h"






#include	"devices/devices_SPC58.h"
#include	"devices/devices_MLX.h"
#include	"devices/devices_DGEN.h"
#include	"devices/devices_SPIEEPROM.h"
#include	"devices/devices_LPS25H.h"
#include	"devices/devices_S32K.h"
#include	"devices/devices_KEA64.h"
#include	"devices/devices_TLE.h"
#include	"devices/devices_AVR0.h"
#include	"devices/devices_AVR1.h"
#include	"devices/devices_AT89.h"
#include	"devices/devices_S12Z.h"
#include	"devices/devices_EFM32.h"
#include	"devices/devices_ONEWIRE.h"
//#include	"devices/devices_SAMD21.h"
#include	"devices/devices_VEML3328.h"

	"END",0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
};

#define _DEVICE_LIST_
#endif
