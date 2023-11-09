import 'package:final_app/sqlite/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/ui/account_page.dart';
import 'package:final_app/sqlite/user.dart';

class SignUP extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUP> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? isExist;
  bool isLoading = false;

  final _model = UserModel();
  List<dynamic> allUsers = [];

Future<void> checkAccountInFirebase(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    String username = _usernameController.text;
    String password = _passwordController.text;

    // Check for username format
    if (username.trim() != username || username.contains(' ') || username == '') {
      showSnackBar("Username format is incorrect.", "false", context);
      setState(() {
        isLoading = false;
      });
    } 
    // Check for password format
    else if (password.trim() != password || password.contains(' ') || password == '') {
      showSnackBar("Password format is incorrect.", "false", context);
      setState(() {
        isLoading = false;
      });
    } 
    else {
      try {
        // initialize Firebase
        await Firebase.initializeApp();
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;

        final QuerySnapshot querySnapshot = await _firestore
            .collection('accounts')
            .where('username', isEqualTo: username)
            .get();

        isExist = querySnapshot.docs.isNotEmpty.toString();
        if (isExist == "false") {
          _addUser(username,password);
          _readUser();
          await _firestore.collection('accounts').add({
            'username': username,
            'password': password,
          });
          Navigator.pop(context, {'isExist': isExist});
        } else {
          showSnackBar("Account exists, try again.", "false", context);
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

  }

  Future _addUser(String username, String password) async{
      User newuser = User(id: null, username: username, password: password);
      int insertedUser = await _model.insertUser(newuser);

      if(insertedUser != null){
       print("New User registered");
      }


    }

  Future _readUser() async{
    List users = await _model.getAllUsers();
    setState(() {
        allUsers = users;
    });

    print(' ');
    print("All the Users: ");
    for(User user in users){
      print(user);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  checkAccountInFirebase(context);
                },
                child: Text('Confirm'),
              ),
            ),
            if (isLoading) CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}

String extractUsername(String input) {
  if (input.contains('@')) {
    return input.split('@')[0];
  } else {
    return input;
  }
}
