import 'package:flutter/material.dart';
import '../services/wolof_tts_service.dart';

class VoiceButton extends StatefulWidget {
  final String textToSpeak;
  final double size;
  final Color? color;
  
  const VoiceButton({
    Key? key,
    required this.textToSpeak,
    this.size = 48,
    this.color,
  }) : super(key: key);

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  final WolofTTSService _tts = WolofTTSService();
  bool _isPlaying = false;
  bool _isLoading = false;

  Future<void> _speak() async {
    setState(() {
      _isLoading = true;
    });
    
    final success = await _tts.speak(widget.textToSpeak);
    
    setState(() {
      _isLoading = false;
      _isPlaying = success;
    });
    
    // Vérifier périodiquement si la lecture est terminée
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_tts.isPlaying) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  Future<void> _stop() async {
    await _tts.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isPlaying ? _stop : _speak,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          gradient: _isPlaying
              ? LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[600]!],
                )
              : LinearGradient(
                  colors: [
                    widget.color ?? Colors.green[500]!,
                    widget.color ?? Colors.green[700]!,
                  ],
                ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isPlaying ? Colors.red : Colors.green).withOpacity(0.3),
              blurRadius: _isPlaying ? 12 : 8,
              spreadRadius: _isPlaying ? 2 : 1,
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  _isPlaying ? Icons.stop : Icons.volume_up,
                  color: Colors.white,
                  size: widget.size * 0.45,
                ),
        ),
      ),
    );
  }
}