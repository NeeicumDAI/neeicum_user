import 'package:NEEEICUM/new/screens/Jornadas/brindes.dart';
import 'package:NEEEICUM/new/screens/Jornadas/participa%C3%A7oes.dart';
import 'package:NEEEICUM/new/screens/UMRC/utils/blocks.dart';
import 'package:flutter/material.dart';
import 'package:NEEEICUM/new/screens/Jornadas/agenda.dart';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

//import 'dart:ffi';

enum Status { open, registered, full, closed, registereddandclosed, appear }

class UMRCPage extends StatefulWidget {
  const UMRCPage({super.key});

  @override
  State<UMRCPage> createState() => _UMRCPage();
}

class _UMRCPage extends State<UMRCPage> {
  //ScrollController _scrollController1 = ScrollController();
  Map datamap = {};
  int regStage = 0;
  late StreamSubscription<DatabaseEvent> callback;
  int coins = 0;
  Map mainData = {};
  Map settings = {};
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();

  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: '56WBs0A4Kng',
    flags: YoutubePlayerFlags(
      isLive: true,
      hideControls: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      double minScrollExtent = _scrollController1.position.minScrollExtent;
      double maxScrollExtent = _scrollController1.position.maxScrollExtent;

      animateToMaxMin(maxScrollExtent, minScrollExtent, maxScrollExtent, 20,
          _scrollController1);
    });*/

    DatabaseReference dbRefEmp =
        FirebaseDatabase.instance.ref().child('empresas');
    Stream<DatabaseEvent> streamEmp = dbRefEmp.orderByChild('date').onValue;
    streamEmp.listen((DatabaseEvent event) {
      updateInfoEmpresas(event.snapshot.children);
    });

    DatabaseReference ref =
        FirebaseDatabase.instance.ref("umrc").child("settings");
    Stream<DatabaseEvent> stream_settings = ref.onValue;
    stream_settings.listen((DatabaseEvent event) {
      updatesettings(event.snapshot.value);
    });
  }

  void updateInfoEmpresas(data) {
    if (mounted) {
      setState(() {
        datamap.clear();
        data.forEach((child) {
          if (child.value["show"]) {
            datamap[child.key] = child.value;
          }
        });
      });
    }
  }

  void updatesettings(data) {
    if (mounted) {
      setState(() {
        settings = data;
      });
    }
  }

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

  /*animateToMaxMin(double max, double min, double direction, int seconds,
      ScrollController scrollController) {
    scrollController
        .animateTo(direction,
            duration: Duration(seconds: seconds), curve: Curves.linear)
        .then((value) {
      direction = direction == max ? min : max;
      animateToMaxMin(max, min, direction, seconds, scrollController);
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFEEF1F8),
        body: (settings["show"] != null ? settings["show"] : false)
            ? Stack(
                children: [
                  SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.all(20),
                          ),
                          Center(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 0),
                                child: Image.asset("assets/images/UMRC.png",
                                    height: 180)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "Empresas",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            height: 130,
                            child: ListView.builder(
                                clipBehavior: Clip.none,
                                //physics: NeverScrollableScrollPhysics(),
                                //controller: _scrollController1,
                                padding:
                                    EdgeInsets.only(/*top: 5, bottom: 35.0*/),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: datamap.keys.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return EmpresaBloco(
                                      datamap: datamap[
                                          datamap.keys.elementAt(index)]);
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "Outros",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: YoutubePlayer(
                                  controller: _controller,
                                  liveUIColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AgendaPage()),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Icon(
                                            Icons.arrow_forward_ios_rounded),
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  padding: EdgeInsets.all(0),
                                                  child: Icon(
                                                    size: 40,
                                                    Icons
                                                        .electric_bolt_outlined,
                                                    color: Color.fromARGB(
                                                        255, 66, 66, 66),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 30),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Text(
                                                    "Atividades",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const participacoesPage()),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Icon(
                                            Icons.arrow_forward_ios_rounded),
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  padding: EdgeInsets.all(0),
                                                  child: Icon(
                                                    size: 40,
                                                    Icons.article_rounded,
                                                    color: Color.fromARGB(
                                                        255, 66, 66, 66),
                                                  ),
                                                  /*decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                blurRadius: 15,
                                                                offset: Offset(
                                                                    0, 7.5))
                                                          ],
                                                          color: Color.fromARGB(
                                                              255, 66, 66, 66),
                                                          /*border: Border.all(
                                              color: Color.fromARGB(255, 66, 66, 66), // Border color
                                              width: 2.0, // Border width
                                                                        )*/
                                                          /*borderRadius: const BorderRadius.all(
                                                                        Radius.circular(20),
                                                              ),*/
                                                        ),*/
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 30),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Text(
                                                    "Objetivos",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10, bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const brindesPage()),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Icon(
                                            Icons.arrow_forward_ios_rounded),
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  padding: EdgeInsets.all(0),
                                                  child: Icon(
                                                    size: 40,
                                                    Icons.emoji_events_rounded,
                                                    color: Color.fromARGB(
                                                        255, 66, 66, 66),
                                                  ),
                                                  /*decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                blurRadius: 15,
                                                                offset: Offset(
                                                                    0, 7.5))
                                                          ],
                                                          color: Color.fromARGB(
                                                              255, 66, 66, 66),
                                                          /*border: Border.all(
                                              color: Color.fromARGB(255, 66, 66, 66), // Border color
                                              width: 2.0, // Border width
                                                                        )*/
                                                          /*borderRadius: const BorderRadius.all(
                                                                        Radius.circular(20),
                                                              ),*/
                                                        ),*/
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 30),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: Text(
                                                    "Brindes JEE",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          StreamBuilder(
                              stream: FirebaseDatabase.instance
                                  .ref()
                                  .child("jeepoints")
                                  .child(uid.toString())
                                  .child('points')
                                  .onValue,
                              builder: (context, snap) {
                                return (snap.hasData &&
                                        !snap.hasError &&
                                        snap.data?.snapshot.value != null)
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 10,
                                            bottom: 10),
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2,
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 0),
                                                            child: Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.13,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.13,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              child: Icon(
                                                                size: 40,
                                                                Icons
                                                                    .badge_rounded,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              /*decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              10)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color:
                                                                        Colors.grey,
                                                                    blurRadius: 15,
                                                                    offset: Offset(
                                                                        0, 7.5))
                                                              ],
                                                              color: Color.fromARGB(
                                                                  255, 66, 66, 66),
                                                              /*border: Border.all(
                                                  color: Color.fromARGB(255, 66, 66, 66), // Border color
                                                  width: 2.0, // Border width
                                                                            )*/
                                                              /*borderRadius: const BorderRadius.all(
                                                                            Radius.circular(20),
                                                                  ),*/
                                                            ),*/
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    right: 30),
                                                            child: Container(
                                                              /*width: MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.,*/
                                                              child: Text(
                                                                "Estás acreditado",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 10,
                                            bottom: 10),
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.2,
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 0),
                                                            child: Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.13,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.13,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              child: Icon(
                                                                size: 40,
                                                                Icons
                                                                    .badge_rounded,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              /*decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              10)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color:
                                                                        Colors.grey,
                                                                    blurRadius: 15,
                                                                    offset: Offset(
                                                                        0, 7.5))
                                                              ],
                                                              color: Color.fromARGB(
                                                                  255, 66, 66, 66),
                                                              /*border: Border.all(
                                                  color: Color.fromARGB(255, 66, 66, 66), // Border color
                                                  width: 2.0, // Border width
                                                                            )*/
                                                              /*borderRadius: const BorderRadius.all(
                                                                            Radius.circular(20),
                                                                  ),*/
                                                            ),*/
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    right: 30),
                                                            child: Container(
                                                              /*width: MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.,*/
                                                              child: Text(
                                                                "Não estás acreditado",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                              }),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: (() {
                          Navigator.pop(context);
                        }),
                        child: Container(
                          //margin: const EdgeInsets.only(left: 16),
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 3),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "JORNADAS",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.2,
                                  height:
                                      MediaQuery.of(context).size.width / 1.2,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          scale: 1,
                                          image: AssetImage(
                                              "assets/images/logo_w_grey.png"))),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0),
                                child: Text(
                                  "Aguarda pelas próximas jornadas",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: (() {
                          Navigator.pop(context);
                        }),
                        child: Container(
                          //margin: const EdgeInsets.only(left: 16),
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 3),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                      ),
                    ),
                  ),
                ],
              ));
  }
}
