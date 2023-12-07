import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:final_app/sqlite/notif_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:final_app/ui/account_page.dart';
import 'package:final_app/sqlite/notif.dart';

class LocalNotifications {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool showNotificationEnable = false;
  static NotifModel model = NotifModel();
  static bool isEnabled = false;
  // List<dynamic> allNotifs = []; //just for testing

  LocalNotifications() {
    initializeNotifications();
  }

  Future _readNotifs() async{
    List users = await model.getNotif();
    for(Notifs notif in users){
      print(notif);
    }
  }

  Future<int> getNotifs() async{
    List users = await model.getNotif();
    return users[0].enableNotif;
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
    var preStatus = await Permission.notification.status;
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();

      if(preStatus != PermissionStatus.granted)
      {
        bool result = status == PermissionStatus.granted;
        AccountPageState.notificationEnabled = result;
        isEnabled = result;

        Notifs newNotif = Notifs(notificationEnabled: result);
        LocalNotifications.model.updateAllNotif(newNotif);
      }
      else if(status == PermissionStatus.granted)
      {
        bool result = (await getNotifs()) == 1;
        AccountPageState.notificationEnabled = result;
        isEnabled = result;

        Notifs newNotif = Notifs(notificationEnabled: result);
        LocalNotifications.model.updateAllNotif(newNotif);
      }
      else if(status != PermissionStatus.granted)
      {
        AccountPageState.notificationEnabled = false;
        
        Notifs newNotif = Notifs(notificationEnabled: false);
        model.updateAllNotif(newNotif);

        isEnabled = false;
      }
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

      if(isEnabled == true)
      {
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