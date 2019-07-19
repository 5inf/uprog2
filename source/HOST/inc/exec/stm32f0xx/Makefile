################################################################################
#                                                                              #
#  Makefile for STM32F030C6						       #
#                                                                              #
#  (c) 2015-2016 Joerg Wolfram (joerg@jcwolfram.de)                            #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
################################################################################

myNAME=boot

################################################################################
DEVICE=stm32f030c6
HDEVICE=stm32f0xx

TOOLPREFIX=/usr/local/toolchain/arm-none-eabi/bin/arm-none-eabi
UNILIBPREFIX=/usr/local/toolchain/unilib/stm32f0xx

CC=$(TOOLPREFIX)-gcc
AS=$(TOOLPREFIX)-as
AR=$(TOOLPREFIX)-ar
LD=$(TOOLPREFIX)-gcc
OC=$(TOOLPREFIX)-objcopy
OD=$(TOOLPREFIX)-objdump
SZ=$(TOOLPREFIX)-size

CFLAGS=-Wall -Os -mfloat-abi=soft -mthumb -mcpu=cortex-m0 -msoft-float -fno-builtin -fno-common -nostartfiles -nostdlib -fshort-double
CFLAGS+=-I$(UNILIBPREFIX)/include -L$(UNILIBPREFIX)/lib
CFLAGS+=-I./inc

RLDOPTS=-Wl,-script=$(UNILIBPREFIX)/ldscripts/$(DEVICE)_ram.x
RLDOPTS+=-nostartfiles -nostdlib
OCFLAGS=-O srec
OC1FLAGS=-O ihex
ODFLAGS=-S -D -xdC
ARFLAGS=rcs

ASOURCES     := $(shell find -L ./src/ -type f -name *.s)
AOBJECTS     := $(patsubst ./%,build/%,$(ASOURCES:.s=.o))

################################################################################
bin:	dir $(COBJECTS) $(AOBJECTS)
	$(LD) $(RLDOPTS)  -o $(myNAME).elf $(AOBJECTS) $(LDFLAGS)
	$(OC) $(OCFLAGS) $(myNAME).elf $(myNAME).s37
	$(OD) $(ODFLAGS) $(myNAME).elf > $(myNAME).lst
	$(SZ) $(myNAME).elf
	@dos2unix $(myNAME).s37
	./generate_boot.pl $(HDEVICE) 

build/%.o: ./%.s
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

dir:
	mkdir -p build

clean:
	@rm -rf build
	@rm -f $(myNAME).elf
	@rm -f $(myNAME).s37
	@rm -f $(myNAME).a


