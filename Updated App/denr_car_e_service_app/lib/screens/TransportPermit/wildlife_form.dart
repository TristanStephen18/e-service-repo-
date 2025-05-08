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
      final screen =
          widget.type == 'Fauna'
              ? LtpFauna(
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
              )
              : LtpFlora(
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
              );

      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.getHeightScale(14)),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: Responsive.getTextScale(13)),
          prefixIcon: Icon(
            icon,
            color: Colors.green,
            size: Responsive.getTextScale(20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Responsive.getWidthScale(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(Responsive.getWidthScale(12)),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: Responsive.getHeightScale(12),
            horizontal: Responsive.getWidthScale(14),
          ),
        ),
        onChanged: onChanged,
        validator:
            validator ??
            (value) =>
                value == null || value.isEmpty
                    ? 'This field is required'
                    : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context); // Initialize responsive values

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wildlife Transport Form',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(15),
          ),
        ),
        backgroundColor: Colors.green,
        leading: const BackButton(color: Colors.white),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.getWidthScale(15)),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: Responsive.getHeightScale(20)),
              _buildTextField(
                label: 'Name of Species',
                icon: Icons.pets,
                onChanged: (v) => name = v,
              ),
              _buildTextField(
                label: 'Description',
                icon: Icons.description,
                onChanged: (v) => description = v,
              ),
              _buildTextField(
                label: 'Unit Weight Measure',
                icon: Icons.line_weight,
                onChanged: (v) => weight = v,
              ),
              _buildTextField(
                label: 'Quantity',
                icon: Icons.numbers,
                onChanged: (v) => quantity = v,
              ),
              _buildTextField(
                label: 'Mode of Acquisition',
                icon: Icons.info_outline,
                onChanged: (v) => acquisition = v,
              ),
              SizedBox(height: Responsive.getHeightScale(20)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: Responsive.getTextScale(15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.getHeightScale(14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.getWidthScale(12),
                      ),
                    ),
                  ),
                  onPressed: _submitFiles,
                  label: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: Responsive.getTextScale(15),
                      color: Colors.white,
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
