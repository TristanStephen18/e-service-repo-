// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'package:denr_car_e_service_app/screens/Home/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class WildlifeRegistrationScreen extends StatefulWidget {
  @override
  _WildlifeRegistrationScreenState createState() =>
      _WildlifeRegistrationScreenState();
}

class _WildlifeRegistrationScreenState
    extends State<WildlifeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  File? dulyAccomplishForm;
  File? financialCapability;
  File? proofAcquisition;
  File? intentLetter;

  Future<void> _pickFile(String label, Function(File) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      File pickedFile = File(result.files.single.path!);
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
    String today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('wildlife')
            .where(
              'uploadedAt',
              isGreaterThan: Timestamp.fromDate(
                DateTime.now().subtract(Duration(days: 1)),
              ),
            )
            .get();

    int latestNumber = 0;
    for (var doc in querySnapshot.docs) {
      String docId = doc.id;
      RegExp regExp = RegExp(r'WR-\d{4}-\d{2}-\d{2}-(\d{4})');
      Match? match = regExp.firstMatch(docId);
      if (match != null) {
        int currentNumber = int.parse(match.group(1)!);
        if (currentNumber > latestNumber) {
          latestNumber = currentNumber;
        }
      }
    }

    String newNumber = (latestNumber + 1).toString().padLeft(4, '0');
    return 'WR-$today-$newNumber';
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
              CircularProgressIndicator(),
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

      String clientName = userSnapshot.get('name') ?? 'Unknown Client';
      String clientAddress = userSnapshot.get('address') ?? 'Unknown Address';

      String documentId = await _generateDocumentId();

      final Map<String, String> fileLabelMap = {
        'Letter of Intent': 'Letter of Intent',
        'Application Form': 'Application Form',
        'Financial Capability': 'Financial Capability',
        'Proof of Acquisition': 'Proof of Acquisition',
      };

      // Set root metadata
      await FirebaseFirestore.instance
          .collection('wildlife')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'userID': FirebaseAuth.instance.currentUser!.uid,
            'status': 'Pending',
            'client': clientName,
            'current_location': 'RPU - For Evaluation',
            'address': clientAddress,
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
            'status': 'Pending',
          });

      // Upload each file
      for (var entry in files.entries) {
        String label = entry.key;
        File file = entry.value;

        String fileExtension = path.extension(file.path).toLowerCase();
        String base64File = await _convertFileToBase64(file);

        await FirebaseFirestore.instance
            .collection('wildlife')
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
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check, color: Colors.green),
                SizedBox(width: 8),
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
    if (dulyAccomplishForm != null && intentLetter != null) {
      Map<String, File> filesToUpload = {
        'Application Form': dulyAccomplishForm!,
        'Letter of Intent': intentLetter!,
      };

      if (financialCapability != null) {
        filesToUpload['Financial Capability'] = financialCapability!;
      }

      if (proofAcquisition != null) {
        filesToUpload['Proof of Acquisition'] = proofAcquisition!;
      }

      await _uploadFiles(filesToUpload);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Missing Files'),
            content: const Text('Please attach required files.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Closes the dialog
                },
              ),
            ],
          );
        },
      );
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
        title: const Text('Wildlife Registration'),
        centerTitle: true,
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
                  '1. Letter of Intent Addressed to this Office;',
                  intentLetter,
                  (file) => setState(() => intentLetter = file),
                ),
                _buildFilePicker(
                  '2. Duly Accomplished Application Form (Notarized);',
                  dulyAccomplishForm,
                  (file) => setState(() => dulyAccomplishForm = file),
                ),
                _buildFilePicker(
                  '3. Proof of Financial Capability (Certificate of Bank Statement and/or Proof of sustainable Resources to raise wildlife);',
                  financialCapability,
                  (file) => setState(() => financialCapability = file),
                ),

                _buildFilePicker(
                  '4. Proof of acquisition (e.g. Proof of Purchase from legitimate seller and/or Deed of Donation'
                  'from a holder of Wildlife Farm Permit or Certificate of Wildlife Registration)',
                  proofAcquisition,
                  (file) => setState(() => proofAcquisition = file),
                ),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _submitFiles,
                    child: const Text('Submit'),
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
