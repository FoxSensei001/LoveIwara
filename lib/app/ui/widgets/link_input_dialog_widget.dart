import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/deep_link_service.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';

class LinkInputDialogWidget extends StatefulWidget {
  const LinkInputDialogWidget({super.key});

  static void show() {
    AppService.hideGlobalDrawer();
    showAppDialog(const LinkInputDialogWidget(), barrierDismissible: true);
  }

  @override
  State<LinkInputDialogWidget> createState() => _LinkInputDialogWidgetState();
}

class _LinkInputDialogWidgetState extends State<LinkInputDialogWidget> {
  final textController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // 存储从文本中提取的所有链接
  final List<String> extractedLinks = [];
  bool isAnalyzing = false;
  bool hasMultipleLinks = false;

  @override
  void initState() {
    super.initState();
    // 监听文本变化，提取链接
    textController.addListener(_analyzeTextForLinks);
  }

  @override
  void dispose() {
    textController.removeListener(_analyzeTextForLinks);
    textController.dispose();
    super.dispose();
  }

  // 从文本中提取链接的方法
  void _analyzeTextForLinks() {
    if (textController.text.isEmpty || isAnalyzing) return;

    setState(() {
      isAnalyzing = true;
      extractedLinks.clear();
    });

    // 使用正则表达式提取所有包含iwara的链接
    final regex = RegExp(
      r'https?://(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&/=]*)',
      caseSensitive: false,
    );

    final matches = regex.allMatches(textController.text);
    for (final match in matches) {
      final link = match.group(0);
      if (link != null && link.toLowerCase().contains('iwara')) {
        extractedLinks.add(link);
      }
    }

    setState(() {
      hasMultipleLinks = extractedLinks.length > 1;
      isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            // 标题行：标题 + 玻璃关闭圆钮（全局统一约定）
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.insert_link_rounded,
                          size: 22,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            slang.t.linkInputDialog.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        GlassIconButton(
                          standalone: true,
                          icon: const Icon(Icons.close),
                          tooltip: slang.t.common.close,
                          onPressed: () => AppService.tryPop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        slang.t.linkInputDialog.supportedLinksHint(
                          webName: CommonConstants.webName,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 输入表单部分：玻璃胶囊输入框
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Form(
                  key: formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: GlassTokens.fill(colorScheme),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: GlassTokens.stroke(colorScheme),
                        width: GlassTokens.strokeWidth,
                      ),
                    ),
                    child: TextFormField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: slang.t.linkInputDialog.inputHint(
                          webName: CommonConstants.webName,
                        ),
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.insert_link_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return slang.t.linkInputDialog.validatorEmptyLink;
                        }
                        // 如果未检测到iwara链接，显示错误
                        if (extractedLinks.isEmpty) {
                          return slang.t.linkInputDialog.validatorNoIwaraLink(
                            webName: CommonConstants.webName,
                          );
                        }
                        return null;
                      },
                      autofocus: true,
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                ),
              ),
            ),

            // 多链接标题 - 仅在有多个链接时显示
            if (hasMultipleLinks)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    slang.t.linkInputDialog.multipleLinksDetected,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            // 链接列表 - 仅在有多个链接时显示（圆角描边卡，与通知列表同款）
            if (hasMultipleLinks)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Material(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          AppService.tryPop();
                          _processUserLink(extractedLinks[index]);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: GlassTokens.stroke(colorScheme),
                              width: GlassTokens.strokeWidth,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.link,
                                size: 20,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  extractedLinks[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: extractedLinks.length),
              ),

            // 按钮部分
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassButtonGroup(
                      children: [
                        GlassTextActionButton(
                          label: slang.t.common.cancel,
                          onPressed: () => AppService.tryPop(),
                        ),
                        GlassTextActionButton(
                          label: slang.t.common.confirm,
                          emphasized: true,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              // 如果只有一个链接，直接处理
                              if (extractedLinks.length == 1) {
                                AppService.tryPop();
                                _processUserLink(extractedLinks[0]);
                              }
                              // 如果有多个链接但用户点击了确定，处理第一个链接
                              else if (extractedLinks.length > 1) {
                                AppService.tryPop();
                                _processUserLink(extractedLinks[0]);
                              }
                              // 如果没有提取到链接但验证通过（不太可能发生），处理原始输入
                              else if (textController.text.isNotEmpty) {
                                AppService.tryPop();
                                _processUserLink(textController.text.trim());
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 处理用户输入的链接
  void _processUserLink(String link) {
    try {
      final uri = Uri.parse(link);

      if (!DeepLinkService.canHandleLink(link) &&
          !IwaraSiteUtils.isIwaraHost(uri.host)) {
        showAppToast(
          slang.t.linkInputDialog.notIwaraLink(
            webName: CommonConstants.webName,
          ),
          type: AppToastType.error,
          position: AppToastPosition.top,
        );
        return;
      }

      if (DeepLinkService.canHandleInternally(uri)) {
        _handleDeepLink(uri);
      } else {
        _showUnsupportedLinkDialog(link);
      }
    } catch (e) {
      showAppToast(
        slang.t.linkInputDialog.linkParseError(error: e.toString()),
        type: AppToastType.error,
        position: AppToastPosition.top,
      );
    }
  }

  // 处理应用内可支持的深链接
  void _handleDeepLink(Uri uri) {
    final deepLinkService = Get.find<DeepLinkService>();
    deepLinkService.processLink(uri);
  }

  // 显示不支持的链接对话框
  void _showUnsupportedLinkDialog(String link) {
    showAppDialog(
      GlassAlertDialog(
        title: slang.t.linkInputDialog.unsupportedLinkDialogTitle,
        scrollable: true,
        maxWidth: 520,
        content: Text(slang.t.linkInputDialog.unsupportedLinkDialogContent),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
          GlassDialogAction(
            label: slang.t.linkInputDialog.openInBrowser,
            onPressed: () {
              AppService.tryPop();
              _confirmBrowserOpen(link);
            },
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  // 二次确认是否用浏览器打开
  void _confirmBrowserOpen(String link) {
    showAppDialog(
      GlassAlertDialog(
        title: slang.t.linkInputDialog.confirmOpenBrowserDialogTitle,
        scrollable: true,
        maxWidth: 520,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(slang.t.linkInputDialog.confirmOpenBrowserDialogContent),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                link,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(slang.t.linkInputDialog.confirmContinueBrowserOpen),
          ],
        ),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
          GlassDialogAction(
            label: slang.t.common.confirm,
            onPressed: () {
              AppService.tryPop(closeAll: true);
              _openInBrowser(link);
            },
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  // 在浏览器中打开链接
  void _openInBrowser(String link) async {
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showAppToast(
        slang.t.linkInputDialog.browserOpenFailed,
        type: AppToastType.error,
        position: AppToastPosition.top,
      );
    }
  }
}
