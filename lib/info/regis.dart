import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Status { open, registered, full, closed, registereddandclosed }

class Regis extends StatefulWidget {
  final String cardtype;
  final String index;
  const Regis({super.key, required this.cardtype, required this.index});

  @override
  State<Regis> createState() => _RegisState();
}

class _RegisState extends State<Regis> {
  List<MaterialColor> optionsColor = [Colors.green, Colors.red, Colors.green];
  List<IconData> optionsIcons = [
    Icons.add_circle_outline,
    Icons.check,
    Icons.warning,
    Icons.highlight_remove,
    Icons.check,
  ];
  List<String> optionsText = [
    "Inscreve-te",
    "Estás registado.\nEliminar inscrição?",
    "Vagas esgotadas",
    "Inscrições fechadas",
    "Estás registado\nInscrições fechadas"
  ];
  List lists = [];
  Map mainData = {};
  int regStage = 0;
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();

  @override
  void initState() {
    super.initState();
    DatabaseReference dbRef = FirebaseDatabase.instance
        .ref()
        .child(widget.cardtype)
        .child(widget.index.toString());
    Stream<DatabaseEvent> stream = dbRef.onValue;
    stream.listen((DatabaseEvent event) {
      var data = event.snapshot.value;
      print(data);
      mainData = (data as Map);
      updateInfo(mainData);
    });
  }

  void updateInfo(data) {
    if (mounted) {
      setState(() {
        lists.clear();
        regStage = Status.open.index;
        if (data["closed"]) {
          if (data["reg"].containsKey(uid)) {
            regStage = Status.registereddandclosed.index;
          } else {
            regStage = Status.closed.index;
          }
        } else if (data.containsKey("reg")) {
          if (data["reg"].containsKey(uid)) {
            regStage = Status.registered.index;
          } else if (data["reg"].length >= data["max"]) {
            regStage = Status.full.index;
          }
        }
      });
    }
  }

  Future register() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child(widget.cardtype)
        .child(widget.index.toString())
        .child("reg")
        .child(uid.toString());
    await ref.set({"appear": false});
  }

  Future unregister() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child(widget.cardtype)
        .child(widget.index.toString())
        .child("reg")
        .child(uid.toString());
    await ref.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            mainData["name"].toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60),
              child: Image.network(
                  (mainData.isEmpty)
                      ? "https://previews.123rf.com/images/kaymosk/kaymosk1804/kaymosk180400006/100130939-error-404-page-not-found-error-with-glitch-effect-on-screen-vector-illustration-for-your-design-.jpg"
                      : mainData["img"],
                  scale: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                mainData["desc"].toString().replaceAll("\\n", "\n"),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: MaterialButton(
                    onPressed: () => {
                      if (regStage == 0)
                        register()
                      else if (regStage == 1)
                        unregister()
                    },
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: optionsColor[regStage ~/ 2],
                        border: Border.all(color: optionsColor[regStage ~/ 2]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(optionsIcons[regStage], size: 30.0),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                optionsText[regStage].replaceAll("\\n", "\n"),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
