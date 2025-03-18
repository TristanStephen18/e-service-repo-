import 'package:denr_car_e_service_app/firebase_options.dart';
import 'package:denr_car_e_service_app/screens/Home/homepage.dart';
import 'package:denr_car_e_service_app/screens/Home/onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(Eservices());
}

class Eservices extends StatelessWidget {
  const Eservices({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            String userID = snapshot.data!.uid;
            return Homepage(userid: userID);
          }
          return Onboarding();
        },
      ),
    );
  }
}
