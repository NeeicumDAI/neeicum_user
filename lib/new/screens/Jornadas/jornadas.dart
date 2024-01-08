import 'package:NEEEICUM/new/screens/Jornadas/brindes.dart';
import 'package:NEEEICUM/new/screens/Jornadas/participa%C3%A7oes.dart';
import 'package:flutter/material.dart';
import 'agenda.dart';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'dart:ffi';

enum Status { open, registered, full, closed, registereddandclosed, appear }

class JornadasPage extends StatefulWidget {
  const JornadasPage({super.key});

  @override
  State<JornadasPage> createState() => _JornadasPageState();
}

class _JornadasPageState extends State<JornadasPage> {
  //ScrollController _scrollController1 = ScrollController();
  Map datamap = {};
  int regStage = 0;
  late StreamSubscription<DatabaseEvent> callback;
  int coins = 0;
  Map mainData = {};
  Map gerirJee = {};
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();

  @override
  void initState() {
    super.initState();
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      double minScrollExtent = _scrollController1.position.minScrollExtent;
      double maxScrollExtent = _scrollController1.position.maxScrollExtent;

      animateToMaxMin(maxScrollExtent, minScrollExtent, maxScrollExtent, 20,
          _scrollController1);
    });*/

    DatabaseReference dbRefEmp =
        FirebaseDatabase.instance.ref().child('empresas');
    Stream<DatabaseEvent> streamEmp = dbRefEmp.orderByChild('date').onValue;
    streamEmp.listen((DatabaseEvent event) {
      updateInfoEmpresas(event.snapshot.children);
    });

    DatabaseReference ref = FirebaseDatabase.instance.ref().child("gerirJEE");
    Stream<DatabaseEvent> streamJEE = ref.onValue;
    streamJEE.listen((DatabaseEvent event) {
      updateInfojee(event.snapshot.value);
    });

    checkIMG().then((_) {
      return checkCV();
    }).then((_) {
      return checkEmpresas();
    }).then((_) {
      return checkAcred();
    }).then((_) {
      addCoins(coins);
      coins = 0;
    });

    /* checkIMG();
    checkCV();
    checkEmpresas();
    checkAcred();
    addCoins(coins);
    coins = 0;*/
  }

  Future<void> checkIMG() async {
    DatabaseReference flagIMG = FirebaseDatabase.instance
        .ref()
        .child('flags')
        .child(uid.toString())
        .child('hasIMG');

    DatabaseReference ProfileIMG = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(uid.toString())
        .child('avatar');

    final studentIMG = await flagIMG.get();
    final avatar = await ProfileIMG.get();

    if (studentIMG.exists) {
      bool flag = (studentIMG.value) as bool;
      if (!flag) {
        if (avatar.exists) {
          flagIMG.set(true);
          coins += 10;
          print(coins);
        }
      }
    }
  }

  Future<void> checkCV() async {
    DatabaseReference flagIMG = FirebaseDatabase.instance
        .ref()
        .child('flags')
        .child(uid.toString())
        .child('hasCV');

    DatabaseReference ProfileIMG = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(uid.toString())
        .child('cv');

    final studentCV = await flagIMG.get();
    final cv = await ProfileIMG.get();

    if (studentCV.exists) {
      bool flag = (studentCV.value) as bool;
      if (!flag) {
        if (cv.exists) {
          flagIMG.set(true);
          coins += 10;
        }
      }
    }
  }

  Future<void> checkEmpresas() async {
    DatabaseReference allEMP = FirebaseDatabase.instance
        .ref()
        .child('flags')
        .child(uid.toString())
        .child('allEMP');

    DatabaseReference points = FirebaseDatabase.instance
        .ref()
        .child('jee')
        .child('giveaway')
        .child(uid.toString());

    final flagallEMP = await allEMP.get();
    final hasALL = await points.get();

    if (flagallEMP.exists) {
      bool flag = (flagallEMP.value) as bool;
      if (!flag) {
        if (hasALL.exists) {
          allEMP.set(true);
          coins += 10;
        }
      }
    }
  }

  Future<void> checkAcred() async {
    DatabaseReference acred = FirebaseDatabase.instance
        .ref()
        .child('flags')
        .child(uid.toString())
        .child('hasACRED');

    DatabaseReference points = FirebaseDatabase.instance
        .ref()
        .child('jeepoints')
        .child(uid.toString());

    final flagAcred = await acred.get();
    final hasAcred = await points.get();

    if (flagAcred.exists) {
      bool flag = (flagAcred.value) as bool;
      if (!flag) {
        if (hasAcred.exists) {
          acred.set(true);
          coins += 10;
        }
      }
    }
  }

  void addCoins(int coins) async {
    DatabaseReference student = FirebaseDatabase.instance
        .ref()
        .child('neeeicoins')
        .child(uid.toString());

    final studentCoins = await student.child('coins').get();

    if (studentCoins.exists) {
      int addCoins = (studentCoins.value) as int;
      addCoins += coins;
      student.child('coins').set(addCoins);
    }
  }

  void updateInfoEmpresas(data) {
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

  void updateInfojee(data) {
    if (mounted) {
      setState(() {
        gerirJee = data;
      });
    }
  }

  void launchURL(url) async {
    var uri = Uri.parse("https://$url");
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } else {}
  }

  /*animateToMaxMin(double max, double min, double direction, int seconds,
      ScrollController scrollController) {
    scrollController
        .animateTo(direction,
            duration: Duration(seconds: seconds), curve: Curves.linear)
        .then((value) {
      direction = direction == max ? min : max;
      animateToMaxMin(max, min, direction, seconds, scrollController);
    });
  }*/

  Widget openEmpresa(int index) => makeDismissible(
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
                                fontSize: MediaQuery.of(context).size.width /
                                    2 *
                                    0.2),
                          ),
                          datamap[datamap.keys.elementAt(index)]["sponsor"] ==
                                  "Main"
                              ? ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      //begin: Alignment.centerLeft,
                                      //end: Alignment.centerRight,
                                      colors: [
                                        Color.fromARGB(255, 2, 184, 216),
                                        Colors.blue.shade100
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    "${datamap[datamap.keys.elementAt(index)]["sponsor"]} Sponsor",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                2 *
                                                0.2),
                                  ),
                                )
                              : datamap[datamap.keys.elementAt(index)]
                                          ["sponsor"] ==
                                      "Gold"
                                  ? ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.orange,
                                            Colors.yellow
                                          ],
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        "${datamap[datamap.keys.elementAt(index)]["sponsor"]} Sponsor",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2 *
                                                0.2),
                                      ),
                                    )
                                  : ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.grey,
                                            Colors.grey.shade300
                                          ],
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        "${datamap[datamap.keys.elementAt(index)]["sponsor"]} Sponsor",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2 *
                                                0.2),
                                      ),
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
                          SizedBox(height: 30),
                          Center(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (datamap[datamap.keys.elementAt(index)]
                                                  ["linkedin"]
                                              .toString() !=
                                          'null' &&
                                      datamap[datamap.keys.elementAt(index)]
                                                  ["linkedin"]
                                              .toString() !=
                                          '')
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => {
                                            launchURL(datamap[datamap.keys
                                                        .elementAt(index)]
                                                    ["linkedin"]
                                                .toString()),
                                          },
                                          child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                /*image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/facebook.png")),*/
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey,
                                                      blurRadius: 20,
                                                      offset: Offset(0, 5))
                                                ],
                                                color: Colors.orange,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 7.5,
                                                      vertical: 7.5),
                                                  child: Image.asset(
                                                      "assets/images/linkedin.png",
                                                      scale: 0.2),
                                                ),
                                              )),
                                        )
                                      ],
                                    ),
                                  if (datamap[datamap.keys.elementAt(index)]
                                                  ["instagram"]
                                              .toString() !=
                                          'null' &&
                                      datamap[datamap.keys.elementAt(index)]
                                                  ["instagram"]
                                              .toString() !=
                                          '')
                                    Row(
                                      children: [
                                        if (datamap[datamap.keys
                                                        .elementAt(index)]
                                                    ["linkedin"]
                                                .toString() !=
                                            'null')
                                          SizedBox(width: 30),
                                        GestureDetector(
                                          onTap: () => {
                                            launchURL(datamap[datamap.keys
                                                        .elementAt(index)]
                                                    ["instagram"]
                                                .toString()),
                                          },
                                          child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                /*image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/facebook.png")),*/
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey,
                                                      blurRadius: 20,
                                                      offset: Offset(0, 5))
                                                ],
                                                color: Colors.orange,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 7.5,
                                                      vertical: 7.5),
                                                  child: Image.asset(
                                                      "assets/images/instagram.png",
                                                      scale: 0.2),
                                                ),
                                              )),
                                        ),
                                        /*datamap[datamap.keys.elementAt(index)]
                                                      ["facebook"]
                                                  .toString() ==
                                              'null'
                                          ? Container(
                                              height: 40,
                                              width: 40,
                                              child: Image.asset(
                                                  "assets/images/instagram.png"),
                                            )
                                          : Container(
                                              height: 0,
                                            )*/
                                      ],
                                    ),
                                  if (datamap[datamap.keys.elementAt(index)]
                                                  ["link"]
                                              .toString() !=
                                          'null' &&
                                      datamap[datamap.keys.elementAt(index)]
                                                  ["link"]
                                              .toString() !=
                                          '')
                                    Row(
                                      children: [
                                        if (datamap[datamap.keys
                                                            .elementAt(index)]
                                                        ["linkedin"]
                                                    .toString() !=
                                                'null' ||
                                            datamap[datamap.keys
                                                            .elementAt(index)]
                                                        ["instagram"]
                                                    .toString() !=
                                                'null')
                                          SizedBox(width: 30),
                                        GestureDetector(
                                          onTap: () => {
                                            launchURL(datamap[datamap.keys
                                                    .elementAt(index)]["link"]
                                                .toString()),
                                          },
                                          child: Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                /*image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/facebook.png")),*/
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey,
                                                      blurRadius: 20,
                                                      offset: Offset(0, 5))
                                                ],
                                                color: Colors.orange,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 7.5,
                                                      vertical: 7.5),
                                                  child: Image.asset(
                                                      "assets/images/web.png",
                                                      scale: 0.2),
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  if (datamap[datamap.keys.elementAt(index)]
                                                  ["facebook"]
                                              .toString() !=
                                          'null' &&
                                      datamap[datamap.keys.elementAt(index)]
                                                  ["facebook"]
                                              .toString() !=
                                          '')
                                    Center(
                                      child: Row(
                                        children: [
                                          if (datamap[datamap.keys
                                                              .elementAt(index)]
                                                          ["linkedin"]
                                                      .toString() !=
                                                  'null' ||
                                              datamap[datamap.keys
                                                              .elementAt(index)]
                                                          ["link"]
                                                      .toString() !=
                                                  'null' ||
                                              datamap[datamap.keys
                                                              .elementAt(index)]
                                                          ["instagram"]
                                                      .toString() !=
                                                  'null')
                                            SizedBox(width: 30),
                                          GestureDetector(
                                            onTap: () => {
                                              launchURL(datamap[datamap.keys
                                                          .elementAt(index)]
                                                      ["facebook"]
                                                  .toString()),
                                            },
                                            child: Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  /*image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/facebook.png")),*/
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey,
                                                        blurRadius: 20,
                                                        offset: Offset(0, 5))
                                                  ],
                                                  color: Colors.orange,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 7.5,
                                                        vertical: 7.5),
                                                    child: Image.asset(
                                                        "assets/images/facebook.png",
                                                        scale: 0.2),
                                                  ),
                                                )),
                                          ),
                                        ],
                                      ),
                                    )
                                ]),
                          ),
                          SizedBox(height: 40),
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
                      image: DecorationImage(
                          image: NetworkImage(
                              datamap[datamap.keys.elementAt(index)]["img"])),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 20,
                            offset: Offset(0, 20))
                      ],
                      color: Color.fromARGB(255, 234, 225, 211),
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
        ),
      );

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(onTap: () {}, child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFEEF1F8),
        body: gerirJee["show"]
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
                              "JORNADAS",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 0),
                              child: (gerirJee["banner"] == null ||
                                      gerirJee["banner"] == "")
                                  ? Image.asset("assets/images/logo_w.png",
                                      height: 180)
                                  : Image.network(
                                      gerirJee["banner"].toString(),
                                      height: 180,
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "Empresas",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            height: 130,
                            child: ListView.builder(
                                clipBehavior: Clip.none,
                                //physics: NeverScrollableScrollPhysics(),
                                //controller: _scrollController1,
                                padding:
                                    EdgeInsets.only(/*top: 5, bottom: 35.0*/),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: datamap.keys.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: GestureDetector(
                                        onTap: (() => showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (context) =>
                                                openEmpresa(index))),
                                        child: Stack(
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                height: 125,
                                                width: 125,
                                                decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 234, 225, 211),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Color.fromARGB(
                                                            255, 183, 181, 181),
                                                        blurRadius: 30,
                                                        offset: Offset(0, 10))
                                                  ],
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(15)),
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 0.0,
                                                        vertical: 0),
                                                    child: Image.network(
                                                        datamap[datamap.keys
                                                            .elementAt(
                                                                index)]["img"],
                                                        scale: 1),
                                                  ),
                                                )),
                                            Container(
                                              height: 140,
                                              width: 130,
                                              child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 0,
                                                          vertical: 0),
                                                      height: 30,
                                                      width: 60,
                                                      decoration: datamap[datamap
                                                                      .keys
                                                                      .elementAt(
                                                                          index)]
                                                                  ["sponsor"] ==
                                                              "Main"
                                                          ? BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .centerLeft,
                                                                end: Alignment
                                                                    .centerRight,
                                                                colors: [
                                                                  Color
                                                                      .fromARGB(
                                                                          255,
                                                                          2,
                                                                          184,
                                                                          216),
                                                                  Colors.blue
                                                                      .shade100
                                                                ],
                                                              ),
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
                                                              //color: Colors.grey,
                                                              /*boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              blurRadius: 30,
                                                              offset:
                                                                  Offset(0, 10))
                                                        ],*/
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          10)),
                                                            )
                                                          : datamap[datamap.keys
                                                                          .elementAt(
                                                                              index)]
                                                                      [
                                                                      "sponsor"] ==
                                                                  "Gold"
                                                              ? BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    begin: Alignment
                                                                        .centerLeft,
                                                                    end: Alignment
                                                                        .centerRight,
                                                                    colors: [
                                                                      Colors
                                                                          .orange,
                                                                      Colors
                                                                          .yellow
                                                                    ],
                                                                  ),
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

                                                                  //color: Colors.grey,
                                                                  /*boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              blurRadius: 30,
                                                              offset:
                                                                  Offset(0, 10))
                                                        ],*/
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              10)),
                                                                )
                                                              : BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    begin: Alignment
                                                                        .centerLeft,
                                                                    end: Alignment
                                                                        .centerRight,
                                                                    colors: [
                                                                      Colors
                                                                          .grey,
                                                                      Colors
                                                                          .grey
                                                                          .shade300
                                                                    ],
                                                                  ),
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
                                                                  //color: Colors.grey,
                                                                  /*boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              blurRadius: 30,
                                                              offset:
                                                                  Offset(0, 10))
                                                        ],*/
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              10)),
                                                                ),
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      0.0,
                                                                  vertical: 0),
                                                          child: Text(
                                                            datamap[datamap.keys
                                                                    .elementAt(
                                                                        index)]
                                                                ["sponsor"],
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ))),
                                            ),
                                          ],
                                        ),
                                      ));
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "Outros",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AgendaPage()),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Icon(
                                            Icons.arrow_forward_ios_rounded),
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  padding: EdgeInsets.all(0),
                                                  child: Icon(
                                                    size: 40,
                                                    Icons
                                                        .electric_bolt_outlined,
                                                    color: Color.fromARGB(
                                                        255, 66, 66, 66),
                                                  ),
                                                  /*decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                blurRadius: 15,
                                                                offset: Offset(
                                                                    0, 7.5))
                                                          ],
                                                          color: Color.fromARGB(
                                                              255, 66, 66, 66),
                                                          /*border: Border.all(
                                              color: Color.fromARGB(255, 66, 66, 66), // Border color
                                              width: 2.0, // Border width
                                                                        )*/
                                                          /*borderRadius: const BorderRadius.all(
                                                                        Radius.circular(20),
                                                              ),*/
                                                        ),*/
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 30),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Text(
                                                    "Atividades",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const participacoesPage()),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Icon(
                                            Icons.arrow_forward_ios_rounded),
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  padding: EdgeInsets.all(0),
                                                  child: Icon(
                                                    size: 40,
                                                    Icons.article_rounded,
                                                    color: Color.fromARGB(
                                                        255, 66, 66, 66),
                                                  ),
                                                  /*decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                blurRadius: 15,
                                                                offset: Offset(
                                                                    0, 7.5))
                                                          ],
                                                          color: Color.fromARGB(
                                                              255, 66, 66, 66),
                                                          /*border: Border.all(
                                              color: Color.fromARGB(255, 66, 66, 66), // Border color
                                              width: 2.0, // Border width
                                                                        )*/
                                                          /*borderRadius: const BorderRadius.all(
                                                                        Radius.circular(20),
                                                              ),*/
                                                        ),*/
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 30),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Text(
                                                    "Objetivos",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10, bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const brindesPage()),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Icon(
                                            Icons.arrow_forward_ios_rounded),
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  padding: EdgeInsets.all(0),
                                                  child: Icon(
                                                    size: 40,
                                                    Icons.emoji_events_rounded,
                                                    color: Color.fromARGB(
                                                        255, 66, 66, 66),
                                                  ),
                                                  /*decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                blurRadius: 15,
                                                                offset: Offset(
                                                                    0, 7.5))
                                                          ],
                                                          color: Color.fromARGB(
                                                              255, 66, 66, 66),
                                                          /*border: Border.all(
                                              color: Color.fromARGB(255, 66, 66, 66), // Border color
                                              width: 2.0, // Border width
                                                                        )*/
                                                          /*borderRadius: const BorderRadius.all(
                                                                        Radius.circular(20),
                                                              ),*/
                                                        ),*/
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 30),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Text(
                                                    "Brindes JEE",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          StreamBuilder(
                              stream: FirebaseDatabase.instance
                                  .ref()
                                  .child("jeepoints")
                                  .child(uid.toString())
                                  .child('points')
                                  .onValue,
                              builder: (context, snap) {
                                return (snap.hasData &&
                                        !snap.hasError &&
                                        snap.data?.snapshot.value != null)
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 10,
                                            bottom: 10),
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2,
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 0),
                                                            child: Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.13,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.13,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              child: Icon(
                                                                size: 40,
                                                                Icons
                                                                    .badge_rounded,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              /*decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              10)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color:
                                                                        Colors.grey,
                                                                    blurRadius: 15,
                                                                    offset: Offset(
                                                                        0, 7.5))
                                                              ],
                                                              color: Color.fromARGB(
                                                                  255, 66, 66, 66),
                                                              /*border: Border.all(
                                                  color: Color.fromARGB(255, 66, 66, 66), // Border color
                                                  width: 2.0, // Border width
                                                                            )*/
                                                              /*borderRadius: const BorderRadius.all(
                                                                            Radius.circular(20),
                                                                  ),*/
                                                            ),*/
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    right: 30),
                                                            child: Container(
                                                              /*width: MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.,*/
                                                              child: Text(
                                                                "Estás acreditado",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 10,
                                            bottom: 10),
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2,
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 0),
                                                            child: Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.13,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.13,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              child: Icon(
                                                                size: 40,
                                                                Icons
                                                                    .badge_rounded,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              /*decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              10)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color:
                                                                        Colors.grey,
                                                                    blurRadius: 15,
                                                                    offset: Offset(
                                                                        0, 7.5))
                                                              ],
                                                              color: Color.fromARGB(
                                                                  255, 66, 66, 66),
                                                              /*border: Border.all(
                                                  color: Color.fromARGB(255, 66, 66, 66), // Border color
                                                  width: 2.0, // Border width
                                                                            )*/
                                                              /*borderRadius: const BorderRadius.all(
                                                                            Radius.circular(20),
                                                                  ),*/
                                                            ),*/
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    right: 30),
                                                            child: Container(
                                                              /*width: MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.,*/
                                                              child: Text(
                                                                "Não estás acreditado",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                              }),
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
                              "JORNADAS",
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
                                  "Aguarda pelas próximas jornadas",
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
