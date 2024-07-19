import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:homey_app/shared/post_design.dart';

class PendingPosts extends StatefulWidget {
  const PendingPosts({super.key});

  @override
  State<PendingPosts> createState() => _PendingPostsState();
}

class _PendingPostsState extends State<PendingPosts> {
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: backgroundColor,
          titleSpacing: 20,
          centerTitle: true,
          title: Text(
            "Pending Posts",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontFamily: "myfont",
                color: textColor),
          ),
        ),
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:  FirebaseFirestore.instance
                              .collection('postss')
                              .where('status', isEqualTo: 'pending')            
                              .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      );
                    }
                    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child:const Text('No posts found'),
                      );
                    }

                    return ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                            return PostDesign(
                              data: data,
                            );
                          
                      }).toList(),
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