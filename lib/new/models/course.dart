import 'package:NEEEICUM/new/screens/team/presidencia.dart';
import 'package:NEEEICUM/new/screens/team/assembleia.dart';
import 'package:NEEEICUM/new/screens/team/conselhofiscal.dart';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';

// Não está a ser usado

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

String database_Mandato = ''; // Variável global para armazenar o mandato

// Função assíncrona para carregar dados do Firebase
Future<String> loadMandatoFromFirebase() async {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child("equipa").child("Mandato");

  DataSnapshot snapshot = await ref.get();

  // Verifica se o valor existe no snapshot
  if (snapshot.exists) {
    // Tenta garantir que o valor retornado é uma String
    String mandato = snapshot.value.toString();  // Convertendo para String, caso não seja.
    print(mandato);  // Verifica no console o valor retornado.
    return mandato;
  } else {
    // Caso o "Mandato" não exista, você pode retornar um valor padrão ou vazio.
    print("Mandato não encontrado!");
    return "Mandato não encontrado";  // Retorna um valor padrão, se o mandato não existir.
  }
}

Future<void> getCourses() async {
  // Carrega os dados do Firebase primeiro
  String value = await loadMandatoFromFirebase();

  // Agora preenche a lista de cursos
  recentCourses.clear(); // Limpa a lista antes de adicionar novos itens
  
  // Preenche a lista com os cursos
  recentCourses.addAll([
    Course(
      ontap: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PresidenciaPage()),
        );
      },
      title: "Direção",
      description: value,  // Agora a descrição é preenchida corretamente
      iconSrc: "assets/icons/logo_w.png",
    ),
    Course(
      ontap: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AssembleiaPage()),
        );
      },
      title: "Assembleia",
      description: value,
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
      description: value,
      iconSrc: "assets/icons/logo_w.png",
    ),
  ]);
}

// Lista global onde os cursos serão armazenados
List<Course> recentCourses = [];