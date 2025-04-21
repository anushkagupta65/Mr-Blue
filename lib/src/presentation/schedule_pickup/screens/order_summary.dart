import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/home/map_screen.dart';
import 'package:mr_blue/src/presentation/schedule_pickup/screens/booking_confirmation.dart';
import 'package:mr_blue/src/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OrderSummaryScreen extends StatefulWidget {
  final String picdate;
  final String sameOrNextDay;
  final String timeSlotId;
  final String timeSlot;
  final String selectedValue;

  const OrderSummaryScreen({
    super.key,
    required this.picdate,
    required this.sameOrNextDay,
    required this.timeSlotId,
    required this.timeSlot,
    required this.selectedValue,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  DateTime? deliveryDateTime;
  String addressID = "";
  String userID = "";
  String address = "";
  String storeID = "";
  bool isLoading = false;
  bool showAddressError = false;

  @override
  void initState() {
    super.initState();
    loadDetails();
    loadContactNumber();
    fetchDeliveryDateTime();
  }

  Future<void> loadContactNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString('user_mobile') ?? '';
    setState(() {
      contactNumberController.text = number;
    });
  }

  Future<void> loadDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final addressId = prefs.getString('user_address_id') ?? '';
    final userId = prefs.getString('user_id') ?? "";
    final savedAddress = prefs.getString('user_address') ?? "";
    final storeId = prefs.getString('store_id') ?? '';
    setState(() {
      addressID = addressId;
      userID = userId;
      address = savedAddress;
      storeID = storeId;
    });
    print(
      "THESE ARE DETAILS OF USER - address id - $addressId; user id - $userId, address - $address, store id - $storeID",
    );
  }

  Future<void> fetchDeliveryDateTime() async {
    DateTime parsedDate = DateTime.parse(widget.picdate);
    setState(() {
      if (widget.sameOrNextDay == "1" && widget.selectedValue == "0") {
        deliveryDateTime = parsedDate;
      } else if (widget.sameOrNextDay == "1" && widget.selectedValue == "1") {
        deliveryDateTime = parsedDate.add(Duration(days: 1));
      } else {
        deliveryDateTime = parsedDate.add(Duration(days: 3));
      }
    });
  }

  String getDeliveryDateTime() {
    if (deliveryDateTime != null) {
      final dateTime = DateTime(
        deliveryDateTime!.year,
        deliveryDateTime!.month,
        deliveryDateTime!.day,
      );
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
    return 'Loading..';
  }

  Future<void> bookOrder(
    String userId,
    String addressId,
    String picdate,
    String dropdate,
    String timeSlotId,
    String storeId,
    String sameOrNextDay,
  ) async {
    setState(() {
      isLoading = true; // Show loader
    });
    final response = await ApiService().bookOrder(
      userId,
      addressId,
      picdate,
      dropdate,
      timeSlotId,
      storeId,
      sameOrNextDay,
    );
    setState(() {
      isLoading = false; // Hide loader
    });
    final responseBody = jsonDecode(response);
    if (responseBody['Status'] == "Success") {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isLoading = false; // Hide loader
        });
        showToastMessage("Order Confirmed");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => const Confirmation(
                  title: 'Order Confirmed',
                  desription: "Your order has been successfully placed.",
                ),
          ),
        );
      });
    } else {
      showToastMessage("Could not place order");
    }
  }

  @override
  Widget build(BuildContext context) {
    String dropdate = getDeliveryDateTime();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 248, 255),
      appBar: customAppBar("Order Summary"),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Number',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextField(
                              readOnly: true,
                              controller: contactNumberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Enter contact number',
                                hintStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Address',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText:
                                    address.isEmpty
                                        ? 'No address provided..'
                                        : address,
                                hintStyle: TextStyle(
                                  color:
                                      address.isEmpty
                                          ? Colors.grey.shade400
                                          : Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        address.isEmpty && showAddressError
                                            ? Colors.red
                                            : Colors.grey.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MapScreen(
                                              calledFrom: "order_summary",
                                            ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    address.isEmpty
                                        ? "Kindly add address from here to continue .. "
                                        : "Do you want to change address ..?",
                                    style: TextStyle(
                                      wordSpacing: 2,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Pickup Date & Time',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText:
                                    "${widget.picdate}, ${widget.timeSlot}",
                                hintStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Delivery Date & Time',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon:
                                    widget.selectedValue == "-1"
                                        ? IconButton(
                                          icon: Icon(
                                            Icons.calendar_today,
                                            color: Colors.grey.shade600,
                                          ),
                                          onPressed: () async {
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                                  context: context,

                                                  initialDate: DateTime.parse(
                                                    dropdate,
                                                  ),
                                                  firstDate: DateTime.parse(
                                                    dropdate,
                                                  ),
                                                  lastDate: DateTime(2100),
                                                );
                                            if (pickedDate != null) {
                                              String formattedDate = DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(pickedDate);
                                              setState(() {
                                                dropdate = formattedDate;
                                              });
                                            }
                                          },
                                        )
                                        : null,
                                hintText: '$dropdate, ${widget.timeSlot}',
                                hintStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (address.isEmpty) {
                              setState(() {
                                showAddressError = true; // Show error
                              });
                              showToastMessage("Please add an address");
                              return;
                            }
                            print(
                              "These are details passed in booking order : user id  - $userID, address id - $addressID, picdate - ${widget.picdate}, dropdate - $dropdate, timeslotId - ${widget.timeSlotId}, store id - $storeID, samenextday - ${widget.sameOrNextDay} ",
                            );
                            await bookOrder(
                              userID,
                              addressID,
                              widget.picdate,
                              dropdate,
                              widget.timeSlotId,
                              storeID,
                              widget.sameOrNextDay,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 3,
                          ),
                          child:
                              isLoading
                                  ? SizedBox(
                                    height: 24.h,
                                    width: 24.h,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.w,
                                    ),
                                  )
                                  : Text(
                                    'CONFIRM ORDER',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
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
      ),
    );
  }
}
