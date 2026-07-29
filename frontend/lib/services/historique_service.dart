import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoriqueService {
  static const String _historiqueKey = 'analyses_historique';
  
  // Sauvegarder une analyse
  static Future<void> saveAnalyse(Map<String, dynamic> analyse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historique = prefs.getStringList(_historiqueKey) ?? [];
      
      // Ajouter la date si non présente
      if (!analyse.containsKey('date')) {
        analyse['date'] = DateTime.now().toIso8601String();
      }
      
      // Ajouter un ID unique
      analyse['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Ajouter au début de la liste (plus récent en premier)
      historique.insert(0, jsonEncode(analyse));
      
      // Pas de limite : l'historique persiste jusqu'à suppression
      // volontaire par l'agriculteur (deleteAnalyse ou clearAllAnalyses)
      
      await prefs.setStringList(_historiqueKey, historique);
    } catch (e) {
      print('Erreur sauvegarde analyse: $e');
    }
  }
  
  // Récupérer toutes les analyses
  static Future<List<Map<String, dynamic>>> getAllAnalyses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historique = prefs.getStringList(_historiqueKey) ?? [];
      
      return historique.map((item) {
        return jsonDecode(item) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Erreur lecture historique: $e');
      return [];
    }
  }
  
  // Supprimer une analyse par ID
  static Future<void> deleteAnalyse(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historique = prefs.getStringList(_historiqueKey) ?? [];
      
      historique.removeWhere((item) {
        Map<String, dynamic> analyse = jsonDecode(item);
        return analyse['id'] == id;
      });
      
      await prefs.setStringList(_historiqueKey, historique);
    } catch (e) {
      print('Erreur suppression analyse: $e');
    }
  }
  
  // Supprimer toutes les analyses
  static Future<void> clearAllAnalyses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historiqueKey);
    } catch (e) {
      print('Erreur suppression historique: $e');
    }
  }
  
  // Formater la date pour affichage
  static String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
  
  // Obtenir la couleur du score
  static Color getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
  
  // Obtenir le libellé du statut
  static String getStatusText(int score) {
    if (score >= 80) return "Excellent";
    if (score >= 60) return "Bon";
    if (score >= 40) return "Moyen";
    return "Défavorable";
  }
  
  // Obtenir l'icône du statut
  static IconData getStatusIcon(int score) {
    if (score >= 80) return Icons.emoji_emotions;
    if (score >= 60) return Icons.thumb_up;
    if (score >= 40) return Icons.warning;
    return Icons.error;
  }
}