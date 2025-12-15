package m.c.g.a.i_iwara

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.KeyEvent
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "i_iwara/volume_key"
    private val SCREENSHOT_CHANNEL = "i_iwara/screenshot"
    private val FILE_HANDLER_CHANNEL = "com.example.i_iwara/file_handler"

    private var volumeKeyEnabled = false
    private var fileHandlerChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREENSHOT_CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "preventScreenshot" -> {
                            window.setFlags(
                                    WindowManager.LayoutParams.FLAG_SECURE,
                                    WindowManager.LayoutParams.FLAG_SECURE
                            )
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

        // 初始化文件处理 MethodChannel
        fileHandlerChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FILE_HANDLER_CHANNEL)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 处理启动时的 Intent（从文件管理器打开）
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        
        // 处理新的 Intent（应用已在运行时）
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return

        val action = intent.action
        val data: Uri? = intent.data

        Log.d("MainActivity", "收到 Intent - Action: $action, Data: $data")

        // 处理 VIEW action（打开文件）
        if (action == Intent.ACTION_VIEW && data != null) {
            val uriString = data.toString()
            Log.d("MainActivity", "收到文件打开请求: $uriString")
            
            // 通过 MethodChannel 将文件 URI 传递给 Flutter
            fileHandlerChannel?.invokeMethod("onFileOpened", uriString)
        }
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
