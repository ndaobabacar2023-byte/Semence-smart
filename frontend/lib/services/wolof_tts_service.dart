import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class WolofTTSService {
  static const String _baseUrl = 'http://localhost:8000';
  
  bool _isPlaying = false;
  html.AudioElement? _audioElement;
  Function(bool)? onPlaybackStateChanged;
  
  Future<bool> speak(String wolofText) async {
    print('🎤 Lecture...');
    
    if (_isPlaying) await stop();
    
    _isPlaying = true;
    if (onPlaybackStateChanged != null) onPlaybackStateChanged!(_isPlaying);
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tts/wolof'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': wolofText}),
      ).timeout(const Duration(seconds: 90));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['audio_base64'] != null) {
          // Créer l'élément audio
          _audioElement = html.AudioElement();
          
          // Convertir base64 en Blob URL
          final blob = html.Blob(
            [base64Decode(data['audio_base64'])],
            'audio/wav'
          );
          final url = html.Url.createObjectUrlFromBlob(blob);
          
          _audioElement!.src = url;
          _audioElement!.autoplay = true;
          
          // Forcer la lecture
          await _audioElement!.play();
          
          _audioElement!.onEnded.listen((_) {
            html.Url.revokeObjectUrl(url);
            print('✅ Lecture terminée');
            _isPlaying = false;
            if (onPlaybackStateChanged != null) onPlaybackStateChanged!(_isPlaying);
          });
          
          _audioElement!.onError.listen((e) {
            print('❌ Erreur: $e');
            html.Url.revokeObjectUrl(url);
            _isPlaying = false;
            if (onPlaybackStateChanged != null) onPlaybackStateChanged!(_isPlaying);
          });
          
          print('🔊 Lecture en cours...');
          return true;
        }
      }
      
      _isPlaying = false;
      if (onPlaybackStateChanged != null) onPlaybackStateChanged!(_isPlaying);
      return false;
    } catch (e) {
      print('❌ Erreur: $e');
      _isPlaying = false;
      if (onPlaybackStateChanged != null) onPlaybackStateChanged!(_isPlaying);
      return false;
    }
  }
  
  Future<void> stop() async {
    if (_audioElement != null) {
      _audioElement!.pause();
      _audioElement = null;
    }
    _isPlaying = false;
    if (onPlaybackStateChanged != null) onPlaybackStateChanged!(_isPlaying);
  }
  
  bool get isPlaying => _isPlaying;
  void dispose() { stop(); }
}