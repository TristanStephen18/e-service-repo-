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

class AddLumber extends StatefulWidget {
  final String applicationId;

  const AddLumber({super.key, required this.applicationId});

  @override
  _AddLumberState createState() => _AddLumberState();
}

class _AddLumberState extends State<AddLumber> {
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
    if (picture != null) {
      filesToUpload['Pictures of Establishment'] = picture!;
    }
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
          'Lumber Registration',
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
                      'Pictures of Establishment',
                      'Permit to Engage',
                      'Lumber Supply Contract',
                      'Business Plan',
                      'List of Employees',
                      'Income Tax Return',
                      'Audited Financial Statement',
                      'Certificate of Bank',
                      'Previous Certificate of Registration',
                      'Certificate of Registration(DTI or SEC)',
                      'Certification of Non-Coverage',
                      'Annual Report of Lumber',
                      'Inventory of Lumber Stocks',
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
                          'Pictures of Establishment',
                        ))
                          _buildFilePicker(
                            '2. Pictures of the establishment/lumber yard;',
                            picture,
                            (file) => setState(() => picture = file),
                          ),

                        if (!uploadedLabels.contains('Permit to Engage'))
                          _buildFilePicker(
                            '3. Permit to Engage in business issued by City Mayor;',
                            permitEngage,
                            (file) => setState(() => permitEngage = file),
                          ),
                        if (!uploadedLabels.contains('Lumber Supply Contract'))
                          _buildFilePicker(
                            '4. Lumber Supply Contract; ',
                            lumberContract,
                            (file) => setState(() => lumberContract = file),
                          ),
                        if (!uploadedLabels.contains('Business Plan'))
                          _buildFilePicker(
                            '5. Business Plan/Program;',
                            businessPlan,
                            (file) => setState(() => businessPlan = file),
                          ),

                        if (!uploadedLabels.contains('List of Employees'))
                          _buildFilePicker(
                            '6. List of Employees, position and salaries;',
                            listEmployees,
                            (file) => setState(() => listEmployees = file),
                          ),

                        if (!uploadedLabels.contains('Income Tax Return'))
                          _buildFilePicker(
                            '7. Income Tax Return;',
                            incomeTax,
                            (file) => setState(() => incomeTax = file),
                          ),
                        if (!uploadedLabels.contains(
                          'Audited Financial Statement',
                        ))
                          _buildFilePicker(
                            '8. Audited Financial Statement',
                            financialStatement,
                            (file) => setState(() => financialStatement = file),
                          ),
                        if (!uploadedLabels.contains('Certificate of Bank'))
                          _buildFilePicker(
                            '9. Certificate of Bank with available account intended for the business (photocopy);',
                            businessPlan,
                            (file) => setState(() => businessPlan = file),
                          ),

                        if (!uploadedLabels.contains(
                          'Previous Certificate of Registration',
                        ))
                          _buildFilePicker(
                            '10. Previous Certificate of registration as Lumber Dealer (photocopy);',
                            prevCert,
                            (file) => setState(() => prevCert = file),
                          ),

                        if (!uploadedLabels.contains(
                          'Certificate of Registration(DTI or SEC)',
                        ))
                          _buildFilePicker(
                            '11. Certificate of Registration of Business name issued by DTI/SEC;',
                            certRegistration,
                            (file) => setState(() => certRegistration = file),
                          ),
                        if (!uploadedLabels.contains(
                          'Certification of Non-Coverage',
                        ))
                          _buildFilePicker(
                            '12. Certification of Non-Coverage issued by EMB, DENR-CAR;',
                            certNonCoverage,
                            (file) => setState(() => certNonCoverage = file),
                          ),
                        if (!uploadedLabels.contains('Annual Report of Lumber'))
                          _buildFilePicker(
                            '13. Annual Report of Lumber Purchases and Sales;',
                            reportLumber,
                            (file) => setState(() => reportLumber = file),
                          ),

                        if (!uploadedLabels.contains(
                          'Inventory of Lumber Stocks',
                        ))
                          _buildFilePicker(
                            '14. Inventory of Lumber Stocks;',
                            inventory,
                            (file) => setState(() => inventory = file),
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
