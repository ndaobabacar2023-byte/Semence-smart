// widgets/map_location_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapLocationPicker extends StatefulWidget {
  final Function(LatLng position, String adresse, String zone) onLocationSelected;

  const MapLocationPicker({Key? key, required this.onLocationSelected}) : super(key: key);

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late MapController _mapController;
  LatLng _selectedPosition = const LatLng(14.4974, -14.4524);
  String _adresse = "Recherche de votre position...";
  bool _chargement = true;
  String _latitudeStr = "";
  String _longitudeStr = "";

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentPosition();
  }

  Future<void> _getCurrentPosition() async {
    setState(() {
      _chargement = true;
      _adresse = "Recherche de votre position...";
    });

    try {
      // Demander la permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _adresse = "Permission GPS refusée";
          _chargement = false;
        });
        return;
      }

      // Attendre d'avoir une bonne position
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      
      _latitudeStr = pos.latitude.toStringAsFixed(6);
      _longitudeStr = pos.longitude.toStringAsFixed(6);
      
      LatLng nouvellePos = LatLng(pos.latitude, pos.longitude);
      
      // Afficher d'abord les coordonnées
      String adresse = "📍 ${_latitudeStr}° N, ${_longitudeStr}° E";
      
      // Essayer d'obtenir le nom de la ville en arrière-plan
      _getVilleName(pos.latitude, pos.longitude).then((ville) {
        if (ville.isNotEmpty && mounted) {
          setState(() {
            _adresse = "$ville\n📍 ${_latitudeStr}° N, ${_longitudeStr}° E";
          });
          widget.onLocationSelected(nouvellePos, _adresse, _getZone(pos.latitude, pos.longitude));
        }
      });
      
      String zone = _getZone(pos.latitude, pos.longitude);

      setState(() {
        _selectedPosition = nouvellePos;
        _adresse = adresse;
        _chargement = false;
      });

      _mapController.move(nouvellePos, 15);
      widget.onLocationSelected(nouvellePos, adresse, zone);
      
      print("=== POSITION GPS BRUTE ===");
      print("Latitude: ${pos.latitude}");
      print("Longitude: ${pos.longitude}");
      print("Précision: ${pos.accuracy} mètres");
      print("==========================");
      
    } catch (e) {
      print("Erreur GPS: $e");
      setState(() {
        _adresse = "Cliquez sur la carte pour choisir";
        _chargement = false;
      });
    }
  }

  Future<String> _getVilleName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        if (p.locality != null && p.locality!.isNotEmpty) {
          return p.locality!;
        }
        if (p.subLocality != null && p.subLocality!.isNotEmpty) {
          return p.subLocality!;
        }
      }
    } catch (e) {}
    return "";
  }

  String _getZone(double lat, double lng) {
    if (lat >= 15.5) return "Nord";
    if (lat >= 14.8 && lng <= -15.0) return "Vallée du Fleuve";
    if (lat >= 14.4 && lat < 14.9 && lng >= -17.6 && lng <= -16.5)
      return "Littoral - Niayes";
    if (lat >= 13.8 && lat < 14.4) return "Centre";
    if (lat >= 13.0 && lat < 13.8) return "Sud";
    if (lat < 13.0) return "Casamance";
    return "Centre";
  }

  Future<void> _onTapCarte(TapPosition tap, LatLng point) async {
    setState(() {
      _selectedPosition = point;
      _adresse = "Chargement...";
    });

    String adresse = "${point.latitude.toStringAsFixed(6)}° N, ${point.longitude.toStringAsFixed(6)}° E";
    String zone = _getZone(point.latitude, point.longitude);

    setState(() => _adresse = adresse);
    widget.onLocationSelected(point, adresse, zone);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre d'adresse
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.green.shade50,
          child: Row(
            children: [
              Icon(_chargement ? Icons.gps_fixed : Icons.location_on, 
                   color: Colors.green.shade700, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: _chargement
                    ? const Row(children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text("Recherche de votre position..."),
                      ])
                    : Text(_adresse, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
              ),
              IconButton(
                icon: Icon(Icons.my_location, color: Colors.green.shade700),
                onPressed: _getCurrentPosition,
                tooltip: "Re-centrer sur ma position",
              ),
            ],
          ),
        ),
        
        // La carte
        SizedBox(
          height: 350,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(14.4974, -14.4524),
              initialZoom: 7,
              onTap: _onTapCarte,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.semence_smart',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition,
                    width: 50,
                    height: 50,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.location_on, color: Colors.white, size: 16),
                        ),
                        Container(width: 2, height: 12, color: Colors.green.shade700),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Coordonnées GPS
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gps_fixed, size: 12, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                "${_selectedPosition.latitude.toStringAsFixed(6)}° N, ${_selectedPosition.longitude.toStringAsFixed(6)}° E",
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}