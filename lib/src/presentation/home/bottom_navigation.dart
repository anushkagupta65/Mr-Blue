import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/home/home_screen.dart';
import 'package:mr_blue/src/presentation/setting/settings.dart';
import 'package:mr_blue/src/services/api_services.dart';
import 'package:permission_handler/permission_handler.dart' as app_settings;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _selectedIndex = 0;
  bool _loading = false;
  double? _latitude;
  double? _longitude;
  String? _responseText;
  List<Widget>? _pages;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchLocationAndPost().then((_) {
      setState(() {
        _pages = [
          HomeScreen(
            initialLat: _latitude,
            initialLng: _longitude,
            responseText: _responseText,
          ),
          const Setting(),
        ];
      });
    });
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userID = prefs.getString('user_id');

      if (userID != null) {
        String response = await _apiService.availableAddress(userID);
        final responseBody = json.decode(response);
        final addressID = responseBody['Address']['id'].toString();
        await prefs.setString('user_address_id', addressID);
      }
    } catch (e) {
      print('Error occurred in _fetchAddress: $e');
    }
  }

  Future<void> _fetchLocationAndPost() async {
    try {
      bool permissionGranted = await _requestLocationPermission();
      if (!permissionGranted) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('region_id', "5");
        await prefs.setString('city_id', "2");
        await prefs.setString('store_id', "39");
        setState(() {
          _latitude = null;
          _longitude = null;
          _responseText = "No store found in this location.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String latitude = position.latitude.toString();
      String longitude = position.longitude.toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('latitude', latitude);
      await prefs.setString('longitude', longitude);

      String response = await _apiService.postUserLocation(latitude, longitude);
      final responseBody = jsonDecode(response);

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _responseText = responseBody['Text'] ?? '';
      });

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
      print('Error occurred in _fetchLocationAndPost: $e');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('region_id', "5");
      await prefs.setString('city_id', "2");
      await prefs.setString('store_id', "39");
      setState(() {
        _latitude = null;
        _longitude = null;
        _responseText = "No store found in this location.";
      });
    }
  }

  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    PermissionStatus permission = await Permission.location.request();
    if (permission.isGranted) {
      return true;
    } else if (permission.isPermanentlyDenied) {
      setState(() {
        _loading = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Location permissions are permanently denied. Please enable location access from the app settings to proceed.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await app_settings.openAppSettings();
                  Navigator.of(context).pop();
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );

      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions',
      );
    } else {
      return false;
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
      openWhatsAppChat(
        "9555900059",
        message: "Hello! Mr. Blue, I am Interested in your services.",
      );
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Call'),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/whatsapp-icon.png",
              height: 20.h,
              color: Colors.white70,
            ),
            label: 'WhatsApp',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (val) {
          _onItemTapped(val);
        },
        type: BottomNavigationBarType.fixed,
      ),
      body:
          _pages == null
              ? const Center(child: CircularProgressIndicator())
              : _pages![_selectedIndex],
    );
  }
}
