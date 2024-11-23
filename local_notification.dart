import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the local notifications plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  runApp(MyApp(flutterLocalNotificationsPlugin));
}

IOSInitializationSettings() {
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  MyApp(this.flutterLocalNotificationsPlugin);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Local Notifications Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => showNotification(flutterLocalNotificationsPlugin),
            child: Text('Show Notification'),
          ),
        ),
      ),
    );
  }
}

void showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',

    importance: Importance.max,
    priority: Priority.high,
  );

  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    'Notification Title',
    'Notification Body',
    platformChannelSpecifics,
  );
}

IOSNotificationDetails() {
}

