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
import 'package:path/path.dart' as path;

class LumberRegistration extends StatefulWidget {
  const LumberRegistration({super.key});

  @override
  State<LumberRegistration> createState() => _LumberRegistrationState();
}

class _LumberRegistrationState extends State<LumberRegistration> {
  final _formKey = GlobalKey<FormState>();

  File? dulyAccomplishForm;
  File? picture;
  File? permitEngage;
  File? lumberContract;
  File? businessPlan;
  File? listEmployees;

  File? incomeTax;
  File? financialStatement;
  File? certBank;
  File? prevCert;
  File? certRegistration;
  File? certNonCoverage;
  File? reportLumber;
  File? inventory;

  final double cashDeposit = 1500.00;

  double get totalFee => 1116.00 + cashDeposit;

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
            .collection('lumber_registration')
            .orderBy('uploadedAt', descending: true) // Get latest uploads first
            .limit(1) // Only check the latest document
            .get();

    int latestNumber = 0;

    if (querySnapshot.docs.isNotEmpty) {
      String lastDocId = querySnapshot.docs.first.id;
      RegExp regExp = RegExp(r'LR-\d{4}-\d{2}-\d{2}-(\d{4})');
      Match? match = regExp.firstMatch(lastDocId);
      if (match != null) {
        latestNumber = int.parse(match.group(1)!);
      }
    }

    String today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    String newNumber = (latestNumber + 1).toString().padLeft(4, '0');

    return 'LR-$today-$newNumber';
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

      String clientName = userSnapshot.get('name') ?? 'Unknown Client';
      String clientAddress = userSnapshot.get('address') ?? 'Unknown Address';
      String documentId = await _generateDocumentId();

      final Map<String, String> fileLabelMap = {
        'Duly Accomplish Application Form': 'Duly Accomplish Application Form',
        'Pictures of Establishment': 'Pictures of Establishment',
        'Permit to Engage': 'Permit to Engage',
        'Lumber Supply Contract': 'Lumber Supply Contract',
        'Business Plan': 'Business Plan',
        'List of Employees': 'List of Employees',
        'Income Tax Return': 'Income Tax Return',
        'Audited Financial Statement': 'Audited Financial Statement',
        'Certificate of Bank': 'Certificate of Bank',
        'Previous Certificate of Registration':
            'Previous Certificate of Registration',
        'Certificate of Registration(DTI or SEC)':
            'Certificate of Registration(DTI or SEC)',
        'Certification of Non-Coverage': 'Certification of Non-Coverage',
        'Annual Report of Lumber': 'Annual Report of Lumber',
        'Inventory of Lumber Stocks': 'Inventory of Lumber Stocks',
      };

      // Set root metadata
      await FirebaseFirestore.instance
          .collection('lumber_registration')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'client': clientName,
            'address': clientAddress,
            'status': 'Pending',
            'userID': FirebaseAuth.instance.currentUser!.uid,
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

            'status': 'Pending',
          });

      // Upload each file
      for (var entry in files.entries) {
        String label = entry.key;
        File file = entry.value;

        String fileExtension = path.extension(file.path).toLowerCase();
        String base64File = await _convertFileToBase64(file);

        await FirebaseFirestore.instance
            .collection('lumber_registration')
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
    if (dulyAccomplishForm != null) {
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
        Map<String, File> filesToUpload = {
          'Duly Accomplish Application Form': dulyAccomplishForm!,
          'Pictures of Establishment': picture!,
        };

        if (permitEngage != null) {
          filesToUpload['Permit to Engage'] = permitEngage!;
        }
        if (lumberContract != null) {
          filesToUpload['Lumber Supply Contract'] = lumberContract!;
        }
        if (businessPlan != null) {
          filesToUpload['Business Plan'] = businessPlan!;
        }
        if (listEmployees != null) {
          filesToUpload['List of Employees'] = listEmployees!;
        }
        if (incomeTax != null) {
          filesToUpload['Income Tax Return'] = incomeTax!;
        }
        if (financialStatement != null) {
          filesToUpload['Audited Financial Statement'] = financialStatement!;
        }
        if (certBank != null) {
          filesToUpload['Certificate of Bank'] = certBank!;
        }
        if (prevCert != null) {
          filesToUpload['Previous Certificate of Registration'] = prevCert!;
        }
        if (certRegistration != null) {
          filesToUpload['Certificate of Registration(DTI or SEC)'] =
              certRegistration!;
        }
        if (certNonCoverage != null) {
          filesToUpload['Certification of Non-Coverage'] = certNonCoverage!;
        }
        if (reportLumber != null) {
          filesToUpload['Annual Report of Lumber'] = reportLumber!;
        }
        if (inventory != null) {
          filesToUpload['Inventory of Lumber Stocks'] = inventory!;
        }

        await _uploadFiles(filesToUpload);
      }
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
          'Lumber Registration',
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
                  '1. Application Form (Duly Accomplished)',
                  dulyAccomplishForm,
                  (file) => setState(() => dulyAccomplishForm = file),
                ),
                _buildFilePicker(
                  '2. Pictures of the establishment/lumber yard;',
                  picture,
                  (file) => setState(() => picture = file),
                ),
                _buildFilePicker(
                  '3. Permit to Engage in business issued by City Mayor;',
                  permitEngage,
                  (file) => setState(() => permitEngage = file),
                ),
                _buildFilePicker(
                  '4. Lumber Supply Contract; ',
                  lumberContract,
                  (file) => setState(() => lumberContract = file),
                ),
                _buildFilePicker(
                  '5. Business Plan/Program;',
                  businessPlan,
                  (file) => setState(() => businessPlan = file),
                ),
                _buildFilePicker(
                  '6. List of Employees, position and salaries;',
                  listEmployees,
                  (file) => setState(() => listEmployees = file),
                ),
                _buildFilePicker(
                  '7. Income Tax Return;',
                  incomeTax,
                  (file) => setState(() => incomeTax = file),
                ),
                _buildFilePicker(
                  '8. Audited Financial Statement',
                  financialStatement,
                  (file) => setState(() => financialStatement = file),
                ),
                _buildFilePicker(
                  '9. Certificate of Bank with available account intended for the business (photocopy);',
                  businessPlan,
                  (file) => setState(() => businessPlan = file),
                ),
                _buildFilePicker(
                  '10. Previous Certificate of registration as Lumber Dealer (photocopy);',
                  prevCert,
                  (file) => setState(() => prevCert = file),
                ),
                _buildFilePicker(
                  '11. Certificate of Registration of Business name issued by DTI/SEC;',
                  certRegistration,
                  (file) => setState(() => certRegistration = file),
                ),
                _buildFilePicker(
                  '12. Certification of Non-Coverage issued by EMB, DENR-CAR;',
                  certNonCoverage,
                  (file) => setState(() => certNonCoverage = file),
                ),
                _buildFilePicker(
                  '13. Annual Report of Lumber Purchases and Sales;',
                  reportLumber,
                  (file) => setState(() => reportLumber = file),
                ),
                _buildFilePicker(
                  '14. Inventory of Lumber Stocks;',
                  inventory,
                  (file) => setState(() => inventory = file),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Fees to be Paid',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFeeRow(
                  'Application, Permit,\nLicense, Oath Fee',
                  1116.00,
                ),
                _buildFeeRow('Application Fee', cashDeposit),

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
