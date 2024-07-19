import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class DigitalContract extends StatefulWidget {
  const DigitalContract({super.key});

  @override
  State<DigitalContract> createState() => _DigitalContractState();
}

class _DigitalContractState extends State<DigitalContract> {
  Map userData = {};
  bool isLoading = true;
  List<GlobalKey> _repaintBoundaryKeys = [];

  @override
  void initState() {
    super.initState();
    _repaintBoundaryKeys = List.generate(100, (index) => GlobalKey());
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('userss')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      userData = snapshot.data()!;
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 5,
        backgroundColor: backgroundColor,
        title: Text(
          "Digital Contracts",
          style: TextStyle(
            color: textColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            CupertinoIcons.arrow_left,
            color: textColor,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: primaryColor,
                size: 35,
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Contracts')
                  .where('ContractReceiverId', isEqualTo: userData['uid'])
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SpinKitFadingCircle(
                    color: primaryColor,
                    size: 35,
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No contracts found'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot contract = snapshot.data!.docs[index];

                    String? contractPostImage = contract['ContractPostImage'];
                    String? contractPost = contract['ContractPost'];
                    String? contractPrice = contract['ContractPrice'];

                    if (contractPostImage == null || contractPost == null || contractPrice == null) {
                      return Text('Invalid contract data'); // Show message if contract data is invalid
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 4,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      child: RepaintBoundary(
                        key: _repaintBoundaryKeys[index],
                        child: Column(
                          children: [
                            Text("Digital Contract", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("N°: ${contract["ContractId"].substring(0, 5)}"),
                            SizedBox(height: 10),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(contractPostImage),
                              ),
                            ),
                            Text(contract['ContractPost'], style: TextStyle(fontSize: 16)),
                            Text(contract['ContractPrice'], style: TextStyle(fontSize: 16)),
                            SizedBox(height: 40),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("The owner is: ${contract['ContractSender']}", style: TextStyle(fontSize: 16)),
                                SizedBox(height: 10),
                                Text("The tenant is: ${contract['ContractReceiver']}", style: TextStyle(fontSize: 16)),
                                SizedBox(height: 10),
                                Text("This property is rented for ${contract['ContractDays']} days", style: TextStyle(fontSize: 16)),
                                SizedBox(height: 10),
                                Text("From ${contract['ContractStartDate']} to ${contract['ContractEndDate']} for ${contract['ContractGuests']} guests.", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            SizedBox(height: 40),
                            Icon(CupertinoIcons.signature, size: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    try {
                                      final boundary = _repaintBoundaryKeys[index].currentContext!.findRenderObject() as RenderRepaintBoundary;
                                      final image = await boundary.toImage();
                                      final document = await _createPdf(image);
                                      await _saveAndLaunchFile(document, 'contract.pdf');
                                      print("Downloaded successfully!");
                                    } catch (e) {
                                      print('Error: $e');
                                    }
                                  },
                                  icon: Icon(CupertinoIcons.cloud_download, color: blueColor,),
                                ),
                                IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Delete this Contract?',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            SizedBox(height: 20),
                                            ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStateProperty.all(
                                                        primaryColor),
                                              ),
                                              onPressed: () async {
                                                try {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Contracts')
                                                      .doc(contract.id)
                                                      .delete();
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                } catch (e) {
                                                  print(e.toString());
                                                }
                                              },
                                              child: Text('Yes'),
                                            ),
                                            SizedBox(height: 10),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                    color: primaryColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            icon: Icon(
                              CupertinoIcons.delete,
                              size: 25,
                              color: red,
                            ),
                          ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }


  Future<pw.Document> _createPdf(ui.Image image) async {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final document = pw.Document();
    final imageProvider = pw.MemoryImage(bytes!.buffer.asUint8List());
    document.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(imageProvider),
        );
      },
    ));
    return document;
  }

  Future<void> _saveAndLaunchFile(pw.Document document, String fileName) async {
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/Download';
    final dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync();
    }
    final file = File('$path/$fileName');
    final pdfBytes = await document.save();
    await file.writeAsBytes(pdfBytes);
    await OpenFile.open(file.path);
  }
}
