import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RiveAssetEmp {
  final String title;
  final IconData iconData;

  RiveAssetEmp({
    required this.title,
    required this.iconData,
  });
}

List<RiveAssetEmp> sideMenus = [
  RiveAssetEmp(
    title: "Home",
    iconData: Icons.house_rounded,
  ),
  /*RiveAssetEmp(
    title: "Visitas",
    iconData: Icons.search,
  ),*/
  /*RiveAsset(
    title: "Carrinho",
    iconData: Icons.shopping_cart_checkout_outlined,
  ),*/
  /*RiveAssetEmp(
    title: "O meu perfil",
    iconData: Icons.person,
  ),*/
  RiveAssetEmp(
    title: "Log Out",
    iconData: Icons.logout,
  ),
];

List<RiveAssetEmp> sideMenu2 = [
  RiveAssetEmp(
    title: "Leaderboard",
    iconData: Icons.leaderboard_rounded,
  ),
  RiveAssetEmp(
    title: "Prémio",
    iconData: Icons.emoji_events_rounded,
  ),
];
