// lib/screens/technicien/selection_agriculteur_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../type_culture_screen.dart';

class SelectionAgriculteurScreen extends StatefulWidget {
  const SelectionAgriculteurScreen({super.key});

  @override
  State<SelectionAgriculteurScreen> createState() =>
      _SelectionAgriculteurScreenState();
}

class _SelectionAgriculteurScreenState
    extends State<SelectionAgriculteurScreen> {
  List _agriculteurs = [];
  List _filtered = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _loadAgriculteurs();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAgriculteurs() async {
    try {
      final users = await ApiService.getUsers();
      final agriculteurs = users.where((u) => u['role'] == 'agriculteur').toList();
      setState(() {
        _agriculteurs = agriculteurs;
        _filtered = agriculteurs;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _agriculteurs
          : _agriculteurs.where((u) {
              final nom = "${u['prenom']} ${u['nom']}".toLowerCase();
              final tel = (u['telephone'] ?? '').toString().toLowerCase();
              return nom.contains(q) || tel.contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text(
          "Analyse pour un agriculteur",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Rechercher un agriculteur...",
                  prefixIcon: Icon(Icons.search, color: primaryGreen),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: primaryGreen))
                : _filtered.isEmpty
                    ? Center(
                        child: Text(
                          "Aucun agriculteur trouvé",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final u = _filtered[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
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
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              leading: CircleAvatar(
                                backgroundColor: primaryGreen.withOpacity(0.12),
                                child: Icon(Icons.person, color: primaryGreen),
                              ),
                              title: Text(
                                "${u['prenom']} ${u['nom']}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(u['telephone'] ?? 'Pas de téléphone'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TypeCultureScreen(
                                      agriculteurId: u['_id'],
                                      agriculteurNom:
                                          "${u['prenom']} ${u['nom']}",
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}