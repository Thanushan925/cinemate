import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class UserDBUtils{
  static Future init() async{
    //sets up database
    var database = await openDatabase(
      path.join(await getDatabasePath(), 'user.db'),
      onCreate: (db, version){
        db.execute(
          'CREATE TABLE users_info(id INTEGER PRIMARY KEY, username TEXT, password TEXT)'
        );
      },
      version: 1,
    );
    print("Created DB $database");
  }
}