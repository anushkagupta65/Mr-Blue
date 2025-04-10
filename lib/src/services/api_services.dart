import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://crm.mr-blue.in/api';

  static Map<String, String> _getHeaders() {
    return {'Accept': 'application/json'};
  }

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

  Exception _handleError(dynamic error) {
    if (error is http.ClientException) {
      return Exception('Network error: ${error.message}');
    }
    return Exception('An error occurred: $error');
  }
}
