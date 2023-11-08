import 'user.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'user_util.dart';

class UserModel{
  Future<int> insertUser(User user) async{
    final db = await UserDBUtils.init();

    return db.insert(
      'users_info',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future getAllUsers() async{
    final db = await UserDBUtils.init();

    final List maps = await db.query('users_info');

    List result = [];
    for(int i = 0; i < maps.length; i++){
      result.add(
        User.fromMap(maps[i])
      );
    }
    return result;
  }

  Future<int> updateUser(User user) async{
    final db = await UserDBUtils.init();

    return db.update(
      'users_info',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async{
    final db = await UserDBUtils.init();

    return db.delete(
      'users_info',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}