import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/home/bottom_navigation.dart';
import 'package:mr_blue/src/services/api_services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String userId;
  const VerifyOtpScreen(this.userId, {super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String _otp = "";
  final ApiService apiService = ApiService();

  Future<void> _verifyOtp() async {
    debugPrint(
      'Verifying OTP for userId: ${widget.userId}, entered OTP: $_otp',
    );
    try {
      String response = await apiService.verifyOtp(widget.userId, _otp);
      debugPrint('API Response: $response');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      Map<String, dynamic> userData = jsonDecode(response);
      await prefs.setString('user_name', userData['name'] ?? 'User');
      await prefs.setString('user_id', userData['user_id'].toString());
      await prefs.setString(
        'user_email',
        userData['email'] ?? 'abc@example.com',
      );
      await prefs.setString('user_mobile', userData['mobile'] ?? '');
      debugPrint('Login status and user data saved');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Bottomnavigation()),
        );
        debugPrint('Navigated to Bottomnavigation');
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      if (mounted) {
        showToastMessage("Please enter a valid OTP");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade100, Colors.blue.shade700],
            ),
            image: DecorationImage(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.dstATop,
              ),
              image: AssetImage("assets/images/login_screen.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Center(
              child: Card(
                color: Colors.blue.shade50.withOpacity(0.8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 18.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          'Please enter OTP sent on your mobile number.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: 1,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 50.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: PinCodeTextField(
                          appContext: context,
                          length: 4,
                          onChanged: (value) {
                            setState(() {
                              _otp = value;
                            });
                          },
                          onCompleted: (value) {
                            setState(() {
                              _otp = value;
                            });
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5.r),
                            fieldHeight: 52.h,
                            fieldWidth: 44.w,
                            activeFillColor: Colors.grey[200],
                            inactiveFillColor: Colors.grey[200],
                            selectedFillColor: Colors.grey[200],
                            activeColor: Colors.black,
                            inactiveColor: Colors.black,
                            selectedColor: Colors.black,
                          ),
                          cursorColor: Colors.black,
                          animationType: AnimationType.fade,
                          enableActiveFill: true,
                          keyboardType: TextInputType.number,
                          textStyle: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 50.h),
                      ElevatedButton(
                        onPressed: _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 4,
                          padding: EdgeInsets.symmetric(
                            vertical: 15.h,
                            horizontal: 50.w,
                          ),
                        ),
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 1,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
