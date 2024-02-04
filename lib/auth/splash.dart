import 'package:NEEEICUM/main.dart';
import 'package:NEEEICUM/new/entry_point.dart';
import 'package:NEEEICUM/new_emp/entry_pointemp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:NEEEICUM/auth/signup.dart';
import 'package:NEEEICUM/auth/empresa.dart';
import 'login.dart';


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String logo = "assets/images/logo_w.png";
  bool loginPage = true;
  bool Empresa = false;
  bool Emp_LoggedIn = false;

  void toggleScreen() {
    setState(() {
      loginPage = !loginPage;
      Empresa = false;
    });
  }

  void toggleEmpresaScreen() {
    setState(() {
      Empresa = !Empresa;
      loginPage = false;
    });
  }

  void toggleEmpLogIn() {
    setState(() {
      Emp_LoggedIn = !Emp_LoggedIn;
    });
  }

  void toggleEmpLogIn2() {
    Emp_LoggedIn = !Emp_LoggedIn;
  }

  void setToken() async {
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
  }

  @override
  Widget build(BuildContext context) {
    empresa = prefs.getString("empresa") ?? "";
    empresaId = prefs.getString("empresaId") ?? "";
    if (empresa != "") {
      Emp_LoggedIn = true;
      print("Empresa selecionada: " + empresa);
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 149, 137, 125),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (Emp_LoggedIn) {
              return EntryPointEmp(LogInUpdate: toggleEmpLogIn2);
            } else {
              print(Emp_LoggedIn);
              return const EntryPoint();
            }
          } else {
            if (loginPage) {
              return LoginPage(
                showSignUpPage: toggleScreen,
                showSignEmpresaPage: toggleEmpresaScreen,
              );
            }
            if (Empresa) {
              return EmpresaPage(
                  showLoginPage: toggleScreen, LogInUpdate: toggleEmpLogIn);
            } else {
              return SignUpPage(showLoginPage: toggleScreen);
            }
          }
        },
      ),
    );
  }
}
