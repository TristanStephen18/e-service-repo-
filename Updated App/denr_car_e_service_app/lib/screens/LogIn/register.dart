import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/model/photo.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/LogIn/login.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  final TextEditingController type = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController contact = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirm = TextEditingController();
  final TextEditingController office = TextEditingController();
  final TextEditingController representative = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showInfoDialog();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _showInfoDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text("Important Notice"),
              content: Text(
                "Names and information to be given should be the information of the permit applicant.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Got it"),
                ),
              ],
            ),
      );
    });
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    String? fcmToken = await FirebaseMessaging.instance.getToken();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(width: 15),
              Text('Registering user...'),
            ],
          ),
        );
      },
    );

    try {
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
            'age': age.text.trim(),
            'sex': sex.text.trim(),
            'address': address.text.trim(),
            'contact': contact.text.trim(),
            'email': email.text.trim(),
            'photo': ProfileDefault.photo,
            'token': fcmToken,
            'type': type.text.trim(),
            if (type.text != 'Citizen/Individual') ...{
              'office': office.text.trim(),
              'representative': representative.text.trim(),
            },
            if (type.text == 'Citizen/Individual') ...{
              'name': name.text.trim(),
            },
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
                  onPressed: () async {
                    await FirebaseMessaging.instance.deleteToken();
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (_) => Login()),
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
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Registration Failed'),
              content: Text(e.message ?? 'An unknown error occurred.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
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
              title: const Text('Error'),
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
        horizontal: Responsive.getWidthScale(12),
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
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(17),
          ),
        ),
        backgroundColor: Colors.green,
        leading: BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getWidthScale(20),
            vertical: Responsive.getHeightScale(15),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "lib/images/logo.png",
                  height: Responsive.getHeightScale(130),
                ),
                SizedBox(height: Responsive.getHeightScale(5)),
                Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontSize: Responsive.getTextScale(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.getHeightScale(20)),

                // Type of Client
                DropdownButtonFormField<String>(
                  value: type.text.isEmpty ? null : type.text,
                  onChanged: (value) => setState(() => type.text = value ?? ''),
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? 'Type of Client Required'
                              : null,
                  decoration: _inputDecoration("Client Type"),
                  items:
                      [
                            'Citizen/Individual',
                            'Business/Company',
                            'Peoples/Community Organization',
                            'Government',
                          ]
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                ),

                // Conditional Fields
                if (type.text != 'Citizen/Individual' &&
                    type.text.isNotEmpty) ...[
                  SizedBox(height: Responsive.getHeightScale(15)),
                  TextFormField(
                    controller: office,
                    validator:
                        (val) =>
                            val!.isEmpty ? 'Office/Company is required' : null,
                    decoration: _inputDecoration("Name of Office/Company"),
                  ),
                  SizedBox(height: Responsive.getHeightScale(15)),
                  TextFormField(
                    controller: representative,
                    validator:
                        (val) =>
                            val!.isEmpty
                                ? 'Authorized Representative is required'
                                : null,
                    decoration: _inputDecoration("Authorized Representative"),
                  ),
                ],

                SizedBox(height: Responsive.getHeightScale(15)),

                // Full Name
                if (type.text == 'Citizen/Individual') ...[
                  TextFormField(
                    controller: name,
                    validator:
                        (val) => val!.isEmpty ? 'Full name is required' : null,
                    decoration: _inputDecoration("Full Name"),
                  ),
                ],

                SizedBox(height: Responsive.getHeightScale(10)),

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

                // Contact
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

                // Email
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
