import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/LogIn/login.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final TextEditingController name = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController sex = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController contact = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirm = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email.text.trim(),
              password: password.text,
            );

        String userId = userCredential.user!.uid;

        await FirebaseFirestore.instance
            .collection("mobile_users")
            .doc(userId)
            .set({
              'name': name.text.trim(),
              'age': age.text.trim(),
              'sex': sex.text.trim(),
              'address': address.text.trim(),
              'contact': contact.text.trim(),
              'email': email.text.trim(),
              'photo':
                  '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',
            });

        Navigator.pop(context);

        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Success'),
                  ],
                ),
                content: const Text('User successfully registered!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(builder: (_) => const Login()),
                      );
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
        );
      } catch (e) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Registration Failed'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.getWidthScale(12), // Scaled padding
        vertical: Responsive.getHeightScale(12),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive settings
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(17), // Scale text size
          ),
        ),
        backgroundColor: Colors.green,
        leading: BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getWidthScale(20), // Scaled padding
            vertical: Responsive.getHeightScale(15), // Scaled padding
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "lib/images/logo.png",
                  height: Responsive.getHeightScale(100), // Scaled height
                ),
                SizedBox(height: Responsive.getHeightScale(10)),
                Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontSize: Responsive.getTextScale(20), // Scaled font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.getHeightScale(20)),

                // Full Name
                TextFormField(
                  controller: name,
                  validator:
                      (val) => val!.isEmpty ? 'Full name is required' : null,
                  decoration: _inputDecoration("Full Name"),
                ),
                SizedBox(height: Responsive.getHeightScale(15)),

                // Age and Gender
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: age,
                        keyboardType: TextInputType.number,
                        validator:
                            (val) => val!.isEmpty ? 'Age is required' : null,
                        decoration: _inputDecoration("Age"),
                      ),
                    ),
                    SizedBox(width: Responsive.getWidthScale(12)),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: sex.text.isEmpty ? null : sex.text,
                        onChanged:
                            (value) => setState(() => sex.text = value ?? ''),
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? 'Gender is required'
                                    : null,
                        decoration: _inputDecoration("Gender"),
                        items:
                            ['Male', 'Female']
                                .map(
                                  (gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.getHeightScale(15)),

                // Address
                TextFormField(
                  controller: address,
                  validator:
                      (val) => val!.isEmpty ? 'Address is required' : null,
                  decoration: _inputDecoration("Complete Address"),
                ),
                SizedBox(height: Responsive.getHeightScale(15)),

                // Contact Number
                TextFormField(
                  controller: contact,
                  maxLength: 11,
                  keyboardType: TextInputType.phone,
                  validator:
                      (val) =>
                          val!.isEmpty ? 'Contact number is required' : null,
                  decoration: _inputDecoration(
                    "Contact Number",
                  ).copyWith(counterText: ''),
                ),
                SizedBox(height: Responsive.getHeightScale(15)),

                // Email Address
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val!.isEmpty) return 'Email is required';
                    if (!EmailValidator.validate(val))
                      return 'Invalid email format';
                    return null;
                  },
                  decoration: _inputDecoration("Email Address"),
                ),
                SizedBox(height: Responsive.getHeightScale(15)),

                // Password
                TextFormField(
                  controller: password,
                  obscureText: _obscurePassword,
                  validator:
                      (val) => val!.isEmpty ? 'Password is required' : null,
                  decoration: _inputDecoration("Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.getHeightScale(15)),

                // Confirm Password
                TextFormField(
                  controller: confirm,
                  obscureText: _obscurePassword,
                  validator: (val) {
                    if (val!.isEmpty) return 'Please confirm your password';
                    if (val != password.text) return 'Passwords do not match';
                    return null;
                  },
                  decoration: _inputDecoration("Confirm Password"),
                ),
                SizedBox(height: Responsive.getHeightScale(25)),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.getHeightScale(10),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      'Register',
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
      ),
    );
  }
}
