import 'package:flutter/material.dart';
import 'package:final_app/firebase/sign_in.dart';
import 'package:final_app/firebase/sign_up.dart';

class AccountPage extends StatefulWidget {
  String? message = '';

  AccountPage({required this.message});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  static String? _isExist;
  String? _username;

  {
    // TODO: implement print
    print("********************* current isExist = ${_isExist} ***********************");
    throw UnimplementedError();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _signOut() {
    setState(() {
      _isExist = 'false';
      _username = '';
    });
  }

  void _navigateSignIn(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );

    if (result != null) {
      setState(() {
        _isExist = result['isExist'];
        _username = result['username'];

        if (_isExist == 'true') 
        {
          showSnackBar("Sign In Successful.", _isExist!, context);
        }
      });
    }
  }

  void _navigateSignUp(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUP()),
    );

    if (result != null) {
      setState(() {
        _isExist = result['isExist'];

        if (_isExist == 'false') 
        {
          showSnackBar("Sign up Successful.", 'true', context);
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _isExist == 'true' ? Text('Welcome $_username') : Text('Account Page'),
        actions: <Widget>[
          if (_isExist == 'true')
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _signOut();
              },
            ),
        ],
      ),
      body: Center(
        child: _isExist == 'true'
            ? Text('Welcome')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _navigateSignIn(context);
                    },
                    child: Text('Sign In'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _navigateSignUp(context);
                    },
                    child: Text('Sign Up'),
                  ),
                ],
              ),
      )
    );
  }
}


void showSnackBar(String message, String isExist, BuildContext context) {
  SnackBar? snackBar;
  if (isExist == 'false') {
    snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 8),
          Text(message, style: TextStyle(color: Colors.white)),
        ],
      ),
      backgroundColor: Colors.red,
    );
  } else if (isExist == 'true') {
    snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.check, color: Colors.white),
          SizedBox(width: 8),
          Text(message, style: TextStyle(color: Colors.white)),
        ],
      ),
      backgroundColor: Colors.green,
    );
  }
  ScaffoldMessenger.of(context).showSnackBar(snackBar!);
}