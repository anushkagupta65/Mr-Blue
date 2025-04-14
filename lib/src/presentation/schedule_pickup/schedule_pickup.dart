import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/schedule_pickup/order_summary.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  String finalDate = '';
  String finalHour = '';
  List<DateTime> weekDates = List.generate(
    7,
    (index) => DateTime.now().add(Duration(days: index)),
  );
  List<Map<String, dynamic>> availableTimes = [];
  int? timeid;
  int selectedValue = 1;
  int expressService = 1;
  List<dynamic> addresses = [];
  bool isLoading = false;
  String userId = '123';
  final DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Automatically select today's date and load time slots
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onDateTap(context, currentDate, setState, userId);
    });
  }

  Future<void> fetchTime() async {
    bool isToday =
        selectedDate != null &&
        selectedDate!.year == currentDate.year &&
        selectedDate!.month == currentDate.month &&
        selectedDate!.day == currentDate.day;
    finalHour =
        isToday
            ? DateFormat('HH').format(DateTime.now().add(Duration(hours: 2)))
            : '06';

    if (finalDate.isNotEmpty && finalHour.isNotEmpty) {
      final response = await http.get(
        Uri.parse(
          'https://fabspin.org/api/check-available-time/$finalDate/$finalHour/pick',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          availableTimes = List<Map<String, dynamic>>.from(
            json.decode(response.body),
          );
        });
      } else {
        throw Exception('Failed to load data');
      }
    }
  }

  DateTime? getSelectedDateTime() {
    if (selectedDate != null && timeid != null) {
      final selectedTime = availableTimes.firstWhere(
        (time) => time['id'] == timeid,
        orElse: () => {},
      );
      if (selectedTime.isNotEmpty) {
        int startHour = selectedTime['start_time'];
        return DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          startHour,
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("mr. blue"),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade100],
            end: Alignment.topCenter,
            begin: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 6.r,
                    offset: Offset(0, 6.r),
                  ),
                ],
              ),
              padding: EdgeInsets.all(14.r),
              child: SizedBox(
                height: 64.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDates.length,
                  itemBuilder: (context, index) {
                    DateTime date = weekDates[index];
                    String dayOfWeek = DateFormat('EEE').format(date);
                    String dayOfMonth = DateFormat('d').format(date);
                    String month = DateFormat('MMM').format(date);
                    bool isSelected =
                        selectedDate != null &&
                        date.day == selectedDate!.day &&
                        date.month == selectedDate!.month &&
                        date.year == selectedDate!.year;

                    return GestureDetector(
                      onTap: () {
                        onDateTap(context, date, setState, userId);
                      },
                      child: Container(
                        width: 60.w,
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(6.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4.r,
                              offset: Offset(0, 2.r),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$dayOfWeek\n$dayOfMonth $month',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : availableTimes.isNotEmpty
                        ? GridView.builder(
                          itemCount: availableTimes.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: 1.5,
                              ),
                          itemBuilder: (context, index) {
                            final time = availableTimes[index];
                            bool isSelected = timeid == time['id'];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  timeid = time['id'];
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.blue.shade700
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.blue.shade700
                                            : Colors.grey[400]!,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 4.r,
                                      offset: Offset(0, 1.r),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      time['combine_time'].toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                        : Center(
                          child: Text(
                            selectedDate == null
                                ? 'Select a date to view time slots'
                                : 'No time slots available',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      checkmarkColor: Colors.white,
                      label: Text(
                        'Express Service',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color:
                              selectedValue == 0 ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: selectedValue == 0,
                      selectedColor: Colors.blue.shade700,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedValue = 0;
                            expressService = 1;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ChoiceChip(
                      checkmarkColor: Colors.white,
                      label: Text(
                        'Normal Service',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color:
                              selectedValue == 1 ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: selectedValue == 1,
                      selectedColor: Colors.blue.shade700,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      onSelected: (selected) {
                        if (selected)
                          setState(() {
                            selectedValue = 1;
                            expressService = 0;
                          });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: ElevatedButton(
                onPressed: () {
                  DateTime? pickupDateTime = getSelectedDateTime();
                  if (pickupDateTime != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => OrderSummaryScreen(
                              pickupDateTime: pickupDateTime,
                            ),
                      ),
                    );
                  } else {
                    showToastMessage('Please select a date and time slot');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Schedule',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDateTap(
    BuildContext context,
    DateTime date,
    Function setState,
    String userId,
  ) async {
    setState(() {
      selectedDate = date;
      finalDate = DateFormat('yyyy-MM-dd').format(date);
      availableTimes.clear();
      isLoading = true;
      timeid = null; // Reset time selection when date changes
    });
    try {
      await fetchTime();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching times: $e");
      setState(() {
        isLoading = false;
      });
      showToastMessage('Failed to load time slots');
    }
  }
}
