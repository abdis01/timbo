package com.timbo.timbo_app

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build
import android.os.Bundle
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat

class MainActivity : FlutterActivity() {
    private val SHORTCUT_CHANNEL = "com.timbo.app/shortcut"
    private val CAPTURE_CHANNEL = "com.timbo.app/capture"
    private val SHARE_CHANNEL = "com.timbo.app/share"
    private val SHAKE_CHANNEL = "com.timbo.app/shake"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHORTCUT_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "pinShortcut") {
                val id = call.argument<String>("id") ?: return@setMethodCallHandler result.error("NO_ID", "Missing id", null)
                val shortLabel = call.argument<String>("shortLabel") ?: "Timbo"
                val longLabel = call.argument<String>("longLabel") ?: "Open Timbo note"
                pinShortcut(id, shortLabel, longLabel)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHARE_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "shareText") {
                val title = call.argument<String>("title") ?: "Timbo"
                val text = call.argument<String>("text") ?: ""
                val shareIntent = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_SUBJECT, title)
                    putExtra(Intent.EXTRA_TEXT, text)
                }
                startActivity(Intent.createChooser(shareIntent, "Share via"))
                result.success(true)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CAPTURE_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "onCapture") {
                result.success(true)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHAKE_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val intent = Intent(this, ShakeService::class.java)
                    startForegroundService(intent)
                    result.success(true)
                }
                "stop" -> {
                    val intent = Intent(this, ShakeService::class.java)
                    stopService(intent)
                    result.success(true)
                }
                "isRunning" -> {
                    // Simple check: try to check if service is active
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Start shake service on launch if user has it enabled
        val prefs: SharedPreferences = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val shakeEnabled = prefs.getBoolean("setting_shake", true)
        if (shakeEnabled) {
            val intent = Intent(this, ShakeService::class.java)
            startForegroundService(intent)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action == "com.timbo.timbo_app.action.CAPTURE") {
            flutterEngine?.dartExecutor?.binaryMessenger?.let {
                MethodChannel(it, CAPTURE_CHANNEL).invokeMethod("onCapture", null)
            }
        } else if (intent.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
            if (sharedText != null) {
                flutterEngine?.dartExecutor?.binaryMessenger?.let {
                    MethodChannel(it, CAPTURE_CHANNEL).invokeMethod("onShare", sharedText)
                }
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun pinShortcut(id: String, shortLabel: String, longLabel: String) {
        val baseIntent = packageManager.getLaunchIntentForPackage(packageName) ?: Intent(this, javaClass)
        baseIntent.action = Intent.ACTION_VIEW
        baseIntent.putExtra("timboId", id)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val shortcutManager = getSystemService(ShortcutManager::class.java)
                if (shortcutManager.isRequestPinShortcutSupported) {
                    val shortcut = ShortcutInfo.Builder(this, id)
                        .setShortLabel(shortLabel)
                        .setLongLabel(longLabel)
                        .setIcon(Icon.createWithResource(this, R.mipmap.ic_launcher))
                        .setIntent(baseIntent)
                        .build()
                    val pendingIntent = PendingIntent.getBroadcast(
                        this, id.hashCode(),
                        Intent(this, javaClass).apply {
                            action = "com.timbo.timbo_app.PIN_SHORTCUT"
                        },
                        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                    )
                    shortcutManager.requestPinShortcut(shortcut, pendingIntent.intentSender)
                }
            } else {
                val shortcut = ShortcutInfoCompat.Builder(this, id)
                    .setShortLabel(shortLabel)
                    .setLongLabel(longLabel)
                    .setIcon(IconCompat.createWithResource(this, R.mipmap.ic_launcher))
                    .setIntent(baseIntent)
                    .build()
                ShortcutManagerCompat.pushDynamicShortcut(this, shortcut)
                ShortcutManagerCompat.requestPinShortcut(this, shortcut, null)
            }
        }
    }
}
