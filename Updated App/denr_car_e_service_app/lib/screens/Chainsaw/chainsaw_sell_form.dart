import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/Chainsaw/permit_to_sell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChainsawSellForm extends StatefulWidget {
  const ChainsawSellForm({super.key});

  @override
  _ChainsawSellFormState createState() => _ChainsawSellFormState();
}

class _ChainsawSellFormState extends State<ChainsawSellForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  String serialNumber = '';
  String brand = '';
  String model = '';
  String engineCapacity = '';
  String guideBar = '';
  String countryOfOrigin = '';

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
          'Permit To Sell Form',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(17),
          ),
        ),
        backgroundColor: Colors.green,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Serial Number',
                onChanged: (v) => serialNumber = v,
                icon: Icons.confirmation_number,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Brand',
                onChanged: (v) => brand = v,
                icon: Icons.label,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Model',
                onChanged: (v) => model = v,
                icon: Icons.build_circle,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Engine Capacity',
                onChanged: (v) => engineCapacity = v,
                icon: Icons.speed,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Guide Bar',
                onChanged: (v) => guideBar = v,
                icon: Icons.straighten,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Country of Origin',
                onChanged: (v) => countryOfOrigin = v,
                icon: Icons.flag,
              ),
              const SizedBox(height: 28),

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
              (ctx) => PermitToSellScrenn(
                serialNumber: serialNumber,
                brand: brand,
                model: model,
                engineCapacity: engineCapacity,
                guideBar: guideBar,
                countryOfOrigin: countryOfOrigin,
              ),
        ),
      );
    }
  }
}
