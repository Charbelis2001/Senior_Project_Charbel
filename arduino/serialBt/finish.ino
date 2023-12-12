#include <Bonezegei_HCSR04.h>
#include <HX711.h>
#include <BluetoothSerial.h>

BluetoothSerial SerialBT;

#define DOUT_PIN 19
#define CLK_PIN 18
HX711 scale;

const int TRIGGER_PIN = 26;
const int ECHO_PIN = 27;
const int TRIGGER_PIN_1 = 22;
const int ECHO_PIN_1 = 23;
const int photoPin = 2;

Bonezegei_HCSR04 ultrasonic(TRIGGER_PIN, ECHO_PIN);
Bonezegei_HCSR04 ultrasonic_1(TRIGGER_PIN_1, ECHO_PIN_1);

void setup() {
  Serial.begin(9600);
  SerialBT.begin("ESP32_BT"); // Bluetooth device name
  scale.begin(DOUT_PIN, CLK_PIN);
  scale.set_scale(-120660);
  scale.tare();
}

void loop() {
  int d = ultrasonic.getDistance();
  int d1 = ultrasonic_1.getDistance();
  int light = analogRead(photoPin);
  float weight = scale.get_units();

  Serial.print("Distance: ");
  Serial.print(d);
  Serial.println(" cm");
  Serial.print("Distance_1: ");
  Serial.print(d1);
  Serial.println(" cm");
  Serial.println("Light: ");
  Serial.println(light);
  Serial.print("Weight: ");
  Serial.print(weight, 3);
  Serial.println(" kg");

  if (SerialBT.connected()) 
  {
    SerialBT.print("D1:");
    SerialBT.print(d);
    SerialBT.print(".");
    
    SerialBT.print("D2:");
    SerialBT.print(d1);
    SerialBT.print(".");
    
    SerialBT.print("L:");
    SerialBT.print(light);
    SerialBT.print(".");
    
    SerialBT.print("W:");
    SerialBT.print(weight, 3);
    SerialBT.println("."); // End of data entry
  } 
  else 
  {
      Serial.println("Bluetooth not connected!");
  }

  delay(1000);
}
