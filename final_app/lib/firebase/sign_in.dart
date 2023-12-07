import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/ui/account_page.dart';
import 'package:final_app/sqlite/user_model.dart';
import 'package:final_app/sqlite/user.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? isExist;
  bool isLoading = false;
  final _model = UserModel();
  List checkUser = [];
  bool checking = false;
  bool mounted = false;

  // SignIn({required this.isExistController});

  Future<void> checkAccountInFirebase(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        // initialize Firebase
        await Firebase.initializeApp();
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;

        final QuerySnapshot querySnapshot = await _firestore
            .collection('accounts')
            .where('username', isEqualTo: username)
            .where('password', isEqualTo: password)
            .get();

        isExist = querySnapshot.docs.isNotEmpty.toString();
        if(isExist == "true")
        {
          Navigator.pop(context, {
            'isExist': querySnapshot.docs.isNotEmpty.toString(),
            'username': extractUsername(username)
          });
          checking = await _model.userExist(username);
          if(checking == false){
            _addUser(username, password);
          }
          _readUser();
        }
        else
        {
          showSnackBar("Account/Password incorrect, try again.", isExist!, context);
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

  @override
  void initState(){
    super.initState();
    mounted = true;
  }

  @override
  void dispose(){
    mounted = false;
    super.dispose();
  }

  Future _addUser(String username, String password) async{
      User newuser = User(id: null, username: username, password: password);
      int insertedUser = await _model.insertUser(newuser);

      if(insertedUser != null){
       print("Added to local storage!");
      }


    }

  Future _readUser() async{
    List users = await _model.getAllUsers();
    if(mounted == true){
      setState(() {
          checkUser = users;
      });
    }
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
            if (isLoading)
              CircularProgressIndicator() 
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
