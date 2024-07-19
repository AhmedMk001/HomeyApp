import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homey_app/models/post.dart';
import 'package:homey_app/screens/login.dart';
import 'package:homey_app/screens/personal_info.dart';
import 'package:homey_app/screens/register.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:homey_app/shared/contracts.dart';
import 'package:homey_app/shared/myProperties.dart';

class Profile extends StatefulWidget {
  final String uiddd;
  const Profile({Key? key, required this.uiddd}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> userData = {};
  List<PostData> userPosts = [];

  bool isLoading = true;
  CollectionReference users = FirebaseFirestore.instance.collection('userss');
  final User? credential = FirebaseAuth.instance.currentUser;

  Future<void> getUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('userss')
          .doc(widget.uiddd)
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
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: SpinKitFadingCircle(
              color: primaryColor,
              size: 35,
            ),
          )
        : SafeArea(
            child: Scaffold(
              backgroundColor: backgroundColor,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 160,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black87.withOpacity(0.2),
                            blurRadius: 0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.asset(
                                  "assets/img/user.png",
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userData["username"],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 4, 0, 0),
                                          child: Text(
                                            userData["email"],
                                            style: TextStyle(
                                                color: textColor2,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ]),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(167, 207, 205, 205),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 0,
                            color: Color(0xFFE3E5E7),
                            offset: Offset(
                              0.0,
                              2,
                            ),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Account details",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PersonalInfo()));
                      },
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 0,
                              color: Colors.grey,
                              offset: Offset(
                                0.0,
                                2,
                              ),
                            )
                          ],
                          border: Border.all(
                            color: Colors.grey,
                            width: 0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    size: 25,
                                    color: textColor,
                                    CupertinoIcons.gear,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Edit Profile",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Icon(
                                size: 25,
                                color: textColor2,
                                CupertinoIcons.arrow_right_circle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyProperties()));
                      },
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 0,
                              color: Colors.grey,
                              offset: Offset(
                                0.0,
                                2,
                              ),
                            )
                          ],
                          border: Border.all(
                            color: Colors.grey,
                            width: 0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    size: 25,
                                    color: textColor,
                                    CupertinoIcons.house,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "My Properties",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Icon(
                                size: 25,
                                color: textColor2,
                                CupertinoIcons.arrow_right_circle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DigitalContract()));
                      },
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 0,
                              color: Colors.grey,
                              offset: Offset(
                                0.0,
                                2,
                              ),
                            )
                          ],
                          border: Border.all(
                            color: Colors.grey,
                            width: 0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    size: 25,
                                    color: textColor,
                                    CupertinoIcons.doc_on_doc,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Digital Contract",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Icon(
                                size: 25,
                                color: textColor2,
                                CupertinoIcons.arrow_right_circle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(167, 207, 205, 205),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 0,
                            color: Color(0xFFE3E5E7),
                            offset: Offset(
                              0.0,
                              2,
                            ),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Services",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 0,
                            color: Colors.grey,
                            offset: Offset(
                              0.0,
                              2,
                            ),
                          )
                        ],
                        border: Border.all(
                          color: Colors.grey,
                          width: 0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  size: 25,
                                  color: textColor,
                                  CupertinoIcons.doc_text_search,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Get Help",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Icon(
                              size: 25,
                              color: textColor2,
                              CupertinoIcons.arrow_right_circle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 0,
                            color: Colors.grey,
                            offset: Offset(
                              0.0,
                              2,
                            ),
                          )
                        ],
                        border: Border.all(
                          color: Colors.grey,
                          width: 0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  size: 25,
                                  color: textColor,
                                  CupertinoIcons.doc_text,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "About Us",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Icon(
                              size: 25,
                              color: textColor2,
                              CupertinoIcons.arrow_right_circle,
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await users.doc(credential!.uid).delete();
                        await credential!.delete();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Register()),
                        );
                      },
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 0,
                              color: Colors.grey,
                              offset: Offset(
                                0.0,
                                2,
                              ),
                            )
                          ],
                          border: Border.all(
                            color: Colors.grey,
                            width: 0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    size: 25,
                                    color: textColor,
                                    CupertinoIcons.delete,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Delete Account",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              Icon(
                                size: 25,
                                color: textColor2,
                                CupertinoIcons.arrow_right_circle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 24, 0, 20),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (!mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                              (route) => false);
                        },
                        child: Text(
                          "Log Out",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(primaryColor),
                          padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 100)),
                          shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
