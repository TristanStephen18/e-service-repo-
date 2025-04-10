import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: _currentPasswordController.text.trim(),
    );

    try {
      await user.reauthenticateWithCredential(cred);

      if (_newPasswordController.text != _confirmPasswordController.text) {
        throw FirebaseAuthException(
          code: 'password-mismatch',
          message: 'New passwords do not match',
        );
      }

      await user.updatePassword(_newPasswordController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: _inputDecoration('Current Password'),
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Please enter your current password'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: _inputDecoration('New Password'),
                validator:
                    (value) =>
                        value!.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: _inputDecoration('Confirm New Password'),
                validator:
                    (value) =>
                        value != _newPasswordController.text
                            ? 'Passwords do not match'
                            : null,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _changePassword();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Update Password',
                        style: TextStyle(fontSize: 16, color: Colors.white),
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
