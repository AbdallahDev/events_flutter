import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationReceiver extends StatefulWidget {
  @override
  _NotificationReceiverState createState() => _NotificationReceiverState();
}

class _NotificationReceiverState extends State<NotificationReceiver> {
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
