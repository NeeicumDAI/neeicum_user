import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:NEEEICUM/main.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showSignUpPage;
  const LoginPage({super.key, required this.showSignUpPage});
  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  String logo = "assets/images/logo_w.png";
  bool remember = false;
  bool hidePassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //controllers
  final _emailCont = TextEditingController();
  final _passCont = TextEditingController();

/*
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
  }*/

  //display
  void displayError(String error) {
    showDialog(
      context: context,
      builder: (context) => Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          height: 90,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 241, 133, 25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                error,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //changeUI Func
  void changeUI() {
    setState(() {
      remember = !remember;
    });
  }

  //signIn Func

  Future signIn() async {
    String errorName = '0';
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Image.asset(logo, scale: 20),
              ),
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: '${_emailCont.text.trim()}@alunos.uminho.pt',
        password: _passCont.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      errorName = e.message.toString();
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);

    if (errorName != '0') {
      displayError(errorName);
    }
  }

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: '${_emailCont.text.trim()}@alunos.uminho.pt');
      setState(() {
        remember = false;
      });
      displayError(
          "Password Reset Email sent successfully. May appear in junk");
    } on FirebaseAuthException catch (e) {
      displayError(e.message.toString());
    }
  }

  @override
  void dispose() {
    _passCont.dispose();
    _emailCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //setToken();
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Logo
                Image.asset(logo, scale: 20),
                const SizedBox(height: 20),

                //Name
                const Text(
                  'NEEEICUM App',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 20,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 70, vertical: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 241, 133, 25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                //Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextField(
                              controller: _emailCont,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'aXXXX ou pgXXXX',
                                  hintStyle: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          '@alunos.uminho.pt',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                //Password
                !remember
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextField(
                              controller: _passCont,
                              style: const TextStyle(color: Colors.black),
                              obscureText: hidePassword,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Password',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  suffixIcon: IconButton(
                                    icon: hidePassword
                                        ? Icon(Icons.visibility_off_rounded)
                                        : Icon(Icons.visibility_rounded),
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                  )),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(height: 20),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: remember ? resetPassword : signIn,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 241, 133, 25),
                          border: Border.all(
                              color: Color.fromARGB(255, 241, 133, 25)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            remember ? "Redefine Password" : "Sign in",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                !remember
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Não estás registado ainda? '),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: widget.showSignUpPage,
                              child: Text(
                                'Regista-te ',
                                style: TextStyle(
                                  color: Colors.blue[200],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(height: 10),
                const SizedBox(height: 10),

                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: changeUI,
                    child: Text(
                      remember ? "Voltar a Sign-In" : 'Recuperar password',
                      style: TextStyle(
                        color: Colors.blue[200],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
