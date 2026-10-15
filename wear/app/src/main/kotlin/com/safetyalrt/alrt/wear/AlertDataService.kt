package com.safetyalrt.alrt.wear

import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.WearableListenerService

/** Receives the nearby-alert glance from the phone app. */
class AlertDataService : WearableListenerService() {
    override fun onDataChanged(events: DataEventBuffer) {
        for (event in events) {
            if (event.type != DataEvent.TYPE_CHANGED) continue
            val item = event.dataItem
            if (item.uri.path != "/alrt/nearby") continue
            val payload = DataMapItem.fromDataItem(item).dataMap.getString("payload")
            if (payload != null) GlanceStore.save(applicationContext, payload)
        }
    }
}
