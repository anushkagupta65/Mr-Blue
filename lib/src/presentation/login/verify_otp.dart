import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/home/bottom_navigation.dart';
import 'package:mr_blue/src/presentation/home/map_screen.dart';
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
  bool _isLoading = false;
  final ApiService apiService = ApiService();

  Future<void> _verifyOtp() async {
    debugPrint(
      'Verifying OTP for userId: ${widget.userId}, entered OTP: $_otp',
    );

    // Validate OTP length
    if (_otp.length != 4) {
      showToastMessage("Please enter a valid 4-digit OTP");
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Call the API to verify OTP
      String response = await apiService.verifyOtp(widget.userId, _otp);
      debugPrint('API Response: $response');

      // Parse the response
      Map<String, dynamic> responseData = jsonDecode(response);

      // Check if the response indicates success
      if (responseData['Status'] == 'Success') {
        // Save user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('user_name', responseData['name'] ?? 'User');
        await prefs.setString('user_id', responseData['user_id'].toString());
        await prefs.setString(
          'user_email',
          responseData['email'] ?? 'example@gmail.com',
        );
        await prefs.setString('user_mobile', responseData['mobile'] ?? '');
        debugPrint('Login status and user data saved');

        // Check user address and navigate accordingly
        String? userAddress = prefs.getString('user_address');
        if (mounted) {
          if (userAddress == null || userAddress.isEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MapScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Bottomnavigation()),
            );
            debugPrint('Navigated to Bottomnavigation');
          }
        }
      } else {
        // Handle invalid OTP or API error response
        if (mounted) {
          showToastMessage(
            responseData['message'] ?? "Invalid OTP. Please try again.",
          );
        }
      }
    } catch (e) {
      // Handle any exceptions (e.g., network errors, JSON parsing issues)
      debugPrint('Error verifying OTP: $e');
      if (mounted) {
        showToastMessage("An error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                        onPressed: _isLoading ? null : _verifyOtp,
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
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                )
                                : Text(
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
