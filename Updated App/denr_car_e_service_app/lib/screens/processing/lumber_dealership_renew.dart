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

class LumberDealershipRenew extends StatefulWidget {
  final String type;
  const LumberDealershipRenew({super.key, required this.type});

  @override
  State<LumberDealershipRenew> createState() => _LumberDealershipRenewState();
}

class _LumberDealershipRenewState extends State<LumberDealershipRenew> {
  final _formKey = GlobalKey<FormState>();

  File? dulyAccomplishForm;
  File? registrationImport;
  File? supplyContract;
  File? importDocs;
  File? forestryBonds;
  File? partnership;

  File? businessName;
  File? mayorsPermit;
  File? incomeTax;
  File? adequateCash;
  File? permitEngage;
  File? businessPlan;
  File? log;

  final double registrationFee = 480.00;
  final double oathFee = 36.00;

  double get totalFee => 600.00 + registrationFee + oathFee;

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
            .collection('processing')
            .orderBy('uploadedAt', descending: true) // Get latest uploads first
            .limit(1) // Only check the latest document
            .get();

    int latestNumber = 0;

    if (querySnapshot.docs.isNotEmpty) {
      String lastDocId = querySnapshot.docs.first.id;
      RegExp regExp = RegExp(r'PR-\d{4}-\d{2}-\d{2}-(\d{4})');
      Match? match = regExp.firstMatch(lastDocId);
      if (match != null) {
        latestNumber = int.parse(match.group(1)!);
      }
    }

    String today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    String newNumber = (latestNumber + 1).toString().padLeft(4, '0');

    return 'PR-$today-$newNumber';
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
        'Registration To Import': 'Registration To Import',
        'Permit To Engage': 'Permit To Engage',
        'Supply Contract': 'Supply Contract',
        'Business Plan': 'Business Plan',
        'Import Documents': 'Import Documents',
        'Income Tax Return': 'Income Tax Return',

        'Forestry Bonds': 'Forestry Bonds',
        'Articles of Partnership': 'Articles of Partnership',

        'Business Name': 'Business Name',

        'Mayors Permit': 'Mayors Permit',
        'Certification of Adequate Cash': 'Certification of Adequate Cash',
        'Pole Supply Contract': 'Pole Supply Contract',
      };

      // Set root metadata
      await FirebaseFirestore.instance
          .collection('processing')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'client': clientName,
            'address': clientAddress,
            'status': 'Pending',
            'userID': FirebaseAuth.instance.currentUser!.uid,
            'current_location': 'RPU - For Evaluation',
            'type': 'Lumber Dealership Permit (Renewal)',
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
            'type': 'Lumber Dealership Permit (Renewal)',

            'status': 'Pending',
          });

      // Upload each file
      for (var entry in files.entries) {
        String label = entry.key;
        File file = entry.value;

        String fileExtension = path.extension(file.path).toLowerCase();
        String base64File = await _convertFileToBase64(file);

        await FirebaseFirestore.instance
            .collection('processing')
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
    Map<String, File> filesToUpload = {};

    if (dulyAccomplishForm != null) {
      filesToUpload['Duly Accomplish Application Form'] = dulyAccomplishForm!;
    }
    if (registrationImport != null) {
      filesToUpload['Registration To Import'] = registrationImport!;
    }

    if (supplyContract != null) {
      filesToUpload['Supply Contract'] = supplyContract!;
    }
    if (importDocs != null) {
      filesToUpload['Import Documents'] = importDocs!;
    }
    if (forestryBonds != null) {
      filesToUpload['Forestry Bonds'] = forestryBonds!;
    }
    if (partnership != null) {
      filesToUpload['Articles of Partnership'] = partnership!;
    }
    if (businessName != null) {
      filesToUpload['Business Name'] = businessName!;
    }
    if (mayorsPermit != null) {
      filesToUpload['Mayors Permit'] = mayorsPermit!;
    }
    if (incomeTax != null) {
      filesToUpload['Income Tax Return'] = incomeTax!;
    }
    if (adequateCash != null) {
      filesToUpload['Certification of Adequate Cash'] = adequateCash!;
    }
    if (permitEngage != null) {
      filesToUpload['Permit To Engage'] = permitEngage!;
    }
    if (businessPlan != null) {
      filesToUpload['Business Plan'] = businessPlan!;
    }
    if (log != null) {
      filesToUpload['Pole Supply Contract'] = log!;
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
          'Lumber Dealership (Renewal)',
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
                  '1. Letter application or duly accomplished Application Form filled-up by the applicant',
                  dulyAccomplishForm,
                  (file) => setState(() => dulyAccomplishForm = file),
                ),
                _buildFilePicker(
                  '2. Authenticated copy of Registration to import logs, lumber, veneer or commercial poles and piles',
                  registrationImport,
                  (file) => setState(() => registrationImport = file),
                ),
                _buildFilePicker(
                  '3. Authenticated copy of sales/supply contract with a foreign exporter of said wood commodities sworn to by the local importer as a binding legal instrument',
                  supplyContract,
                  (file) => setState(() => supplyContract = file),
                ),
                _buildFilePicker(
                  '4. Authenticated copies of import documents covering the imported commodities',
                  importDocs,
                  (file) => setState(() => importDocs = file),
                ),
                _buildFilePicker(
                  '5. Forestry Bond (Specifying permit applied for) either Cash P1000.00 or Surety Bond P1,250.00',
                  forestryBonds,
                  (file) => setState(() => forestryBonds = file),
                ),
                _buildFilePicker(
                  '6. Articles of Partnership or Incorporation duly registered with the SEC if application is filed by partnership, corporation or association',
                  partnership,
                  (file) => setState(() => partnership = file),
                ),
                _buildFilePicker(
                  '7. Certified copy or xerox copy of Business Name or Trade Name duly registered with the Department of Trade and Industry (DTI) if applicant is using a trade name',
                  businessName,
                  (file) => setState(() => businessName = file),
                ),
                _buildFilePicker(
                  '8. Mayors permit together with a certification from the city or municipal treasurer stating that the operation of the intended business does not violate any existing ordinance of said municipality/city',
                  mayorsPermit,
                  (file) => setState(() => mayorsPermit = file),
                ),
                _buildFilePicker(
                  '9. Copy of Annual Income Tax Return for the last two (2) years (Individual or Corporate Annual Income Tax Return), if applicable',
                  incomeTax,
                  (file) => setState(() => incomeTax = file),
                ),
                _buildFilePicker(
                  '10. Certification of adequate cash capital deposit from a bank and affidavit of the applicant stating that said deposit shall be used solely for the intended business',
                  adequateCash,
                  (file) => setState(() => adequateCash = file),
                ),
                _buildFilePicker(
                  '11. Permit to engage in business (if applicant is a foreigner)',
                  permitEngage,
                  (file) => setState(() => permitEngage = file),
                ),
                _buildFilePicker(
                  '12. Business Plan',
                  businessPlan,
                  (file) => setState(() => businessPlan = file),
                ),
                _buildFilePicker(
                  '13. Log/Lumber/Pole Supply Contract with legitimate sawmill operator/timber concessionaires',
                  log,
                  (file) => setState(() => log = file),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Fees to be Paid',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFeeRow('Application Fee', 600.00),
                _buildFeeRow('Registration Fee', registrationFee),
                _buildFeeRow('Oath Fee', oathFee),

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
