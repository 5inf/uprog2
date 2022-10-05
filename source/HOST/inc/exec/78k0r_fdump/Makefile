################################################################################
#                                                                              #
#  Makefile for 78K0R							       #
#                                                                              #
#  (c) 2015-2018 Joerg Wolfram (joerg@jcwolfram.de)                            #
#                                                                              #
################################################################################

myNAME = N78k0r-dump-flash

################################################################################

DEVICE=upd78f1804
PROGDEV=N78K0RDMP

TOOLPREFIX=/usr/local/toolchain/rl78-elf/bin/rl78-elf
UNILIBPREFIX=/usr/local/toolchain/unilib/78k0r

CC=$(TOOLPREFIX)-gcc
AS=$(TOOLPREFIX)-as
AR=$(TOOLPREFIX)-ar
LD=$(TOOLPREFIX)-ld
OC=$(TOOLPREFIX)-objcopy
OD=$(TOOLPREFIX)-objdump
SZ=$(TOOLPREFIX)-size

CFLAGS  = -Os -DMCU=UPD78F1804 -fno-ident -fno-common -fno-builtin -fomit-frame-pointer -mrelax -nostartfiles -nostdlib -fshort-double
CFLAGS +=-I$(UNILIBPREFIX)/include
CFLAGS +=-L$(UNILIBPREFIX)/lib
CFLAGS +=-I./inc -Duarch=nec78k0r

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
	./generate_dumper.pl


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
	uprog2 $(PROGDEV) -ecpm $(myNAME).s37

start:	clean prog
	uprog2 $(PROGDEV) -st

start5:	clean prog
	uprog2 $(PROGDEV) -5vst

clean:
	@rm -rf build
	@rm -f $(myNAME).elf
	@rm -f $(myNAME).s3*
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
