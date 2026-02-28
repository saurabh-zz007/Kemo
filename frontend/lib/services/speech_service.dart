import 'package:speech_to_text/speech_to_text.dart'
    as stt;

class SpeechService {
  final stt.SpeechToText _speech =
      stt.SpeechToText();
  bool _isAvailable = false;

  Future<void> initialize(
    Function() onStopped,
  ) async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) {
        print('[SPEECH STATUS] $status');
        // If the engine shuts down unexpectedly, trigger the rescue callback
        if (status == 'notListening' ||
            status == 'done') {
          onStopped();
        }
      },
      onError: (errorNotification) => print(
        '[SPEECH ERROR] $errorNotification',
      ),
    );
  }

  Future<void> startListening(
    Function(String) onResult,
  ) async {
    if (_isAvailable) {
      await _speech.listen(
        onResult: (result) {
          // NO 'finalResult' CHECKS! Just send whatever words it hears instantly.
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
          stt.SpeechListenOptions(
            partialResults:
                true, // This is mandatory for the bypass
          );
        },

        pauseFor: const Duration(
          seconds: 2,
        ), // Shut off after 2 seconds of silence
      );
    } else {
      print("[FATAL] Microphone not available.");
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}
