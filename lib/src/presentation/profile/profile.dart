import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  int? userId;
  String _mobile = '';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 80.r,
                    child: Image.asset(
                      'assets/images/mr-blue-logo.png',
                      fit: BoxFit.cover,
                      height: 64.h,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade900),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Icon(Icons.person_outline, color: Colors.blue.shade900),
                        SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: _name,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.blue.shade900),
                              hintText: "Name",
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade900,
                              letterSpacing: 1,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  InkWell(
                    onTap: () {
                      showToastMessage("Contact number cannot be changed");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade900),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Icon(Icons.phone, color: Colors.blue.shade900),
                          SizedBox(width: 2),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              _mobile,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade900,
                                letterSpacing: 1,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade900),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Icon(Icons.mail, color: Colors.blue.shade900),
                        SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: _email,
                            decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(color: Colors.blue.shade900),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade900,
                              letterSpacing: 1,
                              fontSize: 12,
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
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 56, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Update Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 1,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
