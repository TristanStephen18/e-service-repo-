import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class InspectionDateScreen extends StatefulWidget {
  final String applicationId;

  const InspectionDateScreen({super.key, required this.applicationId});

  @override
  State<InspectionDateScreen> createState() => _InspectionDateScreenState();
}

class _InspectionDateScreenState extends State<InspectionDateScreen> {
  DateTime? inspectionDate;
  bool isLoading = true;
  bool hasNoInspection = false;

  @override
  void initState() {
    super.initState();
    _loadInspectionDate();
  }

  Future<void> _loadInspectionDate() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      var snapshot =
          await FirebaseFirestore.instance
              .collection('mobile_users')
              .doc(user?.uid)
              .collection('applications')
              .doc(widget.applicationId)
              .get();

      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null && data.containsKey('inspection')) {
          Timestamp timestamp = data['inspection'];
          setState(() {
            inspectionDate = timestamp.toDate();
            isLoading = false;
          });
        } else {
          setState(() {
            hasNoInspection = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasNoInspection = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasNoInspection = true;
        isLoading = false;
      });
    }
  }

  void _showPopup(BuildContext context, DateTime selectedDate) {
    final formatted = DateFormat.yMMMMd().format(selectedDate);
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Inspection Scheduled"),
            content: Text("Your inspection is scheduled on:\n$formatted"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inspection Date',
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.green,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              )
              : hasNoInspection
              ? const Center(
                child: Text(
                  'No Inspection Date!',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
              : Column(
                children: [
                  TableCalendar(
                    focusedDay: inspectionDate!,
                    firstDay: DateTime.utc(2020, 01, 01),
                    lastDay: DateTime.utc(2030, 12, 31),
                    selectedDayPredicate: (day) {
                      return isSameDay(inspectionDate, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (isSameDay(selectedDay, inspectionDate)) {
                        _showPopup(context, selectedDay);
                      }
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(color: Colors.white),
                      selectedTextStyle: const TextStyle(color: Colors.white),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ],
              ),
    );
  }
}
