import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homey_app/models/post.dart';
import 'package:homey_app/provider/favorite_provider.dart';
import 'package:homey_app/screens/post_details.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:provider/provider.dart';

class FavoriteWidget extends StatelessWidget {
  const FavoriteWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);
    final favorites = provider.favorites;
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: backgroundColor,
          title: Text(
            'Wishlists',
            style: TextStyle(color: textColor, fontSize: 20,fontFamily: 'myfont'),
          ),
          centerTitle: true,
          leading: Icon(
            CupertinoIcons.square_favorites_alt,
            color: Colors.black,
            size: 35,
          ),
        ),
        body: favorites.isEmpty
            ? Center(
                child: Text("No favourite post found"),
              )
            : SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final favorite = favorites[index];
                      return Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          margin: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  favorite.imageUrl,
                                ),
                                radius: 35,
                              ),
                              title: Text(
                                  '${favorite.title}, ${favorite.propertyType}'),
                              subtitle: Row(
                                children: [
                                  Row(
                                    children: [
                                      Text('${favorite.averageRating.toStringAsFixed(2)} '),
                                      Icon(
                                        CupertinoIcons.star_fill,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  Text(
                                      ' , ${favorite.price} ${favorite.monthNight}'),
                                ],
                              ),
                              trailing: IconButton(
                                  onPressed: () {
                                    provider.toggleFavorite(favorite);
                                  },
                                  icon: provider.isExist(favorite)
                                      ? Icon(
                                          Icons.favorite,
                                          color: red,
                                        )
                                      : Icon(
                                          Icons.favorite_border,
                                          color: primaryColor,
                                        )),
                              onTap: () async {
                                // Fetch the PostData for the favorite from Firestore
                                DocumentSnapshot docSnap =
                                    await FirebaseFirestore.instance
                                        .collection('postss')
                                        .doc(favorite.postId)
                                        .get();

                                // Convert the DocumentSnapshot to PostData
                                PostData postData =
                                    PostData.convertSnap2Model(docSnap);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetails(
                                      property: postData,
                                      hostUid: favorite.uid,
                                    ),
                                  ),
                                );
                              }));
                    },
                  ),
                ),
              ));
  }
}
