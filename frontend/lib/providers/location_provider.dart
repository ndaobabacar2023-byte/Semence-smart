// providers/location_provider.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? _currentPosition;
  String _currentZone = '';
  String _currentAddress = '';
  bool _isLoading = false;
  bool _isApiAvailable = true;

  LatLng? get currentPosition => _currentPosition;
  String get currentZone => _currentZone;
  String get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  bool get isApiAvailable => _isApiAvailable;

  // Méthode d'initialisation
  Future<void> initLocation(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulation de chargement (à remplacer par votre logique GPS)
    await Future.delayed(const Duration(seconds: 2));
    
    _currentZone = "Centre";
    _isLoading = false;
    _isApiAvailable = true;
    notifyListeners();
  }

  void updateLocation(LatLng position, String address, String zone) {
    _currentPosition = position;
    _currentAddress = address;
    _currentZone = zone;
    notifyListeners();
  }
}