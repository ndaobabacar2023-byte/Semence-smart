// lib/models/variete_model.dart
class VarieteModel {
  final String id;
  final String nom;
  final String culture;
  final String description;
  final String typeCulture;
  final List<String> zoneRecommandee;
  final String periodeSemis;
  final int cycleJours;
  final double rendementTonnesHa;
  final double prixSemence;
  final DateTime createdAt;

  VarieteModel({
    required this.id,
    required this.nom,
    required this.culture,
    required this.description,
    required this.typeCulture,
    required this.zoneRecommandee,
    required this.periodeSemis,
    required this.cycleJours,
    required this.rendementTonnesHa,
    required this.prixSemence,
    required this.createdAt,
  });

  // Constructeur vide pour création
  VarieteModel.empty({
    required this.nom,
    required this.culture,
    this.description = '',
    this.typeCulture = 'both',
    this.zoneRecommandee = const [],
    this.periodeSemis = '',
    this.cycleJours = 0,
    this.rendementTonnesHa = 0.0,
    this.prixSemence = 0.0,
  }) : id = '', createdAt = DateTime.now();

  factory VarieteModel.fromJson(Map<String, dynamic> json) {
    return VarieteModel(
      id: json['_id'] ?? json['id'] ?? '',
      nom: json['nom'] ?? '',
      culture: json['culture'] ?? '',
      description: json['description'] ?? '',
      typeCulture: json['typeCulture'] ?? 'both',
      zoneRecommandee: List<String>.from(json['zoneRecommandee'] ?? []),
      periodeSemis: json['periodeSemis'] ?? '',
      cycleJours: json['cycleJours'] ?? 0,
      rendementTonnesHa: (json['rendementTonnesHa'] ?? 0).toDouble(),
      prixSemence: (json['prixSemence'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'culture': culture,
      'description': description,
      'typeCulture': typeCulture,
      'zoneRecommandee': zoneRecommandee,
      'periodeSemis': periodeSemis,
      'cycleJours': cycleJours,
      'rendementTonnesHa': rendementTonnesHa,
      'prixSemence': prixSemence,
    };
  }
}