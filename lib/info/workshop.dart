import 'dart:ffi';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'regis.dart';

class Workshop extends StatefulWidget {
  final String cardtype;
  const Workshop({super.key, required this.cardtype});

  @override
  State<Workshop> createState() => _WorkshopState();
}

class _WorkshopState extends State<Workshop> {
  Map datamap = {};

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
    "ADD",
    "REGISTADO",
    "Sem stock",
  ];

  late StreamSubscription<DatabaseEvent> callback;
  Map mainData = {};
  int regStage = 0;
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();

  @override
  void initState() {
    super.initState();
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child(widget.cardtype);
    Stream<DatabaseEvent> stream = dbRef.orderByChild('date').onValue;
    stream.listen((DatabaseEvent event) {
      updateInfo(event.snapshot.children);
    });
  }

  void openCard(key) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Regis(cardtype: widget.cardtype, index: key)),
    );
  }

  Future register(Map data, int index) async {
    String key = datamap.keys.elementAt(index).toString();
    String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
    String? name = FirebaseAuth.instance.currentUser?.displayName;

    DatabaseReference nameref = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(uid.toString())
        .child("name");

    DataSnapshot nameSnapshot = await nameref.get();
    if (nameSnapshot.value != null) {
      name = nameSnapshot.value.toString();
    }

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child(widget.cardtype)
        .child(key)
        .child("reg")
        .child(uid.toString());

    await ref.set({
      "appear": false,
      "name": name,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 0x36, 0x34, 0x32),
      body: datamap.isNotEmpty
          ? (widget.cardtype == "parcerias"
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 1 / 1,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2),
                  itemCount: datamap.keys.length,
                  itemBuilder: (BuildContext context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => openCard(datamap.keys.elementAt(index)),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: (datamap[datamap.keys.elementAt(index)]
                                                ["img"] ==
                                            "" ||
                                        datamap[datamap.keys.elementAt(index)]
                                                ["img"] ==
                                            null)
                                    ? Image.asset("assets/images/logo_w.png")
                                    : Image.network(
                                        datamap[datamap.keys.elementAt(index)]
                                            ["img"],
                                        scale: 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : widget.cardtype == "kits"
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 270,
                              childAspectRatio: 1 / 1.6,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2),
                      itemCount: datamap.keys.length,
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () =>
                                  openCard(datamap.keys.elementAt(index)),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: (datamap[datamap.keys
                                                            .elementAt(index)]
                                                        ["img"] ==
                                                    "" ||
                                                datamap[datamap.keys
                                                            .elementAt(index)]
                                                        ["img"] ==
                                                    null)
                                            ? Image.asset(
                                                "assets/images/logo_w.png")
                                            : Image.network(
                                                datamap[datamap.keys
                                                    .elementAt(index)]["img"],
                                                scale: 1),
                                      ),
                                      Text(
                                        datamap[datamap.keys.elementAt(index)]
                                            ["name"],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${datamap[datamap.keys.elementAt(index)]["price"]} €",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      FloatingActionButton.extended(
                                          backgroundColor: datamap[datamap.keys.elementAt(index)]
                                                      ["stock"] ==
                                                  "0"
                                              ? (Colors.red)
                                              : (datamap[datamap.keys.elementAt(index)]
                                                          .containsKey("reg") &&
                                                      datamap[datamap.keys.elementAt(index)]
                                                              ["reg"]
                                                          .containsKey(uid))
                                                  ? Colors.green
                                                  : Color.fromARGB(
                                                      255, 241, 133, 25),
                                          icon: Icon(Icons.add_shopping_cart),
                                          onPressed: () {
                                            if (datamap[datamap.keys
                                                        .elementAt(index)]
                                                    ["stock"] !=
                                                "0") {
                                              register(
                                                  datamap[datamap.keys
                                                      .elementAt(index)],
                                                  index);
                                            }
                                          },
                                          label: datamap[datamap.keys.elementAt(index)]
                                                      ["stock"] ==
                                                  "0"
                                              ? (Text('SEM STOCK'))
                                              : (datamap[datamap.keys.elementAt(index)]
                                                          .containsKey("reg") &&
                                                      datamap[datamap.keys.elementAt(index)]
                                                              ["reg"]
                                                          .containsKey(uid))
                                                  ? Text("RESERVADO")
                                                  : Text("ADD"))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: datamap.keys.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, right: 10.0, left: 10.0),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () =>
                                  openCard(datamap.keys.elementAt(index)),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: SizedBox(
                                        width: 80,
                                        child: (datamap[datamap.keys
                                                            .elementAt(index)]
                                                        ["img"] ==
                                                    "" ||
                                                datamap[datamap.keys
                                                            .elementAt(index)]
                                                        ["img"] ==
                                                    null)
                                            ? Image.asset(
                                                "assets/images/logo_w.png")
                                            : Image.network(
                                                datamap[datamap.keys
                                                    .elementAt(index)]["img"],
                                                scale: 1),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20,
                                                  bottom: 5,
                                                  right: 20),
                                              child: Text(
                                                datamap[datamap.keys
                                                    .elementAt(index)]["name"],
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            widget.cardtype != "avisos"
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 20.0,
                                                        vertical: 0),
                                                    child: Text(
                                                      DateFormat("dd/MM").format(
                                                          DateTime.parse(
                                                              datamap[datamap
                                                                      .keys
                                                                      .elementAt(
                                                                          index)]
                                                                  ["date"])),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            widget.cardtype != "avisos"
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 20.0,
                                                        vertical: 0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          DateFormat("HH:mm").format(
                                                              DateTime.parse(
                                                                  datamap[datamap
                                                                          .keys
                                                                          .elementAt(
                                                                              index)]
                                                                      [
                                                                      "date"])),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                        (widget.cardtype ==
                                                                "jee")
                                                            ? Expanded(
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  child: Text(
                                                                    "${datamap[datamap.keys.elementAt(index)]["points"]} pontos",
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : const SizedBox()
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ))
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      scale: 2,
                      image: AssetImage("assets/images/logo_w_grey.png"))),
              child: const Center(
                child: Text(
                  "Ainda não temos nada para te mostrar",
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
