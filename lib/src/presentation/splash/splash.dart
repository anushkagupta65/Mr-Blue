import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/presentation/home/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mr_blue/src/presentation/login/login.dart';
import 'package:geolocator/geolocator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    await _handleLocationPermission();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    final double? storedLat = prefs.getDouble('latitude');
    final double? storedLong = prefs.getDouble('longitude');
    print('Stored Latitude: $storedLat, Stored Longitude: $storedLong');

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Bottomnavigation()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _handleLocationPermission() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await _showLocationServiceDialog();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        bool retry = await _showPermissionDeniedDialog();
        if (retry) {
          permission = await Geolocator.requestPermission();
        }
      }
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await prefs.setDouble('latitude', position.latitude);
        await prefs.setDouble('longitude', position.longitude);
      } catch (e) {
        print('Error getting location: $e');
      }
    }
  }

  Future<void> _showLocationServiceDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Please enable location services to allow the app to determine your location.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showPermissionDeniedDialog() async {
    bool retry = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app requires location permission to provide location-based services. Would you like to grant permission?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Deny'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Allow'),
              onPressed: () {
                retry = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return retry;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.blue.shade900],
            ),
            image: DecorationImage(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.dstATop,
              ),
              image: const AssetImage("assets/images/splash_screen.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 88.r,
              child: Image.asset(
                'assets/images/primary_logo.png',
                fit: BoxFit.cover,
                height: 72.h,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
