import 'package:NEEEICUM/auth/empresa.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:NEEEICUM/new_emp/models/rive_asset.dart';

import 'info_card.dart';
import 'side_menu_tile.dart';

typedef void OnMenuChange(RiveAssetEmp menu);

class SideMenu extends StatefulWidget {
  final OnMenuChange onMenuChange; // O callback

  const SideMenu({Key? key, required this.onMenuChange}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  DatabaseReference ref = FirebaseDatabase.instance.ref("users/${empresaId}");
  final _name = TextEditingController();
  final _image = TextEditingController();
  final _sponsor = TextEditingController();
  Map gerirJee = {};

  RiveAssetEmp selectedMenu = sideMenus.first;

  void updateInfo(data) {
    if (mounted) {
      setState(() {
        _name.text = data['name'];
        _image.text = data['img'] == null ? "" : data["img"].toString();
        _sponsor.text =
            data["sponsor"] == "Main" ? "Diamond" : data["sponsor"].toString();
      });
    }
  }

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
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      updateInfo(data);
    });

    DatabaseReference dbref = FirebaseDatabase.instance.ref().child("gerirJEE");
    Stream<DatabaseEvent> streamJEE = dbref.onValue;
    streamJEE.listen((DatabaseEvent event) {
      updateInfojee(event.snapshot.value);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: Colors.grey[900],
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoCard(
                image: _image.text,
                name: empresa,
                profession: "Empresa ${_sponsor.text}",
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "Browse".toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white70),
                ),
              ),
              ...sideMenus.map(
                (menu) => SideMenuTile(
                  menu: menu,
                  press: () {
                    setState(() {
                      selectedMenu = menu;
                      widget.onMenuChange(menu);
                      /*Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => getPageForMenu(menu),
                        ),
                      );*/
                    });
                  },
                  isActive: selectedMenu == menu,
                ),
              ),
              gerirJee["show"]
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, top: 32, bottom: 16),
                          child: Text(
                            "JORNADAS".toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: Colors.white70),
                          ),
                        ),
                        ...sideMenu2.map(
                          (menu) => SideMenuTile(
                            menu: menu,
                            press: () {
                              setState(() {
                                selectedMenu = menu;
                                widget.onMenuChange(menu);
                              });
                            },
                            isActive: selectedMenu == menu,
                          ),
                        )
                      ],
                    )
                  : Container()

              /*Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            "Log Out",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
