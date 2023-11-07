import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:final_app/firebase/account_model.dart';
import 'package:final_app/ui/account_page.dart';

// void main() {
//   runApp(MyApp());
// }

class FirestoreAccounts extends StatelessWidget {
  final String username;
  final String password;

  FirestoreAccounts({required this.username, required this.password});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error initializing Firebase");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          print("Successfully connected to Firebase");
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('accounts')
                .where('username', isEqualTo: username)
                .where('password', isEqualTo: password)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.data!.docs.isNotEmpty) {
                String documentId = snapshot.data!.docs[0].id;
                return MaterialApp(
                    title: 'Accessing Account',
                    theme: ThemeData(primarySwatch: Colors.blue),
                    home: LoginSuccess(documentId: documentId));
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AccountPage(
                          message: 'Account/Password Incorrect')));
                });
                return CircularProgressIndicator();
              }
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}


class LoginSuccess extends StatelessWidget {
  final String documentId;

  LoginSuccess({required this.documentId});

  final CollectionReference accounts = FirebaseFirestore.instance.collection('accounts');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: accounts.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        print("documentID: $documentId **********************************************8");

        Account account = Account.fromMap(snapshot.data!.data(), reference: snapshot.data!.reference);
        String? username = extractUsername(account.username!);

        return Scaffold(
          appBar: AppBar(
            title: Text('Welcome $username'),
          ),
          body: Center(
            child: Text('successflly logged in'),
          ),
        );
      },
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
