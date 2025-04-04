import 'package:flutter/material.dart';

class OrderOfPaymentScreen extends StatelessWidget {
  const OrderOfPaymentScreen({super.key});

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
    );
  }
}
