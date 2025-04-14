import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/constants.dart';
import 'package:mr_blue/src/core/utils.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("About Us"),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(18.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.aboutUs,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 22.h,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  textAlign: TextAlign.justify,
                  AppConstants.mrblue,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 10.h,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  AppConstants.ourMission,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 22.h,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  textAlign: TextAlign.justify,
                  AppConstants.mission,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 10.h,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  AppConstants.ourVision,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 22.h,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  textAlign: TextAlign.justify,
                  AppConstants.vision,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 10.h,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
