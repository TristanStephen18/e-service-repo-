import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/Chainsaw/chainsaw_reg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegistrationForm extends StatefulWidget {
  final String type;

  const RegistrationForm({super.key, required this.type});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();

  String serialNumber = '';
  String brand = '';
  String model = '';
  String engineCapacity = '';
  String guideBar = '';
  String countryOfOrigin = '';
  String purposeOfUse = '';
  String nameOfDealer = '';
  DateTime? dateOfPurchase;

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
          'Chainsaw Registration Form',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(17),
          ),
        ),
        backgroundColor: Colors.green,
        leading: const BackButton(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? 100 : 16,
              vertical: 20,
            ),
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(9),
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Serial Number',
                            onChanged: (v) => serialNumber = v,
                            icon: Icons.confirmation_number,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Brand',
                            onChanged: (v) => brand = v,
                            icon: Icons.precision_manufacturing,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Model',
                            onChanged: (v) => model = v,
                            icon: Icons.settings_input_component,
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
                            icon: Icons.build,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Country of Origin',
                            onChanged: (v) => countryOfOrigin = v,
                            icon: Icons.public,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Purpose of Use',
                            onChanged: (v) => purposeOfUse = v,
                            icon: Icons.assignment,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Name of Dealer',
                            onChanged: (v) => nameOfDealer = v,
                            icon: Icons.store,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date of Purchase',
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.green,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                            ),
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: dateOfPurchase ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  dateOfPurchase = selectedDate;
                                  _dateController.text =
                                      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                            validator:
                                (val) =>
                                    dateOfPurchase == null
                                        ? 'Please select a date'
                                        : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton.icon(
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

                        label: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
        },
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
              (ctx) => ChainsawReg(
                type: widget.type,
                serialNumber: serialNumber,
                brand: brand,
                model: model,
                engineCapacity: engineCapacity,
                guideBar: guideBar,
                countryOfOrigin: countryOfOrigin,
                purposeOfUse: purposeOfUse,
                nameOfDealer: nameOfDealer,
                dateOfPurchase: dateOfPurchase,
              ),
        ),
      );
    }
  }
}
