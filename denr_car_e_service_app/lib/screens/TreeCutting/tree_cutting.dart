import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TreeCuttingChoices extends StatelessWidget {
  const TreeCuttingChoices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tree Cutting Type')),
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
                      color: Colors.grey,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.public, color: Colors.green),
                  title: Text(
                    "Public safety Permit",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // Navigator.of(context).push(
                    //   CupertinoPageRoute(
                    //     builder: (ctx) => ChainsawRegistrationScreen(),
                    //   ),
                    // );
                  },
                  subtitle: Text("For removal of trees in public places."),
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
                      color: Colors.grey,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.landscape, color: Colors.green),
                  title: Text(
                    "Private Land Timber Permit",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {},
                  subtitle: Text("For trees within private lands"),
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
                      color: Colors.grey,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const ListTile(
                  leading: Icon(Icons.security, color: Colors.green),
                  title: Text(
                    "National Government Agencies Permit",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "For trees affected by national government agency projects.",
                  ),
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
