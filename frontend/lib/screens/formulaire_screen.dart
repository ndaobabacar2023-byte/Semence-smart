import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'resultat_screen.dart';

class FormulaireScreen extends StatefulWidget {
  final String type;
  final String culture;

  FormulaireScreen({required this.type, required this.culture});

  @override
  _FormulaireScreenState createState() => _FormulaireScreenState();
}

class _FormulaireScreenState extends State<FormulaireScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  double _temperature = 25;
  double _humidite = 50;
  double _eau = 30;

  String? _sol;
  String? _zone;
  String? _saison;

  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fadeInAnim;

  final List<String> sols = ['Limoneux', 'Argileux', 'Sableux'];
  final List<String> zones = ['Kaolack', 'Dakar', 'Saint-Louis'];
  final List<String> saisons = ['Printemps', 'Été', 'Automne', 'Hiver'];

  // Variables pour score indicatif
  int _scoreIndicatif = 0;
  List<String> _recoIndicatives = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 800));
    _fadeInAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();

    _updateIndicatif();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Fonction simple de calcul indicatif (basée sur poids approximatifs)
  void _updateIndicatif() {
    int tempScore = (_temperature >= 20 && _temperature <= 30)
        ? 100
        : (_temperature >= 15 && _temperature <= 35 ? 60 : 20);

    int humiditeScore = (_humidite >= 40 && _humidite <= 70)
        ? 100
        : (_humidite >= 30 && _humidite <= 80 ? 60 : 20);

    int eauScore = (_eau >= 20 && _eau <= 80) ? 100 : (_eau >= 10 ? 60 : 20);

    int solScore = (_sol != null) ? 100 : 50;
    int saisonScore = (_saison != null) ? 100 : 50;

    double weighted = tempScore * 0.35 +
        humiditeScore * 0.25 +
        solScore * 0.2 +
        eauScore * 0.1 +
        saisonScore * 0.1;

    setState(() {
      _scoreIndicatif = weighted.round();

      // Recommandations simples
      _recoIndicatives = [];
      if (tempScore < 60) _recoIndicatives.add('Ajuster la température');
      if (humiditeScore < 60) _recoIndicatives.add('Adapter l\'humidité');
      if (solScore < 60) _recoIndicatives.add('Vérifier le type de sol');
      if (eauScore < 60) _recoIndicatives.add('Augmenter ou réduire l\'irrigation');
      if (saisonScore < 60) _recoIndicatives.add('Planifier la saison');
      if (_recoIndicatives.isEmpty) _recoIndicatives.add('Conditions favorables');
    });
  }

  Future<void> _submit() async {
    if (_sol == null || _zone == null || _saison == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _loading = true);

    final body = {
      "culture": widget.culture,
      "typeCulture": widget.type,
      "temperature": _temperature,
      "humidite": _humidite,
      "eau": _eau,
      "sol": _sol,
      "zone": _zone,
      "saison": _saison
    };

    try {
      final result = await ApiService.analyseConditions(body);

      if (result['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ResultatScreen(result: result['data'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Erreur serveur')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged, String unit) {
    return FadeTransition(
      opacity: _fadeInAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$label : ${value.toStringAsFixed(1)} $unit",
                style: TextStyle(fontSize: 16)),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              label: value.toStringAsFixed(1),
              onChanged: (val) {
                onChanged(val);
                _updateIndicatif();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String? value, String label, List<String> items,
      ValueChanged<String?> onChanged) {
    return FadeTransition(
      opacity: _fadeInAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (val) {
            onChanged(val);
            _updateIndicatif();
          },
          validator: (v) => v == null ? 'Champ requis' : null,
        ),
      ),
    );
  }

  Widget _buildIndicatifCard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Score indicatif : $_scoreIndicatif / 100",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Recommandations :",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ..._recoIndicatives.map((r) => Text("- $r")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètres ${widget.culture}"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildSlider("Température", _temperature, 0, 50,
                        (val) => setState(() => _temperature = val), "°C"),
                    _buildSlider("Humidité", _humidite, 0, 100,
                        (val) => setState(() => _humidite = val), "%"),
                    _buildDropdown(_sol, "Type de sol", sols,
                        (val) => setState(() => _sol = val)),
                    _buildDropdown(_zone, "Zone", zones,
                        (val) => setState(() => _zone = val)),
                    _buildDropdown(_saison, "Saison", saisons,
                        (val) => setState(() => _saison = val)),
                    _buildSlider("Eau", _eau, 0, 100,
                        (val) => setState(() => _eau = val), "mm/semaine"),
                    _buildIndicatifCard(),
                    SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeInAnim,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 5,
                        ),
                        child:
                            Text("Analyser", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
