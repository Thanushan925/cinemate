import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;


class notifDB{
    static Future init() async{
      var database = await openDatabase(
        path.join(await getDatabasesPath(), 'notif.db'),
        onCreate: (db, version){
          db.execute(
            'CREATE TABLE notif(enableNotif INTEGER)'
          );
        },
        version: 1,
      );
      print("Created DB: $database");
      return database;
    }
}