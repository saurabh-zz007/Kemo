import 'dart:async';

import 'package:flutter/material.dart';

class CustomLoadingIndicator
    extends StatefulWidget {
  final Color color;
  final Duration speed;

  const CustomLoadingIndicator({
    super.key,
    required this.color,
    required this.speed,
  });

  @override
  State<CustomLoadingIndicator> createState() =>
      _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState
    extends State<CustomLoadingIndicator> {
  final List<String> _frames = [
    '-',
    '\\',
    '|',
    '/',
    '-',
  ];
  int _currentFrame = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSpinning();
  }

  void _startSpinning() {
    _timer = Timer.periodic(widget.speed, (
      timer,
    ) {
      if (mounted) {
        setState(() {
          _currentFrame =
              (_currentFrame + 1) %
              _frames.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _frames[_currentFrame],
      style: TextStyle(
        color: widget.color,
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
