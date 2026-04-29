import 'package:flutter/material.dart';
import '../services/historique_service.dart';
import 'resultat_screen.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({Key? key}) : super(key: key);

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  List<Map<String, dynamic>> _analyses = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    setState(() {
      _isLoading = true;
    });
    
    final analyses = await HistoriqueService.getAllAnalyses();
    
    setState(() {
      _analyses = analyses;
      _isLoading = false;
    });
  }

  Future<void> _deleteAnalyse(String id) async {
    await HistoriqueService.deleteAnalyse(id);
    _loadHistorique();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analyse supprimée'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _deleteSelectedAnalyses() async {
    for (String id in _selectedIds) {
      await HistoriqueService.deleteAnalyse(id);
    }
    
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
    
    _loadHistorique();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedIds.length} analyse(s) supprimée(s)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _clearAllAnalyses() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer tout'),
        content: const Text('Voulez-vous vraiment supprimer tout l\'historique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await HistoriqueService.clearAllAnalyses();
      _loadHistorique();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tout l\'historique a été supprimé'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          _isSelectionMode ? '${_selectedIds.length} sélectionnée(s)' : 'Historique des analyses',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(_isSelectionMode ? Icons.close : Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isSelectionMode) {
              setState(() {
                _isSelectionMode = false;
                _selectedIds.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (!_isLoading && _analyses.isNotEmpty)
            if (!_isSelectionMode)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'clear_all') {
                    _clearAllAnalyses();
                  } else if (value == 'select_mode') {
                    setState(() {
                      _isSelectionMode = true;
                    });
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'select_mode',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Sélectionner'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Tout supprimer'),
                      ],
                    ),
                  ),
                ],
              ),
          if (_isSelectionMode && _selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteSelectedAnalyses,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : _analyses.isEmpty
              ? _buildEmptyState()
              : _buildHistoriqueList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun historique',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les analyses que vous effectuerez\napparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Faire une analyse'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoriqueList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _analyses.length,
      itemBuilder: (context, index) {
        final analyse = _analyses[index];
        final id = analyse['id'] ?? index.toString();
        final score = analyse['score'] ?? 0;
        final culture = analyse['culture'] ?? 'Culture';
        final typeCulture = analyse['typeCulture'] ?? 'Type';
        final date = analyse['date'] ?? DateTime.now().toIso8601String();
        final isSelected = _selectedIds.contains(id);
        
        return GestureDetector(
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (isSelected) {
                  _selectedIds.remove(id);
                  if (_selectedIds.isEmpty) {
                    _isSelectionMode = false;
                  }
                } else {
                  _selectedIds.add(id);
                }
              });
            } else {
              // Voir le détail de l'analyse
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultatScreen(result: analyse),
                ),
              );
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                _selectedIds.add(id);
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green[50] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.green[400]! : Colors.green[100]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Checkbox en mode sélection
                  if (_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedIds.add(id);
                            } else {
                              _selectedIds.remove(id);
                              if (_selectedIds.isEmpty) {
                                _isSelectionMode = false;
                              }
                            }
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ),
                  
                  // Score
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          HistoriqueService.getScoreColor(score),
                          HistoriqueService.getScoreColor(score).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$score%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Informations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          culture,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          typeCulture,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              HistoriqueService.formatDate(date),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Statut
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: HistoriqueService.getScoreColor(score).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          HistoriqueService.getStatusIcon(score),
                          size: 14,
                          color: HistoriqueService.getScoreColor(score),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          HistoriqueService.getStatusText(score),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: HistoriqueService.getScoreColor(score),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Flèche (hors mode sélection)
                  if (!_isSelectionMode)
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultatScreen(result: analyse),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}