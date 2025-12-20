/// IWARA 状态页面的数据模型
library;

/// 服务器状态
enum IwaraServerStatus {
  completed('Completed'),
  inProgress('In progress'),
  inProgressWithFailures('In progress with failures...'),
  error('Error'),
  queuing('Queuing...'),
  initializing('Initializing...'),
  housekeeping('Housekeeping...');

  const IwaraServerStatus(this.displayName);
  final String displayName;

  static IwaraServerStatus? fromString(String status) {
    for (final value in IwaraServerStatus.values) {
      if (status.contains(value.displayName) || 
          status == value.displayName ||
          (value == inProgress && status.contains('In progress'))) {
        return value;
      }
    }
    return null;
  }
}

/// 分发环状态
enum IwaraDistributionRingStatus {
  completed('Completed'),
  inProgress('In progress'),
  inProgressWithFailures('In progress with failures...');

  const IwaraDistributionRingStatus(this.displayName);
  final String displayName;

  static IwaraDistributionRingStatus? fromString(String status) {
    for (final value in IwaraDistributionRingStatus.values) {
      if (status.contains(value.displayName)) {
        return value;
      }
    }
    return null;
  }
}

/// 服务器信息
class IwaraServer {
  final String name;
  final String config;
  final IwaraServerStatus status;
  final String? progress; // 例如 "0.00%"

  const IwaraServer({
    required this.name,
    required this.config,
    required this.status,
    this.progress,
  });

  factory IwaraServer.fromJson(Map<String, dynamic> json) {
    return IwaraServer(
      name: json['name'] as String,
      config: json['config'] as String,
      status: IwaraServerStatus.fromString(json['status'] as String) ?? 
              IwaraServerStatus.queuing,
      progress: json['progress'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'config': config,
      'status': status.displayName,
      'progress': progress,
    };
  }

  @override
  String toString() {
    return 'IwaraServer{name: $name, config: $config, status: ${status.displayName}, progress: $progress}';
  }
}

/// 分发环信息
class IwaraDistributionRing {
  final DateTime? lastDistributionTime;
  final IwaraDistributionRingStatus status;
  final bool? globalHousekeeping; // null 表示未设置
  final bool? recentHousekeeping; // null 表示未设置
  final List<IwaraServer> servers;

  const IwaraDistributionRing({
    this.lastDistributionTime,
    required this.status,
    this.globalHousekeeping,
    this.recentHousekeeping,
    required this.servers,
  });

  factory IwaraDistributionRing.fromJson(Map<String, dynamic> json) {
    return IwaraDistributionRing(
      lastDistributionTime: json['lastDistributionTime'] != null
          ? DateTime.parse(json['lastDistributionTime'] as String)
          : null,
      status: IwaraDistributionRingStatus.fromString(
              json['status'] as String) ??
          IwaraDistributionRingStatus.inProgress,
      globalHousekeeping: json['globalHousekeeping'] as bool?,
      recentHousekeeping: json['recentHousekeeping'] as bool?,
      servers: (json['servers'] as List<dynamic>)
          .map((e) => IwaraServer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastDistributionTime': lastDistributionTime?.toIso8601String(),
      'status': status.displayName,
      'globalHousekeeping': globalHousekeeping,
      'recentHousekeeping': recentHousekeeping,
      'servers': servers.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'IwaraDistributionRing{lastDistributionTime: $lastDistributionTime, status: ${status.displayName}, servers: ${servers.length}}';
  }
}

/// IWARA 状态页面完整信息
class IwaraStatusPage {
  final IwaraDistributionRing fastRing;
  final IwaraDistributionRing? pushRing;
  final IwaraDistributionRing slowRing;

  const IwaraStatusPage({
    required this.fastRing,
    this.pushRing,
    required this.slowRing,
  });

  factory IwaraStatusPage.fromJson(Map<String, dynamic> json) {
    return IwaraStatusPage(
      fastRing: IwaraDistributionRing.fromJson(
          json['fastRing'] as Map<String, dynamic>),
      pushRing: json['pushRing'] != null
          ? IwaraDistributionRing.fromJson(
              json['pushRing'] as Map<String, dynamic>)
          : null,
      slowRing: IwaraDistributionRing.fromJson(
          json['slowRing'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fastRing': fastRing.toJson(),
      'pushRing': pushRing?.toJson(),
      'slowRing': slowRing.toJson(),
    };
  }

  @override
  String toString() {
    return 'IwaraStatusPage{fastRing: $fastRing, pushRing: $pushRing, slowRing: $slowRing}';
  }
}
