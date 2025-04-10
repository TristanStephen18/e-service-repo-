import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denr_car_e_service_app/classes/applications.dart';
import 'package:denr_car_e_service_app/classes/chat.dart';
import 'package:denr_car_e_service_app/classes/profiles.dart';
import 'package:denr_car_e_service_app/classes/services.dart';
import 'package:flutter/material.dart';
import 'package:denr_car_e_service_app/model/responsive.dart';

class Homepage extends StatefulWidget {
  final String userid;
  const Homepage({super.key, required this.userid});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  String? _userID;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _userID = widget.userid;

    _updateUserStatus('online');

    _screens = [
      const Services(),
      const Applications(),
      const ChatScreen(),
      const Profiles(),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateUserStatus('offline');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_userID == null) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _updateUserStatus('offline');
    } else if (state == AppLifecycleState.resumed) {
      _updateUserStatus('online');
    }
  }

  void _updateUserStatus(String status) {
    if (_userID == null) return;
    FirebaseFirestore.instance.collection('mobile_users').doc(_userID).update({
      'status': status,
      if (status == 'offline') 'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[600],
        elevation: 10.0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: Responsive.getTextScale(12),
        unselectedFontSize: Responsive.getTextScale(10),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy),
            label: 'Applications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
