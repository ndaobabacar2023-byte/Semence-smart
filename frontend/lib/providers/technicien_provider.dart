// lib/providers/technicien_provider.dart
// ✅ VERSION CORRIGÉE AVEC refreshAll()

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TechnicienProvider extends ChangeNotifier {
  List<dynamic> _analyses = [];
  List<dynamic> _varietes = [];
  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  String _currentFilter = 'pending';

  // =========================
  // GETTERS
  // =========================
  List<dynamic> get analyses => _analyses;
  List<dynamic> get varietes => _varietes;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get stats => _stats;
  String get currentFilter => _currentFilter;

  // =========================
  // ANALYSES FILTRÉES
  // =========================
  List<dynamic> get filteredAnalyses {
    if (_currentFilter == 'all') return _analyses;

    return _analyses.where((analyse) {
      final statut = analyse['statut'] ?? 'pending';
      return statut == _currentFilter;
    }).toList();
  }

  // =========================
  // CHARGER ANALYSES
  // =========================
  Future<void> loadAnalyses({String? status}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.getTechnicienAnalyses(
        status: status,
      );

      if (response['success'] == true) {
        _analyses = response['data'] ?? [];
        _stats = response['stats'];
      }
    } catch (e) {
      debugPrint("Erreur loadAnalyses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // CHARGER VARIÉTÉS
  // =========================
  Future<void> loadVarietes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.getVarietes();

      if (response['success'] == true) {
        _varietes = response['data'] ?? [];
      }
    } catch (e) {
      debugPrint("Erreur loadVarietes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // ✅ AJOUT IMPORTANT
  // RAFRAÎCHIR TOUT
  // =========================
  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        loadAnalyses(
          status: _currentFilter == 'all' ? null : _currentFilter,
        ),
        loadVarietes(),
      ]);
    } catch (e) {
      debugPrint("Erreur refreshAll: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // VALIDER ANALYSE
  // =========================
  Future<bool> validateAnalyse(String analyseId) async {
    try {
      final response = await ApiService.validateAnalyse(analyseId);

      if (response['success'] == true) {
        await refreshAll();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Erreur validateAnalyse: $e");
      return false;
    }
  }

  // =========================
  // CORRIGER ANALYSE
  // =========================
  Future<bool> correctAnalyse({
    required String analyseId,
    required String comment,
    required List<String> recommandations,
    String? variete,
  }) async {
    try {
      final response = await ApiService.correctAnalyse(
        analyseId,
        comment: comment,
        recommandations: recommandations,
        variete: variete,
      );

      if (response['success'] == true) {
        await refreshAll();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Erreur correctAnalyse: $e");
      return false;
    }
  }

  // =========================
  // AJOUTER VARIÉTÉ
  // =========================
  Future<bool> addVariete(Map<String, dynamic> varieteData) async {
    try {
      final response = await ApiService.addVariete(varieteData);

      if (response['success'] == true) {
        await loadVarietes();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Erreur addVariete: $e");
      return false;
    }
  }

  // =========================
  // SUPPRIMER VARIÉTÉ
  // =========================
  Future<bool> deleteVariete(String id) async {
    try {
      final response = await ApiService.deleteVariete(id);

      if (response['success'] == true) {
        await loadVarietes();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Erreur deleteVariete: $e");
      return false;
    }
  }

  // =========================
  // FILTRE
  // =========================
  void setFilter(String filter) {
    _currentFilter = filter;

    loadAnalyses(
      status: filter == 'all' ? null : filter,
    );

    notifyListeners();
  }
}