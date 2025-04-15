import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/setting/screens/add_address.dart';

class AddAddressStatic extends StatefulWidget {
  const AddAddressStatic({super.key});

  @override
  State<AddAddressStatic> createState() => _AddAddressStaticState();
}

class _AddAddressStaticState extends State<AddAddressStatic> {
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': 1,
      'house': 'Apartment 4B',
      'landmark': 'Near City Park',
      'address': '123 Main Street',
      'is_active': 1,
      'default': 1,
    },
    {
      'id': 2,
      'house': 'Flat 101',
      'landmark': 'Opposite Mall',
      'address': '456 Oak Avenue',
      'is_active': 1,
      'default': 0,
    },
    {
      'id': 3,
      'house': 'Villa 7',
      'landmark': 'Lake View',
      'address': '789 Pine Road',
      'is_active': 1,
      'default': 0,
    },
  ];

  List<String> _addressAll = [];
  int? _selectedAddressIndex;

  @override
  void initState() {
    super.initState();
    _addressAll =
        _addresses.map((address) {
          final house = address['house'] ?? '';
          final landmark = address['landmark'] ?? '';
          final mainAddress = address['address'] ?? '';
          return '$house, $landmark, $mainAddress';
        }).toList();

    final defaultAddressIndex = _addresses.indexWhere(
      (address) => address['default'] == 1,
    );
    _selectedAddressIndex =
        defaultAddressIndex >= 0 ? defaultAddressIndex : null;
  }

  void _setDefaultAddress(int index) {
    setState(() {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i]['default'] = i == index ? 1 : 0;
      }
      _selectedAddressIndex = index;
    });
  }

  void _deleteAddress(int addressId) {
    setState(() {
      _addresses.removeWhere((address) => address['id'] == addressId);
      _addressAll =
          _addresses.map((address) {
            final house = address['house'] ?? '';
            final landmark = address['landmark'] ?? '';
            final mainAddress = address['address'] ?? '';
            return '$house, $landmark, $mainAddress';
          }).toList();

      if (_selectedAddressIndex != null &&
          _selectedAddressIndex! >= _addresses.length) {
        _selectedAddressIndex = _addresses.isNotEmpty ? 0 : null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0.w),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddressScreen(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(12.0.w),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 24.sp),
                          SizedBox(width: 15.w),
                          Text(
                            'Add Address',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 1,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Text(
                    'Saved Addresses',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade900,
                      letterSpacing: 1,
                      fontSize: 16.sp,
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 12.h),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _addresses.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final isSelected = _selectedAddressIndex == index;
                  final address = _addresses[index];
                  final addressID = address['id'];
                  return GestureDetector(
                    onTap: () => _setDefaultAddress(index),
                    child: Container(
                      margin: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade800 : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade600.withOpacity(0.4),
                            spreadRadius: 2.w,
                            blurRadius: 3.w,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(19.0.w),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.home,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                              size: 24.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                _addressAll[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                  letterSpacing: 1,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                          letterSpacing: 1,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                'Delete Address',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete this address?',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: Text(
                                                    'No',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.blue.shade700,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _deleteAddress(addressID);
                                                  },
                                                  child: Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.blue.shade700,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    SizedBox(width: 10.w),
                                    InkWell(
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                          letterSpacing: 1,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                isSelected
                                    ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16.sp,
                                    )
                                    : Icon(
                                      Icons.add,
                                      color: Colors.grey.shade600,
                                      size: 16.sp,
                                    ),
                              ],
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
      ),
    );
  }
}
