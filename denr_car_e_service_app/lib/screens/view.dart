import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/screens/Chainsaw/add_chainsaw_reg.dart';
import 'package:denr_car_e_service_app/screens/Plantation&Wood/add_plantation.dart';
import 'package:denr_car_e_service_app/screens/TransportPermit/add_transport.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/add_governmet.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/add_pltp.dart';
import 'package:denr_car_e_service_app/screens/TreeCutting/add_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class Display extends StatefulWidget {
  final String applicationId;

  const Display({super.key, required this.applicationId});

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _files;
  String? applicationType; // Stores the application type
  bool isLoading = true; // Track loading state

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

  /// Fetch application type from Firestore
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
      appBar: AppBar(title: const Text('Requirements')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _files,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
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
                  final fileName = data['fileName'];
                  final base64EncodedFile = data['file'];

                  IconData fileIcon = Icons.insert_drive_file;
                  Color iconColor = Colors.grey;

                  if (ext == '.pdf') {
                    fileIcon = Icons.picture_as_pdf;
                    iconColor = Colors.red;
                  } else if ([
                    '.jpg',
                    '.jpeg',
                    '.png',
                  ].contains(ext.toLowerCase())) {
                    fileIcon = Icons.image;
                    iconColor = Colors.blue;
                  }

                  return GestureDetector(
                    onTap: () {
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
          } else if (widget.applicationId.startsWith("TP-")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddForestRequirementsForm(
                      applicationId: widget.applicationId,
                    ),
              ),
            );
          } else if (widget.applicationId.startsWith("TC-") &&
              applicationType == 'Private Land Timber Permit') {
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
              applicationType == 'Public Safety Permit') {
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
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No Additional Files Needed!")),
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload_file),
            const SizedBox(height: 4),
            const Text('Add', style: TextStyle(fontSize: 12)),
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
      appBar: AppBar(title: Text(fileName)),
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
      appBar: AppBar(title: Text(fileName)),
      body: Center(child: Image.memory(imageBytes)),
    );
  }
}
