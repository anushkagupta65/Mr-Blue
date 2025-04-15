import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/schedule_pickup/screens/booking_confirmation.dart';
import 'package:mr_blue/src/services/api_services.dart';

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

      // Find the city ID for the selected city
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
        // Call the addAddress API
        String responseBody = await ApiService().addAddress(
          cityId,
          _streetController.text.trim(),
          _zipController.text.trim(),
        );

        // Parse the response
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['Status'] == 'Success') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => const Confirmation(
                    title: 'Address Added',
                    desription: 'Your address has been added successfully.',
                  ),
            ),
          );

          // Clear the form
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        textInputAction: inputAction,
        obscureText: obscureText,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint ?? 'Enter your $label',
          labelStyle: GoogleFonts.poppins(color: Colors.black),
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
          prefixIcon: icon != null ? Icon(icon, color: Colors.black) : null,
          suffixIcon:
              suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCity,
        decoration: InputDecoration(
          labelStyle: GoogleFonts.poppins(color: Colors.black),
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
          prefixIcon: const Icon(
            Icons.location_city_outlined,
            color: Colors.black,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
        ),
        items:
            _cities.map((city) {
              return DropdownMenuItem<String>(
                value: city['name'],
                child: Text(city['name']!, style: GoogleFonts.poppins()),
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
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Text(
                  'Select a city',
                  style: GoogleFonts.poppins(color: Colors.grey[400]),
                ),
        isExpanded: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Add Address"),
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
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        'Delivery Address',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please fill in the details below to add a new address.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        color: const Color.fromARGB(255, 197, 229, 255),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                  final trimmedValue = value?.trim() ?? '';
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
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitOrder,
                      icon:
                          _isSubmitting
                              ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(
                                Icons.local_shipping_outlined,
                                size: 22,
                                color: Colors.white,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        foregroundColor: Colors.blue,
                      ),
                      label: Text(
                        _isSubmitting ? 'Adding...' : 'Add Address',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
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
  }
}
