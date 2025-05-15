// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/Home/homepage.dart';
import 'package:denr_car_e_service_app/screens/LogIn/register.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _obscurePassword = true;
  String? _userID;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Responsive.init(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_userID == null) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      FirebaseFirestore.instance.collection('mobile_users').doc(_userID).update(
        {'status': 'offline', 'lastSeen': FieldValue.serverTimestamp()},
      );
    } else if (state == AppLifecycleState.resumed) {
      FirebaseFirestore.instance.collection('mobile_users').doc(_userID).update(
        {'status': 'online'},
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _login() async {
    bool hasInternet = await _hasInternet();
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (!hasInternet) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("No Internet"),
              content: Text(
                "Please check your internet connection and try again.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
      );
      return;
    } else if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(width: 15),
                  Text('Logging in...'),
                ],
              ),
            );
          },
        );

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username.text,
          password: password.text,
        );

        User? user = FirebaseAuth.instance.currentUser;
        String userID = user!.uid;
        _userID = userID;

        DocumentReference userDoc = FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(userID);

        // 🔄 Update status and token ONLY if fcmToken is available
        Map<String, dynamic> updateData = {'status': 'online'};
        if (fcmToken != null && fcmToken.isNotEmpty) {
          updateData['token'] = fcmToken;
        }

        await userDoc.update(updateData);

        Navigator.pop(context);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text('Success'),
                ],
              ),
              content: Text('You have successfully logged in!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      CupertinoPageRoute(
                        builder: (ctx) => Homepage(userid: userID),
                      ),
                    );
                  },
                  child: Text('OK', style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
      } catch (e) {
        Navigator.pop(context); // Dismiss loading dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Email or Password is incorrect!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  // Dialog function to get the email
  Future<String?> _showEmailDialog(BuildContext context) async {
    TextEditingController emailController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your email'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(hintText: 'Email'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(emailController.text);
              },
              child: Text(
                'Send Reset Email',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.getWidthScale(16)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(Responsive.getWidthScale(1)),
                          child: Image.asset(
                            "lib/images/logo.png",
                            height: Responsive.getHeightScale(150),
                          ),
                        ),
                        Text(
                          "CENRO Baguio Permits\n"
                          "\t\t\tInformation System",
                          style: TextStyle(
                            fontSize: Responsive.getTextScale(18),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(30),
                        TextFormField(
                          controller: username,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required.';
                            }
                            if (!EmailValidator.validate(value)) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.getHeightScale(15)),
                        TextFormField(
                          controller: password,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () async {
                                String? email = await _showEmailDialog(context);
                                if (email != null && email.isNotEmpty) {
                                  try {
                                    await FirebaseAuth.instance
                                        .sendPasswordResetEmail(email: email);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Password reset email sent to $email',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: Responsive.getTextScale(12),
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: Responsive.getHeightScale(10),
                              ),
                              backgroundColor: Colors.green,
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.getTextScale(15),
                              ),
                            ),
                          ),
                        ),
                        Gap(15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No Account?",
                              style: TextStyle(
                                fontSize: Responsive.getTextScale(12),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: Responsive.getTextScale(12),
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Developed by: Angelito Solis\nEmail: angelitosolis99@gmail.com',
                style: TextStyle(
                  fontSize: Responsive.getTextScale(10),
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
