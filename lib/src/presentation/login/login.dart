import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/login/verify_otp.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileNumber = TextEditingController();
  bool isChecked = false;

  // Future<void> registerUser() async {
  //   final url = Uri.parse(Urls.registerUser);
  //   final response = await http.post(
  //     url,
  //     body: json.encode({
  //       "mobile": mobileNumber.text,
  //     }),
  //     headers: {'Content-Type': 'application/json'},
  //   );

  //   if (response.statusCode == 200) {
  //     final responseData = json.decode(response.body);
  //     if (responseData['Status'] == 'Success') {
  //       print("responseData inside login screen $responseData");

  //       await _saveUserId(responseData['user']['id']);
  //       mobileNumber.clear();

  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => VerifyOtpScreen(
  //             responseData['user']['m_otp'].toString(),
  //           ),
  //         ),
  //       );
  //     } else {
  //       _showSnackBar('Registration failed. Please try again.');
  //     }
  //   } else {
  //     _showSnackBar('An error occurred. Please try again later.');
  //   }
  // }

  // Future<void> _saveUserId(int userId) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt('user_id', userId);
  // }

  // void _showSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(message)),
  //   );
  // }

  void _validateForm() {
    if (!isChecked) {
      showToastMessage('You must accept the conditions to proceed.');
    } else if (mobileNumber.text.isEmpty) {
      showToastMessage('Please enter your phone number.');
    } else {
      // registerUser();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerifyOtpScreen("1234")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade100, Colors.blue.shade700],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.blue.shade900,
                    letterSpacing: 2,
                    fontSize: 44,
                  ),
                ),
                const SizedBox(height: 24),
                Image.asset(
                  'assets/images/mr-blue-logo.png',
                  fit: BoxFit.cover,
                  height: 80,
                ),

                const SizedBox(height: 24),
                Text(
                  ' Have your clothes cleaned effortlessly. with just a tap of your finger. ​',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.indigo.shade900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 36),
                TextField(
                  controller: mobileNumber,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Enter Phone Number',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 1,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: Colors.black,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value ?? false;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the terms and conditions page
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => TermsAndConditionsPage(),
                        //   ),
                        // );
                      },
                      child: Text(
                        "Accept Terms & Conditions.",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 1,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _validateForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50.0,
                      vertical: 10.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'GET OTP',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 1,
                      fontSize: 16,
                    ),
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
