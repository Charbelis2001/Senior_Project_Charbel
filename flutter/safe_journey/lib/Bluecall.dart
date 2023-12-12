import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';

class Bluecall {
  late FlutterBlue flutterBlue;
  late BluetoothDevice targetDevice;
  late BluetoothCharacteristic targetCharacteristic;
  late BluetoothCharacteristic weightCharacteristic;
  late BluetoothCharacteristic lightCharacteristic;
  late BluetoothCharacteristic distanceCharacteristic;
  late StreamSubscription<List<ScanResult>> scanSubscription;
  late bool isConnected = false;
  late String receivedData = '';
  late String weightData = '';
  late String lightData = '';
  late String distanceData = '';
  late String lightLevel = '';
  late String distance1 = '';
  late String distance2 = '';

  Bluecall() {
    flutterBlue = FlutterBlue.instance;
  }

  Future<void> startScan() async {
    await flutterBlue.startScan(timeout: Duration(seconds: 4));
  }

  Future<void> stopScan() async {
    await flutterBlue.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    targetDevice = device;
    print('Device connected');
    await Future.delayed(Duration(seconds: 1)); // Ensuring the device is fully connected

    List<BluetoothService> services = await device.discoverServices();
    print('Services discovered');

    for (var service in services) {
      if (service.uuid.toString() == '4fafc201-1fb5-459e-8fcc-c5c9c331914b') {
        for (var characteristic in service.characteristics) {
          switch (characteristic.uuid.toString()) {
            case 'beb5483e-36e1-4688-b7f5-ea07361b26a8':
              targetCharacteristic = characteristic;
              print('Status Characteristic found');
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                updateData(value);
              });
              break;
            case 'beb5483e-36e1-4688-b7f5-ea07361b27a1':
              weightCharacteristic = characteristic;
              print('Weight Characteristic found');
              break;
            case 'beb5483e-36e1-4688-b7f5-ea07361b27a2':
              lightCharacteristic = characteristic;
              print('Light Characteristic found');
              break;
            case 'beb5483e-36e1-4688-b7f5-ea07361b27a3':
              distanceCharacteristic = characteristic;
              print('Distance Characteristic found');
              break;
          }
        }
      }
    }
    isConnected = true;
  }

  void updateData(List<int> value) {
    // Convert the received data into a string
    String data = String.fromCharCodes(value);
    print('Received data: $data'); // Add this for debugging

    // Assuming the data is comma separated as 'L:x,D:x'
    final readings = data.split(',');
    for (var reading in readings) {
      final readingParts = reading.split(':');
      if (readingParts.length == 2) {
        // Update the class fields directly
        if (readingParts[0] == 'L') {
          lightData = readingParts[1];
        } else if (readingParts[0] == 'D') {
          distanceData = readingParts[1];
        }
        print('Updated ${readingParts[0]} Data to ${readingParts[1]}'); // Add this for debugging
      }
    }

    // Notify listeners (UI) to update
    onDataReceived();
  }


  Future<void> readWeightData() async {
    await weightCharacteristic.read().then((value) {
      weightData = (double.parse(String.fromCharCodes(value)) + 5).toString();
      onDataReceived();
    });
  }

  Future<void> readLightData() async {
    await lightCharacteristic.read().then((value) {
      lightLevel= String.fromCharCodes(value);
      onDataReceived();
    });
  }

  Future<void> readDistanceData() async {
    await distanceCharacteristic.read().then((value) {
      // Assuming the value format is 'D1:x,D2:x'
      final parts = String.fromCharCodes(value).split(',');
      if (parts.length >= 2) {
        distance1 = parts[0].split(':')[1];
        distance2 = parts[1].split(':')[1];
      }
      onDataReceived();
    });
  }

  Function onDataReceived = () {};

  Future<void> disconnectFromDevice() async {
    await targetDevice.disconnect();
    isConnected = false;
    onDataReceived(); 
  }
}