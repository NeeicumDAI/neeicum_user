import 'package:flutter/material.dart';
import 'empresaview.dart';

class EmpresaBloco extends StatefulWidget {
  const EmpresaBloco({super.key, required this.datamap});
  final Map datamap;

  @override
  State<EmpresaBloco> createState() => _EmpresaBlocoState();
}

class _EmpresaBlocoState extends State<EmpresaBloco> {
  Map sponsor_colors = {
    "Main": [Colors.orange, Colors.yellow],
    "Team": [Colors.grey, Colors.grey.shade300]
  };

  Widget openEmpresa(Map datamap) =>
      makeDismissible(child: CompanyView(datamap: this.widget.datamap));

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(onTap: () {}, child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: GestureDetector(
          onTap: (() => showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => openEmpresa(this.widget.datamap))),
          child: Stack(
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  height: 125,
                  width: 125,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 234, 225, 211),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(255, 183, 181, 181),
                          blurRadius: 30,
                          offset: Offset(0, 10))
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 0),
                      child:
                          Image.network(this.widget.datamap["img"], scale: 1),
                    ),
                  )),
              Container(
                height: 140,
                width: 130,
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 0),
                        height: 30,
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: sponsor_colors[
                                          this.widget.datamap["sponsor"]] !=
                                      null
                                  ? sponsor_colors[
                                      this.widget.datamap["sponsor"]]
                                  : sponsor_colors["Team"]),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                blurRadius: 30,
                                offset: Offset(0, 10))
                          ],
                          //color: Colors.grey,
                          /*boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              blurRadius: 30,
                                                              offset:
                                                                  Offset(0, 10))
                                                        ],*/
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 0),
                            child: Text(
                              this.widget.datamap["sponsor"],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ))),
              ),
            ],
          ),
        ));
  }
}
