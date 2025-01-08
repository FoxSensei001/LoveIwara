import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/sign_in/widgets/sign_in_heatmap_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';

import '../../../routes/app_routes.dart';
import '../../../services/user_service.dart';
import 'controllers/sign_in_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final SignInController controller = Get.put(SignInController());
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    endDate = DateTime.now();
    startDate = endDate.subtract(const Duration(days: 30));
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      // 各种text
      helpText: slang.t.signIn.selectDateRange,
      cancelText: slang.t.common.cancel,
      confirmText: slang.t.common.confirm,
      saveText: slang.t.common.save,
      errorFormatText: slang.t.signIn.invalidDate,
      errorInvalidText: slang.t.signIn.invalidDateRange,
      errorInvalidRangeText: slang.t.signIn.invalidDateRange,
      fieldStartHintText: slang.t.signIn.startDate,
      fieldEndHintText: slang.t.signIn.endDate,
      fieldStartLabelText: slang.t.signIn.startDate,
      fieldEndLabelText: slang.t.signIn.endDate,
      barrierLabel: slang.t.signIn.selectDateRange,
    );

    if (picked != null) {
      // 确保日期范围不超过1年
      if (picked.end.difference(picked.start).inDays > 365) {
        showToastWidget(MDToastWidget(message: slang.t.signIn.dateRangeCantBeMoreThanOneYear, type: MDToastType.error));
        return;
      }
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  @override
  void dispose() {
    Get.delete<SignInController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final UserService userService = Get.find<UserService>();
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.signIn.signIn),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: t.signIn.selectDateRange,
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Obx(() {
            if (userService.currentUser.value == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t.signIn.pleaseLoginFirst,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed(Routes.LOGIN),
                        icon: const Icon(Icons.login),
                        label: Text(t.auth.login),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 32 : 16,
                vertical: 24,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (isWideScreen) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 2,
                          child: _buildMainContent(context),
                        ),
                        const SizedBox(width: 24),
                        Flexible(
                          flex: 3,
                          child: _buildHeatMapCard(context),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildMainContent(context),
                      const SizedBox(height: 24),
                      _buildHeatMapCard(context),
                    ],
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final t = slang.Translations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useVerticalLayout = constraints.maxWidth < 400;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!controller.hasSignedInToday.value)
              ElevatedButton.icon(
                      onPressed: _showSignInDialog,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(t.signIn.signIn),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
            const SizedBox(height: 16),
            if (useVerticalLayout)
              Column(
                children: [
                  _buildStatisticCard(
                    title: t.signIn.totalSignIns,
                    count: controller.totalSignIns.value,
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),
                  _buildStatisticCard(
                    title: t.signIn.consecutiveSignIns,
                    count: controller.consecutiveSignIns.value,
                    icon: Icons.trending_up,
                  ),
                ],
              )
            else
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildStatisticCard(
                        title: t.signIn.totalSignIns,
                        count: controller.totalSignIns.value,
                        icon: Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatisticCard(
                        title: t.signIn.consecutiveSignIns,
                        count: controller.consecutiveSignIns.value,
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeatMapCard(BuildContext context) {
    final t = slang.Translations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.signIn.signInRecord,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SignInHeatMap(
              signInStatus: controller.signInStatus.map(
                (key, value) => MapEntry(
                  DateTime(key.year, key.month, key.day),
                  value,
                ),
              ),
              consecutiveSignIns: controller.consecutiveSignIns.value,
              startDate: startDate,
              endDate: endDate,
              failureReasons: controller.signInReasons,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required int count,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showSignInDialog() {
    Get.dialog(SignInDialog(controller: controller), barrierDismissible: false);
  }
}

// 优化对话框样式
class SignInDialog extends StatefulWidget {
  final SignInController controller;

  const SignInDialog({super.key, required this.controller});

  @override
  _SignInDialogState createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  TextEditingController reasonController = TextEditingController();
  bool isSuccess = true;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.signIn.signIn,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              t.signIn.pleaseSelectSignInStatus,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(t.signIn.signInSuccess),
                    value: true,
                    groupValue: isSuccess,
                    onChanged: (value) {
                      if (value != null) setState(() => isSuccess = value);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(t.signIn.signInFailed),
                    value: false,
                    groupValue: isSuccess,
                    onChanged: (value) {
                      if (value != null) setState(() => isSuccess = value);
                    },
                  ),
                ),
              ],
            ),
            if (!isSuccess) ...[
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: t.signIn.failureReason,
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.common.cancel),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await widget.controller.signIn(
                      isSuccess: isSuccess,
                      reason: isSuccess ? null : reasonController.text.trim(),
                    );
                  },
                  child: Text(t.common.confirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
