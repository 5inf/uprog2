;-------------------------------------------------------------------------------
; Flash module
;-------------------------------------------------------------------------------
FLASH_DP	.equ		0x002c		;0xa80 >> 6
FBANKWAIT	.equ		0x0a86		;256*pagewait + randwait
FOTPWAIT	.equ		0x0a87		;otpwait

;-------------------------------------------------------------------------------
; CSM module
;-------------------------------------------------------------------------------
CSM_DP		.equ		0x002b		;0x0ae0 >> 6
KEY0		.equ		0x0ae0		;KEY register for unsecuring
KEY1		.equ		0x0ae1		;KEY register for unsecuring
KEY2		.equ		0x0ae2		;KEY register for unsecuring
KEY3		.equ		0x0ae3		;KEY register for unsecuring
KEY4		.equ		0x0ae4		;KEY register for unsecuring
KEY5		.equ		0x0ae5		;KEY register for unsecuring
KEY6		.equ		0x0ae6		;KEY register for unsecuring
KEY7		.equ		0x0ae7		;KEY register for unsecuring
CSMSCR		.equ		0x0aef		;CSM status and control register
SECURW		.equ		0		;SECURE bit
FORCESEC	.equ		15		;Force secure by software

;-------------------------------------------------------------------------------
; CLOCK module
;-------------------------------------------------------------------------------
CLOCK_DP	.equ		0x01c0		;0x7000 >> 6
XCLK		.equ		0x7010		;XCLK control
PLLSTS		.equ		0x7011		;PLL status register
HISPCP		.equ		0x701a		;High-Speed peripheral clock prescaler
LOSPCP		.equ		0x701b		;LOW-Speed peripheral clock prescaler
PCLKCR0		.equ		0x701c		;peripheral clock control register 0
PCLKCR1		.equ		0x701d		;peripheral clock control register 1
LPMCR0		.equ		0x701e		;low power mode control register 0
PLLCR		.equ		0x7021		;PLL control register
SCSR		.equ		0x7022		;system control and status register
WDCNTR		.equ		0x7023		;watchdog counter register
WDKEY		.equ		0x7025		;watchdog reset key register
WDCR		.equ		0x7029		;watchdog control register

;-------------------------------------------------------------------------------
; SCI-A module
;-------------------------------------------------------------------------------
SCIA_DP		.equ		0x01c1		;0x7050 >> 6
SCICCRA		.equ		0x7050		;Communications control register
SCICTL1A	.equ		0x7051		;control register 1
SCIHBAUDA	.equ		0x7052		;baud register
SCILBAUDA	.equ		0x7053		;
SCICTL2A	.equ		0x7054		;control register 2
SCIRXSTA	.equ		0x7055		;receive status register
SCIRXEMUA	.equ		0x7056		;receive emulation data buffer register
SCIRXBUFA	.equ		0x7057		;receive data buffer register
SCITXBUFA	.equ		0x7059		;transmit buffer register
SCIFFTXA	.equ		0x705a		;FIFO transmit register
SCIFFRXA	.equ		0x705b		;FIFO receive register
SCIFFCTA	.equ		0x705c		;FIFO control register
SCIPRIA		.equ		0x705f		;Priority control register

;-------------------------------------------------------------------------------
; SCI-B module
;-------------------------------------------------------------------------------
SCIB_DP		.equ		0x01dd		;0x7750 >> 6
SCICCRB		.equ		0x7750		;Communications control register
SCICTL1B	.equ		0x7751		;control register 1
SCIHBAUDB	.equ		0x7752		;baud register
SCILBAUDB	.equ		0x7753		;
SCICTL2B	.equ		0x7754		;control register 2
SCIRXSTB	.equ		0x7755		;receive status register
SCIRXEMUB	.equ		0x7756		;receive emulation data buffer register
SCIRXBUFB	.equ		0x7757		;receive data buffer register
SCITXBUFB	.equ		0x7759		;transmit buffer register
SCIFFTXB	.equ		0x775a		;FIFO transmit register
SCIFFRXB	.equ		0x775b		;FIFO receive register
SCIFFCTB	.equ		0x775c		;FIFO control register
SCIPRIB		.equ		0x775f		;Priority control register

;-------------------------------------------------------------------------------
; SCI module bits
;-------------------------------------------------------------------------------
RXENA		.equ		0		;(SCICTL1) enable Receiver
RXRDY		.equ		6		;(SCIRXST) new character received


;-------------------------------------------------------------------------------
; GPIO - CONTROL module
;-------------------------------------------------------------------------------
GPIO_CTRL_DP	.equ		0x01be		;0x6f80 >> 6

GPACTRL		.equ		0x6f80		;GPIO Control
GPACTRL_L	.equ		0x6f80
GPACTRL_H	.equ		0x6f81

GPAQSEL1	.equ		0x6f82		;
GPAQSEL1_L	.equ		0x6f82
GPAQSEL1_H	.equ		0x6f83

GPAQSEL2	.equ		0x6f84
GPAQSEL2_L	.equ		0x6f84
GPAQSEL2_H	.equ		0x6f85

GPAMUX1		.equ		0x6f86
GPAMUX1_L	.equ		0x6f86
GPAMUX1_H	.equ		0x6f87

GPAMUX2		.equ		0x6f88
GPAMUX2_L	.equ		0x6f88
GPAMUX2_H	.equ		0x6f89

GPADIR		.equ		0x6f8a
GPADIR_L	.equ		0x6f8a
GPADIR_H	.equ		0x6f8b

GPAPUD		.equ		0x6f8c
GPAPUD_L	.equ		0x6f8c
GPAPUD_H	.equ		0x6f8d

GPBCTRL		.equ		0x6f90		;GPIO Control
GPBCTRL_L	.equ		0x6f90
GPBCTRL_H	.equ		0x6f91

GPBQSEL1	.equ		0x6f92		;
GPBQSEL1_L	.equ		0x6f92
GPBQSEL1_H	.equ		0x6f93

GPBQSEL2	.equ		0x6f94
GPBQSEL2_L	.equ		0x6f94
GPBQSEL2_H	.equ		0x6f95

GPBMUX1		.equ		0x6f96
GPBMUX1_L	.equ		0x6f96
GPBMUX1_H	.equ		0x6f97

GPBMUX2		.equ		0x6f98
GPBMUX2_L	.equ		0x6f98
GPBMUX2_H	.equ		0x6f99

GPBDIR		.equ		0x6f9a
GPBDIR_L	.equ		0x6f9a
GPBDIR_H	.equ		0x6f9b

GPBPUD		.equ		0x6f9c
GPBPUD_L	.equ		0x6f9c
GPBPUD_H	.equ		0x6f9d


;-------------------------------------------------------------------------------
; GPIO - DATA module
;-------------------------------------------------------------------------------
GPIO_DATA_DP	.equ		0x01bf		;0x6fc0 >> 6

GPADAT		.equ		0x6fc0
GPADAT_L	.equ		0x6fc0
GPADAT_H	.equ		0x6fc1

GPASET		.equ		0x6fc2
GPASET_L	.equ		0x6fc2
GPASET_H	.equ		0x6fc3

GPACLEAR	.equ		0x6fc4
GPACLEAR_L	.equ		0x6fc4
GPACLEAR_H	.equ		0x6fc5

GPATOGGLE	.equ		0x6fc6
GPATOGGLE_L	.equ		0x6fc6
GPATOGGLE_H	.equ		0x6fc7

GPBDAT		.equ		0x6fc8
GPBDAT_L	.equ		0x6fc8
GPBDAT_H	.equ		0x6fc9

GPBSET		.equ		0x6fca
GPBSET_L	.equ		0x6fca
GPBSET_H	.equ		0x6fcb

GPBCLEAR	.equ		0x6fcc
GPBCLEAR_L	.equ		0x6fcc
GPBCLEAR_H	.equ		0x6fcd

GPBTOGGLE	.equ		0x6fce
GPBTOGGLE_L	.equ		0x6fce
GPBTOGGLE_H	.equ		0x6fcf



