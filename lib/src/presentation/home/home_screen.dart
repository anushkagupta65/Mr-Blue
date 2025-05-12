import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/drawer/drawer.dart';
import 'package:mr_blue/src/presentation/home/home_helper.dart';
import 'package:mr_blue/src/presentation/home/map_screen.dart';
import 'package:mr_blue/src/presentation/schedule_pickup/schedule_pickup.dart';
import 'package:flutter_google_maps_webservices/places.dart';

class HomeScreen extends StatefulWidget {
  final String? initialLat;
  final String? initialLng;
  final String? responseText;

  const HomeScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.responseText,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HelperMethods helpers;
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String _displayAddress = "Add Location";
  List<Prediction> _predictions = [];
  bool _showSuggestions = false;
  bool _noStoreFound = false;

  @override
  void initState() {
    super.initState();
    helpers = HelperMethods(
      initialLat: widget.initialLat,
      initialLng: widget.initialLng,
      responseText: widget.responseText,
    );
    helpers.onServicesUpdated = (services, isLoading, noStoreFound) {
      setState(() {
        _services = services;
        _isLoading = isLoading;
        _noStoreFound = noStoreFound;
      });
    };
    helpers.onAddressUpdated = (displayAddress) {
      setState(() {
        _displayAddress = displayAddress;
      });
    };
    helpers.onPredictionsUpdated = (predictions, showSuggestions) {
      setState(() {
        _predictions = predictions;
        _showSuggestions = showSuggestions;
      });
    };
  }

  @override
  void dispose() {
    helpers.dispose();
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
                MaterialPageRoute(builder: (context) => MapScreen()),
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
                                      controller: helpers.searchController,
                                      decoration: InputDecoration(
                                        labelStyle: TextStyle(fontSize: 10.sp),
                                        hintStyle: TextStyle(fontSize: 10.sp),
                                        hintText: 'Search for location',
                                        prefixIcon: const Icon(Icons.search),
                                        suffixIcon:
                                            helpers
                                                    .searchController
                                                    .text
                                                    .isNotEmpty
                                                ? IconButton(
                                                  icon: const Icon(Icons.clear),
                                                  onPressed:
                                                      helpers.clearSearch,
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
                                      onChanged: helpers.searchPlaces,
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
                                                  () => helpers.selectPlace(
                                                    prediction,
                                                  ),
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
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: _services.length,
                                          itemBuilder: (context, index) {
                                            final service = _services[index];
                                            return InkWell(
                                              onTap:
                                                  !_noStoreFound
                                                      ? () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    BookingScreen(),
                                                          ),
                                                        );
                                                      }
                                                      : () {
                                                        showToastMessage(
                                                          "No laundromat found at current location. Please search for a different place.",
                                                        );
                                                      },
                                              child: Opacity(
                                                opacity:
                                                    !_noStoreFound ? 1.0 : 0.5,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 10.w,
                                                    left: 6.w,
                                                    top: 4.h,
                                                    bottom: 4.h,
                                                  ),
                                                  child: Container(
                                                    height: 56.h,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
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
                                                                  Colors.black,
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
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      _noStoreFound
                                          ? Padding(
                                            padding: EdgeInsets.only(top: 12.h),
                                            child: Text(
                                              "No laundromat found at current location. Please search for a different place.",
                                              style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12.sp,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                          : SizedBox(height: 32.h),
                                    ],
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
