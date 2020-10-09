################################################################################
#                                                                              #
#  Makefile for EFM32							       #
#                                                                              #
#  (c) 2019-2020 Joerg Wolfram (joerg@jcwolfram.de)                            #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
################################################################################

myNAME=boot

################################################################################

PDEVICE=EFM32xx-16k

LIBS=-lgcc

TOOLPREFIX=/usr/local/toolchain/arm-none-eabi/bin/arm-none-eabi

CC=$(TOOLPREFIX)-gcc
AS=$(TOOLPREFIX)-as
AR=$(TOOLPREFIX)-ar
LD=$(TOOLPREFIX)-gcc
OC=$(TOOLPREFIX)-objcopy
OD=$(TOOLPREFIX)-objdump
SZ=$(TOOLPREFIX)-size
ST=$(TOOLPREFIX)-strip

CFLAGS=-Wall -Os -mfloat-abi=soft -mthumb -mcpu=cortex-m3 -msoft-float -fno-builtin -fno-common -nostartfiles -nostdlib -fshort-double
CFLAGS+=-I./inc

RLDOPTS=-Wl,-script=./inc/efm32_ram.x
RLDOPTS+=-nostartfiles -nostdlib
LDFLAGS=-L/usr/local/toolchain/arm-none-eabi/lib/
OCFLAGS=-O srec
OC1FLAGS=-O ihex
ODFLAGS=-S -D -xdC
ARFLAGS=rcs

CSOURCES     := $(shell find -L ./src/ -type f -name *.c)
COBJECTS     := $(patsubst ./%,build/%,$(CSOURCES:.c=.o))

ASOURCES     := $(shell find -L ./src/ -type f -name *.s)
AOBJECTS     := $(patsubst ./%,build/%,$(ASOURCES:.s=.o))

################################################################################

rbin:	dir $(COBJECTS) $(AOBJECTS)
	$(LD) $(RLDOPTS)  -o $(myNAME).elf $(COBJECTS) $(AOBJECTS) $(LDFLAGS) $(LIBS)
	$(OC) $(OCFLAGS) $(myNAME).elf $(myNAME).s37
	$(OD) $(ODFLAGS) $(myNAME).elf > $(myNAME).lst
	$(SZ) $(myNAME).elf
	@dos2unix $(myNAME).s37
	./generate_boot.pl efm32a

lib:	dir $(COBJECTS) $(AOBJECTS)
	$(AR) $(ARFLAGS) $(myNAME).a $(COBJECTS) $(AOBJECTS)
	$(ST) -x $(myNAME).a

build/%.o: ./%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

build/%.o: ./%.s
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

dir:	
	mkdir -p build

run:	clean rbin
	uprog2 $(PDEVICE) -rr $(myNAME).s37

clean:
	@rm -rf build
	@rm -f $(myNAME).elf
	@rm -f $(myNAME).s37
	@rm -f $(myNAME).a

depend:
		@(sed '/^### DO NOT DELETE THIS LINE ###/,$$d' Makefile;\
		echo '### DO NOT DELETE THIS LINE ###';\
		for i in $(CSOURCES); do \
		$(CC) -MM $(CFLAGS) $$i |\
		sed ':1;/\.o: .* \\/{;N;s/ *\\\n */ /;};s/ \/[^ ]*h */ /;t1' | dep_addpath;\
		done; \
		echo '### DEPENDENCIES END ###') > Makefile~ &&\
		mv Makefile~ Makefile

### DO NOT DELETE THIS LINE ###
