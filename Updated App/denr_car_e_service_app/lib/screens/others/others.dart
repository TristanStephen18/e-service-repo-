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

class Others extends StatefulWidget {
  const Others({super.key});

  @override
  _OthersState createState() => _OthersState();
}

class _OthersState extends State<Others> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> additionalAttachments = [];

  Future<void> _pickFile(String label, Function(File) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      File pickedFile = File(result.files.single.path!);
      int fileSize = await pickedFile.length();

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

  Future<String> _convertFileToBase64(File file) async {
    List<int> fileBytes = await file.readAsBytes();
    return base64Encode(fileBytes);
  }

  Future<String> _generateDocumentId() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('others')
            .orderBy('uploadedAt', descending: true)
            .limit(1)
            .get();

    int latestNumber = 0;

    if (querySnapshot.docs.isNotEmpty) {
      String lastDocId = querySnapshot.docs.first.id;
      RegExp regExp = RegExp(r'OT-\d{4}-\d{2}-\d{2}-(\d{4})');
      Match? match = regExp.firstMatch(lastDocId);
      if (match != null) {
        latestNumber = int.parse(match.group(1)!);
      }
    }

    String today = DateTime.now().toString().split(' ')[0];
    String newNumber = (latestNumber + 1).toString().padLeft(4, '0');

    return 'OT-$today-$newNumber';
  }

  Future<void> _uploadFiles(Map<String, File> files) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                SizedBox(width: 16),
                Text('Uploading files...'),
              ],
            ),
          ),
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

      await FirebaseFirestore.instance
          .collection('others')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'userID': userId,
            'status': 'Pending',
            'client': clientName,
            'current_location': 'RPU - For Evaluation',
            'address': clientAddress,
          });

      for (var entry in files.entries) {
        File file = entry.value;
        String base64File = await _convertFileToBase64(file);
        String extension = path.extension(file.path).toLowerCase();

        await FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(userId)
            .collection('applications')
            .doc(documentId)
            .collection('requirements')
            .doc(entry.key)
            .set({
              'fileName': entry.key,
              'fileExtension': extension,
              'file': base64File,
              'uploadedAt': Timestamp.now(),
            });

        await FirebaseFirestore.instance
            .collection('others')
            .doc(documentId)
            .collection('requirements')
            .doc(entry.key)
            .set({
              'fileName': entry.key,
              'fileExtension': extension,
              'file': base64File,
              'uploadedAt': Timestamp.now(),
            });
      }

      await FirebaseFirestore.instance
          .collection('mobile_users')
          .doc(userId)
          .collection('applications')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'userID': userId,
            'status': 'Pending',
          });

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
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error during file upload.')),
      );
      return null;
    }
  }

  Future<void> _submitFiles() async {
    Map<String, File> filesToUpload = {};

    for (var attachment in additionalAttachments) {
      if (attachment['file'] != null && attachment['label'] != null) {
        filesToUpload[attachment['label']] = attachment['file'];
      }
    }

    if (filesToUpload.isEmpty) {
      showDialog(
        context: context,
        builder:
            (BuildContext context) => AlertDialog(
              title: const Text('Missing Files'),
              content: const Text('Please attach at least one file.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
      return;
    }

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Confirm Upload'),
            content: const Text(
              'Are you sure you want to upload attached files?',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text(
                  'Upload',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _uploadFiles(filesToUpload);
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

  void _addAttachmentField() {
    setState(() {
      additionalAttachments.add({
        'label': 'Attachment ${additionalAttachments.length + 1}',
        'file': null,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Other Permits',
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
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
                  'Attach Files',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                for (int i = 0; i < additionalAttachments.length; i++)
                  _buildFilePicker(
                    '${i + 1}. ${additionalAttachments[i]['label']}',
                    additionalAttachments[i]['file'],
                    (file) =>
                        setState(() => additionalAttachments[i]['file'] = file),
                  ),

                TextButton.icon(
                  onPressed: _addAttachmentField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Another Attachment'),
                ),

                const SizedBox(height: 25),

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
