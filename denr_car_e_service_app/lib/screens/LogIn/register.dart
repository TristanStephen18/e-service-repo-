// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.green, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("lib/images/logo.png", height: 110),
                const SizedBox(height: 10),
                const Text(
                  "Create Your Account",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),

                TextFormField(
                  controller: name,
                  validator:
                      (val) => val!.isEmpty ? 'Full name is required' : null,
                  decoration: _inputDecoration("Full Name"),
                ),
                const SizedBox(height: 16),

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
                    const SizedBox(width: 12),
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
                const SizedBox(height: 16),

                TextFormField(
                  controller: address,
                  validator:
                      (val) => val!.isEmpty ? 'Address is required' : null,
                  decoration: _inputDecoration("Complete Address"),
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

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
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
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
      ),
    );
  }
}
