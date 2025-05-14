import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/application/app_options.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Applications extends StatefulWidget {
  const Applications({super.key});

  @override
  State<Applications> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications> {
  String selectedFilter = 'All';

  final Map<String, String> applicationTypeMap = {
    'CH': 'Chainsaw',
    'TP': 'Transport',
    'WR': 'Wildlife',
    'PTP': 'Private Tree',
    'TC': 'Tree Cutting',
    'PR': 'Processing',
    'OT': 'Other Permit',
  };

  Future<List<QueryDocumentSnapshot>> fetchUserApplications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(user.uid)
            .collection('applications')
            .get();

    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(
          Responsive.getWidthScale(15.0),
        ), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: ExactAssetImage('lib/images/logo.png'),
                  backgroundColor: Colors.transparent,
                ),

                SizedBox(
                  width: Responsive.getWidthScale(10.0),
                ), // Responsive spacing
                const Text(
                  'DENR-CAR CENRO',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Responsive.getHeightScale(20.0),
            ), // Responsive height

            Center(
              child: Text(
                'Applications',
                style: TextStyle(
                  fontSize: Responsive.getTextScale(
                    22.0,
                  ), // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),

            DropdownButton<String>(
              value: selectedFilter,
              icon: const Icon(Icons.arrow_drop_down),
              underline: Container(height: 3, color: Colors.blue),
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
              },
              items:
                  ['All', ...applicationTypeMap.values]
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
            ),

            Flexible(
              child: FutureBuilder<List<QueryDocumentSnapshot>>(
                future: fetchUserApplications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data ?? [];

                  final filteredDocs =
                      selectedFilter == 'All'
                          ? docs
                          : docs.where((doc) {
                            final prefix = doc.id.split('-').first;
                            return applicationTypeMap[prefix] == selectedFilter;
                          }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text("No applications found."));
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final docId = doc.id;
                      final prefix = docId.split('-').first;

                      String title;
                      if (prefix == 'CH') {
                        final subtype =
                            data.containsKey('subtype')
                                ? data['subtype']
                                : null;
                        title =
                            'Chainsaw - ${data['type']}' +
                            (subtype != null &&
                                    subtype.toString().trim().isNotEmpty
                                ? ' - $subtype'
                                : '');
                      } else if (prefix == 'WR') {
                        title = 'Wildlife - ${data['type']}';
                      } else if (prefix == 'PTP') {
                        title = 'Private Tree Plantation - ${data['type']}';
                      } else if (prefix == 'PR') {
                        title = 'Processing - ${data['type']}';
                      } else if (prefix == 'TC') {
                        title = 'Tree Cutting - ${data['type']}';
                      } else if (prefix == 'TP') {
                        title = 'Transport - ${data['type']}';
                      } else if (prefix == 'OT') {
                        title = 'Other Permit';
                      } else {
                        title = applicationTypeMap[prefix] ?? 'Unknown Permit';
                      }

                      final status = data['status'] ?? 'No Status';

                      IconData leadingIcon;
                      Color iconColor;

                      if (prefix == 'CH') {
                        leadingIcon = Icons.carpenter;
                        iconColor = Colors.green;
                      } else if (prefix == 'TP') {
                        leadingIcon = Icons.car_crash;
                        iconColor = Colors.green;
                      } else if (prefix == 'WR') {
                        leadingIcon = Icons.pets;
                        iconColor = Colors.green;
                      } else if (prefix == 'PTP') {
                        leadingIcon = Icons.grass;
                        iconColor = Colors.green;
                      } else if (prefix == 'PR') {
                        leadingIcon = Icons.park;
                        iconColor = Colors.green;
                      } else if (prefix == 'TC') {
                        leadingIcon = Icons.forest;
                        iconColor = Colors.green;
                      } else if (prefix == 'OT') {
                        leadingIcon = Icons.file_copy;
                        iconColor = Colors.green;
                      } else {
                        leadingIcon = Icons.description;
                        iconColor = Colors.grey;
                      }

                      if (status.toLowerCase() == 'rejected') {
                        iconColor = Colors.red;
                      }

                      return Container(
                        margin: EdgeInsets.symmetric(
                          vertical: Responsive.getHeightScale(8.0),
                        ), // Responsive margin
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
                          leading: Icon(leadingIcon, color: iconColor),
                          title: Text(
                            "$title ($status)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Application No: $docId"),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.green,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder:
                                    (ctx) => OptionScreen(
                                      applicationId: docId,
                                      appType: prefix,
                                      status: status,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
