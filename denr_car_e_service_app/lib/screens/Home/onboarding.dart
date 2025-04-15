import 'dart:core';
import 'package:denr_car_e_service_app/screens/LogIn/login.dart';
import 'package:flutter/material.dart';
import 'package:denr_car_e_service_app/model/responsive.dart'; // Import the responsive model

class Onboarding extends StatefulWidget {
  final String token;
  const Onboarding({super.key, required this.token});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<String> _imagePaths = [
    'lib/images/logo.png',
    'lib/images/logo.png',
  ];

  final List<String> _titles = ['DENR-CENRO E-SERVICES', 'SAMPLE'];
  final List<String> _descriptions = [
    'E-Services on permitting',
    'Easy to use',
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive settings
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => Login(token: widget.token)),
              );
            },
            child: Text(
              "Skip",
              style: TextStyle(fontSize: Responsive.getTextScale(15)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _titles.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                imagePath: _imagePaths[index],
                title: _titles[index],
                description: _descriptions[index],
              );
            },
          ),
          Positioned(
            bottom: Responsive.getHeightScale(15),
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _titles.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Responsive.getWidthScale(8.0)),
      height: Responsive.getHeightScale(8.0),
      width: Responsive.getWidthScale(8.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green : Colors.grey,
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize responsive settings
    Responsive.init(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            imagePath,
            height: Responsive.getHeightScale(200), // Responsive image height
          ),
          SizedBox(height: Responsive.getHeightScale(25.0)),
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.getTextScale(
                20.0,
              ), // Responsive title font size
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Responsive.getHeightScale(10.0)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.getWidthScale(30.0),
            ),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.getTextScale(15.0), // Responsive text size
              ),
            ),
          ),
        ],
      ),
    );
  }
}
