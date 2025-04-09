import 'package:flutter/material.dart';
import 'package:mr_blue/src/core/utils.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

int _activeDrawerIndex = 0;

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 16.0,
      shadowColor: Colors.black.withOpacity(0.3),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.blue[800],
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        // child: profileImg != null && profileImg!.isNotEmpty
                        //     ? Image.network(
                        //         profileImg!,
                        //         fit: BoxFit.cover,
                        //         width: 70,
                        //         height: 70,
                        //       )
                        //     : Image.asset(
                        //         'assets/images/Fabspin.png',
                        //         fit: BoxFit.cover,
                        //         width: 70,
                        //         height: 70,
                        //       ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Anushka",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 1,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              "Noida, India",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.6),
                                letterSpacing: 1,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              "Wallet: Rs. ",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 1,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            customDivider(),
            _buildMenuItem(
              icon: Icons.home,
              title: 'Home',
              index: 0,
              isActive: _activeDrawerIndex == 0,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 0;
                });
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const Bottomnavigation(),
                //   ),
                // );
              },
            ),
            customDivider(),
            _buildMenuItem(
              icon: Icons.announcement_outlined,
              title: 'Promotions & Offers',
              index: 1,
              isActive: _activeDrawerIndex == 1,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 1;
                });
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const Promotions()),
                // );
              },
            ),
            customDivider(),
            _buildMenuItem(
              icon: Icons.delivery_dining_outlined,
              title: 'Request Pickup',
              index: 2,
              isActive: _activeDrawerIndex == 2,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 2;
                });
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const RequestPickup(),
                //   ),
                // );
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
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => MyRequest()),
                // );
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
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const OrderScreen()),
                // );
              },
            ),
            customDivider(),
            _buildMenuItem(
              icon: Icons.currency_rupee_outlined,
              title: 'Pay  Now',
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
              title: 'Price  List',
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
              icon: Icons.settings,
              title: 'Settings',
              index: 8,
              isActive: _activeDrawerIndex == 8,
              onTap: () {
                setState(() {
                  _activeDrawerIndex = 8;
                });
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const Setting()),
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
                // _handleLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildMenuItem({
  required IconData icon,
  required String title,
  required int index,
  required bool isActive,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
    child: InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[800] : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 18.0, top: 5, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: isActive ? Colors.white : Colors.blue[900]),
              const SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : Colors.blue[900],
                  letterSpacing: 1,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
