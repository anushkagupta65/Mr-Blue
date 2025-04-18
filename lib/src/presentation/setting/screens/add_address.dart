import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/home/map_screen.dart';
import 'package:mr_blue/src/presentation/schedule_pickup/screens/booking_confirmation.dart';
import 'package:mr_blue/src/services/api_services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _zipController = TextEditingController();
  String? _selectedCity;
  List<Map<String, String>> _cities = [];
  bool _isLoadingCities = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _fetchCities() async {
    setState(() {
      _isLoadingCities = true;
    });
    try {
      String responseBody = await ApiService().fetchCities();
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      if (jsonResponse['Status'] == 'Success') {
        List<dynamic> citiesJson = jsonResponse['Text'];
        setState(() {
          _cities =
              citiesJson
                  .map(
                    (city) => {
                      'name': city['name'].toString(),
                      'id': city['id'].toString(),
                    },
                  )
                  .toList();
          _isLoadingCities = false;
        });
      } else {
        throw Exception(
          'API returned non-success status: ${jsonResponse['Status']}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingCities = false;
      });
      showToastMessage("Failed to load cities: $e");
    }
  }

  void _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      String? cityId;
      for (var city in _cities) {
        if (city['name'] == _selectedCity) {
          cityId = city['id'];
          break;
        }
      }

      if (cityId == null) {
        setState(() {
          _isSubmitting = false;
        });
        showToastMessage("Please select a city");
        return;
      }

      try {
        String responseBody = await ApiService().addAddress(
          cityId,
          _streetController.text.trim(),
          _zipController.text.trim(),
        );

        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['Status'] == 'Success') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => Confirmation(
                    title: 'Address Added',
                    desription: 'Your address has been added successfully.',
                  ),
            ),
          );

          _streetController.clear();
          _zipController.clear();
          setState(() {
            _selectedCity = null;
          });
        } else {
          throw Exception(
            'API returned non-success status: ${jsonResponse['Status']}',
          );
        }
      } catch (e) {
        showToastMessage("Failed to add address: $e");
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    IconData? suffixIcon,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
    TextInputAction inputAction = TextInputAction.next,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.r),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        textInputAction: inputAction,
        obscureText: obscureText,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint ?? 'Enter your $label',
          labelStyle: TextStyle(color: Colors.black, fontSize: 16.sp),
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          prefixIcon:
              icon != null
                  ? Icon(icon, color: Colors.black, size: 24.sp)
                  : null,
          suffixIcon:
              suffixIcon != null
                  ? Icon(suffixIcon, color: Colors.grey, size: 24.sp)
                  : null,
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.w),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.r),
      child: DropdownButtonFormField<String>(
        value: _selectedCity,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.black, fontSize: 16.sp),
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          prefixIcon: Icon(
            Icons.location_city_outlined,
            color: Colors.black,
            size: 24.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.w),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 18.h,
          ),
        ),
        items:
            _cities.map((city) {
              return DropdownMenuItem<String>(
                value: city['name'],
                child: Text(city['name']!, style: TextStyle(fontSize: 16.sp)),
              );
            }).toList(),
        onChanged: (value) {
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
                  'Select a city',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                ),
        isExpanded: true,
      ),
    );
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
              colors: [Colors.white, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.all(20.r),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Delivery Address',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Please fill in the details below to add a new address.',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Card(
                                  color: Color.fromARGB(255, 197, 229, 255),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.r),
                                    child: Column(
                                      children: [
                                        _buildTextField(
                                          controller: _streetController,
                                          label: 'Street Address',
                                          icon: Icons.location_on_outlined,
                                        ),
                                        _buildCityDropdown(),
                                        _buildTextField(
                                          maxLength: 6,
                                          controller: _zipController,
                                          label: 'ZIP Code',
                                          icon: Icons.code_outlined,
                                          inputType: TextInputType.number,
                                          validator: (value) {
                                            final trimmedValue =
                                                value?.trim() ?? '';
                                            if (trimmedValue.isEmpty) {
                                              return 'Please enter ZIP code';
                                            }
                                            if (!RegExp(
                                              r'^\d{6}$',
                                            ).hasMatch(trimmedValue)) {
                                              return 'ZIP code must be six digits';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.blue.shade800,
                                        thickness: 2,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Or',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blue.shade800,
                                        letterSpacing: 1,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.blue.shade800,
                                        thickness: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    minimumSize: Size(double.infinity, 40.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24.r),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MapScreen(
                                              calledFrom: "add_address",
                                            ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32.w,
                                      vertical: 8.h,
                                    ),
                                    child: Text(
                                      "Choose on maps",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : _submitOrder,
                                icon:
                                    _isSubmitting
                                        ? SizedBox(
                                          height: 22.h,
                                          width: 22.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.w,
                                            color: Colors.white,
                                          ),
                                        )
                                        : Icon(
                                          Icons.local_shipping_outlined,
                                          size: 22.sp,
                                          color: Colors.white,
                                        ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding: EdgeInsets.symmetric(vertical: 18.h),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  foregroundColor: Colors.blue,
                                ),
                                label: Text(
                                  _isSubmitting ? 'Adding...' : 'Add Address',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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
      ),
    );
  }
}
