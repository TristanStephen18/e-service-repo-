import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'package:flutter/material.dart';

class Fileupload extends StatefulWidget {
  const Fileupload({super.key});

  @override
  State<Fileupload> createState() => _FileuploadState();
}

class _FileuploadState extends State<Fileupload> {
  File? _fileupload;
  String? _uploadedFileUrl; // To store URL or base64 string from Firestore

  Future<void> _pickFile() async {
    // Open file picker with multiple types allowed (images, PDFs, etc.)
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Don't allow multiple file selection
      type: FileType.custom, // Allow custom file types (like image, pdf, etc.)
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'docx',
        'txt',
      ], // Specify file types
    );

    if (result != null) {
      setState(() {
        _fileupload = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    File? selectedFile = _fileupload;

    if (selectedFile != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      // Convert file to bytes
      List<int> fileBytes = selectedFile.readAsBytesSync();

      // Encode bytes to base64 string
      String base64File = base64Encode(fileBytes);

      // Get the original file name and extension
      String fileName = selectedFile.uri.pathSegments.last;
      String fileExtension = fileName.split('.').last;

      // Store base64 string, file name, and file extension in Firestore
      await FirebaseFirestore.instance.collection('files').add({
        'file': base64File,
        'fileName': fileName, // Store original file name
        'fileExtension': fileExtension, // Store file extension
      });

      // Fetch the uploaded file URL (if you store the URL or any other identifier)
      // You might want to use Firebase Storage for actual file storage, not Firestore.
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File uploaded successfully')));

      setState(() {
        _fileupload = null; // Reset selected file
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select a file')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _pickFile(); // Open the file picker on tap
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child:
                      _fileupload != null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(_fileupload!.path.split('/').last),
                            ],
                          )
                          : Center(
                            child: Icon(
                              Icons.attach_file,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                ),
              ),
              SizedBox(height: 20),
              // Display the image if it's an image file
              if (_uploadedFileUrl != null) ...[
                // This assumes you saved the base64-encoded image and retrieved it
                Image.memory(
                  base64Decode(_uploadedFileUrl!),
                  height: 200,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
              ],
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _uploadFile,
                    child: Text(
                      'Upload',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
