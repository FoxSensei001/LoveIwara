import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class LayoutSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const LayoutSettingsPage({
    super.key,
    this.isWideScreen = false,
  });

  @override
  State<LayoutSettingsPage> createState() => _LayoutSettingsPageState();
}

class _LayoutSettingsPageState extends State<LayoutSettingsPage> {
  late ConfigService _configService;
  late int _manualColumnsCount;
  final TextEditingController _columnsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _configService = Get.find<ConfigService>();
    _loadSettings();
  }

  void _loadSettings() {
    _manualColumnsCount = _configService[ConfigKey.MANUAL_COLUMNS_COUNT] as int;
    _columnsController.text = _manualColumnsCount.toString();
  }

  @override
  void dispose() {
    _columnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: slang.t.layoutSettings.title,
            isWideScreen: widget.isWideScreen,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDescriptionCard(),
                _buildLayoutModeCard(),
                _buildManualSettingsCard(),
                _buildBreakpointsCard(),
                _buildPreviewCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slang.t.layoutSettings.descriptionTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slang.t.layoutSettings.descriptionContent,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutModeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    slang.t.layoutSettings.layoutMode,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(slang.t.layoutSettings.reset),
                  onPressed: () => _showResetConfirmDialog(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() => RadioListTile<String>(
            title: Text(slang.t.layoutSettings.autoMode),
            subtitle: Text(slang.t.layoutSettings.autoModeDesc),
            value: 'auto',
            groupValue: _configService[ConfigKey.LAYOUT_MODE] as String,
            onChanged: (value) {
              _configService[ConfigKey.LAYOUT_MODE] = value!;
            },
          )),
          Obx(() => RadioListTile<String>(
            title: Text(slang.t.layoutSettings.manualMode),
            subtitle: Text(slang.t.layoutSettings.manualModeDesc),
            value: 'manual',
            groupValue: _configService[ConfigKey.LAYOUT_MODE] as String,
            onChanged: (value) {
              _configService[ConfigKey.LAYOUT_MODE] = value!;
            },
          )),
        ],
      ),
    );
  }

  Widget _buildManualSettingsCard() {
    return Obx(() {
      final isManual = _configService[ConfigKey.LAYOUT_MODE] as String == 'manual';
      
      // 如果不是手动模式，不显示此卡片
      if (!isManual) {
        return const SizedBox.shrink();
      }
      
      final isNarrowScreen = MediaQuery.of(context).size.width < 600;
      
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                slang.t.layoutSettings.manualSettings,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            if (isNarrowScreen)
              // 窄屏下的紧凑布局
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.grid_view,
                              size: 16,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slang.t.layoutSettings.fixedColumns,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${_configService[ConfigKey.MANUAL_COLUMNS_COUNT]} ${slang.t.layoutSettings.columns}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: () {
                            final current = _configService[ConfigKey.MANUAL_COLUMNS_COUNT] as int;
                            if (current > 1) {
                              _configService[ConfigKey.MANUAL_COLUMNS_COUNT] = current - 1;
                              _columnsController.text = (current - 1).toString();
                            }
                          },
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _columnsController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            onSubmitted: (value) {
                              final newValue = int.tryParse(value);
                              if (newValue != null && newValue > 0 && newValue <= 12) {
                                _configService[ConfigKey.MANUAL_COLUMNS_COUNT] = newValue;
                              } else {
                                _columnsController.text = _configService[ConfigKey.MANUAL_COLUMNS_COUNT].toString();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () {
                            final current = _configService[ConfigKey.MANUAL_COLUMNS_COUNT] as int;
                            if (current < 12) {
                              _configService[ConfigKey.MANUAL_COLUMNS_COUNT] = current + 1;
                              _columnsController.text = (current + 1).toString();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              // 宽屏下的原有布局
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.grid_view,
                      size: 20,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
                title: Text(slang.t.layoutSettings.fixedColumns),
                subtitle: Text('${_configService[ConfigKey.MANUAL_COLUMNS_COUNT]} ${slang.t.layoutSettings.columns}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        final current = _configService[ConfigKey.MANUAL_COLUMNS_COUNT] as int;
                        if (current > 1) {
                          _configService[ConfigKey.MANUAL_COLUMNS_COUNT] = current - 1;
                          _columnsController.text = (current - 1).toString();
                        }
                      },
                    ),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _columnsController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        onSubmitted: (value) {
                          final newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0 && newValue <= 12) {
                            _configService[ConfigKey.MANUAL_COLUMNS_COUNT] = newValue;
                          } else {
                            _columnsController.text = _configService[ConfigKey.MANUAL_COLUMNS_COUNT].toString();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final current = _configService[ConfigKey.MANUAL_COLUMNS_COUNT] as int;
                        if (current < 12) {
                          _configService[ConfigKey.MANUAL_COLUMNS_COUNT] = current + 1;
                          _columnsController.text = (current + 1).toString();
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildBreakpointsCard() {
    return Obx(() {
      final isAuto = _configService[ConfigKey.LAYOUT_MODE] as String == 'auto';
      
      // 如果不是自动模式，不显示此卡片
      if (!isAuto) {
        return const SizedBox.shrink();
      }
      
      final isNarrowScreen = MediaQuery.of(context).size.width < 600;
      
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: isNarrowScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slang.t.layoutSettings.breakpointConfig,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(slang.t.layoutSettings.add),
                          onPressed: () => _showAddBreakpointDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          slang.t.layoutSettings.breakpointConfig,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(slang.t.layoutSettings.add),
                        onPressed: () => _showAddBreakpointDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
            ),
            const Divider(height: 1),
            _buildDefaultColumnsSetting(),
            const Divider(height: 1),
            ..._buildBreakpointList(),
          ],
        ),
      );
    });
  }

  Widget _buildDefaultColumnsSetting() {
    final isNarrowScreen = MediaQuery.of(context).size.width < 600;
    
    if (isNarrowScreen) {
      // 窄屏下的紧凑布局
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.settings,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slang.t.layoutSettings.defaultColumns,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        slang.t.layoutSettings.defaultColumnsDesc,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  onPressed: () {
                    final breakpoints = _getSafeBreakpoints();
                    final defaultColumns = breakpoints['9999'] ?? 6;
                    if (defaultColumns > 1) {
                      breakpoints['9999'] = defaultColumns - 1;
                      _updateBreakpointsWithSorting(breakpoints);
                    }
                  },
                ),
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_getSafeBreakpoints()['9999'] ?? 6}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () {
                    final breakpoints = _getSafeBreakpoints();
                    final defaultColumns = breakpoints['9999'] ?? 6;
                    if (defaultColumns < 12) {
                      breakpoints['9999'] = defaultColumns + 1;
                      _updateBreakpointsWithSorting(breakpoints);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // 宽屏下的原有布局
      return ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.settings,
              size: 20,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        title: Text(slang.t.layoutSettings.defaultColumns),
        subtitle: Text(slang.t.layoutSettings.defaultColumnsDesc),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                final breakpoints = _getSafeBreakpoints();
                final defaultColumns = breakpoints['9999'] ?? 6;
                if (defaultColumns > 1) {
                  breakpoints['9999'] = defaultColumns - 1;
                  _updateBreakpointsWithSorting(breakpoints);
                }
              },
            ),
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${_getSafeBreakpoints()['9999'] ?? 6}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final breakpoints = _getSafeBreakpoints();
                final defaultColumns = breakpoints['9999'] ?? 6;
                if (defaultColumns < 12) {
                  breakpoints['9999'] = defaultColumns + 1;
                  _updateBreakpointsWithSorting(breakpoints);
                }
              },
            ),
          ],
        ),
      );
    }
  }

  /// 安全获取断点配置，确保类型正确
  Map<String, int> _getSafeBreakpoints() {
    final breakpointsRaw = _configService[ConfigKey.LAYOUT_BREAKPOINTS];
    
    if (breakpointsRaw is Map<String, int>) {
      return breakpointsRaw;
    } else if (breakpointsRaw is Map) {
      // 如果类型不匹配，尝试转换
      return Map<String, int>.from(breakpointsRaw.map((key, value) => 
        MapEntry(key.toString(), value is int ? value : int.tryParse(value.toString()) ?? 6)));
    } else {
      // 如果获取失败，使用默认值
      return <String, int>{
        '600': 2,
        '900': 3,
        '1200': 4,
        '1500': 5,
        '9999': 6,
      };
    }
  }

  List<Widget> _buildBreakpointList() {
    final breakpoints = _getSafeBreakpoints();
    final sortedEntries = breakpoints.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    // 过滤掉默认值（9999）
    final userBreakpoints = sortedEntries.where((entry) => entry.key != '9999').toList();

    if (userBreakpoints.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  slang.t.layoutSettings.noCustomBreakpoints,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    final isNarrowScreen = MediaQuery.of(context).size.width < 600;

    return userBreakpoints.asMap().entries.map((entry) {
      final index = entry.key;
      final breakpointEntry = entry.value;
      final width = breakpointEntry.key;
      final columns = breakpointEntry.value;
      
      // 计算区间说明 - 简化显示
      String rangeDescription;
      if (index == 0) {
        rangeDescription = slang.t.layoutSettings.breakpointRangeDescFirst(width: width);
      } else {
        final prevWidth = userBreakpoints[index - 1].key;
        rangeDescription = slang.t.layoutSettings.breakpointRangeDescMiddle(
          start: (int.parse(prevWidth) + 1).toString(),
          end: width,
        );
      }

      if (isNarrowScreen) {
        // 窄屏下的紧凑布局
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '$columns',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rangeDescription,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$columns ${slang.t.layoutSettings.columns}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Text(slang.t.layoutSettings.edit),
                    onPressed: () => _showEditBreakpointDialog(width, columns),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: Text(slang.t.layoutSettings.delete),
                    onPressed: () => _showDeleteBreakpointDialog(width),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        // 宽屏下的原有布局
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$columns',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          title: Text(rangeDescription),
          subtitle: Text('$columns ${slang.t.layoutSettings.columns}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showEditBreakpointDialog(width, columns),
                tooltip: slang.t.layoutSettings.edit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showDeleteBreakpointDialog(width),
                tooltip: slang.t.layoutSettings.delete,
              ),
            ],
          ),
        );
      }
    }).toList();
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              slang.t.layoutSettings.previewEffect,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.screen_rotation,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${MediaQuery.of(context).size.width.toInt()}px',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    Obx(() {
                      final columns = _calculatePreviewColumns();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$columns ${slang.t.layoutSettings.columns}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPreviewGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewGrid() {
    return Obx(() {
      final columns = _calculatePreviewColumns();
      return Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.5,
          ),
          itemCount: columns * 2,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  int _calculatePreviewColumns() {
    final layoutMode = _configService[ConfigKey.LAYOUT_MODE] as String;
    if (layoutMode == 'manual') {
      return _configService[ConfigKey.MANUAL_COLUMNS_COUNT] as int;
    } else {
      final breakpoints = _getSafeBreakpoints();
      final screenWidth = MediaQuery.of(context).size.width;
      
      final sortedBreakpoints = breakpoints.entries
          .map((e) => MapEntry(int.parse(e.key), e.value))
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      
      for (final entry in sortedBreakpoints) {
        if (screenWidth <= entry.key) {
          return entry.value;
        }
      }
      
      return sortedBreakpoints.last.value;
    }
  }

  void _showAddBreakpointDialog() {
    final widthController = TextEditingController();
    final columnsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    Get.dialog(
      AlertDialog(
        title: Text(slang.t.layoutSettings.addBreakpoint),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: widthController,
                decoration: InputDecoration(
                  labelText: slang.t.layoutSettings.screenWidthLabel,
                  hintText: slang.t.layoutSettings.screenWidthHint,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return slang.t.layoutSettings.enterWidth;
                  }
                  final width = int.tryParse(value);
                  if (width == null || width <= 0) {
                    return slang.t.layoutSettings.enterValidWidth;
                  }
                  if (width > 9999) {
                    return slang.t.layoutSettings.widthCannotExceed9999;
                  }
                  
                  // 检查是否已存在相同的断点
                  final breakpoints = _getSafeBreakpoints();
                  if (breakpoints.containsKey(width.toString())) {
                    return slang.t.layoutSettings.breakpointAlreadyExists;
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: columnsController,
                decoration: InputDecoration(
                  labelText: slang.t.layoutSettings.columnsLabel,
                  hintText: slang.t.layoutSettings.columnsHint,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return slang.t.layoutSettings.enterColumns;
                  }
                  final columns = int.tryParse(value);
                  if (columns == null || columns <= 0) {
                    return slang.t.layoutSettings.enterValidColumns;
                  }
                  if (columns > 12) {
                    return slang.t.layoutSettings.columnsCannotExceed12;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.layoutSettings.cancel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final width = int.parse(widthController.text);
                final columns = int.parse(columnsController.text);
                
                final breakpoints = _getSafeBreakpoints();
                breakpoints[width.toString()] = columns;
                
                // 自动排序并保存
                _updateBreakpointsWithSorting(breakpoints);
                AppService.tryPop();
              }
            },
            child: Text(slang.t.layoutSettings.add),
          ),
        ],
      ),
    );
  }

  void _showEditBreakpointDialog(String width, int columns) {
    final widthController = TextEditingController(text: width);
    final columnsController = TextEditingController(text: columns.toString());
    final formKey = GlobalKey<FormState>();
    
    Get.dialog(
      AlertDialog(
        title: Text(slang.t.layoutSettings.editBreakpoint),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: widthController,
                decoration: InputDecoration(
                  labelText: slang.t.layoutSettings.screenWidthLabel,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return slang.t.layoutSettings.enterWidth;
                  }
                  final newWidth = int.tryParse(value);
                  if (newWidth == null || newWidth <= 0) {
                    return slang.t.layoutSettings.enterValidWidth;
                  }
                  if (newWidth > 9999) {
                    return slang.t.layoutSettings.widthCannotExceed9999;
                  }
                  
                  // 检查是否与其他断点冲突（排除当前断点）
                  final breakpoints = _getSafeBreakpoints();
                  if (newWidth.toString() != width && breakpoints.containsKey(newWidth.toString())) {
                    return slang.t.layoutSettings.breakpointConflict;
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: columnsController,
                decoration: InputDecoration(
                  labelText: slang.t.layoutSettings.columnsLabel,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return slang.t.layoutSettings.enterColumns;
                  }
                  final newColumns = int.tryParse(value);
                  if (newColumns == null || newColumns <= 0) {
                    return slang.t.layoutSettings.enterValidColumns;
                  }
                  if (newColumns > 12) {
                    return slang.t.layoutSettings.columnsCannotExceed12;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.layoutSettings.cancel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newWidth = int.parse(widthController.text);
                final newColumns = int.parse(columnsController.text);
                
                final breakpoints = _getSafeBreakpoints();
                breakpoints.remove(width);
                breakpoints[newWidth.toString()] = newColumns;
                
                // 自动排序并保存
                _updateBreakpointsWithSorting(breakpoints);
                AppService.tryPop();
              }
            },
            child: Text(slang.t.layoutSettings.save),
          ),
        ],
      ),
    );
  }

  /// 更新断点配置并自动排序
  void _updateBreakpointsWithSorting(Map<String, int> breakpoints) {
    // 确保默认值（9999）始终存在
    if (!breakpoints.containsKey('9999')) {
      breakpoints['9999'] = 6;
    }
    
    // 按宽度排序
    final sortedEntries = breakpoints.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    
    // 重新构建有序的Map
    final sortedBreakpoints = <String, int>{};
    for (final entry in sortedEntries) {
      sortedBreakpoints[entry.key] = entry.value;
    }
    
    _configService[ConfigKey.LAYOUT_BREAKPOINTS] = sortedBreakpoints;
  }

  /// 显示重置确认对话框
  void _showResetConfirmDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(slang.t.layoutSettings.confirmResetLayoutSettings),
        content: Text(slang.t.layoutSettings.confirmResetLayoutSettingsDesc),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.layoutSettings.cancel),
          ),
          TextButton(
            onPressed: () {
              _resetToDefaults();
              AppService.tryPop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(slang.t.layoutSettings.resetToDefaults),
          ),
        ],
      ),
    );
  }

  /// 重置所有布局设置到默认值
  void _resetToDefaults() {
    // 重置布局模式
    _configService[ConfigKey.LAYOUT_MODE] = 'auto';
    
    // 重置手动列数
    _configService[ConfigKey.MANUAL_COLUMNS_COUNT] = 3;
    _columnsController.text = '3';
    
    // 重置断点配置到默认值
    final defaultBreakpoints = <String, int>{
      '600': 2,
      '900': 3,
      '1200': 4,
      '1500': 5,
      '9999': 6,
    };
    _configService[ConfigKey.LAYOUT_BREAKPOINTS] = defaultBreakpoints;
  }

  void _showDeleteBreakpointDialog(String width) {
    Get.dialog(
      AlertDialog(
        title: Text(slang.t.layoutSettings.confirmDeleteBreakpoint),
        content: Text(slang.t.layoutSettings.confirmDeleteBreakpointDesc(width: width)),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.layoutSettings.cancel),
          ),
          TextButton(
            onPressed: () {
              final breakpoints = _getSafeBreakpoints();
              breakpoints.remove(width);
              _updateBreakpointsWithSorting(breakpoints);
              AppService.tryPop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(slang.t.layoutSettings.delete),
          ),
        ],
      ),
    );
  }
}
