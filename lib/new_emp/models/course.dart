import 'package:NEEEICUM/new_emp/screens/team/presidencia.dart';
import 'package:NEEEICUM/new_emp/screens/team/assembleia.dart';
import 'package:NEEEICUM/new_emp/screens/team/conselhofiscal.dart';
import 'package:flutter/material.dart';

class Course {
  final String title, description, iconSrc;
  final Color bgColor;
  final Function(BuildContext) ontap;

  Course({
    required this.title,
    this.description = "",
    this.iconSrc = "",
    this.bgColor = const Color.fromARGB(255, 66, 66, 66),
    required this.ontap,
  });
}

List<Course> recentCourses = [
  Course(
      ontap: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PresidenciaPage()),
        );
      },
      title: "Direção",
      description: "Mandato 2023/2024",
      iconSrc: "assets/icons/logo_w.png"),
  Course(
    ontap: (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AssembleiaPage()),
      );
    },
    title: "Assembleia",
    description: "Mandato 2023/2024",
    bgColor: Color.fromARGB(255, 128, 128, 128),
    iconSrc: "assets/icons/logo_w.png",
  ),
  Course(
      ontap: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConselhoFiscalPage()),
        );
      },
      title: "Conselho fiscal",
      description: "Mandato 2023/2024",
      iconSrc: "assets/icons/logo_w.png"),
];
