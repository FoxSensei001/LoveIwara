package m.c.g.a.i_iwara.xr

import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

class ImmersivePresentationTest {
    @Before fun reset() = ImmersiveBridge.detachScene()
    @After fun detach() = ImmersiveBridge.detachScene()

    private fun request(id: String) = ImmersiveVideoRequest(
        url = "file:///fixture/$id.mp4", title = id, author = "", videoId = "",
        mediaId = id, requestId = 1L, shape = "flat", stereo = "none", fullFrame = false,
        width = 1920, height = 1080, positionMs = 0L, unsupportedProjection = false,
    )

    private class Scene : ImmersiveBridge.Listener {
        var presentation: ImmersiveVideoPresentation? = null
        override fun onPresent(presentation: ImmersiveVideoPresentation) { this.presentation = presentation }
        override fun onPresentGallery(request: ImmersiveGalleryRequest) {}
        override fun onDismiss() {}
        override fun onSources(mediaId: String, requestId: Long, sources: List<ImmersiveSourceOption>) {}
        override fun onHostFinished() {}
        override fun onTogglePanelControls() = false
        override fun onAbortSwitch(videoId: String, reason: String) {}
        override fun onPlaylist(
            sections: List<ImmersivePlaylistSection>, catalog: ImmersiveCatalogNode?,
            activeQueueId: String?, browseQueueId: String?, nowPlayingId: String?,
            browseRejectedQueueId: String?, texts: Map<String, String>,
        ) {}
    }

    @Test fun aRequestIsAcknowledgedOnlyAfterTheSceneCommits() {
        val results = mutableListOf<Boolean>()
        ImmersiveBridge.present(request("local-a"), results::add)
        assertTrue(results.isEmpty())
        val scene = Scene()
        ImmersiveBridge.attachScene(scene)
        assertEquals("local-a", scene.presentation!!.request.mediaId)
        assertEquals("", scene.presentation!!.request.videoId)
        assertTrue(results.isEmpty())
        scene.presentation!!.complete(true)
        scene.presentation!!.complete(false)
        assertEquals(listOf(true), results)
    }

    @Test fun supersedingAndDismissingPendingRequestsCompletesEachOnce() {
        val first = mutableListOf<Boolean>()
        val second = mutableListOf<Boolean>()
        ImmersiveBridge.present(request("a"), first::add)
        ImmersiveBridge.present(request("b"), second::add)
        assertEquals(listOf(false), first)
        assertTrue(second.isEmpty())
        ImmersiveBridge.dismiss()
        ImmersiveBridge.detachScene()
        assertEquals(listOf(false), second)
    }

    @Test fun abortUsesLocalMediaIdentityAndDoesNotCancelADifferentRequest() {
        val results = mutableListOf<Boolean>()
        ImmersiveBridge.present(request("local-a"), results::add)
        ImmersiveBridge.abortSwitch("local-b", "unavailable")
        assertTrue(results.isEmpty())
        ImmersiveBridge.abortSwitch("local-a", "unavailable")
        assertEquals(listOf(false), results)
    }

    @Test fun losingTheSceneCompletesAPendingRequest() {
        val results = mutableListOf<Boolean>()
        ImmersiveBridge.present(request("a"), results::add)
        ImmersiveBridge.detachScene()
        assertEquals(listOf(false), results)
        val scene = Scene()
        ImmersiveBridge.attachScene(scene)
        assertNull(scene.presentation)
    }
}
