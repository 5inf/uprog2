.equ		SPI_CS		= SIG1
.equ		SPI_SCK		= SIG2
.equ		SPI_MOSI	= SIG3
.equ		SPI_MISO	= SIG4

.equ		SPI_SCK_PULSE	= SIG2_OR

;------------------------------------------------------------------------------
; init SPI, mode 0
;------------------------------------------------------------------------------
spi0_init:		out	CTRLPORT,const_0
			out	CTRLDDR,const_0
			call	api_vcc_on
spi0_reinit:		ldi	XL,0x3d
			out	CTRLPORT,XL
			ldi	XL,0x37
			out	CTRLDDR,XL
			
			ret

;------------------------------------------------------------------------------
; init SPI, mode 3
;------------------------------------------------------------------------------
spi3_init:		out	CTRLPORT,const_0
			out	CTRLDDR,const_0
			call	api_vcc_on
spi3_reinit:		ldi	XL,0x37
			out	CTRLPORT,XL
			out	CTRLDDR,XL
			
			ret

;------------------------------------------------------------------------------
; exit SPI
;------------------------------------------------------------------------------
spi_exit:		out	CTRLPORT,const_0
			out	CTRLDDR,const_0
			call	api_vcc_off
			ret

;------------------------------------------------------------------------------
; set CSN active
;------------------------------------------------------------------------------
spi_active:		cbi	CTRLPORT,SPI_CS
			ret

;------------------------------------------------------------------------------
; set CSN inactive
;------------------------------------------------------------------------------
spi_inactive:		sbi	CTRLPORT,SPI_CS
			ret

;------------------------------------------------------------------------------
; exchange byte XL -> XL
; ca. 1MHz
;------------------------------------------------------------------------------
spi_zerobyte:		clr	XL
spi_byte:		ldi	r22,SPI_SCK_PULSE
			ldi	r21,8
spi_byte_1:		sbrc	XL,7
			sbi	CTRLPORT,SPI_MOSI
			sbrs	XL,7
			cbi	CTRLPORT,SPI_MOSI
			out	CTRLPIN,r22		;clock pulse
			lsl	XL
			sbic	CTRLPIN,SPI_MISO
			inc	XL		
			out	CTRLPIN,r22
			dec	r21
			brne	spi_byte_1
			ret

spi_byte_fast:		ldi	r22,SPI_SCK_PULSE
			ldi	r21,0xFF
spi_bytef_1:		sbrc	XL,7
			sbi	CTRLPORT,SPI_MOSI
			sbrs	XL,7
			cbi	CTRLPORT,SPI_MOSI
			
			
			
			out	CTRLPIN,r22		;clock pulse
			lsl	XL
			sbic	CTRLPIN,SPI_MISO
			inc	XL		
			out	CTRLPIN,r22
			dec	r21
			brne	spi_bytef_1
			ret




;------------------------------------------------------------------------------
; exchange byte XL -> XL
; ca. 1MHz
;------------------------------------------------------------------------------
spi3_zerobyte:		clr	XL
spi3_byte:		ldi	r22,SPI_SCK_PULSE
			ldi	r21,8
spi3_byte_1:		out	CTRLPIN,r22		;clock pulse
			sbrc	XL,7
			sbi	CTRLPORT,SPI_MOSI
			sbrs	XL,7
			cbi	CTRLPORT,SPI_MOSI
			out	CTRLPIN,r22
			lsl	XL
			sbic	CTRLPIN,SPI_MISO
			inc	XL		
			dec	r21
			brne	spi3_byte_1
			ret
			
