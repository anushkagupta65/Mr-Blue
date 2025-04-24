import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:permission_handler/permission_handler.dart' as app_settings;
import 'package:mr_blue/src/services/api_services.dart';
import 'dart:async';

class MapHelper {
  final GoogleMapsPlaces _places = GoogleMapsPlaces(
    apiKey: 'AIzaSyCHnauUdIQDCprpFfdj6-JRlskIDTzWg94',
  );
  Timer? _debounce;

  Future<void> getUserId(void Function(String? id) onUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    print('[DEBUG] MapHelper: User ID from SharedPreferences: $userId');
    onUserId(userId);
  }

  Future<void> getCurrentLocation({
    required void Function(bool loading) onLoading,
    required void Function(LatLng position) onPosition,
    required void Function(String address, String zip) onAddress,
    required void Function(String message) onError,
  }) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onLoading(false);
      onError('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        onLoading(false);
        onError('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      onLoading(false);
      onError('Location permissions are permanently denied.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    onLoading(false);
    LatLng latLng = LatLng(position.latitude, position.longitude);
    onPosition(latLng);
    await getAddressFromLatLng(
      position.latitude.toString(),
      position.longitude.toString(),
      onAddress,
    );
  }

  Future<void> openAppSettings() async {
    await app_settings.openAppSettings();
  }

  Future<void> searchPlaces(
    String input,
    String sessionToken,
    void Function(List<Prediction> predictions) onPredictions,
    void Function(String message) onError,
  ) async {
    print(
      '[DEBUG] MapHelper: searchPlaces called with input: $input, sessionToken: $sessionToken',
    );
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      if (input.isEmpty) {
        onPredictions([]);
        return;
      }

      try {
        List<Prediction> allPredictions = [];
        final queries = [input, '$input ', '$input city', '$input street'];

        for (final query in queries) {
          PlacesAutocompleteResponse response = await _places.autocomplete(
            query,
            language: 'en',
            sessionToken: sessionToken,
          );
          allPredictions.addAll(response.predictions);
          if (allPredictions.length >= 30) break;
        }

        final seenPlaceIds = <String>{};
        final predictions =
            allPredictions.where((prediction) {
              final placeId = prediction.placeId;
              if (placeId != null && !seenPlaceIds.contains(placeId)) {
                seenPlaceIds.add(placeId);
                return true;
              }
              return false;
            }).toList();

        onPredictions(predictions);
      } catch (e) {
        print('[DEBUG] MapHelper: Place search error: $e');
        onError('Error searching places: $e');
      }
    });
  }

  Future<void> selectPlace(
    Prediction prediction,
    String sessionToken,
    void Function(LatLng position, String address) onPlaceSelected,
    void Function(String zip) onZipCode,
    void Function(String message) onError,
  ) async {
    try {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(
        prediction.placeId!,
        sessionToken: sessionToken,
      );
      final lat = detail.result.geometry?.location.lat;
      final lng = detail.result.geometry?.location.lng;

      if (lat != null && lng != null) {
        final position = LatLng(lat, lng);
        onPlaceSelected(
          position,
          prediction.description ?? "Unable to fetch address",
        );
        await getAddressFromLatLng(lat.toString(), lng.toString(), (
          address,
          zip,
        ) {
          print('[DEBUG] MapHelper: Address from place: $address, Zip: $zip');
          onZipCode(zip);
        });
      } else {
        onError('Could not retrieve coordinates');
      }
    } catch (e) {
      print('[DEBUG] MapHelper: Place selection error: $e');
      onError('Error fetching place details: $e');
    }
  }

  Future<void> getAddressFromLatLng(
    String latitude,
    String longitude,
    void Function(String address, String zip) onAddress,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        double.parse(latitude),
        double.parse(longitude),
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode} ${place.country}";
        print('[DEBUG] MapHelper: Address constructed: $address');
        onAddress(address, place.postalCode ?? "No Zip Code");
      } else {
        onAddress("Unable to fetch address", "No Zip Code");
      }
    } catch (e) {
      print('[DEBUG] MapHelper: Address fetch error: $e');
      onAddress("Unable to fetch address", "No Zip Code");
    }
  }

  void updateMarker(Set<Marker> markers, LatLng position) {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
        infoWindow: const InfoWindow(title: 'Selected Location'),
      ),
    );
  }

  Future<void> fetchCities({
    required void Function(bool loading) onLoading,
    required void Function(List<Map<String, String>> cities) onCities,
    required void Function(String message) onError,
  }) async {
    onLoading(true);
    try {
      String responseBody = await ApiService().fetchCities();
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      if (jsonResponse['Status'] == 'Success') {
        List<dynamic> citiesJson = jsonResponse['Text'];
        onCities(
          citiesJson
              .map(
                (city) => {
                  'name': city['name'].toString(),
                  'id': city['id'].toString(),
                },
              )
              .toList(),
        );
      } else {
        throw Exception(
          'API returned non-success status: ${jsonResponse['Status']}',
        );
      }
    } catch (e) {
      print('[DEBUG] MapHelper: Cities fetch error: $e');
      onError("Failed to load cities: $e");
    } finally {
      onLoading(false);
    }
  }

  Future<void> updateUserAddress({
    required String? userId,
    required String cityId,
    required String zipCode,
    required String address,
    required String finalAddress,
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    if (userId == null) {
      onError("User not logged in");
      return;
    }

    try {
      final response = await ApiService().updateUserAddress(
        userId: userId,
        cityId: cityId,
        zip: zipCode,
        address: address,
      );

      final responseData = jsonDecode(response);
      if (responseData['Status'] == "Success") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_address', finalAddress);
        print(
          '[DEBUG] MapHelper: Final address saved to SharedPreferences: $finalAddress',
        );
        onSuccess();
      } else {
        print(
          '[DEBUG] MapHelper: Address update failed: ${responseData['Text']}',
        );
        onError("Failed to update address: ${responseData['Text']}");
      }
    } catch (e) {
      print('[DEBUG] MapHelper: Address update error: $e');
      onError("An error occurred while updating address");
    }
  }
}
