// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:denr_car_e_service_app/screens/Home/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class PublicSafetyScreen extends StatefulWidget {
  const PublicSafetyScreen({super.key});

  @override
  State<PublicSafetyScreen> createState() => _PublicSafetyScreenState();
}

class _PublicSafetyScreenState extends State<PublicSafetyScreen> {
  final _formKey = GlobalKey<FormState>();

  File? applicationLetter;
  File? lguEndorsement;
  File? resolution;
  File? ptaResolution;
  File? landTitle;
  File? pambClearance;

  File? spa;
  File? photo;

  // Pick file method
  Future<void> _pickFile(String label, Function(File) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'docx', 'txt'],
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
            .collection('tree_cutting')
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
      RegExp regExp = RegExp(r'TC-\d{4}-\d{2}-\d{2}-(\d{4})');
      Match? match = regExp.firstMatch(docId);
      if (match != null) {
        int currentNumber = int.parse(match.group(1)!);
        if (currentNumber > latestNumber) {
          latestNumber = currentNumber;
        }
      }
    }

    String newNumber = (latestNumber + 1).toString().padLeft(4, '0');
    return 'TC-$today-$newNumber';
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
        'applicationLetter': 'Duly Accomplish Application Form',
        'lguEndorsement': 'LGU Endorsement/Certification',
        'resolution': 'Homeowners Resolution',
        'ptaResolution': 'PTA Resolution',
        'landTitle': 'Land Title',
        'pambClearance': 'PAMB Clearance',
        'spa': 'SPA',
        'photo': 'Photos of Trees',
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
            'type': 'Public Safety Permit',
            'current_location': 'RPU - For Evaluation',
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
            'type': 'Public Safety Permit',
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
    if (applicationLetter != null && lguEndorsement != null) {
      Map<String, File> filesToUpload = {
        'applicationLetter': applicationLetter!,
        'lguEndorsement': lguEndorsement!,
      };

      if (resolution != null) {
        filesToUpload['resolution'] = resolution!;
      }
      if (ptaResolution != null) {
        filesToUpload['ptaResolution'] = ptaResolution!;
      }
      if (landTitle != null) {
        filesToUpload['landTitle'] = landTitle!;
      }
      if (pambClearance != null) {
        filesToUpload['pambClearance'] = pambClearance!;
      }
      if (spa != null) {
        filesToUpload['spa'] = spa!;
      }
      if (photo != null) {
        filesToUpload['photo'] = photo!;
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
      appBar: AppBar(title: const Text('Public Safety'), centerTitle: true),
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
                  '1. Application Letter (1 original Copy)\n'
                  '\t\t\t Address: Engr. Leandro L. De Jesus\n'
                  '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tCENRO Officer\n'
                  '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tCENRO Baguio',
                  applicationLetter,
                  (file) => setState(() => applicationLetter = file),
                ),
                _buildFilePicker(
                  '2. LGU Endorsement / Certification of No Objection / Resolution (1 original) - interposing no objection to the cutting of trees',
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
                  '3. resolution if the applicant is not the owner of the tree_cutting;',
                  resolution,
                  (file) => setState(() => resolution = file),
                ),
                _buildFilePicker(
                  '4. Detailed Specification of tree_cutting (e.g. brand, model, engine capacity, etc.);',
                  ptaResolution,
                  (file) => setState(() => ptaResolution = file),
                ),
                _buildFilePicker(
                  '5. Notarized Deed of Absolute Sale, if transfer of ownership (1 original);',
                  landTitle,
                  (file) => setState(() => landTitle = file),
                ),
                _buildFilePicker(
                  '6. tree_cutting to be registered',
                  pambClearance,
                  (file) => setState(() => pambClearance = file),
                ),
                _buildFilePicker(
                  '7. Certified True Copy of Forest Tenure Agreement, if Tenure Instrument Holder;',
                  spa,
                  (file) => setState(() => spa = file),
                ),
                _buildFilePicker(
                  '8. Business Permit (1 photocopy), if business owner;',
                  photo,
                  (file) => setState(() => photo = file),
                ),

                const SizedBox(height: 32),

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
