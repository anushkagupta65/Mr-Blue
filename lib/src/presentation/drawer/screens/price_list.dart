import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PriceList extends StatefulWidget {
  const PriceList({super.key});

  @override
  State<PriceList> createState() => _PriceListState();
}

class _PriceListState extends State<PriceList>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  List<String> serviceNames = ['Dry Cleaning', 'Laundry'];
  List<String> uniqueSubtrades = [];
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> allItems = [];
  String? selectedSubtrade;
  String regionId = "5";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: serviceNames.length, vsync: this);
    _loadRegionIdAndFetchData();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadRegionIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    regionId = prefs.getString('regionId') ?? "5";
    await _fetchPriceData(serviceNames[0]);
  }

  Future<void> _fetchPriceData(String service) async {
    setState(() {
      isLoading = true;
    });
    try {
      String response;
      if (service == 'Dry Cleaning') {
        response = await ApiService().getDryCleaningPriceDetails(regionId);
      } else {
        response = await ApiService().getLaundryPriceDetails(regionId);
      }

      List<dynamic> data;
      if (service == 'Dry Cleaning') {
        data = jsonDecode(response);
      } else {
        final jsonData = jsonDecode(response) as Map<String, dynamic>;
        data = jsonData['services'] as List<dynamic>;
      }

      setState(() {
        allItems = data.cast<Map<String, dynamic>>();
        filterItemsByService(service);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load price list for $service')),
      );
    }
  }

  void filterItemsByService(String service) {
    setState(() {
      if (service == 'Dry Cleaning') {
        final filteredByParent =
            allItems
                .where(
                  (item) =>
                      (item['parent_trade_name']?.toString().toLowerCase() ??
                          '') ==
                      'dry cleaning',
                )
                .toList();

        final allSubtrades =
            filteredByParent
                .map((item) => item['sub_trade_name']?.toString() ?? '<empty>')
                .toList();

        uniqueSubtrades =
            allSubtrades.toSet().toList()
              ..removeWhere(
                (subtrade) => subtrade.isEmpty || subtrade == '<empty>',
              )
              ..sort();
        selectedSubtrade =
            uniqueSubtrades.isNotEmpty ? uniqueSubtrades[0] : null;
        filterItemsBySubtrade(selectedSubtrade ?? '');
      } else {
        uniqueSubtrades =
            allItems
                .map((item) => item['name']?.toString() ?? '')
                .toSet()
                .toList()
              ..removeWhere((name) => name.isEmpty)
              ..sort();
        selectedSubtrade =
            uniqueSubtrades.isNotEmpty ? uniqueSubtrades[0] : null;
        filterItemsBySubtrade(selectedSubtrade ?? '');
      }
    });
  }

  void filterItemsBySubtrade(String subtrade) {
    setState(() {
      selectedSubtrade = subtrade;
      final currentService = serviceNames[tabController!.index];
      if (currentService == 'Dry Cleaning') {
        filteredItems =
            allItems
                .where(
                  (item) =>
                      item['sub_trade_name'] == subtrade &&
                      (item['parent_trade_name']?.toString().toLowerCase() ??
                              '') ==
                          'dry cleaning' &&
                      item['cloth_name'] != null,
                )
                .toList();
      } else {
        filteredItems =
            allItems
                .where(
                  (item) => item['name'] == subtrade && item['name'] != null,
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Price List"),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.blue.shade50),
          child:
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      TabBar(
                        labelColor: Colors.white,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        unselectedLabelColor: Colors.black,
                        indicatorPadding: EdgeInsets.all(6.r),
                        dividerColor: Colors.blue[900],
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue[800]!,
                              Colors.blue[400]!,
                              Colors.blue[800]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        controller: tabController,
                        tabs:
                            serviceNames
                                .map(
                                  (service) => Tab(text: service.toUpperCase()),
                                )
                                .toList(),
                        onTap: (index) {
                          _fetchPriceData(serviceNames[index]);
                        },
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        child: SizedBox(
                          height: 60.h,
                          child:
                              uniqueSubtrades.isEmpty
                                  ? Center(
                                    child: Text('No categories available'),
                                  )
                                  : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: uniqueSubtrades.length,
                                    itemBuilder: (context, index) {
                                      final subtrade = uniqueSubtrades[index];
                                      bool isSelected =
                                          subtrade == selectedSubtrade;
                                      return GestureDetector(
                                        onTap: () {
                                          filterItemsBySubtrade(subtrade);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 4.w),
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.36,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? Colors.blue.shade700
                                                    : Colors.blue.shade100,
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              subtrade,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : Colors.black87,
                                                letterSpacing: 1.sp,
                                                fontSize: 14.sp,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children:
                              serviceNames.map((service) {
                                return filteredItems.isEmpty
                                    ? Center(child: Text('No items available'))
                                    : Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 12.h,
                                      ),
                                      child: ListView.builder(
                                        itemCount: filteredItems.length,
                                        itemBuilder: (context, index) {
                                          final item = filteredItems[index];
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              left: 10.w,
                                              right: 10.w,
                                              bottom: 12.h,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white70,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                border: Border.all(
                                                  color: Colors.blue.shade900,
                                                  width: 0.6.w,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(12.r),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item['cloth_name'] ??
                                                            item['name'] ??
                                                            'N/A',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.black87,
                                                          letterSpacing: 0.5.sp,
                                                          fontSize: 12.sp,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "Rs. ${item['price']}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black87,
                                                        letterSpacing: 0.5.sp,
                                                        fontSize: 12.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
