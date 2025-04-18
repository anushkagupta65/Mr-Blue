import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/drawer/drawer.dart';
import 'package:mr_blue/src/presentation/home/map_screen.dart';
import 'package:mr_blue/src/presentation/schedule_pickup/schedule_pickup.dart';
import 'dart:convert';
import 'package:mr_blue/src/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _filteredServices = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _displayAddress = "Add Location";

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _searchController.addListener(_onSearchTextChanged);
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
        _filteredServices = _services;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching services: $e');
      setState(() {
        _isLoading = false;
      });
      showToastMessage('Failed to load services');
    }
  }

  void _onSearchTextChanged() {
    String query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredServices = _services;
      } else {
        _filteredServices =
            _services
                .where(
                  (service) => service['name'].toLowerCase().contains(query),
                )
                .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
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
          iconTheme: IconThemeData(color: Colors.white),
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
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      child: Column(
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
                                        hintText:
                                            'Search for a laundry service',
                                        prefixIcon: Icon(Icons.search),
                                        suffixIcon:
                                            _searchController.text.isNotEmpty
                                                ? IconButton(
                                                  icon: Icon(Icons.clear),
                                                  onPressed: () {
                                                    _searchController.clear();
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
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32.h),
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
                                  height: 120.h,
                                  child: Center(
                                    child:
                                        _filteredServices.isEmpty
                                            ? Text(
                                              'No services found',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.grey,
                                              ),
                                            )
                                            : ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemCount:
                                                  _filteredServices.length,
                                              itemBuilder: (context, index) {
                                                final service =
                                                    _filteredServices[index];
                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                BookingScreen(),
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      right: 10.w,
                                                      left: 6.w,
                                                      top: 4.h,
                                                      bottom: 4.h,
                                                    ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                  0.5,
                                                                ),
                                                            spreadRadius: 2.r,
                                                            blurRadius: 4.r,
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
                                                              horizontal: 10.w,
                                                              vertical: 6.h,
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
                                                              width: 60.w,
                                                              errorBuilder:
                                                                  (
                                                                    context,
                                                                    error,
                                                                    stackTrace,
                                                                  ) => Icon(
                                                                    Icons
                                                                        .image_not_supported,
                                                                    size: 60.w,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                            ),
                                                            SizedBox(
                                                              height: 12.h,
                                                            ),
                                                            Text(
                                                              service['name'],
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                letterSpacing:
                                                                    1.w,
                                                                fontSize: 12.sp,
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
                                                );
                                              },
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Column(
                                children: [
                                  SizedBox(height: 18.h),
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
