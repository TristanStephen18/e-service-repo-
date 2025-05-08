import 'dart:convert';
import 'dart:typed_data';
import 'package:denr_car_e_service_app/screens/Chainsaw/add_lease.dart';
import 'package:denr_car_e_service_app/screens/Chainsaw/add_manufacture.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/add_prunning.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/add_special.dart';
import 'package:intl/intl.dart'; // Add this at the top of your file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/Chainsaw/add_chainsaw_reg.dart';
import 'package:denr_car_e_service_app/screens/Chainsaw/add_permit_to_purchase.dart';
import 'package:denr_car_e_service_app/screens/Chainsaw/add_permit_to_sell.dart';
import 'package:denr_car_e_service_app/screens/Lumber/add_lumber.dart';
import 'package:denr_car_e_service_app/screens/Plantation&Wood/add_plantation.dart';
import 'package:denr_car_e_service_app/screens/Resaw/add_resaw.dart';
import 'package:denr_car_e_service_app/screens/TransportPermit/add_ltp(Fauna).dart';
import 'package:denr_car_e_service_app/screens/TransportPermit/add_ltp(Flora).dart';
import 'package:denr_car_e_service_app/screens/TransportPermit/add_transport.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/add_governmet.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/add_pltp.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/add_public.dart';
import 'package:denr_car_e_service_app/screens/Wildlife/add_farm.dart';
import 'package:denr_car_e_service_app/screens/Wildlife/add_registration.dart';

class Display extends StatefulWidget {
  final String applicationId;

  const Display({super.key, required this.applicationId});

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _files;
  String? applicationType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplicationType();
    _files =
        FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('applications')
            .doc(widget.applicationId)
            .collection('requirements')
            .snapshots();
  }

  Future<void> _fetchApplicationType() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('mobile_users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('applications')
              .doc(widget.applicationId)
              .get();

      if (snapshot.exists) {
        setState(() {
          applicationType = snapshot.data()?['type'];
        });
      }
    } catch (e) {
      print("Error fetching application type: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Requirements',
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _files,
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

              final documents = snapshot.data!.docs;

              if (documents.isEmpty) {
                return const Center(child: Text('No Files found'));
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final data = documents[index].data();
                  final ext = data['fileExtension'];
                  final fileName = data['fileName'] ?? 'Details';
                  final base64EncodedFile = data['file'];

                  IconData fileIcon = Icons.description;
                  Color iconColor = Colors.grey;

                  if (ext == '.pdf') {
                    fileIcon = Icons.picture_as_pdf;
                    iconColor = Colors.red;
                  } else if ([
                    '.jpg',
                    '.jpeg',
                    '.png',
                  ].contains(ext?.toLowerCase())) {
                    fileIcon = Icons.image;
                    iconColor = Colors.blue;
                  } else if (base64EncodedFile == null) {
                    fileIcon = Icons.text_snippet;
                    iconColor = Colors.green;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (base64EncodedFile != null && ext != null) {
                        if (ext == ".pdf") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PdfViewerScreen(
                                    base64EncodedPdf: base64EncodedFile,
                                    fileName: fileName,
                                  ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ImagePreviewScreen(
                                    base64EncodedFile: base64EncodedFile,
                                    fileName: fileName,
                                  ),
                            ),
                          );
                        }
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PlainTextDetailsScreen(data: data),
                          ),
                        );
                      }
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(fileIcon, size: 80, color: iconColor),
                            const SizedBox(height: 10),
                            Text(
                              fileName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          if (widget.applicationId.startsWith("CH-") &&
              applicationType == 'Chainsaw Registration') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AddChainsawReg(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("CH-") &&
              applicationType == 'Permit To Sell') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AddPermitToSell(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("CH-") &&
              applicationType == 'Permit To Purchase') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddPermitToPurchase(
                      applicationId: widget.applicationId,
                    ),
              ),
            );
          } else if (widget.applicationId.startsWith("CH-") &&
              applicationType == 'Permit To Manufacture') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AddManufacture(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("CH-") &&
              applicationType == 'Authority To Lease') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddLease(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("TP-") &&
              applicationType == 'Forest Product') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddForestRequirementsForm(
                      applicationId: widget.applicationId,
                    ),
              ),
            );
          } else if (widget.applicationId.startsWith("TP-") &&
              applicationType == 'LTP(Fauna)') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AddLTPFauna(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("TP-") &&
              applicationType == 'LTP(Flora)') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AddLTPFlora(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("TC-") &&
              applicationType == 'Private Land Timber') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddPrivateLandScreen(
                      applicationId: widget.applicationId,
                    ),
              ),
            );
          } else if (widget.applicationId.startsWith("TC-") &&
              applicationType == 'Public Safety') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddPublicSafetyScreen(
                      applicationId: widget.applicationId,
                    ),
              ),
            );
          } else if (widget.applicationId.startsWith("TC-") &&
              applicationType == 'National Government Agencies') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AddGovermentScreen(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("TC-") &&
              applicationType == 'Prunning') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AddPrunning(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("TC-") &&
              applicationType == 'Special Tree Cutting') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AddSpecial(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("PTP-")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddPlantationRegistrationScreen(
                      applicationId: widget.applicationId,
                    ),
              ),
            );
          } else if (widget.applicationId.startsWith("LR-")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddLumber(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("WR-") &&
              applicationType == 'Wildlife Farm Permit') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddFarm(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("WR-") &&
              applicationType == 'Wildlife Registration') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AddRegistration(applicationId: widget.applicationId),
              ),
            );
          } else if (widget.applicationId.startsWith("RP-")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddResaw(applicationId: widget.applicationId),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No Additional Files Needed!")),
            );
          }
        },
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_file, color: Colors.white),
            SizedBox(height: 4),
            Text('Add', style: TextStyle(fontSize: 12, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String base64EncodedPdf;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.base64EncodedPdf,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    Uint8List pdfBytes = base64Decode(base64EncodedPdf);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          fileName,
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(17),
          ),
        ),
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.green,
      ),
      body: PDFView(pdfData: pdfBytes),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String base64EncodedFile;
  final String fileName;

  const ImagePreviewScreen({
    super.key,
    required this.base64EncodedFile,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = base64Decode(base64EncodedFile);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          fileName,
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(17),
          ),
        ),
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.green,
      ),
      body: Center(child: Image.memory(imageBytes)),
    );
  }
}

class PlainTextDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const PlainTextDetailsScreen({super.key, required this.data});

  String formatValue(dynamic value) {
    if (value is Timestamp) {
      DateTime dateTime = value.toDate();
      return DateFormat('MMMM dd, yyyy').format(dateTime);
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              data.entries.map((entry) {
                final label = entry.key;
                final value = formatValue(entry.value);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(value),
                      const Divider(thickness: 0.5),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
