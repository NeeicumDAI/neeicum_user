import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

void criarVisita(){

}

class VisitasPage extends StatefulWidget{
  const VisitasPage({super.key});

  @override
  State<VisitasPage> createState() => VisitasPageState();
}

class VisitasPageState extends State<VisitasPage>{
  Map datamap = {};
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();

  @override
  void initState(){
    super.initState();
    DatabaseReference ref = FirebaseDatabase.instance.ref().
                            child('users').child(uid.toString()).child('visitas');
    Stream<DatabaseEvent> stream = ref.orderByChild('data').onValue;
    stream.listen((DatabaseEvent event) {
      updateInfo(event.snapshot.children);
    });
  }

  void updateInfo(data){
    if(mounted){
      setState(() {
        datamap.clear();
        data.forEach((child) {
          datamap[child.key] = child.value;
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
      body: datamap.isNotEmpty 
        ? //if datamap.isNotEmpty
        ListView.builder(
          shrinkWrap: true,
          itemCount: datamap.keys.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 10.0, left: 10.0),
              child: Container(),
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