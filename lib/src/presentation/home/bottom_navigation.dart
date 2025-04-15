import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/home/home_screen.dart';
import 'package:mr_blue/src/presentation/setting/settings.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [HomeScreen(), Setting()];

  void _onItemTapped(int index) {
    if (index == 0 || index == 1) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 2) {
      call("9555900059");
    } else if (index == 3) {
      openWhatsApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade800,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 1,
          fontSize: 10.sp,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.grey,
          letterSpacing: 1,
          fontSize: 10.sp,
        ),
        unselectedIconTheme: IconThemeData(color: Colors.white70, size: 20.sp),
        selectedIconTheme: IconThemeData(color: Colors.white, size: 20.sp),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Call'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'WhatsApp',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (val) {
          _onItemTapped(val);
        },
        type: BottomNavigationBarType.fixed,
      ),
      body: _pages[_selectedIndex],
    );
  }
}
