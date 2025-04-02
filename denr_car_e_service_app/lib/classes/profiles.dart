// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/LogIn/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Profiles extends StatelessWidget {
  const Profiles({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Responsive class
    Responsive.init(context);

    User? user = FirebaseAuth.instance.currentUser;
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(
            Responsive.getWidthScale(15.0),
          ), // Responsive padding
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Gap(Responsive.getHeightScale(20.0)), // Responsive gap
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: Responsive.getTextScale(
                      22.0,
                    ), // Responsive font size
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Gap(Responsive.getHeightScale(20.0)), // Responsive gap
                Container(
                  width: Responsive.getWidthScale(130.0), // Responsive width
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 1.0),
                  ),
                  child: CircleAvatar(
                    radius: Responsive.getWidthScale(55.0), // Responsive radius
                    backgroundImage: ExactAssetImage('lib/images/user.png'),
                  ),
                ),
                Gap(Responsive.getHeightScale(12.0)), // Responsive gap
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
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Text('User not found');
                    }

                    var userData = snapshot.data!;

                    return Column(
                      children: [
                        Text(
                          '${userData['name']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: Responsive.getTextScale(
                              20.0,
                            ), // Responsive font size
                          ),
                        ),
                        Text(
                          userData['email'] ?? '',
                          style: TextStyle(
                            color: Colors.black.withOpacity(.3),
                            fontSize: Responsive.getTextScale(
                              14.0,
                            ), // Responsive font size
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Gap(Responsive.getHeightScale(25.0)), // Responsive gap
                _buildListTile(
                  context,
                  icon: Icons.person,
                  title: "Account Settings",
                  onTap: () {},
                ),
                Gap(Responsive.getHeightScale(15.0)), // Responsive gap
                _buildListTile(
                  context,
                  icon: Icons.help,
                  title: "Help",
                  onTap: () {
                    // Navigator.of(
                    //   context,
                    // ).push(CupertinoPageRoute(builder: (ctx) => D()));
                  },
                ),
                Gap(Responsive.getHeightScale(15.0)), // Responsive gap
                _buildListTile(
                  context,
                  icon: Icons.logout_rounded,
                  title: "Logout",
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable widget for ListTile
  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return Container(
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
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: onTap,
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
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
