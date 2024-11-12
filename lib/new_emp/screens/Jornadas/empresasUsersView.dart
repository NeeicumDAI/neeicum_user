import 'package:NEEEICUM/auth/empresa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UsersView extends StatefulWidget {
  const UsersView({super.key});
  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  String uname = "";
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("users/${FirebaseAuth.instance.currentUser?.uid.trim()}");
  Map datamap = {};

  void initState() {
    super.initState();
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child("empresas").child(empresaId).child("reg");
    Stream<DatabaseEvent> stream = dbRef.orderByChild('date').onValue;

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
    print(datamap);
    return Scaffold(
        backgroundColor: const Color(0xFFEEF1F8),
        body: (datamap.isNotEmpty)
            ? Stack(
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
                                    top: 60, bottom: 20, left: 20, right: 20),
                                child: Text(
                                  "SCANNED PROFILES",
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
                                    data2 = snap2.data!.snapshot.value as Map;
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20, top: 10),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.2,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.13,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.13,
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      child:
                                                          data2["avatar"] ==
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
                                                                          data2["avatar"]
                                                                              .toString()),
                                                                ),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              blurRadius: 30,
                                                              offset: Offset(
                                                                  0, 7.5))
                                                        ],
                                                        color: Color.fromARGB(
                                                            255, 66, 66, 66),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10, right: 0),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          width:
                                                              MediaQuery.of(context)
                                                                      .size
                                                                      .width *
                                                                  0.5,
                                                          height: MediaQuery.of(context).size.width * 0.06,
                                                          child: Text(
                                                            
                                                            data2["name"]
                                                                .toString(),
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),

                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                          Container(
                                                          width:
                                                              MediaQuery.of(context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                          child: Text(
                                                            "Ciclo de Estudos :",
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                          ),
                                                        ),Container(
                                                          width:
                                                              MediaQuery.of(context)
                                                                      .size
                                                                      .width *
                                                                  0.2,
                                                          child: Text(
                                                            "Ano :",
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                          ),
                                                        )
                                                          ]
                                                        )
                                                      ],
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
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            scale: 2,
                            image:
                                AssetImage("assets/images/logo_w_grey.png"))),
                    child: const Center(
                      child: Text(
                        "No profiles scanned",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
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