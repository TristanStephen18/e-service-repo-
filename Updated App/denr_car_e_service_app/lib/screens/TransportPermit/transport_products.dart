import 'package:denr_car_e_service_app/map/transport_map.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TransportProducts extends StatefulWidget {
  const TransportProducts({super.key});

  @override
  State<TransportProducts> createState() => _TransportProductsState();
}

class _TransportProductsState extends State<TransportProducts> {
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
          'Forest Products',
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
                  leading: Icon(Icons.park, color: Colors.green),
                  title: Text(
                    "Timber / Lumber",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(14),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder:
                            (ctx) => TransportMap(type: 'Timber or Lumber'),
                      ),
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
                  leading: Icon(Icons.forest, color: Colors.green),
                  title: Text(
                    "Non-Timber Forest Products",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(14), // Scale text size
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (ctx) => TransportMap(type: 'Non-Timber'),
                      ),
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
                    "Charcoal",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(14), // Scale text size
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (ctx) => TransportMap(type: 'Charcoal'),
                      ),
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
                  leading: Icon(Icons.oil_barrel, color: Colors.green),
                  title: Text(
                    "Gums, Resins, Oils and Exudates",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.getTextScale(14), // Scale text size
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder:
                            (ctx) => TransportMap(
                              type: 'Gums, Resins, Oils and Exudates',
                            ),
                      ),
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
