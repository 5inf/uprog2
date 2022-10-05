	

	//GPIO registers
	.equ	GPIO_BASE		, 0x48028000

	.equ	GPIO_P0_DATA		, 0x00
	.equ	GPIO_P0_DIR		, 0x04
	.equ	GPIO_P1_DATA		, 0x08
	.equ	GPIO_P1_DIR		, 0x0C
	.equ	GPIO_P2_DATA		, 0x10
	.equ	GPIO_P2_DIR		, 0x14
	.equ	GPIO_P0_PUDSEL		, 0x18
	.equ	GPIO_P0_PUDEN		, 0x1C
	.equ	GPIO_P1_PUDSEL		, 0x20
	.equ	GPIO_P1_PUDEN		, 0x24
	.equ	GPIO_P2_PUDSEL		, 0x28
	.equ	GPIO_P2_PUDEN		, 0x2C

	.equ	GPIO_P0_ALTSEL0		, 0x30
	.equ	GPIO_P0_ALTSEL1		, 0x34
	.equ	GPIO_P1_ALTSEL0		, 0x38
	.equ	GPIO_P1_ALTSEL1		, 0x3C
	
	.equ	GPIO_P0_OD		, 0x40
	.equ	GPIO_P1_OD		, 0x44


	