import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/drawer/screens/contact_us.dart';
import 'package:mr_blue/src/presentation/drawer/screens/logout.dart';
import 'package:mr_blue/src/presentation/drawer/screens/my_orders.dart';
import 'package:mr_blue/src/presentation/drawer/screens/price_list.dart';
import 'package:mr_blue/src/presentation/home/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

int _activeDrawerIndex = 1;

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
                        'assets/images/primary_logo.png',
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
                                fontSize: 15.sp,
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
            menuTile(
              icon: Icon(
                Icons.home,
                color:
                    _activeDrawerIndex == 1 ? Colors.white : Colors.blue[900],
                size: 20.sp,
              ),
              title: 'Home',
              index: 1,
              isActive: _activeDrawerIndex == 1,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 1;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Bottomnavigation(),
                  ),
                );
              },
            ),
            customDivider(),
            // menuTile(
            //   icon: Icon(
            //     Icons.shopping_bag_outlined,
            //     color:
            //         _activeDrawerIndex == 1 ? Colors.white : Colors.blue[900],
            //     size: 20.sp,
            //   ),
            //   title: 'My Requests',
            //   index: 3,
            //   isActive: _activeDrawerIndex == 3,
            //   onTap: () {
            //     setState(() {
            //       _activeDrawerIndex = 3;
            //     });
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => MyRequests()),
            //     );
            //   },
            // ),
            // customDivider(),
            menuTile(
              icon: Image.asset(
                "assets/images/orders-icon.png",
                color:
                    _activeDrawerIndex == 2 ? Colors.white : Colors.blue[900],
                height: 18.h,
              ),
              title: 'My Orders',
              index: 2,
              isActive: _activeDrawerIndex == 2,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 2;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrders()),
                );
              },
            ),
            customDivider(),
            menuTile(
              icon: Image.asset(
                "assets/images/rupee-price-list-icon.png",
                color:
                    _activeDrawerIndex == 3 ? Colors.white : Colors.blue[900],
                height: 18.h,
              ),
              title: 'Price List',
              index: 3,
              isActive: _activeDrawerIndex == 3,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 3;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PriceList()),
                );
              },
            ),
            customDivider(),
            menuTile(
              icon: Image.asset(
                "assets/images/feedback-icon.png",
                color:
                    _activeDrawerIndex == 4 ? Colors.white : Colors.blue[900],
                height: 18.h,
              ),
              title: 'Contact Us',
              index: 4,
              isActive: _activeDrawerIndex == 4,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 4;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactUs()),
                );
              },
            ),
            customDivider(),
            menuTile(
              icon: Icon(
                Icons.logout,
                color:
                    _activeDrawerIndex == 5 ? Colors.white : Colors.blue[900],
                size: 20.sp,
              ),
              title: 'Logout ',
              index: 5,
              isActive: _activeDrawerIndex == 5,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 5;
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

  Widget menuTile({
    required Widget icon,
    required String title,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[800] : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 16.w, top: 4.h, bottom: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                icon,
                SizedBox(width: 16.w),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
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
