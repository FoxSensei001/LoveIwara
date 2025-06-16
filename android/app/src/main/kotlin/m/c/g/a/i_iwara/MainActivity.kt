package m.c.g.a.i_iwara

import android.view.KeyEvent
import android.view.WindowManager
import android.os.Bundle
import android.content.Context
import android.os.Build
import android.view.Window
import android.view.Display
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "i_iwara/volume_key"
    private val SCREENSHOT_CHANNEL = "i_iwara/screenshot"
    private val REFRESH_RATE_CHANNEL = "refresh_rate"
    private var volumeKeyEnabled = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableVolumeKeyListener" -> {
                    volumeKeyEnabled = true
                    result.success(null)
                }
                "disableVolumeKeyListener" -> {
                    volumeKeyEnabled = false
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREENSHOT_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "preventScreenshot" -> {
                    window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                "allowScreenshot" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, REFRESH_RATE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setRefreshRate") {
                try {
                    val refreshRate = (call.arguments as? Int)?.toFloat() ?: getMaxRefreshRate()
                    setRefreshRate(refreshRate)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("REFRESH_RATE_ERROR", "Failed to set refresh rate", e.message)
                }
            } else if (call.method == "getMaxRefreshRate") {
                try {
                    val maxRefreshRate = getMaxRefreshRate()
                    result.success(maxRefreshRate.toInt())
                } catch (e: Exception) {
                    result.error("REFRESH_RATE_ERROR", "Failed to get max refresh rate", e.message)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getMaxRefreshRate(): Float {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                display?.let { display ->
                    val supportedModes = display.supportedModes
                    supportedModes.maxByOrNull { it.refreshRate }?.refreshRate ?: 60f
                } ?: 60f
            } else {
                60f
            }
        } catch (e: Exception) {
            60f
        }
    }

    private fun setRefreshRate(refreshRate: Float) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                window.attributes = window.attributes.also { 
                    it.preferredRefreshRate = refreshRate
                    it.preferredDisplayModeId = 0
                }
                
                window.attributes.layoutInDisplayCutoutMode = 
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
                
                display?.let { display ->
                    val supportedModes = display.supportedModes
                    val targetMode = supportedModes
                        .filter { it.refreshRate <= refreshRate + 0.1f }
                        .maxByOrNull { it.refreshRate }
                    
                    targetMode?.let {
                        window.attributes.preferredRefreshRate = it.refreshRate
                    }
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                window.attributes = window.attributes.also {
                    it.preferredRefreshRate = refreshRate
                }
            }
            
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            window.addFlags(WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val maxRefreshRate = getMaxRefreshRate()
        setRefreshRate(maxRefreshRate)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (volumeKeyEnabled) {
            when (keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> {
                    MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                        .invokeMethod("onVolumeKeyUp", null)
                    return true
                }
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                        .invokeMethod("onVolumeKeyDown", null)
                    return true
                }
            }
        }
        return super.onKeyDown(keyCode, event)
    }
}
