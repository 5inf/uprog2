# 21.11.2021 Version 1.41
* System-Version ist jetzt 0019, Update erfolgt automatisch
* Bugfix: Update-Daten waren teilweise unvollständig
* Feature: Option für nicht umprogrammierte FTDI-Chips
* Neue Devices: STM8L mit 64K Flash
* Neue Devices: VEML3328 Farbsensor
* Change beim KEA64: Code im RAM beginnt jetzt im L-SRAM
* Bugfix: JTAG/SWD-Umschaltung bei KEA64 entfernt
* Optimierung: SPI-Flashes werden jetzt schneller ausgelesen

# 12.6.2021 Version 1.40
* System-Version ist jetzt 0018, Update erfolgt automatisch
* Feature: Debug-Funktionen für HCS08 Controller
* Feature: Checksummen-Berechnung für die RL78 Familie
* Neue Devices: ATTiny 1xxx
* Neue Devices: ATMEGA über JTAG
* Erstmals Binary für Raspberry Pi
* Beschleunigung der Datenübertragung beim Auslesen
* Feature: Margin Check / Dataflash für S32K Familie
* Bugfix: Program->Verify für S32K Familie las erste 16 Bytes falsch
* Bugfix: Programmierung S32K: FSEC etc. wurde vorher nicht gelöscht

# 12.1.2021 Version 1.39
* System-Version ist jetzt 0017, Update erfolgt automatisch
* Feature: Debug-Funktionen für ARM Cortex basierte Controller
* Feature: Dump-Funktionen für die RL78 Familie
* Feature: ID-Funktionen für die RH870 Familie
* Neue Devices: STM32F7xx
* Neues Device: DS28E07
* Modellpflege: Neue Devices beim R8C
* Bugfix: Beim STM32F4xx blieb das Erase manchmal in einer Endlosschleife
* Bugfix: falsche Maske für Option-Bytes beim STM32F4xx
* diverse kleinere Bugfixes

# 26.10.2020 Version 1.38
*  System-Version ist jetzt 0016, Update erfolgt automatisch
*  Bugfix: Bei S08 und S12X wurde die BDM-Frequenz zu niedrig erkannt (nur ca. 1/3)
*  Bugfix: Dateiname bei make install korrigiert

# 28.9.2020 Version 1.37
*  System-Version ist jetzt 0015, Update erfolgt automatisch
*  Die 32-Bit Version (X86 Binary) habe ich eingestellt
*  Anpassungen an GCC10
*  Neue Devices: NXP/Freescale S12Z
*  Neue Devices: NXP/Freescale MPC574x
*  Neue Devices: STM SPC584cc
*  Neue Devices: Silabs EFM32/EFR32
*  diverse kleinere Bugfixes

# 27.1.2020 Version 1.36
*  System-Version ist jetzt 0014, Update erfolgt automatisch
*  Bugfix: Programmierung XC95xxXL funktionerte nicht richtig
*  Feature: Bootstrapping beim RH850
*  Feature: Config lesen/schreiben beim SPI Flash
*  Neue Devices: AT89S8252
*  Modellpflege: neue Devices beim RH850
*  Modellpflege: neue Devices beim SPI-Flash, Änderung der Standardtypen

# 25.10.2019 Version 1.35
*  Loader-Version ist jetzt 1.6, das gesamte Image muss neu programmiert werden
*  System-Version ist jetzt 0013
*  Wichtig: Änderung der USB PID auf 0x6661
*  externe Versorgung wird jetzt erst ab 1,5V erkannt
*  Bugfix: Beim RH850 wurde der Data-Flash nicht komlett beschrieben
*  Feature: Es können beim Programmieren/Verify bis zu 4 Dateien angegeben werden
*  Feature: Security beim RH850 lesen/schreiben
*  Neue Devices: AVR0 mit UPDI
*  Neue Devices: TLE5014
*  Modellpflege: neue Devices und Funktionen bei den SPI-Flashes


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
