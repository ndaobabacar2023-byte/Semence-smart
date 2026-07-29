import 'package:flutter/material.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final data = notification["data"] ?? {};

    final String? technicienNom = data["technicienNom"];
    final String? technicienEmail = data["technicienEmail"];
    final String? technicienTelephone = data["technicienTelephone"];
    final String? commentaire = data["commentaire"];
    final varieteRecommandee = data["variete"];
    final recommandations = data["recommandations"];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text(
          "Détails de la notification",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Titre + message ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification["title"] ?? "",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    notification["message"] ?? "",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // ── Infos technicien ──────────────────────────────
            if (technicienNom != null && technicienNom.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "Technicien",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoCard([
                _infoRow(Icons.person_rounded, "Nom", technicienNom, Colors.blue),
                if (technicienEmail != null && technicienEmail.isNotEmpty)
                  _infoRow(Icons.email_rounded, "Email", technicienEmail, Colors.orange),
                if (technicienTelephone != null && technicienTelephone.isNotEmpty)
                  _infoRow(Icons.phone_rounded, "Téléphone", technicienTelephone, Colors.green),
              ]),
            ],

            // ── Commentaire de correction ─────────────────────
            if (commentaire != null && commentaire.toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "Commentaire du technicien",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Text(
                  commentaire.toString(),
                  style: TextStyle(fontSize: 14, color: Colors.blue[900]),
                ),
              ),
            ],

            // ── Variété recommandée après correction ──────────
            if (varieteRecommandee != null &&
                varieteRecommandee.toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "Variété recommandée",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.eco_rounded, color: primaryGreen, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      varieteRecommandee.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],

            // ── Recommandations ────────────────────────────────
            if (recommandations != null &&
                (recommandations is! List || recommandations.isNotEmpty)) ...[
              const SizedBox(height: 16),
              Text(
                "Recommandations",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: recommandations is List
                    ? Column(
                        children: List.generate(
                          recommandations.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: primaryGreen, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    recommandations[index].toString(),
                                    style: const TextStyle(fontSize: 13.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Text(recommandations.toString()),
              ),
            ],

            // ── Date ────────────────────────────────────────────
            if (notification["createdAt"] != null) ...[
              const SizedBox(height: 20),
              Text(
                "Date : ${notification["createdAt"]}",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}