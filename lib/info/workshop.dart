import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'regis.dart';

class Workshop extends StatefulWidget {
  final String cardtype;
  const Workshop({super.key, required this.cardtype});

  @override
  State<Workshop> createState() => _WorkshopState();
}

class _WorkshopState extends State<Workshop> {
  List lists = [];

  @override
  void initState() {
    super.initState();
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child(widget.cardtype);
    Stream<DatabaseEvent> stream = dbRef.onValue;
    stream.listen((DatabaseEvent event) {
      var data = event.snapshot.value;
      print(data);
      data = data ?? [];
      updateInfo(data);
    });
  }

  void openCard(index) {
    if (widget.cardtype != "avisos") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Regis(cardtype: widget.cardtype, index: index)),
      );
    }
  }

  void updateInfo(data) {
    if (mounted) {
      setState(() {
        lists.clear();
        data.forEach((values) {
          if (values["show"]) {
            lists.add(values);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lists.isNotEmpty
          ? (widget.cardtype == "parcerias"
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 270,
                      childAspectRatio: 1 / 1,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2),
                  itemCount: lists.length,
                  itemBuilder: (BuildContext context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GestureDetector(
                        onTap: () => openCard(index),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  Image.network(lists[index]["img"], scale: 1),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: lists.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GestureDetector(
                        onTap: () => openCard(index),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: SizedBox(
                                  width: 80,
                                  child: Image.network(lists[index]["img"],
                                      scale: 1),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        lists[index]["name"],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20, left: 5.0, bottom: 10),
                                      child: Text(
                                        lists[index]["desc"]
                                            .replaceAll("\\n", "\n"),
                                        textAlign: TextAlign.justify,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ))
          : const Center(
              child: Text(
                "Ainda não temos nada para te mostrar",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
    );
  }
}
