import 'package:denr_car_e_service_app/model/responsive.dart';

import 'package:denr_car_e_service_app/screens/TransportPermit/transport_products.dart';
import 'package:denr_car_e_service_app/screens/TransportPermit/transport_wildlife.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TransportType extends StatefulWidget {
  const TransportType({super.key});

  @override
  State<TransportType> createState() => _TransportTypeState();
}

class _TransportTypeState extends State<TransportType> {
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
          'Transport Type',
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
                  leading: Icon(Icons.car_crash, color: Colors.green),
                  title: Text(
                    "Local Transport Permit (Wildlife)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(14),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (ctx) => TransportWildlife()),
                    );
                  },
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
                ),
              ),
              Gap(Responsive.getHeightScale(15)),
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
                  leading: Icon(Icons.car_crash, color: Colors.green),
                  title: Text(
                    "Transport Permit (Forest Products)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(14), // Scale text size
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (ctx) => TransportProducts()),
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
