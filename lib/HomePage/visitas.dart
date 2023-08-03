import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class VisitasPage extends StatefulWidget{
  const VisitasPage({super.key});

  @override
  State<VisitasPage> createState() => VisitasPageState();
}

class VisitasPageState extends State<VisitasPage>{
  Map datamap = {};
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  DatabaseReference vref = FirebaseDatabase.instance.ref("visitas/${FirebaseAuth.instance.currentUser?.uid.trim()}");
  final _desc = TextEditingController();
  final _data = TextEditingController();
  DateTime dateTime = DateTime.now();

  Future sendData() async{
    final newKey = FirebaseDatabase.instance.ref().child("visitas").set(uid);
    DatabaseReference ref = FirebaseDatabase.instance.ref("visitas/${newKey.toString()}");

    if(_data.text.isEmpty){
      print("É obrigatório definir uma data!");
    }else if(_desc.text.length > 30){
      print("Limite de caratéres: 30");
    }else{
      /*await ref.set({
        'data': _data.text.trim(),
        'desc': _desc.text.trim(),
      });*/
      print(_data.text.toString());
      print(_desc.text.toString());
    }
  }

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
        datamap.clear();
        data.forEach((child) {
          datamap[child.keys] = child.value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visitas"),
        actions: [
          IconButton(
            onPressed: () => criarVisita(),
            icon: const Icon(Icons.add)
          ), 
          const SizedBox(width: 10)],
      ),
      body: datamap.isNotEmpty 
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