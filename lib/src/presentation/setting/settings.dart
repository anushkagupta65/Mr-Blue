import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/drawer/drawer.dart';
import 'package:mr_blue/src/presentation/home/map_screen.dart';
import 'package:mr_blue/src/presentation/login/terms_and_conditions.dart';
import 'package:mr_blue/src/presentation/setting/screens/about_us.dart';
import 'package:mr_blue/src/presentation/setting/screens/profile.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Color blueColor = Colors.blue.shade900;

  TextStyle textStyle = TextStyle(
    color: Colors.blue.shade900,
    fontSize: 14.sp,
    fontWeight: FontWeight.w900,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("mr. blue"),
      drawer: CustomDrawer(),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyProfile()),
                  );
                },
                child: ListTile(
                  title: Text("My Profile", style: textStyle),
                  leading: Icon(
                    Icons.person_outline,
                    color: blueColor,
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(height: 7.h),
              customDivider(),
              SizedBox(height: 7.h),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(calledFrom: "setting"),
                    ),
                  );
                },
                child: ListTile(
                  title: Text("Address", style: textStyle),
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: blueColor,
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(height: 7.h),
              customDivider(),
              SizedBox(height: 7.h),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutUs()),
                  );
                },
                child: ListTile(
                  title: Text("About us", style: textStyle),
                  leading: Image.asset(
                    "assets/images/round-information-outline-black-icon.png",
                    color: blueColor,
                    height: 20.h,
                  ),
                ),
              ),
              SizedBox(height: 7.h),
              customDivider(),
              SizedBox(height: 7.h),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsAndConditions(),
                    ),
                  );
                },
                child: ListTile(
                  title: Text("Terms & Conditions", style: textStyle),
                  leading: Image.asset(
                    "assets/images/terms-and-conditions-icon.png",
                    color: blueColor,
                    height: 20.h,
                  ),
                ),
              ),
              SizedBox(height: 7.h),
              customDivider(),
              SizedBox(height: 7.h),
              InkWell(
                onTap: () {
                  shareApplication();
                },
                child: ListTile(
                  title: Text("Share", style: textStyle),
                  leading: Icon(Icons.share, color: blueColor, size: 24.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
