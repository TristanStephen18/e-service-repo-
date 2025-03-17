import 'package:denr_car_e_service_app/screens/Chainsaw/chainsaw_reg.dart';
import 'package:denr_car_e_service_app/screens/Chainsaw/permit_to_purchase.dart';
import 'package:denr_car_e_service_app/screens/chainsaw/permit_to_sell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ChainsawRegistrationScreen extends StatefulWidget {
  const ChainsawRegistrationScreen({super.key});

  @override
  State<ChainsawRegistrationScreen> createState() =>
      _ChainsawRegistrationScreenState();
}

class _ChainsawRegistrationScreenState
    extends State<ChainsawRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chainsaw Type')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
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
                    "Chainsaw Registration",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(CupertinoPageRoute(builder: (ctx) => ChainsawReg()));
                  },

                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
                ),
              ),
              const Gap(20),
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
                    "Permit to Sell",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (ctx) => PermitToSellScrenn(),
                      ),
                    );
                  },

                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
                ),
              ),
              const Gap(20),
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
                  leading: Icon(Icons.forest, color: Colors.green),
                  title: Text(
                    "Permit to Purchase",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (ctx) => PermitToPurchase()),
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
