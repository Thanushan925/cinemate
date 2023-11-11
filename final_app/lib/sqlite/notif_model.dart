import 'notif.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'notification_util.dart';


class NotifModel{
  Future<int> insertNotif(Notifs notifs) async{
    final db = await notifDB.init();

    return db.insert(
      'notif',
      notifs.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future getNotif() async{
    final db = await notifDB.init();

    final List maps = await db.query('notif');

    List result = [];
    //result.add(Notifs.fromMap(maps[0]));
    for(int i = 0; i <maps.length; i++){
      result.add(Notifs.fromMap(maps[i]));
    }

    return result;
  }


  Future<int> updateNotif(Notifs notif) async{
    final db = await notifDB.init();

    return db.update(
      'notif',
      notif.toMap(),
      where: 'enableNotif = ?',
      whereArgs: [notif.enableNotif],
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