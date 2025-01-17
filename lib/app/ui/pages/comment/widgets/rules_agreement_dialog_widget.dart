
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/rules.model.dart';
import 'package:i_iwara/app/services/comment_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
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

  @override
  void initState() {
    super.initState();
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.common.rules,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
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
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  final configService = Get.find<ConfigService>();
                  configService[ConfigService.RULES_AGREEMENT_KEY] = false;
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