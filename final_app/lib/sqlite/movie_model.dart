import 'package:final_app/ui/homepage.dart';

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'db_util.dart';

class MovieModel{
  Future<int> insertMovie(Movie movie) async{
    final db = await DBUtils.init();
    return db.insert(
      'user_favorites',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }



  Future getAllFavorites() async{
    final db = await DBUtils.init();

    final List maps = await db.query('user_favorites');
    List result = [];

    for(int i = 0; i < maps.length; i++){
      result.add(
        Movie.fromMap(maps[i])
      );
    }
    return result;
  }

  Future<int> updateMovie(Movie movie) async{
    final db = await DBUtils.init();
    return db.update(
      'user_favorites',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }


  Future<int> deleteMovie(int id) async{
    final db = await DBUtils.init();
    return db.delete(
      'user_favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}