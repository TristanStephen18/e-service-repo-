import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class Display extends StatefulWidget {
  final String applicationId;

  const Display({super.key, required this.applicationId});

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _files;

  @override
  void initState() {
    super.initState();
    _files =
        FirebaseFirestore.instance
            .collection('mobile_users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('applications')
            .doc(widget.applicationId)
            .collection('requirements')
            .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Requirements')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _files,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final documents = snapshot.data!.docs;

              if (documents.isEmpty) {
                return const Center(child: Text('No Files found'));
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final data = documents[index].data();
                  final ext = data['fileExtension'];
                  final fileName = data['fileName'];
                  final base64EncodedFile = data['file'];

                  IconData fileIcon = Icons.insert_drive_file;
                  Color iconColor = Colors.grey;

                  if (ext == '.pdf') {
                    fileIcon = Icons.picture_as_pdf;
                    iconColor = Colors.red;
                  } else if ([
                    '.jpg',
                    '.jpeg',
                    '.png',
                  ].contains(ext.toLowerCase())) {
                    fileIcon = Icons.image;
                    iconColor = Colors.blue;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (ext == ".pdf") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PdfViewerScreen(
                                  base64EncodedPdf: base64EncodedFile,
                                  fileName: fileName,
                                ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ImagePreviewScreen(
                                  base64EncodedFile: base64EncodedFile,
                                  fileName: fileName,
                                ),
                          ),
                        );
                      }
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(fileIcon, size: 80, color: iconColor),
                            const SizedBox(height: 10),
                            Text(
                              fileName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String base64EncodedPdf;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.base64EncodedPdf,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    Uint8List pdfBytes = base64Decode(base64EncodedPdf);

    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: PDFView(pdfData: pdfBytes),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String base64EncodedFile;
  final String fileName;

  const ImagePreviewScreen({
    super.key,
    required this.base64EncodedFile,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = base64Decode(base64EncodedFile);
    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: Center(child: Image.memory(imageBytes)),
    );
  }
}
