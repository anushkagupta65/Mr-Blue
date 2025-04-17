import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/home/home_screen.dart';
import 'package:mr_blue/src/presentation/setting/settings.dart';
import 'package:mr_blue/src/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [HomeScreen(), Setting()];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchLocationAndPost();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? userID = prefs.getString('user_id');

      if (userID != null) {
        String response = await _apiService.availableAddress(userID);
        print('API Response _fetchAddress: $response');
        final responseBody = json.decode(response);
        final addressID = responseBody['Address']['id'].toString();
        await prefs.setString('user_address_id', addressID);
      } else {
        print('User id not found in SharedPreferences');
      }
    } catch (e) {
      print('DEBUG: Error occurred: $e');
    }
  }

  Future<void> _fetchLocationAndPost() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? latitude = prefs.getDouble('latitude').toString();
      String? longitude = prefs.getDouble('longitude').toString();

      print('DEBUG: Latitude: $latitude, Longitude: $longitude');

      String response = await _apiService.postUserLocation();
      final responseBody = jsonDecode(response);

      print('DEBUG: API Response: $responseBody');

      if (responseBody['Status'] == "Success") {
        await prefs.setString(
          'region_id',
          responseBody['region_id'].toString(),
        );
        await prefs.setString('city_id', responseBody['city_id'].toString());
        await prefs.setString('store_id', responseBody['store_id'].toString());
      } else {
        await prefs.setString('region_id', "5");
        await prefs.setString('city_id', "2");
        await prefs.setString('store_id', "39");
      }
    } catch (e) {
      print('DEBUG: Error occurred: $e');
    }
  }

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
