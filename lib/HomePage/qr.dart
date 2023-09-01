import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'visitas.dart';

class QrPage extends StatefulWidget {
  const QrPage({super.key});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  final _n_aluno = TextEditingController();
  final _n_socio = TextEditingController();
  final _name = TextEditingController();
  final _data = TextEditingController();
  bool cota = false;
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("users/${FirebaseAuth.instance.currentUser?.uid.trim()}");
  DateTime dateTime = DateTime.now();

  void updateInfo(data) {
    if (mounted) {
      setState(() {
        _n_socio.text =
            data['n_socio'] == null ? "" : data['n_socio'].toString();
        _name.text = data['name'];
        _n_aluno.text = data['aluno'] == null ? "" : data['aluno'].toString();
        cota = data['cotas'];
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
  }

  Future UpdateData() async {
    await ref.update({
      'name': _name.text.trim(),
    });
  }

  void GetInfo() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            scrollable: true,
            title: const Text('Atualizar dados'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        icon: Icon(Icons.person),
                      ),
                    ),
                    TextFormField(
                      readOnly: true,
                      controller: _n_aluno,
                      decoration: const InputDecoration(
                        labelText: 'Nº Aluno',
                        icon: Icon(Icons.book),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FloatingActionButton(
                backgroundColor: Color.fromARGB(255, 241, 133, 25),
                onPressed: () {
                  if (_name.text.isNotEmpty && _n_socio.text.isNotEmpty) {
                    UpdateData();
                    Navigator.of(context).pop();
                  }
                },
                child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil de Utilizador"),
        //backgroundColor: const Color.fromARGB(255, 0x01, 0x1f, 0x26),
      ),
      //backgroundColor: Colors.grey[900],
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                scale: 2, image: AssetImage("assets/images/logo_w_grey.png"))),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      _name.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 70, vertical: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 241, 133, 25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: const BoxDecoration(boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.black54,
                        blurRadius: 15.0,
                        offset: Offset(0.0, 0.75))
                  ]),
                  child: QrImage(
                    data: uid!.trim(),
                    padding: const EdgeInsets.all(5),
                    backgroundColor: Colors.white,
                    size: 150,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Text(
                      (_n_socio.text != '')
                          ? "Nº Socio: ${_n_socio.text}"
                          : "Obtém o teu Nº socio",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 70, vertical: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 241, 133, 25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 60,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cota ? Colors.green : Colors.red,
                      border:
                          Border.all(color: cota ? Colors.green : Colors.red),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(cota ? Icons.check : Icons.warning_rounded,
                              size: 40.0),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            cota ? "Cotas pagas" : "Cotas sem pagar",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        GetInfo();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 241, 133, 25),
                          border: Border.all(
                              color: const Color.fromARGB(255, 241, 133, 25)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            "Editar Dados",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.only(right: 40, left: 40, bottom: 40),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const VisitasPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 241, 133, 25),
                          border: Border.all(
                              color: const Color.fromARGB(255, 241, 133, 25)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            "Visitas",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
