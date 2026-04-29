import 'package:flutter/material.dart';
import 'formulaire_screen.dart';

class ChoixCultureScreen extends StatelessWidget {
  final String type;
  const ChoixCultureScreen({required this.type, super.key});

  final Map<String, List<Map<String, String>>> cultures = const {
    "serre": [
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
    ],
    "plein_air": [
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
    ],
  };

  @override
  Widget build(BuildContext context) {
    final selectedCultures = cultures[type] ?? [];

    if (selectedCultures.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.green[50],
        appBar: AppBar(
          title: const Text(
            "Choix de culture",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Texte blanc
            ),
          ),
          backgroundColor: Colors.green[700],
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white), // Flèche de retour blanche
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            "Aucune culture disponible",
            style: TextStyle(
              fontSize: 18,
              color: Colors.green[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.green[50], // Fond vert clair
      appBar: AppBar(
        title: const Text(
          "Choix de culture",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Texte blanc
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Flèche de retour blanche
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, // Corps blanc
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
                        type == "serre" ? "Culture sous serre" : "Culture en plein air",
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
                      ...List.generate(selectedCultures.length, (index) {
                        final culture = selectedCultures[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildCultureCard(
                            context,
                            culture["nom"] ?? "Culture",
                            culture["emoji"] ?? "🌱",
                            culture["description"] ?? "",
                          ),
                        );
                      }),
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

  Widget _buildCultureCard(BuildContext context, String nom, String emoji, String description) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormulaireScreen(
              type: type,
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
            color: Colors.green[100]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Emoji avec fond vert
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
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nom,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
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
              // Flèche
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.green[700],
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}