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
  File? certPublicSafetyScreen;

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
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance
              .collection('mobile_users')
              .doc(userId)
              .get();

      String clientName = userSnapshot.get('name') ?? 'Unknown Client';
      String clientAddress = userSnapshot.get('address') ?? 'Unknown Address';
      String documentId = await _generateDocumentId();

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
            'type': 'Chainsaw Registration',

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
    if (dulyAccomplishForm != null && chainsawReciept != null) {
      Map<String, File> filesToUpload = {
        'accomplishForm': dulyAccomplishForm!,
        'chainsawReciept': chainsawReciept!,
      };

      if (spa != null) {
        filesToUpload['spa'] = spa!;
      }
      if (chainsawSpec != null) {
        filesToUpload['chainsawSpec'] = chainsawSpec!;
      }
      if (deedofSale != null) {
        filesToUpload['deedofSale'] = deedofSale!;
      }
      if (regChainsaw != null) {
        filesToUpload['regChainsaw'] = regChainsaw!;
      }
      if (forestTenure != null) {
        filesToUpload['forestTenure'] = forestTenure!;
      }
      if (businessPermit != null) {
        filesToUpload['businessPermit'] = businessPermit!;
      }
      if (certRegistration != null) {
        filesToUpload['certRegistration'] = certRegistration!;
      }
      if (permitAffidavit != null) {
        filesToUpload['permitAffidavit'] = permitAffidavit!;
      }
      if (plantPermit != null) {
        filesToUpload['plantPermit'] = plantPermit!;
      }
      if (headOffice != null) {
        filesToUpload['headOffice'] = headOffice!;
      }
      if (certPublicSafetyScreen != null) {
        filesToUpload['certPublicSafetyScreen'] = certPublicSafetyScreen!;
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
                _buildFilePicker(
                  '4. Detailed Specification of Chainsaw (e.g. brand, model, engine capacity, etc.);',
                  chainsawSpec,
                  (file) => setState(() => chainsawSpec = file),
                ),
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
                  deedofSale,
                  (file) => setState(() => deedofSale = file),
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
                  certPublicSafetyScreen,
                  (file) => setState(() => certPublicSafetyScreen = file),
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
