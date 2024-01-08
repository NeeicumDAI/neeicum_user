import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    required this.image,
    required this.name,
    required this.profession,
  }) : super(key: key);

  final String name, profession, image;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color.fromARGB(255, 61, 60, 60),
        child: image == ""
            ? CircleAvatar(
                backgroundColor: Color.fromARGB(255, 61, 60, 60),
                backgroundImage: AssetImage("assets/images/logo_w.png"),
              )
            : CircleAvatar(
                backgroundColor: Color.fromARGB(255, 234, 225, 211),
                backgroundImage: NetworkImage(image),
              ),
      ),
      title: Text(
        overflow: TextOverflow.ellipsis,
        name,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        overflow: TextOverflow.ellipsis,
        profession,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
