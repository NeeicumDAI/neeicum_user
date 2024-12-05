import 'package:flutter/material.dart';

import 'package:NEEEICUM/new/screens/team/presidencia.dart';
import 'package:NEEEICUM/new/screens/team/assembleia.dart';
import 'package:NEEEICUM/new/screens/team/conselhofiscal.dart';

import 'package:firebase_database/firebase_database.dart';

// Visualização Ao clicar no Botão Equipa na Página Principal

class TeamViewPage extends StatefulWidget  {
  @override
  State<TeamViewPage> createState() => _TeamViewPageState();
}

class _TeamViewPageState extends State<TeamViewPage> with SingleTickerProviderStateMixin {

late TabController _tabController;
final _mandato = TextEditingController();

  @override
  void initState()  {
    super.initState();
    // Inicializar o controlador
    _tabController = TabController(length: 3, vsync: this);
    

    //get Mandato from Firebase
    DatabaseReference mandato_reference = FirebaseDatabase.instance.ref().child("equipa").child("Mandato");
    Stream<DatabaseEvent> mandato_stream = mandato_reference.onValue;
        mandato_stream.listen((DatabaseEvent event) {
            final data =  event.snapshot.value;
            _updateMandato(data);
    });
  }

  @override
  void dispose() {
    // Dispose do controlador ao destruir o widget
    _tabController.dispose();
    super.dispose();
  }

// update do Mandato
  Future _updateMandato(dynamic data)async{
      if (mounted) {
      setState(() {
        _mandato.text = data;
      });
    }
    
  }

  @override
 Widget build(BuildContext context)  {
   
    return DefaultTabController(
          length: 3, // Número de páginas
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                _mandato.text,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 23,
                  color: Colors.grey[800],
                ),
              ),
              backgroundColor: Colors.grey[100],
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              bottom: PreferredSize(
              preferredSize:const Size.fromHeight(kToolbarHeight), // Adjust height if needed
              child: Container(
                child:TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: false,
                dividerColor: Colors.transparent,
                labelColor: Colors.grey[800],
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: Colors.orange[400],
                labelStyle: const TextStyle(
                  fontSize: 20, // Size for the selected tab's text
                  fontWeight: FontWeight.bold, // Weight for the selected tab's text
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14, // Size for the unselected tab's text
                  fontWeight: FontWeight.normal, // Weight for the unselected tab's text
                ),
                tabs: [
                  Tab(text: 'Direção'),
                  Tab(text: 'AG'),
                  Tab(text: 'CF'),
                ],
              ),
            ),
            ),
            ),
            body: 
            TabBarView(
              controller: _tabController,
              children: [
                Center(child: PresidenciaPage()),
                Center(child: AssembleiaPage()),
                Center(child: ConselhoFiscalPage()),
              ],
            ),
              
            
          ),
        );
  }
}
