import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  FlutterTts? _tts;
  bool _isInitialized = false;

  Future<void> _init() async {
    if (_isInitialized) return;
    try {
      _tts = FlutterTts();
      await _tts?.setLanguage('ar');
      await _tts?.setSpeechRate(0.42); // Yoqimli, tushunarli, sekinroq tezlik
      await _tts?.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS init xatosi: $e');
    }
  }

  Future<void> speak(String arabicText) async {
    try {
      await _init();
      if (_tts != null) {
        await _tts!.stop();
        await _tts!.speak(arabicText);
      }
    } catch (e) {
      debugPrint('TTS speak xatosi: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
