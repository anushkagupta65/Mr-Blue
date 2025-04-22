import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/drawer/drawer.dart';
import 'package:mr_blue/src/presentation/home/map_screen.dart';
import 'package:mr_blue/src/presentation/schedule_pickup/schedule_pickup.dart';
import 'dart:convert';
import 'package:mr_blue/src/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _displayAddress = "Add Location";
  final GoogleMapsPlaces _places = GoogleMapsPlaces(
    apiKey: 'AIzaSyCHnauUdIQDCprpFfdj6-JRlskIDTzWg94',
  );
  List<Prediction> _predictions = [];
  bool _showSuggestions = false;
  double? _selectedLat;
  double? _selectedLng;
  Timer? _debounce;
  String _sessionToken = const Uuid().v4();
  bool _noStoreFound = false;
  bool _locationSelected = false;

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('user_address');
    setState(() {
      _displayAddress =
          savedAddress != null && savedAddress.isNotEmpty
              ? savedAddress
              : "Please add location..";
    });
  }

  Future<void> _fetchServices() async {
    try {
      String response = await _apiService.getServices();
      Map<String, dynamic> responseData = jsonDecode(response);
      List<dynamic> servicesData = responseData['services'] ?? [];
      print('Services Data: $servicesData');
      setState(() {
        _services =
            servicesData
                .map(
                  (service) => {
                    'name': service['name'] ?? 'Unknown Service',
                    'imageUrl': service['image'] ?? '',
                  },
                )
                .toList();
        _isLoading = false;
        _noStoreFound = false;
      });
    } catch (e) {
      print('Error fetching services: $e');
      setState(() {
        _isLoading = false;
      });
      showToastMessage('Failed to load services');
    }
  }

  Future<void> _searchPlaces(String input) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (input.isEmpty) {
        setState(() {
          _predictions = [];
          _showSuggestions = false;
        });
        return;
      }

      try {
        List<Prediction> allPredictions = [];
        final queries = [input, '$input ', '$input city', '$input street'];

        for (final query in queries) {
          PlacesAutocompleteResponse response = await _places.autocomplete(
            query,
            language: 'en',
            sessionToken: _sessionToken,
          );
          allPredictions.addAll(response.predictions);
          if (allPredictions.length >= 30) break;
        }

        final seenPlaceIds = <String>{};
        _predictions =
            allPredictions.where((prediction) {
              final placeId = prediction.placeId;
              if (placeId != null && !seenPlaceIds.contains(placeId)) {
                seenPlaceIds.add(placeId);
                return true;
              }
              return false;
            }).toList();

        setState(() {
          _showSuggestions = true;
        });
      } catch (e) {
        print('Error searching places: $e');
        showToastMessage('Failed to search places');
        setState(() {
          _showSuggestions = false;
        });
      }
    });
  }

  Future<void> _selectPlace(Prediction prediction) async {
    try {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(
        prediction.placeId!,
        sessionToken: _sessionToken,
      );
      final lat = detail.result.geometry?.location.lat;
      final lng = detail.result.geometry?.location.lng;

      if (lat != null && lng != null) {
        setState(() {
          _selectedLat = lat;
          _selectedLng = lng;
          _searchController.clear();
          _predictions = [];
          _showSuggestions = false;
          _sessionToken = const Uuid().v4();
          _locationSelected = true;
        });
        print('Selected Location: Latitude: $lat, Longitude: $lng');

        try {
          String response = await _apiService.postUserLocation(
            lat.toString(),
            lng.toString(),
          );
          print(
            '========================= API Response ========================: $response',
          );
          final responseBody = jsonDecode(response);
          final responseText = responseBody['Text'] ?? '';
          showToastMessage(responseText);

          if (responseText == "No store found in this location.") {
            setState(() {
              _noStoreFound = true;
              _services = [];
            });
          } else {
            setState(() {
              _noStoreFound = false;
            });
            await _fetchServices();
          }
        } catch (e) {
          print('Error posting user location: $e');
          showToastMessage('Failed to send location to server');
        }
      } else {
        showToastMessage('Could not retrieve coordinates');
      }
    } catch (e) {
      print('Error fetching place details: $e');
      showToastMessage('Failed to fetch place details');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade700,
          title: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(calledFrom: "home_screen"),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.location_pin, color: Colors.white, size: 16.h),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _displayAddress,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: CustomDrawer(),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade50.withValues(alpha: 0.3),
                  Colors.blue.shade200,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Find Your Nearest Laundromat",
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        labelStyle: TextStyle(fontSize: 10.sp),
                                        hintStyle: TextStyle(fontSize: 10.sp),
                                        hintText: 'Search for location',
                                        prefixIcon: const Icon(Icons.search),
                                        suffixIcon:
                                            _searchController.text.isNotEmpty
                                                ? IconButton(
                                                  icon: const Icon(Icons.clear),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() {
                                                      _predictions = [];
                                                      _showSuggestions = false;
                                                    });
                                                  },
                                                )
                                                : null,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.blue.shade50,
                                      ),
                                      onChanged: _searchPlaces,
                                    ),
                                    if (_showSuggestions &&
                                        _predictions.isNotEmpty)
                                      Container(
                                        constraints: BoxConstraints(
                                          maxHeight: 400.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                              spreadRadius: 1.r,
                                              blurRadius: 3.r,
                                            ),
                                          ],
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _predictions.length,
                                          itemBuilder: (context, index) {
                                            final prediction =
                                                _predictions[index];
                                            return ListTile(
                                              title: Text(
                                                prediction.description ?? '',
                                              ),
                                              onTap:
                                                  () =>
                                                      _selectPlace(prediction),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'OUR SERVICES',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 20.sp,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 6.h,
                                  horizontal: 12.w,
                                ),
                                child: SizedBox(
                                  height: 180.h,
                                  child: Center(
                                    child:
                                        _noStoreFound
                                            ? Text(
                                              'No store found in this location.',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            )
                                            : Column(
                                              children: [
                                                Expanded(
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    itemCount: _services.length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      final service =
                                                          _services[index];
                                                      return InkWell(
                                                        onTap:
                                                            _locationSelected
                                                                ? () {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (
                                                                            context,
                                                                          ) =>
                                                                              BookingScreen(),
                                                                    ),
                                                                  );
                                                                }
                                                                : () {
                                                                  showToastMessage(
                                                                    "Please choose a location using the search bar above to find a store and proceed with your booking.",
                                                                  );
                                                                },
                                                        child: Opacity(
                                                          opacity:
                                                              _locationSelected
                                                                  ? 1.0
                                                                  : 0.5,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  right: 10.w,
                                                                  left: 6.w,
                                                                  top: 4.h,
                                                                  bottom: 4.h,
                                                                ),
                                                            child: Container(
                                                              height: 56.h,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                          0.5,
                                                                        ),
                                                                    spreadRadius:
                                                                        2.r,
                                                                    blurRadius:
                                                                        4.r,
                                                                  ),
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      4.r,
                                                                    ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10.w,
                                                                      vertical:
                                                                          6.h,
                                                                    ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Image.network(
                                                                      service['imageUrl'],
                                                                      fit:
                                                                          BoxFit
                                                                              .fitHeight,
                                                                      width:
                                                                          60.w,
                                                                      errorBuilder:
                                                                          (
                                                                            context,
                                                                            error,
                                                                            stackTrace,
                                                                          ) => Icon(
                                                                            Icons.image_not_supported,
                                                                            size:
                                                                                60.w,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          12.h,
                                                                    ),
                                                                    Text(
                                                                      service['name'],
                                                                      style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        color:
                                                                            Colors.black,
                                                                        letterSpacing:
                                                                            1.w,
                                                                        fontSize:
                                                                            12.sp,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                _locationSelected
                                                    ? SizedBox(height: 32.h)
                                                    : Center(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 12.h,
                                                          ),
                                                          Text(
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            "Please choose a location using the search bar above to find a store and proceed with your booking.",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .blueGrey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                              ],
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Column(
                                children: [
                                  SizedBox(height: 8.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black,
                                          ],
                                          stops: [0.0, 1.0],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: Image.asset(
                                        "assets/images/home_screen.png",
                                        fit: BoxFit.fitHeight,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Picks up, Cleans ',
                                        style: TextStyle(
                                          height: 2,
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'and ',
                                        style: TextStyle(
                                          height: 2,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Delivers ',
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          height: 2,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            'your laundry right to your doorstep!',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          height: 2,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
