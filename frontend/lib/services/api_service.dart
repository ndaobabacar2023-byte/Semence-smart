import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.122.190:3000/api/advisor";

// ===== ANALYSE CONDITIONS =====
static Future<Map<String, dynamic>> analyseConditions({
  required String culture,
  required String typeCulture,
  required double temperature,
  required double humidite,
  required String sol,
  required String zone,
  required String saison,
  required double eau,
}) async {
  try {
    final token = await getToken();
    
    if (token == null) {
      return {
        "success": false,
        "message": "Non authentifié. Veuillez vous reconnecter."
      };
    }
    
    final body = {
      "culture": culture,
      "typeCulture": typeCulture,
      "temperature": temperature,
      "humidite": humidite,
      "sol": sol,
      "zone": zone,
      "saison": saison,
      "eau": eau,
    };
    
    print("📤 Envoi analyse: ${jsonEncode(body)}");
    
    final res = await http.post(
       Uri.parse("$baseUrl/analyse"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 30));
    
    print("📥 Réponse analyse - Status: ${res.statusCode}");
    print("📥 Body: ${res.body}");
    
    if (res.statusCode == 200) {
      try {
        final data = jsonDecode(res.body);
        
        if (data['success'] == true) {
          return {
            "success": true,
            "data": data,
          };
        } else {
          return {
            "success": false,
            "message": data['message'] ?? "Erreur inconnue",
            "statusCode": res.statusCode,
          };
        }
      } catch (e) {
        print("❌ Erreur parsing JSON: $e");
        return {
          "success": false,
          "message": "Erreur format réponse",
          "rawBody": res.body,
        };
      }
    } else if (res.statusCode == 401) {
      return {
        "success": false,
        "message": "Session expirée. Veuillez vous reconnecter.",
        "statusCode": res.statusCode,
      };
    } else {
      try {
        final errorData = jsonDecode(res.body);
        return {
          "success": false,
          "message": errorData['message'] ?? "Erreur serveur (${res.statusCode})",
          "statusCode": res.statusCode,
        };
      } catch (_) {
        return {
          "success": false,
          "message": "Erreur serveur (${res.statusCode})",
          "rawBody": res.body,
        };
      }
    }
  } catch (e) {
    print("❌ Erreur analyse: $e");
    return {
      "success": false,
      "message": "Erreur réseau: ${e.toString()}",
    };
  }
}
  
  // ===== TEST DE CONNEXION API =====
  static Future<Map<String, dynamic>> testApi() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/test"),
        headers: {"Accept": "application/json"},
      ).timeout(const Duration(seconds: 5));
      
      print("🧪 Test API - Status: ${res.statusCode}");
      
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return {"error": "API non accessible: ${res.statusCode}"};
      }
    } catch (e) {
      return {"error": "API non accessible: $e"};
    }
  }
  
  // ===== GET TOKEN =====
  static Future<String?> getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print("❌ Erreur getToken: $e");
      return null;
    }
  }
  
  // ===== GET ROLE =====
  static Future<String?> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
  
  // ===== LOGOUT =====
  static Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('role');
      print("✅ Déconnexion effectuée");
    } catch (e) {
      print("❌ Erreur logout: $e");
    }
  }
  
  // ===== REGISTER =====
  static Future<Map<String, dynamic>> register(
    String nom,
    String prenom,
    String email,
    String motDePasse,
    String telephone,
    String role
  ) async {
    try {
      print("📤 Envoi inscription...");
      
      var res = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          "nom": nom,
          "prenom": prenom,
          "email": email,
          "motDePasse": motDePasse,
          "telephone": telephone,
          "role": role
        }),
      ).timeout(const Duration(seconds: 15));
      
      print("📥 Réponse inscription - Status: ${res.statusCode}");
      
      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body);
        
        if (data['token'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setString('role', data['user']['role']);
          print("✅ Token sauvegardé après inscription");
        }
        
        return data;
      } else {
        try {
          final errorData = jsonDecode(res.body);
          return {
            "error": errorData['message'] ?? "Erreur ${res.statusCode}",
            "statusCode": res.statusCode
          };
        } catch (_) {
          return {
            "error": "Erreur serveur (${res.statusCode})",
            "statusCode": res.statusCode
          };
        }
      }
    } catch (e) {
      return {
        "error": "Erreur réseau: ${e.toString()}",
        "details": e.toString()
      };
    }
  }
  
  // ===== LOGIN =====
  static Future<Map<String, dynamic>> login(String email, String motDePasse) async {
    try {
      print("📤 Envoi connexion...");
      
      var res = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          "email": email,
          "motDePasse": motDePasse,
        }),
      ).timeout(const Duration(seconds: 15));
      
      print("📥 Réponse connexion - Status: ${res.statusCode}");
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        
        if (data['token'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setString('role', data['user']['role']);
          print("✅ Token sauvegardé: ${data['token'].substring(0, 20)}...");
        }
        
        return data;
      } else {
        try {
          final errorData = jsonDecode(res.body);
          return {
            "error": errorData['message'] ?? "Erreur ${res.statusCode}",
            "statusCode": res.statusCode
          };
        } catch (_) {
          return {
            "error": "Erreur serveur (${res.statusCode})",
            "statusCode": res.statusCode,
            "body": res.body
          };
        }
      }
    } catch (e) {
      return {
        "error": "Erreur réseau: ${e.toString()}",
        "details": e.toString()
      };
    }
  }
}