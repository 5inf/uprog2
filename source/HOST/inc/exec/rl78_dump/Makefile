################################################################################
#  automatic generated file                                                    #
################################################################################

myNAME = rl78-dump-dflash

################################################################################

DEVICE=r5f10agg
PROGDEV=RL78DMP

TOOLPREFIX=/usr/local/toolchain/rl78-elf/bin/rl78-elf
UNILIBPREFIX=/usr/local/toolchain/unilib/rl78

CC=$(TOOLPREFIX)-gcc
AS=$(TOOLPREFIX)-as
AR=$(TOOLPREFIX)-ar
LD=$(TOOLPREFIX)-ld
OC=$(TOOLPREFIX)-objcopy
OD=$(TOOLPREFIX)-objdump
SZ=$(TOOLPREFIX)-size

CFLAGS  = -O2 -fno-ident -fno-common -fno-builtin -fomit-frame-pointer -mrelax -nostartfiles -nostdlib -fshort-double
CFLAGS +=-I$(UNILIBPREFIX)/include
CFLAGS +=-L$(UNILIBPREFIX)/lib
CFLAGS +=-I./inc -Duarch=necrl78

ACFLAGS  = -Os -fno-ident -fno-common -fomit-frame-pointer -mrelax

ACFLAGS +=-I$(UNILIBPREFIX)/include
ACFLAGS +=-L$(UNILIBPREFIX)/lib
ACFLAGS +=-I./inc

LDFLAGS=-Wl,--script=$(UNILIBPREFIX)/ldscripts/$(DEVICE).x
LIBS=-luni-$(DEVICE) -lm -lc -lgcc
OCFLAGS=-O srec
ARFLAGS=rcs

# objcopy flags...
# (objcopy creates s-record, adjusts load memory address of code sections)
# the latter is required because the bootloader only appears to accept
# addresses within the linear space from 0xC0000 to 0xFFFFF...
OCFLAGS = -O srec

# objdump flags...
# (objdump creates a listing file)
ODFLAGS = -S -D -xdC

# rules -------------------------------------------------------------------------------


CSOURCES     := $(shell find -L ./src/ -type f -name *.c)
COBJECTS     := $(patsubst ./%,build/%,$(CSOURCES:.c=.o))

ASOURCES     := $(shell find -L ./src/ -type f -name *.s)
AOBJECTS     := $(patsubst ./%,build/%,$(ASOURCES:.s=.o))

################################################################################

bin:	dir $(COBJECTS) $(AOBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(myNAME).elf $(COBJECTS) $(AOBJECTS) $(LIBS)
	$(OC) $(OCFLAGS) $(myNAME).elf $(myNAME).s37
	$(OD) $(ODFLAGS) $(myNAME).elf > $(myNAME).dump
	$(SZ) $(myNAME).elf
	@dos2unix $(myNAME).s37


lib:	dir $(COBJECTS) $(AOBJECTS)
	$(AR) $(ARFLAGS) $(myNAME).a $(COBJECTS) $(AOBJECTS)

build/%.o: ./%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

build/%.o: ./%.s
	mkdir -p $(dir $@)
	$(CC) $(ACFLAGS) -c -o $@ $<

dir:	
	mkdir -p build

prog:	bin
	uprog2 $(PROGDEV) -empm $(myNAME).s37

start:	clean prog
	sleep 1
	uprog2 $(PROGDEV) -st

clean:
	@rm -rf build
	@rm -f $(myNAME).elf
	@rm -f $(myNAME).s3*
	@rm -f $(myNAME).a


