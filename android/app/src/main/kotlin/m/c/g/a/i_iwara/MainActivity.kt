package m.c.g.a.i_iwara

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.storage.StorageManager
import android.provider.DocumentsContract
import android.util.Log
import android.view.KeyEvent
import android.view.WindowManager
import android.webkit.MimeTypeMap
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

    private var volumeKeyEnabled = false
    private var fileHandlerChannel: MethodChannel? = null
    private val mainScope = CoroutineScope(Dispatchers.Main)

    private val REQUEST_CODE_PICK_DIRECTORY = 51423
    private var pendingDirectoryResult: MethodChannel.Result? = null

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
                "pickDirectory" -> {
                    if (pendingDirectoryResult != null) {
                        result.error("ALREADY_ACTIVE", "目录选择器已在运行", null)
                    } else {
                        try {
                            pendingDirectoryResult = result
                            startActivityForResult(
                                    Intent(Intent.ACTION_OPEN_DOCUMENT_TREE),
                                    REQUEST_CODE_PICK_DIRECTORY
                            )
                        } catch (e: Exception) {
                            pendingDirectoryResult = null
                            result.error("PICKER_FAILED", e.message, null)
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_CODE_PICK_DIRECTORY) {
            val result = pendingDirectoryResult
            if (result == null) {
                super.onActivityResult(requestCode, resultCode, data)
                return
            }
            pendingDirectoryResult = null
            val uri = data?.data
            if (resultCode != RESULT_OK || uri == null) {
                // 用户取消选择
                result.success(null)
                return
            }
            try {
                result.success(resolveTreeUriToPath(uri))
            } catch (e: Exception) {
                Log.e("MainActivity", "解析目录路径失败: $uri", e)
                result.error("RESOLVE_FAILED", e.message, null)
            }
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    /**
     * 将 SAF 目录树 URI 解析为文件系统绝对路径。
     * 不依赖 file_selector 插件的转换逻辑（其不支持外置 SD/TF 卡卷），
     * 主存储与外置存储卷均可解析；写入依赖「所有文件访问」权限而非 SAF。
     */
    private fun resolveTreeUriToPath(uri: Uri): String {
        if (uri.authority != "com.android.externalstorage.documents") {
            throw UnsupportedOperationException("不支持的存储位置，请选择设备存储或 SD 卡中的目录")
        }
        val docId = DocumentsContract.getTreeDocumentId(uri)
        val split = docId.split(":", limit = 2)
        val volumeId = split[0]
        val subPath = if (split.size > 1) split[1] else ""
        val volumeRoot = when {
            volumeId.equals("primary", ignoreCase = true) ->
                    Environment.getExternalStorageDirectory().absolutePath
            volumeId.equals("home", ignoreCase = true) ->
                    File(Environment.getExternalStorageDirectory(), "Documents").absolutePath
            else -> findVolumeRootByUuid(volumeId) ?: "/storage/$volumeId"
        }
        return if (subPath.isEmpty()) volumeRoot else "$volumeRoot/$subPath"
    }

    /** 通过 StorageManager 将存储卷 UUID 映射到挂载根目录 */
    private fun findVolumeRootByUuid(uuid: String): String? {
        // StorageVolume.getDirectory 需要 API 30，R 以下由调用方回退 /storage/<卷ID>
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return null
        return try {
            val storageManager = getSystemService(STORAGE_SERVICE) as StorageManager
            storageManager.storageVolumes
                    .firstOrNull { uuid.equals(it.uuid, ignoreCase = true) }
                    ?.directory
                    ?.absolutePath
        } catch (e: Exception) {
            Log.w("MainActivity", "查找存储卷失败: ${e.message}")
            null
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
