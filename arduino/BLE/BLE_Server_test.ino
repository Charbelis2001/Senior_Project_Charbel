#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <Bonezegei_HCSR04.h>
#include <HX711.h>

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

#define WEIGHT_UUID "beb5483e-36e1-4688-b7f5-ea07361b27a1"
#define LIGHT_UUID "beb5483e-36e1-4688-b7f5-ea07361b27a2"
#define DISTANCE_UUID "beb5483e-36e1-4688-b7f5-ea07361b27a3"

BLECharacteristic *pCharacteristic;
BLECharacteristic *pWeightCharacteristic;
BLECharacteristic *pLightCharacteristic;
BLECharacteristic *pDistanceCharacteristic;

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

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      Serial.println("Device connected");
    }

    void onDisconnect(BLEServer* pServer) {
      Serial.println("Device disconnected");
      ESP.restart(); // Restart the ESP32
    }
};


class WeightCharacteristicCallbacks: public BLECharacteristicCallbacks {
  void onRead(BLECharacteristic *pCharacteristic) {
    float weight = scale.get_units();
    pCharacteristic->setValue(String(weight, 3).c_str());
  }
};

class LightCharacteristicCallbacks: public BLECharacteristicCallbacks {
  void onRead(BLECharacteristic *pCharacteristic) {
    int light = analogRead(photoPin);
    pCharacteristic->setValue(String(light).c_str());
  }
};

class DistanceCharacteristicCallbacks: public BLECharacteristicCallbacks {
  void onRead(BLECharacteristic *pCharacteristic) {
    int d = ultrasonic.getDistance();
    int d1 = ultrasonic_1.getDistance();
    String distances = "D1:" + String(d) + ",D2:" + String(d1);
    pCharacteristic->setValue(distances.c_str());
  }
};


void setup() {
  Serial.begin(115200);
  Serial.println("Starting BLE work!");

  BLEDevice::init("Safe Journey SuitCase");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);
  
  pCharacteristic = pService->createCharacteristic(
                       CHARACTERISTIC_UUID,
                       BLECharacteristic::PROPERTY_READ |
                       BLECharacteristic::PROPERTY_NOTIFY
                     );
  pCharacteristic->addDescriptor(new BLEDescriptor(BLEUUID((uint16_t)0x2902)));

  pWeightCharacteristic = pService->createCharacteristic(
    WEIGHT_UUID,
    BLECharacteristic::PROPERTY_READ
  );
  
  pLightCharacteristic = pService->createCharacteristic(
    LIGHT_UUID,
    BLECharacteristic::PROPERTY_READ
  );

  pDistanceCharacteristic = pService->createCharacteristic(
    DISTANCE_UUID,
    BLECharacteristic::PROPERTY_READ
  );

  pWeightCharacteristic->setCallbacks(new WeightCharacteristicCallbacks());
  pLightCharacteristic->setCallbacks(new LightCharacteristicCallbacks());
  pDistanceCharacteristic->setCallbacks(new DistanceCharacteristicCallbacks());

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(pService->getUUID());
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  pServer->setCallbacks(new MyServerCallbacks());

  Serial.println("Characteristic defined! Now you can read it on your phone!");

  scale.begin(DOUT_PIN, CLK_PIN);
  scale.set_scale(-120660);
  scale.tare();
}


unsigned long previousMillis = 0;
const long interval = 1000; // interval at which to send data (milliseconds)

void loop() {
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    int d = ultrasonic.getDistance();
    int d1 = ultrasonic_1.getDistance();
    int light = analogRead(photoPin);
    float weight = scale.get_units();

    // Print readings to Serial for debugging
    Serial.print("Distance: "); Serial.print(d); Serial.println(" cm");
    Serial.print("Distance_1: "); Serial.print(d1); Serial.println(" cm");
    Serial.print("Light: "); Serial.println(light);
    Serial.print("Weight: "); Serial.print(weight, 3); Serial.println(" kg");

    // Simplified status for light and distance
    String lightStatus = light > 0 ? "L:1" : "L:0";
    String distanceStatus = (d > 3 || d1 > 3) ? "1" : "0";

    Serial.print("lightStatus is: ");Serial.println(lightStatus );
    Serial.print("distanceStatus is:");Serial.println(distanceStatus);
    // Update status characteristic
    String statusData = lightStatus + ",D:" + distanceStatus;
    pCharacteristic->setValue(statusData.c_str());
    pCharacteristic->notify();
  }
}
