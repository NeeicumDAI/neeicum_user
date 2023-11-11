import 'dart:io';

import 'package:flutter/material.dart';
import 'package:NEEEICUM/auth/empresa.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/*
* Scanner de QR codes usado para verificar se um user está inscrito
* num workshop organizado pelo neeeicum
*/

class QrPageEmpresa extends StatefulWidget {
  const QrPageEmpresa({super.key});

  @override
  State<QrPageEmpresa> createState() => _QrPageEmpresaState();
}

class _QrPageEmpresaState extends State<QrPageEmpresa> {
  String logoCurso = "assets/images/logo_w.png";
  bool inscricao = false;
  MobileScannerController cameraController =
      MobileScannerController(facing: CameraFacing.back);
  String feedback = '';
  Color feedbackColor = Colors.green;
  IconData feedbackIcon = Icons.done;

  /*
  * procura na isntancia 'workshop/reg' o userId lido pelo scanner
  * se o userId existirna instancia muda a variavel 'appear' para true
  * e mostra um pop up a confirmar a presença do user, se o userId não existir
  * mostra um pop up a informar que o userId nao está inscrito no workshop
  */
  Future<void> checkforGiveaway(Barcode barcode) async {
    int inscricoes = 0;
    DatabaseReference empresasRef =
        FirebaseDatabase.instance.ref().child("empresas");
    Map data;

    final giveawayRef = FirebaseDatabase.instance
        .ref()
        .child('jee')
        .child("giveaway")
        .child(barcode.rawValue.toString());

    await empresasRef.get().then((value) {
      data = Map<dynamic, dynamic>.from(value.value as Map);
      data.forEach((key, value) async {
        DatabaseReference empresaRegRef =
            empresasRef.child("$key").child("reg");
        DataSnapshot regSnapshot = await empresaRegRef.get();
        final regData = Map<dynamic, dynamic>.from(regSnapshot.value as Map);

        if (regData.containsKey(barcode.rawValue.toString())) {
          inscricoes++;
          if (inscricoes >= data.length) {
            giveawayRef.set({'appear': true});
          }
        }
      });
    });
  }

  void showLimitExceededSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              size: 32, // Adjust the size of the icon as needed.
              color: Colors.white, // Adjust the icon color as needed.
            ),
            SizedBox(width: 10), // Add some spacing between the icon and text.
            Text(
              'Não tem currículo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18, // Adjust the font size of the text as needed.
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), // Adjust the border radius as needed.
            topRight:
                Radius.circular(20), // Adjust the border radius as needed.
          ),
        ), // Adjust the duration as needed.
      ),
    );
  }

  Future launchCV(Barcode barcode) async {
    final studentCV = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(barcode.rawValue.toString())
        .child("cv");

    final snap = await studentCV.get();
    if (snap.exists) {
      String link = snap.value.toString();
      launchURL(link);
    } else {
      showLimitExceededSnackbar(context);
    }
  }

  void launchURL(url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } else {}
  }

  Future<void> searchEmpresa(Barcode barcode) async {
    final flagAcred = FirebaseDatabase.instance
        .ref()
        .child('neeeicoins')
        .child(barcode.rawValue.toString());

    final ref = FirebaseDatabase.instance
        .ref()
        .child('empresas')
        .child(empresaId)
        .child('reg')
        .child(barcode.rawValue.toString());

    // toma o valor do userId presente em ref

    final snap = await ref.get();
    final points = await flagAcred.get();
    if (!(snap.exists)) {
      if (points.exists) {
        ref.set({'appear': true});
        addCoins(barcode);
        setState(() {
          feedback = 'Com sucesso!';
          feedbackColor = Colors.green;
          feedbackIcon = Icons.done;
        });
        //feedback = 'Com sucesso!';
      } else {
        setState(() {
          feedback = 'Nao estás acreditado!';
          feedbackColor = Colors.red;
          feedbackIcon = Icons.close;
        });
      }
    } else {
      setState(() {
        feedback = "Repetido";
        feedbackColor = Colors.red;
        feedbackIcon = Icons.close;
      });
    }
  }

  void addCoins(Barcode barcode) async {
    DatabaseReference student = FirebaseDatabase.instance
        .ref()
        .child('neeeicoins')
        .child(barcode.rawValue.toString());
    DatabaseReference eventReg = FirebaseDatabase.instance
        .ref()
        .child('empresas')
        .child(empresaId)
        .child('reg')
        .child(barcode.rawValue.toString());
    DatabaseReference eventCoins = FirebaseDatabase.instance
        .ref()
        .child('empresas')
        .child(empresaId)
        .child('coins');

    final studentCoins = await student.child('coins').get();
    final reg = await eventReg.get();
    final coins = await eventCoins.get();

    if (studentCoins.exists) {
      //if(reg.exists){
      //if(reg.children.first.value == false){
      int addCoins = (studentCoins.value) as int;
      addCoins += coins.exists ? (coins.value) as int : 0;
      student.child('coins').set(addCoins);
      //}

      // }
    }
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller:
                cameraController, // definimos cameraController como controlador do scanner
            onDetect: (capture) async {
              // ao detetar um QR code
              final List<Barcode> barcodes = capture
                  .barcodes; // guarda o valor do QR code lido na lista barcodes
              cameraController
                  .stop(); // para a camara, parando a leitura de QR codes
              for (final barcode in barcodes) {
                // atribui o valor do ultimo barcode na lista à variavel barcode
                // chama a função searchWorkshop
                // mostra um pop-up com a informação do QR code presente em barcode

                searchEmpresa(barcode).then((_) {
                  return checkforGiveaway(barcode);
                }).then((_) {
                  showDialog(
                      context: context,
                      builder: (context) => showResult(context, barcode));
                });
              }
            },
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
                  child: RotatedBox(
                      quarterTurns: 4,
                      child: Icon(Icons.arrow_back_ios_new_rounded)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*
  * função retorna um pop-up que mostra se o user está inscrito
  * ou não no workshop e ainda um botão de fechar o pop up que deve ser usado, 
  * ou então a camara não é ativada novamente, sendo necessário fechar e abrir
  * de novo o scanner para ativar a camara
  */
  Widget showResult(BuildContext context, Barcode barcode) {
    cameraController.barcodes.drain();
    print("------------------------------------------" + empresaId);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Container(
            //width: 30,
            height: MediaQuery.of(context).size.width / 3.25,
            decoration: BoxDecoration(
                color: feedbackColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.width / 3,
                  child: Icon(
                    feedbackIcon as IconData?,
                    size: 100,
                    color: Colors.white,
                  )),
              Text(
                empresa,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(feedback),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StatefulBuilder(builder: (context, inState) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          textStyle: TextStyle(fontSize: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Set rounded borders
                          ),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          launchCV(barcode);
                        },
                        child: Container(
                          width: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf_rounded),
                              SizedBox(
                                width: 5,
                              ),
                              const Text('CV'),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StatefulBuilder(builder: (context, inState) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          textStyle: TextStyle(fontSize: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Set rounded borders
                          ),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // limpa a lista de barcodes lidos
                          cameraController.barcodes.drain();
                          // fecha o pop-up com a info do QR code
                          Navigator.of(context).pop();
                          // liga a camara
                          cameraController.start();
                        },
                        child: Container(
                          width: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded),
                              SizedBox(
                                width: 5,
                              ),
                              const Text('Sair'),
                            ],
                          ),
                        ),
                      );
                    }),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
