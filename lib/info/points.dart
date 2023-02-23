import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:deep_collection/deep_collection.dart';

class PointsPage extends StatefulWidget {
  const PointsPage({super.key});
  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  Map datamap = {};

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
          title: Padding(
        padding: const EdgeInsets.all(0.0),
        child: StreamBuilder(
            stream: FirebaseDatabase.instance
                .ref()
                .child("jeepoints")
                .child(uid.toString())
                .child('points')
                .onValue,
            builder: (context, snap) {
              return Row(
                children: [
                  const Icon(Icons.people_rounded, size: 30),
                  const SizedBox(width: 5),
                  const Text(
                    'Classificação',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Pontos: ${snap.data!.snapshot.value.toString()}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
                ],
              );
            }),
      )),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref()
            .child("jeepoints")
            .orderByChild('points')
            .limitToLast(20)
            .onValue,
        builder: (context, snap) {
          if (snap.hasData) {
            Iterable<DataSnapshot> data = snap.data!.snapshot.children;
            datamap.clear();
            for (var child in data) {
              datamap[child.key] = child.value;
            }
            datamap = datamap.deepReverse();

            return ListView.builder(
              shrinkWrap: true,
              itemCount: datamap.keys.length,
              itemBuilder: (context, index) {
                return StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child("users")
                      .child(datamap.keys.elementAt(index).toString())
                      .onValue,
                  builder: (context, snap2) {
                    Map data2 = {};
                    if (snap2.hasData) {
                      data2 = snap2.data!.snapshot.value as Map;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 5.0, right: 10.0, left: 10.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: snap2.hasData
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: SizedBox(
                                      width: 30,
                                      child: Icon(Icons.people_rounded),
                                    ),
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              data2["name"].toString(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 20.0),
                                                child: Text(
                                                  textAlign: TextAlign.end,
                                                  (data2["n_socio"] != null)
                                                      ? data2["n_socio"]
                                                      : '',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Pontos: ${datamap.values.elementAt(index)["points"]}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 20.0),
                                                  child: Text(
                                                    (data2["aluno"] != null)
                                                        ? 'Aluno: ${data2["aluno"]}'
                                                        : 'Sem Aluno Associado',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                                ],
                              )
                            : const SizedBox(),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      scale: 2,
                      image: AssetImage("assets/images/logo_w_grey.png"))),
              child: const Center(
                child: Text(
                  "Não há utilizadores com pontos...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
