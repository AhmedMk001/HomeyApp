import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homey_app/provider/post_provider.dart';
import 'package:homey_app/screens/search.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:homey_app/shared/postMap.dart';
import 'package:homey_app/shared/post_design.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map userData = {};

  late String userAdministrativeArea;
  bool isLoading = false;
  String sortBy = 'popular';
  TextEditingController searchController = TextEditingController();

  getData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('userss')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (mounted) {
        setState(() {
          userData = snapshot.data()!;
          isLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PostProvider(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: Stack(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Filter posts as you like ->",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'myfont',
                              letterSpacing: 2),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.03,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.12,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(top: 10),
                        child: IconButton(
                          icon: Icon(CupertinoIcons.slider_horizontal_3),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()));
                          },
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.flame),
                                Text(
                                  'Trending',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: textColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                sortBy = 'popular';
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.near_me_outlined),
                                Text(
                                  'Nearby',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: textColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                sortBy = 'location';
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.sparkles),
                                Text(
                                  'New',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: textColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                sortBy = 'latest';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: sortBy == 'popular'
                          ? FirebaseFirestore.instance
                              .collection('postss')
                              .where('status', isEqualTo: 'approved')
                              .orderBy('averageRating', descending: true)
                              .snapshots()
                          : sortBy == 'location'
                              ? FirebaseFirestore.instance
                                  .collection('postss')
                                  .where('status', isEqualTo: 'approved')
                                  .where("administrativeArea",
                                      isEqualTo:
                                          userData["userAdministrativeArea"])
                                  .orderBy('averageRating', descending: true)
                                  .snapshots()
                              : FirebaseFirestore.instance
                                  .collection('postss')
                                  .where('status', isEqualTo: 'approved')
                                  .orderBy('datePublished', descending: true)
                                  .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Something went wrong'));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: SpinKitFadingCircle(
                            color: primaryColor,
                            size: 35,
                          ));
                        }
                        if (snapshot.data == null ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text('No posts found'),
                          );
                        }
                        return ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;

                            return Consumer<PostProvider>(
                              builder: (context, postProvider, child) {
                                return PostDesign(
                                  data: data,
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  // SizedBox(height: 60,)
                ],
              ),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.35,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  width: 110,
                  child: FloatingActionButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: textColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Map"),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(CupertinoIcons.map_fill)
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostsMapScreen(),
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
