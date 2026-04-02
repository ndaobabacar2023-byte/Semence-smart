import 'package:flutter/material.dart';
import 'formulaire_screen.dart';

class ChoixCultureScreen extends StatelessWidget {
  final String type;
  const ChoixCultureScreen({required this.type, super.key});

  final Map<String, List<Map<String, String>>> cultures = const {
    "serre": [
      {"nom": "Tomate", "image": "assets/images/tomate.jpg"},
      {"nom": "Poivron", "image": "assets/images/poivron.jpg"},
    ],
    "plein_air": [
      {"nom": "Mil", "image": "assets/images/mil.jpg"},
      {"nom": "Arachide", "image": "assets/images/arachide.jpeg"},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final selectedCultures = cultures[type] ?? [];

    if (selectedCultures.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Choix de culture"),
          backgroundColor: Colors.green[700],
        ),
        body: const Center(
          child: Text(
            "Aucune culture disponible",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choix de culture"),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF2E7D32)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: List.generate(selectedCultures.length, (index) {
                    final culture = selectedCultures[index];

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 400 + index * 100),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
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
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [

                              // 🌱 Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  culture["image"]!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              const SizedBox(width: 15),

                              // 🌱 Texte
                              Expanded(
                                child: Text(
                                  culture["nom"]!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // ➡️ Icon
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
