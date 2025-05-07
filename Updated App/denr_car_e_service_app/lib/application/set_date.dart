import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class SetDateScreen extends StatefulWidget {
  final String applicationId;

  const SetDateScreen({super.key, required this.applicationId});

  @override
  State<SetDateScreen> createState() => _SetDateScreenState();
}

class _SetDateScreenState extends State<SetDateScreen> {
  Set<DateTime> selectedInspectionDates = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInspectionDates();
  }

  // Fetch selected dates from Firestore
  Future<void> _loadInspectionDates() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot applicationDoc =
          await FirebaseFirestore.instance
              .collection('mobile_users')
              .doc(user?.uid)
              .collection('applications')
              .doc(widget.applicationId)
              .get();

      if (applicationDoc.exists) {
        List<dynamic> dates = applicationDoc['user_inspection_dates'] ?? [];
        selectedInspectionDates =
            dates.map((date) => (date as Timestamp).toDate()).toSet();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load inspection dates.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveInspectionDates(Set<DateTime> dates) async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('mobile_users')
          .doc(user?.uid)
          .collection('applications')
          .doc(widget.applicationId)
          .update({
            'user_inspection_dates':
                dates.map((d) => Timestamp.fromDate(d)).toList(),
          });

      setState(() {
        isLoading = false;
      });

      _showConfirmationPopup(dates);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save inspection dates.")),
      );
    }
  }

  void _showConfirmationPopup(Set<DateTime> dates) {
    final formattedDates = dates
        .map((d) => DateFormat.yMMMMd().format(d))
        .join("\n");

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Inspection Dates Set"),
            content: Text("You selected:\n$formattedDates"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Wrap(
        spacing: 16,
        children: [
          _legendItem(Colors.green, "Selected Inspection Dates"),
          _legendItem(Colors.blue, "Today"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set Inspection Date',
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
              : Column(
                children: [
                  _buildLegend(),
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 01, 01),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: DateTime.now(),
                    selectedDayPredicate: (day) {
                      return selectedInspectionDates.any(
                        (d) => isSameDay(d, day),
                      );
                    },
                    onDaySelected: (selectedDay, focusedDay) async {
                      setState(() {
                        final alreadySelected = selectedInspectionDates.any(
                          (d) => isSameDay(d, selectedDay),
                        );
                        if (alreadySelected) {
                          selectedInspectionDates.removeWhere(
                            (d) => isSameDay(d, selectedDay),
                          );
                        } else {
                          selectedInspectionDates.add(selectedDay);
                        }
                      });

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text("Confirm Dates"),
                              content: const Text(
                                "Save selected inspection date?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text("Confirm"),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        await _saveInspectionDates(selectedInspectionDates);
                      }
                    },
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(color: Colors.white),
                    ),
                    calendarBuilders: CalendarBuilders(
                      selectedBuilder:
                          (context, day, _) =>
                              _buildCalendarDay(day, Colors.green),
                      todayBuilder:
                          (context, day, _) =>
                              _buildCalendarDay(day, Colors.blue),
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

  Widget _buildCalendarDay(DateTime day, Color color) {
    return Center(
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
