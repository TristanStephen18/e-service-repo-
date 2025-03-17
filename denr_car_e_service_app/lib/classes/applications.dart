import 'package:denr_car_e_service_app/screens/view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Applications extends StatelessWidget {
  const Applications({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: CircleAvatar(
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
              Center(
                child: const Text(
                  'Applications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
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
                  leading: Icon(Icons.file_copy, color: Colors.green),
                  title: Text(
                    "Tree Cutting Permit (Pending)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Application No:0123123"),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(CupertinoPageRoute(builder: (ctx) => Display()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
