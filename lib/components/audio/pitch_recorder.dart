import 'dart:math';
import 'dart:typed_data';

import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:record/record.dart';
import 'package:singstar/components/audio/no_permission_exception.dart';

class PitchRecord {
  final Pitch? pitch;

  const PitchRecord({
    required this.pitch,
  });
}

List<String> noteNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

class Pitch {
  final double hertz;
  final double probability;

  const Pitch({
    required this.hertz,
    required this.probability,
  });

  int get midiNote {
    return (69 + 12 * (log(hertz / 440) / ln2)).round();
  }

  String get noteName {
    int noteIndex = midiNote % 12;
    return noteNames[noteIndex];
  }

  int get octave {
    return (midiNote ~/ 12) - 1; // MIDI octave starts from -1
  }
}

class PitchRecorder {
  final _audioRecorder = AudioRecorder();
  final _pitchDetector = PitchDetector(44100, 2000);

  PitchRecorder();

  Future<void> requestPermission() async {
    final granted = await _audioRecorder.hasPermission();
    if (!granted) {
      throw NoPermissionException('No permission to record audio');
    }
  }

  Future<Stream<PitchRecord>> start() async {
    await requestPermission();

    final stream = await _audioRecorder.startStream(
      const RecordConfig(encoder: AudioEncoder.pcm16bits),
    );
    return stream.map((byte) {
      final audioSample = _normalizeBytes(byte);
      final pitchDetectorResult = _pitchDetector.getPitch(audioSample);

      if (!pitchDetectorResult.pitched) {
        return const PitchRecord(pitch: null);
      }

      return PitchRecord(
        pitch: Pitch(
          hertz: pitchDetectorResult.pitch,
          probability: pitchDetectorResult.probability,
        ),
      );
    });
  }

  /// Combines 8 bit pairs (2 bytes) to 16 bit.
  /// Returns these 16 bit normalized to [-1.0, 1.0].
  List<double> _normalizeBytes(Uint8List uint8List) {
    if (uint8List.length % 2 != 0) {
      throw ArgumentError('Input Uint8List length must be even.');
    }

    return [
      for (int i = 0; i < uint8List.length; i += 2)
        (uint8List[i] | (uint8List[i + 1] << 8)) / 32768.0,
    ];
  }

  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  Future<bool> isPaused() async {
    return await _audioRecorder.isPaused();
  }

  Future<void> pause() async {
    await _audioRecorder.pause();
  }

  Future<void> resume() async {
    await _audioRecorder.resume();
  }

  Future<void> stop() async {
    await _audioRecorder.stop();
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}
