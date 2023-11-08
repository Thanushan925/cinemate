import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBUtils{
  static Future init() async{
    //sets up database
    var database = await openDatabase(
      path.join(await getDatabasesPath(), 'favorites.db'),
      onCreate: (db, version){
        db.execute(
          'CREATE TABLE user_favorites(id INTEGER PRIMARY KEY, name TEXT, runtime TEXT, releaseDate TEXT, largePosterImageUrl TEXT)'
        );
      },
      version: 1,
    );
    print("Created DB $database");
  }
}