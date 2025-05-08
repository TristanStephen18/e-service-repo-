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

class AddGovermentScreen extends StatefulWidget {
  final String applicationId;

  const AddGovermentScreen({super.key, required this.applicationId});

  @override
  _AddGovermentScreenState createState() => _AddGovermentScreenState();
}

class _AddGovermentScreenState extends State<AddGovermentScreen> {
  final _formKey = GlobalKey<FormState>();
  File? applicationLetter;
  File? lguEndorsement;
  File? ecc;
  File? siteDevelopment;

  File? waiver;
  File? pambClearance;
  File? others;
  File? ncip;
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
        'LGU Endorsement or Certification': 'LGU Endorsement or Certification',
        'Waiver': 'Waiver',
        'ECC': 'ECC',
        'Site Development Plan': 'Site Development Plan',
        'PAMB Clearance': 'PAMB Clearance',
        'NCIP Clearance': 'NCIP Clearance',
        'Photos of Trees': 'Photos of Trees',
        'Others': 'Others',
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

    if (waiver != null) {
      filesToUpload['Waiver'] = waiver!;
    }
    if (ecc != null) {
      filesToUpload['ECC'] = ecc!;
    }
    if (siteDevelopment != null) {
      filesToUpload['Site Development Plan'] = siteDevelopment!;
    }
    if (pambClearance != null) {
      filesToUpload['PAMB Clearance'] = pambClearance!;
    }
    if (ncip != null) {
      filesToUpload['NCIP Clearance'] = ncip!;
    }
    if (photo != null) {
      filesToUpload['Photos of Trees'] = photo!;
    }

    if (others != null) {
      filesToUpload['Others'] = others!;
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
          'Private Land Timber',
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
                      'LGU Endorsement or Certification',
                      'Waiver',
                      'ECC',
                      'Site Development Plan',
                      'PAMB Clearance',
                      'NCIP Clearance',
                      'Photos of Trees',
                      'Others',
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
                            '2. Endorsement / Certification from the concerned LGU interposing no objection to the cutting of trees under the following conditions: (1 original)\n'
                            '\t\t\ta. If the trees to be cut falls within one barangay, an\n'
                            '\t\t\t  endorsement from Barangay Captain shall be\n'
                            '\t\t\t  secured\n'
                            '\t\t\tb. If the trees to be cut falls within more than one\n'
                            '\t\t\t  barangay, endorsement shall be secured either from\n'
                            '\t\t\t  the Municipal/City Mayor or all the Barangay\n'
                            '\t\t\t  Captains concerned\n'
                            '\t\t\tc. If the trees to be cut falls within more than one\n'
                            '\t\t\t  municipality/city, endorsement shall be secured\n'
                            '\t\t\t  either from the Provincial Governor or all the\n'
                            '\t\t\t  Municipal/City Mayors concerned\n'
                            '\t\t\td. If within Baguio City, Clearance from the City\n'
                            '\t\t\t  Environment and Parks Management Office\n'
                            '\t\t\t  (CEPMO)',

                            lguEndorsement,
                            (file) => setState(() => lguEndorsement = file),
                          ),
                        if (!uploadedLabels.contains('Site Development Plan'))
                          _buildFilePicker(
                            '3. Approved Site Development Plan/Infrastructure Plan with Tree Charting indicating the geotagged location of individual trees affected by the project, to be numbered sequentially, as basis of validation by the DENR during actual cutting operations(1 certified copy);',
                            siteDevelopment,
                            (file) => setState(() => siteDevelopment = file),
                          ),

                        if (!uploadedLabels.contains('ECC'))
                          _buildFilePicker(
                            '4. Environmental Compliance Certificate (ECC) / Certificate of Non-Coverage (CNC), whichever is applicable, issued by EMB (1certified true copy);',
                            ecc,
                            (file) => setState(() => ecc = file),
                          ),
                        if (!uploadedLabels.contains('NCIP Clearance'))
                          _buildFilePicker(
                            '5. NCIP Clearance (FPIC/CP/CNO, whichever is applicable);',
                            ncip,
                            (file) => setState(() => ncip = file),
                          ),

                        if (!uploadedLabels.contains('Waiver'))
                          _buildFilePicker(
                            '6. Waiver/Consent of owner/s, if titled property, if applicable (1 original);',
                            waiver,
                            (file) => setState(() => waiver = file),
                          ),

                        if (!uploadedLabels.contains('PAMB Clearance'))
                          _buildFilePicker(
                            '7. Protected Area Management Board (PAMB) Clearance/Certification\n'
                            '\t\t\t a. Lower Agno Watershed Forest Reserve (LAWFR)\n'
                            '\t\t\t b. Marcos Highway Watershed Forest Reserve (MHWFR)\n'
                            '\t\t\t c. Mount Pulag Protected Landscape (MPPL)\n'
                            '\t\t\t d. Upper Agno River Basin Resource Reserve (UARBRR)',
                            pambClearance,
                            (file) => setState(() => pambClearance = file),
                          ),
                        if (!uploadedLabels.contains('Photos of Trees'))
                          _buildFilePicker(
                            '8. Photos of the trees to be cut',
                            photo,
                            (file) => setState(() => photo = file),
                          ),

                        if (!uploadedLabels.contains('Others'))
                          _buildFilePicker(
                            '9. Others:',
                            others,
                            (file) => setState(() => others = file),
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
