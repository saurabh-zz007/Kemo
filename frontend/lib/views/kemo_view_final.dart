import 'package:flutter/material.dart';
import 'package:frontend/controllers/kemo_controller.dart';
import 'package:frontend/views/custom_loading_indicator.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class KemoViewFinal extends StatelessWidget {
  KemoViewFinal({super.key});

  final KemoController controller = Get.put(
    KemoController(),
  );
  final ScrollController scrollController =
      ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  controller: scrollController,
                  itemCount:
                      controller.messages.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              '${controller.messages[index].sender} > ',
                            ),
                            Expanded(
                              child: Text(
                                controller
                                    .messages[index]
                                    .text,
                                softWrap: true,
                                style: TextStyle(
                                  fontWeight:
                                      index == 0
                                      ? FontWeight
                                            .w900
                                      : FontWeight
                                            .normal,
                                  wordSpacing: 3,
                                  letterSpacing:
                                      2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.0),
                        if (index ==
                            controller
                                    .messages
                                    .length -
                                1)
                          controller
                                  .isLoading
                                  .value
                              ? Row(
                                  children: [
                                    Text(
                                      'Kemo > Thinking...   ',
                                    ),
                                    CustomLoadingIndicator(
                                      color: Colors
                                          .white,

                                      speed: Duration(
                                        milliseconds:
                                            100,
                                      ),
                                    ),
                                  ],
                                )
                              : _buildInputArea(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return TextField(
      onSubmitted: (value) {
        controller.submitCommand(value);
      },
      controller: controller.textController,
      decoration: const InputDecoration(
        prefixText: 'User > ',

        hintText: 'Tell Kemo what to do...',
        border: InputBorder.none,
      ),
    );
  }
}
