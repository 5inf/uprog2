/********************************************************************************
*										*
*	TMS320F28x SPX Bootloader						*
*	Stage 2									*
*										*
*-------------------------------------------------------------------------------*
* V0.10		10.07.2013	JOW						*
*********************************************************************************/

#include "DSP280x_Device.h"
#include "Flash280x/Flash280x_API_Library.h"

/*---------------------------------------------------------------------------
  Data/Program Buffer used for testing the flash API functions
---------------------------------------------------------------------------*/
#define  WORDS_IN_FLASH_BUFFER 0x100               // Programming data buffer, Words

Uint16  Buffer[WORDS_IN_FLASH_BUFFER];

#define GPATOGGLE (volatile Uint32 *) 0x6fc6

/*---------------------------------------------------------------------------
  project-specific settings
---------------------------------------------------------------------------*/
#define SPXC 0x800000
#define SPXD 0x400000
#define LED1 0x0002
#define LED2 0x0020

#define SET_LED_00 \
			GpioDataRegs.GPASET.all    = LED1 | LED2;

#define SET_LED_01 \
			GpioDataRegs.GPASET.all    = LED2; \
			GpioDataRegs.GPACLEAR.all  = LED1;

#define SET_LED_10 \
			GpioDataRegs.GPASET.all    = LED1; \
			GpioDataRegs.GPACLEAR.all  = LED2;

#define SET_LED_11 \
			GpioDataRegs.GPACLEAR.all    = LED1 | LED2;

#define WAIT_SPXC_LOW \
			while((GpioDataRegs.GPADAT.all & SPXC) == SPXC);	// wait for SPXC=0

#define WAIT_SPXC_HIGH \
			while((GpioDataRegs.GPADAT.all & SPXC) == 0);		// wait for SPXC=1


/*---------------------------------------------------------------------------
  Sector address info
---------------------------------------------------------------------------*/
#define OTP_START_ADDR  0x3D7800
#define OTP_END_ADDR    0x3D7BFF
#define OTP_PAGES       4
#define OTP_WORDS       1024


#if FLASH_F2808
	#define FLASH_START_ADDR  0x3E8000
	#define FLASH_END_ADDR    0x3F7FFF
	#define FLASH_PAGES       256
	#define FLASH_WORDS       65536
#endif

#if FLASH_F2806
	#define FLASH_START_ADDR  0x3F0000
	#define FLASH_END_ADDR    0x3F7FFF
	#define FLASH_PAGES       128
	#define FLASH_WORDS       32768
#endif

#if FLASH_F2802
	#define FLASH_START_ADDR  0x3F0000
	#define FLASH_END_ADDR    0x3F7FFF
	#define FLASH_PAGES       128
	#define FLASH_WORDS       32768
#endif

#if FLASH_F2801
	#define FLASH_START_ADDR  0x3F4000
	#define FLASH_END_ADDR    0x3F7FFF
	#define FLASH_PAGES       64
	#define FLASH_WORDS       16384
#endif

#if FLASH_F28015
	#define FLASH_START_ADDR  0x3F4000
	#define FLASH_END_ADDR    0x3F7FFF
	#define FLASH_PAGES       64
	#define FLASH_WORDS       16384
#endif

#if FLASH_F28016
	#define FLASH_START_ADDR  0x3F4000
	#define FLASH_END_ADDR    0x3F7FFF
	#define FLASH_PAGES       64
	#define FLASH_WORDS       16384
#endif

// Prototype statements for functions found within this file.
void delay_loop();
void toggle_led();
void Gpio_init(void);
int set_pll(void);
void InitFlash(void);
void InitPll(Uint16,Uint16);
void InitPeripheralClocks(void);
void Example_Error(Uint16 Status);
void Example_Done(void);
int Flash_version_check(void);
int Flash_erase_all(void);
int Flash_depletion_recover(void);
int Flash_prog_block_test(void);
int Flash_prog_spx(void);
int Flash_verify_spx(void);
int OTP_prog_spx(void);
int OTP_verify_spx(void);
int FLASH_blankcheck(void);

void Flash_ToggleTest(volatile Uint32 *ToggleReg,Uint32 Mask);

// SPX routines
Uint16 spx_read(void);
Uint16 spx_read_wait(void);
void spx_read_nowait(void);
void spx_write(Uint16);
void spx_write_end(void);



/*--- Global variables used to interface to the flash routines */
FLASH_ST FlashStatus;

extern Uint32 Flash_CPUScaleFactor;

void main(void)
{
	Uint16 spx_data_word,flash_data;
	Uint16 *Flash_rptr;
	Uint32 j,dummy;
	int i,flash_erased,otp_blank,pstatus;

	InitPll(PLLCR_VALUE,0);

	pstatus=0xABCD;	//OK

	i=set_pll();
	if(i != 0)
	{
	
		SET_LED_11			//error
		pstatus = 0xEE01;
	}

	InitPeripheralClocks();
//	toggle_led();
	InitFlash();

	Flash_CPUScaleFactor = SCALE_FACTOR;
	Flash_CallbackPtr = 0;

	i=Flash_version_check();
	if(i != 0)
	{
		SET_LED_11			//error
		pstatus = 0xEE02;
	}

	//check for flash empty
	Flash_rptr = (Uint16 *)FLASH_START_ADDR;	//start addr
	flash_erased=1;
	for(j=0;j<FLASH_WORDS;j++)			//words to do
	{
		flash_data = *Flash_rptr++;	//get data
		if(flash_data != 0xffff)
		{
			flash_erased=0;
		}
	}

	//check for OTP empty
	Flash_rptr = (Uint16 *)OTP_START_ADDR;	//start addr
	otp_blank=1;
	for(j=0;j<OTP_WORDS;j++)		//words to do
	{
		flash_data = *Flash_rptr++;	//get data
		if(flash_data != 0xffff)
		{
			otp_blank=0;
		}
	}

	SET_LED_01				//WAIT
	pstatus=0xABCD;			//set OK

	for(;;)
	{
		spx_data_word=spx_read_wait();
		SET_LED_00					// all off

		switch(spx_data_word)
		{
		//read status

		case 0x8888:
			SET_LED_01
			spx_read_nowait();		//end read cycle
			spx_write(pstatus);		//write status
			pstatus=0xABCD;			//set OK
			spx_write_end();		//switch to read mode
		break;

		//read flash
		case 0x7851:
			pstatus=0xABCD;			//set OK
			spx_read_nowait();
			Flash_rptr = (Uint16 *)FLASH_START_ADDR;	//start addr

			for(j=0;j<FLASH_WORDS;j++)			//words to do
			{
				flash_data = *Flash_rptr++;	//get data
				spx_write(flash_data);		//write out
			}
			SET_LED_01				//OK
			spx_write_end();
		break;

		//program flash
		case 0x7852:
			spx_read_nowait();
			if(flash_erased==1)
			{
				i=Flash_prog_spx();
				dummy=spx_read_wait();		//additional word for waiting
				//do a dummy read to get flash working ???
				Flash_rptr = (Uint16 *)FLASH_START_ADDR;	//start addr
				for(j=0;j<FLASH_WORDS;j++)	//words to do
				{
					flash_data += *Flash_rptr++;	//get data
				
				}
				if(i==0)
				{
					SET_LED_01		//OK
					pstatus=0xABCD;			//set OK
				}
				else
				{
					SET_LED_11		//NOK
					pstatus = 0xEE00 | (i & 0xFF);		//set status
				}
				spx_read_nowait();
			}
			else
			{
				for(j=0;j<FLASH_WORDS+1;j++)
				{
					flash_data=spx_read();	//dummy
				}
				SET_LED_01			//OK
				pstatus=0xABCD;			//set OK
			}
		break;

		//verify flash
		case 0x7853:
			i=0;
			spx_read_nowait();
			i=Flash_verify_spx();
			dummy=spx_read_wait();		//additional word for waiting
			Flash_rptr = (Uint16 *)FLASH_START_ADDR;	//start addr
			for(j=0;j<FLASH_WORDS;j++)	//words to do
			{
				flash_data += *Flash_rptr++;	//get data
			
			}

			if(i==0)
			{
				//do a dummy read to get flash working ???
				SET_LED_01		//OK
				pstatus=0xABCD;
			}
			else
			{
				SET_LED_11		//NOK
				pstatus=0xEE08;		//verify error
			}
			spx_read_nowait();
		break;

		//erase flash
		case 0x7858:
			pstatus=0xABCD;			//set OK
			if(flash_erased == 0)
			{
				i=Flash_erase_all();
				flash_erased=0;
				//do a dummy read to get flash working ???
				Flash_rptr = (Uint16 *)FLASH_START_ADDR;	//start addr
				for(j=0;j<FLASH_WORDS;j++)	//words to do
				{
					if(flash_data != 0xffff)
					{
						flash_erased=0;
						pstatus = 0xEE09;		//erase err
					}
				}
				if(i==0)
				{
					SET_LED_01		//OK
				}
				else
				{
					SET_LED_11		//NOK
					pstatus = 0xEE00 | (i & 0xFF);		//set status
				}
			}
			else
			{
				SET_LED_01		//OK
			}
			spx_read_nowait();
		break;


		//read OTP
		case 0x7951:
			pstatus=0xABCD;			//set OK
			spx_read_nowait();
			Flash_rptr = (Uint16 *)OTP_START_ADDR;	//start addr

			for(j=0;j<OTP_WORDS;j++)			//words to do
			{
				flash_data = *Flash_rptr++;	//get data
				spx_write(flash_data);		//write out
			}
			SET_LED_01				//OK
			spx_write_end();
		break;


		//program otp
		case 0x7952:
			spx_read_nowait();
			if(otp_blank==1)
			{
				i=OTP_prog_spx();
				dummy=spx_read_wait();		//additional word for waiting
				//do a dummy read to get otp working ???
				Flash_rptr = (Uint16 *)OTP_START_ADDR;	//start addr
				for(j=0;j<OTP_WORDS;j++)	//words to do
				{
					flash_data += *Flash_rptr++;	//get data
				
				}
				if(i==0)
				{
					SET_LED_01		//OK
					pstatus=0xABCD;			//set OK
				}
				else
				{
					SET_LED_11		//NOK
					pstatus = 0xEE00 | (i & 0xFF);		//set status
				}
				spx_read_nowait();
			}
			else
			{
				for(j=0;j<OTP_WORDS+1;j++)
				{
					flash_data=spx_read();	//dummy
				}
				SET_LED_01			//OK
				pstatus=0xABCD;			//set OK
			}
		break;


		//verify OTP
		case 0x7953:
			spx_read_nowait();
			i=OTP_verify_spx();
			dummy=spx_read_wait();		//additional word for waiting
			Flash_rptr = (Uint16 *)OTP_START_ADDR;	//start addr
			for(j=0;j<OTP_WORDS;j++)	//words to do
			{
				flash_data += *Flash_rptr++;	//get data
			
			}
			if(i==0)
			{
				//do a dummy read to get flash working ???
				SET_LED_01		//OK
				pstatus=0xABCD;
			}
			else
			{
				SET_LED_11		//NOK
				pstatus=0xEE08;		//verify error
			}
			spx_read_nowait();
		break;

		//depletion recover
		case 0x7859:
			i=Flash_depletion_recover();
			dummy=spx_read_wait();		//additional word for waiting
			//do a dummy read to get flash working ???
			Flash_rptr = (Uint16 *)FLASH_START_ADDR;	//start addr
			for(j=0;j<FLASH_WORDS;j++)	//words to do
			{
				flash_data += *Flash_rptr++;	//get data
			
			}
			if(i==0)
			{
				SET_LED_01		//OK
				pstatus=0xABCD;			//set OK
			}
			else
			{
				SET_LED_11		//NOK
				pstatus = 0xEE00 | (i & 0xFF);		//set status
			}
			spx_read_nowait();
		break;

			//blank check flash
		case 0x785a:
			i=FLASH_blankcheck();
			if(i==0)
			{
				SET_LED_01		//OK
				pstatus=0xABCD;			//set OK
			}
			else
			{
				SET_LED_11		//NOK
				pstatus = 0xEE00 | (i & 0xFF);		//set status
			}
			spx_read_nowait();
		break;

		//LED check
		case 0x0000:
			SET_LED_00
			spx_read_nowait();
			i=0;
			break;

		//LED check
		case 0x1111:
			SET_LED_01
			spx_read_nowait();
			i=0;
			break;

		//LED check
		case 0x2222:
			SET_LED_10
			spx_read_nowait();
			i=0;
			break;

		//LED check
		case 0x3333:
			SET_LED_11
			spx_read_nowait();
			i=0;
			break;

		//toggle test
		case 0x5555:
			spx_read_nowait();
			Flash_ToggleTest(GPATOGGLE,LED2);
			i=0;
			break;

		default:
			SET_LED_10		//CMD ERROR
			spx_read_nowait();
			i=spx_data_word;
		}
	}
}

//===========================================================================
// enable GPIO
//===========================================================================
void Gpio_init(void)
{
	EALLOW;
	GpioCtrlRegs.GPAMUX1.all = 0x00000000;  // All GPIO
	GpioCtrlRegs.GPAMUX2.all = 0x00000000;  // All GPIO
	GpioCtrlRegs.GPAMUX1.all = 0x00000000;  // All GPIO
	GpioCtrlRegs.GPADIR.all  = LED1 | LED2;  // All inputs except LED
	GpioCtrlRegs.GPBDIR.all  = 0x00000000;  // All outputs
	EDIS;
}

//===========================================================================
// get SPX word
//===========================================================================
Uint16 spx_read(void)
{
	int data = 0;
	int dbits;
	EALLOW;
	if((GpioDataRegs.GPADAT.all & SPXC) != 0)			//check if clock = 1
	{
		GpioDataRegs.GPASET.all = SPXD;				// set SPXD to one
		GpioCtrlRegs.GPADIR.all |= SPXD;			// set SPXD to output
		WAIT_SPXC_LOW						//wait for clock=0
	}
	GpioCtrlRegs.GPADIR.all &= ~SPXD;				//set SPX to INPUT

	for(dbits=0;dbits<8;dbits++)
	{
		WAIT_SPXC_HIGH						// wait for SPXC=1
		data = data << 1;
		if((GpioDataRegs.GPADAT.all & SPXD) != 0)
		{
			data++;
		}
		WAIT_SPXC_LOW						// wait for SPXC=0
		data = data << 1;
		if((GpioDataRegs.GPADAT.all & SPXD) != 0)
		{
			data++;
		}
	}
	WAIT_SPXC_HIGH							// wait for SPXC=1
	GpioDataRegs.GPASET.all = SPXD;					// set SPXD to one
	GpioCtrlRegs.GPADIR.all |= SPXD;				// set SPXD to output
	WAIT_SPXC_LOW							// wait for SPXC=0
	GpioCtrlRegs.GPADIR.all &= ~SPXD;				// set SPXD to input
	EDIS;
	return data;
}

//===========================================================================
// get SPX word
//===========================================================================
Uint16 spx_read_wait(void)
{
	int data = 0;
	int dbits;
	EALLOW;
	if((GpioDataRegs.GPADAT.all & SPXC) != 0)			//check if clock = 1
	{
		GpioDataRegs.GPASET.all = SPXD;				// set SPXD to one
		GpioCtrlRegs.GPADIR.all |= SPXD;			// set SPXD to output
		WAIT_SPXC_LOW						//wait for clock=0
	}
	GpioCtrlRegs.GPADIR.all &= 0xFF3FFFFF;				//set SPX to INPUT

	for(dbits=0;dbits<8;dbits++)
	{
		WAIT_SPXC_HIGH						// wait for SPXC=1
		data = data << 1;
		if((GpioDataRegs.GPADAT.all & SPXD) != 0)
		{
			data++;
		}
		WAIT_SPXC_LOW						// wait for SPXC=0
		data = data << 1;
		if((GpioDataRegs.GPADAT.all & SPXD) != 0)
		{
			data++;
		}
	}
	WAIT_SPXC_HIGH							// wait for SPXC=1
	EDIS;
	return data;
}

void spx_read_nowait(void)
{
	EALLOW;
	GpioDataRegs.GPASET.all = SPXD;					// set SPXD to one
	GpioCtrlRegs.GPADIR.all |= SPXD;				// set SPXD to output
	WAIT_SPXC_LOW							// wait for SPXC=0
	GpioCtrlRegs.GPADIR.all &= ~SPXD;				// set SPXD to input
	EDIS;
}

//===========================================================================
// put SPX word
//===========================================================================
void spx_write(Uint16 data)
{
	int dbits;

	EALLOW;
	GpioCtrlRegs.GPADIR.all |= SPXD;				// set SPXD to output
	for(dbits=0;dbits<8;dbits++)
	{
		WAIT_SPXC_HIGH						// wait for SPXC=1
		if((data & 0x8000) == 0x8000)
		{
			GpioDataRegs.GPASET.all = SPXD;
		}
		else
		{
			GpioDataRegs.GPACLEAR.all = SPXD;
		}
		data = data << 1;

		WAIT_SPXC_LOW						// wait for SPXC=0
		if((data & 0x8000) == 0x8000)
		{
			GpioDataRegs.GPASET.all = SPXD;
		}
		else
		{
			GpioDataRegs.GPACLEAR.all = SPXD;
		}
		data = data << 1;
	}
}

void spx_write_end(void)
{
	EALLOW;
	WAIT_SPXC_HIGH							// wait for SPXC=1
	WAIT_SPXC_LOW							// wait for SPXC=0
	GpioCtrlRegs.GPADIR.all &= ~SPXD;				// set SPXD to input
}


//===========================================================================
//  (dummy) Callback function
//===========================================================================
int Flash_version_check(void)
{
	Uint16  VersionHex;     // Version of the API in decimal encoded hex
	VersionHex = Flash_APIVersionHex();
	if(VersionHex != 0x0302)
	{
		// Unexpected API version
		// Make a decision based on this info. 
		return 1;
	}
	return 0;
}


int Flash_erase_all(void)
{
	Uint16  Status;
	EALLOW;
	Status = Flash_Erase(15,&FlashStatus);
	return Status;
}

int Flash_depletion_recover(void)
{
	Uint16  Status;
	EALLOW;
	Status = Flash_DepRecover();
	return Status;
}

int Flash_prog_spx(void)
{
	Uint16 Status,loops,words;
	Uint16 *Flash_ptr;
	// In this case just fill a buffer with data to program into the flash. 
	Status = 0;
	for(loops=0;loops<FLASH_PAGES;loops++)
	{
		for(words=0;words<255;words++)
		{
			Buffer[words]=spx_read();
		}
		Buffer[255]=spx_read_wait();
		Flash_ptr = (Uint16 *)FLASH_START_ADDR + 256 * loops;
		Status |= Flash_Program(Flash_ptr,Buffer,0x100,&FlashStatus);
		spx_read_nowait();
	}
	return Status;
}

int Flash_verify_spx(void)
{
	Uint16 Status,loops,words;
	Uint16 *Flash_ptr;
	// In this case just fill a buffer with data to program into the flash. 
	Status = 0;
	for(loops=0;loops<FLASH_PAGES;loops++)
	{
		for(words=0;words<255;words++)
		{
			Buffer[words]=spx_read();
		}
		Buffer[255]=spx_read_wait();
		Flash_ptr = (Uint16 *)FLASH_START_ADDR + 256 * loops;
		Status |= Flash_Verify(Flash_ptr,Buffer,0x100,&FlashStatus);
		spx_read_nowait();
	}
	return Status;
}

int OTP_prog_spx(void)
{
	Uint16 Status,loops,words;
	Uint16 *Flash_ptr;
	// In this case just fill a buffer with data to program into the flash. 
	Status = 0;
	for(loops=0;loops<OTP_PAGES;loops++)
	{
		for(words=0;words<255;words++)
		{
			Buffer[words]=spx_read();
		}
		Buffer[255]=spx_read_wait();
		Flash_ptr = (Uint16 *)OTP_START_ADDR + 256 * loops;
		Status |= Flash_Program(Flash_ptr,Buffer,0x100,&FlashStatus);
		spx_read_nowait();
	}
	return Status;
}

int OTP_verify_spx(void)
{
	Uint16 Status,loops,words;
	Uint16 *Flash_ptr;
	// In this case just fill a buffer with data to program into the flash. 
	Status = 0;
	for(loops=0;loops<OTP_PAGES;loops++)
	{
		for(words=0;words<255;words++)
		{
			Buffer[words]=spx_read();
		}
		Buffer[255]=spx_read_wait();
		Flash_ptr = (Uint16 *)OTP_START_ADDR + 256 * loops;
		Status |= Flash_Verify(Flash_ptr,Buffer,0x100,&FlashStatus);
		spx_read_nowait();
	}
	return Status;
}

int FLASH_blankcheck(void)
{
	Uint16 Status;
	Uint16 *Flash_rptr;
	Uint32 jj;
	Uint16 flash_data;

	Flash_rptr = (Uint16 *)FLASH_START_ADDR;	//start addr
	Status=0;
	for(jj=0;jj<FLASH_WORDS;jj++)			//words to do
	{
		flash_data = *Flash_rptr++;	//get data
		if(flash_data != 0xffff)
		{
			Status=1;
		}
	}
	return Status;
}

void toggle_led()
{
	for (;;) 
	{
		SET_LED_01
		delay_loop();
		SET_LED_10
		delay_loop();
	}
}


//===========================================================================
// wait a little bit
//===========================================================================
void delay_loop()
{
	long i;
	for (i = 0; i < 2000000; i++) 
	{
		asm ("NOP");
	}
}

#include "pll.c"
