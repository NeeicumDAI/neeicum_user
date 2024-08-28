import 'package:flutter/material.dart';

class SlideBlock extends StatelessWidget {
  SlideBlock(
      {super.key, required this.page, required this.icon, required this.name});
  final Widget page;
  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => page),
                );
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  height: (MediaQuery.of(context).size.width * 0.185),
                  width: (MediaQuery.of(context).size.width * 0.185),
                  decoration: const BoxDecoration(
                    color: const Color.fromARGB(255, 66, 66, 66),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 30,
                          offset: Offset(0, 10))
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 0),
                      child: Icon(
                        icon,
                        color: const Color(0xFFEEF1F8),
                        size: 40,
                      ),
                    ),
                  )),
            ),
            Text(name)
          ],
        ));
  }
}
