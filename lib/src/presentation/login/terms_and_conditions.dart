import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/constants.dart';
import 'package:mr_blue/src/core/utils.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(18.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.termsAndConditions,
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 22.h,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    textAlign: TextAlign.justify,
                    AppConstants.tAndCHeading,
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 12.h,
                      wordSpacing: 0.6,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  textWithBullet(AppConstants.tAndC1),
                  textWithBullet(AppConstants.tAndC2),
                  textWithBullet(AppConstants.tAndC3),
                  textWithBullet(AppConstants.tAndC4),
                  textWithBullet(AppConstants.tAndC5),
                  textWithBullet(AppConstants.tAndC6),
                  textWithBullet(AppConstants.tAndC7),
                  textWithBullet(AppConstants.tAndC8),
                  textWithBullet(AppConstants.tAndC9),
                  textWithBullet(AppConstants.tAndC10),
                  textWithBullet(AppConstants.tAndC11),
                  textWithBullet(AppConstants.tAndC12),
                  textWithBullet(AppConstants.tAndC13),
                  textWithBullet(AppConstants.tAndC14),
                  textWithBullet(AppConstants.tAndC15),
                  textWithBullet(AppConstants.tAndC16),
                  textWithBullet(AppConstants.tAndC17),
                  textWithBullet(AppConstants.tAndC18),
                  textWithBullet(AppConstants.tAndC19),
                  textWithBullet(AppConstants.tAndC20),
                  SizedBox(height: 6.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textWithBullet(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "➤ ",
            style: TextStyle(fontSize: 14.sp, color: Colors.blue.shade900),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 12.sp,
                wordSpacing: 0.6,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
