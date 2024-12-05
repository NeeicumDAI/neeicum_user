import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LinkedlnPage extends StatefulWidget {
  const LinkedlnPage({super.key});

  @override
  State<LinkedlnPage> createState() => _LinkedlnPageState();
}

class _LinkedlnPageState extends State<LinkedlnPage> {
  final TextEditingController  _linkedin = TextEditingController();

  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("users/${FirebaseAuth.instance.currentUser?.uid.trim()}");

@override
  void initState() {
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
       
      final data = event.snapshot.value;
     if (data != null && data is Map) {
        _linkedin.text = data['linkedin']== null ? "" : data['linkedin'].toString();
      } else {
        print("Dados inválidos ou nulos recebidos: $data");
      }
    });

    super.initState();
  }
  
   Future UpdateData() async {

     await ref.update({
      "linkedin" : _linkedin.text
     });
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F8),
     body: Stack(
                    children: [
                      SafeArea(
                        bottom:false,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 60),
                          Center(
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width / 1.2,
                              height:
                                  MediaQuery.of(context).size.width / 1.2,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      scale: 1,
                                      image: AssetImage(
                                          "assets/images/logo_w_grey.png"))),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20),
                            child: Text(
                              "Ainda não tens LinkedIn",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                          ),
                          Text("Insere já o teu link do perfil do LinkedIn",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),),
                          Padding(
                            padding: EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.all(25),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () async {
                                    
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 30,
                                            offset: Offset(0, 10))
                                      ],
                                      color: const Color.fromARGB(
                                          255, 66, 66, 66),
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 66, 66, 66)),
                                      borderRadius:
                                          BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                       child: TextField(
                                                  controller: _linkedin,
                                                  decoration: InputDecoration(
                                                  hintText:
                                                        'https://www.exemplo.com',
                                                  ),
                                                ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                           Padding(
                   padding: const EdgeInsets.only(top: 8.0, bottom: 30.0),
                   child: Center(
                     child: Container(
                          width: 300,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 30,
                                  offset: Offset(0, 10))
                            ],
                            color: Colors.orange,
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: GestureDetector(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.add,
                                    size: 30.0,
                                    color: Color(0xFFEEF1F8),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                //  Expanded(
                                    Text(
                                      "Atualizar LinkedIn",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFFEEF1F8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                 // ),
                                ],
                              ),
                              onTap:() {
                                UpdateData();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                   ),
                 ),
                          
                        ],
                          )
                        )
                        
                      ),
                       Positioned(
                                      top: 16,
                                      left: 16,
                                      child: SafeArea(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (() {
                        Navigator.pop(context);
                                          }),
                                          child: Container(
                        //margin: const EdgeInsets.only(left: 16),
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 3),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded),
                                          ),
                                        ),
                                      ),
                                    ),
                    ],
                    
                  ),
      
           
    );
  }
}