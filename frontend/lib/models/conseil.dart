// Modèle de conseil ou résultat pour AgriAdvisor
class Conseil {
  String culture;
  String typeCulture;
  String status;
  int score;
  String message;
  List<String> varietes;
  List<dynamic> fournisseurs;
  List<String> recommandations;

  Conseil({required this.culture, required this.typeCulture, required this.status,
          required this.score, required this.message, required this.varietes,
          required this.fournisseurs, required this.recommandations});
}
