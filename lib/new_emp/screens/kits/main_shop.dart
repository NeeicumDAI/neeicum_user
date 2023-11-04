import 'dart:async';
import 'package:NEEEICUM/new/screens/kits/kits.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:NEEEICUM/new/screens/kits/others.dart';
import 'package:NEEEICUM/new/screens/kits/rasp.dart';
import 'package:flutter/material.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  Map datamap = {};
  late StreamSubscription<DatabaseEvent> callback;
  Map mainData = {};
  int regStage = 0;
  bool? cotas = false;
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  int _activePage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _pages = [
    const KitsPage(),
    const RaspPage(),
    const OthersPage()
  ];

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
          Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                                        offset:
                                            Offset(0, 2), // Offset from the top
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: _activePage == index ? 15 : 9,
                                    backgroundColor: _activePage == index
                                        ? Colors.orange
                                        : Color.fromARGB(255, 66, 66, 66),
                                  ),
                                )),
                          )),
                ),
              )),
        ],
      ),
    );
  }
}
