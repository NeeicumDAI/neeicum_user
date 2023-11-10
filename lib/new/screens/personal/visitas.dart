//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class VisitasPage extends StatefulWidget {
  const VisitasPage({super.key});

  @override
  State<VisitasPage> createState() => _VisitasPageState();
}

class _VisitasPageState extends State<VisitasPage> {
  Map datamap = {};
  Map uMap = {};
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  DatabaseReference userRef = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(FirebaseAuth.instance.currentUser!.uid.trim().toString());
  final _desc = TextEditingController();
  final _data = TextEditingController();

  DateTime dateTime = DateTime.now();

  List<Color> colorList = [
    const Color.fromARGB(255, 66, 66, 66), // confirm = 0 -> esperar confirmação
    Colors.green, // confirm = 1 -> visita confirmada
    Colors.red, // confirm = 2 -> visita recusada
  ];

  List<String> textList = [
    "Agendamento Pendente. Cancelar?", // confirm = 0
    "Visita Confirmada", // confirm = 1
    "Visita Recusada", // confirm = 2
  ];

  void getUData(uData) {
    if (mounted) {
      setState(() {
        uMap = uData;
      });
    }
  }

  Future sendData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("visitas/$uid");

    if (_data.text.isEmpty) {
      print("É obrigatório definir uma data.");
    } else if (_desc.text.length > 30) {
      print("Limite de caratéres alcançado. Limite: 30");
    } else {
      await ref.set({
        'data': _data.text.trim().toString(),
        'desc': _desc.text.isNotEmpty ? _desc.text.trim().toString() : "",
        'confirm': 0,
        'adminInfo': "",
      });
    }
  }

  // DATE TIME PICKER
  Future pickDateTime() async {
    DateTime? date = await pickDate();
    if (date == null) return;

    TimeOfDay? time = await pickTime();
    if (time == null) return;

    final dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

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

  Widget deleteVisita(BuildContext context) {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("visitas")
        .child(FirebaseAuth.instance.currentUser!.uid.trim());

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('Cancelar visita?'),
      content: const Text('Tens a certeza que queres cancelar a visita?'),
      actions: <Widget>[
        FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () {
            ref.remove();
            Navigator.pop(context);
            setState(() {});
            datamap.clear();
          },
          child: const Icon(Icons.done, color: Colors.white),
        ),
        FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
            if (mounted) {
              setState(() {});
            }
          },
          child: const Icon(Icons.close, color: Colors.white),
        )
      ],
    );
  }

  void criarVisita() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            scrollable: true,
            title: const Text(
              "MARCAÇÃO",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: _desc,
                        maxLength: 30,
                        maxLines: 2,
                        minLines: 1,
                        style:
                            TextStyle(color: Color.fromARGB(255, 66, 66, 66)),
                        decoration: InputDecoration(
                          filled: true, // This fills the background
                          fillColor: Colors.white,
                          labelText: 'Descrição (opcional)',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 66, 66, 66),
                              )),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 66, 66, 66),
                              )),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    StatefulBuilder(builder: (context, inState) {
                      return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.only(
                                  left: 0, right: 0, top: 20, bottom: 20),
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0))),
                          onPressed: () async {
                            await pickDateTime();
                            inState(() {});
                          },
                          child: Container(
                            width: 200,
                            height: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                ),
                                SizedBox(width: 10),
                                Text(
                                    style: TextStyle(fontSize: 15),
                                    '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute}'),
                              ],
                            ),
                          ));
                    }),
                    const SizedBox(height: 5),
                    StatefulBuilder(builder: (context, inState) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          textStyle: TextStyle(fontSize: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Set rounded borders
                          ),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          sendData();
                          _data.clear();
                          _desc.clear();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 161,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.bookmark_add_rounded),
                              SizedBox(
                                width: 5,
                              ),
                              const Text('Criar visita'),
                            ],
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget showVisita() {
    return Container(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          scale: 1,
                          image: AssetImage("assets/images/logo_w_grey.png"))),
                ),
              ),
              Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Column(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: MediaQuery.of(context).size.width / 2 * 0.2,
                        color: Color.fromARGB(255, 66, 66, 66),
                      ),
                      Text(
                        (datamap["data"].toString() != "")
                            ? DateFormat("dd/MM")
                                .format(DateTime.parse(datamap["data"]))
                            : "",
                      )
                    ],
                  ),
                  SizedBox(width: 40),
                  Column(
                    children: [
                      Icon(Icons.access_time_filled_rounded,
                          size: MediaQuery.of(context).size.width / 2 * 0.2,
                          color: Color.fromARGB(255, 66, 66, 66)),
                      Text(
                        (datamap["data"].toString() != "")
                            ? DateFormat("HH:mm")
                                .format(DateTime.parse(datamap["data"]))
                            : "",
                      )
                    ],
                  ),
                  SizedBox(width: 40),
                  Column(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: MediaQuery.of(context).size.width / 2 * 0.2,
                        color: Color.fromARGB(255, 66, 66, 66),
                      ),
                      Text("2-1.01")
                    ],
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Text(
                (datamap["desc"].toString() != "")
                    ? datamap["desc"].toString()
                    : "",
                style: const TextStyle(
                  color: Color.fromARGB(255, 66, 66, 66),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if (datamap["confirm"] == 0 || datamap["confirm"] == 2) {
                        showDialog(
                            context: context,
                            builder: (context) => deleteVisita(context));
                        setState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorList[datamap["confirm"]],
                        border: Border.all(
                          color: colorList[datamap["confirm"]],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          textList[datamap["confirm"]].toString(),
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
                (datamap["confirm"] == 0)
                    ? "A visita não pode ser cancelada após ser confirmada pelo núcleo.\nEstá atento para saberes se a visita foi confirmada!"
                    : (datamap["confirm"] == 1)
                        ? "A visita não pode ser cancelada após ser confirmada pelo núcleo."
                        : "",
                style: const TextStyle(
                  color: Color.fromARGB(255, 66, 66, 66),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                (datamap["confirm"] == 1 || datamap["confirm"] == 2)
                    ? datamap["adminInfo"].toString()
                    : "",
                style: const TextStyle(
                  color: Color.fromARGB(255, 66, 66, 66),
                  fontSize: 30,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    DatabaseReference dbref = FirebaseDatabase.instance.ref("visitas/$uid");
    Stream<DatabaseEvent> vstream = dbref.onValue;
    Stream<DatabaseEvent> ustream = userRef.onValue;
    vstream.listen((DatabaseEvent event) {
      updateInfo(event.snapshot.value);
    });
    ustream.listen((DatabaseEvent event) {
      getUData(event.snapshot.value);
    });
    super.initState();
  }

  void updateInfo(data) {
    if (mounted) {
      setState(() {
        datamap = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F8),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "VISITAS",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ),
                  datamap.isNotEmpty
                      ? //if datamap.isNotEmpty
                      showVisita()
                      : // else
                      Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 4),
                          child: Center(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => criarVisita(),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 66, 66, 66),
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 66, 66, 66),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
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
                              ),
                              const SizedBox(height: 10),
                              const Center(
                                child: Text(
                                  "Precisas de ir à sala do NEEEICUM? Marca Já a tua visita.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
