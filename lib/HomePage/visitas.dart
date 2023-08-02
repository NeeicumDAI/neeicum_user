import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

Widget criarVisita(){
  return AlertDialog();
}

class VisitasPage extends StatefulWidget{
  const VisitasPage({super.key});

  @override
  State<VisitasPage> createState() => VisitasPageState();
}

class VisitasPageState extends State<VisitasPage>{
  Map fullDatamap = {}, datamap = {};
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  DatabaseReference vref = FirebaseDatabase.instance.ref().child('visitas');
  final _desc = TextEditingController();
  final _data = TextEditingController();
  final _uid = TextEditingController();

  @override
  void initState(){
    super.initState();
    Stream<DatabaseEvent> stream = vref.orderByChild('data').onValue;
    
    stream.listen((DatabaseEvent event) {
      updateInfo(event.snapshot.children);
    });
  }

  void updateInfo(data){
    if(mounted){
      setState(() {
        fullDatamap.clear();
        datamap.clear();
        data.forEach((child) {
          fullDatamap[child.keys] = child.value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visitas"),
        actions: [IconButton(onPressed: () => criarVisita(), icon: const Icon(Icons.add)), 
                  const SizedBox(width: 10,)],
      ),
      body: fullDatamap.isNotEmpty 
        ? //if datamap.isNotEmpty
        ListView.builder(
          shrinkWrap: true,
          itemCount: datamap.keys.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 10.0, left: 10.0),
              child: Container( // container com info da visita

              ),
            );
          },
        )
        : // else
        Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      scale: 2,
                      image: AssetImage("assets/images/logo_w_grey.png"))),
              child: const Center(
                child: Text(
                  "Ainda não tens visitas marcadas",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
    );
  }
}