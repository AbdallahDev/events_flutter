import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationReceiver extends StatefulWidget {
  @override
  _NotificationReceiverState createState() => _NotificationReceiverState();
}

class _NotificationReceiverState extends State<NotificationReceiver> {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    //Flutter local notification initialization settings for both Android and IOS.
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(android, ios);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    //Firebase message receiving configuration.
    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) {
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) {
        _showNotification(msg);
        print(" onMessage called ${(msg)}");
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
  }

  //This method will show a notification when a message received.
  void _showNotification(Map<String, dynamic> msg) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'ONE', "EVENTS", "This is the event notifications channel",
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      msg['data']['title'],
      msg['data']['body'],
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(),
        body: new Center(),
      ),
    );
  }
}
