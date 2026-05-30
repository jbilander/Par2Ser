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
Text GLabel 6400 1650 1    50   Input ~ 0
GND
Text GLabel 5000 2850 0    50   Input ~ 0
GND
Text GLabel 6700 2850 2    50   BiDi ~ 0
BUSY_B9
Text GLabel 6700 2750 2    50   BiDi ~ 0
POUT_B10
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
Text GLabel 6700 2650 2    50   BiDi ~ 0
SELECT_B11
NoConn ~ 3750 3300
NoConn ~ 3750 3500
NoConn ~ 3750 5100
Text GLabel 3800 2450 0    50   Input ~ 0
VCC
NoConn ~ 3750 3100
Text GLabel 1800 2200 0    50   Input ~ 0
3V3
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
F 1 "10k" H 2050 2300 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 2000 2300 50  0001 C CNN
F 3 "~" H 2000 2300 50  0001 C CNN
	1    2000 2300
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R1
U 1 1 5EB9CA00
P 2250 4050
F 0 "R1" H 2150 4050 50  0000 C CNN
F 1 "1k" H 2400 4050 50  0000 C CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 2250 4050 50  0001 C CNN
F 3 "~" H 2250 4050 50  0001 C CNN
	1    2250 4050
	1    0    0    -1  
$EndComp
$Comp
L Device:LED D1
U 1 1 5EBA7223
P 2250 4400
F 0 "D1" V 2250 4600 50  0000 R CNN
F 1 "Activity LED" V 2350 4950 50  0000 R CNN
F 2 "LED_THT:LED_Rectangular_W5.0mm_H2.0mm" H 2250 4400 50  0001 C CNN
F 3 "~" H 2250 4400 50  0001 C CNN
	1    2250 4400
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
Text GLabel 6700 2950 2    50   Output ~ 0
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
Wire Wire Line
	2250 4150 2250 4250
Wire Notes Line
	2950 3250 1550 3250
$Comp
L Device:R_Small R6
U 1 1 610DADE6
P 6850 5450
F 0 "R6" H 6950 5450 50  0000 C CNN
F 1 "330" H 6650 5450 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 6850 5450 50  0001 C CNN
F 3 "~" H 6850 5450 50  0001 C CNN
	1    6850 5450
	-1   0    0    1   
$EndComp
$Comp
L Device:C_Small C10
U 1 1 611D1D5F
P 8500 1250
F 0 "C10" H 8650 1250 50  0000 C CNN
F 1 "0.1uF" H 8550 1400 50  0000 C CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 8500 1250 50  0001 C CNN
F 3 "~" H 8500 1250 50  0001 C CNN
	1    8500 1250
	-1   0    0    1   
$EndComp
$Comp
L Device:C_Small C8
U 1 1 612089E2
P 7900 1250
F 0 "C8" H 7750 1250 50  0000 C CNN
F 1 "0.1uF" H 7850 1100 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 7900 1250 50  0001 C CNN
F 3 "~" H 7900 1250 50  0001 C CNN
	1    7900 1250
	1    0    0    -1  
$EndComp
Text GLabel 3750 5400 0    50   Output ~ 0
STROBE
Text GLabel 6850 5650 3    50   Input ~ 0
STROBE
Text GLabel 2750 6350 0    50   Input ~ 0
GND
NoConn ~ 3750 5300
Text Label 3750 5300 2    50   ~ 0
Amiga_5V
$Comp
L Device:C_Small C7
U 1 1 67141D33
P 6050 7200
F 0 "C7" H 5900 7200 50  0000 C CNN
F 1 "0.1uF" H 5950 7100 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 6050 7200 50  0001 C CNN
F 3 "~" H 6050 7200 50  0001 C CNN
	1    6050 7200
	1    0    0    -1  
$EndComp
Text GLabel 6300 1650 1    50   Input ~ 0
TXLED
Text GLabel 6200 1650 1    50   Input ~ 0
RXLED
Text GLabel 2250 4650 3    50   Input ~ 0
GND
Wire Wire Line
	2250 4650 2250 4550
Wire Notes Line
	1550 5300 2950 5300
Wire Notes Line
	2950 3250 2950 5300
Wire Notes Line
	1550 3250 1550 5300
Text GLabel 7700 1350 0    50   Input ~ 0
GND
$Comp
L Device:C_Small C6
U 1 1 67247829
P 4950 7200
F 0 "C6" H 5100 7200 50  0000 C CNN
F 1 "0.1uF" H 5050 7300 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 4950 7200 50  0001 C CNN
F 3 "~" H 4950 7200 50  0001 C CNN
	1    4950 7200
	-1   0    0    1   
$EndComp
$Comp
L Connector:USB_C_Receptacle_USB2.0 J2
U 1 1 6728305B
P 3650 6350
F 0 "J2" V 3711 7080 50  0000 L CNN
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
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 4050 7250 50  0001 C CNN
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
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 3950 7250 50  0001 C CNN
F 3 "~" H 3950 7250 50  0001 C CNN
	1    3950 7250
	-1   0    0    1   
$EndComp
$Comp
L Device:LED D3
U 1 1 67168DF9
P 2150 1500
F 0 "D3" V 2150 1450 50  0000 R CNN
F 1 "TX_LED" V 2350 1650 50  0000 R CNN
F 2 "Diode_SMD:D_0603_1608Metric_Pad1.05x0.95mm_HandSolder" H 2150 1500 50  0001 C CNN
F 3 "~" H 2150 1500 50  0001 C CNN
	1    2150 1500
	0    -1   -1   0   
$EndComp
$Comp
L Device:LED D4
U 1 1 6716E917
P 2400 1500
F 0 "D4" V 2400 1450 50  0000 R CNN
F 1 "RX_LED" V 2600 1550 50  0000 R CNN
F 2 "Diode_SMD:D_0603_1608Metric_Pad1.05x0.95mm_HandSolder" H 2400 1500 50  0001 C CNN
F 3 "~" H 2400 1500 50  0001 C CNN
	1    2400 1500
	0    -1   -1   0   
$EndComp
Text GLabel 2050 750  0    50   Input ~ 0
TXLED
Text GLabel 2500 750  2    50   Input ~ 0
RXLED
$Comp
L Device:R_Small R3
U 1 1 67180031
P 2150 1100
F 0 "R3" H 2250 1100 50  0000 C CNN
F 1 "1k 0805" V 2350 900 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 2150 1100 50  0001 C CNN
F 3 "~" H 2150 1100 50  0001 C CNN
	1    2150 1100
	-1   0    0    1   
$EndComp
$Comp
L Device:R_Small R4
U 1 1 67181F69
P 2400 1100
F 0 "R4" H 2300 1100 50  0000 C CNN
F 1 "1k 0805" V 2200 900 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 2400 1100 50  0001 C CNN
F 3 "~" H 2400 1100 50  0001 C CNN
	1    2400 1100
	-1   0    0    1   
$EndComp
Wire Wire Line
	2150 1650 2150 1750
Wire Wire Line
	2400 1650 2400 1750
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
Text GLabel 6050 6950 1    50   Input ~ 0
VCC
Wire Wire Line
	5400 6950 5650 6950
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
L Device:C_Small C4
U 1 1 671F8752
P 3300 7250
F 0 "C4" H 3450 7250 50  0000 C CNN
F 1 "47pF" H 3500 7350 50  0000 C CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 3300 7250 50  0001 C CNN
F 3 "~" H 3300 7250 50  0001 C CNN
	1    3300 7250
	-1   0    0    1   
$EndComp
$Comp
L Device:C_Small C5
U 1 1 671FEDD5
P 3500 7250
F 0 "C5" H 3350 7250 50  0000 C CNN
F 1 "47pF" H 3350 7350 50  0000 C CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 3500 7250 50  0001 C CNN
F 3 "~" H 3500 7250 50  0001 C CNN
	1    3500 7250
	-1   0    0    1   
$EndComp
$Comp
L Device:C_Small C2
U 1 1 6722133F
P 5650 7200
F 0 "C2" H 5500 7200 50  0000 C CNN
F 1 "4.7uF" H 5550 7100 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 5650 7200 50  0001 C CNN
F 3 "~" H 5650 7200 50  0001 C CNN
	1    5650 7200
	1    0    0    -1  
$EndComp
Text GLabel 6700 3150 2    50   Input ~ 0
GND
Text GLabel 5300 4250 3    50   Input ~ 0
GND
Text GLabel 5000 2450 0    50   Input ~ 0
TDI
Text GLabel 6700 2550 2    50   Output ~ 0
TDO
Text GLabel 6700 3550 2    50   Input ~ 0
TMS
Text GLabel 5000 3450 0    50   Input ~ 0
TCK
Text GLabel 5000 2950 0    50   Input ~ 0
3V3
Text GLabel 6700 3050 2    50   Input ~ 0
3V3
Text GLabel 5000 3550 0    50   Input ~ 0
3V3
Text GLabel 6700 2450 2    50   Input ~ 0
3V3
Text GLabel 6000 4250 3    50   BiDi ~ 0
D0_B0
Text GLabel 6100 4250 3    50   BiDi ~ 0
D1_B1
Text GLabel 6200 4250 3    50   BiDi ~ 0
D2_B2
Text GLabel 6300 4250 3    50   BiDi ~ 0
D3_B3
Text GLabel 6400 4250 3    50   BiDi ~ 0
D4_B4
Text GLabel 6700 3450 2    50   BiDi ~ 0
D5_B5
Text GLabel 6700 3350 2    50   BiDi ~ 0
D6_B6
Text GLabel 6700 3250 2    50   BiDi ~ 0
D7_B7
Text GLabel 5800 4250 3    50   Input ~ 0
RESET
Text GLabel 3750 4900 0    50   Output ~ 0
RESET
Text GLabel 5000 3250 0    50   BiDi ~ 0
D0_3V3
Text GLabel 5600 1650 1    50   BiDi ~ 0
D1_3V3
Text GLabel 5000 3050 0    50   BiDi ~ 0
D2_3V3
Text GLabel 5000 2550 0    50   BiDi ~ 0
D3_3V3
Text GLabel 5000 3150 0    50   BiDi ~ 0
D4_3V3
Text GLabel 5000 2750 0    50   BiDi ~ 0
D5_3V3
Text GLabel 5000 2650 0    50   BiDi ~ 0
D6_3V3
Text GLabel 5500 1650 1    50   BiDi ~ 0
D7_3V3
$Comp
L Par2Ser:FT240XS-R U2
U 1 1 6A22D05C
P 9150 3250
F 0 "U2" H 9150 4065 50  0000 C CNN
F 1 "FT240XS-R" H 9150 3974 50  0000 C CNN
F 2 "Package_SO:SSOP-24_3.9x8.7mm_P0.635mm" H 8900 3950 50  0001 L CNN
F 3 "http://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT240X.pdf" H 9650 3800 50  0001 L CNN
	1    9150 3250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Pack04 RN5
U 1 1 6A265F89
P 8950 5450
F 0 "RN5" H 9138 5496 50  0000 L CNN
F 1 "330" H 9138 5405 50  0000 L CNN
F 2 "Resistor_SMD:R_Array_Convex_4x0603" V 9225 5450 50  0001 C CNN
F 3 "~" H 8950 5450 50  0001 C CNN
	1    8950 5450
	1    0    0    -1  
$EndComp
Text GLabel 4950 5650 3    50   BiDi ~ 0
D0_B0
Text GLabel 6050 5250 1    50   Input ~ 0
3V3
$Comp
L Device:R_Network04 RN2
U 1 1 6A24EE3C
P 6250 5450
F 0 "RN2" H 6438 5496 50  0000 L CNN
F 1 "10k" H 6438 5405 50  0000 L CNN
F 2 "Resistor_THT:R_Array_SIP5" V 6525 5450 50  0001 C CNN
F 3 "http://www.vishay.com/docs/31509/csc.pdf" H 6250 5450 50  0001 C CNN
	1    6250 5450
	1    0    0    -1  
$EndComp
Text GLabel 4950 5250 1    50   Input ~ 0
3V3
Text GLabel 6050 5650 3    50   BiDi ~ 0
SELECT_B11
Text GLabel 6150 5650 3    50   BiDi ~ 0
POUT_B10
Text GLabel 6250 5650 3    50   BiDi ~ 0
BUSY_B9
Text GLabel 5650 5650 3    50   BiDi ~ 0
D7_B7
Text GLabel 5550 5650 3    50   BiDi ~ 0
D6_B6
Text GLabel 5450 5650 3    50   BiDi ~ 0
D5_B5
Text GLabel 5350 5650 3    50   BiDi ~ 0
D4_B4
Text GLabel 5250 5650 3    50   BiDi ~ 0
D3_B3
Text GLabel 5150 5650 3    50   BiDi ~ 0
D2_B2
Text GLabel 5050 5650 3    50   BiDi ~ 0
D1_B1
$Comp
L Device:R_Network08 RN1
U 1 1 670EBA04
P 5350 5450
F 0 "RN1" H 5738 5496 50  0000 L CNN
F 1 "10k" H 5738 5405 50  0000 L CNN
F 2 "Resistor_THT:R_Array_SIP9" V 5825 5450 50  0001 C CNN
F 3 "http://www.vishay.com/docs/31509/csc.pdf" H 5350 5450 50  0001 C CNN
	1    5350 5450
	1    0    0    -1  
$EndComp
Text GLabel 9050 5250 1    50   BiDi ~ 0
D0
Text GLabel 9050 5650 3    50   BiDi ~ 0
D0_B0
Text GLabel 8750 5650 3    50   BiDi ~ 0
D3_B3
Text GLabel 8850 5650 3    50   BiDi ~ 0
D2_B2
Text GLabel 8950 5650 3    50   BiDi ~ 0
D1_B1
Text GLabel 8950 5250 1    50   BiDi ~ 0
D1
Text GLabel 8850 5250 1    50   BiDi ~ 0
D2
Text GLabel 8750 5250 1    50   BiDi ~ 0
D3
$Comp
L Device:R_Pack04 RN4
U 1 1 6A289A33
P 8250 5450
F 0 "RN4" H 8438 5496 50  0000 L CNN
F 1 "330" H 8438 5405 50  0000 L CNN
F 2 "Resistor_SMD:R_Array_Convex_4x0603" V 8525 5450 50  0001 C CNN
F 3 "~" H 8250 5450 50  0001 C CNN
	1    8250 5450
	1    0    0    -1  
$EndComp
Text GLabel 8350 5650 3    50   BiDi ~ 0
D4_B4
Text GLabel 8250 5650 3    50   BiDi ~ 0
D5_B5
Text GLabel 8150 5650 3    50   BiDi ~ 0
D6_B6
Text GLabel 8050 5650 3    50   BiDi ~ 0
D7_B7
Text GLabel 8350 5250 1    50   BiDi ~ 0
D4
Text GLabel 8250 5250 1    50   BiDi ~ 0
D5
Text GLabel 8150 5250 1    50   BiDi ~ 0
D6
Text GLabel 8050 5250 1    50   BiDi ~ 0
D7
$Comp
L Device:R_Pack04 RN3
U 1 1 6A2B099B
P 7500 5450
F 0 "RN3" H 7688 5496 50  0000 L CNN
F 1 "330" H 7688 5405 50  0000 L CNN
F 2 "Resistor_SMD:R_Array_Convex_4x0603" V 7775 5450 50  0001 C CNN
F 3 "~" H 7500 5450 50  0001 C CNN
	1    7500 5450
	1    0    0    -1  
$EndComp
Text GLabel 6350 5650 3    50   Input ~ 0
TMS
Text GLabel 7400 5250 1    50   BiDi ~ 0
POUT
Text GLabel 7500 5250 1    50   BiDi ~ 0
BUSY
Text GLabel 7300 5250 1    50   BiDi ~ 0
SELECT
NoConn ~ 7600 5250
NoConn ~ 7600 5650
Text GLabel 7300 5650 3    50   BiDi ~ 0
SELECT_B11
Text GLabel 7400 5650 3    50   BiDi ~ 0
POUT_B10
Text GLabel 7500 5650 3    50   BiDi ~ 0
BUSY_B9
Wire Wire Line
	6850 5350 6850 4850
Wire Wire Line
	6850 4850 5900 4850
Wire Wire Line
	5900 4850 5900 4250
Text Label 6850 4850 0    50   ~ 0
STRB
$Comp
L Device:C_Small C9
U 1 1 5EB53531
P 8200 1250
F 0 "C9" H 8050 1250 50  0000 C CNN
F 1 "0.1uF" H 8150 1100 50  0000 C CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 8200 1250 50  0001 C CNN
F 3 "~" H 8200 1250 50  0001 C CNN
	1    8200 1250
	1    0    0    -1  
$EndComp
Text GLabel 9800 2700 2    50   BiDi ~ 0
D0_3V3
Text GLabel 8500 3000 0    50   BiDi ~ 0
D1_3V3
Text GLabel 8500 2800 0    50   BiDi ~ 0
D2_3V3
Text GLabel 8500 3500 0    50   BiDi ~ 0
D3_3V3
Text GLabel 8500 2700 0    50   BiDi ~ 0
D4_3V3
Text GLabel 8500 3300 0    50   BiDi ~ 0
D5_3V3
Text GLabel 8500 3400 0    50   BiDi ~ 0
D6_3V3
Text GLabel 8500 3100 0    50   BiDi ~ 0
D7_3V3
Text GLabel 8500 3200 0    50   Input ~ 0
GND
Text GLabel 9800 3200 2    50   Input ~ 0
GND
Text GLabel 10450 3700 2    50   BiDi ~ 0
USBDM
Text GLabel 10450 3800 2    50   BiDi ~ 0
USBDP
Text GLabel 9800 3600 2    50   Input ~ 0
3V3
Text GLabel 9800 3300 2    50   Input ~ 0
3V3
Text GLabel 8500 2900 0    50   Input ~ 0
3V3
Text Label 10050 3400 0    50   ~ 0
VCORE
Text GLabel 10850 2250 0    50   Output ~ 0
CLK12M
Text GLabel 6100 1650 1    50   BiDi ~ 0
CBUS6
Text GLabel 9800 2900 2    50   BiDi ~ 0
CBUS6
$Comp
L Device:R_Small R5
U 1 1 6A380E9A
P 10850 2800
F 0 "R5" V 10654 2800 50  0000 C CNN
F 1 "33" V 10745 2800 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 10850 2800 50  0001 C CNN
F 3 "~" H 10850 2800 50  0001 C CNN
	1    10850 2800
	0    1    1    0   
$EndComp
Text Label 10200 2800 0    50   ~ 0
CLK12M_RAW
Wire Wire Line
	9800 2800 10750 2800
Wire Wire Line
	10950 2800 11050 2800
Wire Wire Line
	11050 2800 11050 2250
Wire Wire Line
	11050 2250 10850 2250
Text GLabel 5800 1650 1    50   Input ~ 0
CLK12M
Text GLabel 8100 3900 3    50   Input ~ 0
3V3
Text GLabel 9800 3500 2    50   Input ~ 0
3V3
Wire Wire Line
	10050 3400 9800 3400
NoConn ~ 10050 3400
Wire Wire Line
	6850 5550 6850 5650
Text GLabel 8500 3800 0    50   Input ~ 0
WR
Text GLabel 5300 1650 1    50   Output ~ 0
WR
Text GLabel 8500 3700 0    50   Input ~ 0
RD
Text GLabel 5400 1650 1    50   Output ~ 0
RD
Text GLabel 9800 3000 2    50   Output ~ 0
RXF
Text GLabel 9800 3100 2    50   Output ~ 0
TXE
Text GLabel 5400 4250 3    50   Input ~ 0
RXF
Text GLabel 5500 4250 3    50   Input ~ 0
TXE
Text GLabel 2150 3600 0    50   Input ~ 0
ACT_LED
Wire Wire Line
	2250 3600 2150 3600
Wire Wire Line
	2250 3600 2250 3950
Text GLabel 5600 4250 3    50   Output ~ 0
ACT_LED
Text GLabel 2150 1750 3    50   Input ~ 0
GND
Text GLabel 2400 1750 3    50   Input ~ 0
GND
Wire Wire Line
	2050 750  2150 750 
Wire Wire Line
	2150 750  2150 1000
Wire Wire Line
	2500 750  2400 750 
Wire Wire Line
	2400 750  2400 1000
Text GLabel 7700 1150 0    50   Input ~ 0
3V3
Wire Wire Line
	7700 1150 7900 1150
Wire Wire Line
	7700 1350 7900 1350
NoConn ~ 5000 3350
NoConn ~ 6000 1650
NoConn ~ 5700 4250
$Comp
L Device:C_Small C1
U 1 1 6A4BF462
P 4550 7200
F 0 "C1" H 4400 7200 50  0000 C CNN
F 1 "4.7uF" H 4450 7100 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 4550 7200 50  0001 C CNN
F 3 "~" H 4550 7200 50  0001 C CNN
	1    4550 7200
	1    0    0    -1  
$EndComp
Wire Wire Line
	4050 7450 4550 7450
Wire Wire Line
	4250 6950 4550 6950
Wire Wire Line
	4550 7100 4550 6950
Connection ~ 4550 6950
Wire Wire Line
	4550 6950 4950 6950
Wire Wire Line
	4550 7300 4550 7450
Connection ~ 4550 7450
Wire Wire Line
	4550 7450 4950 7450
Wire Wire Line
	4950 7300 4950 7450
Connection ~ 4950 7450
Wire Wire Line
	4950 7450 5650 7450
Wire Wire Line
	4950 7100 4950 6950
Connection ~ 4950 6950
Wire Wire Line
	4950 6950 5200 6950
Wire Wire Line
	5650 6950 5650 7100
Connection ~ 5650 6950
Wire Wire Line
	5650 7300 5650 7450
Connection ~ 5650 7450
Wire Wire Line
	6050 7100 6050 6950
Wire Wire Line
	5650 6950 6050 6950
Wire Wire Line
	6050 7450 6050 7300
Wire Wire Line
	5650 7450 6050 7450
Wire Wire Line
	7900 1150 8200 1150
Connection ~ 7900 1150
Connection ~ 8200 1150
Wire Wire Line
	8200 1150 8500 1150
Wire Wire Line
	7900 1350 8200 1350
Connection ~ 7900 1350
Connection ~ 8200 1350
Wire Wire Line
	8200 1350 8500 1350
Wire Wire Line
	2150 1200 2150 1350
Wire Wire Line
	2400 1200 2400 1350
$Comp
L Device:R_Small R10
U 1 1 6A5B4EB2
P 10150 3800
F 0 "R10" V 10050 3800 50  0000 C CNN
F 1 "27" V 10050 3600 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 10150 3800 50  0001 C CNN
F 3 "~" H 10150 3800 50  0001 C CNN
	1    10150 3800
	0    -1   -1   0   
$EndComp
$Comp
L Device:R_Small R9
U 1 1 6A5B195C
P 10150 3700
F 0 "R9" V 10250 3700 50  0000 C CNN
F 1 "27" V 10250 3500 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 10150 3700 50  0001 C CNN
F 3 "~" H 10150 3700 50  0001 C CNN
	1    10150 3700
	0    -1   -1   0   
$EndComp
Wire Wire Line
	10050 3700 9800 3700
Wire Wire Line
	10050 3800 9800 3800
Wire Wire Line
	10450 3700 10250 3700
Wire Wire Line
	10450 3800 10250 3800
$Comp
L Device:C_Small C11
U 1 1 6A632E26
P 8800 1250
F 0 "C11" H 8950 1250 50  0000 C CNN
F 1 "0.1uF" H 8850 1400 50  0000 C CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 8800 1250 50  0001 C CNN
F 3 "~" H 8800 1250 50  0001 C CNN
	1    8800 1250
	-1   0    0    1   
$EndComp
Wire Wire Line
	8800 1150 8500 1150
Connection ~ 8500 1150
Wire Wire Line
	8800 1350 8500 1350
Connection ~ 8500 1350
$Comp
L Device:C_Small C12
U 1 1 6A647103
P 9100 1250
F 0 "C12" H 9250 1250 50  0000 C CNN
F 1 "0.1uF" H 9150 1400 50  0000 C CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 9100 1250 50  0001 C CNN
F 3 "~" H 9100 1250 50  0001 C CNN
	1    9100 1250
	-1   0    0    1   
$EndComp
Wire Wire Line
	8800 1150 9100 1150
Connection ~ 8800 1150
Wire Wire Line
	8800 1350 9100 1350
Connection ~ 8800 1350
$Comp
L Device:C_Small C13
U 1 1 6A67B251
P 9400 1250
F 0 "C13" H 9550 1250 50  0000 C CNN
F 1 "0.1uF" H 9450 1400 50  0000 C CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 9400 1250 50  0001 C CNN
F 3 "~" H 9400 1250 50  0001 C CNN
	1    9400 1250
	-1   0    0    1   
$EndComp
Wire Wire Line
	9400 1150 9100 1150
Connection ~ 9100 1150
Wire Wire Line
	9400 1350 9100 1350
Connection ~ 9100 1350
$Comp
L Connector_Generic:Conn_02x05_Odd_Even J3
U 1 1 6A69D469
P 1500 6350
F 0 "J3" H 1550 6767 50  0000 C CNN
F 1 "Conn_02x05_Odd_Even" H 1550 6676 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x05_P2.54mm_Vertical" H 1500 6350 50  0001 C CNN
F 3 "~" H 1500 6350 50  0001 C CNN
	1    1500 6350
	1    0    0    -1  
$EndComp
Text GLabel 850  6150 0    50   Input ~ 0
TCK
Text GLabel 1300 6250 0    50   Input ~ 0
TMS
Text GLabel 1300 6350 0    50   Input ~ 0
TDI
Text GLabel 1300 6450 0    50   Output ~ 0
TDO
NoConn ~ 1300 6550
NoConn ~ 1800 6550
NoConn ~ 1800 6450
Text GLabel 1800 6150 2    50   Input ~ 0
GND
Text GLabel 1800 6250 2    50   Input ~ 0
GND
Text GLabel 1800 6350 2    50   Input ~ 0
3V3
Text Notes 1450 6750 0    50   ~ 0
JTAG
$Comp
L Device:R_Small R11
U 1 1 6A16EF59
P 950 5900
F 0 "R11" H 1050 5900 50  0000 C CNN
F 1 "4.7k" H 750 5900 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric_Pad1.20x1.40mm_HandSolder" H 950 5900 50  0001 C CNN
F 3 "~" H 950 5900 50  0001 C CNN
	1    950  5900
	-1   0    0    1   
$EndComp
Text GLabel 950  5700 1    50   Input ~ 0
GND
Wire Wire Line
	950  5700 950  5800
Wire Wire Line
	850  6150 950  6150
Wire Wire Line
	950  6000 950  6150
Connection ~ 950  6150
Wire Wire Line
	950  6150 1300 6150
$Comp
L Regulator_Linear:TLV73312PDBV U3
U 1 1 6A18516F
P 3700 1250
F 0 "U3" H 3700 1592 50  0000 C CNN
F 1 "TLV75533PDBVR" H 3700 1501 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-5" H 3700 1575 50  0001 C CIN
F 3 "" H 3700 1250 50  0001 C CNN
	1    3700 1250
	1    0    0    -1  
$EndComp
Text GLabel 3700 1550 3    50   Input ~ 0
GND
Text GLabel 4250 1150 2    50   Output ~ 0
3V3
Text GLabel 3400 1150 0    50   Input ~ 0
VCC
Wire Wire Line
	3400 1150 3400 1250
$Comp
L Device:C_Small C3
U 1 1 6A19BC5B
P 4150 1250
F 0 "C3" H 4000 1250 50  0000 C CNN
F 1 "1uF" H 4050 1150 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 4150 1250 50  0001 C CNN
F 3 "~" H 4150 1250 50  0001 C CNN
	1    4150 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 1150 4150 1150
Connection ~ 4150 1150
Wire Wire Line
	4150 1150 4250 1150
Wire Wire Line
	3700 1550 4150 1550
Wire Wire Line
	4150 1550 4150 1350
$Comp
L Par2Ser:LC4064V-75TN48C U1
U 1 1 6A25C54A
P 5850 3000
F 0 "U1" H 5800 3000 50  0000 L CNN
F 1 "LC4064V-75TN48C" H 5500 3350 50  0000 L CNN
F 2 "Package_QFP:TQFP-48_7x7mm_P0.5mm" H 6550 4150 50  0001 L CNN
F 3 "" H 6550 4050 50  0001 L CNN
	1    5850 3000
	1    0    0    -1  
$EndComp
NoConn ~ 5900 1650
$Comp
L Device:R_Small R12
U 1 1 6A2FCD79
P 8100 3750
F 0 "R12" H 8200 3750 50  0000 C CNN
F 1 "10k" H 7950 3750 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 8100 3750 50  0001 C CNN
F 3 "~" H 8100 3750 50  0001 C CNN
	1    8100 3750
	1    0    0    -1  
$EndComp
Wire Wire Line
	7900 3600 8100 3600
Wire Wire Line
	8100 3600 8100 3650
Connection ~ 8100 3600
Wire Wire Line
	8100 3600 8500 3600
Wire Wire Line
	8100 3850 8100 3900
Text GLabel 7900 3600 0    50   Input ~ 0
SIWU
Text GLabel 5700 1650 1    50   Output ~ 0
SIWU
$EndSCHEMATC
