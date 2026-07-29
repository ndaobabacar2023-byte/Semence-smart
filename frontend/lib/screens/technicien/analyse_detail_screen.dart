import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/technicien_provider.dart';
import '../../models/analyse_model.dart';

class AnalyseDetailScreen extends StatefulWidget {
  final AnalyseModel analyse;

  const AnalyseDetailScreen({
    Key? key,
    required this.analyse,
  }) : super(key: key);

  @override
  State<AnalyseDetailScreen> createState() => _AnalyseDetailScreenState();
}

class _AnalyseDetailScreenState extends State<AnalyseDetailScreen> {
  final _commentController = TextEditingController();
  bool _isProcessing = false;

  static const Color primaryGreen = Color(0xFF2E7D32);

  Future<void> _validerAnalyse() async {
    setState(() => _isProcessing = true);

    final success =
        await Provider.of<TechnicienProvider>(context, listen: false)
            .validateAnalyse(widget.analyse.id);

    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Analyse validée'),
          backgroundColor: Colors.green[600],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _corrigerAnalyse() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ajoutez un commentaire'),
          backgroundColor: Colors.orange[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final success =
        await Provider.of<TechnicienProvider>(context, listen: false)
            .correctAnalyse(
      analyseId: widget.analyse.id,
      comment: _commentController.text,
      recommandations: widget.analyse.recommandations,
    );

    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Analyse corrigée'),
          backgroundColor: Colors.blue[600],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final analyse = widget.analyse;
    final bool isPending = analyse.statut == 'pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: Text(
          'Analyse ${analyse.culture}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (isPending)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _isProcessing ? null : _validerAnalyse,
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                label: const Text('Valider', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Statut badge ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isPending ? Colors.orange : primaryGreen).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPending ? Icons.hourglass_bottom_rounded : Icons.check_circle_rounded,
                          size: 16,
                          color: isPending ? Colors.orange[800] : primaryGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPending ? "En attente de validation" : analyse.statut.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isPending ? Colors.orange[800] : primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _infoTile(Icons.person_rounded, 'Agriculteur', analyse.userName, Colors.blue),
                  _infoTile(Icons.agriculture_rounded, 'Culture', analyse.culture, Colors.green),
                  _infoTile(
                    Icons.thermostat_rounded,
                    'Conditions',
                    'Temp: ${analyse.temperature}°C, Hum: ${analyse.humidite}%, Eau: ${analyse.eau}mm',
                    Colors.orange,
                  ),
                  _infoTile(
                    Icons.recommend_rounded,
                    'Recommandations',
                    analyse.recommandations.isNotEmpty
                        ? analyse.recommandations.first
                        : 'Aucune',
                    Colors.purple,
                  ),

                  if (isPending) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Commentaire de correction',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[850],
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
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
                        controller: _commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Ajoutez vos corrections...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _corrigerAnalyse,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Corriger'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}