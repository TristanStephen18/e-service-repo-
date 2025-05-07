// ignore_for_file: use_build_context_synchronously

import 'package:denr_car_e_service_app/screens/TransportPermit/ltp(Fauna).dart';
import 'package:denr_car_e_service_app/screens/TransportPermit/ltp(Flora).dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';

class WildlifeForm extends StatefulWidget {
  final LatLng startLocation;
  final LatLng destinationLocation;
  final String startAddress;
  final String destinationAddress;
  final String polygonName;
  final String type;

  const WildlifeForm({
    super.key,
    required this.type,
    required this.startAddress,
    required this.destinationAddress,
    required this.startLocation,
    required this.destinationLocation,
    required this.polygonName,
  });

  @override
  State<WildlifeForm> createState() => _WildlifeFormState();
}

class _WildlifeFormState extends State<WildlifeForm> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String description = '';
  String weight = '';
  String quantity = '';
  String acquisition = '';

  Future<void> _submitFiles() async {
    if (!_formKey.currentState!.validate()) return;

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Submission'),
          content: const Text('Are you sure you want to submit this form?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (widget.type == 'Fauna') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => LtpFauna(
                  startLocation: widget.startLocation,
                  destinationLocation: widget.destinationLocation,
                  startAddress: widget.startAddress,
                  destinationAddress: widget.destinationAddress,
                  polygonName: widget.polygonName,
                  name: name,
                  description: description,
                  weight: weight,
                  quantity: quantity,
                  acquisition: acquisition,
                ),
          ),
        );
      } else if (widget.type == 'Flora') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => LtpFlora(
                  startLocation: widget.startLocation,
                  destinationLocation: widget.destinationLocation,
                  startAddress: widget.startAddress,
                  destinationAddress: widget.destinationAddress,
                  polygonName: widget.polygonName,
                  name: name,
                  description: description,
                  weight: weight,
                  quantity: quantity,
                  acquisition: acquisition,
                ),
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
      onChanged: onChanged,
      validator:
          validator ??
          (value) =>
              value == null || value.isEmpty ? 'This field is required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScale = Responsive.getTextScale(17);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wildlife Transport Form',
          style: TextStyle(color: Colors.white, fontSize: textScale),
        ),
        backgroundColor: Colors.green,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                label: 'Name of Species',
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Description',
                onChanged: (v) => description = v,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Unit Weight Measure',
                onChanged: (v) => weight = v,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Quantity',
                onChanged: (v) => quantity = v,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Mode of Acquisition',
                onChanged: (v) => acquisition = v,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _submitFiles,
                  child: const Text(
                    'Proceed',
                    style: TextStyle(color: Colors.white),
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
