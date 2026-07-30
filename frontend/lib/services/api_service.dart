import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  //static const String baseUrl ="https://semence-smart-backend.onrender.com/api";
  static const String baseUrl =
      "https://semence-smart-backend-qkjf.onrender.com/api";
  static const String aiUrl = "http://localhost:8000";

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
  String? agriculteurId,
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
      "topVarietes": 3,
      if (agriculteurId != null) "agriculteurId": agriculteurId,
    };
    
    print("📤 Envoi analyse: ${jsonEncode(body)}");
    
    final res = await http.post(
       Uri.parse("$baseUrl/advisor/analyse"),
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
  
static Future<Map<String, dynamic>> validerTechnicien(String id) async {
  final token = await getToken();

  print("Validation technicien : $id");

  final response = await http.put(
    Uri.parse("$baseUrl/users/techniciens/$id/valider"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  print("Status : ${response.statusCode}");
  print("Body : ${response.body}");

  return jsonDecode(response.body);
}


static Future<List> getTechniciensAttente() async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse("$baseUrl/techniciens/attente"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return jsonDecode(response.body);
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
          await prefs.setString('userId', data['user']['id']);
          await prefs.setString('nom', data['user']['nom'] ?? '');
          await prefs.setString('prenom', data['user']['prenom'] ?? '');
          await prefs.setString('email', data['user']['email'] ?? '');
          await prefs.setString('telephone', data['user']['telephone'] ?? '');
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


  // ── 1. Récupérer les cultures disponibles (depuis la BDD) ─────────────────────
static Future<Map<String, dynamic>> getCultures({String? type}) async {
  try {
    final token = await getToken();
    if (token == null) {
      return {"success": false, "message": "Non authentifié"};
    }
 
    String url = "$baseUrl/cultures";
    if (type != null && type.isNotEmpty) {
      url += "?type=$type";
    }
 
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: 15));
 
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Accepte { success: true, data: [...] }  OU  directement [...]
      if (data is List) {
        return {"success": true, "data": data};
      } else if (data['success'] == true) {
        return {"success": true, "data": data['data'] ?? data['cultures'] ?? []};
      } else {
        return {"success": false, "message": data['message'] ?? "Erreur"};
      }
    } else {
      return {"success": false, "message": "Erreur ${response.statusCode}"};
    }
  } catch (e) {
    return {"success": false, "message": "Erreur réseau: $e"};
  }
}



  static Future<Map<String, dynamic>> getNotifications() async {
  try {
    final token = await getToken();

    if (token == null) {
      return {
        "success": false,
        "message": "Utilisateur non connecté"
      };
    }

    final response = await http.get(
      Uri.parse("$baseUrl/notifications"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {
      "success": false,
      "message": "Erreur ${response.statusCode}"
    };
  } catch (e) {
    return {
      "success": false,
      "message": e.toString()
    };
  }
}


static Future<void> marquerNotificationLue(String id) async {

  final token = await getToken();

  print("PUT : $baseUrl/notifications/$id/read");

  final response = await http.put(
    Uri.parse("$baseUrl/notifications/$id/read"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  print("Status : ${response.statusCode}");
  print("Body : ${response.body}");
}

static Future<void> saveFcmToken(
String token
) async {

    final jwt = await getToken();

    await http.post(

        Uri.parse(
            "$baseUrl/notifications/register-token"
        ),

        headers:{

            "Content-Type":"application/json",

            "Authorization":"Bearer $jwt"

        },

        body:jsonEncode({

            "fcmToken":token

        })

    );

}

  // Récupérer toutes les analyses (technicien)
  static Future<Map<String, dynamic>> getTechnicienAnalyses({String? status}) async {
  final token = await getToken();

  String url = "$baseUrl/technicien/analyses";

  if (status!= null && status != 'all') {
    url += '?status=$status'; // OK backend accepte status
  }

  final response = await http.get(
    Uri.parse(url),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  return jsonDecode(response.body);
}


static Future<List> getUsers() async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse("$baseUrl/users"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  return jsonDecode(response.body);
}

static Future deleteUser(String id) async {
  final token = await getToken();

  final response = await http.delete(
    Uri.parse('$baseUrl/api/users/$id'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  return jsonDecode(response.body);
}
  
  // Récupérer une analyse par ID
  static Future<Map<String, dynamic>> getAnalyseById(String id) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "message": "Non authentifié"};
      }
      
      final response = await http.get(
        Uri.parse("$baseUrl/technicien/analyses/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Erreur ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur: $e"};
    }
  }
  
  // Valider une analyse
  static Future<Map<String, dynamic>> validateAnalyse(String id) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "message": "Non authentifié"};
      }
      
      final response = await http.put(
        Uri.parse("$baseUrl/technicien/analyses/$id/validate"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Erreur ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur: $e"};
    }
  }

  // ===============================
// Sauvegarder le token Firebase
// ===============================
  
  // Corriger une analyse
  static Future<Map<String, dynamic>> correctAnalyse(
    String id, {
    required String comment,
    required List<String> recommandations,
    String? variete,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "message": "Non authentifié"};
      }
      
      final response = await http.put(
        Uri.parse("$baseUrl/technicien/analyses/$id/correct"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "comment": comment,
          "recommandations": recommandations,
          "variete": variete,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Erreur ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur: $e"};
    }
  }
  
  // Récupérer les statistiques technicien
  static Future<Map<String, dynamic>> getTechnicienStats() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "message": "Non authentifié"};
      }
      
      final response = await http.get(
        Uri.parse("$baseUrl/technicien/stats"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Erreur ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur: $e"};
    }
  }
  
  // Récupérer toutes les variétés
  static Future<Map<String, dynamic>> getVarietes({String? culture, String? zone}) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "message": "Non authentifié"};
      }
      
      String url = "$baseUrl/technicien/varietes";
      final params = [];
      if (culture != null) params.add("culture=$culture");
      if (zone != null) params.add("zone=$zone");
      if (params.isNotEmpty) url += "?${params.join("&")}";
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Erreur ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur: $e"};
    }
  }
  
  // Ajouter une variété
  static Future<Map<String, dynamic>> addVariete(Map<String, dynamic> variete) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "message": "Non authentifié"};
      }
      
      final response = await http.post(
        Uri.parse("$baseUrl/technicien/varietes"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(variete),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Erreur ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur: $e"};
    }
  }
  
  // Supprimer une variété
  static Future<Map<String, dynamic>> deleteVariete(String id) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"success": false, "message": "Non authentifié"};
      }
      
      final response = await http.delete(
        Uri.parse("$baseUrl/technicien/varietes/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Erreur ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": "Erreur: $e"};
    }
  }
  static Future<Map<String, dynamic>> getRecommendations({
  required String culture,
  required String modeCulture,
  required String typeCulture,
  required double temperature,
  required double humidite,
  required String typeSol,
  required String saison,
}) async {
  try {
    final response = await http.post(
      Uri.parse("$aiUrl/recommend"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "culture": culture,
        "mode_culture": modeCulture,
        "type_culture": typeCulture,
        "temperature": temperature,
        "humidite": humidite,
        "type_sol": typeSol,
        "saison": saison,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {
      "success": false,
      "message": "Erreur serveur"
    };
  } catch (e) {
    return {
      "success": false,
      "message": e.toString()
    };
  }
}
}
