import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:NEEEICUM/new/components/side_menu.dart';

import 'package:NEEEICUM/new/screens/home/home_screen.dart';

import 'package:NEEEICUM/new/screens/personal/qr.dart';
import 'package:NEEEICUM/new/screens/Jornadas/points.dart';
import 'package:NEEEICUM/new/utils/rive_utils.dart';
import 'screens/personal/visitas.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/menu_btn.dart';
import 'models/rive_asset.dart';

// We are done with our 5th and last episode
// Thank you so much for watching entire serise
// Bye

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint>
    with SingleTickerProviderStateMixin {
  RiveAsset selectedsideMenus = sideMenus.first;

  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scalAnimation;

  // Let's chnage the name
  late SMIBool isSideBarClosed;

  bool isSideMenuClosed = true;

  Widget getPageForMenu(RiveAsset menu) {
    if (menu == sideMenus[0]) {
      return HomePage();
    } else if (menu == sideMenus[1]) {
      return VisitasPage();
      /*} else if (menu == sideMenus[2]) {
      return CarrinhoPage();*/
    } else if (menu == sideMenus[2]) {
      return QrPage();
    } else if (menu == sideMenus[3]) {
      FirebaseAuth.instance.signOut();
      return Container();
    } else if (menu == sideMenu2[0]) {
      return PointsPage();
    } else {
      return Container();
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );
    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            width: 288,
            left: isSideMenuClosed ? -288 : 0,
            height: MediaQuery.of(context).size.height,
            child: SideMenu(
              onMenuChange: (menu) {
                setState(() {
                  selectedsideMenus = menu;
                });
              },
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(animation.value - 30 * animation.value * pi / 180),
            child: Transform.translate(
              offset: Offset(animation.value * 265, 0),
              child: Transform.scale(
                scale: scalAnimation.value,
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    child: GestureDetector(
                      child: getPageForMenu(selectedsideMenus),
                      onTap: () {
                        if (!isSideMenuClosed) {
                          setState(() {
                            isSideBarClosed.value = !isSideBarClosed.value;
                            if (isSideMenuClosed) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }
                            isSideMenuClosed = isSideBarClosed.value;
                          });
                        }
                      },
                      onHorizontalDragUpdate: (details) {
                        double dx = details.delta.dx;
                        if (dx > 0) {
                          if (isSideMenuClosed) {
                            setState(() {
                              isSideBarClosed.value = !isSideBarClosed.value;
                              if (isSideMenuClosed) {
                                _animationController.forward();
                              } else {
                                _animationController.reverse();
                              }
                              isSideMenuClosed = isSideBarClosed.value;
                            });
                          }
                        }
                        if (dx < 0) {
                          if (!isSideMenuClosed) {
                            setState(() {
                              isSideBarClosed.value = !isSideBarClosed.value;
                              if (isSideMenuClosed) {
                                _animationController.forward();
                              } else {
                                _animationController.reverse();
                              }
                              isSideMenuClosed = isSideBarClosed.value;
                            });
                          }
                        }
                      },
                    )),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideMenuClosed ? 0 : 220,
            top: 16,
            child: MenuBtn(
              riveOnInit: (artboard) {
                StateMachineController controller = RiveUtils.getRiveController(
                    artboard,
                    stateMachineName: "State Machine");
                isSideBarClosed = controller.findSMI("isOpen") as SMIBool;

                isSideBarClosed.value = true;
              },
              press: () {
                isSideBarClosed.value = !isSideBarClosed.value;
                if (isSideMenuClosed) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
                setState(() {
                  isSideMenuClosed = isSideBarClosed.value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
