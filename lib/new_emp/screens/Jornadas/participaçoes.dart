import 'dart:async';
import 'package:NEEEICUM/new_emp/screens/Jornadas/ob_gerais.dart';
import 'package:NEEEICUM/new_emp/screens/Jornadas/w_participados.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:NEEEICUM/new_emp/screens/Jornadas/fichaempresas.dart';
import 'package:NEEEICUM/new_emp/screens/Jornadas/brindes.dart';
import 'package:flutter/material.dart';

class participacoesPage extends StatefulWidget {
  const participacoesPage({super.key});

  @override
  State<participacoesPage> createState() => _participacoesPageState();
}

class _participacoesPageState extends State<participacoesPage> {
  Map datamap = {};
  late StreamSubscription<DatabaseEvent> callback;
  Map mainData = {};
  int regStage = 0;
  bool? cotas = false;
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  int _activePage = 0;
  Map gerirJee = {};
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _pages = [
    const FichaEmpresasPage(),
    const w_participadosPage(),
    const objGeraisPage()
  ];

  void updateInfojee(data) {
    if (mounted) {
      setState(() {
        gerirJee = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("gerirJEE");
    Stream<DatabaseEvent> streamJEE = ref.onValue;
    streamJEE.listen((DatabaseEvent event) {
      updateInfojee(event.snapshot.value);
    });
    //print(gerirJee);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F8),
      body: Stack(
        children: [
          PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _activePage = page;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (BuildContext context, int index) {
                return _pages[index % _pages.length];
              }),
          Container(
            height: MediaQuery.of(context).size.width * 0.5 + 10,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 7.5),
                    blurRadius: 30,
                  )
                ],
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25))),
          ),
          SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
                child: Text(
                  "Objetivos",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
              _activePage == 0
                  ? Padding(
                      padding:
                          const EdgeInsets.only(right: 20.0, left: 25, top: 0),
                      child: Text("Empresas",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400)),
                    )
                  : _activePage == 1
                      ? Padding(
                          padding: const EdgeInsets.only(
                              right: 20.0, left: 25, top: 0),
                          child: Text("Workshops",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400)),
                        )
                      : _activePage == 2
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  right: 20.0, left: 25, top: 0),
                              child: Text("Gerais",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400)),
                            )
                          : Container(),
              Align(
                alignment: Alignment.center,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(
                        _pages.length,
                        (index) => Padding(
                              padding: EdgeInsets.all(5),
                              child: InkWell(
                                  onTap: () {
                                    _pageController.animateToPage(index,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeIn);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.2), // Shadow color
                                          spreadRadius: 2, // Spread radius
                                          blurRadius: 4, // Blur radius
                                          offset: Offset(
                                              0, 2), // Offset from the top
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: _activePage == index ? 7.5 : 5,
                                      backgroundColor: _activePage == index
                                          ? Colors.orange
                                          : Color.fromARGB(255, 66, 66, 66),
                                    ),
                                  )),
                            )),
                  ),
                ),
              )
            ],
          )),
          Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child:
                      (gerirJee["banner"] == null || gerirJee["banner"] == "")
                          ? Image.asset("assets/images/logo_w.png", height: 180)
                          : Image.network(
                              gerirJee["banner"].toString(),
                              height: 180,
                            ),
                ),
              )),
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
                            borderRadius: BorderRadius.all(Radius.circular(20)),
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
                                      top: 10, left: 10, right: 5, bottom: 10),
                                  child: Image.asset("assets/images/coin.gif"),
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
      ),
    );
  }
}
