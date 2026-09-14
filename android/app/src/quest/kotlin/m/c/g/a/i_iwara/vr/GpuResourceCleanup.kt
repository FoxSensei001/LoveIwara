package m.c.g.a.i_iwara.vr

/** A lost GL context must not prevent disconnecting the Android output surfaces. */
internal class GpuResourceCleanup {
    var failure: Throwable? = null
        private set

    fun attempt(label: String, release: () -> Unit) {
        try {
            release()
        } catch (error: Throwable) {
            val problem = IllegalStateException("GPU cleanup failed: $label", error)
            val first = failure
            if (first == null) failure = problem else first.addSuppressed(problem)
        }
    }
}
