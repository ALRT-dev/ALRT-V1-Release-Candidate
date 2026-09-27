package com.safetyalrt.alrt

import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * ALRT Family circles home-screen widget (payload version 2).
 *
 * One row per circle, most urgent first: a live SOS (solid red row), a
 * check-in someone is waiting on from me (amber row), asks I am waiting
 * on, then ordinary status. The card summarises the top item and prints
 * when the data was generated; a stale payload says so instead of
 * pretending to be current, because the launcher only redraws the last
 * payload the app handed over.
 *
 * Every tap opens the app at that circle, that check-in flow or that
 * SOS, and never checks in, shares a location, acknowledges or ends an
 * SOS (rule 3). No row ever carries a member's name or a location.
 */
class AlrtFamilyWidgetProvider : HomeWidgetProvider() {

    companion object {
        private const val PAYLOAD_KEY = "alrt_family_widget_payload"
        private const val STALE_AFTER_MS = 60L * 60L * 1000L

        private val ROW_IDS = intArrayOf(
            R.id.family_row_0, R.id.family_row_1, R.id.family_row_2, R.id.family_row_3
        )
        private val ROW_ICON_IDS = intArrayOf(
            R.id.family_row_icon_0, R.id.family_row_icon_1, R.id.family_row_icon_2, R.id.family_row_icon_3
        )
        private val ROW_GLYPH_IDS = intArrayOf(
            R.id.family_row_glyph_0, R.id.family_row_glyph_1, R.id.family_row_glyph_2, R.id.family_row_glyph_3
        )
        private val ROW_NAME_IDS = intArrayOf(
            R.id.family_row_name_0, R.id.family_row_name_1, R.id.family_row_name_2, R.id.family_row_name_3
        )
        private val ROW_STATUS_IDS = intArrayOf(
            R.id.family_row_status_0, R.id.family_row_status_1, R.id.family_row_status_2, R.id.family_row_status_3
        )
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val compact = isCompact(appWidgetManager, widgetId)
            val layout = if (compact) R.layout.alrt_family_widget_compact else R.layout.alrt_family_widget
            val views = RemoteViews(context.packageName, layout)
            val payload = widgetData.getString(PAYLOAD_KEY, null)
                ?.let { runCatching { JSONObject(it) }.getOrNull() }

            if (payload == null) {
                views.setTextViewText(R.id.family_kicker, "FAMILY CIRCLES")
                views.setTextViewText(R.id.family_headline, "Open ALRT to see your circles")
                views.setTextViewText(R.id.family_sub, "")
                views.setTextViewText(R.id.family_freshness, "")
                if (!compact) hideRows(views)
            } else {
                bindCard(views, payload, compact)
                if (!compact) bindRows(context, views, payload)
            }

            val deeplink = payload?.optString("deeplink")
                ?.takeIf { it.isNotBlank() }
                ?: "alrtwidget://open?screen=family"
            // The header and summary open the top item; on the compact card
            // that is the whole card.
            views.setOnClickPendingIntent(
                if (compact) R.id.family_root else R.id.family_header,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(deeplink))
            )
            if (!compact) {
                views.setOnClickPendingIntent(
                    R.id.family_headline,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(deeplink))
                )
                views.setOnClickPendingIntent(
                    R.id.family_more,
                    HomeWidgetLaunchIntent.getActivity(
                        context, MainActivity::class.java, Uri.parse("alrtwidget://open?screen=family")
                    )
                )
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun isCompact(appWidgetManager: AppWidgetManager, widgetId: Int): Boolean {
        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
        return minHeight in 1..99
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle?
    ) {
        onUpdate(
            context,
            appWidgetManager,
            intArrayOf(appWidgetId),
            es.antonborri.home_widget.HomeWidgetPlugin.getData(context)
        )
    }

    private fun bindCard(views: RemoteViews, payload: JSONObject, compact: Boolean) {
        val state = payload.optString("state", "ok")
        val headline = payload.optString("headline", "")
        val sub = payload.optString("sub", "")
        val circleName = payload.optString("circleName", "")
        val isCritical = payload.optBoolean("isCritical", false)

        views.setTextViewText(
            R.id.family_kicker,
            if (circleName.isNotBlank()) circleName.uppercase() else "FAMILY CIRCLES"
        )
        views.setTextViewText(R.id.family_headline, headline)
        views.setTextViewText(R.id.family_sub, sub)
        views.setTextViewText(R.id.family_freshness, freshnessOf(payload.optString("generatedAt", "")))

        when {
            isCritical -> {
                views.setInt(R.id.family_root, "setBackgroundResource", R.drawable.alrt_widget_bg_critical)
                views.setTextColor(R.id.family_kicker, 0xFFFFD9D5.toInt())
                views.setTextColor(R.id.family_headline, 0xFFFFFFFF.toInt())
                views.setTextColor(R.id.family_sub, 0xFFFFE3E0.toInt())
            }
            else -> {
                views.setInt(R.id.family_root, "setBackgroundResource", R.drawable.alrt_widget_bg_purple)
                views.setTextColor(R.id.family_kicker, 0xFFD9D0F7.toInt())
                views.setTextColor(
                    R.id.family_headline,
                    if (state == "check_in_requested") 0xFFF5C518.toInt() else 0xFFFFFFFF.toInt()
                )
                views.setTextColor(R.id.family_sub, 0xFFCFC7EC.toInt())
            }
        }
    }

    /** "Updated 9:42 am", or a stale marker once the payload is over an hour old. */
    private fun freshnessOf(generatedAt: String): String {
        if (generatedAt.isBlank()) return ""
        val parser = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US).apply {
            timeZone = TimeZone.getTimeZone("UTC")
        }
        val at = runCatching { parser.parse(generatedAt.substring(0, 19)) }.getOrNull() ?: return ""
        val local = SimpleDateFormat("h:mm a", Locale.getDefault()).format(at).lowercase()
        val age = Date().time - at.time
        return if (age > STALE_AFTER_MS) "As of $local · open ALRT" else "Updated $local"
    }

    private fun hideRows(views: RemoteViews) {
        for (id in ROW_IDS) views.setViewVisibility(id, View.GONE)
        views.setViewVisibility(R.id.family_more, View.GONE)
    }

    private fun bindRows(context: Context, views: RemoteViews, payload: JSONObject) {
        val rows = payload.optJSONArray("rows")
        hideRows(views)
        if (rows == null) return
        for (slot in ROW_IDS.indices) {
            val row = rows.optJSONObject(slot) ?: continue
            val kind = row.optString("kind", "ok")
            views.setViewVisibility(ROW_IDS[slot], View.VISIBLE)
            views.setTextViewText(ROW_NAME_IDS[slot], row.optString("name", "Circle"))
            views.setTextViewText(
                ROW_STATUS_IDS[slot],
                listOf(row.optString("headline", ""), row.optString("sub", ""))
                    .filter { it.isNotBlank() }.joinToString(" · ")
            )
            // A word and a glyph as well as a colour, for anyone who cannot
            // rely on colour alone.
            val glyph = when (kind) {
                "sos_mine", "sos_other" -> "SOS"
                "check_in_requested" -> "!"
                "waiting" -> "…"
                else -> "✓"
            }
            views.setTextViewText(ROW_GLYPH_IDS[slot], glyph)
            val background = when (kind) {
                "sos_mine", "sos_other" -> R.drawable.alrt_widget_row_sos
                "check_in_requested" -> R.drawable.alrt_widget_row_request
                else -> R.drawable.alrt_widget_row_neutral
            }
            views.setInt(ROW_IDS[slot], "setBackgroundResource", background)
            val dark = kind == "check_in_requested"
            val ink = if (dark) 0xFF231A00.toInt() else 0xFFFFFFFF.toInt()
            val inkSoft = if (dark) 0xFF4A3A00.toInt() else 0xFFF2EEFF.toInt()
            views.setTextColor(ROW_NAME_IDS[slot], ink)
            views.setTextColor(ROW_STATUS_IDS[slot], inkSoft)
            views.setTextColor(ROW_GLYPH_IDS[slot], ink)

            val path = row.optString("iconPath").takeIf { it.isNotBlank() }
            val bitmap = path?.let { runCatching { BitmapFactory.decodeFile(it) }.getOrNull() }
            if (bitmap == null) {
                views.setViewVisibility(ROW_ICON_IDS[slot], View.GONE)
            } else {
                views.setImageViewBitmap(ROW_ICON_IDS[slot], bitmap)
                views.setViewVisibility(ROW_ICON_IDS[slot], View.VISIBLE)
            }

            val link = row.optString("deeplink").takeIf { it.isNotBlank() }
                ?: "alrtwidget://open?screen=family"
            // A distinct request code per row, or Android would hand every
            // row the same PendingIntent.
            views.setOnClickPendingIntent(
                ROW_IDS[slot],
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse(link))
            )
        }
        val more = payload.optInt("moreCircles", 0)
        if (more > 0) {
            views.setTextViewText(R.id.family_more, "+$more more circle${if (more > 1) "s" else ""} · open ALRT")
            views.setViewVisibility(R.id.family_more, View.VISIBLE)
        }
    }
}
