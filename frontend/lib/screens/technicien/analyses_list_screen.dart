// lib/screens/technicien/analyses_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/technicien_provider.dart';

class AnalysesListScreen extends StatefulWidget {
  const AnalysesListScreen({Key? key}) : super(key: key);

  @override
  State<AnalysesListScreen> createState() => _AnalysesListScreenState();
}

class _AnalysesListScreenState extends State<AnalysesListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TechnicienProvider>(
        context,
        listen: false,
      ).loadAnalyses();
    });
  }

  Future<void> _refresh() async {
    await Provider.of<TechnicienProvider>(
      context,
      listen: false,
    ).loadAnalyses();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TechnicienProvider>(
      builder: (context, provider, child) {
        final analyses = provider.filteredAnalyses;

        return Scaffold(
          backgroundColor: Colors.grey[50],

          body: Column(
            children: [
              // ===== FILTRES =====
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        provider,
                        label: 'Toutes',
                        value: 'all',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        provider,
                        label: 'En attente',
                        value: 'pending',
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        provider,
                        label: 'Validées',
                        value: 'validated',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        provider,
                        label: 'Corrigées',
                        value: 'corrected',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),

              // ===== STATS =====
              if (provider.stats != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Total',
                        '${provider.stats!['total'] ?? 0}',
                        Colors.blue,
                      ),
                      _buildStatItem(
                        'Pending',
                        '${provider.stats!['pending'] ?? 0}',
                        Colors.orange,
                      ),
                      _buildStatItem(
                        'Validées',
                        '${provider.stats!['validated'] ?? 0}',
                        Colors.green,
                      ),
                      _buildStatItem(
                        'Corrigées',
                        '${provider.stats!['corrected'] ?? 0}',
                        Colors.purple,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // ===== LISTE =====
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : analyses.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: analyses.length,
                              itemBuilder: (context, index) {
                                final analyse = analyses[index];
                                return _buildAnalyseCard(
                                  context,
                                  analyse,
                                  provider,
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== CHIP FILTRE =====
  Widget _buildFilterChip(
    TechnicienProvider provider, {
    required String label,
    required String value,
    required Color color,
  }) {
    final selected = provider.currentFilter == value;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: selected,
      onSelected: (_) => provider.setFilter(value),
      selectedColor: color,
      backgroundColor: color.withOpacity(0.1),
      checkmarkColor: Colors.white,
    );
  }

  // ===== STATS =====
  Widget _buildStatItem(
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ===== EMPTY =====
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune analyse trouvée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les nouvelles analyses apparaîtront ici',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // ===== CARD ANALYSE =====
  Widget _buildAnalyseCard(
    BuildContext context,
    dynamic analyse,
    TechnicienProvider provider,
  ) {
    final culture = analyse['culture'] ?? 'Culture inconnue';
    final agriculteur =
        analyse['userId'] != null
            ? '${analyse['userId']['prenom'] ?? ''} ${analyse['userId']['nom'] ?? ''}'
                .trim()
            : 'Agriculteur';

    final statut = analyse['statut'] ?? 'pending';

    Color statusColor;
    IconData statusIcon;

    switch (statut) {
      case 'validated':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'corrected':
        statusColor = Colors.purple;
        statusIcon = Icons.edit;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Icon(
                    Icons.agriculture,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        culture,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        agriculteur,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statut.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ===== INFOS =====
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(
                  Icons.thermostat,
                  '${analyse['temperature'] ?? 0}°C',
                ),
                _infoChip(
                  Icons.water_drop,
                  '${analyse['humidite'] ?? 0}%',
                ),
                _infoChip(
                  Icons.landscape,
                  analyse['sol'] ?? 'N/A',
                ),
                _infoChip(
                  Icons.location_on,
                  analyse['zone'] ?? 'N/A',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ===== SCORE =====
            LinearProgressIndicator(
              value: ((analyse['score'] ?? 0) / 100).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _scoreColor((analyse['score'] ?? 0)),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Score: ${analyse['score'] ?? 0}/100',
              style: TextStyle(
                color: _scoreColor(analyse['score'] ?? 0),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // ===== ACTIONS =====
            if (statut == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final success = await provider.validateAnalyse(
                          analyse['_id'],
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Analyse validée'
                                    : 'Erreur de validation',
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Valider'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showCorrectionDialog(
                          context,
                          analyse,
                          provider,
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Corriger'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ===== INFOS CHIP =====
  Widget _infoChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.green[700],
          ),
          const SizedBox(width: 4),
          Text(text),
        ],
      ),
    );
  }

  // ===== SCORE COLOR =====
  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  // ===== DIALOG CORRECTION =====
  void _showCorrectionDialog(
    BuildContext context,
    dynamic analyse,
    TechnicienProvider provider,
  ) {
    final commentController = TextEditingController();
    final recoController = TextEditingController();
    final varieteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Corriger l’analyse'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Commentaire',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: recoController,
                decoration: const InputDecoration(
                  labelText: 'Recommandations (séparées par ;)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: varieteController,
                decoration: const InputDecoration(
                  labelText: 'Variété recommandée',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Enregistrer'),
            onPressed: () async {
              final success = await provider.correctAnalyse(
                analyseId: analyse['_id'],
                comment: commentController.text.trim(),
                recommandations: recoController.text
                    .split(';')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
                variete: varieteController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Analyse corrigée'
                          : 'Erreur lors de la correction',
                    ),
                    backgroundColor:
                        success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}