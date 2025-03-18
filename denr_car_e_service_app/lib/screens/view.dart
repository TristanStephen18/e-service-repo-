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
      appBar: AppBar(title: Text('Requirements')),
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

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final data = documents[index].data();
                  final ext = data['fileExtension'];
                  final base64EncodedFile = data['file'];

                  return Card(
                    child: ListTile(
                      onTap: () {
                        if (ext == ".pdf") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PdfViewerScreen(
                                    base64EncodedPdf: base64EncodedFile,
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
                                  ),
                            ),
                          );
                        }
                      },
                      title: Text(
                        data['fileName'],
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
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

  const PdfViewerScreen({super.key, required this.base64EncodedPdf});

  @override
  Widget build(BuildContext context) {
    Uint8List pdfBytes = base64Decode(base64EncodedPdf);

    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: PDFView(pdfData: pdfBytes),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String base64EncodedFile;

  const ImagePreviewScreen({super.key, required this.base64EncodedFile});

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = base64Decode(base64EncodedFile);
    return Scaffold(
      appBar: AppBar(title: const Text('Image Preview')),
      body: Center(child: Image.memory(imageBytes)),
    );
  }
}
