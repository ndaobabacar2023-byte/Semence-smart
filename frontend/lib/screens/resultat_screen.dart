//voici l'ecran des resultat des analyse 
import 'package:flutter/material.dart';
import '../services/historique_service.dart';
import '../services/wolof_message_generator.dart';
import '../services/wolof_tts_service.dart';
import '../widgets/voice_button.dart';

class ResultatScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const ResultatScreen({required this.result, Key? key}) : super(key: key);

  @override
  State<ResultatScreen> createState() => _ResultatScreenState();
}

class _ResultatScreenState extends State<ResultatScreen> {
  bool _isSaved = false;

  final WolofTTSService _ttsService = WolofTTSService();
  String _wolofMessage = '';

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
    _generateWolofMessage();
    _autoPlayAudio();
  }

  void _generateWolofMessage() {
    _wolofMessage = WolofMessageGenerator.generateAnalysisMessage(
      culture: widget.result['culture'] ?? 'Culture',
      score: widget.result['score'] ?? 0,
      message: widget.result['message'] ?? '',
      recommandations: (widget.result['recommandations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      typeCulture: widget.result['typeCulture'],
    );
  }

  Future<void> _autoPlayAudio() async {
    await Future.delayed(const Duration(milliseconds: 800));
    await _ttsService.speak(_wolofMessage);
    if (mounted) setState(() {});
  }

  Future<void> _checkIfSaved() async {
    final analyses = await HistoriqueService.getAllAnalyses();
    final currentId = widget.result['id'];
    if (currentId != null) {
      final exists = analyses.any((a) => a['id'] == currentId);
      if (mounted) setState(() => _isSaved = exists);
    }
  }

  Future<void> _saveAnalyse() async {
    Map<String, dynamic> analyseToSave = Map.from(widget.result);
    if (!analyseToSave.containsKey('date')) {
      analyseToSave['date'] = DateTime.now().toIso8601String();
    }
    await HistoriqueService.saveAnalyse(analyseToSave);
    if (mounted) {
      setState(() => _isSaved = true);
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
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  // ── Helpers statut ──────────────────────────────────────────────────────────
  Color _getColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':    return Colors.green;
      case 'bon':          return Colors.lightGreen;
      case 'moyen':        return Colors.orange;
      case 'défavorable':  return Colors.orange[800]!;
      case 'critique':     return Colors.red;
      default:             return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':    return Icons.emoji_emotions;
      case 'bon':          return Icons.thumb_up;
      case 'moyen':        return Icons.warning;
      case 'défavorable':  return Icons.warning_amber;
      case 'critique':     return Icons.error;
      default:             return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':    return "Conditions optimales";
      case 'bon':          return "Bonnes conditions";
      case 'moyen':        return "Conditions acceptables";
      case 'défavorable':  return "Conditions défavorables";
      case 'critique':     return "Conditions critiques";
      default:             return status;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (_) {
      return dateString;
    }
  }

  // ── Résolution top variétés ─────────────────────────────────────────────────
  List<dynamic> _resolveTopVarietes(Map<String, dynamic> result) {
    final top = result['topVarietes'];
    if (top is List && top.isNotEmpty) return top;
    final single = result['variete'];
    if (single is Map && single['nom'] != null) return [single];
    return [];
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final success = result['success'] ?? true;

    if (!success) {
      return _buildErrorScreen(result['message'] ?? "Erreur lors de l'analyse");
    }

    final culture         = result['culture'] ?? 'Culture';
    final typeCulture     = result['typeCulture'] ?? 'Type';
    final status          = result['status'] ?? 'inconnu';
    final score           = result['score'] ?? 0;
    final message         = result['message'] ?? '';
    final emoji           = result['emoji'] ?? '';
    final recommandations = result['recommandations'] as List<dynamic>? ?? [];
    final sousScores      = result['sousScores'] as Map<String, dynamic>?;
    final metadata        = result['metadata'] as Map<String, dynamic>?;
    final topVarietes     = _resolveTopVarietes(result);

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text(
          "Résultats d'analyse",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          VoiceButton(textToSpeak: _wolofMessage, size: 40),
          IconButton(
            icon: Icon(
              _isSaved ? Icons.check_circle : Icons.save,
              color: Colors.white,
            ),
            onPressed: _isSaved ? null : _saveAnalyse,
            tooltip: _isSaved ? 'Déjà sauvegardé' : "Sauvegarder l'analyse",
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
                      // ── En-tête ──────────────────────────────────────
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
                                      fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          if (_isSaved)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 14, color: Colors.green[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sauvegardé',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.green[700]),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Culture ──────────────────────────────────────
                      _buildInfoCard(
                        "Culture analysée",
                        "$culture ($typeCulture)",
                        Icons.agriculture,
                      ),
                      const SizedBox(height: 16),

                      // ── Statut + score ───────────────────────────────
                      _buildStatusCard(status, score, message, emoji),
                      const SizedBox(height: 16),

                      // ── Sous-scores ──────────────────────────────────
                      if (sousScores != null && sousScores.isNotEmpty)
                        _buildSousScoresCard(sousScores),

                      // ── Top 3 variétés ───────────────────────────────
                      if (topVarietes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildTop3VarietesCard(topVarietes),
                      ],

                      // ── Recommandations ──────────────────────────────
                      if (recommandations.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildRecommandationsCard(recommandations),
                      ],

                      // ── Métadonnées ──────────────────────────────────
                      if (metadata != null) ...[
                        const SizedBox(height: 16),
                        _buildMetadataCard(metadata),
                      ],

                      const SizedBox(height: 32),

                      // ── Boutons ──────────────────────────────────────
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                        onPressed: () =>
                            Navigator.popUntil(context, (r) => r.isFirst),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.green[700]!),
                        ),
                        child: Text(
                          "Retour à l'accueil",
                          style:
                              TextStyle(fontSize: 16, color: Colors.green[700]),
                        ),
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

  // ── Écran erreur ────────────────────────────────────────────────────────────
  Widget _buildErrorScreen(String msg) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text(
          "Erreur d'analyse",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
              const SizedBox(height: 20),
              Text(msg,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card info culture ───────────────────────────────────────────────────────
  Widget _buildInfoCard(String title, String subtitle, IconData icon) {
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
                  colors: [Colors.green[500]!, Colors.green[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                  Text(title,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card statut + score ─────────────────────────────────────────────────────
  // ── Card statut + score ─────────────────────────────────────────────────────
  Widget _buildStatusCard(
      String status, int score, String message, String emoji) {
    final statusColor = _getColor(status);
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
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text("Résultat d'analyse",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(status),
                          size: 16, color: statusColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(_getStatusText(status),
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
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
                          if (emoji.isNotEmpty)
                            Text(emoji,
                                style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(message,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700])),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text("Score global",
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "$score",
                            style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: statusColor),
                          ),
                          const SizedBox(width: 4),
                          Text("/100",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
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
                        valueColor:
                            AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                    Text(
                      "$score%",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor),
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

  // ── Sous-scores ─────────────────────────────────────────────────────────────
  Widget _buildSousScoresCard(Map<String, dynamic> sousScores) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green[100]!, width: 1),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.bar_chart, color: Colors.green[700]),
        title: Text(
          "Détails des critères",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green[800]),
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                if (sousScores['temperature'] != null)
                  _buildSousScoreItem(
                    "🌡️ Température",
                    sousScores['temperature']['score'] ?? 0,
                    "Optimal: ${sousScores['temperature']['optimal'] ?? 'N/A'}",
                  ),
                if (sousScores['humidite'] != null)
                  _buildSousScoreItem(
                    "💧 Humidité",
                    sousScores['humidite']['score'] ?? 0,
                    "Optimal: ${sousScores['humidite']['optimal'] ?? 'N/A'}",
                  ),
                if (sousScores['sol'] != null)
                  _buildSousScoreItem(
                    "🌍 Type de sol",
                    sousScores['sol']['score'] ?? 0,
                    "Sol optimal: ${sousScores['sol']['optimal'] ?? 'N/A'}",
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
                    "Optimale: ${sousScores['saison']['optimale'] ?? 'N/A'}",
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSousScoreItem(String label, int score, String detail) {
    Color scoreColor;
    if (score >= 80) scoreColor = Colors.green;
    else if (score >= 60) scoreColor = Colors.lightGreen;
    else if (score >= 40) scoreColor = Colors.orange;
    else scoreColor = Colors.red;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        backgroundColor: scoreColor.withOpacity(0.2),
        child: Text('$score',
            style: TextStyle(
                color: scoreColor, fontWeight: FontWeight.bold)),
      ),
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle:
          Text(detail, style: const TextStyle(fontSize: 12)),
      trailing: SizedBox(
        width: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          ),
        ),
      ),
    );
  }

  // ── Top 3 variétés ──────────────────────────────────────────────────────────
  Widget _buildTop3VarietesCard(List<dynamic> varietes) {
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
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[500]!, Colors.green[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.emoji_events,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Top ${varietes.length > 1 ? '3' : '1'} variété${varietes.length > 1 ? 's' : ''} recommandée${varietes.length > 1 ? 's' : ''}",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800]),
                      ),
                      Text(
                        "Classées par score de pertinence",
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Liste podium
            ...varietes.take(3).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final v = entry.value as Map<String, dynamic>;
              final medals = ["🥇", "🥈", "🥉"];
              final medalColors = [
                Colors.amber[700]!,
                Colors.blueGrey[400]!,
                Colors.orange[700]!,
              ];
              final varScore =
                  (v['score_variete'] ?? v['score'] ?? 0) as num;
              final nom = v['nom'] ?? 'Variété ${index + 1}';
              final description = (v['description'] ?? '') as String;
              final cycle = v['cycle_vegetatif'];
              final resistSecheresse =
                  v['resistance_secheresse'] == true;

              return Container(
                margin: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: index == 0
                      ? Colors.amber[50]
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: index == 0
                        ? Colors.amber[200]!
                        : Colors.grey[200]!,
                    width: index == 0 ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rang + nom + badge score
                    Row(
                      children: [
                        Text(medals[index],
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            nom,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: medalColors[index].withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${varScore.round()}%",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: medalColors[index]),
                          ),
                        ),
                      ],
                    ),
                    // Barre progression
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: varScore / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            medalColors[index]),
                      ),
                    ),
                    // Description
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Tags
                    if (cycle != null || resistSecheresse) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          if (cycle != null)
                            _buildTag("⏱ $cycle", Colors.green),
                          if (resistSecheresse)
                            _buildTag(
                                "💧 Résistante sécheresse", Colors.blue),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ── Recommandations ─────────────────────────────────────────────────────────
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
            _buildCardHeader(Icons.lightbulb, "Recommandations"),
            const SizedBox(height: 12),
            ...recommandations.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
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
                          '${entry.key + 1}',
                          style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey[700]),
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

  // ── Métadonnées ─────────────────────────────────────────────────────────────
  Widget _buildMetadataCard(Map<String, dynamic> metadata) {
    return Card(
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
    );
  }

  // ── Helper en-tête de carte ─────────────────────────────────────────────────
  Widget _buildCardHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[500]!, Colors.green[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[800]),
        ),
      ],
    );
  }
}