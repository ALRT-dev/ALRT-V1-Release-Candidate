package com.safetyalrt.alrt.wear

import android.content.Context
import android.content.SharedPreferences

/** Keeps the last payload the phone sent, so the glance opens instantly. */
object GlanceStore {
    private const val FILE = "alrt_watch"
    private const val KEY = "payload"

    fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(FILE, Context.MODE_PRIVATE)

    fun save(context: Context, payloadJson: String) {
        prefs(context).edit().putString(KEY, payloadJson).apply()
    }

    fun load(context: Context): String? = prefs(context).getString(KEY, null)
}
