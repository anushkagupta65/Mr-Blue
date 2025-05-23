import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://crm.mr-blue.in/api';

  static Map<String, String> _getHeaders() {
    return {'Accept': 'application/json'};
  }

  // ========================================================================== POST ======================================================
  // =================================================================== TO REGISTER NEW USER =============================================
  /// Registers a new user with the provided mobile number.
  Future<String> registerNewUser(String mobile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/new-user-register'),
      );

      request.fields.addAll({'mobile': mobile});
      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ======================================================================== POST ======================================================
  // =================================================================== TO VERIFY OTP ===================================================
  /// Verifies the OTP for a user.
  Future<String> verifyOtp(String userId, String otp) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/new-user-otp-match'),
      );

      request.fields.addAll({'user_id': userId, 'otp': otp});
      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ================================================================== TO GET SERVICES ==================================================
  /// Fetches the list of services available for a user.
  Future<String> getServices() async {
    try {
      var request = http.Request(
        'GET',
        Uri.parse('$_baseUrl/new-user-get-services/1'),
      );

      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ================================================================= TO UPDATE USER'S PROFILE INFORMATION ===================================
  /// Updates the profile for a user.
  Future<String> updateProfile(String userId, String name, String email) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/update-profile'),
      );

      request.fields.addAll({'user_id': userId, 'name': name, 'email': email});
      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================-========= TO GET USER'S PROFILE ===================================================
  /// Fetches the profile information for a user.
  Future<String> checkAvailableTime(String date) async {
    try {
      var request = http.Request(
        'GET',
        Uri.parse('$_baseUrl/check-available-time/$date/15:30/pick'),
      );
      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> availableAddress(String userID) async {
    try {
      var request = http.Request(
        'GET',
        Uri.parse('$_baseUrl/new-user-get-address/$userID'),
      );
      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ================================================================= TO GET CITIES ===================================================
  /// Fetches the list of cities available for a user.
  Future<String> fetchCities() async {
    try {
      var request = http.Request('GET', Uri.parse('$_baseUrl/new-user-city'));
      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ================================================================ TO ADD ADDRESS ===================================================
  /// Adds a new address for a user.
  Future<String> addAddress(String cityId, String address, String zip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? '';

      if (userId.isEmpty) {
        throw Exception('User ID not found in SharedPreferences');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/new-user-update-address'),
      );

      request.fields.addAll({
        'user_id': userId,
        'city_id': cityId,
        'zip': zip,
        'address': address,
      });
      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ================================================================ TO POST USER'S LOCATION ===================================================
  /// Posts the user's location with latitude and longitude.
  Future<String> postUserLocation(String latitude, String longitude) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/new-user-time-slot'),
      );

      request.fields.addAll({
        'latitude': latitude,
        'longitude': longitude,
        // 'latitude': '28.536165745526322',
        // 'longitude': '77.14089179999999',
      });
      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ================================================================ TO GET LAUNDRY PRICE DETAILS ===================================================
  /// Fetches the laundry price details for a given region.
  Future<String> getLaundryPriceDetails(String regionId) async {
    try {
      var request = http.Request(
        'GET',
        Uri.parse('$_baseUrl/new-user-get-price-services/$regionId'),
      );

      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ================================================================ TO GET DRY CLEANING PRICE DETAILS ===================================================
  /// Fetches the dry cleaning price details for a given region.
  Future<String> getDryCleaningPriceDetails(String regionId) async {
    try {
      var request = http.Request(
        'GET',
        Uri.parse('$_baseUrl/pricelists/$regionId'),
      );

      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  //
  Future<String> updateUserAddress({
    required String userId,
    required String cityId,
    required String zip,
    required String address,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/new-user-update-address'),
      );

      request.headers.addAll(_getHeaders());

      request.fields.addAll({
        'user_id': userId,
        'city_id': cityId,
        'zip': zip,
        'address': address,
      });

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> bookOrder(
    String userId,
    String addressId,
    String picdate,
    String dropdate,
    String timeSlotId,
    String storeId,
    String sameOrNextDay,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/confirm-new-booking'),
      );

      request.fields.addAll({
        'user_id': userId,
        'address_id': addressId,
        'picdate': picdate,
        'dropdate': dropdate,
        'timeslot_id': timeSlotId,
        'timeslot2_id': timeSlotId,
        'store_id': storeId,
        'same_or_next_day': sameOrNextDay,
      });
      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> submitContactUs(
    String name,
    String email,
    String phone,
    String message,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/contact-us'),
      );

      request.fields.addAll({
        'name': name,
        'email': email,
        'phone': phone,
        'message': message,
      });

      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseBody;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<String>> getStoreNames() async {
    try {
      var request = http.Request('GET', Uri.parse('$_baseUrl/new-stores'));

      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();

      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        List<dynamic> stores = jsonDecode(responseBody);
        List<String> storeNames =
            stores.map((store) => store['name'].toString()).toList();
        return storeNames;
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List> fetchUserBookings(String userID) async {
    try {
      var request = http.Request(
        'GET',
        Uri.parse('$_baseUrl/user-booking-list/$userID'),
      );
      request.headers.addAll(_getHeaders());

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['status'] == 'success') {
          return jsonResponse['bookings'];
        } else {
          throw Exception('API returned unsuccessful status');
        }
      } else {
        throw Exception(
          'Failed: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  // ================================================================ TO HANDLE EXCEPTION ===================================================
  /// Handles errors that occur during API requests.
  Exception _handleError(dynamic error) {
    if (error is http.ClientException) {
      return Exception('Network error: ${error.message}');
    }
    return Exception('An error occurred: $error');
  }
}
