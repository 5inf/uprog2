	// ICS
	.equ	ICS_BASE	, 0x40064000
	.equ	ICS_C1 		, 0x00
	.equ	ICS_C2 		, 0x01
	.equ	ICS_C3 		, 0x02
	.equ	ICS_C4 		, 0x03
	.equ	ICS_S 		, 0x03

	// WDOG
	.equ	WDOG_BASE	, 0x40052000
	.equ	WDOG_CS1 	, 0x00
	.equ	WDOG_CS2 	, 0x01
	.equ	WDOG_CNTH	, 0x02
	.equ	WDOG_CNTL	, 0x03
	.equ	WDOG_TOVALH	, 0x04
	.equ	WDOG_TOVALL	, 0x05
	.equ	WDOG_WINH	, 0x06
	.equ	WDOG_WINL	, 0x07
	
	// GPIO
	.equ	GPIOA_BASE	, 0x400FF000
	.equ	GPIOB_BASE	, 0x400FF000
	.equ	PDOR		, 0x00
	.equ	PSOR		, 0x04
	.equ	PCOR		, 0x08
	.equ	PTOR		, 0x0c
	.equ	PDIR		, 0x10
	.equ	PDDR		, 0x14
	.equ	PIDR		, 0x18


	// PMUX
	.equ	PORT_IOFLT	, 0x40049000
	.equ	PORT_PUEL	, 0x40049004
	.equ	PORT_PUEH	, 0x40049008
	.equ	PORT_HDRVE	, 0x4004900C
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
	.equ	FCLKDIV		, 0x00
	.equ	FSEC		, 0x01
	.equ	FCCOBIX		, 0x02
	.equ	FCNFG		, 0x04
	.equ	FERCNFG		, 0x05
	.equ	FSTAT		, 0x06
	.equ	FERSTAT		, 0x07
	.equ	FPROT		, 0x08	
	.equ	EEPROT		, 0x09
	.equ	FCCOBHI		, 0x0A
	.equ	FCCOBLO		, 0x0B
	.equ	FOPT		, 0x0C
	
	
	