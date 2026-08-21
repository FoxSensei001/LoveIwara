
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/rules.model.dart';
import 'package:i_iwara/app/services/comment_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/markdown_original_text_toggle.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
class RulesAgreementDialog extends StatefulWidget {
  final ScrollController scrollController;

  const RulesAgreementDialog({
    super.key,
    required this.scrollController,
  });

  @override
  State<RulesAgreementDialog> createState() => _RulesAgreementDialogState();
}

class _RulesAgreementDialogState extends State<RulesAgreementDialog> {
  final CommentService _commentService = Get.find<CommentService>();
  bool _isLoading = true;
  String _error = '';
  List<RulesModel> _rules = [];

  /// 「显示原始文本」在本弹窗里是整份规则的显示偏好：一枚玻璃圆钮放标题行，
  /// 所有条目跟着一起翻（每条正文的内置行内开关已关闭）。
  late bool _showOriginal;

  /// 哪些条目确实有加工差异；只要有一条有，标题行那枚钮就长出来。
  /// ListView 会回收条目，所以这里只增不减——避免滚动时按钮忽隐忽现。
  final Set<int> _processedRuleIndexes = <int>{};

  @override
  void initState() {
    super.initState();
    _showOriginal = Get.find<ConfigService>()[ConfigKey
        .SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
    _loadRules();
  }

  Future<void> _loadRules() async {
    try {
      final result = await _commentService.getRules();
      if (result.isSuccess) {
        if (mounted) {
          setState(() {
            _rules = result.data?.results ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = result.message;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t.common.rules,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              MarkdownOriginalTextToggle(
                style: MarkdownToggleStyle.glass,
                visible: _processedRuleIndexes.isNotEmpty,
                showOriginal: _showOriginal,
                padding: const EdgeInsets.only(right: 4),
                onChanged: (v) => setState(() => _showOriginal = v),
              ),
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.close),
                tooltip: t.common.close,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (_isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error.isNotEmpty)
          Expanded(
            child: Center(
              child: Text(_error),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _rules.length,
              itemBuilder: (context, index) {
                final rule = _rules[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.getLocalizedTitle(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomMarkdownBody(
                      data: rule.getLocalizedBody(),
                      clickInternalLinkByUrlLaunch: true,
                      initialShowUnprocessedText: _showOriginal,
                      onProcessedContentChanged: (hasProcessed) {
                        if (!hasProcessed ||
                            _processedRuleIndexes.contains(index)) {
                          return;
                        }
                        setState(() => _processedRuleIndexes.add(index));
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        const Divider(height: 1),
        Container(
          padding: EdgeInsets.fromLTRB(
            16.0,
            16.0,
            16.0,
            16.0 + computeSheetBottomInset(context),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  final configService = Get.find<ConfigService>();
                  configService[ConfigKey.RULES_AGREEMENT_KEY] = false;
                  Navigator.pop(context);
                },
                child: Text(t.common.disagree),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t.common.agree),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 