first of all you should have arduino IDE, and you should know the board you are using. we were using esp32 devkit v1.
we start by downloading the board from tools->board->board manager, and we search fro esp32 and downlaod the one by espressif systems.
then you should connect the esp32 to your laptop (ensure you have the necessary drivers and that your cable can send data through it since some cable can only be used for power).
once you select your board in tools, you should also select the port. then everything is set for your esp32.
all that's left is to connect the sensors to the board.

if you are not using the board ensure that the pin you are connecting the sensors to are (VIN which is 5v), (GND the ground), and the rest of the pins are all digital pins except for the LDRs (analogue pin).

so now you need to download the libraries corresponding to each sensor.

please make sure you include the libraries you are using.


you can use this link to download the library for hx711:  https://github.com/bogde/HX711. 

now you should fix your load cell where you want to use it.
then you can use the code we provided for calibration, and after calibration and getting the factor, you can directly get the weight accuratly without the need to calibrate it again.

as for the Ultrasonic, you can download a library for HCSR04, we used "Bonezegei_HCSR04", and you can use the code in the example.
now for the LDR, we did the voltage divider circuit, and we connect to a digital pin, and you can use the code we provided in the report to test it.

finally you can put everything together as seen in our report.

all bluetooth library should already be downloaded with the board (they are in the library of the board).

now for Bluetooth serial, include <BluetoothSerial.h>, then declare a varibale from it like (BluetoothSerial SerialBT) and then "SerialBT.begin("ESP32_BT")" initialize the name of the device, and "SerialBT.print" send the String in it.

as for BLE, you can check the example BLE server. and if you want to send the data as we did you can update your code similarly to ours. evrything is explained in the report.

PLEASE MAKE SURE YOU CHANGE THE PIN NUMBERS TO THE WAY YOU CONNECT THEM WHILE MAKING SURE THE PINS ARE DIGITAL EXCEPT FOR LDR (ANALOGUE PIN).