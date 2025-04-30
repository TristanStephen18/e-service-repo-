import 'package:flutter/material.dart';
import 'package:denr_car_e_service_app/screens/LogIn/login.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<String> _imagePaths = [
    'lib/images/logo.png',
    'lib/images/register.png',
    'lib/images/login.png',
    'lib/images/services.png',
    'lib/images/type.png',
    'lib/images/applications.png',
    'lib/images/options.png',
    'lib/images/chat.png',
    'lib/images/profile.png',
  ];

  final List<String> _titles = [
    'DENR-CENRO E-SERVICES',
    'Create Account',
    'Login',
    'Available Services',
    'Select Service Type',
    'My Applications',
    'Application Options',
    'Chat Support',
    'User Profile',
  ];

  final List<String> _descriptions = [
    'Access online permitting and other DENR-CENRO services.',
    'Register an account to start using the app.',
    'Log in with your registered account.',
    'Browse and choose from available services.',
    'Choose the type of service you want to apply for.',
    'View your submitted applications.',
    'Manage and track your application details.',
    'Chat with an administrator for faster support.',
    'View and update your profile information.',
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _skipToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _titles.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      imagePath: _imagePaths[index],
                      title: _titles[index],
                      description: _descriptions[index],
                      index: index,
                    );
                  },
                ),
                Positioned(
                  top: Responsive.getHeightScale(5),
                  right: Responsive.getWidthScale(10),
                  child: TextButton(
                    onPressed: _skipToLogin,
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: Responsive.getTextScale(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: Responsive.getHeightScale(16),
                  left: Responsive.getWidthScale(19),
                  right: Responsive.getWidthScale(19),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Previous Button
                      GestureDetector(
                        onTap: () {
                          if (_currentPage > 0) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          _currentPage > 0 ? '< Previous' : '',
                          style: TextStyle(
                            fontSize: Responsive.getTextScale(12),
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),

                      // Centered Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildPageIndicator(),
                      ),

                      // Next / Get Started
                      GestureDetector(
                        onTap: () {
                          if (_currentPage == _titles.length - 1) {
                            _skipToLogin();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == _titles.length - 1
                              ? 'Login'
                              : 'Next >',
                          style: TextStyle(
                            fontSize: Responsive.getTextScale(
                              _currentPage == _titles.length - 1 ? 15.0 : 12.0,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            height: 1.2,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    return List<Widget>.generate(_titles.length, (i) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.symmetric(horizontal: Responsive.getWidthScale(4)),
        height: Responsive.getHeightScale(6),
        width:
            _currentPage == i
                ? Responsive.getWidthScale(16)
                : Responsive.getWidthScale(6),
        decoration: BoxDecoration(
          color: _currentPage == i ? Colors.green : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
      );
    });
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final int index;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final screenHeight = MediaQuery.of(context).size.height;
    double imageHeight = index == 0 ? screenHeight * 0.30 : screenHeight * 0.45;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.getWidthScale(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: imageHeight),
          SizedBox(height: Responsive.getHeightScale(20)),
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.getTextScale(20),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Responsive.getHeightScale(5)),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Responsive.getTextScale(13),
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
