import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/location_provider.dart';
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

  // Paramètres
  double _temperature = 28.0;
  double _humidite = 60.0;
  double _eau = 30.0;
  String? _sol;
  String? _zone;
  String? _saison;
  bool _loading = false;
  bool _isLocationLoaded = false;

  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Options
  final List<String> sols = ['Sableux', 'Limoneux', 'Argileux', 'Lateritique', 'Tourbeux'];
  
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

  @override
  void initState() {
    super.initState();
    
    // Animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();

    _setDefaultValues();
    _loadUserLocation();
  }

  void _setDefaultValues() {
    setState(() {
      _saison = 'Hivernage (juin - septembre)';
      if (widget.type == "serre") {
        _temperature = 25.0;
        _humidite = 65.0;
      } else {
        _temperature = 28.0;
        _humidite = 60.0;
      }
    });
  }

  void _loadUserLocation() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        String detectedZone = locationProvider.currentZone;
        String formattedZone = _getFormattedZone(detectedZone);
        
        if (formattedZone.isNotEmpty) {
          _zone = formattedZone;
          _isLocationLoaded = true;
        }
      });
    });
  }

  String _getFormattedZone(String zone) {
    switch (zone) {
      case 'Nord': return 'Nord (Louga, Matam, Podor)';
      case 'Centre': return 'Centre (Thiès, Diourbel, Kaolack)';
      case 'Sud': return 'Sud (Ziguinchor, Sédhiou, Kolda)';
      case 'Littoral': return 'Littoral (Dakar, Mbour, Saly)';
      case 'Vallée': return 'Vallée du Fleuve (Saint-Louis, Dagana)';
      default: return '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sol == null || _zone == null || _saison == null) {
      _showErrorSnackBar('Veuillez remplir tous les champs');
      return;
    }

    setState(() => _loading = true);

    try {
      final zoneSimple = _zone!.split(' ')[0].replaceAll('(', '');
      final saisonSimple = _saison!.split(' ')[0].toLowerCase();

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

      if (result['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultatScreen(result: result['data']),
          ),
        );
      } else {
        _showErrorSnackBar(result['message'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _loading ? _buildLoadingScreen() : _buildForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.culture,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.type == "serre" ? "Culture sous serre" : "Culture plein champ",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.green[800],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showHelpDialog(),
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[700]!],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Analyse en cours...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Évaluation des conditions pour ${widget.culture}",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec icône
                _buildHeader(),
                const SizedBox(height: 24),
                
                // Carte de localisation
                _buildLocationCard(),
                const SizedBox(height: 24),
                
                // Section paramètres environnementaux
                _buildSectionTitle("🌡️ Conditions environnementales"),
                const SizedBox(height: 16),
                
                // Sliders
                _buildModernSlider(
                  label: "Température",
                  value: _temperature,
                  min: 15,
                  max: 45,
                  unit: "°C",
                  icon: Icons.thermostat,
                  color: Colors.orange,
                  onChanged: (val) => setState(() => _temperature = val),
                ),
                _buildModernSlider(
                  label: "Humidité",
                  value: _humidite,
                  min: 20,
                  max: 95,
                  unit: "%",
                  icon: Icons.water_drop,
                  color: Colors.blue,
                  onChanged: (val) => setState(() => _humidite = val),
                ),
                _buildModernSlider(
                  label: "Disponibilité en eau",
                  value: _eau,
                  min: 0,
                  max: 100,
                  unit: "mm",
                  icon: Icons.water,
                  color: Colors.cyan,
                  onChanged: (val) => setState(() => _eau = val),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle("🌍 Paramètres du sol"),
                const SizedBox(height: 16),
                
                // Dropdowns modernes
                _buildModernDropdown(
                  label: "Type de sol",
                  value: _sol,
                  items: sols,
                  icon: Icons.landscape,
                  onChanged: (val) => setState(() => _sol = val),
                ),
                const SizedBox(height: 16),
                
                _buildModernDropdown(
                  label: "Zone géographique",
                  value: _zone,
                  items: zones,
                  icon: Icons.location_on,
                  onChanged: (val) => setState(() => _zone = val),
                  isLocationAuto: _isLocationLoaded,
                ),
                const SizedBox(height: 16),
                
                _buildModernDropdown(
                  label: "Saison de culture",
                  value: _saison,
                  items: saisons,
                  icon: Icons.calendar_today,
                  onChanged: (val) => setState(() => _saison = val),
                ),
                
                const SizedBox(height: 32),
                
                // Bouton d'action
                _buildSubmitButton(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[600]!, Colors.green[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.type == "serre" ? Icons.home_work : Icons.agriculture,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.culture,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Remplissez les informations ci-dessous pour obtenir une analyse personnalisée",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isLocationLoaded ? Colors.green[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isLocationLoaded ? Colors.green[200]! : Colors.orange[200]!,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isLocationLoaded ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isLocationLoaded ? Icons.location_on : Icons.location_searching,
                  color: _isLocationLoaded ? Colors.green[700] : Colors.orange[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLocationLoaded ? "Zone détectée automatiquement" : "Détection en cours",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isLocationLoaded ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLocationLoaded 
                        ? "📍 ${locationProvider.currentZone} - ${_zone ?? ''}"
                        : "Recherche de votre position géographique...",
                      style: TextStyle(
                        fontSize: 12,
                        color: _isLocationLoaded ? Colors.green[600] : Colors.orange[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isLocationLoaded)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.orange[700]!),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildModernSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required IconData icon,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${value.toStringAsFixed(1)} $unit",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
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
            activeColor: color,
            inactiveColor: color.withOpacity(0.2),
            divisions: (max - min).toInt(),
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$min $unit", style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              Text("${((min + max) / 2).toInt()} $unit", style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              Text("$max $unit", style: TextStyle(fontSize: 11, color: Colors.grey[400])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    bool isLocationAuto = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green[600], size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Row(
              children: [
                if (isLocationAuto && value == item)
                  Icon(Icons.location_on, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(item),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Champ requis' : null,
        icon: Icon(Icons.arrow_drop_down, color: Colors.green[600]),
        dropdownColor: Colors.white,
        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[500]!, Colors.green[700]!],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 22),
            SizedBox(width: 12),
            Text(
              "Lancer l'analyse détaillée",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("💡 Conseils", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem("🌡️ Température", "Température moyenne journalière de votre région"),
            const SizedBox(height: 12),
            _buildHelpItem("💧 Humidité", "Taux d'humidité dans l'air (moyenne journalière)"),
            const SizedBox(height: 12),
            _buildHelpItem("🌍 Type de sol", "Nature dominante de votre sol (sableux, argileux, etc.)"),
            const SizedBox(height: 12),
            _buildHelpItem("📍 Zone", "Votre zone géographique au Sénégal"),
            const SizedBox(height: 12),
            _buildHelpItem("💦 Eau", "Quantité d'eau disponible pour l'irrigation (mm/semaine)"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }
}