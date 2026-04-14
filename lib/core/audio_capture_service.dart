import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioCaptureService {
  AudioCaptureService();

  final AudioRecorder _recorder = AudioRecorder();

  Future<bool> hasPermission({bool request = true}) {
    return _recorder.hasPermission(request: request);
  }

  Future<String> startRecording() async {
    final hasPermission = await _recorder.hasPermission();

    if (!hasPermission) {
      throw Exception('Nebyl udělen přístup k mikrofonu.');
    }

    final tempDir = await getTemporaryDirectory();
    final fileName = 'crying_${DateTime.now().millisecondsSinceEpoch}.wav';
    final filePath = p.join(tempDir.path, fileName);

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: filePath,
    );

    return filePath;
  }

  Future<String?> stopRecording() async {
    return _recorder.stop();
  }

  Future<void> cancelRecording() async {
    await _recorder.cancel();
  }

  Future<bool> isRecording() {
    return _recorder.isRecording();
  }

  Future<void> dispose() async {
    _recorder.dispose();
  }
}
