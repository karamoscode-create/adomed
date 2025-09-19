// lib/screens/call/call_screen.dart
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _microOn = true;
  bool _cameraOn = true;
  final Stopwatch _stopwatch = Stopwatch()..start();
  String _elapsed = '00:00';

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        final min =
            (_stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, '0');
        final sec =
            (_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
        _elapsed = '$min:$sec';
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.grey.shade900),
          ),
          Positioned(
            top: 64,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFF1E9BBA),
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dr. Bile Yao',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  _elapsed,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.small(
                  backgroundColor: Colors.white24,
                  child: Icon(
                    _microOn ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(() => _microOn = !_microOn),
                ),
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                FloatingActionButton.small(
                  backgroundColor: Colors.white24,
                  child: Icon(
                    _cameraOn ? Icons.videocam : Icons.videocam_off,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(() => _cameraOn = !_cameraOn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
