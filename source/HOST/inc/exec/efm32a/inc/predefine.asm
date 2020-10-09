//------------------------------------------------------------
// LED PORT
//------------------------------------------------------------
.if LED_PORT == PORT_A
	.equ PCC_LED_PORT , PCC_PORTA
	.equ LED_PBASE , PORTA_BASE
	.equ LED_BASE , GPIOA_BASE
.endif

.if LED_PORT == PORT_B
	.equ PCC_LED_PORT , PCC_PORTB
	.equ LED_PBASE , PORTB_BASE
	.equ LED_BASE , GPIOB_BASE
.endif

.if LED_PORT == PORT_C
	.equ PCC_LED_PORT , PCC_PORTC
	.equ LED_PBASE , PORTC_BASE
	.equ LED_BASE , GPIOC_BASE
.endif

.if LED_PORT == PORT_D
	.equ PCC_LED_PORT , PCC_PORTD
	.equ LED_PBASE , PORTD_BASE
	.equ LED_BASE , GPIOD_BASE
.endif

.if LED_PORT == PORT_E
	.equ PCC_LED_PORT , PCC_PORTE
	.equ LED_PBASE , PORTE_BASE
	.equ LED_BASE , GPIOE_BASE
.endif


//------------------------------------------------------------
// SPX PORT
//------------------------------------------------------------
.if SPX_PORT == PORT_A
	.equ PCC_SPX_PORT , PCC_PORTA
	.equ SPX_PBASE , PORTA_BASE
	.equ SPX_BASE , GPIOA_BASE
.endif

.if SPX_PORT == PORT_B
	.equ PCC_SPX_PORT , PCC_PORTB
	.equ SPX_PBASE , PORTB_BASE
	.equ SPX_BASE , GPIOB_BASE
.endif

.if SPX_PORT == PORT_C
	.equ PCC_SPX_PORT , PCC_PORTC
	.equ SPX_PBASE , PORTC_BASE
	.equ SPX_BASE , GPIOC_BASE
.endif

.if SPX_PORT == PORT_D
	.equ PCC_SPX_PORT , PCC_PORTD
	.equ SPX_PBASE , PORTD_BASE
	.equ SPX_BASE , GPIOD_BASE
.endif

.if SPX_PORT == PORT_E
	.equ PCC_SPX_PORT , PCC_PORTE
	.equ SPX_PBASE , PORTE_BASE
	.equ SPX_BASE , GPIOE_BASE
.endif


//------------------------------------------------------------
// SPXC PORT
//------------------------------------------------------------
.if SPXC_PORT == PORT_A
	.equ PCC_SPXC_PORT , PCC_PORTA
	.equ SPXC_PBASE , PORTA_BASE
	.equ SPXC_BASE , GPIOA_BASE
.endif

.if SPXC_PORT == PORT_B
	.equ PCC_SPXC_PORT , PCC_PORTB
	.equ SPXC_PBASE , PORTB_BASE
	.equ SPXC_BASE , GPIOB_BASE
.endif

.if SPXC_PORT == PORT_C
	.equ PCC_SPXC_PORT , PCC_PORTC
	.equ SPXC_PBASE , PORTC_BASE
	.equ SPXC_BASE , GPIOC_BASE
.endif

.if SPXC_PORT == PORT_D
	.equ PCC_SPXC_PORT , PCC_PORTD
	.equ SPXC_PBASE , PORTD_BASE
	.equ SPXC_BASE , GPIOD_BASE
.endif

.if SPXC_PORT == PORT_E
	.equ PCC_SPXC_PORT , PCC_PORTE
	.equ SPXC_PBASE , PORTE_BASE
	.equ SPXC_BASE , GPIOE_BASE
.endif



//------------------------------------------------------------
// SPXD PORT
//------------------------------------------------------------
.if SPXD_PORT == PORT_A
	.equ PCC_SPXD_PORT , PCC_PORTA
	.equ SPXD_PBASE , PORTA_BASE
	.equ SPXD_BASE , GPIOA_BASE
.endif

.if SPXD_PORT == PORT_B
	.equ PCC_SPXD_PORT , PCC_PORTB
	.equ SPXD_PBASE , PORTB_BASE
	.equ SPXD_BASE , GPIOB_BASE
.endif

.if SPXD_PORT == PORT_C
	.equ PCC_SPXD_PORT , PCC_PORTC
	.equ SPXD_PBASE , PORTC_BASE
	.equ SPXD_BASE , GPIOC_BASE
.endif

.if SPXD_PORT == PORT_D
	.equ PCC_SPXD_PORT , PCC_PORTD
	.equ SPXD_PBASE , PORTD_BASE
	.equ SPXD_BASE , GPIOD_BASE
.endif

.if SPXD_PORT == PORT_E
	.equ PCC_SPXD_PORT , PCC_PORTE
	.equ SPXD_PBASE , PORTE_BASE
	.equ SPXD_BASE , GPIOE_BASE
.endif


//------------------------------------------------------------
// LED PINMASKS
//------------------------------------------------------------
.if RLED == 0
	.equ RLED_MASK , 0x0001
	.equ RLED_IMASK , 0xFFFE
	.equ RLED_PCR, PCR0
.endif

.if RLED == 1
	.equ RLED_MASK , 0x0002
	.equ RLED_IMASK , 0xFFFD
	.equ RLED_PCR, PCR1
.endif

.if RLED == 2
	.equ RLED_MASK , 0x0004
	.equ RLED_IMASK , 0xFFFB
	.equ RLED_PCR, PCR2
.endif

.if RLED == 3
	.equ RLED_MASK , 0x0008
	.equ RLED_IMASK , 0xFFF7
	.equ RLED_PCR, PCR3
.endif

.if RLED == 4
	.equ RLED_MASK , 0x0010
	.equ RLED_IMASK , 0xFFEF
	.equ RLED_PCR, PCR4
.endif

.if RLED == 5
	.equ RLED_MASK , 0x0020
	.equ RLED_IMASK , 0xFFDF
	.equ RLED_PCR, PCR5
.endif

.if RLED == 6
	.equ RLED_MASK , 0x0040
	.equ RLED_IMASK , 0xFFBF
	.equ RLED_PCR, PCR6
.endif

.if RLED == 7
	.equ RLED_MASK , 0x0080
	.equ RLED_IMASK , 0xFF7F
	.equ RLED_PCR, PCR7
.endif

.if RLED == 8
	.equ RLED_MASK , 0x0100
	.equ RLED_IMASK , 0xFEFF
	.equ RLED_PCR, PCR8
.endif

.if RLED == 9
	.equ RLED_MASK , 0x0200
	.equ RLED_IMASK , 0xFDFF
	.equ RLED_PCR, PCR9
.endif

.if RLED == 10
	.equ RLED_MASK , 0x0400
	.equ RLED_IMASK , 0xFBFF
	.equ RLED_PCR, PCR10
.endif

.if RLED == 11
	.equ RLED_MASK , 0x0800
	.equ RLED_IMASK , 0xF7FF
	.equ RLED_PCR, PCR11
.endif

.if RLED == 12
	.equ RLED_MASK , 0x1000
	.equ RLED_IMASK , 0xEFFF
	.equ RLED_PCR, PCR12
.endif

.if RLED == 13
	.equ RLED_MASK , 0x2000
	.equ RLED_IMASK , 0xDFFF
	.equ RLED_PCR, PCR13
.endif

.if RLED == 14
	.equ RLED_MASK , 0x4000
	.equ RLED_IMASK , 0xBFFF
	.equ RLED_PCR, PCR14
.endif

.if RLED == 15
	.equ RLED_MASK , 0x8000
	.equ RLED_IMASK , 0x7FFF
	.equ RLED_PCR, PCR15
.endif

.if GLED == 0
	.equ GLED_MASK , 0x0001
	.equ GLED_IMASK , 0xFFFE
	.equ GLED_PCR, PCR0
.endif

.if GLED == 1
	.equ GLED_MASK , 0x0002
	.equ GLED_IMASK , 0xFFFD
	.equ GLED_PCR, PCR1
.endif

.if GLED == 2
	.equ GLED_MASK , 0x0004
	.equ GLED_IMASK , 0xFFFB
	.equ GLED_PCR, PCR2
.endif

.if GLED == 3
	.equ GLED_MASK , 0x0008
	.equ GLED_IMASK , 0xFFF7
	.equ GLED_PCR, PCR3
.endif

.if GLED == 4
	.equ GLED_MASK , 0x0010
	.equ GLED_IMASK , 0xFFEF
	.equ GLED_PCR, PCR4
.endif

.if GLED == 5
	.equ GLED_MASK , 0x0020
	.equ GLED_IMASK , 0xFFDF
	.equ GLED_PCR, PCR5
.endif

.if GLED == 6
	.equ GLED_MASK , 0x0040
	.equ GLED_IMASK , 0xFFBF
	.equ GLED_PCR, PCR6
.endif

.if GLED == 7
	.equ GLED_MASK , 0x0080
	.equ GLED_IMASK , 0xFF7F
	.equ GLED_PCR, PCR7
.endif

.if GLED == 8
	.equ GLED_MASK , 0x0100
	.equ GLED_IMASK , 0xFEFF
	.equ GLED_PCR, PCR8
.endif

.if GLED == 9
	.equ GLED_MASK , 0x0200
	.equ GLED_IMASK , 0xFDFF
	.equ GLED_PCR, PCR9
.endif

.if GLED == 10
	.equ GLED_MASK , 0x0400
	.equ GLED_IMASK , 0xFBFF
	.equ GLED_PCR, PCR10
.endif

.if GLED == 11
	.equ GLED_MASK , 0x0800
	.equ GLED_IMASK , 0xF7FF
	.equ GLED_PCR, PCR11
.endif

.if GLED == 12
	.equ GLED_MASK , 0x1000
	.equ GLED_IMASK , 0xEFFF
	.equ GLED_PCR, PCR12
.endif

.if GLED == 13
	.equ GLED_MASK , 0x2000
	.equ GLED_IMASK , 0xDFFF
	.equ GLED_PCR, PCR13
.endif

.if GLED == 14
	.equ GLED_MASK , 0x4000
	.equ GLED_IMASK , 0xBFFF
	.equ GLED_PCR, PCR14
.endif

.if GLED == 15
	.equ GLED_MASK , 0x8000
	.equ GLED_IMASK , 0x7FFF
	.equ GLED_PCR, PCR15
.endif

//------------------------------------------------------------
// SIGNAL PINMASKS
//------------------------------------------------------------
.if SPXC == 0
	.equ SPXC_MASK , 0x0001
	.equ SPXC_IMASK , 0xFFFE
	.equ SPXC_PCR, PCR0
.endif

.if SPXC == 1
	.equ SPXC_MASK , 0x0002
	.equ SPXC_IMASK , 0xFFFD
	.equ SPXC_PCR, PCR1
.endif

.if SPXC == 2
	.equ SPXC_MASK , 0x0004
	.equ SPXC_IMASK , 0xFFFB
	.equ SPXC_PCR, PCR2
.endif

.if SPXC == 3
	.equ SPXC_MASK , 0x0008
	.equ SPXC_IMASK , 0xFFF7
	.equ SPXC_PCR, PCR3
.endif

.if SPXC == 4
	.equ SPXC_MASK , 0x0010
	.equ SPXC_IMASK , 0xFFEF
	.equ SPXC_PCR, PCR4
.endif

.if SPXC == 5
	.equ SPXC_MASK , 0x0020
	.equ SPXC_IMASK , 0xFFDF
	.equ SPXC_PCR, PCR5
.endif

.if SPXC == 6
	.equ SPXC_MASK , 0x0040
	.equ SPXC_IMASK , 0xFFBF
	.equ SPXC_PCR, PCR6
.endif

.if SPXC == 7
	.equ SPXC_MASK , 0x0080
	.equ SPXC_IMASK , 0xFF7F
	.equ SPXC_PCR, PCR7
.endif

.if SPXC == 8
	.equ SPXC_MASK , 0x0100
	.equ SPXC_IMASK , 0xFEFF
	.equ SPXC_PCR, PCR8
.endif

.if SPXC == 9
	.equ SPXC_MASK , 0x0200
	.equ SPXC_IMASK , 0xFDFF
	.equ SPXC_PCR, PCR9
.endif

.if SPXC == 10
	.equ SPXC_MASK , 0x0400
	.equ SPXC_IMASK , 0xFBFF
	.equ SPXC_PCR, PCR10
.endif

.if SPXC == 11
	.equ SPXC_MASK , 0x0800
	.equ SPXC_IMASK , 0xF7FF
	.equ SPXC_PCR, PCR11
.endif

.if SPXC == 12
	.equ SPXC_MASK , 0x1000
	.equ SPXC_IMASK , 0xEFFF
	.equ SPXC_PCR, PCR12
.endif

.if SPXC == 13
	.equ SPXC_MASK , 0x2000
	.equ SPXC_IMASK , 0xDFFF
	.equ SPXC_PCR, PCR13
.endif

.if SPXC == 14
	.equ SPXC_MASK , 0x4000
	.equ SPXC_IMASK , 0xBFFF
	.equ SPXC_PCR, PCR14
.endif

.if SPXC == 15
	.equ SPXC_MASK , 0x8000
	.equ SPXC_IMASK , 0x7FFF
	.equ SPXC_PCR, PCR15
.endif

.if SPXD == 0
	.equ SPXD_MASK , 0x0001
	.equ SPXD_IMASK , 0xFFFE
	.equ SPXD_PCR, PCR0
.endif

.if SPXD == 1
	.equ SPXD_MASK , 0x0002
	.equ SPXD_IMASK , 0xFFFD
	.equ SPXD_PCR, PCR1
.endif

.if SPXD == 2
	.equ SPXD_MASK , 0x0004
	.equ SPXD_IMASK , 0xFFFB
	.equ SPXD_PCR, PCR2
.endif

.if SPXD == 3
	.equ SPXD_MASK , 0x0008
	.equ SPXD_IMASK , 0xFFF7
	.equ SPXD_PCR, PCR3
.endif

.if SPXD == 4
	.equ SPXD_MASK , 0x0010
	.equ SPXD_IMASK , 0xFFEF
	.equ SPXD_PCR, PCR4
.endif

.if SPXD == 5
	.equ SPXD_MASK , 0x0020
	.equ SPXD_IMASK , 0xFFDF
	.equ SPXD_PCR, PCR5
.endif

.if SPXD == 6
	.equ SPXD_MASK , 0x0040
	.equ SPXD_IMASK , 0xFFBF
	.equ SPXD_PCR, PCR6
.endif

.if SPXD == 7
	.equ SPXD_MASK , 0x0080
	.equ SPXD_IMASK , 0xFF7F
	.equ SPXD_PCR, PCR7
.endif

.if SPXD == 8
	.equ SPXD_MASK , 0x0100
	.equ SPXD_IMASK , 0xFEFF
	.equ SPXD_PCR, PCR8
.endif

.if SPXD == 9
	.equ SPXD_MASK , 0x0200
	.equ SPXD_IMASK , 0xFDFF
	.equ SPXD_PCR, PCR9
.endif

.if SPXD == 10
	.equ SPXD_MASK , 0x0400
	.equ SPXD_IMASK , 0xFBFF
	.equ SPXD_PCR, PCR10
.endif

.if SPXD == 11
	.equ SPXD_MASK , 0x0800
	.equ SPXD_IMASK , 0xF7FF
	.equ SPXD_PCR, PCR11
.endif

.if SPXD == 12
	.equ SPXD_MASK , 0x1000
	.equ SPXD_IMASK , 0xEFFF
	.equ SPXD_PCR, PCR12
.endif

.if SPXD == 13
	.equ SPXD_MASK , 0x2000
	.equ SPXD_IMASK , 0xDFFF
	.equ SPXD_PCR, PCR13
.endif

.if SPXD == 14
	.equ SPXD_MASK , 0x4000
	.equ SPXD_IMASK , 0xBFFF
	.equ SPXD_PCR, PCR14
.endif

.if SPXD == 15
	.equ SPXD_MASK , 0x8000
	.equ SPXD_IMASK , 0x7FFF
	.equ SPXD_PCR, PCR15
.endif

.if AUX == 0
	.equ AUX_MASK , 0x0001
	.equ AUX_IMASK , 0xFFFE
	.equ AUX_PCR, PCR0
.endif

.if AUX == 1
	.equ AUX_MASK , 0x0002
	.equ AUX_IMASK , 0xFFFD
	.equ AUX_PCR, PCR1
.endif

.if AUX == 2
	.equ AUX_MASK , 0x0004
	.equ AUX_IMASK , 0xFFFB
	.equ AUX_PCR, PCR2
.endif

.if AUX == 3
	.equ AUX_MASK , 0x0008
	.equ AUX_IMASK , 0xFFF7
	.equ AUX_PCR, PCR3
.endif

.if AUX == 4
	.equ AUX_MASK , 0x0010
	.equ AUX_IMASK , 0xFFEF
	.equ AUX_PCR, PCR4
.endif

.if AUX == 5
	.equ AUX_MASK , 0x0020
	.equ AUX_IMASK , 0xFFDF
	.equ AUX_PCR, PCR5
.endif

.if AUX == 6
	.equ AUX_MASK , 0x0040
	.equ AUX_IMASK , 0xFFBF
	.equ AUX_PCR, PCR6
.endif

.if AUX == 7
	.equ AUX_MASK , 0x0080
	.equ AUX_IMASK , 0xFF7F
	.equ AUX_PCR, PCR7
.endif

.if AUX == 8
	.equ AUX_MASK , 0x0100
	.equ AUX_IMASK , 0xFEFF
	.equ AUX_PCR, PCR8
.endif

.if AUX == 9
	.equ AUX_MASK , 0x0200
	.equ AUX_IMASK , 0xFDFF
	.equ AUX_PCR, PCR9
.endif

.if AUX == 10
	.equ AUX_MASK , 0x0400
	.equ AUX_IMASK , 0xFBFF
	.equ AUX_PCR, PCR10
.endif

.if AUX == 11
	.equ AUX_MASK , 0x0800
	.equ AUX_IMASK , 0xF7FF
	.equ AUX_PCR, PCR11
.endif

.if AUX == 12
	.equ AUX_MASK , 0x1000
	.equ AUX_IMASK , 0xEFFF
	.equ AUX_PCR, PCR12
.endif

.if AUX == 13
	.equ AUX_MASK , 0x2000
	.equ AUX_IMASK , 0xDFFF
	.equ AUX_PCR, PCR13
.endif

.if AUX == 14
	.equ AUX_MASK , 0x4000
	.equ AUX_IMASK , 0xBFFF
	.equ AUX_PCR, PCR14
.endif

.if AUX == 15
	.equ AUX_MASK , 0x8000
	.equ AUX_IMASK , 0x7FFF
	.equ AUX_PCR, PCR15
.endif

.equ LED_MASK , RLED_MASK | GLED_MASK
