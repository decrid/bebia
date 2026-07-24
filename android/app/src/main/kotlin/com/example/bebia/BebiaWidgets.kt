package com.example.bebia

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.TimeUnit

object BebiaWidgetStore {
    private const val preferencesName = "bebia_widget_snapshot"
    private const val snapshotKey = "snapshot"

    fun saveSnapshot(context: Context, payload: Map<*, *>) {
        context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit()
            .putString(snapshotKey, mapToJson(payload).toString())
            .apply()
    }

    fun updateAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        updateProvider(context, manager, BebiaFeedingWidget::class.java, WidgetSize.SMALL)
        updateProvider(context, manager, BebiaCareWidget::class.java, WidgetSize.MEDIUM)
    }

    fun buildWidget(context: Context, size: WidgetSize): RemoteViews {
        val layout = when (size) {
            WidgetSize.SMALL -> R.layout.widget_feeding
            WidgetSize.MEDIUM -> R.layout.widget_care
        }
        val views = RemoteViews(context.packageName, layout)
        val snapshot = snapshot(context)
        if (size == WidgetSize.SMALL) {
            bindSmall(context, views, snapshot)
        } else {
            bindMedium(context, views, snapshot)
        }
        return views
    }

    private fun updateProvider(
        context: Context,
        manager: AppWidgetManager,
        provider: Class<*>,
        size: WidgetSize,
    ) {
        val ids = manager.getAppWidgetIds(ComponentName(context, provider))
        ids.forEach { id -> manager.updateAppWidget(id, buildWidget(context, size)) }
    }

    private fun snapshot(context: Context): JSONObject {
        val raw = context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .getString(snapshotKey, null)
            ?: return JSONObject()
        return runCatching { JSONObject(raw) }.getOrDefault(JSONObject())
    }

    private fun bindSmall(
        context: Context,
        views: RemoteViews,
        snapshot: JSONObject,
    ) {
        val feeding = snapshot.optJSONObject("feeding")
        views.setTextViewText(
            R.id.widget_feeding_age,
            feeding?.let { relativeAge(it.optLong("time")) } ?: "Bez záznamu",
        )
        views.setTextViewText(
            R.id.widget_feeding_detail,
            feeding?.optString("detail")?.takeIf { it.isNotBlank() }
                ?: "Přidejte první krmení",
        )
        views.setOnClickPendingIntent(
            R.id.widget_root,
            openIntent(context, "timeline/feeding", 310),
        )
        views.setOnClickPendingIntent(
            R.id.widget_add_feeding,
            openIntent(context, "add/feeding", 311),
        )
    }

    private fun bindMedium(
        context: Context,
        views: RemoteViews,
        snapshot: JSONObject,
    ) {
        bindEvent(
            views,
            R.id.widget_feeding_value,
            R.id.widget_feeding_meta,
            snapshot.optJSONObject("feeding"),
        )
        bindEvent(
            views,
            R.id.widget_sleep_value,
            R.id.widget_sleep_meta,
            snapshot.optJSONObject("sleep"),
        )
        bindEvent(
            views,
            R.id.widget_diaper_value,
            R.id.widget_diaper_meta,
            snapshot.optJSONObject("diaper"),
        )
        views.setOnClickPendingIntent(
            R.id.widget_root,
            openIntent(context, "timeline", 320),
        )
        views.setOnClickPendingIntent(
            R.id.widget_add_feeding,
            openIntent(context, "add/feeding", 321),
        )
        views.setOnClickPendingIntent(
            R.id.widget_add_sleep,
            openIntent(context, "add/sleep", 322),
        )
        views.setOnClickPendingIntent(
            R.id.widget_add_diaper,
            openIntent(context, "add/diaper", 323),
        )
    }

    private fun bindEvent(
        views: RemoteViews,
        valueId: Int,
        metaId: Int,
        event: JSONObject?,
    ) {
        if (event == null) {
            views.setTextViewText(valueId, "—")
            views.setTextViewText(metaId, "Bez záznamu")
            return
        }
        views.setTextViewText(valueId, relativeAge(event.optLong("time")))
        views.setTextViewText(
            metaId,
            event.optString("detail").takeIf { it.isNotBlank() } ?: "Zaznamenáno",
        )
    }

    private fun openIntent(
        context: Context,
        target: String,
        requestCode: Int,
    ): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            data = Uri.parse("bebia://$target")
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun relativeAge(timestamp: Long): String {
        if (timestamp <= 0L) return "Bez záznamu"
        val elapsed = (System.currentTimeMillis() - timestamp).coerceAtLeast(0L)
        val minutes = TimeUnit.MILLISECONDS.toMinutes(elapsed)
        if (minutes < 1) return "Právě teď"
        if (minutes < 60) return "Před $minutes min"
        val hours = TimeUnit.MILLISECONDS.toHours(elapsed)
        if (hours < 24) return "Před $hours h"
        val days = TimeUnit.MILLISECONDS.toDays(elapsed)
        return if (days == 1L) "Včera" else "Před $days d"
    }

    private fun mapToJson(map: Map<*, *>): JSONObject {
        val result = JSONObject()
        map.forEach { (key, value) ->
            if (key != null) result.put(key.toString(), jsonValue(value))
        }
        return result
    }

    private fun jsonValue(value: Any?): Any? {
        return when (value) {
            null -> JSONObject.NULL
            is Map<*, *> -> mapToJson(value)
            is List<*> -> JSONArray().apply {
                value.forEach { put(jsonValue(it)) }
            }
            else -> value
        }
    }
}

enum class WidgetSize {
    SMALL,
    MEDIUM,
}

abstract class BebiaWidgetProvider(
    private val size: WidgetSize,
) : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { id ->
            appWidgetManager.updateAppWidget(
                id,
                BebiaWidgetStore.buildWidget(context, size),
            )
        }
    }
}

class BebiaFeedingWidget : BebiaWidgetProvider(WidgetSize.SMALL)
class BebiaCareWidget : BebiaWidgetProvider(WidgetSize.MEDIUM)

class BebiaWidgetBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (
            intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED
        ) {
            BebiaWidgetStore.updateAll(context)
        }
    }
}
