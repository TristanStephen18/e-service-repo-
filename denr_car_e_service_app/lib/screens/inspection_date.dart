import 'package:flutter/material.dart';

class InspectionDateScreen extends StatelessWidget {
  const InspectionDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inspection Date',
          style: TextStyle(color: Colors.white),
        ),
        leading: BackButton(color: Colors.white),
        backgroundColor: Colors.green,
      ),
    );
  }
}
