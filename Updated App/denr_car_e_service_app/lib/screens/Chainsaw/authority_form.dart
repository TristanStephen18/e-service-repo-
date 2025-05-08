import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/Chainsaw/chainsaw_lease.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthorityForm extends StatefulWidget {
  const AuthorityForm({super.key});

  @override
  _AuthorityFormState createState() => _AuthorityFormState();
}

class _AuthorityFormState extends State<AuthorityForm> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String location = '';
  String period = '';
  String purpose = '';

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
          'Authority to Lease',
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
                label: 'Name of leasee, rentee or lendee',
                keyboardType: TextInputType.text,
                onChanged: (v) => name = v,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Specific location where the chainsaw will be used',
                onChanged: (v) => location = v,
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Period for the use of chainsaw',
                onChanged: (v) => period = v,
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Purpose of the use of chainsaw',
                onChanged: (v) => purpose = v,
                icon: Icons.info_outline,
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
              (ctx) => ChainsawLease(
                name: name,
                location: location,
                period: period,
                purpose: purpose,
              ),
        ),
      );
    }
  }
}
