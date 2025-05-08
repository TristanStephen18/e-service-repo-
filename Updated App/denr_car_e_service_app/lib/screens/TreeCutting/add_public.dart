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

class AddPublicSafetyScreen extends StatefulWidget {
  final String applicationId;

  const AddPublicSafetyScreen({super.key, required this.applicationId});

  @override
  _AddPublicSafetyScreenState createState() => _AddPublicSafetyScreenState();
}

class _AddPublicSafetyScreenState extends State<AddPublicSafetyScreen> {
  final _formKey = GlobalKey<FormState>();
  File? applicationLetter;
  File? lguEndorsement;
  File? resolution;
  File? ptaResolution;
  File? landTitle;
  File? pambClearance;

  File? spa;
  File? photo;

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
        'LGU Endorsement/Certification': 'LGU Endorsement/Certification',
        'Homeowners Resolution': 'Homeowners Resolution',
        'PTA Resolution': 'PTA Resolution',
        'Land Title': 'Land Title',
        'PAMB Clearance': 'PAMB Clearance',
        'SPA': 'SPA',
        'Photos of Trees': 'Photos of Trees',
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
            .collection('tree_cutting')
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
            .collection('tree_cutting')
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
    if (applicationLetter != null) {
      filesToUpload['Duly Accomplish Application Form'] = applicationLetter!;
    }
    if (lguEndorsement != null) {
      filesToUpload['LGU Endorsement or Certification'] = lguEndorsement!;
    }

    if (resolution != null) {
      filesToUpload['Homeowners Resolution'] = resolution!;
    }
    if (ptaResolution != null) {
      filesToUpload['PTA Resolution'] = ptaResolution!;
    }
    if (landTitle != null) {
      filesToUpload['Land Title'] = landTitle!;
    }
    if (pambClearance != null) {
      filesToUpload['PAMB Clearance'] = pambClearance!;
    }
    if (spa != null) {
      filesToUpload['SPA'] = spa!;
    }
    if (photo != null) {
      filesToUpload['Photos of Trees'] = photo!;
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
          'Public Safety',
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
                      'LGU Endorsement/Certification',
                      'Homeowners Resolution',
                      'PTA Resolution',
                      'Land Title',
                      'PAMB Clearance',
                      'SPA',
                      'Photos of Trees',
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
                            '1. Application Letter (1 original Copy)\n'
                            '\t\t\t Address: Engr. Leandro L. De Jesus\n'
                            '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tCENRO Officer\n'
                            '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tCENRO Baguio',
                            applicationLetter,
                            (file) => setState(() => applicationLetter = file),
                          ),

                        if (!uploadedLabels.contains(
                          'LGU Endorsement or Certification',
                        ))
                          _buildFilePicker(
                            '2. LGU Endorsement / Certification of No Objection / Resolution (1 original) - interposing no objection to the cutting of trees',
                            lguEndorsement,
                            (file) => setState(() => lguEndorsement = file),
                          ),

                        if (!uploadedLabels.contains('Homeowners Resolution'))
                          _buildFilePicker(
                            '3. Homeowners Resolution (1 original / 1 Certified True Copy), if within Subdivisions;',
                            resolution,
                            (file) => setState(() => resolution = file),
                          ),

                        if (!uploadedLabels.contains('PTA Resolution'))
                          _buildFilePicker(
                            '4. PTA Resolution or Resolution from any organized group of No Objection and reason for Cutting (1 original), if School/Organization;',
                            ptaResolution,
                            (file) => setState(() => ptaResolution = file),
                          ),
                        if (!uploadedLabels.contains('Land Title'))
                          _buildFilePicker(
                            '5. Authenticated copy of Land Title/CLOA issued by LRA or Registry of Deeds, whichever is applicable, if within private land;',
                            landTitle,
                            (file) => setState(() => landTitle = file),
                          ),

                        if (!uploadedLabels.contains('PAMB Clearance'))
                          _buildFilePicker(
                            '6. Protected Area Management Board (PAMB) Clearance/Certification\n'
                            '\t\t\t a. Lower Agno Watershed Forest Reserve (LAWFR)\n'
                            '\t\t\t b. Marcos Highway Watershed Forest Reserve (MHWFR)\n'
                            '\t\t\t c. Mount Pulag Protected Landscape (MPPL)\n'
                            '\t\t\t d. Upper Agno River Basin Resource Reserve (UARBRR)',
                            pambClearance,
                            (file) => setState(() => pambClearance = file),
                          ),

                        if (!uploadedLabels.contains('SPA'))
                          _buildFilePicker(
                            '7. Special Power of Attorney (SPA), if the applicant is not the owner of the title;',
                            spa,
                            (file) => setState(() => spa = file),
                          ),
                        if (!uploadedLabels.contains('Photos of Trees'))
                          _buildFilePicker(
                            '8. Photos of the trees to be cut',
                            photo,
                            (file) => setState(() => photo = file),
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
