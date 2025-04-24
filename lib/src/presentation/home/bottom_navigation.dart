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
  String? _latitude;
  String? _longitude;
  String? _responseText;
  List<Widget>? _pages;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // print('[Bottomnavigation] initState: Initializing and fetching data');
    _fetchDataAndPost().then((_) {
      setState(() {
        _pages = [
          HomeScreen(
            initialLat: _latitude,
            initialLng: _longitude,
            responseText: _responseText,
          ),
          const Setting(),
        ];
        // print(
        //   '[Bottomnavigation] initState: Pages set with latitude: $_latitude, longitude: $_longitude, responseText: $_responseText',
        // );
      });
    });
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userID = prefs.getString('user_id');
      // print('[Bottomnavigation] _fetchAddress: userID = $userID');

      if (userID != null) {
        String response = await _apiService.availableAddress(userID);
        // print('[Bottomnavigation] _fetchAddress: API response: $response');
        final responseBody = json.decode(response);
        final addressID = responseBody['Address']['id'].toString();
        await prefs.setString('user_address_id', addressID);
        // print('[Bottomnavigation] _fetchAddress: Saved addressID: $addressID');
      }
    } catch (e) {
      // print('[Bottomnavigation] _fetchAddress: Error occurred: $e');
    }
  }

  Future<void> _fetchDataAndPost() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String latitude = prefs.getString('latitude') ?? "";
      String longitude = prefs.getString('longitude') ?? "";
      // print(
      //   '[Bottomnavigation] _fetchDataAndPost: latitude = $latitude, longitude = $longitude',
      // );

      // ignore: unnecessary_null_comparison
      if (latitude == null || longitude == null) {
        await prefs.setString('region_id', "5");
        await prefs.setString('city_id', "2");
        await prefs.setString('store_id', "39");
        return;
      }
      String response = await _apiService.postUserLocation(latitude, longitude);
      // print('[Bottomnavigation] _fetchDataAndPost: API response: $response');
      final responseBody = jsonDecode(response);
      setState(() {
        _latitude = latitude;
        _longitude = longitude;
        _responseText = responseBody['Text'] ?? '';
      });

      if (responseBody['Status'] == "Success") {
        await prefs.setString(
          'region_id',
          responseBody['region_id'].toString(),
        );
        await prefs.setString('city_id', responseBody['city_id'].toString());
        await prefs.setString('store_id', responseBody['store_id'].toString());
        // print(
        //   '[Bottomnavigation] _fetchDataAndPost: Success - Saved region_id=${responseBody['region_id']}, city_id=${responseBody['city_id']}, store_id=${responseBody['store_id']}',
        // );
      } else {
        await prefs.setString('region_id', "5");
        await prefs.setString('city_id', "2");
        await prefs.setString('store_id', "39");
      }
    } catch (e) {
      // print('[Bottomnavigation] _fetchDataAndPost: Error occurred: $e');
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
