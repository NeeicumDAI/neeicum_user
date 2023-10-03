import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:NEEEICUM/info/jee.dart';
import 'qr.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../info/workshop.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String logoCurso = "assets/images/logo_w.png";
  final _pageViewController = PageController();
  Map gerirJee = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("gerirJEE");
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
      updateInfo(event.snapshot.value);
    });
  }

  void updateInfo(data) {
    if (mounted) {
      setState(() {
        gerirJee = data;
      });
    }
  }

  void goToQr() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrPage()),
    );
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _pageViewController.animateToPage(index,
          duration: const Duration(milliseconds: 200), curve: Curves.bounceOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[900],
      appBar: AppBar(
        //backgroundColor: const Color.fromARGB(255, 0x01, 0x1f, 0x26),
        actions: [
          IconButton(onPressed: goToQr, icon: const Icon(Icons.person)),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Image.asset(
                logoCurso,
                scale: 50,
              ),
              const SizedBox(
                width: 20,
              ),
              const Text(
                'NEEEICUM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        //backgroundColor: Colors.indigo,
      ),
      body: PageView(
        // mudar isto para mostrar jee se show == true
        controller: _pageViewController,
        children: (gerirJee["show"] as bool)
            ? const <Widget>[
                Workshop(cardtype: "avisos"),
                Workshop(cardtype: "workshop"),
                JEE(),
                Workshop(cardtype: "parcerias"),
                Workshop(cardtype: "kits"),
              ]
            : const <Widget>[
                Workshop(cardtype: "avisos"),
                Workshop(cardtype: "workshop"),
                Workshop(cardtype: "parcerias"),
                Workshop(cardtype: "kits"),
              ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black54,
              blurRadius: 15.0,
              offset: Offset(0.0, 0.75))
        ]),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.grey[800],
          mouseCursor: SystemMouseCursors.click,
          selectedItemColor: Color.fromARGB(255, 241, 133, 25),
          unselectedItemColor: Colors.grey,
          items: (gerirJee["show"] as bool)
              ? const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications),
                    label: 'Avisos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.work),
                    label: 'Workshops',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.electric_bolt_outlined),
                    label: 'JEE',
                    //activeIcon: Icon(Icons.electric_bolt_outlined),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people),
                    label: 'Parcerias',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_bag_rounded),
                    label: 'Kits',
                  )
                ]
              : const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications),
                    label: 'Avisos',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.work),
                    label: 'Workshops',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people),
                    label: 'Parcerias',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_bag_rounded),
                    label: 'Kits',
                  )
                ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
