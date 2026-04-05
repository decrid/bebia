import 'dart:io';
import 'dart:typed_data';

import 'audio_preprocessing_result.dart';
import 'wav_audio_features.dart';

class AudioPreprocessingService {
  const AudioPreprocessingService();

  Future<AudioPreprocessingResult> prepare(String? audioSamplePath) async {
    if (audioSamplePath == null || audioSamplePath.trim().isEmpty) {
      return const AudioPreprocessingResult(
        filePath: null,
        fileExists: false,
        fileSizeBytes: 0,
        hasUsableAudio: false,
        features: null,
      );
    }

    final file = File(audioSamplePath);

    final exists = await file.exists();
    if (!exists) {
      return AudioPreprocessingResult(
        filePath: audioSamplePath,
        fileExists: false,
        fileSizeBytes: 0,
        hasUsableAudio: false,
        features: null,
      );
    }

    final bytes = await file.readAsBytes();
    final fileSizeBytes = bytes.length;

    final features = _extractWavFeatures(bytes);
    final hasUsableAudio =
        fileSizeBytes >= 1024 &&
        features != null &&
        features.sampleCount > 0 &&
        features.durationMs >= 300;

    return AudioPreprocessingResult(
      filePath: audioSamplePath,
      fileExists: true,
      fileSizeBytes: fileSizeBytes,
      hasUsableAudio: hasUsableAudio,
      features: features,
    );
  }

  WavAudioFeatures? _extractWavFeatures(Uint8List bytes) {
    if (bytes.length < 44) return null;

    final riff = String.fromCharCodes(bytes.sublist(0, 4));
    final wave = String.fromCharCodes(bytes.sublist(8, 12));
    if (riff != 'RIFF' || wave != 'WAVE') return null;

    final byteData = ByteData.sublistView(bytes);

    int? channelCount;
    int? sampleRate;
    int? bitsPerSample;
    Uint8List? pcmData;

    var offset = 12;
    while (offset + 8 <= bytes.length) {
      final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final chunkSize = byteData.getUint32(offset + 4, Endian.little);
      final chunkDataStart = offset + 8;
      final chunkDataEnd = chunkDataStart + chunkSize;

      if (chunkDataEnd > bytes.length) {
        return null;
      }

      if (chunkId == 'fmt ' && chunkSize >= 16) {
        channelCount = byteData.getUint16(chunkDataStart + 2, Endian.little);
        sampleRate = byteData.getUint32(chunkDataStart + 4, Endian.little);
        bitsPerSample = byteData.getUint16(chunkDataStart + 14, Endian.little);
      } else if (chunkId == 'data') {
        pcmData = bytes.sublist(chunkDataStart, chunkDataEnd);
      }

      offset = chunkDataEnd + (chunkSize.isOdd ? 1 : 0);
    }

    if (channelCount == null ||
        sampleRate == null ||
        bitsPerSample == null ||
        pcmData == null) {
      return null;
    }

    if (bitsPerSample != 16 || channelCount != 1) {
      return null;
    }

    if (pcmData.length < 2) return null;

    final sampleCount = pcmData.length ~/ 2;
    final pcmByteData = ByteData.sublistView(pcmData);

    var sumSquares = 0.0;
    var peak = 0.0;
    var zeroCrossings = 0;
    var prevSample = 0.0;

    const silenceThreshold = 0.02;
    const frameSize = 512;
    var activeFrames = 0;
    var totalFrames = 0;

    final normalizedSamples = List<double>.filled(sampleCount, 0.0);

    for (var i = 0; i < sampleCount; i++) {
      final sample = pcmByteData.getInt16(i * 2, Endian.little) / 32768.0;
      normalizedSamples[i] = sample;

      final absSample = sample.abs();
      sumSquares += sample * sample;

      if (absSample > peak) {
        peak = absSample;
      }

      if (i > 0) {
        final changedSign =
            (prevSample >= 0 && sample < 0) || (prevSample < 0 && sample >= 0);
        if (changedSign) {
          zeroCrossings++;
        }
      }

      prevSample = sample;
    }

    for (var start = 0; start < sampleCount; start += frameSize) {
      final end = (start + frameSize < sampleCount)
          ? start + frameSize
          : sampleCount;

      var frameEnergy = 0.0;
      for (var i = start; i < end; i++) {
        final sample = normalizedSamples[i];
        frameEnergy += sample * sample;
      }

      final frameLength = end - start;
      if (frameLength <= 0) continue;

      final frameRms = (frameEnergy / frameLength).sqrtApprox();
      totalFrames++;

      if (frameRms >= silenceThreshold) {
        activeFrames++;
      }
    }

    final rms = (sumSquares / sampleCount).sqrtApprox();
    final zeroCrossingRate =
        sampleCount > 1 ? zeroCrossings / (sampleCount - 1) : 0.0;
    final activeFrameRatio = totalFrames > 0 ? activeFrames / totalFrames : 0.0;
    final durationMs = ((sampleCount / sampleRate) * 1000).round();

    return WavAudioFeatures(
      sampleRate: sampleRate,
      channelCount: channelCount,
      bitsPerSample: bitsPerSample,
      sampleCount: sampleCount,
      durationMs: durationMs,
      rms: rms,
      peakAmplitude: peak,
      zeroCrossingRate: zeroCrossingRate,
      activeFrameRatio: activeFrameRatio,
    );
  }
}

extension on double {
  double sqrtApprox() {
    if (this <= 0) return 0;
    var x = this;
    var guess = x > 1 ? x : 1.0;

    for (var i = 0; i < 8; i++) {
      guess = 0.5 * (guess + x / guess);
    }

    return guess;
  }
}