import 'dart:core';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/LogIn/login.dart';
import 'package:flutter/material.dart';

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
    'lib/images/logo.png',
  ];

  final List<String> _titles = ['DENR-CAR E-SERVICES', 'SAMPLE'];
  final List<String> _descriptions = [
    'E-Services on permitting',
    'Easy to use',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the Responsive class to calculate screen sizes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Responsive.init(context);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => Login()));
            },
            child: Text(
              "Skip",
              style: TextStyle(
                fontSize: Responsive.getTextScale(18.0), // Scaled font size
              ),
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
            bottom: Responsive.getHeightScale(20.0), // Scaled position
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
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.getWidthScale(8.0),
      ), // Scaled margin
      height: Responsive.getHeightScale(8.0), // Scaled height
      width: Responsive.getWidthScale(8.0), // Scaled width
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          imagePath,
          height: Responsive.getHeightScale(250.0),
        ), // Scaled image height
        SizedBox(height: Responsive.getHeightScale(30.0)), // Scaled space
        Text(
          title,
          style: TextStyle(
            fontSize: Responsive.getTextScale(26.0), // Scaled font size
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: Responsive.getHeightScale(10.0)), // Scaled space
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getWidthScale(40.0),
          ), // Scaled padding
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Responsive.getTextScale(18.0),
            ), // Scaled font size
          ),
        ),
      ],
    );
  }
}
