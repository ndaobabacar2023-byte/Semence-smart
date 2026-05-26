// lib/screens/technicien/analyse_detail_screen.dart
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

  Future<void> _validerAnalyse() async {
    setState(() => _isProcessing = true);

    final success =
        await Provider.of<TechnicienProvider>(context, listen: false)
            .validateAnalyse(widget.analyse.id);

    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analyse validée'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _corrigerAnalyse() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez un commentaire'),
          backgroundColor: Colors.orange,
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
        const SnackBar(
          content: Text('Analyse corrigée'),
          backgroundColor: Colors.blue,
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
      appBar: AppBar(
        title: Text('Analyse ${analyse.culture}'),
        backgroundColor: Colors.green[700],
        actions: [
          if (isPending)
            TextButton.icon(
              onPressed: _isProcessing ? null : _validerAnalyse,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'Valider',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoTile(Icons.person, 'Agriculteur', analyse.userName),
                  _infoTile(Icons.agriculture, 'Culture', analyse.culture),
                  _infoTile(
                    Icons.thermostat,
                    'Conditions',
                    'Temp: ${analyse.temperature}°C, Hum: ${analyse.humidite}%, Eau: ${analyse.eau}mm',
                  ),
                  _infoTile(
                    Icons.recommend,
                    'Recommandations',
                    analyse.recommandations.isNotEmpty
                        ? analyse.recommandations.first
                        : 'Aucune',
                  ),
                  if (isPending) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Commentaire de correction',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Ajoutez vos corrections...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _corrigerAnalyse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('Corriger'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}