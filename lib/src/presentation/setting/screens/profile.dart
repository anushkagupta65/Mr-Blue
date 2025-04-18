import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  String _userId = '';
  String _mobile = '';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name.text = prefs.getString('user_name') ?? 'User';
      _email.text = prefs.getString('user_email') ?? 'No email';
      _mobile = prefs.getString('user_mobile') ?? 'No mobile';
      _userId = prefs.getString('user_id') ?? '';
    });
  }

  Future<void> _updateProfile() async {
    if (_userId.isEmpty) {
      showToastMessage("User ID not found. Please log in again.");
      return;
    }

    try {
      String response = await _apiService.updateProfile(
        _userId,
        _name.text,
        _email.text,
      );
      print(response);
      Map<String, dynamic> userData = jsonDecode(response);
      if (userData['Status'] == 'Success') {
        Navigator.of(context).pop();
        showToastMessage("Profile updated successfully");
      } else {
        showToastMessage("Failed to update profile: ${userData['message']}");
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _name.text);
      await prefs.setString('user_email', _email.text);
      showToastMessage("Profile updated successfully");
    } catch (e) {
      showToastMessage("Failed: $e");
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    super.dispose();
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 80.r,
                                child: Image.asset(
                                  'assets/images/primary_logo.png',
                                  fit: BoxFit.cover,
                                  height: 64.h,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.w),
                                  border: Border.all(
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.person_outline,
                                      color: Colors.blue.shade900,
                                      size: 24.sp,
                                    ),
                                    SizedBox(width: 15.w),
                                    Expanded(
                                      child: TextField(
                                        controller: _name,
                                        decoration: InputDecoration(
                                          hintStyle: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 12.sp,
                                          ),
                                          hintText: "Name",
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue.shade900,
                                          letterSpacing: 1,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15.h),
                              InkWell(
                                onTap: () {
                                  showToastMessage(
                                    "Contact number cannot be changed",
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.w),
                                    border: Border.all(
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8.w),
                                      Icon(
                                        Icons.phone,
                                        color: Colors.blue.shade900,
                                        size: 24.sp,
                                      ),
                                      SizedBox(width: 2.w),
                                      Padding(
                                        padding: EdgeInsets.all(15.w),
                                        child: Text(
                                          _mobile,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue.shade900,
                                            letterSpacing: 1,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.h),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.w),
                                  border: Border.all(
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.mail,
                                      color: Colors.blue.shade900,
                                      size: 24.sp,
                                    ),
                                    SizedBox(width: 15.w),
                                    Expanded(
                                      child: TextField(
                                        controller: _email,
                                        decoration: InputDecoration(
                                          hintText: "Email",
                                          hintStyle: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 12.sp,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue.shade900,
                                          letterSpacing: 1,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              padding: EdgeInsets.symmetric(
                                horizontal: 56.w,
                                vertical: 16.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.w),
                              ),
                            ),
                            onPressed: _updateProfile,
                            child: Text(
                              'Update Profile',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 1,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
