	//I/O register definitions for FLASH

	.equ	FLASH_BASE	, 0x40022000
	.equ	FLASH_ACR	, 0x00
	.equ	FLASH_PDKEYR	, 0x04
	.equ	FLASH_KEYR	, 0x08
	.equ	FLASH_OPTKEYR	, 0x0C
	.equ	FLASH_SR	, 0x10
	.equ	FLASH_CR	, 0x14
	.equ	FLASH_ECCR	, 0x18
	.equ	FLASH_OPTR	, 0x20
	.equ	FLASH_PCROP1SR	, 0x24
	.equ	FLASH_PCROP1ER	, 0x28
	.equ	FLASH_WRP1AR	, 0x2C
	.equ	FLASH_WRP1BR	, 0x30
	.equ	FLASH_PCROP2SR	, 0x44
	.equ	FLASH_PCROP2ER	, 0x48
	.equ	FLASH_WRP2AR	, 0x4C
	.equ	FLASH_WRP2BR	, 0x50
	
	
	//I/O register definitions for RCC
	.equ	RCC_BASE	, 0x40021000
	.equ	RCC_AHB2ENR	, 0x4C
	
	
	//I/O register definitions for PORT C
	.equ	PORTC_BASE	, 0x48000800
	.equ	PORTC_MODER	, 0x00
	.equ	PORTC_IDR	, 0x10
	.equ	PORTC_ODR	, 0x14
	
	
	
	