import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';

class MyRequests extends StatefulWidget {
  const MyRequests({super.key});

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  final List<Map<String, dynamic>> pickups = [
    {
      'service': 'Dry Cleaning',
      'booking_code': 'MB12345',
      'pickup_date': '2025-04-15',
      'pickup_time': '10:00 AM',
      'rider_name': 'John Doe',
      'status': 1,
    },
    {
      'service': 'Shoe Cleaning',
      'booking_code': 'MB12346',
      'pickup_date': '2025-04-16',
      'pickup_time': '2:00 PM',
      'rider_name': 'Jane Smith',
      'status': 0,
    },
  ];

  final List<Map<String, dynamic>> dropoffs = [
    {
      'service_name': 'Dry Cleaning',
      'booking_code': 'MB12347',
      'drop_date': '2025-04-14',
      'drop_time': '3:00 PM',
      'rider_name': 'Mike Brown',
    },
  ];

  final String dryCleanImg =
      'https://fabspin.org/public/assets/images/dry-clean-icon.png';
  final String shoeCleanImg =
      'https://fabspin.org/public/assets/images/shoe-cleaning-icon.png';
  final String steamIronImg =
      'https://fabspin.org/public/assets/images/steam-iron-icon.png';
  final String defaultImg =
      'https://media.istockphoto.com/id/1055079680/vector/black-linear-photo-camera-like-no-image-available.jpg?s=612x612&w=0&k=20&c=P1DebpeMIAtXj_ZbVsKVvg-duuL0v9DlrOZUvPG6UJk=';

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("mr. blue"),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade300],
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.white,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
                unselectedLabelColor: Colors.black,
                indicatorPadding: EdgeInsets.all(6.w),
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
                  borderRadius: BorderRadius.circular(8.w),
                ),
                controller: tabController,
                tabs: const [Tab(text: 'PICKUPS'), Tab(text: 'DROP OFFS')],
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    ListView.builder(
                      itemCount: pickups.length,
                      itemBuilder: (context, index) {
                        final pickup = pickups[index];
                        final status = pickup['status'];
                        final service = pickup['service'];

                        String imgUrl;
                        if (service == 'Dry Cleaning') {
                          imgUrl = dryCleanImg;
                        } else if (service == 'Shoe Cleaning') {
                          imgUrl = shoeCleanImg;
                        } else if (service == 'Steam Iron') {
                          imgUrl = steamIronImg;
                        } else {
                          imgUrl = defaultImg;
                        }

                        return _buildPickupCard(
                          service: pickup['service'],
                          bookingCode: pickup['booking_code'],
                          pickupDate: pickup['pickup_date'],
                          pickupTime: pickup['pickup_time'],
                          riderName: pickup['rider_name'],
                          status: status,
                          imgUrl: imgUrl,
                          onClick: () {},
                        );
                      },
                    ),
                    dropoffs.isEmpty
                        ? Center(
                          child: Text(
                            "No drop-offs found",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        )
                        : ListView.builder(
                          itemCount: dropoffs.length,
                          itemBuilder: (context, index) {
                            final dropoff = dropoffs[index];
                            final service = dropoff['service_name'];

                            String imgUrl;
                            if (service == 'Dry Cleaning') {
                              imgUrl = dryCleanImg;
                            } else if (service == 'Shoe Cleaning') {
                              imgUrl = shoeCleanImg;
                            } else if (service == 'Steam Iron') {
                              imgUrl = steamIronImg;
                            } else {
                              imgUrl = defaultImg;
                            }

                            return _buildDropoffCard(
                              service: service,
                              bookingCode: dropoff['booking_code'],
                              dropDate: dropoff['drop_date'],
                              dropTime: dropoff['drop_time'],
                              riderName: dropoff['rider_name'],
                              imgUrl: imgUrl,
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

  Widget _buildPickupCard({
    required String service,
    required String bookingCode,
    required String pickupDate,
    required String pickupTime,
    required String riderName,
    required int status,
    required String imgUrl,
    required VoidCallback onClick,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue[900]!),
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!.withOpacity(0.3),
            blurRadius: 5.w,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16.w),
            Container(
              width: 72.w,
              height: 72.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue[900]!),
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.w),
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Icon(Icons.error, size: 40.w),
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.blue[900],
                      letterSpacing: 1,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    "Booking Code: $bookingCode",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    "Rider Name: $riderName",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    "Pickup Date: $pickupDate",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    "Pickup Time: $pickupTime",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  status == 1
                      ? InkWell(
                        onTap: onClick,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                          child: Text(
                            "Cancel Pickup",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      )
                      : Text(
                        "Cancelled Pickup",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                          fontSize: 12.sp,
                        ),
                      ),
                ],
              ),
            ),
            SizedBox(width: 15.w),
          ],
        ),
      ),
    );
  }

  Widget _buildDropoffCard({
    required String service,
    required String bookingCode,
    required String dropDate,
    required String dropTime,
    required String riderName,
    required String imgUrl,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue[900]!),
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!.withOpacity(0.3),
            blurRadius: 5.w,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 15.w),
            Container(
              width: 72.w,
              height: 72.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue[900]!),
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.w),
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Icon(Icons.error, size: 40.w),
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[900],
                      letterSpacing: 1,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    "Booking Code: $bookingCode",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    "Drop Date: $dropDate",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    "Drop Time: $dropTime",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    "Rider Name: $riderName",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 15.w),
          ],
        ),
      ),
    );
  }
}
