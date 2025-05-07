// ignore_for_file: use_build_context_synchronously

import 'package:denr_car_e_service_app/model/responsive.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class WildlifeForm extends StatefulWidget {
  final String type;
  const WildlifeForm({super.key, required this.type});

  @override
  State<WildlifeForm> createState() => _ChainsawRegState();
}

class _ChainsawRegState extends State<WildlifeForm> {
  final _formKey = GlobalKey<FormState>();

  String serialNumber = '';
  String brand = '';
  String model = '';
  String engineCapacity = '';
  String guideBar = '';
  String countryOfOrigin = '';
  String purposeOfUse = '';
  String nameOfDealer = '';
  DateTime? dateOfPurchase;

  Future<void> saveChainsawDetails(String documentId) async {
    try {
      // Ensure the documentId is valid and we have a user logged in
      if (FirebaseAuth.instance.currentUser != null) {
        // Prepare data to be stored
        Map<String, dynamic> chainsawDetails = {
          'Serial Number': serialNumber,
          'Brand': brand,
          'Model': model,
          'Engine Capacity': engineCapacity,
          'Guide Bar': guideBar,
          'Country of Origin': countryOfOrigin,
          'Purpose of Use': purposeOfUse,
          'Name of Dealer': nameOfDealer,
          'Date of Purchase':
              dateOfPurchase != null
                  ? Timestamp.fromDate(dateOfPurchase!)
                  : Timestamp.now(), // Use current timestamp if null
        };

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('applications')
            .doc(documentId)
            .collection('requirements')
            .doc('Chainsaw Details')
            .set(chainsawDetails);

        await FirebaseFirestore.instance
            .collection('chainsaw')
            .doc(documentId)
            .collection('requirements')
            .doc('Chainsaw Details')
            .set(chainsawDetails);

        // Optionally, show a confirmation message or feedback
        print('Chainsaw details saved successfully!');
      } else {
        print('User is not logged in');
      }
    } catch (e) {
      // Handle errors gracefully
      print('Error saving chainsaw details: $e');
    }
  }

  // Submit all files
  Future<void> _submitFiles() async {
    // Confirm upload dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Upload'),
          content: const Text(
            'Are you sure you want to upload attached files?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                'Upload',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      //  Navigator.of(context).push(
      //                 CupertinoPageRoute(
      //                   builder: (ctx) => TransportMap(type: 'Flora'),
      //                 ),
      //               );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wildlife Form',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(17), // Scale text size
          ),
        ),
        backgroundColor: Colors.green,
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name of Species',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => serialNumber = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => brand = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Unit Weight Measure',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => model = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => engineCapacity = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Mode of Acquisition',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => guideBar = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Country of Origin',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => countryOfOrigin = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Purpose of Use',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => purposeOfUse = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name of Dealer',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => nameOfDealer = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Date of Purchase',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: dateOfPurchase ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        dateOfPurchase = selectedDate;
                      });
                    }
                  },
                  controller: TextEditingController(
                    text:
                        dateOfPurchase != null
                            ? '${dateOfPurchase!.toLocal()}'.split(' ')[0]
                            : '',
                  ),
                ),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _submitFiles,

                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
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
}
