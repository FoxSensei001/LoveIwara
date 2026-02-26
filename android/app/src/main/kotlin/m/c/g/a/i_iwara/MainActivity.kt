package m.c.g.a.i_iwara

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.view.KeyEvent
import android.view.WindowManager
import android.webkit.MimeTypeMap
import android.window.OnBackInvokedCallback
import android.window.OnBackInvokedDispatcher
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {
    private val CHANNEL = "i_iwara/volume_key"
    private val SCREENSHOT_CHANNEL = "i_iwara/screenshot"
    private val FILE_HANDLER_CHANNEL = "com.example.i_iwara/file_handler"
    private val SYSTEM_SETTINGS_CHANNEL = "i_iwara/system_settings"

    private var volumeKeyEnabled = false
    private var fileHandlerChannel: MethodChannel? = null
    private val mainScope = CoroutineScope(Dispatchers.Main)
    private var flutterBackInvokedCallback: OnBackInvokedCallback? = null

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
        fileHandlerChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "copyContentUriToCache" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString == null) {
                        result.error("INVALID_ARGUMENT", "URI is required", null)
                        return@setMethodCallHandler
                    }
                    copyContentUriToCache(uriString, result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Android system settings & back gesture bridge
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_SETTINGS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getEnableBackAnimation" -> {
                        // Settings.Global.enable_back_animation: 1 enabled, 0 disabled
                        val enabled = try {
                            Settings.Global.getInt(contentResolver, "enable_back_animation", 0)
                        } catch (_: Exception) {
                            0
                        }
                        result.success(enabled)
                    }
                    "setFlutterBackCallbackEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: true
                        if (enabled) {
                            registerFlutterBackCallbackIfNeeded()
                        } else {
                            unregisterFlutterBackCallbackIfNeeded()
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * 将 content:// URI 的文件复制到应用缓存目录
     * 这是解决 media_kit/mpv 无法播放 content:// URI 的 workaround
     */
    private fun copyContentUriToCache(uriString: String, result: MethodChannel.Result) {
        mainScope.launch {
            try {
                val uri = Uri.parse(uriString)
                val cachedPath = withContext(Dispatchers.IO) {
                    copyUriToCache(uri)
                }
                result.success(cachedPath)
            } catch (e: Exception) {
                Log.e("MainActivity", "复制文件失败: ${e.message}", e)
                result.error("COPY_FAILED", e.message, e.stackTraceToString())
            }
        }
    }

    /**
     * 在 IO 线程中执行实际的文件复制操作
     */
    private fun copyUriToCache(uri: Uri): String {
        val contentResolver = applicationContext.contentResolver

        // 获取文件名
        var fileName = "video_${System.currentTimeMillis()}"
        var extension = ".mp4"

        // 尝试从 URI 路径获取文件名
        val uriPath = Uri.decode(uri.toString())
        val pathFileName = uriPath.substringAfterLast('/')
        if (pathFileName.isNotEmpty() && pathFileName.contains('.')) {
            fileName = pathFileName.substringBeforeLast('.')
            extension = ".${pathFileName.substringAfterLast('.')}"
        }

        // 尝试从 ContentResolver 获取 MIME 类型来确定扩展名
        val mimeType = contentResolver.getType(uri)
        if (mimeType != null) {
            val mimeExtension = MimeTypeMap.getSingleton().getExtensionFromMimeType(mimeType)
            if (mimeExtension != null) {
                extension = ".$mimeExtension"
            }
        }

        // 创建缓存目录
        val cacheDir = File(applicationContext.cacheDir, "local_videos")
        if (!cacheDir.exists()) {
            cacheDir.mkdirs()
        }

        // 清理旧的缓存文件（超过 24 小时的文件）
        cleanOldCacheFiles(cacheDir)

        // 清理文件名中的非法字符
        val safeFileName = fileName.replace(Regex("[^a-zA-Z0-9_\\-\\u4e00-\\u9fa5]"), "_")
        val targetFile = File(cacheDir, "$safeFileName$extension")

        // 如果文件已存在且大小匹配，直接返回（避免重复复制）
        if (targetFile.exists()) {
            val existingSize = targetFile.length()
            val sourceSize = getContentUriSize(uri)
            if (sourceSize > 0 && existingSize == sourceSize) {
                Log.d("MainActivity", "缓存文件已存在且大小匹配，跳过复制: ${targetFile.absolutePath}")
                return targetFile.absolutePath
            }
        }

        Log.d("MainActivity", "开始复制文件: $uri -> ${targetFile.absolutePath}")

        // 复制文件内容
        contentResolver.openInputStream(uri)?.use { inputStream ->
            FileOutputStream(targetFile).use { outputStream ->
                val buffer = ByteArray(8192)
                var bytesRead: Int
                var totalBytes = 0L
                while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                    outputStream.write(buffer, 0, bytesRead)
                    totalBytes += bytesRead
                }
                Log.d("MainActivity", "文件复制完成，大小: $totalBytes bytes")
            }
        } ?: throw Exception("无法打开 content:// URI 的输入流")

        return targetFile.absolutePath
    }

    /**
     * 获取 content:// URI 指向的文件大小
     */
    private fun getContentUriSize(uri: Uri): Long {
        return try {
            applicationContext.contentResolver.openFileDescriptor(uri, "r")?.use {
                it.statSize
            } ?: -1L
        } catch (e: Exception) {
            -1L
        }
    }

    /**
     * 清理超过 24 小时的缓存文件
     */
    private fun cleanOldCacheFiles(cacheDir: File) {
        try {
            val maxAge = 24 * 60 * 60 * 1000L // 24 小时（毫秒）
            val now = System.currentTimeMillis()

            cacheDir.listFiles()?.forEach { file ->
                if (file.isFile && (now - file.lastModified()) > maxAge) {
                    Log.d("MainActivity", "删除过期缓存文件: ${file.name}")
                    file.delete()
                }
            }
        } catch (e: Exception) {
            Log.w("MainActivity", "清理缓存文件失败: ${e.message}")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 处理启动时的 Intent（从文件管理器打开）
        handleIntent(intent)
    }

    private fun registerFlutterBackCallbackIfNeeded() {
        if (Build.VERSION.SDK_INT < 33) return
        if (flutterBackInvokedCallback != null) return

        flutterBackInvokedCallback = OnBackInvokedCallback {
            try {
                val engine = flutterEngine
                if (engine != null) {
                    engine.navigationChannel.popRoute()
                } else {
                    // Fallback: if engine is not available, exit normally.
                    finishAfterTransition()
                }
            } catch (e: Exception) {
                Log.w("MainActivity", "onBackInvoked dispatch failed: ${e.message}", e)
                finishAfterTransition()
            }
        }

        try {
            onBackInvokedDispatcher.registerOnBackInvokedCallback(
                OnBackInvokedDispatcher.PRIORITY_DEFAULT,
                flutterBackInvokedCallback!!
            )
            Log.d("MainActivity", "Registered Flutter OnBackInvokedCallback")
        } catch (e: Exception) {
            Log.w("MainActivity", "Failed to register OnBackInvokedCallback: ${e.message}", e)
        }
    }

    private fun unregisterFlutterBackCallbackIfNeeded() {
        if (Build.VERSION.SDK_INT < 33) return
        val callback = flutterBackInvokedCallback ?: return
        try {
            onBackInvokedDispatcher.unregisterOnBackInvokedCallback(callback)
        } catch (e: Exception) {
            Log.w("MainActivity", "Failed to unregister OnBackInvokedCallback: ${e.message}", e)
        } finally {
            flutterBackInvokedCallback = null
        }
    }

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= 33) {
            val callback = flutterBackInvokedCallback
            if (callback != null) {
                try {
                    onBackInvokedDispatcher.unregisterOnBackInvokedCallback(callback)
                } catch (e: Exception) {
                    Log.w("MainActivity", "Failed to unregister OnBackInvokedCallback: ${e.message}", e)
                }
            }
            flutterBackInvokedCallback = null
        }
        super.onDestroy()
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
