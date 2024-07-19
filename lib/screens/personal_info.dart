import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homey_app/shared/colors.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  Map userData = {};
  bool isLoading = true;
  final dialogUsernameController = TextEditingController();
  final credential = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('userss');

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

  myDialog(userData, dynamic mykey) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          child: Container(
            padding: const EdgeInsets.all(22),
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                    controller: dialogUsernameController,
                    maxLength: 20,
                    decoration:
                        InputDecoration(hintText: "${userData[mykey]}")),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () async {
                          await users
                              .doc(credential!.uid)
                              .update({mykey: dialogUsernameController.text});
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        child: const Text(
                          "Update",
                          style: TextStyle(fontSize: 17),
                        )),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontSize: 17),
                        )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: Colors.white,
            body: const Center(
              child: SpinKitFadingCircle(
                color: primaryColor,
                size: 35,
              ),
            ),
          )
        : Scaffold(
          backgroundColor: backgroundColor,
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  CupertinoIcons.arrow_left,
                  color: textColor,
                ),
              ),
              centerTitle: true,
              backgroundColor: backgroundColor,
              title: Text(
                "Edit Profile",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Card(
                    elevation: 5,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(CupertinoIcons.person_alt,
                              color: primaryColor),
                          title: Text(
                            "Full name",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            userData["username"],
                            style:
                                TextStyle(color: Colors.black54, fontSize: 18),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              myDialog(userData, "username");
                            },
                            icon: Icon(Icons.edit, color: primaryColor),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        ListTile(
                          leading: Icon(CupertinoIcons.location_solid,
                              color: primaryColor),
                          title: Text(
                            "Current location",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            userData["location"],
                            style:
                                TextStyle(color: Colors.black54, fontSize: 18),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              myDialog(userData, "location");
                            },
                            icon: Icon(Icons.edit, color: primaryColor),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        ListTile(
                          leading: Icon(CupertinoIcons.envelope_fill,
                              color: primaryColor),
                          title: Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            userData["email"],
                            style:
                                TextStyle(color: Colors.black54, fontSize: 18),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              myDialog(userData, "email");
                            },
                            icon: Icon(Icons.edit, color: primaryColor),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                        ),
                        ListTile(
                          leading: Icon(CupertinoIcons.phone_fill,
                              color: primaryColor),
                          title: Text(
                            "Phone number",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "+216 ${userData["phone"]}",
                            style:
                                TextStyle(color: Colors.black54, fontSize: 18),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              myDialog(userData, "phone");
                            },
                            icon: Icon(Icons.edit, color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
