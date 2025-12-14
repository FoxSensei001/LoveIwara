import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../models/iwara_status.model.dart';
import 'package:flutter/foundation.dart';

class IwaraStatusHtmlParser {
  /// 解析 distribution 页面 HTML
  static IwaraStatusPage parseDistributionPage(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final contentElement = document.querySelector('#content');
    
    if (contentElement == null) {
      throw Exception('无法找到 content 元素');
    }

    final contentText = contentElement.text;
    
    // 解析 Fast ring
    final fastRing = _parseFastRing(contentElement, contentText);
    
    // 解析 Push ring
    final pushRing = _parsePushRing(contentElement, contentText);
    
    // 解析 Slow ring
    final slowRing = _parseSlowRing(contentElement, contentText);

    return IwaraStatusPage(
      fastRing: fastRing,
      pushRing: pushRing,
      slowRing: slowRing,
    );
  }

  /// 解析 Fast ring distribution
  static IwaraDistributionRing _parseFastRing(Element contentElement, String contentText) {
    // 提取时间
    final fastRingTimeMatch = RegExp(
      r'Last fast ring distribution time:\s*(\d{4}\.\d{2}\.\d{2}\s+\d{2}:\d{2}:\d{2})',
    ).firstMatch(contentText);
    
    DateTime? lastDistributionTime;
    if (fastRingTimeMatch != null) {
      lastDistributionTime = _parseDateTime(fastRingTimeMatch.group(1)!);
    }

    // 提取状态
    final fastRingStatusMatch = RegExp(
      r'Fast ring distribution.*?Status:\s*([^<]+?)(?:\n|$)',
      dotAll: true,
    ).firstMatch(contentText);
    
    final statusText = fastRingStatusMatch?.group(1)?.trim() ?? 'In progress';
    final status = IwaraDistributionRingStatus.fromString(statusText) ?? 
                   IwaraDistributionRingStatus.inProgress;

    // 提取 housekeeping 设置
    final globalHousekeepingMatch = RegExp(
      r'Fast ring distribution global housekeeping:\s*(Enabled|Disabled)',
    ).firstMatch(contentText);
    final globalHousekeeping = globalHousekeepingMatch != null
        ? globalHousekeepingMatch.group(1) == 'Enabled'
        : null;

    final recentHousekeepingMatch = RegExp(
      r'Fast ring distribution recent housekeeping:\s*(Enabled|Disabled)',
    ).firstMatch(contentText);
    final recentHousekeeping = recentHousekeepingMatch != null
        ? recentHousekeepingMatch.group(1) == 'Enabled'
        : null;

    // 提取服务器列表
    final servers = _parseServerTable(contentElement, 'fast');

    return IwaraDistributionRing(
      lastDistributionTime: lastDistributionTime,
      status: status,
      globalHousekeeping: globalHousekeeping,
      recentHousekeeping: recentHousekeeping,
      servers: servers,
    );
  }

  /// 解析 Push ring distribution
  static IwaraDistributionRing? _parsePushRing(Element contentElement, String contentText) {
    // 检查是否存在 push ring
    if (!contentText.contains('Last push ring distribution time:')) {
      return null;
    }

    // 提取时间
    final pushRingTimeMatch = RegExp(
      r'Last push ring distribution time:\s*(\d{4}\.\d{2}\.\d{2}\s+\d{2}:\d{2}:\d{2})',
    ).firstMatch(contentText);
    
    DateTime? lastDistributionTime;
    if (pushRingTimeMatch != null) {
      lastDistributionTime = _parseDateTime(pushRingTimeMatch.group(1)!);
    }

    // 提取状态
    final pushRingStatusMatch = RegExp(
      r'Last push ring distribution time:.*?Status:\s*([^<]+?)(?:\n|$)',
      dotAll: true,
    ).firstMatch(contentText);
    
    final statusText = pushRingStatusMatch?.group(1)?.trim() ?? 'In progress';
    final status = IwaraDistributionRingStatus.fromString(statusText) ?? 
                   IwaraDistributionRingStatus.inProgress;

    // 提取服务器列表
    final servers = _parseServerTable(contentElement, 'push');

    return IwaraDistributionRing(
      lastDistributionTime: lastDistributionTime,
      status: status,
      servers: servers,
    );
  }

  /// 解析 Slow ring distribution
  static IwaraDistributionRing _parseSlowRing(Element contentElement, String contentText) {
    // 提取时间
    final slowRingTimeMatch = RegExp(
      r'Last slow ring distribution time:\s*(\d{4}\.\d{2}\.\d{2}\s+\d{2}:\d{2}:\d{2})',
    ).firstMatch(contentText);
    
    DateTime? lastDistributionTime;
    if (slowRingTimeMatch != null) {
      lastDistributionTime = _parseDateTime(slowRingTimeMatch.group(1)!);
    }

    // 提取状态
    final slowRingStatusMatch = RegExp(
      r'Last slow ring distribution time:.*?Status:\s*([^<]+?)(?:\n|$)',
      dotAll: true,
    ).firstMatch(contentText);
    
    final statusText = slowRingStatusMatch?.group(1)?.trim() ?? 'In progress';
    final status = IwaraDistributionRingStatus.fromString(statusText) ?? 
                   IwaraDistributionRingStatus.inProgress;

    // 提取 housekeeping 设置
    final housekeepingMatch = RegExp(
      r'Slow ring distribution housekeeping:\s*(Enabled|Disabled)',
    ).firstMatch(contentText);
    final housekeeping = housekeepingMatch != null
        ? housekeepingMatch.group(1) == 'Enabled'
        : null;

    // 提取服务器列表
    final servers = _parseServerTable(contentElement, 'slow');

    return IwaraDistributionRing(
      lastDistributionTime: lastDistributionTime,
      status: status,
      recentHousekeeping: housekeeping,
      servers: servers,
    );
  }

  /// 解析服务器表格
  static List<IwaraServer> _parseServerTable(Element contentElement, String ringType) {
    final servers = <IwaraServer>[];
    
    // 找到所有表格
    final tables = contentElement.querySelectorAll('table.cslist');
    
    // 根据 ringType 选择对应的表格
    Element? targetTable;
    if (ringType == 'fast') {
      // Fast ring 是第一个表格
      targetTable = tables.isNotEmpty ? tables[0] : null;
    } else if (ringType == 'push') {
      // Push ring 是第二个表格（如果存在）
      targetTable = tables.length > 1 ? tables[1] : null;
    } else if (ringType == 'slow') {
      // Slow ring 是最后一个表格
      targetTable = tables.isNotEmpty ? tables[tables.length - 1] : null;
    }

    if (targetTable == null) {
      return servers;
    }

    // 解析表格行
    final rows = targetTable.querySelectorAll('tr');
    for (final row in rows) {
      final cells = row.querySelectorAll('td');
      if (cells.length >= 3) {
        final name = cells[0].text.trim();
        final config = cells[1].text.trim();
        final statusText = cells[2].text.trim();
        
        // 解析状态和进度
        IwaraServerStatus status;
        String? progress;
        
        // 检查是否包含进度信息，例如 "In progress... (0.00%)"
        final progressMatch = RegExp(r'\(([\d.]+%)\)').firstMatch(statusText);
        if (progressMatch != null) {
          progress = progressMatch.group(1);
        }
        
        status = IwaraServerStatus.fromString(statusText) ?? 
                 IwaraServerStatus.queuing;

        servers.add(IwaraServer(
          name: name,
          config: config,
          status: status,
          progress: progress,
        ));
      }
    }

    return servers;
  }

  /// 解析日期时间字符串
  /// 格式: "2025.12.07 15:08:53"
  static DateTime? _parseDateTime(String dateTimeStr) {
    try {
      // 将 "2025.12.07 15:08:53" 转换为 "2025-12-07 15:08:53"
      final normalized = dateTimeStr.replaceAll('.', '-');
      final parts = normalized.split(' ');
      
      if (parts.length == 2) {
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');
        
        if (dateParts.length == 3 && timeParts.length == 3) {
          final year = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final day = int.parse(dateParts[2]);
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final second = int.parse(timeParts[2]);
          
          return DateTime(year, month, day, hour, minute, second);
        }
      }
    } catch (e) {
      debugPrint('解析日期时间失败: $e, 输入: $dateTimeStr');
    }
    return null;
  }
}

