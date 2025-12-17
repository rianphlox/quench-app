import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Play droplet sound when adding water
  static Future<void> playDropletSound() async {
    try {
      // Note: Sound files would need to be added to assets folder and pubspec.yaml
      // For now, we'll silently skip playing audio
      // await _audioPlayer.play(AssetSource('sounds/droplet.mp3'));
      debugPrint('💧 Water added sound');
    } catch (e) {
      debugPrint('Error playing droplet sound: $e');
    }
  }

  // Play success sound when goal is reached
  static Future<void> playSuccessSound() async {
    try {
      // Note: Sound files would need to be added to assets folder and pubspec.yaml
      // For now, we'll silently skip playing audio
      // await _audioPlayer.play(AssetSource('sounds/success.mp3'));
      debugPrint('🎉 Goal reached sound');
    } catch (e) {
      debugPrint('Error playing success sound: $e');
    }
  }

  // Dispose the audio player
  static Future<void> dispose() async {
    await _audioPlayer.dispose();
  }

  // Set volume (0.0 to 1.0)
  static Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }
}