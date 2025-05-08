import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/Chainsaw/chainsaw_manufacture.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChainsawManufactureForm extends StatefulWidget {
  const ChainsawManufactureForm({super.key});

  @override
  _ChainsawManufactureFormState createState() =>
      _ChainsawManufactureFormState();
}

class _ChainsawManufactureFormState extends State<ChainsawManufactureForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  String numberofChainsaw = '';
  String type = '';
  String source = '';

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    IconData? icon,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
      keyboardType: keyboardType,
      validator:
          validator ?? (val) => val == null || val.isEmpty ? 'Required' : null,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Permit to Manufacture',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(18),
          ),
        ),
        backgroundColor: Colors.green,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),

              _buildTextField(
                label: 'Number of Chainsaws',
                keyboardType: TextInputType.number,
                onChanged: (v) => numberofChainsaw = v,
                icon: Icons.format_list_numbered,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Type of Chainsaw',
                onChanged: (v) => type = v,
                icon: Icons.device_hub,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Source of Materials',
                onChanged: (v) => source = v,
                icon: Icons.source,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Submission'),
            content: const Text('Are you sure you want to submit this form?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Yes', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder:
              (ctx) => ChainsawManufacture(
                numberofChainsaw: numberofChainsaw,
                type: type,
                source: source,
              ),
        ),
      );
    }
  }
}
