// helper_methods.dart
import 'package:flutter/material.dart';
import 'package:mr_blue/src/core/utils.dart';

class BookingHelper {
  static void onScheduleTap(
    BuildContext context,
    int? timeid,
    List<dynamic> addresses,
    String userId,
  ) async {
    if (timeid != null) {
      if (addresses.isNotEmpty) {
        // _showAddressBottomSheet(context); // Placeholder
      } else {
        showToastMessage('No addresses available');
      }
    } else {
      showToastMessage('Please select a time slot');
    }
  }
}
