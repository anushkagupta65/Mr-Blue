import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutDialog {
  static void show(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          message: Text(
            "Do you really want to logout?",
            style: TextStyle(fontSize: 16.sp, color: Colors.black87),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove("user_id");
                await prefs.remove("user_name");
                await prefs.remove("user_email");
                await prefs.setBool("isLoggedIn", false);

                FocusScope.of(context).unfocus();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );

                showToastMessage("User logged out successfully.");
              },
              child: Text(
                "Logout",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
            isDefaultAction: true,
            child: Text(
              "Cancel",
              style: TextStyle(fontSize: 16.sp, color: Colors.black54),
            ),
          ),
        );
      },
    );
  }
}
