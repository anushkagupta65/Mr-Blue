import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/drawer/screens/logout.dart';
import 'package:mr_blue/src/presentation/drawer/screens/my_orders.dart';
import 'package:mr_blue/src/presentation/drawer/screens/my_requests.dart';
import 'package:mr_blue/src/presentation/home/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

int _activeDrawerIndex = 0;

class _CustomDrawerState extends State<CustomDrawer> {
  String _name = '';
  String _email = '';
  String _mobile = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'User';
      _email = prefs.getString('user_email') ?? 'No email';
      _mobile = prefs.getString('user_mobile') ?? 'No mobile';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 0.70.sw,
      elevation: 16.0,
      shadowColor: Colors.black.withOpacity(0.3),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 120.h,
              color: Colors.blue[800],
              child: Padding(
                padding: EdgeInsets.only(left: 10.w, top: 30.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 32.r,
                      child: Image.asset(
                        'assets/images/mr-blue-logo.png',
                        fit: BoxFit.cover,
                        height: 30.h,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 8.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 1,
                                fontSize: 15.sp, // Responsive font size
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Padding(
                              padding: EdgeInsets.only(right: 5.w),
                              child: Text(
                                _email,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.6),
                                  letterSpacing: 1,
                                  fontSize: 8.sp,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Padding(
                              padding: EdgeInsets.only(right: 5.w),
                              child: Text(
                                _mobile,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                  fontSize: 12.sp,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildMenuItem(
              icon: Icons.home,
              title: 'Home',
              index: 0,
              isActive: _activeDrawerIndex == 0,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 0;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Bottomnavigation(),
                  ),
                );
              },
            ),
            customDivider(),
            _buildMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'My Requests',
              index: 3,
              isActive: _activeDrawerIndex == 3,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 3;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyRequests()),
                );
              },
            ),
            customDivider(),
            _buildMenuItem(
              icon: Icons.shopping_cart_outlined,
              title: 'My Orders',
              index: 4,
              isActive: _activeDrawerIndex == 4,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 4;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrders()),
                );
              },
            ),
            customDivider(),
            _buildMenuItem(
              icon: Icons.currency_rupee_outlined,
              title: 'Pay Now',
              index: 5,
              isActive: _activeDrawerIndex == 5,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 5;
                });
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => PayNow()),
                // );
              },
            ),
            customDivider(),
            _buildMenuItem(
              icon: Icons.price_change_outlined,
              title: 'Price List',
              index: 6,
              isActive: _activeDrawerIndex == 6,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 6;
                });
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const PrizeList()),
                // );
              },
            ),
            customDivider(),
            _buildMenuItem(
              icon: Icons.mail_outline,
              title: 'Contact Us',
              index: 7,
              isActive: _activeDrawerIndex == 7,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 7;
                });
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const ContactUs()),
                // );
              },
            ),
            customDivider(),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Logout ',
              index: 9,
              isActive: _activeDrawerIndex == 9,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 9;
                });
                Navigator.pop(context);
                LogoutDialog.show(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[800] : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 18.w, top: 5.h, bottom: 5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.blue[900],
                  size: 20.sp,
                ),
                SizedBox(width: 20.w),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : Colors.blue[900],
                    letterSpacing: 1,
                    fontSize: 14.sp,
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
