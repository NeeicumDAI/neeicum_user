import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RiveAsset {
  final String title;
  final IconData iconData;

  RiveAsset({
    required this.title,
    required this.iconData,
  });
}

List<RiveAsset> sideMenus = [
  RiveAsset(
    title: "Home",
    iconData: Icons.house_rounded,
  ),
  RiveAsset(
    title: "Visitas",
    iconData: Icons.search,
  ),
  /*RiveAsset(
    title: "Carrinho",
    iconData: Icons.shopping_cart_checkout_outlined,
  ),*/
  RiveAsset(
    title: "O meu perfil",
    iconData: Icons.person,
  ),
  RiveAsset(
    title: "Log Out",
    iconData: Icons.logout,
  ),
];

List<RiveAsset> sideMenu2 = [
  RiveAsset(
    title: "Leaderboard",
    iconData: Icons.leaderboard_rounded,
  ),
  RiveAsset(
    title: "Prémio",
    iconData: Icons.emoji_events_rounded,
  ),
];
