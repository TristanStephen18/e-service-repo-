import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/screens/Home/homepage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class PermitToPurchase extends StatefulWidget {
  const PermitToPurchase({super.key});

  @override
  State<PermitToPurchase> createState() => _PermitToPurchaseState();
}

class _PermitToPurchaseState extends State<PermitToPurchase> {
  final _formKey = GlobalKey<FormState>();

  File? dulyAccomplishForm;
  File? businessNameReg;
  File? affidavit;
  File? bussinessPermit;
  File? purchaseOrder;

  final double permitFee = 500.00;

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
      String documentId = await _generateDocumentId();

      // Set root metadata
      await FirebaseFirestore.instance
          .collection('chainsaw')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'type': 'Permit To Purchase',
            'userID': FirebaseAuth.instance.currentUser!.uid,
            'client': 'Tristan Tukmol',
            'status': 'Pending',
            'current_location': 'RPU - For Evaluation',
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
            'type': 'Permit To Purchase',

            'status': 'Pending',
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
    if (dulyAccomplishForm != null && businessNameReg != null) {
      Map<String, File> filesToUpload = {
        'accomplish_form': dulyAccomplishForm!,
        'proof_owneship': businessNameReg!,
      };

      if (affidavit != null) {
        filesToUpload['business_registration'] = affidavit!;
      }
      if (bussinessPermit != null) {
        filesToUpload['business_permit'] = bussinessPermit!;
      }
      if (purchaseOrder != null) {
        filesToUpload['purchase_order'] = purchaseOrder!;
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
      appBar: AppBar(
        title: const Text('Permit to Purchase'),
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
                  '1. Duly Accomplish Application Form, together with the following details:\n'
                  '\t\t\t\ta. Number of chainsaws to be purchased/imported\n'
                  '\t\t\t\t\t\t\t\twith specifications\n'
                  '\t\t\t\tb. Purpose for purchasing/importing\n'
                  '\t\t\t\tc. Name and address of sellers/supliers\n'
                  '\t\t\t\td. Expected time of arrival at port of entry or release\n'
                  '\t\t\t\t\t\t\t\tfrom the Bureau of Customs, if imported\n'
                  '\t\t\t\te. Import Entry Declaration from the Bangko Sentral\n'
                  '\t\t\t\t\t\t\t\tng Pilipinas',
                  dulyAccomplishForm,
                  (file) => setState(() => dulyAccomplishForm = file),
                ),
                _buildFilePicker(
                  '2. Business name registration of applicant from DTI, SEC registration or CDA registration',
                  businessNameReg,
                  (file) => setState(() => businessNameReg = file),
                ),

                _buildFilePicker(
                  '3. If applicant is an individual, Affidavit the he will use the chainsaw for legal purpose only (e.g., tree pruning, tree surgery, landscaping and etc.)',
                  affidavit,
                  (file) => setState(() => affidavit = file),
                ),
                _buildFilePicker(
                  '4. Business Permit form LGU (1 photocopy), if business owner;',
                  bussinessPermit,
                  (file) => setState(() => bussinessPermit = file),
                ),
                _buildFilePicker(
                  '5. Copy of purchase orders, if imported;',
                  purchaseOrder,
                  (file) => setState(() => purchaseOrder = file),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Fees to be Paid',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFeeRow('Permit Fee', permitFee),

                const Divider(thickness: 1.2),
                _buildFeeRow('TOTAL', permitFee, isTotal: true),
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
