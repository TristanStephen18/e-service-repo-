import 'package:denr_car_e_service_app/map/transport_map.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LegalSource extends StatefulWidget {
  final String type;
  const LegalSource({super.key, required this.type});

  @override
  State<LegalSource> createState() => _LegalSourceState();
}

class _LegalSourceState extends State<LegalSource> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Responsive.init(context);
    });
  }

  Widget buildListTile({
    required IconData icon,
    required String title,
    required String legalType,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.getHeightScale(15)),
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
        leading: Icon(icon, color: Colors.green),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.getTextScale(14),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder:
                  (ctx) => TransportMap(type: widget.type, legal: legalType),
            ),
          );
        },
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Legal Source',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.getTextScale(17),
          ),
        ),
        backgroundColor: Colors.green,
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(Responsive.getWidthScale(16)),
        child: ListView(
          children: [
            if (widget.type == 'Charcoal') ...[
              buildListTile(
                icon: Icons.local_fire_department,
                title: 'Wood Charcoal Permit',
                legalType: 'Wood Charcoal Permit',
              ),
            ] else ...[
              buildListTile(
                icon: Icons.verified_user,
                title: 'Certification / Permit from LGU',
                legalType: 'Certification or Permit from LGU',
              ),
              buildListTile(
                icon: Icons.nature,
                title: 'Tree Cutting Permit',
                legalType: 'Tree Cutting Permit',
              ),

              buildListTile(
                icon: Icons.factory,
                title: 'Wood Processing Plant Permit',
                legalType: 'Wood Processing Plant Permit',
              ),
              buildListTile(
                icon: Icons.store,
                title: 'Certificate of Registration as Lumber Dealer',
                legalType: 'Certificate of Registration as Lumber Dealer',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
