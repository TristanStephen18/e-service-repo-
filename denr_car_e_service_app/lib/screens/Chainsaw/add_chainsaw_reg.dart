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

class AddChainsawReg extends StatefulWidget {
  final String applicationId; // ID of existing application

  const AddChainsawReg({super.key, required this.applicationId});

  @override
  State<AddChainsawReg> createState() => _AddChainsawRegState();
}

class _AddChainsawRegState extends State<AddChainsawReg> {
  final _formKey = GlobalKey<FormState>();

  File? deedofSale;
  File? regChainsaw;

  File? forestTenure;
  File? businessPermit;
  File? certRegistration;
  File? permitAffidavit;
  File? plantPermit;
  File? headOffice;
  File? certChainsawReg;

  // Pick file method
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

  // Upload additional files to existing application
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
        'Deed of Sale': 'Deed of Sale',
        'Forest Tenure Agreement': 'Forest Tenure Agreement',
        'Business Permit': 'Business Permit',
        'Certificate of Registration': 'Certificate of Registration',
        'Affidavit/Permit from LGU': 'Affidavit/Permit from LGU',
        'Plant Permit': 'Plant Permit',
        'Certification of Head Office': 'Certification of Head Office',
        'Certificate of Chainsaw Registration':
            'Certificate of Chainsaw Registration',
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
            .collection('chainsaw')
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

  // Submit selected files
  Future<void> _submitFiles() async {
    Map<String, File> filesToUpload = {};
    if (forestTenure != null) {
      filesToUpload['Forest Tenure Agreement'] = forestTenure!;
    }
    if (businessPermit != null) {
      filesToUpload['businessPermit'] = businessPermit!;
    }
    if (deedofSale != null) {
      filesToUpload['Deed of Sale'] = deedofSale!;
    }
    if (regChainsaw != null) {
      filesToUpload['Certificate of Chainsaw Registration'] = regChainsaw!;
    }

    if (businessPermit != null) {
      filesToUpload['Business Permit'] = businessPermit!;
    }
    if (certRegistration != null) {
      filesToUpload['Certificate of Registration'] = certRegistration!;
    }
    if (permitAffidavit != null) {
      filesToUpload['Affidavit/Permit from LGU'] = permitAffidavit!;
    }
    if (plantPermit != null) {
      filesToUpload['Plant Permit'] = plantPermit!;
    }
    if (headOffice != null) {
      filesToUpload['Certification of Head Office'] = headOffice!;
    }
    if (certChainsawReg != null) {
      filesToUpload['Certificate of Registration'] = certChainsawReg!;
    }
    if (filesToUpload.isNotEmpty) {
      await _uploadFiles(filesToUpload);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one file.')),
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
        title: const Text('Upload Additional Documents'),
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
                  'Additional Requirements',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                _buildFilePicker(
                  '1. Certified True Copy of Forest Tenure Agreement, if Tenure Instrument Holder;',
                  forestTenure,
                  (file) => setState(() => forestTenure = file),
                ),
                _buildFilePicker(
                  '2. Business Permit (1 photocopy), if business owner;',
                  businessPermit,
                  (file) => setState(() => businessPermit = file),
                ),
                _buildFilePicker(
                  '3. Certificate of Registration, if registered as PTPR;',
                  deedofSale,
                  (file) => setState(() => deedofSale = file),
                ),
                _buildFilePicker(
                  '4. Business Permit from LGU or affidavit that the chainsaw is needed in applications/profession/work'
                  ' and will be used for legal purpose (1 photocopy);',
                  permitAffidavit,
                  (file) => setState(() => permitAffidavit = file),
                ),
                _buildFilePicker(
                  '5. Wood processing plant permit (1 photocopy), if licensed wood processor;',
                  plantPermit,
                  (file) => setState(() => plantPermit = file),
                ),
                _buildFilePicker(
                  '6. Certification from the Head of Office or his/her authorized representative that chainsaws are owned/possessed'
                  ' by the office and use for legal purposes (specify), if government and GOCC;',
                  headOffice,
                  (file) => setState(() => headOffice = file),
                ),
                _buildFilePicker(
                  '7. Latest Certificate of Chainsaw Registration (1 photocopy), if renewal of registration',
                  certChainsawReg,
                  (file) => setState(() => certChainsawReg = file),
                ),
                const SizedBox(height: 32),

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
