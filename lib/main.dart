// import 'package:NEEEICUM/firebaseapi.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/splash.dart';

// retirar comments ao criar nova versão para tele e voltar a meter ao dar update na web

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'NEEEICUM User App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
        //backgroundColor: Color.fromARGB(255, 0x36, 0x34, 0x32),
      ),
      home: const Splash(),
    );
  }
}
