// ignore_for_file: use_build_context_synchronously

import 'package:denr_car_e_service_app/screens/TransportPermit/cert_timber.dart';
import 'package:denr_car_e_service_app/screens/TransportPermit/charcoal.dart';
import 'package:denr_car_e_service_app/screens/TransportPermit/cov.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';

class ForestForm extends StatefulWidget {
  final LatLng startLocation;
  final LatLng destinationLocation;
  final String startAddress;
  final String destinationAddress;
  final String polygonName;
  final String type;
  final String legal;

  const ForestForm({
    super.key,
    required this.type,
    required this.startAddress,
    required this.destinationAddress,
    required this.startLocation,
    required this.destinationLocation,
    required this.polygonName,
    required this.legal,
  });

  @override
  State<ForestForm> createState() => _ForestFormState();
}

class _ForestFormState extends State<ForestForm> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String description = '';
  String weight = '';
  String quantity = '';
  String volume = '';
  String nameofLoading = '';
  String conveyance = '';
  String nameofConsignee = '';
  String source = '';

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
      if (widget.type == 'Timber or Lumber' || widget.type == 'Non-Timber') {
        if (widget.legal == 'Certification or Permit from LGU' ||
            widget.legal == 'Tree Cutting Permit') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CertificateOfVerification(
                    startLocation: widget.startLocation,
                    destinationLocation: widget.destinationLocation,
                    startAddress: widget.startAddress,
                    destinationAddress: widget.destinationAddress,
                    polygonName: widget.polygonName,
                    name: name,
                    description: description,
                    weight: weight,
                    quantity: quantity,
                    volume: volume,
                    nameofLoading: nameofLoading,
                    nameofConsignee: nameofConsignee,
                    source: source,
                    legal: widget.legal,
                    conveyance: conveyance,
                  ),
            ),
          );
        }
      } else if (widget.type == 'Timber or Lumber') {
        if (widget.legal == 'Wood Processing Plant Permit' ||
            widget.legal == 'Certificate of Registration as Lumber Dealer') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CertificateofTimber(
                    startLocation: widget.startLocation,
                    destinationLocation: widget.destinationLocation,
                    startAddress: widget.startAddress,
                    destinationAddress: widget.destinationAddress,
                    polygonName: widget.polygonName,
                    name: name,
                    description: description,
                    weight: weight,
                    quantity: quantity,
                    volume: volume,
                    nameofLoading: nameofLoading,
                    nameofConsignee: nameofConsignee,
                    source: source,
                    legal: widget.legal,
                    conveyance: conveyance,
                  ),
            ),
          );
        }
      } else if (widget.type == 'Charcoal') {
        if (widget.legal == 'Wood Charcoal Permit') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => Charcoal(
                    startLocation: widget.startLocation,
                    destinationLocation: widget.destinationLocation,
                    startAddress: widget.startAddress,
                    destinationAddress: widget.destinationAddress,
                    polygonName: widget.polygonName,
                    name: name,
                    description: description,
                    weight: weight,
                    quantity: quantity,
                    volume: volume,
                    nameofLoading: nameofLoading,
                    nameofConsignee: nameofConsignee,
                    source: source,
                    legal: widget.legal,
                    conveyance: conveyance,
                  ),
            ),
          );
        }
      } else {}
    }
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.getHeightScale(8)),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: Responsive.getTextScale(14)),
          prefixIcon:
              icon != null
                  ? Icon(
                    icon,
                    color: Colors.green,
                    size: Responsive.getTextScale(17),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Responsive.getWidthScale(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2),
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
    Responsive.init(context); // Initialize responsive metrics

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forest Products Transport Form',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(15),
          ),
        ),
        backgroundColor: Colors.green,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.getWidthScale(16)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Details',
                style: TextStyle(
                  fontSize: Responsive.getTextScale(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTextField(
                label: 'Name of Species',
                icon: Icons.grass,
                onChanged: (v) => name = v,
              ),
              _buildTextField(
                label: 'Description (e.g., Lumber, Timber)',
                icon: Icons.description,
                onChanged: (v) => description = v,
              ),
              _buildTextField(
                label: 'Unit Weight Measure / Dimension',
                icon: Icons.straighten,
                onChanged: (v) => weight = v,
              ),
              _buildTextField(
                label: 'Quantity',
                icon: Icons.numbers,
                onChanged: (v) => quantity = v,
              ),
              _buildTextField(
                label: 'Estimated Volume',
                icon: Icons.line_weight,
                onChanged: (v) => volume = v,
              ),

              SizedBox(height: Responsive.getHeightScale(15)),
              Text(
                'Transport Details',
                style: TextStyle(
                  fontSize: Responsive.getTextScale(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTextField(
                label: 'Name and Place of Loading',
                icon: Icons.local_shipping,
                onChanged: (v) => nameofLoading = v,
              ),
              _buildTextField(
                label: 'Type of Conveyance and Plate No.',
                icon: Icons.directions_car,
                onChanged: (v) => conveyance = v,
              ),
              _buildTextField(
                label: 'Name and Address of Consignee',
                icon: Icons.person_pin,
                onChanged: (v) => nameofConsignee = v,
              ),
              _buildTextField(
                label: 'Source of Forest Products',
                icon: Icons.source,
                onChanged: (v) => source = v,
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
                      vertical: Responsive.getHeightScale(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.getWidthScale(12),
                      ),
                    ),
                  ),
                  onPressed: _submitFiles,
                  label: Text(
                    'Proceed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.getTextScale(15),
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
