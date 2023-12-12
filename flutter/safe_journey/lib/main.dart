import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Bluecall.dart';
import 'Noti.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Bluecall blueCall;
  List<ScanResult> scanResults = [];
  bool notificationsEnabled = false;
  bool isScanning = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? notificationTimer;
  bool isNotificationSent = false;
  String selectedSensor = '';

  @override
  void initState() {
    super.initState();
    blueCall = Bluecall();
    blueCall.onDataReceived = () {
      if (mounted) {
        setState(() {});
        handleBluetoothData();
      }
    };
    _initializeNotifications();
    _requestPermissions();
  }

  void setSelectedSensor(String sensor) {
    setState(() {
      selectedSensor = sensor;
    });
  }

  void handleBluetoothData() {
    bool shouldSendNotification = notificationsEnabled &&
        (blueCall.lightData == '1' || blueCall.distanceData == '1');

    if (shouldSendNotification && !isNotificationSent) {
      sendNotifications();
      isNotificationSent = true;
      startTimer();
    } else if (!shouldSendNotification) {
      notificationTimer?.cancel();
      isNotificationSent = false;
    }
  }

  void sendNotifications() {
    if (blueCall.lightData == '1' && blueCall.distanceData == '1') {
      Noti.showNoti(
          title: "Combined Alert",
          body:
              "Both light and distance are higher than threshold, please check your case",
          fln: flutterLocalNotificationsPlugin);
    } else {
      if (blueCall.lightData == '1') {
        Noti.showNoti(
            title: "Light Alert",
            body: "Light sensor has detected light, check your case",
            fln: flutterLocalNotificationsPlugin);
      }
      if (blueCall.distanceData == '1') {
        Noti.showNoti(
            title: "Distance Alert",
            body: "Distance is bigger than threshold, check your case",
            fln: flutterLocalNotificationsPlugin);
      }
    }
  }

  void startTimer() {
    notificationTimer?.cancel();
    notificationTimer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      if (notificationsEnabled &&
          (blueCall.lightData == '1' || blueCall.distanceData == '1')) {
        sendNotifications();
      } else {
        notificationTimer?.cancel();
        isNotificationSent = false;
      }
    });
  }

  Future<void> _initializeNotifications() async {
    await Noti.initialize(flutterLocalNotificationsPlugin);
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses.values.any((status) => status != PermissionStatus.granted)) {
      print('Permissions not granted!');
    } else {
      print('Permissions granted!');
    }
  }

  @override
  void dispose() {
    blueCall.stopScan();
    blueCall.scanSubscription.cancel();
    super.dispose();
  }

  void toggleScan() async {
    if (isScanning) {
      await blueCall.disconnectFromDevice();
      setState(() {
        isScanning = false;
        selectedSensor = '';
        blueCall.lightData = '';
        blueCall.distanceData = '';
        blueCall.weightData = '';
        blueCall.lightLevel = '';
        blueCall.distance1 = '';
        blueCall.distance2 = '';
      });
    } else {
      bool isBluetoothAvailable = await blueCall.flutterBlue.isAvailable;
      bool isBluetoothOn = await blueCall.flutterBlue.isOn;
      if (isBluetoothAvailable && isBluetoothOn) {
        blueCall.startScan();
        blueCall.scanSubscription =
            blueCall.flutterBlue.scanResults.listen((results) {
          setState(() {
            scanResults = results;
          });
        });
      } else {
        print("Bluetooth not available");
      }
    }
  }

  Widget _buildSensorDataDisplay() {
    if (selectedSensor.isEmpty) {
      return SizedBox
          .shrink(); // Return an empty widget when no sensor is selected
    } else {
      String displayText = '';
      String value = '';
      switch (selectedSensor) {
        case 'weight':
          displayText = 'Current Weight Value:';
          value = '${blueCall.weightData} Kg';
          break;
        case 'light':
          displayText = 'Current Light Level:';
          value = '${blueCall.lightLevel}';
          break;
        case 'distance':
          displayText = 'Current Distance Values:';
          value ='UltradSonic 1: ${blueCall.distance1} cm\nUltraSonic 2: ${blueCall.distance2} cm';
          break;
          case 'smarttag':
          displayText = 'SmartTag Information:';
          value = 'To see your SmartTag location, please open the SmartThings app and navigate to the find tab. There you\'ll be able to access all your SmartTag information and location.';
          break;
        default:
          return SizedBox.shrink(); // Empty widget for no selection
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(displayText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(value,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Safe Journey'),
                  Text('      Notification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
        actions: <Widget>[
          Switch(
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Sensor Data'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Weight'),
              onTap: () async {
                await blueCall.readWeightData();
                setSelectedSensor('weight');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Light'),
              onTap: () async {
                await blueCall.readLightData();
                setSelectedSensor('light');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Distance'),
              onTap: () async {
                await blueCall.readDistanceData();
                setSelectedSensor('distance');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('SmartTag'),
               onTap: () {
                setSelectedSensor('smarttag');
                Navigator.pop(context); 
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/airplane.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: toggleScan,
                child: Text(isScanning ? 'Disconnect' : 'Scan'),
              ),
              SizedBox(height: 20),
              _buildSensorDataDisplay(),
              SizedBox(height: 10),
              if (!blueCall.isConnected && scanResults.isNotEmpty)
                Text('Nearby Devices:'),
              if (!blueCall.isConnected)
                Expanded(
                  child: ListView.builder(
                    itemCount: scanResults.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(scanResults[index].device.name),
                        subtitle: Text(scanResults[index].device.id.toString()),
                        onTap: () async {
                          await blueCall
                              .connectToDevice(scanResults[index].device);
                          setState(() {
                            isScanning = blueCall.isConnected;
                            scanResults.clear();
                          });
                        },
                      );
                    },
                  ),
                ),
              if (blueCall.isConnected)
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Status Data:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Light Status: ${blueCall.lightData}',
                          style: TextStyle(fontSize: 18)),
                      Text('Distance Status: ${blueCall.distanceData}',
                          style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
