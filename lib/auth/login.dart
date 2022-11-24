import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neeicum/main.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showSignUpPage;
  const LoginPage({super.key, required this.showSignUpPage});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  String logo = "assets/images/logo_w.png";

  //controllers
  final _emailCont = TextEditingController();
  final _passCont = TextEditingController();

  //display
  void displayError(String error) {
    showDialog(
      context: context,
      builder: (context) => Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          height: 75,
          decoration: const BoxDecoration(
            color: Colors.indigo,
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
      print(e.message);
      errorName = e.message.toString();
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);

    if (errorName != '0') {
      displayError(errorName);
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
                        color: Colors.indigo,
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
                                  hintText: 'Email',
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
                Padding(
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
                        obscureText: true,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        border: Border.all(color: Colors.indigo),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não estás registado ainda? '),
                    GestureDetector(
                      onTap: widget.showSignUpPage,
                      child: Text(
                        'Regista-te ',
                        style: TextStyle(
                          color: Colors.blue[200],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
