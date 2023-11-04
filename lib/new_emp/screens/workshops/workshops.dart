import 'package:flutter/material.dart';
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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
