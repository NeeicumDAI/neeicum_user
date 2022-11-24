import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'qr.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String logoCurso = "assets/images/logo_curso.png";

  void goToQr() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrPage()),
    );
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
                scale: 40,
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
      body: const Center(),
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
            icon: Icon(Icons.electrical_services),
            label: 'JEE',
            activeIcon: Icon(Icons.electric_bolt_outlined),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Parcerías',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      /*floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: (() => FirebaseAuth.instance.signOut()),
        tooltip: 'Sign Out',
        child: const Icon(Icons.logout),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,*/
    );
  }
}
