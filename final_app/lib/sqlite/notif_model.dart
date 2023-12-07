import 'notif.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'notification_util.dart';

class NotifModel{

  Future getNotif() async{
    final db = await notifDB.init();

    final List maps = await db.query('notif');

    List result = [];
    for(int i = 0; i <maps.length; i++){
      result.add(Notifs.fromMap(maps[i]));
    }

    return result;
  }

  Future<int> updateAllNotif(Notifs notif) async {
    final db = await notifDB.init();
    return db.update(
      'notif',
      notif.toMap()
    );
  }

  Future<int> addNotif(Notifs notif) async {
    final db = await notifDB.init();
    return db.insert(
      'notif',
      notif.toMap(),
    );
  }

  Future<bool> isEmpty() async{
    final db = await notifDB.init();
    var count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM notif'));
    if(count == 0){
      return true;
    }
    else{
      return false;
    }
  }
}