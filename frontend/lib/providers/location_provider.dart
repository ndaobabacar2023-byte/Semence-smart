import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/ipinfo_service.dart';

class LocationProvider extends ChangeNotifier {
  String _currentZone = 'Centre';
  bool _isLoading = false;
  bool _isApiAvailable = true;
  String _currentCity = '';
  String _currentRegion = '';
  
  String get currentZone => _currentZone;
  bool get isLoading => _isLoading;
  bool get isApiAvailable => _isApiAvailable;
  String get currentCity => _currentCity;
  String get currentRegion => _currentRegion;

  // ==========================================
  // INITIALISATION - Appelée au démarrage
  // ==========================================
  Future<void> initLocation(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 1. Vérifier si une zone est déjà sauvegardée
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedZone = prefs.getString('user_zone');
      
      if (savedZone != null && savedZone.isNotEmpty) {
        _currentZone = savedZone;
        _currentCity = prefs.getString('user_city') ?? '';
        _currentRegion = prefs.getString('user_region') ?? '';
        _isApiAvailable = true;
        _isLoading = false;
        notifyListeners();
        print("📍 Zone chargée depuis préférences: $_currentZone");
        return;
      }
      
      // 2. Détection automatique par API IPinfo
      print("📍 Tentative de détection automatique par IPinfo...");
      String zone = await IpinfoService.getCurrentZone();
      
      if (zone == 'Centre') {
        // Si la détection a échoué, demander à l'utilisateur
        _isApiAvailable = false;
        zone = await IpinfoService.askUserZone(context);
      } else {
        _isApiAvailable = true;
      }
      
      _currentZone = zone;
      
      // 3. Sauvegarder la zone
      await prefs.setString('user_zone', zone);
      if (_currentCity.isNotEmpty) await prefs.setString('user_city', _currentCity);
      if (_currentRegion.isNotEmpty) await prefs.setString('user_region', _currentRegion);
      
      print("✅ Zone finale: $_currentZone");
      
    } catch (e) {
      print("❌ Erreur initLocation: $e");
      _currentZone = 'Centre';
      _isApiAvailable = false;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // ==========================================
  // RAFRAÎCHIR LA LOCALISATION
  // ==========================================
  Future<void> refreshLocation(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    
    Fluttertoast.showToast(
      msg: "📍 Recherche de votre position...",
      backgroundColor: Colors.blue,
    );
    
    String zone = await IpinfoService.getCurrentZone();
    _currentZone = zone;
    _isApiAvailable = true;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_zone', zone);
    
    _isLoading = false;
    notifyListeners();
    
    Fluttertoast.showToast(
      msg: "📍 Zone mise à jour: $zone",
      backgroundColor: Colors.green,
    );
  }

  // ==========================================
  // CHANGER DE ZONE MANUELLEMENT
  // ==========================================
  Future<void> changeZone(String newZone, BuildContext context) async {
    _currentZone = newZone;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_zone', newZone);
    
    notifyListeners();
    
    Fluttertoast.showToast(
      msg: "📍 Zone changée: $newZone",
      backgroundColor: Colors.green,
    );
  }
}