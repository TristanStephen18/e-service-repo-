import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/screens/LogIn/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Profiles extends StatelessWidget {
  const Profiles({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Gap(25),
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Gap(20),
                Container(
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 1.0),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: ExactAssetImage('lib/images/logo.png'),
                  ),
                ),
                Gap(10),
                FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('mobile_users')
                          .doc(user?.uid)
                          .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Text('User not found');
                    }

                    var userData = snapshot.data!;

                    return Column(
                      children: [
                        Text(
                          '${userData['name'][0].toUpperCase()}${userData['name'].substring(1)}',

                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        Text(
                          userData['email'] ?? '',
                          style: TextStyle(color: Colors.black.withOpacity(.3)),
                        ),
                      ],
                    );
                  },
                ),
                Gap(30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(Icons.person, color: Colors.green),
                    title: Text(
                      "Account Settings",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {},
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green,
                    ),
                  ),
                ),
                Gap(15),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(Icons.help, color: Colors.green),
                    title: Text(
                      "Help",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // Navigator.of(
                      //   context,
                      // ).push(CupertinoPageRoute(builder: (ctx) => D()));
                    },

                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green,
                    ),
                  ),
                ),
                Gap(15),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(Icons.logout_rounded, color: Colors.green),
                    title: Text(
                      "Logout",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      // Show confirmation dialog
                      bool shouldLogout = await _showLogoutConfirmationDialog(
                        context,
                      );

                      if (shouldLogout) {
                        // Sign out and show logout confirmation dialog
                        await FirebaseAuth.instance.signOut();
                        _showLogoutSuccessDialog(context);
                      }
                    },

                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to show the confirmation dialog
  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled logout
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed logout
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false); // Return false if user canceled
  }

  // Function to show success message after logout
  void _showLogoutSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logged Out'),
          content: Text('You have successfully logged out.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
