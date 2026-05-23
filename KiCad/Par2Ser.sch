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
$Comp
L Device:C_Small C6
U 1 1 5EB53531
P 8400 1500
F 0 "C6" H 8250 1500 50  0000 C CNN
F 1 "0.1uF" H 8250 1400 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 8400 1500 50  0001 C CNN
F 3 "~" H 8400 1500 50  0001 C CNN
	1    8400 1500
	1    0    0    -1  
$EndComp
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
F 1 "330" H 2050 2300 50  0000 L CNN
F 2 "Resistor_SMD:R_1206_3216Metric_Pad1.30x1.75mm_HandSolder" H 2000 2300 50  0001 C CNN
F 3 "~" H 2000 2300 50  0001 C CNN
	1    2000 2300
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R1
U 1 1 5EB9CA00
P 2250 4050
F 0 "R1" H 2150 4050 50  0000 C CNN
F 1 "330" H 2400 4050 50  0000 C CNN
F 2 "Resistor_SMD:R_1206_3216Metric_Pad1.30x1.75mm_HandSolder" H 2250 4050 50  0001 C CNN
F 3 "~" H 2250 4050 50  0001 C CNN
	1    2250 4050
	1    0    0    -1  
$EndComp
Text GLabel 12800 2400 0    50   Input ~ 0
GND
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
Text GLabel 14500 2900 2    50   Output ~ 0
3V3
Wire Wire Line
	2250 3850 2250 3950
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
Text GLabel 8400 1600 3    50   Input ~ 0
GND
$Comp
L Device:C_Small C7
U 1 1 611D1D5F
P 12550 3700
F 0 "C7" H 12700 3700 50  0000 C CNN
F 1 "0.1uF" H 12350 3700 50  0000 C CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 12550 3700 50  0001 C CNN
F 3 "~" H 12550 3700 50  0001 C CNN
	1    12550 3700
	-1   0    0    1   
$EndComp
$Comp
L Device:C_Small C3
U 1 1 612089E2
P 14500 2350
F 0 "C3" H 14400 2250 50  0000 C CNN
F 1 "0.1uF" H 14350 2450 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 14500 2350 50  0001 C CNN
F 3 "~" H 14500 2350 50  0001 C CNN
	1    14500 2350
	-1   0    0    1   
$EndComp
Text GLabel 3750 5400 0    50   Output ~ 0
STROBE
Text GLabel 6850 5550 3    50   Input ~ 0
STROBE
Text GLabel 2750 6350 0    50   Input ~ 0
GND
Text GLabel 8800 1100 0    50   Input ~ 0
RESET
Text GLabel 8400 1300 1    50   Input ~ 0
3V3
Text GLabel 8150 2250 3    50   Input ~ 0
GND
Text GLabel 8650 1900 2    50   Input ~ 0
GND
Text GLabel 8000 1850 0    50   Input ~ 0
IRQ
Text GLabel 7950 1450 1    50   Input ~ 0
GND
Text GLabel 10800 5650 3    50   Input ~ 0
IRQ
Text GLabel 8350 2300 3    50   Output ~ 0
IRQ
NoConn ~ 3750 5300
Text Label 3750 5300 2    50   ~ 0
Amiga_5V
$Comp
L Par2Ser:FT232RNL-REEL U2
U 1 1 67123320
P 13450 2400
F 0 "U2" H 13450 3265 50  0000 C CNN
F 1 "FT232RNL-REEL" H 13450 3174 50  0000 C CNN
F 2 "Package_SO:SSOP-28_5.3x10.2mm_P0.65mm" H 13950 3100 50  0001 L CNN
F 3 "https://ftdichip.com/wp-content/uploads/2022/12/DS_FT232RN.pdf" H 13950 3000 50  0001 L CNN
	1    13450 2400
	1    0    0    -1  
$EndComp
Text GLabel 12800 2200 0    50   Input ~ 0
TX
Text GLabel 12800 1800 0    50   Output ~ 0
RX
Text GLabel 12800 2000 0    50   Output ~ 0
CTS
Text GLabel 12800 2800 0    50   Input ~ 0
RTS
Text GLabel 14100 3000 2    50   BiDi ~ 0
USBDM
Text GLabel 14100 3100 2    50   BiDi ~ 0
USBDP
Text GLabel 14500 2600 2    50   Input ~ 0
VCC
Text GLabel 12500 2000 1    50   Input ~ 0
VCC
Text GLabel 14100 2700 2    50   Input ~ 0
RESET
Text GLabel 14100 2800 2    50   Input ~ 0
GND
Text GLabel 14100 2500 2    50   Input ~ 0
GND
Text GLabel 14100 2000 2    50   Input ~ 0
GND
Text GLabel 14100 2100 2    50   Input ~ 0
GND
NoConn ~ 14100 2200
Text GLabel 12800 2500 0    50   Output ~ 0
CTS
NoConn ~ 12800 2300
Text GLabel 12800 2600 0    50   Input ~ 0
DTR
Wire Wire Line
	12800 2700 12800 2600
Text GLabel 12800 1900 0    50   Output ~ 0
DSR
Text GLabel 8800 1500 0    50   Input ~ 0
GND
Wire Wire Line
	8400 1300 8400 1400
NoConn ~ 14100 1800
NoConn ~ 14100 1900
$Comp
L Device:C_Small C5
U 1 1 67141D33
P 12500 2200
F 0 "C5" H 12350 2250 50  0000 C CNN
F 1 "0.1uF" H 12300 2150 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 12500 2200 50  0001 C CNN
F 3 "~" H 12500 2200 50  0001 C CNN
	1    12500 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	12800 2100 12500 2100
Wire Wire Line
	12500 2100 12500 2000
Connection ~ 12500 2100
Text GLabel 12500 2300 3    50   Input ~ 0
GND
Wire Wire Line
	10800 5650 10800 5550
Text GLabel 10800 5250 1    50   Input ~ 0
3V3
Wire Wire Line
	10800 5250 10800 5350
Text GLabel 14100 2300 2    50   Input ~ 0
TXLED
Text GLabel 14100 2400 2    50   Input ~ 0
RXLED
Text GLabel 12350 3800 0    50   Input ~ 0
3V3
Wire Wire Line
	12350 3800 12450 3800
Connection ~ 12550 3800
Wire Wire Line
	12550 3800 12750 3800
Text GLabel 12550 3600 1    50   Input ~ 0
GND
Text GLabel 12750 4400 3    50   Input ~ 0
GND
Wire Wire Line
	12450 4100 12450 3800
Connection ~ 12450 3800
Wire Wire Line
	12450 3800 12550 3800
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
Wire Wire Line
	14100 2600 14500 2600
Wire Wire Line
	14500 2600 14500 2450
Text GLabel 14500 2250 1    50   Input ~ 0
GND
$Comp
L Device:C_Small C4
U 1 1 67247829
P 14500 3150
F 0 "C4" H 14650 3250 50  0000 C CNN
F 1 "0.1uF" H 14700 3350 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 14500 3150 50  0001 C CNN
F 3 "~" H 14500 3150 50  0001 C CNN
	1    14500 3150
	-1   0    0    1   
$EndComp
Wire Wire Line
	14100 2900 14500 2900
Wire Wire Line
	14500 2900 14500 3050
Text GLabel 14500 3250 3    50   Input ~ 0
GND
NoConn ~ 12800 2900
NoConn ~ 12800 3000
NoConn ~ 12800 3100
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
L Par2Ser:LC4032V-5TN48C U1
U 1 1 6A10FE30
P 5850 3000
F 0 "U1" H 5800 3000 50  0000 L CNN
F 1 "LC4032V-5TN48C" H 5550 3300 50  0000 L CNN
F 2 "Package_QFP:TQFP-48_7x7mm_P0.5mm" H 6550 4150 50  0001 L CNN
F 3 "https://componentsearchengine.com/Datasheets/34/LC4032V-5TN48C.pdf" H 6550 4050 50  0001 L CNN
	1    5850 3000
	1    0    0    -1  
$EndComp
Text GLabel 6700 3150 2    50   Input ~ 0
GND
Text GLabel 5300 4250 3    50   Input ~ 0
GND
Text GLabel 5000 2450 0    50   Input ~ 0
TDI
Text GLabel 6700 2550 2    50   Output ~ 0
TD0
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
Text GLabel 5700 1650 1    50   BiDi ~ 0
D0_3V3
Text GLabel 5600 1650 1    50   BiDi ~ 0
D1_3V3
Text GLabel 5500 1650 1    50   BiDi ~ 0
D2_3V3
Text GLabel 5400 1650 1    50   BiDi ~ 0
D3_3V3
Text GLabel 5300 1650 1    50   BiDi ~ 0
D4_3V3
Text GLabel 5000 2550 0    50   BiDi ~ 0
D5_3V3
Text GLabel 5000 2650 0    50   BiDi ~ 0
D6_3V3
Text GLabel 5000 2750 0    50   BiDi ~ 0
D7_3V3
$Comp
L Par2Ser:FT240XS-R U3
U 1 1 6A22D05C
P 9150 3250
F 0 "U3" H 9150 4065 50  0000 C CNN
F 1 "FT240XS-R" H 9150 3974 50  0000 C CNN
F 2 "Par2Ser:SOP64P599X175-24N" H 8900 3950 50  0001 L CNN
F 3 "http://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT240X.pdf" H 9650 3800 50  0001 L CNN
	1    9150 3250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Pack04 RN3
U 1 1 6A265F89
P 8950 5450
F 0 "RN3" H 9138 5496 50  0000 L CNN
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
L Device:R_Pack04 RN5
U 1 1 6A2B099B
P 7500 5450
F 0 "RN5" H 7688 5496 50  0000 L CNN
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
$EndSCHEMATC
