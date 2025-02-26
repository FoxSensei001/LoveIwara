import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/deep_link_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class LinkInputDialogWidget extends StatefulWidget {
  const LinkInputDialogWidget({super.key});

  static void show() {
    AppService.hideGlobalDrawer();
    Get.dialog(
      const LinkInputDialogWidget(),
      barrierDismissible: true,
    );
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
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            // 标题部分
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slang.t.linkInputDialog.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slang.t.linkInputDialog.supportedLinksHint(webName: CommonConstants.webName),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 输入表单部分
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: slang.t.linkInputDialog.inputHint(webName: CommonConstants.webName),
                      prefixIcon: const Icon(Icons.insert_link_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return slang.t.linkInputDialog.validatorEmptyLink;
                      }
                      // 如果未检测到iwara链接，显示错误
                      if (extractedLinks.isEmpty) {
                        return slang.t.linkInputDialog.validatorNoIwaraLink(webName: CommonConstants.webName);
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
            
            // 多链接标题 - 仅在有多个链接时显示
            if (hasMultipleLinks)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        slang.t.linkInputDialog.multipleLinksDetected,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            
            // 链接列表 - 仅在有多个链接时显示
            if (hasMultipleLinks)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListTile(
                        title: Text(
                          extractedLinks[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: const Icon(Icons.link),
                        onTap: () {
                          AppService.tryPop();
                          _processUserLink(extractedLinks[index]);
                        },
                      ),
                    );
                  },
                  childCount: extractedLinks.length,
                ),
              ),
            
            // 按钮部分
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("取消"),
                      onPressed: () => AppService.tryPop(),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      child: const Text("确定"),
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
                    const SizedBox(width: 8),
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
      
      // 检查是否是有效的iwara链接
      if (!uri.host.contains("iwara")) {
        showToastWidget(MDToastWidget(
          message: slang.t.linkInputDialog.notIwaraLink(webName: CommonConstants.webName),
          type: MDToastType.error,
        ), position: ToastPosition.top);
        return;
      }

      // 使用DeepLinkService判断是否可以在应用内处理
      if (DeepLinkService.canHandleInternally(uri)) {
        // 应用内可处理的链接
        _handleDeepLink(uri);
      } else {
        // 应用内不能处理的链接
        _showUnsupportedLinkDialog(link);
      }
    } catch (e) {
      showToastWidget(MDToastWidget(
        message: slang.t.linkInputDialog.linkParseError(error: e.toString()),
        type: MDToastType.error,
      ), position: ToastPosition.top);
    }
  }

  // 处理应用内可支持的深链接
  void _handleDeepLink(Uri uri) {
    final deepLinkService = Get.find<DeepLinkService>();
    deepLinkService.processLink(uri);
  }

  // 显示不支持的链接对话框
  void _showUnsupportedLinkDialog(String link) {
    Get.dialog(
      _CustomDialogWithScrollView(
        title: slang.t.linkInputDialog.unsupportedLinkDialogTitle,
        content: Text(slang.t.linkInputDialog.unsupportedLinkDialogContent),
        actions: [
          TextButton(
            child: Text(slang.t.common.cancel),
            onPressed: () => AppService.tryPop(),
          ),
          ElevatedButton(
            child: Text(slang.t.linkInputDialog.openInBrowser),
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
    Get.dialog(
      _CustomDialogWithScrollView(
        title: slang.t.linkInputDialog.confirmOpenBrowserDialogTitle,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(slang.t.linkInputDialog.confirmOpenBrowserDialogContent),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                link,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(slang.t.linkInputDialog.confirmContinueBrowserOpen),
          ],
        ),
        actions: [
          TextButton(
            child: Text(slang.t.common.cancel),
            onPressed: () => AppService.tryPop(),
          ),
          ElevatedButton(
            child: Text(slang.t.common.confirm),
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
      showToastWidget(MDToastWidget(
        message: slang.t.linkInputDialog.browserOpenFailed,
        type: MDToastType.error,
      ), position: ToastPosition.top);
    }
  }
}

// 自定义使用CustomScrollView的对话框
class _CustomDialogWithScrollView extends StatelessWidget {
  final String title;
  final dynamic content;
  final List<Widget> actions;

  const _CustomDialogWithScrollView({
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            // 标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // 内容
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: content is String ? Text(content) : content,
              ),
            ),
            
            // 按钮
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ...actions.map((action) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: action,
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 