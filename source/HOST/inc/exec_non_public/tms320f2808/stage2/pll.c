int set_pll(void)
{
/*------------------------------------------------------------------
 Initalize the PLLCR value before calling any of the F280x Flash API 
 functions.

     Check to see if the PLL needs to changed
     PLLCR_VALUE is defined in Example_Flash280x_API.h
     1) Make sure PLL is not in limp mode
     2) Disable missing clock detect logic
     3) Make the change
     4) Wait for the DSP to switch to the PLL clock
        This wait is performed to ensure that the flash API functions 
        will be executed at the correct frequency.
     5) While waiting, feed the watchdog so it will not reset.
     6) Re-enable the missing clock detect logic 
------------------------------------------------------------------*/
	// Assuming PLLSTS[CLKINDIV] = 0 (default on XRSn).  If it is not
	// 0, then the PLLCR cannot be written to. 
	// Make sure the PLL is not running in limp mode
	if (SysCtrlRegs.PLLSTS.bit.MCLKSTS != 1)
	{
		if (SysCtrlRegs.PLLCR.bit.DIV != PLLCR_VALUE)
		{
			EALLOW;
			// Before setting PLLCR turn off missing clock detect
			SysCtrlRegs.PLLSTS.bit.MCLKOFF = 1;
			SysCtrlRegs.PLLCR.bit.DIV = PLLCR_VALUE;
			EDIS;

			// Wait for PLL to lock.
			// During this time the CPU will switch to OSCCLK/2 until
			// the PLL is stable.  Once the PLL is stable the CPU will
			// switch to the new PLL value. 
			//
			// This time-to-lock is monitored by a PLL lock counter.
			//
			// The watchdog should be disabled before this loop, or fed within
			// the loop.
			EALLOW;
			SysCtrlRegs.WDCR= 0x0068;
			EDIS;
			// Wait for the PLL lock bit to be set.  
			// Note this bit is not available on 281x devices.  For those devices
			// use a software loop to perform the required count. 

			while(SysCtrlRegs.PLLSTS.bit.PLLLOCKS != 1) { }
			EALLOW;
			SysCtrlRegs.PLLSTS.bit.MCLKOFF = 0;
			EDIS;
		}
		return 0;
	}
	// If the PLL is in limp mode, halt
	else 
	{
		return 1;
	}
}

