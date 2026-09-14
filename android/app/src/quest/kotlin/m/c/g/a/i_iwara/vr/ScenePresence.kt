package m.c.g.a.i_iwara.vr

/** The two runtime signals can arrive in either order. Both must allow input. */
internal class ScenePresence {
    var vrVisible = false
    var hmdMounted = true
    val foreground: Boolean get() = vrVisible && hmdMounted
}
