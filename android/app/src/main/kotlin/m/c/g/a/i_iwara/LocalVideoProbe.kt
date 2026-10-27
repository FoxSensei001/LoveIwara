package m.c.g.a.i_iwara

import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import java.io.ByteArrayOutputStream
import kotlin.math.roundToLong

/**
 * 本机视频的元数据与封面帧，走系统的 [MediaMetadataRetriever]（硬件解码器）。
 *
 * 本地库派生封面原来一律开一个无头 libmpv：建播放器、打开、seek 等落地、截屏、在 Dart
 * isolate 里纯软件编码 JPEG、再 dispose，一条就是一两秒起步，片子关键帧间隔长时更久；
 * 一个两百条的目录要排好几分钟（2026-10-27 用户报「自动设置封面非常慢」）。系统解码器
 * 取一帧通常一两百毫秒，而且不和用户正在用的 mpv 抢软解线程。
 *
 * 只做「读」：拿不到就返回空，由 Dart 侧退回 mpv（mkv 里的冷门编码、rmvb 之类系统
 * 解不了）。
 */
object LocalVideoProbe {
    /**
     * @param source 绝对路径或 `content://` URI。
     * @param positionMs 为 null 时不取帧。
     * @param maxSize 帧的长边上限（等比缩放）。
     */
    fun retrieve(
            context: Context,
            source: String,
            positionMs: Long?,
            maxSize: Int,
            wantMetadata: Boolean
    ): Map<String, Any?> {
        val retriever = MediaMetadataRetriever()
        try {
            if (source.startsWith("content://")) {
                retriever.setDataSource(context, Uri.parse(source))
            } else {
                retriever.setDataSource(source)
            }
            val result = HashMap<String, Any?>()
            if (wantMetadata) readMetadata(retriever, result)
            if (positionMs != null) {
                result["frame"] = readFrame(retriever, positionMs, maxSize)
            }
            return result
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
            }
        }
    }

    private fun readMetadata(retriever: MediaMetadataRetriever, out: MutableMap<String, Any?>) {
        fun long(key: Int): Long? =
                retriever.extractMetadata(key)?.trim()?.toLongOrNull()?.takeIf { it > 0 }

        val durationMs = long(MediaMetadataRetriever.METADATA_KEY_DURATION)
        var width = long(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toInt()
        var height = long(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toInt()
        // 宽高是编码尺寸；竖拍的片子带 90/270 度旋转，要换成显示尺寸，
        // 与 MediaStore / 列表上「720x1280」的口径一致。
        val rotation = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)
                ?.trim()
                ?.toIntOrNull() ?: 0
        if (rotation % 180 != 0) {
            val swap = width
            width = height
            height = swap
        }
        out["durationMs"] = durationMs
        out["width"] = width
        out["height"] = height
        out["hasVideo"] =
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_HAS_VIDEO) == "yes"
        // 容器里没有直接的帧率字段可读；总帧数 / 时长是平均帧率，可变帧率的片子会有小数。
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && durationMs != null) {
            val frames = long(MediaMetadataRetriever.METADATA_KEY_VIDEO_FRAME_COUNT)
            if (frames != null) {
                val fps = frames * 1000.0 / durationMs
                if (fps > 0 && fps < 1000) out["fps"] = (fps * 1000).roundToLong() / 1000.0
            }
        }
    }

    private fun readFrame(retriever: MediaMetadataRetriever, positionMs: Long, maxSize: Int): ByteArray? {
        val timeUs = positionMs.coerceAtLeast(0) * 1000
        // 关键帧取帧：只解一帧，封面落在目标附近即可（同 mpv 那条路关掉精确 seek 的理由）。
        val option = MediaMetadataRetriever.OPTION_CLOSEST_SYNC
        val bitmap: Bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            retriever.getScaledFrameAtTime(timeUs, option, maxSize, maxSize)
        } else {
            retriever.getFrameAtTime(timeUs, option)?.let { scaleDown(it, maxSize) }
        } ?: return null
        return try {
            ByteArrayOutputStream().use { out ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 85, out)
                out.toByteArray()
            }
        } finally {
            bitmap.recycle()
        }
    }

    private fun scaleDown(bitmap: Bitmap, maxSize: Int): Bitmap {
        val longEdge = maxOf(bitmap.width, bitmap.height)
        if (longEdge <= maxSize) return bitmap
        val scale = maxSize.toFloat() / longEdge
        val scaled = Bitmap.createScaledBitmap(
                bitmap,
                (bitmap.width * scale).toInt().coerceAtLeast(1),
                (bitmap.height * scale).toInt().coerceAtLeast(1),
                true
        )
        if (scaled !== bitmap) bitmap.recycle()
        return scaled
    }
}
