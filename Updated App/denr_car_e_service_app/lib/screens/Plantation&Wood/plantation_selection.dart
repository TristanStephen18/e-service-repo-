import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/Plantation&Wood/bamboo_plantation.dart';
import 'package:denr_car_e_service_app/screens/Plantation&Wood/plantation_registration.dart';
import 'package:denr_car_e_service_app/screens/Plantation&Wood/wood_charcoal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PlantationSelection extends StatelessWidget {
  PlantationSelection({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the responsive values when the widget is built
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Type of Plantation',
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
                  leading: Icon(Icons.forest, color: Colors.green),
                  title: Text(
                    "Timber/Tree Plantation",
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
                        builder: (ctx) => PlantationRegistrationScreen(),
                      ),
                    );
                  },

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
                  leading: Icon(Icons.nature, color: Colors.green),
                  title: Text(
                    "Bamboo Plantation",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(
                        14,
                      ), // Responsive text size
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (ctx) => BambooPlantation()),
                    );
                  },

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
                  leading: Icon(
                    Icons.local_fire_department,
                    color: Colors.green,
                  ),
                  title: Text(
                    "Wood Charcoal Production",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(
                        14,
                      ), // Responsive text size
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (ctx) => WoodCharcoal()),
                    );
                  },

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
