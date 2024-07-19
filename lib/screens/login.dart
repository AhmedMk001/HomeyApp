import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homey_app/firebase_services/auth.dart';
import 'package:homey_app/responsive/mobilescreen.dart';
import 'package:homey_app/screens/forgetPassword.dart';
import 'package:homey_app/screens/register.dart';
import 'package:homey_app/shared/colors.dart';
import 'package:homey_app/shared/constant.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isVisibale = false;

  Future<UserCredential?> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      UserCredential? userCredential = await AuthMethods().login(
        emaill: emailController.text,
        passwordd: passwordController.text,
        context: context,
      );
      setState(() {
        isLoading = false;
      });
      return userCredential;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      return null;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(fontSize: 30, fontFamily: "myfont"),
                    ),
                    // Image.asset(
                    //   "assets/img/techny-real-estate-purchase.png",
                    //   width: 200,
                    // ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 100, 0, 4),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back,',
                              style: TextStyle(fontSize: 28),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Login to your account now",
                              style: TextStyle(fontSize: 18, color: textColor2),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    TextField(
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
                    TextField(
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
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgotPassword()),
                          );
                        },
                        child: Text("Foget Password?",
                            style: TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                                color: primaryColor))),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        UserCredential? userCredential = await login();
                        if (userCredential != null) {
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MobileScreen()),
                          );
                        } else {
                          // Login failed, show an error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Invalid email or password')),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(primaryColor),
                        padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                            vertical: 12, horizontal: 100)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                      ),
                      child: isLoading
                          ? LoadingAnimationWidget.staggeredDotsWave(
                              color: backgroundColor, size: 25)
                          : Text(
                              "Login",
                              style:
                                  TextStyle(fontSize: 19, color: Colors.white),
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(fontSize: 18),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Register()),
                              );
                            },
                            child: Text("Sign up",
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
    );
  }
}
