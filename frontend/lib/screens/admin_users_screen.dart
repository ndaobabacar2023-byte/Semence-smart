import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      var res = await ApiService.getUsers();

      setState(() {
        users = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
        ),
      );
    }
  }

  Future<void> validerTechnicien(String id) async {
    try {
      await ApiService.validerTechnicien(id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Technicien validé"),
        ),
      );

      fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
        ),
      );
    }
  }

  Future<void> supprimerUtilisateur(
      String id, int index) async {
    bool? confirmation = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text(
          "Voulez-vous supprimer cet utilisateur ?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      try {
        await ApiService.deleteUser(id);

        setState(() {
          users.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "🗑️ Utilisateur supprimé",
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion utilisateurs"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : users.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun utilisateur trouvé",
                  ),
                )
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var u = users[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          "${u['prenom']} ${u['nom']}",
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Rôle : ${u['role']}",
                            ),

                            if (u['statut'] != null)
                              Text(
                                "Statut : ${u['statut']}",
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // Validation technicien
                            if (u['role'] == 'technicien' &&
                                u['statut'] ==
                                    'en_attente')
                              ElevatedButton(
                                onPressed: () =>
                                    validerTechnicien(
                                  u['_id'],
                                ),
                                child:
                                    const Text("Valider"),
                              ),

                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  supprimerUtilisateur(
                                u['_id'],
                                index,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}