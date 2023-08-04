import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VisitasPage extends StatefulWidget{
  const VisitasPage({super.key});

  @override
  State<VisitasPage> createState() => VisitasPageState();
}

class VisitasPageState extends State<VisitasPage>{
  Map datamap = {};
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users")
    .child(FirebaseAuth.instance.currentUser!.uid.trim().toString());
  final _desc = TextEditingController();
  final _data = TextEditingController();
  final _name = TextEditingController();
  final _socio = TextEditingController();
  final _admInfo = TextEditingController();
  DateTime dateTime = DateTime.now();
  int confirm = 1;

  List<Color> colorList = [
    const Color.fromARGB(255, 241, 133, 25), // confirm = 0 -> esperar confirmação
    Colors.green, // confirm = 1 -> visita confirmada
    Colors.red, // confirm = 2 -> visita recusada
  ];

  List<String> textList = [
    "Agendamento Pendente. Cancelar?", // confirm = 0
    "Visita Confirmada", // confirm = 1
    "Visita Recusada", // confirm = 2
  ];

  void getUData(uData){
    if(mounted){
      setState(() {
        _name.text = uData["name"];
        _socio.text = uData["n_socio"];
      });
    }
  }

  Future sendData() async{
    final newKey = FirebaseDatabase.instance.ref().child("visitas").push().key;
    DatabaseReference ref = FirebaseDatabase.instance.ref("visitas/${newKey.toString()}");

    if(_data.text.isEmpty){
      print("É obrigatório definir uma data.");
    }else if(_desc.text.length > 30){
      print("Limite de caratéres alcançado. Limite: 30");
    }else{
      await ref.set({
        'data': _data.text.trim().toString(),
        'desc': _desc.text.isNotEmpty ? _desc.text.trim().toString() : "",
        'uid': FirebaseAuth.instance.currentUser!.uid.trim().toString(),
        '_confirm': 0,
      });
    }
  }

  // DATE TIME PICKER
  Future pickDateTime() async {
    DateTime? date = await pickDate();
    if (date == null) return;

    TimeOfDay? time = await pickTime();
    if (time == null) return;

    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    this.dateTime = dateTime;
    _data.text = dateTime.toString();
  }

  Future<DateTime?> pickDate() => showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100));

  Future<TimeOfDay?> pickTime() => showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute));
  // -------------------

  void deleteVisita(){

  }

  void criarVisita(){
     showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          scrollable: true,
          title: const Text("Marcar visita"),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _desc,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  StatefulBuilder(
                    builder: (context, inState){
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                          )
                        ),
                        onPressed: () async {
                          await pickDateTime();
                        },
                        child: Text(
                          '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute}'
                        )
                      );
                    } 
                  ),
                  const SizedBox(height: 10),
                  StatefulBuilder(
                    builder: (context, inState){
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 241, 133, 25),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          sendData();
                          _data.clear();
                          _desc.clear();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Criar visita'),
                      );
                    }
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget showVisita(){
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          scale: 2,
          image: AssetImage("assets/images/logo_w_grey.png")
        )
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  _name.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 20,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 70, vertical: 5
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 241, 133, 25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: const BoxDecoration(boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black54,
                    blurRadius: 15.0,
                    offset: Offset(0.0, 0.75))
              ]),
              child: QrImage(
                data: uid!.trim(),
                padding: const EdgeInsets.all(5),
                backgroundColor: Colors.white,
                size: 150,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Text(
                  (_socio.text != '') ?
                  "Nº Socio: ${_socio.text}" :
                  "Obtém o teu Nº socio",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 20,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 70, vertical: 5
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 241, 133, 25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              (datamap["data"].toString() != "") ?
              datamap["data"].toString() :
              "",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16
              )
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 70, vertical: 5
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 241, 133, 25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              (datamap["desc"].toString() != "") ?
              datamap["desc"].toString() :
              "",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if(confirm == 0){
                      deleteVisita();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorList[confirm],
                      border: Border.all(
                        color: colorList[confirm],
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Center(
                      child: Text(
                        textList[confirm].toString(),
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
            Text(
              (confirm == 0 || confirm == 1) ?
              "A visita não pode ser cancelada após ser confirmada pelo núcleo.":
              "",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              (confirm == 1 || confirm == 2) ?
              datamap["adminInfo"].toString() :
              "",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState(){
    super.initState();
    DatabaseReference dbref = FirebaseDatabase.instance.ref().child("visitas");
    Stream<DatabaseEvent> vstream = dbref.onValue;
    Stream<DatabaseEvent> ustream = userRef.onValue;

    vstream.listen((DatabaseEvent event) {
      updateInfo(event.snapshot.children);
    });

    ustream.listen((DatabaseEvent event) {
      getUData(event.snapshot.value);
    });
  }

  void updateInfo(data){
    if(mounted){
      setState(() {
        datamap.clear();
        data.forEach((child){
          if(child.value["uid"] == FirebaseAuth.instance.currentUser!.uid.trim().toString()){
            datamap[child] = child.value;
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visitas"),
      ),
      body: datamap.isNotEmpty 
        ? //if datamap.isNotEmpty
        showVisita()
        : // else
        Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      scale: 2,
                      image: AssetImage("assets/images/logo_w_grey.png"))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "Ainda não tens visitas marcadas",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => criarVisita(),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 241, 133, 25),
                            border: Border.all(
                              color: const Color.fromARGB(255, 241, 133, 25),
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: const Center(
                            child: Text(
                              "Marcar Visita",
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
                  )
                ],
              )
            ),
    );
  }
}