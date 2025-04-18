import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/home/bottom_navigation.dart';
import 'package:mr_blue/src/presentation/schedule_pickup/screens/booking_confirmation.dart';
import 'package:mr_blue/src/services/api_services.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  final String calledFrom;
  const MapScreen({super.key, required this.calledFrom});

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
  String? _selectedCity;
  List<Map<String, String>> _cities = [];
  bool _isLoadingCities = false;
  final TextEditingController _searchController = TextEditingController();

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
                  await AppSettings.openAppSettings();
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

  Future<void> _searchCity(String cityName) async {
    try {
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng cityPosition = LatLng(location.latitude, location.longitude);

        setState(() {
          _currentPosition = cityPosition;
          _selectedPosition = cityPosition;
          _updateMarker(cityPosition);
        });

        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: cityPosition, zoom: 14.0),
          ),
        );

        await _getAddressFromLatLng(location.latitude, location.longitude);
      } else {
        showToastMessage('City not found');
      }
    } catch (e) {
      showToastMessage('Error searching for city: $e');
    }
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
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode} ${place.country}";

        setState(() {
          _currentAddress = address;
          zipCode = place.postalCode ?? "No Zip Code";
        });
      } else {
        setState(() {
          _currentAddress = "Unable to fetch address";
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

  Future<void> _fetchCities() async {
    setState(() {
      _isLoadingCities = true;
    });
    try {
      String responseBody = await ApiService().fetchCities();
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      if (jsonResponse['Status'] == 'Success') {
        List<dynamic> citiesJson = jsonResponse['Text'];
        setState(() {
          _cities =
              citiesJson
                  .map(
                    (city) => {
                      'name': city['name'].toString(),
                      'id': city['id'].toString(),
                    },
                  )
                  .toList();
          _isLoadingCities = false;
        });
      } else {
        throw Exception(
          'API returned non-success status: ${jsonResponse['Status']}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingCities = false;
      });
      showToastMessage("Failed to load cities: $e");
    }
  }

  Widget _buildCityDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: DropdownButtonFormField<String>(
        value: _selectedCity,
        decoration: InputDecoration(
          hintText: 'Select a city nearest to your location *',
          hintStyle: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
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
        items:
            _cities.map((city) {
              return DropdownMenuItem<String>(
                value: city['name'],
                child: Text(city['name']!, style: TextStyle(fontSize: 13.sp)),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCity = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a city';
          }
          return null;
        },
        hint:
            _isLoadingCities
                ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: CircularProgressIndicator(strokeWidth: 2.w),
                )
                : Text(
                  'Select a city nearest to your location *',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10.sp),
                ),
        isExpanded: true,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getUserId();
    _fetchCities();
  }

  @override
  void dispose() {
    _controller?.dispose();
    house.dispose();
    street.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: customAppBar(
        "mr. blue",
        leading:
            widget.calledFrom == "splash_screen" ||
                    widget.calledFrom == "verify_otp"
                ? IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Bottomnavigation(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                )
                : null,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for a place on maps.. ',
                            hintStyle: TextStyle(
                              fontSize: 8.sp,
                              color: Colors.grey[600],
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue.shade700,
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 7.h,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.search,
                                color: Colors.blue.shade700,
                              ),
                              onPressed: () {
                                if (_searchController.text.trim().isNotEmpty) {
                                  _searchCity(_searchController.text.trim());
                                } else {
                                  showToastMessage('Please enter a city name');
                                }
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _searchCity(value.trim());
                            } else {
                              showToastMessage('Please enter a city name');
                            }
                          },
                        ),
                      ),
                      _loading || _currentPosition == null
                          ? Padding(
                            padding: EdgeInsets.all(8.r),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _currentAddress ??
                                            'Please wait while we fetch address for you....',
                                        softWrap: true,
                                        textAlign: TextAlign.left,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildCityDropdown(),
                              Padding(
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: TextFormField(
                                  controller: house,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Flat No./Suite No./Building No./Block *',
                                    hintStyle: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey[600],
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue.shade700,
                                      ),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                      ),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                      ),
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
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: TextField(
                                  controller: street,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Street/Society/Landmark (Optional)',
                                    hintStyle: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey[600],
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue.shade700,
                                      ),
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
                                padding: EdgeInsets.symmetric(vertical: 6.h),
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
                                      showToastMessage(
                                        'Please select a location on the map',
                                      );
                                      return;
                                    }

                                    bool isValid =
                                        _formKey.currentState!.validate();
                                    if (!isValid) {
                                      return;
                                    }

                                    String? cityId;
                                    for (var city in _cities) {
                                      if (city['name'] == _selectedCity) {
                                        cityId = city['id'];
                                        break;
                                      }
                                    }

                                    if (cityId == null) {
                                      showToastMessage('Please select a city');
                                      return;
                                    }

                                    String finalAddress = house.text.trim();
                                    if (street.text.trim().isNotEmpty) {
                                      finalAddress += ", ${street.text.trim()}";
                                    }
                                    if (_selectedCity != null &&
                                        _selectedCity!.isNotEmpty) {
                                      finalAddress += ", $_selectedCity";
                                    }
                                    if (_currentAddress != null &&
                                        _currentAddress!.isNotEmpty) {
                                      finalAddress += ", $_currentAddress";
                                    }

                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final userID = prefs.getString('user_id');

                                    if (userID != null) {
                                      try {
                                        final response = await ApiService()
                                            .updateUserAddress(
                                              userId: userID,
                                              cityId: cityId,
                                              zip: zipCode,
                                              address: _currentAddress!,
                                            );

                                        final responseData = jsonDecode(
                                          response,
                                        );

                                        if (responseData['Status'] ==
                                            "Success") {
                                          await prefs.setString(
                                            'user_address',
                                            finalAddress,
                                          );

                                          showToastMessage(
                                            "Location confirmed",
                                          );
                                          await Future.delayed(
                                            const Duration(seconds: 2),
                                          );
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Confirmation(
                                                    title: "Location Added",
                                                    desription:
                                                        "Your new location has been added successfully: $finalAddress",
                                                  ),
                                            ),
                                          );
                                        } else {
                                          showToastMessage(
                                            "Failed to update address: ${responseData["Text"]}",
                                          );
                                        }
                                      } catch (e) {
                                        showToastMessage(
                                          "An error occurred while updating address",
                                        );
                                      }
                                    } else {
                                      showToastMessage("User not logged in");
                                    }
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
              ),
            );
          },
        ),
      ),
    );
  }
}
