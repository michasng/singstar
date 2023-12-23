import 'dart:async';

import 'package:flutter/material.dart';
import 'package:singstar/components/audio/pitch_recorder.dart';

class GameRoute extends StatefulWidget {
  const GameRoute({super.key});

  @override
  State<GameRoute> createState() => _GameRouteState();
}

class _GameRouteState extends State<GameRoute> {
  final _recorder = PitchRecorder();
  StreamSubscription<PitchRecord>? _subscription;
  Pitch? _pitch;
  bool _isRecording = false;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (_isRecording) {
      await _stop();
    } else {
      await _start();
    }
  }

  Future<void> _start() async {
    final stream = await _recorder.start();
    final sub = stream.listen(
      (record) {
        setState(() {
          _pitch = record.pitch;
        });
      },
      onError: (dynamic e) {
        print(e);
      },
    );

    _subscription?.cancel();
    setState(() {
      _subscription = sub;
      _pitch = null;
      _isRecording = true;
    });
  }

  Future<void> _stop() async {
    await _recorder.stop();
    _subscription?.cancel();

    setState(() {
      _subscription = null;
      _pitch = null;
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          height: 400,
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _toggleRecord,
                    icon: Icon(_isRecording ? Icons.mic_off : Icons.mic),
                  ),
                  if (_isRecording)
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
              if (_pitch != null)
                Text(
                  '${_pitch!.noteName}${_pitch!.octave}',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
