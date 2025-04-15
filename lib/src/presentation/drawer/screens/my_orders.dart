import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/drawer/widgets/custom_widgets.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String selectedFilter = 'Orders';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Orders"),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.blue[50]!.withOpacity(0.3)),
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.white,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
                unselectedLabelColor: Colors.black,
                indicatorPadding: EdgeInsets.all(6),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                controller: _tabController,
                tabs: const [Tab(text: 'PICKUPS'), Tab(text: 'DROP OFFS')],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  FilterButton(
                                    label: 'Orders',
                                    icon: Icons.shopping_cart_outlined,
                                    isSelected: selectedFilter == 'Orders',
                                    onTap: () {
                                      setState(() {
                                        selectedFilter = 'Orders';
                                      });
                                    },
                                    context: context,
                                  ),
                                  FilterButton(
                                    label: 'Processing',
                                    icon: Icons.man,
                                    isSelected: selectedFilter == 'Processing',
                                    onTap: () {
                                      setState(() {
                                        selectedFilter = 'Processing';
                                      });
                                    },
                                    context: context,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  FilterButton(
                                    label: 'Due Rs. 0',
                                    icon: Icons.wallet,
                                    isSelected: selectedFilter == 'Due',
                                    onTap: () {
                                      setState(() {
                                        selectedFilter = 'Due';
                                      });
                                    },
                                    context: context,
                                  ),
                                  FilterButton(
                                    label: 'Ready',
                                    icon: Icons.check_circle_outline,
                                    isSelected: selectedFilter == 'Ready',
                                    onTap: () {
                                      setState(() {
                                        selectedFilter = 'Ready';
                                      });
                                    },
                                    context: context,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.blue[900], thickness: 1),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (BuildContext context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: 12.w,
                                  right: 12.w,
                                  top: 12.h,
                                ),
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(12.w),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14.w,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: 10.h,
                                                  bottom: 5.h,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Dryclean',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.blueGrey,
                                                        fontSize: 14.sp,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Amount: Rs. 500',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                        fontSize: 10.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: 10.h,
                                                  bottom: 5.h,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '#ORD123',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                        fontSize: 10.sp,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Quantity 1',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                        fontSize: 10.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                              height: 28.h,
                                              width: 64.w,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.w,
                                                      ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Track',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 28.h,
                                              width: 64.w,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.w,
                                                      ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Pay',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 28.h,
                                              width: 64.w,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.w,
                                                      ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'View',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.h),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                    ListView.builder(
                      itemCount: 2,
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 12.w,
                            right: 12.w,
                            top: 12.h,
                          ),
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(12.w),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 5.h,
                                      bottom: 5.h,
                                      left: 12.w,
                                      right: 12.w,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Dryclean',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: Colors.blueGrey,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                            Text(
                                              '#ORD124',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontSize: 10.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Quantity: 1',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontSize: 10.sp,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(4.sp),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.w,
                                                      ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 14.w,
                                                    vertical: 6.h,
                                                  ),
                                                  child: Text(
                                                    'View',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
