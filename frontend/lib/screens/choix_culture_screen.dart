import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'formulaire_screen.dart';
import 'ajouter_culture_screen.dart'; // À créer

class ChoixCultureScreen extends StatefulWidget {
  final String type;
  const ChoixCultureScreen({required this.type, super.key});

  @override
  State<ChoixCultureScreen> createState() => _ChoixCultureScreenState();
}

class _ChoixCultureScreenState extends State<ChoixCultureScreen> {
  // Cultures par défaut pour serre
  final List<Map<String, String>> _defaultSerreCultures = const [
    {
      "nom": "Tomate",
      "emoji": "🍅",
      "description": "Idéale pour serre, rendement élevé"
    },
    {
      "nom": "Poivron",
      "emoji": "🫑",
      "description": "Culture sous serre, protection optimale"
    },
    {
      "nom": "Piment",
      "emoji": "🌶️",
      "description": "Culture sous serre, variétés douces à très fortes"
    },
    {
      "nom": "Laitue",
      "emoji": "🥬",
      "description": "Culture sous serre, croissance rapide"
    },
  ];

  // Cultures par défaut pour plein air
  final List<Map<String, String>> _defaultPleinAirCultures = const [
    {
      "nom": "Mil",
      "emoji": "🌾",
      "description": "Culture en plein air, besoin en eau modéré"
    },
    {
      "nom": "Arachide",
      "emoji": "🥜",
      "description": "Culture en plein air, résistante aux sécheresses"
    },
    {
      "nom": "Oignon",
      "emoji": "🧅",
      "description": "Culture en plein air, journée courte"
    },
    {
      "nom": "Aubergine",
      "emoji": "🍆",
      "description": "Culture en plein air, résistante à la chaleur"
    },
  ];

  List<Map<String, String>> _userCultures = [];
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadUserCultures();
  }

  Future<void> _loadUserCultures() async {
    _prefs = await SharedPreferences.getInstance();
    final String key = 'user_cultures_${widget.type}';
    final String? culturesJson = _prefs?.getString(key);
    
    if (culturesJson != null && culturesJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = List<dynamic>.from(
          culturesJson.split('|||').map((e) {
            final parts = e.split(';;;');
            return {
              'nom': parts[0],
              'emoji': parts[1],
              'description': parts.length > 2 ? parts[2] : 'Culture personnalisée',
            };
          })
        );
        setState(() {
          _userCultures = decoded.map((e) => Map<String, String>.from(e)).toList();
        });
      } catch (e) {
        print('Erreur chargement cultures: $e');
        _userCultures = [];
      }
    }
  }

  Future<void> _saveUserCultures() async {
    final String key = 'user_cultures_${widget.type}';
    final String culturesJson = _userCultures.map((c) => 
      '${c['nom']};;;${c['emoji']};;;${c['description']}'
    ).join('|||');
    await _prefs?.setString(key, culturesJson);
  }

  Future<void> _ajouterCulture() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AjouterCultureScreen(type: widget.type),
      ),
    );
    
    if (result != null && result is Map<String, String>) {
      setState(() {
        _userCultures.add(result);
      });
      _saveUserCultures();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Culture "${result['nom']}" ajoutée avec succès'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _supprimerCulture(int index) async {
    final culture = _userCultures[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la culture'),
        content: Text('Voulez-vous vraiment supprimer "${culture['nom']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() {
        _userCultures.removeAt(index);
      });
      _saveUserCultures();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Culture "${culture['nom']}" supprimée'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  List<Map<String, String>> get _allCultures {
    final defaultCultures = widget.type == "serre" ? _defaultSerreCultures : _defaultPleinAirCultures;
    return [...defaultCultures, ..._userCultures];
  }

  @override
  Widget build(BuildContext context) {
    final allCultures = _allCultures;

    if (allCultures.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.green[50],
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.agriculture,
                size: 80,
                color: Colors.green[300],
              ),
              const SizedBox(height: 16),
              Text(
                "Aucune culture disponible",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _ajouterCulture,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une culture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: _buildAppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              margin: const EdgeInsets.all(16),
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
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        widget.type == "serre" ? "Culture sous serre" : "Culture en plein air",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Sélectionnez la culture que vous souhaitez analyser",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      // Section cultures par défaut
                      if (widget.type == "serre" || widget.type == "plein_air") ...[
                        _buildSectionHeader("Cultures recommandées", Icons.recommend),
                        ..._buildDefaultCulturesList(),
                      ],
                      // Section cultures personnalisées
                      if (_userCultures.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSectionHeader("Mes cultures", Icons.person),
                        ..._buildUserCulturesList(),
                      ],
                      const SizedBox(height: 20),
                      // Bouton ajouter culture
                      _buildAjouterCultureButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Choix de culture",
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
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDefaultCulturesList() {
    final defaultCultures = widget.type == "serre" ? _defaultSerreCultures : _defaultPleinAirCultures;
    
    return List.generate(defaultCultures.length, (index) {
      final culture = defaultCultures[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildCultureCard(
          culture["nom"]!,
          culture["emoji"]!,
          culture["description"]!,
          isUserCulture: false,
        ),
      );
    });
  }

  List<Widget> _buildUserCulturesList() {
    return List.generate(_userCultures.length, (index) {
      final culture = _userCultures[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Dismissible(
          key: Key(culture['nom']!),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _supprimerCulture(index),
          child: _buildCultureCard(
            culture["nom"]!,
            culture["emoji"]!,
            culture["description"]!,
            isUserCulture: true,
            onDelete: () => _supprimerCulture(index),
          ),
        ),
      );
    });
  }

  Widget _buildCultureCard(String nom, String emoji, String description, {
    required bool isUserCulture,
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormulaireScreen(
              type: widget.type,
              culture: nom,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: isUserCulture ? Colors.orange[200]! : Colors.green[100]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isUserCulture
                        ? [Colors.orange[500]!, Colors.orange[700]!]
                        : [Colors.green[500]!, Colors.green[700]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          nom,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        if (isUserCulture) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Personnalisée",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isUserCulture && onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
                  onPressed: onDelete,
                ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isUserCulture ? Colors.orange[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: isUserCulture ? Colors.orange[700] : Colors.green[700],
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAjouterCultureButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: OutlinedButton.icon(
        onPressed: _ajouterCulture,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Ajouter ma propre culture'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green[700],
          side: BorderSide(color: Colors.green[300]!),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _ajouterCulture,
      backgroundColor: Colors.green[700],
      child: const Icon(Icons.add, color: Colors.white),
      tooltip: 'Ajouter une culture',
    );
  }
}