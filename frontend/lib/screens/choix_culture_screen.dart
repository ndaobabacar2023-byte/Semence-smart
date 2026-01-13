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
        appBar: AppBar(title: const Text("Choix de culture")),
        body: const Center(child: Text("Aucune culture disponible pour ce type.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Choix de culture"), backgroundColor: Colors.green[700]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: selectedCultures.length,
          itemBuilder: (context, index) {
            final culture = selectedCultures[index];
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
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                        child: Image.asset(
                          culture["image"]!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          culture["nom"]!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
