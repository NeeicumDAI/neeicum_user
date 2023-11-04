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
  final passwordController = TextEditingController();
  bool hide = true;
  String empresa = "";
  List<String> empresas = [];

  List<String> passwords = [];
  Map _empresas = {};
  String dropEmpresa = "";

  //controllers

  bool hidePassword = true;
  bool hidePasswordConfirm = true;

  void initState() {
    super.initState();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('empresas');
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
      var data = event.snapshot.value;
      data = data ?? {};
      updateInfo(data as Map);
    });

    DatabaseReference dbRefEmp =
        FirebaseDatabase.instance.ref().child('empresas');
    Stream<DatabaseEvent> streamEmp = dbRefEmp.onValue;
    streamEmp.listen((DatabaseEvent event) {
      var data = event.snapshot.value;
      data = data ?? {};
      updateInfoPasswords(data as Map);
    });
  }

  void updateInfoPasswords(data) {
    if (mounted) {
      Map datamap = {};
      setState(() {
        data.forEach((key, values) {
          datamap[key] = values;
          passwords.add(datamap[key]["password"]);
        });
      });
    }
  }

  void updateInfo(data) {
    if (mounted) {
      Map datamap = {};
      _empresas.clear();
      empresas = [];
      setState(() {
        data.forEach((key, values) {
          datamap[key] = values;
          empresas.add(datamap[key]["name"]);
        });
      });
    }
  }

  int findIndexForEmpresa(String nomeEmpresa) {
    int _index = -1;
    int currentIndex = 0;
    for (currentIndex = 0; currentIndex < empresas.length; currentIndex++) {
      if (empresas[currentIndex] == nomeEmpresa) _index = currentIndex;
    }

    print(_index);
    return _index;
  }

  void showLimitExceededSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              size: 32, // Adjust the size of the icon as needed.
              color: Colors.white, // Adjust the icon color as needed.
            ),
            SizedBox(width: 10), // Add some spacing between the icon and text.
            Text(
              'Wrong password. Try again',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18, // Adjust the font size of the text as needed.
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), // Adjust the border radius as needed.
            topRight:
                Radius.circular(20), // Adjust the border radius as needed.
          ),
        ), // Adjust the duration as needed.
      ),
    );
  }

  Future signIn() async {
    String errorName = '0';
    empresa = dropEmpresa;
    hide = true;
    showDialog(
      context: context,
      builder: ((context) => Scaffold(
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
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );

    if (passwordController.text == passwords[findIndexForEmpresa(empresa)]) {
      widget.LogInUpdate();
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "neeicum.dai@gmail.com",
          password: "Y*QJclC303Ye",
        );
      } on FirebaseAuthException catch (e) {
        print(e.message);
        errorName = e.message.toString();
      }
    } else {
      showLimitExceededSnackbar(context);
    }

    /*
    * função usa o metodo de sign in com email e password e tenta enviar 
    * os dados para a autenticação da firebase para efetuar o login
    * se não conseguir fazer login ocorre um erro e 
    * a função displayError é chamada
    */

    navigatorKey.currentState!.popUntil((route) => route.isFirst);

    if (errorName != '0') {
      displayError(errorName);
    }
  }

  Padding selectEmpresa() {
    print(passwords);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.only(right: 23.5, left: 15, top: 8),
          child: DropdownButton(
            borderRadius: BorderRadius.circular(15),
            value: dropEmpresa.isNotEmpty ? dropEmpresa : null,
            //icon: Container(),
            style: const TextStyle(color: Colors.black),
            underline: Container(
              //width: 30,
              color: Colors.white,
            ),
            onChanged: ((String? valueemp) {
              setState(() {
                dropEmpresa = valueemp!;
              });
            }),
            items: empresas.map<DropdownMenuItem<String>>((String valueemp) {
              return DropdownMenuItem<String>(
                value: valueemp,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    valueemp,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

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

  @override
  void dispose() {
    passwordController.dispose();
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
                selectEmpresa(),

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
                        controller: passwordController,
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
                      onTap: signIn,
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
                      'És aluno?',
                      style: TextStyle(color: Colors.white),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.showLoginPage,
                        child: Text(
                          ' Faz login',
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
