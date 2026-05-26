import 'package:flutter/material.dart';

class AjouterCultureScreen extends StatefulWidget {
  final String type;
  const AjouterCultureScreen({required this.type, super.key});

  @override
  State<AjouterCultureScreen> createState() => _AjouterCultureScreenState();
}

class _AjouterCultureScreenState extends State<AjouterCultureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedEmoji = "🌱";
  
  final List<String> _emojis = [
    "🌱", "🌾", "🍅", "🫑", "🌶️", "🥬", "🧅", "🍆", "🥕", "🥔", 
    "🥒", "🍉", "🍈", "🍓", "🍊", "🍋", "🥥", "🌽", "🥦", "🧄"
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text(
          "Ajouter une culture",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Nouvelle culture personnalisée",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Cette culture ne sera visible que par vous",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Type de culture (info)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.type == "serre" ? Icons.agriculture : Icons.landscape,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Type: ${widget.type == "serre" ? "Sous serre" : "Plein air"}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Nom de la culture
                    const Text(
                      "Nom de la culture *",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nomController,
                      decoration: InputDecoration(
                        hintText: "Ex: Concombre, Haricot, etc.",
                        prefixIcon: const Icon(Icons.eco),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        if (value.length < 2) {
                          return 'Nom trop court';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Emoji
                    const Text(
                      "Icône / Emoji",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _emojis.map((emoji) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedEmoji = emoji;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _selectedEmoji == emoji
                                      ? Colors.green[100]
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedEmoji == emoji
                                        ? Colors.green[700]!
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Cliquez sur un emoji pour le sélectionner",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    const Text(
                      "Description (optionnelle)",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Ex: Culture résistante à la chaleur, cycle 60 jours...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text("Annuler"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context, {
                                  'nom': _nomController.text.trim(),
                                  'emoji': _selectedEmoji,
                                  'description': _descriptionController.text.trim().isEmpty
                                      ? 'Culture personnalisée (${widget.type == "serre" ? "sous serre" : "plein air"})'
                                      : _descriptionController.text.trim(),
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text("Ajouter"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}