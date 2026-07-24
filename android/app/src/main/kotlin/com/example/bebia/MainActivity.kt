package com.example.bebia

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val audioChannelName = "bebia/audio_classifier"
    private val platformChannelName = "com.example.bebia/platform"
    private val audioClassifierExecutor: ExecutorService =
        Executors.newSingleThreadExecutor()
    private lateinit var audioClassifier: YamnetCryClassifier
    private var audioChannel: MethodChannel? = null
    private var platformChannel: MethodChannel? = null
    private var pendingLaunchTarget: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        pendingLaunchTarget = launchTarget(intent)
        audioClassifier = YamnetCryClassifier(this)

        audioChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            audioChannelName,
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

        platformChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            platformChannelName,
        )
        platformChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLaunchTarget" -> {
                    result.success(pendingLaunchTarget)
                    pendingLaunchTarget = null
                }
                "syncWidgetSnapshot" -> {
                    val payload = call.arguments as? Map<*, *>
                    if (payload == null) {
                        result.error(
                            "invalid_widget_snapshot",
                            "Chybí data pro widget Bebia.",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    try {
                        BebiaWidgetStore.saveSnapshot(this, payload)
                        BebiaWidgetStore.updateAll(this)
                        result.success(null)
                    } catch (error: Exception) {
                        Log.e(
                            "Bebia.MainActivity",
                            "Widget snapshot synchronization failed",
                            error,
                        )
                        result.error(
                            "widget_sync_failed",
                            "Widgety se nepodařilo obnovit.",
                            error.javaClass.simpleName,
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val target = launchTarget(intent) ?: return
        val channel = platformChannel
        if (channel == null) {
            pendingLaunchTarget = target
        } else {
            channel.invokeMethod("openLaunchTarget", target)
        }
    }

    override fun onDestroy() {
        audioChannel?.setMethodCallHandler(null)
        audioChannel = null
        platformChannel?.setMethodCallHandler(null)
        platformChannel = null
        if (::audioClassifier.isInitialized) {
            audioClassifierExecutor.execute {
                audioClassifier.close()
            }
        }
        audioClassifierExecutor.shutdown()
        super.onDestroy()
    }

    private fun launchTarget(intent: Intent?): String? {
        val uri = intent?.data ?: return null
        if (uri.scheme != "bebia") return null
        val section = uri.host ?: return null
        val eventType = uri.pathSegments.firstOrNull()
        val supportedEventTypes = setOf("feeding", "sleep", "diaper", "crying")
        return when (section) {
            "home" -> if (eventType == null) "home" else null
            "timeline" -> when {
                eventType == null -> "timeline"
                eventType != null && eventType in supportedEventTypes ->
                    "timeline/$eventType"
                else -> null
            }
            "add" -> if (eventType != null && eventType in supportedEventTypes) {
                "add/$eventType"
            } else {
                null
            }
            else -> null
        }
    }
}
