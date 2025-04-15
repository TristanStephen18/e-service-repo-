import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/changepass.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/LogIn/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class Profiles extends StatefulWidget {
  const Profiles({super.key});

  @override
  State<Profiles> createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  String? imageBase64;

  Future<void> _pickAndUploadImage(String uid) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      final base64Image = base64Encode(bytes);

      FirebaseFirestore.instance.collection('mobile_users').doc(uid).update({
        'photo': base64Image,
        'changed_photo': true,
      });

      setState(() {
        imageBase64 = base64Image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    User? user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Responsive.getWidthScale(15.0)),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Gap(Responsive.getHeightScale(20.0)),
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: Responsive.getTextScale(22.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Gap(Responsive.getHeightScale(20.0)),
                FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('mobile_users')
                          .doc(user?.uid)
                          .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Text('User not found');
                    }

                    var userData = snapshot.data!;
                    String? base64Photo = imageBase64 ?? userData['photo'];
                    String name = userData['name'] ?? 'No Name';
                    String email = userData['email'] ?? '';
                    Uint8List? imageBytes =
                        base64Photo != null ? base64Decode(base64Photo) : null;

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await _pickAndUploadImage(user!.uid);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: Responsive.getWidthScale(130.0),
                                height: Responsive.getWidthScale(130.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: Responsive.getWidthScale(65.0),
                                  backgroundImage:
                                      imageBytes != null
                                          ? MemoryImage(imageBytes)
                                          : null,
                                  child:
                                      imageBytes == null
                                          ? Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          )
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(Responsive.getHeightScale(12.0)),
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: Responsive.getTextScale(20.0),
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.black.withOpacity(.3),
                            fontSize: Responsive.getTextScale(14.0),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Gap(Responsive.getHeightScale(25.0)),
                _buildListTile(
                  context,
                  icon: Icons.key,
                  title: "Change Password",
                  onTap:
                      () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (ctx) => ChangePasswordScreen(),
                        ),
                      ),
                ),
                Gap(Responsive.getHeightScale(15.0)),
                _buildListTile(
                  context,
                  icon: Icons.help,
                  title: "Help",
                  onTap: () {},
                ),
                Gap(Responsive.getHeightScale(15.0)),
                _buildListTile(
                  context,
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  onTap: () async {
                    bool shouldLogout = await _showLogoutConfirmationDialog(
                      context,
                    );
                    if (shouldLogout) {
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
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

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
                  MaterialPageRoute(builder: (context) => Login(token: '')),
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
