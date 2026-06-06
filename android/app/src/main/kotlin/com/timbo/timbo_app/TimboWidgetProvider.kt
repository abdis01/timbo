package com.timbo.timbo_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TimboWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.timbo_widget).apply {
                val openAppIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, openAppIntent)

                val micIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("timbo://quick_capture")
                )
                setOnClickPendingIntent(R.id.widget_mic, micIntent)

                val balanceIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("timbo://finance")
                )
                setOnClickPendingIntent(R.id.widget_balance, balanceIntent)

                val balance = widgetData.getString("balance", null)
                if (balance != null) {
                    setTextViewText(R.id.widget_balance, balance)
                    if (balance.startsWith("+")) {
                        setTextColor(R.id.widget_balance, 0xFF34D399.toInt())
                    } else {
                        setTextColor(R.id.widget_balance, 0xFFF87171.toInt())
                    }
                } else {
                    setTextViewText(R.id.widget_balance, "\$0")
                    setTextColor(R.id.widget_balance, 0xFF94A3B8.toInt())
                }

                val reminder = widgetData.getString("reminder", null)
                if (reminder != null) {
                    setTextViewText(R.id.widget_reminder, reminder)
                } else {
                    setTextViewText(R.id.widget_reminder, "No reminders today")
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
