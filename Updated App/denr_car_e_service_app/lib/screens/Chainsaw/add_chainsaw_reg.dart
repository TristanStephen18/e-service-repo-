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

class AddChainsawReg extends StatefulWidget {
  final String applicationId;

  const AddChainsawReg({super.key, required this.applicationId});

  @override
  _AddChainsawRegState createState() => _AddChainsawRegState();
}

class _AddChainsawRegState extends State<AddChainsawReg> {
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
  File? certChainsawReg;

  Set<String> uploadedLabels = {};

  @override
  void initState() {
    super.initState();
    _loadUploadedFiles();
  }

  Future<void> _loadUploadedFiles() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference applicationRef = FirebaseFirestore.instance
        .collection('mobile_users')
        .doc(userId)
        .collection('applications')
        .doc(widget.applicationId);

    QuerySnapshot existingFiles =
        await applicationRef.collection('requirements').get();

    setState(() {
      uploadedLabels = existingFiles.docs.map((doc) => doc.id).toSet();
    });
  }

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
      String documentId = widget.applicationId;

      DocumentReference applicationRef = FirebaseFirestore.instance
          .collection('mobile_users')
          .doc(userId)
          .collection('applications')
          .doc(documentId);

      DocumentSnapshot applicationSnapshot = await applicationRef.get();

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
                  Navigator.of(context).pushReplacement(
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
    if (certChainsawReg != null) {
      filesToUpload['Certificate of Chainsaw Registration'] = certChainsawReg!;
    }

    if (filesToUpload.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Missing Files'),
            content: const Text('Please attach required files.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }

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
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chainsaw Registration',
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
            child:
                uploadedLabels.containsAll([
                      'Duly Accomplish Application Form',
                      'Reciept of Chainsaw Purchase',
                      'SPA',
                      'Specification of Chainsaw',
                      'Deed of Sale',
                      'Chainsaw',
                      'Forest Tenure Agreement',
                      'Business Permit',
                      'Certificate of Registration',
                      'Affidavit or Permit from LGU',
                      'Plant Permit',
                      'Certification of Head Office',
                      'Certificate of Chainsaw Registration',
                    ])
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 200),
                        child: Text(
                          "All documents have been successfully uploaded.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Additional Requirements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (!uploadedLabels.contains(
                          'Duly Accomplish Application Form',
                        ))
                          _buildFilePicker(
                            '1. Application Form (Duly Accomplished)',
                            dulyAccomplishForm,
                            (file) => setState(() => dulyAccomplishForm = file),
                          ),

                        if (!uploadedLabels.contains(
                          'Reciept of Chainsaw Purchase',
                        ))
                          _buildFilePicker(
                            '2. Official Receipt of Chainsaw Purchase (1 certified copy and 1 original for verification) '
                            'or Affidavit of ownership in case the original copy is lost;',
                            chainsawReciept,
                            (file) => setState(() => chainsawReciept = file),
                          ),

                        if (!uploadedLabels.contains('SPA'))
                          _buildFilePicker(
                            '3. SPA if the applicant is not the owner of the chainsaw;',
                            spa,
                            (file) => setState(() => spa = file),
                          ),
                        if (!uploadedLabels.contains(
                          'Specification of Chainsaw',
                        ))
                          _buildFilePicker(
                            '4. Detailed Specification of Chainsaw (e.g. brand, model, engine capacity, etc.);',
                            chainsawSpec,
                            (file) => setState(() => chainsawSpec = file),
                          ),
                        if (!uploadedLabels.contains('Deed of Sale'))
                          _buildFilePicker(
                            '5. Notarized Deed of Absolute Sale, if transfer of ownership (1 original);',
                            deedofSale,
                            (file) => setState(() => deedofSale = file),
                          ),

                        if (!uploadedLabels.contains('Chainsaw'))
                          _buildFilePicker(
                            '6. Chainsaw to be registered',
                            regChainsaw,
                            (file) => setState(() => regChainsaw = file),
                          ),

                        if (!uploadedLabels.contains('Forest Tenure Agreement'))
                          _buildFilePicker(
                            '7. Certified True Copy of Forest Tenure Agreement, if Tenure Instrument Holder;',
                            forestTenure,
                            (file) => setState(() => forestTenure = file),
                          ),
                        if (!uploadedLabels.contains('Business Permit'))
                          _buildFilePicker(
                            '8. Business Permit (1 photocopy), if business owner;',
                            businessPermit,
                            (file) => setState(() => businessPermit = file),
                          ),
                        if (!uploadedLabels.contains(
                          'Certificate of Registration',
                        ))
                          _buildFilePicker(
                            '9. Certificate of Registration, if registered as PTPR;',
                            deedofSale,
                            (file) => setState(() => deedofSale = file),
                          ),

                        if (!uploadedLabels.contains(
                          'Affidavit or Permit from LGU',
                        ))
                          _buildFilePicker(
                            '10. Business Permit from LGU or affidavit that the chainsaw is needed in applications/profession/work'
                            ' and will be used for legal purpose (1 photocopy);',
                            permitAffidavit,
                            (file) => setState(() => permitAffidavit = file),
                          ),

                        if (!uploadedLabels.contains('Plant Permit'))
                          _buildFilePicker(
                            '11. Wood processing plant permit (1 photocopy), if licensed wood processor;',
                            plantPermit,
                            (file) => setState(() => plantPermit = file),
                          ),
                        if (!uploadedLabels.contains(
                          'Certification of Head Office',
                        ))
                          _buildFilePicker(
                            '12. Certification from the Head of Office or his/her authorized representative that chainsaws are owned/possessed'
                            ' by the office and use for legal purposes (specify), if government and GOCC;',
                            headOffice,
                            (file) => setState(() => headOffice = file),
                          ),
                        if (!uploadedLabels.contains(
                          'Certificate of Chainsaw Registration',
                        ))
                          _buildFilePicker(
                            '13. Latest Certificate of Chainsaw Registration (1 photocopy), if renewal of registration',
                            certChainsawReg,
                            (file) => setState(() => certChainsawReg = file),
                          ),

                        const SizedBox(height: 15),

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
