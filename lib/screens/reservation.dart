import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:homey_app/models/post.dart';
import 'package:homey_app/responsive/mobilescreen.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:homey_app/shared/constant.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:uuid/uuid.dart';

class Reservation extends StatefulWidget {
  final PostData post;

  const Reservation({Key? key, required this.post});

  @override
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  final _formKey = GlobalKey<FormState>();

  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final _guestController = TextEditingController();

  final _dateFormat = DateFormat('d-MMM');
  final dateFormat = DateFormat('yyyy-MM-dd'); // Format: Year-Month-Day

  DateTime? _startDate;
  DateTime? _endDate;
  String _guests = '1';

  double _finalPrice = 0.0;
  int _numDays = 0;

  Map userData = {};
  bool isLoading = true;

  void _calculateFinalPrice() {
    if (_startDate != null && _endDate != null) {
      final start = DateTime.parse(dateFormat.format(_startDate!));
      final end = DateTime.parse(dateFormat.format(_endDate!));
      final days = end.difference(start).inDays;
      final price = double.parse(widget.post.price);
      setState(() {
        _finalPrice = price * days;
        _numDays = days;
      });
    }
  }

  Future<void> getUserData() async {
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
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Text(
            'Request to reserve',
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
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
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image(
                                image: NetworkImage(widget.post.imgUrls[0]),
                                height: 80,
                              )),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'An entire ${widget.post.propertyType} in ${widget.post.location}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  '${widget.post.availability}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                    "For ${widget.post.price} per ${widget.post.monthNight}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
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
                          horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Reserve details",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                         Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Start date',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              final DateTime? picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime(
                                                    DateTime.now().year + 3),
                                              );
                                              if (picked != null) {
                                                setState(() {
                                                  _startDate = picked;
                                                  _startDateController.text =
                                                      '${_dateFormat.format(_startDate!)}';
                                                  _calculateFinalPrice();
                                                });
                                              }
                                            },
                                            child: IgnorePointer(
                                              child: Text(
                                                _startDate == null
                                                    ? 'Select a date'
                                                    : _dateFormat
                                                        .format(_startDate!),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  decoration: _startDate == null
                                                      ? TextDecoration.none
                                                      : TextDecoration
                                                          .underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'End date',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              final DateTime? picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: _startDate ??
                                                    DateTime.now(),
                                                firstDate: _startDate ??
                                                    DateTime.now(),
                                                lastDate: DateTime(
                                                    DateTime.now().year + 1),
                                              );
                                              if (picked != null) {
                                                setState(() {
                                                  _endDate = picked;
                                                  _endDateController.text =
                                                      '${_dateFormat.format(_endDate!)}';
                                                  _calculateFinalPrice();
                                                });
                                              }
                                            },
                                            child: IgnorePointer(
                                              child: Text(
                                                _endDate == null
                                                    ? 'Select a date'
                                                    : _dateFormat
                                                        .format(_endDate!),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  decoration: _endDate == null
                                                      ? TextDecoration.none
                                                      : TextDecoration
                                                          .underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                'Guests:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              DropdownButton<String>(
                                value: _guests,
                                onChanged: (value) {
                                  setState(() {
                                    _guests = value!;
                                    _guestController.text = value;
                                  });
                                },
                                items: List.generate(
                                  6,
                                  (index) => DropdownMenuItem<String>(
                                    value: '${index + 1}',
                                    child: Text('${index + 1}'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
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
                        children: [
                          Row(
                            children: [
                              Text(
                                "Price details",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          widget.post.availability == "Open"
                              ? Text("${widget.post.price} dt per Month")
                              : Row(
                                  children: [
                                    Text(
                                      "${widget.post.price} dt × ",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text('(${_numDays}) nights',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          widget.post.availability == "Open"
                              ? SizedBox(
                                  height: 10,
                                )
                              : Row(
                                  children: [
                                    Text('Total: ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text('${_finalPrice} dt',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text(' for (${_numDays} days)',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
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
                        children: [
                          Row(
                            children: [
                              Text(
                                "Pay with",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Text(
                                "Payment method",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                "Hand to Hand",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "you give the total price to the host when you meet with him the first you come to this property (that you want to reserve).",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Other methods will be there soon...",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
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
                        children: [
                          Row(
                            children: [
                              Text(
                                "Required informations",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                validator: (value) {
                                  return value!.isEmpty
                                      ? "Can not be empty"
                                      : null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: nameController,
                                keyboardType: TextInputType.text,
                                decoration: decorationTextfield.copyWith(
                                    labelText: "Full name"),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              IntlPhoneField(
                                controller: phoneController,
                                decoration: decorationTextfield.copyWith(
                                  labelText: 'Phone Number',
                                  labelStyle:
                                      const TextStyle(color: Colors.black87),
                                ),
                                initialCountryCode: 'TN',
                                onChanged: (phone) {
                                  print(phone.completeNumber);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
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
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/time-twenty-four-svgrepo-com.svg",
                            height: 30,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Text(
                              "Your reservation won't be confirmed until the host accepts your request (within 24 hours). You will be notified.",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
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
                      child: Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "By selecting the button below. I agree to the Host's House Rules. I agree to pay the total ammount show if the Host accepts my reservation request.",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  String newNotifId = const Uuid().v1();
                                  String newReservId = const Uuid().v1();

                                 await sendMessage(
                                          title: 'Reservation request',
                                          message:
                                              "You have new reservation from ${nameController.text} for the ${widget.post.propertyType} in ${widget.post.location}, with these details: * ${_numDays} days * ${_guestController.text} guests * ${_finalPrice} dt, and for more information here is the Phone Number: ${phoneController.text}.");
                                   await FirebaseFirestore.instance
                                          .collection('userss')
                                          .doc(widget.post.uid)
                                          .collection('notifications')
                                          .doc(newNotifId)
                                          .set({
                                          'notifId': newNotifId,
                                          'notifSender': userData["username"],
                                          'notifTitle': "Reservation request",
                                          'notifBody':
                                              "You have new reservation from ${nameController.text} for the ${widget.post.propertyType} in ${widget.post.location}, with these details: * ${_numDays} days * ${_guestController.text} guests * ${_finalPrice} dt, and for more information here is the Phone Number: ${phoneController.text}.",
                                          'notifDate': DateTime.now(),
                                          'token': widget.post.token,
                                        });
                                 await FirebaseFirestore.instance
                                          .collection('userss')
                                          .doc(widget.post.uid)
                                          .collection('reservations')
                                          .doc(newReservId)
                                          .set({
                                          'reservId': newReservId,
                                          'reservSender': userData["uid"],
                                          'reservPostId': widget.post.postID,
                                          'reservName': nameController.text,
                                          'reservNumber': phoneController.text,
                                          'startDate':_startDateController.text ,
                                          'endDate':_endDateController.text,
                                          'reservDays': _numDays,
                                          'reservGuests': _guestController.text,
                                          'reservPrice': _finalPrice,
                                          'reservDate': DateTime.now(),
                                        });

                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.success,
                                    title: 'Done',
                                    text: 'Reservation sent',
                                    onConfirmBtnTap: () async {
                                      await Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                              builder: (context) =>
                                                  const MobileScreen()));
                                    },
                                  );
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(primaryColor),
                                padding: WidgetStateProperty.all(
                                    EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 80)),
                                shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                              ),
                              child: Text(
                                "Request to reseve",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
