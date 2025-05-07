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

class ChainsawRenewal extends StatefulWidget {
  final String type;
  const ChainsawRenewal({super.key, required this.type});

  @override
  State<ChainsawRenewal> createState() => _ChainsawRenewalState();
}

class _ChainsawRenewalState extends State<ChainsawRenewal> {
  final _formKey = GlobalKey<FormState>();

  File? dulyAccomplishForm;
  File? chainsawReciept;
  File? spa;
  File? chainsawSpec;
  File? deedofSale;
  File? regChainsaw;

  File? forestTenure;
  File? businessPermit;
  File? certRegistration;
  File? permitAffidavit;
  File? plantPermit;
  File? headOffice;
  File? certChainsawRenewal;

  String serialNumber = '';
  String brand = '';
  String model = '';
  String engineCapacity = '';
  String guideBar = '';
  String countryOfOrigin = '';
  String purposeOfUse = '';
  String nameOfDealer = '';
  DateTime? dateOfPurchase;

  final double registrationFee = 500.00;

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
            .collection('chainsaw')
            .orderBy('uploadedAt', descending: true) // Get latest uploads first
            .limit(1) // Only check the latest document
            .get();

    int latestNumber = 0;

    if (querySnapshot.docs.isNotEmpty) {
      String lastDocId = querySnapshot.docs.first.id;
      RegExp regExp = RegExp(r'CH-\d{4}-\d{2}-\d{2}-(\d{4})');
      Match? match = regExp.firstMatch(lastDocId);
      if (match != null) {
        latestNumber = int.parse(match.group(1)!);
      }
    }

    String today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    String newNumber = (latestNumber + 1).toString().padLeft(4, '0');

    return 'CH-$today-$newNumber';
  }

  Future<void> saveChainsawDetails(String documentId) async {
    try {
      // Ensure the documentId is valid and we have a user logged in
      if (FirebaseAuth.instance.currentUser != null) {
        // Prepare data to be stored
        Map<String, dynamic> chainsawDetails = {
          'Serial Number': serialNumber,
          'Brand': brand,
          'Model': model,
          'Engine Capacity': engineCapacity,
          'Guide Bar': guideBar,
          'Country of Origin': countryOfOrigin,
          'Purpose of Use': purposeOfUse,
          'Name of Dealer': nameOfDealer,
          'Date of Purchase':
              dateOfPurchase != null
                  ? Timestamp.fromDate(dateOfPurchase!)
                  : Timestamp.now(), // Use current timestamp if null
        };

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('applications')
            .doc(documentId)
            .collection('requirements')
            .doc('Chainsaw Details')
            .set(chainsawDetails);

        await FirebaseFirestore.instance
            .collection('chainsaw')
            .doc(documentId)
            .collection('requirements')
            .doc('Chainsaw Details')
            .set(chainsawDetails);

        // Optionally, show a confirmation message or feedback
        print('Chainsaw details saved successfully!');
      } else {
        print('User is not logged in');
      }
    } catch (e) {
      // Handle errors gracefully
      print('Error saving chainsaw details: $e');
    }
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
        'Reciept of Chainsaw Purchase': 'Reciept of Chainsaw Purchase',
        'SPA': 'SPA',
        'Specification of Chainsaw': 'Specification of Chainsaw',
        'Deed of Sale': 'Deed of Sale',
        'Chainsaw': 'Chainsaw',
        'Forest Tenure Agreement': 'Forest Tenure Agreement',
        'Business Permit': 'Business Permit',
        'Certificate of Registration': 'Certificate of Registration',
        'Affidavit or Permit from LGU': 'Affidavit or Permit from LGU',
        'Plant Permit': 'Plant Permit',
        'Certification of Head Office': 'Certification of Head Office',
        'Certificate of Chainsaw Registration':
            'Certificate of Chainsaw Registration',
      };

      // Set root metadata
      await FirebaseFirestore.instance
          .collection('chainsaw')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'client': clientName,
            'address': clientAddress,
            'status': 'Pending',
            'userID': FirebaseAuth.instance.currentUser!.uid,
            'type': 'Chainsaw Registration',
            'chainsaw_type': widget.type,
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
            'type': 'Chainsaw Registration',
            'chainsaw_type': widget.type,
            'status': 'Pending',
          });

      // Upload each file
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
      saveChainsawDetails(documentId);

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
                  Navigator.of(context).pop();
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
    if (chainsawReciept != null) {
      filesToUpload['Reciept of Chainsaw Purchase'] = chainsawReciept!;
    }

    if (spa != null) {
      filesToUpload['SPA'] = spa!;
    }
    if (chainsawSpec != null) {
      filesToUpload['Specification of Chainsaw'] = chainsawSpec!;
    }
    if (deedofSale != null) {
      filesToUpload['Deed of Sale'] = deedofSale!;
    }
    if (regChainsaw != null) {
      filesToUpload['Chainsaw Registration'] = regChainsaw!;
    }
    if (certChainsawRenewal != null) {
      filesToUpload['Certificate of Chainsaw Registration'] =
          certChainsawRenewal!;
    }

    if (forestTenure != null) {
      filesToUpload['Forest Tenure Agreement'] = forestTenure!;
    }
    if (businessPermit != null) {
      filesToUpload['Business Permit'] = businessPermit!;
    }
    if (certRegistration != null) {
      filesToUpload['Certificate of Registration'] = certRegistration!;
    }
    if (permitAffidavit != null) {
      filesToUpload['Affidavit or Permit from LGU'] = permitAffidavit!;
    }
    if (plantPermit != null) {
      filesToUpload['Plant Permit'] = plantPermit!;
    }
    if (headOffice != null) {
      filesToUpload['Certification of Head Office'] = headOffice!;
    }
    if (certChainsawRenewal != null) {
      filesToUpload['Certificate of Chainsaw Registration'] =
          certChainsawRenewal!;
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
          'Renewal',
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
                  '1. Duly Accomplish Application Form',
                  dulyAccomplishForm,
                  (file) => setState(() => dulyAccomplishForm = file),
                ),
                _buildFilePicker(
                  '2. Official Receipt of Chainsaw Purchase (1 certified copy and 1 original for verification) '
                  'or Affidavit of ownership in case the original copy is lost;',
                  chainsawReciept,
                  (file) => setState(() => chainsawReciept = file),
                ),
                _buildFilePicker(
                  '3. SPA if the applicant is not the owner of the chainsaw;',
                  spa,
                  (file) => setState(() => spa = file),
                ),

                const Text('4. Chainsaw Specifications'),
                const SizedBox(height: 14),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Serial Number',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => serialNumber = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => brand = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => model = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Engine Capacity',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => engineCapacity = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Guide Bar',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => guideBar = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Country of Origin',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => countryOfOrigin = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Purpose of Use',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => purposeOfUse = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name of Dealer',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) => nameOfDealer = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Date of Purchase',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: dateOfPurchase ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        dateOfPurchase = selectedDate;
                      });
                    }
                  },
                  controller: TextEditingController(
                    text:
                        dateOfPurchase != null
                            ? '${dateOfPurchase!.toLocal()}'.split(' ')[0]
                            : '',
                  ),
                ),
                const SizedBox(height: 10),
                _buildFilePicker(
                  '5. Notarized Deed of Absolute Sale, if transfer of ownership (1 original);',
                  deedofSale,
                  (file) => setState(() => deedofSale = file),
                ),
                _buildFilePicker(
                  '6. Chainsaw to be registered',
                  regChainsaw,
                  (file) => setState(() => regChainsaw = file),
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
                  '7. Certified True Copy of Forest Tenure Agreement, if Tenure Instrument Holder;',
                  forestTenure,
                  (file) => setState(() => forestTenure = file),
                ),
                _buildFilePicker(
                  '8. Business Permit (1 photocopy), if business owner;',
                  businessPermit,
                  (file) => setState(() => businessPermit = file),
                ),
                _buildFilePicker(
                  '9. Certificate of Registration, if registered as PTPR;',
                  certRegistration,
                  (file) => setState(() => certRegistration = file),
                ),
                _buildFilePicker(
                  '10. Business Permit from LGU or affidavit that the chainsaw is needed in applications/profession/work'
                  ' and will be used for legal purpose (1 photocopy);',
                  permitAffidavit,
                  (file) => setState(() => permitAffidavit = file),
                ),
                _buildFilePicker(
                  '11. Wood processing plant permit (1 photocopy), if licensed wood processor;',
                  plantPermit,
                  (file) => setState(() => plantPermit = file),
                ),
                _buildFilePicker(
                  '12. Certification from the Head of Office or his/her authorized representative that chainsaws are owned/possessed'
                  ' by the office and use for legal purposes (specify), if government and GOCC;',
                  headOffice,
                  (file) => setState(() => headOffice = file),
                ),
                _buildFilePicker(
                  '13. Latest Certificate of Chainsaw Registration (1 photocopy), if renewal of registration',
                  certChainsawRenewal,
                  (file) => setState(() => certChainsawRenewal = file),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Fees to be Paid',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFeeRow('Registration Fee', registrationFee),

                const Divider(thickness: 1.2),
                _buildFeeRow('TOTAL', registrationFee, isTotal: true),
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
