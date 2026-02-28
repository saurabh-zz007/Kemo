import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../services/window_service.dart';
import '../services/speech_service.dart'; // NEW

enum KemoState { resting, listening, expanded }

class KemoController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final WindowService _windowService = Get.put(
    WindowService(),
  );
  final ApiService _apiService = Get.put(
    ApiService(),
  );
  final SpeechService _speechService = Get.put(
    SpeechService(),
  ); // NEW

  // Reactive State
  final Rx<KemoState> currentState =
      KemoState.resting.obs;
  final RxBool isLoading = false.obs;
  final RxList<Message> messages =
      <Message>[].obs;

  bool _isProcessingCommand = false;

  final TextEditingController textController =
      TextEditingController();
  final FocusNode focusNode = FocusNode();

  // Animation Engine
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  @override
  void onInit() {
    super.onInit();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    pulseAnimation =
        Tween<double>(
          begin: 1.0,
          end: 1.3,
        ).animate(
          CurvedAnimation(
            parent: pulseController,
            curve: Curves.easeInOut,
          ),
        );

    // THE MASTER TRIGGER: This fires when pauseFor (2 seconds of silence) hits!
    _speechService.initialize(() {
      if (currentState.value ==
          KemoState.listening) {
        if (textController.text
            .trim()
            .isNotEmpty) {
          print(
            '[KEMO] Silence detected. Submitting: ${textController.text}',
          );
          _stopListeningAndExpand();
          submitCommand(textController.text);
        } else {
          print(
            '[KEMO] Nothing heard. Going back to sleep.',
          );
          shrinkToResting();
        }
      }
    });

    focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!focusNode.hasFocus &&
        !_isProcessingCommand &&
        currentState.value ==
            KemoState.expanded) {
      shrinkToResting();
    }
  }

  // --- STATE CYCLER ---
  void handleTap() {
    if (currentState.value == KemoState.resting) {
      _startListening();
    } else if (currentState.value ==
        KemoState.listening) {
      _stopListeningAndExpand();
    }
  }

  Future<void> _startListening() async {
    print('[KEMO] Waking up UI...');
    await _windowService.resizeForListening();
    currentState.value = KemoState.listening;
    textController.clear();

    await _speechService.startListening((
      recognizedText,
    ) {
      // SILENT COLLECTION: Just keep updating the buffer as the user talks
      print('[KEMO HEARD]: $recognizedText');
      textController.text = recognizedText;
    });
  }

  Future<void> _stopListeningAndExpand() async {
    // 1. THE FIX: Change state FIRST to lock out the rescue callback!
    currentState.value = KemoState.expanded;

    // 2. Safely stop the microphone
    await _speechService.stopListening();

    // 3. Expand the OS window to fit the chat box
    await _windowService.expandWindow(
      hasMessages: messages.isNotEmpty,
    );

    // 4. Put the blinking cursor in the text field
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        focusNode.requestFocus();
      },
    );
  }

  Future<void> shrinkToResting() async {
    await _speechService.stopListening();
    currentState.value = KemoState.resting;
    focusNode.unfocus();

    Future.delayed(
      const Duration(milliseconds: 300),
      () async {
        await _windowService.shrinkWindow();
      },
    );
  }

  Future<void> submitCommand(
    String command,
  ) async {
    if (command.trim().isEmpty) return;

    messages.add(
      Message(sender: "user", text: command),
    );
    isLoading.value = true;
    _isProcessingCommand = true;
    textController.clear();

    // Immediately ensure the window expands if typing from Resting state
    if (currentState.value !=
        KemoState.expanded) {
      await _windowService.expandWindow(
        hasMessages: true,
      );
      currentState.value = KemoState.expanded;
    }

    focusNode.requestFocus();

    final responseText = await _apiService
        .sendCommand(command);

    messages.add(
      Message(sender: "kemo", text: responseText),
    );
    isLoading.value = false;

    // Optional: Auto-shrink after reading, or keep open for conversation
    await Future.delayed(
      const Duration(seconds: 3),
    );
    _isProcessingCommand = false;
    shrinkToResting();
  }

  @override
  void onClose() {
    pulseController.dispose();
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
