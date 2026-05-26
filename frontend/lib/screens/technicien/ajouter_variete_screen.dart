// lib/screens/technicien/ajouter_variete_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/technicien_provider.dart';

class AjouterVarieteScreen extends StatefulWidget {
  const AjouterVarieteScreen({Key? key}) : super(key: key);

  @override
  State<AjouterVarieteScreen> createState() => _AjouterVarieteScreenState();
}

class _AjouterVarieteScreenState extends State<AjouterVarieteScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _cultureController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _periodeSemisController =
      TextEditingController();
  final TextEditingController _cycleController = TextEditingController();
  final TextEditingController _rendementController =
      TextEditingController();
  final TextEditingController _prixController = TextEditingController();

  bool _isSubmitting = false;

  String _typeCulture = 'both';

  List<String> _zonesSelectionnees = [];

  final List<String> _typesCulture = [
    'plein_air',
    'serre',
    'both',
  ];

  final List<String> _zonesDisponibles = [
    'Nord',
    'Centre',
    'Sud',
    'Vallée du Fleuve',
    'Littoral',
    'Casamance',
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _cultureController.dispose();
    _descriptionController.dispose();
    _periodeSemisController.dispose();
    _cycleController.dispose();
    _rendementController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  // ==========================
  // AJOUTER VARIÉTÉ
  // ==========================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_zonesSelectionnees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une zone'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final Map<String, dynamic> varieteData = {
      "nom": _nomController.text.trim(),
      "culture": _cultureController.text.trim(),
      "description": _descriptionController.text.trim(),

      // IMPORTANT : correspond au backend
      "caracteristiques": {
        "typeCulture": _typeCulture,
        "zoneRecommandee": _zonesSelectionnees,
        "periodeSemis": _periodeSemisController.text.trim(),
        "cycleJours": int.tryParse(
              _cycleController.text.trim(),
            ) ??
            0,
        "rendementTonnesHa": double.tryParse(
              _rendementController.text.trim(),
            ) ??
            0,
      },

      "prixSemence": double.tryParse(
            _prixController.text.trim(),
          ) ??
          0,
    };

    final success = await Provider.of<TechnicienProvider>(
      context,
      listen: false,
    ).addVariete(varieteData);

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Variété ajoutée avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      _resetForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erreur lors de l’ajout de la variété',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================
  // RESET FORM
  // ==========================
  void _resetForm() {
    _formKey.currentState?.reset();

    _nomController.clear();
    _cultureController.clear();
    _descriptionController.clear();
    _periodeSemisController.clear();
    _cycleController.clear();
    _rendementController.clear();
    _prixController.clear();

    setState(() {
      _typeCulture = 'both';
      _zonesSelectionnees = [];
    });
  }

  // ==========================
  // BUILD
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        title: const Text(
          'Ajouter une variété',
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),

      body: _isSubmitting
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      '🌱 Informations générales',
                    ),

                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _nomController,
                      label: 'Nom de la variété',
                      icon: Icons.agriculture,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Champ obligatoire';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _cultureController,
                      label: 'Culture',
                      icon: Icons.eco,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Champ obligatoire';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      '📊 Caractéristiques techniques',
                    ),

                    const SizedBox(height: 12),

                    _buildDropdown(),

                    const SizedBox(height: 16),

                    _buildZonesSelector(),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _periodeSemisController,
                      label: 'Période de semis',
                      hint:
                          'Ex: Juin - Septembre',
                      icon: Icons.calendar_month,
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller:
                                _cycleController,
                            label:
                                'Cycle (jours)',
                            icon:
                                Icons.timer,
                            keyboardType:
                                TextInputType
                                    .number,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _buildTextField(
                            controller:
                                _rendementController,
                            label:
                                'Rendement (T/ha)',
                            icon: Icons
                                .bar_chart,
                            keyboardType:
                                const TextInputType
                                    .numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _prixController,
                      label:
                          'Prix semence (FCFA/kg)',
                      icon: Icons.money,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        onPressed:
                            _isSubmitting
                                ? null
                                : _submit,

                        icon: const Icon(
                          Icons.add_circle,
                        ),

                        label: Text(
                          _isSubmitting
                              ? 'Ajout en cours...'
                              : 'Ajouter la variété',
                        ),

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green[700],
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ==========================
  // TITRE SECTION
  // ==========================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ==========================
  // TEXT FIELD
  // ==========================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType =
        TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: Colors.green[700],
        ),
        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      validator: validator,
    );
  }

  // ==========================
  // DROPDOWN TYPE CULTURE
  // ==========================
  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _typeCulture,

      decoration: InputDecoration(
        labelText: 'Type de culture',
        prefixIcon: Icon(
          Icons.home_work,
          color: Colors.green[700],
        ),
        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      items: _typesCulture.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),

      onChanged: (value) {
        if (value != null) {
          setState(() {
            _typeCulture = value;
          });
        }
      },
    );
  }

  // ==========================
  // ZONES
  // ==========================
  Widget _buildZonesSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.green[700],
              ),
              const SizedBox(width: 8),
              const Text(
                'Zones recommandées',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,

            children:
                _zonesDisponibles.map((zone) {
              final selected =
                  _zonesSelectionnees
                      .contains(zone);

              return FilterChip(
                label: Text(zone),

                selected: selected,

                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _zonesSelectionnees
                          .add(zone);
                    } else {
                      _zonesSelectionnees
                          .remove(zone);
                    }
                  });
                },

                selectedColor:
                    Colors.green[100],
                checkmarkColor:
                    Colors.green[700],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}