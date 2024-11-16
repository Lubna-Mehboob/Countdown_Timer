import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // For playing sound

class CountdownTimerScreen extends StatefulWidget {
  @override
  _CountdownTimerScreenState createState() => _CountdownTimerScreenState();
}

class _CountdownTimerScreenState extends State<CountdownTimerScreen> {
  Timer? _timer;
  Duration _timeRemaining = Duration(minutes: 1); // Default time (1 minute)
  Duration _initialTime = Duration(minutes: 1);
  bool _isRunning = false;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize audio player

  // Start Timer
  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {
        if (_timeRemaining.inMilliseconds > 0) {
          _timeRemaining = _timeRemaining - Duration(milliseconds: 10);
        } else {
          _stopTimer();
          _playCompletionSound(); // Play sound when timer completes
        }
      });
    });
  }

  // Play sound when timer ends
  void _playCompletionSound() {
    _audioPlayer.play(AssetSource('assets/sounds/timer_end.mp3'));
  }

  // Stop Timer
  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _isRunning = false;
    });
  }

  // Reset Timer
  void _resetTimer() {
    _stopTimer();
    setState(() {
      _timeRemaining = _initialTime;
    });
  }

  // Set the initial countdown duration
  void _setTime(Duration time) {
    setState(() {
      _initialTime = time;
      _timeRemaining = time;
    });
  }

  // Format Duration to HH:MM:SS:MS (with two-digit milliseconds)
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds =
        twoDigits((duration.inMilliseconds.remainder(1000)) ~/ 10);
    return "$hours:$minutes:$seconds:$milliseconds";
  }

  // Show Time Picker for User to Set Time
  Future<void> _pickTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _initialTime.inHours,
        minute: _initialTime.inMinutes.remainder(60),
      ),
    );

    if (pickedTime != null) {
      Duration selectedDuration =
          Duration(hours: pickedTime.hour, minutes: pickedTime.minute);
      _setTime(selectedDuration);
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer when the widget is disposed
    _audioPlayer.dispose(); // Dispose audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Countdown Timer',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(_timeRemaining),
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isRunning ? null : () => _pickTime(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Set Time'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _isRunning ? _stopTimer : _startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isRunning ? Colors.redAccent : Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(_isRunning ? 'Stop' : 'Start'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _resetTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Time Remaining Progress',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(5),
                value:
                    _timeRemaining.inMicroseconds / _initialTime.inMicroseconds,
                backgroundColor: Colors.white30,
                color: Colors.deepPurpleAccent,
                minHeight: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
