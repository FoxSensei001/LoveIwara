package m.c.g.a.i_iwara.vr

import com.meta.spatial.core.Entity
import com.meta.spatial.core.Pose
import com.meta.spatial.core.SystemManager
import com.meta.spatial.core.Vector3
import com.meta.spatial.runtime.ButtonBits
import com.meta.spatial.toolkit.Controller
import com.meta.spatial.toolkit.ControllerType
import com.meta.spatial.toolkit.PlayerBodyAttachmentSystem
import com.meta.spatial.toolkit.Transform

/**
 * 每帧读一次双手 / 双手柄的按键位，抽出上升沿、下降沿与持续按住，交给沉浸 Activity 做映射。
 *
 * # 机制
 *
 * `Controller` 组件（挂在 AvatarBody 的 leftHand / rightHand 实体上）的 `buttonState`
 * 是一个位掩码。**手势模式下 ButtonX / ButtonA 就是左右手食指捏合**
 * （官方 `spatial-sdk-inputs-controllers` 原文），手柄模式下它们才是真按键。
 * 这里按 `type == HAND` 分家，把「捏合」与「A/X 键」当成两种事件报出去。
 *
 * # 「选择」是按下 + 松开两个事件
 *
 * 用户 2026-09-05 反馈：捏住想拖面板/幕布时会误触发面板召唤/收起。所以「选择」不再在
 * 按下那一刻裁决，而是同时报 [Events.selectDown] 与 [Events.selectUp]，并附带那只手的位置，
 * 由调用方区分「点一下」（短按、没移动）与「抓着拖」（长按或移动）。
 *
 * # 键位约定（需求文档 §7 设计决策 + 官方 `design/controllers`）
 *
 * | 输入 | 事件 |
 * |---|---|
 * | 捏合（任一手） / 扳机（任一手柄） | selectDown / selectUp：点一下 = 面板显隐 toggle；按在窗框上 = 抓住窗 |
 * | 抓握扳机（手柄） | gripDown / gripUp：影院态按下就抓住幕布拖（不用瞄准）；按在窗框上 = 挪 / 缩放（见 `WindowManipulator`） |
 * | A / X（手柄） | [Events.primaryTap]：播放 / 暂停 |
 * | B / Y（手柄） | [Events.back]：收起面板 |
 * | 摇杆左 / 右（按住） | [Events.seekLeft] / [Events.seekRight]：按住拖动进度、越久越快，松开才 seek |
 * | 摇杆上 / 下（按住） | [Events.volumeUp] / [Events.volumeDown]：幕布推远 / 拉近（平幕与球幕共用） |
 *
 * ⛔ 摇杆只有四个数字位没有模拟量，斜着推会同时亮起纵横两位 —— 用户 2026-09-05：「往前推很容易变成调进度」。
 * 所以一次推杆**锁轴**：从中位推出去那一帧哪根轴亮就归哪根轴（同帧都亮归纵轴），回中位前另一根轴一律不报。
 * | 左手 Menu | [Events.menu]：唤出面板并打开设置 |
 *
 * ⛔ Meta 键 / 长按 Meta 键是系统的，读不到也不该读。
 */
class SpatialInputPoller(private val systemManager: SystemManager) {

    class Events {
        /** 本帧开始「选择」的手：位 0 = 左，位 1 = 右。 */
        var selectDown = 0

        /** 本帧结束「选择」的手，同上。 */
        var selectUp = 0

        /** 本帧按下 / 松开抓握扳机的手柄，位掩码同上。手势模式没有这个键。 */
        var gripDown = 0
        var gripUp = 0
        var primaryTap = false
        var back = false
        /** 摇杆此刻推着左 / 右（持续态，不是上升沿）：按住拖动进度用。 */
        var seekLeft = false
        var seekRight = false
        var volumeUp = false
        var volumeDown = false
        var menu = false

        fun clear() {
            selectDown = 0; selectUp = 0; gripDown = 0; gripUp = 0; primaryTap = false; back = false
            seekLeft = false; seekRight = false
            volumeUp = false; volumeDown = false; menu = false
        }
    }

    val events = Events()

    /** 两只手（或手柄）本帧的世界坐标；读不到为 null。下标 0 = 左，1 = 右。 */
    val handPositions = arrayOfNulls<Vector3>(2)

    /** 两只手（或手柄）本帧的世界位姿；读不到为 null。 */
    val handPoses = arrayOfNulls<Pose>(2)

    /** 两只手（或手柄）的实体；ISDK 没报过射线来源时用它兜底。 */
    val handEntities = arrayOfNulls<Entity>(2)

    /** 这只手此刻是手柄（true）还是裸手（false）；没活着的为 false。 */
    val isController = BooleanArray(2)

    /** Tracking is live for this particular hand; stale poses must not keep a window hovered. */
    val handActive = BooleanArray(2)

    /** 此刻按着「选择」（捏合 / 扳机）的手。 */
    val selectHeld = BooleanArray(2)

    /** 此刻按着抓握扳机的手柄。 */
    val gripHeld = BooleanArray(2)

    private val lastSelect = BooleanArray(2)
    private val lastGrip = BooleanArray(2)
    private val selectGate = Array(2) { InputReleaseGate() }
    private val gripGate = Array(2) { InputReleaseGate() }
    private val controllerGate = Array(2) { InputReleaseGate() }
    private var lastControllerButtons = 0

    /** 本次推杆锁在哪根轴：0 = 中位，1 = 横（左右），2 = 纵（上下）。 */
    private var stickAxis = 0

    /** 手 / 手柄现在有没有一个是活着的。摘下头显、放下手柄时会变 false。 */
    var anyActive = false
        private set

    fun poll() {
        events.clear()
        val body = systemManager.findSystem<PlayerBodyAttachmentSystem>().tryGetLocalPlayerAvatarBody()
        var controllerButtons = 0
        var active = false
        val inputActive = handActive
        inputActive.fill(false)
        val rawControllerButtons = IntArray(2)
        val select = BooleanArray(2)
        val grip = BooleanArray(2)
        if (body != null) {
            val hands = arrayOf(body.leftHand, body.rightHand)
            for (i in 0..1) {
                val hand = hands[i]
                handEntities[i] = hand
                val pose = hand.tryGetComponent<Transform>()?.transform
                handPoses[i] = pose
                handPositions[i] = pose?.t
                isController[i] = false
                val c = hand.tryGetComponent<Controller>() ?: continue
                if (!c.isActive) continue
                active = true
                when (c.type) {
                    ControllerType.HAND -> {
                        inputActive[i] = true
                        // 手：ButtonX（左）/ ButtonA（右）就是食指捏合。
                        select[i] = (c.buttonState and (ButtonBits.ButtonX or ButtonBits.ButtonA)) != 0
                    }
                    ControllerType.CONTROLLER -> {
                        inputActive[i] = true
                        isController[i] = true
                        rawControllerButtons[i] = c.buttonState
                        val triggerBit = if (i == 0) ButtonBits.ButtonTriggerL else ButtonBits.ButtonTriggerR
                        val gripBit = if (i == 0) ButtonBits.ButtonSqueezeL else ButtonBits.ButtonSqueezeR
                        select[i] = (c.buttonState and triggerBit) != 0
                        grip[i] = (c.buttonState and gripBit) != 0
                    }
                    else -> {}
                }
            }
        } else {
            for (i in 0..1) {
                handPositions[i] = null
                handPoses[i] = null
                handEntities[i] = null
                isController[i] = false
            }
        }
        anyActive = active

        for (i in 0..1) {
            select[i] = selectGate[i].read(inputActive[i], select[i])
            grip[i] = gripGate[i].read(inputActive[i], grip[i])
            if (controllerGate[i].read(isController[i], rawControllerButtons[i] != 0)) {
                controllerButtons = controllerButtons or rawControllerButtons[i]
            }
            if (select[i] && !lastSelect[i]) events.selectDown = events.selectDown or (1 shl i)
            if (!select[i] && lastSelect[i]) events.selectUp = events.selectUp or (1 shl i)
            lastSelect[i] = select[i]
            selectHeld[i] = select[i]
            if (grip[i] && !lastGrip[i]) events.gripDown = events.gripDown or (1 shl i)
            if (!grip[i] && lastGrip[i]) events.gripUp = events.gripUp or (1 shl i)
            lastGrip[i] = grip[i]
            gripHeld[i] = grip[i]
        }

        val ctrlRising = controllerButtons and lastControllerButtons.inv()
        lastControllerButtons = controllerButtons
        events.primaryTap = (ctrlRising and (ButtonBits.ButtonA or ButtonBits.ButtonX)) != 0
        events.back = (ctrlRising and (ButtonBits.ButtonB or ButtonBits.ButtonY)) != 0
        val left = (controllerButtons and (ButtonBits.ButtonThumbLL or ButtonBits.ButtonThumbRL)) != 0
        val right = (controllerButtons and (ButtonBits.ButtonThumbLR or ButtonBits.ButtonThumbRR)) != 0
        val up = (controllerButtons and (ButtonBits.ButtonThumbLU or ButtonBits.ButtonThumbRU)) != 0
        val down = (controllerButtons and (ButtonBits.ButtonThumbLD or ButtonBits.ButtonThumbRD)) != 0
        stickAxis = when {
            !left && !right && !up && !down -> 0
            stickAxis != 0 -> stickAxis
            up || down -> 2
            else -> 1
        }
        events.seekLeft = stickAxis == 1 && left
        events.seekRight = stickAxis == 1 && right
        events.volumeUp = stickAxis == 2 && up
        events.volumeDown = stickAxis == 2 && down
        events.menu = (ctrlRising and ButtonBits.ButtonMenu) != 0
    }

    fun reset(awaitRelease: Boolean = false) {
        handActive.fill(false)
        anyActive = false
        for (i in 0..1) {
            lastSelect[i] = false
            lastGrip[i] = false
            selectHeld[i] = false
            gripHeld[i] = false
            selectGate[i].reset(awaitRelease)
            gripGate[i].reset(awaitRelease)
            controllerGate[i].reset(awaitRelease)
        }
        lastControllerButtons = 0
        stickAxis = 0
        events.clear()
    }
}

/** Missing tracking is not a physical release; each hand must report its own neutral input. */
internal class InputReleaseGate {
    private var awaitingRelease = false

    fun read(active: Boolean, pressed: Boolean): Boolean {
        if (!active) {
            awaitingRelease = true
            return false
        }
        if (awaitingRelease) {
            if (!pressed) awaitingRelease = false
            return false
        }
        return pressed
    }

    fun reset(awaitRelease: Boolean) {
        awaitingRelease = awaitRelease
    }
}
