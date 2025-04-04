import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileWidget({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black, size: 24),

              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.black, size: 14),
        ],
      ),
    );
  }
}
