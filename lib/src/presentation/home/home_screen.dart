import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/drawer/drawer.dart';
import 'dart:convert';
import 'package:mr_blue/src/services/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
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
      });
    } catch (e) {
      print('Error fetching services: $e');
      setState(() {
        _isLoading = false;
      });
      showToastMessage('Failed to load services');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // Typical iPhone 11 Pro size
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Scaffold(
        appBar: customAppBar(),
        drawer: CustomDrawer(),
        body: Container(
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
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(fontSize: 10.sp),
                                    hintText: 'Search for a laundry service',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
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
                              height: 160.h,
                              child: Center(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _services.length,
                                  itemBuilder: (context, index) {
                                    final service = _services[index];
                                    return Padding(
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
                                              color: Colors.grey.withOpacity(
                                                0.5,
                                              ),
                                              spreadRadius: 2.r,
                                              blurRadius: 4.r,
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 6.h,
                                          ),
                                          child: InkWell(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.network(
                                                  service['imageUrl'],
                                                  fit: BoxFit.fitHeight,
                                                  width: 68.w,
                                                ),
                                                SizedBox(height: 12.h),
                                                Text(
                                                  service['name'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black,
                                                    letterSpacing: 1.w,
                                                    fontSize: 12.sp,
                                                  ),
                                                  textAlign: TextAlign.center,
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
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 32.h),
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
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'and ',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Delivers ',
                                    style: TextStyle(
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'your laundry right to your doorstep!',
                                    style: TextStyle(
                                      fontSize: 16.sp,
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
    );
  }
}
