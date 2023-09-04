import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:NEEEICUM/HomePage/home.dart';
import 'package:NEEEICUM/auth/signup.dart';
import 'login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String logo = "assets/images/logo_w.png";
  bool loginPage = true;

  void toggleScreen() {
    setState(() {
      loginPage = !loginPage;
    });
  }

  // retirar comments ao criar nova versão para tele e voltar a meter ao dar update na web

  /*void setToken() async {
    final _firebaseMessaging = FirebaseMessaging.instance;
    final fCMToken = await _firebaseMessaging.getToken();
    String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
    final ref =
        FirebaseDatabase.instance.ref().child('users').child(uid.toString());
    final ref_token = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(uid.toString())
        .child('token');

    final snap_token = await ref_token.get();
    final snap = await ref.get();
    if (!(snap_token.exists)) {
      ref.update({'token': fCMToken.toString()});
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0x36, 0x34, 0x32),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //setToken();
            return const HomePage();
          } else {
            if (loginPage) {
              return LoginPage(showSignUpPage: toggleScreen);
            } else {
              return SignUpPage(showLoginPage: toggleScreen);
            }
          }
        },
      ),
    );
  }
}
