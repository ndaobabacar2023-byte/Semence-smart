// lib/models/analyse_model.dart
import 'package:flutter/material.dart';

class AnalyseModel {
  final String id;
  final String userId;
  final String userName;
  final String culture;
  final String typeCulture;
  final double temperature;
  final double humidite;
  final double eau;
  final String sol;
  final String zone;
  final String saison;
  final int score;

  final String statut; // ✅ UNIFIÉ (pending, validated, corrected, rejected)

  final List<String> recommandations;
  final String? variete;
  final DateTime createdAt;

  final Map<String, dynamic>? correction;
  final Map<String, dynamic>? validation;

  AnalyseModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.culture,
    required this.typeCulture,
    required this.temperature,
    required this.humidite,
    required this.eau,
    required this.sol,
    required this.zone,
    required this.saison,
    required this.score,
    required this.statut,
    required this.recommandations,
    this.variete,
    required this.createdAt,
    this.correction,
    this.validation,
  });

  factory AnalyseModel.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] is Map ? json['userId'] : null;

    return AnalyseModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: user != null
          ? user['_id'] ?? user['id']
          : json['userId']?.toString() ?? '',
      userName: user != null
          ? '${user['prenom'] ?? ''} ${user['nom'] ?? ''}'.trim()
          : json['userName'] ?? 'Agriculteur',
      culture: json['culture'] ?? '',
      typeCulture: json['typeCulture'] ?? '',
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidite: (json['humidite'] ?? 0).toDouble(),
      eau: (json['eau'] ?? 0).toDouble(),
      sol: json['sol'] ?? '',
      zone: json['zone'] ?? '',
      saison: json['saison'] ?? '',
      score: json['score'] ?? 0,

      statut: json['statut'] ?? json['statusAnalyse'] ?? 'pending',

      recommandations: List<String>.from(json['recommandations'] ?? []),
      variete: json['variete'],
      createdAt: DateTime.tryParse(
            json['createdAt'] ??
                json['dateAnalyse'] ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),

      correction: json['correction'],
      validation: json['validation'],
    );
  }

  // ✅ STATUS HELPERS
  bool get isPending => statut == 'pending';
  bool get isValidated => statut == 'validated';
  bool get isCorrected => statut == 'corrected';

  String get statutLabel {
    switch (statut) {
      case 'pending':
        return 'En attente';
      case 'validated':
        return 'Validée';
      case 'corrected':
        return 'Corrigée';
      case 'rejected':
        return 'Rejetée';
      default:
        return 'En attente';
    }
  }

  Color get statutColor {
    switch (statut) {
      case 'pending':
        return Colors.orange;
      case 'validated':
        return Colors.green;
      case 'corrected':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}