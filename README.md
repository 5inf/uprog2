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
    
#### Access to the uprog USB adapter as non root

if the uprog in its default configuration (vid0403, pid:0601) is plugged into the RaspberryPi the usbcore automatically loads the usbserial kernel module, which in turn automatically loads the ftdi_sio module. This creates a character device entry as /dev/ttyUSBx, where x is the next free number. (There is probably already udev and the systemd hwdb involved somewhere.) By default only the user root and the groupt dialout has access to this device. So to run uprog2 and get access to the hardware we either need to be root or belong to the group dialout.

Another way to get access to to the hardware is by adding to following udev rule to the udev configuration, e.g. via /etc/udev/rules.d/uprog2.rules

    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666"
    
 More options to filter for the uprog2 serial port in the udev rule could be used from the following list. These might come handy later.
 
    ATTRS{manufacturer}=="<your device name here>"
    ATTRS{product}=="<your product name here>"
    ATTRS{serial}=="<your device serial number here>"

/lib/udev/rules.d/60-serial.rules


### Adapter device

To build the adapter device we need an assembler. 
There are two options, gcc-avr contains avr-as as an assembler, but it does not understand the dialect used by uprog2.

avra is an assembler which would be capable of assembling uprog2.
As the version in Debian is currently to old (1.3.0) to know about the mega644 chip.
Support is only included since https://github.com/Ro5bert/avra/pull/3.
Thus we need to get the current version ourself from the official repository.

    cd ~
    git clone https://github.com/Ro5bert/avra.git
    cd avra
    make
    sudo make install
    which avra
    
Also, as uprog2 does include some "non public devices", we need to edit main.asm to uncomment (with a semicolon) the lines referencing files inside the folder devices_no_public/.

We can then build the binary for the adapter device with

    cd ~/uprog2/source/PROG
    ./asemble

This successfully builds the birnary to be programmed into the hardware adapter AVR644(P).
    
#### Initial adapter device programming

This is a chicken and egg situation. A programmer is required to initially program the programmer. Subsequent firmware updates are (mostly) handled automatically by uprog.

Any AVR ISP compatible programmer works with the board. I recommend an AVR ISP mk2 compatible USB programmer to do this. The programmer can even be an Arduino which has been programmed via the Arduino IDE to act as ISP programmer.

With a programmer programming can be done using e.g. AVRdude (https://www.nongnu.org/avrdude/) or uisp (http://savannah.nongnu.org/projects/uisp).

    sudo apt-get install avrdude
    sudo avrdude -c avrisp2 -p atmega644p -U hfuse:w:0xD4:m -U lfuse:w:0xE6:m -U efuse:w:0xFF:m -U flash:w:./binary/PROG/main.hex
    
Note: As of version 1.42 and possibly earlier versions too, the documentation on the uprog2 website states the wrong fuse values.
The fuse values used here have been comunicated by Jörg to me via mail and have been confirmed to work with 1.42.
    
 If at least one uprog is already available uprog2 itsel can be used to program the next ones.
 
    uprog2 ATMEGA644PA -5vlslf 0xE6
    uprog2 ATMEGA644PA -5vlshf 0xD4
    uprog2 ATMEGA644PA -5vlsef 0xFF
    uprog2 ATMEGA644PA -5veapmve main.hex
       
##### Setting USB device strings on the FTDI USB Serial interface

! WARNING: This changes the configuration of the FTDI chip on your uprog2 board. It has been tested and is working properly in a setup consisting of multiple uprog2 programmers. However: Use with caution!

Initially, around version 1.33, uprog2 had problems when multiple FTDI FT232 USB serial converter with vid=0403 and pid 6001 were connected to the machine.
This might happen in a typical setup, where besides uprog2 another FTDI FT232 chip is connected, e.g. to provide a USB UART for debugging.
Then uprog2 will simply open the first one it finds and then fails if that one is not the actual uprog2 hardware.

Therefore it is desired to have uprog2 check the USB device strings (manufacturer, device name and/or serial number) to find a matching programmer.

In recent versions (e.g. 1.42) uprog checks for vid=0x0403,pid=0x6661 (which Jörg uses) or vid=0x2763,pid=0xffff (officially reserved for uprog2) instead of the default vid=0x0403,pid=0x6001.

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
   
After this your FTDI device has its manufacturer string changed to 5inf and the device name changed to USBPROG2 (and currently the serial number set to 0815 as well as some other settings are also modified. Save the eeprom config read with --read-eeprom for restoring later and use with caution!).

After changing the strings any udev rules eventually in place might also need to be adapted (see above).
