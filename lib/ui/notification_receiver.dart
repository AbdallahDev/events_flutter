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
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
