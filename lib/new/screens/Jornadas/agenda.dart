//import 'dart:ffi';

import 'package:NEEEICUM/main.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum Status { open, registered, full, closed, registereddandclosed, appear }

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  Map datamap = {};
  late StreamSubscription<DatabaseEvent> callback;
  int activeList = 1;
  int lastactiveList = 1;
  int first_day = 19;
  Map datamap2 = {};
  Map datamap3 = {};
  Map datamap4 = {};
  bool isDragging = false;
  double phonewidth = 0;
  int regStage = 0;
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();

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

  @override
  void initState() {
    super.initState();
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('jee').child('first_day');
    ;
    Stream<DatabaseEvent> stream = dbRef.orderByChild('date').onValue;
    stream.listen((DatabaseEvent event) {
      updateInfo1(event.snapshot.children);
    });

    DatabaseReference dbRef2 =
        FirebaseDatabase.instance.ref().child('jee').child('second_day');
    ;
    Stream<DatabaseEvent> stream2 = dbRef2.orderByChild('date').onValue;
    stream2.listen((DatabaseEvent event) {
      updateInfo2(event.snapshot.children);
    });

    DatabaseReference dbRef3 =
        FirebaseDatabase.instance.ref().child('jee').child('third_day');
    ;
    Stream<DatabaseEvent> stream3 = dbRef3.orderByChild('date').onValue;
    stream3.listen((DatabaseEvent event) {
      updateInfo3(event.snapshot.children);
    });

    DatabaseReference dbRef4 =
        FirebaseDatabase.instance.ref().child('jee').child('last_day');
    ;
    Stream<DatabaseEvent> stream4 = dbRef4.orderByChild('date').onValue;
    stream4.listen((DatabaseEvent event) {
      updateInfo4(event.snapshot.children);
    });
    getday();
  }

  Future getday() async {
    DatabaseReference dayref =
        FirebaseDatabase.instance.ref().child("gerirJEE").child("first_day");

    DataSnapshot daySnapshot = await dayref.get();
    if (daySnapshot.value != null) {
      first_day = int.parse(daySnapshot.value.toString());
    }
  }

  void updateInfo1(data) {
    if (mounted) {
      setState(() {
        datamap.clear();
        data.forEach((child) {
          if (child.value["show"]) {
            datamap[child.key] = child.value;
          }
        });
      });
    }
  }

  void updateInfo2(data) {
    if (mounted) {
      setState(() {
        datamap2.clear();
        data.forEach((child) {
          if (child.value["show"]) {
            datamap2[child.key] = child.value;
          }
        });
      });
    }
  }

  void updateInfo3(data) {
    if (mounted) {
      setState(() {
        datamap3.clear();
        data.forEach((child) {
          if (child.value["show"]) {
            datamap3[child.key] = child.value;
          }
        });
      });
    }
  }

  void updateInfo4(data) {
    if (mounted) {
      setState(() {
        datamap4.clear();
        data.forEach((child) {
          if (child.value["show"]) {
            datamap4[child.key] = child.value;
          }
        });
      });
    }
  }

  void updateRegis(int index, Map datamap) {
    setState(() {
      regStage = Status.open.index;
      if (datamap[datamap.keys.elementAt(index)]["closed"]) {
        if (datamap[datamap.keys.elementAt(index)].containsKey("reg") &&
            datamap[datamap.keys.elementAt(index)]["reg"].containsKey(uid)) {
          regStage = Status.registereddandclosed.index;
        } else {
          regStage = Status.closed.index;
        }
      } else if (datamap[datamap.keys.elementAt(index)].containsKey("reg")) {
        if (datamap[datamap.keys.elementAt(index)]["reg"].containsKey(uid)) {
          if (datamap[datamap.keys.elementAt(index)]["reg"][uid]["appear"]) {
            regStage = Status.appear.index;
          } else {
            regStage = Status.registered.index;
          }
        } else if (datamap[datamap.keys.elementAt(index)]["reg"].length >=
            int.parse(
                datamap[datamap.keys.elementAt(index)]["max"].toString())) {
          regStage = Status.full.index;
        }
      }
    });
  }

  Future register(int index, String day, Map _datamap) async {
    String? name = FirebaseAuth.instance.currentUser?.displayName;
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("jee")
        .child(day)
        .child(_datamap.keys.elementAt(index).toString())
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

    print(_datamap);

    await ref.set({
      "appear": false,
      "name": name,
    });
  }

  Future unregister(int index, String day, Map _datamap) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("jee")
        .child(day)
        .child(_datamap.keys.elementAt(index).toString())
        .child("reg")
        .child(uid.toString());
    await ref.remove();
  }

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(onTap: () {}, child: child),
      );

  Widget openWorkshop(int index, Map _datamap, String day) {
    return StatefulBuilder(builder: ((context, setState) {
      return makeDismissible(
          child: SingleChildScrollView(
        child: Column(children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 80),
                child: Container(
                  //height: ((MediaQuery.of(context).size.height)),
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.only(top: 120, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _datamap[_datamap.keys.elementAt(index)]["name"],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width / 2 * 0.2),
                        ),
                        SizedBox(height: 20),
                        Text(
                          _datamap[_datamap.keys.elementAt(index)]["desc"]
                              .toString()
                              .replaceAll("\\n", "\n"),
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width /
                                  2 *
                                  0.0680),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      size: MediaQuery.of(context).size.width /
                                          2 *
                                          0.2,
                                      color: Color.fromARGB(255, 66, 66, 66),
                                    ),
                                    Text(DateFormat("dd/MM").format(
                                        DateTime.parse(_datamap[_datamap.keys
                                            .elementAt(index)]["date"])))
                                  ],
                                ),
                                SizedBox(width: 40),
                                Column(
                                  children: [
                                    Icon(Icons.access_time_filled_rounded,
                                        size:
                                            MediaQuery.of(context).size.width /
                                                2 *
                                                0.2,
                                        color: Color.fromARGB(255, 66, 66, 66)),
                                    Text(DateFormat("HH:mm").format(
                                        DateTime.parse(_datamap[_datamap.keys
                                            .elementAt(index)]["date"])))
                                  ],
                                ),
                                SizedBox(width: 40),
                                Column(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: MediaQuery.of(context).size.width /
                                          2 *
                                          0.2,
                                      color: Color.fromARGB(255, 66, 66, 66),
                                    ),
                                    Text(
                                        _datamap[_datamap.keys.elementAt(index)]
                                            ["sala"])
                                  ],
                                ),
                              ]),
                        ),
                        SizedBox(height: 10),
                        Center(
                            child: MaterialButton(
                          onPressed: () => {
                            setState(() => {
                                  updateRegis(index, _datamap),
                                  if (regStage == 0)
                                    {
                                      regStage = 1,
                                      register(index, day, _datamap)
                                    }
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
                                              title: const Text('Confirmação'),
                                              content: const Text(
                                                  'Tem a certeza para remover?'),
                                              actions: <Widget>[
                                                FloatingActionButton(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 241, 133, 25),
                                                  onPressed: () {
                                                    setState(() {
                                                      regStage = 0;
                                                    });
                                                    unregister(
                                                        index, day, _datamap);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Icon(Icons.done,
                                                      color: Colors.white),
                                                ),
                                                FloatingActionButton(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 241, 133, 25),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Icon(Icons.close,
                                                      color: Colors.white),
                                                )
                                              ],
                                            );
                                          }),
                                    },
                                }),
                          },
                          child: Container(
                            width: 300,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 30,
                                    offset: Offset(0, 10))
                              ],
                              color: optionsColor[regStage],
                              border: Border.all(color: optionsColor[regStage]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
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
                                  Expanded(
                                    child: Text(
                                      optionsText[regStage],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFFEEF1F8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                        SizedBox(
                          height: 15,
                        )
                      ]),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 175,
                  width: 175,
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    image: (_datamap[_datamap.keys.elementAt(index)]["img"] ==
                                "" ||
                            _datamap[_datamap.keys.elementAt(index)]["img"] ==
                                null)
                        ? DecorationImage(
                            image: AssetImage("assets/images/logo_w.png"))
                        : DecorationImage(
                            image: NetworkImage(
                                _datamap[_datamap.keys.elementAt(index)]
                                    ["img"])),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 30,
                          offset: Offset(0, 7.5))
                    ],
                    color: Color.fromARGB(255, 66, 66, 66),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 120,
                left: 20,
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
                      child: RotatedBox(
                          quarterTurns: 3,
                          child: Icon(Icons.arrow_back_ios_new_rounded)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ));
    }));
  }

  @override
  Widget build(BuildContext context) {
    phonewidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: const Color(0xFFEEF1F8),
        body: GestureDetector(
          onHorizontalDragStart: (details) {
            setState(() {
              isDragging = true;
              lastactiveList = activeList;
            });
          },
          onHorizontalDragUpdate: (details) {
            if (isDragging) {
              setState(() {
                double dx = details.delta.dx;
                if (dx > 0) {
                  if (activeList > 1) activeList = lastactiveList - 1;
                }
                if (dx < 0) {
                  if (activeList < 4) activeList = lastactiveList + 1;
                }
              });
            }
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              isDragging = false;
            });
          },
          child: Stack(
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
                          "ATIVIDADES",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: Row(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: phonewidth / 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      activeList = 1;
                                    });
                                  },
                                  child: Container(
                                    child: Column(
                                      children: [
                                        AnimatedDefaultTextStyle(
                                          style: TextStyle(
                                            fontSize: activeList == 1 ? 20 : 10,
                                            color: activeList == 1
                                                ? Colors.orange
                                                : Colors.black,
                                          ),
                                          duration:
                                              const Duration(milliseconds: 200),
                                          curve: Curves.easeIn,
                                          child: Text(
                                            "SEG",
                                            /*style: TextStyle(
                                                  fontSize: activeList == 1 ? 50 : 20,
                                                  color: activeList == 1
                                                      ? Colors.orange
                                                      : Colors.black),*/
                                          ),
                                        ),
                                        AnimatedDefaultTextStyle(
                                          style: TextStyle(
                                            fontSize: activeList == 1 ? 30 : 20,
                                            color: activeList == 1
                                                ? Colors.orange
                                                : Colors.black,
                                          ),
                                          duration:
                                              const Duration(milliseconds: 200),
                                          curve: Curves.easeIn,
                                          child: Text(
                                            first_day.toString(),
                                            /*style: TextStyle(
                                                  fontSize: activeList == 1 ? 50 : 20,
                                                  color: activeList == 1
                                                      ? Colors.orange
                                                      : Colors.black),*/
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            /*const SizedBox(
                                height: 40,
                                child: VerticalDivider(
                                  color: Color.fromARGB(255, 66, 66, 66),
                                ),
                              ),*/
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: phonewidth / 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      activeList = 2;
                                    });
                                  },
                                  child: Container(
                                    child: Column(
                                      children: [
                                        AnimatedDefaultTextStyle(
                                          style: TextStyle(
                                            fontSize: activeList == 2 ? 20 : 10,
                                            color: activeList == 2
                                                ? Colors.orange
                                                : Colors.black,
                                          ),
                                          duration:
                                              const Duration(milliseconds: 200),
                                          curve: Curves.easeIn,
                                          child: Text(
                                            "TER",
                                            /*style: TextStyle(
                                                  fontSize: activeList == 1 ? 50 : 20,
                                                  color: activeList == 1
                                                      ? Colors.orange
                                                      : Colors.black),*/
                                          ),
                                        ),
                                        AnimatedDefaultTextStyle(
                                          style: TextStyle(
                                            fontSize: activeList == 2 ? 30 : 20,
                                            color: activeList == 2
                                                ? Colors.orange
                                                : Colors.black,
                                          ),
                                          duration:
                                              const Duration(milliseconds: 200),
                                          curve: Curves.easeIn,
                                          child: Text(
                                            (first_day + 1).toString()
                                                .toString(),
                                            /*style: TextStyle(
                                                  fontSize: activeList == 1 ? 50 : 20,
                                                  color: activeList == 1
                                                      ? Colors.orange
                                                      : Colors.black),*/
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            /*const SizedBox(
                                height: 40,
                                child: VerticalDivider(
                                  color: Color.fromARGB(255, 66, 66, 66),
                                ),
                              ),*/
                            Container(
                              width: phonewidth / 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    activeList = 3;
                                  });
                                },
                                child: Container(
                                  child: Column(
                                    children: [
                                      AnimatedDefaultTextStyle(
                                        style: TextStyle(
                                          fontSize: activeList == 3 ? 20 : 10,
                                          color: activeList == 3
                                              ? Colors.orange
                                              : Colors.black,
                                        ),
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.easeIn,
                                        child: Text(
                                          "QUA",
                                        ),
                                      ),
                                      AnimatedDefaultTextStyle(
                                        style: TextStyle(
                                          fontSize: activeList == 3 ? 30 : 20,
                                          color: activeList == 3
                                              ? Colors.orange
                                              : Colors.black,
                                        ),
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.easeIn,
                                        child: Text(
                                          (first_day + 2).toString(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: phonewidth / 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    activeList = 4;
                                  });
                                },
                                child: Container(
                                  child: Column(
                                    children: [
                                      AnimatedDefaultTextStyle(
                                        style: TextStyle(
                                          fontSize: activeList == 4 ? 20 : 10,
                                          color: activeList == 4
                                              ? Colors.orange
                                              : Colors.black,
                                        ),
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.easeIn,
                                        child: Text(
                                          "QUI",
                                        ),
                                      ),
                                      AnimatedDefaultTextStyle(
                                        style: TextStyle(
                                          fontSize: activeList == 4 ? 30 : 20,
                                          color: activeList == 4
                                              ? Colors.orange
                                              : Colors.black,
                                        ),
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.easeIn,
                                        child: Text(
                                          (first_day + 3).toString(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ),
                      AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: activeList == 1
                              ? datamap.isNotEmpty
                                  ? Stack(
                                      key: ValueKey<int>(1),
                                      children: [
                                        Container(
                                          //height: MediaQuery.of(context).size.height,
                                          padding: EdgeInsets.all(0),
                                          child: ListView.builder(
                                              clipBehavior: Clip.none,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemCount: datamap.keys.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 0,
                                                          right: 0,
                                                          top: 5,
                                                          bottom: 5),
                                                  child: GestureDetector(
                                                    onTap: (() {
                                                      setState(() {
                                                        updateRegis(
                                                            index, datamap);
                                                        showModalBottomSheet(
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            context: context,
                                                            builder: (context) {
                                                              return openWorkshop(
                                                                  index,
                                                                  datamap,
                                                                  "first_day");
                                                            });
                                                      });
                                                    }),
                                                    child: Stack(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                              top: 10,
                                                              left: 27.5,
                                                              right: 20,
                                                            ),
                                                            height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.3575 -
                                                                17.5,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.65,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius: const BorderRadius
                                                                  .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          30),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          30)),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 50,
                                                                      right:
                                                                          10),
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                5),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              datamap[datamap.keys.elementAt(index)]["type"],
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 10,
                                                                            ),
                                                                            Text(datamap[datamap.keys.elementAt(index)]["name"],
                                                                                style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                                overflow: TextOverflow.ellipsis),
                                                                            SizedBox(
                                                                              height: 10,
                                                                            )
                                                                          ],
                                                                        )),
                                                                    Row(
                                                                      children: [
                                                                        Align(
                                                                          alignment:
                                                                              Alignment.bottomLeft,
                                                                          child:
                                                                              Row(children: [
                                                                          /*   Icon(Icons.calendar_month,
                                                                                size: MediaQuery.of(context).size.width / 16,
                                                                                color: Color.fromARGB(255, 66, 66, 66)),
                                                                           Text(
                                                                              DateFormat("dd/MM").format(DateTime.parse(datamap[datamap.keys.elementAt(index)]["date"])),
                                                                              style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                            )*/
                                                                          ]),
                                                                        ),
                                                                        Align(
                                                                          alignment:
                                                                              Alignment.bottomCenter,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(Icons.access_time_filled_rounded, size: MediaQuery.of(context).size.width / 16, color: Color.fromARGB(255, 66, 66, 66)),
                                                                              Text(
                                                                                DateFormat("HH:mm").format(DateTime.parse(datamap[datamap.keys.elementAt(index)]["date"])),
                                                                                style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Align(
                                                                          alignment:
                                                                              Alignment.bottomRight,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Icon(Icons.location_on, size: MediaQuery.of(context).size.width / 16, color: Color.fromARGB(255, 66, 66, 66)),
                                                                              Text(datamap[datamap.keys.elementAt(index)]["sala"], style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5), overflow: TextOverflow.ellipsis)
                                                                            ],
                                                                          ),
                                                                        )
                                                                      ],
                                                                    )
                                                                  ]),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  right: 5),
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.3575,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.3575,
                                                          decoration:
                                                              BoxDecoration(
                                                            image: (datamap[datamap.keys.elementAt(index)]
                                                                            [
                                                                            "img"] ==
                                                                        "" ||
                                                                    datamap[datamap.keys.elementAt(index)]
                                                                            [
                                                                            "img"] ==
                                                                        null)
                                                                ? DecorationImage(
                                                                    image: AssetImage(
                                                                        "assets/images/logo_w.png"))
                                                                : DecorationImage(
                                                                    image: NetworkImage(
                                                                        datamap[datamap.keys.elementAt(index)]
                                                                            ["img"])),
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    66,
                                                                    66,
                                                                    66),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  color: Colors
                                                                      .grey,
                                                                  blurRadius:
                                                                      30,
                                                                  offset:
                                                                      Offset(0,
                                                                          10))
                                                            ],
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    )
                                  : Container()
                              : activeList == 2
                                  ? datamap2.isNotEmpty
                                      ? Stack(
                                          key: ValueKey<int>(2),
                                          children: [
                                            Container(
                                              //height: MediaQuery.of(context).size.height,
                                              padding: EdgeInsets.all(0),
                                              child: ListView.builder(
                                                  clipBehavior: Clip.none,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  //controller: scrollController,
                                                  //padding: EdgeInsets.only(/*top: 5, bottom: 35.0*/),
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      datamap2.keys.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 0,
                                                              right: 0,
                                                              top: 5,
                                                              bottom: 5),
                                                      child: GestureDetector(
                                                        onTap: (() {
                                                          setState(() {
                                                            updateRegis(index,
                                                                datamap2);
                                                            showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return openWorkshop(
                                                                      index,
                                                                      datamap2,
                                                                      "second_day");
                                                                });
                                                          });
                                                        }),
                                                        child: Stack(
                                                          children: [
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .only(
                                                                  top: 10,
                                                                  left: 27.5,
                                                                  right: 20,
                                                                ),
                                                                height: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.3575 -
                                                                    17.5,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.65,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius: const BorderRadius
                                                                      .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              30),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              30)),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              50,
                                                                          right:
                                                                              10),
                                                                  child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 5),
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  datamap2[datamap2.keys.elementAt(index)]["type"],
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Text(datamap2[datamap2.keys.elementAt(index)]["name"], style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5), overflow: TextOverflow.ellipsis),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                )
                                                                              ],
                                                                            )),
                                                                        Row(
                                                                          children: [
                                                                            Align(
                                                                              alignment: Alignment.bottomLeft,
                                                                              child: Row(children: [
                                                                               /* Icon(Icons.calendar_month, size: MediaQuery.of(context).size.width / 16, color: Color.fromARGB(255, 66, 66, 66)),
                                                                                Text(
                                                                                  DateFormat("dd/MM").format(DateTime.parse(datamap2[datamap2.keys.elementAt(index)]["date"])),
                                                                                  style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                                )*/
                                                                              ]),
                                                                            ),
                                                                            Align(
                                                                              alignment: Alignment.bottomCenter,
                                                                              child: Row(
                                                                                children: [
                                                                                  Icon(Icons.access_time_filled_rounded, size: MediaQuery.of(context).size.width / 16, color: Color.fromARGB(255, 66, 66, 66)),
                                                                                  Text(
                                                                                    DateFormat("HH:mm").format(DateTime.parse(datamap2[datamap2.keys.elementAt(index)]["date"])),
                                                                                    style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Align(
                                                                              alignment: Alignment.bottomRight,
                                                                              child: Row(
                                                                                children: [
                                                                                  Icon(Icons.location_on, size: MediaQuery.of(context).size.width / 16, color: Color.fromARGB(255, 66, 66, 66)),
                                                                                  Text(datamap2[datamap2.keys.elementAt(index)]["sala"], style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5), overflow: TextOverflow.ellipsis)
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        )
                                                                      ]),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 20,
                                                                      right: 5),
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.3575,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.3575,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image: (datamap2[datamap2.keys.elementAt(index)]["img"] ==
                                                                            "" ||
                                                                        datamap2[datamap2.keys.elementAt(index)]["img"] ==
                                                                            null)
                                                                    ? DecorationImage(
                                                                        image: AssetImage(
                                                                            "assets/images/logo_w.png"))
                                                                    : DecorationImage(
                                                                        image: NetworkImage(datamap2[datamap2
                                                                            .keys
                                                                            .elementAt(index)]["img"])),
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        66,
                                                                        66,
                                                                        66),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .grey,
                                                                      blurRadius:
                                                                          30,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              10))
                                                                ],
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            20)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ],
                                        )
                                      : Container()
                                  : activeList == 3
                                      ? datamap3.isNotEmpty
                                          ? Stack(
                                              key: ValueKey<int>(3),
                                              children: [
                                                Container(
                                                  //height: MediaQuery.of(context).size.height,
                                                  padding: EdgeInsets.all(0),
                                                  child: ListView.builder(
                                                      clipBehavior: Clip.none,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      //controller: scrollController,
                                                      //padding: EdgeInsets.only(/*top: 5, bottom: 35.0*/),
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          datamap3.keys.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 0,
                                                                  right: 0,
                                                                  top: 5,
                                                                  bottom: 5),
                                                          child:
                                                              GestureDetector(
                                                            onTap: (() {
                                                              setState(() {
                                                                updateRegis(
                                                                    index,
                                                                    datamap3);
                                                                showModalBottomSheet(
                                                                    isScrollControlled:
                                                                        true,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return openWorkshop(
                                                                          index,
                                                                          datamap3,
                                                                          "third_day");
                                                                    });
                                                              });
                                                            }),
                                                            child: Stack(
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  child:
                                                                      Container(
                                                                    margin:
                                                                        EdgeInsets
                                                                            .only(
                                                                      top: 10,
                                                                      left:
                                                                          27.5,
                                                                      right: 20,
                                                                    ),
                                                                    height: MediaQuery.of(context).size.width *
                                                                            0.3575 -
                                                                        17.5,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.65,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius: const BorderRadius
                                                                          .only(
                                                                          topRight: Radius.circular(
                                                                              30),
                                                                          bottomRight:
                                                                              Radius.circular(30)),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              50,
                                                                          right:
                                                                              10),
                                                                      child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment
                                                                              .start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Padding(
                                                                                padding: EdgeInsets.only(left: 5),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Text(
                                                                                      datamap3[datamap3.keys.elementAt(index)]["type"],
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 10,
                                                                                    ),
                                                                                    Text(datamap3[datamap3.keys.elementAt(index)]["name"], style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5), overflow: TextOverflow.ellipsis),
                                                                                    SizedBox(
                                                                                      height: 10,
                                                                                    )
                                                                                  ],
                                                                                )),
                                                                            Row(
                                                                              children: [
                                                                                Align(
                                                                                  alignment: Alignment.bottomLeft,
                                                                                  child: Row(children: [
                                                                                   /* Icon(Icons.calendar_month, size: MediaQuery.of(context).size.width / 16, color: Color.fromARGB(255, 66, 66, 66)),
                                                                                    Text(
                                                                                      DateFormat("dd/MM").format(DateTime.parse(datamap3[datamap3.keys.elementAt(index)]["date"])),
                                                                                      style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                                    )*/
                                                                                  ]),
                                                                                ),
                                                                                Align(
                                                                                  alignment: Alignment.bottomCenter,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Icon(Icons.access_time_filled_rounded, size: MediaQuery.of(context).size.width / 16, color: Color.fromARGB(255, 66, 66, 66)),
                                                                                      Text(
                                                                                        DateFormat("HH:mm").format(DateTime.parse(datamap3[datamap3.keys.elementAt(index)]["date"])),
                                                                                        style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Align(
                                                                                  alignment: Alignment.bottomRight,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Icon(Icons.location_on, size: MediaQuery.of(context).size.width / 16, color: Color.fromARGB(255, 66, 66, 66)),
                                                                                      Text(datamap3[datamap3.keys.elementAt(index)]["sala"], style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5), overflow: TextOverflow.ellipsis)
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            )
                                                                          ]),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              5),
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.3575,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.3575,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image: (datamap3[datamap3.keys.elementAt(index)]["img"] ==
                                                                                "" ||
                                                                            datamap3[datamap3.keys.elementAt(index)]["img"] ==
                                                                                null)
                                                                        ? DecorationImage(
                                                                            image: AssetImage(
                                                                                "assets/images/logo_w.png"))
                                                                        : DecorationImage(
                                                                            image:
                                                                                NetworkImage(datamap3[datamap3.keys.elementAt(index)]["img"])),
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            66,
                                                                            66,
                                                                            66),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Colors
                                                                              .grey,
                                                                          blurRadius:
                                                                              30,
                                                                          offset: Offset(
                                                                              0,
                                                                              10))
                                                                    ],
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(20)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ],
                                            )
                                          : Container()
                                      : datamap4.isNotEmpty
                                          ? Stack(
                                              key: ValueKey<int>(4),
                                              children: [
                                                Container(
                                                  //height: MediaQuery.of(context).size.height,
                                                  padding: EdgeInsets.all(0),
                                                  child: ListView.builder(
                                                      clipBehavior: Clip.none,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      //controller: scrollController,
                                                      //padding: EdgeInsets.only(/*top: 5, bottom: 35.0*/),
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          datamap4.keys.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 0,
                                                                  right: 0,
                                                                  top: 5,
                                                                  bottom: 5),
                                                          child:
                                                              GestureDetector(
                                                            onTap: (() {
                                                              setState(() {
                                                                updateRegis(
                                                                    index,
                                                                    datamap4);
                                                                showModalBottomSheet(
                                                                    isScrollControlled:
                                                                        true,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return openWorkshop(
                                                                          index,
                                                                          datamap4,
                                                                          "last_day");
                                                                    });
                                                              });
                                                            }),
                                                            child: Stack(
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  child:
                                                                      Container(
                                                                    margin:
                                                                        EdgeInsets
                                                                            .only(
                                                                      top: 10,
                                                                      left:
                                                                          27.5,
                                                                      right: 20,
                                                                    ),
                                                                    height: MediaQuery.of(context).size.width *
                                                                            0.3575 -
                                                                        17.5,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.65,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius: const BorderRadius
                                                                          .only(
                                                                          topRight: Radius.circular(
                                                                              30),
                                                                          bottomRight:
                                                                              Radius.circular(30)),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              50,
                                                                          right:
                                                                              10),
                                                                      child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment
                                                                              .start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Padding(
                                                                                padding: EdgeInsets.only(left: 5),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Text(
                                                                                      datamap4[datamap4.keys.elementAt(index)]["type"],
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 10,
                                                                                    ),
                                                                                    Text(datamap4[datamap4.keys.elementAt(index)]["name"], style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5), overflow: TextOverflow.ellipsis),
                                                                                    SizedBox(
                                                                                      height: 10,
                                                                                    )
                                                                                  ],
                                                                                )),
                                                                            Row(
                                                                              children: [
                                                                                Align(
                                                                                  alignment: Alignment.bottomLeft,
                                                                                  child: Row(children: [
                                                                                  /*  Icon(Icons.calendar_month, size: MediaQuery.of(context).size.width / 16, color: Color.fromARGB(255, 66, 66, 66)),
                                                                                    Text(
                                                                                      DateFormat("dd/MM").format(DateTime.parse(datamap4[datamap4.keys.elementAt(index)]["date"])),
                                                                                      style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                                    )*/
                                                                                  ]),
                                                                                ),
                                                                                Align(
                                                                                  alignment: Alignment.bottomCenter,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Icon(Icons.access_time_filled_rounded, size: MediaQuery.of(context).size.width / 16, color: Color.fromARGB(255, 66, 66, 66)),
                                                                                      Text(
                                                                                        DateFormat("HH:mm").format(DateTime.parse(datamap4[datamap4.keys.elementAt(index)]["date"])),
                                                                                        style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Align(
                                                                                  alignment: Alignment.bottomRight,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Icon(Icons.location_on, size: MediaQuery.of(context).size.width / 16, color: Color.fromARGB(255, 66, 66, 66)),
                                                                                      Text(datamap4[datamap4.keys.elementAt(index)]["sala"], style: TextStyle(fontSize: MediaQuery.of(context).size.width / 27.5), overflow: TextOverflow.ellipsis)
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            )
                                                                          ]),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              5),
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.3575,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.3575,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image: (datamap4[datamap4.keys.elementAt(index)]["img"] ==
                                                                                "" ||
                                                                            datamap4[datamap4.keys.elementAt(index)]["img"] ==
                                                                                null)
                                                                        ? DecorationImage(
                                                                            image: AssetImage(
                                                                                "assets/images/logo_w.png"))
                                                                        : DecorationImage(
                                                                            image:
                                                                                NetworkImage(datamap4[datamap4.keys.elementAt(index)]["img"])),
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            66,
                                                                            66,
                                                                            66),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          color: Colors
                                                                              .grey,
                                                                          blurRadius:
                                                                              30,
                                                                          offset: Offset(
                                                                              0,
                                                                              10))
                                                                    ],
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(20)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ],
                                            )
                                          : Container()),
                    ],
                  ),
                ),
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
        ));
  }
}
