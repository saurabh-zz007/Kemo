import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kemo_controller.dart';
import '../models/message_model.dart';

class KemoView extends StatelessWidget {
  KemoView({super.key});

  final KemoController controller = Get.put(
    KemoController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
          ), // Keeps it off the absolute top edge
          child: Obx(() {
            // Dynamically calculate sizes based on GetX state
            double currentWidth =
                controller.currentState.value ==
                    KemoState.expanded
                ? 650.0
                : controller.currentState.value ==
                      KemoState.listening
                ? 120.0
                : 80.0;

            double currentHeight =
                controller.currentState.value ==
                    KemoState.expanded
                ? (controller.messages.isNotEmpty
                      ? 350.0
                      : 120.0)
                : 80.0;

            return GestureDetector(
              onTap: controller.handleTap,
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 300,
                ),
                curve: Curves.easeOutCubic,
                width: currentWidth,
                height: currentHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(
                    controller
                                    .currentState
                                    .value ==
                                KemoState
                                    .expanded &&
                            controller
                                .messages
                                .isNotEmpty
                        ? 15.0
                        : 30.0,
                  ),
                  border: Border.all(
                    color:
                        controller
                                .currentState
                                .value ==
                            KemoState.listening
                        ? Colors.cyanAccent
                        : controller
                                  .currentState
                                  .value ==
                              KemoState.expanded
                        ? Colors.cyan
                        : Colors.white24,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          controller
                                  .currentState
                                  .value ==
                              KemoState.listening
                          ? Colors.cyanAccent
                                .withOpacity(0.5)
                          : Colors.black54,
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child:
                    _buildUIState(), // Delegate the interior
              ),
            );
          }),
        ),
      ),
    );
  }

  // Add this helper function below the build method!
  Widget _buildUIState() {
    switch (controller.currentState.value) {
      case KemoState.resting:
        return const Icon(
          Icons.circle_outlined,
          color: Colors.white54,
          size: 30,
        );

      case KemoState.listening:
        return ScaleTransition(
          scale: controller.pulseAnimation,
          child: const Icon(
            Icons.blur_on,
            color: Colors.cyanAccent,
            size: 35,
          ),
        );

      case KemoState.expanded:
        return _buildCommandCenter();
    }
  }

  Widget _buildCommandCenter() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18.0,
        vertical: 8,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Chat History
          if (controller.messages.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount:
                    controller.messages.length,
                itemBuilder: (context, index) {
                  return _buildChatBubble(
                    controller.messages[index],
                  );
                },
              ),
            ),

          // Loading Bar
          if (controller.isLoading.value)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: Colors.cyan,
              minHeight: 2,
            ),

          // Input Field
          _buildInputBar(),
        ],
      ),
    );
  }

  // --- Sub-Widgets (Keeps the tree clean) ---

  Widget _buildChatBubble(Message msg) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        msg.isUser ? 30 : 0,
        5,
        msg.isUser ? 0 : 30,
        5,
      ),
      child: Align(
        alignment: msg.isUser
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(
            bottom: 8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: msg.isUser
                ? Colors.cyan
                : Colors.grey[800],
            borderRadius: BorderRadius.circular(
              8,
            ),
            border: msg.isUser
                ? Border.all(color: Colors.cyan)
                : null,
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Consolas',
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Row(
        children: [
          const Text(
            ">",
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 20,
              fontFamily: 'Consolas',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller:
                  controller.textController,
              focusNode: controller.focusNode,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Consolas',
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText:
                    "Tell KEMO to execute a task...",
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                ),
                border: InputBorder.none,
              ),
              onSubmitted:
                  controller.submitCommand,
            ),
          ),
        ],
      ),
    );
  }
}
