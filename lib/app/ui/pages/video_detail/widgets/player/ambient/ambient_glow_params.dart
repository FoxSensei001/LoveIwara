// 剧院模式「环境光」的参数。
//
// 效果：把当前画面缩成一张很小的图，模糊、压暗后铺到播放器背后并放大，
// 黑边里就透出与画面同色的柔光；换画面时慢慢交叉淡化，不跟着每一帧闪。
// 所有数值都按「在 16:9 片、常见播放器尺寸下看起来柔和、不抢画面」调定。

/// 小画布上的模糊半径（高斯标准差，单位是小画布像素，不是屏幕像素）。
/// 小画布最终会被放大几十倍，所以这里的 5 在屏幕上是很大的一片柔光。
const double kAmbientBlurSigma = 5;

/// 画布四周留的底色边，取模糊半径的 3 倍：模糊到这里已经衰减完，
/// 画布本身的硬边因此看不见。
const double kAmbientCanvasPadding = kAmbientBlurSigma * 3;

/// 取样小图的高度（像素），宽度按视频比例算，16:9 片是 80×45。
/// 再小颜色会糊成一团，再大放大后会看出细节、显得脏。
const double kAmbientFrameHeight = 45;

/// 画面叠到底色上时的不透明度。光只做氛围，不能比画面本身更抢眼。
const double kAmbientGlowOpacity = 0.4;

/// 底色。播放器背景就是黑的，底色同为黑色，光才能自然地融进黑边。
const int kAmbientFillColor = 0xFF000000;

/// 小画布先拉伸到视频画面所在的矩形，再以中心放大的倍数：放大后光才能漫进
/// 四周黑边。横竖同倍，避免光晕被拉成扁的。
const double kAmbientScaleX = 2;
const double kAmbientScaleY = 2;

/// 两次换帧至少间隔这么久：光只需要跟上场景的大致色调，不必逐帧追。
const Duration kAmbientMinUpdateInterval = Duration(milliseconds: 5000);

/// 换帧时新画面从 0 淡到 1 的时长，与换帧间隔相同，过渡首尾相接、不会停顿。
const Duration kAmbientCrossfadeDuration = Duration(milliseconds: 5000);

/// 没有画面可取（未起播 / 播完）时淡回纯底色的时长。
const Duration kAmbientFadeOutDuration = Duration(milliseconds: 500);

/// 淡化按这个帧率分级推进，不做连续插值：5 秒过渡只有 75 级，每级重绘一次。
/// 背景色变得这么慢，人眼分不出 15 级 / 秒和逐帧的区别，重绘却少得多。
const int kAmbientTransitionFrameRate = 15;

/// 一段淡化分多少级。
int ambientTransitionSteps(Duration duration) =>
    (duration.inMilliseconds * kAmbientTransitionFrameRate / 1000).round();
