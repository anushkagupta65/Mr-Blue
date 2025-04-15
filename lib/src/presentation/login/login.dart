import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/login/terms_and_conditions.dart';
import 'package:mr_blue/src/presentation/login/verify_otp.dart';
import 'package:mr_blue/src/services/api_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileNumber = TextEditingController();
  bool isChecked = false;
  bool isLoading = false;
  final ApiService apiService = ApiService();

  bool isValidMobileNumber(String mobile) {
    final RegExp mobileRegExp = RegExp(r'^\d{10}$');
    return mobileRegExp.hasMatch(mobile);
  }

  Future<void> submitMobileNumber() async {
    if (!isChecked) {
      showToastMessage('You must accept the conditions to proceed.');
      return;
    }

    String mobile = mobileNumber.text.trim();
    if (mobile.isEmpty) {
      showToastMessage('Please enter your phone number.');
      return;
    }

    if (!isValidMobileNumber(mobile)) {
      showToastMessage('Please enter a valid 10-digit mobile number.');
      return;
    }

    setState(() => isLoading = true);

    try {
      String response = await apiService.registerNewUser(mobile);
      print("This is response = $response");
      if (response.isEmpty) {
        showToastMessage('Failed to send OTP. Please try again.');
        return;
      }

      Map<String, dynamic> responseData = jsonDecode(response);
      String userId = responseData['user']['id'].toString();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => VerifyOtpScreen(userId)),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        showToastMessage(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
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
              image: const AssetImage("assets/images/login_screen.png"),
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
                    vertical: 12.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.indigo.shade900,
                          letterSpacing: 2,
                          fontSize: 28.sp,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Image.asset(
                        'assets/images/mr-blue-logo.png',
                        fit: BoxFit.cover,
                        height: 64.h,
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Have your clothes cleaned effortlessly with just a tap of your finger.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 36.h),
                      TextField(
                        controller: mobileNumber,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter Phone Number',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            letterSpacing: 1,
                            fontSize: 10.sp,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15.h,
                            horizontal: 20.w,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isChecked,
                            activeColor: Colors.indigo.shade900,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value ?? false;
                              });
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const TermsAndConditions(),
                                ),
                              );
                            },
                            child: Text(
                              "Accept Terms & Conditions.",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                letterSpacing: 1,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: isLoading ? null : submitMobileNumber,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 50.w,
                            vertical: 10.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child:
                            isLoading
                                ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.w,
                                    color: Colors.black,
                                  ),
                                )
                                : Text(
                                  'GET OTP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    letterSpacing: 1,
                                    fontSize: 14.sp,
                                  ),
                                ),
                      ),
                      SizedBox(height: 12.h),
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

  @override
  void dispose() {
    mobileNumber.dispose();
    super.dispose();
  }
}
