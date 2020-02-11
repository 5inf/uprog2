################################################################################
#                                                                              #
#  makefile for UPROG2 universal programmer                                    #
#                                                                              #
#  (c) 2010-2016 Joerg Wolfram (joerg@jcwolfram.de)                            #
#                                                                              #
################################################################################

myNAME=uprog2-64

################################################################################

CC=gcc
AS=as
AR=ar
LD=gcc
OC=objcopy
OD=objdump
SZ=size

CFLAGS=-Wall -O3
CFLAGS+=-I./inc
LIBS=-lc -lftdi1 -lbluetooth


CSOURCES     := $(shell find ./src -type f -name *.c)
COBJECTS     := $(patsubst ./%,build/%,$(CSOURCES:.c=.o))

################################################################################

bin:	dir $(COBJECTS)
	$(LD) $(LDOPTS)  -o $(myNAME) $(COBJECTS) $(LDFLAGS) $(LIBS)

lib:	dir $(COBJECTS)
	$(AR) $(ARFLAGS) $(myNAME).a $(COBJECTS)

build/%.o: ./%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

dir:	
	mkdir -p build

install:	bin
	cp -f uprog2-64 /usr/local/bin/uprog2

clean:
	@rm -rf build
	@rm -f $(myNAME)


depend:
		@(sed '/^### DO NOT DELETE THIS LINE ###/,$$d' Makefile;\
		echo '### DO NOT DELETE THIS LINE ###';\
		$(CC) -MM $(CFLAGS) $(CSOURCES) |\
		sed ':1;/\.o: .* \\/{;N;s/ *\\\n */ /;};s/ \/[^ ]*h */ /;t1';\
		echo '### DEPENDENCIES END ###') > Makefile~ &&\
		mv Makefile~ Makefile

### DO NOT DELETE THIS LINE ###
main.o: src/main.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/devices.h inc/devices/devices_78K0R_FX3.h inc/devices/devices_FSL_HCS08.h inc/devices/devices_R8C.h inc/devices/devices_MSP430x2.h inc/devices/devices_MSP430x5.h inc/devices/devices_AVR.h inc/devices/devices_STM8.h inc/devices/devices_PIC12.h inc/devices/devices_PIC16.h inc/devices/devices_PIC18.h inc/devices/devices_DSPIC33.h inc/devices/devices_PPCBAM.h inc/devices/devices_SPC56.h inc/devices/devices_RL78F12.h inc/devices/devices_RL78F13.h inc/devices/devices_RL78F14.h inc/devices/devices_ST7FLITE.h inc/devices/devices_I2C.h inc/devices/devices_CC25xx.h inc/devices/devices_PSOC4.h inc/devices/devices_STM32F0.h inc/devices/devices_STM32F1.h inc/devices/devices_STM32F2.h inc/devices/devices_STM32F3.h inc/devices/devices_STM32F4.h inc/devices/devices_STM32L4.h inc/devices/devices_XC95xx.h inc/devices/devices_S12XD.h inc/devices/devices_S12XE.h inc/devices/devices_S12XS.h inc/devices/devices_SPIFLASH.h inc/devices/devices_DATAFLASH.h inc/devices/devices_ATXMEGA.h inc/devices/devices_RH850.h inc/devices/devices_V850.h inc/devices/devices_CC2640.h inc/devices_non_public/devices_ZMDI.h inc/devices_non_public/devices_MRK3.h inc/devices_non_public/devices_ELMOS.h inc/devices_non_public/devices_FRS81.h inc/devices_non_public/devices_SP40.h inc/devices_non_public/devices_RF430.h inc/devices_non_public/devices_SPC58.h inc/devices/devices_MLX.h inc/devices/devices_DGEN.h inc/devices/devices_SPIEEPROM.h inc/devices/devices_LPS25H.h inc/devices/devices_S32K.h inc/devices/devices_KEA64.h inc/devices/devices_TLE.h inc/devices/devices_AVR0.h inc/algorithm.h inc/algorithm/algo_atxmega.h inc/algorithm/algo_avr.h inc/algorithm/algo_c2000.h inc/algorithm/algo_cc25xx.h inc/algorithm/algo_dspic30.h inc/algorithm/algo_dspic33.h inc/algorithm/algo_ftest.h inc/algorithm/algo_hcitest.h inc/algorithm/algo_i2c.h inc/algorithm/algo_msp430a.h inc/algorithm/algo_msp430b.h inc/algorithm/algo_nec.h inc/algorithm/algo_nec2.h inc/algorithm/algo_pic16a.h inc/algorithm/algo_pic16b.h inc/algorithm/algo_pic16c.h inc/algorithm/algo_pic16d.h inc/algorithm/algo_pic18a.h inc/algorithm/algo_ppcbam.h inc/algorithm/algo_ppcjtag.h inc/algorithm/algo_ppcjtag2.h inc/algorithm_non_public/algo_ppcjtag3.h inc/algorithm/algo_psoc4.h inc/algorithm/algo_r8c.h inc/algorithm/algo_rl78.h inc/algorithm/algo_s08.h inc/algorithm/algo_s12xd.h inc/algorithm/algo_s12xe.h inc/algorithm/algo_s12xs.h inc/algorithm/algo_spigen.h inc/algorithm/algo_st7flite.h inc/algorithm/algo_stm8.h inc/algorithm/algo_stm32swd.h inc/algorithm/algo_spiflash.h inc/algorithm/algo_spieeprom.h inc/algorithm/algo_dataflash.h inc/algorithm/algo_mlx363.h inc/algorithm/algo_mlx316.h inc/algorithm/algo_rh850.h inc/algorithm/algo_v850.h inc/algorithm/algo_cc2640.h inc/algorithm_non_public/algo_zmdi.h inc/algorithm_non_public/algo_sp40.h inc/algorithm_non_public/algo_mrk3.h inc/algorithm_non_public/algo_elmos_sbw.h inc/algorithm_non_public/algo_rf430.h inc/algorithm/algo_fgen.h inc/algorithm/algo_la.h inc/algorithm/algo_lps25h.h inc/algorithm_non_public/algo_frs.h inc/algorithm/algo_s32kswd.h inc/algorithm/algo_kea64swd.h inc/algorithm/algo_sici.h inc/algorithm/algo_xc9500.h inc/algorithm/algo_rundev.h inc/algorithm/update.h inc/algorithm/list.h inc/wires.h
readhex.o: src/modules/readhex.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
getpid.o: src/modules/getpid.c
readsvf.o: src/modules/readsvf.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
list.o: src/modules/list.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
list4.o: src/modules/list4.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
subfunct.o: src/modules/subfunct.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
daemon.o: src/modules/daemon.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
writehexblock.o: src/modules/writehexblock.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
update.o: src/modules/update.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec/system/system.h
writehex.o: src/modules/writehex.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_zmdi.o: src/algorithm_non_public/algo_zmdi.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_mrk3.o: src/algorithm_non_public/algo_mrk3.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_elmos_sbw.o: src/algorithm_non_public/algo_elmos_sbw.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_rf430.o: src/algorithm_non_public/algo_rf430.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_ppcjtag3.o: src/algorithm_non_public/algo_ppcjtag3.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec_non_public/ppcjtag_84c/exec_ppcjtag.h
algo_sp40.o: src/algorithm_non_public/algo_sp40.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_frs.o: src/algorithm_non_public/algo_frs.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_psoc4.o: src/algorithm/algo_psoc4.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_stm32swd.o: src/algorithm/algo_stm32swd.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec/stm32f0xx/exec_stm32f0xx.h inc/exec/stm32f1xx/exec_stm32f1xx.h inc/exec/stm32f2xx/exec_stm32f2xx.h inc/exec/stm32f3xx/exec_stm32f3xx.h inc/exec/stm32f4xx/exec_stm32f4xx.h inc/exec/stm32l4xx/exec_stm32l4xx.h
algo_spiflash.o: src/algorithm/algo_spiflash.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_stm8.o: src/algorithm/algo_stm8.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_ppcjtag.o: src/algorithm/algo_ppcjtag.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec/ppcjtag_0b/exec_ppcjtag.h inc/exec/ppcjtag_0p/exec_ppcjtag.h
algo_mlx363.o: src/algorithm/algo_mlx363.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_atxmega.o: src/algorithm/algo_atxmega.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_v850.o: src/algorithm/algo_v850.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_rundev.o: src/algorithm/algo_rundev.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_cc25xx.o: src/algorithm/algo_cc25xx.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_sici.o: src/algorithm/algo_sici.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_lps25h.o: src/algorithm/algo_lps25h.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_pic18a.o: src/algorithm/algo_pic18a.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_spieeprom.o: src/algorithm/algo_spieeprom.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_pic16b.o: src/algorithm/algo_pic16b.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_rh850.o: src/algorithm/algo_rh850.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_dspic33.o: src/algorithm/algo_dspic33.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec/dspic33/exec_dspic33e.h
algo_ppcjtag2.o: src/algorithm/algo_ppcjtag2.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec/ppcjtag_el/exec_ppcjtag.h
algo_msp430b.o: src/algorithm/algo_msp430b.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec/msp430f5xx/exec_msp430f5xx.h
algo_kea64.o: src/algorithm/algo_kea64.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec/kea64/exec_kea64.h
algo_dataflash.o: src/algorithm/algo_dataflash.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_st7flite.o: src/algorithm/algo_st7flite.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_xc9500.o: src/algorithm/algo_xc9500.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_mlx316.o: src/algorithm/algo_mlx316.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_c2000.o: src/algorithm/algo_c2000.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_msp430a.o: src/algorithm/algo_msp430a.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_cc2640.o: src/algorithm/algo_cc2640.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec/cc2640/exec_cc2640.h
algo_r8c.o: src/algorithm/algo_r8c.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_s12xd.o: src/algorithm/algo_s12xd.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_s32k.o: src/algorithm/algo_s32k.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec/s32k/exec_s32k.h
algo_s19tohex.o: src/algorithm/algo_s19tohex.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_s12xs.o: src/algorithm/algo_s12xs.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_pic16d.o: src/algorithm/algo_pic16d.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_pic16a.o: src/algorithm/algo_pic16a.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_s12xe.o: src/algorithm/algo_s12xe.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_rl78.o: src/algorithm/algo_rl78.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_avr.o: src/algorithm/algo_avr.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_i2c.o: src/algorithm/algo_i2c.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_ppcbam.o: src/algorithm/algo_ppcbam.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec/ppcbam_0b/exec_ppcbam.h inc/exec/ppcbam_el/exec_ppcbam.h inc/exec/ppcbam_0p/exec_ppcbam_08.h inc/exec/ppcbam_0p/exec_ppcbam_16.h inc/exec/ppcbam_0p/exec_ppcbam_20.h inc/exec/ppcbam_0p/exec_ppcbam_40.h inc/exec/ppc_shadow/spc560b/proto_shadow.h inc/exec/ppc_shadow/spc560p/proto_shadow.h inc/exec/ppc_shadow/spc56el/proto_shadow.h
algo_avr0.o: src/algorithm/algo_avr0.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_s08.o: src/algorithm/algo_s08.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_datagen.o: src/algorithm/algo_datagen.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_fgen.o: src/algorithm/algo_fgen.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_dspic30.o: src/algorithm/algo_dspic30.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h inc/exec/dspic30/exec_dspic30.h
algo_nec2.o: src/algorithm/algo_nec2.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
algo_pic16c.o: src/algorithm/algo_pic16c.c inc/main.h inc/subfunct.h inc/readhex.h inc/writehex.h
### DEPENDENCIES END ###
