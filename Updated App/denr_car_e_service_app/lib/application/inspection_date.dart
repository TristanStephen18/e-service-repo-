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
  List<DateTime> inspectionDates = [];
  DateTime? submissionDate;
  bool isLoading = true;
  bool hasNoInspection = false;

  @override
  void initState() {
    super.initState();
    _loadApplicationData();
  }

  Future<void> _loadApplicationData() async {
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
        if (data != null) {
          List<dynamic> inspectionTimestamps = data['inspection_dates'] ?? [];
          submissionDate = (data['submission_date'] as Timestamp?)?.toDate();

          setState(() {
            inspectionDates =
                inspectionTimestamps
                    .map((ts) => (ts as Timestamp).toDate())
                    .toList();
            hasNoInspection = inspectionDates.isEmpty;
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

  void _showPopupSubmission(BuildContext context, DateTime selectedDate) {
    final formatted = DateFormat.yMMMMd().format(selectedDate);
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Submission Date"),
            content: Text("You Submit your requirements on:\n$formatted"),
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
        runSpacing: 10,
        children: [
          _legendItem(Colors.green, "Inspection Date"),
          _legendItem(Colors.orange, "Submission Date"),
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
          'Activity Date',
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
              : hasNoInspection && submissionDate == null
              ? const Center(
                child: Text(
                  'No Inspection or Submission Data!',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
              : Column(
                children: [
                  _buildLegend(),
                  TableCalendar(
                    focusedDay:
                        inspectionDates.isNotEmpty
                            ? inspectionDates[0]
                            : DateTime.now(),
                    firstDay: DateTime.utc(2020, 01, 01),
                    lastDay: DateTime.utc(2030, 12, 31),
                    selectedDayPredicate: (day) {
                      return inspectionDates.any((d) => isSameDay(d, day));
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (inspectionDates.any(
                        (d) => isSameDay(d, selectedDay),
                      )) {
                        _showPopup(context, selectedDay);
                      } else if (submissionDate != null &&
                          isSameDay(submissionDate!, selectedDay)) {
                        _showPopupSubmission(context, selectedDay);
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
                      defaultBuilder: (context, day, _) {
                        final isInspectionDay = inspectionDates.any(
                          (d) => isSameDay(d, day),
                        );
                        final isSubmissionDay =
                            submissionDate != null &&
                            isSameDay(submissionDate!, day);

                        if (isInspectionDay) {
                          return _buildCalendarDay(day, Colors.green);
                        } else if (isSubmissionDay) {
                          return _buildCalendarDay(day, Colors.orange);
                        }
                        return null;
                      },
                      todayBuilder: (context, day, _) {
                        final isInspectionDay = inspectionDates.any(
                          (d) => isSameDay(d, day),
                        );
                        final isSubmissionDay =
                            submissionDate != null &&
                            isSameDay(submissionDate!, day);

                        if (isInspectionDay) {
                          return _buildCalendarDay(day, Colors.green);
                        } else if (isSubmissionDay) {
                          return _buildCalendarDay(day, Colors.orange);
                        }

                        // If today is neither inspection nor submission, fallback to blue
                        return _buildCalendarDay(day, Colors.blue);
                      },
                      selectedBuilder: (context, day, _) {
                        final isInspectionDay = inspectionDates.any(
                          (d) => isSameDay(d, day),
                        );
                        final isSubmissionDay =
                            submissionDate != null &&
                            isSameDay(submissionDate!, day);

                        if (isInspectionDay) {
                          return _buildCalendarDay(day, Colors.green);
                        } else if (isSubmissionDay) {
                          return _buildCalendarDay(day, Colors.orange);
                        }

                        return _buildCalendarDay(day, Colors.grey);
                      },
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
