import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:NEEEICUM/info/points.dart';
import 'package:NEEEICUM/info/workshop.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class JEE extends StatefulWidget {
  const JEE({super.key});

  @override
  State<JEE> createState() => _JEEState();
}

class _JEEState extends State<JEE> {
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  Map gerirJee = {};

  void launchURL(url) async {
    var uri = Uri.parse("https://$url");
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } else {}
  }

  void openWorkshops() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            //backgroundColor: const Color.fromARGB(255, 0x01, 0x1f, 0x26),
            title: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                "Atividades",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          body: const Workshop(cardtype: "jee"),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("gerirJEE");
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
      updateInfo(event.snapshot.value);
    });
  }

  void updateInfo(data) {
    if (mounted) {
      setState(() {
        gerirJee = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref()
            .child("jeepoints")
            .child(uid.toString())
            .child('points')
            .onValue,
        builder: (context, snap) {
          return Scaffold(
            //backgroundColor: const Color.fromARGB(255, 0x36, 0x34, 0x32),
            body: Container(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 40),
                            child: (gerirJee["banner"] == null ||
                                    gerirJee["banner"] == "")
                                ? Image.asset("assets/images/logo_w.png",
                                    height: 180)
                                : Image.network(
                                    gerirJee["banner"].toString(),
                                    height: 180,
                                  ),
                          ),
                          Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    //Workshops
                                    MaterialButton(
                                      onPressed: openWorkshops,
                                      child: Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 241, 133, 25),
                                          border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 241, 133, 25)),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const <Widget>[
                                              Icon(Icons.construction,
                                                  size: 30.0),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "Atividades",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
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
                                    const SizedBox(height: 20),
                                    //Calendário
                                    MaterialButton(
                                      onPressed: () => launchURL(
                                          // alterar isto para var in firebase
                                          "github.com/NeeicumDAI/NeeeicumFiles/blob/main/JEE/23/jeecartaz.pdf?raw=true"),
                                      child: Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 241, 133, 25),
                                          border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 241, 133, 25)),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const <Widget>[
                                              Icon(Icons.calendar_month,
                                                  size: 30.0),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "Calendário",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
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
                                    const SizedBox(height: 20),
                                    //Pontos
                                    (snap.hasData &&
                                            !snap.hasError &&
                                            snap.data?.snapshot.value != null)
                                        ? MaterialButton(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PointsPage()),
                                            ),
                                            child: Container(
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 241, 133, 25),
                                                border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255, 241, 133, 25)),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const <Widget>[
                                                    Icon(Icons.sports_esports,
                                                        size: 30.0),
                                                    SizedBox(
                                                      width: 15,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        "Pontos",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              const Text(
                                                "Passa pela acreditação",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 70,
                                                      vertical: 5),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 241, 133, 25),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
