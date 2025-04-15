import 'package:flutter/material.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/setting/screens/add_address.dart';

class AddAddressStatic extends StatefulWidget {
  const AddAddressStatic({super.key});

  @override
  State<AddAddressStatic> createState() => _AddAddressStaticState();
}

class _AddAddressStaticState extends State<AddAddressStatic> {
  // Static list of addresses
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
    // Initialize address strings from static data
    _addressAll =
        _addresses.map((address) {
          final house = address['house'] ?? '';
          final landmark = address['landmark'] ?? '';
          final mainAddress = address['address'] ?? '';
          return '$house, $landmark, $mainAddress';
        }).toList();

    // Set default address
    final defaultAddressIndex = _addresses.indexWhere(
      (address) => address['default'] == 1,
    );
    _selectedAddressIndex =
        defaultAddressIndex >= 0 ? defaultAddressIndex : null;
  }

  void _setDefaultAddress(int index) {
    setState(() {
      // Update default status
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

      // Reset selected index if deleted address was selected
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
                padding: const EdgeInsets.all(16.0),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: Colors.white),
                          const SizedBox(width: 15),
                          Text(
                            'Add Address',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 1,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Text(
                    'Saved Addresses',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                      letterSpacing: 1,
                      fontSize: 15,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 15),
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
                      margin: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade800 : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 3,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(19.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.home,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _addressAll[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isSelected ? Colors.white : Colors.grey,
                                  letterSpacing: 1,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
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
                                                  : Colors.grey,
                                          letterSpacing: 1,
                                          fontSize: 15,
                                        ),
                                      ),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'Delete Address',
                                              ),
                                              content: const Text(
                                                'Are you sure you want to delete this address?',
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
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.grey,
                                          letterSpacing: 1,
                                          fontSize: 15,
                                        ),
                                      ),
                                      onTap: () {
                                        // Navigate to edit address screen
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                isSelected
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    )
                                    : const Icon(Icons.add, color: Colors.grey),
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
