import 'package:flutter/material.dart';
import 'package:final_app/firebase/access_accounts.dart';

class AccountPage extends StatefulWidget {
  String? message = '';

  AccountPage({required this.message});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Function that shows a Snackbar with the given message
  void _showErrorSnackbar(BuildContext context, String message) {
    final snackbar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 8),
          Text(message, style: TextStyle(color: Colors.white)),
        ],
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.message != '' && widget.message != null)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                widget.message!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _showErrorSnackbar(context, "Error Signing In! Please Try Again.");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FirestoreAccounts(
                      username: _usernameController.text,
                      password: _passwordController.text,
                    ),
                  ),
                );
              },
              child: Text('Sign in'),
            ),
          ),
        ],
      ),
    );
  }
}
