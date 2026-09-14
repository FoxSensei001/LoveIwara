package m.c.g.a.i_iwara.vr

import org.junit.Assert.*
import org.junit.Test

class GpuResourceCleanupTest {
    @Test fun contextLossAndOneBadSurfaceDoNotSkipTheRemainingReleases() {
        val calls = mutableListOf<String>()
        val cleanup = GpuResourceCleanup()
        cleanup.attempt("GL objects") { calls += "current"; error("context lost") }
        cleanup.attempt("output") { calls += "output"; error("surface already gone") }
        cleanup.attempt("context") { calls += "context" }
        cleanup.attempt("input") { calls += "input" }
        cleanup.attempt("display") { calls += "display" }
        assertEquals(listOf("current", "output", "context", "input", "display"), calls)
        assertEquals("context lost", cleanup.failure?.cause?.message)
        assertEquals("surface already gone", cleanup.failure?.suppressed?.single()?.cause?.message)
    }

    @Test fun successfulReleaseHasNoFailure() {
        val cleanup = GpuResourceCleanup()
        var disconnected = false
        cleanup.attempt("output") { disconnected = true }
        assertTrue(disconnected)
        assertNull(cleanup.failure)
    }
}
