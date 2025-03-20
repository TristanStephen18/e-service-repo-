import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/screens/view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Applications extends StatefulWidget {
  const Applications({super.key});

  @override
  State<Applications> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications> {
  String selectedFilter = 'All';

  final Map<String, String> applicationTypeMap = {
    'CH': 'Chainsaw',
    'TP': 'Transport Permit',
    'WR': 'Certificate of Wildlife',
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
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Header
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundImage: ExactAssetImage('lib/images/logo.png'),
                  ),
                ),
                const SizedBox(width: 13),
                const Text(
                  'DENR-CAR',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Gap(25),
            Center(
              child: const Text(
                'Applications',
                style: TextStyle(
                  fontSize: 24,
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
                    return const Center(child: CircularProgressIndicator());
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
                        title = 'Chainsaw - ${data['type'] ?? 'Chainsaw'}';
                      } else if (prefix == 'WR') {
                        title = 'Certificate of Wildlife';
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
                      } else {
                        leadingIcon = Icons.description;
                        iconColor = Colors.grey;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Application No: $docId"),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.green,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (ctx) => Display(applicationId: docId),
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
