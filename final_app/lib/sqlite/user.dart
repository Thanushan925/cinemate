import 'package:flutter/material.dart';

class User{
  int? id;
  String? username;
  String? password;

  User({this.id, this.username, this.password});

  User.toMap(Map map){
    this.id = map['id'];
    this.username = map['username'];
    this.password = map['password'];
  }

  Map<String, Object?> toMap(){
    return{
      'id': this.id!,
      'username': this.username!,
      'password': this.password!
    };
  }

  String toString(){
    return "ID: $id, Username: $username, Password: $password";
  }
}