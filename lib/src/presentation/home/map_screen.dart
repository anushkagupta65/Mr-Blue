import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/schedule_pickup/screens/booking_confirmation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  bool _loading = true;
  String? _currentAddress;
  String zipCode = '';
  int? userId;
  LatLng? _currentPosition;
  LatLng? _selectedPosition;
  final Set<Marker> _markers = {};
  final _formKey = GlobalKey<FormState>();

  TextEditingController house = TextEditingController();
  TextEditingController street = TextEditingController();

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id');
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _selectedPosition = _currentPosition;
      _loading = false;
      _updateMarker(_selectedPosition!);
    });

    _moveToLocation(position);

    await _getAddressFromLatLng(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

        setState(() {
          _currentAddress = address;
          zipCode = place.postalCode ?? "No Zip Code";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Unable to fetch address";
      });
    }
  }

  void _moveToLocation(Position position) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        ),
      ),
    );
  }

  void _moveToSelectedLocation(LatLng position) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 14.0),
      ),
    );
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getUserId();
  }

  @override
  void dispose() {
    _controller?.dispose();
    house.dispose();
    street.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: customAppBar("mr. blue"),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _loading || _currentPosition == null
                ? Padding(
                  padding: EdgeInsets.all(8.w),
                  child: SizedBox(
                    height: 300.h,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 4.w,
                      ),
                    ),
                  ),
                )
                : Expanded(
                  child: GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                      if (_currentPosition != null) {
                        _controller!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _currentPosition!,
                              zoom: 14.0,
                            ),
                          ),
                        );
                      }
                    },
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition ?? const LatLng(0, 0),
                      zoom: 14.0,
                    ),
                    onTap: (LatLng position) {
                      setState(() {
                        _selectedPosition = position;
                        _updateMarker(position);
                      });
                      _moveToSelectedLocation(position);
                      _getAddressFromLatLng(
                        position.latitude,
                        position.longitude,
                      );
                    },
                  ),
                ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _currentAddress ??
                                  'Please wait while we fetch address for you....',
                              softWrap: true,
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: TextFormField(
                        controller: house,
                        decoration: InputDecoration(
                          hintText: 'Flat No./Suite No./Building No./Block *',
                          hintStyle: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue.shade700),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'This field is mandatory';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (_formKey.currentState != null) {
                            _formKey.currentState!.validate();
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: TextField(
                        controller: street,
                        decoration: InputDecoration(
                          hintText: 'Street/Society/Landmark (Optional)',
                          hintStyle: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue.shade700),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          minimumSize: Size(double.infinity, 40.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        onPressed: () async {
                          if (_selectedPosition == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select a location on the map',
                                ),
                              ),
                            );
                            return;
                          }

                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          String finalAddress = house.text.trim();
                          if (_currentAddress != null &&
                              _currentAddress!.isNotEmpty) {
                            finalAddress += ", $_currentAddress";
                          }
                          if (street.text.trim().isNotEmpty) {
                            finalAddress += ", ${street.text.trim()}";
                          }

                          showToastMessage("Location confirmed");
                          await Future.delayed(const Duration(seconds: 2));
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder:
                                  (context) => Confirmation(
                                    title: "Location Added",
                                    desription:
                                        "Your new location has been added successfully: $finalAddress",
                                  ),
                            ),
                          );
                        },
                        child: Text(
                          'Confirm Location',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
