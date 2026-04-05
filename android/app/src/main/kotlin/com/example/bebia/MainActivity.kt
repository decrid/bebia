package com.example.bebia

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "bebia/audio_classifier"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val classifier = YamnetCryClassifier(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "classifyAudioFile" -> {
                    val audioPath = call.argument<String>("audioPath")
                    val cryThreshold =
                        (call.argument<Double>("cryThreshold") ?: 0.60).toFloat()

                    if (audioPath.isNullOrBlank()) {
                        result.error(
                            "invalid_args",
                            "Chybí cesta k audio souboru.",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        result.success(
                            classifier.classify(
                                audioPath = audioPath,
                                cryThreshold = cryThreshold,
                            ),
                        )
                    } catch (e: Exception) {
                        result.error(
                            "classification_error",
                            e.message ?: "Nepodařilo se klasifikovat audio.",
                            null,
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}