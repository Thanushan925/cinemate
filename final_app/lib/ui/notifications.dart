import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:final_app/ui/account_page.dart';


class LocalNotifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool showNotificationEnable = false;

  LocalNotifications() {
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      AccountPageState.notificationEnabled = status == PermissionStatus.granted;
      return status == PermissionStatus.granted;
    }
    return true; // For iOS, permission is not required
  }

  Future<void> showNotification() async {
    if (await requestNotificationPermission()) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      print("current value = ${LocalNotifications.showNotificationEnable}***************************8");

      if(showNotificationEnable)
      {
        print("enterssssssssssssssssssssssssssssss");
        await flutterLocalNotificationsPlugin.show(
          0,
          'Welcome to Cinemate!',
          'Your mate for all your cinema needs.',
          platformChannelSpecifics,
          payload: 'item x',
        );
      }
    }
  }
}