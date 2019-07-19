	//I/O register definitions for WDOG
	.equ	WDOG_BASE	, 0x40052000
	.equ	WDOG_CS 	, 0x00
	.equ	WDOG_CNT	, 0x04
	.equ	WDOG_TOVAL	, 0x08
	.equ	WDOG_WIN	, 0x0c
	
	//PERIPHERAL CLOCK CONTROL
	.equ	PCC_ACTIVE	, 0xC0000000
	.equ	PCC_INACTIVE	, 0x80000000
	.equ	PCC_BASE	, 0x40065000
	.equ	PCC_BASE2	, 0x40065100
	.equ	PCC_FTFC	, 0x080
	.equ	PCC_DMAMUX	, 0x084
	.equ	PCC_FLEXCAN0	, 0x090
	.equ	PCC_FLEXCAN1	, 0x094
	.equ	PCC_FTM3	, 0x098
	.equ	PCC_ADC1	, 0x09C
	.equ	PCC_FLEXCAN2	, 0x0AC
	.equ	PCC_LPSPI0	, 0x0B0
	.equ	PCC_LPSPI1	, 0x0B4
	.equ	PCC_LPSPI2	, 0x0B8
	.equ	PCC_PDB1	, 0x0C4

	.equ	PCC_CRC		, 0x0C8
	.equ	PCC_PDB0	, 0x0D8
	.equ	PCC_LPIT	, 0x0DC
	.equ	PCC_FTM0	, 0x0E0
	.equ	PCC_FTM1	, 0x0E4
	.equ	PCC_FTM2	, 0x0E8
	.equ	PCC_ADC0	, 0x0EC
	.equ	PCC_RTC		, 0x0F4
	
	.equ	PCC_LPTMR0	, 0x000
	.equ	PCC_PORTA	, 0x024
	.equ	PCC_PORTB	, 0x028
	.equ	PCC_PORTC	, 0x02C
	.equ	PCC_PORTD	, 0x030
	.equ	PCC_PORTE	, 0x034
	
	.equ	PCC_SAI0	, 0x050
	.equ	PCC_SAI1	, 0x054
	.equ	PCC_FLEXIO	, 0x068
	.equ	PCC_EWM		, 0x084
	
	.equ	PCC_LPI2C0	, 0x098
	.equ	PCC_LPI2C1	, 0x09C
	.equ	PCC_LPUART0	, 0x0A8
	.equ	PCC_LPUART1	, 0x0AC
	.equ	PCC_LPUART2	, 0x0B0
	.equ	PCC_FTM4	, 0x0B8
	.equ	PCC_FTM5	, 0x0BC
	.equ	PCC_FTM6	, 0x0C0
	.equ	PCC_FTM7	, 0x0C4
	
	.equ	PCC_CMP0	, 0x0CC
	.equ	PCC_QSPI	, 0x0D8
	.equ	PCC_ENET	, 0x0E4
	
	// GPIO
	.equ	GPIOA_BASE	, 0x400FF000
	.equ	GPIOB_BASE	, 0x400FF480
	.equ	GPIOC_BASE	, 0x400FF080
	.equ	GPIOD_BASE	, 0x400FF0C0
	.equ	GPIOE_BASE	, 0x400FF100
	.equ	PDOR		, 0x00
	.equ	PSOR		, 0x04
	.equ	PCOR		, 0x08
	.equ	PTOR		, 0x0c
	.equ	PDIR		, 0x10
	.equ	PDDR		, 0x14
	.equ	PIDR		, 0x18

	// PMUX
	.equ	PORTA_BASE	, 0x40049000
	.equ	PORTB_BASE	, 0x4004A000
	.equ	PORTC_BASE	, 0x4004B000
	.equ	PORTD_BASE	, 0x4004C000
	.equ	PORTE_BASE	, 0x4004D000
	.equ	PCR0		, 0
	.equ	PCR1		, 4
	.equ	PCR2		, 8
	.equ	PCR3		, 12
	.equ	PCR4		, 16
	.equ	PCR5		, 20
	.equ	PCR6		, 24
	.equ	PCR7		, 28
	.equ	PCR8		, 32
	.equ	PCR9		, 36
	.equ	PCR10		, 40
	.equ	PCR11		, 44
	.equ	PCR12		, 48
	.equ	PCR13		, 52
	.equ	PCR14		, 56
	.equ	PCR15		, 60
	.equ	PCR16		, 64
	.equ	PCR17		, 68
	.equ	PCR18		, 72
	.equ	PCR19		, 76
	.equ	PCR20		, 80
	.equ	PCR21		, 84
	.equ	PCR22		, 88
	.equ	PCR23		, 92
	.equ	PCR24		, 96
	.equ	PCR25		, 100
	.equ	PCR26		, 104
	.equ	PCR27		, 108
	.equ	PCR28		, 112
	.equ	PCR29		, 116
	.equ	PCR30		, 120
	.equ	PCR31		, 124
	.equ	GPCLR		, 0x80
	.equ	GPCHR		, 0x84
	.equ	GICLR		, 0x88
	.equ	GICHR		, 0x8C
	.equ	ISFR		, 0xA0
	.equ	DFER		, 0xC0
	.equ	DFCR		, 0xC4
	.equ	DFWR		, 0xC8
	
	
	// FLASH
	.equ	FLASH_BASE	, 0x40020000
	.equ	FSTAT		, 0x00
	.equ	FCNFG		, 0x01
	.equ	FSEC		, 0x02
	.equ	FOPT		, 0x03
	.equ	FCCOB3		, 0x04	
	.equ	FCCOB2		, 0x05	
	.equ	FCCOB1		, 0x06	
	.equ	FCCOB0		, 0x07	
	.equ	FCCOB7		, 0x08	
	.equ	FCCOB6		, 0x09	
	.equ	FCCOB5		, 0x0A	
	.equ	FCCOB4		, 0x0B	
	.equ	FCCOBB		, 0x0C	
	.equ	FCCOBA		, 0x0D	
	.equ	FCCOB9		, 0x0E	
	.equ	FCCOB8		, 0x0F	
	.equ	FPROT3		, 0x10	
	.equ	FPROT2		, 0x11	
	.equ	FPROT1		, 0x12	
	.equ	FPROT0		, 0x13	
	.equ	FEPROT		, 0x16
	.equ	FDPROT		, 0x17
	.equ	FCSESTAT	, 0x2C
	.equ	FERSTAT		, 0x2E
	.equ	FERCNFG		, 0x2F
	
	