package m.c.g.a.i_iwara.vr

import com.meta.spatial.core.SystemManager
import com.meta.spatial.runtime.ButtonBits
import com.meta.spatial.toolkit.Controller
import com.meta.spatial.toolkit.ControllerType
import com.meta.spatial.toolkit.PlayerBodyAttachmentSystem

/**
 * 每帧读一次双手 / 双手柄的按键位，抽出上升沿与持续按住，交给沉浸 Activity 做映射。
 *
 * # 机制
 *
 * `Controller` 组件（挂在 AvatarBody 的 leftHand / rightHand 实体上）的 `buttonState`
 * 是一个位掩码。**手势模式下 ButtonX / ButtonA 就是左右手食指捏合**
 * （官方 `spatial-sdk-inputs-controllers` 原文），手柄模式下它们才是真按键。
 * 这里按 `type == HAND` 分家，把「捏合」与「A/X 键」当成两种事件报出去。
 *
 * # 键位约定（需求文档 §7 设计决策 + 官方 `design/controllers`）
 *
 * | 输入 | 事件 |
 * |---|---|
 * | 捏合（任一手） / 扳机（任一手柄） | [Events.select]：面板显隐 toggle |
 * | A / X（手柄） | [Events.primaryTap]：播放 / 暂停 |
 * | B / Y（手柄） | [Events.back]：收起面板 |
 * | 摇杆左 / 右（上升沿） | [Events.seekBack] / [Events.seekForward] |
 * | 摇杆上 / 下（按住） | [Events.volumeUp] / [Events.volumeDown]（按住持续） |
 * | 左手 Menu | [Events.menu]：唤出面板并打开设置 |
 *
 * ⛔ Meta 键 / 长按 Meta 键是系统的，读不到也不该读。
 */
class SpatialInputPoller(private val systemManager: SystemManager) {

    class Events {
        var select = false
        var primaryTap = false
        var back = false
        var seekBack = false
        var seekForward = false
        var volumeUp = false
        var volumeDown = false
        var menu = false

        fun clear() {
            select = false; primaryTap = false; back = false
            seekBack = false; seekForward = false
            volumeUp = false; volumeDown = false; menu = false
        }
    }

    val events = Events()

    private var lastHandButtons = 0
    private var lastControllerButtons = 0

    /** 手 / 手柄现在有没有一个是活着的。摘下头显、放下手柄时会变 false。 */
    var anyActive = false
        private set

    fun poll() {
        events.clear()
        val body = systemManager.findSystem<PlayerBodyAttachmentSystem>().tryGetLocalPlayerAvatarBody()
        var handButtons = 0
        var controllerButtons = 0
        var active = false
        if (body != null) {
            for (hand in arrayOf(body.leftHand, body.rightHand)) {
                val c = hand.tryGetComponent<Controller>() ?: continue
                if (!c.isActive) continue
                active = true
                when (c.type) {
                    ControllerType.HAND -> handButtons = handButtons or c.buttonState
                    ControllerType.CONTROLLER -> controllerButtons = controllerButtons or c.buttonState
                    else -> {}
                }
            }
        }
        anyActive = active

        val handRising = handButtons and lastHandButtons.inv()
        val ctrlRising = controllerButtons and lastControllerButtons.inv()
        lastHandButtons = handButtons
        lastControllerButtons = controllerButtons

        val pinchMask = ButtonBits.ButtonX or ButtonBits.ButtonA
        val triggerMask = ButtonBits.ButtonTriggerL or ButtonBits.ButtonTriggerR
        events.select = (handRising and pinchMask) != 0 || (ctrlRising and triggerMask) != 0
        events.primaryTap = (ctrlRising and pinchMask) != 0
        events.back = (ctrlRising and (ButtonBits.ButtonB or ButtonBits.ButtonY)) != 0
        events.seekBack = (ctrlRising and (ButtonBits.ButtonThumbLL or ButtonBits.ButtonThumbRL)) != 0
        events.seekForward = (ctrlRising and (ButtonBits.ButtonThumbLR or ButtonBits.ButtonThumbRR)) != 0
        events.volumeUp = (controllerButtons and (ButtonBits.ButtonThumbLU or ButtonBits.ButtonThumbRU)) != 0
        events.volumeDown = (controllerButtons and (ButtonBits.ButtonThumbLD or ButtonBits.ButtonThumbRD)) != 0
        events.menu = (ctrlRising and ButtonBits.ButtonMenu) != 0
    }

    fun reset() {
        lastHandButtons = 0
        lastControllerButtons = 0
        events.clear()
    }
}
