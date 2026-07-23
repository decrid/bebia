package com.example.bebia

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val channelName = "bebia/audio_classifier"
    private val audioClassifierExecutor: ExecutorService =
        Executors.newSingleThreadExecutor()
    private lateinit var audioClassifier: YamnetCryClassifier
    private var audioChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        audioClassifier = YamnetCryClassifier(this)

        audioChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        )
        audioChannel?.setMethodCallHandler { call, result ->
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

                    audioClassifierExecutor.execute {
                        try {
                            val classification = audioClassifier.classify(
                                audioPath = audioPath,
                                cryThreshold = cryThreshold,
                            )
                            runOnUiThread {
                                result.success(classification)
                            }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error(
                                    "classification_error",
                                    e.message
                                        ?: "Nepodařilo se klasifikovat audio.",
                                    null,
                                )
                            }
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        audioChannel?.setMethodCallHandler(null)
        audioChannel = null
        if (::audioClassifier.isInitialized) {
            audioClassifierExecutor.execute {
                audioClassifier.close()
            }
        }
        audioClassifierExecutor.shutdown()
        super.onDestroy()
    }
}
