# Showcase screenshots / 展示截图

The PNG screenshots use production Flutter components with sample data and
placeholder images. The Meta Quest JPGs are device captures. The PNG renderer is
[`showcase_screenshots_test.dart`](../../test/tool/showcase_screenshots_test.dart).

## Regenerate

Run from the repository root:

```sh
SHOWCASE_SHOT_DIR=docs/imgs flutter test test/tool/showcase_screenshots_test.dart --reporter expanded
```

The renderer uses the English locale, Material appearance, and a 1400 × 860 logical
viewport. PNGs are exported at 2100 × 1290. API responses and images come from local
fixtures; database files use a temporary directory. The tool runs only when
`SHOWCASE_SHOT_DIR` is set.

Check fonts, icons, layout, and loading states before replacing screenshots.
Update the localized README references if a filename changes. Headset screenshots
should be captured on a device using sample media.

## 简体中文

PNG 截图使用应用现有 Flutter 组件、示例数据和占位图，Meta Quest 的 JPG 为实机截图。
上面的命令可重新生成整套 PNG 图片。

渲染使用英文界面和 Material 外观，逻辑尺寸为 1400 × 860，导出尺寸为
2100 × 1290。API 响应和图片来自本地 mock，数据库文件位于临时目录。
只有设置 `SHOWCASE_SHOT_DIR` 时才运行该工具。

替换前检查字体、图标、布局和加载状态；文件名变化时，同步各语言 README。
头显截图应使用示例素材在设备上拍摄。
