class WavAudioFeatures {
  const WavAudioFeatures({
    required this.sampleRate,
    required this.channelCount,
    required this.bitsPerSample,
    required this.sampleCount,
    required this.durationMs,
    required this.rms,
    required this.peakAmplitude,
    required this.zeroCrossingRate,
    required this.activeFrameRatio,
  });

  final int sampleRate;
  final int channelCount;
  final int bitsPerSample;
  final int sampleCount;
  final int durationMs;
  final double rms;
  final double peakAmplitude;
  final double zeroCrossingRate;
  final double activeFrameRatio;
}