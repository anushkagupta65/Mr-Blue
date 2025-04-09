import 'package:flutter/material.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/home/bottom_navigation.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String otp;
  const VerifyOtpScreen(this.otp, {super.key});
  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String _otp = "";
  int? userId;
  final TextEditingController _otpController = TextEditingController();

  void _verifyOtp() {
    if (_otp == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Bottomnavigation()),
      );
    } else {
      showToastMessage("Please enter valid OTP");
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _getUserId();
  // }

  // @override
  // void dispose() {
  //   _otpController.dispose();
  //   super.dispose();
  // }

  // Future<void> _getUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     userId = prefs.getInt('user_id');
  //   });
  // }

  // Future<void> _verifyOtp() async {
  //   if (userId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('User ID not found. Please register again.')),
  //     );
  //     return;
  //   }

  //   final url = Uri.parse(Urls.otpVerify);
  //   try {
  //     final response = await http.post(
  //       url,
  //       body: json.encode({'otp': _otp, 'user_id': userId}),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       print("responseData inside verify otp  ${responseData}");
  //       if (responseData['Status'] == 'Success') {
  //         final prefs = await SharedPreferences.getInstance();
  //         await prefs.setInt('user_id', responseData['user_id']);
  //         await prefs.setString('mobile', responseData['mobile']);
  //         await prefs.setString('email', responseData['email']);
  //         await prefs.setString('name', responseData['name']);
  //         await prefs.setString(
  //           'userAddress',
  //           responseData['address']['house'] +
  //               ', ' +
  //               responseData['address']['landmark'] +
  //               ', ' +
  //               responseData['address']['address'],
  //         );
  //         print(responseData['name']);
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => const Bottomnavigation()),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Invalid OTP. Please try again.')),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('An error occurred. Please try again later.')),
  //       );
  //     }
  //   } catch (e) {
  //     if (_otp == widget.OTP.toString()) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => const Bottomnavigation()),
  //       );
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Login Successful')));
  //     }
  //   }

  //   setState(() {
  //     _otp = "";
  //     _otpController.clear();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Center(
            child: Card(
              color: Colors.blue.shade50.withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Please enter OTP sent on your mobile number.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: 1,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 4,
                        controller: _otpController,
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
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 66,
                          fieldWidth: 52,
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
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        _verifyOtp();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 50,
                        ),
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 1,
                            fontSize: 18,
                          ),
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
    );
  }
}
