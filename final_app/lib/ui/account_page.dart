import 'package:flutter/material.dart';
import 'package:final_app/firebase/sign_in.dart';
import 'package:final_app/firebase/sign_up.dart';
import 'package:final_app/ui/notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:final_app/sqlite/notif.dart';

class AccountPage extends StatefulWidget {
  String? message = '';

  AccountPage({required this.message});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> with WidgetsBindingObserver {
  static String? _isExist;
  static String? _username;
  static bool notificationEnabled = false;
  static bool isAlertDialogShowing = false;
  static bool alertSettingsClicked = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isAlertDialogShowing) {
      // this block will be executed when the app is resumed
      print("Back to app");
      _checkNotificationPermission();
    }
  }

  Future<void> _checkNotificationPermission() async {
    var status = await Permission.notification.status;

    if (status.isGranted && alertSettingsClicked) {
      print("enter check");

      // perform asynchronous work without updating the widget state
      Notifs newNotif = Notifs(notificationEnabled: notificationEnabled);
      await LocalNotifications.model.updateAllNotif(newNotif);

      alertSettingsClicked = false;

      setState(() {
        notificationEnabled = true;
      });
    } else if (status.isDenied) {
      setState(() {
        notificationEnabled = false;
      });
    }
  }

  // notification alert
  Future<void> _showNotificationPermissionDialog(BuildContext context) async {
    // set the flag to true when the dialog is shown
    isAlertDialogShowing = true;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert"),
          content: Text("Please allow notification settings in Account!"),
          actions: [
            TextButton(
              onPressed: () {
                // close the dialog
                Navigator.of(context).pop();
                // set the flag back to false when the dialog is dismissed
                isAlertDialogShowing = false;
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // close the dialog
                Navigator.of(context).pop();

                alertSettingsClicked = true;

                // open the app settings
                openAppSettings();

                // set the flag back to false when the dialog is dismissed
                isAlertDialogShowing = false;
              },
              child: Text("Settings"),
            ),
          ],
        );
      },
    );
  }

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

        if (_isExist == 'true') {
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

        if (_isExist == 'false') {
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
        title: _isExist == 'true'
            ? Text('Welcome $_username')
            : Text('Account Page'),
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
      body: Container(
        color: Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // show only when _isExist is false or null
            if (_isExist == 'false' || _isExist == null)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _navigateSignIn(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      alignment: Alignment.centerLeft,
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      elevation: 0.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      _navigateSignUp(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      alignment: Alignment.centerLeft,
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      elevation: 0.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 8.0),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Text(
                      'Enable Notifications',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Spacer(),
                  Switch(
                    value: notificationEnabled,
                    onChanged: (value) async {
                      final status = await Permission.notification.request();
                      if (notificationEnabled == false &&
                          status != PermissionStatus.granted) {
                        await _showNotificationPermissionDialog(context);
                      } else {
                        setState(() {
                          LocalNotifications.isEnabled = value;
                          notificationEnabled = value;

                          Notifs newNotif = Notifs(notificationEnabled: value);
                          LocalNotifications.model.updateAllNotif(newNotif);
                        });
                      }
                    },
                    activeTrackColor: Colors.blue,
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Text(
                      'Terms and Conditions',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              actions: [
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                              title: Text('Privacy Policy'),
                              content: RichText(
                                  text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                    TextSpan(
                                      text: 'Acceptance of Terms',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '\n\nBy downloading, installing, or using the '
                                          '"Cinemate" mobile application, you agree '
                                          'to comply with and be bound by the following '
                                          'terms and conditions.',
                                    ),
                                    TextSpan(
                                      text: '\n\nUser Conduct',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '\n\nTo access certain features of the App, '
                                          'you may be required to create a user account. '
                                          'You agree to provide accurate and complete '
                                          'information during the registration process. ',
                                    ),
                                    TextSpan(
                                      text:
                                          '\n\nYou agree not to use the App for any unlawful or prohibited purpose. Unauthorized access or use of the App is strictly prohibited.',
                                    ),
                                    TextSpan(
                                      text: '\n\nData Accuracy:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '\n\nWhile we strive to provide accurate and up-to-date information, we do not guarantee the accuracy, completeness, or reliability of any content within the App.',
                                    ),
                                    TextSpan(
                                      text: '\n\nIntellectual Property:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '\n\nAll content, trademarks, and intellectual property rights in the App are the property of Cinemate or its licensors. You may not reproduce, distribute, or create derivative works without our explicit permission.',
                                    ),
                                    TextSpan(
                                      text:
                                          '\n\nNotifications and Recommendations:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '\n\nBy using the App, you may receive notifications and personalized recommendations based on your activity. You can manage notification settings within the App.',
                                    ),
                                  ])),
                            );
                          });
                    },
                    child: Icon(Icons.storage),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              color: Colors.white,
              child: const Row(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
