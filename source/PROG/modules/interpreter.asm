;################################################################################
;#										#
;# UPROG2 universal programmer for linux					#
;#										#
;# copyright (c) 2012-2017 Joerg Wolfram (joerg@jcwolfram.de)			#
;#										#
;#										#
;# This program is free software; you can redistribute it and/or		#
;# modify it under the terms of the GNU General Public License			#
;# as published by the Free Software Foundation; either version 2		#
;# of the License, or (at your option) any later version.			#
;#										#
;# This program is distributed in the hope that it will be useful,		#
;# but WITHOUT ANY WARRANTY; without even the implied warranty of		#
;# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the GNU		#
;# General Public License for more details.					#
;#										#
;# You should have received a copy of the GNU General Public			#
;# License along with this library; if not, write to the			#
;# Free Software Foundation, Inc., 59 Temple Place - Suite 330,			#
;# Boston, MA 02111-1307, USA.							#
;#										#
;################################################################################

prg_exec_jtab1:	jmp	prg_exec_e1		;code 00 unknown
		jmp	avr_init		;code 01 AVR init
		jmp	avr_setfast		;code 02 AVR set SPI speed to fast
		jmp	avr_readid		;code 03 AVR read ID and fuses
		jmp	avr_merase		;code 04 AVR mass erase
		jmp	avr_fprog		;code 05 AVR program flash
		jmp	avr_fread		;code 06 AVR read flash
		jmp	avr_eprog		;code 07 AVR program EEPROM
		jmp	avr_eread		;code 08 AVR read EEPROM
		jmp	avr_wfuse_l		;code 09 AVR write LOW fuse
		jmp	avr_wfuse_h		;code 0a AVR write HIGH fuse
		jmp	avr_wfuse_e		;code 0b AVR write EXT fuse
		jmp	avr_wlock		;code 0c AVR write lock bits
		jmp	avr_exit		;code 0d AVR exit
		jmp	start_device		;code 0e start device
		jmp	stop_device		;code 0f stop device

		jmp	init_bdm		;code 10 BDM entry
		jmp	exit_bdm		;code 11 BDM exit
		jmp	s08_fdiv		;code 12 set clock divider
		jmp	s08_exec		;code 13 exec
		jmp	s08_merase		;code 14 mass erase
		jmp	s08_unsecure		;code 15 unsecure
		jmp	s08_prog		;code 16 program
		jmp	s08_read		;code 17 read
		jmp	s08_write		;code 18 write non flash memory
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e1		;code 1e unknown
		jmp	bdm_setfreq		;code 1f re-init BDM

		jmp	r8c_init		;code 20 R8C init and read BL version
		jmp	r8c_exec		;code 21 R8C exec code
		jmp	r8c_unlock		;code 22 R8C unlock
		jmp	r8c_exit		;code 23 R8C progmode exit
		jmp	r8c_prog		;code 24 R8C program
		jmp	r8c_read		;code 25 R8C read
		jmp	r8c_erase		;code 26 R8C erase blocks
		jmp	r8c_blank		;code 27 R8C blank check device
		jmp	r8c_version		;code 28 R8C get BL version
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	s08_trim		;code 2b BDM sync pulse measure
		jmp	sercomm1		;code 2c sercomm 9K6
		jmp	sercomm2		;code 2d sercomm 38K4
		jmp	sercomm3		;code 2e sercomm 115K
		jmp	sercomm4		;code 2f sercomm 500k

		jmp	s12xd_fdiv		;code 30 s12xd set fclkdiv
		jmp	s12x_exec		;code 31 s12 exec in RAM
		jmp	s12x_execw		;code 32 s12 exec in RAM and wait for end
		jmp	s12xd_merase		;code 33 s12xd FLASH erase
		jmp	s12xd_unsec		;code 34 s12xd unsecure
		jmp	s12xd_fprog		;code 35 s12xd program 1k flash
		jmp	s12xd_eprog		;code 36 s12xd program 1k EEPROM
		jmp	s12xd_read		;code 37 s12xd read 1k memory
		jmp	s12xd_eerase		;code 38 s12xd erase EEPROM
		jmp	s12x_active		;code 39 s12 goto active bdm mode
		jmp	s12x_wram		;code 3a s12xd write to RAM
		jmp	s12xd_setpll		;code 3b s12xd set PLL
		jmp	s12xd_read_eep		;code 3c s12xd read 1K EEPROM memory page
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved

		jmp	s12xe_fdiv		;code 40 s12xe set fclkdiv
		jmp	prg_exec_e1		;code 41 unknown
		jmp	prg_exec_e1		;code 42 unknown
		jmp	s12xe_erase		;code 43 s12xe mass erase
		jmp	s12xe_unsec		;code 44 s12xe unsecure
		jmp	s12xe_pprog		;code 45 s12xe program PFLASH
		jmp	s12xe_read		;code 46 s12xe read memory
		jmp	prg_exec_e1		;code 47 unknown
		jmp	s12xe_dprog		;code 48 s12xe program DFLASH
		jmp	prg_exec_e1		;code 49 unknown
		jmp	prg_exec_e1		;code 4a unknown
		jmp	s12xe_setpll		;code 4b s12xe set PLL
		jmp	s12xe_merase		;code 4c s12xe main erase
		jmp	s12xe_derase		;code 4d s12xe dflash erase
		jmp	swd32_erase1		;code 4e erase STM32F0/F1/F2/F3/F4
		jmp	swd32_readregs		;code 4f stm32 read registers

		jmp	init_swim		;code 50 STM8 SWIM init
		jmp	exit_swim		;code 51 STM8 SWIM exit
		jmp	swim_config		;code 52 configure SWIM and release reset
		jmp	swim_sequence		;code 53 SWIM do sequence
		jmp	swim_wram		;code 54 write data to STM8 RAM
		jmp	swim_exec		;code 55 exec STM8 CODE
		jmp	swim_read		;code 56 read data from STM8 memory
		jmp	prg_exec_e1		;code 57 unknown
		jmp	swd32_cmd1		;code 58 STM32 send command to bootcode (new address)
		jmp	swd32_cmd		;code 59 STM32 send command to bootcode
		jmp	init_icc		;code 5a ST7 ICC init (devices without ICCSEL)
		jmp	exit_icc		;code 5b ST7 ICC exit
		jmp	icc_write_mem		;code 5c ST7 ICC write to memory and exec
		jmp	rl78_csum		;code 5d RL78 CSUM
		jmp	wait_vdd		;code 5e unknown
		jmp	rl78_getsec		;code 5f RL78 get security

		jmp	nec2_init		;code 60 NEC 78K0R init
		jmp	nec2_cerase		;code 61 NEC 78K0R mass erase
		jmp	nec2_berase		;code 62 NEC 78K0R block erase
		jmp	nec2_bprog		;code 63 NEC 78K0R block program
		jmp	nec2_bvfy		;code 64 NEC 78K0R block verify
		jmp	nec2_exit		;code 65 NEC 78K0R exit
		jmp	prg_exec_e2		;code 66 reserved command
		jmp	prg_exec_e2		;code 67 reserved command
		jmp	rl78_init		;code 68 RL78 init
		jmp	rl78_exit		;code 69 RL78 exit
		jmp	rl78_erase		;code 6a RL78 erase blocks
		jmp	rl78_bprog		;code 6b RL78 program block
		jmp	rl78_bvfy		;code 6c RL78 verify block
		jmp	rl78_secrel		;code 6d RL78 release security
		jmp	rl78_readsig		;code 6e RL78 read silicon signature
		jmp	rl78_bcheck		;code 6f RL78 blank check

		jmp	pic_hvinit		;code 70 init HV ICSP for PIC
		jmp	pic_hvexit		;code 71 exit HV ICSP mode
		jmp	pic1_readid		;code 72 read device ID
		jmp	pic1_merase		;code 73 pic16 mass erase
		jmp	pic1_perase		;code 74 pic16 program flash erase
		jmp	pic1_derase		;code 75 pic16 data flash erase
		jmp	pic1_pprog		;code 76 pic16 prog program flash (4-word)
		jmp	pic1_pread		;code 77 pic16 read program flash
		jmp	pic1_dprog		;code 78 pic16 prog data flash
		jmp	pic1_dread		;code 79 pic16 read data flash
		jmp	pic1_cprog		;code 7a pic16 prog user ID
		jmp	pic1_cread		;code 7b pic16 read user ID
		jmp	pic1_merase2		;code 7c pic16 bulk erase [2]
		jmp	pic1_perase2		;code 7d pic16 program flash erase [2]
		jmp	pic1_derase2		;code 7e pic16 data flash erase [2]
		jmp	pic1_pprog2		;code 7f pic16 prog program flash [2]

		jmp	pic1_dprog2		;code 80 pic16 prog data flash [2]
		jmp	pic1_cprog2		;code 81 pic16 prog user ID [2]
		jmp	pic2_init		;code 82 pic18/dspic init
		jmp	prg_exec_e1		;code 83 unknown
		jmp	icc_boot		;code 84 boot st7flite
		jmp	st7_fprog		;code 85 ST7FLITE0 prog flash
		jmp	st7_fread		;code 86 ST7FLITE0 read
		jmp	st7_eprog		;code 87 ST7FLITE0 prog eeprom
		jmp	st7_oprog		;code 88 ST7FLITE0 prog option bytes
		jmp	st7_oread		;code 89 ST7FLITE0 read option bytes
		jmp	pic2_erase		;code 8a PIC18 erase (div. modes)
		jmp	pic2_readf		;code 8b PIC18 readout (flash)
		jmp	pic2_reade		;code 8c PIC18 readout (eeprom)
		jmp	pic2_progf		;code 8d PIC18 flash program
		jmp	pic2_readb		;code 8e PIC18 read bytes (UID / config / ID)
		jmp	pic2_proge		;code 8f PIC18 eeprom program

		jmp	ppcbam_init		;code 90 init PPC ESCI BAM (8M)
		jmp	ppcbam_exit		;code 91 exit PPC ESCI BAM
		jmp	ppcbam_send		;code 92 PPC send boot data
		jmp	ppcbam_read		;code 93 PPC read
		jmp	ppcbam_cprog		;code 94 PPC prog CFLASH
		jmp	ppcbam_cerase		;code 95 PPC erase CFLASH
		jmp	ppcbam_dprog		;code 96 PPC prog DFLASH
		jmp	ppcbam_derase		;code 97 PPC erase DFLASH
		jmp	ppcbam_sprog		;code 98 PPC prog SHADOW
		jmp	ppcbam_serase		;code 99 PPC erase SHADOW
		jmp	swd32_exit_debug	;code 9a STM32 leave debug mode
		jmp	r8c_exec2		;code 9b R8C exec first block
		jmp	r8c_exec3		;code 9c R8C exec consecutive blocks
		jmp	prg_exec_e1		;code 9d unknown
		jmp	act_reset		;code 9e activate reset
		jmp	rel_reset		;code 9f release reset

		jmp	i2c_init		;code a0 I2C init
		jmp	i2c_exit		;code a1 I2C exit
		jmp	i2c_read		;code a2 I2C eeprom read
		jmp	i2c_write		;code a3 I2C eeprom write
		jmp	lps25h_start		;code a4 start LPS25H conversion
		jmp	prg_exec_e1		;code a5 unknown
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved

		jmp	pic2_progu		;code b0 PIC18 uid program
		jmp	pic2_progc		;code b1 PIC18 config program
		jmp	swd32_write		;code b2 STM32 write memory block
		jmp	swd32_go		;code b3 STM32 run code
		jmp	ccxx_init		;code b4 CC25xx init and read ID
		jmp	ccxx_cerase		;code b5 CC25xx erase chip
		jmp	ccxx_prog		;code b6 CC25xx program 1K
		jmp	ccxx_read		;code b7 CC25xx read 1K
		jmp	psoc4_init		;code b8 SWD init and read ID
		jmp	psoc4_check_sid		;code b9 SWD check silicon ID
		jmp	psoc4_unprot		;code ba SWD unprotect
		jmp	psoc4_erase		;code bb SWD erase
		jmp	psoc4_readout		;code bc SWD readout
		jmp	psoc4_prog		;code bd SWD prog
		jmp	swd32_init		;code be STM32 init SWD
		jmp	swd32_read		;code bf STM32 read memory block

		jmp	dspic_init		;code c0 dspic33 init
		jmp	dspic_exit		;code c1 dspic33 exit
		jmp	dspic_readid		;code c2 dspic33 read device + app ID
		jmp	dspic_exera		;code c3 dspic33 erase executive memory
		jmp	dspic_exprog		;code c4 dspic33 program executive memory
		jmp	psoc4_protect		;code c5 PSOC4 set to protected mode
		jmp	dspic_erall		;code c6 dspic33 erase all
		jmp	dspic_defconf		;code c7 dspic33 set config registers to default value
		jmp	dspic_einit		;code c8 dspic33 init in EICSP-mode
		jmp	dspic_scheck		;code c9 dspic33 EICSP sanity check
		jmp	dspic_eraseb		;code ca dspic33 EICSP bulk erase
		jmp	dspic_progp2		;code cb dspic33 EICSP program flash
		jmp	dspic_progc		;code cc dspic33 EICSP program config
		jmp	dspic_readp		;code cd dspic33 EICSP read flash
		jmp	dspic_readc		;code ce dspic33 EICSP read config
		jmp	dspic_qblank		;code cf dspic33 EICSP blank check

		jmp	sbw_init2		;code d0 init MSP430F5/6 for sbw
		jmp	sbw_exit1		;code d1 exit sbw
		jmp	sbw_read2		;code d2 read memory from MSP430F5/6
		jmp	sbw_bwrite2		;code d3 write memory for MSP430F5/6 (bytes)
		jmp	sbw_wwrite2		;code d4 write memory for MSP430F5/6 (words)
		jmp	sbw_run2		;code d5 run code for MSP430F5/6
		jmp	sbw_erase2		;code d6 main erase for MSP430F5/6
		jmp	sbw_program2		;code d7 flash for MSP430F5/6
		jmp	sbw_init1		;code d8 init MSP430F1/2/3/4 for sbw
		jmp	sbw_exit1		;code d9 exit sbw
		jmp	sbw_read1		;code da read memory from MSP430F1/2/3/4
		jmp	sbw_bwrite1		;code db write memory for MSP430F1/2/3/4 (bytes)
		jmp	sbw_wwrite1		;code dc write memory for MSP430F1/2/3/4 (words)
		jmp	sbw_run1		;code dd run code for MSP430F1/2/3/4
		jmp	sbw_erase1		;code de main erase for MSP430F1/2/3/4
		jmp	sbw_flash1		;code df flash for MSP430F1/2/3/4

		jmp	prg_exec_e2		;code e0 reserved command
		jmp	prg_exec_e2		;code e1 reserved command
		jmp	prg_exec_e2		;code e2 reserved command
		jmp	prg_exec_e2		;code e3 reserved command
		jmp	prg_exec_e2		;code e4 reserved command
		jmp	prg_exec_e2		;code e5 reserved command
		jmp	prg_exec_e2		;code e6 reserved command
		jmp	prg_exec_e2		;code e7 reserved command
		jmp	prg_exec_e2		;code e8 reserved command
		jmp	prg_exec_e2		;code e9 reserved command
		jmp	prg_exec_e2		;code ea reserved command
		jmp	prg_exec_e2		;code eb reserved command
		jmp	prg_exec_e2		;code ec reserved command
		jmp	prg_exec_e2		;code ed reserved command
		jmp	prg_exec_e1		;code ee unknown
		jmp	prg_exec_e1		;code ef unknown

		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

prg_exec_jtab2:
		jmp	spiflash_init		;code 100
		jmp	spiflash_exit		;code 101 
		jmp	spiflash_read		;code 102 read spi flash 
		jmp	spiflash_write		;code 103 write spi flash (256 bytes page)
		jmp	spiflash_erase_bulk	;code 104 erase SPI flash
		jmp	spiflash_getstat	;code 105 get code protection etc
		jmp	spiflash_setstat	;code 106 set code protection etc
		jmp	spiflash_set_bank	;code 107 set bank (for devices > 16M)
		jmp	xc9500_erase		;code 108 XC9500 erase
		jmp	xc9500xl_erase		;code 109 XC9500XL erase
		jmp	xc9500_prog_start	;code 10a XC9500 start program
		jmp	xc9500_prog		;code 10b XC9500 program block
		jmp	xc9500_prog_end		;code 10c XC9500 end program
		jmp	xc9500_init		;code 10d XC9500 init JTAG and get device ID
		jmp	xc9500_exit		;code 10e XC9500 exit
		jmp	spiflash_write2		;code 10f write spi flash (512 bytes page)

		jmp	dataflash_init		;code 110 atmel dataflash init
		jmp	dataflash_exit		;code 111 atmel dataflash exit
		jmp	dataflash_read		;code 112 atmel dataflash read pages
		jmp	dataflash_write		;code 113 atmel dataflash program pages
		jmp	dataflash_erase		;code 114 atmel dataflash erase
		jmp	dataflash_getstat	;code 115 atmel dataflash get status
		jmp	dataflash_param		;code 116 atmel dataflash set page parameters (size)
		jmp	dataflash_fread		;code 117 atmel dataflash read full pages
		jmp	dataflash_fwrite	;code 118 atmel dataflash program full pages
		jmp	dataflash_setbin	;code 119 atmel dataflash set to binary
		jmp	xc9500xl_prog_start	;code 11a XC9500 start program
		jmp	xc9500xl_prog		;code 11b XC9500 program block
		jmp	xc9500xl_prog_end	;code 11c XC9500 end program
		jmp	prg_exec_e1		;code 11d unknown
		jmp	prg_exec_e1		;code 11e unknown
		jmp	r8c_lock		;code 11f r8c read/write lock

		jmp	spiflash_write41	;code 120 write spi flash (256 bytes page) in quad mode
		jmp	spiflash_write42	;code 121 write spi flash (512 bytes page) in quad mode
		jmp	spiflash_read4		;code 122 read spi flash in quad mode
		jmp	spiflash_getstatus	;code 123 get spi flash status (+0x60)
		jmp	spiflash_erase_nw	;code 124 erase and no wait
		jmp	spiflash_setquad	;code 125 set spi flash into quad mode
		jmp	pic1_dprog3		;code 126 pic16 prog data flash
		jmp	pic1_dread3		;code 127 pic16 read data flash
		jmp	swd32_prepare		;code 128 STM32 write SP/PC
		jmp	swd32_step		;code 129 STM32 single step
		jmp	swd32_readregs		;code 12a STM32 read registers
		jmp	swd32_sgo		;code 12b STM32 run
		jmp	prg_exec_e1		;code 12c unknown
		jmp	spiflash_resquad	;code 12d reset quad mode on spi flash
		jmp	la_stop			;code 12e logic analyzer stop
		jmp	freq_gen_stop		;code 12f frequency generator stop

		jmp	pdi_init		;code 130 pdi init
		jmp	prg_exec_e1		;code 131 pdi re-init
		jmp	pdi_exit		;code 132 pdi exit
		jmp	pdi_read_mem		;code 133 pdi read memory
		jmp	pdi_read_fuses		;code 134 pdi read fuses
		jmp	prg_exec_e1		;code 135 pdi chip erase
		jmp	pdi_erase_main		;code 136 pdi appl erase
		jmp	pdi_erase_boot		;code 137 pdi boot erase
		jmp	pdi_erase_eeprom	;code 138 pdi eeprom erase
		jmp	prg_exec_e1		;code 139 pdi usersig erase
		jmp	pdi_prog_main		;code 13a pdi prog appl. flash
		jmp	pdi_prog_boot		;code 13b pdi prog boot section
		jmp	pdi_prog_eeprom		;code 13c pdi prog EEPROM
		jmp	prg_exec_e1		;code 13d unknown
		jmp	pdi_prog_fuse		;code 13e pdi program fuses
		jmp	prg_exec_e1		;code 13f unknown

		jmp	rh850_init		;code 140 RH850 init
		jmp	rh850_exit		;code 141 RH850 exit
		jmp	rh850_run		;code 142 RH850 start
		jmp	rh850_high_speed	;code 143 RH850 set to high speed
		jmp	rh850_get_device	;code 144 RH850 get device
		jmp	rh850_set_freq		;code 145 RH850 set frequency
		jmp	rh850_inquiry		;code 146 RH850 inquiry
		jmp	rh850_authmode_get	;code 147 RH850 get authmode
		jmp	rh850_signature		;code 148 RH850 signature
		jmp	rh850_lb_enable		;code 149 RH850 lockbit enable
		jmp	rh850_read_opt		;code 14a RH850 get option bytes
		jmp	rh850_write_opt		;code 14b RH850 write option bytes
		jmp	rh850_get_crc		;code 14c RH850 get CRC
		jmp	prg_exec_e1		;code 14d RH850 unknown
		jmp	rh850_set_addr1		;code 14e RH850 set start address
		jmp	rh850_set_addr2		;code 14f RH850 set end address

		jmp	rh850_bcheck		;code 150 RH850 blank check
		jmp	rh850_erase		;code 151 RH850 erase
		jmp	rh850_prog_start	;code 152 RH850 start programming
		jmp	rh850_prog_block	;code 153 RH850 program/verify 1K block
		jmp	rh850_skip_block	;code 154 RH850 skip 1K block
		jmp	rh850_read_start	;code 155 RH850 start reading
		jmp	rh850_read_block	;code 156 RH850 read 2 blocks
		jmp	rh850_derase		;code 157 RH850 erase 2K blocks (32)
		jmp	rh850_prog_blockx	;code 158 RH850 program variable block
		jmp	rh850_set_prot		;code 159 RH850 set command protection
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	rh850_get_prot		;code 15c RH850 get command protection
		jmp	prg_exec_e1		;code 15d unknown
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved

		jmp	v850_init		;code 160 V850 init
		jmp	v850_exit		;code 161 V850 exit
		jmp	v850_run		;code 162 V850 start in user mode
		jmp	v850_get_signature	;code 163 V850 get device and return info
		jmp	v850_set_osc		;code 164 V850 set osc frequency
		jmp	v850_bcheck_main	;code 165 V850 blank check main memory
		jmp	v850_chip_erase		;code 166 V850 chip erase
		jmp	v850_protect		;code 167 V850 set write prohibition
		jmp	prg_exec_e1		;code 168 V850 prog 2K
		jmp	v850_verifym_start	;code 169 V850 init verify
		jmp	v850_verify_blocks	;code 16a V850 verify 2K
		jmp	v850_prog_2k		;code 16b V850 prog2K komplete
		jmp	v850_bcheck		;code 16c V850 blank check (universal)
		jmp	v850_verify_start	;code 16d V850 init verify (universal)
		jmp	prg_exec_e1		;code 16e unknown
		jmp	prg_exec_e1		;code 16f unknown

		jmp	mlx363_init		;code 170 MLX90363 init
		jmp	mlx363_exit		;code 171 MLX90363 exit
		jmp	mlx363_readxyz		;code 172 MLX90363 read XYZ
		jmp	mlx316_readout		;code 173 MLX90316 readout
		jmp	ppcjtag_init		;code 174 PPC JTAG init and read JTAG ID
		jmp	ppcjtag_exit		;code 175 PPC JTAG exit
		jmp	ppcjtag_read_jid	;code 176 PPC JTAG read JID
		jmp	ppcjtag_enter_dbg	;code 177 PPC JTAG enter external DBG
		jmp	ppcjtag_exit_dbg	;code 178 PPC JTAG exit external DBG
		jmp	ppcjtag_once_nexus	;code 179 PPC OnCE -> Nexus
		jmp	ppcjtag_nexus_write	;code 17a PPC nexus write long
		jmp	ppcjtag_nexus_wblock	;code 17b PPC nexus write 2k block
		jmp	ppcjtag_nexus_rblock	;code 17c PPC nexus read 2k block
		jmp	ppcjtag_nexus_rblockb	;code 17d PPC nexus read 2k block in burst mode
		jmp	ppcjtag_nexus_wblockb	;code 17e PPC nexus write 2k block in burst mode
		jmp	ppcjtag_nexus_read	;code 17f PPC nexus read long

		jmp	ppjtag_set_pc		;code 180 PPC OnCE set PC...
		jmp	ppcjtag_init2		;code 181 PPC JTAG init and read JTAG ID (JCOMP active)
		jmp	ppcjtag_reset		;code 182 PPC OnCE reset CPU
		jmp	ppcjtag_read_jid_2	;code 183 PPC JTAG read JID without entering OnCE 
		jmp	ppcjtag_unlock		;code 184 PPC JTAG unlock device
		jmp	ppcjtag_once_status	;code 185 PPC JTAG read once status register
		jmp	ppcjtag_enter_dbg2	;code 186 PPC JTAG enter external DBG (clear WKUP)
		jmp	ppcjtag_enter_nexus	;code 187 PPC JTAG enter Nexus
		jmp	ppcjtag_enter_once	;code 188 PPC JTAG enter OnCE
		jmp	jppc_init_0		;code 189 unknown
		jmp	ppcjtag_unlock2		;code 18a PPC JTAG unlock device
		jmp	ppcjtag_enter_dbg4	;code 18b unknown
		jmp	ppcjtag_get_rwcs	;code 18c unknown
		jmp	ppcjtag_nexus_wblockb2	;code 18d unknown
		jmp	ppcjtag_xreset		;code 18e unknown
		jmp	ppcjtag_nexus_pread	;code 18f PPC nexus read long withadditional pause

		jmp	la1m_start		;code 190 logic analyzer, 1M sample freq
		jmp	freq_gen_start		;code 191 frequency generator
		jmp	la100k_start		;code 192 logic analyzer, 100k sample freq
		jmp	rl78_gdump		;code 193 RL78 get 1024 bytes dump data
		jmp	swd32_erase_chk		;code 194 SWD read DRW
		jmp	prg_exec_e1		;code 195 unknown
		jmp	spieeprom_read1		;code 196 AT25xxx EEPROM read (16 bit addr)
		jmp	spieeprom_write1	;code 197 AT25xxx EEPROM write (16 bit addr)
		jmp	spieeprom_init		;code 198 AT25xxx EEPROM init
		jmp	spieeprom_exit		;code 199 AT25xxx EEPROM exit
		jmp	spieeprom_read		;code 19a AT25xxx EEPROM read (8 bit addr)
		jmp	spieeprom_write		;code 19b AT25xxx EEPROM write (8 bit addr)
		jmp	spieeprom_getstat	;code 19c AT25xxx EEPROM get status register
		jmp	spieeprom_setstat	;code 19d AT25xxx EEPROM set status register
		jmp	prg_exec_e1		;code 19e unknown
		jmp	prg_exec_e1		;code 19f this is the only check command wich never reaches programmer

		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e1		;code 1a5 unknown
		jmp	prg_exec_e1		;code 1a6 unknown
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e1		;code 1a8 unknown
		jmp	prg_exec_e1		;code 1a9 unknown
		jmp	prg_exec_e1		;code 1aa unknown
		jmp	prg_exec_e1		;code 1ab unknown
		jmp	avr_fprog2		;code 1ac AVR fprog (old)
		jmp	avr_eprog2		;code 1ad AVR eprog (old)
		jmp	avr_merase2		;code 1ae AVR merase (old)
		jmp	prg_exec_e1		;code 1af unknown

		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e2		;reserved
		jmp	prg_exec_e1		;code 1b2 unknown
		jmp	prg_exec_e1		;code 1b3 unknown
		jmp	prg_exec_e1		;code 1b4 unknown
		jmp	prg_exec_e1		;code 1b5 unknown
		jmp	prg_exec_e1		;code 1b6 unknown
		jmp	prg_exec_e1		;code 1b7 unknown
		jmp	pic1_readid2		;code 1b8 pic16 read ID (new protocol)
		jmp	pic1_read2		;code 1b9 pic16 read (new protocol)
		jmp	pic1_merase3		;code 1ba pic16 bulk erase (new protocol)
		jmp	pic1_prog2_row		;code 1bb pic16 prog rows (new protocol)
		jmp	pic1_prog2_word		;code 1bc pic16 prog single word (new protocol)
		jmp	prg_exec_e1		;code 1bd unknown
		jmp	prg_exec_e1		;code 1be unknown
		jmp	prg_exec_e1		;code 1bf unknown

		jmp	cc2640_init		;code 1c0 CC2640 init
		jmp	cc2640_merase		;code 1c1 CC2640 mass erase
		jmp	cc2640_init_core	;code 1c2 CC2640 init core
		jmp	cc2640_wcode		;code 1c3 write code to RAM
		jmp	cc2640_start_core	;code 1c4 start core
		jmp	cc2640_read		;code 1c5 read memory
		jmp	cc2640_read_pc		;code 1c6 read PC
		jmp	cc2640_wdata		;code 1c7 CC2640 write data block to 0x20002000
		jmp	cc2640_rstat		;code 1c8 CC2640 prog status
		jmp	prg_exec_e1		;code 1c9 unknown
		jmp	sici_init		;code 1ca SICI init
		jmp	sici_exit		;code 1cb SICI exit
		jmp	sici_rwork		;code 1cc SICI read work
		jmp	sici_rpage		;code 1cd SICI read EEPROM page
		jmp	sici_wpage		;code 1ce SICI write EEPROM page
		jmp	prg_exec_e1		;code 1cf SICI chip reset

		jmp	s32k_init		;code 1d0 S32K init sequence
		jmp	s32k_readid		;code 1d1 S32K read device ID
		jmp	s32k_erase		;code 1d2 S32K erase via MDM
		jmp	s32k_erase2		;code 1d3 S32K erase via DEBUG
		jmp	s9kea_erase		;code 1d4 S9KEA erase
		jmp	updi_prog_user		;code 1d5 UPDI prog user row
		jmp	updi_read_id		;code 1d6 UPDI read ID and fuses
		jmp	updi_prog_fuse		;code 1d7 UPDI program fuse
		jmp	updi_init		;code 1d8 UPDI init and read device ID
		jmp	updi_exit		;code 1d9 UPDI exit
		jmp	updi_read_mem		;code 1da UPDI read memory
		jmp	updi_erase		;code 1db UPDI erase
		jmp	updi_prog_main		;code 1dc UPDI prog main falsh
		jmp	updi_erase_eeprom	;code 1dd UPDI erase EEPROM
		jmp	updi_prog_eeprom	;code 1de UPDI program EEPROM
		jmp	updi_read_eeprom	;code 1df UPDI read EEPROM

		jmp	prog_val_sig		;code 1e0 output to signals
		jmp	prog_val_dir		;code 1e1 define signal directions
		jmp	prog_set_sig		;code 1e2 set signals to 1
		jmp	prog_set_dir		;code 1e3 set signals to output
		jmp	prog_clr_sig		;code 1e4 set signals to 0
		jmp	prog_clr_dir		;code 1e5 set signals to input
		jmp	prg_exec_e1		;code 1e6 unknown
		jmp	prg_exec_e1		;code 1e7 unknown
		jmp	spiflash_read_conf	;code 1e8 SPIflash read config register
		jmp	prg_exec_e1		;code 1e9 unknown
		jmp	prg_exec_e1		;code 1ea unknown
		jmp	prg_exec_e1		;code 1eb unknown
		jmp	prg_exec_e1		;code 1ec unknown
		jmp	prg_exec_e1		;code 1ed unknown
		jmp	prg_exec_e1		;code 1ee unknown
		jmp	prg_exec_e1		;code 1ef unknown


		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		.db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

		;this table is reserved for debugging commands
prg_exec_jtab3:	jmp	s08_active		;code 200 HCS08 active BDM
		jmp	s08_read		;code 201 HCS08 read memory
		jmp	s08_read_regs		;code 202 HCS08 read registers
		jmp	s08_write		;code 203 HCS08 write memory
		jmp	s08_write_regs		;code 204 HCS08 write registers
		jmp	s08_go			;code 205 HCS08 exec PC
		jmp	prg_exec_e1		;code 206 unknown
		jmp	prg_exec_e1		;code 207 unknown
		jmp	rh850_idcode_prg	;code 208 RH850 set ID code and SPIE
		jmp	rh850_idcode_get	;code 209 RH850 get ID code
		jmp	rh850_idcode_chk	;code 20a RH850 check against ID code
		jmp	rh850_idcode_set	;code 20b RH850 set ID code
		jmp	rh850_bst_start		;code 20c unknown
		jmp	rh850_bst_block		;code 20d unknown
		jmp	rh850_vfy_start		;code 20e RH850 verify start
		jmp	rh850_vfy_block		;code 20f RH850 verify block

		jmp	at8252_init		;code 210 AT89S8252 init 
		jmp	at8252_exit		;code 211 AT89S8252 exit
		jmp	at8252_cerase		;code 212 AT89S8252 chip erase
		jmp	at8252_fprog		;code 213 AT89S8252 flash program
		jmp	at8252_fread		;code 214 AT89S8252 flash read
		jmp	at8252_eprog		;code 215 AT89S8252 eeprom program
		jmp	at8252_eread		;code 216 AT89S8252 eeprom read
		jmp	at8252_wlock		;code 217 AT89S8252 write lockbits
		jmp	efm32_init		;code 218 EFM32 init
		jmp	efm32_lock		;code 219 EFM32 lock
		jmp	efm32_unlock		;code 21a EFM32 unlock via SWD 
		jmp	efm32_merase		;code 21b EFM32 mass erase direct
		jmp	efm32_perase		;code 21c EFM32 page erase direct
		jmp	prg_exec_e1		;code 21d unknown
		jmp	prg_exec_e1		;code 21e unknown
		jmp	prg_exec_e1		;code 21f unknown

		jmp	s12z_entry		;code 220 S12Z entry
		jmp	s12z_write		;code 221 S12Z write data to RAM
		jmp	s12z_exec		;code 222 S12Z exec code
		jmp	s12z_read		;code 223 S12Z read memory
		jmp	s12z_prog_flash		;code 224 S12Z program flash
		jmp	s12z_unsecure		;code 225 S12Z unsecure (mass erase)
		jmp	s12z_prog_eeprom	;code 226 S12Z program EEPROM
		jmp	bdm_setfreq0		;code 227 unknown
		jmp	s12z_test		;code 228 S12Z LED and secure test
		jmp	s12z_active		;code 229 S12Z enter active background debug mode
		jmp	s12z_go			;code 22a S12Z release CPU
		jmp	s12z_step		;code 22b S12Z single step
		jmp	s12z_readregs		;code 22c S12Z read registers
		jmp	s12z_writereg		;code 22d S12Z write register
		jmp	init_bdmz		;code 22e unknown
		jmp	bdm_setfreqz		;code 22f unknown

		jmp	onewire_init		;code 230 init+reset onewire
		jmp	onewire_exit		;code 231 exit onewire (clear Pull-Up)
		jmp	onewire_read_id		;code 232 read ROM data
		jmp	onewire_read_mem	;code 233 read memory data
		jmp	onewire_write_mem	;code 234 write memory data
		jmp	prg_exec_e1		;code 235 unknown
		jmp	swd32_wreg		;code 236 SWD write register
		jmp	swd32_cont		;code 237 SWD continue at address
		jmp	swd32_setbrk		;code 238 SWD set breakpoint
		jmp	swd32_clrbrk		;code 239 SWD clear breakpoint
		jmp	swd32_dbgcheck		;code 23a SWD check if in debug mode
		jmp	swd32_halt		;code 23b SWD halt processor
		jmp	swd32_nread		;code 23c SWD read n longs
		jmp	swd32_wlong		;code 23d SWD write long
		jmp	swd32_wword		;code 23e SWD write word
		jmp	swd32_wbyte		;code 23f SWD write byte

		jmp	prg_exec_e1		;code 240 unknown
		jmp	prg_exec_e1		;code 241 unknown
		jmp	prg_exec_e1		;code 242 unknown
		jmp	prg_exec_e1		;code 243 unknown
		jmp	prg_exec_e1		;code 244 unknown
		jmp	prg_exec_e1		;code 245 unknown
		jmp	prg_exec_e1		;code 246 unknown
		jmp	prg_exec_e1		;code 247 unknown
		jmp	prg_exec_e1		;code 248 unknown
		jmp	prg_exec_e1		;code 249 unknown
		jmp	prg_exec_e1		;code 24a unknown
		jmp	prg_exec_e1		;code 24b unknown
		jmp	prg_exec_e1		;code 24c unknown
		jmp	prg_exec_e1		;code 24d unknown
		jmp	prg_exec_e1		;code 24e unknown
		jmp	prg_exec_e1		;code 24f unknown

		jmp	prg_exec_e1		;code 250 unknown
		jmp	prg_exec_e1		;code 251 unknown
		jmp	prg_exec_e1		;code 252 unknown
		jmp	prg_exec_e1		;code 253 unknown
		jmp	prg_exec_e1		;code 254 unknown
		jmp	prg_exec_e1		;code 255 unknown
		jmp	prg_exec_e1		;code 256 unknown
		jmp	prg_exec_e1		;code 257 unknown
		jmp	prg_exec_e1		;code 258 unknown
		jmp	prg_exec_e1		;code 259 unknown
		jmp	prg_exec_e1		;code 25a unknown
		jmp	prg_exec_e1		;code 25b unknown
		jmp	prg_exec_e1		;code 25c unknown
		jmp	prg_exec_e1		;code 25d unknown
		jmp	prg_exec_e1		;code 25e unknown
		jmp	prg_exec_e1		;code 25f unknown

		jmp	prg_exec_e1		;code 260 unknown
		jmp	prg_exec_e1		;code 261 unknown
		jmp	prg_exec_e1		;code 262 unknown
		jmp	prg_exec_e1		;code 263 unknown
		jmp	prg_exec_e1		;code 264 unknown
		jmp	prg_exec_e1		;code 265 unknown
		jmp	prg_exec_e1		;code 266 unknown
		jmp	prg_exec_e1		;code 267 unknown
		jmp	prg_exec_e1		;code 268 unknown
		jmp	prg_exec_e1		;code 269 unknown
		jmp	prg_exec_e1		;code 26a unknown
		jmp	prg_exec_e1		;code 26b unknown
		jmp	prg_exec_e1		;code 26c unknown
		jmp	prg_exec_e1		;code 26d unknown
		jmp	prg_exec_e1		;code 26e unknown
		jmp	prg_exec_e1		;code 26f unknown

		jmp	prg_exec_e1		;code 270 unknown
		jmp	prg_exec_e1		;code 271 unknown
		jmp	prg_exec_e1		;code 272 unknown
		jmp	prg_exec_e1		;code 273 unknown
		jmp	prg_exec_e1		;code 274 unknown
		jmp	prg_exec_e1		;code 275 unknown
		jmp	prg_exec_e1		;code 276 unknown
		jmp	prg_exec_e1		;code 277 unknown
		jmp	prg_exec_e1		;code 278 unknown
		jmp	prg_exec_e1		;code 279 unknown
		jmp	prg_exec_e1		;code 27a unknown
		jmp	prg_exec_e1		;code 27b unknown
		jmp	prg_exec_e1		;code 27c unknown
		jmp	prg_exec_e1		;code 27d unknown
		jmp	prg_exec_e1		;code 27e unknown
		jmp	prg_exec_e1		;code 27f unknown

		jmp	prg_exec_e1		;code 280 unknown
		jmp	prg_exec_e1		;code 281 unknown
		jmp	prg_exec_e1		;code 282 unknown
		jmp	prg_exec_e1		;code 283 unknown
		jmp	prg_exec_e1		;code 284 unknown
		jmp	prg_exec_e1		;code 285 unknown
		jmp	prg_exec_e1		;code 286 unknown
		jmp	prg_exec_e1		;code 287 unknown
		jmp	prg_exec_e1		;code 288 unknown
		jmp	prg_exec_e1		;code 289 unknown
		jmp	prg_exec_e1		;code 28a unknown
		jmp	prg_exec_e1		;code 28b unknown
		jmp	prg_exec_e1		;code 28c unknown
		jmp	prg_exec_e1		;code 28d unknown
		jmp	prg_exec_e1		;code 28e unknown
		jmp	prg_exec_e1		;code 28f unknown

		jmp	prg_exec_e1		;code 290 unknown
		jmp	prg_exec_e1		;code 291 unknown
		jmp	prg_exec_e1		;code 292 unknown
		jmp	prg_exec_e1		;code 293 unknown
		jmp	prg_exec_e1		;code 294 unknown
		jmp	prg_exec_e1		;code 295 unknown
		jmp	prg_exec_e1		;code 296 unknown
		jmp	prg_exec_e1		;code 297 unknown
		jmp	prg_exec_e1		;code 298 unknown
		jmp	prg_exec_e1		;code 299 unknown
		jmp	prg_exec_e1		;code 29a unknown
		jmp	prg_exec_e1		;code 29b unknown
		jmp	prg_exec_e1		;code 29c unknown
		jmp	prg_exec_e1		;code 29d unknown
		jmp	prg_exec_e1		;code 29e unknown
		jmp	prg_exec_e1		;code 29f unknown

		jmp	prg_exec_e1		;code 2a0 unknown
		jmp	prg_exec_e1		;code 2a1 unknown
		jmp	prg_exec_e1		;code 2a2 unknown
		jmp	prg_exec_e1		;code 2a3 unknown
		jmp	prg_exec_e1		;code 2a4 unknown
		jmp	prg_exec_e1		;code 2a5 unknown
		jmp	prg_exec_e1		;code 2a6 unknown
		jmp	prg_exec_e1		;code 2a7 unknown
		jmp	prg_exec_e1		;code 2a8 unknown
		jmp	prg_exec_e1		;code 2a9 unknown
		jmp	prg_exec_e1		;code 2aa unknown
		jmp	prg_exec_e1		;code 2ab unknown
		jmp	prg_exec_e1		;code 2ac unknown
		jmp	prg_exec_e1		;code 2ad unknown
		jmp	prg_exec_e1		;code 2ae unknown
		jmp	prg_exec_e1		;code 2af unknown

		jmp	prg_exec_e1		;code 2b0 unknown
		jmp	prg_exec_e1		;code 2b1 unknown
		jmp	prg_exec_e1		;code 2b2 unknown
		jmp	prg_exec_e1		;code 2b3 unknown
		jmp	prg_exec_e1		;code 2b4 unknown
		jmp	prg_exec_e1		;code 2b5 unknown
		jmp	prg_exec_e1		;code 2b6 unknown
		jmp	prg_exec_e1		;code 2b7 unknown
		jmp	prg_exec_e1		;code 2b8 unknown
		jmp	prg_exec_e1		;code 2b9 unknown
		jmp	prg_exec_e1		;code 2ba unknown
		jmp	prg_exec_e1		;code 2bb unknown
		jmp	prg_exec_e1		;code 2bc unknown
		jmp	prg_exec_e1		;code 2bd unknown
		jmp	prg_exec_e1		;code 2be unknown
		jmp	prg_exec_e1		;code 2bf unknown

		jmp	prg_exec_e1		;code 2c0 unknown
		jmp	prg_exec_e1		;code 2c1 unknown
		jmp	prg_exec_e1		;code 2c2 unknown
		jmp	prg_exec_e1		;code 2c3 unknown
		jmp	prg_exec_e1		;code 2c4 unknown
		jmp	prg_exec_e1		;code 2c5 unknown
		jmp	prg_exec_e1		;code 2c6 unknown
		jmp	prg_exec_e1		;code 2c7 unknown
		jmp	prg_exec_e1		;code 2c8 unknown
		jmp	prg_exec_e1		;code 2c9 unknown
		jmp	prg_exec_e1		;code 2ca unknown
		jmp	prg_exec_e1		;code 2cb unknown
		jmp	prg_exec_e1		;code 2cc unknown
		jmp	prg_exec_e1		;code 2cd unknown
		jmp	prg_exec_e1		;code 2ce unknown
		jmp	prg_exec_e1		;code 2cf unknown

		jmp	prg_exec_e1		;code 2d0 unknown
		jmp	prg_exec_e1		;code 2d1 unknown
		jmp	prg_exec_e1		;code 2d2 unknown
		jmp	prg_exec_e1		;code 2d3 unknown
		jmp	prg_exec_e1		;code 2d4 unknown
		jmp	prg_exec_e1		;code 2d5 unknown
		jmp	prg_exec_e1		;code 2d6 unknown
		jmp	prg_exec_e1		;code 2d7 unknown
		jmp	prg_exec_e1		;code 2d8 unknown
		jmp	prg_exec_e1		;code 2d9 unknown
		jmp	prg_exec_e1		;code 2da unknown
		jmp	prg_exec_e1		;code 2db unknown
		jmp	prg_exec_e1		;code 2dc unknown
		jmp	prg_exec_e1		;code 2dd unknown
		jmp	prg_exec_e1		;code 2de unknown
		jmp	prg_exec_e1		;code 2df unknown

		jmp	prg_exec_e1		;code 2e0 unknown
		jmp	prg_exec_e1		;code 2e1 unknown
		jmp	prg_exec_e1		;code 2e2 unknown
		jmp	prg_exec_e1		;code 2e3 unknown
		jmp	prg_exec_e1		;code 2e4 unknown
		jmp	prg_exec_e1		;code 2e5 unknown
		jmp	prg_exec_e1		;code 2e6 unknown
		jmp	prg_exec_e1		;code 2e7 unknown
		jmp	prg_exec_e1		;code 2e8 unknown
		jmp	prg_exec_e1		;code 2e9 unknown
		jmp	prg_exec_e1		;code 2ea unknown
		jmp	prg_exec_e1		;code 2eb unknown
		jmp	prg_exec_e1		;code 2ec unknown
		jmp	prg_exec_e1		;code 2ed unknown
		jmp	relais_on		;code 2ee unknown
		jmp	relais_off		;code 2ef unknown

act_reset:	cbi	CTRLPORT,SIG1
		sbi	CTRLDDR,SIG1
		jmp	main_loop_ok

rel_reset:	sbi	CTRLPORT,SIG1
		cbi	CTRLDDR,SIG1
		jmp	main_loop_ok

relais_on:	ldi	r16,150
		sts	par_1,r16
		call	api_setvpp
		ldi	ZL,50
		ldi	ZH,0
		call	api_wait_ms
		call	api_vpp_on
relais_on1:	ldi	ZL,200
		ldi	ZH,0
		call	api_wait_ms
		jmp	main_loop_ok

relais_off:	call	api_vpp_off
		call	api_vpp_dis
		rjmp	relais_on1

;-------------------------------------------------------------------------------
; wait n*10us
;-------------------------------------------------------------------------------
prg_wait:	ldi	r16,35			;1
prg_wait_1:	dec	r16			;1
		brne	prg_wait_1		;1/2
		sbiw	XL,1			;2
		nop				;1 filling
		brne	prg_wait		;1/2
		ret


prg_exec_e0:	clr	r16				;no error occured
		jmp	main_loop

prg_exec_e1:	ldi	r16,0x01			;unknown command
		jmp	main_loop

prg_exec_e2:	ldi	r16,0x02			;reserved command
		jmp	main_loop

start_device:	in	XL,CTRLDDR
		andi	XL,0xc0
		or	XL,r16
		out	CTRLDDR,XL
		in	XL,CTRLPORT
		andi	XL,0xc0
		or	XL,r17
		out	CTRLPORT,XL
		call	api_vcc_on
		jmp	main_loop_ok

stop_device:	call	api_vcc_off
		in	XL,CTRLDDR
		andi	XL,0xc0
		out	CTRLDDR,XL
		in	XL,CTRLPORT
		andi	XL,0xc0
		out	CTRLPORT,XL
		jmp	main_loop_ok

wait_vdd:	ldi	ZL,0
		ldi	ZH,200
wait_vdd_1:	push	XL
		push	XH
		call	read_vext
		pop	XH
		pop	XL
		cpi	ZL,5
		brcc	wait_vdd_2
		ldi	XL,10
		ldi	XH,0
		rcall	prg_wait
		sbiw	XL,1
		brne	wait_vdd_1
		ldi	r16,0x7e
		jmp	main_loop
		
wait_vdd_2:	jmp	main_loop_ok
		

wait_vdd_int:	call	vcc_dis
		ldi	YL,0
		ldi	YH,200
		clt
wait_vdd_int1:	call	read_vext
		cpi	ZL,5
		brcc	wait_vdd_int2
		ldi	XL,10
		ldi	XH,0
		rcall	prg_wait
		sbiw	YL,1
		brne	wait_vdd_int1
		set
wait_vdd_int2:	ret


prog_val_sig:	out	CTRLPORT,r19
		jmp	main_loop_ok

prog_set_sig:	in	XL,CTRLPORT
		or	XL,r19
		out	CTRLPORT,XL
		jmp	main_loop_ok

prog_clr_sig:	in	XL,CTRLPORT
		com	r19
		and	XL,r19
		out	CTRLPORT,XL
		jmp	main_loop_ok

prog_val_dir:	out	CTRLDDR,r19
		jmp	main_loop_ok

prog_set_dir:	in	XL,CTRLDDR
		or	XL,r19
		out	CTRLDDR,XL
		jmp	main_loop_ok

prog_clr_dir:	in	XL,CTRLDDR
		com	r19
		and	XL,r19
		out	CTRLDDR,XL
		jmp	main_loop_ok
		
