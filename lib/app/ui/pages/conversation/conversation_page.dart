import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/message_and_conversation.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/conversation/widgets/conversation_list_widget.dart';
import 'package:i_iwara/app/ui/pages/conversation/widgets/message_list_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final Rxn<ConversationModel> _selectedConversation = Rxn<ConversationModel>();
  bool _previousIsWideScreen = false;

  @override
  void dispose() {
    _selectedConversation.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWideScreen = constraints.maxWidth > 600;

          // 如果从宽屏切换到小屏，清除选中的对话
          if (_previousIsWideScreen && !isWideScreen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _selectedConversation.value = null;
            });
          }
          _previousIsWideScreen = isWideScreen;

          return Row(
            children: [
              // 对话列表部分
              SizedBox(
                width: isWideScreen ? 300 : constraints.maxWidth,
                child: ConversationListWidget(
                  onConversationSelected: (ConversationModel conversation) {
                    if (!isWideScreen) {
                      // 小屏幕时使用嵌套导航
                      NaviService.navigateToMessagePage(conversation);
                    } else {
                      // 宽屏时更新选中的对话
                      _selectedConversation.value = conversation;
                    }
                  },
                ),
              ),
              // 消息列表部分 - 仅在宽屏时显示
              if (isWideScreen)
                Expanded(
                  child: Obx(() {
                    final selectedConversation = _selectedConversation.value;
                    if (selectedConversation == null) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border(
                            left: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    CommonConstants.launcherIconPath,
                                    width: 80,
                                    height: 80,
                                  )),
                              const SizedBox(height: 24),
                              Text(
                                t.conversation.noConversation,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t.conversation.selectFromLeftListAndStartConversation,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return MessageListWidget(
                      conversation: selectedConversation,
                      key: ValueKey(selectedConversation.id),
                      fromNarrowScreen: false,
                    );
                  }),
                ),
            ],
          );
        },
      ),
    );
  }
}
