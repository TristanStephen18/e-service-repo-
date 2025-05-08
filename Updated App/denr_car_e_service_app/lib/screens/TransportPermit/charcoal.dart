// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart' as path;

class Charcoal extends StatefulWidget {
  final LatLng startLocation;
  final LatLng destinationLocation;
  final String startAddress;
  final String destinationAddress;
  final String polygonName;
  final String name;
  final String description;
  final String weight;
  final String quantity;

  final String volume;
  final String nameofLoading;
  final String nameofConsignee;
  final String source;
  final String legal;
  final String conveyance;

  const Charcoal({
    super.key,
    required this.startAddress,
    required this.destinationAddress,
    required this.startLocation,
    required this.destinationLocation,
    required this.polygonName,
    required this.name,
    required this.description,
    required this.weight,
    required this.quantity,

    required this.volume,
    required this.nameofLoading,
    required this.nameofConsignee,
    required this.source,
    required this.conveyance,
    required this.legal,
  });

  @override
  _CharcoalState createState() => _CharcoalState();
}

class _CharcoalState extends State<Charcoal> {
  final _formKey = GlobalKey<FormState>();
  File? requestLetter;
  File? woodPermit;

  final double certificationFee = 50.00;
  final double oathFee = 36.00;
  final double authentication = 100.00;

  double get totalFee => certificationFee + oathFee + authentication;

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
    List<int> fileBytes = await file.readAsBytes();
    return base64Encode(fileBytes);
  }

  Future<String> _generateDocumentId() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance
            .collection('transport_permit')
            .orderBy('uploadedAt', descending: true)
            .limit(1)
            .get();

    int latestNumber = 0;

    if (querySnapshot.docs.isNotEmpty) {
      String lastDocId = querySnapshot.docs.first.id;
      RegExp regExp = RegExp(r'TP-\d{4}-\d{2}-\d{2}-(\d{4})');
      Match? match = regExp.firstMatch(lastDocId);
      if (match != null) {
        latestNumber = int.parse(match.group(1)!);
      }
    }

    String today = DateTime.now().toString().split(' ')[0];
    String newNumber = (latestNumber + 1).toString().padLeft(4, '0');

    return 'TP-$today-$newNumber';
  }

  Future<void> savewildlifeDetails(String documentId) async {
    try {
      // Ensure the documentId is valid and we have a user logged in
      if (FirebaseAuth.instance.currentUser != null) {
        // Prepare data to be stored
        Map<String, dynamic> wildlifeDetails = {
          'Name of Species': widget.name,
          'Description': widget.description,
          'Unit Weight Measure': widget.weight,
          'Quantity': widget.quantity,
          'Volume': widget.volume,
          'Name of Loading': widget.nameofLoading,
          'Name of Consignee': widget.nameofConsignee,
          'Source of Forest Products': widget.source,
          'Type of Conveyance': widget.conveyance,
        };

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('applications')
            .doc(documentId)
            .collection('requirements')
            .doc('Forest Products')
            .set(wildlifeDetails);

        await FirebaseFirestore.instance
            .collection('transport')
            .doc(documentId)
            .collection('requirements')
            .doc('Forest Products')
            .set(wildlifeDetails);
      } else {
        print('User is not logged in');
      }
    } catch (e) {
      // Handle errors gracefully
      print('Error saving chainsaw details: $e');
    }
  }

  Future<String?> _uploadFiles(Map<String, File> files) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                SizedBox(width: 16),
                Text('Uploading files...'),
              ],
            ),
          ),
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
        'Request Letter': 'Request Letter',
        'Wood Charcoal Production Permit': 'Wood Charcoal Production Permit',
      };

      await FirebaseFirestore.instance
          .collection('transport_permit')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'userID': userId,
            'status': 'Pending',
            'client': clientName,
            'current_location': 'RPU - For Evaluation',
            'address': clientAddress,
            'from': widget.startAddress,
            'to': widget.destinationAddress,
            'from_coordinates': GeoPoint(
              widget.startLocation.latitude,
              widget.startLocation.longitude,
            ),
            'to_coordinates': GeoPoint(
              widget.destinationLocation.latitude,
              widget.destinationLocation.longitude,
            ),
            'type': 'Forest Product',
            'legalSource': widget.legal,
          });

      for (var entry in files.entries) {
        String label = entry.key;
        File file = entry.value;
        String fileExtension = path.extension(file.path).toLowerCase();
        String base64File = await _convertFileToBase64(file);

        await FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(userId)
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

        await FirebaseFirestore.instance
            .collection('transport_permit')
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
          .doc(userId)
          .collection('applications')
          .doc(documentId)
          .set({
            'uploadedAt': Timestamp.now(),
            'userID': userId,
            'status': 'Pending',
            'type': 'Forest Product',
          });

      savewildlifeDetails(documentId);

      Navigator.of(context).pop(); // close loader
      return documentId;
    } catch (e) {
      Navigator.of(context).pop(); // close loader
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error during file upload.')),
      );
      return null;
    }
  }

  // Submit all files
  Future<void> _submitFiles() async {
    Map<String, File> filesToUpload = {};

    if (woodPermit != null) {
      filesToUpload['Wood Charcoal Production Permit'] = woodPermit!;
    }
    if (requestLetter != null) {
      filesToUpload['Request Letter'] = requestLetter!;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transport Permit',
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.green,
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
                  '1. Request letter',
                  requestLetter,
                  (file) => setState(() => requestLetter = file),
                ),
                _buildFilePicker(
                  '2. Copy of the Wood Charcoal Production Permit',
                  woodPermit,
                  (file) => setState(() => woodPermit = file),
                ),

                const SizedBox(height: 25),
                const Text(
                  'Fees to be Paid',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFeeRow('Application Fee', certificationFee),
                _buildFeeRow('Oath Fee', oathFee),
                _buildFeeRow('Authentication Fee (per page)', authentication),
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
