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

class AddPublicSafetyScreen extends StatefulWidget {
  final String applicationId; // ID of existing application

  const AddPublicSafetyScreen({super.key, required this.applicationId});

  @override
  State<AddPublicSafetyScreen> createState() => _AddPublicSafetyScreenState();
}

class _AddPublicSafetyScreenState extends State<AddPublicSafetyScreen> {
  final _formKey = GlobalKey<FormState>();

  File? resolution;
  File? ptaResolution;
  File? landTitle;
  File? pambClearance;

  File? spa;
  File? photo;
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
      String documentId = widget.applicationId; // Use provided application ID

      DocumentReference applicationRef = FirebaseFirestore.instance
          .collection('mobile_users')
          .doc(userId)
          .collection('applications')
          .doc(documentId);

      DocumentSnapshot applicationSnapshot = await applicationRef.get();

      final Map<String, String> fileLabelMap = {
        'resolution': 'Homeowners Resolution',
        'ptaResolution': 'PTA Resolution',
        'landTitle': 'Land Title',
        'pambClearance': 'PAMB Clearance',
        'spa': 'SPA',
        'photo': 'Photos of Trees',
      };

      if (!applicationSnapshot.exists) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Application not found!')));
        return;
      }

      for (var entry in files.entries) {
        String label = entry.key;
        File file = entry.value;

        String fileExtension = path.extension(file.path).toLowerCase();
        String base64File = await _convertFileToBase64(file);

        await applicationRef.collection('requirements').doc(label).set({
          'fileName': fileLabelMap[label] ?? label,
          'fileExtension': fileExtension,
          'file': base64File,
          'uploadedAt': Timestamp.now(),
        });
      }

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
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('Success'),
              ],
            ),
            content: const Text('Files uploaded successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (ctx) => Homepage(userid: userId),
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
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error during file upload: $e')));
    }
  }

  // Submit all files
  Future<void> _submitFiles() async {
    if (resolution != null && resolution != null) {
      Map<String, File> filesToUpload = {
        'resolution': resolution!,
        'ptaResolution': resolution!,
      };
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
                  'Additional Requirements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFilePicker(
                  '1. Homeowners Resolution (1 original / 1 Certified True Copy), if within Subdivisions;',
                  resolution,
                  (file) => setState(() => resolution = file),
                ),
                _buildFilePicker(
                  '2. PTA Resolution or Resolution from any organized group of No Objection and reason for Cutting (1 original), if School/Organization;',
                  ptaResolution,
                  (file) => setState(() => ptaResolution = file),
                ),
                _buildFilePicker(
                  '3. Authenticated copy of Land Title/CLOA issued by LRA or Registry of Deeds, whichever is applicable, if within private land;',
                  landTitle,
                  (file) => setState(() => landTitle = file),
                ),
                _buildFilePicker(
                  '4. Protected Area Management Board (PAMB) Clearance/Certification\n'
                  '\t\t\t a. Lower Agno Watershed Forest Reserve (LAWFR)\n'
                  '\t\t\t b. Marcos Highway Watershed Forest Reserve (MHWFR)\n'
                  '\t\t\t c. Mount Pulag Protected Landscape (MPPL)\n'
                  '\t\t\t d. Upper Agno River Basin Resource Reserve (UARBRR)',
                  pambClearance,
                  (file) => setState(() => pambClearance = file),
                ),
                _buildFilePicker(
                  '5. Special Power of Attorney (SPA), if the applicant is not the owner of the title;',
                  spa,
                  (file) => setState(() => spa = file),
                ),
                _buildFilePicker(
                  '6. Photos of the trees to be cut',
                  photo,
                  (file) => setState(() => photo = file),
                ),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
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
