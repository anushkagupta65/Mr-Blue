import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mr_blue/src/presentation/home/bottom_navigation.dart';
import 'package:mr_blue/src/presentation/schedule_pickup/screens/booking_confirmation.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'map_helper.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  final String calledFrom;
  const MapScreen({super.key, required this.calledFrom});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapHelper _mapHelper = MapHelper();
  GoogleMapController? _controller;
  bool _loading = true;
  String? _currentAddress;
  String zipCode = '';
  String? userId;
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
  List<Prediction> _predictions = [];
  bool _showSuggestions = false;
  Timer? _debounce;
  String _sessionToken = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    print(
      '[DEBUG] MapScreen: initState called, calledFrom: ${widget.calledFrom}',
    );
    _mapHelper.getCurrentLocation(
      onLoading: (bool loading) {
        print('[DEBUG] MapScreen: Location loading state: $loading');
        setState(() => _loading = loading);
      },
      onPosition: (LatLng position) {
        print(
          '[DEBUG] MapScreen: Current position: ${position.latitude}, ${position.longitude}',
        );
        setState(() {
          _currentPosition = position;
          _selectedPosition = position;
          _mapHelper.updateMarker(_markers, position);
        });
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: position, zoom: 14.0),
          ),
        );
      },
      onAddress: (String address, String zip) {
        print('[DEBUG] MapScreen: Address fetched: $address, Zip: $zip');
        setState(() {
          _currentAddress = address;
          zipCode = zip;
        });
      },
      onError: (String message) {
        print('[DEBUG] MapScreen: Location error: $message');
        showToastMessage(message);
        if (message.contains('permanently denied')) {
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
                      await _mapHelper.openAppSettings();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              );
            },
          );
        }
      },
    );
    _mapHelper.getUserId((String? id) {
      print('[DEBUG] MapScreen: User ID fetched: $id');
      setState(() => userId = id);
    });
    _mapHelper.fetchCities(
      onLoading: (bool loading) {
        print('[DEBUG] MapScreen: Cities loading state: $loading');
        setState(() => _isLoadingCities = loading);
      },
      onCities: (List<Map<String, String>> cities) {
        print('[DEBUG] MapScreen: Cities fetched: ${cities.length} cities');
        setState(() => _cities = cities);
      },
      onError: (String message) {
        print('[DEBUG] MapScreen: Cities fetch error: $message');
        showToastMessage(message);
      },
    );
    _searchController.addListener(() {
      print(
        '[DEBUG] MapScreen: Search input changed: ${_searchController.text}',
      );
      _mapHelper.searchPlaces(
        _searchController.text,
        _sessionToken,
        (List<Prediction> predictions) {
          print(
            '[DEBUG] MapScreen: Place predictions received: ${predictions.length}',
          );
          setState(() {
            _predictions = predictions;
            _showSuggestions = predictions.isNotEmpty;
          });
        },
        (String message) {
          print('[DEBUG] MapScreen: Place search error: $message');
          showToastMessage(message);
          setState(() => _showSuggestions = false);
        },
      );
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    house.dispose();
    street.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
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
          print('[DEBUG] MapScreen: City selected: $value');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: customAppBar(
        "mr. blue",
        leading:
            widget.calledFrom == "verify_otp"
                ? IconButton(
                  onPressed: () {
                    print('[DEBUG] MapScreen: Back button pressed');
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
                        child: Column(
                          children: [
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search for a place on maps..',
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
                                    print(
                                      '[DEBUG] MapScreen: Search button pressed, input: ${_searchController.text}',
                                    );
                                    if (_searchController.text
                                        .trim()
                                        .isNotEmpty) {
                                      _mapHelper.searchPlaces(
                                        _searchController.text.trim(),
                                        _sessionToken,
                                        (predictions) {
                                          print(
                                            '[DEBUG] MapScreen: Search predictions received: ${predictions.length}',
                                          );
                                          setState(() {
                                            _predictions = predictions;
                                            _showSuggestions =
                                                predictions.isNotEmpty;
                                          });
                                        },
                                        (message) => showToastMessage(message),
                                      );
                                    } else {
                                      showToastMessage(
                                        'Please enter a place name',
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            if (_showSuggestions && _predictions.isNotEmpty)
                              SizedBox(
                                height: 200.h,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4.r,
                                        offset: Offset(0, 2.h),
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: _predictions.length,
                                    itemBuilder: (context, index) {
                                      final prediction = _predictions[index];
                                      return ListTile(
                                        title: Text(
                                          prediction.description ?? '',
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                        onTap: () {
                                          print(
                                            '[DEBUG] MapScreen: Prediction selected: ${prediction.description}',
                                          );
                                          _mapHelper.selectPlace(
                                            prediction,
                                            _sessionToken,
                                            (
                                              LatLng position,
                                              String address,
                                            ) async {
                                              print(
                                                '[DEBUG] MapScreen: Place selected, position: ${position.latitude}, ${position.longitude}, address: $address',
                                              );
                                              final prefs =
                                                  await SharedPreferences.getInstance();
                                              await prefs.setString(
                                                'latitude',
                                                position.latitude.toString(),
                                              );
                                              await prefs.setString(
                                                'longitude',
                                                position.longitude.toString(),
                                              );
                                              setState(() {
                                                _currentPosition = position;
                                                _selectedPosition = position;
                                                _mapHelper.updateMarker(
                                                  _markers,
                                                  position,
                                                );
                                                _currentAddress = address;
                                                _showSuggestions = false;
                                                _predictions = [];
                                                _searchController.clear();
                                                _sessionToken =
                                                    const Uuid().v4();
                                              });
                                              _controller?.animateCamera(
                                                CameraUpdate.newCameraPosition(
                                                  CameraPosition(
                                                    target: position,
                                                    zoom: 14.0,
                                                  ),
                                                ),
                                              );
                                            },
                                            (String zip) {
                                              print(
                                                '[DEBUG] MapScreen: Zip code updated: $zip',
                                              );
                                              setState(() => zipCode = zip);
                                            },
                                            (String message) {
                                              print(
                                                '[DEBUG] MapScreen: Place selection error: $message',
                                              );
                                              showToastMessage(message);
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
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
                                print(
                                  '[DEBUG] MapScreen: Map tapped at: ${position.latitude}, ${position.longitude}',
                                );
                                setState(() {
                                  _selectedPosition = position;
                                  _mapHelper.updateMarker(_markers, position);
                                });
                                _controller?.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: position,
                                      zoom: 14.0,
                                    ),
                                  ),
                                );
                                _mapHelper.getAddressFromLatLng(
                                  position.latitude.toString(),
                                  position.longitude.toString(),
                                  (address, zip) {
                                    print(
                                      '[DEBUG] MapScreen: Address from tap: $address, Zip: $zip',
                                    );
                                    setState(() {
                                      _currentAddress = address;
                                      zipCode = zip;
                                    });
                                  },
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
                                    print(
                                      '[DEBUG] MapScreen: House input changed: $value',
                                    );
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
                                  onChanged: (value) {
                                    print(
                                      '[DEBUG] MapScreen: Street input changed: $value',
                                    );
                                  },
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
                                    print(
                                      '[DEBUG] MapScreen: Confirm Location button pressed',
                                    );
                                    if (_selectedPosition == null) {
                                      print(
                                        '[DEBUG] MapScreen: No selected position',
                                      );
                                      showToastMessage(
                                        'Please select a location on the map',
                                      );
                                      return;
                                    }

                                    bool isValid =
                                        _formKey.currentState!.validate();
                                    print(
                                      '[DEBUG] MapScreen: Form validation result: $isValid',
                                    );
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
                                      print(
                                        '[DEBUG] MapScreen: No city selected',
                                      );
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
                                    print(
                                      '[DEBUG] MapScreen: Final address: $finalAddress',
                                    );

                                    await _mapHelper.updateUserAddress(
                                      userId: userId?.toString(),
                                      cityId: cityId,
                                      zipCode: zipCode,
                                      address: _currentAddress!,
                                      finalAddress: finalAddress,
                                      onSuccess: () {
                                        print(
                                          '[DEBUG] MapScreen: Address updated successfully',
                                        );
                                        showToastMessage("Location confirmed");
                                        Future.delayed(
                                          const Duration(seconds: 2),
                                          () {
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
                                          },
                                        );
                                      },
                                      onError: (String message) {
                                        print(
                                          '[DEBUG] MapScreen: Address update error: $message',
                                        );
                                        showToastMessage(message);
                                      },
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
              ),
            );
          },
        ),
      ),
    );
  }
}
