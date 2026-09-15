package m.c.g.a.i_iwara.vr

import m.c.g.a.i_iwara.questui.EnvironmentKind
import m.c.g.a.i_iwara.questui.EnvironmentSettings
import org.junit.Assert.*
import org.junit.Test

class EnvironmentAssetsTest {
    @Test fun otherWorldsNeverAllocateOrbitalBodiesFromRememberedSpaceSettings() {
        val space = EnvironmentSettings(EnvironmentKind.DEEP_SPACE, dynamicSpace = true)
        assertTrue(space.usesOrbitalBodies)
        for (kind in EnvironmentKind.entries.filter { it != EnvironmentKind.DEEP_SPACE }) {
            val next = space.copy(kind = kind)
            assertFalse(next.usesOrbitalBodies)
            assertTrue(next.showEarth && next.showMoon && next.dynamicSpace)
        }
    }

    @Test fun roomAndBlackHaveNoTextureWhileEachVistaHasItsOwnAsset() {
        assertNull(environmentAsset(EnvironmentSettings(EnvironmentKind.PASSTHROUGH)))
        assertNull(environmentAsset(EnvironmentSettings(EnvironmentKind.VOID)))
        val assets = EnvironmentKind.entries.filter { it.hasPanorama }
            .map { environmentAsset(EnvironmentSettings(it)) }
        assertTrue(assets.all { it != null && it.startsWith("environments/") })
        assertEquals(assets.size, assets.toSet().size)
    }

    @Test fun spaceBodyVisibilityStillSelectsTheMatchingStaticPanorama() {
        val space = EnvironmentSettings(EnvironmentKind.DEEP_SPACE)
        assertEquals("environments/deep_space.png", environmentAsset(space))
        assertEquals("environments/deep_space_earth.png", environmentAsset(space.copy(showMoon = false)))
        assertEquals("environments/deep_space_moon.png", environmentAsset(space.copy(showEarth = false)))
        assertEquals("environments/stars.png", environmentAsset(space.copy(showEarth = false, showMoon = false)))
        assertEquals("environments/stars.png", environmentAsset(space.copy(dynamicSpace = true)))
    }
}
