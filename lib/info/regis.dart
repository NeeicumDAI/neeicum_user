import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Status { open, registered, full, closed, registereddandclosed, appear }

enum kitStatus { add, registered, withoutstock }

class Regis extends StatefulWidget {
  final String cardtype;
  final String index;
  const Regis({super.key, required this.cardtype, required this.index});

  @override
  State<Regis> createState() => _RegisState();
}

class _RegisState extends State<Regis> {
  List<Color> optionsColor = [
    Color.fromARGB(255, 241, 133, 25),
    Colors.green,
    Colors.red,
    Colors.red,
    Colors.green,
    Colors.green,
  ];
  List<IconData> optionsIcons = [
    Icons.add_circle_outline,
    Icons.check,
    Icons.warning,
    Icons.highlight_remove,
    Icons.check,
    Icons.thumb_up_alt,
  ];
  List<String> optionsText = [
    "Inscreve-te",
    "Estás registado.\nEliminar inscrição?",
    "Vagas esgotadas",
    "Inscrições fechadas",
    "Estás registado\nInscrições fechadas",
    "Obrigado por participar"
  ];
  List<String> kitsoptionsText = [
    "Add",
    "Estás registado.\nEliminar inscrição?",
    "Sem stock",
  ];
  late StreamSubscription<DatabaseEvent> callback;
  Map mainData = {};
  int regStage = 0;
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();

  @override
  void initState() {
    super.initState();
    DatabaseReference dbRef = FirebaseDatabase.instance
        .ref()
        .child(widget.cardtype)
        .child(widget.index.toString());
    Stream<DatabaseEvent> stream = dbRef.onValue;
    callback = stream.listen((DatabaseEvent event) {
      var data = event.snapshot.value;
      mainData = (data as Map);
      updateInfo(mainData);
    });
  }

  void updateInfo(data) {
    if (mounted &&
        (widget.cardtype != "parcerias" &&
            widget.cardtype != "avisos" &&
            widget.cardtype != "kits")) {
      setState(() {
        regStage = Status.open.index;
        if (data["closed"]) {
          if (data.containsKey("reg") && data["reg"].containsKey(uid)) {
            regStage = Status.registereddandclosed.index;
          } else {
            regStage = Status.closed.index;
          }
        } else if (data.containsKey("reg")) {
          if (data["reg"].containsKey(uid)) {
            if (data["reg"][uid]["appear"]) {
              regStage = Status.appear.index;
            } else {
              regStage = Status.registered.index;
            }
          } else if (data["reg"].length >= int.parse(data["max"].toString())) {
            regStage = Status.full.index;
          }
        }
      });
    } else {
      if (widget.cardtype == "kits") {
        setState(() {
          regStage = kitStatus.add.index;
          if ((data["closed"]) || data["stock"] == getSize(data)) {
            if (data.containsKey("reg") && data["reg"].containsKey(uid)) {
              regStage = kitStatus.registered.index;
            } else {
              regStage = kitStatus.withoutstock.index;
            }
          } else if (data.containsKey("reg")) {
            if (data["reg"].containsKey(uid)) {
              regStage = kitStatus.registered.index;
            } else if (data["stock"] == 0) {
              regStage = kitStatus.withoutstock.index;
            }
          }
        });
      } else {
        setState(() {});
      }
    }
  }

  Future register() async {
    String? name = FirebaseAuth.instance.currentUser?.displayName;
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child(widget.cardtype)
        .child(widget.index.toString())
        .child("reg")
        .child(uid.toString());

    DatabaseReference nameref = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(uid.toString())
        .child("name");

    DataSnapshot nameSnapshot = await nameref.get();
    if (nameSnapshot.value != null) {
      name = nameSnapshot.value.toString();
    }

    await ref.set({
      "appear": false,
      "name": name,
    });
  }

  Future unregister() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child(widget.cardtype)
        .child(widget.index.toString())
        .child("reg")
        .child(uid.toString());
    await ref.remove();
  }

  int getSize(Map datamap){
    if(datamap["reg"] is Map){
      Map temp = datamap["reg"];
      return temp.length;
    }
    return 0;
  }

  @override
  void dispose() {
    super.dispose();
    callback.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 0x36, 0x34, 0x32),
      appBar: AppBar(
        //backgroundColor: const Color.fromARGB(255, 0x01, 0x1f, 0x26),
        title: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            mainData["name"].toString(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 60),
                          child: Image.network(
                              (mainData.isEmpty ||
                                      mainData["img"] == '' ||
                                      mainData["img"] == null)
                                  ? "https://previews.123rf.com/images/kaymosk/kaymosk1804/kaymosk180400006/100130939-error-404-page-not-found-error-with-glitch-effect-on-screen-vector-illustration-for-your-design-.jpg"
                                  : mainData["img"],
                              scale: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          child: Text(
                            mainData["desc"].toString().replaceAll("\\n", "\n"),
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: (widget.cardtype != "parcerias" &&
                                  widget.cardtype != "avisos" &&
                                  widget.cardtype != "kits")
                              ? MaterialButton(
                                  onPressed: () => {
                                    if (regStage == 0)
                                      {register()}
                                    else if (regStage == 1)
                                      {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                scrollable: true,
                                                title:
                                                    const Text('Confirmação'),
                                                content: const Text(
                                                    'Tem a certeza para remover?'),
                                                actions: <Widget>[
                                                  FloatingActionButton(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 241, 133, 25),
                                                    onPressed: () {
                                                      unregister();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Icon(
                                                        Icons.done,
                                                        color: Colors.white),
                                                  ),
                                                  FloatingActionButton(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 241, 133, 25),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white),
                                                  )
                                                ],
                                              );
                                            })
                                      }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: optionsColor[regStage],
                                      border: Border.all(
                                          color: optionsColor[regStage]),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(optionsIcons[regStage],
                                              size: 30.0),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Expanded(
                                            child: Text(
                                              optionsText[regStage]
                                                  .replaceAll("\\n", "\n"),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : (widget.cardtype == "kits")
                                  ? MaterialButton(
                                      onPressed: () => {
                                        if (regStage == 0)
                                          {register()}
                                        else if (regStage == 1)
                                          {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                    scrollable: true,
                                                    title: const Text(
                                                        'Confirmação'),
                                                    content: const Text(
                                                        'Tem a certeza para remover?'),
                                                    actions: <Widget>[
                                                      FloatingActionButton(
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                241, 133, 25),
                                                        onPressed: () {
                                                          unregister();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Icon(
                                                            Icons.done,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      FloatingActionButton(
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                241, 133, 25),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Icon(
                                                            Icons.close,
                                                            color:
                                                                Colors.white),
                                                      )
                                                    ],
                                                  );
                                                })
                                          }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: optionsColor[regStage],
                                          border: Border.all(
                                              color: optionsColor[regStage]),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(optionsIcons[regStage],
                                                  size: 30.0),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  kitsoptionsText[regStage]
                                                      .replaceAll("\\n", "\n"),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
