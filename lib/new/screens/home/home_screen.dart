import 'package:NEEEICUM/new/screens/kits/main_shop.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:NEEEICUM/new/screens/Jornadas/jornadas.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:NEEEICUM/new/screens/workshops/workshops.dart';
import 'package:NEEEICUM/new/screens/team/team_view.dart';
import 'package:NEEEICUM/new/screens/avisos/avisos.dart';

import '../../models/course.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //ScrollController _scrollController1 = ScrollController();
  Map datamap = {};
  late StreamSubscription<DatabaseEvent> callback;
  Map mainData = {};

  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  String? username;
  final _name = TextEditingController();

  final PageController _pageController = PageController();
  final _NumerodeAvisos = TextEditingController();

  int _selectedPage = 0; // Página atual (índice)~
  int previousPage = 0;
  int totalAvisos = 10;
  late Timer _timer; 

  List<Map<String, dynamic>> _avisos = [];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      double minScrollExtent = _scrollController1.position.minScrollExtent;
      double maxScrollExtent = _scrollController1.position.maxScrollExtent;

      animateToMaxMin(maxScrollExtent, minScrollExtent, maxScrollExtent, 30,
          _scrollController1);
    });*/

    getCourses().then((_){
    setState(() {
        
      });
    });
    fetchAvisos().then((data) {
    setState(() {
      _avisos = data;
    });});
    
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('parcerias');
    Stream<DatabaseEvent> stream = dbRef.orderByChild('date').onValue;
    stream.listen((DatabaseEvent event) {
      updateInfo(event.snapshot.children);
    });

    DatabaseReference UserRef = FirebaseDatabase.instance.ref("users/${FirebaseAuth.instance.currentUser?.uid.trim()}");
    print(FirebaseAuth.instance.currentUser?.uid);
    Stream<DatabaseEvent> stream_user = UserRef.onValue;
    stream_user.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      updateName(data);
    });

  
  }
  
  Future<List<Map<String, dynamic>>> fetchAvisos() async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('avisos');
  
  try {
    final DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      // Transformar os dados em uma lista de mapas e filtrar os avisos onde `show` é `true`
      final avisos = snapshot.children
          .map((e) => Map<String, dynamic>.from(e.value as Map))
          .where((aviso) => aviso['show'] == true)
          .toList();
      
      return avisos; // Lista filtrada
    } else {
      return []; // Nenhum dado encontrado
    }
  } catch (e) {
    print('Erro ao buscar avisos: $e');
    return [];
  }
}
  void updateAvisos (data) {
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
  // Função para iniciar o slider automático nos Avisos
  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
    /*  if(previousPage != _selectedPage){
        _restartAutoSlide();
      } else*/
       if (_selectedPage < _avisos.length - 1) {
        // Se não for o último aviso, avança para o próximo
        _selectedPage++;
        
      // Muda a página no PageView
        _pageController.animateToPage(
        _selectedPage,
        duration: Duration(milliseconds: 500), // Animação suave de transição
        curve: Curves.easeInOut, // Tipo de transição suave
      );
      } else {
        // Caso contrário, reinicia para o primeiro aviso
        _selectedPage = 0;
        _pageController.jumpToPage(_selectedPage);
      }

      previousPage=_selectedPage;
      setState(() {}); // Atualiza a interface
    });
  }

      // Reinicia o timer manualmente quando o user interage
    void _restartAutoSlide() {
      _timer.cancel(); // Cancela o timer atual
      _startAutoSlide(); // Inicia um novo timer
    }
    @override
    void dispose() {
      _timer.cancel(); // Cancela o timer quando o widget é destruído
      _pageController.dispose(); // Libera o controlador do PageView
      super.dispose();
    }
  void updateName(dynamic data) {
    if (mounted) {
      setState(() {
        _name.text = data['name'];
      });
    }
  }

  void updateInfo(data) {
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

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(onTap: () {}, child: child),
      );

  Widget openWorkshop(int index) => makeDismissible(
        child: SingleChildScrollView(
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
                          topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        datamap[datamap.keys.elementAt(index)]["name"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width / 2 * 0.2),
                      ),
                      SizedBox(height: 20),
                      Text(
                        datamap[datamap.keys.elementAt(index)]["desc"]
                            .toString()
                            .replaceAll("\\n", "\n"),
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: MediaQuery.of(context).size.width / 2 * 0.0680),
                      ),
                      SizedBox(height: 35),
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
                          image: NetworkImage(datamap[datamap.keys.elementAt(index)]["img"])),
                      boxShadow: [
                        BoxShadow(color: Colors.grey, blurRadius: 20, offset: Offset(0, 20))
                      ],
                      color: Color.fromARGB(255, 66, 66, 66),
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
                            quarterTurns: 3, child: Icon(Icons.arrow_back_ios_new_rounded)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      );

// Abrir qr code na appbar
  Widget openQr() {
    return StatefulBuilder(builder: ((context, setState) {
      return makeDismissible(
          child: SingleChildScrollView(
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
                        topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Center(
                      child: Container(
                        height: MediaQuery.of(context).size.width / 1.5,
                        width: MediaQuery.of(context).size.width / 1.5,
                        decoration: const BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 30.0,
                                  offset: Offset(0.0, 0.75))
                            ]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: QrImage(
                            data: uid!.trim(),
                            padding: const EdgeInsets.all(10),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 100),
                  ]),
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
                          quarterTurns: 3, child: Icon(Icons.arrow_back_ios_new_rounded)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ));
    }));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    int totalAvisos = (_NumerodeAvisos.value is int)
    ? _NumerodeAvisos.value as int
    : int.tryParse(_NumerodeAvisos.value.toString()) ?? 1;

    username = _name.text.split(" ")[0];
   //username = 'Cristianoooo';
    int fontsize_username = username != null ? username!.length : 0; //check letters of username

// Logica para a bola com Cor dependendo do número de Avisos Existentes
    final int bolinhasCount = (_avisos.length < 5) ? _avisos.length : 5;
   
    bool checkBolinha = false;

    int selectedBall = 0;

    if (_selectedPage >= 4 && _selectedPage < _avisos.length-1) {
      // Enquanto o usuário está entre o 4º aviso e o último, a bolinha selecionada será a 4ª (índice 3)
      selectedBall = 3;
    } else if (_selectedPage == _avisos.length-1 ) {
      // Quando chega ao último aviso, a bolinha selecionada será a última
      selectedBall = bolinhasCount-1;
    } else {
      // Se estiver nos primeiros 4 avisos, a bolinha selecionada será a correspondente
      selectedBall = _selectedPage;
    }

   

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(screenWidth, context), // NEEEICUM e QR Code
              NomeELogoNeeicum(screenWidth, fontsize_username, screenHeight),
              RowBotoes(context), // Equipa Workshops Jornadas Kits
      // Nome: Avisos  +  Bolinhas
                  Padding(
                        padding: const EdgeInsets.only(top:20, left:20),
                        child: Text(
                          "Avisos",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
              Avisos_Section(bolinhasCount, checkBolinha),
        //Parte das Parcerias
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Parcerias",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              DisplayParcerias(),
            const SizedBox(height: 40),
        /*      
        // Codigo Anterior
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Equipa",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              ...recentCourses.map(
                (course) => Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: SecondaryCourseCard(course: course),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  Container DisplayParcerias() {
    return Container(
              height: 230,
              child: ListView.builder(
                  clipBehavior: Clip.none,
                  //controller: _scrollController1,
                  //physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(/*top: 5, bottom: 35.0*/),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: datamap.keys.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: GestureDetector(
                          onTap: (() => showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) => openWorkshop(index))),
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                              height: 230,
                              width: 220,
                              decoration: const BoxDecoration(
                                color: const Color.fromARGB(255, 66, 66, 66),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey, blurRadius: 30, offset: Offset(0, 10))
                                ],
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                                  child: Image.network(
                                      datamap[datamap.keys.elementAt(index)]["img"],
                                      scale: 1),
                                ),
                              )),
                        ));
                  }),
            );
  }

  Row RowBotoes(BuildContext context) {
    return Row(
              children: [
                Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 20),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  TeamViewPage()),//AvisosPage()),
                            );
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              height: (MediaQuery.of(context).size.width * 0.185),
                              width: (MediaQuery.of(context).size.width * 0.185),
                              decoration: const BoxDecoration(
                                color: const Color.fromARGB(255, 66, 66, 66),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey, blurRadius: 30, offset: Offset(0, 10))
                                ],
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                                  child: Icon(
                                    Icons.groups,
                                    color: const Color(0xFFEEF1F8),
                                    size: 40,
                                  ),
                                ),
                              )),
                        ),
                        Text("Equipa")
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 20),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WorkshopsPage()),
                            );
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              height: (MediaQuery.of(context).size.width * 0.185),
                              width: (MediaQuery.of(context).size.width * 0.185),
                              decoration: const BoxDecoration(
                                color: const Color.fromARGB(255, 66, 66, 66),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey, blurRadius: 30, offset: Offset(0, 10))
                                ],
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                                  child: Icon(
                                    Icons.construction_outlined,
                                    color: const Color(0xFFEEF1F8),
                                    size: 40,
                                  ),
                                ),
                              )),
                        ),
                        Text("Workshops")
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 20),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const JornadasPage()),
                            );
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              height: (MediaQuery.of(context).size.width * 0.185),
                              width: (MediaQuery.of(context).size.width * 0.185),
                              decoration: const BoxDecoration(
                                color: const Color.fromARGB(255, 66, 66, 66),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey, blurRadius: 30, offset: Offset(0, 10))
                                ],
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                                  child: Icon(
                                    Icons.electric_bolt_outlined,
                                    color: const Color(0xFFEEF1F8),
                                    size: 40,
                                  ),
                                ),
                              )),
                        ),
                        Text("Jornadas")
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 20),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ShopPage()),
                            );
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              height: (MediaQuery.of(context).size.width * 0.185),
                              width: (MediaQuery.of(context).size.width * 0.185),
                              decoration: const BoxDecoration(
                                color: const Color.fromARGB(255, 66, 66, 66),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey, blurRadius: 30, offset: Offset(0, 10))
                                ],
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                                  child: Icon(
                                    Icons.work,
                                    color: const Color(0xFFEEF1F8),
                                    size: 40,
                                  ),
                                ),
                              )),
                        ),
                        Text("Kits")
                      ],
                    ))
              ],
            );
  }

  Row NomeELogoNeeicum(double screenWidth, int fontsize_username, double screenHeight) {
    return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * 0.05,
                          right: screenWidth * 0.05,
                          top: screenWidth * 0.05),
                      child: Text(
                        username != null ? 'Olá,' : 'Olá!\n',
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.09,
                            color: Color.fromRGBO(33, 33, 33, 33),),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * 0.05,
                          right: screenWidth * 0.05,
                          bottom: screenWidth * 0.05),
                      child: Text(
                        username != null ? '$username !' : '',
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
                            fontSize: fontsize_username <= 5
                                ? screenWidth * 0.09
                                : screenWidth * 0.09 * (5 / fontsize_username) + 10,
                                color:Color.fromRGBO(33, 33, 33, 33),),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                GestureDetector(
                  child: Image.asset('assets/images/logo.png',
                      height: screenHeight * 0.2, width: screenWidth * 0.35, fit: BoxFit.contain),
                  onTap: () {
                    /* final User? user = FirebaseAuth.instance.currentUser; // getting UID
                String? userId = user?.uid;
                _showQRCodeDialog(context, userId);*/
                  },
                ),
              ],
            );
  }

  Stack TopBar(double screenWidth, BuildContext context) {
    return Stack(
              children: [
                // Texto centralizado na tela
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                    child: Text(
                      'NEEEICUM',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: (screenWidth * 0.06),
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 101, 100, 100),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Ícone alinhado à direita
                Positioned(
                  right: 10,
                  top: 20,
                  child: SafeArea(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return openQr();
                            },
                          );
                        });
                      },
                      child: Container(
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
                            ),
                          ],
                        ),
                        child: Icon(Icons.qr_code_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            );
  }
  GestureDetector Avisos_Section(int bolinhasCount, bool checkBolinha) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AvisosPage()),
      );
    },
    child: Column(
      children: [
        Container(
          height: 200, // Altura para o PageView
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            itemCount:_avisos.length, // Número de avisos
            onPageChanged: (index) {
              setState(() {
                _selectedPage = index; // Atualiza a bolinha selecionada
                _restartAutoSlide();
              });
            },
            itemBuilder: (context, index) {
              final aviso = _avisos[index];
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(0, -index * 0.0), // Ajuste o deslocamento
                      child: Container(
                        width: constraints.maxWidth, // Usa a largura disponível
                        margin: EdgeInsets.symmetric(horizontal: 30.0), // Margem para efeito visual
                        height: 150, // Altura do retângulo
                        decoration: BoxDecoration(
                          color: Colors.grey[((index % 5 + 2) * 100).toInt()],
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(0, 5), // Sombra para profundidade
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top:8.0, left:2.0, bottom: 8.0, right:5.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Container(
                                    height: 150,
                                    width: 150,
                                    decoration:BoxDecoration(
                                       image: DecorationImage(image: 
                                           aviso['img'] != null
                                                  ? NetworkImage(aviso['img'])
                                                  : AssetImage('assets/images/logo_w_grey.png') as ImageProvider,
                                                  fit: BoxFit.fill,
                                            ),
                                            color: Colors.grey[((index % 5 + 2) * 100).toInt()],
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                            )),
                                ),
                                const SizedBox(width: 10),
                                Expanded( // centraliza o título
                                  child: Column(
                                   mainAxisAlignment: MainAxisAlignment.start, // Centraliza verticalmente na coluna
                                   crossAxisAlignment: CrossAxisAlignment.start, // Alinha o texto à esquerda
                                    children: [
                                      Text( aviso['name'] ?? 'Sem nome', 
                                          //'Workshop ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black, 
                                            fontSize: 18),
                                          maxLines: 2, // Quebra o texto se necessário
                                          overflow: TextOverflow.visible, // Permite quebra em novas linhas,
                                        ),                             
                                      SizedBox(height: 8),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.only(right:5.0),
                                          child: Text(
                                            aviso['desc'] ?? 'Sem descrição',
                                            style: TextStyle(color: Colors.black54, fontSize: 8),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ), 
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
  
        // Bolinhas (indicadores de página)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(bolinhasCount, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedPage == index ? Colors.orange : Colors.grey,
              ),
            );
          }),
        ),
      ],
    ),
  );
  }
}
