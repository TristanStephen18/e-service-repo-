import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Responsive.init(context); // Initialize the responsive scaling

    final helpTopics = [
      {
        "title": "How to Install the App",
        "icon": Icons.download,
        "content": """
1. Scan the QR code to access the file or link.
2. Click Download.
3. Tap the 'Install' button.
4. Once installed, tap 'Open' to start using the app.
""",
      },
      {
        "title": "How to Create Account",
        "icon": Icons.person,
        "content": """
1. On the login screen, tap on 'Register'
2. Fill up all needed.
3. Tap Register then wait for your account creation.
4. After account creation login.
""",
      },
      {
        "title": "How to Change Password",
        "icon": Icons.key,
        "content": """
1. On the Profiles screen, tap on 'Change Password'
2. Enter old password then new password.
3. Tap Update Password.

""",
      },
      {
        "title": "How to Reset/Forgot Password",
        "icon": Icons.lock_reset,
        "content": """
1. On the login screen, tap on 'Forgot Password?'
2. Enter your registered email.
3. You will receive a password reset email.
4. Follow the link in the email to set a new password.
""",
      },
      {
        "title": "How to Submit an Application",
        "icon": Icons.assignment,
        "content": """
1. Log in to the app.
2. Go to the Services section.
3. Choose the application type.
4. Fill out the required form and upload any documents.
5. Tap 'Submit' to complete the process.
""",
      },
      {
        "title": "How to Contact Support",
        "icon": Icons.support_agent,
        "content": """
1. Go to MeCenro Screen.
2. Message the Admin.
3. Wait for the Admin to reply to your concern.
""",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help & Support",
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(17),
          ),
        ),
        backgroundColor: Colors.green,
        leading: BackButton(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: helpTopics.length,
        itemBuilder: (context, index) {
          final topic = helpTopics[index];
          return Card(
            margin: EdgeInsets.symmetric(
              vertical: Responsive.getHeightScale(7),
              horizontal: Responsive.getWidthScale(12),
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: ExpansionTile(
              leading: Icon(
                topic['icon'] as IconData,
                color: Colors.green,
                size: Responsive.getWidthScale(20), // Responsive icon size
              ),
              title: Text(
                topic['title'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.getTextScale(
                    15,
                  ), // Responsive title font size
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(Responsive.getHeightScale(14)),
                  child: Text(
                    topic['content'] as String,
                    style: TextStyle(
                      fontSize: Responsive.getTextScale(
                        13,
                      ), // Responsive content font size
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
