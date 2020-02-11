const char * const cables[]=
{
	// 0 
	"no cable defined",

	// 1 (HCS08-BDM)
	"(1=VSS  2=VDD  3=RESET  4=BKGD)",

	// 2 (R8C)
	"(1=VSS  2=VDD  3=RESET  4=MODE)",

	// 3 (AVR)
	"(1=VSS  2=VDD  3=RST  4=SCK  5=MISO  6=MOSI)",

	// 4 (MSP430-SBW)
	"(1=VSS  2=VDD  3=TEST  4=RESET)",

	// 5 (MSP430-SBW)
	"(1=VSS  2=VDD  3=TEST  4=RESET)",

	// 6 (S12XE-BDM)
	"(1=VSS  2=VDD  3=RESET  4=BKGD)",

	// 7 (S12XD-BDM)
	"(1=VSS  2=VDD  3=RESET  4=BKGD)",

	// 8 (STM8-SWIM)
	"(1=VSS  2=VDD  3=RESET  4=SWIM)",

	// 9 
	"no connections",

	// 10 (dsPIC33)
	"(1=VSS  2=VDD  3=PGD  4=PGC)",

	// 11 (S12XS-BDM)
	"(1=VSS  2=VDD  3=RESET  4=BKGD)",

	// 12 (78K0R)
	"(1=VSS  2=VDD  3=RESET  4=TOOL0  5=FLMD0)",

	// 13 (RL78)
	"(1=VSS  2=VDD  3=RESET  4=TOOL0)",

	// 14 (PIC16)
	"(1=VSS  2=VDD  3=PGD  4=PGC  9=MCLR)",

	// 15 (PIC16)
	"(1=VSS  2=VDD  3=PGD  4=PGC  9=MCLR)",

	// 16 (PPC-BAM)
	"(1=VSS  2=VDD  3=RESET  4=RX  5=TX  7=FAB)",

	// 17 (PIC18)
	"(1=VSS  2=VDD  3=PGD  4=PGC  9=MCLR)",

	// 18 (dsPIC30)
	"(1=VSS  2=VDD  3=PGD  4=PGC  9=MCLR)",

	// 19 
	"no connections",

	// 20 (ST7FLITE)
	"(1=VSS  2=VDD  3=ICCCLK  4=ICCDATA  5=RESET)",

	// 21 (I2C)
	"(1=VSS  2=VDD  3=SCL  4=SDA)",

	// 22 (SPI flash)
	"(1=VSS  2=VDD  3=/CS  4=SCK  5=SI  6=SO (7=IO2  8=IO3)",

	// 23 (dataflash)
	"(1=VSS  2=VDD  3=/CS  4=SCK  5=MOSI  6=MISO",

	// 24 
	"no connections",

	// 25 (SPI)
	"(1=VSS  2=VDD  3=SEL  4=SCK  5=MOSI  6=MISO)",

	// 26 (RH850)
	"(1=VSS  2=VDD  3=RESET  4=FPCK  5=FPDR  6=FPDT  7=FLMD0",

	// 27 (MRK3)
	"(1=VSS  2=VDD  3=MSCL  4=MSDA)",

	// 28 (Elmos SBW)	
	"(1=VSS  2=VDD  3=TCK  4=TDA  5=TST)",

	// 29
	"no connections",

	// 30 (XC95xx JTAG)
	"(1=VSS  2=VDD  3=TMS  4=TCK  5=TDI  6=TDO)",

	// 31 (CC25xx)
	"(1=VSS  2=VDD  3=RST  4=DC  5=DD)",

	// 32 (PSOC4 SWD)
	"(1=VSS  2=VDD  3=RST  4=SWDCK  5=SWDIO)",

	// 33 (STM32 F0xx SWD)
	"(1=VSS  2=VDD  3=RST  4=SWDCK  5=SWDIO)",

	// 34 (STM32 F1xx SWD) 
	"(1=VSS  2=VDD  3=RST  4=SWDCK  5=SWDIO)",
	
	// 35  (STM32 F2xx SWD)
	"(1=VSS  2=VDD  3=RST  4=SWDCK  5=SWDIO)",
	
	// 36  (STM32 F3xx SWD)
	"(1=VSS  2=VDD  3=RST  4=SWDCK  5=SWDIO)",
	
	// 37  (STM32 F4xx SWD)
	"(1=VSS  2=VDD  3=RST  4=SWDCK  5=SWDIO)",
	
	// 38 
	"no connections",
	
	// 39 
	"no connections",
	
	// 40 
	"(1=VSS  2=VDD  3=RST  4=PDI)",
	
	// 41 (I2C)
	"(1=VSS  2=VDD  3=SCL  4=SDA)",

	// 42 (V850) 
	"(1=VSS  2=VDD  3=RESET  4=SCK  5=SI  6=SO  7=FLMD0)",
	
	// 43 (MLX90363) 
	"(1=VSS  2=VDD  3=SEL  4=SCK  5=MOSI  6=MISO)",
	
	// 44 (PPC JTAG) 
	"(1=VSS  2=VDD  3=TMS  4=TCK  5=TDI  6=TDO  [8=RESET])",
	
	// 45 (PPC JTAG2)
	"(1=VSS  2=VDD  3=TMS  4=TCK  5=TDI  6=TDO  7=JCOMP  [8=RESET])",
	
	// FRS
	"no connections",
	
	// 47 
	"(1=VSS  2=VDD  3=SEL  4=SCK  5=MOSI  6=MISO)",
	
	// 48 (SP40) 
	"(1=VSS  2=VDD  3=SCL  4=SDA)",

	// 49 (LPS25H) 
	"(1=VSS  2=VDD  3=SCL  4=SDA)",

	// 50 (MLX90316) 
	"(1=VSS  2=VDD  3=SEL  4=MOSI/MISO  5=SCK)",
	
	// 51 (CC2640) 
	"(1=VSS  2=VDD  3=TMS  4=TCK  5=TDI  6=TDO  [8=RESET])",
	
	// 52 (STM32L4xx)
	"(1=VSS  2=VDD  3=RST  4=SWDCK  5=SWDIO)",
	
	// 53 (S32K) 
	"(1=VSS  2=VDD  3=RST  4=SWDCK  5=SWDIO)",
	
	// 54 (PPC JTAG 3)
	"(1=VSS  2=VDD  3=TMS  4=TCK  5=TDI  6=TDO  7=JCOMP  [8=RESET])",
	
	// 55 PIC16
	"(1=VSS  2=VDD  3=PGD  4=PGC  9=MCLR)",
	
	// 56 S9KEA 
	"(1=VSS  2=VDD  3=RST  4=SWDCK  5=SWDIO)",
	
	// 57 PIC16 
	"(1=VSS  2=VDD  3=PGD  4=PGC  9=MCLR)",
	
	// 58 RF430
	"(1=VSS  2=VDD  3=TEST  4=RESET  5=TEN  6=TCLK  7=TDAT)",

	// 59 SICI 
	"(1=VSS  2=VDD  3=IFB)",

	// 60 AVR0
	"(1=VSS  2=VDD  3=UPDI)",
	
	// 61 
	"no connections",
	
	// 62 
	"no connections",
	
	// 63 
	"no connections",
	
	// 64 
	"no connections",
	
	// 65 
	"no connections",
	
	// 66 
	"no connections",
	
	// 67 
	"no connections",
	
	// 68 
	"no connections",

	// 69 
	"no connections"

	// 70 
	"no connections",
	
	// 71 
	"no connections",
	
	// 72 
	"no connections",
	
	// 73 
	"no connections",
	
	// 74 
	"no connections",
	
	// 75 
	"no connections",
	
	// 76 
	"no connections",
	
	// 77 
	"no connections",
	
	// 78 
	"no connections",

	// 79 
	"no connections"
};	
