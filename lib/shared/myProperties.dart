import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homey_app/models/post.dart';
import 'package:homey_app/screens/post_details.dart';
import 'package:homey_app/shared/colors.dart';

class MyProperties extends StatefulWidget {
  const MyProperties({super.key});

  @override
  State<MyProperties> createState() => _MyPropertiesState();
}

class _MyPropertiesState extends State<MyProperties> {
  List<PostData> userPosts = [];
  bool isLoading = true;

  Future<List<PostData>> getUserPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('postss')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
          .get();

      userPosts =
          snapshot.docs.map((doc) => PostData.convertSnap2Model(doc)).toList();
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      isLoading = false;
    });
    return userPosts;
  }

  @override
  void initState() {
    getUserPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
         isLoading
            ? const Center(
                child: SpinKitFadingCircle(
                  color: primaryColor,
                  size: 35,
                ),
              )
            :
        Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 5,
        backgroundColor: backgroundColor,
        title: Text(
          "My Properties",
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
      body: userPosts.isEmpty
          ? const Center(
              child: Text("You don't have posts yet."),
            )
          : 
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 25,),
                Container(
                    color: backgroundColor,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: userPosts.length,
                      itemBuilder: (context, index) {
                        final post = userPosts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetails(
                                  property: post,
                                  hostUid: post.uid,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  spreadRadius: 5,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                AspectRatio(
                                  aspectRatio: 18.0 / 8.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      post.imgUrls[0],
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(16.0, 18.0, 12.0, 0.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${post.location}, ${post.propertyType}'),
                                      SizedBox(height: 2.0),
                                      Row(
                                        children: [
                                          Text('${post.averageRating}'),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Icon(
                                            CupertinoIcons.star_fill,
                                            size: 15,
                                          ),
                                        ],
                                      ),
                                      Text('${post.price}dt ${post.monthNight}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }
}
