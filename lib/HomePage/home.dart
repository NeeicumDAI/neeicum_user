import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'qr.dart';
import '../info/workshop.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String logoCurso = "assets/images/logo_w.png";
  final _pageViewController = PageController();

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
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        actions: [
          IconButton(onPressed: goToQr, icon: const Icon(Icons.qr_code)),
          IconButton(
            onPressed: FirebaseAuth.instance.signOut,
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
        controller: _pageViewController,
        children: <Widget>[
          const Workshop(cardtype: "avisos"),
          const Workshop(cardtype: "workshop"),
          const Workshop(cardtype: "jee"),
          const Workshop(cardtype: "parcerias"),
          Container(color: Colors.black),
        ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        mouseCursor: SystemMouseCursors.grab,
        selectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
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
            label: 'Parcerías',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Info',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
