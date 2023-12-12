import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class Noti
{

  static Future initialize (FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async
  {
      var androidInitialize = new AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettings = new InitializationSettings(android: androidInitialize);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future showNoti ({var id =0, required String title, required String body, var payload, required FlutterLocalNotificationsPlugin fln}) async
  {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('Safe_Journey_Notification', 'channel_name', playSound: true, importance: Importance.max,
                               priority: Priority.high,icon: '@mipmap/ic_launcher',);
    var not = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0,title,body,not);
  }

}