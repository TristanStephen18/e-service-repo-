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

class AddLumberDealershipRenewal extends StatefulWidget {
  final String applicationId;

  const AddLumberDealershipRenewal({super.key, required this.applicationId});

  @override
  _AddLumberDealershipRenewalState createState() =>
      _AddLumberDealershipRenewalState();
}

class _AddLumberDealershipRenewalState
    extends State<AddLumberDealershipRenewal> {
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
        await FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('applications')
            .doc(documentId)
            .update({'status': 'Pending'});

        // Set root metadata
        await FirebaseFirestore.instance
            .collection('processing')
            .doc(documentId)
            .update({
              'status': 'Pending',

              'current_location': 'RPU - For Evaluation',
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
        title: const Text('Charcoal', style: TextStyle(color: Colors.white)),
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
                      'Registration To Import',
                      'Permit To Engage',
                      'Supply Contract',
                      'Business Plan',
                      'Import Documents',
                      'Income Tax Return',

                      'Forestry Bonds',
                      'Articles of Partnership',

                      'Business Name',

                      'Mayors Permit',
                      'Certification of Adequate Cash',
                      'Pole Supply Contract',
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
                            '1. Letter application or duly accomplished Application Form filled-up by the applicant',
                            dulyAccomplishForm,
                            (file) => setState(() => dulyAccomplishForm = file),
                          ),

                        if (!uploadedLabels.contains('Registration To Import'))
                          _buildFilePicker(
                            '2. Authenticated copy of Registration to import logs, lumber, veneer or commercial poles and piles',
                            registrationImport,
                            (file) => setState(() => registrationImport = file),
                          ),

                        if (!uploadedLabels.contains('Supply Contract'))
                          _buildFilePicker(
                            '3. Approved Log / Lumber Supply Contract or Invoice Receipt (1 photocopy)',
                            supplyContract,
                            (file) => setState(() => supplyContract = file),
                          ),

                        if (!uploadedLabels.contains('Import Documents'))
                          _buildFilePicker(
                            '4. Authenticated copies of import documents covering the imported commodities',
                            importDocs,
                            (file) => setState(() => importDocs = file),
                          ),

                        if (!uploadedLabels.contains('Forestry Bonds'))
                          _buildFilePicker(
                            '5. Forestry Bond (Specifying permit applied for) either Cash P1000.00 or Surety Bond P1,250.00',
                            forestryBonds,
                            (file) => setState(() => forestryBonds = file),
                          ),

                        if (!uploadedLabels.contains('Articles of Partnership'))
                          _buildFilePicker(
                            '6. Articles of Partnership or Incorporation duly registered with the SEC if application is filed by partnership, corporation or association',
                            partnership,
                            (file) => setState(() => partnership = file),
                          ),

                        if (!uploadedLabels.contains('Business Name'))
                          _buildFilePicker(
                            '7. Certified copy or xerox copy of Business Name or Trade Name duly registered with the Department of Trade and Industry (DTI) if applicant is using a trade name',
                            businessName,
                            (file) => setState(() => businessName = file),
                          ),

                        if (!uploadedLabels.contains('Mayors Permit'))
                          _buildFilePicker(
                            '8. Mayors permit together with a certification from the city or municipal treasurer stating that the operation of the intended business does not violate any existing ordinance of said municipality/city',
                            mayorsPermit,
                            (file) => setState(() => mayorsPermit = file),
                          ),

                        if (!uploadedLabels.contains('Income Tax Return'))
                          _buildFilePicker(
                            '9. Copy of Annual Income Tax Return for the last two (2) years (Individual or Corporate Annual Income Tax Return), if applicable',
                            incomeTax,
                            (file) => setState(() => incomeTax = file),
                          ),

                        if (!uploadedLabels.contains(
                          'Certification of Adequate Cash',
                        ))
                          _buildFilePicker(
                            '10. Certification of adequate cash capital deposit from a bank and affidavit of the applicant stating that said deposit shall be used solely for the intended business',
                            adequateCash,
                            (file) => setState(() => adequateCash = file),
                          ),

                        if (!uploadedLabels.contains('Permit To Engage'))
                          _buildFilePicker(
                            '11. Permit to engage in business (if applicant is a foreigner)',
                            permitEngage,
                            (file) => setState(() => permitEngage = file),
                          ),

                        if (!uploadedLabels.contains('Business Plan'))
                          _buildFilePicker(
                            '12. Business Plan',
                            businessPlan,
                            (file) => setState(() => businessPlan = file),
                          ),

                        if (!uploadedLabels.contains('Pole Supply Contract'))
                          _buildFilePicker(
                            '13. Log/Lumber/Pole Supply Contract with legitimate sawmill operator/timber concessionaires',
                            log,
                            (file) => setState(() => log = file),
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
