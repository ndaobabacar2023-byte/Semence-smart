import 'package:flutter/material.dart';

class ResultatScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  ResultatScreen({required this.result});

  Color getColor(String status) {
    if (status == "bon") return Colors.green;
    if (status == "moyen") return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final variete = result['variete'];
    final fournisseurs = result['fournisseurs'] as List<dynamic>? ?? [];
    final recommandations = result['recommandations'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(title: Text("Résultat"), backgroundColor: Colors.green[700]),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            ..._buildCard("Culture", "${result['culture']} (${result['typeCulture']})", Icons.agriculture, Colors.green[700]!),
            SizedBox(height: 10),
            ..._buildCard("Status", "${result['status']} - Score: ${result['score']}", Icons.speed, getColor(result['status'])),
            SizedBox(height: 10),
            if (variete != null)
              ..._buildCard("Variété recommandée", "${variete['nom']} - ${variete['description'] ?? ''}", Icons.local_florist, Colors.green),
            SizedBox(height: 10),
            ..._buildFournisseursCard(fournisseurs),
            SizedBox(height: 10),
            ..._buildRecommandationsCard(recommandations),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text("Nouvelle analyse", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCard(String title, String subtitle, IconData icon, Color color) {
    return [
      Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
        ),
      )
    ];
  }

  List<Widget> _buildFournisseursCard(List<dynamic> fournisseurs) {
    return [
      Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Fournisseurs:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...fournisseurs.map((f) => ListTile(
                leading: Icon(Icons.store, color: Colors.orange[700]),
                title: Text(f['nom']),
                subtitle: Text("${(f['zones'] as List).join(', ')} - ${f['contact']['telephone']}"),
              )),
            ],
          ),
        ),
      )
    ];
  }

  List<Widget> _buildRecommandationsCard(List<dynamic> recommandations) {
    return [
      Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Recommandations:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...recommandations.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("- $r"),
              )),
            ],
          ),
        ),
      )
    ];
  }
}
