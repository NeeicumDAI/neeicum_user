import 'package:flutter/material.dart';
import 'package:NEEEICUM/auth/empresa.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  void searchEmpresa(Barcode barcode) async {
    final ref = FirebaseDatabase.instance
        .ref()
        .child('empresas')
        .child(empresaId)
        .child('reg')
        .child(barcode.rawValue.toString());

    // toma o valor do userId presente em ref

    final snap = await ref.get();

    ref.set({'appear': true});

    addCoins(barcode);
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
            onDetect: (capture) {
              // ao detetar um QR code
              final List<Barcode> barcodes = capture
                  .barcodes; // guarda o valor do QR code lido na lista barcodes
              cameraController
                  .stop(); // para a camara, parando a leitura de QR codes
              for (final barcode in barcodes) {
                // atribui o valor do ultimo barcode na lista à variavel barcode
                // chama a função searchWorkshop
                // mostra um pop-up com a informação do QR code presente em barcode
                searchEmpresa(barcode);
                checkforGiveaway(barcode);
                showDialog(
                    context: context,
                    builder: (context) => showResult(context));
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
  Widget showResult(BuildContext context) {
    cameraController.barcodes.drain();
    print("------------------------------------------" + empresaId);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            empresaId,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: () {
                  // limpa a lista de barcodes lidos
                  cameraController.barcodes.drain();
                  // fecha o pop-up com a info do QR code
                  Navigator.of(context).pop();
                  // liga a camara
                  cameraController.start();
                },
                backgroundColor: Colors.orange,
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}