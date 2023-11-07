import 'package:cloud_firestore/cloud_firestore.dart';

class Account
{
  String? username;
  String? password;
  DocumentReference? reference;

  Account.fromMap(var map, {this.reference})
  {
    this.username = map['username'];
    this.password = map['password'];
  }

  Map<String, Object?> toMap(){
    return {
      'username': this.username,
      'password': this.password
    };
  }
}