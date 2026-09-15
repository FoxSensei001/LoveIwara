package m.c.g.a.i_iwara.vr

import android.content.ContextWrapper
import android.content.SharedPreferences
import m.c.g.a.i_iwara.questui.EnvironmentKind
import m.c.g.a.i_iwara.questui.EnvironmentSettings
import m.c.g.a.i_iwara.questui.VideoControlsState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class PlayerPrefsTest {
    @Test fun everyEnvironmentSurvivesRestartAndPerVideoResetWithoutChangingRoomVisibility() {
        for (kind in EnvironmentKind.entries) {
            val storage = MemoryPreferences()
            val expected = EnvironmentSettings(kind, .28f, dynamicSpace = true, showMoon = false)
            val state = VideoControlsState().apply {
                environment = expected
                mediaEffects = mediaEffects.copy(backgroundTransparency = .71f)
            }
            prefs(storage).save(state)
            val restored = VideoControlsState()
            prefs(MemoryPreferences(storage.all)).load(restored)
            restored.resetPerVideoSettings()
            assertEquals(expected, restored.environment)
            assertEquals(.71f, restored.mediaEffects.backgroundTransparency, 0f)
        }
    }

    @Test fun anUnknownFutureEnvironmentFallsBackToTheRoom() {
        val state = VideoControlsState()
        prefs(MemoryPreferences(mapOf("backgroundEnvironment" to "FUTURE_WORLD"))).load(state)
        assertEquals(EnvironmentKind.PASSTHROUGH, state.environment.kind)
    }

    @Test fun newAndExistingProfilesWithoutSpaceOptionsStartStaticWithBothBodies() {
        for (stored in listOf(emptyMap(), mapOf("backgroundEnvironment" to "DEEP_SPACE"))) {
            val state = VideoControlsState()
            prefs(MemoryPreferences(stored)).load(state)
            assertFalse(state.environment.dynamicSpace)
            assertTrue(state.environment.showEarth)
            assertTrue(state.environment.showMoon)
            assertEquals(stored["backgroundEnvironment"] ?: "PASSTHROUGH", state.environment.kind.name)
        }
    }

    @Test fun everyVisibilityAndMotionChoiceSurvivesSavingIntoFreshStateAndPreferences() {
        for (dynamic in listOf(false, true)) for (earth in listOf(false, true)) for (moon in listOf(false, true)) {
            val storage = MemoryPreferences()
            val expected = EnvironmentSettings(EnvironmentKind.DEEP_SPACE, 0.37f, dynamic, earth, moon)
            val state = VideoControlsState().apply { environment = expected }
            prefs(storage).save(state)
            // A new preferences object sees only stored values, never the old UI state.
            val restored = VideoControlsState()
            prefs(MemoryPreferences(storage.all)).load(restored)
            assertEquals(expected, restored.environment)
            restored.resetPerVideoSettings()
            assertEquals(expected, restored.environment)
        }
    }

    @Test fun returningThroughPassthroughRetainsTheLatestIndependentBodyChoices() {
        val storage = MemoryPreferences()
        val writer = prefs(storage)
        val state = VideoControlsState().apply {
            environment = EnvironmentSettings(EnvironmentKind.DEEP_SPACE, dynamicSpace = true, showEarth = false)
        }
        writer.save(state)
        state.environment = state.environment.copy(kind = EnvironmentKind.PASSTHROUGH, dynamicSpace = false, showMoon = false)
        writer.save(state)
        val restored = VideoControlsState()
        prefs(MemoryPreferences(storage.all)).load(restored)
        restored.environment = restored.environment.copy(kind = EnvironmentKind.DEEP_SPACE).normalized()
        assertEquals(EnvironmentSettings(EnvironmentKind.DEEP_SPACE, dynamicSpace = false, showEarth = false, showMoon = false), restored.environment)
    }

    private fun prefs(storage: SharedPreferences) = PlayerPrefs(object : ContextWrapper(null) {
        override fun getSharedPreferences(name: String, mode: Int): SharedPreferences {
            assertEquals("xr_player_v2", name)
            return storage
        }
    })

    /** Tests the real preference codec; Android's asynchronous disk I/O needs a device. */
    private class MemoryPreferences(initial: Map<String, *> = emptyMap<String, Any>()) : SharedPreferences {
        private val values = initial.toMutableMap()
        override fun getAll(): Map<String, *> = values.toMap()
        override fun getString(key: String, defValue: String?): String? = values[key] as String? ?: defValue
        @Suppress("UNCHECKED_CAST")
        override fun getStringSet(key: String, defValues: Set<String>?): Set<String>? = values[key] as Set<String>? ?: defValues
        override fun getInt(key: String, defValue: Int) = values[key] as Int? ?: defValue
        override fun getLong(key: String, defValue: Long) = values[key] as Long? ?: defValue
        override fun getFloat(key: String, defValue: Float) = values[key] as Float? ?: defValue
        override fun getBoolean(key: String, defValue: Boolean) = values[key] as Boolean? ?: defValue
        override fun contains(key: String) = values.containsKey(key)
        override fun registerOnSharedPreferenceChangeListener(listener: SharedPreferences.OnSharedPreferenceChangeListener) = Unit
        override fun unregisterOnSharedPreferenceChangeListener(listener: SharedPreferences.OnSharedPreferenceChangeListener) = Unit
        override fun edit(): SharedPreferences.Editor = object : SharedPreferences.Editor {
            private val pending = mutableMapOf<String, Any?>()
            private var clearFirst = false
            override fun putString(key: String, value: String?) = apply { pending[key] = value }
            override fun putStringSet(key: String, values: Set<String>?) = apply { pending[key] = values?.toSet() }
            override fun putInt(key: String, value: Int) = apply { pending[key] = value }
            override fun putLong(key: String, value: Long) = apply { pending[key] = value }
            override fun putFloat(key: String, value: Float) = apply { pending[key] = value }
            override fun putBoolean(key: String, value: Boolean) = apply { pending[key] = value }
            override fun remove(key: String) = apply { pending[key] = null }
            override fun clear() = apply { clearFirst = true }
            override fun commit(): Boolean {
                if (clearFirst) values.clear()
                for ((key, value) in pending) if (value == null) values.remove(key) else values[key] = value
                return true
            }
            override fun apply() { commit() }
        }
    }
}
