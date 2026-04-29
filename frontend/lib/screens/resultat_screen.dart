import 'package:flutter/material.dart';
import '../services/historique_service.dart';  // ← AJOUTER CET IMPORT

class ResultatScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const ResultatScreen({required this.result, Key? key}) : super(key: key);

  @override
  State<ResultatScreen> createState() => _ResultatScreenState();
}

class _ResultatScreenState extends State<ResultatScreen> {
  bool _showSousScores = false;
  bool _isSaved = false;  // ← AJOUTER CETTE VARIABLE

  @override
  void initState() {
    super.initState();
    _checkIfSaved();  // ← VÉRIFIER SI DÉJÀ SAUVEGARDÉ
  }

  // Vérifier si l'analyse est déjà sauvegardée
  Future<void> _checkIfSaved() async {
    final analyses = await HistoriqueService.getAllAnalyses();
    final currentId = widget.result['id'];
    
    if (currentId != null) {
      final exists = analyses.any((a) => a['id'] == currentId);
      setState(() {
        _isSaved = exists;
      });
    }
  }

  // Sauvegarder l'analyse
  Future<void> _saveAnalyse() async {
    // Ajouter la date si non présente
    Map<String, dynamic> analyseToSave = Map.from(widget.result);
    if (!analyseToSave.containsKey('date')) {
      analyseToSave['date'] = DateTime.now().toIso8601String();
    }
    
    await HistoriqueService.saveAnalyse(analyseToSave);
    
    setState(() {
      _isSaved = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Analyse sauvegardée avec succès !'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Colorer le statut
  Color getColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'bon':
        return Colors.lightGreen;
      case 'moyen':
        return Colors.orange;
      case 'défavorable':
        return Colors.orange[800]!;
      case 'critique':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return Icons.emoji_emotions;
      case 'bon':
        return Icons.thumb_up;
      case 'moyen':
        return Icons.warning;
      case 'défavorable':
        return Icons.warning_amber;
      case 'critique':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return "Conditions optimales";
      case 'bon':
        return "Bonnes conditions";
      case 'moyen':
        return "Conditions acceptables";
      case 'défavorable':
        return "Conditions défavorables";
      case 'critique':
        return "Conditions critiques";
      default:
        return status;
    }
  }

  Widget _buildScoreIndicator(int score) {
    return SizedBox(
      width: double.infinity,
      height: 20,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FractionallySizedBox(
            widthFactor: score / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    score < 50 ? Colors.red : Colors.orange,
                    score >= 80 ? Colors.green : Colors.lightGreen,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            left: '${score}%'.length * 3.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                '$score%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSousScoreItem(String label, int score, String detail) {
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.green;
    } else if (score >= 60) {
      scoreColor = Colors.lightGreen;
    } else if (score >= 40) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        backgroundColor: scoreColor.withOpacity(0.2),
        child: Text(
          '$score',
          style: TextStyle(
            color: scoreColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        detail,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: _buildScoreIndicator(score),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final success = result['success'] ?? true;
    
    if (!success) {
      return Scaffold(
        backgroundColor: Colors.green[50],
        appBar: AppBar(
          title: const Text(
            "Erreur d'analyse",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red[700],
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                const SizedBox(height: 20),
                Text(
                  result['message'] ?? "Erreur lors de l'analyse",
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final culture = result['culture'] ?? 'Culture';
    final typeCulture = result['typeCulture'] ?? 'Type';
    final status = result['status'] ?? 'inconnu';
    final score = result['score'] ?? 0;
    final message = result['message'] ?? '';
    final emoji = result['emoji'] ?? '';
    final variete = result['variete'];
    final fournisseurs = result['fournisseurs'] as List<dynamic>? ?? [];
    final recommandations = result['recommandations'] as List<dynamic>? ?? [];
    final sousScores = result['sousScores'] as Map<String, dynamic>?;
    final metadata = result['metadata'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text(
          "Résultats d'analyse",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // ← BOUTON DE SAUVEGARDE AJOUTÉ
          IconButton(
            icon: Icon(
              _isSaved ? Icons.check_circle : Icons.save,
              color: Colors.white,
            ),
            onPressed: _isSaved ? null : _saveAnalyse,
            tooltip: _isSaved ? 'Déjà sauvegardé' : 'Sauvegarder l\'analyse',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Résultat de l'analyse",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Analyse des conditions pour $culture",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Indicateur de sauvegarde
                          if (_isSaved)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sauvegardé',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Carte culture
                      _buildCard(
                        "Culture analysée",
                        "$culture ($typeCulture)",
                        Icons.agriculture,
                        Colors.green[700]!,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Carte statut
                      _buildStatusCard(status, score, message, emoji),
                      
                      const SizedBox(height: 16),
                      
                      // Bouton pour afficher les sous-scores
                      if (sousScores != null && sousScores.isNotEmpty)
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.green[100]!, width: 1),
                          ),
                          child: ExpansionTile(
                            leading: Icon(
                              _showSousScores ? Icons.expand_less : Icons.expand_more,
                              color: Colors.green[700],
                            ),
                            title: Text(
                              "Détails des critères",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[800],
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Column(
                                  children: [
                                    if (sousScores['temperature'] != null)
                                      _buildSousScoreItem(
                                        "🌡️ Température",
                                        sousScores['temperature']['score'] ?? 0,
                                        "Optimal: ${sousScores['temperature']['optimal'] ?? 'Non spécifié'}",
                                      ),
                                    if (sousScores['humidite'] != null)
                                      _buildSousScoreItem(
                                        "💧 Humidité",
                                        sousScores['humidite']['score'] ?? 0,
                                        "Optimal: ${sousScores['humidite']['optimal'] ?? 'Non spécifié'}",
                                      ),
                                    if (sousScores['sol'] != null)
                                      _buildSousScoreItem(
                                        "🌍 Type de sol",
                                        sousScores['sol']['score'] ?? 0,
                                        "Sol optimal: ${sousScores['sol']['optimal'] ?? 'Non spécifié'}",
                                      ),
                                    if (sousScores['eau'] != null)
                                      _buildSousScoreItem(
                                        "💦 Irrigation",
                                        sousScores['eau']['score'] ?? 0,
                                        "Besoin: ${sousScores['eau']['besoin'] ?? 'moyen'}",
                                      ),
                                    if (sousScores['saison'] != null)
                                      _buildSousScoreItem(
                                        "📅 Saison",
                                        sousScores['saison']['score'] ?? 0,
                                        "Saison optimale: ${sousScores['saison']['optimale'] ?? 'Non spécifiée'}",
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Variété recommandée
                      if (variete != null && variete['nom'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: _buildVarieteCard(variete),
                        ),
                      
                      // Recommandations
                      if (recommandations.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: _buildRecommandationsCard(recommandations),
                        ),
                      
                      // Fournisseurs
                      if (fournisseurs.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: _buildFournisseursCard(fournisseurs),
                        ),
                      
                      // Métadonnées
                      if (metadata != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.green[100]!, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.green[500], size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Zone: ${metadata['zone'] ?? 'Non spécifiée'}",
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                        Text(
                                          "Saison: ${metadata['saison'] ?? 'Non spécifiée'}",
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _formatDate(metadata['dateAnalyse']),
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Boutons d'action
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh, size: 22, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  "Nouvelle analyse",
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.popUntil(context, (route) => route.isFirst);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.green[700]!),
                            ),
                            child: Text(
                              "Retour à l'accueil",
                              style: TextStyle(fontSize: 16, color: Colors.green[700]),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green[100]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[500]!,
                    Colors.green[700]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status, int score, String message, String emoji) {
    final statusColor = getColor(status);
    final statusText = getStatusText(status);
    final statusIcon = getStatusIcon(status);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green[100]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Résultat d'analyse",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (emoji.isNotEmpty) Text(emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              message,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Score global",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "$score",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "/100",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                    Text(
                      "$score%",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVarieteCard(Map<String, dynamic> variete) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green[100]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green[500]!,
                        Colors.green[700]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_florist, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  "Variété recommandée",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variete['nom'] ?? 'Non spécifié',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  if (variete['description'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      variete['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (variete['resistance_secheresse'] == true)
                  Chip(
                    label: const Text("Résistante à la sécheresse"),
                    backgroundColor: Colors.blue[50],
                    avatar: Icon(Icons.water_drop, color: Colors.blue, size: 18),
                  ),
                if (variete['score_variete'] != null)
                  Chip(
                    label: Text("Pertinence: ${variete['score_variete']}%"),
                    backgroundColor: Colors.amber[50],
                    avatar: Icon(Icons.star, color: Colors.amber, size: 18),
                  ),
                if (variete['cycle_vegetatif'] != null)
                  Chip(
                    label: Text("Cycle: ${variete['cycle_vegetatif']}"),
                    backgroundColor: Colors.green[50],
                    avatar: Icon(Icons.calendar_today, color: Colors.green, size: 18),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommandationsCard(List<dynamic> recommandations) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green[100]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green[500]!,
                        Colors.green[700]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lightbulb, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  "Recommandations",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommandations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommandation = entry.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommandation,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFournisseursCard(List<dynamic> fournisseurs) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green[100]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green[500]!,
                        Colors.green[700]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.store, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  "Fournisseurs recommandés",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...fournisseurs.map((f) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.green[100]!, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Text(
                                (f['nom']?[0] ?? 'F').toUpperCase(),
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f['nom'] ?? 'Nom inconnu',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  if (f['specialite'] != null)
                                    Text(
                                      f['specialite'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (f['note'] != null)
                              Chip(
                                label: Text(f['note'].toString()),
                                backgroundColor: Colors.amber[50],
                                avatar: const Icon(Icons.star, size: 14),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (f['adresse'] != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    f['adresse'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (f['telephone'] != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 48, top: 8),
                            child: Row(
                              children: [
                                Icon(Icons.phone, size: 16, color: Colors.grey[500]),
                                const SizedBox(width: 6),
                                Text(
                                  f['telephone'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Appeler"),
                                ),
                              ],
                            ),
                          ),
                        if (f['cultures'] != null && (f['cultures'] as List).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 48, top: 8),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: (f['cultures'] as List)
                                  .take(3)
                                  .map((culture) => Chip(
                                        label: Text(
                                          culture,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        backgroundColor: Colors.green[50],
                                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                      ))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}