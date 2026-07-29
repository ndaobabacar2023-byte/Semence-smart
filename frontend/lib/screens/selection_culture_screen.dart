// lib/screens/selection_culture_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'formulaire_screen.dart';

class SelectionCultureScreen extends StatefulWidget {
  final String type;
  final String? agriculteurId;

  const SelectionCultureScreen({
    required this.type,
    this.agriculteurId,
    super.key,
  });
  @override
  State<SelectionCultureScreen> createState() => _SelectionCultureScreenState();
}

class _SelectionCultureScreenState extends State<SelectionCultureScreen> {
  List<Map<String, dynamic>> _cultures = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();

  // Mapping emoji par nom (fallback si la BDD n'a pas de champ emoji)
  static const Map<String, String> _emojiMap = {
    'tomate': '🍅',
    'poivron': '🫑',
    'piment': '🌶️',
    'laitue': '🥬',
    'mil': '🌾',
    'arachide': '🥜',
    'oignon': '🧅',
    'aubergine': '🍆',
    'pastèque': '🍉',
    'épinard': '🥬',
    'courgette': '🥒',
    'betterave': '🥕',
    'carotte': '🥕',
    'concombre': '🥒',
    'haricot': '🫘',
    'chou': '🥦',
    'maïs': '🌽',
    'ail': '🧄',
    'pomme de terre': '🥔',
    'citron': '🍋',
  };

  String _getEmoji(String nom) {
    final key = nom.trim().toLowerCase();
    return _emojiMap[key] ?? '🌱';
  }

  @override
  void initState() {
    super.initState();
    _loadCultures();
    _searchController.addListener(_filterCultures);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCultures() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final result = await ApiService.getCultures(type: widget.type);

      if (result['success'] == true) {
        final list = result['data'] as List<dynamic>? ?? [];
        setState(() {
          _cultures = list.map((e) => Map<String, dynamic>.from(e)).toList();
          _filtered = _cultures;
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Impossible de charger les cultures";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Erreur : $e";
        _loading = false;
      });
    }
  }

  void _filterCultures() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? _cultures
          : _cultures.where((c) {
              final nom = (c['nom'] ?? '').toString().toLowerCase();
              final nomLocal = (c['nom_local'] ?? '').toString().toLowerCase();
              return nom.contains(query) || nomLocal.contains(query);
            }).toList();
    });
  }

  void _selectCulture(Map<String, dynamic> culture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormulaireScreen(
          type: widget.type,
          culture: culture['nom'] ?? '',
          agriculteurId: widget.agriculteurId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text(
          "Choisir une culture",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Barre de recherche ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Rechercher une culture...",
                  prefixIcon: Icon(Icons.search, color: Colors.green[700]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // ── Contenu ──────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green[700]),
            const SizedBox(height: 16),
            Text(
              "Chargement des cultures...",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.orange[400]),
              const SizedBox(height: 16),
              Text(_error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCultures,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                child: const Text("Réessayer", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[350]),
            const SizedBox(height: 16),
            Text(
              _cultures.isEmpty
                  ? "Aucune culture disponible"
                  : "Aucun résultat pour cette recherche",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final culture = _filtered[index];
        return _buildCultureCard(culture);
      },
    );
  }

  Widget _buildCultureCard(Map<String, dynamic> culture) {
    final nom = (culture['nom'] ?? '').toString();
    final emoji = _getEmoji(nom);
    final difficulte = culture['difficulte']?.toString() ?? '';
    final besoinEau = culture['besoin_eau']?.toString() ?? '';
    final saison = culture['saison_optimale']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.green[100]!, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _selectCulture(culture),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.green[700]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nom.isNotEmpty
                                ? "${nom[0].toUpperCase()}${nom.substring(1)}"
                                : nom,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          if (saison.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              "Saison : $saison",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.arrow_forward_ios,
                          color: Colors.green[700], size: 14),
                    ),
                  ],
                ),
                if (difficulte.isNotEmpty || besoinEau.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (difficulte.isNotEmpty)
                        _buildTag(
                          Icons.speed,
                          "Difficulté : $difficulte",
                          _difficultyColor(difficulte),
                        ),
                      if (besoinEau.isNotEmpty)
                        _buildTag(
                          Icons.water_drop,
                          "Eau : $besoinEau",
                          Colors.blue,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _difficultyColor(String difficulte) {
    switch (difficulte.toLowerCase()) {
      case 'facile':
        return Colors.green;
      case 'moyen':
        return Colors.orange;
      case 'difficile':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}