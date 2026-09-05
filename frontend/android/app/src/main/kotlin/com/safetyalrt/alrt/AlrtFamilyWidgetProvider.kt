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

/**
 * ALRT Family status home-screen widget.
 *
 * Shows one headline + sub-line for the user's circle. The solid red card is
 * used ONLY for a live family SOS (rule 6). A tap opens the app (SOS receiver
 * for an active SOS, otherwise the Family tab) and never triggers or resolves
 * an SOS (rule 3).
 */
class AlrtFamilyWidgetProvider : HomeWidgetProvider() {

    companion object {
        private const val PAYLOAD_KEY = "alrt_family_widget_payload"

        /** The group-icon slots in the layout, in draw order. */
        private val ICON_SLOTS = intArrayOf(
            R.id.family_group_icon_0,
            R.id.family_group_icon_1,
            R.id.family_group_icon_2,
            R.id.family_group_icon_3
        )
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val layout = layoutFor(
                appWidgetManager,
                widgetId,
                R.layout.alrt_family_widget,
                R.layout.alrt_family_widget_compact
            )
            val views = RemoteViews(context.packageName, layout)
            val payload = widgetData.getString(PAYLOAD_KEY, null)
                ?.let { runCatching { JSONObject(it) }.getOrNull() }

            if (payload == null) {
                views.setTextViewText(R.id.family_kicker, "FAMILY")
                views.setTextViewText(R.id.family_headline, "No family circle")
                views.setTextViewText(R.id.family_sub, "Set up in the app")
                views.setViewVisibility(R.id.family_groups_row, View.GONE)
            } else {
                bind(views, payload)
                bindGroups(views, payload.optJSONArray("groups"))
            }

            val deeplink = payload?.optString("deeplink")
                ?.takeIf { it.isNotBlank() }
                ?: "alrtwidget://open?screen=family"
            views.setOnClickPendingIntent(
                R.id.family_root,
                HomeWidgetLaunchIntent.getActivity(
                    context, MainActivity::class.java, Uri.parse(deeplink)
                )
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    /** Compact card when the widget is one cell high; full card otherwise. */
    private fun layoutFor(
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        full: Int,
        compact: Int
    ): Int {
        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        val minHeight = options.getInt(
            AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0
        )
        return if (minHeight in 1..99) compact else full
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle?
    ) {
        // Re-render at the new size so the layout swap happens live.
        onUpdate(
            context,
            appWidgetManager,
            intArrayOf(appWidgetId),
            es.antonborri.home_widget.HomeWidgetPlugin.getData(context)
        )
    }

    /**
     * Draws one icon per group the user belongs to.
     *
     * The widget process cannot fetch a URL, so the app renders each icon to
     * a PNG in its own files directory and passes the path. A missing or
     * unreadable file hides that slot rather than drawing a blank square.
     */
    private fun bindGroups(views: RemoteViews, groups: org.json.JSONArray?) {
        var shown = 0

        for (slot in ICON_SLOTS.indices) {
            val group = groups?.optJSONObject(slot)
            val path = group?.optString("iconPath")?.takeIf { it.isNotBlank() }
            val bitmap = path
                ?.let { runCatching { BitmapFactory.decodeFile(it) }.getOrNull() }

            if (bitmap == null) {
                views.setViewVisibility(ICON_SLOTS[slot], View.GONE)
                continue
            }

            views.setImageViewBitmap(ICON_SLOTS[slot], bitmap)
            views.setViewVisibility(ICON_SLOTS[slot], View.VISIBLE)
            // The group the headline is about is drawn at full strength; the
            // others sit back so the card still says which one it reports on.
            views.setInt(
                ICON_SLOTS[slot],
                "setImageAlpha",
                if (group.optBoolean("isCurrent", false)) 255 else 130
            )
            shown++
        }

        // One group is already named in the kicker, so a single icon adds
        // nothing. The row earns its space from two groups up.
        views.setViewVisibility(
            R.id.family_groups_row,
            if (shown > 1) View.VISIBLE else View.GONE
        )
    }

    private fun bind(views: RemoteViews, payload: JSONObject) {
        val state = payload.optString("state", "no_circle")
        val headline = payload.optString("headline", "")
        val sub = payload.optString("sub", "")
        val circleName = payload.optString("circleName", "")
        val isCritical = payload.optBoolean("isCritical", false)

        views.setTextViewText(
            R.id.family_kicker,
            if (circleName.isNotBlank()) circleName.uppercase() else "FAMILY"
        )
        views.setTextViewText(R.id.family_headline, headline)
        views.setTextViewText(R.id.family_sub, sub)

        when {
            isCritical -> {
                views.setInt(R.id.family_root, "setBackgroundResource", R.drawable.alrt_widget_bg_critical)
                views.setTextColor(R.id.family_kicker, 0xFFFFD9D5.toInt())
                views.setTextColor(R.id.family_headline, 0xFFFFFFFF.toInt())
                views.setTextColor(R.id.family_sub, 0xFFFFE3E0.toInt())
            }
            state == "safe" -> {
                // Everyone's safe: the same bright green -> teal identity as
                // the in-app I'm Safe action, not just coloured text on the
                // default card.
                views.setInt(R.id.family_root, "setBackgroundResource", R.drawable.alrt_widget_bg_safe)
                views.setTextColor(R.id.family_kicker, 0xFFDFFDF2.toInt())
                views.setTextColor(R.id.family_headline, 0xFFFFFFFF.toInt())
                views.setTextColor(R.id.family_sub, 0xFFE3FBF2.toInt())
            }
            else -> {
                // Every other state: the Family identity purple, matching
                // FamilyColors.headerGradient in the app.
                views.setInt(R.id.family_root, "setBackgroundResource", R.drawable.alrt_widget_bg_purple)
                views.setTextColor(R.id.family_kicker, 0xFFD9D0F7.toInt())
                // An unanswered check-in reads in amber, so it still asks
                // for something on the purple card; other states are white.
                views.setTextColor(
                    R.id.family_headline,
                    if (state == "check_in_requested") 0xFFF5C518.toInt() else 0xFFFFFFFF.toInt()
                )
                views.setTextColor(R.id.family_sub, 0xFFCFC7EC.toInt())
            }
        }
    }
}
