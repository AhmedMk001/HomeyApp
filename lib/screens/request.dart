import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homey_app/models/post.dart';
import 'package:homey_app/responsive/mobilescreen.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class Request extends StatefulWidget {
  final PostData post;
  const Request({super.key, required this.post});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  Map userData = {};
  bool isLoading = true;

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

  sendMessage({required String title, required String message}) async {
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAACFtIais:APA91bGDMPL2IldEvu2qVLIfDCbz-DN2CeT_pdCqh5WixVRm3jNK_xlJFu0N1lrRsysq3n1EA_Yk5mUUQZiaNsfV0z2mzTvXq3U4KZLHVVVwuwUXgLBvBQYJj__1jVuB8rr4ATwvlCZh'
    };
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    var body = {
      "to": widget.post.token,
      "notification": {
        "title": title,
        "body": message,
        // "mutable_content": true,
        // "sound": "Tri-tone"
      }
    };

    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print(resBody);
    } else {
      print(res.reasonPhrase);
    }
    print(message);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Text(
            'Requests for reservation',
            style: TextStyle(color: textColor),
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
          )),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('userss')
                    .doc(userData['uid'])
                    .collection('reservations')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: textColor,
                    ));
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      if (snapshot.hasData &&
                          data['reservPostId'] == widget.post.postID) {
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
                          margin: EdgeInsets.all(2),
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.5),
                                          spreadRadius: 4,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image(
                                            image: NetworkImage(
                                                widget.post.imgUrls[0]),
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "${data['reservName']} want to reserve the ${widget.post.propertyType} in ${widget.post.location} for ${data["reservDays"]} days between ${data["startDate"]} and ${data['endDate']} (for ${data["reservGuests"]} Guests).",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                widget.post.availability == "Open"
                                    ? Text(
                                        "The price is ${widget.post.price} dt per month",
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        "The total price will be ${data['reservPrice'].toString()} dt",
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Text(
                                  "Requested in ${DateFormat('yMMMd').format(data['reservDate'].toDate())}",
                                  style: const TextStyle(
                                      color: textColor2, fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Text(
                                  "For more details: ${data["reservNumber"]}",
                                  style: const TextStyle(
                                      color: textColor, fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Text(
                                  "When your receive your money you can go and edit your property as a reserved one.",
                                  style: const TextStyle(
                                      color: textColor, fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        String newNotifId = const Uuid().v1();
                                        await sendMessage(
                                            title: 'Reservation accepted',
                                            message:
                                                "Your reservation for the ${widget.post.propertyType} in ${widget.post.location} has been accepted from the Host. You can go check your ${widget.post.propertyType}");

                                        await FirebaseFirestore.instance
                                            .collection('userss')
                                            .doc(data["reservSender"])
                                            .collection('notifications')
                                            .doc(newNotifId)
                                            .set({
                                          'notifId': newNotifId,
                                          'notifSender': userData["username"],
                                          'notifTitle': "Reservation accepted",
                                          'notifBody':
                                              "Your reservation for the ${widget.post.propertyType} in ${widget.post.location} has been accepted from the Host. You can go check your ${widget.post.propertyType}",
                                          'notifDate': DateTime.now(),
                                        });
                                        await document.reference.delete();

                                        String contractId = const Uuid().v1();
                                        await FirebaseFirestore.instance
                                            .collection('Contracts')
                                            .doc(contractId)
                                            .set({
                                              'ContractId': contractId,
                                              'ContractPostId': widget.post.postID,
                                              'ContractPostImage': widget.post.imgUrls[0],
                                              'ContractSender': userData["username"],
                                              'ContractSenderId': userData["uid"],
                                              'ContractReceiver': data["reservName"],
                                              'ContractGuests': data['reservGuests'],
                                              'ContractDays': data['reservDays'],
                                              'ContractReceiverId': data["reservSender"],
                                              'ContractPost': "${widget.post.propertyType} in ${widget.post.location} for ${widget.post.category}",
                                              'ContractStartDate': data["startDate"],
                                              'ContractEndDate': data["endDate"],
                                              'ContractPrice': "${widget.post.price} per ${widget.post.monthNight}",
                                              'ContractStatus': 'Accepted',
                                              'ContractDate': DateTime.now(),
                                            });

                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.success,
                                          title: 'Done',
                                          text: 'Reservation accepted',
                                          onConfirmBtnTap: () async {
                                            setState(() {
                                              FirebaseFirestore.instance
                                                  .collection('postss')
                                                  .doc(widget.post.postID)
                                                  .update({
                                                'open':
                                                    'In progress of reservation...',
                                              });
                                            });
                                            if (!mounted) return;
                                            Navigator.of(context).pushReplacement(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const MobileScreen()));
                                          },
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                Color.fromARGB(
                                                    255, 39, 197, 44)),
                                        padding: WidgetStateProperty.all(
                                            EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 20)),
                                        shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                      ),
                                      child: Text(
                                        "Accept",
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        String newNotifId = const Uuid().v1();

                                        await sendMessage(
                                            title: 'Reservation declined',
                                            message:
                                                "Your reservation has been declined.");

                                        await FirebaseFirestore.instance
                                            .collection('userss')
                                            .doc(data["reservSender"])
                                            .collection('notifications')
                                            .doc(newNotifId)
                                            .set({
                                          'notifId': newNotifId,
                                          'notifSender': userData["username"],
                                          'notifTitle': "Reservation declined",
                                          'notifBody':
                                              "Your reservation has been declined.",
                                          'notifDate': DateTime.now(),
                                        });
                                        await document.reference.delete();
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.success,
                                          title: 'Done',
                                          text: 'Reservation declined',
                                          onConfirmBtnTap: () async {
                                            await Navigator.of(context)
                                                .pushReplacement(MaterialPageRoute(
                                                    builder: (context) =>
                                                        const MobileScreen()));
                                          },
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(red),
                                        padding: WidgetStateProperty.all(
                                            EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 20)),
                                        shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                      ),
                                      child: Text(
                                        "Decline",
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
