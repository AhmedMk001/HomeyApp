import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:homey_app/firebase_services/firestore.dart';
import 'package:homey_app/responsive/mobilescreen.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:homey_app/shared/constant.dart';
import 'package:homey_app/shared/snackar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:intl/intl.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  bool haveRefrigirator = false;
  bool haveWifi = false;
  bool haveWasher = false;
  bool haveSmokeDetector = false;
  bool haveGarage = false;
  bool havePool = false;
  bool haveBalcony = false;
  bool haveGarden = false;
  bool havetv = false;
  bool _isOpen = false;

  final List<File> _image = [];
  final picker = ImagePicker();
  File? imgPath;
  String? imgName;
  bool isLoading = false;
  bool uploading = false;

  final addressController = TextEditingController();
  final administrativeAreaController = TextEditingController();
  final priceController = TextEditingController();
  final bedController = TextEditingController();
  final bathController = TextEditingController();
  final descController = TextEditingController();
  final categController = TextEditingController();
  final propTypeController = TextEditingController();
  final monthNightController = TextEditingController();
  final rulesController = TextEditingController();
  final availabilityController = TextEditingController();

  String? _selectedCatigory;
  String? _selectedPropertyType;
  String? _selectedMonthNight;
  DateTime? _startDate;
  DateTime? _endDate;

  final _dateFormat = DateFormat('d-MMM'); // Format: Year-Month-Day

  List<String> monthNight = ["Month", "Night"];

  List<String> propertyType = [
    "Apartment",
    "Villa",
    "House",
    "Townhouse",
    "Cabin",
  ];

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

  getToken() async {
    String? mytoken = await FirebaseMessaging.instance.getToken();
    print("-------------------------------------");
    print(mytoken);
    return mytoken;
  }

  Future<Location> _getCurrentAddress(String address) async {
    final locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      return locations.first;
    } else {
      throw Exception('No location found for the entered address.');
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    administrativeAreaController.dispose();
    priceController.dispose();
    bedController.dispose();
    bathController.dispose();
    descController.dispose();
    categController.dispose();
    propTypeController.dispose();
    monthNightController.dispose();
    rulesController.dispose();
    availabilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: backgroundColor,
          titleSpacing: 20,
          centerTitle: true,
          title: Text(
            "Add your property to rent",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontFamily: "myfont",
                color: textColor),
          ),
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: SingleChildScrollView(
              child: Form(
                key: formstate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Property type",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    DropdownButtonFormField<String>(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a property';
                        }
                        return null;
                      },
                      value: _selectedPropertyType,
                      decoration: decorationTextfield.copyWith(
                        labelText: 'Property type',
                        hintText: 'Select a property',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedPropertyType = value;
                          propTypeController.text = value!;
                        });
                      },
                      items: propertyType.map((property) {
                        return DropdownMenuItem<String>(
                          value: property,
                          child: Text(property),
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Category",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
                      "Location",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "Enter your address in the field below, then click 'Get Coordinates' to retrieve and display the exact coordinates of your location.",
                    ),

                    SizedBox(
                      height: 6,
                    ),
                    Column(
                      children: <Widget>[
                        TextFormField(
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            hintText: 'Enter an address',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final address =
                                '${administrativeAreaController.text}, ${addressController.text}';
                            if (address.isEmpty) {
                              print('Please enter an address.');
                              return;
                            }
                            try {
                              final location =
                                  await _getCurrentAddress(address);
                              print(
                                  'Location coordinates: ${location.latitude}, ${location.longitude}');

                              // Convert the coordinates into a human-readable address
                              final placemarks = await placemarkFromCoordinates(
                                  location.latitude, location.longitude);

                              final place = placemarks.first;
                              final locationAddress =
                                  "${place.subAdministrativeArea}, ${place.locality}";
                              final administrativeArea =
                                  place.administrativeArea!;

                              // Update the TextFormField with the address
                              setState(() {
                                addressController.text = locationAddress;
                                administrativeAreaController.text =
                                    administrativeArea;
                              });
                            } catch (e) {
                              print('Error: $e');
                            }
                          },
                          child: Text('Get Coordinates'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.12,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Price",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    return value!.isEmpty
                                        ? "Can not be empty"
                                        : null;
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: decorationTextfield.copyWith(
                                    labelText: "Enter price",
                                    suffixIcon: Icon(Icons.attach_money),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              child: VerticalDivider(
                            width: 1,
                            color: Colors.black,
                          )),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Time",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 10,
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
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    Text(
                      "Availability",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    // Add a checkbox for "Open" availability
                    CheckboxListTile(
                      title: Text("Open"),
                      value: _isOpen,
                      onChanged: (value) {
                        setState(() {
                          _isOpen = value!;
                          if (_isOpen) {
                            _startDate = null;
                            _endDate = null;
                            availabilityController.text = 'Open';
                          } else {
                            availabilityController.text = '';
                          }
                        });
                      },
                    ),

                    // Start Date
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        hintText: 'Select a start date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      enabled:
                          !_isOpen, // Disable this field when _isOpen is true
                      onTap: () async {
                        if (!_isOpen) {
                          // If _isOpen is false, then show the date picker

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
                        }
                      },
                    ),

// End Date
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        hintText: 'Select an end date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      enabled: !_isOpen,
                      onTap: () async {
                        if (!_isOpen) {
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
                        }
                      },
                    ),

// Availability
                    TextFormField(
                      controller: availabilityController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Availability',
                        hintText: 'Select a date range',
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Bedroom",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
                      decoration: InputDecoration(
                        hoverColor: Colors.white,
                        focusColor: Colors.white,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter number",
                        suffixIcon: Icon(Icons.bedroom_parent_outlined),
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Bathroom",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
                      decoration: InputDecoration(
                        hoverColor: Colors.white,
                        focusColor: Colors.white,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter number",
                        suffixIcon: Icon(Icons.bathroom_outlined),
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "What this place offers",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
                    SizedBox(
                      height: 12,
                    ),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Give your property some description",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 11,
                    ),
                    TextFormField(
                      validator: (value) {
                        return value!.isEmpty ? "Can not be empty" : null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: descController,
                      maxLines: 6,
                      maxLength: 400,
                      keyboardType: TextInputType.text,
                      decoration: decorationTextfield.copyWith(
                        hintText: "Describe your post / How far from the center ville / how far from the beach...",
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Give your property some rules",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 11,
                    ),
                    TextFormField(
                      validator: (value) {
                        return value!.isEmpty ? "Can not be empty" : null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: rulesController,
                      maxLines: 6,
                      maxLength: 200,
                      keyboardType: TextInputType.text,
                      decoration: decorationTextfield.copyWith(
                        hintText: "Set your rules...",
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Add images to show you property",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    SizedBox(
                      height: 20,
                    ),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Notice :",
                        style: TextStyle(
                            color: Colors.redAccent.shade400,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "We appreciate your submitting. Our team will review your post. If it meets our guidelines, we will publish it for others to see.Within 24hours",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(),
                    SizedBox(
                      height: 25,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formstate.currentState!.validate()) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.confirm,
                              text: 'Do you want to add this post',
                              confirmBtnText: 'Yes',
                              onConfirmBtnTap: () async {
                                Navigator.of(context).pop();
                                setState(() {
                                  uploading = false;
                                  isLoading = true;
                                });

                                String myNotifToken = await getToken();

                                await FirestoreMethods().uploadPost(
                                  token: myNotifToken,
                                  bathroom: bathController.text,
                                  location: addressController.text,
                                  context: context,
                                  uid: FirebaseAuth.instance.currentUser!.uid,
                                  price: priceController.text,
                                  bedroom: bedController.text,
                                  description: descController.text,
                                  images: _image,
                                  wifi: haveWifi,
                                  tv: havetv,
                                  washer: haveWasher,
                                  refrigirator: haveRefrigirator,
                                  smokeDetector: haveSmokeDetector,
                                  garage: haveGarage,
                                  pool: havePool,
                                  balcony: haveBalcony,
                                  garden: haveGarden,
                                  availability: availabilityController.text,
                                  monthNight: monthNightController.text,
                                  rules: rulesController.text,
                                  category: categController.text,
                                  propertyType: propTypeController.text,
                                  administrativeArea:
                                      administrativeAreaController.text,
                                );

                                setState(() {
                                  uploading = false;
                                  isLoading = false;
                                });
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MobileScreen()),
                                );
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
                          backgroundColor:
                              WidgetStateProperty.all(primaryColor),
                          padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 60)),
                          shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                        child: isLoading
                            ? LoadingAnimationWidget.staggeredDotsWave(
                              color: backgroundColor, size: 25)
                            : Text(
                                "Submit",
                                style: TextStyle(
                                    fontSize: 19, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
