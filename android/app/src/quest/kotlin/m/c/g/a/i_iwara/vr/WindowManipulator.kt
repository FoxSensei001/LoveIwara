package m.c.g.a.i_iwara.vr

import android.util.Log
import com.meta.spatial.core.Entity
import com.meta.spatial.core.Hand
import com.meta.spatial.core.Pose
import com.meta.spatial.core.Quaternion
import com.meta.spatial.core.SystemManager
import com.meta.spatial.core.Vector2
import com.meta.spatial.core.Vector3
import com.meta.spatial.isdk.IsdkCurvedPanel
import com.meta.spatial.isdk.IsdkDefaultCursorSystem
import com.meta.spatial.isdk.IsdkPanelDimensions
import com.meta.spatial.isdk.IsdkSystem
import com.meta.spatial.runtime.DepthWrite
import com.meta.spatial.runtime.PanelConfigOptions
import com.meta.spatial.runtime.PanelSceneObject
import com.meta.spatial.runtime.PanelShapeLayerBlendType
import com.meta.spatial.runtime.PointerEvent
import com.meta.spatial.runtime.PointerEventType
import com.meta.spatial.toolkit.CylinderShapeOptions
import com.meta.spatial.toolkit.DpPerMeterDisplayOptions
import com.meta.spatial.toolkit.Panel
import com.meta.spatial.toolkit.PanelRenderMode
import com.meta.spatial.toolkit.PanelStyleOptions
import com.meta.spatial.toolkit.QuadShapeOptions
import com.meta.spatial.toolkit.SceneObjectSystem
import com.meta.spatial.toolkit.Scale
import com.meta.spatial.toolkit.Transform
import com.meta.spatial.toolkit.UIPanelRenderOptions
import com.meta.spatial.toolkit.UIPanelSettings
import com.meta.spatial.toolkit.UIPanelShapeOptions
import com.meta.spatial.toolkit.Visible
import com.meta.spatial.toolkit.getAbsoluteTransform
import m.c.g.a.i_iwara.questui.WindowFrameState
import m.c.g.a.i_iwara.questui.WindowFrameZone
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin
import kotlin.math.sqrt

/** 空间里的三块窗。 */
enum class WindowKind { UI, CONTROLS, SCREEN }

/** 拉角时怎么变：锁比例（沿对角线等比）还是自由（宽高各自拉）。 */
enum class ResizePolicy { ASPECT_LOCKED, FREE }

/**
 * 一块能被抓、挪、缩放的窗。几何上的「窗」= 内容面板的**可见面**（quad 就是自己，圆柱幕是弧面），
 * 位置用弧面中心表达；换算到实体锚点（圆柱轴心）是宿主自己的事。
 */
interface WindowHost {
    val kind: WindowKind
    val resizePolicy: ResizePolicy

    /** 内容面板的尺寸上下限（米）。 */
    val minSize: Vector2
    val maxSize: Vector2

    /**
     * 内容面板**此刻**自己的圆角（米），x / y 分开给；窗框的角把手就顺着它画。
     *
     * ⛔ 两条都是「此刻」：
     * - 跟着缩放走 —— 面板放大两倍，它的圆角在世界里也是两倍，窗框不跟就对不上；
     * - 分轴 —— 2D 应用面板拖动中先被非等比 `Scale` 拉伸（松手才按新像素重排），
     *   那期间内容自己的圆角本来就是椭圆的。
     *
     * 零 = 内容是直角（视频幕布 / 图库图片都走合成层，圆不了角），窗框会把角画成利落的直角。
     */
    fun cornerRadiusM(): Vector2 = Vector2(0f, 0f)

    /** 内容面板的合成层次序；窗框排在它后面一层。 */
    val zIndex: Int

    /** 可见面的中心位姿（朝向 = 面板朝向）；不在场 / 藏起来时为 null，窗框也跟着停走。 */
    fun surfacePose(): Pose?

    /** 内容面板当前的宽高（米）。 */
    fun size(): Vector2

    /** 弧幕的弧度；0 = 平面。 */
    fun arcDegrees(): Float = 0f

    fun moveTo(surface: Pose)

    /** 拉角：新的尺寸 + 新的面中心。拖动中每帧一次（commit=false），松手再来一次 commit=true。 */
    fun resizeTo(size: Vector2, surface: Pose, commit: Boolean)

    /** 用户碰了这块窗（悬停在窗框 / 抓着）：宿主拿去续空闲计时之类。 */
    fun onInteraction() {}

    /** 一次抓着挪结束了（松开抓握扳机 / 扳机）。[byGrip] = 是抓握扳机抓的。缩放结束不走这里。 */
    fun onMoveReleased(byGrip: Boolean) {}
}

/**
 * 三块窗共用的抓取 / 挪动 / 缩放系统，取代 ISDK 自带的 `Grabbable` + `IsdkPanelResize`。
 *
 * # 为什么不用 ISDK 的
 *
 * ISDK 的面板抓取只认**边缘抓条**：光标在窗体上时抓握扳机没反应，得先把光标挪到边上才能拖
 * （用户 2026-09-05：「不符合直觉，光标在面板上时就要能拖」）。四角缩放与四边拉伸的外观也改不了。
 * 所以三块窗都摘掉 `Grabbable` / `IsdkPanelResize`，改成：
 *
 * - **手柄抓握扳机**按在窗体（内容面板）上 = 抓着挪；影院态里按下抓握扳机**不用瞄准**就抓幕布
 *   （[startGrab]，用户 2026-09-05：「点击该按钮后可对播放器拖拽，松开时隐藏操作栏」）；
 * - 每块窗后方 1cm 贴一块自绘窗框（`questui/WindowFrameView.kt`）：抓握扳机 / 扳机 / 捏合按在
 *   **四条边**上 = 挪，按在**四个角**上 = 缩放（以窗中心为原点；锁比例的沿对角线等比，2D 应用面板自由拉）；
 * - 挪的时候三块窗都按当前观察位置更新俯仰与偏航（SDK FACE 行为）；摇杆上下推远拉近。
 *
 * # 几何怎么算
 *
 * 射线来源用 ISDK 报过的指针实体（`PointerEvent.source`，与光标同一条射线），没报过时退回手 / 手柄实体。
 * 命中与高亮都来自本帧、对应手的射线。Compose / ISDK 的 Exit 可能不送达，缓存的高亮绝不能作为抓取兜底。
 * 一旦真正抓住，才允许射线离开窗框继续拖；松手后下次捏合必须重新命中。
 *
 * # 尺寸怎么落地
 *
 * 与 ISDK 的做法一致：等比缩放的窗只改 `Scale`；能重排的 2D 应用面板拖动中先 `Scale`，松手时
 * `PanelSceneObject.resize(px)` 让 Activity 按新像素重排（`Scale` 留着，dp/m 不变）。幕布走宿主自己的
 * `reshape` 流水线。具体在各 [WindowHost] 里。
 *
 * # ⛔ 两条继承来的铁律
 *
 * 1. `Visible(false)` 不影响 ISDK 命中（§19 事实 6）：窗框藏 = 停到脚下 100m；摘窗框 = 先停走、隔 3 帧再销毁。
 * 2. ECS `Transform` 晚一帧生效（事实 3）：跟着窗体走的位姿同时直接写到场景对象上。
 */
class WindowManipulator(
    private val systemManager: SystemManager,
    private val frameIds: Map<WindowKind, Int>,
    /** 以 forward 为前向搭一个去 roll 的坐标系（拿宿主的四元数约定自检来算）。 */
    private val basisPose: (origin: Vector3, forward: Vector3) -> Pose,
    /** 摆在 position 的窗应当朝哪：面向头部；头部没跟踪到返回 null（保持原朝向）。 */
    private val faceViewer: (position: Vector3) -> Quaternion?,
) {

    /** 一条射线：起点 + 单位方向。 */
    class PointerRay(val origin: Vector3, val direction: Vector3)

    private class Slot(val host: WindowHost, val state: WindowFrameState) {
        var frameEntity: Entity? = null
        var framePanel: PanelSceneObject? = null

        /** 窗框现在是按这个内容尺寸 / 弧度建的；变了就 reshape。 */
        var frameSize = Vector2(0f, 0f)
        var frameArc = 0f
        var parked = true
        /** Content size the current Scale / ISDK shape / metrics were applied for. */
        var appliedSize = Vector2(0f, 0f)
        /** Ticks to wait before [createFrame] after the previous entity was destroyed; 0 = none pending. */
        var rebuildInTicks = 0
        /** The compositor order was applied to a live layer (see [orderLayer]). */
        var layerOrdered = false
        /** Pose last written to [frameEntity]; an unchanged window must not dirty its Transform every tick. */
        var appliedPose: Pose? = null
        var appliedPoseEntity: Entity? = null
        /** framePanel arrives asynchronously after the entity; it needs its own first write. */
        var appliedPosePanel: PanelSceneObject? = null
    }

    private class Hit(
        val slot: Slot,
        val zone: WindowFrameZone,
        /** 面内本地坐标（米）：x 向右、y 向上，原点在面中心；弧幕的 x 是弧长。 */
        val local: Vector2,
        val distance: Float,
    )

    private class Session(val hand: Int, val slot: Slot, val zone: WindowFrameZone, val byGrip: Boolean) {
        // 挪：面中心在射线坐标系里的偏移，松手前保持不变
        var localOffset = Vector3(0f, 0f, 0f)
        var rotation = Quaternion(0f, 0f, 0f)

        // 缩放：固定的拖动平面，不受可见曲面的边界或圆柱切线限制。
        var startSurface = Pose()
        var startSize = Vector2(1f, 1f)
        var resizePlane = Pose()
        var resizeStart = Vector2(0f, 0f)
        var resizeWidthProjection = 1f
        var signX = 1f
        var signY = 1f
        var lastSize: Vector2? = null
        var lastSurface: Pose? = null
    }

    private val states: Map<WindowKind, WindowFrameState> = WindowKind.entries.associateWith { WindowFrameState() }
    private val slots = LinkedHashMap<WindowKind, Slot>()
    private val doomed = ArrayList<Pair<Entity, IntArray>>()
    private val hits = arrayOfNulls<Hit>(2)
    private val sessions = arrayOfNulls<Session>(2)

    /** ISDK 最近一次报过的每只手的指针实体（与光标同一条射线）。 */
    private val raySource = arrayOfNulls<Entity>(2)
    private var isdk: IsdkSystem? = null
    private var rayChecksLogged = 0
    private val observer: (PointerEvent) -> Unit = { ev -> onPointerEvent(ev) }

    /** 窗框面板注册时拿这个（`createWindowFrameView(ctx, frameState(kind))`）。 */
    fun frameState(kind: WindowKind): WindowFrameState = states.getValue(kind)

    /** 有没有哪只手正抓着窗挪（摇杆此时归推远拉近）。 */
    val isMoving: Boolean
        get() = sessions.any { it != null && it.zone.movesWindow }

    fun isMoving(hand: Int): Boolean = sessions[hand]?.zone?.movesWindow == true

    /** 这只手此刻是否在抓着某块窗（挪或缩放）。 */
    fun isBusy(hand: Int): Boolean = sessions[hand] != null

    /** 这只手的射线此刻落在哪块窗的哪个区（含窗体 BODY）；什么都没碰到 = NONE。 */
    fun zoneUnder(hand: Int): WindowFrameZone = hits[hand]?.zone ?: WindowFrameZone.NONE

    /** Placement outside a grab update must move the frame in the same scene tick. */
    fun syncFrame(kind: WindowKind) {
        slots[kind]?.let { syncFrame(it) }
    }

    // ================================================================ 生命周期

    fun onSceneReady() {
        isdk = runCatching { systemManager.findSystem<IsdkSystem>() }.getOrNull()
        isdk?.registerObserver(observer)
        // ISDK draws its cursor in the scene, offset 1cm from the hit surface by default.
        // Our frame sits 1.2cm behind the picture: a frame hit can leave that cursor under
        // the picture near a curved edge. Keep the native cursor ahead of both surfaces.
        runCatching {
            systemManager.findSystem<IsdkDefaultCursorSystem>().cursorConfigZOffset = BEHIND_M + 0.01f
        }.onFailure { Log.w(TAG, "IMMERSIVE cursor depth configuration failed", it) }
    }

    fun shutdown() {
        runCatching { isdk?.unregisterObserver(observer) }
        isdk = null
        for (i in 0..1) sessions[i] = null
        for (kind in slots.keys.toList()) detachNow(kind)
        for ((entity, _) in doomed) runCatching { entity.destroy() }
        doomed.clear()
    }

    /** Recenter/focus loss cancels, rather than committing an old resize or hiding the controls. */
    fun cancelAll() {
        for (i in 0..1) {
            sessions[i]?.slot?.state?.activeZone = WindowFrameZone.NONE
            sessions[i] = null
            hits[i] = null
            raySource[i] = null
        }
        for (slot in slots.values) {
            slot.state.activeZone = WindowFrameZone.NONE
            slot.state.pointerZone = WindowFrameZone.NONE
            slot.state.nearEdge = false
        }
    }

    /** 窗体建好了：给它配一块窗框。同一种窗重复 attach 会先摘掉旧的。 */
    fun attach(host: WindowHost) {
        detachNow(host.kind)
        val slot = Slot(host, states.getValue(host.kind))
        slots[host.kind] = slot
        createFrame(slot)
    }

    /** 窗体没了：窗框先停走，隔几帧再销毁（让 ISDK 清掉悬停态）。 */
    fun detach(kind: WindowKind) {
        val slot = slots.remove(kind) ?: return
        endSessionsOn(slot)
        val entity = slot.frameEntity ?: return
        entity.setComponent(Visible(false))
        entity.setComponent(Transform(PARKED_POSE))
        doomed.add(entity to intArrayOf(DOOMED_TICKS))
        slot.frameEntity = null
        slot.framePanel = null
        slot.state.pointerZone = WindowFrameZone.NONE
        slot.state.nearEdge = false
        slot.state.activeZone = WindowFrameZone.NONE
    }

    private fun detachNow(kind: WindowKind) {
        val slot = slots.remove(kind) ?: return
        endSessionsOn(slot)
        slot.frameEntity?.destroy()
        slot.frameEntity = null
        slot.framePanel = null
        slot.state.pointerZone = WindowFrameZone.NONE
        slot.state.nearEdge = false
        slot.state.activeZone = WindowFrameZone.NONE
    }

    private fun endSessionsOn(slot: Slot) {
        for (i in 0..1) if (sessions[i]?.slot === slot) sessions[i] = null
    }

    /** 窗框面板的注册用：形状取内容面板此刻的尺寸 + 一圈边。 */
    fun frameSettings(kind: WindowKind): UIPanelSettings {
        val slot = slots[kind]
        val size = slot?.host?.size() ?: Vector2(1f, 1f)
        val arc = slot?.host?.arcDegrees() ?: 0f
        return UIPanelSettings(
            shape = frameShape(size, arc),
            display = DpPerMeterDisplayOptions(dpPerMeter = FRAME_DP_PER_METER),
            rendering = UIPanelRenderOptions(
                renderMode = PanelRenderMode.Layer(layerBlendType = PanelShapeLayerBlendType.ALPHA_BLEND),
            ),
            style = FrameMeshStyle,
        )
    }

    /**
     * ⛔ 窗框的像素只许由合成层画，场景网格只留几何、不写颜色（与媒体面板同一招，见 `MediaEffectsRenderer.style`）。
     *
     * Layer 模式的面板除了合成层，还有一块场景网格往眼缓冲里画一份。两份各有各的缩放语义，
     * 拖角时总有一份跟不上幕布（用户 2026-09-13，曲面幕布，前后两次）：
     * - 用 `Scale` 拉：网格按几何缩放、贴着幕布，圆柱合成层却不认 Scale、飘向镜头；
     * - 用 `reshape()`：SDK 只重建 `PanelShape`（合成层），**网格不动**（`PanelSceneObject.reshape`
     *   字节码里只有 PanelShape.destroy / new PanelShape），暗色的旧网格就留在原尺寸上偏离幕布。
     *   换网格也换不动：`setSceneMesh` 运行时不生效（光晕那次真机证过）。
     * 平面幕布之所以两种都没事，是 quad 层认 Scale。只要网格不出颜色，残影就无从谈起。
     */
    private object FrameMeshStyle : PanelStyleOptions() {
        override fun applyTo(options: PanelConfigOptions) {
            super.applyTo(options)
            val createMesh = options.generateSceneMeshCreator()
            options.sceneMeshCreator = { config, texture ->
                createMesh(config, texture).also { mesh ->
                    mesh.getMaterial(0)?.let { material ->
                        material.setColorWrite(0)
                        material.setDepthWrite(DepthWrite.DISABLE)
                    }
                }
            }
        }
    }

    private fun frameShape(size: Vector2, arc: Float): UIPanelShapeOptions {
        val w = size.x + 2f * RING_M
        val h = size.y + 2f * RING_M
        if (arc >= ScreenGeometry.MIN_ARC_DEGREES) {
            val r = ScreenGeometry.radiusFor(arc, size.x)
            val rf = r + BEHIND_M
            return CylinderShapeOptions(radius = rf, width = w * rf / r, height = h)
        }
        return QuadShapeOptions(width = w, height = h)
    }

    private fun createFrame(slot: Slot) {
        val host = slot.host
        val id = frameIds[host.kind] ?: return
        val surface = host.surfacePose()
        val size = host.size()
        val arc = host.arcDegrees()
        slot.frameSize = size
        slot.frameArc = arc
        slot.appliedSize = size
        val pose = surface?.let { framePose(it, size, arc) } ?: PARKED_POSE
        val entity = Entity.create(Panel(id), Transform(pose), Visible(surface != null))
        slot.frameEntity = entity
        slot.parked = surface == null
        syncIsdkShape(entity, size, arc)
        updateFrameMetrics(slot, size)
        slot.state.activeZone = WindowFrameZone.NONE
        slot.layerOrdered = false
        systemManager.findSystem<SceneObjectSystem>().getSceneObject(entity)?.thenAccept { so ->
            slot.framePanel = so as? PanelSceneObject
            orderLayer(slot)
        }
    }

    /**
     * ⛔ `panel.layer` is still null when the scene object future completes, so ordering
     * the layer there silently did nothing; the frame only got its z-index after the
     * first reshape(). With the ambience halo in the eye buffer, an unordered frame is
     * composited behind the scene and never seen. Retry every tick until the layer exists.
     */
    private fun orderLayer(slot: Slot) {
        if (slot.layerOrdered) return
        val layer = slot.framePanel?.layer ?: return
        runCatching { layer.setZIndex(frameZIndex(slot.host)) }
            .onSuccess { slot.layerOrdered = true }
            .onFailure { Log.w(TAG, "IMMERSIVE frame layer order failed kind=${slot.host.kind}", it) }
    }

    /**
     * Compositor order of the frame: one below its host, as it always was for the 2D panel
     * and the controls, but never below 0. The screen's frame used to land at −1, and layers
     * below 0 are composited BEHIND the eye buffer, where the media ambience halo now lives
     * with near-opaque alpha right around the picture, hiding the lit handles. At 0 it shares
     * the screen's z-index and depth sorting keeps it behind the picture (BEHIND_M). Putting
     * frames ABOVE their host was tried and reverted: the 2D panel's cursor stopped landing
     * on the panel after a resize.
     */
    private fun frameZIndex(host: WindowHost): Int = maxOf(0, host.zIndex - 1)

    /**
     * Replace the frame entity for the host's current size and arc. The old entity is
     * destroyed synchronously: a doomed old entity overlapping the new one of the same
     * panel id for three ticks left the new frame blank on Quest 3. Nobody hovers a frame
     * at the moment its owner lets go of a corner, so the ISDK hover-clearing grace period
     * that [detach] needs does not apply here.
     */
    private fun rebuildFrame(slot: Slot) {
        slot.frameEntity?.let { old -> runCatching { old.destroy() } }
        slot.frameEntity = null
        slot.framePanel = null
        // Creating the replacement in the same tick as the destroy left it blank as well:
        // give the scene object system a few ticks to retire the old panel of this id first.
        slot.rebuildInTicks = REBUILD_GAP_TICKS
    }

    /** 窗框实体的位姿：平面贴在面后 [BEHIND_M]；弧幕与幕布同轴心（半径大 [BEHIND_M]）。 */
    private fun framePose(surface: Pose, size: Vector2, arc: Float): Pose {
        val f = surface.forward()
        if (arc >= ScreenGeometry.MIN_ARC_DEGREES) {
            val r = ScreenGeometry.radiusFor(arc, size.x)
            return Pose(surface.t - f * r, surface.q)
        }
        return Pose(surface.t + f * BEHIND_M, surface.q)
    }

    private fun syncIsdkShape(entity: Entity, size: Vector2, arc: Float) {
        val w = size.x + 2f * RING_M
        val h = size.y + 2f * RING_M
        if (arc >= ScreenGeometry.MIN_ARC_DEGREES) {
            val r = ScreenGeometry.radiusFor(arc, size.x)
            entity.setComponent(IsdkPanelDimensions(Vector2(w * (r + BEHIND_M) / r, h)))
            // The frame includes the outer ring, so its angular span is wider than the content's.
            entity.setComponent(IsdkCurvedPanel(Math.toDegrees((w / r).toDouble()).toFloat()))
        } else {
            entity.setComponent(IsdkPanelDimensions(Vector2(w, h)))
            runCatching { entity.removeComponent<IsdkCurvedPanel>() }
        }
    }

    /**
     * 把窗框要画 / 要判定的几何**按米**交给面板。
     *
     * ⛔ 别再换算成「占整幅的比例」：窗框面板的画布 `reshape()` 换不掉（§19 续十二），窗被拉长时
     * 画布是被非等比抻开的，只有米数能让面板把粗细与圆角还原成人眼里的同一档（见 `WindowFrameState`）。
     */
    private fun updateFrameMetrics(slot: Slot, size: Vector2) {
        val s = slot.state
        s.widthM = size.x + 2f * RING_M
        s.heightM = size.y + 2f * RING_M
        s.ringM = RING_M
        s.cornerZoneM = CORNER_M
        val r = slot.host.cornerRadiusM()
        s.cornerRadiusXM = r.x
        s.cornerRadiusYM = r.y
        s.freeResize = slot.host.resizePolicy == ResizePolicy.FREE
    }

    // ================================================================ 每帧

    fun tick(input: SpatialInputPoller) {
        reapDoomed()
        for (slot in slots.values) {
            if (slot.rebuildInTicks > 0 && --slot.rebuildInTicks == 0) createFrame(slot)
            syncFrame(slot)
        }
        for (hand in 0..1) hits[hand] = computeHit(hand, input)
        for (slot in slots.values) {
            slot.state.pointerZone = hits.firstOrNull { hit ->
                hit != null && hit.slot === slot && (hit.zone.isEdge || hit.zone.isCorner)
            }?.zone ?: WindowFrameZone.NONE
            // 光标在窗体里操作应用时窗框不露面；只有贴近窗沿（离边 < NEAR_EDGE_M）才提前亮起来。
            slot.state.nearEdge = hits.any { hit ->
                hit != null && hit.slot === slot && hit.zone == WindowFrameZone.BODY && run {
                    val half = slot.host.size() / 2f
                    abs(hit.local.x) > half.x - NEAR_EDGE_M || abs(hit.local.y) > half.y - NEAR_EDGE_M
                }
            }
            if (slot.state.pointerZone != WindowFrameZone.NONE) slot.host.onInteraction()
        }
        val e = input.events
        for (hand in 0..1) {
            val session = sessions[hand]
            if (session != null) {
                val held = if (session.byGrip) input.gripHeld[hand] else input.selectHeld[hand]
                if (held) updateSession(session, input) else endSession(hand)
                continue
            }
            val bit = 1 shl hand
            when {
                (e.gripDown and bit) != 0 -> tryStart(hand, byGrip = true, input)
                (e.selectDown and bit) != 0 -> tryStart(hand, byGrip = false, input)
            }
        }
        for (slot in slots.values) {
            slot.state.activeZone = sessions.firstOrNull { it?.slot === slot }?.zone ?: WindowFrameZone.NONE
        }
    }

    /**
     * 不用瞄准、直接抓住 [kind] 那块窗挪（影院态抓握扳机按下就拖幕布）。
     * 窗跟着手柄射线刚性走（面中心在射线坐标系里的偏移固定），与瞄准抓到窗体时完全同一套。
     * @return false = 这只手已经在抓别的窗（tick 里瞄准命中的先裁决）/ 窗不在场 / 读不到射线。
     */
    fun startGrab(hand: Int, kind: WindowKind, input: SpatialInputPoller): Boolean {
        if (sessions[hand] != null) return false
        val slot = slots[kind] ?: return false
        val ray = rayFor(hand, input) ?: return false
        val surface = slot.host.surfacePose() ?: return false
        val session = Session(hand, slot, WindowFrameZone.BODY, byGrip = true)
        val rp = basisPose(ray.origin, ray.direction)
        session.localOffset = rp.q.inverse() * (surface.t - rp.t)
        session.rotation = surface.q
        sessions[hand] = session
        slot.state.activeZone = WindowFrameZone.BODY
        slot.host.onInteraction()
        Log.i(TAG, "IMMERSIVE window grab (blind) kind=$kind hand=$hand")
        return true
    }

    /** 强制结束这只手的会话（两手抓取缩放接管时）。挪动中的按松手处理、缩放中的按当前尺寸落地。 */
    fun release(hand: Int) = endSession(hand)

    /** 挪动中：摇杆上下把窗沿射线推远 / 拉近。 */
    fun nudgeDistance(delta: Float, hands: Int = 0b11) {
        for (hand in 0..1) {
            if (hands and (1 shl hand) == 0) continue
            val session = sessions[hand]
            if (session == null || !session.zone.movesWindow) continue
            val len = session.localOffset.length()
            if (len < 1e-3f) continue
            val next = (len * (1f + delta)).coerceIn(MIN_DISTANCE_M, MAX_DISTANCE_M)
            session.localOffset = session.localOffset * (next / len)
        }
    }

    private fun reapDoomed() {
        val it = doomed.iterator()
        while (it.hasNext()) {
            val (entity, ticks) = it.next()
            if (--ticks[0] > 0) continue
            runCatching { entity.destroy() }
            it.remove()
        }
    }

    private fun syncFrame(slot: Slot) {
        val host = slot.host
        val entity = slot.frameEntity ?: return
        orderLayer(slot)
        val surface = host.surfacePose()
        if (surface == null) {
            if (!slot.parked) {
                entity.setComponent(Visible(false))
                entity.setComponent(Transform(PARKED_POSE))
                slot.framePanel?.setPosition(PARKED_POSE.t)
                slot.parked = true
                slot.state.pointerZone = WindowFrameZone.NONE
            }
            return
        }
        val size = host.size()
        val arc = host.arcDegrees()
        val sizeChanged = abs(size.x - slot.appliedSize.x) > SIZE_EPS_M || abs(size.y - slot.appliedSize.y) > SIZE_EPS_M
        val arcChanged = abs(arc - slot.frameArc) > 0.5f
        if (sizeChanged || arcChanged) {
            // ⛔ Never reshape() the frame's compositor layer (Quest 3, SDK 0.13.2, 2026-09-09):
            // reshape destroys and recreates the layer, and a burst of those during a corner
            // drag left the runtime either drawing a stale layer at the pre-drag size next to
            // the live one ("two sets of handles") or drawing no frame at all. Destroying and
            // recreating the entity on release was not safe either: a released layer could
            // linger with its last image until the next layer change, which showed up as the
            // same stale frame during the following drag. So a size change never touches a
            // layer: the entity is stretched with Scale (the frame view draws in metres, so its
            // ring stays RING_M wide), and the entity is rebuilt only when the arc changes or
            // the stretch leaves [1/REBUILD_SCALE_LIMIT, REBUILD_SCALE_LIMIT], where the canvas
            // would get too coarse. Those rebuilds happen at rest, never mid-gesture.
            //
            // Only the FLAT screen's frame takes this path. The 2D panel's and the controls' frames
            // keep the original reshape(): their behaviour was right, and the 2D panel's cursor
            // misbehaved after a resize once its frame carried a Scale (reverted 2026-09-09).
            //
            // ⛔ A CURVED screen frame must not be stretched with Scale either (user 2026-09-13:
            // dragging a corner of the curved stage made the handles fly toward the camera while a
            // dark copy of them stayed on the stage's corners). Scale reaches two things: the panel's
            // hole-punch mesh in the eye buffer, which scales geometrically and stays on the stage
            // (the dark copy), and the SDK cylinder compositor layer, which does not treat Scale as a
            // geometric scale (`SceneLayer.setScale` → native; same failure as the curved 2D panel,
            // see `uiHost.resizeTo`) and drifts off (the lit handles). Quad layers do honour Scale
            // (the controls panel resizes this way and is fine), so only flat frames stay here;
            // curved ones take the reshape path, exactly like the curved 2D panel's frame.
            // An arc change still enters this branch: it rebuilds, which also drops any Scale a
            // flat frame was carrying before it turns curved.
            if (host.kind == WindowKind.SCREEN && (arcChanged || arc < ScreenGeometry.MIN_ARC_DEGREES)) {
                val sx = (size.x + 2f * RING_M) / (slot.frameSize.x + 2f * RING_M)
                val sy = (size.y + 2f * RING_M) / (slot.frameSize.y + 2f * RING_M)
                // z follows x like the 2D panel's own Scale: a cylinder frame stays a true
                // cylinder only when x and z scale together, otherwise it leaves the panel's edge.
                val scale = Vector3(sx, sy, sx)
                val resizing = sessions.any { it?.slot === slot && !it.zone.movesWindow }
                val tooCoarse = maxOf(scale.x, scale.y) > REBUILD_SCALE_LIMIT ||
                    minOf(scale.x, scale.y) < 1f / REBUILD_SCALE_LIMIT
                if (arcChanged || (tooCoarse && !resizing)) {
                    rebuildFrame(slot)
                    return
                }
                entity.setComponent(Scale(scale))
                slot.framePanel?.setScale(scale)
            } else {
                slot.frameSize = size
                slot.frameArc = arc
                slot.framePanel?.let { panel ->
                    runCatching {
                        panel.reshape(frameSettings(host.kind).toPanelConfigOptions())
                        // reshape replaces the compositor layer; its runtime ordering is not retained.
                        panel.layer?.setZIndex(frameZIndex(host))
                    }
                        .onFailure { Log.w(TAG, "IMMERSIVE frame reshape 失败 kind=${host.kind}", it) }
                }
            }
            slot.appliedSize = size
            // reshape / Scale may rebuild what the runtime holds: never trust the cached pose across them.
            slot.appliedPose = null
            syncIsdkShape(entity, size, arc)
            updateFrameMetrics(slot, size)
        }
        val pose = framePose(surface, size, arc)
        val panel = slot.framePanel
        if (slot.parked || pose != slot.appliedPose || entity !== slot.appliedPoseEntity || panel !== slot.appliedPosePanel) {
            entity.setComponent(Transform(pose))
            slot.framePanel?.let {
                it.setPosition(pose.t)
                it.setRotationQuat(pose.q)
            }
            slot.appliedPose = pose
            slot.appliedPoseEntity = entity
            slot.appliedPosePanel = panel
        }
        if (slot.parked) {
            entity.setComponent(Visible(true))
            slot.parked = false
        }
    }

    // ================================================================ 射线与命中

    /** 这只手此刻的射线（ISDK 光标那条；没报过就退回手 / 手柄位姿）。球幕拖视角也用它。 */
    fun ray(hand: Int, input: SpatialInputPoller): PointerRay? = rayFor(hand, input)

    private fun rayFor(hand: Int, input: SpatialInputPoller): PointerRay? {
        if (!input.handActive[hand]) {
            raySource[hand] = null
            return null
        }
        val source = raySource[hand]
        val pose = source?.let { runCatching { getAbsoluteTransform(it) }.getOrNull() }
            ?: input.handPoses[hand]
            ?: return null
        val dir = pose.forward()
        if (dir.length() < 1e-4f) return null
        return PointerRay(pose.t, dir.normalize())
    }

    /**
     * 射线 × 任意一块窗面：命中点的**面内本地坐标**（米，原点在面心、x 向右、y 向上），
     * 打不到或打在面外为 null。
     *
     * 给 `:app` 的「幕布上横拖翻片」用（视频幕布没有 Compose 手势层，只能这么算）。
     * ⛔ 别再另写一份求交：平面 / 弧面两种形状的公式就在 [intersect]，抓窗与拉角一直用的是它。
     */
    fun surfaceHit(hand: Int, input: SpatialInputPoller, surface: Pose, size: Vector2, arc: Float): Vector2? {
        val ray = rayFor(hand, input) ?: return null
        val local = intersect(ray, surface, size, arc) ?: return null
        if (abs(local.x) > size.x / 2f || abs(local.y) > size.y / 2f) return null
        return Vector2(local.x, local.y)
    }

    private fun computeHit(hand: Int, input: SpatialInputPoller): Hit? {
        val ray = rayFor(hand, input) ?: return null
        var best: Hit? = null
        for (slot in slots.values) {
            if (slot.parked) continue
            val surface = slot.host.surfacePose() ?: continue
            val size = slot.host.size()
            val arc = slot.host.arcDegrees()
            val local = intersect(ray, surface, size, arc) ?: continue
            val totalW = size.x + 2f * RING_M
            val totalH = size.y + 2f * RING_M
            val fx = (local.x + totalW / 2f) / totalW
            val fy = (totalH / 2f - local.y) / totalH
            val zone = slot.state.classify(fx, fy)
            if (zone == WindowFrameZone.NONE) continue
            if (best == null || local.z < best.distance) {
                best = Hit(slot, zone, Vector2(local.x, local.y), local.z)
            }
        }
        return best
    }

    /** 射线 × 窗面。返回 (本地 x, 本地 y, 射线参数 t)；没打到为 null。 */
    private fun intersect(ray: PointerRay, surface: Pose, size: Vector2, arc: Float): Vector3? {
        if (arc >= ScreenGeometry.MIN_ARC_DEGREES) {
            val r = ScreenGeometry.radiusFor(arc, size.x)
            return intersectCylinder(ray, surface, r, arc, size.y / 2f + RING_M)
        }
        return intersectPlane(ray, surface)
    }

    private fun intersectPlane(ray: PointerRay, surface: Pose): Vector3? {
        val n = surface.forward()
        val denom = ray.direction.dot(n)
        if (abs(denom) < 1e-4f) return null
        val t = (surface.t - ray.origin).dot(n) / denom
        if (t <= 0f) return null
        val d = ray.origin + ray.direction * t - surface.t
        return Vector3(d.dot(surface.right()), d.dot(surface.up()), t)
    }

    /**
     * 射线 × 圆柱弧面（轴沿面的「上」，穿过 surface − forward·radius）。
     * 本地 x = 弧长（从面中心沿弧），y = 沿轴。人通常在圆柱里面，只有一个正根。
     */
    private fun intersectCylinder(ray: PointerRay, surface: Pose, radius: Float, arc: Float, halfH: Float): Vector3? {
        val f = surface.forward()
        val r = surface.right()
        val u = surface.up()
        val axis = surface.t - f * radius
        val o = ray.origin - axis
        val ox = o.dot(r)
        val oz = o.dot(f)
        val dx = ray.direction.dot(r)
        val dz = ray.direction.dot(f)
        val a = dx * dx + dz * dz
        if (a < 1e-6f) return null
        val b = 2f * (ox * dx + oz * dz)
        val c = ox * ox + oz * oz - radius * radius
        val disc = b * b - 4f * a * c
        if (disc < 0f) return null
        val sq = sqrt(disc)
        val halfArc = Math.toRadians(arc / 2.0).toFloat() + RING_M / radius
        for (t in floatArrayOf((-b - sq) / (2f * a), (-b + sq) / (2f * a))) {
            if (t <= 0f) continue
            val d = ray.origin + ray.direction * t - axis
            val theta = atan2(d.dot(r), d.dot(f))
            val y = d.dot(u)
            if (abs(theta) <= halfArc && abs(y) <= halfH) return Vector3(radius * theta, y, t)
        }
        return null
    }

    // ================================================================ 抓 / 挪 / 缩放

    private fun tryStart(hand: Int, byGrip: Boolean, input: SpatialInputPoller) {
        val hit = hits[hand] ?: return
        val slot = hit.slot
        val zone = hit.zone
        // A new pinch requires this hand's current hit. Content keeps select; only grip can grab BODY.
        if (zone == WindowFrameZone.NONE || (zone == WindowFrameZone.BODY && !byGrip)) return
        val ray = rayFor(hand, input) ?: return
        val surface = slot.host.surfacePose() ?: return
        val size = slot.host.size()
        val session = Session(hand, slot, zone, byGrip)
        if (zone.movesWindow) {
            val rp = basisPose(ray.origin, ray.direction)
            session.localOffset = rp.q.inverse() * (surface.t - rp.t)
            session.rotation = surface.q
        } else {
            session.startSurface = surface
            session.startSize = size
            val local = hit.local
            session.signX = when {
                abs(local.x) > 0.01f -> if (local.x > 0f) 1f else -1f
                zone == WindowFrameZone.CORNER_TR || zone == WindowFrameZone.CORNER_BR -> 1f
                else -> -1f
            }
            session.signY = when {
                abs(local.y) > 0.01f -> if (local.y > 0f) 1f else -1f
                zone == WindowFrameZone.CORNER_TL || zone == WindowFrameZone.CORNER_TR -> 1f
                else -> -1f
            }
            // A cylinder corner moves along the line from the face center to that edge as the
            // radius changes. Put that line and the vertical axis in one unbounded drag plane.
            // Continuing against the original finite cylinder stops at its old bounds (or tangent).
            val radius = ScreenGeometry.radiusFor(slot.host.arcDegrees(), size.x)
            val angle = if (radius > 0f) size.x / (4f * radius) else 0f
            val yaw = angle * session.signX
            val normal = surface.forward() * cos(yaw) + surface.right() * sin(yaw)
            session.resizePlane = Pose(surface.t, Quaternion.fromDirection(normal, surface.up()).normalize())
            session.resizeWidthProjection = if (angle > 0f) sin(angle) / angle else 1f
            val start = intersectPlane(ray, session.resizePlane) ?: return
            session.resizeStart = Vector2(start.x, start.y)
        }
        sessions[hand] = session
        slot.state.activeZone = zone
        slot.host.onInteraction()
        Log.i(TAG, "IMMERSIVE window grab kind=${slot.host.kind} zone=$zone grip=$byGrip hand=$hand")
    }

    private fun updateSession(session: Session, input: SpatialInputPoller) {
        val ray = rayFor(session.hand, input) ?: return
        val host = session.slot.host
        if (session.zone.movesWindow) {
            val rp = basisPose(ray.origin, ray.direction)
            val t = rp.t + rp.q * session.localOffset
            session.rotation = faceViewer(t) ?: session.rotation
            host.moveTo(Pose(t, session.rotation))
        } else {
            val hit = intersectPlane(ray, session.resizePlane) ?: return
            val w0 = session.startSize.x
            val h0 = session.startSize.y
            // Keep the center fixed and preserve the exact grab offset: holding still must not
            // enlarge the window by the width of its outer handle.
            val dx = w0 + (hit.x - session.resizeStart.x) * session.signX * 2f / session.resizeWidthProjection
            val dy = h0 + (hit.y - session.resizeStart.y) * session.signY * 2f
            val w: Float
            val h: Float
            if (host.resizePolicy == ResizePolicy.FREE) {
                w = dx.coerceIn(host.minSize.x, host.maxSize.x)
                h = dy.coerceIn(host.minSize.y, host.maxSize.y)
            } else {
                val sMin = max(host.minSize.x / w0, host.minSize.y / h0)
                val sMax = min(host.maxSize.x / w0, host.maxSize.y / h0)
                val s = ((dx * w0 + dy * h0) / (w0 * w0 + h0 * h0)).coerceIn(sMin, sMax)
                w = w0 * s
                h = h0 * s
            }
            val start = session.startSurface
            val size = Vector2(w, h)
            val surface = Pose(start.t, start.q)
            session.lastSize = size
            session.lastSurface = surface
            host.resizeTo(size, surface, commit = false)
        }
        host.onInteraction()
        // The frame must follow this frame's content pose, not the pose before the grab update.
        syncFrame(session.slot)
    }

    private fun endSession(hand: Int) {
        val session = sessions[hand] ?: return
        sessions[hand] = null
        session.slot.state.activeZone = WindowFrameZone.NONE
        if (!session.zone.movesWindow) {
            val size = session.lastSize
            val surface = session.lastSurface
            if (size != null && surface != null) session.slot.host.resizeTo(size, surface, commit = true)
        } else {
            session.slot.host.onMoveReleased(session.byGrip)
        }
        Log.i(TAG, "IMMERSIVE window release kind=${session.slot.host.kind} zone=${session.zone}")
    }

    // ================================================================ ISDK 指针事件（只用来认射线来源 + 自检）

    private fun onPointerEvent(ev: PointerEvent) {
        val system = isdk ?: return
        val hand = runCatching { system.getHandForPointerEvent(ev) }.getOrNull() ?: return
        val index = if (hand == Hand.LEFT) 0 else 1
        raySource[index] = ev.source
        if (rayChecksLogged >= RAY_CHECKS || ev.type != PointerEventType.Hover.id) return
        // 自检：ISDK 报的命中点与我们按同一实体位姿算出的射线差多远（真机日志对账用）
        val hitPoint = ev.hitInfo.point
        val pose = runCatching { getAbsoluteTransform(ev.source) }.getOrNull() ?: return
        val toHit = hitPoint - pose.t
        val len = toHit.length()
        if (len < 0.05f) return
        val cosine = toHit.normalize().dot(pose.forward().normalize())
        rayChecksLogged++
        Log.i(TAG, "IMMERSIVE ray check hand=$index cos(forward,toHit)=${"%.4f".format(cosine)} dist=${"%.2f".format(len)}")
    }

    private companion object {
        const val TAG = "IwaraVR"

        /** 窗框边圈的厚度（米）：1.5–2.4m 外看是 1.2–1.9°，够光标停住。 */
        const val RING_M = 0.05f

        /** 角把手的边长（米）。 */
        const val CORNER_M = 0.14f

        /** 窗框贴在窗体后方这么远。 */
        const val BEHIND_M = 0.012f
        const val FRAME_DP_PER_METER = 400f
        const val SIZE_EPS_M = 0.002f
        const val DOOMED_TICKS = 3
        const val REBUILD_GAP_TICKS = 4
        const val REBUILD_SCALE_LIMIT = 2f
        /** 光标离窗沿不到这么远就把窗框提前亮出来。 */
        const val NEAR_EDGE_M = 0.06f
        const val MIN_DISTANCE_M = 0.4f
        const val MAX_DISTANCE_M = 12f
        const val RAY_CHECKS = 3

        val PARKED_POSE = Pose(Vector3(0f, -100f, 0f), Quaternion(0f, 0f, 0f))
    }
}
