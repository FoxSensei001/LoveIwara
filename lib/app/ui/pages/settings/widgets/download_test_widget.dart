import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';
import 'dart:io';

/// 下载功能测试组件
class DownloadTestWidget extends StatefulWidget {
  const DownloadTestWidget({super.key});

  @override
  State<DownloadTestWidget> createState() => _DownloadTestWidgetState();
}

class _DownloadTestWidgetState extends State<DownloadTestWidget> {
  bool _isTesting = false;
  List<TestResult> _testResults = [];

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  t.settings.downloadSettings.functionalTest,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isTesting ? null : _runTests,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isTesting ? t.settings.downloadSettings.testInProgress : t.settings.downloadSettings.runTest),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              t.settings.downloadSettings.testDownloadPathAndPermissions,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),

            if (_testResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                t.settings.downloadSettings.testResults,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              ..._testResults.map((result) => _buildTestResultItem(result)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultItem(TestResult result) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            result.passed ? Icons.check_circle : Icons.error,
            color: result.passed ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (result.message.isNotEmpty)
            Tooltip(
              message: result.message,
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _runTests() async {
    final t = slang.Translations.of(context);
    setState(() {
      _isTesting = true;
      _testResults.clear();
    });

    try {
      final results = <TestResult>[];

      // 测试1: 权限检查
      results.add(await _testPermissions());

      // 测试2: 路径验证
      results.add(await _testPathValidation());

      // 测试3: 文件命名模板
      results.add(await _testFilenameTemplates());

      // 测试4: 目录创建和写入
      results.add(await _testDirectoryOperations());

      setState(() {
        _testResults = results;
      });

      final passedCount = results.where((r) => r.passed).length;
      final totalCount = results.length;

      showToast('${t.settings.downloadSettings.testCompleted}: $passedCount/$totalCount ${t.settings.downloadSettings.testPassed}');
    } catch (e) {
      showToast('${t.settings.downloadSettings.testFailed}: $e');
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<TestResult> _testPermissions() async {
    final t = slang.Translations.of(context);
    try {
      final permissionService = Get.find<PermissionService>();
      final hasPermission = await permissionService.hasStoragePermission();

      return TestResult(
        name: t.settings.downloadSettings.testStoragePermissionCheck,
        passed: true,
        message: hasPermission ? t.settings.downloadSettings.testStoragePermissionGranted : t.settings.downloadSettings.testStoragePermissionMissing,
      );
    } catch (e) {
      return TestResult(
        name: t.settings.downloadSettings.testStoragePermissionCheck,
        passed: false,
        message: '${t.settings.downloadSettings.testPermissionCheckFailed}: $e',
      );
    }
  }

  Future<TestResult> _testPathValidation() async {
    final t = slang.Translations.of(context);
    try {
      final downloadPathService = Get.find<DownloadPathService>();
      final pathInfo = await downloadPathService.getPathStatusInfo();

      return TestResult(
        name: t.settings.downloadSettings.testDownloadPathValidation,
        passed: pathInfo.isValid,
        message: pathInfo.validationResult.message,
      );
    } catch (e) {
      return TestResult(
        name: t.settings.downloadSettings.testDownloadPathValidation,
        passed: false,
        message: '${t.settings.downloadSettings.testPathValidationFailed}: $e',
      );
    }
  }

  Future<TestResult> _testFilenameTemplates() async {
    final t = slang.Translations.of(context);
    try {
      final filenameService = Get.find<FilenameTemplateService>();
      final configService = Get.find<ConfigService>();

      final videoTemplate = configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String;
      final galleryTemplate = configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] as String;
      final imageTemplate = configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] as String;

      final videoValid = filenameService.validateTemplate(videoTemplate);
      final galleryValid = filenameService.validateTemplate(galleryTemplate);
      final imageValid = filenameService.validateTemplate(imageTemplate);

      final allValid = videoValid && galleryValid && imageValid;

      return TestResult(
        name: t.settings.downloadSettings.testFilenameTemplateValidation,
        passed: allValid,
        message: allValid ? t.settings.downloadSettings.testAllTemplatesValid : t.settings.downloadSettings.testSomeTemplatesInvalid,
      );
    } catch (e) {
      return TestResult(
        name: t.settings.downloadSettings.testFilenameTemplateValidation,
        passed: false,
        message: '${t.settings.downloadSettings.testTemplateValidationFailed}: $e',
      );
    }
  }

  Future<TestResult> _testDirectoryOperations() async {
    final t = slang.Translations.of(context);
    try {
      final downloadPathService = Get.find<DownloadPathService>();
      final pathInfo = await downloadPathService.getPathStatusInfo();
      final testPath = '${pathInfo.currentPath}/test';

      // 尝试创建测试目录
      final testDir = Directory(testPath);
      if (!await testDir.exists()) {
        await testDir.create(recursive: true);
      }

      // 尝试写入测试文件
      final testFile = File('$testPath/.download_test');
      await testFile.writeAsString('test');

      // 清理测试文件
      await testFile.delete();
      if (await testDir.exists()) {
        await testDir.delete();
      }

      return TestResult(
        name: t.settings.downloadSettings.testDirectoryOperationTest,
        passed: true,
        message: t.settings.downloadSettings.testDirectoryOperationNormal,
      );
    } catch (e) {
      return TestResult(
        name: t.settings.downloadSettings.testDirectoryOperationTest,
        passed: false,
        message: '${t.settings.downloadSettings.testDirectoryOperationFailed}: $e',
      );
    }
  }
}

/// 测试结果
class TestResult {
  final String name;
  final bool passed;
  final String message;

  TestResult({
    required this.name,
    required this.passed,
    required this.message,
  });
}
