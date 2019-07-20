# 7.4.2019 Version 1.33 
* System-Version ist jetzt 0012, Update erfolgt automatisch
* Bugfix: langsame SPI-Geschwindigkeit beim AVR war zu hoch
* Bugfix: beim R8C wurde Code>2K nicht im RAM gestartet
* Bugfix: Beim MSP430 POR vor Code-Transfer
* Bugfix: Beim HCS08 falscher Flash-bereich bei den 60K Varianten
* Feature: Programmierung über JTAG jetzt auch beim SPC56ELxx
* Feature: Option Bytes beim RH850 lesen/schreiben
* Modellpflege: neue Devices beim RL78

# 25.1.2019 Version 1.32 
* Loader-Version ist jetzt 1.4, das gesamte Image muss neu programmiert werden
* System-Version ist jetzt 0011, Update erfolgt automatisch
* Verkleinerte Bootloader-Sektion, Fuse muss neu programmiert weden
* Bugfix: Prorammierung alter AVRs ohne Ready/Busy Bit
* Neue Devices: NXP K9EA
* Neue Devices: PIC16(L)F153xx
* Neue Devices: RH850/FK1M-S1
# 25.10.2018 Version 1.31 
* System-Version ist jetzt 0010, Update erfolgt automatisch
* Bugfix: Quad-Program bei SPI-Flashes funktionierte teilweise nicht richtig
* WebGui-Funktion entfernt
* Neue Devices: NXP S32K
# 23.04.2018 Version 1.30 
* Loader-Version ist jetzt 1.4, das gesamte Image muss neu programmiert werden
* System-Version ist jetzt 0009, Update erfolgt automatisch
* Bugfix: EEPROM-Programierung beim AVR ließ Bytes aus
* Bugfix: Binärpage-Erkennung bei den Dataflashes funktionierte nicht richtig
* Bugfix: Zu kleine RAM-Größen beim STM32F4xx, es wurden bei -rr nur max. 4K übertragen
* Neue Funktion, Umschaltung auf zweites Device
* Neue Devices: TI CC2640
* Neue Devices: STM32L4xx
* Neue Devices: PIC18F2xxx/PIC18F4xxx
# 17.12.2017 Version 1.29 
* System-Version ist jetzt 0008, Update erfolgt automatisch
* Bugfix: Dataflash-Startadressen beim S12XE angepasst
* Trimm-Funktion für den internen Oszillator beim HCS08
* Neue Devices: Renesas V850/RH850
* Neues Device: Drucksensor LPS25H
# 5.10.2017 Version 1.28 
* System-Version ist jetzt 0007, Update erfolgt automatisch
* Bugfix: Leerblock-Erkennung bei PIC16xxx entfernt (wird sequentiell programmmiert)
* MSP430F5xx fehlende Funktionalität beim Löschen/Schreiben integriert
* MSP430 Flash löschen mit/ohne INFO-A
* Single-Core SPC56xx können jetzt auch über JTAG programmiert werden
* SPC56xx Programmierung über BAM hat jetzt andere Typbezeichhnungen (SPC56XX-BL)
* Unterstützung für SPI-EEPROMs (AT25010...AT25640)
* Neue Funktion: Frequenzgenerator
* Neue Funktion: Web-Interface
# 25.2.2017 Version 1.26 
* Anzeige über Debug-LEDs beim SPC56xx deaktiviert
* Bugfix: Pageoffset bei SPI-Flashes stimmte nicht
* Bugfix: beim MSP430 wurden falsche Programmerpins angesteuert
* Bugfix: Erase Dataflash beim RL78 brach mit Fehler ab, obwohl alles OK war
* 64MB SPI-Flash und Quad-Mode hinzugefügt
* MLX90363 readout (EEPROM write noch nicht implementiert
# 8.11.2016 Version 1.25a 
* DOC: Fehler in der Controllerbeschaltung behoben (10K-Widerstand an PA3)
# 7.11.2016 Version 1.25 
* Initiale Version
