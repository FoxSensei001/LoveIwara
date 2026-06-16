# i_iwara 安装说明 / Install Note

## 中文

1. 将 **i_iwara** 图标拖入右侧的 **Applications** 文件夹。
2. 首次打开时，若提示 **"i_iwara 已损坏"** 或 **"无法打开，因为来自身份不明的开发者"**，
   这是因为本版本未经过 Apple 公证（开发者暂无 Apple 付费开发者账号），并非应用损坏。

   按以下任一方式打开即可：

   - **方式 A（推荐）**：在「访达 / Finder」的「应用程序」里，
     **右键点击 i_iwara → 打开**，在弹窗中再次点击「打开」。之后即可正常双击启动。

   - **方式 B（终端）**：打开「终端」执行：

     ```bash
     xattr -dr com.apple.quarantine /Applications/i_iwara.app
     ```

     然后正常双击打开。

## English

1. Drag the **i_iwara** icon onto the **Applications** folder on the right.
2. On first launch macOS may say **"i_iwara is damaged"** or **"cannot be opened
   because it is from an unidentified developer"**. This build is not
   Apple-notarized (the developer has no paid Apple Developer account yet) — the
   app is **not** actually damaged.

   Open it with either:

   - **Option A (recommended):** In Finder → Applications,
     **right-click i_iwara → Open**, then click **Open** in the dialog.
     Subsequent launches work normally with a double-click.

   - **Option B (Terminal):**

     ```bash
     xattr -dr com.apple.quarantine /Applications/i_iwara.app
     ```

     then double-click to open.
