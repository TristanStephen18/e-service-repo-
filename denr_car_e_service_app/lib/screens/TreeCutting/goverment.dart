// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:denr_car_e_service_app/screens/Home/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart' as path;

class GovermentScreen extends StatefulWidget {
  final LatLng geoP;
  final String address;
  final String polygonName;
  const GovermentScreen({
    super.key,
    required this.address,
    required this.geoP,
    required this.polygonName,
  });

  @override
  State<GovermentScreen> createState() => _GovermentScreenState();
}

class _GovermentScreenState extends State<GovermentScreen> {
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

  // Pick file method
  Future<void> _pickFile(String label, Function(File) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
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
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('tree_cutting')
            .orderBy('uploadedAt', descending: true) // Get latest uploads first
            .limit(1) // Only check the latest document
            .get();

    int latestNumber = 0;

    if (querySnapshot.docs.isNotEmpty) {
      String lastDocId = querySnapshot.docs.first.id;
      RegExp regExp = RegExp(r'TC-\d{4}-\d{2}-\d{2}-(\d{4})');
      Match? match = regExp.firstMatch(lastDocId);
      if (match != null) {
        latestNumber = int.parse(match.group(1)!);
      }
    }

    String today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    String newNumber = (latestNumber + 1).toString().padLeft(4, '0');

    return 'TC-$today-$newNumber';
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

      // Set root metadata
      await FirebaseFirestore.instance
          .collection('tree_cutting')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'client': clientName,
            'address': clientAddress,
            'status': 'Pending',
            'userID': FirebaseAuth.instance.currentUser!.uid,
            'type': 'National Agencies Government Permit',
            'current_location': 'RPU - For Evaluation',
            'location': GeoPoint(widget.geoP.latitude, widget.geoP.longitude),
            'tcp_location': widget.address,
            'pamb': widget.polygonName,
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
            'type': 'National Government Agencies',
            'status': 'Pending',
          });

      // Upload each file
      for (var entry in files.entries) {
        String label = entry.key;
        File file = entry.value;

        String fileExtension = path.extension(file.path).toLowerCase();
        String base64File = await _convertFileToBase64(file);

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
    if (applicationLetter != null && lguEndorsement != null) {
      Map<String, File> filesToUpload = {
        'Duly Accomplish Application Form': applicationLetter!,
        'LGU Endorsement or Certification': lguEndorsement!,
      };

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
      appBar: AppBar(
        title: const Text('National Government Agencies'),
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
                  '1. Application Letter (1 original Copy)\n'
                  '\t\t\t Address: Engr. Leandro L. De Jesus\n'
                  '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tCENRO Officer\n'
                  '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tCENRO Baguio',
                  applicationLetter,
                  (file) => setState(() => applicationLetter = file),
                ),
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
                _buildFilePicker(
                  '3. Approved Site Development Plan/Infrastructure Plan with Tree Charting indicating the geotagged location of individual trees affected by the project, to be numbered sequentially, as basis of validation by the DENR during actual cutting operations(1 certified copy);',
                  siteDevelopment,
                  (file) => setState(() => siteDevelopment = file),
                ),
                _buildFilePicker(
                  '4. Environmental Compliance Certificate (ECC) / Certificate of Non-Coverage (CNC), whichever is applicable, issued by EMB (1certified true copy);',
                  ecc,
                  (file) => setState(() => ecc = file),
                ),
                _buildFilePicker(
                  '5. NCIP Clearance (FPIC/CP/CNO, whichever is applicable);',
                  ncip,
                  (file) => setState(() => ncip = file),
                ),
                _buildFilePicker(
                  '6. Waiver/Consent of owner/s, if titled property, if applicable (1 original);',
                  waiver,
                  (file) => setState(() => waiver = file),
                ),
                _buildFilePicker(
                  '7. Protected Area Management Board (PAMB) Clearance/Certification\n'
                  '\t\t\t a. Lower Agno Watershed Forest Reserve (LAWFR)\n'
                  '\t\t\t b. Marcos Highway Watershed Forest Reserve (MHWFR)\n'
                  '\t\t\t c. Mount Pulag Protected Landscape (MPPL)\n'
                  '\t\t\t d. Upper Agno River Basin Resource Reserve (UARBRR)',
                  pambClearance,
                  (file) => setState(() => pambClearance = file),
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
                  '8. Photos of the trees to be cut',
                  photo,
                  (file) => setState(() => photo = file),
                ),
                _buildFilePicker(
                  '9. Others:',
                  others,
                  (file) => setState(() => others = file),
                ),

                const SizedBox(height: 32),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
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
