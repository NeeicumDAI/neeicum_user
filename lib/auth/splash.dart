import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0x36, 0x34, 0x32),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
