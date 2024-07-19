// userPosts.isEmpty
//                         ? const Center(
//                             child: Text("You don't have posts"),
//                           )
//                         : Container(
//                             color: backgroundColor,
//                             height: MediaQuery.of(context).size.height * 0.25,
//                             width: MediaQuery.of(context).size.width,
//                             child: GridView.builder(
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                               ),
//                               itemCount: userPosts.length,
//                               itemBuilder: (context, index) {
//                                 final post = userPosts[index];
//                                 return GestureDetector(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => PostDetails(
//                                           property: post,
//                                           hostUid: post.uid,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: cardColor,
//                                       borderRadius: BorderRadius.circular(15),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.4),
//                                           spreadRadius: 5,
//                                           blurRadius: 5,
//                                           offset: Offset(0, 3),
//                                         ),
//                                       ],
//                                     ),
//                                     margin: EdgeInsets.all(12),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: <Widget>[
//                                         AspectRatio(
//                                           aspectRatio: 18.0 / 8.0,
//                                           child: ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(15),
//                                             child: Image.network(
//                                               post.imgUrls[0],
//                                               fit: BoxFit.fitWidth,
//                                             ),
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: EdgeInsets.fromLTRB(
//                                               16.0, 18.0, 12.0, 0.0),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                   '${post.location}, ${post.propertyType}'),
//                                               SizedBox(height: 2.0),
//                                               Row(
//                                                 children: [
//                                                   Text('${post.averageRating}'),
//                                                   SizedBox(
//                                                     width: 3,
//                                                   ),
//                                                   Icon(
//                                                     CupertinoIcons.star_fill,
//                                                     size: 15,
//                                                   ),
//                                                 ],
//                                               ),
//                                               Text(
//                                                   '${post.price}dt ${post.monthNight}'),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),




  // Future<List<PostData>> getUserPosts() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
  //         .instance
  //         .collection('postss')
  //         .where('uid', isEqualTo: widget.uiddd)
  //         .get();

  //     userPosts =
  //         snapshot.docs.map((doc) => PostData.convertSnap2Model(doc)).toList();
  //   } catch (e) {
  //     print(e.toString());
  //   }

  //   setState(() {
  //     isLoading = false;
  //   });
  //   return userPosts;
  // }