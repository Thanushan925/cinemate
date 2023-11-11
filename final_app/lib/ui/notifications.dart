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
  final _model = NotifModel();
  int isEnabled = 1;
  List<dynamic> allNotifs = []; //just for testing

  LocalNotifications() {
    initializeNotifications();
  }

  Future _addNotif(bool notifchange) async{
    Notifs newNotif = Notifs(enableNotif: isEnabled);

    int insertedNotif = await _model.insertNotif(newNotif);

    if(insertedNotif != null){
      print("Notif changed");
    }
  }

  Future setNotifs(bool notifchange) async{
     if(notifchange == false){
      isEnabled = 0;
    }
    else{
      isEnabled = 1;
    }
  }

  Future _readNotifs() async{
    List users = await _model.getNotif();
    allNotifs = users;
    for(Notifs notif in users){
      print(notif);
    }
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
      if(status == PermissionStatus.granted){
        showNotificationEnable = true;
      }
      else{
        showNotificationEnable = false;
      }
      setNotifs(showNotificationEnable);
      if(await _model.isEmpty() == true){
        _addNotif(showNotificationEnable);
      }
      else{
        Notifs newNotif = Notifs(enableNotif: isEnabled);
        _model.updateNotif(newNotif);
      }
      _readNotifs();
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

      //print("current value = ${LocalNotifications.showNotificationEnable}***************************8");
      if(isEnabled == 1){
        print("Notification is enabled");
      }
      else{
        print("Notification is not enabled");
      }

      //if(showNotificationEnable)
      if(isEnabled == 1)
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