// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/Home/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart' as path;

class Pruning extends StatefulWidget {
  final LatLng geoP;
  final String address;
  final Map<String, dynamic> polygonName;
  final String purpose;
  final String landStatus;
  final String treeCategory;
  final String treeCount;
  final String treeSpecies;
  final String authority;
  const Pruning({
    super.key,
    required this.address,
    required this.geoP,
    required this.polygonName,
    required this.purpose,
    required this.landStatus,
    required this.treeCategory,
    required this.treeCount,
    required this.treeSpecies,
    required this.authority,
  });

  @override
  State<Pruning> createState() => _PruningState();
}

class _PruningState extends State<Pruning> {
  final _formKey = GlobalKey<FormState>();

  File? applicationLetter;
  File? lguEndorsement;
  File? homeowner;
  File? ptaRes;
  File? landTitle;
  File? pambClearance;

  File? cepmoClearance;

  final double certificationFee = 50.00;
  final double oathFee = 36.00;
  final double inspectionFee = 360.00;

  double get totalFee => certificationFee + oathFee + inspectionFee;
  Future<void> _pickFile(String label, Function(File) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      File pickedFile = File(result.files.single.path!);
      int fileSize = await pickedFile.length();

      // File size validation: max 749 KB (in bytes = 749 * 1024)
      if (fileSize > 749 * 1024) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("File Too Large"),
                content: const Text(
                  "The selected file exceeds the 750 KB limit. Please choose a smaller or compressed file.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
        return;
      }

      onFilePicked(pickedFile);
    }
  }

  // Convert file to Base64
  Future<String> _convertFileToBase64(File file) async {
    try {
      List<int> fileBytes = await file.readAsBytes();
      return base64Encode(fileBytes);
    } catch (e) {
      throw Exception("Failed to convert file to Base64: $e");
    }
  }

  // Generate Document ID
  Future<String> _generateDocumentId() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('tree_cutting')
            .orderBy('uploadedAt', descending: true) // Get latest uploads first
            .limit(1) // Only check the latest document
            .get();

    int latestNumber = 0;

    if (querySnapshot.docs.isNotEmpty) {
      String lastDocId = querySnapshot.docs.first.id;
      RegExp regExp = RegExp(r'TC-\d{4}-\d{2}-\d{2}-(\d{4})');
      Match? match = regExp.firstMatch(lastDocId);
      if (match != null) {
        latestNumber = int.parse(match.group(1)!);
      }
    }

    String today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    String newNumber = (latestNumber + 1).toString().padLeft(4, '0');

    return 'TC-$today-$newNumber';
  }

  Widget _buildFeeRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
              color: isTotal ? Colors.red : Colors.black,
            ),
          ),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
              color: isTotal ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Upload all files to Firestore
  Future<void> _uploadFiles(Map<String, File> files) async {
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
              SizedBox(width: 16),
              Text('Uploading files...'),
            ],
          ),
        );
      },
    );
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance
              .collection('mobile_users')
              .doc(userId)
              .get();

      Map<String, dynamic>? data = userSnapshot.data() as Map<String, dynamic>?;

      String clientName =
          (data != null && data.containsKey('name'))
              ? data['name']
              : data?['representative'] ?? 'No Name';
      String clientAddress = userSnapshot.get('address') ?? 'Unknown Address';
      String documentId = await _generateDocumentId();

      final Map<String, String> fileLabelMap = {
        'Duly Accomplish Application Form': 'Duly Accomplish Application Form',
        'LGU Endorsement or Certification': 'LGU Endorsement or Certification',
        'Homeowner': 'Homeowner',
        'Land Title': 'Land Title',
        'PAMB Clearance': 'PAMB Clearance',
        'CEPMO Clearance': 'CEPMO Clearance',

        'PTA Resolution': 'PTA Resolution',
      };

      // Set root metadata
      await FirebaseFirestore.instance
          .collection('tree_cutting')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'client': clientName,
            'address': clientAddress,
            'status': 'Pending',
            'userID': FirebaseAuth.instance.currentUser!.uid,
            'type': 'Prunning',
            'current_location': 'RPU - For Evaluation',
            'location': GeoPoint(widget.geoP.latitude, widget.geoP.longitude),
            'tcp_location': widget.address,
            'pamb': widget.polygonName,
            'Authority': widget.authority,
          });

      // Upload each file
      for (var entry in files.entries) {
        String label = entry.key;
        File file = entry.value;

        String fileExtension = path.extension(file.path).toLowerCase();
        String base64File = await _convertFileToBase64(file);

        await FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('applications')
            .doc(documentId)
            .collection('requirements')
            .doc(label)
            .set({
              'fileName': fileLabelMap[label] ?? label,
              'fileExtension': fileExtension,
              'file': base64File,
              'uploadedAt': Timestamp.now(),
            });
      }

      await FirebaseFirestore.instance
          .collection('mobile_users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('applications')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'userID': FirebaseAuth.instance.currentUser!.uid,
            'type': 'Prunning',
            'status': 'Pending',
          });

      // Upload each file
      for (var entry in files.entries) {
        String label = entry.key;
        File file = entry.value;

        String fileExtension = path.extension(file.path).toLowerCase();
        String base64File = await _convertFileToBase64(file);

        await FirebaseFirestore.instance
            .collection('tree_cutting')
            .doc(documentId)
            .collection('requirements')
            .doc(label)
            .set({
              'fileName': fileLabelMap[label] ?? label,
              'fileExtension': fileExtension,
              'file': base64File,
              'uploadedAt': Timestamp.now(),
            });

        Map<String, dynamic> formData = {
          'Purpose': widget.purpose,
          'Land Status': widget.landStatus,
          'Tree Category': widget.treeCategory,
          'Tree Count': widget.treeCount,
          'Tree Species': widget.treeSpecies,
        };

        await FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('applications')
            .doc(documentId)
            .collection('requirements')
            .doc('TCP Data')
            .set(formData);

        await FirebaseFirestore.instance
            .collection('tree_cutting')
            .doc(documentId)
            .collection('requirements')
            .doc('TCP Data')
            .set(formData);
      }

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('Success'),
              ],
            ),
            content: const Text('Application Submitted Successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder:
                          (ctx) => Homepage(
                            userid: FirebaseAuth.instance.currentUser!.uid,
                          ),
                    ),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error during file upload.')),
      );
    }
  }

  // Submit all files
  Future<void> _submitFiles() async {
    Map<String, File> filesToUpload = {};

    if (applicationLetter != null) {
      filesToUpload['Duly Accomplish Application Form'] = applicationLetter!;
    }
    if (lguEndorsement != null) {
      filesToUpload['LGU Endorsement or Certification'] = lguEndorsement!;
    }

    if (homeowner != null) {
      filesToUpload['Utilization Plan'] = homeowner!;
    }
    if (cepmoClearance != null) {
      filesToUpload['CEPMO Clearance'] = cepmoClearance!;
    }
    if (landTitle != null) {
      filesToUpload['Land Title'] = landTitle!;
    }
    if (pambClearance != null) {
      filesToUpload['PAMB Clearance'] = pambClearance!;
    }

    if (ptaRes != null) {
      filesToUpload['PTA Resolution'] = ptaRes!;
    }

    if (filesToUpload.isEmpty) {
      // Show alert if no files attached
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Missing Files'),
            content: const Text('Please attach at least one file.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

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
      await _uploadFiles(filesToUpload);
    }
  }

  // File Picker UI Widget
  Widget _buildFilePicker(
    String label,
    File? file,
    Function(File) onFilePicked,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _pickFile(label, onFilePicked),
            icon: const Icon(Icons.attach_file),
            label: const Text('Attach File'),
          ),
          if (file != null)
            Text(
              'Selected: ${path.basename(file.path)}',
              style: const TextStyle(fontSize: 14),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prunning',
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
                const Text(
                  'Checklist of Requirements',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFilePicker(
                  '1. Application Letter (1 original Copy)',

                  applicationLetter,
                  (file) => setState(() => applicationLetter = file),
                ),
                _buildFilePicker(
                  '2. LGU Endorsement / Certification of No Objection / Resolution (1 original',

                  lguEndorsement,
                  (file) => setState(() => lguEndorsement = file),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Additional Requirements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFilePicker(
                  '3.Homeowners Resolution (1 original / 1 certified true copy), if within Subdivisions',
                  homeowner,
                  (file) => setState(() => homeowner = file),
                ),

                _buildFilePicker(
                  '4.PTA Resolution or Resolution from any organized group of No Objection and REason for Cutting (1 original), if School / Organization',
                  ptaRes,
                  (file) => setState(() => ptaRes = file),
                ),
                _buildFilePicker(
                  '5. Photocopy of Land Title / CLOA issued by LRA or Registry of Deeds, whichever is applicable, is within private or titled lot',
                  landTitle,
                  (file) => setState(() => landTitle = file),
                ),
                _buildFilePicker(
                  '6.PAMB Clearance / Certification, if within Protected Area',
                  pambClearance,
                  (file) => setState(() => pambClearance = file),
                ),
                _buildFilePicker(
                  '7. CEPMO Clearance, if within the City of Baguio',
                  cepmoClearance,
                  (file) => setState(() => cepmoClearance = file),
                ),

                const SizedBox(height: 15),
                const Text(
                  'Fees to be Paid',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFeeRow('Certification Fee', certificationFee),
                _buildFeeRow('Oath Fee', oathFee),
                _buildFeeRow('Inventory Fee', inspectionFee),
                const Divider(thickness: 1.2),
                _buildFeeRow('TOTAL', totalFee, isTotal: true),
                const SizedBox(height: 32),

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
