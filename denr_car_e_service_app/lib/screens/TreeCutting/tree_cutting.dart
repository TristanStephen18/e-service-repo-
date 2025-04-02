import 'package:denr_car_e_service_app/map/map.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TreeCuttingChoices extends StatelessWidget {
  TreeCuttingChoices({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the responsive values when the widget is built
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tree Cutting Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(
              17,
            ), // Adjusting the font size responsively
          ),
        ),
        leading: BackButton(color: Colors.white),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(
            Responsive.getWidthScale(16),
          ), // Responsive padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(Responsive.getHeightScale(15)), // Responsive gap
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.public, color: Colors.green),
                  title: Text(
                    "Public safety Permit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(
                        15,
                      ), // Responsive text size
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (ctx) => MapScreen(type: 'PSP'),
                      ),
                    );
                  },
                  subtitle: Text(
                    "For removal of trees in public places.",
                    style: TextStyle(
                      fontSize: Responsive.getTextScale(
                        12,
                      ), // Responsive text size
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
                ),
              ),
              Gap(Responsive.getHeightScale(15)), // Responsive gap
              // Tree Cutting Permit Service
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.landscape, color: Colors.green),
                  title: Text(
                    "Private Land Timber Permit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(
                        14,
                      ), // Responsive text size
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (ctx) => MapScreen(type: 'PLTP'),
                      ),
                    );
                  },
                  subtitle: Text(
                    "For trees within private lands",
                    style: TextStyle(
                      fontSize: Responsive.getTextScale(
                        12,
                      ), // Responsive text size
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
                ),
              ),
              Gap(Responsive.getHeightScale(15)), // Responsive gap
              // Transport Permit Service
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.security, color: Colors.green),
                  title: Text(
                    "National Government Agencies Permit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(
                        14,
                      ), // Responsive text size
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (ctx) => MapScreen(type: 'NGA'),
                      ),
                    );
                  },
                  subtitle: Text(
                    "For trees affected by national government agency projects.",
                    style: TextStyle(
                      fontSize: Responsive.getTextScale(
                        12,
                      ), // Responsive text size
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
