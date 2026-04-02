import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'resultat_screen.dart';

class FormulaireScreen extends StatefulWidget {
  final String type;
  final String culture;

  const FormulaireScreen({
    required this.type,
    required this.culture,
    Key? key,
  }) : super(key: key);

  @override
  _FormulaireScreenState createState() => _FormulaireScreenState();
}

class _FormulaireScreenState extends State<FormulaireScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Valeurs par défaut adaptées au Sénégal
  double _temperature = 28.0;
  double _humidite = 60.0;
  double _eau = 30.0;

  String? _sol;
  String? _zone;
  String? _saison;

  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fadeInAnim;

  // Options adaptées au Sénégal
  final List<String> sols = [
    'Sableux',
    'Limoneux',
    'Argileux',
    'Lateritique',
    'Tourbeux'
  ];

  final List<String> zones = [
    'Nord (Louga, Matam, Podor)',
    'Centre (Thiès, Diourbel, Kaolack)',
    'Sud (Ziguinchor, Sédhiou, Kolda)',
    'Vallée du Fleuve (Saint-Louis, Dagana)',
    'Littoral (Dakar, Mbour, Saly)'
  ];

  final List<String> saisons = [
    'Hivernage (juin - septembre)',
    'Saison sèche (octobre - mai)',
    'Contre-saison (novembre - février)'
  ];

  // Variables pour score indicatif
  int _scoreIndicatif = 0;
  List<String> _recoIndicatives = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    // Définir des valeurs par défaut selon la culture
    _setDefaultValues();
    _updateIndicatif();
  }

  void _setDefaultValues() {
    // Température par défaut selon le type de culture
    setState(() {
      _saison = 'Hivernage (juin - septembre)';
      
      if (widget.type == "serre") {
        _temperature = 25.0; // Température contrôlée en serre
        _humidite = 65.0; // Humidité plus élevée en serre
      } else {
        _temperature = 28.0; // Température extérieure moyenne
        _humidite = 60.0; // Humidité extérieure moyenne
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _updateIndicatif() {
    // Calcul simplifié adapté au Sénégal
    int tempScore = (_temperature >= 25 && _temperature <= 35)
        ? 100
        : (_temperature >= 20 && _temperature <= 40 ? 60 : 20);

    int humiditeScore = (_humidite >= 40 && _humidite <= 75)
        ? 100
        : (_humidite >= 30 && _humidite <= 85 ? 60 : 20);

    int eauScore = (_eau >= 20 && _eau <= 60) ? 100 : (_eau >= 10 ? 60 : 20);

    int solScore = (_sol != null) ? 100 : 50;
    int saisonScore = (_saison != null) ? 100 : 50;

    // Pondérations pour le Sénégal
    double weighted = tempScore * 0.30 +
        humiditeScore * 0.25 +
        solScore * 0.20 +
        eauScore * 0.15 +
        saisonScore * 0.10;

    setState(() {
      _scoreIndicatif = weighted.round();

      // Recommandations simplifiées
      _recoIndicatives = [];
      if (tempScore < 60) {
        if (_temperature < 25) {
          _recoIndicatives.add('Température trop basse pour la saison');
        } else {
          _recoIndicatives.add('Température élevée, protéger les plants');
        }
      }
      if (humiditeScore < 60) {
        if (_humidite < 40) {
          _recoIndicatives.add('Humidité faible, augmenter l\'arrosage');
        } else {
          _recoIndicatives.add('Humidité élevée, risque de maladies fongiques');
        }
      }
      if (solScore < 60) _recoIndicatives.add('Type de sol à vérifier');
      if (eauScore < 60) {
        if (_eau < 20) {
          _recoIndicatives.add('Irrigation insuffisante');
        } else {
          _recoIndicatives.add('Excès d\'eau, améliorer drainage');
        }
      }
      if (saisonScore < 60) _recoIndicatives.add('Saison non optimale');
      if (_recoIndicatives.isEmpty) {
        _recoIndicatives.add('Conditions favorables pour le Sénégal');
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Veuillez corriger les erreurs dans le formulaire');
      return;
    }

    if (_sol == null || _zone == null || _saison == null) {
      _showErrorSnackBar('Veuillez remplir tous les champs');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      // Extraire la zone simplifiée
      final zoneSimple = _zone!.split(' ')[0].replaceAll('(', '');

      // Extraire la saison simplifiée
      final saisonSimple = _saison!.split(' ')[0].toLowerCase();

      print("🚀 Lancement de l'analyse...");
      print("🌱 Culture: ${widget.culture}");
      print("📍 Zone: $zoneSimple");
      print("📅 Saison: $saisonSimple");

      final result = await ApiService.analyseConditions(
        culture: widget.culture,
        typeCulture: widget.type,
        temperature: _temperature,
        humidite: _humidite,
        sol: _sol!,
        zone: zoneSimple,
        saison: saisonSimple,
        eau: _eau,
      );

      print("📥 Résultat API: ${result['success']}");

      if (result['success'] == true) {
        _showSuccessSnackBar('✅ Analyse réussie !');

        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultatScreen(
              result: result['data'],
            ),
          ),
        );
      } else {
        String errorMessage = result['message'] ?? 'Erreur inconnue';

        if (errorMessage.contains('expirée') || result['statusCode'] == 401) {
          _showErrorSnackBar('Session expirée, reconnexion nécessaire');
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        } else {
          _showErrorSnackBar(errorMessage);
        }
      }
    } catch (e) {
      print("❌ Exception: $e");
      _showErrorSnackBar('Erreur: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String unit,
    String tip,
  ) {
    return FadeTransition(
      opacity: _fadeInAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (tip.isNotEmpty)
                      Text(
                        tip,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Text(
                    "${value.toStringAsFixed(1)} $unit",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              label: value.toStringAsFixed(1),
              activeColor: Colors.green[700],
              inactiveColor: Colors.green[100],
              onChanged: (val) {
                setState(() => onChanged(val));
                _updateIndicatif();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$min $unit", style: TextStyle(color: Colors.grey[500])),
                Text("${(min + max) / 2} $unit",
                    style: TextStyle(color: Colors.grey[500])),
                Text("$max $unit", style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String? value,
    String label,
    List<String> items,
    ValueChanged<String?> onChanged,
    String tip,
  ) {
    return FadeTransition(
      opacity: _fadeInAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tip.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  tip,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() => onChanged(val));
                _updateIndicatif();
              },
              validator: (v) => v == null ? 'Ce champ est requis' : null,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatifCard() {
    Color scoreColor;
    String niveau;
    if (_scoreIndicatif >= 80) {
      scoreColor = Colors.green;
      niveau = "Excellent";
    } else if (_scoreIndicatif >= 65) {
      scoreColor = Colors.green[400]!;
      niveau = "Bon";
    } else if (_scoreIndicatif >= 50) {
      scoreColor = Colors.orange;
      niveau = "Moyen";
    } else if (_scoreIndicatif >= 35) {
      scoreColor = Colors.orange[800]!;
      niveau = "Défavorable";
    } else {
      scoreColor = Colors.red;
      niveau = "Critique";
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pré-analyse",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "$niveau ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        "$_scoreIndicatif/100",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Recommandations préliminaires:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ..._recoIndicatives.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: scoreColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCultureInfo() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              widget.type == "serre" ? Icons.home : Icons.agriculture,
              color: Colors.green[700],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.culture,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.type == "serre" ? "Culture sous serre" : "Culture plein champ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.green[700]),
          const SizedBox(height: 20),
          Text(
            "Analyse en cours...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Évaluation des conditions pour ${widget.culture}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètres ${widget.culture}"),
        backgroundColor: Colors.green[700],
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _loading
            ? _buildLoadingIndicator()
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildCultureInfo(),
                    const SizedBox(height: 8),
                    Text(
                      "Paramètres environnementaux",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ajustez les paramètres selon vos conditions réelles",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSlider(
                      "Température ambiante",
                      _temperature,
                      15,
                      45,
                      (val) => setState(() => _temperature = val),
                      "°C",
                      "Moyenne journalière",
                    ),
                    _buildSlider(
                      "Humidité relative",
                      _humidite,
                      20,
                      95,
                      (val) => setState(() => _humidite = val),
                      "%",
                      "Pourcentage d'humidité dans l'air",
                    ),
                    _buildDropdown(
                      _sol,
                      "Type de sol dominant",
                      sols,
                      (val) => setState(() => _sol = val),
                      "Sélectionnez le type de sol de votre parcelle",
                    ),
                    _buildDropdown(
                      _zone,
                      "Zone géographique",
                      zones,
                      (val) => setState(() => _zone = val),
                      "Zone climatique de votre exploitation",
                    ),
                    _buildDropdown(
                      _saison,
                      "Saison de culture",
                      saisons,
                      (val) => setState(() => _saison = val),
                      "Période de l'année pour la culture",
                    ),
                    _buildSlider(
                      "Disponibilité en eau",
                      _eau,
                      0,
                      100,
                      (val) => setState(() => _eau = val),
                      "mm/semaine",
                      "Quantité d'eau disponible pour l'irrigation",
                    ),
                    _buildIndicatifCard(),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeInAnim,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.analytics, size: 24),
                            SizedBox(width: 12),
                            Text(
                              "Lancer l'analyse détaillée",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, size: 18, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "Changer de culture",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
