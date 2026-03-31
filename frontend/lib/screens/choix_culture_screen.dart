import 'package:flutter/material.dart';
import 'formulaire_screen.dart';

class ChoixCultureScreen extends StatelessWidget {
  final String type;
  const ChoixCultureScreen({required this.type, Key? key}) : super(key: key);

  // Cultures adaptées au Sénégal
  final Map<String, List<Map<String, dynamic>>> cultures = const {
    "serre": [
      {
        "nom": "Tomate",
        "nom_local": "Tomat",
        "image": "assets/images/tomate.jpg",
        "description": "Culture de contre-saison très rentable",
        "saison": "saison sèche"
      },
      {
        "nom": "Piment",
        "nom_local": "Kaani",
        "image": "assets/images/piment.jpg",
        "description": "Fortes demandes sur les marchés locaux",
        "saison": "saison sèche"
      },
      {
        "nom": "Aubergine",
        "nom_local": "Birek",
        "image": "assets/images/aubergine.jpg",
        "description": "Adaptée aux sols riches en matière organique",
        "saison": "saison sèche"
      },
      {
        "nom": "Chou",
        "nom_local": "Chou",
        "image": "assets/images/chou.jpg",
        "description": "Pour les zones fraîches et altitude",
        "saison": "contre-saison"
      },
    ],
    "plein_air": [
      {
        "nom": "Arachide",
        "nom_local": "Gerte",
        "image": "assets/images/arachide.jpg",
        "description": "Culture de rente importante au Sénégal",
        "saison": "hivernage"
      },
      {
        "nom": "Mil",
        "nom_local": "Souna",
        "image": "assets/images/mil.jpg",
        "description": "Céréale de base, résistante à la sécheresse",
        "saison": "hivernage"
      },
      {
        "nom": "Niébé",
        "nom_local": "Niebé",
        "image": "assets/images/niebe.jpg",
        "description": "Légumineuse riche en protéines",
        "saison": "hivernage"
      },
      {
        "nom": "Maïs",
        "nom_local": "Màkka",
        "image": "assets/images/mais.jpg",
        "description": "Culture vivrière importante",
        "saison": "hivernage"
      },
      {
        "nom": "Gombo",
        "nom_local": "Lalo",
        "image": "assets/images/gombo.jpg",
        "description": "Légume très apprécié dans la cuisine",
        "saison": "hivernage"
      },
      {
        "nom": "Oignon",
        "nom_local": "Sobolo",
        "image": "assets/images/oignon.jpg",
        "description": "Culture de décrue et contre-saison",
        "saison": "saison sèche"
      },
      {
        "nom": "Pastèque",
        "nom_local": "Watar",
        "image": "assets/images/pasteque.jpg",
        "description": "Fruit très demandé en saison chaude",
        "saison": "hivernage"
      },
      {
        "nom": "Haricot",
        "nom_local": "Ndew",
        "image": "assets/images/haricot.jpg",
        "description": "Légumineuse pour rotation des cultures",
        "saison": "hivernage"
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final selectedCultures = cultures[type] ?? [];

    if (selectedCultures.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Choix de culture")),
        body: const Center(child: Text("Aucune culture disponible pour ce type.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choix de culture"),
        backgroundColor: Colors.green[700],
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type == "serre" ? "🌿 Cultures sous serre" : "🌾 Cultures de plein champ",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == "serre" 
                ? "Cultures de contre-saison à haute valeur ajoutée"
                : "Cultures traditionnelles adaptées au climat sénégalais",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: selectedCultures.length,
                itemBuilder: (context, index) {
                  final culture = selectedCultures[index];
                  return _buildCultureCard(context, culture, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCultureCard(BuildContext context, Map<String, dynamic> culture, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + index * 100),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FormulaireScreen(
                  type: type,
                  culture: culture["nom"]!,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                    image: culture["image"] != null
                        ? DecorationImage(
                            image: AssetImage(culture["image"] as String),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: culture["image"] == null
                      ? Icon(Icons.agriculture, size: 40, color: Colors.grey[400])
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            culture["nom"] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (culture["nom_local"] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange[100]!),
                              ),
                              child: Text(
                                culture["nom_local"] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (culture["description"] != null)
                        Text(
                          culture["description"] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            "Saison: ${culture["saison"] ?? "hivernage"}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: type == "serre" ? Colors.blue[50] : Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (type == "serre" ? Colors.blue[100] : Colors.green[100])!,
                              ),
                            ),
                            child: Text(
                              type == "serre" ? "🏠 Serre" : "🌱 Plein air",
                              style: TextStyle(
                                fontSize: 11,
                                color: type == "serre" ? Colors.blue[800] : Colors.green[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}