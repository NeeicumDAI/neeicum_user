import 'package:NEEEICUM/new_emp/screens/qr/qrEmpresa.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:NEEEICUM/new_emp/screens/Jornadas/jornadas.dart';

import 'package:NEEEICUM/new_emp/screens/workshops/workshops.dart';
import 'package:NEEEICUM/new_emp/screens/avisos/avisos.dart';

import '../../models/course.dart';

import 'components/secondary_course_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //ScrollController _scrollController1 = ScrollController();
  Map datamap = {};
  late StreamSubscription<DatabaseEvent> callback;
  Map mainData = {};
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();

  @override
  void initState() {
    super.initState();

    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      double minScrollExtent = _scrollController1.position.minScrollExtent;
      double maxScrollExtent = _scrollController1.position.maxScrollExtent;

      animateToMaxMin(maxScrollExtent, minScrollExtent, maxScrollExtent, 30,
          _scrollController1);
    });*/

    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('parcerias');
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

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(onTap: () {}, child: child),
      );

  Widget openWorkshop(int index) => makeDismissible(
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
                          SizedBox(height: 35),
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
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width / 20),
                child: Text(
                  "NEEEICUM",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 20),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AvisosPage()),
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                height:
                                    (MediaQuery.of(context).size.width * 0.185),
                                width:
                                    (MediaQuery.of(context).size.width * 0.185),
                                decoration: const BoxDecoration(
                                  color: const Color.fromARGB(255, 66, 66, 66),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 30,
                                        offset: Offset(0, 10))
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 0),
                                    child: Icon(
                                      Icons.notifications,
                                      color: const Color(0xFFEEF1F8),
                                      size: 40,
                                    ),
                                  ),
                                )),
                          ),
                          Text("Avisos")
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 20),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const WorkshopsPage()),
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                height:
                                    (MediaQuery.of(context).size.width * 0.185),
                                width:
                                    (MediaQuery.of(context).size.width * 0.185),
                                decoration: const BoxDecoration(
                                  color: const Color.fromARGB(255, 66, 66, 66),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 30,
                                        offset: Offset(0, 10))
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 0),
                                    child: Icon(
                                      Icons.construction_outlined,
                                      color: const Color(0xFFEEF1F8),
                                      size: 40,
                                    ),
                                  ),
                                )),
                          ),
                          Text("Workshops")
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 20),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const JornadasPage()),
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                height:
                                    (MediaQuery.of(context).size.width * 0.185),
                                width:
                                    (MediaQuery.of(context).size.width * 0.185),
                                decoration: const BoxDecoration(
                                  color: const Color.fromARGB(255, 66, 66, 66),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 30,
                                        offset: Offset(0, 10))
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 0),
                                    child: Icon(
                                      Icons.electric_bolt_outlined,
                                      color: const Color(0xFFEEF1F8),
                                      size: 40,
                                    ),
                                  ),
                                )),
                          ),
                          Text("Jornadas")
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 20),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const QrPageEmpresa(
                                          value: '',
                                        )),
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                height:
                                    (MediaQuery.of(context).size.width * 0.185),
                                width:
                                    (MediaQuery.of(context).size.width * 0.185),
                                decoration: const BoxDecoration(
                                  color: const Color.fromARGB(255, 66, 66, 66),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 30,
                                        offset: Offset(0, 10))
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 0),
                                    child: Icon(
                                      Icons.qr_code_rounded,
                                      color: const Color(0xFFEEF1F8),
                                      size: 40,
                                    ),
                                  ),
                                )),
                          ),
                          Text("Leitor Qr")
                        ],
                      ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Parcerias",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                height: 230,
                child: ListView.builder(
                    clipBehavior: Clip.none,
                    //controller: _scrollController1,
                    //physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(/*top: 5, bottom: 35.0*/),
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
                                builder: (context) => openWorkshop(index))),
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 24),
                                height: 230,
                                width: 220,
                                decoration: const BoxDecoration(
                                  color: const Color.fromARGB(255, 66, 66, 66),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 30,
                                        offset: Offset(0, 10))
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 0),
                                    child: Image.network(
                                        datamap[datamap.keys.elementAt(index)]
                                            ["img"],
                                        scale: 1),
                                  ),
                                )),
                          ));
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Equipa",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              ...recentCourses.map(
                (course) => Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: SecondaryCourseCard(course: course),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
