package com.timbo.timbo_app

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt

class MainActivity : FlutterActivity() {
    private lateinit var sensorManager: SensorManager
    private var lastShakeTime = 0L
    private lateinit var shakeListener: SensorEventListener

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.timbo.app/shake"
        )

        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        val accel = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        shakeListener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                val x = event.values[0]
                val y = event.values[1]
                val z = event.values[2]
                val force = sqrt((x * x + y * y + z * z).toDouble()) - SensorManager.GRAVITY_EARTH
                val now = System.currentTimeMillis()
                if (force > 12 && now - lastShakeTime > 1200) {
                    lastShakeTime = now
                    runOnUiThread { channel.invokeMethod("onShake", null) }
                }
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        sensorManager.registerListener(shakeListener, accel, SensorManager.SENSOR_DELAY_NORMAL)
    }

    override fun onDestroy() {
        sensorManager.unregisterListener(shakeListener)
        super.onDestroy()
    }
}
