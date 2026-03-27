import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';

enum KemoState { resting, listening, expanded }

class KemoController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ApiService _apiService = Get.put(
    ApiService(),
  );
  // NEW

  // Reactive State

  final RxBool isLoading = false.obs;
  final RxList<Message> messages =
      <Message>[].obs;

  final TextEditingController textController =
      TextEditingController();
  final FocusNode focusNode = FocusNode();

  // Animation Engine
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  @override
  void onInit() {
    super.onInit();
    messages.add(
      Message(
        text: '''
  _  _________ __  __  ____  
 | |/ / ____|  \\/  |/ __ \\ 
 | ' /|  _| | \\  / | |  | |
 | . \\| |___| |\\/| | |__| |
 |_|\\_\\_____|_|  |_|\\____/ 
                           
 [ System Assistant v1.0.0 ]
''',
        sender: " ",
      ),
    );
  }

  // THE MASTER TRIGGER: This fires when pauseFor (2 seconds of silence) hits!

  Future<void> submitCommand(
    String command,
  ) async {
    if (command.trim().isEmpty) return;

    messages.add(
      Message(sender: "User", text: command),
    );
    isLoading.value = true;
    textController.clear();

    focusNode.requestFocus();

    final responseText = await _apiService
        .sendCommand(command);

    messages.add(
      Message(sender: "Kemo", text: responseText),
    );
    isLoading.value = false;
  }

  @override
  void onClose() {
    pulseController.dispose();
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
