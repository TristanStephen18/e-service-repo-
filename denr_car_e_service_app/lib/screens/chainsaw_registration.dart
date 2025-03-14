import 'package:flutter/material.dart';

class ChainsawRegistrationScreen extends StatefulWidget {
  const ChainsawRegistrationScreen({super.key});

  @override
  State<ChainsawRegistrationScreen> createState() =>
      _ChainsawRegistrationScreenState();
}

class _ChainsawRegistrationScreenState
    extends State<ChainsawRegistrationScreen> {
  String dropdownValue = 'New Application';

  // Controllers for input fields
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final TextEditingController controller4 = TextEditingController();
  final TextEditingController controller5 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chainsaw Registration Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Application Type'),
            // Dropdown to select New Application or Renewal
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items:
                  <String>[
                    'New Application',
                    'Renewal',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            SizedBox(height: 20),

            // Show input fields based on the selected option
            if (dropdownValue == 'New Application') ...[
              // 5 inputs for New Application
              TextField(
                controller: controller1,
                decoration: InputDecoration(labelText: 'Input 1'),
              ),
              TextField(
                controller: controller2,
                decoration: InputDecoration(labelText: 'Input 2'),
              ),
              TextField(
                controller: controller3,
                decoration: InputDecoration(labelText: 'Input 3'),
              ),
              TextField(
                controller: controller4,
                decoration: InputDecoration(labelText: 'Input 4'),
              ),
              TextField(
                controller: controller5,
                decoration: InputDecoration(labelText: 'Input 5'),
              ),
            ] else if (dropdownValue == 'Renewal') ...[
              // 2 inputs for Renewal
              TextField(
                controller: controller1,
                decoration: InputDecoration(labelText: 'Input 1'),
              ),
              TextField(
                controller: controller2,
                decoration: InputDecoration(labelText: 'Input 2'),
              ),
            ],
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle form submission
                  String formType =
                      dropdownValue == 'New Application'
                          ? 'New Application'
                          : 'Renewal';
                  print('Form submitted: $formType');
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
