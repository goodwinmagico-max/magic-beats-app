import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MagicBeatsApp());
}

class MagicBeatsApp extends StatelessWidget {
  const MagicBeatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Beats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _bpm = 130;
  bool _isCountdown = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _hasResult = false;
  int _countdownValue = 3;
  int _recordProgress = 0;
  Timer? _timer;

  void _startFlow() {
    if (_isCountdown || _isRecording || _isProcessing) return;

    setState(() {
      _isCountdown = true;
      _countdownValue = 3;
      _hasResult = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 1) {
        setState(() => _countdownValue--);
      } else {
        timer.cancel();
        _startRecording();
      }
    });
  }

  void _startRecording() {
    setState(() {
      _isCountdown = false;
      _isRecording = true;
      _recordProgress = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_recordProgress < 5) {
        setState(() => _recordProgress++);
      } else {
        timer.cancel();
        _processBeat();
      }
    });
  }

  void _processBeat() {
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
        _hasResult = true;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'MAGIC BEATS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: Color(0xFFF5D061),
              ),
            ),
            const SizedBox(height: 20),

            // BPM Slider
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Text(
                    '${_bpm.toInt()} BPM',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: _bpm,
                    min: 100,
                    max: 160,
                    divisions: 12,
                    activeColor: const Color(0xFFF5D061),
                    onChanged: (val) => setState(() => _bpm = val),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // REC Button & States
            GestureDetector(
              onTap: _startFlow,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF333333), Color(0xFF111111)],
                  ),
                  border: Border.all(
                    color: _isRecording ? Colors.red : const Color(0xFFF5D061),
                    width: 6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? Colors.red : const Color(0xFFF5D061)).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Center(
                  child: _buildButtonContent(),
                ),
              ),
            ),

            const Spacer(),

            // Result Panel
            if (_hasResult)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.music_note, color: Color(0xFFF5D061), size: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Last Beat', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Magic_Beat_001.wav', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (_isCountdown) {
      return Text(
        '$_countdownValue',
        style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Color(0xFFF5D061)),
      );
    }
    if (_isRecording) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fiber_manual_record, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text('REC (${5 - _recordProgress}s)', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      );
    }
    if (_isProcessing) {
      return const CircularProgressIndicator(color: Color(0xFFF5D061));
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'REC',
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.redAccent, letterSpacing: 2),
        ),
        SizedBox(height: 4),
        Text('TAP TO START', style: TextStyle(fontSize: 12, color: Colors.white54)),
      ],
    );
  }
}
