import 'package:flutter/material.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum Status { open, registered, full, closed, registereddandclosed, appear }

class brindesPage extends StatefulWidget {
  const brindesPage({super.key});

  @override
  State<brindesPage> createState() => _brindesPageState();
}

class _brindesPageState extends State<brindesPage> {
  Map datamap = {};
  Map prev_datamap = {};
  late StreamSubscription<DatabaseEvent> callback;
  Map mainData = {};
  int regStage = 0;
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();

  @override
  void initState() {
    super.initState();
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('store');
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
                              "BRINDES JEE",
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
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, // Number of columns
                                      crossAxisSpacing:
                                          0, // Spacing between columns
                                      mainAxisSpacing:
                                          0, // Spacing between rows
                                    ),
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
                                        child: Column(
                                          children: [
                                            Stack(
                                              children: [
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20, right: 20),
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.3575,
                                                    width: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.3575,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors
                                                              .grey, // Shadow color
                                                          offset: Offset(0,
                                                              3), // Shadow offset (x, y)
                                                          blurRadius:
                                                              30, // Shadow blur radius
                                                          spreadRadius:
                                                              0, // Spread radius
                                                        ),
                                                      ],
                                                      color: Colors
                                                          .white, // Background color of the circle
                                                    ),
                                                    child: (datamap[datamap.keys.elementAt(index)]
                                                                    ["img"] ==
                                                                "" ||
                                                            datamap[datamap.keys.elementAt(index)]
                                                                    ["img"] ==
                                                                null)
                                                        ? CircleAvatar(
                                                            backgroundColor:
                                                                Color.fromARGB(255, 61, 60, 60),
                                                            backgroundImage: AssetImage("assets/images/logo_w.png"))
                                                        : CircleAvatar(backgroundColor: Color.fromARGB(255, 61, 60, 60), backgroundImage: NetworkImage(datamap[datamap.keys.elementAt(index)]["img"]))),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.08,
                                                      top: 10),
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.325,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.325,
                                                    child: Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0,
                                                                    vertical:
                                                                        0),
                                                            height: 35,
                                                            width: 60,
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    Colors.white

                                                                //color: Colors.grey,
                                                                /*boxShadow: [
                                                            BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                blurRadius: 30,
                                                                offset:
                                                                    Offset(0, 10))
                                                          ],*/
                                                                ),
                                                            child: Center(
                                                              child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          0.0,
                                                                      vertical:
                                                                          0),
                                                                  child: datamap[datamap.keys.elementAt(index)].containsKey(
                                                                              "reg") &&
                                                                          datamap[datamap.keys.elementAt(index)]["reg"]
                                                                              .containsKey(uid)
                                                                      ? Icon(
                                                                          Icons
                                                                              .check,
                                                                          color:
                                                                              Colors.orange,
                                                                        )
                                                                      : Text(
                                                                          "${datamap[datamap.keys.elementAt(index)]["price"].toString()}",
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        )),
                                                            ))),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              datamap[datamap.keys
                                                  .elementAt(index)]["name"],
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ],
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
                  StreamBuilder(
                      stream: FirebaseDatabase.instance
                          .ref()
                          .child("neeeicoins")
                          .child(uid.toString())
                          .child('coins')
                          .onValue,
                      builder: (context, snap) {
                        return (snap.data!.snapshot.value != null)
                            ? Positioned(
                                right: 20,
                                bottom: 20,
                                child: Container(
                                  height: 50,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(0, 3),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10,
                                              left: 10,
                                              right: 5,
                                              bottom: 10),
                                          child: Image.asset(
                                              "assets/images/coin.gif"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10, right: 10),
                                          child: Text(
                                            "${snap.data!.snapshot.value.toString()}",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ))
                            : Container();
                      })
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
                              "BRINDES JEE",
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
                ],
              ));
  }
}
