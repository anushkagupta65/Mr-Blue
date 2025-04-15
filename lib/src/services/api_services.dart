import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://crm.mr-blue.in/api';

  static Map<String, String> _getHeaders() {
    return {'Accept': 'application/json'};
  }

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

      request.fields.addAll({'latitude': latitude, 'longitude': longitude});
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

  // ================================================================ TO HANDLE EXCEPTION ===================================================
  /// Handles errors that occur during API requests.
  Exception _handleError(dynamic error) {
    if (error is http.ClientException) {
      return Exception('Network error: ${error.message}');
    }
    return Exception('An error occurred: $error');
  }
}
