import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:denr_car_e_service_app/screens/inspection_date.dart';
import 'package:denr_car_e_service_app/screens/order_of_payment.dart';
import 'package:denr_car_e_service_app/screens/view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class OptionScreen extends StatelessWidget {
  final String applicationId;
  OptionScreen({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context) {
    // Initialize the responsive values when the widget is built
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Application',
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
                  leading: Icon(Icons.file_copy, color: Colors.green),
                  title: Text(
                    "View Requirements",
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
                        builder: (ctx) => Display(applicationId: applicationId),
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
                  leading: Icon(Icons.payment, color: Colors.green),
                  title: Text(
                    "View Order of Payment",
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
                        builder: (ctx) => OrderOfPaymentScreen(),
                      ),
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
                  leading: Icon(Icons.date_range, color: Colors.green),
                  title: Text(
                    "View Date of Inspection",
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
                        builder: (ctx) => InspectionDateScreen(),
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
