import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:window_manager/window_manager.dart';

class KemoSearchBar extends StatefulWidget {
  const KemoSearchBar({super.key});

  @override
  _KemoSearchBarState createState() =>
      _KemoSearchBarState();
}

class _KemoSearchBarState
    extends State<KemoSearchBar> {
  bool _isExpanded = false;
  bool _isLoading = false;
  bool _isProcessingCommand = false;
  List<Map<String, String>> _messages = [];
  final TextEditingController _controller =
      TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus &&
          !_isProcessingCommand) {
        _shrink();
      }
    });
  }

  void _expand() async {
    await windowManager.setSize(
      const Size(650, 650),
    );
    await windowManager.setAlignment(
      Alignment.topCenter,
    );

    setState(() {
      _isExpanded = true;
    });

    Future.delayed(
      const Duration(milliseconds: 400),
      () {
        _focusNode.requestFocus();
      },
    );
  }

  void _shrink() async {
    setState(() {
      _isExpanded = false;
    });
    _focusNode.unfocus();

    Future.delayed(
      const Duration(milliseconds: 500),
      () async {
        await windowManager.setSize(
          const Size(40, 50),
        );
        await windowManager.setAlignment(
          Alignment.topCenter,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitCommand(String command) async {
    if (command.trim().isEmpty) return;
    setState(() {
      _messages.add({
        "sender": "user",
        "text": command,
      });
      _isLoading = true;
      _controller.clear();
    });
    _focusNode.requestFocus();
    final url = Uri.parse(
      'http://127.0.0.1:8000/execute',
    );
    final payload = jsonEncode({
      'prompt': command,
    });
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: payload,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final kemoMessage =
            data['message'] ??
            "Task executed, but AI provided no message.";
        final status =
            data['status'] ?? "unknown";
        if (mounted) {
          setState(() {
            _messages.add({
              "sender": "kemo",
              "text": kemoMessage,
            });
            _isLoading = false;
          });
        }
        ;
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    _controller.clear();

    setState(() {
      _isExpanded = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: _expand,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: _isExpanded ? 600.0 : 60.0,
            height: _isExpanded ? 600.0 : 60.0,
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(
                10.0,
              ),
              border: Border.all(
                color: _isExpanded
                    ? Colors.cyan
                    : Colors.white24,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 15,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: _isExpanded
                ? _buildCommandCenter()
                : Icon(
                    Icons.auto_awesome,
                    color: Colors.cyan,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
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
          if (_messages.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  bool isUser =
                      msg["sender"] == "user";

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      isUser ? 30 : 0,
                      5,
                      isUser ? 0 : 30,
                      5,
                    ),
                    child: Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin:
                            const EdgeInsets.only(
                              bottom: 8,
                            ),
                        padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.cyan
                              : Colors.grey[800],
                          borderRadius:
                              BorderRadius.circular(
                                8,
                              ),
                          border: isUser
                              ? Border.all(
                                  color:
                                      Colors.cyan,
                                )
                              : null,
                        ),
                        child: Text(
                          msg["text"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily:
                                'Consolas',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: Colors.cyan,
              minHeight: 2,
            ),

          Padding(
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
                    controller: _controller,
                    focusNode: _focusNode,
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
                    onSubmitted: _submitCommand,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
