import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderOfPaymentScreen extends StatefulWidget {
  final String applicationId;

  const OrderOfPaymentScreen({super.key, required this.applicationId});

  @override
  State<OrderOfPaymentScreen> createState() => _OrderOfPaymentScreenState();
}

class _OrderOfPaymentScreenState extends State<OrderOfPaymentScreen> {
  String? pdfFilePath;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPdfFromFirestore();
  }

  Future<void> loadPdfFromFirestore() async {
    try {
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('mobile_users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('applications')
              .doc(widget.applicationId)
              .get();

      if (!docSnapshot.exists) {
        setState(() {
          isLoading = false;
          errorMessage = 'Order of Payment not found.';
        });
        return;
      }

      final data = docSnapshot.data()!;
      final base64Pdf = data['oop'];

      Uint8List pdfBytes = base64Decode(base64Pdf);

      final outputDir = await getTemporaryDirectory();
      final outputFile = File('${outputDir.path}/Order of Payment.pdf');
      await outputFile.writeAsBytes(pdfBytes, flush: true);

      setState(() {
        pdfFilePath = outputFile.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'No Order of Payment Yet!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order of Payment',
          style: TextStyle(color: Colors.white),
        ),
        leading: BackButton(color: Colors.white),
        backgroundColor: Colors.green,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : PDFView(
                filePath: pdfFilePath!,
                enableSwipe: true,
                swipeHorizontal: false,
                pageSnap: true,
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          if (pdfFilePath == null) return;

          try {
            await Share.shareXFiles([
              XFile(pdfFilePath!),
            ], text: 'Order of Payment PDF');
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to share PDF')));
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.save, color: Colors.white),
            SizedBox(height: 4),
            Text('Save', style: TextStyle(fontSize: 12, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
