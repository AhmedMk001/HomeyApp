import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homey_app/firebase_services/auth.dart';
import 'package:homey_app/responsive/mobilescreen.dart';
import 'package:homey_app/screens/login.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:homey_app/shared/constant.dart';
import 'package:email_validator/email_validator.dart';
import 'package:homey_app/shared/snackar.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final locationController = TextEditingController();
  final userAdministrativeAreaController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  bool isLoading = false;
  bool isVisibale = false;
  String? _currentLocation;

  Future<void> _getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(CupertinoIcons.exclamationmark_bubble),
          title: Text('Location Services Disabled'),
          content:
              Text('Please enable location services to continue in our app.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }
  }

  final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  final placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

  final location = placemarks.first;
  if (mounted) {
    setState(() {
      _currentLocation =
          "${location.subAdministrativeArea}, ${location.locality}";
      locationController.text = _currentLocation!;
      userAdministrativeAreaController.text = location.administrativeArea!;
    });
  }
}


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 30, fontFamily: "myfont"),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Get Started Now,',
                              style: TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      TextFormField(
                          validator: (value) {
                            return value!.isEmpty ? "Can not be empty" : null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: usernameController,
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          decoration: decorationTextfield.copyWith(
                              labelText: "Username",
                              hintText: "Username :",
                              suffixIcon: const Icon(CupertinoIcons.person))),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      TextFormField(
                        controller: TextEditingController(
                          text:
                              '${userAdministrativeAreaController.text}, ${locationController.text}',
                        ),
                        decoration: decorationTextfield.copyWith(
                          labelText: 'Location',
                          hintText: 'Please open your location',
                          enabled: false,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      TextFormField(
                          validator: (value) {
                            return value != null &&
                                    !EmailValidator.validate(value)
                                ? "Enter a valid email"
                                : null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          obscureText: false,
                          decoration: decorationTextfield.copyWith(
                              hintText: "Enter Your Email : ",
                              labelText: "Email",
                              suffixIcon: const Icon(CupertinoIcons.mail))),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      TextFormField(
                          validator: (value) {
                            return value!.length < 8
                                ? "Enter at least 8 characters"
                                : null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: passwordController,
                          keyboardType: TextInputType.text,
                          obscureText: isVisibale ? false : true,
                          decoration: decorationTextfield.copyWith(
                              hintText: "Enter Your Password : ",
                              labelText: "Password",
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isVisibale = !isVisibale;
                                  });
                                },
                                icon: isVisibale
                                    ? Icon(CupertinoIcons.eye)
                                    : Icon(CupertinoIcons.eye_slash),
                              ))),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      IntlPhoneField(
                        controller: phoneController,
                        decoration: decorationTextfield.copyWith(
                          labelText: 'Phone Number',
                          labelStyle: const TextStyle(color: Colors.black87),
                        ),
                        initialCountryCode: 'TN',
                        onChanged: (phone) {
                          print(phone.completeNumber);
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });

                            await AuthMethods().register(
                                usernameee: usernameController.text,
                                emailll: emailController.text,
                                passworddd: passwordController.text,
                                context: context,
                                phone: phoneController.text,
                                locationnn: locationController.text,
                                userAdministrativeArea:
                                    userAdministrativeAreaController.text);
                            setState(() {
                              isLoading = false;
                            });

                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MobileScreen()),
                            );
                          } else {
                            showSnackBar(context, "ERROR");
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(primaryColor),
                          padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 80)),
                          shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                        child: isLoading
                            ? LoadingAnimationWidget.staggeredDotsWave(
                                color: backgroundColor, size: 25)
                            : Text(
                                "Register",
                                style: TextStyle(
                                    fontSize: 19, color: Colors.white),
                              ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(fontSize: 18),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login()),
                                );
                              },
                              child: Text("Login",
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 18,
                                      decoration: TextDecoration.underline))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
