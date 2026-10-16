package com.safetyalrt.alrt.wear

import android.app.Activity
import android.content.SharedPreferences
import android.graphics.Color
import android.graphics.Typeface
import android.os.Bundle
import android.view.Gravity
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import org.json.JSONObject

/**
 * One read-only screen: the most serious nearby alert, or "All clear".
 * Severity is always written as a word as well as a colour. There is nothing
 * to tap that sends anything: no SOS, no message, no location.
 */
class GlanceActivity : Activity() {

    private lateinit var content: LinearLayout
    private val listener = SharedPreferences.OnSharedPreferenceChangeListener { _, _ -> render() }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val pad = (resources.displayMetrics.density * 18).toInt()
        content = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(pad, pad, pad, pad)
        }
        setContentView(ScrollView(this).apply {
            setBackgroundColor(Color.BLACK)
            addView(content)
        })
    }

    override fun onResume() {
        super.onResume()
        GlanceStore.prefs(this).registerOnSharedPreferenceChangeListener(listener)
        render()
    }

    override fun onPause() {
        GlanceStore.prefs(this).unregisterOnSharedPreferenceChangeListener(listener)
        super.onPause()
    }

    private fun bandColor(band: String): Int = when (band) {
        "critical" -> Color.parseColor("#DA1F2D")
        "action" -> Color.parseColor("#F07E1B")
        "monitor" -> Color.parseColor("#F5C518")
        else -> Color.parseColor("#8A93A0")
    }

    private fun text(value: String, sizeSp: Float, color: Int = Color.WHITE, bold: Boolean = false): TextView =
        TextView(this).apply {
            text = value
            textSize = sizeSp
            setTextColor(color)
            gravity = Gravity.CENTER
            if (bold) setTypeface(typeface, Typeface.BOLD)
        }

    private fun render() {
        content.removeAllViews()
        val raw = GlanceStore.load(this)
        if (raw == null) {
            content.addView(text("ALRT", 20f, Color.parseColor("#FF6B01"), true))
            content.addView(text("Open ALRT on your phone to see nearby alerts here.", 14f))
            return
        }
        val json = try { JSONObject(raw) } catch (e: Exception) { null }
        if (json == null) {
            content.addView(text("Open ALRT on your phone to refresh.", 14f))
            return
        }
        val primary = json.optJSONObject("primary")
        if (primary == null || json.optString("state") == "all_clear") {
            content.addView(text("All clear", 22f, Color.parseColor("#00B383"), true))
            content.addView(text("No active alerts near you.", 14f))
        } else {
            val band = primary.optString("band")
            content.addView(text(primary.optString("severityLabel"), 18f, bandColor(band), true))
            content.addView(text(primary.optString("title"), 16f, Color.WHITE, true))
            val where = listOf(primary.optString("area"), primary.optString("distance"))
                .filter { it.isNotBlank() }.joinToString(" · ")
            if (where.isNotBlank()) content.addView(text(where, 13f))
            val time = primary.optString("time")
            if (time.isNotBlank()) content.addView(text(time, 12f, Color.parseColor("#B0B6C0")))
            val count = json.optInt("activeCount", 0)
            if (count > 1) content.addView(text("+${count - 1} more on your phone", 12f, Color.parseColor("#B0B6C0")))
        }
        val updated = json.optString("updatedLabel")
        if (updated.isNotBlank()) content.addView(text(updated, 11f, Color.parseColor("#8A93A0")))
        content.addView(text("If you are experiencing an emergency, call your local emergency number.", 11f, Color.parseColor("#B0B6C0")))
    }
}
