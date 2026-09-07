package m.c.g.a.i_iwara.vr

/** Initial browsing-panel placement, shared by startup and explicit recenter. */
internal class UiPanelPlacement {
    var shown = false
        private set
    private var placedByHead = false
    private var placedByUser = false

    fun shouldSettle(headReady: Boolean, timedOut: Boolean): Boolean =
        !placedByUser && ((headReady && !placedByHead) || (timedOut && !shown))

    fun placed(show: Boolean, headReady: Boolean) {
        shown = show
        placedByHead = show && headReady
        placedByUser = false
    }

    /** A user drag takes precedence over late tracking and fallback placement. */
    fun moved() {
        placedByUser = true
    }

    fun reset() {
        shown = false
        placedByHead = false
        placedByUser = false
    }
}
