import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.183.190:3000/api";

  // ===== REGISTER =====
  static Future<Map<String, dynamic>> register(
      String nom, String prenom, String email, String motDePasse) async {
    try {
      var res = await http
          .post(
            Uri.parse("$baseUrl/auth/register"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "nom": nom,
              "prenom": prenom,
              "email": email,
              "motDePasse": motDePasse
            }),
          )
          .timeout(Duration(seconds: 10));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body);
      } else {
        return {
          "error": "Erreur serveur (${res.statusCode})",
          "body": res.body
        };
      }
    } catch (e) {
      return {"error": "Erreur réseau ou serveur: $e"};
    }
  }

  // ===== LOGIN =====
  static Future<Map<String, dynamic>> login(String email, String motDePasse) async {
    try {
      var res = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "motDePasse": motDePasse,
        }),
      ).timeout(Duration(seconds: 10));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);

        // ✅ Sauvegarde du token
        if (data['token'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
        }

        return data;
      } else {
        return {
          "error": "Erreur serveur (${res.statusCode})",
          "body": res.body
        };
      }
    } catch (e) {
      return {"error": "Erreur réseau ou serveur: $e"};
    }
  }

  // ===== Récupérer le token =====
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ===== LOGOUT =====
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ===== ANALYSE CONDITIONS =====
  static Future<Map<String, dynamic>> analyseConditions(
      Map<String, dynamic> body) async {
    try {
      String? token = await getToken();
      if (token == null) return {"error": "Utilisateur non authentifié"};

      var res = await http
          .post(
            Uri.parse("$baseUrl/analyse"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token"
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: 10));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body);
      } else {
        return {
          "error": "Erreur serveur (${res.statusCode})",
          "body": res.body
        };
      }
    } catch (e) {
      return {"error": "Erreur réseau ou serveur: $e"};
    }
  }
}
