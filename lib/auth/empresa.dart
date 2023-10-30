import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:NEEEICUM/main.dart';
import 'package:firebase_database/firebase_database.dart';

class EmpresaPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  final VoidCallback LogInUpdate;
  const EmpresaPage(
      {super.key, required this.showLoginPage, required this.LogInUpdate});

  @override
  State<EmpresaPage> createState() => _EmpresaPage();
}

class _EmpresaPage extends State<EmpresaPage> {
  String logo = "assets/images/logo_w.png";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //controllers
  final _emailCont = TextEditingController();
  final _passCont = TextEditingController();
  final _passConfCont = TextEditingController();
  final _userName = TextEditingController();
  final _phone = TextEditingController();
  bool hidePassword = true;
  bool hidePasswordConfirm = true;

  //display
  void displayError(String error) {
    showDialog(
      context: context,
      builder: (context) => Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          height: 75,
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

  //signIn Func

  Future signUp() async {
    String errorName = '0';

    User? user;

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

    navigatorKey.currentState!.popUntil((route) => route.isFirst);

    if (errorName != '0') {
      displayError(errorName);
    }
  }

  @override
  void dispose() {
    _passCont.dispose();
    _emailCont.dispose();
    _phone.dispose();
    _passConfCont.dispose();
    _userName.dispose();
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
                    color: Colors.white,
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

//nam
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    /*decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),*/
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0), //20
                      child: TextField(
                        controller: _passCont,
                        style: const TextStyle(color: Colors.black),
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Empresa',
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
                ),

                const SizedBox(height: 10),

                //Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    /*decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),*/
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0), //20
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
                ),

                //Conf
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: signUp,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 241, 133, 25),
                          border: Border.all(
                              color: Color.fromARGB(255, 241, 133, 25)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            "Sign In",
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
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já estás registado?',
                      style: TextStyle(color: Colors.white),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.showLoginPage,
                        child: Text(
                          'Faz login',
                          style: TextStyle(
                            color: Colors.blue[200],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
