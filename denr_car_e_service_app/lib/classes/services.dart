import 'package:denr_car_e_service_app/screens/chainsaw/chainsaw_registration.dart';
import 'package:denr_car_e_service_app/screens/transportPermit/transport_permit.dart';
import 'package:denr_car_e_service_app/screens/treeCutting/tree_cutting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundImage: ExactAssetImage('lib/images/logo.png'),
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Text(
                      'DENR-CAR',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const Gap(25),
                const Center(
                  child: Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const Gap(20),

                _buildServiceTile(
                  context,
                  icon: Icons.carpenter,
                  title: "Chainsaw",
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
                        CupertinoPageRoute(
                          builder: (ctx) => TreeCuttingChoices(),
                        ),
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
                          builder: (ctx) => ForestRequirementsForm(),
                        ),
                      ),
                ),

                _buildServiceTile(
                  context,
                  icon: Icons.grass,
                  title: "Plantation and Wood Processing Registration",
                  subtitle: "Apply Now!",
                  onTap:
                      () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (ctx) => TreeCuttingChoices(),
                        ),
                      ),
                ),

                _buildServiceTile(
                  context,
                  icon: Icons.pets,
                  title: "Wildlife Registration",
                  subtitle: "Apply Now!",
                  onTap:
                      () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (ctx) => TreeCuttingChoices(),
                        ),
                      ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.only(bottom: 20),
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
