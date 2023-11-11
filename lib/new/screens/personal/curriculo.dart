import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class CurriculoPage extends StatefulWidget {
  const CurriculoPage({super.key});

  @override
  State<CurriculoPage> createState() => _CurriculoPageState();
}

class _CurriculoPageState extends State<CurriculoPage> {
  final cv = TextEditingController();
  bool change = false;
  bool ACCEPTED = false;
  bool editmode = false;
  bool firsttime = false;
  bool hasFile = false;
  File? _selectedFile;
  String? uid = FirebaseAuth.instance.currentUser?.uid.trim();
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("users/${FirebaseAuth.instance.currentUser?.uid.trim()}");
  final FirebaseStorage _storage = FirebaseStorage.instance;

  void initState() {
    super.initState();
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      updateInfo(data);
    });
  }

  void resetPDFView() {
    setState(() {
      change = false;
    });
  }

  void updateInfo(data) {
    if (mounted) {
      setState(() {
        cv.text = data['cv'].toString();
        if (data['cv'] == null) {
          hasFile = false;
          firsttime = true;
        } else {
          hasFile = true;
          firsttime = false;
        }
      });
    }
  }

  Future<void> checkUPLOAD() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            /* shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            scrollable: true,*/
            /* title: const Text(
              "PERMISSÃO",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),*/
            child: Stack(
              children: [
                Container(
                  //width: 30,
                  height: MediaQuery.of(context).size.width / 3.25,
                  decoration: BoxDecoration(
                      color: Colors.orange,
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
                          Icons.warning_amber_outlined,
                          size: 100,
                          color: Colors.white,
                        )),
                    Text(
                      "PERMISSÃO",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Permites a partilha do teu CV?"),
                    const SizedBox(
                      height: 10,
                    ),
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
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf'],
                                );

                                if (result != null) {
                                  PlatformFile file = result.files.single;
                                  if (file.size <= 8 * 1024 * 1024 &&
                                      file.extension == 'pdf') {
                                    setState(() {
                                      _selectedFile =
                                          File(result.files.single.path!);
                                      //_pdfPage = 0;
                                      editmode = true;
                                      hasFile = true;
                                      firsttime = true;
                                    });
                                  } else {
                                    _selectedFile = null;
                                    showLimitExceededSnackbar(context);
                                  }
                                } else {
                                  print('No file selected.');
                                }
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 60,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.done_rounded),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    const Text('Sim'),
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
                                Navigator.of(context).pop();
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
                                    const Text('Não'),
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
                /* Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            //const SizedBox(height: 5),
                            Text("Permites a partilha do teu CV?"),
                            const SizedBox(height: 20),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: StatefulBuilder(
                                        builder: (context, inState) {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.only(
                                              left: 20, right: 20),
                                          textStyle: TextStyle(fontSize: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                15), // Set rounded borders
                                          ),
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () async {
                                          FilePickerResult? result =
                                              await FilePicker.platform
                                                  .pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: ['pdf'],
                                          );

                                          if (result != null) {
                                            PlatformFile file =
                                                result.files.single;
                                            if (file.size <= 8 * 1024 * 1024 &&
                                                file.extension == 'pdf') {
                                              setState(() {
                                                _selectedFile = File(
                                                    result.files.single.path!);
                                                //_pdfPage = 0;
                                                editmode = true;
                                                hasFile = true;
                                                firsttime = true;
                                              });
                                            } else {
                                              _selectedFile = null;
                                              showLimitExceededSnackbar(
                                                  context);
                                            }
                                          } else {
                                            print('No file selected.');
                                          }
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          width: 60,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.done_rounded),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              const Text('Sim'),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: StatefulBuilder(
                                        builder: (context, inState) {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.only(
                                              left: 20, right: 20),
                                          textStyle: TextStyle(fontSize: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                15), // Set rounded borders
                                          ),
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          width: 60,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.close_rounded),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              const Text('Não'),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),*/
              ],
            ),
          );
        });
  }

  Future<void> removefile() async {
    Reference urlReference = FirebaseStorage.instance.refFromURL(cv.text);

    await urlReference.delete();
    print('File deleted successfully');

    await ref.child('cv').remove();
    setState(() {
      change = false;
      editmode = false;
      firsttime = false;
      hasFile = false;
    });
    initState();
  }

  Future<void> _uploadFile() async {
    if (!firsttime) {
      Reference urlReference = FirebaseStorage.instance.refFromURL(cv.text);

      await urlReference.delete();
      print('File deleted successfully');
    }

    try {
      if (_selectedFile != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
            '_' +
            _selectedFile!.path.split('/').last;
        Reference storageReference =
            _storage.ref().child('curriculos').child(fileName);

        await storageReference.putFile(_selectedFile!);

        String downloadURL = await storageReference.getDownloadURL();

        await ref.update({'cv': downloadURL});

        setState(() {
          cv.text = downloadURL;

          editmode = false;
        });

        resetPDFView();

        print('PDF uploaded and URL saved: $downloadURL');
      } else {
        print('No file selected.');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
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
              'Only PDF and size limit of 8MB.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F8),
      body: Stack(
        children: [
          /*Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Colors.orange,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -10),
                    blurRadius: 30,
                  )
                ],
              ),
              height: MediaQuery.of(context).size.height / 1.8,
              width: MediaQuery.of(context).size.width,
            ),
          ),*/
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
                      "O TEU CURRÍCULO",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ),
                  hasFile
                      ? Center(
                          child: Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 3),
                                    blurRadius: 8,
                                  )
                                ],
                              ),
                              height: MediaQuery.of(context).size.height / 1.8,
                              width: MediaQuery.of(context).size.width / 1.15,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: editmode && _selectedFile != null
                                      ? PDFView(
                                          filePath: _selectedFile!.path,
                                          pageSnap: false,
                                        )
                                      : change
                                          ? PDFView(
                                              filePath: _selectedFile!.path,
                                              pageSnap: false,
                                            )
                                          : SfPdfViewer.network(cv.text))),
                        )
                      : Container(),
                  editmode
                      ? Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(0),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 25, right: 25, left: 25),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        editmode = false;
                                        _uploadFile();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 30,
                                              offset: Offset(0, 10))
                                        ],
                                        color: const Color.fromARGB(
                                            255, 66, 66, 66),
                                        border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 66, 66, 66)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.mode_edit_outlined,
                                              size: 30.0,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Aceitar",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(0),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 25, right: 25, bottom: 20),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        editmode = false;
                                        if (firsttime == true) hasFile = false;
                                        if (change) {
                                          change = false;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 30,
                                              offset: Offset(0, 10))
                                        ],
                                        color: const Color.fromARGB(
                                            255, 66, 66, 66),
                                        border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 66, 66, 66)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.mode_edit_outlined,
                                              size: 30.0,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "Rejeitar",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      : hasFile
                          ? Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25, right: 25, top: 25),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () async {
                                          FilePickerResult? result =
                                              await FilePicker.platform
                                                  .pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: ['pdf'],
                                          );

                                          if (result != null) {
                                            PlatformFile file =
                                                result.files.single;
                                            if (file.size <= 8 * 1024 * 1024 &&
                                                file.extension == 'pdf') {
                                              setState(() {
                                                _selectedFile = File(
                                                    result.files.single.path!);
                                                //_pdfPage = 0;
                                                firsttime = false;
                                                editmode = true;
                                                change = true;
                                              });
                                            } else {
                                              showLimitExceededSnackbar(
                                                  context);
                                            }
                                          } else {
                                            _selectedFile = null;
                                            print('No file selected.');
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  blurRadius: 30,
                                                  offset: Offset(0, 10))
                                            ],
                                            color: const Color.fromARGB(
                                                255, 66, 66, 66),
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 66, 66, 66)),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.mode_edit_outlined,
                                                  size: 30.0,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "Alterar currículo",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25,
                                        right: 25,
                                        top: 10,
                                        bottom: 25),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            removefile();
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  blurRadius: 30,
                                                  offset: Offset(0, 10))
                                            ],
                                            color: const Color.fromARGB(
                                                255, 66, 66, 66),
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 66, 66, 66)),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.mode_edit_outlined,
                                                  size: 30.0,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "Remover currículo",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                    height:
                                        MediaQuery.of(context).size.width / 1.2,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            scale: 1,
                                            image: AssetImage(
                                                "assets/images/logo_w_grey.png"))),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20),
                                  child: Text(
                                    "Ainda não tens currículo",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(25),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () async {
                                          checkUPLOAD();

                                          /*if (ACCEPTED) {
                                            FilePickerResult? result =
                                                await FilePicker.platform
                                                    .pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: ['pdf'],
                                            );

                                            if (result != null) {
                                              PlatformFile file =
                                                  result.files.single;
                                              if (file.size <=
                                                      8 * 1024 * 1024 &&
                                                  file.extension == 'pdf') {
                                                setState(() {
                                                  _selectedFile = File(result
                                                      .files.single.path!);
                                                  //_pdfPage = 0;
                                                  editmode = true;
                                                  hasFile = true;
                                                  firsttime = true;
                                                });
                                              } else {
                                                _selectedFile = null;
                                                showLimitExceededSnackbar(
                                                    context);
                                              }
                                            } else {
                                              print('No file selected.');
                                            }
                                          }*/
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey,
                                                  blurRadius: 30,
                                                  offset: Offset(0, 10))
                                            ],
                                            color: const Color.fromARGB(
                                                255, 66, 66, 66),
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 66, 66, 66)),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.mode_edit_outlined,
                                                  size: 30.0,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "Adicionar currículo",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                ],
              ),
            ),
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
                  child: Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
