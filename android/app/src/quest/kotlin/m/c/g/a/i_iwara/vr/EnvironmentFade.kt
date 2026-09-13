package m.c.g.a.i_iwara.vr

/** Reversible crossfade. Repeated settings updates must not restart an in-flight fade. */
internal class EnvironmentFade(private val durationMs: Long = 450L) {
    private var from = 0f
    private var target = 0f
    private var startedAt = 0L

    fun setVisible(visible: Boolean, now: Long, immediate: Boolean = false) {
        val next = if (visible) 1f else 0f
        if (!immediate && next == target) return
        from = if (immediate) next else valueAt(now)
        target = next
        startedAt = now
    }

    fun valueAt(now: Long): Float {
        val t = ((now - startedAt).toFloat() / durationMs).coerceIn(0f, 1f)
        return from + (target - from) * t * t * (3f - 2f * t)
    }
}
