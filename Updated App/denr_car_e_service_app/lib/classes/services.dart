import 'package:denr_car_e_service_app/map/map.dart';

import 'package:denr_car_e_service_app/screens/Plantation&Wood/plantation_selection.dart';

import 'package:denr_car_e_service_app/screens/TransportPermit/transport_type.dart';

import 'package:denr_car_e_service_app/screens/Wildlife/wildlife_type.dart';
import 'package:denr_car_e_service_app/screens/chainsaw/chainsaw_registration.dart';
import 'package:denr_car_e_service_app/screens/others/others.dart';
import 'package:denr_car_e_service_app/screens/processing/processing_type.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive settings
    Responsive.init(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.getWidthScale(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: ExactAssetImage('lib/images/logo.png'),
                    backgroundColor: Colors.transparent,
                  ),

                  SizedBox(width: Responsive.getWidthScale(10)),
                  const Text(
                    'DENR-CAR CENRO',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              Gap(Responsive.getHeightScale(15)),
              Center(
                child: Text(
                  'Services',
                  style: TextStyle(
                    fontSize: Responsive.getTextScale(22), // Scaled text size
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              Gap(Responsive.getHeightScale(15)),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildServiceTile(
                        context,
                        icon: Icons.carpenter,
                        title: "Chainsaw Registrations and Permits",
                        subtitle: "Apply Now!",
                        onTap:
                            () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (ctx) => ChainsawRegistrationScreen(),
                              ),
                            ),
                      ),

                      _buildServiceTile(
                        context,
                        icon: Icons.forest,
                        title: "Tree Cutting Permit",
                        subtitle: "Apply Now!",
                        onTap:
                            () => Navigator.of(context).push(
                              CupertinoPageRoute(builder: (ctx) => MapScreen()),
                            ),
                      ),

                      _buildServiceTile(
                        context,
                        icon: Icons.car_crash,
                        title: "Transport Permit",
                        subtitle: "Apply Now!",
                        onTap:
                            () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (ctx) => TransportType(),
                              ),
                            ),
                      ),

                      _buildServiceTile(
                        context,
                        icon: Icons.grass,
                        title:
                            "Plantation and Non-Timber Forest Products Registration and Permits, including Rattan, Bamboo and Charcoal",
                        subtitle: "Apply Now!",
                        onTap:
                            () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (ctx) => PlantationSelection(),
                              ),
                            ),
                      ),

                      _buildServiceTile(
                        context,
                        icon: Icons.pets,
                        title: "Wildlife Permit and Registration",
                        subtitle: "Apply Now!",
                        onTap:
                            () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (ctx) => WildlifeType(),
                              ),
                            ),
                      ),
                      _buildServiceTile(
                        context,
                        icon: Icons.park,
                        title: "Processing / Dealership of Forest Products",
                        subtitle: "Apply Now!",
                        onTap:
                            () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (ctx) => ProcessingType(),
                              ),
                            ),
                      ),

                      _buildServiceTile(
                        context,
                        icon: Icons.file_copy,
                        title: "Other Permits",
                        subtitle: "Apply Now!",
                        onTap:
                            () => Navigator.of(context).push(
                              CupertinoPageRoute(builder: (ctx) => Others()),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.getHeightScale(15)),
      child: Container(
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
          leading: Icon(icon, color: Colors.green),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
          onTap: onTap,
        ),
      ),
    );
  }
}
