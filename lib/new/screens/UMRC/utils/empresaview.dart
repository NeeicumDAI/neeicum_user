import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyView extends StatefulWidget {
  const CompanyView({super.key, required this.datamap});

  final Map datamap;

  @override
  State<CompanyView> createState() => _CompanyViewState();
}

class _CompanyViewState extends State<CompanyView> {
  Map sponsor_colors = {
    "Main": [Colors.orange, Colors.yellow],
    "Team": [Colors.grey, Colors.grey.shade300]
  };

  void launchURL(url) async {
    var uri = Uri.parse("https://$url");
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 80),
              child: Container(
                //height: ((MediaQuery.of(context).size.height)),
                width: MediaQuery.of(context).size.width,
                clipBehavior: Clip.none,
                padding: EdgeInsets.only(top: 120, left: 20, right: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        this.widget.datamap["name"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                MediaQuery.of(context).size.width / 2 * 0.2),
                      ),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            //begin: Alignment.centerLeft,
                            //end: Alignment.centerRight,
                            colors: sponsor_colors[
                                        this.widget.datamap["sponsor"]] !=
                                    null
                                ? sponsor_colors[this.widget.datamap["sponsor"]]
                                : [Colors.grey, Colors.grey.shade300],
                          ).createShader(bounds);
                        },
                        child: Text(
                          "${this.widget.datamap["sponsor"]} Sponsor",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width / 2 * 0.2),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        this
                            .widget
                            .datamap["desc"]
                            .toString()
                            .replaceAll("\\n", "\n"),
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.width / 2 * 0.0680),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Redes sociais",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                MediaQuery.of(context).size.width / 2 * 0.2),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (this.widget.datamap["linkedin"].toString() !=
                                      'null' &&
                                  this.widget.datamap["linkedin"].toString() !=
                                      '')
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => {
                                        launchURL(this
                                            .widget
                                            .datamap["linkedin"]
                                            .toString()),
                                      },
                                      child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            /*image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/facebook.png")),*/
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  blurRadius: 20,
                                                  offset: Offset(0, 5))
                                            ],
                                            color: Color.fromARGB(
                                                255, 234, 225, 211),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7.5,
                                                      vertical: 7.5),
                                              child: Image.asset(
                                                  "assets/images/linkedin.png",
                                                  scale: 0.2),
                                            ),
                                          )),
                                    )
                                  ],
                                ),
                              if (this.widget.datamap["instagram"].toString() !=
                                      'null' &&
                                  this.widget.datamap["instagram"].toString() !=
                                      '')
                                Row(
                                  children: [
                                    if (this
                                            .widget
                                            .datamap["linkedin"]
                                            .toString() !=
                                        'null')
                                      SizedBox(width: 30),
                                    GestureDetector(
                                      onTap: () => {
                                        launchURL(this
                                            .widget
                                            .datamap["instagram"]
                                            .toString()),
                                      },
                                      child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            /*image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/facebook.png")),*/
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  blurRadius: 20,
                                                  offset: Offset(0, 5))
                                            ],
                                            color: Color.fromARGB(
                                                255, 234, 225, 211),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7.5,
                                                      vertical: 7.5),
                                              child: Image.asset(
                                                  "assets/images/instagram.png",
                                                  scale: 0.2),
                                            ),
                                          )),
                                    ),
                                    /*this.widget.datamap
                                                      ["facebook"]
                                                  .toString() ==
                                              'null'
                                          ? Container(
                                              height: 40,
                                              width: 40,
                                              child: Image.asset(
                                                  "assets/images/instagram.png"),
                                            )
                                          : Container(
                                              height: 0,
                                            )*/
                                  ],
                                ),
                              if (this.widget.datamap["link"].toString() !=
                                      'null' &&
                                  this.widget.datamap["link"].toString() != '')
                                Row(
                                  children: [
                                    if (this
                                                .widget
                                                .datamap["linkedin"]
                                                .toString() !=
                                            'null' ||
                                        this
                                                .widget
                                                .datamap["instagram"]
                                                .toString() !=
                                            'null')
                                      SizedBox(width: 30),
                                    GestureDetector(
                                      onTap: () => {
                                        launchURL(this
                                            .widget
                                            .datamap["link"]
                                            .toString()),
                                      },
                                      child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            /*image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/facebook.png")),*/
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  blurRadius: 20,
                                                  offset: Offset(0, 5))
                                            ],
                                            color: Color.fromARGB(
                                                255, 234, 225, 211),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7.5,
                                                      vertical: 7.5),
                                              child: Image.asset(
                                                  "assets/images/web.png",
                                                  scale: 0.2),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              if (this.widget.datamap["facebook"].toString() !=
                                      'null' &&
                                  this.widget.datamap["facebook"].toString() !=
                                      '')
                                Center(
                                  child: Row(
                                    children: [
                                      if (this
                                                  .widget
                                                  .datamap["linkedin"]
                                                  .toString() !=
                                              'null' ||
                                          this
                                                  .widget
                                                  .datamap["link"]
                                                  .toString() !=
                                              'null' ||
                                          this
                                                  .widget
                                                  .datamap["instagram"]
                                                  .toString() !=
                                              'null')
                                        SizedBox(width: 30),
                                      GestureDetector(
                                        onTap: () => {
                                          launchURL(this
                                              .widget
                                              .datamap["facebook"]
                                              .toString()),
                                        },
                                        child: Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              /*image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/facebook.png")),*/
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    blurRadius: 20,
                                                    offset: Offset(0, 5))
                                              ],
                                              color: Color.fromARGB(
                                                  255, 240, 231, 215),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7.5,
                                                        vertical: 7.5),
                                                child: Image.asset(
                                                    "assets/images/facebook.png",
                                                    scale: 0.2),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                )
                            ]),
                      ),
                      SizedBox(height: 40),
                    ]),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 175,
                width: 175,
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(this.widget.datamap["img"])),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 20,
                        offset: Offset(0, 20))
                  ],
                  color: Color.fromARGB(255, 234, 225, 211),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 20,
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
                    child: RotatedBox(
                        quarterTurns: 3,
                        child: Icon(Icons.arrow_back_ios_new_rounded)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
