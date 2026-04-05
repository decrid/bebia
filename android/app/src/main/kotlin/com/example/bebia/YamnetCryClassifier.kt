package com.example.bebia

import android.content.Context
import com.google.mediapipe.tasks.audio.audioclassifier.AudioClassifier
import com.google.mediapipe.tasks.audio.core.RunningMode
import com.google.mediapipe.tasks.components.containers.AudioData
import com.google.mediapipe.tasks.core.BaseOptions
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.roundToInt

class YamnetCryClassifier(
    private val context: Context,
) {
    private val classifier: AudioClassifier by lazy {
        val options = AudioClassifier.AudioClassifierOptions.builder()
            .setBaseOptions(
                BaseOptions.builder()
                    .setModelAssetPath(MODEL_NAME)
                    .build(),
            )
            .setRunningMode(RunningMode.AUDIO_CLIPS)
            .setMaxResults(10)
            .setScoreThreshold(0.0f)
            .build()

        AudioClassifier.createFromOptions(context, options)
    }

    fun classify(
        audioPath: String,
        cryThreshold: Float = DEFAULT_CRY_THRESHOLD,
    ): Map<String, Any?> {
        val wav = readMono16kPcmWav(audioPath)

        val audioData = AudioData.create(
            AudioData.AudioDataFormat.builder()
                .setNumOfChannels(1)
                .setSampleRate(SAMPLE_RATE.toFloat())
                .build(),
            wav.samples.size,
        )
        audioData.load(wav.samples)

        val result = classifier.classify(audioData)

        val categories = result.classificationResults()
            .flatMap { it.classifications() }
            .flatMap { it.categories() }
            .sortedByDescending { it.score() }

        val babyCryCategory = categories.firstOrNull {
            it.categoryName().equals(BABY_CRY_LABEL, ignoreCase = true)
        }
        val babyCryScore = babyCryCategory?.score()?.toDouble() ?: 0.0
        val cryDetected = babyCryScore >= cryThreshold

        val topCategories = categories
            .take(5)
            .map {
                mapOf(
                    "name" to it.categoryName(),
                    "score" to it.score().toDouble(),
                )
            }

        val signals = mutableListOf<String>()
        signals.add("reálný model YAMNet")
        signals.add("délka vzorku ${wav.durationMs} ms")

        if (babyCryCategory != null) {
            signals.add(
                "Baby cry, infant cry ${(babyCryScore * 100).roundToInt()} %",
            )
        } else {
            signals.add("třída Baby cry, infant cry nebyla v top výsledcích")
        }

        categories.firstOrNull()?.let {
            signals.add("top třída: ${it.categoryName()}")
        }

        return mapOf(
            "hasUsableAudio" to true,
            "cryDetected" to cryDetected,
            "cryProbability" to babyCryScore,
            "modelVersion" to MODEL_VERSION,
            "signals" to signals,
            "topCategories" to topCategories,
        )
    }

    private fun readMono16kPcmWav(audioPath: String): WavClip {
        val file = File(audioPath)
        if (!file.exists()) {
            throw IllegalArgumentException("Audio soubor nebyl nalezen.")
        }

        val bytes = file.readBytes()
        if (bytes.size < 44) {
            throw IllegalArgumentException("WAV soubor je příliš krátký.")
        }

        val byteBuffer = ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN)

        val riff = String(bytes, 0, 4)
        val wave = String(bytes, 8, 4)
        if (riff != "RIFF" || wave != "WAVE") {
            throw IllegalArgumentException("Soubor není validní WAV.")
        }

        var audioFormat: Int? = null
        var channelCount: Int? = null
        var sampleRate: Int? = null
        var bitsPerSample: Int? = null
        var dataOffset: Int? = null
        var dataSize: Int? = null

        var offset = 12
        while (offset + 8 <= bytes.size) {
            val chunkId = String(bytes, offset, 4)
            val chunkSize = byteBuffer.getInt(offset + 4)
            val chunkDataStart = offset + 8
            val chunkDataEnd = chunkDataStart + chunkSize

            if (chunkDataEnd > bytes.size) {
                break
            }

            when (chunkId) {
                "fmt " -> {
                    audioFormat =
                        byteBuffer.getShort(chunkDataStart).toInt() and 0xFFFF
                    channelCount =
                        byteBuffer.getShort(chunkDataStart + 2).toInt() and 0xFFFF
                    sampleRate = byteBuffer.getInt(chunkDataStart + 4)
                    bitsPerSample =
                        byteBuffer.getShort(chunkDataStart + 14).toInt() and 0xFFFF
                }

                "data" -> {
                    dataOffset = chunkDataStart
                    dataSize = chunkSize
                }
            }

            offset = chunkDataEnd + (chunkSize and 1)
        }

        if (audioFormat != 1) {
            throw IllegalArgumentException("WAV musí být PCM.")
        }
        if (channelCount != 1) {
            throw IllegalArgumentException("WAV musí být mono.")
        }
        if (sampleRate != SAMPLE_RATE) {
            throw IllegalArgumentException("WAV musí mít sample rate 16000 Hz.")
        }
        if (bitsPerSample != 16) {
            throw IllegalArgumentException("WAV musí být 16-bit PCM.")
        }
        if (dataOffset == null || dataSize == null || dataSize < 2) {
            throw IllegalArgumentException("WAV neobsahuje platná PCM data.")
        }

        val sampleCount = dataSize / 2
        val samples = FloatArray(sampleCount)

        for (index in 0 until sampleCount) {
            val raw = byteBuffer.getShort(dataOffset + (index * 2)).toInt()
            samples[index] = (raw / 32768.0f).coerceIn(-1.0f, 1.0f)
        }

        val durationMs = ((sampleCount / SAMPLE_RATE.toDouble()) * 1000.0).roundToInt()

        return WavClip(
            samples = samples,
            durationMs = durationMs,
        )
    }

    private data class WavClip(
        val samples: FloatArray,
        val durationMs: Int,
    )

    companion object {
        private const val MODEL_NAME = "yamnet.tflite"
        private const val MODEL_VERSION = "yamnet-v1"
        private const val SAMPLE_RATE = 16000
        private const val DEFAULT_CRY_THRESHOLD = 0.60f
        private const val BABY_CRY_LABEL = "Baby cry, infant cry"
    }
}