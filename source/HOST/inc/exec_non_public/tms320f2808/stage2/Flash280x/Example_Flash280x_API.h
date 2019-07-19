// TI File $Revision: /main/2 $
// Checkin $Date: December 16, 2004   21:15:53 $
//###########################################################################
//
// FILE:  Example_Flash280X_API.h	
//
// TITLE: F280X Flash API example include file
//
// DESCRIPTION:
//
// Function prototypes and macros for the F280x Flash API library examples.
//
//###########################################################################
// $TI Release: F2808, F2806, F2801 API V3.00 $
// $Release Date: August 15, 2005 $
//###########################################################################


#ifndef EXAMPLE_FLASH280X_API_H
#define EXAMPLE_FLASH280X_API_H


//---------------------------------------------------------------------------
// For Portability, User Is Recommended To Use Following Data Type Size
// Definitions For 16-bit and 32-Bit Signed/Unsigned Integers:
//

#ifndef DSP28_DATA_TYPES
#define DSP28_DATA_TYPES
typedef int             int16;
typedef long            int32;
typedef unsigned int    Uint16;
typedef unsigned long   Uint32;
typedef float           float32;
typedef long double     float64;
#endif

/*---- DSP280x Header Files -- Part of SPRC191 from TI's website. ----------*/
#include "DSP280x_Gpio.h"
#include "DSP280x_SysCtrl.h"

/*---- flash program files -------------------------------------------------*/
#include "Flash280x_API_Library.h"

/*---------------------------------------------------------------------------
   Functions used by this example
*---------------------------------------------------------------------------*/

void Example_ToggleTest(Uint16 Pin);    // Run the ToggleTest
Uint16 Example_CsmUnlock(void);         // Unlock the Code Security Module
void Example_CallFlashAPI(void);        // Kernel function that interfaces to the API
void Example_Error(Uint16 Status);      // If an error, stop here
void Example_Done(void);                // If done, stop here
void Example_MemCopy(Uint16 *SourceAddr, Uint16* SourceEndAddr, Uint16* DestAddr);

/*---------------------------------------------------------------------------
  Symbols used to copy support functions from Flash to RAM 
  These symbols are assigned by the linker.  Refer to the .cmd file
---------------------------------------------------------------------------*/

extern Uint16 RamfuncsLoadStart;
extern Uint16 RamfuncsLoadEnd;
extern Uint16 RamfuncsRunStart;

/*-----------------------------------------------------------------------------
     Specify the PLLCR (PLL Control Register) value.   

      Uncomment the appropriate line by removing the leading double slash: // 
      Only one statement should be uncommented.

      The user's application must set the PLLCR Register before calling any
      of the Flash API functions.
 
      Example:  CLKIN is a 20MHz crystal.  
                The user wants to have a 100Mhz CPU clock (SYSCLKOUT = 100MHz).  
                In this case, PLLCR must be set to 10 (0x000A)
                Uncomment the line: #define PLLCR_VALUE 10
                Comment out the remaining lines with a double slash: //
-----------------------------------------------------------------------------*/

#define PLLCR_VALUE  0x000A     // SYSCLKOUT = (OSCLK*10)/2
// #define PLLCR_VALUE   0x0009     // SYSCLKOUT = (OSCLK*9)/2
// #define PLLCR_VALUE   0x0008     // SYSCLKOUT = (OSCLK*8)/2
// #define PLLCR_VALUE   0x0007     // SYSCLKOUT = (OSCLK*7)/2
// #define PLLCR_VALUE   0x0006     // SYSCLKOUT = (OSCLK*6)/2
// #define PLLCR_VALUE   0x0005     // SYSCLKOUT = (OSCLK*5)/2
// #define PLLCR_VALUE   0x0004     // SYSCLKOUT = (OSCLK*4)/2
// #define PLLCR_VALUE   0x0003     // SYSCLKOUT = (OSCLK*3)/2
// #define PLLCR_VALUE   0x0002     // SYSCLKOUT = (OSCLK*2)/2
// #define PLLCR_VALUE   0x0001     // SYSCLKOUT = (OSCLK*1)/2
// #define PLLCR_VALUE   0x0000     // SYSCLKOUT = (OSCLK)/2 (PLL Bypassed)



/*---------------------------------------------------------------------------
   These key values are used to unlock the CSM by this example
   They are defined in Example_Flash2812_CsmKeys.asm
--------------------------------------------------------------------------*/
extern Uint16 PRG_key0;        //   CSM Key values
extern Uint16 PRG_key1;
extern Uint16 PRG_key2;
extern Uint16 PRG_key3;
extern Uint16 PRG_key4;
extern Uint16 PRG_key5;
extern Uint16 PRG_key6;
extern Uint16 PRG_key7;  

//---------------------------------------------------------------------------
// Common CPU Definitions used by this example:
//

#define	 EALLOW	asm(" EALLOW")
#define	 EDIS	asm(" EDIS")
#define  DINT   asm(" setc INTM")


#endif // ---- End of EXAMPLE_FLASH280X_API_H     
