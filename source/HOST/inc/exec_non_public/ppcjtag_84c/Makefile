################################################################################
#                                                                              #
#  Makefile for SPC560B                                                        #
#                                                                              #
#  (c) 2014-2015 Joerg Wolfram (joerg@jcwolfram.de)                            #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
################################################################################

myNAME=boot

################################################################################

DEVICE=spc584c60
PDEVICE=SPC584C60

#LIBS=-luni-$(DEVICE)

TOOLPREFIX=/usr/local/toolchain/powerpc-vle-elf/bin/powerpc-elf
UNILIBPREFIX=/usr/local/toolchain/unilib/ppc-vle

CC=$(TOOLPREFIX)-gcc
AS=$(TOOLPREFIX)-as
AR=$(TOOLPREFIX)-ar
LD=$(TOOLPREFIX)-ld
OC=$(TOOLPREFIX)-objcopy
OD=$(TOOLPREFIX)-objdump
SZ=$(TOOLPREFIX)-size

CFLAGS=-Wall -O3 -mvle -flto -mhard-float -fno-builtin -fno-common -nostartfiles -nostdlib -fshort-double
CFLAGS+=-I$(UNILIBPREFIX)/include -L$(UNILIBPREFIX)/lib
CFLAGS+=-I./inc

ASFLAGS=-mvle
LDOPTS=-script=$(UNILIBPREFIX)/ldscripts/$(DEVICE).x
#LDOPTS+=$(UNILIBPREFIX)/startup/startup-$(DEVICE)_core0.o
RLDOPTS=-script=$(UNILIBPREFIX)/ldscripts/$(DEVICE)_ram.x
#RLDOPTS+=$(UNILIBPREFIX)/startup/startup-$(DEVICE)_ram.o
#LDFLAGS=-L$(UNILIBPREFIX)/lib
OCFLAGS=-O srec
ODFLAGS=-S -D -xdC
ARFLAGS=rcs

CSOURCES     := $(shell find -L ./src/ -type f -name *.c)
COBJECTS     := $(patsubst ./%,build/%,$(CSOURCES:.c=.o))

ASOURCES     := $(shell find -L ./src/ -type f -name *.s)
AOBJECTS     := $(patsubst ./%,build/%,$(ASOURCES:.s=.o))

################################################################################

bin:	dir $(COBJECTS) $(AOBJECTS)
	$(LD) $(LDOPTS)  -o $(myNAME).elf $(COBJECTS) $(AOBJECTS) $(LDFLAGS) $(LIBS)
	$(OC) $(OCFLAGS) $(myNAME).elf $(myNAME).s37
	$(SZ) $(myNAME).elf
	$(OD) $(ODFLAGS) $(myNAME).elf >> $(myNAME).dump
	@dos2unix $(myNAME).s37

rbin:	dir $(COBJECTS) $(AOBJECTS)
	$(LD) $(RLDOPTS)  -o $(myNAME).elf $(COBJECTS) $(AOBJECTS) $(LDFLAGS) $(LIBS)
	$(OC) $(OCFLAGS) $(myNAME).elf $(myNAME).s37
	$(SZ) $(myNAME).elf
	$(OD) $(ODFLAGS) $(myNAME).elf >> $(myNAME).dump
	@dos2unix $(myNAME).s37


lib:	dir $(COBJECTS) $(AOBJECTS)
	$(AR) $(ARFLAGS) $(myNAME).a $(COBJECTS) $(AOBJECTS)

build/%.o: ./%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

build/%.o: ./%.s
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

dir:	
	mkdir -p build

run:	clean rbin
	uprog2 $(PDEVICE) -5vrr $(myNAME).s37

prog:	bin
	uprog2 $(PDEVICE) -5vempm $(myNAME).s37

start:	clean prog
	uprog2 $(PDEVICE) -5vst

clean:
	@rm -rf build
	@rm -f $(myNAME).elf
	@rm -f $(myNAME).s37
	@rm -f $(myNAME).a


