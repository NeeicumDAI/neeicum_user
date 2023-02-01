import 'package:neeicum/info/workshop.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class JEE extends StatefulWidget {
  const JEE({super.key});

  @override
  State<JEE> createState() => _JEEState();
}

class _JEEState extends State<JEE> {
  void launchURL(url) async {
    var uri = Uri.parse("https://$url");
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print("launched URL: $url");
      } catch (e) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } else {
      print('Could not launch $url');
    }
  }

  void openWorkshops() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0x01, 0x1f, 0x26),
            title: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                "JEE Workshops",
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 0x36, 0x34, 0x32),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
              child: Image.asset("assets/images/JEE23.png", height: 180),
            ),
            Expanded(
              child: Align(
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
                            color: const Color.fromARGB(255, 0x01, 0x1f, 0x26),
                            border: Border.all(
                                color: const Color.fromARGB(
                                    255, 0x01, 0x1f, 0x26)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Icon(Icons.construction, size: 30.0),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    "Workshops",
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
                        onPressed: () => launchURL("instagram.com/neeeicum"),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0x01, 0x1f, 0x26),
                            border: Border.all(
                                color: const Color.fromARGB(
                                    255, 0x01, 0x1f, 0x26)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Icon(Icons.calendar_month, size: 30.0),
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
                      MaterialButton(
                        onPressed: () => launchURL("www.google.com"),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0x01, 0x1f, 0x26),
                            border: Border.all(
                                color: const Color.fromARGB(
                                    255, 0x01, 0x1f, 0x26)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Icon(Icons.sports_esports, size: 30.0),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    "Pontos",
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
                    ],
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
