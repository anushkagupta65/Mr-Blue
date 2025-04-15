import 'package:flutter/material.dart';
import 'package:mr_blue/src/core/utils.dart';

class MyRequests extends StatefulWidget {
  const MyRequests({super.key});

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  // Dummy data for UI
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
                  fontSize: 14,
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
                controller: tabController,
                tabs: const [Tab(text: 'PICKUPS'), Tab(text: 'DROP OFFS')],
              ),
              SizedBox(height: 10),
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
                          onClick: () {
                            // Handle cancel pickup
                          },
                        );
                      },
                    ),
                    dropoffs.isEmpty
                        ? const Center(child: Text("No drop-offs found"))
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue[900]!),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue[900]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 20),
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
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Booking Code: $bookingCode",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Rider Name: $riderName",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Pickup Date: $pickupDate",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Pickup Time: $pickupTime",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  status == 1
                      ? InkWell(
                        onTap: onClick,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Cancel Pickup",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      : Text(
                        "Cancelled Pickup",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                          fontSize: 14,
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(width: 15),
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue[900]!),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 15),
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue[900]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 20),
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
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Booking Code: $bookingCode",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Drop Date: $dropDate",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Drop Time: $dropTime",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Rider Name: $riderName",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }
}
