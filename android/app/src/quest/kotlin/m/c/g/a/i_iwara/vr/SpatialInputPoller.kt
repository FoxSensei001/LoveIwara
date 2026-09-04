package m.c.g.a.i_iwara.vr

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
 * | 捏合（任一手） / 扳机（任一手柄） | selectDown / selectUp：点一下 = 面板显隐 toggle |
 * | A / X（手柄） | [Events.primaryTap]：播放 / 暂停 |
 * | B / Y（手柄） | [Events.back]：收起面板 |
 * | 摇杆左 / 右（上升沿） | [Events.seekBack] / [Events.seekForward] |
 * | 摇杆上 / 下（按住） | [Events.volumeUp] / [Events.volumeDown] |
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
        var primaryTap = false
        var back = false
        var seekBack = false
        var seekForward = false
        var volumeUp = false
        var volumeDown = false
        var menu = false

        fun clear() {
            selectDown = 0; selectUp = 0; primaryTap = false; back = false
            seekBack = false; seekForward = false
            volumeUp = false; volumeDown = false; menu = false
        }
    }

    val events = Events()

    /** 两只手（或手柄）本帧的世界坐标；读不到为 null。下标 0 = 左，1 = 右。 */
    val handPositions = arrayOfNulls<Vector3>(2)

    private val lastSelect = BooleanArray(2)
    private var lastControllerButtons = 0

    /** 手 / 手柄现在有没有一个是活着的。摘下头显、放下手柄时会变 false。 */
    var anyActive = false
        private set

    fun poll() {
        events.clear()
        val body = systemManager.findSystem<PlayerBodyAttachmentSystem>().tryGetLocalPlayerAvatarBody()
        var controllerButtons = 0
        var active = false
        val select = BooleanArray(2)
        if (body != null) {
            val hands = arrayOf(body.leftHand, body.rightHand)
            for (i in 0..1) {
                val hand = hands[i]
                handPositions[i] = hand.tryGetComponent<Transform>()?.transform?.t
                val c = hand.tryGetComponent<Controller>() ?: continue
                if (!c.isActive) continue
                active = true
                when (c.type) {
                    ControllerType.HAND -> {
                        // 手：ButtonX（左）/ ButtonA（右）就是食指捏合。
                        select[i] = (c.buttonState and (ButtonBits.ButtonX or ButtonBits.ButtonA)) != 0
                    }
                    ControllerType.CONTROLLER -> {
                        controllerButtons = controllerButtons or c.buttonState
                        select[i] = (c.buttonState and (ButtonBits.ButtonTriggerL or ButtonBits.ButtonTriggerR)) != 0
                    }
                    else -> {}
                }
            }
        } else {
            handPositions[0] = null
            handPositions[1] = null
        }
        anyActive = active

        for (i in 0..1) {
            if (select[i] && !lastSelect[i]) events.selectDown = events.selectDown or (1 shl i)
            if (!select[i] && lastSelect[i]) events.selectUp = events.selectUp or (1 shl i)
            lastSelect[i] = select[i]
        }

        val ctrlRising = controllerButtons and lastControllerButtons.inv()
        lastControllerButtons = controllerButtons
        events.primaryTap = (ctrlRising and (ButtonBits.ButtonA or ButtonBits.ButtonX)) != 0
        events.back = (ctrlRising and (ButtonBits.ButtonB or ButtonBits.ButtonY)) != 0
        events.seekBack = (ctrlRising and (ButtonBits.ButtonThumbLL or ButtonBits.ButtonThumbRL)) != 0
        events.seekForward = (ctrlRising and (ButtonBits.ButtonThumbLR or ButtonBits.ButtonThumbRR)) != 0
        events.volumeUp = (controllerButtons and (ButtonBits.ButtonThumbLU or ButtonBits.ButtonThumbRU)) != 0
        events.volumeDown = (controllerButtons and (ButtonBits.ButtonThumbLD or ButtonBits.ButtonThumbRD)) != 0
        events.menu = (ctrlRising and ButtonBits.ButtonMenu) != 0
    }

    fun reset() {
        lastSelect[0] = false
        lastSelect[1] = false
        lastControllerButtons = 0
        events.clear()
    }
}
