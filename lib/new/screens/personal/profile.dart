//import 'dart:html';

import 'dart:io';

import 'package:NEEEICUM/new/screens/personal/curriculo.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:win32/win32.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _n_aluno = TextEditingController();
  final _n_socio = TextEditingController();
  final _name = TextEditingController();
  final avatar = TextEditingController();
  final profile_avatar = TextEditingController();
  final _phone = TextEditingController();

  final description = TextEditingController();


  final TextEditingController _interesseController = TextEditingController();
  List<String> interesses = ['Engenharia', 'Tecnologia', 'Ciências', 'Comunicação e Marketing', 'Design'];



  bool editmode = false;
  bool firsttime = false;
  bool hasFile = false;
  bool change = false;
  File? _selectedFile;
  int? _pdfPage = 0;
  bool cota = false;
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("users/${FirebaseAuth.instance.currentUser?.uid.trim()}");
  DateTime dateTime = DateTime.now();

  final FirebaseStorage _storage = FirebaseStorage.instance;

    void adicionarInteresse() {
    setState(() {
      interesses.add(_interesseController.text);
      _interesseController.clear();
    });
  }

  void updateInfo(data) {
    if (mounted) {
      setState(() {
        description.text = data['desc'];
        _n_socio.text =
            data['n_socio'] == null ? "" : data['n_socio'].toString();
        _name.text = data['name'];
        _n_aluno.text = data['aluno'] == null ? "" : data['aluno'].toString();
        cota = data['cotas'];
        _phone.text = data['phone'] == null ? "" : data['phone'].toString();
        profile_avatar.text =
            data['avatar'] == null ? "" : data['avatar'].toString();
        if (data['avatar'] == null) {
          firsttime = true;
        } else {
          firsttime = false;
        }
        print(profile_avatar.text);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      updateInfo(data);
    });
  }

  Future UpdateData() async {
    await ref.update({
      'name': _name.text.trim(),
      'aluno': _n_aluno.text.trim(),
      'phone': int.parse(_phone.text),
    });
  }

  Future UpdateDesc() async {
    await ref.update({
      'desc': description.text
    });
  }

  Widget openWorkshop() {
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
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Os teus dados",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width / 2 * 0.2),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        TextFormField(
                          controller: _name,
                          decoration: InputDecoration(
                            filled: true, // This fills the background
                            fillColor: Colors.white,

                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 66, 66, 66),
                                )),
                            labelText: 'Nome',
                            icon: Icon(Icons.person),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: _n_aluno,
                          decoration: InputDecoration(
                            filled: true, // This fills the background
                            fillColor: Colors.white,

                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 66, 66, 66),
                                )),
                            labelText: 'Nº Aluno',
                            icon: Icon(Icons.book),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: _phone,
                          decoration: InputDecoration(
                            filled: true, // This fills the background
                            fillColor: Colors.white,

                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 66, 66, 66),
                                )),
                            labelText: 'Nº Telemóvel',
                            icon: Icon(Icons.phone_rounded),
                          ),
                        ),
                        SizedBox(height: 40),
                        Center(
                            child: MaterialButton(
                          onPressed: () => {
                            setState(() => {
                                  if (_name.text.isNotEmpty &&
                                      _n_aluno.text.isNotEmpty)
                                    {
                                      UpdateData(),
                                    },
                                  if (_selectedFile != null) _uploadFile(),
                                  Navigator.of(context).pop()
                                }),
                          },
                          child: Container(
                            width: 300,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 30,
                                    offset: Offset(0, 10))
                              ],
                              color: Colors.orange,
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.add,
                                    size: 30.0,
                                    color: Color(0xFFEEF1F8),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Atualizar dados",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFFEEF1F8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                        SizedBox(height: 10),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 15,
                        )
                      ]),
                ),
              ),
              editmode
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 175,
                        width: 175,
                        child: CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 61, 60, 60),
                          child: CircleAvatar(
                            radius: 175 / 2,
                            backgroundColor: Color.fromARGB(255, 61, 60, 60),
                            backgroundImage: FileImage(_selectedFile!),
                          ),
                        ),
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                blurRadius: 30,
                                offset: Offset(0, 7.5))
                          ],
                          color: Color.fromARGB(255, 223, 214, 198),
                          /*border: Border.all(
                        color: Color.fromARGB(255, 66, 66, 66), // Border color
                        width: 2.0, // Border width
                      )*/
                          /*borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),*/
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 175,
                        width: 175,
                        child: profile_avatar.text == ""
                            ? CircleAvatar(
                                backgroundColor:
                                    Color.fromARGB(255, 61, 60, 60),
                                child: CircleAvatar(
                                  radius: 175 / 2,
                                  backgroundColor:
                                      Color.fromARGB(255, 61, 60, 60),
                                  backgroundImage:
                                      AssetImage("assets/images/logo_w.png"),
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor:
                                    Color.fromARGB(255, 61, 60, 60),
                                child: CircleAvatar(
                                  radius: 175 / 2,
                                  backgroundColor:
                                      Color.fromARGB(255, 61, 60, 60),
                                  backgroundImage:
                                      NetworkImage(profile_avatar.text),
                                ),
                              ),
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                blurRadius: 30,
                                offset: Offset(0, 7.5))
                          ],
                          color: Color.fromARGB(255, 223, 214, 198),
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
              Positioned(
                top: 120,
                left: MediaQuery.of(context).size.width / 1.6,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () async {
                      final result = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);

                      if (result != null) {
                        File imageFile = File(result!.path);
                        int fileSizeInBytes = imageFile.lengthSync();

                        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
                        if (fileSizeInMB < 8) {
                          setState(() {
                            _selectedFile = File(result.path);
                            _pdfPage = 0;
                            editmode = true;
                            hasFile = true;
                            firsttime = true;
                          });
                        } else {
                          showLimitExceededSnackbar(context);
                        }
                      } else {
                        print('No file selected.');
                      }
                    },
                    child: Container(
                      //margin: const EdgeInsets.only(left: 16),
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 194, 193, 193),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, 3),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Icon(Icons.edit),
                    ),
                  ),
                ),
              )
            ],
          ),
        ]),
      ));
    }));
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
              'Only size limit of 8MB.',
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

  Future<void> removefile() async {
    Reference urlReference =
        FirebaseStorage.instance.refFromURL(profile_avatar.text);

    await urlReference.delete();
    print('File deleted successfully');

    await ref.child('avatar').remove();
    setState(() {
      change = false;

      editmode = false;
      firsttime = false;
      hasFile = false;
    });
    initState();
  }

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(onTap: () {}, child: child),
      );

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
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            height: MediaQuery.of(context).size.width / 1.5,
                            width: MediaQuery.of(context).size.width / 1.5,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
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
                          quarterTurns: 3,
                          child: Icon(Icons.arrow_back_ios_new_rounded)),
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

  Future<void> _uploadFile() async {
    if (profile_avatar.text != "") {
      Reference urlReference =
          FirebaseStorage.instance.refFromURL(profile_avatar.text);

      await urlReference.delete();
      print('File deleted successfully');
    }

    try {
      if (_selectedFile != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
            '_' +
            _selectedFile!.path.split('/').last;
        Reference storageReference =
            _storage.ref().child('avatar_profiles').child(fileName);

        await storageReference.putFile(_selectedFile!);

        String downloadURL = await storageReference.getDownloadURL();

        await ref.update({'avatar': downloadURL});

        setState(() {
          avatar.text = downloadURL;
          editmode = false;
        });

        print('PDF uploaded and URL saved: $downloadURL');
      } else {
        print('No file selected.');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  void GetInfo() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 223, 214, 198),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            scrollable: true,
            title: const Text(
              'Atualizar dados',
              textAlign: TextAlign.center,
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _name,
                      decoration: InputDecoration(
                        filled: true, // This fills the background
                        fillColor: Color.fromARGB(255, 223, 214, 198),

                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 66, 66, 66),
                            )),
                        labelText: 'Nome',
                        icon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _n_aluno,
                      decoration: InputDecoration(
                        filled: true, // This fills the background
                        fillColor: Color.fromARGB(255, 223, 214, 198),

                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 66, 66, 66),
                            )),
                        labelText: 'Nº Aluno',
                        icon: Icon(Icons.book),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _phone,
                      decoration: InputDecoration(
                        filled: true, // This fills the background
                        fillColor: Color.fromARGB(255, 223, 214, 198),

                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 66, 66, 66),
                            )),
                        labelText: 'Nº Telemóvel',
                        icon: Icon(Icons.phone_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FloatingActionButton(
                backgroundColor: Color.fromARGB(255, 241, 133, 25),
                onPressed: () {
                  if (_name.text.isNotEmpty && _n_aluno.text.isNotEmpty) {
                    UpdateData();
                    Navigator.of(context).pop();
                  }
                },
                child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F8),
      body: Stack(
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
                      "O MEU PERFIL",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.width / 2.75,
                      width: MediaQuery.of(context).size.width / 2.75,
                      child: profile_avatar.text == ""
                          ? CircleAvatar(
                              backgroundColor: Color.fromARGB(255, 61, 60, 60),
                              child: CircleAvatar(
                                radius: 100,
                                backgroundColor:
                                    Color.fromARGB(255, 61, 60, 60),
                                backgroundImage:
                                    AssetImage("assets/images/logo_w.png"),
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Color.fromARGB(255, 61, 60, 60),
                              child: CircleAvatar(
                                radius: 100,
                                backgroundColor:
                                    Color.fromARGB(255, 61, 60, 60),
                                backgroundImage:
                                    NetworkImage(profile_avatar.text),
                              ),
                            ),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                _name.text,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              
                              Center(
                                child: Text(
                                  
                                  "Engenharia Eletrónica Industrial e Computadores",
                                  style:  TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width/30,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 1,
                              ),
                              Center(
                                child: IntrinsicWidth(
                                  child: IntrinsicHeight(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 8, right: 8),
                                      //width: MediaQuery.of(context).size.width *0.85,
                                         // height:MediaQuery.of(context).size.width /18.5,
                                      decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 83, 83, 83),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                      child: Center(
                                        child: Text(
                                          
                                          "ESTOU DISPONÍVEL PARA OPORTUNIDADES DE EMPREGO",
                                          style:  TextStyle(
                                            color: const Color.fromARGB(255, 219, 217, 217),
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context).size.width/40,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                            ],
                          ),
                          Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 10),
                                  child: 
                                    
                                          Column(
                                            children: [
                                              Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 0),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: TextFormField(
                                                      controller: description,
                                                      minLines: 2,
                                                      maxLines: INFINITE,
                                                      readOnly: false,
                                                      style: TextStyle(
                                                        fontSize:MediaQuery.of(context).size.width*0.03                                                     ),
                                                      keyboardType: TextInputType.multiline,
                                                      decoration: InputDecoration(
                                                        
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                          borderSide: BorderSide.none,
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                          borderSide: BorderSide.none,
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                          borderSide: BorderSide.none,
                                                        ),
                                                        hintText: "Descrição",
                                                        hintStyle: TextStyle(
                                                          fontSize: MediaQuery.of(context).size.width*0.01 ,
                                                          color: Colors.grey
                                                        )
                                                      ),
                                                    )
                                                  ),
                                                ),
                                              ),
                                              /*ElevatedButton(onPressed: (){
                                                UpdateDesc();
                                              }
                                              , child: Text("data"))*/
                                            ],
                                          ),
                                ),
                          Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                  Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 10, top: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CurriculoPage()),
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *0.3,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.1,
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 102, 102, 102),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10
                                              ))),
                                      child: Padding(padding: EdgeInsets.all(0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                                        size: MediaQuery.of(context).size.width*0.07,
                                                        Icons.article,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 1,),
                                                      Text("LinkedIn",style: TextStyle(fontSize: 10,color: Colors.white),)
                                          
                                        ],

                                      ),
                                      )
                                          ),
                                    ),
                                  ),
                                
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 20, top: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CurriculoPage()),
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *0.3,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.1,
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 102, 102, 102),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10
                                              ))),
                                      child: Padding(padding: EdgeInsets.all(0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                                        size: MediaQuery.of(context).size.width*0.07,
                                                        Icons.article_rounded,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 1,),
                                                      Text("Ver CV",style: TextStyle(fontSize: 10,color: Colors.white),)
                                          
                                        ],

                                      ),
                                      )
                                          ),
                                        
                                      ),
                                    
                                  ),
                                
                                  ],

                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left:20),
                              child: Text("Informações de contacto"),
                            )),
                          Padding(
                            padding: EdgeInsets.only(left: 20,right: 20,top:2),
                            child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 20,right: 20),
                                          child: Row(
                                            children: [Container(
                                              width: (MediaQuery.of(context).size.width-80)*0.4 ,
                                              child: Text("Email",style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold),)),
                                              Container(
                                              width: (MediaQuery.of(context).size.width - 80)*0.6 ,
                                              child: Text(
                                                overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                "a101741@alunos.uminho.pt"))
                                              ],
                                            
                                          ),
                                        )
                                      ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 20,right: 20,top:2),
                            child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 20,right: 20),
                                          child: Row(
                                            children: [Container(
                                              width: (MediaQuery.of(context).size.width-80)*0.4 ,
                                              child: Text("Telefone",style:TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold))),
                                              Container(
                                              width: (MediaQuery.of(context).size.width - 80)*0.6 ,
                                              child: Text(overflow:
                                                                        TextOverflow
                                                                            .ellipsis,"912184704"))
                                              ],
                                            
                                          ),
                                        )
                                      ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 20,right: 20,top:2),
                            child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 20,right: 20),
                                          child: Row(
                                            children: [Container(
                                              width: (MediaQuery.of(context).size.width-80)*0.4 ,
                                              child: Text("Cidade",style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold))),
                                              Container(
                                              width: (MediaQuery.of(context).size.width - 80)*0.6 ,
                                              child: Text("Valongo city"))
                                              ],
                                            
                                          ),
                                        )
                                      ),
                          ),SizedBox(height: 10,),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left:20),
                              child: Text("Interesses"),
                            )),
        
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left:20,bottom: 10,right: 10),
            child: Wrap(
              spacing: 10.0, // Adjust spacing between buttons
              runSpacing: 7.5,
              
              children: interesses.map((interesse) {
                return SizedBox(
                  height: MediaQuery.of(context).size.width*0.07,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.grey),
                      overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                    ),
                    onPressed: () {              },
                    child: Text(interesse,style: TextStyle(color: const Color.fromARGB(255, 242, 241, 241),fontWeight:
                                                                                  FontWeight
                                                                                      .bold,fontSize: MediaQuery.of(context).size.width*0.03)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
  
        
      
                          
                          
                            
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
