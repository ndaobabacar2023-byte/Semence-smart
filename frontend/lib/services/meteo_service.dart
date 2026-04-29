import 'dart:convert';
import 'package:http/http.dart' as http;

class MeteoService {
  static const String _apiKey = '0555ea7bfd60c37ce6a7bdef9879939a';
  
  // 🌤️ Récupérer la météo par nom de ville
  static Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?'
          'q=$cityName&appid=$_apiKey&units=metric&lang=fr'
        ),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        
        return {
          'success': true,
          'data': {
            'temperature': data['main']['temp'].round(),
            'ressenti': data['main']['feels_like'].round(),
            'humidite': data['main']['humidity'],
            'vent': data['wind']['speed'].toStringAsFixed(1),
            'description': data['weather'][0]['description'],
            'icone': data['weather'][0]['icon'],
            'ville': data['name'],
            'pays': data['sys']['country'],
            'lever_soleil': DateTime.fromMillisecondsSinceEpoch(
              data['sys']['sunrise'] * 1000
            ),
            'coucher_soleil': DateTime.fromMillisecondsSinceEpoch(
              data['sys']['sunset'] * 1000
            ),
          }
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Ville non trouvée. Vérifiez le nom.'
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur API: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur: $e'
      };
    }
  }
}