import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:mr_blue/src/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'dart:convert';

class HelperMethods {
  final ApiService _apiService = ApiService();
  final GoogleMapsPlaces _places = GoogleMapsPlaces(
    apiKey: 'AIzaSyCHnauUdIQDCprpFfdj6-JRlskIDTzWg94',
  );
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _displayAddress = "Add Location";
  List<Prediction> _predictions = [];
  bool _showSuggestions = false;
  double? _selectedLat;
  double? _selectedLng;
  Timer? _debounce;
  String _sessionToken = const Uuid().v4();
  bool _noStoreFound = false;

  Function(
    List<Map<String, dynamic>> services,
    bool isLoading,
    bool noStoreFound,
  )?
  onServicesUpdated;
  Function(String displayAddress)? onAddressUpdated;
  Function(List<Prediction> predictions, bool showSuggestions)?
  onPredictionsUpdated;

  HelperMethods({
    double? initialLat,
    double? initialLng,
    String? responseText,
  }) {
    _selectedLat = initialLat;
    _selectedLng = initialLng;
    _noStoreFound = responseText == "No store found in this location.";
    _fetchServices();
    _loadSavedAddress(); // Load saved address on initialization
    onServicesUpdated?.call(_services, _isLoading, _noStoreFound);
  }

  // Getters
  List<Map<String, dynamic>> get services => _services;
  bool get isLoading => _isLoading;
  TextEditingController get searchController => _searchController;
  String get displayAddress => _displayAddress;
  List<Prediction> get predictions => _predictions;
  bool get showSuggestions => _showSuggestions;
  bool get noStoreFound => _noStoreFound;

  Future<void> _saveAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_address', address);
  }

  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('user_address');
    _displayAddress =
        savedAddress != null && savedAddress.isNotEmpty
            ? savedAddress
            : "Add Location";
    onAddressUpdated?.call(_displayAddress);
  }

  Future<void> _fetchServices() async {
    try {
      String response = await _apiService.getServices();
      Map<String, dynamic> responseData = jsonDecode(response);
      List<dynamic> servicesData = responseData['services'] ?? [];
      print('Services Data: $servicesData');
      _services =
          servicesData
              .map(
                (service) => {
                  'name': service['name'] ?? 'Unknown Service',
                  'imageUrl': service['image'] ?? '',
                },
              )
              .toList();
      _isLoading = false;
      onServicesUpdated?.call(_services, _isLoading, _noStoreFound);
    } catch (e) {
      print('Error fetching services: $e');
      _isLoading = false;
      showToastMessage('Failed to load services');
      onServicesUpdated?.call(_services, _isLoading, _noStoreFound);
    }
  }

  Future<void> searchPlaces(String input) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      if (input.isEmpty) {
        _predictions = [];
        _showSuggestions = false;
        onPredictionsUpdated?.call(_predictions, _showSuggestions);
        return;
      }

      try {
        List<Prediction> allPredictions = [];
        final queries = [input, '$input ', '$input city', '$input street'];

        for (final query in queries) {
          PlacesAutocompleteResponse response = await _places.autocomplete(
            query,
            language: 'en',
            sessionToken: _sessionToken,
          );
          allPredictions.addAll(response.predictions);
          if (allPredictions.length >= 30) break;
        }

        final seenPlaceIds = <String>{};
        _predictions =
            allPredictions.where((prediction) {
              final placeId = prediction.placeId;
              if (placeId != null && !seenPlaceIds.contains(placeId)) {
                seenPlaceIds.add(placeId);
                return true;
              }
              return false;
            }).toList();

        _showSuggestions = true;
        onPredictionsUpdated?.call(_predictions, _showSuggestions);
      } catch (e) {
        print('Error searching places: $e');
        showToastMessage('Failed to search places');
        _showSuggestions = false;
        onPredictionsUpdated?.call(_predictions, _showSuggestions);
      }
    });
  }

  Future<void> selectPlace(Prediction prediction) async {
    try {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(
        prediction.placeId!,
        sessionToken: _sessionToken,
      );
      final lat = detail.result.geometry?.location.lat;
      final lng = detail.result.geometry?.location.lng;

      if (lat != null && lng != null) {
        _selectedLat = lat;
        _selectedLng = lng;
        _displayAddress = prediction.description ?? "Add Location";
        _searchController.clear();
        _predictions = [];
        _showSuggestions = false;
        _sessionToken = const Uuid().v4();
        onPredictionsUpdated?.call(_predictions, _showSuggestions);
        await _saveAddress(_displayAddress);
        onAddressUpdated?.call(_displayAddress);
        print('Selected Location: Latitude: $lat, Longitude: $lng');

        try {
          String response = await _apiService.postUserLocation(
            lat.toString(),
            lng.toString(),
          );
          print(
            '========================= API Response ========================: $response',
          );
          final responseBody = jsonDecode(response);
          final responseText = responseBody['Text'] ?? '';
          showToastMessage(responseText);

          if (responseText == "No store found in this location.") {
            _noStoreFound = true;
          } else {
            _noStoreFound = false;
          }
          onServicesUpdated?.call(_services, _isLoading, _noStoreFound);
        } catch (e) {
          print('Error posting user location: $e');
          showToastMessage('Failed to send location to server');
        }
      } else {
        showToastMessage('Could not retrieve coordinates');
      }
    } catch (e) {
      print('Error fetching place details: $e');
      showToastMessage('Failed to fetch place details');
    }
  }

  void clearSearch() {
    _searchController.clear();
    _predictions = [];
    _showSuggestions = false;
    onPredictionsUpdated?.call(_predictions, _showSuggestions);
  }

  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
  }
}
