import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:homey_app/firebase_services/storage.dart';
import 'package:homey_app/models/post.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:homey_app/shared/constant.dart';
import 'package:homey_app/shared/snackar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class EditPost extends StatefulWidget {
  final PostData post;

  EditPost({required this.post});

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final _formKey = GlobalKey<FormState>();

  bool haveRefrigirator = false;
  bool haveWifi = false;
  bool haveWasher = false;
  bool haveSmokeDetector = false;
  bool haveGarage = false;
  bool havePool = false;
  bool haveBalcony = false;
  bool haveGarden = false;
  bool havetv = false;

  final List<File> _image = [];
  final picker = ImagePicker();
  File? imgPath;
  String? imgName;
  bool isLoading = false;

  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();
  final _priceController = TextEditingController();
  final categController = TextEditingController();
  final availabilityController = TextEditingController();
  final bedController = TextEditingController();
  final bathController = TextEditingController();
  final monthNightController = TextEditingController();
  final reservController = TextEditingController();

  String? _selectedCatigory;
  String? _selectedMonthNight;
  String? _selectedReserv;
  DateTime? _startDate;
  DateTime? _endDate;

  final _dateFormat = DateFormat('d-MMM');

  List<String> monthNight = ["Month", "Night"];
  List<String> reservation = ["Reserved", "Available"];

  List<String> catigory = [
    'Boys',
    'Girls',
    'Family',
    'Single',
    'Couple',
    'Students'
  ];

  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image.add(File(pickedFile.path));
        int random = Random().nextInt(9999999);
        imgName = "$random$imgName";
      });
    } else {
      showSnackBar(context, "No Image Selected");
    }
  }

  late PostData post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    _descriptionController.text = widget.post.description;
    _rulesController.text = widget.post.rules;
    _priceController.text = widget.post.price;
    haveRefrigirator = widget.post.refrigirator;
    categController.text = widget.post.category;
    availabilityController.text = widget.post.availability;
    monthNightController.text = widget.post.monthNight;
    bedController.text = widget.post.bedroom;
    bathController.text = widget.post.bathroom;
    haveWifi = widget.post.wifi;
    haveWasher = widget.post.washer;
    haveSmokeDetector = widget.post.smokeDetector;
    haveGarage = widget.post.garage;
    havePool = widget.post.pool;
    haveBalcony = widget.post.balcony;
    haveGarden = widget.post.garden;
    havetv = widget.post.tv;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Edit Post',
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: textColor,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Column(
                    children: [
                      Text(
                        "Category",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                        value: _selectedCatigory,
                        decoration: decorationTextfield.copyWith(
                          labelText: 'Category',
                          hintText: 'Select a category',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedCatigory = value;
                            categController.text = value!;
                          });
                        },
                        items: catigory.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Description",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        maxLines: 3,
                        maxLength: 400,
                        controller: _descriptionController,
                        decoration: decorationTextfield.copyWith(
                            labelText: 'Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      Text(
                        "Rules",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        maxLines: 3,
                        maxLength: 200,
                        controller: _rulesController,
                        decoration:
                            decorationTextfield.copyWith(labelText: 'Rules'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter rules';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: primaryColor,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Column(
                    children: [
                      Text(
                        "Availability",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      // Start Date
                      TextFormField(
                        decoration: decorationTextfield.copyWith(
                          labelText: 'Start Date',
                          hintText: 'Select a start date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year + 5),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                              availabilityController.text =
                                  'From: ${_dateFormat.format(_startDate!)}';
                              if (_endDate != null) {
                                availabilityController.text +=
                                    ' To: ${_dateFormat.format(_endDate!)}';
                              }
                            });
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // End Date
                      TextFormField(
                        decoration: decorationTextfield.copyWith(
                          labelText: 'End Date',
                          hintText: 'Select an end date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime.now(),
                            lastDate: DateTime(
                                (_startDate ?? DateTime.now()).year + 5),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                              availabilityController.text =
                                  'From: ${_dateFormat.format(_startDate!)} To: ${_dateFormat.format(_endDate!)}';
                            });
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // Availability
                      TextFormField(
                        controller: availabilityController,
                        readOnly: true,
                        decoration: decorationTextfield.copyWith(
                          labelText: 'Availability',
                          hintText: 'Select a date range',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Time",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please choose one';
                          }
                          return null;
                        },
                        value: _selectedMonthNight,
                        decoration: decorationTextfield.copyWith(
                          labelText: 'Month/Night',
                          hintText: 'Choose one',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedMonthNight = value;
                            monthNightController.text = value!;
                          });
                        },
                        items: monthNight.map((time) {
                          return DropdownMenuItem<String>(
                            value: time,
                            child: Text(time),
                          );
                        }).toList(),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Status of reservation",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please choose one';
                          }
                          return null;
                        },
                        value: _selectedReserv,
                        decoration: decorationTextfield.copyWith(
                          labelText: 'Status of reservation',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedReserv = value;
                            reservController.text = value!;
                          });
                        },
                        items: reservation.map((reservation) {
                          return DropdownMenuItem<String>(
                            value: reservation,
                            child: Text(reservation),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 1,
                  color: primaryColor,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Column(
                    children: [
                      Text(
                        "Price",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        controller: _priceController,
                        decoration:
                            decorationTextfield.copyWith(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 1,
                  color: primaryColor,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Column(
                    children: [
                      Text(
                        "Bedroom",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        validator: (value) {
                          return value!.isEmpty ? "Can not be empty" : null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: bedController,
                        keyboardType: TextInputType.number,
                        decoration: decorationTextfield.copyWith(
                          hintText: "Enter number",
                          suffixIcon: Icon(Icons.bedroom_parent_outlined),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Bathroom",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        validator: (value) {
                          return value!.isEmpty ? "Can not be empty" : null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: bathController,
                        keyboardType: TextInputType.number,
                        decoration: decorationTextfield.copyWith(
                          hintText: "Enter number",
                          suffixIcon: Icon(Icons.bathroom_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 1,
                  color: primaryColor,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Column(
                    children: [
                      Text(
                        "Amenities",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: SwitchListTile(
                                title: Text("Refrigirator"),
                                secondary: SvgPicture.asset(
                                  "assets/icons/refrigerator1.svg",
                                  height: 35,
                                ),
                                value: haveRefrigirator,
                                onChanged: (value) {
                                  setState(() {
                                    haveRefrigirator = value;
                                  });
                                }),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: SwitchListTile(
                                title: Text("Wifi"),
                                secondary: SvgPicture.asset(
                                  "assets/icons/wifi.svg",
                                  height: 30,
                                ),
                                value: haveWifi,
                                onChanged: (value) {
                                  setState(() {
                                    haveWifi = value;
                                  });
                                }),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: SwitchListTile(
                                title: Text("Washer"),
                                secondary: SvgPicture.asset(
                                  "assets/icons/washing.svg",
                                  height: 32,
                                ),
                                value: haveWasher,
                                onChanged: (value) {
                                  setState(() {
                                    haveWasher = value;
                                  });
                                }),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: SwitchListTile(
                                title: Text("Tv"),
                                secondary: SvgPicture.asset(
                                  "assets/icons/tv.svg",
                                  height: 35,
                                ),
                                value: havetv,
                                onChanged: (value) {
                                  setState(() {
                                    havetv = value;
                                  });
                                }),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: SwitchListTile(
                                title: Text("Smoke Detector"),
                                secondary: SvgPicture.asset(
                                  "assets/icons/smoke.svg",
                                  height: 32,
                                ),
                                value: haveSmokeDetector,
                                onChanged: (value) {
                                  setState(() {
                                    haveSmokeDetector = value;
                                  });
                                }),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: SwitchListTile(
                                title: Text("Garage"),
                                secondary: SvgPicture.asset(
                                  "assets/icons/garage.svg",
                                  height: 35,
                                ),
                                value: haveGarage,
                                onChanged: (value) {
                                  setState(() {
                                    haveGarage = value;
                                  });
                                }),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: SwitchListTile(
                                title: Text("Pool"),
                                secondary: SvgPicture.asset(
                                  "assets/icons/pool-stairs-svgrepo-com.svg",
                                  height: 32,
                                ),
                                value: havePool,
                                onChanged: (value) {
                                  setState(() {
                                    havePool = value;
                                  });
                                }),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: SwitchListTile(
                                title: Text("Balcony"),
                                secondary: SvgPicture.asset(
                                  "assets/icons/balcony-svgrepo-com.svg",
                                  height: 32,
                                ),
                                value: haveBalcony,
                                onChanged: (value) {
                                  setState(() {
                                    haveBalcony = value;
                                  });
                                }),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: SwitchListTile(
                                title: Text("Garden"),
                                secondary: SvgPicture.asset(
                                  "assets/icons/garden-planting-flower-svgrepo-com.svg",
                                  height: 35,
                                ),
                                value: haveGarden,
                                onChanged: (value) {
                                  setState(() {
                                    haveGarden = value;
                                  });
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: primaryColor,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Column(
                    children: [
                      Text(
                        "Change your images",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Must rechoose your images",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _image.length + 1,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (context, index) {
                              return index == 0
                                  ? Center(
                                      child: IconButton(
                                          onPressed: () {
                                            chooseImage();
                                          },
                                          icon: Icon(Icons.add)),
                                    )
                                  : Container(
                                      margin: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image: FileImage(_image[index - 1]),
                                        fit: BoxFit.cover,
                                      )),
                                    );
                            }),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      List<String> urls =
                          await uploadImagesToFirebaseStorage(_image);

                      final updatedpost = PostData(
                        open: reservController.text,
                        token: widget.post.token,
                        status: widget.post.status,
                        postID: widget.post.postID,
                        description: _descriptionController.text,
                        rules: _rulesController.text,
                        price: _priceController.text,
                        imgUrls: urls,
                        datePublished: widget.post.datePublished,
                        category: categController.text,
                        propertyType: widget.post.propertyType,
                        availability: availabilityController.text,
                        bedroom: bedController.text,
                        bathroom: bathController.text,
                        garage: haveGarage,
                        balcony: haveBalcony,
                        garden: haveGarden,
                        pool: havePool,
                        washer: haveWasher,
                        wifi: haveWifi,
                        tv: havetv,
                        smokeDetector: haveSmokeDetector,
                        ratingCount: widget.post.ratingCount,
                        averageRating: widget.post.averageRating,
                        uid: widget.post.uid,
                        monthNight: monthNightController.text,
                        location: widget.post.location,
                        refrigirator: haveRefrigirator,
                        administrativeArea: widget.post.administrativeArea,
                      );

                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.confirm,
                        text: 'Do you want to update your post',
                        confirmBtnText: 'Yes',
                        onConfirmBtnTap: () async {
                          Navigator.of(context).pop();
                          setState(() {
                            isLoading = true;
                          });

                          // Update the Firebase document with the new PostData object
                          await FirebaseFirestore.instance
                              .collection('postss')
                              .doc(widget.post.postID)
                              .update(updatedpost.convert2Map());

                          // Navigate back to the PostDetails widget with the updated post object
                          setState(() {
                            isLoading = false;
                            Navigator.pop(context, updatedpost);
                          });
                        },
                        cancelBtnText: 'No',
                        onCancelBtnTap: () async {
                          Navigator.of(context).pop();
                        },
                        confirmBtnColor: Colors.green,
                      );
                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'Oops...',
                        text: 'Add Your Informations',
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(primaryColor),
                    padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12, horizontal: 100)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                  ),
                  child: isLoading
                      ? Text(
                          "Loading...",
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        )
                      : Text(
                          "Save changes",
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
