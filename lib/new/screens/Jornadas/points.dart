import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deep_collection/deep_collection.dart';

class PointsPage extends StatefulWidget {
  const PointsPage({super.key});
  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  String uname = "";
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("users/${FirebaseAuth.instance.currentUser?.uid.trim()}");
  Map datamap = {};

  void initState() {
    super.initState();
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child("jeepoints");
    Stream<DatabaseEvent> stream =
        dbRef.orderByChild('points').limitToLast(25).onValue;
    stream.listen((DatabaseEvent event) {
      updateInfo(event.snapshot.children);
    });

    Stream<DatabaseEvent> stream2 = ref.onValue;
    stream2.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      getname(data);
    });
  }

  void updateInfo(data) {
    if (mounted) {
      setState(() {
        datamap.clear();
        data.forEach((child) {
          datamap[child.key] = child.value;
        });
      });
    }
  }

  void getname(data) {
    if (mounted) {
      setState(() {
        uname = data['name'];
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFEEF1F8),
        body: (datamap.isNotEmpty && (datamap.length >= 3))
            ? StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref()
                    .child("jeepoints")
                    .orderByChild('points')
                    .limitToLast(23)
                    .onValue,
                builder: (context, snap) {
                  if (snap.hasData) {
                    Iterable<DataSnapshot> data = snap.data!.snapshot.children;
                    datamap.clear();
                    for (var child in data) {
                      datamap[child.key] = child.value;
                    }
                    datamap = datamap.deepReverse();

                    return Stack(
                      children: [
                        SafeArea(
                          bottom: false,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //const SizedBox(height: 40),
                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 60,
                                          bottom: 20,
                                          left: 20,
                                          right: 20),
                                      child: Text(
                                        "LEADERBOARD",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium!
                                            .copyWith(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),

                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: datamap.keys.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return StreamBuilder(
                                      stream: FirebaseDatabase.instance
                                          .ref()
                                          .child("users")
                                          .child(datamap.keys
                                              .elementAt(index)
                                              .toString())
                                          .onValue,
                                      builder: (context, snap2) {
                                        Map data2 = {};
                                        if (snap2.hasData) {
                                          data2 =
                                              snap2.data!.snapshot.value as Map;
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20, top: 10),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 20),
                                                    child: Text(
                                                      datamap.values
                                                          .elementAt(
                                                              index)["points"]
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.13,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.08,
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                if (index == 0)
                                                                  Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.13,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.08,
                                                                    child: Image
                                                                        .asset(
                                                                            "assets/images/Gold.png"),
                                                                  ),
                                                                if (index == 1)
                                                                  Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.13,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.07,
                                                                    child: Image
                                                                        .asset(
                                                                            "assets/images/Silver.png"),
                                                                  ),
                                                                if (index == 2)
                                                                  Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.13,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.06,
                                                                    child: Image
                                                                        .asset(
                                                                            "assets/images/Bronze.png"),
                                                                  ),
                                                                if (index > 2)
                                                                  Text(
                                                                      '${index + 1}',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20)),
                                                                if (index > 2)
                                                                  Icon(
                                                                      Icons
                                                                          .circle,
                                                                      size: 7.5)
                                                              ]),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
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
                                                                EdgeInsets.all(
                                                                    0),
                                                            child: data2[
                                                                        "avatar"] ==
                                                                    null
                                                                ? CircleAvatar(
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            61,
                                                                            60,
                                                                            60),
                                                                    backgroundImage:
                                                                        AssetImage(
                                                                            "assets/images/logo_w.png"),
                                                                  )
                                                                : CircleAvatar(
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            61,
                                                                            60,
                                                                            60),
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                            data2["avatar"].toString()),
                                                                  ),
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .grey,
                                                                    blurRadius:
                                                                        30,
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            7.5))
                                                              ],
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      66,
                                                                      66,
                                                                      66),
                                                              /*border: Border.all(
                                        color: Color.fromARGB(255, 66, 66, 66), // Border color
                                        width: 2.0, // Border width
                                                                  )*/
                                                              /*borderRadius: const BorderRadius.all(
                                                                  Radius.circular(20),
                                                        ),*/
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  right: 30),
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.45,
                                                            child: Text(
                                                              data2["name"]
                                                                  .toString(),
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
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                              ],
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
                              return (snap.data!.snapshot.value != null)
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20.0),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20, top: 10),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2,
                                            decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 216, 216, 216),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey,
                                                      blurRadius: 20,
                                                      offset: Offset(0, 7.5))
                                                ],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 20),
                                                    child: Text(
                                                      "${snap.data!.snapshot.value.toString()}",
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
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
                                                                  left: 10),
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
                                                                EdgeInsets.all(
                                                                    0),
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Color
                                                                      .fromARGB(
                                                                          255,
                                                                          61,
                                                                          60,
                                                                          60),
                                                              backgroundImage:
                                                                  AssetImage(
                                                                      "assets/images/logo_w.png"),
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .grey,
                                                                    blurRadius:
                                                                        30,
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            7.5))
                                                              ],
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      66,
                                                                      66,
                                                                      66),
                                                              /*border: Border.all(
                                                color: Color.fromARGB(255, 66, 66, 66), // Border color
                                                width: 2.0, // Border width
                                                                          )*/
                                                              /*borderRadius: const BorderRadius.all(
                                                                          Radius.circular(20),
                                                                ),*/
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  right: 30),
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.45,
                                                            child: Text(
                                                              uname,
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container();
                            }),
                      ],
                    );
                  } else {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              scale: 2,
                              image:
                                  AssetImage("assets/images/logo_w_grey.png"))),
                      child: const Center(
                        child: Text(
                          "Não há utilizadores com pontos...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    );
                  }
                },
              )
            : Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        scale: 2,
                        image: AssetImage("assets/images/logo_w_grey.png"))),
                child: const Center(
                  child: Text(
                    "Aguarda pela competição",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
              ));
  }
}
