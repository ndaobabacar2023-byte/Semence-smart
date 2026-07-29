import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  int totalUsers = 0;
  int agriculteurs = 0;
  int techniciens = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    var users = await ApiService.getUsers();

    setState(() {
      totalUsers = users.length;
      agriculteurs = users.where((u) => u['role'] == 'agriculteur').length;
      techniciens = users.where((u) => u['role'] == 'technicien').length;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistiques")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCard("Total utilisateurs", totalUsers),
                  _buildCard("Agriculteurs", agriculteurs),
                  _buildCard("Techniciens", techniciens),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(String title, int value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}