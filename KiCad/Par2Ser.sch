EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 3750 5200 0    50   BiDi ~ 0
D0
Text GLabel 3750 5000 0    50   BiDi ~ 0
D1
Text GLabel 3750 4800 0    50   BiDi ~ 0
D2
Text GLabel 3750 4600 0    50   BiDi ~ 0
D3
Text GLabel 3750 4400 0    50   BiDi ~ 0
D4
Text GLabel 3750 4200 0    50   BiDi ~ 0
D5
Text GLabel 3750 4000 0    50   BiDi ~ 0
D6
Text GLabel 3750 3800 0    50   BiDi ~ 0
D7
Text GLabel 3750 3400 0    50   BiDi ~ 0
BUSY
Text GLabel 3750 3200 0    50   BiDi ~ 0
POUT
Text GLabel 3750 3000 0    50   BiDi ~ 0
SELECT
Text GLabel 3450 4200 0    50   Input ~ 0
GND
Text GLabel 3750 4900 0    50   Output ~ 0
Amiga_RESET
Text GLabel 4800 3750 0    50   Input ~ 0
GND
Text GLabel 6150 3550 2    50   Input ~ 0
GND
Text GLabel 4800 4050 0    50   BiDi ~ 0
BUSY
Text GLabel 4800 4150 0    50   BiDi ~ 0
POUT
Text GLabel 4800 4250 0    50   BiDi ~ 0
D6
Text GLabel 4800 4350 0    50   BiDi ~ 0
D7
Text GLabel 6150 4550 2    50   BiDi ~ 0
D0
Text GLabel 6150 4450 2    50   BiDi ~ 0
D1
Text GLabel 6150 4350 2    50   BiDi ~ 0
D2
Text GLabel 6150 4250 2    50   BiDi ~ 0
D3
Text GLabel 6150 4150 2    50   BiDi ~ 0
D4
Text GLabel 6150 4050 2    50   BiDi ~ 0
D5
Text GLabel 6650 3400 2    50   Input ~ 0
RESET
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 5EB341E8
P 3800 2500
F 0 "#FLG0101" H 3800 2575 50  0001 C CNN
F 1 "PWR_FLAG" H 3800 2673 50  0000 C CNN
F 2 "" H 3800 2500 50  0001 C CNN
F 3 "~" H 3800 2500 50  0001 C CNN
	1    3800 2500
	-1   0    0    1   
$EndComp
$Comp
L power:+5V #PWR0101
U 1 1 5EB34559
P 3800 2400
F 0 "#PWR0101" H 3800 2250 50  0001 C CNN
F 1 "+5V" H 3815 2573 50  0000 C CNN
F 2 "" H 3800 2400 50  0001 C CNN
F 3 "" H 3800 2400 50  0001 C CNN
	1    3800 2400
	1    0    0    -1  
$EndComp
Wire Wire Line
	3800 2400 3800 2500
$Comp
L power:GND #PWR0102
U 1 1 5EB362B9
P 4100 2500
F 0 "#PWR0102" H 4100 2250 50  0001 C CNN
F 1 "GND" H 4105 2327 50  0000 C CNN
F 2 "" H 4100 2500 50  0001 C CNN
F 3 "" H 4100 2500 50  0001 C CNN
	1    4100 2500
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 5EB368E6
P 4100 2400
F 0 "#FLG0102" H 4100 2475 50  0001 C CNN
F 1 "PWR_FLAG" H 4100 2573 50  0000 C CNN
F 2 "" H 4100 2400 50  0001 C CNN
F 3 "~" H 4100 2400 50  0001 C CNN
	1    4100 2400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4100 2400 4100 2500
Text GLabel 4100 2450 0    50   Input ~ 0
GND
Text GLabel 4800 3850 0    50   BiDi ~ 0
SELECT
$Comp
L Device:C_Small C6
U 1 1 5EB53531
P 6650 4300
F 0 "C6" H 6500 4300 50  0000 C CNN
F 1 "0.1uF" H 6500 4200 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 6650 4300 50  0001 C CNN
F 3 "~" H 6650 4300 50  0001 C CNN
	1    6650 4300
	1    0    0    -1  
$EndComp
NoConn ~ 6150 3850
NoConn ~ 6150 3950
NoConn ~ 6150 4650
NoConn ~ 3750 3300
NoConn ~ 3750 3500
NoConn ~ 3750 5100
NoConn ~ 4800 3650
Text GLabel 6150 4850 2    50   Output ~ 0
SCK
Text GLabel 4800 4850 0    50   Input ~ 0
MISO
Text GLabel 4800 4750 0    50   Output ~ 0
MOSI
Text GLabel 3800 2450 0    50   Input ~ 0
VCC
NoConn ~ 3750 3100
Text GLabel 1800 2200 0    50   Input ~ 0
VCC
$Comp
L Device:LED D2
U 1 1 5EBAFFCE
P 2000 2650
F 0 "D2" V 2039 2533 50  0000 R CNN
F 1 "Power LED indicator" V 1948 2533 50  0000 R CNN
F 2 "LED_THT:LED_Rectangular_W5.0mm_H2.0mm" H 2000 2650 50  0001 C CNN
F 3 "~" H 2000 2650 50  0001 C CNN
	1    2000 2650
	0    -1   -1   0   
$EndComp
Text GLabel 2000 2900 3    50   Input ~ 0
GND
Wire Wire Line
	1800 2200 2000 2200
Wire Wire Line
	2000 2400 2000 2500
Wire Wire Line
	2000 2800 2000 2900
Text GLabel 3750 3600 0    50   Input ~ 0
ACK
$Comp
L Device:R_Small R2
U 1 1 5EB9BBF1
P 2000 2300
F 0 "R2" H 1850 2300 50  0000 L CNN
F 1 "330" H 2050 2300 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric_Pad1.30x1.75mm_HandSolder" H 2000 2300 50  0001 C CNN
F 3 "~" H 2000 2300 50  0001 C CNN
	1    2000 2300
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R5
U 1 1 5EB9C4B4
P 2000 3900
F 0 "R5" V 2100 3900 50  0000 C CNN
F 1 "4k7" V 1900 3850 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric_Pad1.30x1.75mm_HandSolder" H 2000 3900 50  0001 C CNN
F 3 "~" H 2000 3900 50  0001 C CNN
	1    2000 3900
	0    -1   -1   0   
$EndComp
$Comp
L Device:R_Small R1
U 1 1 5EB9CA00
P 2500 4300
F 0 "R1" H 2400 4300 50  0000 C CNN
F 1 "330" H 2650 4300 50  0000 C CNN
F 2 "Resistor_SMD:R_1206_3216Metric_Pad1.30x1.75mm_HandSolder" H 2500 4300 50  0001 C CNN
F 3 "~" H 2500 4300 50  0001 C CNN
	1    2500 4300
	1    0    0    -1  
$EndComp
Text GLabel 9350 3900 0    50   Input ~ 0
GND
$Comp
L Device:LED D1
U 1 1 5EBA7223
P 2500 4650
F 0 "D1" V 2500 4850 50  0000 R CNN
F 1 "Activity LED" V 2600 5200 50  0000 R CNN
F 2 "LED_THT:LED_Rectangular_W5.0mm_H2.0mm" H 2500 4650 50  0001 C CNN
F 3 "~" H 2500 4650 50  0001 C CNN
	1    2500 4650
	0    -1   -1   0   
$EndComp
Text Notes 2100 3350 0    50   ~ 0
Optional Activity LED
Wire Notes Line
	1550 2100 1550 3150
Wire Notes Line
	1550 3150 2950 3150
Wire Notes Line
	2950 3150 2950 2100
Wire Notes Line
	2950 2100 1550 2100
Text Notes 2150 2200 0    50   ~ 0
Optional Power LED
Wire Wire Line
	3750 3700 3450 3700
Wire Wire Line
	3450 3700 3450 3900
Wire Wire Line
	3450 4700 3750 4700
Wire Wire Line
	3750 3900 3450 3900
Connection ~ 3450 3900
Wire Wire Line
	3450 3900 3450 4100
Wire Wire Line
	3750 4100 3450 4100
Connection ~ 3450 4100
Wire Wire Line
	3450 4100 3450 4300
Wire Wire Line
	3750 4300 3450 4300
Connection ~ 3450 4300
Wire Wire Line
	3450 4300 3450 4500
Wire Wire Line
	3750 4500 3450 4500
Connection ~ 3450 4500
Wire Wire Line
	3450 4500 3450 4700
Text GLabel 4800 4550 0    50   Output ~ 0
ACK
$Comp
L Connector:DB25_Male J1
U 1 1 6108B66B
P 4050 4200
F 0 "J1" H 4230 4246 50  0000 L CNN
F 1 "DB25_Male" H 3850 2750 50  0000 L CNN
F 2 "Connector_Dsub:DSUB-25_Male_EdgeMount_P2.77mm" H 4050 4200 50  0001 C CNN
F 3 " ~" H 4050 4200 50  0001 C CNN
	1    4050 4200
	1    0    0    -1  
$EndComp
Text GLabel 11050 4400 2    50   Output ~ 0
3V3
Text GLabel 6300 5800 3    50   Input ~ 0
MOSI
Text GLabel 2400 3500 0    50   Input ~ 0
VCC
Wire Wire Line
	2500 4100 2500 4200
Wire Wire Line
	2500 4400 2500 4500
Wire Notes Line
	2950 3250 1550 3250
Text GLabel 4800 4650 0    50   Output ~ 0
SS
$Comp
L Device:R_Small R6
U 1 1 610DADE6
P 5950 5600
F 0 "R6" H 5850 5600 50  0000 C CNN
F 1 "1k 0805" V 6050 5400 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 5950 5600 50  0001 C CNN
F 3 "~" H 5950 5600 50  0001 C CNN
	1    5950 5600
	-1   0    0    1   
$EndComp
Text GLabel 6200 5800 3    50   Input ~ 0
SS
Text GLabel 6650 4400 3    50   Input ~ 0
GND
NoConn ~ 6150 3450
Text GLabel 6150 3750 2    50   Input ~ 0
VCC
$Comp
L Device:C_Small C7
U 1 1 611D1D5F
P 9100 5200
F 0 "C7" H 9250 5200 50  0000 C CNN
F 1 "0.1uF" H 8900 5200 50  0000 C CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 9100 5200 50  0001 C CNN
F 3 "~" H 9100 5200 50  0001 C CNN
	1    9100 5200
	-1   0    0    1   
$EndComp
Text GLabel 6400 5800 3    50   Input ~ 0
MISO
$Comp
L Device:C_Small C3
U 1 1 612089E2
P 11050 3850
F 0 "C3" H 10950 3750 50  0000 C CNN
F 1 "0.1uF" H 10900 3950 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 11050 3850 50  0001 C CNN
F 3 "~" H 11050 3850 50  0001 C CNN
	1    11050 3850
	-1   0    0    1   
$EndComp
$Comp
L Par2Ser:Arduino_Nano_V3 U1
U 1 1 670D85EB
P 5450 4100
F 0 "U1" H 5475 5165 50  0000 C CNN
F 1 "Arduino_Nano_V3" H 5475 5074 50  0000 C CNN
F 2 "Par2Ser:Arduino_Nano_V3" H 5450 4100 50  0001 C CNN
F 3 "https://content.arduino.cc/assets/NanoV3.3_sch.pdf" H 5450 4100 50  0001 C CNN
	1    5450 4100
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Network08 RN1
U 1 1 670EBA04
P 5150 5600
F 0 "RN1" H 5538 5646 50  0000 L CNN
F 1 "10k" H 5538 5555 50  0000 L CNN
F 2 "Resistor_THT:R_Array_SIP9" V 5625 5600 50  0001 C CNN
F 3 "http://www.vishay.com/docs/31509/csc.pdf" H 5150 5600 50  0001 C CNN
	1    5150 5600
	1    0    0    -1  
$EndComp
Text GLabel 3750 5400 0    50   Output ~ 0
STROBE
Text GLabel 5450 5800 3    50   BiDi ~ 0
D0
Text GLabel 4800 4450 0    50   Input ~ 0
STROBE
Text GLabel 5350 5800 3    50   BiDi ~ 0
D1
Text GLabel 5250 5800 3    50   BiDi ~ 0
D2
Text GLabel 5150 5800 3    50   BiDi ~ 0
D3
Text GLabel 5050 5800 3    50   BiDi ~ 0
D4
Text GLabel 4950 5800 3    50   BiDi ~ 0
D5
Text GLabel 4850 5800 3    50   BiDi ~ 0
D6
Text GLabel 4750 5800 3    50   BiDi ~ 0
D7
Text GLabel 6500 5800 3    50   Input ~ 0
ACK
Text GLabel 6800 5800 3    50   BiDi ~ 0
BUSY
Text GLabel 6700 5800 3    50   BiDi ~ 0
POUT
Text GLabel 6900 5800 3    50   BiDi ~ 0
SELECT
$Comp
L Device:R_Network08 RN2
U 1 1 6716E0A0
P 6600 5600
F 0 "RN2" H 6988 5646 50  0000 L CNN
F 1 "10k" H 6988 5555 50  0000 L CNN
F 2 "Resistor_THT:R_Array_SIP9" V 7075 5600 50  0001 C CNN
F 3 "http://www.vishay.com/docs/31509/csc.pdf" H 6600 5600 50  0001 C CNN
	1    6600 5600
	1    0    0    -1  
$EndComp
Text GLabel 4800 3450 0    50   Output ~ 0
TX0
Text GLabel 4800 3550 0    50   Input ~ 0
RX0
Text GLabel 4850 2500 3    50   Input ~ 0
TX0
Text GLabel 4950 2500 3    50   Output ~ 0
RX0
Text GLabel 2750 6350 0    50   Input ~ 0
GND
Text GLabel 7050 3900 0    50   Input ~ 0
RESET
$Comp
L Par2Ser:SC16IS750IBS,128 U3
U 1 1 671C3779
P 7850 4150
F 0 "U3" H 7850 4150 50  0000 L CNN
F 1 "SC16IS750IBS,128" H 7500 4550 50  0000 L CNN
F 2 "Par2Ser:HVQFN-24-1EP_4x4mm_P0.5mm_EP2.6x2.6mm_HandSolder" H 8500 5100 50  0001 L CNN
F 3 "http://www.nxp.com/docs/en/data-sheet/SC16IS740_750_760.pdf" H 8500 5000 50  0001 L CNN
	1    7850 4150
	1    0    0    -1  
$EndComp
Text GLabel 6650 4100 1    50   Input ~ 0
3V3
Text GLabel 7650 5100 3    50   Output ~ 0
MISO
Text GLabel 7550 5100 3    50   Input ~ 0
MOSI
Text GLabel 7050 4400 0    50   Input ~ 0
SS
Text GLabel 7750 5100 3    50   Input ~ 0
SCK
Text GLabel 7850 5100 3    50   Input ~ 0
GND
Text GLabel 8650 4100 2    50   Input ~ 0
GND
Text GLabel 7050 4000 0    50   Input ~ 0
7M
NoConn ~ 7050 4100
Text GLabel 4800 3950 0    50   Input ~ 0
IRQ
Wire Wire Line
	8050 5300 8050 5100
Text GLabel 8650 4000 2    50   Input ~ 0
DSR
Text GLabel 8650 3900 2    50   Output ~ 0
DTR
Text GLabel 7950 3000 1    50   Output ~ 0
RTS
Text GLabel 7850 3000 1    50   Input ~ 0
CTS
Text GLabel 7750 3000 1    50   Output ~ 0
TX
Text GLabel 7650 3000 1    50   Input ~ 0
RX
Text GLabel 7550 3000 1    50   Input ~ 0
GND
Text GLabel 5950 5800 3    50   Input ~ 0
IRQ
Text GLabel 7950 5100 3    50   Output ~ 0
IRQ
NoConn ~ 3750 5300
Text Label 3750 5300 2    50   ~ 0
Amiga_5V
Text GLabel 6600 5800 3    50   Input ~ 0
STROBE
$Comp
L Par2Ser:FT232RNL-REEL U2
U 1 1 67123320
P 10000 3900
F 0 "U2" H 10000 4765 50  0000 C CNN
F 1 "FT232RNL-REEL" H 10000 4674 50  0000 C CNN
F 2 "Package_SO:SSOP-28_5.3x10.2mm_P0.65mm" H 10500 4600 50  0001 L CNN
F 3 "https://ftdichip.com/wp-content/uploads/2022/12/DS_FT232RN.pdf" H 10500 4500 50  0001 L CNN
	1    10000 3900
	1    0    0    -1  
$EndComp
Text GLabel 9350 3700 0    50   Input ~ 0
TX
Text GLabel 9350 3300 0    50   Output ~ 0
RX
Text GLabel 9350 3500 0    50   Output ~ 0
CTS
Text GLabel 9350 4300 0    50   Input ~ 0
RTS
Text GLabel 10650 4500 2    50   BiDi ~ 0
USBDM
Text GLabel 10650 4600 2    50   BiDi ~ 0
USBDP
Text GLabel 11050 4100 2    50   Input ~ 0
VCC
Text GLabel 9050 3500 1    50   Input ~ 0
VCC
Text GLabel 10650 4200 2    50   Input ~ 0
RESET
Text GLabel 10650 4300 2    50   Input ~ 0
GND
Text GLabel 10650 4000 2    50   Input ~ 0
GND
Text GLabel 10650 3500 2    50   Input ~ 0
GND
Text GLabel 10650 3600 2    50   Input ~ 0
GND
NoConn ~ 10650 3700
Text GLabel 9350 4000 0    50   Output ~ 0
CTS
NoConn ~ 9350 3800
Text GLabel 9350 4100 0    50   Input ~ 0
DTR
Wire Wire Line
	9350 4200 9350 4100
Text GLabel 9350 3400 0    50   Output ~ 0
DSR
Text GLabel 8150 3000 1    50   Input ~ 0
DSR
$Comp
L Connector_Generic:Conn_01x02 JP1
U 1 1 670E5E9D
P 6550 2850
F 0 "JP1" V 6514 2662 50  0000 R CNN
F 1 "PinHeader for 2mm Shunt Jumper" V 6700 3500 50  0000 R CNN
F 2 "Connector_PinHeader_2.00mm:PinHeader_1x02_P2.00mm_Vertical" H 6550 2850 50  0001 C CNN
F 3 "~" H 6550 2850 50  0001 C CNN
	1    6550 2850
	0    -1   -1   0   
$EndComp
Text GLabel 6550 3050 3    50   Input ~ 0
Amiga_RESET
Wire Wire Line
	6150 3650 6650 3650
Wire Wire Line
	6650 3050 6650 3650
Text GLabel 7050 4300 0    50   Input ~ 0
GND
Wire Wire Line
	6650 4200 7050 4200
Wire Wire Line
	6650 4100 6650 4200
Connection ~ 6650 4200
NoConn ~ 6150 4750
NoConn ~ 10650 3300
NoConn ~ 10650 3400
$Comp
L Device:C_Small C5
U 1 1 67141D33
P 9050 3700
F 0 "C5" H 8900 3750 50  0000 C CNN
F 1 "0.1uF" H 8850 3650 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 9050 3700 50  0001 C CNN
F 3 "~" H 9050 3700 50  0001 C CNN
	1    9050 3700
	1    0    0    -1  
$EndComp
Wire Wire Line
	9350 3600 9050 3600
Wire Wire Line
	9050 3600 9050 3500
Connection ~ 9050 3600
Text GLabel 9050 3800 3    50   Input ~ 0
GND
Wire Wire Line
	5950 5800 5950 5700
Text GLabel 4750 5400 1    50   Input ~ 0
VCC
Text GLabel 6200 5400 1    50   Input ~ 0
VCC
Text GLabel 5950 5400 1    50   Input ~ 0
3V3
Wire Wire Line
	5950 5400 5950 5500
Text GLabel 10650 3800 2    50   Input ~ 0
TXLED
Text GLabel 10650 3900 2    50   Input ~ 0
RXLED
$Comp
L Par2Ser:Abracon-ASFL1-7.3728MHZ-EK-T X1
U 1 1 6719B2CF
P 9300 5600
F 0 "X1" H 9600 5750 50  0000 L CNN
F 1 "Abracon-ASFL1-7.3728MHZ-EK-T" H 9450 5900 50  0000 L CNN
F 2 "Oscillator:Oscillator_SMD_SeikoEpson_SG8002LB-4Pin_5.0x3.2mm" H 10000 5250 50  0001 C CNN
F 3 "" H 9200 5600 50  0001 C CNN
	1    9300 5600
	1    0    0    -1  
$EndComp
Text GLabel 8900 5300 0    50   Input ~ 0
3V3
Wire Wire Line
	8900 5300 9000 5300
Connection ~ 9100 5300
Wire Wire Line
	9100 5300 9300 5300
Text GLabel 9100 5100 1    50   Input ~ 0
GND
Text GLabel 9300 5900 3    50   Input ~ 0
GND
Text GLabel 9600 5600 2    50   Output ~ 0
7M
Wire Wire Line
	9000 5600 9000 5300
Connection ~ 9000 5300
Wire Wire Line
	9000 5300 9100 5300
Text GLabel 1750 3900 0    50   Input ~ 0
SS
$Comp
L Transistor_BJT:BC857 Q1
U 1 1 671F3028
P 2400 3900
F 0 "Q1" H 2591 3854 50  0000 L CNN
F 1 "BC857" H 2591 3945 50  0000 L CNN
F 2 "Package_TO_SOT_SMD:SOT-23_Handsoldering" H 2600 3825 50  0001 L CIN
F 3 "https://www.onsemi.com/pub/Collateral/BC860-D.pdf" H 2400 3900 50  0001 L CNN
	1    2400 3900
	1    0    0    1   
$EndComp
Wire Wire Line
	1750 3900 1900 3900
Wire Wire Line
	2100 3900 2200 3900
Wire Wire Line
	2400 3500 2500 3500
Wire Wire Line
	2500 3500 2500 3700
Text GLabel 2500 4900 3    50   Input ~ 0
GND
Wire Wire Line
	2500 4900 2500 4800
Wire Notes Line
	1550 5300 2950 5300
Wire Notes Line
	2950 3250 2950 5300
Wire Notes Line
	1550 3250 1550 5300
Text Label 2100 3900 0    50   ~ 0
Base
Text Label 2500 4150 0    50   ~ 0
Collector
Wire Wire Line
	10650 4100 11050 4100
Wire Wire Line
	11050 4100 11050 3950
Text GLabel 11050 3750 1    50   Input ~ 0
GND
$Comp
L Device:C_Small C4
U 1 1 67247829
P 11050 4650
F 0 "C4" H 11200 4750 50  0000 C CNN
F 1 "0.1uF" H 11250 4850 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 11050 4650 50  0001 C CNN
F 3 "~" H 11050 4650 50  0001 C CNN
	1    11050 4650
	-1   0    0    1   
$EndComp
Wire Wire Line
	10650 4400 11050 4400
Wire Wire Line
	11050 4400 11050 4550
Text GLabel 11050 4750 3    50   Input ~ 0
GND
$Comp
L Connector_Generic:Conn_01x02 J2
U 1 1 6725E5A4
P 4850 2300
F 0 "J2" V 4814 2112 50  0000 R CNN
F 1 "Arduino UART header" V 5100 2400 50  0000 R CNN
F 2 "Par2Ser:PinSocket_1x02_P2.54mm_SMD" H 4850 2300 50  0001 C CNN
F 3 "~" H 4850 2300 50  0001 C CNN
	1    4850 2300
	0    -1   -1   0   
$EndComp
NoConn ~ 8050 3000
NoConn ~ 8050 5300
NoConn ~ 8650 4400
NoConn ~ 8650 4300
NoConn ~ 8650 4200
NoConn ~ 9350 4400
NoConn ~ 9350 4500
NoConn ~ 9350 4600
$Comp
L Connector:USB_C_Receptacle_USB2.0 J3
U 1 1 6728305B
P 3650 6350
F 0 "J3" V 3711 7080 50  0000 L CNN
F 1 "USB_C_Receptacle_USB2.0" V 3802 7080 50  0000 L CNN
F 2 "Connector_USB:USB_C_Receptacle_HRO_TYPE-C-31-M-12" H 3800 6350 50  0001 C CNN
F 3 "https://www.usb.org/sites/default/files/documents/usb_type-c.zip" H 3800 6350 50  0001 C CNN
	1    3650 6350
	0    1    1    0   
$EndComp
Wire Wire Line
	2750 6350 2750 6050
Text GLabel 3500 7100 2    50   BiDi ~ 0
USBDM
Text GLabel 3300 7100 0    50   BiDi ~ 0
USBDP
Connection ~ 2750 6350
NoConn ~ 3050 6950
NoConn ~ 3150 6950
Wire Wire Line
	2750 6350 2750 7450
$Comp
L Device:R_Small R7
U 1 1 6122071E
P 4050 7250
F 0 "R7" H 3950 7250 50  0000 C CNN
F 1 "5k1" V 4000 7000 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric_Pad1.30x1.75mm_HandSolder" H 4050 7250 50  0001 C CNN
F 3 "~" H 4050 7250 50  0001 C CNN
	1    4050 7250
	-1   0    0    1   
$EndComp
$Comp
L Device:R_Small R8
U 1 1 6121F8D5
P 3950 7250
F 0 "R8" H 4050 7250 50  0000 C CNN
F 1 "5k1" V 4000 7000 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric_Pad1.30x1.75mm_HandSolder" H 3950 7250 50  0001 C CNN
F 3 "~" H 3950 7250 50  0001 C CNN
	1    3950 7250
	-1   0    0    1   
$EndComp
$Comp
L Device:CP_Small C1
U 1 1 67312C43
P 4450 7050
F 0 "C1" H 4550 7050 50  0000 L CNN
F 1 "100uF Radial Pitch_2.5mm" H 4350 6950 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D5.0mm_P2.50mm" H 4450 7050 50  0001 C CNN
F 3 "~" H 4450 7050 50  0001 C CNN
	1    4450 7050
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 6950 4450 6950
$Comp
L Device:LED D3
U 1 1 67168DF9
P 6150 7100
F 0 "D3" V 6150 7050 50  0000 R CNN
F 1 "TX_LED" V 6350 7250 50  0000 R CNN
F 2 "Diode_SMD:D_0603_1608Metric_Pad1.05x0.95mm_HandSolder" H 6150 7100 50  0001 C CNN
F 3 "~" H 6150 7100 50  0001 C CNN
	1    6150 7100
	0    -1   -1   0   
$EndComp
$Comp
L Device:LED D4
U 1 1 6716E917
P 6400 7100
F 0 "D4" V 6400 7050 50  0000 R CNN
F 1 "RX_LED" V 6600 7150 50  0000 R CNN
F 2 "Diode_SMD:D_0603_1608Metric_Pad1.05x0.95mm_HandSolder" H 6400 7100 50  0001 C CNN
F 3 "~" H 6400 7100 50  0001 C CNN
	1    6400 7100
	0    -1   -1   0   
$EndComp
Text GLabel 6050 7700 0    50   Output ~ 0
TXLED
Text GLabel 6500 7700 2    50   Output ~ 0
RXLED
Wire Wire Line
	6400 6950 6150 6950
$Comp
L Device:R_Small R3
U 1 1 67180031
P 6150 7500
F 0 "R3" H 6250 7500 50  0000 C CNN
F 1 "1k 0805" V 6350 7300 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 6150 7500 50  0001 C CNN
F 3 "~" H 6150 7500 50  0001 C CNN
	1    6150 7500
	-1   0    0    1   
$EndComp
$Comp
L Device:R_Small R4
U 1 1 67181F69
P 6400 7500
F 0 "R4" H 6300 7500 50  0000 C CNN
F 1 "1k 0805" V 6200 7300 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 6400 7500 50  0001 C CNN
F 3 "~" H 6400 7500 50  0001 C CNN
	1    6400 7500
	-1   0    0    1   
$EndComp
Wire Wire Line
	6150 7250 6150 7400
Wire Wire Line
	6150 7600 6150 7700
Wire Wire Line
	6400 7250 6400 7400
Wire Wire Line
	6400 7600 6400 7700
Wire Wire Line
	6400 7700 6500 7700
Wire Wire Line
	6050 7700 6150 7700
$Comp
L Device:Ferrite_Bead_Small FB1
U 1 1 67177232
P 5300 6950
F 0 "FB1" V 5063 6950 50  0000 C CNN
F 1 "600" V 5154 6950 50  0000 C CNN
F 2 "Inductor_SMD:L_0805_2012Metric_Pad1.15x1.40mm_HandSolder" V 5230 6950 50  0001 C CNN
F 3 "~" H 5300 6950 50  0001 C CNN
	1    5300 6950
	0    1    1    0   
$EndComp
Text GLabel 5900 6950 1    50   Input ~ 0
VCC
Wire Wire Line
	5400 6950 5750 6950
Connection ~ 6150 6950
Wire Wire Line
	5200 6950 4450 6950
Connection ~ 4450 6950
Text Label 4800 6950 0    50   ~ 0
VBUS
Text Label 4050 7000 0    50   ~ 0
CC1
Text Label 3950 7000 2    50   ~ 0
CC2
Wire Wire Line
	3950 6950 3950 7150
Wire Wire Line
	4050 6950 4050 7150
Wire Wire Line
	4450 7450 4050 7450
Wire Wire Line
	4450 7450 4450 7150
Wire Wire Line
	3950 7350 3950 7450
Connection ~ 3950 7450
Wire Wire Line
	3950 7450 3500 7450
Wire Wire Line
	4050 7350 4050 7450
Connection ~ 4050 7450
Wire Wire Line
	4050 7450 3950 7450
Wire Wire Line
	3450 6950 3550 6950
Wire Wire Line
	3650 6950 3750 6950
Wire Wire Line
	3300 6950 3450 6950
Wire Wire Line
	3300 6950 3300 7150
Connection ~ 3450 6950
Wire Wire Line
	3500 7000 3650 7000
Wire Wire Line
	3650 7000 3650 6950
Wire Wire Line
	3500 7000 3500 7150
Connection ~ 3650 6950
Wire Wire Line
	3300 7350 3300 7450
Connection ~ 3300 7450
Wire Wire Line
	3300 7450 2750 7450
Wire Wire Line
	3500 7350 3500 7450
Connection ~ 3500 7450
Wire Wire Line
	3500 7450 3300 7450
$Comp
L Device:C_Small C8
U 1 1 671F8752
P 3300 7250
F 0 "C8" H 3450 7250 50  0000 C CNN
F 1 "47pF" H 3500 7350 50  0000 C CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 3300 7250 50  0001 C CNN
F 3 "~" H 3300 7250 50  0001 C CNN
	1    3300 7250
	-1   0    0    1   
$EndComp
$Comp
L Device:C_Small C9
U 1 1 671FEDD5
P 3500 7250
F 0 "C9" H 3350 7250 50  0000 C CNN
F 1 "47pF" H 3350 7350 50  0000 C CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 3500 7250 50  0001 C CNN
F 3 "~" H 3500 7250 50  0001 C CNN
	1    3500 7250
	-1   0    0    1   
$EndComp
$Comp
L Device:C_Small C2
U 1 1 6722133F
P 5750 7050
F 0 "C2" H 5600 7050 50  0000 C CNN
F 1 "4.7uF (0805)" H 5750 6950 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 5750 7050 50  0001 C CNN
F 3 "~" H 5750 7050 50  0001 C CNN
	1    5750 7050
	1    0    0    -1  
$EndComp
Connection ~ 5750 6950
Wire Wire Line
	5750 6950 6150 6950
Wire Wire Line
	4450 7450 5750 7450
Wire Wire Line
	5750 7450 5750 7150
Connection ~ 4450 7450
$Comp
L Connector_Generic:Conn_01x02 J4
U 1 1 67261FA5
P 5250 2300
F 0 "J4" V 5214 2112 50  0001 R CNN
F 1 "Conn_01x02" V 5123 2112 50  0001 R CNN
F 2 "Par2Ser:PinSocket_1x02_P2.54mm_SMD" H 5250 2300 50  0001 C CNN
F 3 "~" H 5250 2300 50  0001 C CNN
	1    5250 2300
	0    -1   -1   0   
$EndComp
Text GLabel 5250 2500 3    50   Input ~ 0
GND
Text GLabel 5350 2500 3    50   Input ~ 0
GND
Text Notes 4800 2200 0    50   ~ 0
Top
Text Notes 5200 2200 0    50   ~ 0
Bottom
$EndSCHEMATC
