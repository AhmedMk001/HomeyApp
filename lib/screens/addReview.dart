import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:homey_app/responsive/mobilescreen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AddReview extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  const AddReview({super.key, required this.postId, required this.postOwnerId});

  @override
  State<AddReview> createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  TextEditingController reviewController = TextEditingController();

  Map userData = {};
  bool isLoading = true;
  double _rating = 0;

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

  sendReviews(double newRating) async {
    
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String postId = widget.postId;

     // Fetch the post document
  DocumentReference postRef = FirebaseFirestore.instance.collection('postss').doc(postId);
  DocumentSnapshot postSnapshot = await postRef.get();
  Map<String, dynamic> postData = postSnapshot.data()! as Map<String, dynamic>;

   // Calculate the new average rating
  double oldRating = postData['averageRating'] ?? 0.0;
  double ratingCount = postData['ratingCount'] ?? 0;
  double totalRating = oldRating * ratingCount;
  double newAverageRating = (totalRating + newRating) / (ratingCount + 1);

   // Update the post document with the new average rating and increment the rating count
  postRef.update({
    'averageRating': newAverageRating,
    'ratingCount': FieldValue.increment(1),
  });
       // Add the new review
    await FirebaseFirestore.instance
        .collection("postss")
        .doc(postId)
        .collection("reviews")
        .doc(userId)
        .set({
      'userId': userId,
      'reviewIdSender': userData['username'],
      'reviewIdBody': reviewController.text,
      'rating': newRating,
      'reviewIdDate': DateTime.now(),
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Align(
                      alignment: Alignment.topLeft,
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                  const Gap(20),
                  const Text(
                    "Review This Post",
                    style: TextStyle(fontSize: 22, fontFamily: 'myfont'),
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    "assets/icons/review.svg",
                    height: 28,
                  )
                ],
              ),
              const Gap(30),
              const Text(
                "Review",
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),
              const Gap(10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.indigo,
                      width: 0.9, // Border width
                    ),
                    borderRadius: BorderRadius.circular(15), // Border radius
                  ),
                  height: 300,
                  child: TextField(
                    maxLines: null, // Allows text to wrap to the next line
                    controller: reviewController,
                    decoration: const InputDecoration(
                      hintText: "You can add your review here...",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Center(
                  child: RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(12)),
                    child: ElevatedButton(
                      onPressed: () async {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.confirm,
                          title: 'Sure!',
                          text: 'Want To cancel this Review?',
                          cancelBtnText: 'Cancel',
                          confirmBtnColor: Colors.green,
                          confirmBtnText: 'Okay',
                          onConfirmBtnTap: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MobileScreen()),
                                (route) => false);
                          },
                          onCancelBtnTap: () {
                            Navigator.of(context).pop();
                          },
                        );
                      },
                      style: ButtonStyle(
                          elevation: WidgetStateProperty.all(0),
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.indigo),
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)))),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_rating > 0) {
                          await sendReviews(_rating);
                          // ignore: use_build_context_synchronously
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.success,
                            text: 'Review Added Successfully!',
                            onConfirmBtnTap: () {
                              Navigator.of(context).pop();
                            },
                          );

                          print("Succesfuly Bruda");
                          reviewController.clear();
                        } else {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.warning,
                            text: 'Please provide a rating',
                          );
                        }
                      },
                      style: ButtonStyle(
                          elevation: WidgetStateProperty.all(0),
                          foregroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.indigo),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)))),
                      child: const Text(
                        '  Post  ',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
