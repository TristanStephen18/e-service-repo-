import 'package:denr_car_e_service_app/model/responsive.dart';

import 'package:denr_car_e_service_app/screens/processing/lumber_type.dart';
import 'package:denr_car_e_service_app/screens/processing/wood_type.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProcessingType extends StatefulWidget {
  const ProcessingType({super.key});

  @override
  State<ProcessingType> createState() => _ProcessingTypeState();
}

class _ProcessingTypeState extends State<ProcessingType> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Responsive.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Processing/Dealership Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(17), // Scale text size
          ),
        ),
        backgroundColor: Colors.green,
        leading: BackButton(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(
            Responsive.getWidthScale(16),
          ), // Scale padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(Responsive.getHeightScale(15)), // Scale Gap
              // Chainsaw Registration Container
              Container(
                width: double.infinity,
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
                  leading: Icon(Icons.home, color: Colors.green),
                  title: Text(
                    "Lumber Dealership Permit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(14),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(CupertinoPageRoute(builder: (ctx) => LumberType()));
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
                ),
              ),
              Gap(Responsive.getHeightScale(15)),
              // Permit to Sell Container
              Container(
                width: double.infinity,
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
                  leading: Icon(Icons.pets, color: Colors.green),
                  title: Text(
                    "Wood Processing Plant, including sawmill, mini-sawmill, re-saw permit, plywood/veneer plants, blockboards / fiberboard / particle board and other wood based panel plants and wood treating plants",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(14), // Scale text size
                    ),
                  ),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(CupertinoPageRoute(builder: (ctx) => WoodType()));
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
