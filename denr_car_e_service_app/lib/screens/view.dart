import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class Display extends StatefulWidget {
  const Display({super.key});

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
            .doc('TP-2025-03-17-0001')
            .collection('requirements')
            .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Requirements')),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _files,
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
                snapshot.data!.docs;

            if (documents.isEmpty) {
              return Center(child: Text('No Files found'));
            }

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                final DocumentSnapshot<Map<String, dynamic>> document =
                    documents[index];
                final data = document.data()!;
                final ext = data['fileExtension'];
                final base64EncodedPdf =
                    data['file']; // Assuming 'file' field contains base64 PDF string

                return Card(
                  child: ListTile(
                    onTap: () {
                      if (ext == ".pdf") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PdfViewerScreen(
                                  base64EncodedPdf: base64EncodedPdf,
                                ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ImagePreviewScreen(
                                  base64EncodedPdf: base64EncodedPdf,
                                ),
                          ),
                        );
                      }
                    },

                    title: Text(
                      data['fileName'],
                      style: TextStyle(
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
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String base64EncodedPdf;

  PdfViewerScreen({required this.base64EncodedPdf});

  @override
  Widget build(BuildContext context) {
    // Decode the base64 PDF string to get the PDF data
    Uint8List pdfBytes = base64Decode(base64EncodedPdf);

    // Display the PDF using PDFView
    return Scaffold(
      appBar: AppBar(title: Text('PDF Viewer')),
      body: PDFView(
        // Display the PDF from the decoded byte array
        pdfData: pdfBytes,
      ),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String base64EncodedPdf;

  ImagePreviewScreen({required this.base64EncodedPdf});

  @override
  Widget build(BuildContext context) {
    Uint8List images = base64Decode(base64EncodedPdf);
    return Scaffold(
      appBar: AppBar(title: Text('Image Preview')),
      body: Center(
        child: Image.memory(images), // Display image as full screen
      ),
    );
  }
}
