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

class AddPrivateLandScreen extends StatefulWidget {
  final String applicationId; // ID of existing application

  const AddPrivateLandScreen({super.key, required this.applicationId});

  @override
  State<AddPrivateLandScreen> createState() => _AddPrivateLandScreenState();
}

class _AddPrivateLandScreenState extends State<AddPrivateLandScreen> {
  final _formKey = GlobalKey<FormState>();

  File? utiPlan;
  File? pambClearance;
  File? larEndorsement;
  File? ptaRes;
  File? spa;
  File? photo;
  File? others;

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
      String documentId = widget.applicationId; // Use provided application ID

      DocumentReference applicationRef = FirebaseFirestore.instance
          .collection('mobile_users')
          .doc(userId)
          .collection('applications')
          .doc(documentId);

      DocumentSnapshot applicationSnapshot = await applicationRef.get();

      final Map<String, String> fileLabelMap = {
        'Utilization Plan': 'Utilization Plan',

        'PAMB Clearance': 'PAMB Clearance',
        'SPA': 'SPA',
        'Photos of Trees': 'Photos of Trees',
        'Local Agrarian Endorsement': 'Local Agrarian Endorsement',
        'PTA Resolution': 'PTA Resolution',
        'Others': 'Others',
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
    if (pambClearance != null && utiPlan != null) {
      Map<String, File> filesToUpload = {
        'PAMB Clearance': pambClearance!,
        'Utilization Plan': utiPlan!,
      };

      if (larEndorsement != null) {
        filesToUpload['Local Agrarian Endorsement'] = larEndorsement!;
      }
      if (spa != null) {
        filesToUpload['SPA'] = spa!;
      }
      if (photo != null) {
        filesToUpload['Photos of Trees'] = photo!;
      }

      if (ptaRes != null) {
        filesToUpload['PTA Resolution'] = ptaRes!;
      }
      if (others != null) {
        filesToUpload['Others'] = others!;
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
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

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
        title: const Text(
          'Private Land Timber',
          style: TextStyle(color: Colors.white),
        ),
        leading: BackButton(color: Colors.white),
        backgroundColor: Colors.green,
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
                  'Additional Requirements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 15),

                _buildFilePicker(
                  '1. Protected Area Management Board (PAMB) Clearance/Certification\n'
                  '\t\t\t a. Lower Agno Watershed Forest Reserve (LAWFR)\n'
                  '\t\t\t b. Marcos Highway Watershed Forest Reserve (MHWFR)\n'
                  '\t\t\t c. Mount Pulag Protected Landscape (MPPL)\n'
                  '\t\t\t d. Upper Agno River Basin Resource Reserve (UARBRR)',
                  pambClearance,
                  (file) => setState(() => pambClearance = file),
                ),
                _buildFilePicker(
                  '2. Utilization Plan with at least 50% of the area covered with forest trees(1 original), if the applicaton covers 10 hectares or larger;',
                  utiPlan,
                  (file) => setState(() => utiPlan = file),
                ),
                _buildFilePicker(
                  '3. Endorsement by local agrarian reform officer interposing No Objection (1 original), if covered by CLOA, Municipal/City Agrarian Reform Office;',
                  larEndorsement,
                  (file) => setState(() => larEndorsement = file),
                ),
                _buildFilePicker(
                  '4. PTA Resolution or Resolution from any organized group of No Objection and reason for cutting (1 original), if School/Organization;',
                  spa,
                  (file) => setState(() => spa = file),
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
                _buildFilePicker(
                  '7. Others',
                  others,
                  (file) => setState(() => others = file),
                ),

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
