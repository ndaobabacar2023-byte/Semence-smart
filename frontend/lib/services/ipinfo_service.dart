import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class IpinfoService {
  static Future<String> getCurrentZone() async {
    try {
      final token = dotenv.env['IPINFO_TOKEN'];
      if (token == null || token.isEmpty) {
        print("❌ Token IPinfo manquant !");
        return 'Centre';
      }
      
      print("📍 Appel API IPinfo...");
      final response = await http.get(
        Uri.parse('https://ipinfo.io/json?token=$token'),
      ).timeout(const Duration(seconds: 10));
      
      print("📥 Statut: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String city = data['city'] ?? '';
        String region = data['region'] ?? '';
        print("📍 Ville: $city, Région: $region");
        
        String zone = determineZone(city, region);
        print("📍 Zone déterminée: $zone");
        return zone;
      }
    } catch (e) {
      print("❌ Erreur API: $e");
    }
    return 'Centre';
  }
  
  static String determineZone(String city, String region) {
    String text = (city + ' ' + region).toLowerCase();
    
    if (text.contains('dakar') || text.contains('thiès')) return 'Littoral';
    if (text.contains('saint-louis') || text.contains('louga')) return 'Nord';
    if (text.contains('kaolack') || text.contains('diourbel')) return 'Centre';
    if (text.contains('ziguinchor') || text.contains('kolda')) return 'Sud';
    return 'Centre';
  }
  
  // ✅ MÉTHODE askUserZone AJOUTÉE
  static Future<String> askUserZone(BuildContext context) async {
    String? selectedZone = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("📍 Votre zone agricole"),
          content: const Text(
            "La détection automatique n'a pas fonctionné.\n\nVeuillez choisir votre zone :",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'Nord'),
              child: const Text("🌾 NORD"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'Centre'),
              child: const Text("🌽 CENTRE"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'Sud'),
              child: const Text("🍚 SUD"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'Littoral'),
              child: const Text("🌊 LITTORAL"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'Vallée'),
              child: const Text("🏞️ VALLÉE"),
            ),
          ],
        );
      },
    );
    
    return selectedZone ?? 'Centre';
  }
}