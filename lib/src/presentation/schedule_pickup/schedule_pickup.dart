import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/schedule_pickup/screens/order_summary.dart';
import 'package:mr_blue/src/services/api_services.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ApiService apiService = ApiService();
  DateTime? selectedDate;
  String finalDate = '';
  String finalHour = '';
  List<DateTime> weekDates = List.generate(
    7,
    (index) => DateTime.now().add(Duration(days: index)),
  );
  List<Map<String, dynamic>> availableTimes = [];
  int? timeid;
  int selectedValue = -1;
  String? sameOrNextDay;
  List<dynamic> addresses = [];
  bool isLoading = false;
  final DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onDateTap(context, currentDate);
    });
  }

  Future<void> fetchTime() async {
    try {
      bool isToday =
          selectedDate != null &&
          selectedDate!.year == DateTime.now().year &&
          selectedDate!.month == DateTime.now().month &&
          selectedDate!.day == DateTime.now().day;

      final currentHour = DateTime.now().hour;
      final currentMinute = DateTime.now().minute;

      finalHour =
          isToday
              ? DateFormat('HH').format(DateTime.now().add(Duration(hours: 2)))
              : '06';

      if (finalDate.isNotEmpty && finalHour.isNotEmpty) {
        final response = await apiService.checkAvailableTime(finalDate);
        final responseBody = json.decode(response);

        if (responseBody != null && responseBody is List) {
          List<Map<String, dynamic>> filteredTimes =
              List<Map<String, dynamic>>.from(responseBody).where((slot) {
                if (!isToday) {
                  return true;
                }

                int startTime = slot['start_time'];
                return startTime > currentHour ||
                    (startTime == currentHour && currentMinute < 30);
              }).toList();

          setState(() {
            availableTimes = filteredTimes;
          });
        } else {
          throw Exception('Invalid response format');
        }
      }
    } catch (e) {
      print('Error fetching time slots: $e');
      setState(() {
        availableTimes = [];
      });
    }
  }

  String? getSelectedDateTime() {
    if (selectedDate != null) {
      final dateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      );
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
    return null;
  }

  void onDateTap(BuildContext context, DateTime date) async {
    setState(() {
      selectedDate = date;
      finalDate = DateFormat('yyyy-MM-dd').format(date);
      availableTimes.clear();
      isLoading = true;
      timeid = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("mr. blue"),
      body: SafeArea(
        child: Container(
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
                          onDateTap(context, date);
                        },
                        child: Container(
                          width: 60.w,
                          margin: EdgeInsets.only(right: 8.w),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.blue.shade100
                                    : Colors.white,
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
                                  childAspectRatio: 2,
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
                          'Same Day',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                            color:
                                selectedValue == 0
                                    ? Colors.white
                                    : Colors.black,
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
                          setState(() {
                            if (selectedValue == 0) {
                              selectedValue = -1;
                              sameOrNextDay = null;
                            } else {
                              selectedValue = 0;
                              sameOrNextDay = "1";
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ChoiceChip(
                        checkmarkColor: Colors.white,
                        label: Text(
                          'Next Day',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                            color:
                                selectedValue == 1
                                    ? Colors.white
                                    : Colors.black,
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
                          setState(() {
                            if (selectedValue == 1) {
                              selectedValue = -1;
                              sameOrNextDay = null;
                            } else {
                              selectedValue = 1;
                              sameOrNextDay = "1";
                            }
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
                    String? pickupDate = getSelectedDateTime();
                    if (pickupDate != null && timeid != null) {
                      final selectedTime = availableTimes.firstWhere(
                        (time) => time['id'] == timeid,
                        orElse: () => {},
                      );
                      if (selectedTime.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => OrderSummaryScreen(
                                  sameOrNextDay: sameOrNextDay.toString(),
                                  picdate: pickupDate,
                                  timeSlot:
                                      selectedTime['combine_time'].toString(),
                                  timeSlotId: selectedTime['id'].toString(),
                                  selectedValue: selectedValue.toString(),
                                ),
                          ),
                        );
                      } else {
                        showToastMessage('Please select a valid time slot');
                      }
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
      ),
    );
  }
}
