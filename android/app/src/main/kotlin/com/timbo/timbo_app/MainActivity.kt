package com.timbo.timbo_app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt

class MainActivity : FlutterActivity() {
    private lateinit var sensorManager: SensorManager
    private var lastShakeTime: Long = 0
    private var shakeChannel: MethodChannel? = null

    private val shakeListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent) {
            val x = event.values[0]
            val y = event.values[1]
            val z = event.values[2]
            val force = sqrt((x * x + y * y + z * z).toDouble()) - SensorManager.GRAVITY_EARTH
            val now = System.currentTimeMillis()
            if (force > 12 && now - lastShakeTime > 1000) {
                lastShakeTime = now
                shakeChannel?.invokeMethod("onShake", null)
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        shakeChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.timbo.app/shake"
        )

        shakeChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startShakeService" -> {
                    if (hasNotificationPermission()) {
                        requestNotificationPermission()
                        startShakeServiceInternal()
                    } else {
                        startShakeServiceInternal()
                    }
                    result.success(null)
                }
                "stopShakeService" -> {
                    stopShakeServiceInternal()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        sensorManager.registerListener(
            shakeListener,
            sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER),
            SensorManager.SENSOR_DELAY_NORMAL
        )

        handleCaptureIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleCaptureIntent(intent)
    }

    private fun handleCaptureIntent(intent: Intent?) {
        if (intent?.action == "com.timbo.timbo_app.action.CAPTURE") {
            shakeChannel?.invokeMethod("onShake", null)
        }
    }

    private fun hasNotificationPermission(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return ContextCompat.checkSelfPermission(
                this, Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        }
        return false
    }

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (!hasNotificationPermission()) {
                requestPermissions(
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    REQUEST_NOTIFICATION_PERMISSION
                )
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_NOTIFICATION_PERMISSION) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startShakeServiceInternal()
            }
        }
    }

    private fun startShakeServiceInternal() {
        val serviceIntent = Intent(this, ShakeService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    private fun stopShakeServiceInternal() {
        val serviceIntent = Intent(this, ShakeService::class.java)
        stopService(serviceIntent)
    }

    override fun onDestroy() {
        sensorManager.unregisterListener(shakeListener)
        super.onDestroy()
    }

    companion object {
        private const val REQUEST_NOTIFICATION_PERMISSION = 1001
    }
}
