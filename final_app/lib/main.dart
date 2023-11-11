import 'package:flutter/material.dart';
import 'ui/nav.dart';
import 'ui/notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LocalNotifications().showNotification();
    return MaterialApp(
      title: 'Cinemate',
      home: Nav(),
    );
  }
}