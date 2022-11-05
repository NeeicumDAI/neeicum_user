import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPage extends StatefulWidget {
  const QrPage({super.key});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  String aluno = '';
  int phone = 0;
  String name = '';
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();

  void updateInfo(refer) async {
    final event = await refer.once(DatabaseEventType.value);
    final data = event.snapshot.value;
    setState(() {
      aluno = data['aluno'];
      phone = data['phone'];
      name = data['name'];
    });
  }

  @override
  void initState() {
    super.initState();
    DatabaseReference refer =
        FirebaseDatabase.instance.ref("users/${uid?.trim()}");
    updateInfo(refer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            QrImage(
              data: uid!.trim(),
              padding: const EdgeInsets.all(5),
              backgroundColor: Colors.white,
              size: 150,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              aluno,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              phone.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
