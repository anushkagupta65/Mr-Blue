import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/presentation/home/bottom_navigation.dart';

class BookingConfirmation extends StatefulWidget {
  const BookingConfirmation({super.key});

  @override
  State<BookingConfirmation> createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/Verified.gif', height: 120.h),
              SizedBox(height: 20.h),
              Text(
                "Booking Confirmed",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontSize: 24.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 80.w),
                child: Divider(height: 1.h, color: Colors.black),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.all(8.sp),
                child: Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    "Your booking has been confirmed successfully.",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 80.h),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Bottomnavigation(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: Colors.black, width: 1.2.w),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 20.w,
                    ),
                    child: Text(
                      "Done",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 1,
                        fontSize: 16.sp,
                      ),
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
