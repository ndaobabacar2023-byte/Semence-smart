class WolofMessageGenerator {
  static String generateAnalysisMessage({
    required String culture,
    required int score,
    required String message,
    required List<String> recommandations,
    String? typeCulture,
  }) {
    final StringBuffer buffer = StringBuffer();
    
    buffer.write('Assalaam maalekum. ');
    buffer.write('Nga xayma $culture. ');
    
    if (typeCulture == 'serre') {
      buffer.write('Ci serre bi. ');
    } else if (typeCulture == 'plein_air') {
      buffer.write('Ci biir. ');
    }
    
    buffer.write('Xaaj wi nekk $score pourcent. ');
    
    if (score >= 80) {
      buffer.write('Baax na lool! Téggal sa yoonu bi. ');
    } else if (score >= 60) {
      buffer.write('Baax na! Waaye man nga naf. ');
    } else if (score >= 40) {
      buffer.write('Noow na. Jaaxa sa yoon bi. ');
    } else {
      buffer.write('Begg na! Xool nosaay yi. ');
    }
    
    if (recommandations.isNotEmpty) {
      buffer.write('Yi la nosaay yi: ');
      for (int i = 0; i < recommandations.length && i < 3; i++) {
        buffer.write('${i + 1}. ${recommandations[i]}. ');
      }
    }
    
    buffer.write('Yalla may jàmm ci sa loxo. Jërëjëf.');
    
    return buffer.toString();
  }
}