package com.timbo.timbo_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import kotlin.math.sqrt

class ShakeService : Service(), SensorEventListener {

    companion object {
        const val CHANNEL_ID = "timbo_shake_channel"
        const val NOTIFICATION_ID = 1001
        private const val SHAKE_THRESHOLD = 25.0
        private const val SHAKE_DEBOUNCE_MS = 1000L
    }

    private var sensorManager: SensorManager? = null
    private var lastShakeTime = 0L
    private var wakeLock: PowerManager.WakeLock? = null
    private var isDestroyed = false
    private var prefs: SharedPreferences? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        prefs = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        startForeground(NOTIFICATION_ID, buildNotification())
        registerSensorIfEnabled()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (isDestroyed) {
            startForeground(NOTIFICATION_ID, buildNotification())
            isDestroyed = false
        }
        registerSensorIfEnabled()
        return START_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        val restartIntent = Intent(applicationContext, ShakeService::class.java)
        val pendingIntent = android.app.PendingIntent.getService(
            applicationContext, 0, restartIntent,
            android.app.PendingIntent.FLAG_ONE_SHOT or android.app.PendingIntent.FLAG_IMMUTABLE
        )
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
        alarmManager.set(android.app.AlarmManager.RTC, System.currentTimeMillis() + 100, pendingIntent)
        super.onTaskRemoved(rootIntent)
    }

    private fun isShakeEnabled(): Boolean {
        return prefs?.getBoolean("setting_shake", true) ?: true
    }

    private fun registerSensorIfEnabled() {
        sensorManager?.unregisterListener(this)
        if (isShakeEnabled()) {
            sensorManager?.registerListener(
                this,
                sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER),
                SensorManager.SENSOR_DELAY_NORMAL
            )
        }
    }

    override fun onSensorChanged(event: SensorEvent) {
        val x = event.values[0]
        val y = event.values[1]
        val z = event.values[2]
        val force = sqrt(x * x + y * y + z * z) - SensorManager.GRAVITY_EARTH
        val now = System.currentTimeMillis()
        if (force > SHAKE_THRESHOLD && now - lastShakeTime > SHAKE_DEBOUNCE_MS) {
            lastShakeTime = now
            launchCapture()
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    private fun launchCapture() {
        val intent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            action = "com.timbo.timbo_app.action.CAPTURE"
        }
        if (intent != null) {
            startActivity(intent)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Shake to Capture",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Timbo is listening for shake gestures"
                setShowBadge(false)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Timbo")
            .setContentText("Shake to capture")
            .setSmallIcon(android.R.drawable.ic_menu_camera)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }

    override fun onDestroy() {
        isDestroyed = true
        sensorManager?.unregisterListener(this)
        wakeLock?.let {
            if (it.isHeld) it.release()
        }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
