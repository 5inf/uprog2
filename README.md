# uprog2
uprog2: Universal Programmer for Linux

The programmer is designed and developed by Jörg Wolfram. See http://www.jcwolfram.de/projekte/uprog2/main.php.
More info can also be found in this forum thread on mikrocontroller.net: https://www.mikrocontroller.net/topic/411643

The software and schematic are licensed by Jörg Wolfram as "GPL (GNU General Public Licence) Version 3" [http://www.jcwolfram.de/projekte/uprog2/main.php].

This repository tries to mirror the software releases from jcwolfram.de and adds additional stuff such as a PCB layout and a 3d printable housing to allow building actual hardware.

## Supported devices

Currently the following devices are supported for programming

* Atmel AVR (SPI)
* Atmel ATxmega (PDI)
* Cypress PSOC4 (SWD)
* Microchip PIC10xx/PIC12xx/PIC16xx
* Microchip PIC18xx
* Microchip dsPIC33xx
* NXP/Freescale MPC56xx (BAM)
* NXP/Freescale HCS08
* NXP/Freescale HCS12(X)
* NXP/Freescale S32K
* NXP/Freescale K9EA
* Renesas R8C
* Renesas 78K0R
* Renesas RL78
* Renesas V850
* Renesas RH850
* ST Micro SPC56xx (BAM)
* ST Micro SPC56xx (JTAG)
* ST Micro ST7FLITE
* ST Micro STM8 (SWIM)
* ST Micro STM32 (SWD)
* TI MSP430 (SBW)
* TI CC2540, CC2541
* TI CC2640
* XILINX XC9500/XL
* Atmel Dataflash (AT45DBxx)
* SPI-Flash (25xx)
* SPI-EEPROM (250xx)
* I2C-EEPROM (24xx)
* Magnetsensoren (Melexis)

## Building

The build consist of two parts. The uprog2 host firmware on the PC and the adapter device firmware (for ATMEGA644P-20AU).

The following parts describe building both parts on a RaspberryPi 3B+ running raspbian stretch, but should work on any other system where the necessary libraries are available.

### Host

    apt-get install libusb-1.0-0 libusb-1.0-0-dev libftdi1 libftdi1-dev
    git clone https://github.com/5inf/uprog2.git
    cd uprog2
    cd source/HOST
    make clean
    make 
    sudo make install
    /usr/local/bin/uprog2

### Adapter device

! This description is still work in progress. The build under Linux is currently not working as described.

    apt-get install gcc-avr
    apt-get install avra
    git clone https://github.com/5inf/uprog2.git
    cd uprog2
    cd source/PROG_USB or cd source/PROG_BT

One can then try to assemble with a)
    
    avr-as main-usb.asm 2>&1 | less 
    
("2>&1 | less" so to see the full errors log, especcially the first one which tells us gcc avr-as does not understand the avr assembler dialect used.)
 
or b)

    avra main-usb.asm 
    
avra knows the correct dialect, but m644def.inc is not found in /usr/local/include/avr/m644def.inc.
The avra installation locates it's include files at /usr/share/avra/ but also there is no m644def.inc.
One can get the file e.g. from here (https://github.com/DarkSector/AVR/blob/master/asm/include/m644def.inc) or from a local AVR Studio (Windows) installation.
~~Even then avra seem to be lacking support for the ATmega644 at the moment (https://github.com/hsoft/avra/issues/2).~~~
The issue is fixed in https://github.com/5inf/avra and waiting to be pulled into https://github.com/hsoft/avra.

In main-usb.asm currently the lines with .include devices_no_public/... need to be commented out and then 

    avra main-usb.asm 
    
successfully builds the AVR binary.
    
#### Initial adapter device programming

This is a chicken and egg situation. A programmer is required to initially program the programmer. Subsequent firmware updates are (mostly) handled automatically by uprog.

Any AVR ISP compatible programmer works with the board. This can even be an Arduino which has been programmed via the Arduino IDE to act as ISP programmer.

With a programmer programming can be done using e.g. AVRdude (https://www.nongnu.org/avrdude/) or uisp (http://savannah.nongnu.org/projects/uisp).

    apt-get install avrdude
    apt-get install uisp
    
    avrdude ...
    uisp ...
    
##### Setting USB device strings on the FTDI USB Serial interface

! WARNING: This changes the configuration of the FTDI chip on your uprog2 board. Use with caution!

Currently uprog2 has problems when multiple FTDI USB serial converter are connected to the machine, as uprog2 will simply open the first one and then fails if that one is not the actual uprog2 hardware.

In the future it is desired to have uprog2 check the USB device strings (manufacturer, device name and/or serial number) to find a matching programmer.

To adjust the USB device strings (manufacturer name and device name) the FT_PROG utility from FTDI (FT_PROG 3.3.88.402 - EEPROM Programming Utility, https://www.ftdichip.com/Support/Utilities.htm#FT_PROG) is needed. Unfortunately this utility is Windows only.

There are two Linux tools called ftdi-eeprom. One available from the Debian package repository, which seems to be written by Intra2net AG, the maintainer of libftdi. A second one written by Evan Nemerson (https://github.com/nemequ/ftdi-eeprom). Both tools can change the desired settings in the FTDI chip. 

Below is the description for the ftdi-eeprom tool packaged in Debian. More information can be found using man ftdi-eeprom.

    apt-get install ftdi-eeprom
    cd uprog2/config
    sudo rmmod ftdi_sio
    sudo ftdi_eeprom --device i:0x0403:0x6001 --read-eeprom ftdi.conf
    cp eeprom.new eeprom.bak
    sudo ftdi_eeprom --device i:0x0403:0x6001 --build-eeprom ftdi.conf
    sudo ftdi_eeprom --device i:0x0403:0x6001 --flash-eeprom ftdi.conf
    sudo insmod ftdi_sio
   
After this your FTDI device has its manufacturer string changed to 5inf and the device name changed to USBPROG2 (and currently the serial number set to 0815 as well as some other settings are also modified. Use with caution!).


