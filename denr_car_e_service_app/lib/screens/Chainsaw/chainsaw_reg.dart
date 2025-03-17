import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class ChainsawReg extends StatefulWidget {
  const ChainsawReg({super.key});

  @override
  State<ChainsawReg> createState() => _ChainsawRegState();
}

class _ChainsawRegState extends State<ChainsawReg> {
  final _formKey = GlobalKey<FormState>();

  File? dulyAccomplishForm;
  File? _orCrFile;
  File? _treeCuttingPermitFile;
  File? _transportAgreementFile;
  File? _spaFile;

  final double certificationFee = 50.00;
  final double oathFee = 36.00;
  final double inventoryFee = 360.00;

  double get totalFee => certificationFee + oathFee + inventoryFee;

  // Pick file method
  Future<void> _pickFile(String label, Function(File) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
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
            .collection('chainsaw')
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
      RegExp regExp = RegExp(r'CH-\d{4}-\d{2}-\d{2}-(\d{4})');
      Match? match = regExp.firstMatch(docId);
      if (match != null) {
        int currentNumber = int.parse(match.group(1)!);
        if (currentNumber > latestNumber) {
          latestNumber = currentNumber;
        }
      }
    }

    String newNumber = (latestNumber + 1).toString().padLeft(4, '0');
    return 'CH-$today-$newNumber';
  }

  // Upload all files to Firestore
  Future<void> _uploadFiles(Map<String, File> files) async {
    try {
      String documentId = await _generateDocumentId();

      // Set root metadata
      await FirebaseFirestore.instance
          .collection('chainsaw')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),

            'userID': FirebaseAuth.instance.currentUser!.uid,
            'type': 'chainsaw_registration',
          });

      // Upload each file
      for (var entry in files.entries) {
        String label = entry.key;
        File file = entry.value;

        String fileName = path.basename(file.path);
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
              'fileName': fileName,
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
            'type': 'chainsaw_registration',
          });

      // Upload each file
      for (var entry in files.entries) {
        String label = entry.key;
        File file = entry.value;

        String fileName = path.basename(file.path);
        String fileExtension = path.extension(file.path).toLowerCase();
        String base64File = await _convertFileToBase64(file);

        await FirebaseFirestore.instance
            .collection('chainsaw')
            .doc(documentId)
            .collection('requirements')
            .doc(label)
            .set({
              'fileName': fileName,
              'fileExtension': fileExtension,
              'file': base64File,
              'uploadedAt': Timestamp.now(),
            });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All files submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error during file upload.')),
      );
    }
  }

  // Submit all files
  Future<void> _submitFiles() async {
    if (dulyAccomplishForm != null && _orCrFile != null) {
      Map<String, File> filesToUpload = {
        'certification': dulyAccomplishForm!,
        'or_cr': _orCrFile!,
      };

      if (_treeCuttingPermitFile != null) {
        filesToUpload['tree_cutting_permit'] = _treeCuttingPermitFile!;
      }
      if (_transportAgreementFile != null) {
        filesToUpload['transport_agreement'] = _transportAgreementFile!;
      }
      if (_spaFile != null) {
        filesToUpload['spa'] = _spaFile!;
      }

      await _uploadFiles(filesToUpload);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach required files.')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Requirements'), centerTitle: true),
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
                  'Certification (for non-timber)',
                  dulyAccomplishForm,
                  (file) => setState(() => dulyAccomplishForm = file),
                ),
                _buildFilePicker(
                  'OR/CR and Driver’s License',
                  _orCrFile,
                  (file) => setState(() => _orCrFile = file),
                ),
                const SizedBox(height: 24),
                const Text(
                  'If Necessary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFilePicker(
                  'Approved Tree Cutting Permit',
                  _treeCuttingPermitFile,
                  (file) => setState(() => _treeCuttingPermitFile = file),
                ),
                _buildFilePicker(
                  'Certificate of Transport Agreement',
                  _transportAgreementFile,
                  (file) => setState(() => _transportAgreementFile = file),
                ),
                _buildFilePicker(
                  'Special Power of Attorney (SPA)',
                  _spaFile,
                  (file) => setState(() => _spaFile = file),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Fees to be Paid',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFeeRow('Certification Fee', certificationFee),
                _buildFeeRow('Oath Fee', oathFee),
                _buildFeeRow('Inventory Fee', inventoryFee),
                const Divider(thickness: 1.2),
                _buildFeeRow('TOTAL', totalFee, isTotal: true),
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
