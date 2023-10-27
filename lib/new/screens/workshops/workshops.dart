import 'package:flutter/material.dart';
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum Status { open, registered, full, closed, registereddandclosed, appear }

class WorkshopsPage extends StatefulWidget {
  const WorkshopsPage({super.key});

  @override
  State<WorkshopsPage> createState() => _WorkshopsPageState();
}

class _WorkshopsPageState extends State<WorkshopsPage> {
  Map datamap = {};
  late StreamSubscription<DatabaseEvent> callback;
  Map mainData = {};
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
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('workshop');
    Stream<DatabaseEvent> stream = dbRef.orderByChild('date').onValue;
    stream.listen((DatabaseEvent event) {
      updateInfo(event.snapshot.children);
    });
  }

  void updateInfo(data) {
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

  void updateRegis(int index) {
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

  Future register(int index) async {
    String? name = FirebaseAuth.instance.currentUser?.displayName;
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("workshop")
        .child(datamap.keys.elementAt(index).toString())
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

  Future unregister(int index) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("workshop")
        .child(datamap.keys.elementAt(index).toString())
        .child("reg")
        .child(uid.toString());
    await ref.remove();
  }

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(onTap: () {}, child: child),
      );

  Widget openWorkshop(int index) {
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
                          datamap[datamap.keys.elementAt(index)]["name"],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width / 2 * 0.2),
                        ),
                        SizedBox(height: 20),
                        Text(
                          datamap[datamap.keys.elementAt(index)]["desc"]
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
                                        DateTime.parse(datamap[datamap.keys
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
                                        DateTime.parse(datamap[datamap.keys
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
                                    Text(datamap[datamap.keys.elementAt(index)]
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
                                  updateRegis(index),
                                  if (regStage == 0)
                                    {regStage = 1, register(index)}
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
                                                    unregister(index);
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
                    image: (datamap[datamap.keys.elementAt(index)]["img"] ==
                                "" ||
                            datamap[datamap.keys.elementAt(index)]["img"] ==
                                null)
                        ? DecorationImage(
                            image: AssetImage("assets/images/logo_w.png"))
                        : DecorationImage(
                            image: NetworkImage(
                                datamap[datamap.keys.elementAt(index)]["img"])),
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
    print(datamap);
    return Scaffold(
        backgroundColor: const Color(0xFFEEF1F8),
        body: datamap.isNotEmpty
            ? Stack(
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
                              "WORKSHOPS",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                            ),
                          ),
                          Stack(
                            children: [
                              Container(
                                //height: MediaQuery.of(context).size.height,
                                padding: EdgeInsets.all(0),
                                child: ListView.builder(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    //controller: scrollController,
                                    //padding: EdgeInsets.only(/*top: 5, bottom: 35.0*/),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: datamap.keys.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0,
                                            right: 0,
                                            top: 5,
                                            bottom: 5),
                                        child: GestureDetector(
                                          onTap: (() {
                                            setState(() {
                                              updateRegis(index);
                                              showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return openWorkshop(index);
                                                  });
                                            });
                                          }),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                    top: 10,
                                                    left: 27.5,
                                                    right: 20,
                                                  ),
                                                  height: MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.3575 -
                                                      17.5,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.65,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    30),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    30)),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 50, right: 10),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 5),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    datamap[datamap
                                                                        .keys
                                                                        .elementAt(
                                                                            index)]["name"],
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width /
                                                                                27.5),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Text(
                                                                      datamap[datamap
                                                                              .keys
                                                                              .elementAt(index)]
                                                                          [
                                                                          "desc"],
                                                                      style: TextStyle(
                                                                          fontSize: MediaQuery.of(context).size.width /
                                                                              27.5),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  )
                                                                ],
                                                              )),
                                                          Row(
                                                            children: [
                                                              Align(
                                                                alignment: Alignment
                                                                    .bottomLeft,
                                                                child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .calendar_month,
                                                                          size: MediaQuery.of(context).size.width /
                                                                              16,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              66,
                                                                              66,
                                                                              66)),
                                                                      Text(
                                                                        DateFormat("dd/MM").format(DateTime.parse(datamap[datamap
                                                                            .keys
                                                                            .elementAt(index)]["date"])),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                MediaQuery.of(context).size.width / 27.5),
                                                                      )
                                                                    ]),
                                                              ),
                                                              Align(
                                                                alignment: Alignment
                                                                    .bottomCenter,
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .access_time_filled_rounded,
                                                                        size: MediaQuery.of(context).size.width /
                                                                            16,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            66,
                                                                            66,
                                                                            66)),
                                                                    Text(
                                                                      DateFormat("HH:mm").format(DateTime.parse(datamap[datamap
                                                                          .keys
                                                                          .elementAt(
                                                                              index)]["date"])),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.width / 27.5),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment: Alignment
                                                                    .bottomRight,
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .location_on,
                                                                        size: MediaQuery.of(context).size.width /
                                                                            16,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            66,
                                                                            66,
                                                                            66)),
                                                                    Text(
                                                                        datamap[datamap.keys.elementAt(index)]
                                                                            [
                                                                            "sala"],
                                                                        style: TextStyle(
                                                                            fontSize: MediaQuery.of(context).size.width /
                                                                                27.5),
                                                                        overflow:
                                                                            TextOverflow.ellipsis)
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          )

                                                          /*Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .calendar_month,
                                                                  size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      16,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          66,
                                                                          66,
                                                                          66)),
                                                              Text(
                                                                DateFormat(
                                                                        "dd/MM")
                                                                    .format(DateTime.parse(datamap[datamap
                                                                        .keys
                                                                        .elementAt(
                                                                            index)]["date"])),
                                                                style: TextStyle(
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        27.5),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    80,
                                                              ),
                                                              Icon(
                                                                  Icons
                                                                      .access_time_filled_rounded,
                                                                  size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      16,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          66,
                                                                          66,
                                                                          66)),
                                                              Text(
                                                                DateFormat(
                                                                        "HH:mm")
                                                                    .format(DateTime.parse(datamap[datamap
                                                                        .keys
                                                                        .elementAt(
                                                                            index)]["date"])),
                                                                style: TextStyle(
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        27.5),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    80,
                                                              ),
                                                              Icon(
                                                                  Icons
                                                                      .location_on,
                                                                  size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      16,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          66,
                                                                          66,
                                                                          66)),
                                                              Text(
                                                                datamap[datamap
                                                                        .keys
                                                                        .elementAt(
                                                                            index)]
                                                                    ["sala"],
                                                                style: TextStyle(
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        27.5),
                                                              )
                                                            ],
                                                          )*/
                                                        ]),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 20, right: 5),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3575,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3575,
                                                decoration: BoxDecoration(
                                                  image: (datamap[datamap.keys.elementAt(index)]
                                                                  ["img"] ==
                                                              "" ||
                                                          datamap[datamap.keys.elementAt(index)]
                                                                  ["img"] ==
                                                              null)
                                                      ? DecorationImage(
                                                          image: AssetImage(
                                                              "assets/images/logo_w.png"))
                                                      : DecorationImage(
                                                          image: NetworkImage(
                                                              datamap[datamap
                                                                      .keys
                                                                      .elementAt(index)]
                                                                  ["img"])),
                                                  color: Color.fromARGB(
                                                      255, 66, 66, 66),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey,
                                                        blurRadius: 30,
                                                        offset: Offset(0, 10))
                                                  ],
                                                  borderRadius:
                                                      const BorderRadius.all(
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
                          ),
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
              )
            : Stack(
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
                              "WORKSHOPS",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                    left: 20.0, right: 20.0),
                                child: Text(
                                  "Ainda não temos nada para te mostrar",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
              ));
  }
}
